import 'package:flutter/material.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';

/// Local port of `HijriDateChip.tsx`. Renders the Hijri equivalent of a date in
/// a small slate pill. Returns an empty box if the date can't be parsed.
class HijriDateChip extends StatelessWidget {
  const HijriDateChip({super.key, required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();
    final hijri = DateFormatter.toHijri(date!, context.languageCode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: SchooKeepColors.background,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Text(hijri,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
    );
  }
}
