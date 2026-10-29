import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/sa_tokens.dart';

/// Renders the Saudi Riyal currency symbol SVG icon at the given size and color.
class RiyalSymbol extends StatelessWidget {
  const RiyalSymbol({
    super.key,
    this.size = 18,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      SaTokens.currencySvgPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      fit: BoxFit.contain,
    );
  }
}
