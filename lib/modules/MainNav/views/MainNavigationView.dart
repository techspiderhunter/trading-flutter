import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/colors.dart';
import '../controllers/MainNavController.dart';
import '../../Dashboard/views/DashboardView.dart';
import '../../Setting/views/SettingView.dart';

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MainNavController>()
        ? Get.find<MainNavController>()
        : Get.put(MainNavController());

    // Preserve internal selection state; Setting is opened from the dashboard gear.
    final List<Widget> screens = const [
      DashboardView(),
      SettingView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: screens,
          )),
    );
  }
}
