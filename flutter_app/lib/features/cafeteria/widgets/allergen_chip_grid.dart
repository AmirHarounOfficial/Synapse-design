import 'package:flutter/material.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';

/// A single allergen / dietary item for [AllergenChipGrid].
class AllergenItem {
  const AllergenItem({required this.id, required this.emoji, required this.en, required this.ar});
  final String id;
  final String emoji;
  final String en;
  final String ar;
}

/// Ported from `AllergenChipGrid.tsx`. Two grids of selectable chips: dietary /
/// Halal requirements (red) and FDA allergens (blue). Selecting fills the chip.
class AllergenChipGrid extends StatelessWidget {
  const AllergenChipGrid({
    super.key,
    required this.selectedIds,
    this.onToggle,
    this.readOnly = false,
  });

  final List<String> selectedIds;
  final ValueChanged<String>? onToggle;
  final bool readOnly;

  static const List<AllergenItem> _dietaryItems = [
    AllergenItem(id: 'non-halal', emoji: '⚠️', en: 'Non-Halal', ar: 'غير حلال'),
    AllergenItem(id: 'pork', emoji: '🐷', en: 'Pork/Pork-derived', ar: 'خنزير/مشتقات الخنزير'),
    AllergenItem(id: 'alcohol', emoji: '🍺', en: 'Alcohol-derived', ar: 'مشتقات كحولية'),
  ];

  static const List<AllergenItem> _allergenItems = [
    AllergenItem(id: 'peanuts', emoji: '🥜', en: 'Peanuts', ar: 'فول سوداني'),
    AllergenItem(id: 'tree-nuts', emoji: '🌰', en: 'Tree Nuts', ar: 'مكسرات الأشجار'),
    AllergenItem(id: 'dairy', emoji: '🥛', en: 'Dairy', ar: 'ألبان'),
    AllergenItem(id: 'eggs', emoji: '🥚', en: 'Eggs', ar: 'بيض'),
    AllergenItem(id: 'wheat', emoji: '🌾', en: 'Wheat/Gluten', ar: 'قمح/غلوتين'),
    AllergenItem(id: 'soy', emoji: '🫘', en: 'Soy', ar: 'صويا'),
    AllergenItem(id: 'sesame', emoji: '🟤', en: 'Sesame', ar: 'سمسم'),
    AllergenItem(id: 'fish', emoji: '🐟', en: 'Fish', ar: 'أسماك'),
    AllergenItem(id: 'shellfish', emoji: '🦐', en: 'Shellfish', ar: 'قشريات'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(
          context.tr(en: 'Dietary Requirements', ar: 'المتطلبات الغذائية / الشرعية'),
          SchooKeepColors.error,
          const Color(0xFFFECACA),
        ),
        const SizedBox(height: 8),
        _grid(_dietaryItems, isDietary: true),
        const SizedBox(height: 16),
        _sectionHeader(
          context.tr(en: 'Allergen Restrictions', ar: 'المواد المسببة للحساسية'),
          SchooKeepColors.primary,
          const Color(0xFFDBEAFE),
        ),
        const SizedBox(height: 8),
        _grid(_allergenItems, isDietary: false),
      ],
    );
  }

  Widget _sectionHeader(String label, Color textColor, Color lineColor) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: lineColor)),
      ],
    );
  }

  Widget _grid(List<AllergenItem> items, {required bool isDietary}) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [for (final item in items) _chip(item, isDietary: isDietary)],
    );
  }

  Widget _chip(AllergenItem item, {required bool isDietary}) {
    final selected = selectedIds.contains(item.id);

    Color bg;
    Color border;
    Color fg;
    if (selected) {
      bg = isDietary ? SchooKeepColors.error : SchooKeepColors.primary;
      border = bg;
      fg = Colors.white;
    } else {
      bg = SchooKeepColors.surface;
      border = isDietary ? const Color(0xFFFCA5A5) : SchooKeepColors.border;
      fg = isDietary ? SchooKeepColors.error : SchooKeepColors.textPrimary;
    }

    return Builder(
      builder: (context) => Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: readOnly || onToggle == null ? null : () => onToggle!(item.id),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
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
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.ar,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : SchooKeepColors.textSecondary,
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
