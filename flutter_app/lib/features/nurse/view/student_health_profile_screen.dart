import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../widgets/hijri_date_chip.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `StudentHealthProfile.tsx`. Student hero card, UAE insurance
/// block, and a tabbed section (Medications / Visit History / Documents /
/// Screenings). Bilingual. Route is `/nurse/students/:id`.
class StudentHealthProfileScreen extends StatefulWidget {
  const StudentHealthProfileScreen({super.key, required this.id});

  final String id;

  @override
  State<StudentHealthProfileScreen> createState() => _StudentHealthProfileScreenState();
}

class _Medication {
  const _Medication(this.name, this.dose, this.nextTime, this.status);
  final String name;
  final String dose;
  final String nextTime;
  final String status;
}

class _Visit {
  const _Visit(this.date, this.reason, this.nurse, this.locked);
  final String date;
  final String reason;
  final String nurse;
  final bool locked;
}

class _Doc {
  const _Doc(this.name, this.status);
  final String name;
  final String status;
}

class _Screening {
  const _Screening(this.type, this.date, this.nurse, this.values);
  final String type;
  final String date;
  final String nurse;
  final String values;
}

class _StudentHealthProfileScreenState extends State<StudentHealthProfileScreen> {
  String _activeTab = 'medications';
  String _curriculum = 'British';

  static const _medicationsData = <_Medication>[
    _Medication('Albuterol Inhaler 90mcg', '2 puffs', '2:00 PM', 'upcoming'),
    _Medication('Adderall XR 10mg', '1 tablet', '8:00 AM', 'given'),
  ];

  static const _curricula = ['UAE MoE', 'British', 'American', 'Indian', 'IB', 'Other'];

  static (Color bg, Color fg) _statusStyle(String status) {
    switch (status) {
      case 'given':
      case 'approved':
        return (SchooKeepColors.greenChipBg, SchooKeepColors.greenChipText);
      case 'pending':
        return (SchooKeepColors.amberChipBg, SchooKeepColors.amberText);
      case 'upcoming':
        return (const Color(0xFFDBEAFE), const Color(0xFF1E40AF));
      case 'missing':
        return (const Color(0xFFFEE2E2), SchooKeepColors.error);
      default:
        return (SchooKeepColors.border, SchooKeepColors.textSecondary);
    }
  }

