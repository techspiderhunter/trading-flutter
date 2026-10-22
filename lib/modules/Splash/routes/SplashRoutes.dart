import 'package:get/get.dart';
import '../views/SplashIndex.dart';
import '../controllers/SplashControllers.dart';

class SplashRoutes {
  static const splash = '/splash';
  static const splashIndex = '/splash/index';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashIndex(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
    ),
    GetPage(
      name: splashIndex,
      page: () => const SplashIndex(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
    ),
  ];
}
