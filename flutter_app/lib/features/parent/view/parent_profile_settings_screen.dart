import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentProfileSettings.tsx`. Profile header, linked children,
/// notification preference toggles (emergency alerts locked on), authorized
/// persons link, legal & privacy (signed consents, data export, withdraw
/// consent) and a sign-out button. Data is mock; toggles use setState.
class ParentProfileSettingsScreen extends StatefulWidget {
  const ParentProfileSettingsScreen({super.key});

  @override
  State<ParentProfileSettingsScreen> createState() =>
      _ParentProfileSettingsScreenState();
}

class _ParentProfileSettingsScreenState
    extends State<ParentProfileSettingsScreen> {
  bool _clinicVisits = true;
  bool _medicationAdministered = true;
  bool _busBoardingArrival = true;
  bool _documentReminders = true;
  bool _schoolAnnouncements = false;

  void _withdrawConsent() {
    final isRTL = context.isRTL;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRTL
            ? 'سحب الموافقة سيؤدي إلى تعطيل حسابك وتقييد الوصول إلى خدمات المدرسة. يتطلب هذا الإجراء مراجعة المسؤول.'
            : 'Withdrawing consent will deactivate your account and restrict access to school services. This action requires administrator review.'),
      ),
    );
  }

  void _showInfoDialog({required String title, required String message}) {
    final isRTL = context.isRTL;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SchooKeepColors.surface,
        title: Text(title,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
        content: Text(message,
            style: const TextStyle(fontSize: 14, height: 1.5, color: SchooKeepColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(isRTL ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    final isRTL = context.isRTL;
    _showInfoDialog(
      title: isRTL ? 'تعديل الملف الشخصي' : 'Edit profile',
      message: isRTL
          ? 'تتم إدارة تفاصيل ملفك الشخصي بواسطة مكتب المدرسة. يرجى التواصل مع المدرسة لتحديث اسمك أو معلومات الاتصال.'
          : 'Your profile details are managed by the school office. Please contact the school to update your name or contact information.',
    );
  }

  void _addChild() {
    final isRTL = context.isRTL;
    _showInfoDialog(
      title: isRTL ? 'إضافة طفل' : 'Add child',
      message: isRTL
          ? 'يتم ربط الأطفال بحسابك من خلال رمز تسجيل المدرسة أثناء الإعداد. تواصل مع مكتب المدرسة لربط طفل إضافي.'
          : 'Children are linked to your account via a school enrollment code during setup. Contact the school office to link an additional child.',
    );
  }

  void _viewConsent(String title) {
    final isRTL = context.isRTL;
    _showInfoDialog(
      title: title,
      message: isRTL
          ? 'تم توقيع هذه الموافقة وحفظها في سجلات المدرسة. النسخة الموقّعة الكاملة متاحة عند الطلب الكتابي من مكتب المدرسة.'
          : 'This consent has been signed and is stored in the school records. The full signed copy is available on written request from the school office.',
    );
  }

  void _requestDataExport() {
    final isRTL = context.isRTL;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRTL
            ? 'تم تقديم طلب تصدير البيانات. ستتلقى سجلاتك عبر البريد الإلكتروني خلال 30 يوماً وفقاً لـ FERPA.'
            : 'Data export request submitted. You will receive your records by email within 30 days per FERPA.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: isRTL ? 'الملف الشخصي والإعدادات' : 'Profile & Settings',
        onBack: () => context.safeBack(),
      ),
      padding: EdgeInsets.zero,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileHeader(isRTL),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _linkedChildren(isRTL),
                const SizedBox(height: 24),
                _notificationPrefs(isRTL),
                const SizedBox(height: 24),
                _authorizedPersons(isRTL),
                const SizedBox(height: 24),
                _legalPrivacy(isRTL),
                const SizedBox(height: 24),
                // Sign out
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: SchooKeepColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: SchooKeepColors.error),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.go('/login'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(isRTL ? 'تسجيل الخروج' : 'Sign out',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: SchooKeepColors.error)),
                        ),
                      ),
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

  Widget _profileHeader(bool isRTL) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('JT',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.primary)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRTL ? 'جيمس طومسون' : 'James Thompson',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(isRTL ? 'ولي أمر / وصي' : 'Parent / Guardian',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: SchooKeepColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _editProfile,
            child: Text(isRTL ? 'تعديل الملف الشخصي' : 'Edit profile',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SchooKeepColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: SchooKeepColors.textPrimary)),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: SchooKeepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SchooKeepColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _linkedChildren(bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(isRTL ? 'الأطفال المرتبطون' : 'Linked Children'),
        _card(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: Color(0xFFEDE9FE), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Text('MT',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7C3AED))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isRTL ? 'مايا طومسون' : 'Maya Thompson',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: SchooKeepColors.textPrimary)),
                          Text(
                            isRTL
                                ? 'الصف الرابع • مدرسة لينكولن الابتدائية'
                                : '4th Grade • Lincoln Elementary',
                            style: const TextStyle(
                                fontSize: 13,
                                color: SchooKeepColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 52),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: isRTL
                                ? 'الملف الصحي: '
                                : 'Health profile: '),
                        TextSpan(
                          text: isRTL ? 'نشط ✓' : 'Active ✓',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: SchooKeepColors.accent),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                        fontSize: 13, color: SchooKeepColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          // Add child row
          InkWell(
            onTap: _addChild,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.plus,
                        size: 20, color: SchooKeepColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Text(isRTL ? 'إضافة طفل' : 'Add child',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: SchooKeepColors.primary)),
                ],
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _notificationPrefs(bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
            isRTL ? 'تفضيلات الإشعارات' : 'Notification Preferences'),
        _card(children: [
          // Emergency alerts - LOCKED
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(LucideIcons.alertTriangle,
                    size: 20, color: SchooKeepColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isRTL ? 'تنبيهات الطوارئ' : 'Emergency alerts',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: SchooKeepColors.textPrimary)),
                      Text(
                        isRTL
                            ? 'مطلوب بموجب سياسة المدرسة'
                            : 'Required by school policy',
                        style: const TextStyle(
                            fontSize: 12,
                            color: SchooKeepColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: 0.6,
                  child: _toggle(value: true, onChanged: null),
                ),
                const SizedBox(width: 8),
                const Icon(LucideIcons.shield,
                    size: 16, color: SchooKeepColors.textSecondary),
              ],
            ),
          ),
          _toggleRow(
              isRTL ? 'زيارات العيادة' : 'Clinic visits', _clinicVisits,
              (v) => setState(() => _clinicVisits = v)),
          _toggleRow(
              isRTL ? 'إعطاء الدواء' : 'Medication administered',
              _medicationAdministered,
              (v) => setState(() => _medicationAdministered = v)),
          _toggleRow(
              isRTL ? 'صعود/وصول الحافلة' : 'Bus boarding/arrival',
              _busBoardingArrival,
              (v) => setState(() => _busBoardingArrival = v)),
          _toggleRow(
              isRTL ? 'تذكيرات المستندات' : 'Document reminders',
              _documentReminders,
              (v) => setState(() => _documentReminders = v)),
          _toggleRow(
              isRTL ? 'إعلانات المدرسة' : 'School announcements',
              _schoolAnnouncements,
              (v) => setState(() => _schoolAnnouncements = v)),
        ]),
      ],
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SchooKeepColors.textPrimary)),
          ),
          _toggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _toggle({required bool value, required ValueChanged<bool>? onChanged}) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged(!value),
      child: Container(
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? SchooKeepColors.primary : const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Align(
          alignment:
              value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  Widget _authorizedPersons(bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(isRTL ? 'الأشخاص المخوّلون' : 'Authorized Persons'),
        Material(
          color: SchooKeepColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: SchooKeepColors.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.go('/parent/app/authorized-persons'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(LucideIcons.user,
                      size: 20, color: SchooKeepColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isRTL
                          ? 'إدارة تخويلات الاستلام'
                          : 'Manage pickup authorizations',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: SchooKeepColors.textPrimary),
                    ),
                  ),
                  const RtlIcon(LucideIcons.chevronRight,
                      size: 20, color: SchooKeepColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _legalPrivacy(bool isRTL) {
    final consents = [
      (
        title: isRTL ? 'اتفاقية خصوصية FERPA' : 'FERPA Privacy Agreement',
        date: isRTL ? 'تم التوقيع 15/08/2025' : 'Signed 08/15/2025'
      ),
      (
        title: isRTL
            ? 'موافقة العلاج الطبي الطارئ'
            : 'Emergency Medical Treatment Consent',
        date: isRTL ? 'تم التوقيع 15/08/2025' : 'Signed 08/15/2025'
      ),
      (
        title: isRTL ? 'إذن الصور والفيديو' : 'Photo & Video Release',
        date: isRTL ? 'تم التوقيع 15/08/2025' : 'Signed 08/15/2025'
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(isRTL ? 'القانونية والخصوصية' : 'Legal & Privacy'),
        _card(children: [
          // Signed consents
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isRTL ? 'موافقاتي الموقّعة' : 'My signed consents',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 12),
                for (final c in consents)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.title,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: SchooKeepColors.textPrimary)),
                              Text(c.date,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: SchooKeepColors.textSecondary)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _viewConsent(c.title),
                          child: Text(isRTL ? 'عرض' : 'View',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: SchooKeepColors.primary)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Request data export
          InkWell(
            onTap: _requestDataExport,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(LucideIcons.download,
                      size: 20, color: SchooKeepColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            isRTL
                                ? 'طلب تصدير البيانات'
                                : 'Request data export',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: SchooKeepColors.textPrimary)),
                        Text(
                          isRTL
                              ? 'حق FERPA في الوصول إلى السجلات'
                              : 'FERPA right to access records',
                          style: const TextStyle(
                              fontSize: 12,
                              color: SchooKeepColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const RtlIcon(LucideIcons.chevronRight,
                      size: 20, color: SchooKeepColors.textSecondary),
                ],
              ),
            ),
          ),
          // Withdraw consent
          InkWell(
            onTap: _withdrawConsent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertTriangle,
                      size: 20, color: SchooKeepColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isRTL ? 'سحب الموافقة' : 'Withdraw consent',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: SchooKeepColors.error)),
                        Text(
                          isRTL
                              ? 'سيتم عرض تحذير بالتأثير'
                              : 'Impact warning will be shown',
                          style: const TextStyle(
                              fontSize: 12,
                              color: SchooKeepColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const RtlIcon(LucideIcons.chevronRight,
                      size: 20, color: SchooKeepColors.textSecondary),
                ],
              ),
            ),
          ),
        ]),
      ],
    );
  }
}
