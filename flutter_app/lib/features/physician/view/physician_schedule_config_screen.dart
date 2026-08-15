import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `PhysicianScheduleConfig.tsx`. On-site day selector with a DHA
/// 3-day minimum compliance check, per-day clinic hours, on-call emergency
/// coverage details, and a backup physician section. Phone fields format /
/// validate via `Validators` (mirrors `phoneValidator.ts`).
class PhysicianScheduleConfigScreen extends StatefulWidget {
  const PhysicianScheduleConfigScreen({super.key});

  @override
  State<PhysicianScheduleConfigScreen> createState() => _PhysicianScheduleConfigScreenState();
}

class _PhysicianScheduleConfigScreenState extends State<PhysicianScheduleConfigScreen> {
  final List<int> _selectedDays = [1, 2, 4]; // Monday, Tuesday, Thursday
  final Map<int, ({TextEditingController start, TextEditingController end})> _times = {};

  late final TextEditingController _onCallPhone;
  late final TextEditingController _onCallStart;
  late final TextEditingController _onCallEnd;
  late final TextEditingController _backupName;
  late final TextEditingController _backupLicense;
  late final TextEditingController _backupPhone;

  @override
  void initState() {
    super.initState();
    for (final d in _selectedDays) {
      _times[d] = (
        start: TextEditingController(text: '08:00 AM'),
        end: TextEditingController(text: '03:00 PM'),
      );
    }
    _onCallPhone = TextEditingController(text: '+971 50 123 4567');
    _onCallStart = TextEditingController(text: '03:00 PM');
    _onCallEnd = TextEditingController(text: '09:00 PM');
    _backupName = TextEditingController(text: 'Dr. Tariq Al-Mansoori');
    _backupLicense = TextEditingController(text: 'DHA MD-4982');
    _backupPhone = TextEditingController(text: '+971 55 987 6543');
  }

  @override
  void dispose() {
    for (final t in _times.values) {
      t.start.dispose();
      t.end.dispose();
    }
    _onCallPhone.dispose();
    _onCallStart.dispose();
    _onCallEnd.dispose();
    _backupName.dispose();
    _backupLicense.dispose();
    _backupPhone.dispose();
    super.dispose();
  }

