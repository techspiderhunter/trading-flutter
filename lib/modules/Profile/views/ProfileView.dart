import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/DeskUi.dart';
import '../../../themes/colors.dart';
import '../../Kyc/routes/KycRoutes.dart';
import '../../Mitc/routes/MitcRoutes.dart';
import '../../Invoice/routes/InvoiceRoutes.dart';
import '../controllers/ProfileController.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return Scaffold(
      appBar: DeskAppBar(
        group: 'Account',
        onBack: () => Get.back(),
        actions: [
          IconButton(
            tooltip: 'Refresh Profile',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadProfile,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: DeskBody(
          onRefresh: controller.loadProfile,
          children: [
            const DeskHero(
              title: 'Client Profile & Records',
              subtitle:
                  'Manage your account identity, security, and advisory compliance.',
            ),
            const SizedBox(height: 20),

            // 1. Executive Profile & KYC Status Card
            DeskCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar with interactive Camera overlay
                      GestureDetector(
                        onTap: controller.isUploadingAvatar.value
                            ? null
                            : controller.pickAndUploadAvatar,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Obx(() {
                              final name = controller.clientName.value;
                              final url = controller.profileImageUrl.value;
                              return Container(
                                width: 76,
                                height: 76,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.25),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: controller.isUploadingAvatar.value
                                    ? const Center(
                                        child: SizedBox(
                                          width: 26,
                                          height: 26,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5),
                                        ),
                                      )
                                    : url != null && url.isNotEmpty
                                        ? Image.network(
                                            url,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _buildAvatarInitial(name),
                                          )
                                        : _buildAvatarInitial(name),
                              );
                            }),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),

                      // Name, Email, Copyable Client ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                                  controller.clientName.value.isNotEmpty
                                      ? controller.clientName.value
                                      : 'Client User',
                                  style: deskText.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textHeading,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            const SizedBox(height: 3),
                            Obx(() => Text(
                                  controller.clientEmail.value,
                                  style: deskText.copyWith(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            const SizedBox(height: 8),

                            // Copyable Account ID Pill
                            Obx(() {
                              final accId = controller.accountId.value;
                              return InkWell(
                                onTap: () {
                                  if (accId.isNotEmpty) {
                                    Clipboard.setData(
                                        ClipboardData(text: accId));
                                    Get.snackbar(
                                      'Copied',
                                      'Account ID copied to clipboard',
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: const Duration(seconds: 2),
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: 10,
                                      backgroundColor: AppColors.primaryDark,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.borderLight),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        accId,
                                        style: deskText.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(
                                        Icons.copy_rounded,
                                        size: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 14),

                  // Status and Regulatory Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => _buildKycBadge(controller.kycStatus.value)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EEFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                size: 12, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'SEBI Reg. Client',
                              style: TextStyle(
                                fontFamily: 'DeskSans',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Quick Advisory & Compliance Strip
            DeskCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 4, right: 4, bottom: 12),
                    child: Text(
                      'COMPLIANCE & ADVISORY RECORDS',
                      style: deskText.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildServiceTile(
                          icon: Icons.assignment_ind_outlined,
                          label: 'KYC Record',
                          status: 'Verified/Pending',
                          onTap: () => Get.toNamed(KycRoutes.kyc),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildServiceTile(
                          icon: Icons.article_outlined,
                          label: 'MITC Terms',
                          status: 'Advisory Form',
                          onTap: () => Get.toNamed(MitcRoutes.mitc),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildServiceTile(
                          icon: Icons.receipt_long_outlined,
                          label: 'Tax Invoices',
                          status: 'GST Receipts',
                          onTap: () => Get.toNamed(InvoiceRoutes.invoice),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. Personal Information Card
            DeskCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DeskCardHeader(
                    title: 'Personal Information',
                    subtitle: 'Legal details as registered with PAN and Aadhaar',
                    icon: Icons.badge_outlined,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 18),

                  const DeskLabel('Legal full name · Editable'),
                  TextFormField(
                    controller: controller.nameEditController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    style: deskText,
                    decoration: _buildInputDecor(
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const DeskLabel('Registered email · Locked'),
                  TextFormField(
                    controller: controller.emailEditController,
                    enabled: false,
                    style: deskText,
                    decoration: _buildInputDecor(
                      hint: 'Email address',
                      prefixIcon: Icons.mail_outline_rounded,
                      enabled: false,
                      suffixIcon: const Tooltip(
                        message:
                            'Email is linked to SEBI compliance and cannot be edited.',
                        child: Icon(Icons.lock_rounded,
                            size: 18, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const DeskLabel('Phone number · Editable'),
                  TextFormField(
                    controller: controller.phoneEditController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    style: deskText,
                    decoration: _buildInputDecor(
                      hint: '10-digit mobile number',
                      prefixIcon: Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Obx(() => DeskButton(
                        label: 'Save Profile Changes',
                        loading: controller.isUpdatingProfileInfo.value,
                        onPressed: controller.isUpdatingProfileInfo.value
                            ? null
                            : controller.updateProfileDetails,
                      )),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 4. Security & Password Card
            DeskCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DeskCardHeader(
                    title: 'Security & Authentication',
                    subtitle: 'Change or update your portal password',
                    icon: Icons.lock_outline_rounded,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 18),

                  const DeskLabel('New password'),
                  Obx(() => TextFormField(
                        controller: controller.newPasswordController,
                        obscureText: controller.isNewPasswordHidden.value,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {
                          if (controller.newPasswordError.value != null) {
                            controller.newPasswordError.value = null;
                          }
                        },
                        style: deskText,
                        decoration: _buildPasswordDecor(
                          hint: 'Minimum 6 characters',
                          prefixIcon: Icons.lock_outline_rounded,
                          isHidden: controller.isNewPasswordHidden.value,
                          errorText: controller.newPasswordError.value,
                          onToggle: () =>
                              controller.isNewPasswordHidden.toggle(),
                        ),
                      )),
                  const SizedBox(height: 16),

                  const DeskLabel('Confirm new password'),
                  Obx(() => TextFormField(
                        controller: controller.confirmNewPasswordController,
                        obscureText: controller.isConfirmNewPasswordHidden.value,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) {
                          if (controller.confirmPasswordError.value != null) {
                            controller.confirmPasswordError.value = null;
                          }
                        },
                        onFieldSubmitted: (_) {
                          if (!controller.isUpdatingPassword.value) {
                            controller.updatePassword();
                          }
                        },
                        style: deskText,
                        decoration: _buildPasswordDecor(
                          hint: 'Repeat new password',
                          prefixIcon: Icons.lock_reset_rounded,
                          isHidden:
                              controller.isConfirmNewPasswordHidden.value,
                          errorText: controller.confirmPasswordError.value,
                          onToggle: () =>
                              controller.isConfirmNewPasswordHidden.toggle(),
                        ),
                      )),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Minimum 6 characters with mixed characters',
                        style: deskText.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Obx(() => DeskButton(
                        label: 'Update Password',
                        loading: controller.isUpdatingPassword.value,
                        onPressed: controller.isUpdatingPassword.value
                            ? null
                            : controller.updatePassword,
                      )),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 5. Legal & App Details Card
            DeskCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.cardBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NM Research Partner Pvt Ltd',
                          style: deskText.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHeading,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'SEBI Reg. INH000009843 · v2.4.0',
                          style: deskText.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 6. Sign Out Card
            DeskCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: controller.logout,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sign Out Account',
                                style: deskText.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Securely close session on this device',
                                style: deskText.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static Widget _buildServiceTile({
    required IconData icon,
    required String label,
    required String status,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.scaffoldBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Icon(icon, size: 19, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: deskText.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: deskText.copyWith(
                  fontSize: 9.5,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarInitial(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'C';
    return Center(
      child: Text(
        initial,
        style: deskText.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildKycBadge(String status) {
    final clean = status.toLowerCase();
    Color bg;
    Color fg;
    IconData icon;
    String text;

    if (clean == 'verified' || clean == 'approved') {
      bg = AppColors.successBg;
      fg = AppColors.success;
      icon = Icons.verified_rounded;
      text = 'KYC VERIFIED';
    } else if (clean == 'rejected' || clean == 'declined') {
      bg = AppColors.errorBg;
      fg = AppColors.error;
      icon = Icons.cancel_outlined;
      text = 'KYC REJECTED';
    } else {
      bg = AppColors.warningBg;
      fg = AppColors.warning;
      icon = Icons.pending_actions_rounded;
      text = 'KYC PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'DeskSans',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecor({
    required String hint,
    required IconData prefixIcon,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return deskInputDecoration(
      hintText: hint,
      enabled: enabled,
      prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
    );
  }

  InputDecoration _buildPasswordDecor({
    required String hint,
    required IconData prefixIcon,
    required bool isHidden,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    return deskInputDecoration(
      hintText: hint,
      errorText: errorText,
      prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
      suffixIcon: IconButton(
        icon: Icon(
          isHidden
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.textSecondary,
          size: 19,
        ),
        onPressed: onToggle,
      ),
    );
  }
}
