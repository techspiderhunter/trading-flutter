import 'package:get/get.dart';
import '../views/KycView.dart';
import '../controllers/KycController.dart';

class KycRoutes {
  static const kyc = '/kyc';
  static const kycIndex = '/kyc/index';

  static final routes = [
    GetPage(
      name: kyc,
      page: () => const KycView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<KycController>(() => KycController());
      }),
    ),
    GetPage(
      name: kycIndex,
      page: () => const KycView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<KycController>(() => KycController());
      }),
    ),
  ];
}
