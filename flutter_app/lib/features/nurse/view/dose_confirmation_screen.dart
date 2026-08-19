import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/medication_repository.dart';

class DoseConfirmationScreen extends StatefulWidget {
  const DoseConfirmationScreen({super.key, this.medicationId, this.studentId});

  final int? medicationId;
  final int? studentId;

  @override
  State<DoseConfirmationScreen> createState() => _DoseConfirmationScreenState();
}

class _DoseConfirmationScreenState extends State<DoseConfirmationScreen> {
  bool _showSuccess = false;
  bool _submitting = false;
  String _currentTime = '10:48 AM';
  static const int _minutesUntil = 12;
  String _confirmationTime = '';
  Timer? _timer;

  final MedicationRepository _repo = sl<MedicationRepository>();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = _formatTime(DateTime.now()));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime now, {bool withSeconds = false}) {
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour < 12 ? 'AM' : 'PM';
    final hh = hour12.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    if (withSeconds) {
      final ss = now.second.toString().padLeft(2, '0');
      return '$hh:$mm:$ss $period';
    }
    return '$hh:$mm $period';
  }

  void _handleAdminister() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => _confirmDialog(dialogContext),
    );
  }

  void _handleDelay() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SchooKeepColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        const options = [15, 30, 60];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Text(
                  context.tr(en: 'Delay dose', ar: 'تأجيل موعد الجرعة'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  context.tr(en: 'Reschedule this dose by:', ar: 'إعادة جدولة الجرعة بمقدار:'),
                  style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                ),
              ),
              for (final minutes in options)
                ListTile(
                  leading: const Icon(LucideIcons.clock, size: 20, color: SchooKeepColors.primary),
                  title: Text(
                    context.tr(en: '$minutes minutes', ar: '$minutes دقيقة'),
                    style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDelay(minutes);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelay(int minutes) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr(en: 'Dose delayed by $minutes minutes', ar: 'تم تأجيل الجرعة بمقدار $minutes دقيقة'))),
    );
    context.go('/nurse/medications');
  }

  Future<void> _handleConfirm() async {
    final timestamp = _formatTime(DateTime.now(), withSeconds: true);
    final medId = widget.medicationId;
    final studentId = widget.studentId;

    if (medId != null && studentId != null) {
      setState(() => _submitting = true);
      try {
        await _repo.logDose(medicationId: medId, studentId: studentId, status: 'given');
      } catch (e) {
        if (!mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(MedicationRepository.messageFor(e)), backgroundColor: SchooKeepColors.error),
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _confirmationTime = timestamp;
      _showSuccess = true;
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/nurse/medications');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _successScreen(context);
    }

    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        titleWidget: Text(
          context.tr(en: 'Medication Due', ar: 'موعد إعطاء الدواء المستحق'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.error),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _studentCard(context),
            const SizedBox(height: 16),
            _medicationCard(context),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SchooKeepColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitting ? null : _handleAdminister,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.checkCircle, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(en: 'Mark as Administered', ar: 'تأكيد إعطاء الجرعة للطفل'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: _submitting ? null : _handleDelay,
                child: Text(
                  context.tr(en: 'Delay dose', ar: 'تأجيل موعد الجرعة'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentCard(BuildContext context) {
    return SchooKeepCard(
      onTap: () => context.go('/nurse/students/maya-chen'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: SchooKeepColors.primary, shape: BoxShape.circle),
            child: const Text('MC',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Maya Chen',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                Text(
                  context.tr(en: 'Grade 5 · Room 204', ar: 'الصف الخامس · قاعة 204'),
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Methylphenidate 10mg',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          Text(
            context.tr(en: 'Scheduled Time', ar: 'الوقت المحدد للجرعة'),
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 4),
          const Text('11:00 AM',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 16, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                context.tr(en: 'Current time: $_currentTime', ar: 'الوقت الحالي: $_currentTime'),
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: SchooKeepColors.amberChipBg, borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.amberText),
                const SizedBox(width: 6),
                Text(
                  context.tr(
                    en: '$_minutesUntil minutes until scheduled dose',
                    ar: 'متبقي $_minutesUntil دقيقة على موعد الجرعة',
                  ),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.amberText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: SchooKeepColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'Dose 2 of 3 today', ar: 'الجرعة 2 من أصل 3 اليوم'),
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(en: '14 doses remaining', ar: 'متبقي 14 جرعة في العلبة'),
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: SchooKeepColors.background, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr(
                      en: 'Physician order by Dr. Rodriguez on file ✓',
                      ar: 'أمر الطبيب د. رودريغيز موثق في السجل الطبي ✓',
                    ),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmDialog(BuildContext dialogContext) {
    return Dialog(
      backgroundColor: SchooKeepColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: SchooKeepColors.amberChipBg, shape: BoxShape.circle),
                child: const Icon(LucideIcons.alertTriangle, size: 24, color: SchooKeepColors.warning),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr(en: 'Confirm Administration', ar: 'تأكيد إعطاء الدواء'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  en: 'This action is irreversible. Confirm administration of Methylphenidate 10mg to Maya Chen at $_currentTime?',
                  ar: 'هذا الإجراء نهائي وسوف يُسجل في الملف الطبي. هل تؤكد إعطاء دواء ميثيلفينيدات 10 ملغ للطالبة مايا تشن في تمام الساعة $_currentTime؟',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: SchooKeepColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _handleConfirm();
                  },
                  child: Text(
                    context.tr(en: 'Confirm', ar: 'تأكيد'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: SchooKeepColors.surface,
                    side: const BorderSide(color: SchooKeepColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    context.tr(en: 'Cancel', ar: 'إلغاء'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _successScreen(BuildContext context) {
    return ColoredBox(
      color: SchooKeepColors.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: SchooKeepColors.accent, shape: BoxShape.circle),
                child: const Icon(LucideIcons.checkCircle, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                context.tr(en: 'Dose Administered', ar: 'تم تسجيل الجرعة بنجاح'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(en: 'Recorded at $_confirmationTime', ar: 'سُجل في تمام الساعة $_confirmationTime'),
                style: const TextStyle(fontSize: 16, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: SchooKeepColors.background, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.lock, size: 20, color: SchooKeepColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(en: 'Record permanently locked', ar: 'السجل الطبي مقفل وغير قابل للتعديل ✓'),
                      style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
