import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class _Consideration {
  const _Consideration({
    required this.id,
    required this.studentName,
    required this.initials,
    required this.restrictionEn,
    required this.restrictionAr,
    required this.type,
  });
  final String id;
  final String studentName;
  final String initials;
  final String restrictionEn;
  final String restrictionAr;
  final String type; // activity | dietary | environmental
}

/// Ported from `TeacherHealthConsiderations.tsx`. FERPA notice, weather-
/// restricted-today section, full considerations list with type chips, privacy
/// disclaimer, and an info modal explaining FERPA. Localized in EN & AR.
class TeacherHealthConsiderationsScreen extends StatefulWidget {
  const TeacherHealthConsiderationsScreen({super.key});

  @override
  State<TeacherHealthConsiderationsScreen> createState() => _TeacherHealthConsiderationsScreenState();
}

class _TeacherHealthConsiderationsScreenState extends State<TeacherHealthConsiderationsScreen> {
  final _considerations = const [
    _Consideration(
        id: '1',
        studentName: 'Emma Rodriguez',
        initials: 'ER',
        restrictionEn: 'No vigorous outdoor activity',
        restrictionAr: 'ممنوع من الأنشطة الرياضية المجهدة',
        type: 'activity'),
    _Consideration(
        id: '2',
        studentName: 'Marcus Chen',
        initials: 'MC',
        restrictionEn: 'Peanut-free environment required',
        restrictionAr: 'بيئة خالية تماماً من الفول السوداني',
        type: 'dietary'),
    _Consideration(
        id: '3',
        studentName: 'Sarah Williams',
        initials: 'SW',
        restrictionEn: 'Indoor activities during dust advisories',
        restrictionAr: 'البقاء داخل المبنى أثناء التنبيهات الجوية',
        type: 'environmental'),
  ];

  final _weatherRestricted = const [
    (
      id: '3',
      studentName: 'Sarah Williams',
      initials: 'SW',
      restrictionEn: 'Must remain indoors during dust advisory',
      restrictionAr: 'يجب البقاء بالداخل بسبب العاصفة الترابية',
    ),
  ];

  (Color, Color) _typeColors(String type) => switch (type) {
        'activity' => (const Color(0xFFDBEAFE), const Color(0xFF1E40AF)),
        'dietary' => (SchooKeepColors.amberChipBg, SchooKeepColors.amberText),
        'environmental' => (const Color(0xFFF3E8FF), const Color(0xFF6B21A8)),
        _ => (SchooKeepColors.border, SchooKeepColors.textSecondary),
      };

  String _typeLabel(BuildContext context, String type) => switch (type) {
        'activity' => context.tr(en: 'Activity', ar: 'أنشطة رياضية'),
        'dietary' => context.tr(en: 'Dietary', ar: 'غذائية/حساسية'),
        'environmental' => context.tr(en: 'Environmental', ar: 'بيئية/طقس'),
        _ => context.tr(en: 'Other', ar: 'أخرى'),
      };

  void _showFerpaModal() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => Dialog(
        backgroundColor: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ctx.tr(en: 'FERPA Privacy Protection', ar: 'حماية خصوصية البيانات الطبية (FERPA)'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                ctx.tr(
                  en: 'Under the Family Educational Rights and Privacy Act (FERPA), detailed medical information is confidential. You can only view activity restrictions necessary for safe classroom management.',
                  ar: 'بموجب قانون حقوق التعليم والخصوصية (FERPA)، تعد المعلومات الطبية التفصيلية سرية. تقتصر صلاحيتك على عرض القيود والتعليمات الضرورية للإدارة الآمنة للأنشطة.',
                ),
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text(
                ctx.tr(
                  en: 'Full medical records are maintained by the school nurse and accessible only to authorized healthcare personnel.',
                  ar: 'يتم الاحتفاظ بالسجلات الطبية الكاملة لدى ممرض المدرسة وتكون متاحة فقط للكوادر الطبية المعتمدة.',
                ),
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: SchooKeepColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    ctx.tr(en: 'Understood', ar: 'فهمت ذلك'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.canPop() ? context.safeBack() : context.go('/teacher/home'),
        centerTitle: true,
        title: context.tr(en: 'Health Considerations', ar: 'الحالات الصحية والتعليمات الخاصة'),
        actions: [
          InkWell(
            onTap: _showFerpaModal,
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(LucideIcons.info, size: 24, color: SchooKeepColors.textSecondary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ferpaBanner(context),
            const SizedBox(height: 16),
            if (_weatherRestricted.isNotEmpty) ...[
              _dividerLabel(context.tr(en: 'Restricted from Outdoor Activities Today', ar: 'الممنوعون من الأنشطة الخارجية اليوم')),
              const SizedBox(height: 12),
              for (final s in _weatherRestricted) ...[
                _weatherCard(context, s.studentName, s.initials, context.tr(en: s.restrictionEn, ar: s.restrictionAr)),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
            ],
            Text(
              context.tr(en: 'All Health Considerations', ar: 'جميع الحالات الصحية الخاصة').toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: SchooKeepColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            for (final c in _considerations) ...[
              _considerationCard(context, c),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            _disclaimer(context),
          ],
        ),
      ),
    );
  }

  Widget _ferpaBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, size: 20, color: SchooKeepColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr(
                en: 'You are viewing activity restrictions only. Medical details are confidential per FERPA regulations.',
                ar: 'تعرض هذه الشاشة قيود الأنشطة فقط. التفاصيل الطبية سرية طبقاً لأنظمة الخصوصية.',
              ),
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerLabel(String text) {
    return Row(
      children: [
        const Expanded(child: Divider(color: SchooKeepColors.warning, thickness: 1, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: SchooKeepColors.warning,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Expanded(child: Divider(color: SchooKeepColors.warning, thickness: 1, height: 1)),
      ],
    );
  }

  Widget _weatherCard(BuildContext context, String name, String initials, String restriction) {
    return _leftBorderCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(initials, SchooKeepColors.amberChipBg, SchooKeepColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.alertCircle, size: 16, color: SchooKeepColors.warning),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(restriction, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _considerationCard(BuildContext context, _Consideration c) {
    final (bg, fg) = _typeColors(c.type);
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(c.initials, const Color(0xFFEFF6FF), SchooKeepColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(c.studentName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
                      child: Text(_typeLabel(context, c.type),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(en: c.restrictionEn, ar: c.restrictionAr),
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, size: 16, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: context.tr(en: 'Privacy Notice: ', ar: 'إشعار الخصوصية: '),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary),
                    ),
                    TextSpan(
                      text: context.tr(
                        en: 'You cannot access full medical records. These restrictions are provided to support safe classroom activities only.',
                        ar: 'لا يمكنك الوصول للسجلات الطبية الكاملة. تقدم هذه القيود لدعم سلامة الأنشطة الصفية فقط.',
                      ),
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    en: 'For medical emergencies, contact the school nurse immediately at ext. 4521.',
                    ar: 'في حالات الطوارئ الطبية، اتصل فوراً بممرض المدرسة على التحويلة ٤٥٢١.',
                  ),
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _leftBorderCard({required Widget child}) {
    return AccentCard(
      background: SchooKeepColors.surface,
      accentColor: SchooKeepColors.warning,
      accentWidth: 3,
      radius: 12,
      padding: const EdgeInsets.all(12),
      borderColor: SchooKeepColors.border,
      child: child,
    );
  }

  Widget _avatar(String initials, Color bg, Color fg) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(initials, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}
