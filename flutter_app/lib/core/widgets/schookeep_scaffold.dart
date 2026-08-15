import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'schookeep_app_bar.dart';
import 'status_bar_spacer.dart';

/// Standard screen shell: white status-bar spacer (44px) + optional 56px app
/// bar + a `#F8FAFC` body. Reserves bottom space for the fixed tab bar when the
/// screen lives inside a role layout.
class SchooKeepScaffold extends StatelessWidget {
  const SchooKeepScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.title,
    this.onBack,
    this.actions = const [],
    this.scrollable = true,
    this.reserveBottomNav = false,
    this.backgroundColor = SchooKeepColors.background,
    this.bottomBar,
    this.padding = EdgeInsets.zero,
  });

  final Widget body;

  /// Provide a custom app bar; otherwise [title]/[onBack]/[actions] build one.
  final SchooKeepAppBar? appBar;
  final String? title;
  final VoidCallback? onBack;
  final List<Widget> actions;

  final bool scrollable;
  final bool reserveBottomNav;
  final Color backgroundColor;

  /// A pinned bottom action area (e.g. a primary CTA above the tab bar).
  final Widget? bottomBar;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final resolvedAppBar = appBar ??
        ((title != null || onBack != null || actions.isNotEmpty)
            ? SchooKeepAppBar(title: title, onBack: onBack, actions: actions)
            : null);

    final bottomInset = reserveBottomNav ? SchooKeepTheme.bottomNavHeight : 0.0;

    Widget content = Padding(
      padding: padding.add(EdgeInsets.only(bottom: bottomInset)),
      child: body,
    );
    if (scrollable) {
      content = SingleChildScrollView(child: content);
    }

    return ColoredBox(
      color: backgroundColor,
      child: Column(
        children: [
          const StatusBarSpacer(),
          ?resolvedAppBar,
          Expanded(child: content),
          ?bottomBar,
        ],
      ),
    );
  }
}
