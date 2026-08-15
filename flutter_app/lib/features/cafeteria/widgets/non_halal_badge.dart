import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import 'halal_badge.dart' show HalalBadgeSize;

/// Ported from `NonHalalBadge.tsx`. A rounded red pill reading "Non-Halal ⚠".
class NonHalalBadge extends StatelessWidget {
  const NonHalalBadge({super.key, this.size = HalalBadgeSize.medium});

  final HalalBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final small = size == HalalBadgeSize.small;
    return Container(
      height: small ? 24 : 28,
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: SchooKeepColors.error),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.alertTriangle, size: small ? 12 : 14, color: SchooKeepColors.error),
          const SizedBox(width: 4),
          Text(
            context.tr(en: 'Non-Halal ⚠', ar: 'غير حلال ⚠'),
            style: TextStyle(
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: SchooKeepColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
