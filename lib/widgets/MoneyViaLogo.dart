import 'package:flutter/material.dart';

/// Signature Trading Brand Logo Pill Badge
class TradingPillBadge extends StatelessWidget {
  final double height;
  final String title;

  const TradingPillBadge({
    super.key,
    this.height = 48,
    this.title = 'Trading',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6554D9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6554D9).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.trending_up_rounded,
            color: Colors.white,
            size: 26,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DeskSans',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward compatibility alias
typedef FinwiseLogoBadge = TradingPillBadge;

/// Compact Trading Emblem for AppBars & Headers
class TradingLogoBadge extends StatelessWidget {
  final double size;

  const TradingLogoBadge({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF6554D9),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6554D9).withValues(alpha: 0.32),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.trending_up_rounded,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }
}

/// Backward compatibility alias for MoneyaraLogoBadge
typedef MoneyaraLogoBadge = TradingLogoBadge;
typedef MoneyViaLogoBadge = TradingLogoBadge;

/// Full Trading Brand Logo with Icon + Bold Logotype
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
    this.subtitle = 'RESEARCH DESK',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TradingLogoBadge(size: iconSize),
            const SizedBox(width: 12),
            Text(
              'Trading',
              style: TextStyle(
                fontFamily: 'DeskSans',
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF192542),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'DeskSans',
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6554D9),
              letterSpacing: 2.2,
            ),
          ),
        ],
      ],
    );
  }
}

/// Brand Logo Widget for Splash & Auth Screens (Renders Trading)
class MoneyaraLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double textSize;

  const MoneyaraLogo({
    super.key,
    this.size = 90,
    this.showText = false,
    this.textSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return const TradingBrandLogo(
      iconSize: 56,
      fontSize: 32,
      showSubtitle: true,
      subtitle: 'RESEARCH DESK',
    );
  }
}

/// Backward compatibility alias for MoneyaraLogo
typedef MoneyViaLogo = MoneyaraLogo;
