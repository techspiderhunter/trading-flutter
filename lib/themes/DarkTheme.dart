import 'package:flutter/material.dart';
import 'package:ui_helpers/ui/colors.dart';

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    // deepOrange: deepOrange,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
    ),
    scaffoldBackgroundColor: Colors.black,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
