import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../features/parent/view/parent_chatbot_assistant_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'schookeep_app_bar.dart';
import 'status_bar_spacer.dart';

/// Standard screen shell: white status-bar spacer (44px) + optional 56px app
/// bar + a `#F8FAFC` body. Reserves bottom space for the fixed tab bar when the
/// screen lives inside a role layout. Includes floating SchooKeep AI assistant button.
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
    this.showAiButton = true,
    this.roleContext = 'general',
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
  final bool showAiButton;
  final String roleContext;
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

    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final mainLayout = ColoredBox(
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

    if (!showAiButton) {
      return mainLayout;
    }

    return Stack(
      children: [
        mainLayout,
        Positioned(
          bottom: reserveBottomNav ? 95 : 24,
          left: isRTL ? 16 : null,
          right: isRTL ? null : 16,
          child: _FloatingAiButton(role: roleContext),
        ),
      ],
    );
  }
}

class _FloatingAiButton extends StatelessWidget {
  const _FloatingAiButton({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: Colors.transparent,
      elevation: 6,
      borderRadius: BorderRadius.circular(999),
      shadowColor: SchooKeepColors.primary.withAlpha(100),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ParentChatbotAssistantScreen(role: role),
            ),
          );
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: SchooKeepColors.primary,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withAlpha(80), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                isRTL ? 'مساعد AI' : 'SchooKeep AI',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
