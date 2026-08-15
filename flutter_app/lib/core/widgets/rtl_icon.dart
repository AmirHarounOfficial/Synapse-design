import 'package:flutter/material.dart';

/// An icon that horizontally mirrors in RTL — the Flutter equivalent of the
/// export's `${isRTL ? 'rotate-180' : ''}` on chevrons/arrows.
class RtlIcon extends StatelessWidget {
  const RtlIcon(this.icon, {super.key, this.size, this.color});

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final child = Icon(icon, size: size, color: color);
    if (!isRTL) return child;
    return Transform.flip(flipX: true, child: child);
  }
}
