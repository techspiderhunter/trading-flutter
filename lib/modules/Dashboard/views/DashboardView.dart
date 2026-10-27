import '../../../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/colors.dart';
import '../controllers/DashboardController.dart';
import '../../MainNav/controllers/MainNavController.dart';
import '../../Setting/routes/SettingRoutes.dart';
import '../../Kyc/routes/KycRoutes.dart';
import 'widgets/KycInitialLockCard.dart';
import 'widgets/KycUnderReviewCard.dart';
import '../../Notification/views/NotificationView.dart';
import 'widgets/ActiveMessagesFeed.dart';

/// Highly Optimized, Responsive Dashboard View for Trading App
/// Fixed card overflow issues & guaranteed Profile navigation to Settings.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    final mainNavController = Get.isRegistered<MainNavController>()
        ? Get.find<MainNavController>()
        : Get.put(MainNavController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // 1. Sleek, Modern App Header
      appBar: DeskAppBar(group: 'Dashboard', dashboard: true, actions: [
        Obx(() {
          final unread = dashboardController.unreadNotificationsCount.value;
          return Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF1F3FA),
                  borderRadius: BorderRadius.circular(15)),
              child: Stack(alignment: Alignment.center, children: [
                IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        size: 22, color: AppColors.textHeading),
                    tooltip: 'Notifications & Alerts',
                    onPressed: () => NotificationView.open(context)),
                if (unread > 0)
                  Positioned(
                      top: 6,
                      right: 7,
                      child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: Color(0xFFD75C7C),
                              shape: BoxShape.circle))),
              ]));
        }),
        const SizedBox(width: 9),
        Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(15)),
            child: IconButton(
                icon: const Icon(Icons.settings_outlined, size: 23),
                tooltip: 'Setting',
                onPressed: () => Get.toNamed(SettingRoutes.setting))),
      ]),

      // 2. Responsive Body with Refresh Indicator
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await dashboardController.syncDashboard();
            await mainNavController.syncUserAndKyc();
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
                          // Optimized, Non-Breaking Welcome Header Card
                          _buildOptimizedHeaderCard(dashboardController),

                          const SizedBox(height: 16),

                          // Dynamic KYC Status Cards / Messages Feed
                          Obx(() {
                            final isLoading =
                                dashboardController.isLoading.value;
                            final status = dashboardController.kycStatus.value
                                .trim()
                                .toLowerCase();
                            final isSubmitted =
                                dashboardController.isKycSubmitted.value;
                            final kyc = dashboardController.kycProfile.value;

                            // 1. Loading State
                            if (isLoading) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 48),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              );
                            }

                            // 2. Verified State -> Shows Real Messages Feed
                            final bool isVerifiedState =
                                (kyc != null && kyc.isVerified) ||
                                    status == 'verified' ||
                                    status == 'active' ||
                                    status == 'approved' ||
                                    status == 'completed';

                            if (isVerifiedState) {
                              return _buildVerifiedActiveCard(
                                  dashboardController.clientName.value);
                            }

                            // 3. Rejected State
                            final bool isRejectedState =
                                (kyc != null && kyc.isRejected) ||
                                    status == 'rejected' ||
                                    status == 'declined' ||
                                    status == 'action_required';

                            if (isRejectedState) {
                              return _buildRejectedCard(
                                  dashboardController.rejectionReason.value);
                            }

                            // 4. Pending / Under Review State
                            final bool isPendingState = isSubmitted ||
                                (kyc != null && kyc.isPending) ||
                                status == 'pending' ||
                                status == 'under_review' ||
                                status == 'submitted';

                            if (isPendingState) {
                              return KycUnderReviewCard(
                                  referenceId:
                                      dashboardController.referenceId.value);
                            }

                            // 5. Default / Fallback: Lock Card with "Start KYC" button
                            return const KycInitialLockCard();
                          }),
                          Obx(() {
                            if (dashboardController.isExpired.value) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 18),
                                const DeskSection('Research Desk'),
                                Text('Official communications · Secure access',
                                    style: deskText.copyWith(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 24),
                              ],
                            );
                          }),
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

  /// Optimized, Non-Breaking Welcome Banner Card
  /// Organizes title & status vertically to prevent any overflow on small screens.
  Widget _buildOptimizedHeaderCard(DashboardController dashboardController) {
    return Obx(() {
      final name = dashboardController.clientName.value.isNotEmpty &&
              dashboardController.clientName.value != 'Client'
          ? dashboardController.clientName.value
          : 'Trader';
      return DeskHero(
          title: 'Welcome back, $name.',
          subtitle: 'Your market research & regulatory portal.');
    });
  }

  Widget _buildVerifiedActiveCard(String clientName) {
    final dash = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Obx(() {
        if (dash.isExpired.value) {
          return const SizedBox.shrink();
        }
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DeskNote(
                title: 'Verified',
                description:
                    'Your identity is verified. Your research feed is ready.',
                color: AppColors.success,
                icon: Icons.check_rounded),
            SizedBox(height: 18),
            DeskSection('Messages & Advisories'),
            SizedBox(height: 8),
          ],
        );
      }),
      ActiveMessagesFeed(clientName: clientName),
    ]);
  }

  Widget _buildRejectedCard(String? reason) {
    final displayReason = reason != null && reason.isNotEmpty
        ? reason
        : 'Identity proofs were incomplete or unreadable.';

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DeskNote(
          title: 'Action Needed',
          description: displayReason,
          color: AppColors.error,
          icon: Icons.priority_high_rounded),
      const SizedBox(height: 18),
      DeskButton(
          label: 'Re-submit KYC Documents',
          onPressed: () => Get.toNamed(KycRoutes.kycIndex)),
    ]);
  }
}
