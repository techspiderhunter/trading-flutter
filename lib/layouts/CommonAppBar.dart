import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.bottom,
    this.centerTitle = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      toolbarHeight: 72,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: 10, top: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textHeading,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              ),
            )
          : null,
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'DeskSans',
            color: AppColors.textHeading,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      centerTitle: centerTitle,
      bottom: bottom,
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(72 + (bottom?.preferredSize.height ?? 0));
}
