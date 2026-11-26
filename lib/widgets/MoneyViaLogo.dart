import 'package:flutter/material.dart';

/// Signature NM Brand Logo Pill Badge
class TradingPillBadge extends StatelessWidget {
  final double height;
  final String title;

  const TradingPillBadge({
    super.key,
    this.height = 48,
    this.title = 'NM Research Partner',
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/system/logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}

/// Backward compatibility alias
typedef FinwiseLogoBadge = TradingPillBadge;

/// Compact NM Logo Emblem for AppBars & Headers
class TradingLogoBadge extends StatelessWidget {
  final double size;

  const TradingLogoBadge({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/system/logo_icon.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Backward compatibility alias for MoneyaraLogoBadge
typedef MoneyaraLogoBadge = TradingLogoBadge;
typedef MoneyViaLogoBadge = TradingLogoBadge;

/// Full NM Research Partner Brand Logo
class TradingBrandLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool showSubtitle;
  final String subtitle;

  const TradingBrandLogo({
    super.key,
    this.iconSize = 44,
    this.fontSize = 26,
    this.showSubtitle = true,
    this.subtitle = 'PRIVATE LIMITED',
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/system/logo.png',
      width: iconSize * 4.5,
      fit: BoxFit.contain,
    );
  }
}

/// Brand Logo Widget for Splash & Auth Screens
class NMResearchPartnerLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double textSize;

  const NMResearchPartnerLogo({
    super.key,
    this.size = 90,
    this.showText = false,
    this.textSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/system/logo.png',
      width: size * 2.6,
      fit: BoxFit.contain,
    );
  }
}

/// Backward compatibility aliases
typedef MoneyaraLogo = NMResearchPartnerLogo;
typedef MoneyViaLogo = NMResearchPartnerLogo;
