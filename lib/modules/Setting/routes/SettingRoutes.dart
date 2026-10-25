import 'package:get/get.dart';
import '../views/SettingView.dart';
import '../../Profile/controllers/ProfileController.dart';
import '../../Mitc/controllers/MitcController.dart';
import '../../Kyc/controllers/KycController.dart';
import '../../MainNav/controllers/MainNavController.dart';

class SettingRoutes {
  static const setting = '/setting';
  static const settingIndex = '/setting/index';

  static final routes = [
    GetPage(
      name: setting,
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
    GetPage(
      name: settingIndex,
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
