import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' show Random;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../firebase_options.dart';
import '../includes/Storage.dart';
import '../modules/Dashboard/routes/DashboardRoutes.dart';
import '../modules/MainNav/routes/MainNavRoutes.dart';
import '../modules/MainNav/controllers/MainNavController.dart';
import '../modules/Notification/controllers/NotificationController.dart';
import '../modules/Dashboard/controllers/DashboardController.dart';
import '../global/requests/GlobalRequest.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log("📩 FCM Background Message: ${message.messageId} | ${message.notification?.title}");

    // If message arrived in background as a data payload without automatic notification
    if (message.notification == null && message.data.isNotEmpty) {
      final localNotifications = FlutterLocalNotificationsPlugin();
      const androidSettings =
          AndroidInitializationSettings('ic_stat_moneyara');
      const initSettings = InitializationSettings(android: androidSettings);
      await localNotifications.initialize(initSettings);

      const channel = AndroidNotificationChannel(
        'moneyara_urgent_heads_up_v3',
        'Moneyara Notifications',
        description:
            'Real-time compliance alerts, KYC/MITC updates, and trade advisories.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      await localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      final title =
          message.data['title'] ?? message.data['subject'] ?? 'Moneyara Alert';
      final body = message.data['body'] ??
          message.data['message'] ??
          message.data['text'] ??
          '';

      if (title.isNotEmpty || body.isNotEmpty) {
        final androidDetails = AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.max,
          ticker: 'Moneyara Alert',
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          icon: 'ic_stat_moneyara',
          color: const Color(0xFF1E67FA),
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(body, contentTitle: title),
        );

        await localNotifications.show(
          message.hashCode,
          title,
          body,
          NotificationDetails(android: androidDetails),
          payload: jsonEncode(message.data),
        );
      }
    }
  } catch (e) {
    log("🔥 FCM Background Handler Error: $e");
  }
}

