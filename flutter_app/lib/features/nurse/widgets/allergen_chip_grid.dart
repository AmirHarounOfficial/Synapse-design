import 'package:flutter/material.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';

/// Local port of `AllergenChipGrid.tsx`. Two sectioned grids of tappable chips:
/// dietary/sharia requirements (red) and FDA allergens (blue).
class AllergenChipGrid extends StatelessWidget {
  const AllergenChipGrid({
    super.key,
    required this.selectedIds,
    this.onToggle,
    this.readOnly = false,
  });

  final List<String> selectedIds;
  final void Function(String id)? onToggle;
  final bool readOnly;

  static const List<({String id, String emoji, String en, String ar})> _dietary = [
    (id: 'non-halal', emoji: '⚠️', en: 'Non-Halal', ar: 'غير حلال'),
    (id: 'pork', emoji: '🐷', en: 'Pork/Pork-derived', ar: 'خنزير/مشتقات الخنزير'),
    (id: 'alcohol', emoji: '🍺', en: 'Alcohol-derived', ar: 'مشتقات كحولية'),
  ];

  static const List<({String id, String emoji, String en, String ar})> _allergens = [
    (id: 'peanuts', emoji: '🥜', en: 'Peanuts', ar: 'فول سوداني'),
    (id: 'tree-nuts', emoji: '🌰', en: 'Tree Nuts', ar: 'مكسرات الأشجار'),
    (id: 'dairy', emoji: '🥛', en: 'Dairy', ar: 'ألبان'),
    (id: 'eggs', emoji: '🥚', en: 'Eggs', ar: 'بيض'),
    (id: 'wheat', emoji: '🌾', en: 'Wheat/Gluten', ar: 'قمح/غلوتين'),
    (id: 'soy', emoji: '🫘', en: 'Soy', ar: 'صويا'),
    (id: 'sesame', emoji: '🟤', en: 'Sesame', ar: 'سمسم'),
    (id: 'fish', emoji: '🐟', en: 'Fish', ar: 'أسماك'),
    (id: 'shellfish', emoji: '🦐', en: 'Shellfish', ar: 'قشريات'),
  ];

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return Column(
      children: [
        _section(
          context,
          label: isRTL ? 'المتطلبات الغذائية / الشرعية' : 'Dietary Requirements',
          lineColor: const Color(0xFFFECACA),
          labelColor: SchooKeepColors.error,
          items: _dietary,
          isDietary: true,
        ),
        const SizedBox(height: 16),
        _section(
          context,
          label: isRTL ? 'المواد المسببة للحساسية' : 'Allergen Restrictions',
          lineColor: const Color(0xFFDBEAFE),
          labelColor: SchooKeepColors.primary,
          items: _allergens,
          isDietary: false,
        ),
      ],
    );
  }

  Widget _section(
    BuildContext context, {
    required String label,
    required Color lineColor,
    required Color labelColor,
    required List<({String id, String emoji, String en, String ar})> items,
    required bool isDietary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, color: lineColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: lineColor)),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: [for (final item in items) _chip(context, item, isDietary)],
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    ({String id, String emoji, String en, String ar}) item,
    bool isDietary,
  ) {
    final isSelected = selectedIds.contains(item.id);
    final Color bg;
    final Color border;
    final Color fg;
    if (isSelected) {
      bg = isDietary ? SchooKeepColors.error : SchooKeepColors.primary;
      border = bg;
      fg = Colors.white;
    } else {
      bg = SchooKeepColors.surface;
      border = isDietary ? const Color(0xFFFCA5A5) : SchooKeepColors.border;
      fg = isDietary ? SchooKeepColors.error : SchooKeepColors.textPrimary;
    }

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: readOnly || onToggle == null ? null : () => onToggle!(item.id),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.en,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg, height: 1.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                item.ar,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  color: isSelected ? Colors.white.withValues(alpha: 0.95) : SchooKeepColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
