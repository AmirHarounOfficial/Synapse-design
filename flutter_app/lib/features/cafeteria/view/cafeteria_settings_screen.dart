import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/halal_certification.dart';
import '../../../data/repositories/cafeteria_repository.dart';
import '../cubit/halal_certification_cubit.dart';

/// Ported from `CafeteriaSettings.tsx`, now wired to the API for the Halal
/// Compliance section: the certification status chip and certificate modal are
/// driven by `GET /halal-certifications`. Profile header plus Notifications, Halal
/// Compliance, My Shift, Data & Privacy, and About sections — including locked
/// toggles, time/shift pickers, info sheets, a Halal certificate modal, and a
/// sign-out confirmation dialog. The "daily Halal acknowledgment" stays a locked
/// toggle — the backend has no per-user daily-ack endpoint.
class CafeteriaSettingsScreen extends StatelessWidget {
  const CafeteriaSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HalalCertificationCubit(sl<CafeteriaRepository>()),
      child: const _CafeteriaSettingsView(),
    );
  }
}

class _CafeteriaSettingsView extends StatefulWidget {
  const _CafeteriaSettingsView();

  @override
  State<_CafeteriaSettingsView> createState() => _CafeteriaSettingsViewState();
}

class _CafeteriaSettingsViewState extends State<_CafeteriaSettingsView> {
  bool _dailyReminder = true;
  String _reminderTime = '07:15 AM';
  bool _soundAlerts = true;
  String _shiftTime = '07:00 AM — 3:00 PM';
  bool _halalReminder = true;