/// Core Firebase Integration Service
/// Encapsulates Firebase Core, FCM Push Notifications, Local Notifications,
/// Crashlytics error monitoring, and Analytics tracking.
class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'moneyara_urgent_heads_up_v3',
    'Moneyara Notifications',
    description:
        'Real-time compliance alerts, KYC/MITC updates, and trade advisories.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  static FirebaseAnalytics? _analytics;
  static FirebaseAnalytics? get analytics => _analytics;

  /// Main initialization called in main()
  static Future<void> init() async {
    try {
      // 1. Initialize Firebase Core with DefaultFirebaseOptions
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      log("✅ Firebase Core initialized successfully for project: ${DefaultFirebaseOptions.currentPlatform.projectId}");

      // 2. Setup Firebase Crashlytics
      _setupCrashlytics();

      // 3. Setup Firebase Analytics
      _setupAnalytics();

      // 4. Setup FCM & Local Notifications asynchronously so runApp() is NEVER blocked
      _setupFcmAndLocalNotifications().ignore();
    } catch (e, stack) {
      log("🔥 FirebaseService.init Error: $e", error: e, stackTrace: stack);
    }
  }

  static void _setupCrashlytics() {
    try {
      // Pass all uncaught "fatal" errors from the framework to Crashlytics
      FlutterError.onError = (FlutterErrorDetails details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      log("✅ Firebase Crashlytics configured.");
    } catch (e) {
      log("⚠️ Crashlytics setup warning: $e");
    }
  }

  static void _setupAnalytics() {
    try {
      _analytics = FirebaseAnalytics.instance;
      _analytics?.setAnalyticsCollectionEnabled(true);
      log("✅ Firebase Analytics configured.");
    } catch (e) {
      log("⚠️ Analytics setup warning: $e");
    }
  }

  static Future<void> _setupFcmAndLocalNotifications() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize Local Notifications plugin
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('ic_stat_moneyara');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data =
                  jsonDecode(response.payload!) as Map<String, dynamic>;
              _handlePayloadRedirection(data);
            } catch (_) {}
          }
        },
      );

      // Create Android Notification Channel
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_channel);

      // Request notification permissions & token after UI window is active and attached
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final NotificationSettings settings =
              await _messaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );
          log("🔔 FCM Permission status: ${settings.authorizationStatus}");

          final androidPlugin =
              _localNotifications.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
          await androidPlugin?.requestNotificationsPermission();

          await _fetchAndSaveFcmToken();
        } catch (e) {
          log("⚠️ Post-frame notification setup warning: $e");
        }
      });

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        log("🔄 FCM Token Refreshed: $newToken");
        await LocalStorage.write('fcm_token', newToken);
        await syncDeviceTokenWithBackend();
      });

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log("📬 Foreground FCM Message: ${message.messageId} | ${message.notification?.title}");
        _showLocalNotification(message);
        _showInAppTopBanner(message);

        // Auto-refresh dynamic app notifications & dashboard
        final type = (message.data['type'] ?? message.data['target'] ?? '')
            .toString()
            .toLowerCase()
            .trim();

        if (type == 'message') {
          // Message notification: only refresh messages on dashboard, leave notification bell badge untouched
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().syncDashboard();
          }
          if (Get.isRegistered<NotificationController>()) {
            Get.find<NotificationController>().loadMessages();
          }
        } else {
          // General / Regulatory notification: refresh both
          if (Get.isRegistered<NotificationController>()) {
            Get.find<NotificationController>().loadAll();
          }
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().syncDashboard();
          }
        }
      });

      // When notification is clicked in background and opens app
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("📲 FCM Message Opened From Background: ${message.data}");
        _refreshRealtimeData();
        _handlePayloadRedirection(message.data);
      });

      // Check if app was opened from terminated state via notification
      final RemoteMessage? initialMessage =
          await _messaging.getInitialMessage();
      if (initialMessage != null) {
        log("🚀 App Launched via FCM Notification: ${initialMessage.data}");
        Future.delayed(const Duration(milliseconds: 800), () {
          _refreshRealtimeData();
          _handlePayloadRedirection(initialMessage.data);
        });
      }
    } catch (e) {
      log("⚠️ FCM setup warning: $e");
    }
  }

  static Future<void> _fetchAndSaveFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        log("🔑 FCM Device Token: $token");
        await LocalStorage.write('fcm_token', token);
        await syncDeviceTokenWithBackend();
      }
    } catch (e) {
      log("⚠️ Failed to get FCM token: $e");
    }
  }

  /// Sync FCM token with Laravel backend (/api/client/device-token)
  static Future<void> syncDeviceTokenWithBackend() async {
    try {
      final token = await getFcmToken();
      if (token == null || token.isEmpty) return;

      final res = await GlobalRequest()
          .put('/api/client/device-notification-token', data: {
        'token': token,
        'platform': currentPlatform,
        'device_id': getDeviceId(),
      });
      if (res.success) {
        log("🚀 FCM Device Token registered with Laravel backend successfully!");
      }
    } catch (e) {
      log("⚠️ Failed to sync FCM token to backend: $e");
    }
  }

  static String get currentPlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  /// A privacy-safe app installation identifier, stable until app data is cleared.
  static String getDeviceId() {
    final existing = LocalStorage.read(LocalStorage.notificationDeviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final id =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    LocalStorage.write(LocalStorage.notificationDeviceIdKey, id);
    return id;
  }

  static Map<String, dynamic> get logoutDevicePayload => {
        'platform': currentPlatform,
        'device_id': getDeviceId(),
      };

  /// Show heads-up local notification banner when message arrives in foreground
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title'] ??
        message.data['subject'] ??
        'Moneyara Alert';
    final body = message.notification?.body ??
        message.data['body'] ??
        message.data['message'] ??
        message.data['text'] ??
        '';

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'Moneyara Alert',
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      icon: 'ic_stat_moneyara',
      color: const Color(0xFF1E67FA),
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Moneyara',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  /// Show elegant in-app top notification banner if app is currently open in foreground
  static void _showInAppTopBanner(RemoteMessage message) {
    try {
      final title = message.notification?.title ??
          message.data['title'] ??
          'Moneyara Alert';
      final body = message.notification?.body ??
          message.data['body'] ??
          message.data['message'] ??
          '';

      if (title.isEmpty && body.isEmpty) return;

      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 14,
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
        icon: const Padding(
          padding: EdgeInsets.only(left: 6),
          child: Icon(Icons.notifications_active_rounded,
              color: Color(0xFF1E67FA), size: 28),
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        duration: const Duration(seconds: 4),
        animationDuration: const Duration(milliseconds: 350),
        onTap: (_) => _handlePayloadRedirection(message.data),
      );
    } catch (e) {
      log("⚠️ In-app top banner error: $e");
    }
  }

  /// Redirect directly to Dashboard upon notification click
  static void _handlePayloadRedirection(Map<String, dynamic> data) {
    try {
      // 1. Close any open dialog or bottom sheet
      if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
        Get.back();
      }

      // 2. Redirect to MainNav
      if (Get.currentRoute != MainNavRoutes.main) {
        Get.offAllNamed(DashboardRoutes.dashboard);
      }

      // 3. Ensure Dashboard tab (Tab 0) is active
      if (Get.isRegistered<MainNavController>()) {
        Get.find<MainNavController>().changeTab(0);
      }

      // 4. Refresh Dashboard data and messages
      _refreshRealtimeData();
    } catch (e) {
      log("⚠️ Notification redirection error: $e");
    }
  }

  static void _refreshRealtimeData() {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().loadAll();
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().syncDashboard();
    }
  }

  /// Get current FCM token
  static Future<String?> getFcmToken() async {
    final cached = LocalStorage.read('fcm_token');
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    return await _messaging.getToken();
  }
}


