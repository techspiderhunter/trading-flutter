import 'package:flutter/material.dart';

enum AppColorTheme {
  finwiseMint,
  royalBlue,
  obsidianDark, // Deep Obsidian & Neon Mint
}

class AppColors {
  static AppColorTheme currentTheme = AppColorTheme.finwiseMint;

  static void switchTheme(AppColorTheme theme) {
    currentTheme = theme;
  }

  static const Color primary = Color(0xFF6554D9);
  static const Color primaryDark = Color(0xFF5342C3);
  static const Color primaryLight = Color(0xFFEEEBFF);

  static const Color headerGreen = Color(0xFF152945);
  static const Color headerGreenDark = Color(0xFF343665);

  static const Color cardBlue = Color(0xFFF0EDFF);
  static const Color iconBlue = Color(0xFF6554D9);
  static const Color iconBlueLight = Color(0xFFE5DFFF);

  static const Color accent = Color(0xFF7663EB);
  static const Color cards = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7663EB), primaryDark],
    begin: Alignment.topLeft,
    end: Alignment(1, -0.4),
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [
      Color(0xFF152945),
      Color(0xFF343665),
      Color(0xFF6451AD),
    ],
    stops: [0, 0.6, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color scaffoldBackground = Color(0xFFF1F3FA);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color surfaceElevated = Colors.white;
  static const Color surfaceSecondary = Color(0xFFE9EDF5);
  static const Color bottomNavBg = Colors.white;

  static const Color textHeading = Color(0xFF192542);
  static const Color textPrimary = Color(0xFF192542);
  static const Color textSecondary = Color(0xFF65728B);
  static const Color textMuted = Color(0xFF738097);
  static const Color textWhite = Colors.white;

  static const Color border = Color(0xFFE0E5F0);
  static const Color borderLight = Color(0xFFE8ECF5);
  static const Color borderFocused = Color(0xFF6554D9);
  static const Color divider = Color(0xFFE0E5F0);
  static const Color inputBg = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE0E5F0);

  static const Color success = Color(0xFF08785C);
  static const Color successBg = Color(0xFFE1F4ED);
  static const Color successBorder = Color(0xFFA7DCCB);

  static const Color error = Color(0xFFB63D59);
  static const Color errorBg = Color(0xFFFCEAF0);
  static const Color errorBorder = Color(0xFFEEC0CE);

  static const Color warning = Color(0xFF975A12);
  static const Color warningBg = Color(0xFFFFF1DE);
  static const Color warningBorder = Color(0xFFE9D0A8);

  static const Color info = Color(0xFF6554D9);
  static const Color infoBg = Color(0xFFEEEBFF);
  static const Color infoBorder = Color(0xFFD4CBF8);

  static const Color reviewAmberBg = Color(0xFFFFF1DE);
  static const Color reviewAmberCircle = Color(0xFFF9E5C6);
  static const Color reviewAmberBorder = Color(0xFFE9D0A8);
  static const Color reviewAmberText = Color(0xFF975A12);
  static const Color reviewAmberDark = Color(0xFF71410C);

  static const Color readOnlyTag = Color(0xFF975A12);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF192542).withValues(alpha: 0.035),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: const Color(0xFF091A2E).withValues(alpha: 0.01),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.16),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get glowPrimary => [
        BoxShadow(
          color: primary.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get amberShadow => [
        BoxShadow(
          color: warning.withValues(alpha: 0.16),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get errorShadow => [
        BoxShadow(
          color: error.withValues(alpha: 0.14),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
