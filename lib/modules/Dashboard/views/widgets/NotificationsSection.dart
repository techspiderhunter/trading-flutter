import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../themes/AppColors.dart';
import '../../../MainNav/controllers/MainNavController.dart';

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mainNavController = Get.find<MainNavController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active_outlined,
                    color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Notifications & Updates',
                  style: TextStyle(
                    fontFamily: 'DeskSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${mainNavController.notifications.length} alerts',
                  style: TextStyle(
                    fontFamily: 'DeskSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List of Notifications
        Obx(
          () => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mainNavController.notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notif = mainNavController.notifications[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: notif.isUnread
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.border,
                    width: notif.isUnread ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Container
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: notif.iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        notif.icon,
                        color: notif.tagColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Notification Body
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: notif.iconBgColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  notif.tag,
                                  style: TextStyle(
                                    fontFamily: 'DeskSans',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: notif.tagColor,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    notif.time,
                                    style: const TextStyle(
                                      fontFamily: 'DeskSans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  if (notif.isUnread) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif.title,
                            style: TextStyle(
                              fontFamily: 'DeskSans',
                              fontSize: 13.5,
                              fontWeight: notif.isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.message,
                            style: const TextStyle(
                              fontFamily: 'DeskSans',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
