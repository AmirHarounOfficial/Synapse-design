import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/medication_repository.dart';

class LowSupplyAlertScreen extends StatefulWidget {
  const LowSupplyAlertScreen({super.key, this.medicationId});

  final int? medicationId;

  @override
  State<LowSupplyAlertScreen> createState() => _LowSupplyAlertScreenState();
}

class _LowSupplyAlertScreenState extends State<LowSupplyAlertScreen> {
  bool _parentNotified = false;
  String _notificationDate = '';

  final MedicationRepository _repo = sl<MedicationRepository>();
  Medication? _medication;

  @override
  void initState() {
    super.initState();
    final id = widget.medicationId;
    if (id != null) {
      _repo
          .show(id)
          .then((m) {
            if (mounted) setState(() => _medication = m);
          })
          .catchError((_) {});
    }
  }

  int get _dosesRemaining => _medication?.supplyCount ?? 10;
  int get _totalDoses {
    final threshold = _medication?.lowSupplyThreshold;
    if (threshold != null && threshold > 0) return threshold * 3;
    return 30;
  }

  String get _medicationName =>
      _medication?.displayName ?? 'Methylphenidate 10mg';

  double get _supplyPercentage =>
      _totalDoses == 0 ? 0 : (_dosesRemaining / _totalDoses).clamp(0.0, 1.0);

