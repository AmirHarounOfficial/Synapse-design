import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Nurse settings screen with full bilingual support (English & Arabic).
class NurseSettingsScreen extends StatefulWidget {
  const NurseSettingsScreen({super.key});

  @override
  State<NurseSettingsScreen> createState() => _NurseSettingsScreenState();
}

class _NurseSettingsScreenState extends State<NurseSettingsScreen> {
  bool _medicationDue = true;
  bool _clinicReferrals = true;
  bool _emergency = true;
  bool _documents = true;
  bool _system = false;

  int _autoLockMinutes = 5;
  bool _requireBiometric = true;

  static const String _nameEn = 'Jane Smith';
  static const String _nameAr = 'جيلان أحمد';
  static const String _initials = 'JS';
  static const String _license = 'RN-4521';

  void _handleSignOut() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr(en: 'Sign out?', ar: 'تسجيل الخروج؟')),
        content: Text(context.tr(
          en: 'Are you sure you want to sign out?',
          ar: 'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.tr(en: 'Cancel', ar: 'إلغاء')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/login');
            },
            child: Text(
              context.tr(en: 'Sign out', ar: 'تسجيل الخروج'),
              style: const TextStyle(color: SchooKeepColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showInfoSheet({required String title, required List<Widget> children}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: SchooKeepColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(sheetContext).pop(),
                    child: Text(
                      context.tr(en: 'Close', ar: 'إغلاق'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: SchooKeepColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet() {
    _showInfoSheet(
      title: context.tr(en: 'Edit profile', ar: 'تعديل الملف الشخصي'),
      children: [
        Text(
          context.tr(en: 'Name', ar: 'الاسم'),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          context.tr(en: _nameEn, ar: _nameAr),
          style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Text(
          context.tr(en: 'License', ar: 'الترخيص'),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary),
        ),
        const SizedBox(height: 2),
        const Text('#$_license', style: TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
        const SizedBox(height: 12),
        Text(
          context.tr(en: 'Role', ar: 'المسمى الوظيفي'),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          context.tr(en: 'School Nurse', ar: 'ممرض/ة المدرسة'),
          style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Text(
          context.tr(
            en: 'Profile details are managed by your school administrator. Contact support to request a change.',
            ar: 'تتم إدارة تفاصيل الملف الشخصي من قبل مسؤول المدرسة. اتصل بالدعم لطلب التغيير.',
          ),
          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
        ),
      ],
    );
  }

  void _showSessionInfoSheet() {
    _showInfoSheet(
      title: context.tr(en: 'Active session info', ar: 'معلومات الجلسة النشطة'),
      children: [
        _SessionRow(
          label: context.tr(en: 'Device', ar: 'الجهاز'),
          value: 'iPhone 14 · iOS 17.4',
        ),
        _SessionRow(
          label: context.tr(en: 'Location', ar: 'الموقع'),
          value: context.tr(en: 'Dubai, United Arab Emirates', ar: 'دبي، الإمارات العربية المتحدة'),
        ),
        _SessionRow(
          label: context.tr(en: 'IP address', ar: 'عنوان IP'),
          value: '94.200.18.42',
        ),
        _SessionRow(
          label: context.tr(en: 'Signed in', ar: 'تاريخ الدخول'),
          value: context.tr(en: 'Today · 07:42 AM', ar: 'اليوم · 07:42 صباحاً'),
        ),
        _SessionRow(
          label: context.tr(en: 'Auto-lock', ar: 'القفل التلقائي'),
          value: context.tr(en: 'Enabled', ar: 'مُفعل'),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr(
            en: 'This is the only active session for your account.',
            ar: 'هذه هي الجلسة النشطة الوحيدة لحسابك.',
          ),
          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
        ),
      ],
    );
  }

  void _showSupportSheet() {
    _showInfoSheet(
      title: context.tr(en: 'Contact support', ar: 'الاتصال بالدعم الفني'),
      children: [
        Text(
          context.tr(
            en: 'SchooKeep Health Support is available Sunday–Thursday, 8:00 AM – 6:00 PM (GST).',
            ar: 'دعم سكوكيب الصحي متوفر من الأحد إلى الخميس، 8:00 صباحاً - 6:00 مساءً (توقيت الإمارات).',
          ),
          style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 16),
        _contactRow(LucideIcons.mail, 'support@schookeep.ae'),
        const SizedBox(height: 8),
        _contactRow(LucideIcons.phone, '+971 4 123 4567'),
      ],
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: value));
        if (!mounted) return;
        _toast(context.tr(en: 'Copied $value', ar: 'تم نسخ $value'));
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SchooKeepColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: SchooKeepColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
              ),
            ),
            const Icon(LucideIcons.copy, size: 16, color: SchooKeepColors.primary),
          ],
        ),
      ),
    );
  }

  void _showPdplSheet() {
    _showInfoSheet(
      title: context.tr(en: 'UAE PDPL Privacy Declaration', ar: 'إعلان خصوصية قانون حماية البيانات الإماراتي'),
      children: [
        Text(
          context.tr(
            en: 'Governed by Federal Decree-Law No. 45 of 2021 on the Protection of Personal Data (PDPL).',
            ar: 'خاضع للمرسوم بقانون اتحادي رقم 45 لسنة 2021 بشأن حماية البيانات الشخصية.',
          ),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 14),
        Text(
          context.tr(
            en: 'SchooKeep processes student health records as protected personal data. Access is restricted to authorized school health staff and is logged for audit purposes.',
            ar: 'يعالج تطبيق سكوكيب السجلات الصحية للطلاب كبيانات شخصية محمية. يقتصر الوصول على الكادر الصحي المدرسي المخول ويتم تسجيل جميع العمليات لأغراض التدقيق.',
          ),
          style: const TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.6),
        ),
        const SizedBox(height: 14),
        Text(
          context.tr(
            en: 'Data is stored within the UAE and is not shared with third parties without explicit consent, except where required by law. Unauthorized disclosure or modification of these records violates Federal law and may result in legal action.',
            ar: 'تخزن البيانات داخل دولة الإمارات العربية المتحدة ولا تتم مشاركتها مع أطراف ثالثة دون موافقة صريحة، باستثناء ما ينص عليه القانون. الإفصاح غير المصرح به أو التعديل على هذه السجلات يخالف القانون الاتحادي ويستوجب الملاحقة القانونية.',
          ),
          style: const TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.6),
        ),
        const SizedBox(height: 14),
        Text(
          context.tr(
            en: 'Parents and guardians may request access to, correction of, or deletion of their child’s records by contacting the school administrator.',
            ar: 'يمكن لأولياء الأمور والأوصياء طلب الوصول إلى سجلات أطفالهم أو تصحيحها أو حذفها عبر التواصل مع إدارة المدرسة.',
          ),
          style: const TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.6),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: context.tr(en: 'Settings', ar: 'الإعدادات'),
        onBack: () => context.safeBack(),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile
            SchooKeepCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                        child: const Text(_initials,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr(en: _nameEn, ar: _nameAr),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${context.tr(en: 'License', ar: 'ترخيص رقم')} #$_license',
                              style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                context.tr(en: 'School Nurse', ar: 'ممرض/ة المدرسة'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF1E40AF)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: SchooKeepColors.background,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showEditProfileSheet,
                      child: Text(
                        context.tr(en: 'Edit profile', ar: 'تعديل الملف الشخصي'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pharmacy & Operations Shortcuts
            _sectionTitle(context.tr(en: 'Pharmacy & Operations', ar: 'الصيدلية والعمليات الطبية')),
            const SizedBox(height: 12),
            _group([
              _navRow(
                LucideIcons.boxes,
                context.tr(en: 'Medicine Inventory', ar: 'مخزون الأدوية والصيدلية'),
                context.tr(en: 'Manage stock count & expirations', ar: 'إدارة الكميات وتأريخ الصلاحية'),
                onTap: () => context.go('/nurse/medications/inventory'),
              ),
              _navRow(
                LucideIcons.calendar,
                context.tr(en: "Today's Dose Schedule", ar: 'جدول الجرعات اليومي'),
                context.tr(en: 'View all scheduled medication doses', ar: 'عرض كافة الجرعات المجدولة اليوم'),
                onTap: () => context.go('/nurse/daily-doses'),
              ),
            ]),
            const SizedBox(height: 24),

            // Notifications
            _sectionTitle(context.tr(en: 'Notifications', ar: 'الإشعارات')),
            const SizedBox(height: 12),
            _group([
              _toggleRow(
                LucideIcons.bell,
                context.tr(en: 'Medication due', ar: 'استحقاق جرعة دواء'),
                context.tr(en: 'Push, SMS, Email', ar: 'إشعار فوري، رسالة نصية، بريد'),
                _medicationDue,
                (v) => setState(() => _medicationDue = v),
              ),
              _toggleRow(
                LucideIcons.bell,
                context.tr(en: 'Clinic referrals', ar: 'إحالات العيادة الطبية'),
                context.tr(en: 'Push, SMS', ar: 'إشعار فوري، رسالة نصية'),
                _clinicReferrals,
                (v) => setState(() => _clinicReferrals = v),
              ),
              _toggleRow(
                LucideIcons.bell,
                context.tr(en: 'Emergency', ar: 'بلاغات الطوارئ'),
                context.tr(en: 'Push, SMS, Email', ar: 'إشعار فوري، رسالة نصية، بريد'),
                _emergency,
                (v) => setState(() => _emergency = v),
              ),
              _toggleRow(
                LucideIcons.bell,
                context.tr(en: 'Documents', ar: 'المستندات والوثائق'),
                context.tr(en: 'Push', ar: 'إشعار تطبيق فوري'),
                _documents,
                (v) => setState(() => _documents = v),
              ),
              _toggleRow(
                LucideIcons.bell,
                context.tr(en: 'System', ar: 'تحديثات النظام'),
                context.tr(en: 'App updates & maintenance', ar: 'تحديثات التطبيق والصيانة الدوريّة'),
                _system,
                (v) => setState(() => _system = v),
              ),
            ]),
            const SizedBox(height: 24),

            // Session & Security
            _sectionTitle(context.tr(en: 'Session & Security', ar: 'الجلسة والأمان')),
            const SizedBox(height: 12),
            _group([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(LucideIcons.lock, size: 20, color: SchooKeepColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr(en: 'Auto-lock after', ar: 'القفل التلقائي بعد'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                          ),
                          Text(
                            context.tr(
                              en: 'Currently: $_autoLockMinutes minutes',
                              ar: 'حالياً: $_autoLockMinutes دقائق',
                            ),
                            style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    _stepperButton('-', () => setState(() => _autoLockMinutes = (_autoLockMinutes - 1).clamp(3, 10))),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$_autoLockMinutes',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                      ),
                    ),
                    _stepperButton('+', () => setState(() => _autoLockMinutes = (_autoLockMinutes + 1).clamp(3, 10))),
                  ],
                ),
              ),
              _toggleRow(
                LucideIcons.shield,
                context.tr(en: 'Require biometric on return', ar: 'طلب بصمة الوجه/الأصبع عند العودة'),
                context.tr(en: 'Face ID or Touch ID', ar: 'بصمة الوجه (Face ID) أو الأصبع (Touch ID)'),
                _requireBiometric,
                (v) => setState(() => _requireBiometric = v),
              ),
              _navRow(
                LucideIcons.lock,
                context.tr(en: 'Active session info', ar: 'معلومات الجلسة النشطة'),
                context.tr(en: 'Device & location details', ar: 'تفاصيل الجهاز والموقع'),
                onTap: _showSessionInfoSheet,
              ),
            ]),
            const SizedBox(height: 24),

            // My Reports
            _sectionTitle(context.tr(en: 'My Reports', ar: 'تقاريري')),
            const SizedBox(height: 12),
            SchooKeepCard(
              padding: EdgeInsets.zero,
              onTap: () => context.go('/nurse/reports/generate'),
              child: _navRowContent(
                LucideIcons.fileText,
                context.tr(en: 'View my generated reports', ar: 'عرض تقاريري المنشأة'),
                context.tr(en: 'Access report history', ar: 'الوصول إلى سجل التقارير'),
              ),
            ),
            const SizedBox(height: 24),

            // About & Help
            _sectionTitle(context.tr(en: 'About & Help', ar: 'حول والمساعدة')),
            const SizedBox(height: 12),
            _group([
              _navRow(
                LucideIcons.helpCircle,
                context.tr(en: 'Contact support', ar: 'الاتصال بالدعم الفني'),
                null,
                onTap: _showSupportSheet,
              ),
              _navRow(
                LucideIcons.shield,
                context.tr(en: 'UAE PDPL Privacy Declaration', ar: 'إعلان خصوصية قانون حماية البيانات الإماراتي'),
                context.tr(en: 'Governed by Federal Decree-Law No. 45 of 2021', ar: 'خاضع للمرسوم بقانون اتحادي رقم 45 لسنة 2021'),
                onTap: _showPdplSheet,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.tr(en: 'Version 1.0.0 (Build 2026.05.25)', ar: 'الإصدار 1.0.0 (بناء 2026.05.25)'),
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // Sign out
            SchooKeepCard(
              padding: EdgeInsets.zero,
              borderColor: SchooKeepColors.error,
              onTap: _handleSignOut,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.logOut, size: 20, color: SchooKeepColors.error),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(en: 'Sign out', ar: 'تسجيل الخروج'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.error),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
    );
  }

  Widget _group(List<Widget> children) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(const Divider(height: 1, color: SchooKeepColors.border));
      items.add(children[i]);
    }
    return SchooKeepCard(padding: EdgeInsets.zero, child: Column(children: items));
  }

  Widget _toggleRow(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: SchooKeepColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _navRow(IconData icon, String title, String? subtitle, {required VoidCallback onTap}) {
    return InkWell(onTap: onTap, child: _navRowContent(icon, title, subtitle));
  }

  Widget _navRowContent(IconData icon, String title, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                if (subtitle != null)
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
        ],
      ),
    );
  }

  Widget _stepperButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: SchooKeepColors.background, borderRadius: BorderRadius.circular(8)),
          child: Text(label, style: const TextStyle(fontSize: 18, color: SchooKeepColors.textSecondary)),
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary)),
        ],
      ),
    );
  }
}
