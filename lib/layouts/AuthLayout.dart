import '../imports.dart';

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
      appBar: title != null
          ? AppBar(
        title: Text(title!),
        centerTitle: centerTitle ?? true,
        backgroundColor: Colors.blue,
      )
          : null,
      drawer: drawer,
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
