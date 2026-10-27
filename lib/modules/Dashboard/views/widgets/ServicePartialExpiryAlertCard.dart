import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/ServiceExpiryModel.dart';

/// Reddish Alert Card displayed directly above the Messages Feed
/// Shown when isExpired == false AND expiredAlert != null (some services expired, active services remain).
class ServicePartialExpiryAlertCard extends StatelessWidget {
  final ExpiredAlertInfo alert;

  const ServicePartialExpiryAlertCard({
    super.key,
    required this.alert,
  });

  Future<void> _handleContactDesk() async {
    const supportNumber = '+919109033327';
    final uri = Uri.parse('tel:$supportNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final services = alert.services;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Light reddish alert background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFCA5A5), // Reddish alert border
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Red Accent Indicator Bar on Left
              Container(
                width: 5,
                color: const Color(0xFFDC2626),
              ),

              // Card Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Warning Icon + Title + Action Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Subscription Expiry Notice',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF991B1B), // Dark crimson
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Attention Required',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFDC2626),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Compact Renew Button
                          InkWell(
                            onTap: _handleContactDesk,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.phone_in_talk_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Renew',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Explanatory Message from Backend
                      Text(
                        alert.message,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7F1D1D),
                          height: 1.38,
                        ),
                      ),

                      // Expired Services Badges
                      if (services.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: services.map((svc) {
                            final dateText = (svc.expiryDate != null &&
                                    svc.expiryDate!.isNotEmpty)
                                ? ' (${svc.expiryDate})'
                                : '';
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFECACA),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.cancel_rounded,
                                      size: 12,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      '${svc.name}$dateText',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF991B1B),
                                        height: 1.25,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
