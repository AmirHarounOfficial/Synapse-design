import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'schookeep_bottom_nav.dart';

/// Shell used by every role's `ShellRoute`: renders the active child screen with
/// a fixed bottom tab bar underneath (the Flutter analog of a `*Layout.tsx` with
/// its `<Outlet/>`). Screens themselves render their own status bar + app bar.
class RoleShell extends StatelessWidget {
  const RoleShell({
    super.key,
    required this.child,
    required this.tabs,
    this.activeColor = SchooKeepColors.primary,
  });

  final Widget child;
  final List<SchooKeepTab> tabs;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return Scaffold(
      backgroundColor: SchooKeepColors.background,
      body: child,
      bottomNavigationBar: SchooKeepBottomNav(
        tabs: tabs,
        currentRoute: location,
        activeColor: activeColor,
        onSelect: (tab) => context.go(tab.route),
      ),
    );
  }
}
