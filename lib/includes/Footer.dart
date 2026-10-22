// import 'package:flutter/material.dart';
// import 'package:ui_helpers/ui/colors.dart';
//
// class Footer extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//
//   const Footer({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       selectedItemColor:primaryColor,
//       backgroundColor: Colors.white,
//       currentIndex: currentIndex, // Update index based on selected tab
//       onTap: onTap,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.Onboarding),
//           label: 'Onboarding',
//         ),
//         // BottomNavigationBarItem(
//         //   icon: Icon(Icons.settings),
//         //   label: 'Setting',
//         // ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.newspaper),
//           label: 'News',
//         ),
//       ],
//     );
//   }
// }
