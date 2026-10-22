import 'package:flutter/material.dart';

/// Pixel-perfect Moneyara Research Official Brand Logo Widget
/// Faithfully reproduces the blue & cyan upward growth "M" symbol and official logotype.
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Official 3D Circular Moneyara Research Emblem Badge
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF051532).withOpacity(0.22),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/system/logo.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => CustomPaint(
                painter: _MoneyaraLogoPainter(),
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 10),
          // "Moneyara" Brand Title
          Text(
            'Moneyara',
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0A1C3E),
              letterSpacing: -0.6,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          // "— RESEARCH —" Subtitle with flanking lines
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: textSize * 0.7,
                height: 2.2,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A62FF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'RESEARCH',
                  style: TextStyle(
                    fontSize: textSize * 0.38,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A62FF),
                    letterSpacing: 4.5,
                  ),
                ),
              ),
              Container(
                width: textSize * 0.7,
                height: 2.2,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A62FF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Backward compatibility alias for MoneyaraLogo
typedef MoneyViaLogo = MoneyaraLogo;

/// Compact Moneyara Emblem for AppBars & Headers
class MoneyaraLogoBadge extends StatelessWidget {
  final double size;

  const MoneyaraLogoBadge({super.key, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A62FF).withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/system/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => CustomPaint(
            painter: _MoneyaraLogoPainter(),
          ),
        ),
      ),
    );
  }
}

/// Backward compatibility alias for MoneyaraLogoBadge
typedef MoneyViaLogoBadge = MoneyaraLogoBadge;

class _MoneyaraLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Blue Gradient for Left & Right M Pillars
    final bluePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xFF104AE8), Color(0xFF1E67FA), Color(0xFF3B8BFF)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Left Pillar of M
    final leftBarR = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.20, w * 0.22, h * 0.65),
      Radius.circular(w * 0.11),
    );
    canvas.drawRRect(leftBarR, bluePaint);

    // Right Pillar of M
    final rightBarR = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.68, h * 0.32, w * 0.22, h * 0.53),
      Radius.circular(w * 0.11),
    );
    canvas.drawRRect(rightBarR, bluePaint);

    // 2. Center Growth Bar Chart Bars (Emerald / Teal Green)
    final barPaint1 = Paint()..color = const Color(0xFF00C48C);
    final barPaint2 = Paint()..color = const Color(0xFF00A86B);
    final barPaint3 = Paint()..color = const Color(0xFF008F5A);

    // Bar 1 (Short)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.35, h * 0.60, w * 0.09, h * 0.25),
        Radius.circular(w * 0.045),
      ),
      barPaint1,
    );
    // Bar 2 (Medium)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.46, h * 0.50, w * 0.09, h * 0.35),
        Radius.circular(w * 0.045),
      ),
      barPaint2,
    );
    // Bar 3 (Tall)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.57, h * 0.42, w * 0.09, h * 0.43),
        Radius.circular(w * 0.045),
      ),
      barPaint3,
    );

    // 3. Dynamic Upward Diagonal Ribbon & Arrow (Cyan Gradient)
    final cyanPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xFF0080FF), Color(0xFF00BAFF), Color(0xFF00E5FF)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Upward Ribbon cutting across to create "M" flow
    final ribbonPath = Path();
    ribbonPath.moveTo(w * 0.20, h * 0.25);
    ribbonPath.cubicTo(
      w * 0.25, h * 0.45,
      w * 0.45, h * 0.55,
      w * 0.75, h * 0.25,
    );
    ribbonPath.lineTo(w * 0.82, h * 0.35);
    ribbonPath.cubicTo(
      w * 0.50, h * 0.68,
      w * 0.25, h * 0.58,
      w * 0.12, h * 0.34,
    );
    ribbonPath.close();
    canvas.drawPath(ribbonPath, cyanPaint);

    // Dynamic Straight Arrow Stroke to North-East
    final arrowStroke = Path();
    arrowStroke.moveTo(w * 0.34, h * 0.48);
    arrowStroke.lineTo(w * 0.82, h * 0.18);
    arrowStroke.lineTo(w * 0.88, h * 0.26);
    arrowStroke.lineTo(w * 0.40, h * 0.56);
    arrowStroke.close();
    canvas.drawPath(arrowStroke, cyanPaint);

    // Arrow Head (Pointing North-East ↗)
    final arrowHead = Path();
    arrowHead.moveTo(w * 0.72, h * 0.06);
    arrowHead.lineTo(w * 0.94, h * 0.20);
    arrowHead.lineTo(w * 0.74, h * 0.28);
    arrowHead.lineTo(w * 0.76, h * 0.19);
    arrowHead.close();
    canvas.drawPath(arrowHead, cyanPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
