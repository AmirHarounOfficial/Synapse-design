import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `CafeteriaEmptyState.tsx`. The "no restrictions today" variant of
/// the alerts screen: an acknowledgment prompt followed by an all-clear empty
/// state. The source is English-only, so this screen is not bilingual.
class CafeteriaEmptyStateScreen extends StatefulWidget {
  const CafeteriaEmptyStateScreen({super.key});

  @override
  State<CafeteriaEmptyStateScreen> createState() => _CafeteriaEmptyStateScreenState();
}

class _CafeteriaEmptyStateScreenState extends State<CafeteriaEmptyStateScreen> {
  bool _isAcknowledged = false;
  String? _acknowledgedAt;

  String _nowTime() {
    final now = TimeOfDay.now();
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $period';
  }

  void _handleAcknowledge() {
    setState(() {
      _acknowledgedAt = _nowTime();
      _isAcknowledged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final todaysDate = '${months[now.month - 1]} ${now.day}, ${now.year}';

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        titleWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Meal Restrictions",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
            Text(todaysDate, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isAcknowledged)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SchooKeepColors.amberChipBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SchooKeepColors.warning, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Please confirm you have checked today's restriction list",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.amberText),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: SchooKeepColors.warning,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _handleAcknowledge,
                        child: const Text('Acknowledge',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SchooKeepColors.greenChipBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SchooKeepColors.accent),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.check, size: 20, color: SchooKeepColors.accent),
                    const SizedBox(width: 8),
                    Text('List checked at $_acknowledgedAt ✓',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.greenChipText)),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            // Empty state card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(color: SchooKeepColors.greenChipBg, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.checkCircle, size: 40, color: SchooKeepColors.accent),
                  ),
                  const SizedBox(height: 16),
                  const Text('No Meal Restrictions Today',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('All students can eat from the standard menu',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(999)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 8,
                          height: 8,
                          child: DecoratedBox(decoration: BoxDecoration(color: SchooKeepColors.accent, shape: BoxShape.circle)),
                        ),
                        SizedBox(width: 8),
                        Text("All clear for today's service",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.greenChipText)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
                  children: [
                    TextSpan(text: 'Note: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    TextSpan(
                        text:
                            'If any restrictions are added during the day, you will receive an immediate alert notification.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
