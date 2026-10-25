import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Dashboard/controllers/DashboardController.dart';
import '../../Dashboard/routes/DashboardRoutes.dart';
import '../../MainNav/routes/MainNavRoutes.dart';
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
          'Please agree to Moneyara terms & SEBI regulatory conditions.');
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

    isLoginLoading.value = true;
    final response = await _authRequest.login(
      LoginParams(
        email: email,
        password: password,
        direct: false,
      ),
    );
    isLoginLoading.value = false;

    if (response.success) {
      final data = response.data ?? {};
      final requiresOtp = data['requires_otp'] == true;

      if (requiresOtp) {
        // Clear OTP input fields
        otpDigit1.clear();
        otpDigit2.clear();
        otpDigit3.clear();
        otpDigit4.clear();

        startOtpTimer();
        Get.toNamed(AuthRoutes.otp);
        _showSuccessSnackbar(
          'Verification Code Dispatched',
          'A 4-digit code was sent to $email.',
        );
      } else {
        // Direct login succeeded
        if (data.containsKey('name')) {
          currentUser.value = UserModel.fromJson(data);
        }

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

        if (Get.isRegistered<MainNavController>()) {
          final mainNav = Get.find<MainNavController>();
          mainNav.currentIndex.value = 0;
          mainNav.currentUser.value = currentUser.value;
          mainNav.isKycSubmitted.value = false;
          mainNav.kycStatus.value = 'not_submitted';
          mainNav.kycProfile.value = null;
          await mainNav.syncKycStatus();
        }

        // Sync FCM push notification token with backend
        FirebaseService.syncDeviceTokenWithBackend().ignore();

        Get.offAllNamed(DashboardRoutes.dashboard);
        _showSuccessSnackbar('Welcome Back!', 'Login successful. Navigating to Dashboard.');
      }
    } else {
      _showSnackbar('Login Failed', response.firstErrorMessage);
    }
  }

  // =========================================================================
  // OTP VERIFICATION ACTION
  // =========================================================================
  Future<void> verifyOtpAndGoToDashboard() async {
    final email = loginEmailController.text.trim();
    final code = '${otpDigit1.text}${otpDigit2.text}${otpDigit3.text}${otpDigit4.text}'.trim();

    if (code.length < 4) {
      _showSnackbar('Incomplete Code', 'Please enter the complete 4-digit OTP code.');
      return;
    }

    isVerifyingOtp.value = true;
    final response = await _authRequest.verifyOtp(
      VerifyOtpParams(email: email, otp: code),
    );
    isVerifyingOtp.value = false;

    if (response.success && response.data != null) {
      _countdownTimer?.cancel();
      currentUser.value = response.data;

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
        mainNav.currentUser.value = response.data;
        mainNav.isKycSubmitted.value = false;
        mainNav.kycStatus.value = 'not_submitted';
        mainNav.kycProfile.value = null;
        await mainNav.syncKycStatus();
      }

      // Sync FCM push notification token with backend
      FirebaseService.syncDeviceTokenWithBackend().ignore();

      Get.offAllNamed(DashboardRoutes.dashboard);
      _showSuccessSnackbar('Welcome Back!', 'Verification successful. Welcome to your Dashboard.');
    } else {
      _showSnackbar('Verification Failed', response.firstErrorMessage);
    }
  }

  // Resend OTP
  Future<void> resendOtpCode() async {
    final email = loginEmailController.text.trim();
    if (email.isEmpty) return;

    isResendingOtp.value = true;
    final response = await _authRequest.resendOtp(email);
    isResendingOtp.value = false;

    if (response.success) {
      startOtpTimer();
      _showSuccessSnackbar('OTP Resent', response.message);
    } else {
      _showSnackbar('Resend Failed', response.firstErrorMessage);
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
      icon: Icon(Icons.check_circle_outline, color: AppColors.primary),
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
