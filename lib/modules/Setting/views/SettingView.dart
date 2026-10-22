import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/AppColors.dart';
import '../../Profile/controllers/ProfileController.dart';
import '../../Profile/routes/ProfileRoutes.dart';
import '../../Kyc/routes/KycRoutes.dart';
import '../../Kyc/controllers/KycController.dart';
import '../../Mitc/routes/MitcRoutes.dart';
import '../../Mitc/controllers/MitcController.dart';
import '../../Invoice/routes/InvoiceRoutes.dart';
import '../../MainNav/controllers/MainNavController.dart';
import '../../../widgets/MoneyViaLogo.dart';

/// Setting screen in Main Navigation with reactive, synchronized options for Profile, KYC, and MITC
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
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            MoneyaraLogoBadge(size: 28),
            SizedBox(width: 8),
            Text(
              'Setting',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await profileController.loadProfile();
            await mainNavController.syncUserAndKyc();
            await mitcController.loadMitcProfile();
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Info Card Banner
                Obx(() {
                  final name = profileController.clientName.value.isNotEmpty &&
                          profileController.clientName.value != 'Loading...'
                      ? profileController.clientName.value
                      : (mainNavController.currentUser.value?.name ?? 'Client User');
                  final email = profileController.clientEmail.value.isNotEmpty
                      ? profileController.clientEmail.value
                      : (mainNavController.currentUser.value?.email ?? '');
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7F0),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00B074),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00B074),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Section Heading
                const Text(
                  'Account Options',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // 1. Profile Option Card
                _buildSettingOptionCard(
                  icon: Icons.person_outline_rounded,
                  iconColor: const Color(0xFF2563EB),
                  iconBgColor: const Color(0xFFEFF6FF),
                  title: 'Profile',
                  subtitle: 'Personal details, avatar & password',
                  onTap: () {
                    Get.toNamed(ProfileRoutes.profile);
                  },
                ),
                const SizedBox(height: 12),

                // 2. KYC Option Card (Dynamic & linked to real status)
                Obx(() {
                  final status = mainNavController.kycStatus.value.trim().toLowerCase();
                  final kyc = mainNavController.kycProfile.value;
                  final isVerified = status == 'verified' || (kyc != null && kyc.isVerified);
                  final isPending = status == 'pending' || status == 'under_review' || (kyc != null && kyc.isPending);
                  final isRejected = status == 'rejected' || status == 'declined' || (kyc != null && kyc.isRejected);

                  String subtitle = 'Identity verification & statutory compliance';
                  String badgeText = 'START KYC';
                  Color badgeColor = const Color(0xFF1E67FA);
                  Color badgeBgColor = const Color(0xFFEFF6FF);
                  Color iconColor = const Color(0xFF1E67FA);
                  Color iconBgColor = const Color(0xFFEFF6FF);

                  if (isVerified) {
                    subtitle = 'SEBI Regulatory KYC Verified & Approved';
                    badgeText = 'VERIFIED';
                    badgeColor = const Color(0xFF059669);
                    badgeBgColor = const Color(0xFFECFDF5);
                    iconColor = const Color(0xFF059669);
                    iconBgColor = const Color(0xFFECFDF5);
                  } else if (isPending) {
                    subtitle = 'KYC Under Review • Compliance audit pending';
                    badgeText = 'UNDER REVIEW';
                    badgeColor = const Color(0xFFD97706);
                    badgeBgColor = const Color(0xFFFEF3C7);
                    iconColor = const Color(0xFFD97706);
                    iconBgColor = const Color(0xFFFEF3C7);
                  } else if (isRejected) {
                    subtitle = 'KYC Rejected • Action required to re-submit';
                    badgeText = 'REJECTED';
                    badgeColor = const Color(0xFFDC2626);
                    badgeBgColor = const Color(0xFFFEF2F2);
                    iconColor = const Color(0xFFDC2626);
                    iconBgColor = const Color(0xFFFEF2F2);
                  }

                  return _buildSettingOptionCard(
                    icon: Icons.verified_user_outlined,
                    iconColor: iconColor,
                    iconBgColor: iconBgColor,
                    title: 'KYC Verification',
                    subtitle: subtitle,
                    badgeText: badgeText,
                    badgeColor: badgeColor,
                    badgeBgColor: badgeBgColor,
                    onTap: () {
                      if (isRejected) {
                        _showKycRejectionDialog(
                          context,
                          kyc?.rejectionReason,
                        );
                      } else {
                        Get.toNamed(KycRoutes.kycIndex);
                      }
                    },
                  );
                }),
                const SizedBox(height: 12),

                // 3. MITC Option Card (Dynamic & linked to real status)
                Obx(() {
                  final status = mitcController.currentStatus.value.trim().toLowerCase();
                  final mitc = mitcController.mitcProfile.value;
                  final isVerified = status == 'verified' || (mitc != null && mitc.isVerified);
                  final isPending = status == 'pending' || status == 'under_review' || (mitc != null && mitc.isPending);
                  final isRejected = status == 'rejected' || status == 'declined' || (mitc != null && mitc.isRejected);

                  String subtitle = 'Most Important Terms and Conditions';
                  String badgeText = 'START MITC';
                  Color badgeColor = const Color(0xFF8B5CF6);
                  Color badgeBgColor = const Color(0xFFF5F3FF);

                  if (isVerified) {
                    subtitle = 'MITC Agreement Verified & Active';
                    badgeText = 'VERIFIED';
                    badgeColor = const Color(0xFF059669);
                    badgeBgColor = const Color(0xFFECFDF5);
                  } else if (isPending) {
                    subtitle = 'Agreement submitted • Audit in progress';
                    badgeText = 'UNDER REVIEW';
                    badgeColor = const Color(0xFFD97706);
                    badgeBgColor = const Color(0xFFFEF3C7);
                  } else if (isRejected) {
                    subtitle = 'Agreement rejected • Re-submission required';
                    badgeText = 'REJECTED';
                    badgeColor = const Color(0xFFDC2626);
                    badgeBgColor = const Color(0xFFFEF2F2);
                  }

                  return _buildSettingOptionCard(
                    icon: Icons.description_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor: const Color(0xFFF5F3FF),
                    title: 'MITC Agreement',
                    subtitle: subtitle,
                    badgeText: badgeText,
                    badgeColor: badgeColor,
                    badgeBgColor: badgeBgColor,
                    onTap: () {
                      Get.toNamed(MitcRoutes.mitcIndex);
                    },
                  );
                }),
                const SizedBox(height: 12),

                // 4. Tax Invoices Option Card
                _buildSettingOptionCard(
                  icon: Icons.receipt_long_rounded,
                  iconColor: const Color(0xFF0D9488),
                  iconBgColor: const Color(0xFFF0FDFA),
                  title: 'Tax Invoices',
                  subtitle: 'GST invoices, payment receipts & billing history',
                  onTap: () {
                    Get.toNamed(InvoiceRoutes.invoiceIndex);
                  },
                ),

                const SizedBox(height: 28),

                // Logout Option Button
                InkWell(
                  onTap: () => profileController.logout(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Rejection popup dialog matching Dashboard rejected card behavior
  void _showKycRejectionDialog(BuildContext context, String? reason) {
    final displayReason = reason != null && reason.isNotEmpty
        ? reason
        : 'Identity proofs or documents were incomplete or unreadable.';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 36),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'KYC Verification Rejected',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Compliance Desk Reason:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayReason,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF7F1D1D),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back(); // Dismiss dialog
                    final kycCtrl = Get.isRegistered<KycController>()
                        ? Get.find<KycController>()
                        : Get.put(KycController());
                    kycCtrl.startResubmission();
                    Get.toNamed(KycRoutes.kycIndex);
                  },
                  icon: const Icon(Icons.edit_document, size: 18, color: Colors.white),
                  label: const Text(
                    'Re-submit KYC Documents',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(KycRoutes.kycIndex);
                  },
                  child: const Text(
                    'View Status Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 23),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle with Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: badgeBgColor ?? const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: badgeColor ?? const Color(0xFF64748B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Trailing Arrow
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
