import 'package:flutter/material.dart';

/// Exact design tokens ported from the React export (`src/tokens/colors.ts`).
/// Use these everywhere instead of hard-coded hex values.
abstract final class SchooKeepColors {
  static const Color primary = Color(0xFF2563EB); // Deep Medical Blue — CTAs, active states
  static const Color secondary = Color(0xFF06B6D4); // Calm Cyan — secondary actions
  static const Color accent = Color(0xFF10B981); // Emerald Green — success, safe, confirmed
  static const Color background = Color(0xFFF8FAFC); // Soft Cloud — page background
  static const Color surface = Color(0xFFFFFFFF); // White — cards, sheets, modals
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 — headings, labels
  static const Color textSecondary = Color(0xFF64748B); // Slate 500 — subtitles, placeholders
  static const Color error = Color(0xFFDC2626); // Medical Red — errors, critical alerts
  static const Color warning = Color(0xFFF59E0B); // Amber — warnings, pending states
  static const Color border = Color(0xFFE2E8F0); // Slate 200 — dividers, card borders

  // UAE additions
  static const Color uaeGreen = Color(0xFF006C35); // UAE flag green — compliance badges only
  static const Color physicianTeal = Color(0xFF0D9488); // Physician role color
  static const Color halalGreen = Color(0xFF15803D); // Halal badge color

  // Common tints seen inline across screens
  static const Color amberBg = Color(0xFFFFFBEB);
  static const Color amberText = Color(0xFF92400E);
  static const Color amberChipBg = Color(0xFFFEF3C7);
  static const Color greenChipBg = Color(0xFFD1FAE5);
  static const Color greenChipText = Color(0xFF065F46);
}
