import 'package:get/get.dart';
import '../../Dashboard/views/DashboardView.dart';
import '../../Dashboard/controllers/DashboardController.dart';
import '../../Setting/views/SettingView.dart';
import '../../Profile/controllers/ProfileController.dart';
import '../../Mitc/controllers/MitcController.dart';
import '../../Kyc/controllers/KycController.dart';
import '../controllers/MainNavController.dart';

class MainNavRoutes {
  static const main = '/main';
  static const mainIndex = '/main/index';
  static const dashboard = '/main/dashboard';
  static const profile = '/main/profile';

  static final routes = [
    GetPage(
      name: main,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<DashboardController>()) {
          Get.lazyPut<DashboardController>(() => DashboardController());
        }
        if (!Get.isRegistered<MainNavController>()) {
          Get.put<MainNavController>(MainNavController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: mainIndex,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<DashboardController>()) {
          Get.lazyPut<DashboardController>(() => DashboardController());
        }
        if (!Get.isRegistered<MainNavController>()) {
          Get.put<MainNavController>(MainNavController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<DashboardController>()) {
          Get.lazyPut<DashboardController>(() => DashboardController());
        }
        if (!Get.isRegistered<MainNavController>()) {
          Get.put<MainNavController>(MainNavController(), permanent: true);
        }
      }),
    ),
    GetPage(
      name: profile,
      page: () => const SettingView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MainNavController>()) {
          Get.put<MainNavController>(MainNavController(), permanent: true);
        }
        if (!Get.isRegistered<ProfileController>()) {
          Get.lazyPut<ProfileController>(() => ProfileController());
        }
        if (!Get.isRegistered<MitcController>()) {
          Get.lazyPut<MitcController>(() => MitcController());
        }
        if (!Get.isRegistered<KycController>()) {
          Get.lazyPut<KycController>(() => KycController());
        }
      }),
    ),
  ];
}
