import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  static const Color primaryColor = Color(0xFF0D63F3);
  static const Color deepNavy = Color(0xFF101828);

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex();

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 66,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE5ECF6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildNavItem(
                        index: 0,
                        currentIndex: currentIndex,
                        icon: Icons.home_rounded,
                        label: 'Home',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: 1,
                        currentIndex: currentIndex,
                        icon: Icons.directions_car_filled_outlined,
                        label: 'Vehicle',
                      ),
                    ),
                    const SizedBox(width: 76),
                    Expanded(
                      child: _buildNavItem(
                        index: 3,
                        currentIndex: currentIndex,
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Wallet',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: 4,
                        currentIndex: currentIndex,
                        icon: Icons.person_outline_rounded,
                        label: 'Profile',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: _buildScanItem(currentIndex: currentIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    final Color color = isSelected ? primaryColor : const Color(0xFF98A2B3);

    return InkWell(
      onTap: () => _navigate(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: 54,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanItem({required int currentIndex}) {
    final isSelected = currentIndex == 2;

    return InkWell(
      onTap: () => _navigate(2),
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: isSelected ? deepNavy : primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.34),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),

        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // NAVIGATION
  // ----------------------------------------------------------

  void _navigate(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed(''
        );
        break;

      case 1:
        Get.toNamed(''
        );
        break;

      // case 2:
      //   Get.toNamed(''
      //   );
      //   break;
      //
      // case 3:
      //   Get.toNamed(''
      //   );
      //   break;
      //
      // case 4:
      //   Get.toNamed(''
      //   );
    }
  }

  // ----------------------------------------------------------
  // CURRENT PAGE
  // ----------------------------------------------------------

  int _getCurrentIndex() {
    final String route = Get.currentRoute;

    if (route == '') {
      return 0;
    }

    if (route =='') {
      return 1;
    }
    // if (route == '') {
    //   return 2;
    // }
    //
    // if (route == '') {
    //   return 3;
    // }
    //
    // if (route == '') {
    //   return 4;
    // }


    return -1;
  }
}
