// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:flutter/material.dart';
//
// class AdsBannerWidget extends StatefulWidget {
//   @override
//   _AdsBannerState createState() => _AdsBannerState();
// }
//
// class _AdsBannerState extends State<AdsBannerWidget> {
//   BannerAd? _bannerAd;
//   bool _isBannerAdLoaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadBannerAd();
//     });
//   }
//
//   void _loadBannerAd() {
//     _bannerAd = BannerAd(
//       adUnitId: 'ca-app-pub-8053461558779251/5762009863', // Replace with your Ad Unit ID
//       size: AdSize.banner,
//       request: AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (Ad ad) {
//           setState(() {
//             _isBannerAdLoaded = true;
//           });
//           print('✅ Banner Ad Loaded');
//         },
//         onAdFailedToLoad: (Ad ad, LoadAdError error) {
//           print('❌ Banner Ad Failed to Load: ${error.code} - ${error.message}');
//           setState(() {
//             _isBannerAdLoaded = false;
//           });
//         },
//       ),
//     )..load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _isBannerAdLoaded && _bannerAd != null
//         ? Container(
//       width: _bannerAd!.size.width.toDouble(),
//       height: _bannerAd!.size.height.toDouble(),
//       child: AdWidget(ad: _bannerAd!),
//     )
//         : SizedBox.shrink();
//   }
//
//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }
// }