  void _handleSignOut() {
    Navigator.of(context).pop(); // close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr(en: 'Signed out successfully.', ar: 'تم تسجيل الخروج بنجاح'))),
    );
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(centerTitle: true, title: isRTL ? 'الإعدادات' : 'Settings'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCard(isRTL),
            _divider(),
            _sectionLabel(isRTL ? 'تنبيهات الإشعارات' : 'NOTIFICATIONS'),
            _notificationsCard(isRTL),
            _divider(),
            _sectionLabel(isRTL ? 'الامتثال لمتطلبات الحلال' : 'Halal Compliance'),
            BlocBuilder<HalalCertificationCubit, DataState<List<HalalCertification>>>(
              builder: (context, state) {
                final cert = switch (state) {
                  DataLoaded(:final data) => data.isNotEmpty ? data.first : null,
                  _ => null,
                };
                return _halalCard(isRTL, cert);
              },
            ),
            _divider(),
            _sectionLabel(isRTL ? 'ساعات المناوبة' : 'MY SHIFT'),
            _shiftCard(isRTL),
            _divider(),
            _sectionLabel(isRTL ? 'البيانات والخصوصية' : 'DATA & PRIVACY'),
            _dataCard(isRTL),
            _divider(),
            _sectionLabel(isRTL ? 'حول التطبيق' : 'ABOUT'),
            _aboutCard(isRTL),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: SchooKeepColors.surface,
                  side: const BorderSide(color: SchooKeepColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _showSignOutDialog,
                child: Text(isRTL ? 'تسجيل الخروج' : 'Sign out',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(height: 1, color: SchooKeepColors.border),
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
      );

  Widget _profileCard(bool isRTL) {
    return SchooKeepCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('AM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SchooKeepColors.halalGreen)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Alex Martinez',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Text(isRTL ? 'موظف الكافتيريا' : 'Cafeteria Staff',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.halalGreen)),
                ),
                const SizedBox(height: 8),
                const Text('Lincoln Elementary School',
                    style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardShell(List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) children.add(const Divider(height: 1, color: Color(0xFFF1F5F9)));
    }
    return Container(
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _notificationsCard(bool isRTL) {
    return _cardShell([
      _toggleRow(
        icon: LucideIcons.bell,
        title: isRTL ? 'تنبيهات الحساسية الجديدة' : 'New allergen alerts',
        subtitle: isRTL ? 'إشعارات فورية عند إضافة أو تعديل قيود الطعام للطالب' : 'Real-time alerts when a restriction is added or updated',
        value: true,
        locked: true,
        onLockedTap: () => _showLockedSheet(isRTL, isHalal: false),
      ),
      _toggleRow(
        icon: LucideIcons.bell,
        title: isRTL ? 'تذكير القائمة اليومية' : 'Daily allergen list reminder',
        subtitle: isRTL ? 'تذكير لتأكيد مراجعة القائمة قبل تقديم الوجبات' : "Reminder to acknowledge today's list at meal service start",
        value: _dailyReminder,
        onChanged: (v) => setState(() => _dailyReminder = v),
      ),
      if (_dailyReminder)
        _navRow(
          icon: LucideIcons.calendar,
          title: isRTL ? 'وقت التذكير اليومي' : 'Reminder time',
          trailing: Text(_reminderTime,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
          onTap: () => _showTimeSheet(isRTL),
        ),
      _toggleRow(
        icon: LucideIcons.volume2,
        title: isRTL ? 'التنبيهات الصوتية للقيود الجديدة' : 'Sound alerts for new restrictions',
        subtitle: isRTL ? 'تشغيل تنبيه صوتي عند ظهور نافذة التنبيه الفوري' : 'Audible alert when C-03 real-time modal appears',
        value: _soundAlerts,
        onChanged: (v) => setState(() => _soundAlerts = v),
      ),
    ]);
  }

  Widget _halalCard(bool isRTL, HalalCertification? cert) {
    final exp = cert?.expiryDate;
    final chipLabel = exp == null
        ? (isRTL ? 'معتمد' : 'Certified')
        : (isRTL ? 'معتمد · $exp' : 'Certified · Exp: $exp');
    return _cardShell([
      _navRow(
        icon: LucideIcons.award,
        iconColor: const Color(0xFF059669),
        title: isRTL ? 'شهادة الحلال المعتمدة' : 'Halal Certification Status',
        subtitle: isRTL ? 'الترخيص نشط وصالح للتقديم الغذائي للمدارس' : 'Official compliance certificate details',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: SchooKeepColors.greenChipBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Text(chipLabel,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.greenChipText)),
            ),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronRight, size: 16, color: SchooKeepColors.textSecondary),
          ],
        ),
        onTap: () => _showHalalCertificate(isRTL, cert),
      ),
      _toggleRow(
        icon: LucideIcons.check,
        title: isRTL ? 'الإقرار اليومي لشهادة الحلال' : 'Daily Halal acknowledgment',
        subtitle: isRTL ? 'تأكيد مطابقة وجبات اليوم بالكامل للشريعة الإسلامية' : 'Cafeteria staff must confirm Halal compliance daily',
        value: true,
        locked: true,
        onLockedTap: () => _showLockedSheet(isRTL, isHalal: true),
      ),
      _toggleRow(
        icon: LucideIcons.bell,
        title: isRTL ? 'تنبيه انتهاء الشهادة' : 'Certification renewal reminder',
        subtitle: isRTL ? 'إرسال تنبيه قبل 30 يوماً من انتهاء الشهادة' : 'Remind 30 days before certificate expiry',
        value: _halalReminder,
        onChanged: (v) => setState(() => _halalReminder = v),
      ),
    ]);
  }

  Widget _shiftCard(bool isRTL) {
    return _cardShell([
      _navRow(
        icon: LucideIcons.clock,
        title: isRTL ? 'بداية ونهاية المناوبة' : 'Shift start / end',
        subtitle: isRTL ? 'إرسال الإشعارات إليك خلال ساعات عملك الفعلي فقط' : 'Notifications only sent during your shift window',
        trailing: Text(_shiftTime,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
        onTap: () => _showShiftSheet(isRTL),
      ),
    ]);
  }

  Widget _dataCard(bool isRTL) {
    return _cardShell([
      _navRow(
        icon: LucideIcons.fileText,
        title: isRTL ? 'اتفاقية السرية وحماية البيانات' : 'Confidentiality agreement',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isRTL ? 'موقعة في 01/05/2026' : 'Signed May 1, 2026',
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
            const SizedBox(width: 8),
            const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
          ],
        ),
        onTap: () => _showConfidentialitySheet(isRTL),
      ),
      _navRow(
        icon: LucideIcons.shield,
        title: isRTL ? 'مستوى الوصول للبيانات' : 'My data access level',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Text(isRTL ? 'قيود الكافتيريا فقط' : 'Allergens only',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.accent)),
            ),
            const SizedBox(width: 8),
            const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
          ],
        ),
        onTap: () => _showDataAccessSheet(isRTL),
      ),
    ]);
  }

  Widget _aboutCard(bool isRTL) {
    return _cardShell([
      _navRow(
        icon: LucideIcons.info,
        title: isRTL ? 'إصدار التطبيق' : 'App version',
        trailing: const Text('SchooKeep v1.0.0', style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
      ),
      _navRow(
        icon: LucideIcons.headphones,
        title: isRTL ? 'الاتصال بالدعم الفني' : 'Contact support',
        trailing: const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
        onTap: () => _showContactSupportSheet(isRTL),
      ),
    ]);
  }

  Widget _toggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
    bool locked = false,
    VoidCallback? onLockedTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (locked)
            InkWell(
              onTap: onLockedTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
                  const SizedBox(width: 8),
                  _toggleVisual(true),
                ],
              ),
            )
          else
            InkWell(onTap: () => onChanged?.call(!value), child: _toggleVisual(value)),
        ],
      ),
    );
  }

  Widget _toggleVisual(bool on) {
    return Container(
      width: 48,
      height: 28,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: on ? SchooKeepColors.accent : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 150),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _navRow({
    required IconData icon,
    Color iconColor = SchooKeepColors.textSecondary,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.4)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }

  // --- Bottom sheets & dialogs --------------------------------------------

  Future<void> _showSheet({required String title, required List<Widget> children}) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SheetContainer(title: title, children: children),
    );
  }

  void _showLockedSheet(bool isRTL, {required bool isHalal}) {
    _showSheet(
      title: isHalal
          ? (isRTL ? 'إجراء تأكيد إلزامي' : 'Mandatory Requirement')
          : (isRTL ? 'إشعار تنبيه إلزامي' : 'Required Notification'),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(LucideIcons.lock, size: 24, color: SchooKeepColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isHalal
                    ? (isRTL
                        ? 'لا يمكن إلغاء الإقرار اليومي بالحلال. يجب على جميع موظفي الكافتيريا تأكيد الامتثال قبل بدء خدمة تقديم الطعام.'
                        : 'The daily Halal acknowledgment cannot be disabled. All cafeteria staff must confirm Halal compliance before meal service.')
                    : (isRTL
                        ? 'لا يمكن إيقاف تنبيهات الحساسية الممنوعة للطلاب لضمان سلامتهم الغذائية التامة بالمدرسة.'
                        : 'This alert cannot be disabled. Cafeteria staff must receive all allergen updates for student safety.'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary, height: 1.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sheetTealButton(isRTL ? (isHalal ? 'حسناً، مفهوم' : 'مفهوم') : 'Understood'),
      ],
    );
  }

  void _showTimeSheet(bool isRTL) {
    const times = ['06:30 AM', '07:00 AM', '07:15 AM', '07:30 AM', '08:00 AM'];
    _showSheet(
      title: isRTL ? 'تحديد وقت التنبيه' : 'Set Reminder Time',
      children: [
        Text(
          isRTL
              ? 'اختر الوقت الذي تفضله لتلقي التذكير اليومي للقيود الغذائية.'
              : "Choose when you'd like to receive your daily allergen list reminder.",
          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
        ),
        const SizedBox(height: 12),
        for (final t in times) ...[
          _selectableOption(t, selected: _reminderTime == t, onTap: () {
            setState(() => _reminderTime = t);
            Navigator.of(context).pop();
          }),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  void _showShiftSheet(bool isRTL) {
    const times = ['06:00 AM — 2:00 PM', '07:00 AM — 3:00 PM', '08:00 AM — 4:00 PM', '09:00 AM — 5:00 PM'];
    _showSheet(
      title: isRTL ? 'تحديد ساعات المناوبة' : 'Set Shift Hours',
      children: [
        Text(
          isRTL
              ? 'حدد ساعات عملك لتلقي التنبيهات خلال هذه الفترة فقط.'
              : 'Set your shift hours so you only receive notifications during your work time.',
          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
        ),
        const SizedBox(height: 12),
        for (final t in times) ...[
          _selectableOption(t, selected: _shiftTime == t, onTap: () {
            setState(() => _shiftTime = t);
            Navigator.of(context).pop();
          }),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  void _showConfidentialitySheet(bool isRTL) {
    _showSheet(
      title: isRTL ? 'اتفاقية حماية سرية البيانات' : 'Confidentiality Agreement',
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SchooKeepColors.accent),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.lock, size: 20, color: SchooKeepColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRTL ? 'موقعة ونشطة' : 'Signed and Active',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.greenChipText)),
                    const SizedBox(height: 4),
                    Text(isRTL ? 'وقعت في 1 مايو 2026 الساعة 9:15 ص' : 'Signed on May 1, 2026 at 9:15 AM',
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.accent)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isRTL
              ? 'اتفاقية سرية معلومات صحة الطلاب (قانون حماية البيانات الشخصية PDPL)'
              : 'Student Health Information Confidentiality Agreement (UAE PDPL)',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          isRTL
              ? 'بصفتي موظفاً في كافتيريا المدرسة، أقر بأنني قد أطلع على معلومات مسببات الحساسية والقيود الغذائية للطلاب من خلال نظام SchooKeep.'
              : 'As a cafeteria staff member, I understand that I may have access to student allergen and dietary restriction information through the SchooKeep system.',
          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 8),
        Text(isRTL ? 'أوافق على ما يلي:' : 'I agree to:',
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        const SizedBox(height: 8),
        for (final item in (isRTL
            ? const [
                'الحفاظ على السرية التامة لجميع البيانات الشخصية والصحية بموجب المرسوم بقانون رقم 45/2021.',
                'الوصول فقط إلى معلومات قيود الطعام الضرورية لإعداد الوجبات بسلامة.',
                'عدم مناقشة قيود الطلاب الغذائية مع أي جهة غير مصرح لها.',
                'الإبلاغ فوراً عن أي خرق أو تسريب محتمل للخصوصية لـ مسؤول حماية البيانات (DPO).',
              ]
            : const [
                'Keep all student health information strictly confidential per UAE Decree Law No. 45/2021.',
                'Only access information necessary to safely prepare and serve meals.',
                'Never discuss student restrictions with unauthorized individuals.',
                'Report any suspected privacy breaches immediately to the DPO.',
              ]))
          _bullet(item),
        const SizedBox(height: 8),
        Text(
          isRTL
              ? 'توقيعك الرقمي مسجل ونشط ومحفوظ قانوناً طوال فترة العمل.'
              : 'Your digital signature is on file and this agreement remains active under UAE Data Office regulations.',
          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 16),
        _sheetTealButton(isRTL ? 'إغلاق' : 'Close'),
      ],
    );
  }

  void _showDataAccessSheet(bool isRTL) {
    _showSheet(
      title: isRTL ? 'مستوى الوصول للبيانات المصرح بها' : 'Your Data Access Level',
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SchooKeepColors.accent),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.shield, size: 20, color: SchooKeepColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRTL ? 'وصول محدود — موظفي الكافتيريا' : 'Limited Access — Cafeteria Staff',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.greenChipText)),
                    const SizedBox(height: 4),
                    Text(isRTL ? 'قيود الحساسية والأغذية فقط — بدون سجلات طبية' : 'Allergen restrictions only — no medical records',
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.accent)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(isRTL ? 'البيانات المسموح لك بالاطلاع عليها:' : 'What you can see:',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
        const SizedBox(height: 8),
        for (final item in (isRTL
            ? const [
                'اسم الطالب (الاسم الأول والحرف الأول للجد فقط)',
                'الصف الدراسي للمدرسة',
                'قيود الطعام ومسببات الحساسية',
                'متطلبات إعداد وجبة خاصة للطلاب',
              ]
            : const [
                'Student name (first name + last initial only)',
                'Grade level',
                'Allergen and dietary restrictions',
                'Special meal requirements',
              ]))
          _bullet(item),
        const SizedBox(height: 12),
        Text(isRTL ? 'البيانات المحجوبة والسرية عنك:' : 'What you cannot see:',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
        const SizedBox(height: 8),
        for (final item in (isRTL
            ? const [
                'التشخيصات الطبية والأمراض',
                'بيانات الأدوية الموصوفة والجرعات',
                'الأسماء الكاملة للطلاب أو أرقام التواصل',
                'سجل زيارات العيادة أو الملاحظات الطبية',
              ]
            : const [
                'Medical diagnoses or conditions',
                'Medication information',
                'Full names or contact information',
                'Health visit history or clinic notes',
              ]))
          _bullet(item),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.5),
              children: [
                TextSpan(
                  text: isRTL ? 'قانون حماية البيانات الإماراتي (PDPL): ' : 'UAE PDPL Protection: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: isRTL
                      ? 'تم تقييد نطاق وصول موظفي الكافتيريا لحماية خصوصية بيانات الطلاب الصحية مع ضمان حصولك على القيود الغذائية اللازمة فقط لتحضير الوجبات بسلامة.'
                      : 'This limited access scope is designed to protect student privacy per UAE PDPL compliance while ensuring you have dietary information needed to safely prepare meals.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sheetTealButton(isRTL ? 'إغلاق' : 'Close'),
      ],
    );
  }

  void _showContactSupportSheet(bool isRTL) {
    const supportEmail = 'support@schookeep.ae';
    _showSheet(
      title: isRTL ? 'الاتصال بالدعم الفني' : 'Contact Support',
      children: [
        Text(
          isRTL
              ? 'فريق دعم SchooKeep متاح من الأحد إلى الخميس، من 8:00 صباحاً حتى 5:00 مساءً (بتوقيت الإمارات).'
              : 'SchooKeep support is available Sunday–Thursday, 8:00 AM – 5:00 PM (GST).',
          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 12),
        _bullet(isRTL ? 'البريد الإلكتروني: $supportEmail' : 'Email: $supportEmail'),
        _bullet(isRTL ? 'الهاتف: 800-724665' : 'Phone: 800-SCHOOL (800-724665)'),
        _bullet(isRTL
            ? 'للحالات العاجلة المتعلقة بسلامة الطعام، يرجى إبلاغ ممرضة المدرسة فوراً.'
            : 'For urgent food-safety incidents, notify the school nurse immediately.'),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: SchooKeepColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: supportEmail));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isRTL ? 'تم نسخ البريد الإلكتروني' : 'Support email copied to clipboard')),
              );
            },
            icon: const Icon(LucideIcons.copy, size: 18, color: SchooKeepColors.physicianTeal),
            label: Text(isRTL ? 'نسخ البريد الإلكتروني' : 'Copy support email',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.physicianTeal)),
          ),
        ),
        const SizedBox(height: 12),
        _sheetTealButton(isRTL ? 'إغلاق' : 'Close'),
      ],
    );
  }

  void _showHalalCertificate(bool isRTL, HalalCertification? cert) {
    final certNo = cert?.certificateNo ?? 'UAE-HALAL-2026-992';
    final authority = cert?.supplier ?? 'MOHAP / Dubai Municipality';
    final expiry = cert?.expiryDate ?? '15/06/2027';
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => Dialog(
        backgroundColor: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                  ),
                ),
              ),
              const Icon(LucideIcons.award, size: 48, color: SchooKeepColors.halalGreen),
              const SizedBox(height: 12),
              Text(isRTL ? 'شهادة الحلال المعتمدة' : 'Official Halal Certificate',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                isRTL
                    ? 'هذه المنشأة الغذائية معتمدة بالكامل وحلال من الجهات الرسمية في دولة الإمارات العربية المتحدة.'
                    : 'This school cafeteria facility is certified Halal and compliant with UAE food safety regulations.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SchooKeepColors.halalGreen, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    _certRow(isRTL ? 'رقم الشهادة:' : 'Cert No:', certNo,
                        bold: true, color: SchooKeepColors.halalGreen),
                    const SizedBox(height: 8),
                    _certRow(isRTL ? 'جهة الترخيص:' : 'Authority:', authority),
                    const SizedBox(height: 8),
                    _certRow(isRTL ? 'تاريخ الانتهاء:' : 'Expiry Date:', expiry),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: SchooKeepColors.physicianTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isRTL ? 'إغلاق' : 'Close Viewer',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _certRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color ?? const Color(0xFF475569))),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color ?? const Color(0xFF475569))),
      ],
    );
  }

  void _showSignOutDialog() {
    final isRTL = context.isRTL;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => Dialog(
        backgroundColor: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isRTL ? 'تسجيل الخروج · Sign out?' : 'Sign out of SchooKeep?',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 12),
              Text(
                isRTL ? 'ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى التطبيق.' : "You'll need to sign in again to access the app.",
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(isRTL ? 'إلغاء · Cancel' : 'Cancel',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _handleSignOut,
                        child: Text(isRTL ? 'تسجيل الخروج · Sign out' : 'Sign out',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTealButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: SchooKeepColors.physicianTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
      ),
    );
  }

  Widget _selectableOption(String label, {required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? SchooKeepColors.physicianTeal : SchooKeepColors.border, width: 2),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

/// Rounded-top bottom sheet with a drag handle, sticky title, and scrollable body.
class _SheetContainer extends StatelessWidget {
  const _SheetContainer({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(999)),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            ),
          ),
        ],
      ),
    );
  }
}
