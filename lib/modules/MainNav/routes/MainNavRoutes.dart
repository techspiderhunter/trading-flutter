import 'package:get/get.dart';
import '../views/MainNavigationView.dart';
import '../controllers/MainNavController.dart';

class MainNavRoutes {
  static const main = '/main';
  static const mainIndex = '/main/index';
  static const dashboard = '/main/dashboard';
  static const profile = '/main/profile';

  static final routes = [
    GetPage(
      name: main,
      page: () => const MainNavigationView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MainNavController>()) {
          Get.put<MainNavController>(MainNavController(), permanent: true);
        } else {
          Get.find<MainNavController>().currentIndex.value = 0;
        }
      }),
    ),
    GetPage(
      name: mainIndex,
      page: () => const MainNavigationView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MainNavController>()) {
          Get.put<MainNavController>(MainNavController(), permanent: true);
        } else {
          Get.find<MainNavController>().currentIndex.value = 0;
        }
      }),
    ),
    GetPage(
      name: dashboard,
      page: () => const MainNavigationView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MainNavController>()) {
          Get.put<MainNavController>(MainNavController(), permanent: true);
        } else {
          Get.find<MainNavController>().currentIndex.value = 0;
        }
      }),
    ),
    GetPage(
      name: profile,
      page: () => const MainNavigationView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MainNavController>()) {
          final nav = Get.put<MainNavController>(MainNavController(), permanent: true);
          nav.currentIndex.value = 1;
        } else {
          Get.find<MainNavController>().currentIndex.value = 1;
        }
      }),
    ),
  ];
}
