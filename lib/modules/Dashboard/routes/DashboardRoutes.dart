import 'package:get/get.dart';
import '../views/DashboardView.dart';
import '../controllers/DashboardController.dart';
import '../../MainNav/controllers/MainNavController.dart';

class DashboardRoutes {
  static const dashboard = '/dashboard';
  static const dashboardIndex = '/dashboard/index';

  static final routes = [
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
      name: dashboardIndex,
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
  ];
}
