import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/uae_tokens.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `PhysicianSettings.tsx`. Profile card, UAE clinical licensing
/// section (authority selector + read-only license + expiry status), locked &
/// editable notification toggles, a confidentiality agreement sheet, and a sign
/// out flow. `LicenseAuthoritySelector` is ported inline as a dropdown.
class PhysicianSettingsScreen extends StatefulWidget {
  const PhysicianSettingsScreen({super.key});

  @override
  State<PhysicianSettingsScreen> createState() => _PhysicianSettingsScreenState();
}

class _PhysicianSettingsScreenState extends State<PhysicianSettingsScreen> {
  String _authority = 'DHA';
  static const String _licenseNum = 'MD-4029';
  static const String _specialty = 'General Pediatrics';
  static const String _expiryDate = '24/11/2026';

  bool _coSignAlerts = true;
  bool _reminders = true;

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: SchooKeepColors.physicianTeal),
    );
  }

  void _handleSignOut() {
    final isRTL = context.isRTL;
    _toast(isRTL ? 'تم تسجيل الخروج بنجاح' : 'Signed out successfully');
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) context.go('/login');
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
        titleWidget: Text(isRTL ? 'إعدادات الطبيب' : 'Physician Settings',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileCard(isRTL),
          const SizedBox(height: 16),
          _licenseCard(isRTL),
          const SizedBox(height: 16),
          _notificationsCard(isRTL),
          const SizedBox(height: 16),
          _confidentialityCard(isRTL),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: SchooKeepColors.surface,
                side: const BorderSide(color: SchooKeepColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _showSignOutDialog,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.logOut, size: 16, color: SchooKeepColors.error),
                  const SizedBox(width: 8),
                  Text(isRTL ? 'تسجيل الخروج من الحساب' : 'Sign out',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.error)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(bool isRTL) {
    return SchooKeepCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SchooKeepColors.physicianTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Text('DR',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isRTL ? 'د. أمينة الهاشمي' : 'Dr. Amina Al-Hashimi',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: SchooKeepColors.physicianTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(isRTL ? 'طبيب المدرسة المعتمد' : 'School Physician',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)),
                      child: const Text(_specialty,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(isRTL ? 'مدرسة لينكولن الابتدائية' : 'Lincoln Elementary School',
                    style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _licenseCard(bool isRTL) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'الترخيص الطبي المهني بدولة الإمارات' : 'UAE CLINICAL LICENSING',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary, letterSpacing: 0.8)),
          const SizedBox(height: 16),
          // License authority selector (ported inline).
          Text(isRTL ? 'هيئة الترخيص الطبي' : 'Medical License Authority',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 6),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: SchooKeepColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _authority,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, size: 20, color: SchooKeepColors.textSecondary),
                style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
                items: [
                  for (final auth in UaeTokens.licenseAuthorities)
                    DropdownMenuItem(value: auth, child: Text(auth)),
                ],
                onChanged: (v) => setState(() => _authority = v ?? _authority),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: SchooKeepColors.amberBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              isRTL
                  ? 'يجب أن يحمل هذا الموظف ترخيصًا ساريًا من [$_authority] لإجراء الفحوصات والإجراءات الطبية في المدارس.'
                  : 'This staff member must hold a valid [$_authority] license to perform clinical actions in schools.',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFB45309)),
            ),
          ),
          const SizedBox(height: 12),
          Text(isRTL ? 'رقم الترخيص (غير قابل للتعديل)' : 'License Number (Read-only)',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary)),
          const SizedBox(height: 4),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(_licenseNum,
                      style: TextStyle(fontSize: 14, fontFamily: 'monospace', color: SchooKeepColors.textSecondary)),
                ),
                const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isRTL ? 'تاريخ انتهاء الترخيص' : 'License Expiry Date',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary)),
                  const Text(_expiryDate,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(isRTL ? 'ساري الصلاحية ✓' : 'Active ✓',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF065F46))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: SchooKeepColors.physicianTeal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _toast(isRTL ? 'جاري فتح بوابة ترخيص هيئة الصحة...' : 'Opening healthcare licensing document portal...'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.upload, size: 16, color: SchooKeepColors.physicianTeal),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(isRTL ? 'تحديث ملف التراخيص أو رفع مستند' : 'Update Credentials / Upload Certificate',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationsCard(bool isRTL) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRTL ? 'إعدادات الإشعارات والتنبيهات' : 'NOTIFICATION CONFIGURATIONS',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          _lockedToggleRow(
            isRTL ? 'بروتوكولات الأدوية الجديدة' : 'New Medication Protocols',
            isRTL ? 'إشعار فوري لمراجعة طلب الممرضة' : 'Instant review request from school nurse',
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _lockedToggleRow(
            isRTL ? 'تصعيدات الطوارئ الطارئة' : 'Emergency Escalations',
            isRTL ? 'تنبيه فوري عند الحالات الحرجة' : 'Critical triage alarms for clinic incidents',
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _toggleRow(
            isRTL ? 'تقارير بانتظار التوقيع المشترك' : 'Reports to Co-Sign',
            isRTL ? 'تذكير بالتقارير الشهرية المرسلة من الممرضة' : 'Remind when monthly reports are submitted',
            _coSignAlerts,
            (v) => setState(() => _coSignAlerts = v),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _toggleRow(
            isRTL ? 'تذكير بجدول الدوام' : 'Schedule Reminders',
            isRTL ? 'تذكير قبل الدوام بيوم واحد في الموقع' : 'Remind 24 hours before your on-site shift',
            _reminders,
            (v) => setState(() => _reminders = v),
          ),
        ],
      ),
    );
  }

  Widget _lockedToggleRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: _rowText(title, subtitle)),
          const SizedBox(width: 8),
          Opacity(opacity: 0.6, child: _switchTrack(true)),
          const SizedBox(width: 8),
          const Icon(LucideIcons.lock, size: 14, color: SchooKeepColors.textSecondary),
        ],
      ),
    );
  }

  Widget _toggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: _rowText(title, subtitle)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: _switchTrack(value),
          ),
        ],
      ),
    );
  }

  Widget _rowText(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
      ],
    );
  }

  Widget _switchTrack(bool on) {
    return Container(
      width: 40,
      height: 20,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: on ? SchooKeepColors.physicianTeal : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: on ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _confidentialityCard(bool isRTL) {
    return SchooKeepCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: const Icon(LucideIcons.shield, size: 20, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isRTL ? 'ميثاق سرية البيانات الطبية' : 'Confidentiality Agreement',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                Text(isRTL ? 'توقيع القانون الطبي: 15/05/2026' : 'Signed Medical Liability: 15/05/2026',
                    style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showConfidentialitySheet(isRTL),
            child: Text(isRTL ? 'عرض الميثاق' : 'View',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
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
                Text(isRTL ? 'تسجيل الخروج؟' : 'Sign out?',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  isRTL ? 'هل أنت متأكد من رغبتك في تسجيل الخروج؟' : 'Are you sure you want to log out of your session?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
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
                            _handleSignOut();
                          },
                          child: Text(isRTL ? 'تسجيل الخروج' : 'Sign out',
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

  void _showConfidentialitySheet(bool isRTL) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.8,
        child: Container(
          decoration: const BoxDecoration(
            color: SchooKeepColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(isRTL ? 'ميثاق سرية البيانات الطبية' : 'Clinical Disclosure Agreement',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(sheetContext).pop(),
                      child: Text(isRTL ? 'إغلاق' : 'Close',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRTL
                            ? 'مستند قانوني للامتثال للمادة الطبية رَقَم 4 لسنة 2016 لدولة الإمارات وقانون حماية البيانات الشخصية الإمارتي (PDPL):'
                            : 'UAE Legal compliance document pursuant to Medical Liability Law No. 4/2016 and UAE Personal Data Protection Law (PDPL):',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary, height: 1.6),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isRTL
                            ? 'يقر المستخدم الموقّع أدناه بمسؤوليته الكاملة عن الحفاظ على سرية سجلات الطلاب الصحية وكافة التشخيصات الطبية والبروتوكولات التي يتم الاطلاع عليها أو اعتمادها عبر التطبيق.'
                            : 'The undersigned practitioner acknowledges full legal responsibility under UAE law for maintaining student record privacy. Personal health records, medication orders, and escalation details accessed herein constitute protected health files.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.6),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isRTL
                            ? 'يخضع هذا الترخيص لرقابة هيئة الصحة بدبي (DHA) وتطبيقات التفتيش الدورية، وأي تسريب أو مشاركة غير مرخصة للملفات الطبية يعرض صاحبها للملاحقة القانونية.'
                            : 'Access logs are monitored in compliance with DHA clinical audit policies. Unauthorized disclosure, sharing, or modification of these files violates medical ethics and Federal laws.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
