import 'package:flutter/material.dart';

/// Quick helpers for layout widgets

// ---------- Padding ----------
Widget padAll(double value, Widget child) {
  return Padding(
    padding: EdgeInsets.all(value),
    child: child,
  );
}

Widget padSym({double h = 0, double v = 0, required Widget child}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
    child: child,
  );
}

// ---------- Column ----------
Widget colStart(List<Widget> children, {MainAxisSize size = MainAxisSize.max}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: size,
    children: children,
  );
}

Widget colCenter(List<Widget> children, {MainAxisSize size = MainAxisSize.max}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: size,
    children: children,
  );
}

Widget colEnd(List<Widget> children, {MainAxisSize size = MainAxisSize.max}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisSize: size,
    children: children,
  );
}

// ---------- Row ----------
Widget rowStart(List<Widget> children, {MainAxisSize size = MainAxisSize.max}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: size,
    children: children,
  );
}

Widget rowCenter(List<Widget> children, {MainAxisSize size = MainAxisSize.max}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: size,
    children: children,
  );
}

Widget rowEnd(List<Widget> children, {MainAxisSize size = MainAxisSize.max}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisSize: size,
    children: children,
  );
}

Widget rowSpaceBetween(List<Widget> children,
    {MainAxisSize size = MainAxisSize.max}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    mainAxisSize: size,
    children: children,
  );
}

Widget rowSpaceAround(List<Widget> children,
    {MainAxisSize size = MainAxisSize.max}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    mainAxisSize: size,
    children: children,
  );
}

Widget rowSpaceEvenly(List<Widget> children,
    {MainAxisSize size = MainAxisSize.max}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    mainAxisSize: size,
    children: children,
  );
}
