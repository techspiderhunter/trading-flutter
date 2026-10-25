import '../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData lightTheme() {
  final Color primaryColor = AppColors.primary;
  final Color primaryDark = AppColors.primaryDark;
  final Color primaryLight = AppColors.primaryLight;

  final ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: Colors.white,
    primaryContainer: primaryLight,
    onPrimaryContainer: primaryDark,
    secondary: AppColors.iconBlue,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.cardBlue,
    onSecondaryContainer: AppColors.iconBlue,
    error: AppColors.error,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    fontFamily: 'DeskSans',
    textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'DeskSans',
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textHeading),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textHeading,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 72,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'DeskSans',
        color: AppColors.textHeading,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    cardColor: Colors.white,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.borderLight, width: 1.2),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: const TextStyle(
        fontFamily: 'DeskSans',
        color: AppColors.textMuted,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: primaryColor.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'DeskSans',
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ).copyWith(
        minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
        backgroundBuilder: deskButtonBackground,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'DeskSans',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.scaffoldBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(
          fontFamily: 'DeskSans',
          color: AppColors.textHeading,
          fontSize: 22,
          fontWeight: FontWeight.w600),
      contentTextStyle: const TextStyle(
          fontFamily: 'DeskSans',
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.6),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.scaffoldBackground,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Color(0x66192542),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      clipBehavior: Clip.antiAlias,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.scaffoldBackground,
      headerBackgroundColor: AppColors.primaryLight,
      headerForegroundColor: AppColors.textHeading,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: AppColors.primary),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary)),
    iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size(44, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    )),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textHeading,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
      space: 1,
    ),
  );
}
