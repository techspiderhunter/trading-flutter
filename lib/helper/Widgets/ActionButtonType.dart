import 'package:flutter/material.dart';

enum ActionButtonType { full, outline }

class ActionButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final ActionButtonType type;
  final Color color;
  final bool activeColumn;

  const ActionButton({
    this.label,
    this.icon,
    required this.onTap,
    this.type = ActionButtonType.full,
    this.color = Colors.blue, // default theme color
    this.activeColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasLabel = label != null && label!.isNotEmpty;
    final bool hasIcon = icon != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding:  activeColumn == false ? EdgeInsets.symmetric(horizontal:  16 , vertical: 8) : EdgeInsets.symmetric(horizontal:  11 , vertical: 8),
        decoration: BoxDecoration(
          color: type == ActionButtonType.full ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: type == ActionButtonType.outline
              ? Border.all(color: color, width: 1.5)
              : null,
        ),
        child: activeColumn == false ?
          Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIcon) Icon(icon, color: type == ActionButtonType.full ? Colors.white : color, size: 18),
            if (hasIcon && hasLabel) const SizedBox(width: 8),
            if (hasLabel)
              Text(
                label!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: type == ActionButtonType.full ? Colors.white : color,
                ),
              ),
          ],
        ) :
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIcon) Icon(icon, color: type == ActionButtonType.full ? Colors.white : color, size: 18),
            if (hasLabel)
              Text(
                label!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: type == ActionButtonType.full ? Colors.white : color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
