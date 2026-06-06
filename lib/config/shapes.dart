import 'package:flutter/material.dart';
import 'spacing.dart';

class AppShapes {
  static RoundedRectangleBorder get card => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
      );

  static RoundedRectangleBorder get smallCard => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.md),
      );

  static RoundedRectangleBorder get dialog => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.dialogRadius),
      );

  static RoundedRectangleBorder get chip => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.chipRadius),
      );

  static RoundedRectangleBorder input({double radius = Spacing.inputRadius}) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}
