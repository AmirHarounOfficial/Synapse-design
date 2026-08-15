import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../widgets/simulator_frame.dart';

/// Ported from `RamadanModeScreen.tsx` (SYS-05). A simulator showing the active
/// Ramadan-mode dashboard: a persistent amber banner, modified school hours
/// (08:00–13:30), a clinical dose-review prompt, and a cafeteria note. A demo
/// toggle enables/disables the banner. Bilingual via context.tr.
class RamadanModeScreen extends StatefulWidget {
  const RamadanModeScreen({super.key});

  @override
  State<RamadanModeScreen> createState() => _RamadanModeScreenState();
}

class _RamadanModeScreenState extends State<RamadanModeScreen> {
  bool _active = true;

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return SimulatorFrame(
      statusTime: '10:45 AM',
      statusBarDark: false,
      statusBarColor: SimColors.slate900,
      deviceColor: SimColors.slate800,
      controls: SimDemoControls(
        label: 'SYS-05 Ramadan Mode Demo',
        trailing: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: _active ? const Color(0xFFF59E0B) : SimColors.slate700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          onPressed: () => setState(() => _active = !_active),
          child: Text(
            _active
                ? context.tr(en: 'Disable Ramadan Mode', ar: 'إيقاف وضع رمضان')
                : context.tr(en: 'Enable Ramadan Mode', ar: 'تفعيل وضع رمضان'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _active ? Colors.white : SimColors.slate200,
            ),
          ),
        ),
      ),
      child: ColoredBox(
        color: SimColors.slate50,
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: SimColors.white,
                border: Border(bottom: BorderSide(color: SimColors.slate200)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/'),
                    icon: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF0F172A)),
                  ),
                  Expanded(
                    child: Text(
                      context.tr(en: 'Active Ramadan Mode', ar: 'الوضع الرمضاني النشط'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_active) _banner(context, isRTL),
                    if (_active) const SizedBox(height: 16),
                    _operationsCard(context),
                    const SizedBox(height: 16),
                    _doseReviewCard(context),
                    const SizedBox(height: 16),
                    _cafeteriaNote(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _banner(BuildContext context, bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
            child: const Icon(LucideIcons.moon, size: 18, color: Color(0xFFD97706)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(context.tr(en: 'Ramadan Mubarak', ar: 'رمضان كريم'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                    const Text('  ·  ', style: TextStyle(fontSize: 10, color: Color(0xFFF59E0B))),
                    Text(context.tr(en: 'Ramadan Kareem', ar: 'رمضان مبارك'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFB45309))),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(
                    en: 'Modified school hours: 08:00 AM – 1:30 PM',
                    ar: 'ساعات العمل المعدلة: 08:00 ص – 1:30 م',
                  ),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SimColors.slate500),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(en: 'Check medication dose timings', ar: 'تحقق من مواقيت جرعات الأدوية'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _operationsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SimColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.moon, size: 18, color: Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.tr(en: 'Modified School Operations', ar: 'تعديلات ساعات العمل المدرسي'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(
              en: 'Under regulations from the UAE Federal Authority for Government Human Resources and Dubai KHDA, daily school operational timings are compressed to support fasting.',
              ar: 'بموجب قرارات الهيئة الاتحادية للموارد البشرية وهيئة المعرفة والتنمية البشرية في دبي، يتم تعديل ساعات العمل المدرسي اليومية لتسهيل الصيام والالتزام بالأنشطة الروحية.',
            ),
            style: const TextStyle(fontSize: 12, height: 1.5, color: SimColors.slate500),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                Expanded(child: _hoursCol(context.tr(en: 'School Start', ar: 'بداية الدوام'), '08:00 AM')),
                Expanded(child: _hoursCol(context.tr(en: 'School End', ar: 'نهاية الدوام'), '01:30 PM')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hoursCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _doseReviewCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SimColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.checkCircle2, size: 18, color: Color(0xFF10B981)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.tr(en: 'Clinical Dose Review Alert', ar: 'مراجعة جرعات الأدوية للممرضين'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(
              en: "Nurses are prompted to check and adjust students' daytime medication schedules to fall within the shortened school hours.",
              ar: 'يجب على الممرضة مراجعة وتعديل مواقيت جرعات الطلاب لتقع ضمن فترة ساعات العمل المدرسي المخفضة.',
            ),
            style: const TextStyle(fontSize: 12, height: 1.5, color: SimColors.slate500),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.go('/nurse/daily-doses'),
              child: Text(
                context.tr(en: 'Go to Daily Dose View', ar: 'الذهاب لجدول جرعات الأدوية اليومي'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cafeteriaNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertCircle, size: 18, color: Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr(
                en: 'Cafeteria Note: Morning meal service is modified. Food preparation is adapted to accommodate fasting and non-fasting children separately.',
                ar: 'ملاحظة الكافتيريا: يتم إيقاف وجبات الإفطار الصباحية وتعديل خدمات الطعام لتناسب الطلاب الصائمين وغير الصائمين بشكل منفصل.',
              ),
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
            ),
          ),
        ],
      ),
    );
  }
}
