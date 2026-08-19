import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class SecretarySettingsScreen extends StatefulWidget {
  const SecretarySettingsScreen({super.key});

  @override
  State<SecretarySettingsScreen> createState() => _SecretarySettingsScreenState();
}

class _SecretarySettingsScreenState extends State<SecretarySettingsScreen> {
  bool _parentMessages = true;
  bool _importErrors = true;
  bool _clinicCopies = true;
  bool _documentExpiry = true;

  static const String _initials = 'SL';
  static const String _name = 'Sarah Lopez';
  static const String _officeHours = '08:00 AM — 4:30 PM';

  void _showLockSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: SchooKeepColors.border, borderRadius: BorderRadius.circular(999)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(LucideIcons.lock, size: 24, color: SchooKeepColors.warning),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr(en: 'Required Notification', ar: 'إشعار إجباري إلزامية التفعيل'),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(
                        context.tr(
                          en: 'Chatbot escalations must be received by the secretary to ensure no parent query goes unanswered.',
                          ar: 'يجب أن تصل تصعيدات المساعد الآلي للسكرتارية لضمان الإجابة على استفسارات أولياء الأمور دون تأخير.',
                        ),
                        style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: context.tr(en: 'Got it', ar: 'فهمت ذلك'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.tr(en: 'Sign out?', ar: 'تسجيل الخروج؟'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  en: "Are you sure you want to sign out? You'll need to sign in again to access your account.",
                  ar: 'هل أنت متأكد من رغبتك في تسجيل الخروج؟ ستحتاج إلى إدخال بيانات الاعتماد مجدداً للوصول للملف.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
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
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(context.tr(en: 'Cancel', ar: 'إلغاء'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
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
                          Navigator.of(ctx).pop();
                          context.go('/login');
                        },
                        child: Text(context.tr(en: 'Sign out', ar: 'تأكيد الخروج'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
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

  void _showInfoSheet({
    required IconData icon,
    Color iconColor = SchooKeepColors.primary,
    required String title,
    required List<Widget> body,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: SchooKeepColors.border, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 24, color: iconColor)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: body),
              ),
            ),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: context.tr(en: 'Close', ar: 'إغلاق'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _para(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary, height: 1.5)),
      );

  void _showEditProfileInfo() => _showInfoSheet(
        icon: LucideIcons.userCog,
        title: context.tr(en: 'Edit profile', ar: 'تعديل الملف الشخصي'),
        body: [
          _para(context.tr(
            en: 'Name, role, and school assignment are managed by your school administrator and cannot be changed here.',
            ar: 'تتم إدارة الاسم والمسؤولية والمدرسة المخصصة من قبل مدير النظام ولا يمكن تعديلها من هنا.',
          )),
          _para(context.tr(
            en: 'To update your profile details, contact the school administration office.',
            ar: 'لتحديث بياناتك الشخصية، يُرجى التواصل مع إدارة المدرسة الرئيسية.',
          )),
        ],
      );

  void _showWorkingHoursInfo() => _showInfoSheet(
        icon: LucideIcons.clock,
        title: context.tr(en: 'Working hours', ar: 'ساعات العمل الرسمية'),
        body: [
          _para('${context.tr(en: 'Office hours', ar: 'أوقات الدوام الرسمي')}: $_officeHours'),
          _para(context.tr(
            en: 'Non-emergency notifications are batched and delivered during these hours. Emergency clinic escalations are always delivered immediately, day or night.',
            ar: 'تتم أرشفة وتجميع الإشعارات العادية خارج أوقات الدوام. بينما يتم إرسال بلاغات الطوارئ فوراً على مدار الساعة.',
          )),
        ],
      );

  void _showImportHistoryInfo() => _showInfoSheet(
        icon: LucideIcons.table,
        title: context.tr(en: 'Import history', ar: 'سجل عمليات الاستيراد'),
        body: [
          _para(context.tr(en: 'Recent student imports:', ar: 'عمليات استيراد الطلاب الأخيرة:')),
          _para('• students_uae_2026.xlsx — 45 ${context.tr(en: 'students', ar: 'طالباً')} — 28 May 2026 — ${context.tr(en: 'Completed', ar: 'مكتمل')}'),
          _para('• transfers_q1.csv — 8 ${context.tr(en: 'students', ar: 'طالباً')} — 12 Apr 2026 — ${context.tr(en: 'Completed', ar: 'مكتمل')}'),
          _para(context.tr(
            en: 'Every Excel/CSV import is logged with its row count and validation result for audit purposes.',
            ar: 'يتم حفظ كافة عمليات رفع وتعديل بيانات ملفات الإكسل مع تدوين النتائج للتدقيق الإداري.',
          )),
        ],
      );

  void _showConfidentialityInfo() => _showInfoSheet(
        icon: LucideIcons.file,
        title: context.tr(en: 'Confidentiality agreement', ar: 'اتفاقية سرية وحماية البيانات'),
        body: [
          _para('${context.tr(en: 'Signed', ar: 'تاريخ التوقيع')}: 01/05/2026'),
          _para(context.tr(
            en: 'As school secretary, you agree to keep all student information strictly confidential under UAE Federal Decree-Law No. 45 of 2021 (PDPL), to access only the data needed for your duties, and to report any suspected breach to the Data Protection Officer immediately.',
            ar: 'بصفتك سكرتير/ة مدرسة، فإنك تتعهد بالحفاظ على السرية التامة لبيانات الطلاب بموجب المرسوم بقانون إتحادي رقم 45 لسنة 2021 (PDPL)، وعدم استخدام البيانات إلا لأغراض العمل المصرح بها.',
          )),
        ],
      );

  void _showDataAccessInfo() => _showInfoSheet(
        icon: LucideIcons.shield,
        title: context.tr(en: 'My data access level', ar: 'مستوى صلاحية الوصول للبيانات'),
        body: [
          _para(context.tr(
            en: 'Your role can access: student basic info, enrollment records, parent contact details, and import history.',
            ar: 'تتيح لك الصلاحية الوصول إلى: البيانات الأساسية للطلاب، ملفات التسجيل، معلومات اتصال ولي الأمر، وسجلات الاستيراد.',
          )),
          _para(context.tr(
            en: 'Your role cannot access: clinical records, medication data, clinic visit history, or counselor notes.',
            ar: 'لا تتيح صلاحيتك الاطلاع على: السجلات السريرية الطبية، بيانات الأدوية المفصلة، تاريخ زيارات العيادة، أو ملاحظات الأخصائي الاجتماعي.',
          )),
        ],
      );

  void _showTwoFactorInfo() => _showInfoSheet(
        icon: LucideIcons.eyeOff,
        title: context.tr(en: 'Two-factor authentication', ar: 'المصادقة الثنائية (2FA)'),
        body: [
          _para('${context.tr(en: 'Status', ar: 'الحالة')}: ${context.tr(en: 'Enabled', ar: 'مُفعلة')}'),
          _para(context.tr(
            en: 'A one-time verification code is required each time you sign in, protecting student data even if your password is compromised.',
            ar: 'يتطلب الدخول إدخال رمز تحقق لمرة واحدة لتأمين وحماية سجلات الطلاب والبيانات الحساسة.',
          )),
        ],
      );

  void _showContactSupportInfo() => _showInfoSheet(
        icon: LucideIcons.headphones,
        title: context.tr(en: 'Contact support', ar: 'التواصل مع الدعم الفني'),
        body: [
          _para(context.tr(
            en: 'SchooKeep support is available Sunday–Thursday, 8:00 AM – 5:00 PM (GST).',
            ar: 'فريق الدعم الفني متواجد من الأحد إلى الخميس، من 8:00 صباحاً حتى 5:00 مساءً (توقيت الإمارات).',
          )),
          _para('Email: support@schookeep.ae'),
          _para('Phone: 800-SCHOOL (800-724665)'),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SchooKeepButton(
              label: context.tr(en: 'Copy support email', ar: 'نسخ بريد الدعم الفني'),
              fullWidth: false,
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: 'support@schookeep.ae'));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr(en: 'Support email copied to clipboard', ar: 'تم نسخ بريد الدعم الفني للحافظة'))),
                );
              },
            ),
          ),
        ],
      );

  void _showPdplInfo() => _showInfoSheet(
        icon: LucideIcons.book,
        title: context.tr(en: 'UAE PDPL Privacy Declaration', ar: 'إعلان سياسة الخصوصية بموجب قانون PDPL الإمارات'),
        body: [
          _para(context.tr(
            en: 'Governed by Federal Decree-Law No. 45 of 2021 on the Protection of Personal Data.',
            ar: 'تخضع كافة البيانات للمرسوم بقانون إتحادي رقم 45 لسنة 2021 بشأن حماية البيانات الشخصية بالدولة.',
          )),
          _para(context.tr(
            en: 'SchooKeep processes student health and personal data solely to support school health and safety operations. Data is stored within the UAE, access is role-scoped, and all access is logged.',
            ar: 'تتم معالجة البيانات فقط لأغراض السلامة والرعاية الصحية المدرسية وتخزن داخل مراكز بيانات داخل الدولة.',
          )),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(title: context.tr(en: 'Settings', ar: 'إعدادات الحساب والإدارة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SchooKeepCard(
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
                        decoration: const BoxDecoration(color: Color(0xFFECFEFF), shape: BoxShape.circle),
                        child: const Text(_initials,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xFF0E7490))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(_name,
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFEFF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(context.tr(en: 'School Secretary', ar: 'سكرتير/ة المدرسة'),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0E7490))),
                            ),
                            const SizedBox(height: 4),
                            Text(context.tr(en: 'Lakewood Elementary School', ar: 'مدرسة الشروق النموذجية'), style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: GestureDetector(
                      onTap: _showEditProfileInfo,
                      child: Text(context.tr(en: 'Edit profile', ar: 'تعديل البيانات'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _sectionTitle(context.tr(en: 'Notifications', ar: 'إعدادات الإشعارات والتنبيهات')),
            const SizedBox(height: 8),
            _group([
              _toggleRow(LucideIcons.bell, context.tr(en: 'Parent messages received', ar: 'رسائل أولياء الأمور الواردة'), context.tr(en: 'New messages from parents in your inbox', ar: 'تنبيه فور وصول رسالة جديدة من ولي أمر'),
                  _parentMessages, (v) => setState(() => _parentMessages = v)),
              _lockedToggleRow(LucideIcons.bot, context.tr(en: 'Chatbot escalations', ar: 'تصعيدات المساعد الآلي'),
                  context.tr(en: 'When the AI assistant transfers a conversation to you', ar: 'عند تحويل محادثة تعذر على البوت إجابتها')),
              _toggleRow(LucideIcons.fileText, context.tr(en: 'Student import errors', ar: 'أخطاء استيراد ملفات الطلاب'),
                  context.tr(en: 'Alerts when an Excel/CSV import has validation failures', ar: 'إشعار في حال وجود أخطاء في ملف البيانات المرفوع'), _importErrors,
                  (v) => setState(() => _importErrors = v)),
              _toggleRow(LucideIcons.alertTriangle, context.tr(en: 'Clinic copies', ar: 'نسخة إشعار العيادة الطبية'),
                  context.tr(en: 'Receive copies of emergency clinic notifications sent to parents', ar: 'استلام نسخة من بلاغات طوارئ العيادة المرسلة للوالدين'), _clinicCopies,
                  (v) => setState(() => _clinicCopies = v)),
              _toggleRow(LucideIcons.calendar, context.tr(en: 'Document expiry reminders', ar: 'تنبيهات انتهاء صلاحية المستندات'),
                  context.tr(en: 'Students with documents expiring within 30 days', ar: 'تنبيه للوثائق المنتهية خلال 30 يوماً'), _documentExpiry,
                  (v) => setState(() => _documentExpiry = v)),
            ]),
            const SizedBox(height: 16),

            _sectionTitle(context.tr(en: 'Working Hours', ar: 'ساعات الدوام والعمل')),
            const SizedBox(height: 8),
            SchooKeepCard(
              padding: EdgeInsets.zero,
              child: InkWell(
                onTap: _showWorkingHoursInfo,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(LucideIcons.clock, size: 20, color: SchooKeepColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.tr(en: 'Office hours', ar: 'أوقات الدوام الرسمي'),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                                const Text(_officeHours, style: TextStyle(fontSize: 14, color: SchooKeepColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr(
                                en: 'Notifications are batched outside these hours (except emergency escalations).',
                                ar: 'يتم تجميع الإشعارات خارج أوقات الدوام الرسمي باستثناء طوارئ العيادة.',
                              ),
                              style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _sectionTitle(context.tr(en: 'Import History', ar: 'سجل عمليات الرفع والاستيراد')),
            const SizedBox(height: 8),
            SchooKeepCard(
              padding: EdgeInsets.zero,
              child: _navRow(LucideIcons.table, context.tr(en: 'View past imports', ar: 'عرض عمليات الاستيراد السابقة'),
                  context.tr(en: 'See all Excel/CSV student imports and their results', ar: 'استعراض نتائج رفع ملفات الطلاب السابقة'), onTap: _showImportHistoryInfo),
            ),
            const SizedBox(height: 16),

            _sectionTitle(context.tr(en: 'Data & Privacy', ar: 'البيانات والخصوصية الإدارية')),
            const SizedBox(height: 8),
            _group([
              _navRow(LucideIcons.file, context.tr(en: 'Confidentiality agreement', ar: 'اتفاقية حماية سرية المعلومات'), null,
                  trailing: context.tr(en: 'Signed May 1, 2026', ar: 'موقعة بتاريخ 01/05/2026'), onTap: _showConfidentialityInfo),
              _navRow(LucideIcons.shield, context.tr(en: 'My data access level', ar: 'صلاحيات الحساب والوصول'), null,
                  trailing: context.tr(en: 'Student basic info — no clinical records', ar: 'بيانات الطلاب فقط — بدون السجلات الطبية'), onTap: _showDataAccessInfo),
              _navRow(LucideIcons.eyeOff, context.tr(en: 'Two-factor authentication', ar: 'المصادقة الثنائية (2FA)'), null,
                  trailing: context.tr(en: 'Enabled', ar: 'مُفعلة'), trailingColor: SchooKeepColors.accent, onTap: _showTwoFactorInfo),
            ]),
            const SizedBox(height: 16),

            _sectionTitle(context.tr(en: 'About', ar: 'حول النظام والدعم')),
            const SizedBox(height: 8),
            _group([
              _infoRow(LucideIcons.info, context.tr(en: 'App version', ar: 'إصدار التطبيق'), 'SchooKeep v1.0.0'),
              _navRow(LucideIcons.headphones, context.tr(en: 'Contact support', ar: 'التواصل مع الدعم الفني'), null, onTap: _showContactSupportInfo),
              _navRow(LucideIcons.book, context.tr(en: 'UAE PDPL Privacy Declaration', ar: 'إعلان خصوصية PDPL الإمارات'),
                  context.tr(en: 'Governed by Federal Decree-Law No. 45 of 2021', ar: 'بموجب المرسوم بقانون إتحادي رقم 45 لسنة 2021'), onTap: _showPdplInfo),
            ]),
            const SizedBox(height: 16),

            SchooKeepCard(
              padding: EdgeInsets.zero,
              onTap: _showSignOutDialog,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(context.tr(en: 'Sign out', ar: 'تسجيل الخروج من الحساب'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.error)),
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
      child: Text(title.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: SchooKeepColors.textSecondary,
            letterSpacing: 0.8,
          )),
    );
  }

  Widget _group(List<Widget> children) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(const Divider(height: 1, color: Color(0xFFF1F5F9)));
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
                const SizedBox(height: 2),
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

  Widget _lockedToggleRow(IconData icon, String title, String subtitle) {
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
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          InkWell(
            onTap: _showLockSheet,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 4),
                Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(color: SchooKeepColors.primary, borderRadius: BorderRadius.circular(999)),
                  child: const Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: 4),
                      child: CircleAvatar(radius: 10, backgroundColor: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navRow(IconData icon, String title, String? subtitle,
      {String? trailing, Color? trailingColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(trailing,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 12, color: trailingColor ?? SchooKeepColors.textSecondary)),
              ),
              const SizedBox(width: 8),
            ],
            const RtlIcon(LucideIcons.chevronRight, size: 20, color: SchooKeepColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String trailing) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: SchooKeepColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
          ),
          Text(trailing, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
        ],
      ),
    );
  }
}
