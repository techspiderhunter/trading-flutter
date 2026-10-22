import 'package:get/get.dart';
import '../views/ProfileView.dart';
import '../controllers/ProfileController.dart';

class ProfileRoutes {
  static const profile = '/profile';
  static const profileIndex = '/profile/index';

  static final routes = [
    GetPage(
      name: profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: profileIndex,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
  ];
}
