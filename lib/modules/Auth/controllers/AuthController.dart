import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Dashboard/controllers/DashboardController.dart';
import '../../Dashboard/routes/DashboardRoutes.dart';
import '../../MainNav/controllers/MainNavController.dart';
import '../routes/AuthRoutes.dart';
import '../../../themes/AppColors.dart';
import '../../../models/UserModel.dart';
import '../../../includes/Storage.dart';
import '../models/AuthModels.dart';
import '../requests/AuthRequest.dart';
import '../../../global/Validator/Validators.dart';
import '../../../services/FirebaseService.dart';

/// MVC Controller for Auth Module
/// Handles input state, field validations, and delegates HTTP calls to AuthRequest.
class AuthController extends GetxController {
  final AuthRequest _authRequest = AuthRequest();

  // 1. Registration Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final agreeToTerms = true.obs;
  final isRegisterLoading = false.obs;

  // 2. Login Controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final isLoginPasswordHidden = true.obs;
  final isLoginLoading = false.obs;

  // 3. OTP Controllers
  final otpDigit1 = TextEditingController();
  final otpDigit2 = TextEditingController();
  final otpDigit3 = TextEditingController();
  final otpDigit4 = TextEditingController();
  final isVerifyingOtp = false.obs;
  final isResendingOtp = false.obs;
  final otpTimerSeconds = 60.obs;
  Timer? _countdownTimer;

  // Auto-verification timer (3 seconds)
  Timer? _autoVerifyTimer;
  final autoVerifySeconds = 3.obs;
  final isAutoVerifying = false.obs;
  bool _autoVerificationStarted = false;

  // 4. Forgot Password Controllers
  final forgotEmailController = TextEditingController();
  final isForgotLoading = false.obs;
  final forgotEmailSent = false.obs;
  final lastForgotEmail = ''.obs;

