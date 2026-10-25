import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/DeskUi.dart';
import '../../controllers/DashboardController.dart';
import '../../../Notification/controllers/NotificationController.dart';
import 'MessageAttachmentViewerModal.dart';

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
      if (dash.isMessagesLoading.value && dash.messages.isEmpty)
        return const Padding(
            padding: EdgeInsets.all(36),
            child: Center(child: CircularProgressIndicator()));
      final messagesList = dash.messages;
      if (messagesList.isEmpty)
        return const DeskNote(
            title: 'No Messages Yet',
            icon: Icons.mark_email_read_outlined,
            description:
                'Official market recommendations and broadcasts will appear here.');
      return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: messagesList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final item = messagesList[index];
            return DeskMessageCard(
              title: item.subject,
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
                        title: item.subject,
                        subtitle: '${item.sender} • ${item.date}',
                      );
                    }
                  : null,
            );
          });
    });
  }
}
