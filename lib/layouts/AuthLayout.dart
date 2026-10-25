import 'package:flutter/material.dart';
import '../themes/colors.dart';

class AuthLayout extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool? centerTitle;
  final Drawer? drawer;
  final BottomNavigationBar? bottomNavigationBar;

  const AuthLayout({
    required this.child,
    this.title,
    this.centerTitle,
    this.drawer,
    this.bottomNavigationBar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: title != null
          ? AppBar(
              title: Text(
                title!,
                style: const TextStyle(
                  fontFamily: 'DeskSans',
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: centerTitle ?? true,
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      drawer: drawer,
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
