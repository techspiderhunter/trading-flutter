import 'package:flutter/material.dart';



/// Neutral Colors
const Color kcWhite = Color(0xffffffff);
const Color kcOffWhite = Color(0xfff1f1f1);
const Color kcBlack = Color(0xff151515);

/// GRAY Colors
const Color kcGray = Color(0xffcdcdcd);
const Color kcLightGray = Color(0xffeeeeee);

/// All Dark Colors
const Color kcDark = Color(0xFF414141);
const Color kcDarkAlt = Color(0xFF7E7E7E);
const Color kcDarker = Color(0xFF252929);
const Color kcDarkest = Color(0xFF191C1C);

/// Theme colors
// const Color kcPrimary = Color(0xffFF5850);
const Color kcPrimary = Color(0xff2B2926);
const Color kcSecondary = Color(0xFF3f3c39);
const Color kcAccent = Color(0xffdddd2e);
const Color kcDanger = Color(0xFFEB3349);
const Color kcSuccess = Color(0xFF46db43);
const Color kcInfo = Color(0xFF2775C8);
const Color kcWarning = Color(0xFFF59E0B);
const Color kcAccentLight = Color(0xFFFED330);

/// Design specific colors
const Color kcAppbarBackground = kcPrimary;
const Color kcAppBackground = Color(0xffF8F7F7);
const Color kcBtnColor = Color(0xff642284);
const Color kcAppBarSearchBoxColor = Color(0xffD34A44);
const Color kcBtndeepOrange = Color(0xFFEF7A00);


const Color kcBackgroundDark = Color(0xFF0F1720);
const Color kcCard = Color(0xFF111419);
const Color kcAccent1 = Color(0xFFEF4444);
const Color kcAccent2 = Color(0xFFFB923C);
const Color kcAccent3 = Color(0xFFF59E0B);
const Color kcAccent4 = Color(0xFF1E3A8A);
const Color kcAccent5 = Color(0xFF064E3B);

Color getContrastColor(Color color) {
  int d = 0;

// Counting the perceptive luminance - human eye favors green color...
  double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

  if (luminance > 0.7)
    d = 0; // bright colors - black font
  else
    d = 255; // dark colors - white font

  return Color.fromARGB(color.alpha, d, d, d);
}
