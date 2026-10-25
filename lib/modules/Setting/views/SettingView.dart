import '../../../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/colors.dart';
import '../../Profile/controllers/ProfileController.dart';
import '../../Profile/routes/ProfileRoutes.dart';
import '../../Kyc/routes/KycRoutes.dart';
import '../../Mitc/routes/MitcRoutes.dart';
import '../../Mitc/controllers/MitcController.dart';
import '../../Invoice/routes/InvoiceRoutes.dart';
import '../../MainNav/controllers/MainNavController.dart';
import '../../Notification/views/NotificationView.dart';

/// Restores all original settings options cleanly with no mock category grids.
class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    final mainNavController = Get.isRegistered<MainNavController>()
        ? Get.find<MainNavController>()
        : Get.put(MainNavController());

    final mitcController = Get.isRegistered<MitcController>()
        ? Get.find<MitcController>()
        : Get.put(MitcController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: DeskAppBar(group: 'Account', onBack: () => Get.back()),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await profileController.loadProfile();
            await mainNavController.syncUserAndKyc();
            await mitcController.loadMitcProfile();
          },
          color: AppColors.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final hPadding = isWide ? 32.0 : 24.0;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPadding,
                        vertical: 22,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const DeskHero(
                              title: 'Your workspace.',
                              subtitle:
                                  'Account information & compliance records.'),
                          const SizedBox(height: 24),
                          // 1. User Info Banner Card
                          Obx(() {
                            final name = profileController
                                        .clientName.value.isNotEmpty &&
                                    profileController.clientName.value !=
                                        'Loading...'
                                ? profileController.clientName.value
                                : (mainNavController.currentUser.value?.name ??
                                    'Client User');
                            return Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: DeskNote(
                                  title: name,
                                  description:
                                      'Client ID: ${profileController.accountId.value} · KYC: ${deskStatusLabel(mainNavController.kycStatus.value)}',
                                ));
                          }),

                          // Section Label
                          const DeskSection('Account & Compliance'),

                          // Option 1: Profile Information
                          _buildSettingOptionCard(
                            icon: Icons.person_outline_rounded,
                            iconColor: AppColors.iconBlue,
                            iconBgColor: AppColors.cardBlue,
                            title: 'Profile Information',
                            subtitle:
                                'Client credentials and password management',
                            onTap: () => Get.toNamed(ProfileRoutes.profile),
                          ),
                          const SizedBox(height: 15),

                          // Option 2: KYC Verification
                          Obx(() {
                            final status = mainNavController.kycStatus.value
                                .trim()
                                .toLowerCase();
                            String badgeText = 'Not Submitted';
                            Color badgeColor = AppColors.textSecondary;
                            Color badgeBgColor = AppColors.surfaceSecondary;

                            if (status == 'verified' ||
                                status == 'approved' ||
                                status == 'completed') {
                              badgeText = 'Verified';
                              badgeColor = AppColors.primary;
                              badgeBgColor = AppColors.primaryLight;
                            } else if (status == 'pending' ||
                                status == 'under_review' ||
                                status == 'submitted') {
                              badgeText = 'Under Review';
                              badgeColor = AppColors.warning;
                              badgeBgColor = AppColors.warningBg;
                            } else if (status == 'rejected' ||
                                status == 'declined' ||
                                status == 'action_required') {
                              badgeText = 'Rejected';
                              badgeColor = AppColors.error;
                              badgeBgColor = AppColors.errorBg;
                            }

                            return _buildSettingOptionCard(
                              icon: Icons.verified_user_outlined,
                              iconColor: AppColors.primary,
                              iconBgColor: AppColors.primaryLight,
                              title: 'KYC Verification',
                              subtitle:
                                  'SEBI statutory identity and risk profiling',
                              badgeText: badgeText,
                              badgeColor: badgeColor,
                              badgeBgColor: badgeBgColor,
                              onTap: () => Get.toNamed(KycRoutes.kycIndex),
                            );
                          }),
                          const SizedBox(height: 15),

                          // Option 3: MITC Advisory
                          Obx(() {
                            final status = mitcController.currentStatus.value
                                .trim()
                                .toLowerCase();
                            final mitc = mitcController.mitcProfile.value;
                            final isVerified = status == 'verified' ||
                                (mitc != null && mitc.isVerified);
                            final isPending = status == 'pending' ||
                                status == 'under_review' ||
                                (mitc != null && mitc.isPending);
                            final isRejected = status == 'rejected' ||
                                status == 'declined' ||
                                (mitc != null && mitc.isRejected);

                            String subtitle =
                                'Most Important Terms and Conditions';
                            String badgeText = 'START MITC';
                            Color badgeColor = AppColors.primary;
                            Color badgeBgColor = AppColors.primaryLight;

                            if (isVerified) {
                              subtitle = 'MITC Agreement Verified & Active';
                              badgeText = 'VERIFIED';
                              badgeColor = AppColors.primary;
                              badgeBgColor = AppColors.primaryLight;
                            } else if (isPending) {
                              subtitle =
                                  'Agreement submitted, under compliance audit';
                              badgeText = 'UNDER REVIEW';
                              badgeColor = AppColors.warning;
                              badgeBgColor = AppColors.warningBg;
                            } else if (isRejected) {
                              subtitle = 'MITC form returned with remarks';
                              badgeText = 'REJECTED';
                              badgeColor = AppColors.error;
                              badgeBgColor = AppColors.errorBg;
                            }

                            return _buildSettingOptionCard(
                              icon: Icons.description_outlined,
                              iconColor: AppColors.primary,
                              iconBgColor: AppColors.primaryLight,
                              title: 'MITC Advisory',
                              subtitle: subtitle,
                              badgeText: badgeText,
                              badgeColor: badgeColor,
                              badgeBgColor: badgeBgColor,
                              onTap: () => Get.toNamed(MitcRoutes.mitcIndex),
                            );
                          }),
                          const SizedBox(height: 15),

                          // Option 4: Tax Invoices & Billing
                          _buildSettingOptionCard(
                            icon: Icons.receipt_long_rounded,
                            iconColor: AppColors.primary,
                            iconBgColor: AppColors.primaryLight,
                            title: 'Tax Invoices',
                            subtitle:
                                'Download GST invoices and payment receipts',
                            onTap: () => Get.toNamed(InvoiceRoutes.invoice),
                          ),
                          const SizedBox(height: 15),

                          // Option 5: Regulatory Disclosures & Alerts
                          _buildSettingOptionCard(
                            icon: Icons.notifications_none_rounded,
                            iconColor: AppColors.primary,
                            iconBgColor: AppColors.primaryLight,
                            title: 'Regulatory Alerts',
                            subtitle:
                                'Compliance notices and market broadcasts',
                            onTap: () => NotificationView.open(context),
                          ),
                          const SizedBox(height: 24),

                          // Sign Out Button
                          DeskButton(
                              label: 'Sign Out',
                              secondary: true,
                              onPressed: profileController.logout),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingOptionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    Color? badgeBgColor,
    VoidCallback? onTap,
  }) {
    return DeskRow(title: title, subtitle: subtitle, icon: icon, onTap: onTap);
  }
}
