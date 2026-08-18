import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A single bottom-nav destination.
class SchooKeepTab {
  const SchooKeepTab({
    required this.icon,
    required this.label,
    this.arLabel,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String? arLabel;
  final String route; // go_router location for this tab

  String localizedLabel(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    if (isRTL && arLabel != null && arLabel!.isNotEmpty) {
      return arLabel!;
    }
    return label;
  }
}

/// Fixed 83px bottom tab bar. Tab order reverses in RTL (matching
/// `const tabsToRender = isRTL ? [...tabs].reverse() : tabs`). The active color
/// is configurable (e.g. physician teal vs. the default medical blue).
class SchooKeepBottomNav extends StatelessWidget {
  const SchooKeepBottomNav({
    super.key,
    required this.tabs,
    required this.currentRoute,
    required this.onSelect,
    this.activeColor = SchooKeepColors.primary,
  });

  final List<SchooKeepTab> tabs;
  final String currentRoute;
  final ValueChanged<SchooKeepTab> onSelect;
  final Color activeColor;

  bool _isActive(SchooKeepTab tab) =>
      currentRoute == tab.route || currentRoute.startsWith('${tab.route}/');

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final ordered = isRTL ? tabs.reversed.toList() : tabs;

    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: SchooKeepTheme.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final tab in ordered)
                _NavItem(
                  tab: tab,
                  active: _isActive(tab),
                  activeColor: activeColor,
                  onTap: () => onSelect(tab),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  final SchooKeepTab tab;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : SchooKeepColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SchooKeepTheme.radiusLg),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: SchooKeepTheme.minTapTarget,
          minHeight: SchooKeepTheme.minTapTarget,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(tab.localizedLabel(context), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
