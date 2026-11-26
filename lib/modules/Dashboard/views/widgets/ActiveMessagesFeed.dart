
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../../../widgets/DeskUi.dart';
import '../../controllers/DashboardController.dart';
import '../../../Notification/controllers/NotificationController.dart';
import 'MessageAttachmentViewerModal.dart';
import 'ServiceExpiredUnderProgressCard.dart';
import 'ServicePartialExpiryAlertCard.dart';

class ActiveMessagesFeed extends StatelessWidget {
  final String? clientName;

  const ActiveMessagesFeed({super.key, this.clientName});

  // Random message accent colors
  static const List<Color> messageColors = [
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    final dash = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    final notifController = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Obx(() {
      final serviceAccess = dash.serviceAccess.value;

      final bool isFullyExpired = dash.isExpired.value ||
          (serviceAccess != null &&
              !serviceAccess.hasActiveServices &&
              serviceAccess.expiredServicesCount > 0) ||
          (serviceAccess != null &&
              !serviceAccess.canViewServiceMessages);

      // Full Expiry
      if (isFullyExpired) {
        return ServiceExpiredUnderProgressCard(
          alertInfo: dash.expiredAlert.value,
          accessInfo: dash.serviceAccess.value,
        );
      }

      // Loading State
      if (dash.isMessagesLoading.value && dash.messages.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(36),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF6366F1),
            ),
          ),
        );
      }

      final messagesList = dash.messages;

      final hasPartialExpiryAlert = !isFullyExpired &&
          dash.expiredAlert.value != null &&
          dash.expiredAlert.value!.services.isNotEmpty;

      final partialAlertWidget = hasPartialExpiryAlert
          ? Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ServicePartialExpiryAlertCard(
          alert: dash.expiredAlert.value!,
        ),
      )
          : const SizedBox.shrink();

      // Empty Messages
      if (messagesList.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasPartialExpiryAlert) partialAlertWidget,

            const DeskNote(
              title: 'No Messages Yet',
              icon: Icons.mark_email_read_outlined,
              description:
              'Official market recommendations and broadcasts will appear here.',
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasPartialExpiryAlert) partialAlertWidget,

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: messagesList.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 12),

            itemBuilder: (context, index) {
              final item = messagesList[index];

              // Stable random color for each message
              final accentColor = messageColors[
              math.Random(item.message.hashCode ^ index)
                  .nextInt(messageColors.length)
              ];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEAEFFD),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64748B)
                          .withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),

                // Full Height Colored Strip
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      // This strip covers the COMPLETE card height
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 6,
                        child: ColoredBox(
                          color: accentColor,
                        ),
                      ),

                      // Card Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          21,
                          15,
                          15,
                          15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Message
                            Text(
                              item.message,
                              style: const TextStyle(
                                fontFamily: 'DeskSans',
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Divider
                            Container(
                              height: 1,
                              color: const Color(0xFFF1F5F9),
                            ),

                            const SizedBox(height: 12),

                            // Date & Attachment
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 15,
                                  color: Color(0xFF94A3B8),
                                ),

                                const SizedBox(width: 6),

                                Expanded(
                                  child: Text(
                                    item.date,
                                    style: const TextStyle(
                                      fontFamily: 'DeskSans',
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                if (item.hasAttachment)
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius:
                                      BorderRadius.circular(8),
                                      onTap: () {
                                        if (item.isUnread) {
                                          notifController
                                              .markSingleMessageRead(item);
                                        }

                                        MessageAttachmentViewerModal.show(
                                          context,
                                          imageUrl:
                                          item.resolvedAttachmentUrl!,
                                          title: 'Attachment',
                                          subtitle:
                                          '${item.sender} • ${item.date}',
                                        );
                                      },
                                      child: Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          border: Border.all(
                                            color:
                                            const Color(0xFFE0E7FF),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.attach_file_rounded,
                                              size: 14,
                                              color: Color(0xFF6366F1),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Attachment',
                                              style: TextStyle(
                                                fontFamily: 'DeskSans',
                                                fontSize: 11,
                                                fontWeight:
                                                FontWeight.w600,
                                                color:
                                                Color(0xFF6366F1),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}
