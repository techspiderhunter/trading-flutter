import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/colors.dart';
import '../../../widgets/DeskUi.dart';
import '../controllers/NotificationController.dart';
import '../models/NotificationModels.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  static void open(BuildContext context) {
    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());
    controller.selectedTab.value = 0;
    controller.loadAll();
    Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const NotificationView()));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: DeskAppBar(group: 'Notifications', actions: [

        const SizedBox(width: 8),
      ]),
      body: SafeArea(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Padding(
              padding: EdgeInsets.fromLTRB(24, 22, 24, 20),
              child: DeskHero(
                  title: 'Notifications',
                  subtitle: 'Your account updates and compliance notices.')),
          Expanded(child: NotificationList(controller: controller)),
        ]),
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final NotificationController controller;
  const NotificationList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => RefreshIndicator(
      onRefresh: controller.loadNotifications,
      child: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return LayoutBuilder(builder: (context, constraints) {
          final inset = constraints.maxWidth > 688
              ? (constraints.maxWidth - 640) / 2
              : 24.0;
          return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(inset, 0, inset, 24),
              itemCount: controller.notifications.isEmpty
                  ? 1
                  : controller.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (controller.notifications.isEmpty) {
                  return const DeskNote(
                      title: 'No notifications yet',
                      description:
                          'Account and compliance updates will appear here.');
                }
                final notification = controller.notifications[index];
                return NotificationCard(
                    notification: notification,
                    onTap: () =>
                        controller.handleNotificationTap(notification));
              });
        });
      }));
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  const NotificationCard(
      {super.key, required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final item = notification;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: item.isUnread
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.borderLight)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: item.iconBgColor, shape: BoxShape.circle),
                child: Icon(item.icon, size: 22, color: item.tagColor)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Text(item.title,
                                  style: deskText.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600))),
                          if (item.isUnread) ...[
                            const SizedBox(width: 8),
                            const Padding(
                                padding: EdgeInsets.only(top: 7),
                                child: Icon(Icons.circle,
                                    size: 7, color: AppColors.primary)),
                          ],
                        ]),
                    const SizedBox(height: 7),
                    Text(item.message,
                        style: deskText.copyWith(
                            fontSize: 12,
                            height: 1.65,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 14),
                    Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                  color: item.iconBgColor,
                                  borderRadius: BorderRadius.circular(7)),
                              child: Text(item.tag,
                                  style: deskText.copyWith(
                                      fontSize: 10,
                                      color: item.tagColor,
                                      fontWeight: FontWeight.w600))),
                          Text(item.time,
                              style: deskText.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ]),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}
