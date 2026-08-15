import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class _Escalation {
  _Escalation({
    required this.id,
    required this.studentName,
    required this.severity,
    required this.nurseDescription,
    required this.timeElapsedMinutes,
    this.photoUrl,
  });

  final String id;
  final String studentName;
  final String severity; // 'Moderate' | 'Severe' | 'Critical'
  final String nurseDescription;
  final int timeElapsedMinutes;
  final String? photoUrl;
}

class _Resolved {
  _Resolved({required this.id, required this.studentName, required this.action, required this.time});
  final String id;
  final String studentName;
  final String action;
  final String time;
}

/// Ported from `ClinicalEscalationInbox.tsx`. On-call SLA banner, active
/// escalation cards with triage actions (authorize transport / first aid / advise
/// parent call), a confirmation modal, and a collapsible "Resolved Today" list.
class ClinicalEscalationInboxScreen extends StatefulWidget {
  const ClinicalEscalationInboxScreen({super.key});

  @override
  State<ClinicalEscalationInboxScreen> createState() => _ClinicalEscalationInboxScreenState();
}

class _ClinicalEscalationInboxScreenState extends State<ClinicalEscalationInboxScreen> {
  static const bool _isOnCall = true;
  bool _showResolved = false;

  final List<_Escalation> _escalations = [
    _Escalation(
      id: '1',
      studentName: 'Sarah Williams',
      severity: 'Critical',
      nurseDescription:
          'Student is experiencing a severe allergic reaction (anaphylaxis) following recess. Epinephrine administered at 10:14 AM. Breathing is shallow, wheezing continues.',
      timeElapsedMinutes: 9,
      photoUrl: 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?auto=format&fit=crop&q=80&w=200',
    ),
    _Escalation(
      id: '2',
      studentName: 'Ethan Williams',
      severity: 'Moderate',
      nurseDescription:
          'Suspected fracture of left wrist after falling off playground structures. High swelling, pain level 7/10. Wrist splinted.',
      timeElapsedMinutes: 5,
      photoUrl: 'https://images.unsplash.com/photo-1579684389782-64d84b5e901a?auto=format&fit=crop&q=80&w=200',
    ),
  ];

