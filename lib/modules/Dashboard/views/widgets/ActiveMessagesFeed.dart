import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../themes/AppColors.dart';
import '../../controllers/DashboardController.dart';
import '../../../Notification/controllers/NotificationController.dart';
import 'MessageAttachmentViewerModal.dart';

/// Clean dynamic market communications & advisory feed
/// Styled identically to the original layout with left accent color bar,
/// pure white card background, no "NEW" badge, and clean tap actions.
class ActiveMessagesFeed extends StatelessWidget {
  final String? clientName;

  const ActiveMessagesFeed({
    super.key,
    this.clientName,
  });

  @override
  Widget build(BuildContext context) {
    final dash = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    final notifController = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Obx(() {
      // Offline-First: Only show spinner if there is ZERO data in SQLite and first network call is pending
      if (dash.isMessagesLoading.value && dash.messages.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
        );
      }

      final messagesList = dash.messages;

      if (messagesList.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(Icons.mark_email_read_outlined,
                      color: Color(0xFF94A3B8), size: 28),
                ),
              ),
              SizedBox(height: 14),
              Text(
                'No Messages Yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Official research advisories and communications will appear here in real time as dispatched by your advisory desk.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }

      final colors = [
        const Color(0xFF2563EB), // Blue
        const Color(0xFF10B981), // Green
        const Color(0xFF8B5CF6), // Purple
        const Color(0xFFF59E0B), // Amber
        const Color(0xFF06B6D4), // Cyan
      ];

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: messagesList.length,
        itemBuilder: (context, index) {
          final item = messagesList[index];
          final accentColor = colors[index % colors.length];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Accent Bar (Blue, Green, Purple, Amber)
                        Container(
                          width: 4.5,
                          color: accentColor,
                        ),

                        // Card Body
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title / Subject
                                Text(
                                  item.subject,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Message Preview / Body
                                Text(
                                  item.message,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),

                                // VIEW ATTACHMENT BUTTON:
                                // STRICT CONDITION: Rendered ONLY if the message has an attachment from backend!
                                if (item.hasAttachment) ...[
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (item.isUnread) {
                                        notifController.markSingleMessageRead(item);
                                      }
                                      MessageAttachmentViewerModal.show(
                                        context,
                                        imageUrl: item.resolvedAttachmentUrl!,
                                        title: item.subject,
                                        subtitle:
                                            '${item.sender} • ${item.date}',
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                          color: const Color(0xFFBFDBFE),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.attachment_rounded,
                                            size: 16,
                                            color: Color(0xFF2563EB),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'View Attachment',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 16,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 14),

                                // Bottom Row: Date & Time (Left) and Sender (Right)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item.date,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Text(
                                    //   item.sender,
                                    //   style: const TextStyle(
                                    //     fontSize: 11.5,
                                    //     color: Color(0xFF64748B),
                                    //     fontWeight: FontWeight.w600,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
      }
    }
