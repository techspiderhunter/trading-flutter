import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/DeskUi.dart';
import '../../controllers/DashboardController.dart';
import '../../../Notification/controllers/NotificationController.dart';
import 'MessageAttachmentViewerModal.dart';
import 'ServiceExpiredUnderProgressCard.dart';
import 'ServicePartialExpiryAlertCard.dart';

class ActiveMessagesFeed extends StatelessWidget {
  final String? clientName;
  const ActiveMessagesFeed({super.key, this.clientName});

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
          (serviceAccess != null && !serviceAccess.canViewServiceMessages);

      // 1. Full Expiry: When ALL services are expired (isExpired == true)
      // Strict rule: Hide all messages completely and render "Under Progress / Service Expired" card!
      if (isFullyExpired) {
        return ServiceExpiredUnderProgressCard(
          alertInfo: dash.expiredAlert.value,
          accessInfo: dash.serviceAccess.value,
        );
      }

      // Offline-First: Only show spinner if there is ZERO data in SQLite and first network call is pending
      if (dash.isMessagesLoading.value && dash.messages.isEmpty) {
        return const Padding(
            padding: EdgeInsets.all(36),
            child: Center(child: CircularProgressIndicator()));
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

      if (messagesList.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasPartialExpiryAlert) partialAlertWidget,
            const DeskNote(
                title: 'No Messages Yet',
                icon: Icons.mark_email_read_outlined,
                description:
                    'Official market recommendations and broadcasts will appear here.'),
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
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final item = messagesList[index];
                return DeskMessageCard(
                  title: '', // Title/Subject removed as requested: only message body & date/sender shown
                  subtitle:
                      '${item.sender} · ${item.date}${item.isUnread ? ' · Unread' : ''}',
                  message: item.message,
                  onAttachment: item.hasAttachment
                      ? () {
                          if (item.isUnread) {
                            notifController.markSingleMessageRead(item);
                          }
                          MessageAttachmentViewerModal.show(
                            context,
                            imageUrl: item.resolvedAttachmentUrl!,
                            title: 'Attachment',
                            subtitle: '${item.sender} • ${item.date}',
                          );
                        }
                      : null,
                );
              }),
        ],
      );
    });
  }
}