  final List<_Resolved> _resolvedToday = [
    _Resolved(id: '10', studentName: 'Maya Chen', action: 'Authorized first aid at clinic', time: '09:12 AM'),
  ];

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: SchooKeepColors.physicianTeal),
    );
  }

  String _nowTime() {
    final now = DateTime.now();
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour < 12 ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
  }

  void _handleAction(String studentName, String descEn, String descAr) {
    final isRTL = context.isRTL;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
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
                Text(isRTL ? 'تأكيد تصريح الطوارئ' : 'Authorize Emergency Action',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.error)),
                const SizedBox(height: 4),
                Text(
                  isRTL
                      ? 'أنت تصرح بـ: [$descAr] للطالب $studentName'
                      : 'You are authorizing: [$descEn] for $studentName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  isRTL
                      ? 'سيتم تسجيل هذا الإجراء بشكل دائم وغير قابل للتعديل بموجب ترخيص DHA الخاص بك.'
                      : 'This action is logged permanently under your DHA MD-4029 license.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: SchooKeepColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(isRTL ? 'إلغاء' : 'Cancel',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: SchooKeepColors.error,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            _confirmAction(studentName, descEn, descAr);
                          },
                          child: Text(isRTL ? 'تصريح واعتماد' : 'Authorize',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmAction(String studentName, String descEn, String descAr) {
    final isRTL = context.isRTL;
    _toast(isRTL ? 'تم التصريح بـ: $descAr' : 'Authorized: $descEn');
    setState(() {
      _escalations.removeWhere((e) => e.studentName == studentName);
      _resolvedToday.insert(
        0,
        _Resolved(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          studentName: studentName,
          action: descEn,
          time: _nowTime(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        onBack: () => context.go('/physician/dashboard'),
        centerTitle: true,
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.shieldAlert, size: 20, color: SchooKeepColors.error),
            const SizedBox(width: 6),
            Text(isRTL ? 'التصعيدات الطبية' : 'Escalations',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(999)),
              child: Text('${_escalations.length}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.error)),
            ),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isOnCall) ...[
            _onCallBanner(isRTL),
            const SizedBox(height: 16),
          ],
          if (_escalations.isEmpty)
            _allClearCard(isRTL)
          else
            for (final esc in _escalations) ...[
              _escalationCard(isRTL, esc),
              const SizedBox(height: 16),
            ],
          _resolvedSection(isRTL),
        ],
      ),
    );
  }

  Widget _onCallBanner(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SchooKeepColors.amberBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.clock, size: 20, color: Color(0xFFD97706)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isRTL ? 'تنبيه: أنت في وضع الاستعداد خارج المدرسة' : 'Attention: You are currently on-call',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.amberText)),
                const SizedBox(height: 2),
                Text(
                  isRTL
                      ? 'بموجب شروط هيئة الصحة (DHA)، يرجى الاستجابة للتصعيدات الطبية الطارئة خلال 10 دقائق.'
                      : 'DHA mandate requires responding to emergency escalations within 10 minutes SLA.',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFB45309), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _escalationCard(bool isRTL, _Escalation esc) {
    final isOverTime = esc.timeElapsedMinutes >= 8;
    final isCritical = esc.severity == 'Critical';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SchooKeepColors.error, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(esc.studentName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCritical ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isCritical
                            ? (isRTL ? 'حالة حرجة جداً' : 'CRITICAL')
                            : (isRTL ? 'حالة متوسطة' : 'MODERATE'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCritical ? SchooKeepColors.error : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverTime ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isOverTime ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.clock, size: 14, color: isOverTime ? SchooKeepColors.error : SchooKeepColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${esc.timeElapsedMinutes} ${isRTL ? 'دقائق' : 'min ago'}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOverTime ? SchooKeepColors.error : SchooKeepColors.textSecondary,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Text(esc.nurseDescription,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151), height: 1.5)),
          ),
          if (esc.photoUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 140,
                    color: const Color(0xFFF1F5F9),
                    child: Image.network(
                      esc.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(LucideIcons.image, size: 32, color: SchooKeepColors.textSecondary),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 8,
                    start: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(4)),
                      child: Text(isRTL ? 'معاينة الصورة المرفقة' : 'Clinical Image Attachment',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _handleAction(
                esc.studentName,
                'Emergency Ambulance Transport (998)',
                'نقل إسعاف طوارئ (998)',
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.truck, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(isRTL ? 'ترخيص النقل بالإسعاف (998)' : 'Authorize Emergency Transport',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: SchooKeepColors.surface,
                      side: const BorderSide(color: Color(0xFFD97706)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handleAction(
                      esc.studentName,
                      'First Aid Treatment at Clinic',
                      'إسعافات أولية في عيادة المدرسة',
                    ),
                    child: Text(isRTL ? 'ترخيص إسعافات بالعيادة' : 'Authorize First Aid',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: SchooKeepColors.surface,
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _toast(isRTL ? 'تم إرسال طلب تواصل للممرضة مع الوالدين' : 'Nurse advised to contact parent first.');
                      setState(() => _escalations.removeWhere((e) => e.studentName == esc.studentName));
                    },
                    child: Text(isRTL ? 'الاتصال بالوالدين أولاً' : 'Advise Parent Call First',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _allClearCard(bool isRTL) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
            child: const Icon(LucideIcons.checkCircle, size: 24, color: Color(0xFF059669)),
          ),
          const SizedBox(height: 8),
          Text(isRTL ? 'لوحة تحكم خالية' : 'All Clear',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            isRTL ? 'لا توجد أي تصعيدات نشطة حالياً. تم معالجة كافة الحالات.' : 'No active medical escalations. All cases resolved.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _resolvedSection(bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showResolved = !_showResolved),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isRTL ? 'تم حلها اليوم' : 'RESOLVED TODAY',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary, letterSpacing: 0.8)),
                Icon(_showResolved ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: SchooKeepColors.textSecondary),
              ],
            ),
          ),
        ),
        if (_showResolved) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: SchooKeepColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: _resolvedToday.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(isRTL ? 'لم يتم حل أي حالات بعد' : 'No resolved cases today.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < _resolvedToday.length; i++) ...[
                        if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_resolvedToday[i].studentName,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                                    Text(_resolvedToday[i].action,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                                  ],
                                ),
                              ),
                              Text(_resolvedToday[i].time,
                                  style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ],
    );
  }
}