  void _toast(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? SchooKeepColors.error : SchooKeepColors.physicianTeal,
      ),
    );
  }

  void _toggleDay(int idx) {
    setState(() {
      if (_selectedDays.contains(idx)) {
        _selectedDays.remove(idx);
      } else {
        _selectedDays.add(idx);
        _selectedDays.sort();
        _times.putIfAbsent(
          idx,
          () => (
            start: TextEditingController(text: '08:00 AM'),
            end: TextEditingController(text: '03:00 PM'),
          ),
        );
      }
    });
  }

  void _handleSave() {
    final isRTL = context.isRTL;
    if (_selectedDays.length < 3) {
      _toast(
        isRTL
            ? 'تنبيه هيئة الصحة: يجب تحديد 3 أيام دوام في الموقع كحد أدنى أسبوعياً.'
            : 'DHA Compliance Alert: A minimum of 3 on-site days per week is required.',
        error: true,
      );
      return;
    }
    if (!Validators.isValidUaePhone(_onCallPhone.text)) {
      _toast(isRTL ? 'رقم هاتف المناوبة غير صالح' : 'Invalid On-call phone format.', error: true);
      return;
    }
    if (_backupPhone.text.isNotEmpty && !Validators.isValidUaePhone(_backupPhone.text)) {
      _toast(isRTL ? 'رقم هاتف الطبيب البديل غير صالح' : 'Invalid Backup physician phone format.', error: true);
      return;
    }
    _toast(isRTL
        ? 'تم حفظ الجدول الزمني بنجاح والتحقق من الامتثال'
        : 'Schedule saved successfully! DHA compliance verified.');
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/physician/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    final daysShort = isRTL
        ? ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س']
        : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final daysLabels = isRTL
        ? ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت']
        : ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final daysCount = _selectedDays.length;
    final isDhaCompliant = daysCount >= 3;

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.go('/physician/dashboard'),
        centerTitle: true,
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isRTL ? 'جدول المواعيد والدوام' : 'My Schedule',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            Text(isRTL ? 'تكوين وضبط الحضور' : 'Configure Duty Settings',
                style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _daySelectorCard(isRTL, daysShort, daysCount, isDhaCompliant),
          const SizedBox(height: 20),
          if (_selectedDays.isNotEmpty) ...[
            _dailyHoursCard(isRTL, daysLabels),
            const SizedBox(height: 20),
          ],
          _onCallCard(isRTL),
          const SizedBox(height: 20),
          _backupCard(isRTL),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.physicianTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _handleSave,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.save, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(isRTL ? 'حفظ جدول الدوام والالتزام' : 'Save Duty Schedule',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _daySelectorCard(bool isRTL, List<String> daysShort, int daysCount, bool isDhaCompliant) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'أيام التواجد في العيادة (في الموقع)' : 'On-Site Clinic Days',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 2),
          Text(
            isRTL
                ? 'حدد الأيام التي ستتواجد فيها عيادياً داخل حرم المدرسة.'
                : 'Select the weekdays you are physically present in the school clinic.',
            style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var idx = 0; idx < daysShort.length; idx++)
                GestureDetector(
                  onTap: () => _toggleDay(idx),
                  child: Container(
                    width: 40,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedDays.contains(idx) ? SchooKeepColors.physicianTeal : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(daysShort[idx],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _selectedDays.contains(idx) ? Colors.white : SchooKeepColors.textSecondary,
                        )),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isRTL ? 'الأيام المحددة:' : 'Selected Days:',
                  style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDhaCompliant ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: isDhaCompliant ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isDhaCompliant ? LucideIcons.check : LucideIcons.alertCircle,
                        size: 14, color: isDhaCompliant ? const Color(0xFF047857) : const Color(0xFFB45309)),
                    const SizedBox(width: 4),
                    Text(
                      isRTL ? '$daysCount من 7 أيام دوام' : '$daysCount of 7 selected',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDhaCompliant ? const Color(0xFF047857) : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SchooKeepColors.amberBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              isRTL
                  ? '⚠ تشترط هيئة الصحة بدبي (DHA) وجود طبيب المدرسة في الموقع 3 أيام أسبوعياً كحد أدنى.'
                  : 'DHA Compliance: School physicians must configure a minimum of 3 on-site days weekly.',
              style: const TextStyle(fontSize: 11, color: Color(0xFFB45309), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dailyHoursCard(bool isRTL, List<String> daysLabels) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'ساعات دوام العيادة اليومي' : 'Daily Clinic Work Hours',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          for (var i = 0; i < _selectedDays.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFF8FAFC)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(daysLabels[_selectedDays[i]],
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                  ),
                  Expanded(child: _timeField(_times[_selectedDays[i]]!.start)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(isRTL ? 'إلى' : 'to',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
                  ),
                  Expanded(child: _timeField(_times[_selectedDays[i]]!.end)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeField(TextEditingController controller) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: SchooKeepColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: SchooKeepColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: SchooKeepColors.physicianTeal),
          ),
        ),
      ),
    );
  }

  Widget _onCallCard(bool isRTL) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'ساعات التغطية تحت الطلب (الطوارئ)' : 'Emergency On-Call Details',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 16),
          _fieldLabel(isRTL ? 'رقم هاتف الطوارئ تحت الطلب' : 'On-Call Contact Phone'),
          const SizedBox(height: 4),
          SizedBox(
            height: 44,
            child: TextField(
              controller: _onCallPhone,
              onChanged: (v) {
                final formatted = Validators.formatUaePhone(v);
                _onCallPhone.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              },
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(LucideIcons.phone, size: 16, color: SchooKeepColors.textSecondary),
                prefixIconConstraints: const BoxConstraints(minWidth: 36),
                filled: true,
                fillColor: SchooKeepColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: SchooKeepColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: SchooKeepColors.physicianTeal),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _labeledField(isRTL ? 'بدء التغطية' : 'Start Time', _onCallStart)),
              const SizedBox(width: 12),
              Expanded(child: _labeledField(isRTL ? 'نهاية التغطية' : 'End Time', _onCallEnd)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SchooKeepColors.amberBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.info, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isRTL
                        ? 'يجب الرد على جميع تصعيدات الحالات الحرجة خلال 10 دقائق بموجب شروط الترخيص ولا يمكن تعديل هذه الاتفاقية.'
                        : 'Critical Response SLA: Must respond to clinical dispatches within 10 minutes (Locked DHA requirement).',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFB45309), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backupCard(bool isRTL) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'الطبيب البديل (لتغطية الإجازات)' : 'Backup Coverage Physician',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 16),
          _labeledField(isRTL ? 'اسم الطبيب البديل' : 'Physician Name', _backupName),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _labeledField(isRTL ? 'رقم الترخيص الطبي' : 'License Number', _backupLicense)),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledField(
                  isRTL ? 'رقم الهاتف البديل' : 'Backup Phone',
                  _backupPhone,
                  onChanged: (v) {
                    final formatted = Validators.formatUaePhone(v);
                    _backupPhone.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) =>
      Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary));

  Widget _labeledField(String label, TextEditingController controller, {ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: SchooKeepColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.physicianTeal),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
