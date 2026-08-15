import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentDocumentExpiryAlert.tsx`. Lists documents expiring soon
/// with urgency-tinted cards (red < 7 days, amber < 30, blue otherwise) and an
/// "Upload Now" CTA that routes to the document upload screen. Data is mock.
class ParentDocumentExpiryAlertScreen extends StatelessWidget {
  const ParentDocumentExpiryAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    final docs = _documents(isRTL);

    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(
        title: isRTL ? 'تجديد المستندات' : 'Document Renewals',
        centerTitle: true,
        onBack: () => context.safeBack(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.error),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.alertTriangle,
                      size: 20, color: SchooKeepColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRTL ? 'مطلوب اتخاذ إجراء' : 'Action Required',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF991B1B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isRTL
                              ? 'عدد ${docs.length} مستندات تنتهي قريباً. يرجى رفع المستندات المجددة لتجنب التأخير في الرعاية.'
                              : '${docs.length} documents expiring soon. Please upload renewed documents to avoid delays in care.',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF991B1B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final doc in docs) ...[
              _documentCard(context, doc, isRTL),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL
                        ? 'لماذا تجديد المستندات مهم'
                        : 'Why Document Renewal is Important',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRTL
                        ? 'قد تمنع المستندات منتهية الصلاحية ممرضة المدرسة من إعطاء الدواء أو تقديم الرعاية اللازمة. يرجى رفع المستندات المجددة في أقرب وقت ممكن.'
                        : 'Expired documents may prevent the school nurse from administering medication or providing necessary care. Please upload renewed documents as soon as possible.',
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Format requirements
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SchooKeepColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL ? 'صيغ الملفات المقبولة' : 'Acceptable File Formats',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: SchooKeepColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  _bullet(isRTL
                      ? 'مستندات PDF (مفضّلة)'
                      : 'PDF documents (preferred)'),
                  _bullet(isRTL
                      ? 'صور واضحة (JPG، PNG)'
                      : 'Clear photos (JPG, PNG)'),
                  _bullet(isRTL
                      ? 'الحد الأقصى لحجم الملف: 10 ميغابايت'
                      : 'Maximum file size: 10MB'),
                  _bullet(isRTL
                      ? 'يجب أن يكون كل النص مقروءاً'
                      : 'All text must be legible'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _documentCard(
      BuildContext context, _ExpiringDocument doc, bool isRTL) {
    final cfg = _urgencyConfig(doc.daysUntilExpiry);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cfg.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.fileText, size: 20, color: cfg.text),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar,
                            size: 14, color: SchooKeepColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          isRTL
                              ? 'تنتهي ${doc.expiryDate}'
                              : 'Expires ${doc.expiryDate}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: SchooKeepColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cfg.badgeBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isRTL
                      ? '${doc.daysUntilExpiry} ${doc.daysUntilExpiry == 1 ? 'يوم' : 'أيام'}'
                      : '${doc.daysUntilExpiry} ${doc.daysUntilExpiry == 1 ? 'day' : 'days'}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Requirements
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRTL ? 'متطلبات الرفع:' : 'Upload Requirements:',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 8),
                for (final req in doc.requirements) _bullet(req, fontSize: 11),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.textPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.go('/parent/app/document-upload'),
              child: Text(
                isRTL ? 'رفع الآن' : 'Upload Now',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text, {double fontSize = 12}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: TextStyle(
                  fontSize: fontSize, color: SchooKeepColors.textSecondary)),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: fontSize, color: SchooKeepColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  _UrgencyConfig _urgencyConfig(int days) {
    if (days < 7) {
      return const _UrgencyConfig(
        bg: Color(0xFFFEE2E2),
        border: SchooKeepColors.error,
        text: SchooKeepColors.error,
        badgeBg: SchooKeepColors.error,
      );
    } else if (days < 30) {
      return const _UrgencyConfig(
        bg: Color(0xFFFEF3C7),
        border: SchooKeepColors.warning,
        text: SchooKeepColors.warning,
        badgeBg: SchooKeepColors.warning,
      );
    }
    return const _UrgencyConfig(
      bg: Color(0xFFF0F9FF),
      border: Color(0xFF0369A1),
      text: Color(0xFF0369A1),
      badgeBg: Color(0xFF0369A1),
    );
  }

  List<_ExpiringDocument> _documents(bool isRTL) {
    return [
      _ExpiringDocument(
        id: '1',
        name: isRTL ? 'بطاقة التأمين الصحي' : 'Health Insurance Card',
        expiryDate: isRTL ? '22 يونيو 2026' : 'June 22, 2026',
        daysUntilExpiry: 28,
        requirements: isRTL
            ? [
                'صور للوجه الأمامي والخلفي للبطاقة الجديدة',
                'يجب أن تكون واضحة ومقروءة',
                'جميع المعلومات مرئية',
              ]
            : [
                'Front and back photos of new card',
                'Must be clear and legible',
                'All information visible',
              ],
      ),
      _ExpiringDocument(
        id: '2',
        name: isRTL ? 'خطة الرعاية الطبية' : 'Physician Care Plan',
        expiryDate: isRTL ? '10 يونيو 2026' : 'June 10, 2026',
        daysUntilExpiry: 16,
        requirements: isRTL
            ? [
                'خطة رعاية محدّثة موقّعة من الطبيب',
                'مطلوب صيغة PDF',
                'يجب أن تتضمن السنة الحالية',
              ]
            : [
                'Updated care plan signed by physician',
                'PDF format required',
                'Must include current year',
              ],
      ),
      _ExpiringDocument(
        id: '3',
        name: isRTL ? 'نموذج جهة اتصال الطوارئ' : 'Emergency Contact Form',
        expiryDate: isRTL ? '2 يونيو 2026' : 'June 2, 2026',
        daysUntilExpiry: 8,
        requirements: isRTL
            ? [
                'معلومات جهة اتصال الطوارئ المحدّثة',
                'مطلوب توقيع ولي الأمر/الوصي',
                'تم التحقق من جميع أرقام الهواتف',
              ]
            : [
                'Updated emergency contact information',
                'Parent/guardian signature required',
                'All phone numbers verified',
              ],
      ),
      _ExpiringDocument(
        id: '4',
        name: isRTL ? 'خطة التعامل مع الحساسية' : 'Allergy Action Plan',
        expiryDate: isRTL ? '29 مايو 2026' : 'May 29, 2026',
        daysUntilExpiry: 4,
        requirements: isRTL
            ? [
                'خطة محدّثة من أخصائي الحساسية',
                'أوامر الأدوية الحالية',
                'مطلوب توقيع ولي الأمر والطبيب',
              ]
            : [
                'Updated plan from allergist',
                'Current medication orders',
                'Parent and physician signatures required',
              ],
      ),
    ];
  }
}

class _ExpiringDocument {
  const _ExpiringDocument({
    required this.id,
    required this.name,
    required this.expiryDate,
    required this.daysUntilExpiry,
    required this.requirements,
  });
  final String id;
  final String name;
  final String expiryDate;
  final int daysUntilExpiry;
  final List<String> requirements;
}

class _UrgencyConfig {
  const _UrgencyConfig({
    required this.bg,
    required this.border,
    required this.text,
    required this.badgeBg,
  });
  final Color bg;
  final Color border;
  final Color text;
  final Color badgeBg;
}
