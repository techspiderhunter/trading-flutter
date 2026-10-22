import 'package:flutter/material.dart';
import 'package:ui_helpers/ui/text_sizes.dart';
import 'colors.dart';

/// Quick text helpers to reduce boilerplate

Text h1(String text,
    {Color color = black,double fontSize = heading1, FontWeight weight = FontWeight.bold}) {
  return Text(
    text,
    style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color),
  );
}

Text h2(String text,
    {Color color = black,double fontSize = heading2, FontWeight weight = FontWeight.w600}) {
  return Text(
    text,
    style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color),
  );
}

Text h3(String text,
    {Color color = black,double fontSize = heading3, FontWeight weight = FontWeight.w500}) {
  return Text(
    text,
    style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color),
  );
}

Text bodyText(String text,
    {Color color = black,double fontSize = body, FontWeight weight = FontWeight.normal}) {
  return Text(
    text,
    style: TextStyle(fontSize: body, fontWeight: weight, color: color),
  );
}

Text smallText(String text,
    {Color color = greyDark,double fontSize = bodySmall, FontWeight weight = FontWeight.normal}) {
  return Text(
    text,
    style: TextStyle(fontSize: bodySmall, fontWeight: weight, color: color),
  );
}

Text captionText(String text,
    {Color color = grey,double fontSize = caption, FontWeight weight = FontWeight.w300}) {
  return Text(
    text,
    style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color),
  );
}
