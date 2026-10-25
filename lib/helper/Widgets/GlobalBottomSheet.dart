import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlobalBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showHandle;

  const GlobalBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ///  Top Handle
              if (showHandle)
                Container(
                  width: 40,
                  height: 5,
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

              ///  Title
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontFamily: 'DeskSans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              /// 🔹 Content
              child,
            ],
          ),
        ),
      ),
    );
  }

  ///  Static helper (easy use anywhere)
  static void open({
    required Widget child,
    String? title,
  }) {
    Get.bottomSheet(
      GlobalBottomSheet(
        title: title,
        child: child,
      ),
      isScrollControlled: true, //  MUST
      backgroundColor: Colors.transparent,
    );
  }
}