  String _statusLabel(String status, bool isRTL) {
    if (isRTL) {
      switch (status) {
        case 'given':
          return 'أعطي';
        case 'pending':
          return 'معلق';
        case 'upcoming':
          return 'قادم';
        case 'approved':
          return 'معتمد';
        case 'missing':
          return 'مفقود';
        default:
          return status;
      }
    }
    return status[0].toUpperCase() + status.substring(1);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _shareProfile(bool isRTL) async {
    const summary = 'Emma Rodriguez\n'
        'Grade 3 · Room 204\n'
        'Emirates ID: 784-2016-1234567-1\n'
        'DOB: 19/05/2016\n'
        'Medical Alerts: Asthma, Peanut Allergy\n'
        'Insurance: Daman Health (DM-992384-01)';
    await Clipboard.setData(const ClipboardData(text: summary));
    if (!mounted) return;
    _toast(isRTL
        ? 'تم نسخ ملخص الملف الصحي إلى الحافظة'
        : 'Health profile summary copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    final visits = <_Visit>[
      _Visit('24/05/2026', isRTL ? 'إعطاء الدواء المعتاد' : 'Routine medication', 'Nurse Emily Smith RN-4521', true),
      _Visit('23/05/2026', isRTL ? 'إصابة طفيفة' : 'Minor injury', 'Nurse Emily Smith RN-4521', true),
      _Visit('20/05/2026', isRTL ? 'وعكة صحية' : 'Illness', 'Nurse Sarah Johnson RN-3298', true),
    ];

    final documents = <_Doc>[
      _Doc(isRTL ? 'أمر الطبيب المعالج' : 'Physician Order', 'approved'),
      _Doc(isRTL ? 'موافقة ولي الأمر' : 'Parent Consent', 'approved'),
      _Doc(isRTL ? 'بطاقة التأمين الصحي' : 'Insurance Card', 'pending'),
      _Doc(isRTL ? 'سجل التطعيمات' : 'Immunization Record', 'approved'),
    ];

    final screenings = <_Screening>[
      _Screening(isRTL ? 'فحص النظر' : 'Vision', '01/05/2026', 'ES', '20/20 OD, 20/20 OS'),
      _Screening(isRTL ? 'فحص السمع' : 'Hearing', '01/05/2026', 'ES', isRTL ? 'سليم' : 'Pass bilateral'),
    ];

    final tabs = [
      (id: 'medications', label: isRTL ? 'الأدوية' : 'Medications'),
      (id: 'visits', label: isRTL ? 'سجل الزيارات' : 'Visit History'),
      (id: 'documents', label: isRTL ? 'المستندات' : 'Documents'),
      (id: 'screenings', label: isRTL ? 'الفحوصات' : 'Screenings'),
    ];

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: 'Emma Rodriguez',
        centerTitle: true,
        onBack: () => context.safeBack(),
        actions: [
          InkWell(
            onTap: () => _shareProfile(isRTL),
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(LucideIcons.share2, size: 20, color: SchooKeepColors.textSecondary),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heroCard(isRTL),
            const SizedBox(height: 16),
            _insuranceCard(isRTL),
            const SizedBox(height: 16),
            _tabBar(tabs),
            const SizedBox(height: 16),
            _tabContent(isRTL, visits, documents, screenings),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(bool isRTL) {
    final medicalAlerts = isRTL ? ['ربو', 'حساسية الفول السوداني'] : ['Asthma', 'Peanut Allergy'];
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('ER',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emma Rodriguez',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(isRTL ? 'الصف الثالث · غرفة 204' : 'Grade 3 · Room 204',
                        style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    const SizedBox(height: 12),
                    _curriculumSelector(isRTL),
                    const SizedBox(height: 8),
                    _identityBlock(isRTL),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                _statusPill(isRTL ? 'التفويض الطبي' : 'Consent', true),
                const SizedBox(width: 8),
                _statusPill(isRTL ? 'المستندات مكتملة' : 'Docs Complete', true),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(isRTL ? 'تنبيهات طبية مهمة' : 'Medical Alerts',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in medicalAlerts)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(999)),
                  child: Text(a, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.error)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String label, bool complete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: SchooKeepColors.greenChipBg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SchooKeepColors.greenChipText)),
          if (complete) ...[
            const SizedBox(width: 4),
            const Icon(LucideIcons.check, size: 14, color: SchooKeepColors.greenChipText),
          ],
        ],
      ),
    );
  }

  Widget _curriculumSelector(bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isRTL ? 'المنهج الدراسي للمدرسة' : 'School Curriculum',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        SizedBox(
          height: 36,
          child: DropdownButtonFormField<String>(
            initialValue: _curriculum,
            isExpanded: true,
            icon: const Icon(LucideIcons.chevronDown, size: 16, color: SchooKeepColors.textSecondary),
            style: const TextStyle(fontSize: 12, color: SchooKeepColors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.primary),
              ),
            ),
            items: [for (final c in _curricula) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) {
              if (v == null) return;
              setState(() => _curriculum = v);
              _toast(isRTL ? 'تم تحديث المنهج الدراسي بنجاح' : 'Curriculum updated successfully.');
            },
          ),
        ),
      ],
    );
  }

  Widget _identityBlock(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'رقم الهوية الإماراتية (EID)' : 'Emirates ID (EID)',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
          const Text('784-2016-1234567-1',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary, fontFamily: 'monospace')),
          const SizedBox(height: 6),
          Text(isRTL ? 'تاريخ الميلاد' : 'Date of Birth',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              const Text('19/05/2016',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
              HijriDateChip(date: _dob),
            ],
          ),
        ],
      ),
    );
  }

  static final DateTime _dob = DateTime(2016, 5, 19);

  Widget _insuranceCard(bool isRTL) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
            child: Text(isRTL ? 'التأمين الصحي الإماراتي' : 'UAE Health Insurance',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _insuranceField(isRTL ? 'شركة التأمين' : 'Insurer', 'Daman Health')),
              Expanded(child: _insuranceField(isRTL ? 'رقم وثيقة التأمين' : 'Policy Number', 'DM-992384-01', mono: true)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _insuranceField(isRTL ? 'تاريخ انتهاء البطاقة' : 'Card Expiry', '12/2026', mono: true)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRTL ? 'حالة التغطية' : 'Coverage Status',
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: SchooKeepColors.greenChipBg, borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.check, size: 12, color: SchooKeepColors.greenChipText),
                          const SizedBox(width: 4),
                          Text(isRTL ? 'نشط' : 'Active',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SchooKeepColors.greenChipText)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SchooKeepColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.fileText, size: 16, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(isRTL ? 'بطاقة_التأمين_الصحية.pdf' : 'Health_Insurance_Card.pdf',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                ),
                GestureDetector(
                  onTap: () => _toast(isRTL ? 'جاري تحميل بطاقة التأمين...' : 'Downloading insurance card file...'),
                  child: Text(isRTL ? 'تحميل' : 'Download',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _insuranceField(String label, String value, {bool mono = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: SchooKeepColors.textPrimary,
              fontFamily: mono ? 'monospace' : null,
            )),
      ],
    );
  }

  Widget _tabBar(List<({String id, String label})> tabs) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: SchooKeepColors.border))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final t in tabs) _tab(t.id, t.label),
          ],
        ),
      ),
    );
  }

  Widget _tab(String id, String label) {
    final active = _activeTab == id;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = id),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: active ? SchooKeepColors.primary : Colors.transparent, width: 2),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? SchooKeepColors.primary : SchooKeepColors.textSecondary,
            )),
      ),
    );
  }

  Widget _tabContent(
    bool isRTL,
    List<_Visit> visits,
    List<_Doc> documents,
    List<_Screening> screenings,
  ) {
    switch (_activeTab) {
      case 'visits':
        return Column(
          children: [
            for (final v in visits) ...[
              _visitCard(v),
              const SizedBox(height: 12),
            ],
          ],
        );
      case 'documents':
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [for (final d in documents) _docCard(d, isRTL)],
        );
      case 'screenings':
        return Column(
          children: [
            for (final s in screenings) ...[
              _screeningCard(s),
              const SizedBox(height: 12),
            ],
          ],
        );
      default:
        return Column(
          children: [
            for (final m in _medicationsData) ...[
              _medicationCard(m, isRTL),
              const SizedBox(height: 12),
            ],
            _addMedicationButton(isRTL),
          ],
        );
    }
  }

  Widget _medicationCard(_Medication med, bool isRTL) {
    final (bg, fg) = _statusStyle(med.status);
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Text('${med.dose} • ${isRTL ? 'التالي' : 'Next'}: ${med.nextTime}',
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SchooKeepBadge(label: _statusLabel(med.status, isRTL), background: bg, foreground: fg, fontSize: 11),
        ],
      ),
    );
  }

  Widget _addMedicationButton(bool isRTL) {
    return GestureDetector(
      onTap: () => context.go('/nurse/medications/add/step1'),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.plus, size: 20, color: SchooKeepColors.primary),
            const SizedBox(width: 8),
            Text(isRTL ? 'إضافة دواء جديد للطالب' : 'Add medication',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _visitCard(_Visit visit) {
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(visit.date,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              if (visit.locked) ...[
                const SizedBox(width: 8),
                const Icon(LucideIcons.lock, size: 14, color: SchooKeepColors.textSecondary),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(visit.reason, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 4),
          Text(visit.nurse, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _docCard(_Doc doc, bool isRTL) {
    final (bg, fg) = _statusStyle(doc.status);
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: SchooKeepColors.background, borderRadius: BorderRadius.circular(8)),
            child: const Icon(LucideIcons.fileText, size: 24, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(doc.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 8),
          SchooKeepBadge(label: _statusLabel(doc.status, isRTL), background: bg, foreground: fg, fontSize: 10),
        ],
      ),
    );
  }

  Widget _screeningCard(_Screening screening) {
    return SchooKeepCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(screening.type,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(width: 8),
              const Icon(LucideIcons.lock, size: 14, color: SchooKeepColors.textSecondary),
            ],
          ),
          const SizedBox(height: 4),
          Text(screening.values, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 4),
          Text('${screening.date} • ${screening.nurse}',
              style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }
}
