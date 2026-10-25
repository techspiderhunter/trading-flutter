import '../../../../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../themes/AppColors.dart';
import '../../../Notification/controllers/NotificationController.dart';
import '../../../Notification/models/NotificationModels.dart';

/// Regulatory alerts bottom sheet. Advisory messages stay in the dashboard feed.
class NotificationsBottomSheet extends StatelessWidget {
  const NotificationsBottomSheet({super.key});

  static void show(BuildContext context, {int initialTab = 0}) {
    if (Get.isRegistered<NotificationController>()) {
      final c = Get.find<NotificationController>();
      c.selectedTab.value = 0;
      c.loadAll();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());
    return Container(
        height: MediaQuery.sizeOf(context).height * 0.90,
        decoration: const BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: SafeArea(
            top: false,
            child: Column(children: [
              const SizedBox(height: 12),
              Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                        onPressed: () {
                          controller.selectedTab.value = 0;
                          controller.markAllAsRead();
                        },
                        child: const Text('Mark all read')),
                    IconButton(
                        tooltip: 'Close',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context)),
                  ])),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: DeskHero(
                      title: 'Your updates.',
                      subtitle:
                          'Official communication from your research desk.')),
              const SizedBox(height: 25),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                      child: Text('Notifications',
                          textAlign: TextAlign.center,
                          style: deskText.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)))),
              const SizedBox(height: 16),
              Expanded(child: Obx(() {
                if (controller.isLoading.value &&
                    controller.notifications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.notifications.isEmpty) {
                  return const SingleChildScrollView(
                      padding: EdgeInsets.all(24),
                      child: DeskNote(
                          title: 'No Alerts Yet',
                          description:
                              'Regulatory and KYC notices will appear here.'));
                }
                return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: controller.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) => _buildNotificationCard(
                        context, controller, controller.notifications[index]));
              })),
            ])));
  }

  Widget _buildNotificationCard(BuildContext context,
          NotificationController controller, NotificationModel notif) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        DeskRow(
            title: notif.title,
            subtitle:
                '${notif.tag} · ${notif.time}${notif.isUnread ? ' · Unread' : ''}',
            onTap: () => controller.handleNotificationTap(notif)),
        const SizedBox(height: 15),
        DeskNote(title: 'Regulatory notice', description: notif.message),
      ]);
}
