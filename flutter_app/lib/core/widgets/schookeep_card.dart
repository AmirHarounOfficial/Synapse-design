import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// White card with the standard 1px slate-200 border + `rounded-xl` radius,
/// matching `bg-white rounded-xl border border-[#E2E8F0]` from the export.
class SchooKeepCard extends StatelessWidget {
  const SchooKeepCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.radius = SchooKeepTheme.radiusXl,
    this.borderColor = SchooKeepColors.border,
    this.color = SchooKeepColors.surface,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double radius;
  final Color borderColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
    );

    final content = Padding(padding: padding, child: child);

    if (onTap == null) {
      return Container(margin: margin, decoration: decoration, child: content);
    }
    return Container(
      margin: margin,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
