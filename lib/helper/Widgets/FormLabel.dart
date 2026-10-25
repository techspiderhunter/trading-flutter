import 'package:flutter/material.dart';

class FormLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  final TextStyle? style;
  final IconData? icon;
  final int? maxLines;
  final TextOverflow? overflow;

  const FormLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.style,
    this.icon,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: RichText(
          softWrap: true,
          text: TextSpan(
            text: label,
            style: style ??
                TextStyle(
                  fontFamily: 'DeskSans',
                  fontSize: 16,
                  color: Colors.black,
                ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontFamily: 'DeskSans',
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
      SizedBox(
        width: 8,
      ),
      if (icon != null) ...[
        Icon(
          icon,
          size: 16,
          color: Colors.black87,
        ),
        const SizedBox(width: 4),
      ],
    ]);
  }
}
