import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A rounded card/banner with a colored accent stripe on its leading (start)
/// edge — the SchooKeep equivalent of the React `border-l-[3px] rounded-lg`
/// pattern.
///
/// Flutter forbids combining a NON-UNIFORM border (e.g. `BorderDirectional`
/// with only a `start` side) with `borderRadius` in a single `BoxDecoration`
/// (asserts in debug). This widget avoids that by clipping to the radius and
/// drawing the accent as a separate leading strip, so it's safe in debug too.
/// The stripe sits on the start edge, so it mirrors correctly in RTL.
class AccentCard extends StatelessWidget {
  const AccentCard({
    super.key,
    required this.child,
    required this.accentColor,
    this.background = Colors.white,
    this.accentWidth = 3,
    this.radius = SchooKeepTheme.radiusLg,
    this.padding = const EdgeInsets.all(12),
    this.margin,
    this.borderColor,
  });

  final Widget child;
  final Color accentColor;
  final Color background;
  final double accentWidth;
  final double radius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  /// Optional uniform border drawn around the whole card (safe with radius).
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: accentWidth, color: accentColor),
            Expanded(
              child: ColoredBox(
                color: background,
                child: Padding(padding: padding, child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
