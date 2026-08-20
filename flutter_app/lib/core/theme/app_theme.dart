import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Material 3 theme carrying the SchooKeep palette + Inter typography.
/// The React export uses the Inter font family and 12px ("xl") card radii.
abstract final class SchooKeepTheme {
  /// Card / surface corner radius — Tailwind `rounded-xl` == 12px.
  static const double radiusXl = 12;
  static const double radiusLg = 8;
  static const double radiusFull = 999;

  /// Reserved chrome heights from the export.
  static const double statusBarHeight = 44;
  static const double appBarHeight = 56;
  static const double bottomNavHeight = 64;
  static const double minTapTarget = 44;

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: SchooKeepColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SchooKeepColors.primary,
        primary: SchooKeepColors.primary,
        secondary: SchooKeepColors.secondary,
        surface: SchooKeepColors.surface,
        error: SchooKeepColors.error,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: SchooKeepColors.textPrimary,
        displayColor: SchooKeepColors.textPrimary,
      ),
      dividerColor: SchooKeepColors.border,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
