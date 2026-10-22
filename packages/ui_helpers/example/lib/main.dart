import 'package:flutter/material.dart';
import 'package:ui_helpers/ui_helpers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: h2("UI Helpers Demo", color: white), backgroundColor:primaryColor),
        body: padAll(
          16,
          colStart([
            h1("Heading 1"),
            gapH16,
            bodyText("This is body text."),
            gapH12,
            rowSpaceBetween([
              smallText("Left"),
              captionText("Right", color: error),
            ]),
          ]),
        ),
      ),
    );
  }
}
