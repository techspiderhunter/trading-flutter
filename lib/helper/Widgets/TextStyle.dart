
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ColorPalette.dart';

class TextStyl {
  static TextStyle? get heading1 {
    return Theme.of(Get.context!).textTheme.displayLarge;
  }

  static TextStyle? get heading2 {
    return Theme.of(Get.context!).textTheme.displayMedium;
  }

  static TextStyle? get heading3 {
    return Theme.of(Get.context!).textTheme.displaySmall;
  }

  static TextStyle? get title {
    return Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle? get subtitle {
    return Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: kcDark.withOpacity(0.75),
    );
  }

  static TextStyle? get body {
    return Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle? get bodySm {
    return Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
      fontSize: 14.0,
    );
  }

  static TextStyle? get bodyXs {
    return Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
      fontSize: 12.0,
    );
  }

  static TextStyle? get caption {
    return Theme.of(Get.context!).textTheme.bodySmall;
  }

  static TextStyle? get button {
    return Theme.of(Get.context!).textTheme.labelLarge?.copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      height: 1.07,
    );
  }

  static TextStyle? get label {
    return Theme.of(Get.context!).textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 14.0,
    );
  }
}
