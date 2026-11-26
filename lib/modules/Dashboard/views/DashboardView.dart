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
import '../../../widgets/DeskUi.dart';

/// Highly Optimized, Responsive Dashboard View matching the exact original design
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
      backgroundColor: const Color(0xFFF8FAFC),
      // 1. Sleek, Modern App Header matching screenshot exactly
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 68,
          automaticallyImplyLeading: false,
          titleSpacing: 20,
          title: Row(
            children: [
              Image.asset(
                'assets/system/logo_icon.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'NM RESEARCH PARTNER',
                    style: TextStyle(
                      fontFamily: 'DeskSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D253A),
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'PRIVATE LIMITED · DASHBOARD',
                    style: TextStyle(
                      fontFamily: 'DeskSans',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC59B27),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Obx(() {
              final unread = dashboardController.unreadNotificationsCount.value;
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                        color: Color(0xFF0F1E36),
                      ),
                      tooltip: 'Notifications & Alerts',
                      onPressed: () => NotificationView.open(context),
                    ),
                    if (unread > 0)
                      Positioned(
                        top: 8,
                        right: 9,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4B4B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(width: 10),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2F8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 22,
                  color: Color(0xFF0F1E36),
                ),
                tooltip: 'Setting',
                onPressed: () => Get.toNamed(SettingRoutes.setting),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),

      // 2. Responsive Body with Refresh Indicator
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await dashboardController.syncDashboard();
            await mainNavController.syncUserAndKyc();
          },
          color: const Color(0xFF6366F1),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final hPadding = isWide ? 32.0 : 20.0;

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
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Exact Pastel Gradient Welcome Banner Card
                          _buildOptimizedHeaderCard(dashboardController),

                          const SizedBox(height: 18),

                          // 2. Dynamic KYC Status Cards / Messages Feed
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
                                  color: Color(0xFF6366F1),
                                ),
                              );
                            }

                            // 2. Verified State -> Shows Real Messages Feed with Section Heading
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
                                    dashboardController.referenceId.value,
                              );
                            }

                            // 5. Default / Fallback: Lock Card with "Start KYC" button
                            return const KycInitialLockCard();
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

  /// Exact Gradient Welcome Banner Card with 3D Graphic
  Widget _buildOptimizedHeaderCard(DashboardController dashboardController) {
    return Obx(() {
      final rawName = dashboardController.clientName.value.trim();
      final name = (rawName.isNotEmpty && rawName != 'Client')
          ? rawName
          : 'Trader';
      final displayName = name.endsWith('.') ? name : '$name.';

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF5FF),
              Color(0xFFF5EFFF),
              Color(0xFFDFE9FF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Right side 3D ascending chart & arrow illustration
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Image.asset(
                  'assets/placeholders/dashboard_chart_graphic.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                ),
              ),

              // Left side text greeting & description
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 120, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('👋', style: TextStyle(fontSize: 15)),
                        SizedBox(width: 6),
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontFamily: 'DeskSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontFamily: 'DeskSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F1E36),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your market research & regulatory portal.',
                      style: TextStyle(
                        fontFamily: 'DeskSans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Section Header: Purple pill + "Messages & Advisories"
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 19,
            decoration: BoxDecoration(
              color: const Color(0xFF818CF8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Messages & Advisories',
            style: TextStyle(
              fontFamily: 'DeskSans',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F1E36),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedActiveCard(String clientName) {
    final dash = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          if (dash.isExpired.value) {
            return const SizedBox.shrink();
          }
          return _buildSectionHeader();
        }),
        ActiveMessagesFeed(clientName: clientName),
      ],
    );
  }

  Widget _buildRejectedCard(String? reason) {
    final displayReason = reason != null && reason.isNotEmpty
        ? reason
        : 'Identity proofs were incomplete or unreadable.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DeskNote(
          title: 'Action Needed',
          description: displayReason,
          color: AppColors.error,
          icon: Icons.priority_high_rounded,
        ),
        const SizedBox(height: 18),
        DeskButton(
          label: 'Re-submit KYC Documents',
          onPressed: () => Get.toNamed(KycRoutes.kycIndex),
        ),
      ],
    );
  }
}
