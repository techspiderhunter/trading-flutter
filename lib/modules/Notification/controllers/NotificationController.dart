import '../../../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/NotificationModels.dart';
import '../requests/NotificationRequest.dart';
import '../../../models/ClientMessageModel.dart';
import '../../../models/ServiceExpiryModel.dart';
import '../../../includes/Storage.dart';
import '../../Kyc/routes/KycRoutes.dart';
import '../../Mitc/routes/MitcRoutes.dart';
import '../../Dashboard/controllers/DashboardController.dart';
import '../../Dashboard/views/widgets/MessageAttachmentViewerModal.dart';
import '../../../database/db_helper.dart';

/// MVC Controller for Notifications & Messages Module
/// 100% Dynamic backend synchronization with Laravel API
/// Handles both Regulatory Notifications (KYC/MITC) and Official Broadcast Messages
class NotificationController extends GetxController {
  final NotificationRequest _notificationRequest = NotificationRequest();

  // Active Tab: 0 = Notifications (KYC, MITC, Compliance), 1 = Messages (Advisories, Broadcasts)
  final selectedTab = 0.obs;

  // Regulatory Notifications
  final notifications = <NotificationModel>[].obs;
  final unreadNotificationsCount = 0.obs;

  // Broadcast Messages & Market Advisories
  final messages = <ClientMessageModel>[].obs;
  final unreadMessagesCount = 0.obs;

  // Service Expiry State
  final isExpired = false.obs;
  final expiredAlert = Rx<ExpiredAlertInfo?>(null);

  final isLoading = false.obs;

  int get totalUnreadCount =>
      unreadNotificationsCount.value + unreadMessagesCount.value;

  @override
  void onInit() {
    super.onInit();
    _loadCachedMessagesImmediately();
    loadAll();
  }

