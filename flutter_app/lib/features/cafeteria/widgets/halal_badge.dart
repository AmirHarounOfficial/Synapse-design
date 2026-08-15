import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';

/// Ported from `HalalBadge.tsx`. A rounded green pill reading "Halal ✓".
/// Uses [SchooKeepColors.halalGreen] for the border/text and a light green fill.
class HalalBadge extends StatelessWidget {
  const HalalBadge({super.key, this.size = HalalBadgeSize.medium});

  final HalalBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final small = size == HalalBadgeSize.small;
    return Container(
      height: small ? 24 : 28,
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: SchooKeepColors.halalGreen),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.check, size: small ? 12 : 14, color: SchooKeepColors.halalGreen),
          const SizedBox(width: 4),
          Text(
            context.tr(en: 'Halal ✓', ar: 'حلال ✓'),
            style: TextStyle(
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: SchooKeepColors.halalGreen,
            ),
          ),
        ],
      ),
    );
  }
}

enum HalalBadgeSize { small, medium }
