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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFECACA),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 11,
                  color: Color(0xFFDC2626),
                ),
                SizedBox(width: 4),
                Text(
                  'RENEWAL IN PROGRESS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Compact Icon
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_clock_rounded,
              color: Color(0xFFDC2626),
              size: 19,
            ),
          ),

          const SizedBox(height: 6),

          // Title
          const Text(
            'Service Subscription Expired',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 3),

          // Backend Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.25,
            ),
          ),

          // Services List
          if (services.isNotEmpty) ...[
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBFB),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: const Color(0xFFFEE2E2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 12,
                          color: Color(0xFFDC2626),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'YOUR EXPIRED SERVICES',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    height: 1,
                    thickness: 0.7,
                    color: Color(0xFFFEE2E2),
                  ),

                  ...services.asMap().entries.map((entry) {
                    final index = entry.key;
                    final svc = entry.value;
                    final expiryDate = svc.expiryDate?.trim() ?? '';

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  svc.name,
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                    height: 1.2,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 5),

                              if (expiryDate.isNotEmpty)
                                Flexible(
                                  child: Text(
                                    expiryDate,
                                    textAlign: TextAlign.end,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFDC2626),
                                      height: 1.2,
                                    ),
                                  ),
                                ),

                              // Comma after each service/date
                              const Text(
                                ',',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (index != services.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 0.6,
                            color: Color(0xFFF1F5F9),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 7),

          // Compact Information Note
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFFFDE68A),
                width: 0.7,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 12,
                  color: Color(0xFFD97706),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Live market calls will resume immediately upon subscription renewal.',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF92400E),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Contact / Renew Button
          SizedBox(
            width: double.infinity,
            height: 35,
            child: ElevatedButton.icon(
              onPressed: () => _handleContactDesk(context),
              icon: const Icon(
                Icons.phone_in_talk_rounded,
                size: 14,
                color: Colors.white,
              ),
              label: const Text(
                'Contact Advisory Desk / Renew',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Check Renewal Status
          TextButton.icon(
            onPressed: () => dash.syncDashboard(),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 1,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(
              Icons.refresh_rounded,
              size: 13,
              color: Color(0xFF64748B),
            ),
            label: const Text(
              'Check Renewal Status',
              style: TextStyle(
                fontSize: 10.5,
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
