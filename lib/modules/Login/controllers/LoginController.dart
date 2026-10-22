import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../includes/Storage.dart';
import '../requests/LoginRequest.dart';
import '../routes/LoginRoutes.dart';

class LoginController extends GetxController {
  static const phoneStorageKey = 'login_phone';
  static const otpStorageKey = 'pending_otp';

  final LoginRequest _request = LoginRequest();
  final phoneController = TextEditingController();
  final isSending = false.obs;

  String get phone => phoneController.text.replaceAll(RegExp(r'\D'), '');

  @override
  void onInit() {
    super.onInit();
    phoneController.text = LocalStorage.read(phoneStorageKey) ?? '';
  }

  Future<void> sendOtp() async {
    if (phone.length != 10) {
      _showError('Enter a valid 10-digit mobile number.');
      return;
    }
    if (isSending.value) return;

    isSending.value = true;
    final response = await _request.sendOtp(phone);
    isSending.value = false;
    if (!response.isSuccess) {
      _showError(response.message);
      return;
    }

    final otp = _findOtp(response.data);
    await LocalStorage.write(phoneStorageKey, phone);
    if (otp.isNotEmpty) {
      await LocalStorage.write(otpStorageKey, otp);
    } else {
      await LocalStorage.remove(otpStorageKey);
    }

    Get.toNamed(
      LoginRoutes.otpPage,
      arguments: {'phone': phone, 'otp': otp},
    );
  }

  String _findOtp(dynamic value) {
    if (value is String || value is num) {
      final digits = value.toString().replaceAll(RegExp(r'\D'), '');
      return digits.length == 4 ? digits : '';
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
      final digits = direct.toString().replaceAll(RegExp(r'\D'), '');
      if (digits.length == 4) return digits;
    }
    for (final nested in value.values) {
      final found = _findOtp(nested);
      if (found.isNotEmpty) return found;
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
    phoneController.dispose();
    super.onClose();
  }
}
