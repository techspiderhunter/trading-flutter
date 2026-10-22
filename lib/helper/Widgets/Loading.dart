import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({
    super.key,
    this.size = 72,
    this.message,
    this.centered = true,
  });

  static const assetPath = 'assets/system/loading.gif';

  final double size;
  final String? message;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final trimmedMessage = message?.trim() ?? '';
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    final content = trimmedMessage.isEmpty
        ? image
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              image,
              const SizedBox(height: 10),
              Text(
                trimmedMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    return centered ? Center(child: content) : content;
  }
}

class ButtonLoading extends StatelessWidget {
  const ButtonLoading({
    super.key,
    this.size = 22,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.4,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
