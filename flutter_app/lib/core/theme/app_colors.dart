import 'package:flutter/material.dart';

/// Exact design tokens ported from the React export (`src/tokens/colors.ts`).
/// Updated for the Saudi market with KSA-optimized palette.
abstract final class SchooKeepColors {
  // Saudi Primary Palette
  static const Color primary = Color(0xFF006C35); // Saudi Green — CTAs, active states, primary identity
  static const Color secondary = Color(0xFF06B6D4); // Calm Cyan — secondary actions
  static const Color accent = Color(0xFF10B981); // Emerald Green — success, safe, confirmed

  // Surfaces
  static const Color background = Color(0xFFF8FAFC); // Soft Cloud — page background
  static const Color surface = Color(0xFFFFFFFF); // White — cards, sheets, modals

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 — headings, labels
  static const Color textSecondary = Color(0xFF64748B); // Slate 500 — subtitles, placeholders

  // Semantic
  static const Color error = Color(0xFFDC2626); // Medical Red — errors, critical alerts
  static const Color warning = Color(0xFFF59E0B); // Amber — warnings, pending states
  static const Color border = Color(0xFFE2E8F0); // Slate 200 — dividers, card borders

  // Saudi additions
  static const Color saudiGreen = Color(0xFF006C35); // Saudi flag green — primary identity color
  static const Color saudiGreenLight = Color(0xFFE8F5E9); // Light green tint — backgrounds
  static const Color physicianTeal = Color(0xFF0D9488); // Physician role color
  static const Color halalGreen = Color(0xFF15803D); // Halal badge color

  // Common tints seen inline across screens
  static const Color amberBg = Color(0xFFFFFBEB);
  static const Color amberText = Color(0xFF92400E);
  static const Color amberChipBg = Color(0xFFFEF3C7);
  static const Color greenChipBg = Color(0xFFD1FAE5);
  static const Color greenChipText = Color(0xFF065F46);
}
