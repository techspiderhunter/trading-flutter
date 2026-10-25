import '../../../widgets/DeskUi.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../themes/AppColors.dart';
import '../../Auth/routes/AuthRoutes.dart';
import '../../../models/UserModel.dart';
import '../../../includes/Storage.dart';
import '../../Dashboard/controllers/DashboardController.dart';
import '../../MainNav/controllers/MainNavController.dart';
import '../models/ProfileParams.dart';
import '../requests/ProfileRequest.dart';
import '../../../global/Validator/Validators.dart';

/// MVC Controller for Profile Module
/// Manages reactive user profile display, form state, and communicates via ProfileRequest.
class ProfileController extends GetxController {
  final ProfileRequest _profileRequest = ProfileRequest();
  final ImagePicker _imagePicker = ImagePicker();

  // Reactive Client Details
  final clientName = 'Loading...'.obs;
  final clientEmail = '...'.obs;
  final clientPhone = '...'.obs;
  final accountId = '# MV-CLIENT'.obs;
  final kycStatus = 'pending'.obs;
  final profileImageUrl = Rx<String?>(null);
  final isProfileLoading = false.obs;

  // Security & Password Form
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  final isNewPasswordHidden = true.obs;
  final isConfirmNewPasswordHidden = true.obs;
  final isUpdatingPassword = false.obs;
  final isUploadingAvatar = false.obs;
  final newPasswordError = Rx<String?>(null);
  final confirmPasswordError = Rx<String?>(null);

  // Profile Edit Form
  final nameEditController = TextEditingController();
  final phoneEditController = TextEditingController();
  final emailEditController = TextEditingController();
  final isUpdatingProfileInfo = false.obs;

  String? get _currentValidName {
    final n = clientName.value.trim();
    if (n.isNotEmpty && n != 'Loading...' && n != 'Client' && n != 'N/A') {
      return n;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    // 1. Try local cache first for instant display
    final cached = LocalStorage.read(LocalStorage.userProfileKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final user = UserModel.fromJsonString(cached);
        _applyUserData(user);
      } catch (_) {}
    }

    // 2. Fetch fresh from backend via ProfileRequest
    if (!LocalStorage.hasToken()) return;

    isProfileLoading.value = true;
    final res = await _profileRequest.getProfile();
    isProfileLoading.value = false;

    if (res.success && res.data != null) {
      _applyUserData(res.data!);
    }

    // Also sync KYC status
    final kycRes = await _profileRequest.getKyc();
    if (kycRes.success && kycRes.data != null) {
      kycStatus.value = kycRes.data!.verificationStatus;
    }
  }

