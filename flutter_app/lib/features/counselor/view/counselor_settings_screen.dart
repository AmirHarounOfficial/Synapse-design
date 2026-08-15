import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

const Color _counselorPurple = Color(0xFF7C3AED);
const Color _counselorPurpleDark = Color(0xFF6D28D9);
const Color _counselorProfileBg = Color(0xFFF5F3FF);

/// Ported from `CounselorSettings.tsx`. Profile card, notification toggles with
/// a report-reminder day picker, report defaults, active cases, data & privacy
/// (PDPL), about, and a bilingual sign-out flow. Inline mock data + setState.
class CounselorSettingsScreen extends StatefulWidget {
  const CounselorSettingsScreen({super.key});

  @override
  State<CounselorSettingsScreen> createState() => _CounselorSettingsScreenState();
}

class _CounselorSettingsScreenState extends State<CounselorSettingsScreen> {
  bool _newCase = true;
  bool _trendAlerts = true;
  bool _reportReminders = true;
  bool _weatherSummaries = true;
  bool _parentResponses = true;

  bool _showReminderPicker = false;
  int _reminderDays = 3;

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: const SchooKeepAppBar(title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCard(),
            const SizedBox(height: 16),
            _sectionHeader('Notifications'),
            _notificationsCard(),
            const SizedBox(height: 16),
            _sectionHeader('Report Defaults'),
            _reportDefaultsCard(),
            const SizedBox(height: 16),
            _sectionHeader('Active Cases'),
            _activeCasesCard(),
            const SizedBox(height: 16),
            _sectionHeader('Data & Privacy'),
            _dataPrivacyCard(),
            const SizedBox(height: 16),
            _sectionHeader('About'),
            _aboutCard(),
            const SizedBox(height: 16),
            _signOutButton(),
          ],
        ),
      ),
    );
  }

  /// Settings rows are read-only informational entries in this build (no
  /// sub-screens exist). Each opens a small bilingual info dialog explaining
  /// the value, rather than navigating to a route that isn't there.
  void _showInfo({required String titleEn, required String titleAr, required String bodyEn, required String bodyAr}) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => Dialog(
        backgroundColor: SchooKeepColors.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  dialogContext.tr(en: titleEn, ar: titleAr),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  dialogContext.tr(en: bodyEn, ar: bodyAr),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 44,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _counselorPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      dialogContext.tr(en: 'Got it', ar: 'حسنًا'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(label.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: SchooKeepColors.textSecondary,
            letterSpacing: 1.0,
          )),
    );
  }

  Widget _card({required List<Widget> children}) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)));
      rows.add(children[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }

  Widget _profileCard() {
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
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _counselorProfileBg, shape: BoxShape.circle),
                child: const Text('RM',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: _counselorPurpleDark)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rachel Martinez',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: _counselorProfileBg, borderRadius: BorderRadius.circular(999)),
                      child: const Text('Student Counselor',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _counselorPurpleDark)),
                    ),
                    const SizedBox(height: 4),
                    const Text('License #SC-47829',
                        style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                    const SizedBox(height: 2),
                    const Text('Lakewood Elementary School',
                        style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _showInfo(
                titleEn: 'Edit profile',
                titleAr: 'تعديل الملف الشخصي',
                bodyEn: 'Your name, license, and school are managed by your school administrator. Contact them to update these details.',
                bodyAr: 'يتم إدارة اسمك ورخصتك ومدرستك من قبل مسؤول مدرستك. تواصل معه لتحديث هذه التفاصيل.',
              ),
              child: const Text('Edit profile',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationsCard() {
    return _card(children: [
      _toggleRow(
        icon: LucideIcons.user,
        title: 'New case assigned',
        subtitle: 'When a student is referred to you by the nurse or admin',
        value: _newCase,
        onChanged: (v) => setState(() => _newCase = v),
      ),
      // Tag trend alerts (with helper note when on)
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _toggleInner(
              icon: LucideIcons.trendingUp,
              title: 'Tag trend alerts',
              subtitle: 'When the same psychosocial tag is logged 3+ times for one student in 7 days',
              value: _trendAlerts,
              onChanged: (v) => setState(() => _trendAlerts = v),
            ),
            if (_trendAlerts)
              const Padding(
                padding: EdgeInsets.only(left: 32, top: 8),
                child: Text('Helps identify students needing escalated support.',
                    style: TextStyle(fontSize: 11, color: SchooKeepColors.warning, height: 1.5)),
              ),
          ],
        ),
      ),
      // Report due reminders (with day picker when on)
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _toggleInner(
              icon: LucideIcons.fileText,
              title: 'Report due reminders',
              subtitle: 'Reminders before a periodic report is due',
              value: _reportReminders,
              onChanged: (v) => setState(() => _reportReminders = v),
            ),
            if (_reportReminders)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _showReminderPicker = !_showReminderPicker),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Remind me: $_reminderDays days before',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _showReminderPicker ? 0.5 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: const Icon(LucideIcons.chevronDown, size: 16, color: SchooKeepColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            if (_reportReminders && _showReminderPicker)
              Container(
                margin: const EdgeInsets.only(left: 32, top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SchooKeepColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    for (final days in const [1, 2, 3, 7])
                      _reminderOption(days),
                  ],
                ),
              ),
          ],
        ),
      ),
      _toggleRow(
        icon: LucideIcons.cloud,
        title: 'Weather-linked tag summaries',
        subtitle: 'Daily summary of tags logged during active weather advisories',
        value: _weatherSummaries,
        onChanged: (v) => setState(() => _weatherSummaries = v),
      ),
      _toggleRow(
        icon: LucideIcons.bell,
        title: 'Parent responses to referrals',
        subtitle: 'When a parent acknowledges an external referral you submitted',
        value: _parentResponses,
        onChanged: (v) => setState(() => _parentResponses = v),
      ),
    ]);
  }

  Widget _reminderOption(int days) {
    final selected = _reminderDays == days;
    return GestureDetector(
      onTap: () => setState(() {
        _reminderDays = days;
        _showReminderPicker = false;
      }),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? SchooKeepColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text('$days ${days == 1 ? 'day' : 'days'} before',
            style: TextStyle(fontSize: 13, color: selected ? Colors.white : SchooKeepColors.textPrimary)),
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _toggleInner(icon: icon, title: title, subtitle: subtitle, value: value, onChanged: onChanged),
    );
  }

  Widget _toggleInner({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _reportDefaultsCard() {
    return _card(children: [
      _navRow(
        icon: LucideIcons.calendar,
        title: 'Default report date range',
        trailing: 'Last 30 days',
        trailingColor: SchooKeepColors.primary,
        onTap: () => _showInfo(
          titleEn: 'Default report date range',
          titleAr: 'النطاق الزمني الافتراضي للتقرير',
          bodyEn: 'New reports default to the last 30 days. You can change the range per report on the Generate Report screen.',
          bodyAr: 'تبدأ التقارير الجديدة بآخر 30 يومًا افتراضيًا. يمكنك تغيير النطاق لكل تقرير من شاشة إنشاء التقرير.',
        ),
      ),
      _navRow(
        icon: LucideIcons.users,
        title: 'Default report scope',
        trailing: 'All students',
        trailingColor: SchooKeepColors.primary,
        onTap: () => _showInfo(
          titleEn: 'Default report scope',
          titleAr: 'النطاق الافتراضي للتقرير',
          bodyEn: 'New reports include all students on your caseload by default. Choose Individual on the Generate Report screen to scope to one student.',
          bodyAr: 'تشمل التقارير الجديدة جميع الطلاب ضمن قائمتك افتراضيًا. اختر "فردي" من شاشة إنشاء التقرير لتخصيصه لطالب واحد.',
        ),
      ),
    ]);
  }

  Widget _activeCasesCard() {
    return _card(children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showInfo(
            titleEn: 'My active cases',
            titleAr: 'حالاتي النشطة',
            bodyEn: 'You currently have 4 active student wellbeing cases. Open a student from the Students tab to review their tag history.',
            bodyAr: 'لديك حاليًا 4 حالات نشطة لرعاية الطلاب. افتح طالبًا من تبويب الطلاب لمراجعة سجل وسومه.',
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(LucideIcons.clipboard, size: 20, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('My active cases',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                ),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: _counselorPurple, shape: BoxShape.circle),
                  child: const Text('4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
      _navRow(
        icon: LucideIcons.archive,
        title: 'Closed cases',
        chevron: true,
        onTap: () => _showInfo(
          titleEn: 'Closed cases',
          titleAr: 'الحالات المغلقة',
          bodyEn: 'Cases you have closed are archived for your records. A dedicated archive view is coming in a future update.',
          bodyAr: 'تُحفظ الحالات التي أغلقتها في الأرشيف لسجلاتك. سيتوفر عرض أرشيف مخصص في تحديث قادم.',
        ),
      ),
    ]);
  }

  Widget _dataPrivacyCard() {
    return _card(children: [
      _navRow(
        icon: LucideIcons.file,
        title: 'Confidentiality agreement',
        trailing: 'Signed May 1, 2026',
        trailingColor: SchooKeepColors.textSecondary,
        chevron: true,
        onTap: () => _showInfo(
          titleEn: 'Confidentiality agreement',
          titleAr: 'اتفاقية السرية',
          bodyEn: 'You signed the staff confidentiality agreement on May 1, 2026. It governs how you handle student wellbeing records.',
          bodyAr: 'لقد وقّعت اتفاقية سرية الموظفين في 1 مايو 2026. وهي تنظّم كيفية تعاملك مع سجلات رعاية الطلاب.',
        ),
      ),
      _navRow(
        icon: LucideIcons.shield,
        title: 'My data access level',
        trailing: 'Psychosocial records only',
        trailingColor: _counselorPurple,
        chevron: true,
        onTap: () => _showInfo(
          titleEn: 'My data access level',
          titleAr: 'مستوى وصولي إلى البيانات',
          bodyEn: 'Your account can access psychosocial wellbeing records only. Clinical and medical records are restricted to nursing staff.',
          bodyAr: 'يمكن لحسابك الوصول إلى سجلات الرعاية النفسية والاجتماعية فقط. السجلات السريرية والطبية مقصورة على طاقم التمريض.',
        ),
      ),
      _navRow(
        icon: LucideIcons.lock,
        title: 'Two-factor authentication',
        trailing: 'Enabled',
        trailingColor: SchooKeepColors.accent,
        chevron: true,
        onTap: () => _showInfo(
          titleEn: 'Two-factor authentication',
          titleAr: 'المصادقة الثنائية',
          bodyEn: 'Two-factor authentication is enabled on your account, adding a second verification step at sign-in.',
          bodyAr: 'المصادقة الثنائية مفعّلة على حسابك، ما يضيف خطوة تحقق ثانية عند تسجيل الدخول.',
        ),
      ),
    ]);
  }

  Widget _aboutCard() {
    return _card(children: [
      // App version (not a button)
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(LucideIcons.info, size: 20, color: SchooKeepColors.textSecondary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('App version',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
            ),
            const Text('SchooKeep v1.0.0',
                style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
          ],
        ),
      ),
      _navRow(
        icon: LucideIcons.headphones,
        title: 'Contact support',
        chevron: true,
        onTap: () => _showInfo(
          titleEn: 'Contact support',
          titleAr: 'تواصل مع الدعم',
          bodyEn: 'Reach the SchooKeep support team at support@schookeep.ae or call your school IT coordinator.',
          bodyAr: 'تواصل مع فريق دعم SchooKeep عبر support@schookeep.ae أو اتصل بمنسق تقنية المعلومات في مدرستك.',
        ),
      ),
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showInfo(
            titleEn: 'UAE PDPL Privacy Declaration',
            titleAr: 'إقرار خصوصية قانون حماية البيانات الإماراتي',
            bodyEn: 'Student wellbeing records are processed under Federal Decree-Law No. 45 of 2021 on the Protection of Personal Data. Access is limited to authorized counseling staff.',
            bodyAr: 'تتم معالجة سجلات رعاية الطلاب بموجب المرسوم بقانون اتحادي رقم 45 لسنة 2021 بشأن حماية البيانات الشخصية. الوصول مقصور على موظفي الإرشاد المصرح لهم.',
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(LucideIcons.book, size: 20, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UAE PDPL Privacy Declaration',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('Governed by Federal Decree-Law No. 45 of 2021',
                          style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _navRow({
    required IconData icon,
    required String title,
    String? trailing,
    Color trailingColor = SchooKeepColors.textSecondary,
    bool chevron = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Text(trailing, style: TextStyle(fontSize: trailingColor == SchooKeepColors.primary ? 14 : 12, color: trailingColor)),
              ],
              if (chevron) ...[
                const SizedBox(width: 8),
                const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _signOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: SchooKeepColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SchooKeepColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _showSignOutDialog,
          child: const Center(
            child: Text('تسجيل الخروج · Sign out',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.error)),
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => Dialog(
        backgroundColor: SchooKeepColors.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('تسجيل الخروج · Sign out?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 8),
                const Text(
                  'هل أنت متأكد من رغبتك في تسجيل الخروج؟\nYou\'ll need to sign in again to access your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: SchooKeepColors.textPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('إلغاء · Cancel',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            context.go('/login');
                          },
                          child: const Text('تسجيل الخروج · Sign out',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
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
}

/// iOS-style toggle (`w-12 h-7`) matching the export's custom switch.
class _Switch extends StatelessWidget {
  const _Switch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: value ? SchooKeepColors.primary : SchooKeepColors.border,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
