import 'package:flutter/material.dart';
import '../themes/colors.dart';

class AppLayout extends StatelessWidget {
  final Widget? title;
  final Widget child;
  final bool? centerTitle;
  final Drawer? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const AppLayout({
    required this.child,
    this.title,
    this.centerTitle,
    this.drawer,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.floatingActionButton,
    super.key,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: title,
        centerTitle: centerTitle ?? true,
        actions: actions,
        titleSpacing: 0,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: drawer,
      drawerScrimColor: Colors.black45,
      body: child,
      backgroundColor: backgroundColor ?? AppColors.scaffoldBackground,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
