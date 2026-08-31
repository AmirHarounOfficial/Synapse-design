import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../features/parent/view/parent_chatbot_assistant_screen.dart';
import '../auth/admin_session.dart';
import '../theme/app_colors.dart';
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

    // Bottom nav bar is rendered in RoleShell scaffold, so no extra bottom inset is needed inside body
    final bottomInset = 0.0;

    Widget content = Padding(
      padding: padding.add(EdgeInsets.only(bottom: bottomInset)),
      child: body,
    );
    if (scrollable) {
      content = SingleChildScrollView(child: content);
    }

    final mainLayout = Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          const StatusBarSpacer(),
          ?resolvedAppBar,
          Expanded(child: content),
          if (bottomBar != null)
            SizedBox(
              width: double.infinity,
              child: bottomBar!,
            ),
        ],
      ),
    );

    String currentPath = '';
    try {
      currentPath = GoRouterState.of(context).uri.path;
    } catch (_) {}
    final isNavScreen = currentPath == '/' || currentPath == '/navigation';

    final stackChildren = <Widget>[
      mainLayout,
    ];

    if (!isNavScreen) {
      stackChildren.add(
        ValueListenableBuilder<bool>(
          valueListenable: AdminSession.isAdminNotifier,
          builder: (context, isAdmin, _) {
            if (!isAdmin) return const SizedBox.shrink();
            return _DraggableFloatingHomeButton(
              reserveBottomNav: reserveBottomNav,
            );
          },
        ),
      );
    }

    if (showAiButton) {
      stackChildren.add(
        _DraggableFloatingAiButton(
          role: roleContext,
          reserveBottomNav: reserveBottomNav,
        ),
      );
    }

    return Stack(children: stackChildren);
  }
}

class _DraggableFloatingHomeButton extends StatefulWidget {
  const _DraggableFloatingHomeButton({
    required this.reserveBottomNav,
  });

  final bool reserveBottomNav;

  @override
  State<_DraggableFloatingHomeButton> createState() =>
      _DraggableFloatingHomeButtonState();
}

class _DraggableFloatingHomeButtonState
    extends State<_DraggableFloatingHomeButton> {
  Offset? _position;
  bool? _lastIsRTL;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    if (_lastIsRTL != isRTL) {
      _lastIsRTL = isRTL;
      _position = null;
    }

    final frameWidth = screenSize.width > 393.0 ? 393.0 : screenSize.width;
    final frameHeight = screenSize.height;

    const buttonWidth = 42.0;
    final defaultX = isRTL ? (frameWidth - buttonWidth - 16.0) : 16.0;
    final defaultY =
        frameHeight - (widget.reserveBottomNav ? 135.0 : 95.0);

    final pos = _position ?? Offset(defaultX, defaultY);
    final maxLeft =
        (frameWidth - buttonWidth - 8.0).clamp(8.0, frameWidth);
    final maxTop = (frameHeight - 65.0).clamp(50.0, frameHeight);

    return Positioned(
      left: pos.dx.clamp(8.0, maxLeft),
      top: pos.dy.clamp(50.0, maxTop),
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(
              (pos.dx + details.delta.dx).clamp(8.0, maxLeft),
              (pos.dy + details.delta.dy).clamp(50.0, maxTop),
            );
          });
        },
        child: const _FloatingHomeButton(),
      ),
    );
  }
}

class _FloatingHomeButton extends StatelessWidget {
  const _FloatingHomeButton();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Navigation Screen',
      child: Material(
        color: Colors.transparent,
        elevation: 8,
        borderRadius: BorderRadius.circular(999),
        shadowColor: SchooKeepColors.primary.withAlpha(120),
        child: InkWell(
          onTap: () {
            context.go('/');
          },
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SchooKeepColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              LucideIcons.compass,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _DraggableFloatingAiButton extends StatefulWidget {
  const _DraggableFloatingAiButton({
    required this.role,
    required this.reserveBottomNav,
  });

  final String role;
  final bool reserveBottomNav;

  @override
  State<_DraggableFloatingAiButton> createState() => _DraggableFloatingAiButtonState();
}

class _DraggableFloatingAiButtonState extends State<_DraggableFloatingAiButton> {
  Offset? _position;
  bool? _lastIsRTL;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    if (_lastIsRTL != isRTL) {
      _lastIsRTL = isRTL;
      _position = null;
    }

    final frameWidth = screenSize.width > 393.0 ? 393.0 : screenSize.width;
    final frameHeight = screenSize.height;

    const buttonWidth = 140.0;
    final defaultX = isRTL ? 16.0 : (frameWidth - buttonWidth - 16.0);
    final defaultY = frameHeight - (widget.reserveBottomNav ? 110.0 : 75.0);

    final pos = _position ?? Offset(defaultX, defaultY);
    final maxLeft = (frameWidth - buttonWidth - 8.0).clamp(8.0, frameWidth);
    final maxTop = (frameHeight - 65.0).clamp(50.0, frameHeight);

    return Positioned(
      left: pos.dx.clamp(8.0, maxLeft),
      top: pos.dy.clamp(50.0, maxTop),
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(
              (pos.dx + details.delta.dx).clamp(8.0, maxLeft),
              (pos.dy + details.delta.dy).clamp(50.0, maxTop),
            );
          });
        },
        child: _FloatingAiButton(role: widget.role),
      ),
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
