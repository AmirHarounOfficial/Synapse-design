import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The fixed 44px white iOS status-bar spacer used at the top of every screen
/// in the React export (`<div className="h-[44px] bg-[#FFFFFF]" />`).
class StatusBarSpacer extends StatelessWidget {
  const StatusBarSpacer({super.key, this.color = SchooKeepColors.surface});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(height: SchooKeepTheme.statusBarHeight, color: color);
  }
}
