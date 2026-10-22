// import 'package:techspiderhunter/imports.dart';
// import 'package:techspiderhunter/modules/Auth/imports.dart';
// import 'package:techspiderhunter/modules/imports.dart';
//
// import '../modules/Onboarding/controllers/OnboardingControllers.dart';
//
// class CustomDrawer extends StatelessWidget {
//   const CustomDrawer({super.key, required this.OnboardingController});
//
//   final OnboardingController OnboardingController;
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: Column(
//         children: [
//           const SizedBox(height: 50),
//           Obx(() {
//             if (OnboardingController.companyLogo.isNotEmpty) {
//               // If companyLogo is not empty, display the network image
//               return Center(
//                 child: Image.network(
//                   "${OnboardingController.companyLogo}",
//                   width: 200,
//                 ),
//               );
//             } else {
//               // If companyLogo is empty, display the fallback local image
//               return Center(
//                 child: Image.asset(
//                   "assets/icons/MAIN-LOGO-SYS-PVT-LTD-W-logo.png",
//                   width: 200,
//                 ),
//               );
//             }
//           }),
//           const SizedBox(height: 20),
//           // GestureDetector(
//           //   onTap: () {
//           //     Get.toNamed(SettingRoutes.updateProfile);
//           //   },
//           //   child: Image.asset(
//           //     'assets/icons/profile-user.png',
//           //     height: 40,
//           //     // color: Colors.grey,
//           //   ),
//           // ),
//           // const SizedBox(height: 3),
//           // GestureDetector(
//           //     onTap: () {
//           //       Get.toNamed(SettingRoutes.updateProfile);
//           //     },
//           //     child: Text("Update Profile", style: TextStyle(fontWeight: FontWeight.w600,),)),
//           const Divider(),
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             child: GestureDetector(
//               onTap: () {
//                 Get.toNamed(SettingRoutes.updateProfile);
//               },
//               child:Row(
//                 children: [
//                   Image.asset(
//                     'assets/icons/profile-user.png',
//                     height:22,
//                     // color: Colors.grey,
//                   ),
//                   SizedBox(width: 13),
//                   Text("Update Profile"),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             child: GestureDetector(
//               onTap: () {
//                 // Get.toNamed(ProfitAndLossReportsRoutes.profitAndLossReportsIndex);
//               },
//               child:Row(
//                 children: [
//                   Image.asset(
//                     'assets/icons/profit-and-loss.png',
//                     height:22,
//                     // color: Colors.grey,
//                   ),
//                   SizedBox(width: 13),
//                   Text("Profit and Loss Reports"),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             child: GestureDetector(
//               onTap: () {
//                 OnboardingController.logout(); // Fix for navigation
//               },
//               child: const Row(
//                 children: [
//                   Icon(Icons.logout),
//                   SizedBox(width: 10),
//                   Text("Logout"),
//                 ],
//               ),
//             ),
//           ),
//           Spacer(),
//           Center(
//             child: Text(
//               "Developed by Systology Software Pvt.Ltd\n© 2025. All rights reserved.",
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 8,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
// }