  /// Instant Offline Load from SQLite
  Future<void> _loadCachedMessagesImmediately() async {
    final cachedExpiryJson =
        LocalStorage.read(DashboardController.serviceExpiryStorageKey);
    if (cachedExpiryJson != null && cachedExpiryJson.isNotEmpty) {
      try {
        final feed = ClientMessagesFeedPayload.fromJsonString(cachedExpiryJson);
        isExpired.value = feed.isExpired;
        expiredAlert.value = feed.expiredAlert;
        if (isExpired.value) {
          messages.clear();
          unreadMessagesCount.value = 0;
          return;
        }
      } catch (_) {}
    }

    try {
      final cached = await DBHelper().getMessages(limit: 100);
      if (cached.isNotEmpty && !isExpired.value) {
        messages.assignAll(cached);
        unreadMessagesCount.value = messages.where((m) => m.isUnread).length;
      }
    } catch (_) {}
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadNotifications(),
      loadMessages(),
    ]);
  }

  /// Load KYC & Compliance Notifications: GET /api/client/notifications
  Future<void> loadNotifications() async {
    if (!LocalStorage.hasToken()) {
      notifications.clear();
      unreadNotificationsCount.value = 0;
      return;
    }

    try {
      if (notifications.isEmpty && messages.isEmpty) {
        isLoading.value = true;
      }
      final res = await _notificationRequest.getNotifications();

      if (res.success && res.data != null) {
        notifications.assignAll(res.data!);
        final count = notifications.where((n) => n.isUnread).length;
        unreadNotificationsCount.value = count;

        _syncDashboardUnread();
      }
    } catch (_) {
      // Graceful error handling
    } finally {
      isLoading.value = false;
    }
  }

  /// Load Official Broadcast Messages: GET /api/client/messages
  /// Uses Offline-First architecture with sqflite local caching & service expiry checking
  Future<void> loadMessages() async {
    if (!LocalStorage.hasToken()) {
      messages.clear();
      unreadMessagesCount.value = 0;
      return;
    }

    try {
      // 1. Instant Offline Load from SQLite (only if NOT expired):
      if (!isExpired.value) {
        final cached = await DBHelper().getMessages(limit: 100);
        if (cached.isNotEmpty && !isExpired.value) {
          messages.assignAll(cached);
          unreadMessagesCount.value = messages.where((m) => m.isUnread).length;
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().messages.assignAll(cached);
          }
        }
      }

      // 2. Fresh Network Sync from Laravel API:
      final res = await _notificationRequest.getClientMessagesFeed();
      if (res.success && res.data != null) {
        final feed = res.data!;
        isExpired.value = feed.isExpired;
        expiredAlert.value = feed.expiredAlert;

        // Sync with DashboardController
        if (Get.isRegistered<DashboardController>()) {
          final dash = Get.find<DashboardController>();
          dash.isExpired.value = feed.isExpired;
          dash.expiredAlert.value = feed.expiredAlert;
          dash.serviceAccess.value = feed.serviceAccess;
        }

        if (feed.isExpired) {
          messages.clear();
          unreadMessagesCount.value = 0;
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().messages.clear();
          }
        } else {
          messages.assignAll(feed.messages);
          final count = messages.where((m) => m.isUnread).length;
          unreadMessagesCount.value = count;

          // 3. Save fresh messages to local SQLite database:
          await DBHelper().saveMessages(feed.messages);

          // Also sync with DashboardController messages
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().messages.assignAll(feed.messages);
          }
        }
      }
    } catch (_) {
      // Graceful error handling - cached SQLite messages remain visible
    }
  }

  void _syncDashboardUnread() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().unreadNotificationsCount.value =
          unreadNotificationsCount.value;
    }
  }

  /// Handle Notification Click (KYC / MITC direct navigation)
  Future<void> handleNotificationTap(NotificationModel notif) async {
    // 1. Mark as read on backend
    if (notif.isUnread) {
      _notificationRequest.markRead(notif.id);

      final index = notifications.indexWhere((n) => n.id == notif.id);
      if (index != -1) {
        notifications[index] = NotificationModel(
          id: notif.id,
          title: notif.title,
          message: notif.message,
          time: notif.time,
          tag: notif.tag,
          target: notif.target,
          link: notif.link,
          icon: notif.icon,
          tagColor: notif.tagColor,
          iconBgColor: notif.iconBgColor,
          isUnread: false,
        );
      }

      unreadNotificationsCount.value =
          notifications.where((n) => n.isUnread).length;
      _syncDashboardUnread();
    }

    // 2. Direct Redirection on Click based on backend target payload
    final target = notif.target.toLowerCase().trim();
    if (target == 'kyc' || notif.link.contains('/client/kyc')) {
      if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
        Get.back(); // Close bottom sheet
      }
      Get.toNamed(KycRoutes.kycIndex);
    } else if (target == 'mitc' || notif.link.contains('/client/mitc')) {
      if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
        Get.back(); // Close bottom sheet
      }
      Get.toNamed(MitcRoutes.mitcIndex);
    }
  }

  /// Silently mark single message as read without opening any dialog
  Future<void> markSingleMessageRead(ClientMessageModel msg) async {
    if (msg.isUnread) {
      // Mark read on Laravel backend: POST /api/client/messages/{id}/read
      _notificationRequest.markMessageRead(msg.id);
      // Mark read in local SQLite
      DBHelper().markMessageAsRead(msg.id);

      final index = messages.indexWhere((m) => m.id == msg.id);
      if (index != -1) {
        messages[index] = msg.copyWith(isUnread: false);
      }

      unreadMessagesCount.value = messages.where((m) => m.isUnread).length;
      _syncDashboardUnread();

      // Update DashboardController list
      if (Get.isRegistered<DashboardController>()) {
        final dash = Get.find<DashboardController>();
        final dIndex = dash.messages.indexWhere((m) => m.id == msg.id);
        if (dIndex != -1) {
          dash.messages[dIndex] = msg.copyWith(isUnread: false);
        }
      }
    }
  }

  /// Handle Message Click (Mark as Read on backend and open Detail Modal)
  void handleMessageTap(BuildContext context, ClientMessageModel msg) {
    markSingleMessageRead(msg);

    // Show Message Full View Dialog
    _showMessageDetailDialog(context, msg);
  }

  /// Show Full Message Dialog with conditional attachment preview
  void _showMessageDetailDialog(BuildContext context, ClientMessageModel msg) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
          alignment: Alignment.bottomCenter,
          insetPadding: EdgeInsets.zero,
          child: DeskSheetContent(
              title: msg.subject,
              subtitle: '${msg.sender} · ${msg.date}',
              children: [
                const DeskSection('Message'),
                const SizedBox(height: 8),
                Text(msg.message, style: deskText),
                const SizedBox(height: 24),
                if (msg.hasAttachment) ...[
                  DeskAttachmentAction(onPressed: () {
                    MessageAttachmentViewerModal.show(
                      dialogCtx,
                      imageUrl: msg.resolvedAttachmentUrl!,
                      title: msg.subject,
                      subtitle: msg.date,
                    );
                  }),
                  const SizedBox(height: 20)
                ],
                DeskButton(
                    label: 'Close',
                    secondary: true,
                    onPressed: () => Navigator.of(dialogCtx).pop())
              ])),
    );
  }

  /// Mark all as read based on active tab
  Future<void> markAllAsRead() async {
    try {
      if (selectedTab.value == 0) {
        // Notifications
        await _notificationRequest.markAllRead();
        for (int i = 0; i < notifications.length; i++) {
          final notif = notifications[i];
          if (notif.isUnread) {
            notifications[i] = NotificationModel(
              id: notif.id,
              title: notif.title,
              message: notif.message,
              time: notif.time,
              tag: notif.tag,
              target: notif.target,
              link: notif.link,
              icon: notif.icon,
              tagColor: notif.tagColor,
              iconBgColor: notif.iconBgColor,
              isUnread: false,
            );
          }
        }
        unreadNotificationsCount.value = 0;
        _syncDashboardUnread();
      } else {
        // Messages
        for (int i = 0; i < messages.length; i++) {
          final msg = messages[i];
          if (msg.isUnread) {
            _notificationRequest.markMessageRead(msg.id);
            messages[i] = msg.copyWith(isUnread: false);
          }
        }
        DBHelper().markAllMessagesAsRead();
        unreadMessagesCount.value = 0;
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().messages.assignAll(messages);
        }
      }
    } catch (_) {}
  }
}
