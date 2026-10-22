import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/NotificationModels.dart';
import '../requests/NotificationRequest.dart';
import '../../../models/ClientMessageModel.dart';
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

  final isLoading = false.obs;

  int get totalUnreadCount => unreadNotificationsCount.value + unreadMessagesCount.value;

  @override
  void onInit() {
    super.onInit();
    _loadCachedMessagesImmediately();
    loadAll();
  }

  /// Instant Offline Load from SQLite
  Future<void> _loadCachedMessagesImmediately() async {
    try {
      final cached = await DBHelper().getMessages(limit: 100);
      if (cached.isNotEmpty) {
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
  /// Uses Offline-First architecture with sqflite local caching
  Future<void> loadMessages() async {
    if (!LocalStorage.hasToken()) {
      messages.clear();
      unreadMessagesCount.value = 0;
      return;
    }

    try {
      // 1. Instant Offline Load from SQLite:
      final cached = await DBHelper().getMessages(limit: 100);
      if (cached.isNotEmpty) {
        messages.assignAll(cached);
        unreadMessagesCount.value = messages.where((m) => m.isUnread).length;
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().messages.assignAll(cached);
        }
      }

      // 2. Fresh Network Sync from Laravel API:
      final res = await _notificationRequest.getTypedMessages();
      if (res.success && res.data != null) {
        messages.assignAll(res.data!);
        final count = messages.where((m) => m.isUnread).length;
        unreadMessagesCount.value = count;

        // 3. Save fresh messages to local SQLite database:
        await DBHelper().saveMessages(res.data!);

        // Also sync with DashboardController messages
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().messages.assignAll(res.data!);
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

      unreadNotificationsCount.value = notifications.where((n) => n.isUnread).length;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Color(0xFF1E67FA),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.subject,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${msg.sender} • ${msg.date}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),

              // Message Body
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    msg.message,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF334155),
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              // Attachment Action Button - ONLY rendered if message has an attachment
              if (msg.hasAttachment) ...[
                const SizedBox(height: 18),
                InkWell(
                  onTap: () {
                    MessageAttachmentViewerModal.show(
                      dialogCtx,
                      imageUrl: msg.resolvedAttachmentUrl!,
                      title: msg.subject,
                      subtitle: msg.date,
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.attachment_rounded, size: 18, color: Color(0xFF1E67FA)),
                        SizedBox(width: 8),
                        Text(
                          'View Attachment',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E67FA),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF1E67FA)),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
