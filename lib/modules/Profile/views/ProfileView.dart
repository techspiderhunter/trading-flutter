import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/DeskUi.dart';
import '../../../themes/colors.dart';
import '../controllers/ProfileController.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    return Scaffold(
        appBar:
            DeskAppBar(group: 'Account', onBack: () => Get.back(), actions: [
          IconButton(
              tooltip: 'Refresh Profile',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: controller.loadProfile)
        ]),
        body: DeskBody(children: [
          const DeskHero(
              title: 'Personal credentials.',
              subtitle: 'Your identity, always within reach.'),
          const SizedBox(height: 25),
          Center(child: Obx(() {
            final name = controller.clientName.value;
            final url = controller.profileImageUrl.value;
            return Stack(children: [
              Container(
                  width: 88,
                  height: 88,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE5DFFF), shape: BoxShape.circle),
                  child: controller.isUploadingAvatar.value
                      ? const Center(child: CircularProgressIndicator())
                      : url != null && url.isNotEmpty
                          ? Image.network(url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                      name.isEmpty
                                          ? 'C'
                                          : name[0].toUpperCase(),
                                      style: deskText.copyWith(
                                          fontSize: 28,
                                          color: AppColors.primary))))
                          : Center(
                              child: Text(
                                  name.isEmpty ? 'C' : name[0].toUpperCase(),
                                  style: deskText.copyWith(
                                      fontSize: 28,
                                      color: AppColors.primary)))),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                      width: 29,
                      height: 29,
                      child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: controller.pickAndUploadAvatar,
                              child: const Icon(Icons.add_rounded,
                                  size: 19, color: Colors.white))))),
            ]);
          })),
          const SizedBox(height: 24),
          Obx(() => DeskNote(
              title: controller.clientName.value,
              description:
                  '${controller.clientEmail.value} · KYC: ${deskStatusLabel(controller.kycStatus.value)}')),
          const SizedBox(height: 18),
          const DeskLabel('Full name · Editable'),
          TextFormField(
              controller: controller.nameEditController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              style: deskText,
              decoration: _buildInputDecor(
                hint: 'Enter your full name',
                prefixIcon: Icons.person_outline_rounded,
              )),
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
                  message: 'Email is locked and cannot be changed.',
                  child: Icon(Icons.lock_rounded,
                      size: 17, color: AppColors.textMuted),
                ),
              )),
          const SizedBox(height: 16),
          const DeskLabel('Phone number · Editable'),
          TextFormField(
              controller: controller.phoneEditController,
              keyboardType: TextInputType.phone,
              style: deskText,
              decoration: _buildInputDecor(
                hint: 'Enter 10-digit mobile number',
                prefixIcon: Icons.phone_outlined,
              )),
          const SizedBox(height: 16),
          const DeskLabel('Account ID · Read-only'),
          Obx(() => TextFormField(
              key: ValueKey(controller.accountId.value),
              initialValue: controller.accountId.value,
              readOnly: true,
              style: deskText,
              decoration: deskInputDecoration(
                  enabled: true,
                  suffixIcon: IconButton(
                      tooltip: 'Copy Account ID',
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: controller.accountId.value));
                        Get.snackbar(
                          'Copied',
                          'Account ID copied',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          colorText: AppColors.textHeading,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                          duration: const Duration(seconds: 2),
                        );
                      })))),
          const SizedBox(height: 16),
          Obx(() => DeskButton(
              label: 'Save Changes',
              loading: controller.isUpdatingProfileInfo.value,
              onPressed: controller.isUpdatingProfileInfo.value
                  ? null
                  : controller.updateProfileDetails)),
          const SizedBox(height: 26),
          const DeskSection('Security & Password'),
          const SizedBox(height: 8),
          const DeskLabel('New password'),
          Obx(() => TextFormField(
              controller: controller.newPasswordController,
              obscureText: controller.isNewPasswordHidden.value,
              onChanged: (_) {
                if (controller.newPasswordError.value != null) {
                  controller.newPasswordError.value = null;
                }
              },
              style: deskText,
              decoration: _buildPasswordDecor(
                hint: 'Enter minimum 6 characters',
                isHidden: controller.isNewPasswordHidden.value,
                errorText: controller.newPasswordError.value,
                onToggle: () => controller.isNewPasswordHidden.toggle(),
              ))),
          const SizedBox(height: 16),
          const DeskLabel('Confirm new password'),
          Obx(() => TextFormField(
              controller: controller.confirmNewPasswordController,
              obscureText: controller.isConfirmNewPasswordHidden.value,
              onChanged: (_) {
                if (controller.confirmPasswordError.value != null) {
                  controller.confirmPasswordError.value = null;
                }
              },
              style: deskText,
              decoration: _buildPasswordDecor(
                hint: 'Repeat new password',
                isHidden: controller.isConfirmNewPasswordHidden.value,
                errorText: controller.confirmPasswordError.value,
                onToggle: () => controller.isConfirmNewPasswordHidden.toggle(),
              ))),
          const SizedBox(height: 16),
          Obx(() => DeskButton(
              label: 'Update Password',
              loading: controller.isUpdatingPassword.value,
              onPressed: controller.isUpdatingPassword.value
                  ? null
                  : controller.updatePassword)),
          const SizedBox(height: 20),
          DeskButton(
              label: 'Sign Out Account',
              secondary: true,
              onPressed: controller.logout),
        ]));
  }

  InputDecoration _buildInputDecor({
    required String hint,
    required IconData prefixIcon,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return deskInputDecoration(
        hintText: hint, enabled: enabled, suffixIcon: suffixIcon);
  }

  InputDecoration _buildPasswordDecor({
    required String hint,
    required bool isHidden,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    return deskInputDecoration(
        hintText: hint,
        errorText: errorText,
        suffixIcon: IconButton(
          icon: Icon(
            isHidden
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 19,
          ),
          onPressed: onToggle,
        ));
  }
}
