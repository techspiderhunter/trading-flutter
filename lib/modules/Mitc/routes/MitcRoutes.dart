import 'package:get/get.dart';
import '../views/MitcView.dart';
import '../controllers/MitcController.dart';

class MitcRoutes {
  static const mitc = '/mitc';
  static const mitcIndex = '/mitc/index';

  static final routes = [
    GetPage(
      name: mitc,
      page: () => const MitcView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MitcController>(() => MitcController());
      }),
    ),
    GetPage(
      name: mitcIndex,
      page: () => const MitcView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MitcController>(() => MitcController());
      }),
    ),
  ];
}
