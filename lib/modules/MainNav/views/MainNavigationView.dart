import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/AppColors.dart';
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

    // Two main tabs: Dashboard and Setting
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
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  // Tab 1: Dashboard
                  Expanded(
                    child: _buildNavItem(
                      index: 0,
                      controller: controller,
                      label: 'Dashboard',
                      icon: Icons.grid_view_rounded,
                      activeIcon: Icons.grid_view_rounded,
                    ),
                  ),

                  // Tab 2: Setting
                  Expanded(
                    child: _buildNavItem(
                      index: 1,
                      controller: controller,
                      label: 'Setting',
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required MainNavController controller,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final bool isSelected = controller.currentIndex.value == index;

    return InkWell(
      onTap: () => controller.changeTab(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE8F7F0)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 21,
                color: isSelected ? const Color(0xFF00B074) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF00B074) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