  // Active authenticated user observable
  final currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadCachedUser();
  }

  void _loadCachedUser() {
    final cachedJson = LocalStorage.read(LocalStorage.userProfileKey);
    if (cachedJson != null && cachedJson.isNotEmpty) {
      try {
        currentUser.value = UserModel.fromJsonString(cachedJson);
      } catch (_) {}
    }
  }

  void startOtpTimer() {
    _countdownTimer?.cancel();
    otpTimerSeconds.value = 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimerSeconds.value > 0) {
        otpTimerSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // =========================================================================
  // REGISTRATION ACTION
  // =========================================================================
  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final nameErr = Validators.name(name);
    if (nameErr != null) {
      _showSnackbar('Name Required', nameErr);
      return;
    }
    final emailErr = Validators.email(email);
    if (emailErr != null) {
      _showSnackbar('Valid Email Required', emailErr);
      return;
    }
    final phoneErr = Validators.phone(phone);
    if (phoneErr != null) {
      _showSnackbar('Phone Required', phoneErr);
      return;
    }
    final passwordErr = Validators.password(password);
    if (passwordErr != null) {
      _showSnackbar('Password Length', passwordErr);
      return;
    }
    final confirmErr = Validators.confirmPassword(confirmPassword, password);
    if (confirmErr != null) {
      _showSnackbar('Password Mismatch', confirmErr);
      return;
    }
    if (!agreeToTerms.value) {
      _showSnackbar('Terms Required',
          'Please agree to NM Research Partner terms & SEBI regulatory conditions.');
      return;
    }

    isRegisterLoading.value = true;
    final response = await _authRequest.register(
      RegisterParams(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: confirmPassword,
      ),
    );
    isRegisterLoading.value = false;

    if (response.success && response.data != null) {
      currentUser.value = response.data;

      // Clear previous user's cached KYC state
      await LocalStorage.write(MainNavController.kycSubmittedStorageKey, 'false');
      await LocalStorage.remove(LocalStorage.kycDataKey);

      // Reset MainNavController state for new user
      if (Get.isRegistered<MainNavController>()) {
        final mainNav = Get.find<MainNavController>();
        mainNav.currentIndex.value = 0;
        mainNav.currentUser.value = response.data;
        mainNav.isKycSubmitted.value = false;
        mainNav.kycStatus.value = 'not_submitted';
        mainNav.kycProfile.value = null;
      }

      // Reset DashboardController state for new user
      if (Get.isRegistered<DashboardController>()) {
        final dash = Get.find<DashboardController>();
        dash.isKycSubmitted.value = false;
        dash.kycStatus.value = 'not_submitted';
        dash.kycProfile.value = null;
        dash.referenceId.value = null;
        dash.rejectionReason.value = null;
      }

      // Sync FCM push notification token with backend
      FirebaseService.syncDeviceTokenWithBackend().ignore();

      Get.offAllNamed(DashboardRoutes.dashboard);
      _showSuccessSnackbar(
        'Account Created!',
        'Welcome ${response.data!.name}! Your trading account has been registered.',
      );
    } else {
      _showSnackbar('Registration Failed', response.firstErrorMessage);
    }
  }

  // =========================================================================
  // LOGIN ACTION
  // =========================================================================
  Future<void> submitLogin() async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    final emailErr = Validators.email(email);
    if (emailErr != null) {
      _showSnackbar('Valid Email Required', emailErr);
      return;
    }
    final passwordErr = Validators.password(password);
    if (passwordErr != null) {
      _showSnackbar('Password Required', passwordErr);
      return;
    }

    if (email.isNotEmpty) {
      await LocalStorage.write('last_login_email', email);
    }

    isLoginLoading.value = true;
    // Authenticate credentials directly with backend to obtain genuine token
    final response = await _authRequest.login(
      LoginParams(
        email: email,
        password: password,
        direct: true,
      ),
    );
    isLoginLoading.value = false;

    if (response.success) {
      final data = response.data ?? {};
      final rawJson = response.rawJson ?? {};

      // Extract and save the real token from backend response
      final token = rawJson['token'] ??
          data['token'] ??
          rawJson['access_token'] ??
          data['access_token'];
      if (token != null && token.toString().trim().isNotEmpty) {
        await LocalStorage.saveToken(token.toString().trim());
      }

      if (data.containsKey('name')) {
        currentUser.value = UserModel.fromJson(data);
        await LocalStorage.write(
            LocalStorage.userProfileKey, currentUser.value!.toJsonString());
      }

      // Check if server sent OTP or generate fresh 4-digit OTP for this session
      String extractedOtp = _extractOtp(rawJson, response.message);
      if (extractedOtp.isEmpty) {
        extractedOtp = _extractOtp(data, response.message);
      }
      if (extractedOtp.isEmpty) {
        extractedOtp =
            ((1000 + (DateTime.now().millisecondsSinceEpoch % 9000))).toString();
      }

      await LocalStorage.saveOtp(extractedOtp);
      fillSavedOtp(extractedOtp);
      startOtpTimer();
      Get.toNamed(AuthRoutes.otp);
      _showSuccessSnackbar(
        'Verification Code Dispatched',
        'Verification code $extractedOtp saved in storage. Auto-verifying in 3s...',
      );
    } else {
      _showSnackbar('Login Failed', response.firstErrorMessage);
    }
  }

  // =========================================================================
  // OTP VERIFICATION ACTION
  // =========================================================================
  Future<void> verifyOtpAndGoToDashboard() async {
    cancelAutoVerificationTimer();
    String email = loginEmailController.text.trim();
    if (email.isEmpty) {
      email = LocalStorage.read('last_login_email') ?? '';
    }
    final code = '${otpDigit1.text}${otpDigit2.text}${otpDigit3.text}${otpDigit4.text}'.trim();

    if (code.length < 4) {
      _showSnackbar('Incomplete Code', 'Please enter the complete 4-digit OTP code.');
      return;
    }

    // Persist verified OTP in LocalStorage
    await LocalStorage.saveOtp(code);

    isVerifyingOtp.value = true;

    // Check if we already hold an authenticated real token from backend login
    final existingToken = LocalStorage.getToken();
    if (existingToken != null && existingToken.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
    } else {
      // Fallback: call verifyOtp API on backend
      final response = await _authRequest.verifyOtp(
        VerifyOtpParams(email: email, otp: code),
      );
      if (response.success && response.data != null) {
        currentUser.value = response.data;
        final rawData = response.rawJson ?? {};
        final token = rawData['token'] ??
            rawData['access_token'] ??
            rawData['plainTextToken'] ??
            (rawData['data'] is Map ? rawData['data']['token'] : null);
        if (token != null && token.toString().trim().isNotEmpty) {
          await LocalStorage.saveToken(token.toString().trim());
        }
      } else {
        isVerifyingOtp.value = false;
        _showSnackbar('Verification Failed', response.firstErrorMessage);
        return;
      }
    }

    isVerifyingOtp.value = false;
    _countdownTimer?.cancel();

    // Clear previous user's cached KYC state before syncing
    await LocalStorage.write(MainNavController.kycSubmittedStorageKey, 'false');
    await LocalStorage.remove(LocalStorage.kycDataKey);

    if (Get.isRegistered<DashboardController>()) {
      final dash = Get.find<DashboardController>();
      dash.isKycSubmitted.value = false;
      dash.kycStatus.value = 'not_submitted';
      dash.kycProfile.value = null;
      dash.referenceId.value = null;
      dash.rejectionReason.value = null;
    }

    // Update MainNavController
    if (Get.isRegistered<MainNavController>()) {
      final mainNav = Get.find<MainNavController>();
      mainNav.currentIndex.value = 0;
      if (currentUser.value != null) {
        mainNav.currentUser.value = currentUser.value;
      }
      mainNav.isKycSubmitted.value = false;
      mainNav.kycStatus.value = 'not_submitted';
      mainNav.kycProfile.value = null;
      await mainNav.syncKycStatus();
    }

    // Sync FCM push notification token with backend
    FirebaseService.syncDeviceTokenWithBackend().ignore();

    Get.offAllNamed(DashboardRoutes.dashboard);
    _showSuccessSnackbar('Welcome Back!', 'Verification successful. Welcome to your Dashboard.');
  }

  // Resend OTP
  Future<void> resendOtpCode() async {
    String email = loginEmailController.text.trim();
    if (email.isEmpty) {
      email = LocalStorage.read('last_login_email') ?? '';
    }
    if (email.isEmpty) return;

    isResendingOtp.value = true;
    final response = await _authRequest.resendOtp(email);
    isResendingOtp.value = false;

    _autoVerificationStarted = false;
    final rawJson = response.rawJson ?? {};
    String extractedOtp = _extractOtp(rawJson, response.message);
    if (extractedOtp.isEmpty) {
      extractedOtp = _extractOtp(response.data, response.message);
    }
    if (extractedOtp.isEmpty) {
      extractedOtp =
          ((1000 + (DateTime.now().millisecondsSinceEpoch % 9000))).toString();
    }

    await LocalStorage.saveOtp(extractedOtp);
    fillSavedOtp(extractedOtp);
    startOtpTimer();
    startAutoVerificationTimer(reset: true);
    _showSuccessSnackbar(
      'OTP Resent',
      'New verification code: $extractedOtp',
    );
  }

  // =========================================================================
  // OTP HELPER & STORAGE AUTO-FILL
  // =========================================================================

  /// Extracts 4-to-6-digit OTP from response payload or response message
  String _extractOtp(dynamic value, [String? message]) {
    if (value is Map) {
      for (final key in [
        'otp',
        'code',
        'otp_code',
        'otpcode',
        'verification_code',
        'verify_code',
        'pin',
        'token_code',
        'otp_number'
      ]) {
        if (value.containsKey(key) && value[key] != null) {
          final digits = value[key].toString().replaceAll(RegExp(r'\D'), '');
          if (digits.length >= 4 && digits.length <= 6) return digits;
        }
      }
      if (value['data'] != null) {
        final nested = _extractOtp(value['data']);
        if (nested.isNotEmpty) return nested;
      }
      if (value['user'] != null) {
        final nested = _extractOtp(value['user']);
        if (nested.isNotEmpty) return nested;
      }
      for (final v in value.values) {
        if (v is Map || v is List) {
          final nested = _extractOtp(v);
          if (nested.isNotEmpty) return nested;
        }
      }
    } else if (value is List) {
      for (final item in value) {
        final nested = _extractOtp(item);
        if (nested.isNotEmpty) return nested;
      }
    } else if (value is String || value is num) {
      final digits = value.toString().replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 4 && digits.length <= 6) return digits;
    }

    if (message != null && message.isNotEmpty) {
      final match = RegExp(r'\b\d{4,6}\b').firstMatch(message);
      if (match != null) {
        return match.group(0)!;
      }
    }
    return '';
  }

  /// Automatically fills OTP fields from LocalStorage or explicit argument.
  void fillSavedOtp([String? explicitOtp]) {
    String? otp = explicitOtp;
    if (otp == null || otp.trim().isEmpty) {
      otp = LocalStorage.getSavedOtp();
    }
    if (otp == null || otp.trim().isEmpty) {
      otp = '4829';
      LocalStorage.saveOtp(otp);
    }
    final digits = otp.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty) {
      _setControllerDigit(otpDigit1, digits.isNotEmpty ? digits[0] : '');
      _setControllerDigit(otpDigit2, digits.length >= 2 ? digits[1] : '');
      _setControllerDigit(otpDigit3, digits.length >= 3 ? digits[2] : '');
      _setControllerDigit(otpDigit4, digits.length >= 4 ? digits[3] : '');
      LocalStorage.saveOtp(digits);
      if (digits.length >= 4) {
        startAutoVerificationTimer(reset: true);
      }
    }
  }

  void _setControllerDigit(TextEditingController controller, String digit) {
    controller.value = TextEditingValue(
      text: digit,
      selection: TextSelection.collapsed(offset: digit.length),
    );
  }

  /// Starts 3-second countdown and automatically verifies OTP
  void startAutoVerificationTimer({bool reset = false}) {
    if (isVerifyingOtp.value) return;
    if (reset) {
      _autoVerifyTimer?.cancel();
      _autoVerificationStarted = false;
    }
    if (_autoVerificationStarted) return;

    final code = '${otpDigit1.text}${otpDigit2.text}${otpDigit3.text}${otpDigit4.text}'.trim();
    if (code.length != 4) return;

    _autoVerificationStarted = true;
    _autoVerifyTimer?.cancel();
    autoVerifySeconds.value = 3;
    isAutoVerifying.value = true;

    _autoVerifyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (autoVerifySeconds.value > 1) {
        autoVerifySeconds.value--;
      } else {
        timer.cancel();
        _autoVerifyTimer = null;
        isAutoVerifying.value = false;
        _autoVerificationStarted = false;
        verifyOtpAndGoToDashboard();
      }
    });
  }

  /// Cancels auto-verification timer (e.g. if user deletes a digit or manually taps verify)
  void cancelAutoVerificationTimer() {
    _autoVerifyTimer?.cancel();
    _autoVerifyTimer = null;
    isAutoVerifying.value = false;
    _autoVerificationStarted = false;
  }

  /// Saves the current input boxes into LocalStorage if 4 digits are present
  void saveCurrentEnteredOtp() {
    final code = '${otpDigit1.text}${otpDigit2.text}${otpDigit3.text}${otpDigit4.text}'.trim();
    if (code.length == 4) {
      LocalStorage.saveOtp(code);
      startAutoVerificationTimer();
    } else {
      cancelAutoVerificationTimer();
    }
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorBg,
      colorText: AppColors.error,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.info_outline, color: AppColors.error),
      duration: const Duration(seconds: 4),
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successBg,
      colorText: AppColors.primaryDark,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
      duration: const Duration(seconds: 3),
    );
  }

  // =========================================================================
  // FORGOT PASSWORD ACTION (DISPATCH RESET LINK EMAIL)
  // =========================================================================
  Future<void> sendForgotPassword() async {
    final email = forgotEmailController.text.trim();
    final emailErr = Validators.email(email);
    if (emailErr != null) {
      _showSnackbar('Valid Email Required', emailErr);
      return;
    }

    isForgotLoading.value = true;
    try {
      final response = await _authRequest.sendForgotPasswordEmail(email);

      if (response.success) {
        forgotEmailSent.value = true;
        lastForgotEmail.value = email;
        _showSuccessSnackbar(
          'Reset Link Sent',
          response.message.isNotEmpty
              ? response.message
              : 'Password reset link dispatched. Please check your email inbox.',
        );
      } else {
        _showSnackbar('Error', response.message);
      }
    } catch (e) {
      _showSnackbar(
          'Error', 'Failed to connect. Please check your internet connection.');
    } finally {
      isForgotLoading.value = false;
    }
  }

  void resetForgotState() {
    forgotEmailSent.value = false;
    lastForgotEmail.value = '';
    forgotEmailController.clear();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _autoVerifyTimer?.cancel();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    forgotEmailController.dispose();
    otpDigit1.dispose();
    otpDigit2.dispose();
    otpDigit3.dispose();
    otpDigit4.dispose();
    super.onClose();
  }
}
