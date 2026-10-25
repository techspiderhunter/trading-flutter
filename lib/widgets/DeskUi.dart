import 'package:flutter/material.dart';
import '../themes/colors.dart';
export 'desk_exact.dart';
export 'compliance_cards.dart';

/// Keeps existing button states and callbacks; paints only brand actions.
Widget deskButtonBackground(
  BuildContext context,
  Set<WidgetState> states,
  Widget? child,
) {
  final button = context.widget;
  final background = (button is ButtonStyleButton
          ? button.style?.backgroundColor?.resolve(states)
          : null) ??
      Theme.of(context)
          .elevatedButtonTheme
          .style
          ?.backgroundColor
          ?.resolve(states);
  return Ink(
    decoration: BoxDecoration(
      gradient: states.contains(WidgetState.disabled) ||
              (background != null && background != AppColors.primary)
          ? null
          : AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}
