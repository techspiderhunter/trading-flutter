import 'package:ui_helpers/ui/colors.dart';

import '../imports.dart';

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
    this.backgroundColor = primaryColor,
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
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        title: title,
        centerTitle: centerTitle ?? true,
        actions: actions,
        titleSpacing: 0,
        automaticallyImplyLeading:automaticallyImplyLeading,
      ),
      drawer: drawer,
      drawerScrimColor: Colors.white,
      body:  Stack(
        children: [
          // Solid Color Background
          Positioned.fill(
            child: Container(color:primaryColor),
          ),
          // Content
          child,
        ],
      ),


      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
