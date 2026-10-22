// import 'dart:async';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// class AdManager {
//   static final AdManager _instance = AdManager._internal();
//   factory AdManager() => _instance;
//   AdManager._internal();
//
//   InterstitialAd? _interstitialAd;
//   bool _isAdLoading = false;
//   Timer? _adTimer; // Timer for global ad control
//
//   void initialize() {
//     _loadInterstitialAd();
//     _startGlobalAdTimer(); // Start a periodic timer
//   }
//
//   void _loadInterstitialAd() {
//     if (_isAdLoading) return;
//     _isAdLoading = true;
//
//     InterstitialAd.load(
//       adUnitId: 'ca-app-pub-8053461558779251/4169726594', // Replace with real Ad Unit
//       request: AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (InterstitialAd ad) {
//           _interstitialAd = ad;
//           _isAdLoading = false;
//           print("✅ Interstitial Ad Loaded");
//
//           // Set event listener to dispose after use
//           _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
//             onAdDismissedFullScreenContent: (InterstitialAd ad) {
//               print("👋 Interstitial Ad Dismissed");
//               ad.dispose();
//               _interstitialAd = null;
//               _loadInterstitialAd(); // Load next ad after dismissal
//             },
//             onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
//               print("❌ Interstitial Ad Failed to Show: ${error.message}");
//               ad.dispose();
//               _interstitialAd = null;
//               _loadInterstitialAd(); // Try loading again
//             },
//           );
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           print('❌ Interstitial Ad failed to load: ${error.message}');
//           _interstitialAd = null;
//           _isAdLoading = false;
//         },
//       ),
//     );
//   }
//
//   void showInterstitialAd() {
//     if (_interstitialAd != null) {
//       _interstitialAd!.show();
//       print("🎯 Interstitial Ad Shown");
//     } else {
//       print("⚠️ Interstitial Ad Not Available - Loading Again");
//       _loadInterstitialAd();
//     }
//   }
//
//   // ✅ Fixed Timer (Prevents infinite recursion)
//   void _startGlobalAdTimer() {
//     _adTimer?.cancel(); // Cancel any existing timer to prevent duplication
//     _adTimer = Timer.periodic(Duration(minutes: 8), (timer) {
//       print("⏳ Timer Triggered - Checking Ad Availability...");
//       showInterstitialAd();
//     });
//   }
//
//   // 🛑 Call this method when app is closing
//   void dispose() {
//     _adTimer?.cancel();
//     _interstitialAd?.dispose();
//   }
// }
