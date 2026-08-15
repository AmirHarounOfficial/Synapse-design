import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentNotificationSettings.tsx`. Per-channel notification
/// toggles grouped by category; emergency alerts are locked on.
class ParentNotificationSettingsScreen extends StatefulWidget {
  const ParentNotificationSettingsScreen({super.key});

  @override
  State<ParentNotificationSettingsScreen> createState() =>
      _ParentNotificationSettingsScreenState();
}

class _ParentNotificationSettingsScreenState
    extends State<ParentNotificationSettingsScreen> {
  bool _clinicPush = true;
  bool _clinicSMS = true;
  bool _clinicEmail = false;
  bool _medicationPush = true;
  bool _medicationSMS = false;
  bool _documentsPush = true;
  bool _documentsEmail = true;
  static const bool _emergencyPush = true;
  static const bool _emergencySMS = true;

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return SchooKeepScaffold(
      reserveBottomNav: true,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'تفضيلات الإشعارات' : 'Notification Preferences',
        centerTitle: true,
        onBack: () => context.safeBack(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clinic Alerts
            _sectionTitle(isRTL ? 'تنبيهات العيادة' : 'Clinic Alerts'),
            const SizedBox(height: 12),
            _group([
              _row(
                title: isRTL ? 'إشعارات فورية' : 'Push Notifications',
                subtitle: isRTL ? 'تنبيهات فورية على جهازك' : 'Real-time alerts on your device',
                value: _clinicPush,
                onChanged: (v) => setState(() => _clinicPush = v),
              ),
              _row(
                title: isRTL ? 'رسائل SMS النصية' : 'SMS Text Messages',
                subtitle: isRTL ? 'إشعارات الرسائل النصية' : 'Text message notifications',
                value: _clinicSMS,
                onChanged: (v) => setState(() => _clinicSMS = v),
              ),
              _row(
                title: isRTL ? 'البريد الإلكتروني' : 'Email',
                subtitle: isRTL ? 'ملخصات البريد الإلكتروني' : 'Email summaries',
                value: _clinicEmail,
                onChanged: (v) => setState(() => _clinicEmail = v),
              ),
            ]),
            const SizedBox(height: 24),
            // Medication
            _sectionTitle(isRTL ? 'الدواء' : 'Medication'),
            const SizedBox(height: 12),
            _group([
              _row(
                title: isRTL ? 'إشعارات فورية' : 'Push Notifications',
                subtitle: isRTL ? 'تأكيدات الجرعات والتذكيرات' : 'Dose confirmations and reminders',
                value: _medicationPush,
                onChanged: (v) => setState(() => _medicationPush = v),
              ),
              _row(
                title: isRTL ? 'رسائل SMS النصية' : 'SMS Text Messages',
                subtitle: isRTL ? 'تأكيدات الرسائل النصية' : 'Text message confirmations',
                value: _medicationSMS,
                onChanged: (v) => setState(() => _medicationSMS = v),
              ),
            ]),
            const SizedBox(height: 24),
            // Documents
            _sectionTitle(isRTL ? 'المستندات' : 'Documents'),
            const SizedBox(height: 12),
            _group([
              _row(
                title: isRTL ? 'إشعارات فورية' : 'Push Notifications',
                subtitle: isRTL
                    ? 'حالة الموافقة وتذكيرات انتهاء الصلاحية'
                    : 'Approval status and expiry reminders',
                value: _documentsPush,
                onChanged: (v) => setState(() => _documentsPush = v),
              ),
              _row(
                title: isRTL ? 'البريد الإلكتروني' : 'Email',
                subtitle: isRTL ? 'تحديثات حالة المستندات' : 'Document status updates',
                value: _documentsEmail,
                onChanged: (v) => setState(() => _documentsEmail = v),
              ),
            ]),
            const SizedBox(height: 24),
            // Emergency (locked)
            _sectionTitle(isRTL ? 'الطوارئ' : 'Emergency'),
            const SizedBox(height: 12),
            _group([
              _row(
                title: isRTL ? 'إشعارات فورية' : 'Push Notifications',
                subtitle: isRTL ? 'تنبيهات الطوارئ الحرجة (مطلوبة)' : 'Critical emergency alerts (required)',
                value: _emergencyPush,
                onChanged: null,
                locked: true,
              ),
              _row(
                title: isRTL ? 'رسائل SMS النصية' : 'SMS Text Messages',
                subtitle: isRTL ? 'تنبيهات الطوارئ النصية (مطلوبة)' : 'Emergency text alerts (required)',
                value: _emergencySMS,
                onChanged: null,
                locked: true,
              ),
            ]),
            const SizedBox(height: 24),
            // Emergency info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.error),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isRTL ? 'لا يمكن تعطيل تنبيهات الطوارئ' : 'Emergency Alerts Cannot Be Disabled',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRTL
                        ? 'من أجل سلامة طفلك، تظل إشعارات الطوارئ مفعّلة دائماً ولا يمكن إيقافها. تُرسل هذه التنبيهات فقط في الحالات الحرجة التي تتطلب تفويضاً أو إخطاراً فورياً من ولي الأمر.'
                        : "For your child's safety, emergency notifications are always enabled and cannot be turned off. These alerts are only sent for critical situations requiring immediate parent authorization or notification.",
                    style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: SchooKeepColors.textPrimary,
        ),
      );

  Widget _group(List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) {
        children.add(const Divider(height: 1, color: Color(0xFFF1F5F9)));
      }
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

  Widget _row({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool locked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: SchooKeepColors.textPrimary)),
                    ),
                    if (locked) ...[
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.accent),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: locked ? SchooKeepColors.accent : SchooKeepColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }
}
