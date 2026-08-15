import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum SchooKeepButtonVariant { primary, secondary, danger, outline }

/// The recurring full-width 52px CTA button (`h-[52px] rounded-xl`).
class SchooKeepButton extends StatelessWidget {
  const SchooKeepButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SchooKeepButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
    this.height = 52,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final SchooKeepButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final double height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      SchooKeepButtonVariant.primary => (SchooKeepColors.primary, Colors.white, null),
      SchooKeepButtonVariant.secondary => (SchooKeepColors.secondary, Colors.white, null),
      SchooKeepButtonVariant.danger => (SchooKeepColors.error, Colors.white, null),
      SchooKeepButtonVariant.outline => (Colors.white, SchooKeepColors.primary, SchooKeepColors.primary),
    };

    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
        Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: Material(
        color: enabled ? bg : bg.withValues(alpha: 0.5),
        // Use shape only (never shape + borderRadius together — Material asserts).
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SchooKeepTheme.radiusXl),
          side: border == null ? BorderSide.none : BorderSide(color: border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(SchooKeepTheme.radiusXl),
          onTap: enabled ? onPressed : null,
          child: Center(child: child),
        ),
      ),
    );
  }
}