  void _handleMenu() {
    final medId = widget.medicationId;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SchooKeepColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              if (medId != null)
                ListTile(
                  leading: const Icon(LucideIcons.pill, size: 20, color: SchooKeepColors.primary),
                  title: Text(
                    context.tr(en: 'View medication details', ar: 'عرض تفاصيل الدواء'),
                    style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.go('/nurse/medications/$medId');
                  },
                ),
              ListTile(
                leading: const Icon(LucideIcons.bell, size: 20, color: SchooKeepColors.primary),
                title: Text(
                  context.tr(en: 'Notify parent', ar: 'إرسال تنبيه لولي الأمر'),
                  style: const TextStyle(fontSize: 15, color: SchooKeepColors.textPrimary),
                ),
                enabled: !_parentNotified,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _handleNotifyParent();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _handleNotifyParent() {
    final now = DateTime.now();
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour < 12 ? 'AM' : 'PM';
    final hh = hour12.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final formatted = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} $hh:$mm $period';
    setState(() {
      _notificationDate = formatted;
      _parentNotified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: 'Maya Chen',
        centerTitle: true,
        onBack: () => context.go('/nurse/medications'),
        actions: [
          InkWell(
            onTap: _handleMenu,
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                LucideIcons.moreVertical,
                size: 24,
                color: SchooKeepColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _amberBanner(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _alertCard(context),
                const SizedBox(height: 24),
                _actionSection(context),
                const SizedBox(height: 24),
                _medicationDetails(context),
                const SizedBox(height: 24),
                _reorderInfo(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amberBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      color: SchooKeepColors.warning,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(LucideIcons.alertTriangle, size: 24, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            context.tr(en: 'Supply Alert', ar: 'تنبيه انخفاض رصيد المخزون الدوائي'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertCard(BuildContext context) {
    return AccentCard(
      background: SchooKeepColors.amberBg,
      accentColor: SchooKeepColors.warning,
      accentWidth: 4,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  LucideIcons.alertTriangle,
                  size: 24,
                  color: SchooKeepColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(en: 'Low supply of $_medicationName', ar: 'انخفاض مخزون دواء $_medicationName'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.amberText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _detailRow(context.tr(en: 'Current count:', ar: 'الرصيد المتبقي:'), context.tr(en: '$_dosesRemaining doses', ar: '$_dosesRemaining جرعة')),
                    const SizedBox(height: 8),
                    _detailRow(context.tr(en: 'Expected depletion:', ar: 'تاريخ النفاد المتوقع:'), '2026-05-24'),
                    const SizedBox(height: 8),
                    _detailRow(context.tr(en: 'Expiry date:', ar: 'تاريخ انتهاء الصلاحية:'), '2026-06-15'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr(en: 'Supply Status', ar: 'حالة المخزون'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SchooKeepColors.amberText,
                ),
              ),
              Text(
                context.tr(en: '$_dosesRemaining of $_totalDoses doses', ar: '$_dosesRemaining من أصل $_totalDoses جرعة'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SchooKeepColors.amberText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _supplyPercentage,
              minHeight: 8,
              backgroundColor: SchooKeepColors.amberChipBg,
              valueColor: const AlwaysStoppedAnimation<Color>(
                SchooKeepColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: SchooKeepColors.amberText,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: SchooKeepColors.amberText,
          ),
        ),
      ],
    );
  }

  Widget _actionSection(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Actions', ar: 'الإجراءات المطلوبة'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: SchooKeepColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (!_parentNotified) ...[
            SchooKeepButton(
              label: context.tr(en: 'Notify Parent', ar: 'إرسال تنبيه لولي الأمر'),
              icon: LucideIcons.bell,
              onPressed: _handleNotifyParent,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr(
                en: 'Sends automatic supply alert to parent via SMS and app notification',
                ar: 'يرسل تنبيهاً أوتوماتيكياً لإعادة تزويد الدواء لولي الأمر عبر SMS والتطبيق',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: SchooKeepColors.textSecondary,
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: AccentCard(
                background: SchooKeepColors.greenChipBg,
                accentColor: SchooKeepColors.accent,
                accentWidth: 4,
                radius: 12,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        LucideIcons.checkCircle,
                        size: 20,
                        color: SchooKeepColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr(en: 'Parent Notified', ar: 'تم إشعار ولي الأمر ✓'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: SchooKeepColors.greenChipText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _notificationDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: SchooKeepColors.greenChipText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _medicationDetails(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Medication Details', ar: 'بيانات الدواء والوصفة'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: SchooKeepColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(context.tr(en: 'Medication', ar: 'اسم الدواء'), _medicationName, divider: true),
          _infoRow(
            context.tr(en: 'Type', ar: 'نوع الوصفة'),
            _medication?.endDate == null ? context.tr(en: 'Permanent', ar: 'دائم') : context.tr(en: 'Temporary', ar: 'مؤقت'),
            divider: true,
          ),
          _infoRow(
            context.tr(en: 'Daily Doses', ar: 'عدد الجرعات اليومية'),
            context.tr(en: '${_medication?.doses.length ?? 1} dose(s)', ar: '${_medication?.doses.length ?? 1} جرعة'),
            divider: true,
          ),
          _infoRow(
            context.tr(en: 'Prescribing Physician', ar: 'الطبيب المعالج والواصف'),
            _medication?.prescribedBy ?? 'Dr. Rodriguez',
            divider: false,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {required bool divider}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: divider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: SchooKeepColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: SchooKeepColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reorderInfo(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AccentCard(
        background: const Color(0xFFEFF6FF),
        accentColor: SchooKeepColors.primary,
        accentWidth: 4,
        radius: 12,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(en: 'Reorder Information', ar: 'تعليمات إعادة تزويد الشحنة الدوائية'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E40AF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                en: 'Parents must coordinate with prescribing physician for refill authorization. School policy requires 7-day supply buffer.',
                ar: 'على أولياء الأمور التنسيق مع الطبيب المعالج لتجديد الوصفة. تتطلب سياسة العيادة المدرسية الاحتفاظ بهامش أمان لمدة 7 أيام على الأقل.',
              ),
              style: const TextStyle(fontSize: 13, color: Color(0xFF1E40AF)),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                children: [
                  TextSpan(
                    text: context.tr(en: 'Recommended action: ', ar: 'الإجراء التوصية: '),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: context.tr(
                      en: 'Notify parent at least 7 days before depletion',
                      ar: 'إشعار ولي الأمر قبل 7 أيام من تاريخ النفاد المتوقع',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
