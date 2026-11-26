import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'global/routes/MainRoutes.dart';
import 'modules/Splash/routes/SplashRoutes.dart';
import 'themes/LightTheme.dart';
import 'includes/Storage.dart';
import 'services/FirebaseService.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await LocalStorage.init();

    // Initialize Firebase Core, Push Notifications, Crashlytics & Analytics
    try {
      await FirebaseService.init().timeout(const Duration(seconds: 2));
    } catch (e) {
      log("⚠️ FirebaseService init timeout/bypass: $e");
    }

    runApp(const NMResearchPartnerApp());
  }, (error, stackTrace) {
    log("🔥 Static App Error: $error", error: error, stackTrace: stackTrace);
  });
}

class NMResearchPartnerApp extends StatelessWidget {
  const NMResearchPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NM Research Partner',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      initialRoute: SplashRoutes.splashIndex,
      getPages: MainRoutes.routes,
    );
  }
}

typedef MoneyaraApp = NMResearchPartnerApp;
typedef MoneyViaApp = NMResearchPartnerApp;
