import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/AppColors.dart';
import '../controllers/DashboardController.dart';
import '../../MainNav/controllers/MainNavController.dart';
import '../../Kyc/routes/KycRoutes.dart';
import 'widgets/KycInitialLockCard.dart';
import 'widgets/KycUnderReviewCard.dart';
import 'widgets/NotificationsBottomSheet.dart';
import 'widgets/ActiveMessagesFeed.dart';
import '../../../widgets/MoneyViaLogo.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  static String _getInitials(String name) {
    if (name.isEmpty || name == 'Client') return 'MS';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'MS';
  }

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: [
            const MoneyaraLogoBadge(size: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Moneyara',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0A1C3E),
                    letterSpacing: -0.4,
                    height: 1.1,
                  ),
                ),
                Text(
                  'RESEARCH',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A62FF),
                    letterSpacing: 2.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [

          // Bell Icon with dynamic real-time badge -> Opens notifications sheet
          Obx(() {
            final unread = dashboardController.unreadNotificationsCount.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: Color(0xFF1E293B), size: 24),
                  onPressed: () {
                    NotificationsBottomSheet.show(context);
                  },
                ),
                if (unread > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await dashboardController.syncDashboard();
            await mainNavController.syncUserAndKyc();
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Reactive Welcome Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Obx(
                        () {
                          final name = dashboardController.clientName.value.isNotEmpty &&
                                  dashboardController.clientName.value != 'Client'
                              ? dashboardController.clientName.value
                              : '';
                          return Text(
                            'Welcome, $name',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // DYNAMIC KYC STATUS CARDS IN DASHBOARD
                Obx(() {
                  final status = dashboardController.kycStatus.value.trim().toLowerCase();
                  final isSubmitted = dashboardController.isKycSubmitted.value;
                  final kyc = dashboardController.kycProfile.value;

                  // 1. Not Submitted State: Strict gate for new registrations & unsubmitted users
                  final bool isNotSubmitted = (status == 'not_submitted' || status.isEmpty) &&
                      (kyc == null || kyc.isNotSubmitted) &&
                      !isSubmitted;

                  if (isNotSubmitted) {
                    return const KycInitialLockCard();
                  }

                  // 2. Verified & Approved State (STRICTLY ONLY when KYC is verified by compliance admin)
                  final bool isVerifiedState = (kyc != null && kyc.isVerified && status == 'verified') ||
                      (status == 'verified' && (kyc == null || (!kyc.isNotSubmitted && !kyc.isPending && !kyc.isRejected)));

                  if (isVerifiedState) {
                    return _buildVerifiedActiveCard(dashboardController.clientName.value);
                  }

                  // 3. Rejected State (Remark ke saath aur Start KYC button)
                  final bool isRejectedState = (kyc != null && kyc.isRejected) ||
                      status == 'rejected' ||
                      status == 'declined' ||
                      status == 'action_required';

                  if (isRejectedState) {
                    return _buildRejectedCard(dashboardController.rejectionReason.value);
                  }

                  // 4. Submitted & Under Review State (SIRF Under Review Card, NO remark, NO start kyc button)
                  final bool isPendingState = isSubmitted ||
                      (kyc != null && kyc.isPending) ||
                      status == 'pending' ||
                      status == 'under_review' ||
                      status == 'submitted';

                  if (isPendingState) {
                    return KycUnderReviewCard(referenceId: dashboardController.referenceId.value);
                  }

                  // 5. Default / Fallback: Lock Card with "Start KYC" button inside
                  return const KycInitialLockCard();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedActiveCard(String clientName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Messages',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Stay updated with the latest market communications, research alerts and important notices.',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),

        // Dynamic communications & messages feed
        ActiveMessagesFeed(clientName: clientName),
      ],
    );
  }

  Widget _buildRejectedCard(String? reason) {
    final displayReason = reason != null && reason.isNotEmpty
        ? reason
        : 'Identity proofs were incomplete or unreadable.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.cancel_rounded,
                color: Color(0xFFEF4444),
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'KYC Rejected',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Text(
              'Reason: $displayReason',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Get.toNamed(KycRoutes.kycIndex),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Re-submit KYC Documents',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
