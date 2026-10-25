import '../../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static const String packageName =
      "com.moneyararesearch.app"; // Replace with your app's package name
  static const String playStoreUrl =
      "https://play.google.com/store/apps/details?id=$packageName";
  static const String apiUrl =
      "https://play.google.com/store/apps/details?id=$packageName&hl=en&gl=US";

  /// Fetches the latest version from Google Play Store
  static Future<String?> getLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final match = RegExp(r'\[\[\["([0-9.]+)"').firstMatch(response.body);
        print(match?.group(1));
        return match?.group(1); // Returns latest version as string
      }
    } catch (e) {
      print("Error fetching latest version: $e");
    }
    return null;
  }

  /// Gets the installed version of the app
  static Future<String> getInstalledVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Compares the installed version with Play Store version
  static Future<void> checkForUpdate(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? latestVersion = await getLatestVersion();
      String installedVersion = await getInstalledVersion();
      print(
          "installedVersion::::${installedVersion}::::latestVersion::::${latestVersion}");
      if (latestVersion != null && latestVersion != installedVersion) {
        _showUpdateDialog(context);
      }
    });
  }

  /// Shows the update popup dialog
  static void _showUpdateDialog(BuildContext context) {
    if (!context.mounted)
      return; // Ensures context is valid before showing dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
          alignment: Alignment.bottomCenter,
          insetPadding: EdgeInsets.zero,
          child: DeskSheetContent(
              title: 'Update Available',
              subtitle:
                  'A new version of the app is available. Please update to continue.',
              children: [
                DeskButton(label: 'Update', onPressed: () async {}),
                const SizedBox(height: 20),
                DeskButton(
                    label: 'Later',
                    secondary: true,
                    onPressed: () => Navigator.pop(context))
              ])),
    );
  }
}