  void _applyUserData(UserModel user) {
    clientName.value = user.name.isNotEmpty ? user.name : 'Client';
    clientEmail.value = user.email.isNotEmpty ? user.email : 'N/A';
    clientPhone.value = user.phone.isNotEmpty ? user.phone : 'N/A';
    accountId.value = user.formattedAccountId;
    profileImageUrl.value = user.profileImageUrl;

    nameEditController.text = user.name;
    phoneEditController.text = user.phone;
    emailEditController.text = user.email;

    // Sync with MainNavController if available
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().currentUser.value = user;
    }
  }

  /// Update Profile Details (Full Name & Phone)
  Future<void> updateProfileDetails() async {
    final name = nameEditController.text.trim();
    final phone = phoneEditController.text.trim();

    if (name.isEmpty) {
      _showSnackbar('Required Field', 'Please enter your full name.');
      return;
    }

    isUpdatingProfileInfo.value = true;
    final response = await _profileRequest.updateProfile(
      UpdateProfileParams(
        name: name,
        phone: phone.isNotEmpty ? phone : null,
      ),
    );
    isUpdatingProfileInfo.value = false;

    if (response.success && response.data != null) {
      _applyUserData(response.data!);
      if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        'Profile Updated',
        'Your profile details have been saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.primaryDark,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.check_circle_outline, color: AppColors.primary),
      );
    } else {
      _showSnackbar('Update Failed', response.firstErrorMessage);
    }
  }

  /// Change password via ProfileRequest
  Future<void> updatePassword() async {
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmNewPasswordController.text.trim();

    if (newPass.isEmpty) {
      newPasswordError.value = 'Password is required';
      _showSnackbar('Required Field', 'Please enter your new password.');
      return;
    }

    final passErr = Validators.password(newPass);
    if (passErr != null) {
      newPasswordError.value = passErr;
      _showSnackbar('Invalid Password', passErr);
      return;
    }

    if (confirmPass.isEmpty) {
      confirmPasswordError.value = 'Please confirm your password';
      _showSnackbar('Required Field', 'Please repeat the new password.');
      return;
    }

    final matchErr = Validators.confirmPassword(confirmPass, newPass);
    if (matchErr != null) {
      confirmPasswordError.value = matchErr;
      _showSnackbar('Password Mismatch', matchErr);
      return;
    }

    // Clear any previous error before submitting
    newPasswordError.value = null;
    confirmPasswordError.value = null;

    isUpdatingPassword.value = true;
    final response = await _profileRequest.updateProfile(
      UpdateProfileParams(
        name: nameEditController.text.trim().isNotEmpty
            ? nameEditController.text.trim()
            : _currentValidName,
        phone: phoneEditController.text.trim().isNotEmpty
            ? phoneEditController.text.trim()
            : null,
        password: newPass,
      ),
    );
    isUpdatingPassword.value = false;

    if (response.success) {
      newPasswordError.value = null;
      confirmPasswordError.value = null;
      newPasswordController.clear();
      confirmNewPasswordController.clear();
      FocusManager.instance.primaryFocus?.unfocus();

      Get.snackbar(
        'Password Updated',
        'Your login password has been updated successfully on the server.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.successBg,
        colorText: AppColors.primaryDark,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.check_circle_outline, color: AppColors.primary),
      );
    } else {
      _showSnackbar('Update Failed', response.firstErrorMessage);
    }
  }

  /// Pick & upload avatar picture via ProfileRequest
  Future<void> pickAndUploadAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      isUploadingAvatar.value = true;
      final file = File(image.path);
      final response = await _profileRequest.updateProfile(
        UpdateProfileParams(
          name: _currentValidName,
          profileImageFile: file,
        ),
      );
      isUploadingAvatar.value = false;

      if (response.success && response.data != null) {
        _applyUserData(response.data!);
        Get.snackbar(
          'Avatar Updated',
          'Your profile picture was uploaded successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successBg,
          colorText: AppColors.primaryDark,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        _showSnackbar('Upload Failed', response.firstErrorMessage);
      }
    } catch (e) {
      isUploadingAvatar.value = false;
      _showSnackbar('Image Picker Error', 'Could not select image: $e');
    }
  }

  /// Sign out client session via ProfileRequest
  void logout() {
    Get.dialog(
      Dialog(
          alignment: Alignment.bottomCenter,
          insetPadding: EdgeInsets.zero,
          child: DeskSheetContent(
              title: 'Sign Out',
              subtitle:
                  'Are you sure you want to sign out from your Moneyara account?',
              children: [
                DeskButton(
                    label: 'Sign Out',
                    onPressed: () async {
                      Get.back();
                      await _profileRequest.logout();
                      await LocalStorage.write(
                          MainNavController.kycSubmittedStorageKey, 'false');
                      await LocalStorage.remove(LocalStorage.kycDataKey);
                      if (Get.isRegistered<MainNavController>()) {
                        Get.find<MainNavController>().currentIndex.value = 0;
                        Get.delete<MainNavController>(force: true);
                      }
                      if (Get.isRegistered<DashboardController>()) {
                        Get.delete<DashboardController>(force: true);
                      }
                      Get.offAllNamed(AuthRoutes.login);
                      Get.snackbar(
                        'Signed Out',
                        'You have been logged out successfully.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.infoBg,
                        colorText: AppColors.textPrimary,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                        icon: const Icon(Icons.info_outline,
                            color: AppColors.info),
                      );
                    }),
                const SizedBox(height: 20),
                DeskButton(
                    label: 'Cancel',
                    secondary: true,
                    onPressed: () => Get.back())
              ])),
    );
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

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    nameEditController.dispose();
    phoneEditController.dispose();
    emailEditController.dispose();
    super.onClose();
  }
}
