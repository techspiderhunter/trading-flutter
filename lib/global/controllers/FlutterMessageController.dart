import 'dart:convert';
import 'dart:developer';
import 'dart:math' show Random;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../includes/Storage.dart';
import '../helpers/Request.dart';
import '../../modules/Dashboard/routes/DashboardRoutes.dart';
import '../../modules/MainNav/routes/MainNavRoutes.dart';
import '../../modules/MainNav/controllers/MainNavController.dart';

class FCMController extends GetxController {
  static final FCMController instance = Get.put(FCMController());
  static const deviceTokenStorageKey = 'device_token';
  static const deviceIdStorageKey = 'device_id';

  var _token = ''.obs;
  var fcmNotificationData = Rx<RemoteMessage?>(null);
  String get deviceToken => _token.value;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void onInit() {
    super.onInit();
    _requestNotificationPermission(); // Request permission for Android 13+
    _initializeNotifications(); // Initialize notification settings
    FirebaseMessaging.onMessage.listen(_showNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageClick);
    FirebaseMessaging.instance.onTokenRefresh.listen(_handleTokenRefresh);
    _handleInitialMessage();
    getToken();
  }

  /// 🔹 Request Notification Permission for Android 13+
  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  /// 🔹 Initialize Local Notifications and Create Notification Channel
  void _initializeNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'CRM', // Unique Channel ID
      'CRM Notifications', // Channel Name
      description: 'CRM-Message', // Channel Description
      importance: Importance.high,
      playSound: true,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_moneyara');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationClick(details.payload);
      },
    );

    // Register channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 🔹 Show Notification in Foreground
  void _showNotification(RemoteMessage message) async {
    fcmNotificationData.value = message;
    log('FCM foreground message data: ${message.data}');

    final notification = message.notification;
    final title = notification?.title ??
        _stringValue(message.data, ['title', 'notification_title']) ??
        _titleForType(message.data['type']);
    final body = notification?.body ??
        _stringValue(message.data, ['body', 'message', 'description']) ??
        'Tap to view details.';

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'CRM',
      'CRM Notifications',
      channelDescription: 'CRM-Message',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_moneyara',
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.show(
        message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
        title,
        body,
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      log('Error showing notification: $e');
    }
  }

  /// 🔹 Handle Click on Notification
  void _handleNotificationClick(String? payload) {
    if (payload == null) return;

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) _handleNotificationData(decoded);
    } catch (e) {
      log('Error parsing notification payload: $e');
    }
  }

  Future<void> _handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) _handleRemoteMessageClick(message);
  }

  void _handleRemoteMessageClick(RemoteMessage message) {
    log('FCM notification opened data: ${message.data}');
    _handleNotificationData(message.data);
  }

  void _handleNotificationData(Map data) {
    try {
      if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
        Get.back();
      }
      if (Get.currentRoute != MainNavRoutes.main) {
        Get.offAllNamed(DashboardRoutes.dashboard);
      }
      if (Get.isRegistered<MainNavController>()) {
        Get.find<MainNavController>().changeTab(0);
      }
    } catch (e) {
      log('Error handling notification click: $e');
    }
  }

  void _openNotificationPage(Map<String, String> arguments) {
    if (Get.currentRoute != MainNavRoutes.main) {
      Get.offAllNamed(DashboardRoutes.dashboard);
    }
  }

  String? _stringValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  String _titleForType(dynamic type) {
    final normalized = type?.toString().trim().toLowerCase() ?? '';
    if (normalized == 'parking_request') return 'Parking Request';
    return 'Notification';
  }

  /// 🔹 Fetch FCM Token and Save it
  Future<String?> getToken() async {
    try {
      var token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _token.value = token;
        await LocalStorage.write(deviceTokenStorageKey, token);
        log('FCM token saved locally: ${_mask(token)}');
      } else {
        log('FCM token is null.');
      }
      return token;
    } catch (e) {
      log('Error fetching FCM token: $e');
      return null;
    }
  }

  Future<void> _handleTokenRefresh(String token) async {
    _token.value = token;
    await LocalStorage.write(deviceTokenStorageKey, token);
    log('FCM token refreshed and saved locally: ${_mask(token)}');
    await registerDeviceToken();
  }

  Future<void> registerDeviceToken() async {
    final authToken = LocalStorage.read(LocalStorage.tokenKey);
    if (authToken == null || authToken.isEmpty) {
      log('Device token registration skipped: auth token missing.');
      return;
    }

    final token = _token.value.isNotEmpty
        ? _token.value
        : (LocalStorage.read(deviceTokenStorageKey) ?? await getToken() ?? '');
    if (token.isEmpty) {
      log('Device token registration skipped: FCM token missing.');
      return;
    }

    final deviceId = await _deviceId();
    log('Registering device token: token=${_mask(token)}, platform=$_platform, device_id=$deviceId');

    final response = await Request.post(
      '/user/device-token',
      {
        'token': token,
        'platform': _platform,
        'device_id': deviceId,
      },
      auth: true,
    );

    if (!response.isSuccess) {
      log('Device token registration failed: ${response.message}');
    } else {
      log('Device token registered successfully: ${response.message}');
    }
  }

  Future<String> _deviceId() async {
    final existing = LocalStorage.read(deviceIdStorageKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated =
        '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
    await LocalStorage.write(deviceIdStorageKey, generated);
    log('Generated device_id: $generated');
    return generated;
  }

  String _mask(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  String get _platform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}
