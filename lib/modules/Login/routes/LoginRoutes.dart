import 'package:get/get.dart';
import 'package:techspiderhunter/modules/Login/views/LoginIndex.dart';

import '../views/OtpPage.dart';
import '../controllers/LoginController.dart';
import '../controllers/OtpController.dart';

class LoginRoutes {

  // Routes
  static const loginIndex = '/login/index';
  static const otpPage = '/otp/index';




  // Routes
  static final routes = [
    GetPage(
      name: loginIndex,
      page: () => const LoginIndex(),
      binding: BindingsBuilder(() => Get.lazyPut<LoginController>(() => LoginController())),
    ),
    GetPage(
      name: otpPage,
      page: () => const OtpPage(),
      binding: BindingsBuilder(() =>
          Get.lazyPut<OtpController>(() => OtpController())),
    ),
  ];

}
