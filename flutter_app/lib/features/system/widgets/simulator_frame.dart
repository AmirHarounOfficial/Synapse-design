import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Slate palette used by the system-state "simulator" chrome. These intentionally
/// do not map to SchooKeep tokens: the simulator renders an iPhone device frame on
/// a dark workbench, matching the React `SysX` overlays' slate-900 backdrop.
abstract final class SimColors {
  static const slate950 = Color(0xFF020617);
  static const slate900 = Color(0xFF0F172A);
  static const slate800 = Color(0xFF1E293B);
  static const slate700 = Color(0xFF334155);
  static const slate500 = Color(0xFF64748B);
  static const slate400 = Color(0xFF94A3B8);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate50 = Color(0xFFF8FAFC);
  static const white = Color(0xFFFFFFFF);
}

/// Renders the React "Simulator Viewport": a slate-900 page, a centred iPhone
/// device frame (393x852, 52px radius, 12px slate-950 bezel) with a Dynamic
/// Island, a mock iOS status bar, the screen's content, a home indicator, and a
/// "Return to Navigation Map" link below.
class SimulatorFrame extends StatelessWidget {
  const SimulatorFrame({
    super.key,
    required this.statusTime,
    required this.child,
    this.statusBarDark = true,
    this.statusBarColor = SimColors.white,
    this.deviceColor = SimColors.slate800,
    this.controls,
  });

  /// e.g. '7:15 PM'.
  final String statusTime;
  final Widget child;

  /// Dark glyphs on a white status bar (most screens) vs. white glyphs.
  final bool statusBarDark;
  final Color statusBarColor;
  final Color deviceColor;

  /// Optional demo-controls bar pinned to the top of the workbench.
  final Widget? controls;

  @override
  Widget build(BuildContext context) {
    final glyph = statusBarDark ? SimColors.slate900 : SimColors.white;

    return ColoredBox(
      color: SimColors.slate900,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (controls != null) ...[controls!, const SizedBox(height: 16)],
              Center(
                child: Container(
                  width: 393,
                  height: 852,
                  decoration: BoxDecoration(
                    color: deviceColor,
                    borderRadius: BorderRadius.circular(52),
                    border: Border.all(color: SimColors.slate950, width: 12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // Mock iOS status bar
                          Container(
                            height: 44,
                            color: statusBarColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  statusTime,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: glyph),
                                ),
                                Row(
                                  children: [
                                    Text('5G', style: TextStyle(fontSize: 11, color: glyph)),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 20,
                                      height: 10,
                                      padding: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: glyph),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: glyph,
                                          borderRadius: BorderRadius.circular(1.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: child),
                        ],
                      ),
                      // Dynamic Island
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 110,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                            ),
                          ),
                        ),
                      ),
                      // Home indicator
                      Positioned(
                        bottom: 6,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 140,
                            height: 5,
                            decoration: BoxDecoration(
                              color: SimColors.slate900.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text(
                  'Return to Navigation Map',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SimColors.slate400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The slate demo-controls bar shown above the device on standalone screens.
class SimDemoControls extends StatelessWidget {
  const SimDemoControls({super.key, required this.label, this.trailing});
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 393),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SimColors.slate800.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SimColors.slate700),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SimColors.slate200),
            ),
          ),
          if (trailing != null) Flexible(child: trailing!),
        ],
      ),
    );
  }
}
