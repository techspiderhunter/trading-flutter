import 'package:get/get.dart';
import '../views/LoginView.dart';
import '../views/RegisterView.dart';
import '../views/OtpView.dart';
import '../views/ForgotPasswordView.dart';
import '../controllers/AuthController.dart';

class AuthRoutes {
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const otp = '/auth/otp';
  static const forgotPassword = '/auth/forgot-password';

  static final routes = [
    GetPage(
      name: register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: otp,
      page: () => const OtpView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
  ];
}
