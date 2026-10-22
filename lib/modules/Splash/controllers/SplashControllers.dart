import 'dart:async';
import 'package:get/get.dart';
import '../../MainNav/routes/MainNavRoutes.dart';
import '../../Auth/routes/AuthRoutes.dart';
import '../../../includes/Storage.dart';
import '../../Profile/requests/ProfileRequest.dart';
import '../../../services/FirebaseService.dart';

class SplashController extends GetxController {
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    _timer = Timer(const Duration(milliseconds: 1800), () async {
      if (!isClosed) {
        // Check if user is already authenticated
        if (LocalStorage.hasToken()) {
          // Pre-fetch profile in background
          ProfileRequest().getProfile().ignore();
          FirebaseService.syncDeviceTokenWithBackend().ignore();
          Get.offAllNamed(MainNavRoutes.main);
        } else {
          // Unauthenticated -> Registration or Login screen
          Get.offAllNamed(AuthRoutes.login);
        }
      }
    });
  }

  void skipToDashboard() {
    _timer?.cancel();
    Get.offAllNamed(MainNavRoutes.main);
  }

  void skipToRegister() {
    _timer?.cancel();
    Get.offAllNamed(AuthRoutes.register);
  }

  void skipToLogin() {
    _timer?.cancel();
    Get.offAllNamed(AuthRoutes.login);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
