import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rounded pill / chip (`px-3 py-1 rounded-full text-[12px]`) used for statuses
/// and counts throughout the export.
class SchooKeepBadge extends StatelessWidget {
  const SchooKeepBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SchooKeepTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: foreground), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: foreground, fontSize: fontSize, fontWeight: fontWeight)),
        ],
      ),
    );
  }
}
