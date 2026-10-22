import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/AppColors.dart';
import '../controllers/ProfileController.dart';

/// 100% Responsive, Mobile-Optimized ProfileView
/// Displays live user details from Laravel API, KYC verification status,
/// password update functionality, avatar upload and real logout.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary, size: 20),
                onPressed: () => Get.back(),
              )
            : null,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary, size: 20),
            tooltip: 'Refresh Profile',
            onPressed: controller.loadProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.error, size: 22),
            tooltip: 'Sign Out',
            onPressed: controller.logout,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. User Header Section with Avatar Upload
              Center(
                child: Obx(() {
                  final initial = controller.clientName.value.isNotEmpty
                      ? controller.clientName.value[0].toUpperCase()
                      : 'C';
                  final imgUrl = controller.profileImageUrl.value;
                  final isUploading = controller.isUploadingAvatar.value;

                  return Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F7F0),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00B074),
                                width: 2.5,
                              ),
                            ),
                            child: isUploading
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.primary),
                                      ),
                                    ),
                                  )
                                : (imgUrl != null && imgUrl.isNotEmpty)
                                    ? ClipOval(
                                        child: Image.network(
                                          imgUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Center(
                                            child: Text(
                                              initial,
                                              style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF00B074),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          initial,
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF00B074),
                                          ),
                                        ),
                                      ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.clientName.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.clientEmail.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // KYC Badge in header
                      _buildKycStatusPill(controller.kycStatus.value),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 20),

              // 2. Personal Information Section (Directly Editable on Screen)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_rounded, color: Color(0xFF00B074), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'You can edit your details below. Email is permanently locked for account security.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field 1: Client Full Name (EDITABLE)
                    _buildFieldLabel('Full Name', tag: 'Editable'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: controller.nameEditController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: _buildInputDecor(
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline_rounded,
                        enabled: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Field 2: Registered Email (LOCKED / UNCHANGEABLE)
                    _buildFieldLabel('Registered Email', tag: 'Locked', isLocked: true),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: controller.emailEditController,
                      enabled: false,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                      decoration: _buildInputDecor(
                        hint: 'Email address',
                        prefixIcon: Icons.mail_outline_rounded,
                        enabled: false,
                        suffixIcon: const Tooltip(
                          message: 'Email is locked and cannot be changed.',
                          child: Icon(Icons.lock_rounded, size: 17, color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Field 3: Phone Number (EDITABLE)
                    _buildFieldLabel('Phone Number', tag: 'Editable'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: controller.phoneEditController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: _buildInputDecor(
                        hint: 'Enter 10-digit mobile number',
                        prefixIcon: Icons.phone_outlined,
                        enabled: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Field 4: Account ID (Read-only reference)
                    _buildFieldLabel('Account ID', tag: 'Read-only', isLocked: true),
                    const SizedBox(height: 6),
                    Obx(
                      () => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.tag_rounded, color: Color(0xFF94A3B8), size: 17),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                controller.accountId.value,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Save Profile Details Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Obx(
                        () => ElevatedButton.icon(
                          onPressed: controller.isUpdatingProfileInfo.value
                              ? null
                              : controller.updateProfileDetails,
                          icon: controller.isUpdatingProfileInfo.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                          label: Text(
                            controller.isUpdatingProfileInfo.value ? 'Saving...' : 'Save Profile Details',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B074),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Security & Password Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFF00B074), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Security & Password',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'You can update your login password directly here anytime.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // New Password
                    const Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => TextFormField(
                        controller: controller.newPasswordController,
                        obscureText: controller.isNewPasswordHidden.value,
                        onChanged: (_) {
                          if (controller.newPasswordError.value != null) {
                            controller.newPasswordError.value = null;
                          }
                        },
                        decoration: _buildPasswordDecor(
                          hint: 'Enter minimum 6 characters',
                          isHidden: controller.isNewPasswordHidden.value,
                          errorText: controller.newPasswordError.value,
                          onToggle: () =>
                              controller.isNewPasswordHidden.toggle(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Confirm New Password
                    const Text(
                      'Confirm New Password',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => TextFormField(
                        controller: controller.confirmNewPasswordController,
                        obscureText: controller.isConfirmNewPasswordHidden.value,
                        onChanged: (_) {
                          if (controller.confirmPasswordError.value != null) {
                            controller.confirmPasswordError.value = null;
                          }
                        },
                        decoration: _buildPasswordDecor(
                          hint: 'Repeat new password',
                          isHidden: controller.isConfirmNewPasswordHidden.value,
                          errorText: controller.confirmPasswordError.value,
                          onToggle: () =>
                              controller.isConfirmNewPasswordHidden.toggle(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Update Password Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isUpdatingPassword.value
                              ? null
                              : controller.updatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B074),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            elevation: 0,
                          ),
                          child: controller.isUpdatingPassword.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Update Password',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),


              // 4. Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout_rounded,
                      size: 18, color: AppColors.error),
                  label: const Text(
                    'Sign Out Account',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppColors.error.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKycStatusPill(String status) {
    Color bg = const Color(0xFFFEF3C7);
    Color text = const Color(0xFFD97706);
    String label = 'KYC: Under Review';
    IconData icon = Icons.schedule_rounded;

    final s = status.trim().toLowerCase();
    if (s == 'verified' || s == 'active' || s == 'approved' || s == 'completed') {
      bg = const Color(0xFFECFDF5);
      text = const Color(0xFF00B074);
      label = 'KYC: Verified';
      icon = Icons.verified_user_rounded;
    } else if (s == 'not_submitted') {
      bg = const Color(0xFFF1F5F9);
      text = const Color(0xFF64748B);
      label = 'KYC: Not Submitted';
      icon = Icons.error_outline_rounded;
    } else if (s == 'rejected' || s == 'declined' || s == 'action_required') {
      bg = const Color(0xFFFEF2F2);
      text = const Color(0xFFEF4444);
      label = 'KYC: Rejected';
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {String? tag, bool isLocked = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (tag != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: isLocked ? const Color(0xFFF1F5F9) : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isLocked ? const Color(0xFFCBD5E1) : const Color(0xFFA7F3D0),
                width: 0.8,
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isLocked ? const Color(0xFF64748B) : const Color(0xFF00B074),
              ),
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecor({
    required String hint,
    required IconData prefixIcon,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: enabled ? AppColors.textMuted : const Color(0xFF94A3B8),
        size: 18,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00B074), width: 1.5),
      ),
    );
  }

  InputDecoration _buildPasswordDecor({
    required String hint,
    required bool isHidden,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.textMuted,
        size: 18,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textMuted,
          size: 18,
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00B074), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
