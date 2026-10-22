import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_helpers/ui/colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  /// ADD THIS
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
      backgroundColor: Colors.transparent,
      toolbarHeight: 90,

      /// Gradient Background
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              const Color(0xff7B4DFF),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      ),

      /// Back Button
      leading: showBack
          ? Padding(
        padding: const EdgeInsets.only(left: 10, top: 10),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () => Get.back(),
        ),
      )
          : null,

      /// Title
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: .5,
          ),
        ),
      ),

      centerTitle: centerTitle,
      bottom: bottom,

      /// ACTIONS ADDED HERE
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(95 + (bottom?.preferredSize.height ?? 0));
}