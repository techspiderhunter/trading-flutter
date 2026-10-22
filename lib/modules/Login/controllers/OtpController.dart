import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global/controllers/FlutterMessageController.dart';
import '../../../includes/Storage.dart';

import '../models/LoginModel.dart';
import '../requests/LoginRequest.dart';
import 'LoginController.dart';

class OtpController extends GetxController {
  final LoginRequest _request = LoginRequest();
  final otpController = TextEditingController();
  final otpValue = ''.obs;
  final isVerifying = false.obs;
  final isResending = false.obs;
  final secondsRemaining = 30.obs;
  final canResend = false.obs;
  Timer? _timer;
  bool _autoVerificationScheduled = false;

  late final String phone;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments is Map ? Get.arguments as Map : const {};
    phone = (args['phone'] ??
            LocalStorage.read(LoginController.phoneStorageKey) ??
            '')
        .toString();
    final storedOtp =
        (args['otp'] ?? LocalStorage.read(LoginController.otpStorageKey) ?? '')
            .toString();
    setOtp(storedOtp);
    _startTimer();
    _scheduleAutoVerification();
  }

  String get maskedPhone => phone.length == 10
      ? '${phone.substring(0, 2)}******${phone.substring(8)}'
      : phone;

  Future<void> verifyOtp() async {
    final otp = _fourDigits(otpController.text);
    if (phone.length != 10) {
      _showError('Mobile number is missing. Please return and login again.');
      return;
    }
    if (otp.length != 4) {
      _showError('Enter the 4-digit OTP.');
      return;
    }
    if (isVerifying.value) return;

    isVerifying.value = true;
    final response = await _request.verifyOtp(phone, otp);
    if (!response.isSuccess) {
      isVerifying.value = false;
      _autoVerificationScheduled = false;
      _showError(response.message);
      return;
    }

    final tokenData = _findTokenData(response.data);
    final login = LoginModel.fromJson(tokenData ?? const {});
    if (login.token.isEmpty) {
      isVerifying.value = false;
      _showError(
          'OTP verified, but the server did not return an access token.');
      return;
    }

    await _saveLoginSession(tokenData ?? const {}, login.token);
    await _registerDeviceToken();
    await LocalStorage.write(LoginController.phoneStorageKey, phone);
    await LocalStorage.remove(LoginController.otpStorageKey);
    isVerifying.value = false;
    final nextRoute = _nextRoute(tokenData);
    Get.offAllNamed(
      nextRoute,
      arguments: nextRoute == ''
    );
  }

  Future<void> resendOtp() async {
    if (!canResend.value || isResending.value || phone.length != 10) return;
    isResending.value = true;
    final response = await _request.sendOtp(phone);
    isResending.value = false;
    if (!response.isSuccess) {
      _showError(response.message);
      return;
    }

    final otp = _findOtp(response.data);
    setOtp(otp);
    if (otp.isNotEmpty) {
      await LocalStorage.write(LoginController.otpStorageKey, otp);
    } else {
      await LocalStorage.remove(LoginController.otpStorageKey);
    }
    _autoVerificationScheduled = false;
    _startTimer();
    _scheduleAutoVerification();
  }

  void updateOtp(String? value) {
    final otp = _fourDigits(value ?? '');
    otpValue.value = otp;
    if (otp.length == 4) {
      LocalStorage.write(LoginController.otpStorageKey, otp);
    }
  }

  void setOtp(String value) {
    final otp = _fourDigits(value);
    otpValue.value = otp;
    if (otpController.text == otp) return;
    otpController.value = TextEditingValue(
      text: otp,
      selection: TextSelection.collapsed(offset: otp.length),
    );
  }

  void _scheduleAutoVerification() {
    if (_autoVerificationScheduled || otpController.text.length != 4) return;
    _autoVerificationScheduled = true;
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (!isClosed && otpController.text.length == 4) verifyOtp();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    secondsRemaining.value = 30;
    canResend.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value <= 1) {
        secondsRemaining.value = 0;
        canResend.value = true;
        timer.cancel();
      } else {
        secondsRemaining.value--;
      }
    });
  }

  String _fourDigits(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length > 4 ? digits.substring(0, 4) : digits;
  }

  String _findOtp(dynamic value) {
    if (value is String || value is num) {
      final otp = _fourDigits(value.toString());
      return otp.length == 4 ? otp : '';
    }
    if (value is List) {
      for (final nested in value) {
        final found = _findOtp(nested);
        if (found.isNotEmpty) return found;
      }
      return '';
    }
    if (value is! Map) return '';
    final direct = value['otp'] ?? value['code'] ?? value['otp_code'];
    if (direct != null) {
      final otp = _fourDigits(direct.toString());
      if (otp.length == 4) return otp;
    }
    for (final nested in value.values) {
      final found = _findOtp(nested);
      if (found.isNotEmpty) return found;
    }
    return '';
  }

  Map<String, dynamic>? _findTokenData(dynamic value) {
    if (value is! Map) return null;
    final map = Map<String, dynamic>.from(value);
    if (map.containsKey('token') || map.containsKey('access_token')) return map;
    for (final nested in map.values) {
      final found = _findTokenData(nested);
      if (found != null) return found;
    }
    return null;
  }

  Future<void> _saveLoginSession(
    Map<String, dynamic> tokenData,
    String token,
  ) async {
    await LocalStorage.write(LocalStorage.tokenKey, token);
    await LocalStorage.write(
      LocalStorage.authStatusKey,
      (tokenData['status'] ?? '').toString(),
    );
    await LocalStorage.write(
      LocalStorage.isVehicleKey,
      (tokenData['is_vehicle'] ?? '').toString(),
    );
    await LocalStorage.write(
      LocalStorage.isRegisteredKey,
      (tokenData['is_registered'] ?? '').toString(),
    );
    await LocalStorage.write(
      LocalStorage.nextStepKey,
      (tokenData['next_step'] ?? '').toString(),
    );
    await LocalStorage.write(
      'auth_response',
      jsonEncode(tokenData),
    );
  }

  Future<void> _registerDeviceToken() async {
    try {
      if (!Get.isRegistered<FCMController>()) return;
      await Get.find<FCMController>().registerDeviceToken();
    } catch (_) {
      return;
    }
  }

  String _nextRoute(Map<String, dynamic>? tokenData) {
    final hasVehicle = tokenData?['is_vehicle']?.toString() == '1';
    final nextStep = tokenData?['next_step']?.toString().toUpperCase();

    if (hasVehicle || nextStep == 'DASHBOARD') {
      return '';
    }
    return '';
  }

  void _showError(String message) => Get.snackbar(
        'Unable to continue',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    super.onClose();
  }
}
