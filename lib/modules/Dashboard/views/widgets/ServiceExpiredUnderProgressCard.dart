import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../themes/AppColors.dart';
import '../../../../models/ServiceExpiryModel.dart';
import '../../controllers/DashboardController.dart';

/// "Service Expired / Under Progress" Card
/// Displayed when isExpired == true (all client services are expired).
/// Perfectly adjusted to fit the viewport without scrolling,
/// and displays complete service names without truncation.
class ServiceExpiredUnderProgressCard extends StatelessWidget {
  final ExpiredAlertInfo? alertInfo;
  final ServiceAccessInfo? accessInfo;

  const ServiceExpiredUnderProgressCard({
    super.key,
    this.alertInfo,
    this.accessInfo,
  });

  Future<void> _handleContactDesk(BuildContext context) async {
    const supportNumber = '+919109033327';
    final uri = Uri.parse('tel:$supportNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!context.mounted) return;
        _showContactInfoDialog(context, supportNumber);
      }
    } catch (_) {
      if (!context.mounted) return;
      _showContactInfoDialog(context, supportNumber);
    }
  }

  void _showContactInfoDialog(BuildContext context, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Advisory Support Desk',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please connect with our team to renew your services and reactivate market recommendations:',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.35),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_rounded, size: 16, color: Color(0xFF0F172A)),
                  const SizedBox(width: 8),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dash = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    final services = alertInfo?.services ?? [];
    final message = alertInfo?.message ??
        'Your services have expired. Please contact our team to renew your services.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFECACA), // Soft red/coral border
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Status Pill: Renewal / Under Progress Alert
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 12,
                  color: Color(0xFFDC2626),
                ),
                SizedBox(width: 5),
                Text(
                  'RENEWAL IN PROGRESS',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2. Circular Icon Badge
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1F2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_clock_rounded,
                  color: Color(0xFFDC2626),
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Title
          const Text(
            'Service Subscription Expired',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),

          // 4. Backend Alert Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ),

          // 5. Expired Services Breakdown (Shows FULL names without truncation)
          if (services.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history_toggle_off_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      SizedBox(width: 5),
                      Text(
                        'EXPIRED SERVICES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...services.map((svc) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            // Service Name: Fully visible, NO truncation (softWrap enabled)
                            Expanded(
                              child: Text(
                                svc.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                  height: 1.25,
                                ),
                                softWrap: true,
                              ),
                            ),
                            if (svc.expiryDate != null && svc.expiryDate!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: const Color(0xFFFECACA), width: 0.8),
                                ),
                                child: Text(
                                  'Expired: ${svc.expiryDate}',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // 6. Explanatory Note regarding paused feed
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Color(0xFFD97706),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Live market calls will resume immediately upon subscription renewal.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF92400E),
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 7. Action Button: Contact Advisory Desk / Renew
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () => _handleContactDesk(context),
              icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: Colors.white),
              label: const Text(
                'Contact Advisory Desk / Renew',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // 8. Refresh Check Status button (Compact)
          TextButton.icon(
            onPressed: () => dash.syncDashboard(),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 15, color: Color(0xFF64748B)),
            label: const Text(
              'Check Renewal Status',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
