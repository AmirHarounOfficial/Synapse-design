import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';

/// Ported from `RamadanBanner.tsx`. A global, dismissible banner shown while
/// Ramadan mode is active. Expanded it shows greetings, modified school hours,
/// and a link to daily doses; dismissed it collapses to a crescent-moon pill in
/// the bottom corner (which mirrors side based on text direction).
///
/// This widget is wired into the app shell separately. The host decides when
/// Ramadan mode is active and on which routes the banner is hidden (the React
/// source hides it on `/login`, `/verify`, `/biometric`, `/splash`,
/// `/system/simulator`, `/`, and `/system/ramadan`).
class RamadanBanner extends StatefulWidget {
  const RamadanBanner({super.key, this.active = true});

  /// Whether Ramadan mode is globally active. When false the banner renders
  /// nothing (`SizedBox.shrink`).
  final bool active;

  @override
  State<RamadanBanner> createState() => _RamadanBannerState();
}

class _RamadanBannerState extends State<RamadanBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    final isRTL = context.isRTL;

    if (_dismissed) {
      // Collapsed crescent-moon pill in the bottom corner.
      return PositionedDirectional(
        bottom: 96,
        end: 16,
        child: Material(
          color: SchooKeepColors.warning,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => setState(() => _dismissed = false),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(LucideIcons.moon, size: 20, color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Positioned(
      top: 56,
      left: 16,
      right: 16,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 361),
          child: Container(
            decoration: BoxDecoration(
              color: SchooKeepColors.amberBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.warning),
              boxShadow: const [
                BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: SchooKeepColors.amberChipBg, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.moon, size: 18, color: Color(0xFFD97706)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isRTL ? 'رمضان كريم' : 'Ramadan Mubarak',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.amberText),
                          ),
                          const Text('  ·  ', style: TextStyle(fontSize: 10, color: SchooKeepColors.warning)),
                          Text(
                            isRTL ? 'رمضان مبارك' : 'Ramadan Kareem',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRTL
                            ? 'ساعات العمل المعدلة: 08:00 ص – 1:30 م'
                            : 'Modified school hours: 08:00 AM – 1:30 PM',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => context.go('/nurse/daily-doses'),
                        child: Text(
                          isRTL ? 'تحقق من مواقيت جرعات الأدوية' : 'Check medication dose timings',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    onPressed: () => setState(() => _dismissed = true),
                    icon: const Icon(LucideIcons.x, size: 16, color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
