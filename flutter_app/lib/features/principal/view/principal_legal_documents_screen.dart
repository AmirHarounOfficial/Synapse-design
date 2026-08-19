import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

class PrincipalLegalDocumentsScreen extends StatelessWidget {
  const PrincipalLegalDocumentsScreen({super.key});

  static const _signedDocuments = <_SignedDoc>[
    _SignedDoc('Platform Data Processing Agreement (DPA) · UAE PDPL Compliant', '2026-05-01'),
    _SignedDoc('UAE PDPL Controller-Processor Declaration', '2026-05-01'),
    _SignedDoc('Dubai DHA Medical Liability Disclaimer', '2026-05-01'),
  ];

  static const _consentTotal = 487;
  static const _consentActive = 458;
  static const _consentIncomplete = 3;
  static const _consentPercentage = 94;

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: true,
      title: context.tr(en: 'Legal & Compliance', ar: 'الوثائق القانونية والامتثال'),
      onBack: () => context.safeBack(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _jurisdictionBanner(context),
            const SizedBox(height: 16),
            _govIntegration(context),
            const SizedBox(height: 16),
            _dpoCard(context),
            const SizedBox(height: 16),
            _pendingSection(context),
            const SizedBox(height: 16),
            _signedDocsSection(context),
            const SizedBox(height: 16),
            _consentStatusCard(context),
            const SizedBox(height: 16),
            _legalFramework(context),
            const SizedBox(height: 16),
            _documentTypes(context),
          ],
        ),
      ),
    );
  }

  Widget _jurisdictionBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFEFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA5F3FC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(en: 'ACTIVE JURISDICTION', ar: 'النطاق القضائي والترخيص'),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0E7490), letterSpacing: 1.2),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(en: '🇦🇪 Emirate of Dubai', ar: '🇦🇪 إمارة دبي — الإمارات العربية المتحدة'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF164E63)),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(en: 'Governed by UAE PDPL & DHA School Health Guidelines', ar: 'خاضع لقانون حماية البيانات الشخصية ولائحة صحة المدارس بهيئة الصحة بدبي'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF0891B2)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF0E7490), borderRadius: BorderRadius.circular(4)),
            child: Text(
              context.tr(en: 'DHA COMPLIANT', ar: 'معتمد DHA'),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _govIntegration(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(context.tr(en: 'Government Systems Integration', ar: 'الربط الإلكتروني مع الأنظمة الحكومية')),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(en: 'HASANA Integration', ar: 'نظام حصانة (HASANA) - هيئة الصحة بدبي'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(en: 'Dubai DHA Immunization Sync', ar: 'مزامنة سجل التطعيمات والتحصينات لطلاب دبي'),
                        style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    context.tr(en: 'Authorized & Active', ar: 'نشط ومصرح ✓'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  context.tr(en: 'Upload DPO certificate', ar: 'رفع شهادة مسؤل حماية البيانات'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.fileText, color: SchooKeepColors.primary),
              title: Text(context.tr(en: 'Choose PDF from device', ar: 'اختيار ملف PDF من الجهاز')),
              subtitle: Text(context.tr(en: 'UAE PDPL DPO appointment certificate · Max 5MB', ar: 'شهادة تعيين DPO طبقاً للقانون الإماراتي (الحد الأقصى 5 ميجابايت)')),
              onTap: () {
                Navigator.pop(sheetCtx);
                _snack(context, context.tr(en: 'Certificate upload started…', ar: 'بدأ رفع الشهادة...'));
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: SchooKeepColors.primary),
              title: Text(context.tr(en: 'Scan document', ar: 'مسح المستند بالكاميرا')),
              onTap: () {
                Navigator.pop(sheetCtx);
                _snack(context, context.tr(en: 'Document scanner opening…', ar: 'جاري فتح الماسح الضوئي...'));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmResign(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Text(context.tr(en: 'Review & Re-sign DPA', ar: 'مراجعة وإعادة توقيع اتفاقية معالجة البيانات')),
        content: Text(context.tr(
          en: 'The Data Processing Agreement renewal is due June 1, 2026. Re-signing renews the agreement for another term under the UAE PDPL.',
          ar: 'تجديد اتفاقية معالجة البيانات مستحق في 1 يونيو 2026. التوقيع يجدد الاتفاقية لفترة جديدة وفق قانون البيانات الإماراتي.',
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlgCtx, false), child: Text(context.tr(en: 'Cancel', ar: 'إلغاء'))),
          TextButton(onPressed: () => Navigator.pop(dlgCtx, true), child: Text(context.tr(en: 'Re-sign', ar: 'إعادة التوقيع'))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      _snack(context, context.tr(en: 'DPA re-signed — renewal recorded', ar: 'تمت إعادة توقيع الاتفاقية وتسجيل التجديد'));
    }
  }

  Widget _dpoCard(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(context.tr(en: 'Data Protection Officer (DPO)', ar: 'مسؤول حماية البيانات (DPO)')),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SchooKeepColors.border, width: 2),
            ),
            child: Column(
              children: [
                const Icon(LucideIcons.fileText, size: 32, color: Color(0xFF9CA3AF)),
                const SizedBox(height: 8),
                Text(
                  context.tr(en: 'DPO Registration Certificate', ar: 'شهادة تسجيل مسؤول حماية البيانات'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(en: 'Upload your UAE PDPL DPO appointment certificate (PDF, Max 5MB)', ar: 'رفع شهادة التكليف الرسمية لمسؤول حماية البيانات (PDF, حد أقصى 5 ميجابايت)'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('dpo_certificate_dubai.pdf',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 6,
                            height: 6,
                            child: DecoratedBox(
                                decoration: BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.tr(en: 'Verified', ar: 'موثق ✓'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF059669)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showUploadSheet(context),
                  child: Text(
                    context.tr(en: 'Re-upload certificate', ar: 'إعادة رفع الشهادة'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
            const SizedBox(width: 8),
            Text(
              context.tr(en: 'Pending Actions', ar: 'الإجراءات المطلوبة'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.warning),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SchooKeepColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.warning),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.fileText, size: 20, color: SchooKeepColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(en: 'Renewal Required', ar: 'تجديد الاتفاقية مطلوب'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(en: 'DPA renewal due June 1, 2026', ar: 'تجديد اتفاقية معالجة البيانات مستحق في 1 يونيو 2026'),
                          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: SchooKeepColors.warning,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _confirmResign(context),
                  child: Text(
                    context.tr(en: 'Review & Re-sign', ar: 'المراجعة وإعادة التوقيع'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _signedDocsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(context.tr(en: 'Signed Documents', ar: 'المستندات والاتفاقيات الموقعة')),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: SchooKeepColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _signedDocuments.length; i++) ...[
                if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                _signedDocTile(context, _signedDocuments[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _signedDocTile(BuildContext context, _SignedDoc doc) {
    final parts = doc.signedDate.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final lang = context.isRTL ? 'ar' : 'en';
    final formatted = DateFormatter.formatGregorianLong(date, lang);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
            child: const Icon(LucideIcons.lock, size: 20, color: SchooKeepColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  context.tr(en: 'Signed $formatted', ar: 'موقع بتاريخ $formatted'),
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _snack(context, context.tr(en: 'Opening "${doc.name}"…', ar: 'جاري فتح "${doc.name}"...')),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.eye, size: 16, color: SchooKeepColors.primary),
                const SizedBox(width: 4),
                Text(
                  context.tr(en: 'View', ar: 'عرض'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _consentStatusCard(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(context.tr(en: 'Parent Consent Status', ar: 'حالة موافقات أولياء الأمور')),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.tr(
                    en: '$_consentActive of $_consentTotal students have active parent consent',
                    ar: '$_consentActive من أصل $_consentTotal طالب لديهم موافقة ولي أمر نشطة',
                  ),
                  style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                ),
              ),
              const Text('$_consentPercentage%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.accent)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: _consentPercentage / 100,
              minHeight: 12,
              backgroundColor: Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(SchooKeepColors.accent),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr(en: 'Incomplete consents', ar: 'موافقات غير مكتملة'),
                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
              ),
              GestureDetector(
                onTap: () => _snack(context, context.tr(
                  en: '$_consentIncomplete student(s) missing parent consent — follow-up required',
                  ar: '$_consentIncomplete طالب/طلاب بحاجة لمتابعة موافقة ولي الأمر',
                )),
                child: Text(
                  context.tr(en: '$_consentIncomplete incomplete', ar: '$_consentIncomplete غير مكتملة'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.warning),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legalFramework(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Legal Framework', ar: 'المرجعية التشريعية والقانونية'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 8),
          _frameworkLine(
            context.tr(en: 'UAE PDPL', ar: 'قانون حماية البيانات الإماراتي (PDPL)'),
            context.tr(en: ' (Federal Decree-Law No. 45 of 2021) governs general data privacy protections', ar: ' (المرسوم بقانون اتحادي رقم 45 لسنة 2021) ينظم حماية البيانات الشخصية.'),
          ),
          _frameworkLine(
            context.tr(en: 'DHA Guidelines', ar: 'لوائح هيئة الصحة بدبي'),
            context.tr(en: ' protect student clinical data and DHA school clinic operating procedures', ar: ' تحمي البيانات الطبية وتحدد إجراءات تشغيل العيادات المدرسية.'),
          ),
          _frameworkLine(
            context.tr(en: 'HASANA Sync Protocols', ar: 'بروتوكولات ربط حصنة (HASANA)'),
            context.tr(en: ' dictate mandatory reporting of childhood immunizations', ar: ' تنظم الإبلاغ الإلزامي عن تطعيمات الطلاب.'),
          ),
        ],
      ),
    );
  }

  Widget _frameworkLine(String bold, String rest) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: SizedBox(
              width: 6,
              height: 6,
              child: DecoratedBox(decoration: BoxDecoration(color: SchooKeepColors.primary, shape: BoxShape.circle)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: bold,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary)),
                TextSpan(text: rest, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentTypes(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Document Types', ar: 'أنواع المستندات والاتفاقيات'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _docType(
            context.tr(en: 'Platform Data Processing Agreement (DPA)', ar: 'اتفاقية معالجة البيانات عبر المنصة (DPA)'),
            context.tr(
              en: 'Defines how student data is processed, stored, and protected by the SchooKeep platform in accordance with the UAE PDPL.',
              ar: 'تحدد كيفية معالجة وحفظ وحماية بيانات الطلاب من خلال منصة SchooKeep وفقاً للقانون الإماراتي.',
            ),
          ),
          const SizedBox(height: 12),
          _docType(
            context.tr(en: 'UAE PDPL Controller-Processor Declaration', ar: 'إقرار المسؤول والمعالج لحماية البيانات الإماراتي'),
            context.tr(
              en: 'Delineates the responsibilities of the school (Controller) and SchooKeep (Processor) under the Federal Decree-Law No. 45 of 2021.',
              ar: 'يحدد مسؤوليات المدرسة (المسؤول) ومنصة SchooKeep (المعالج) بموجب المرسوم بقانون اتحادي رقم 45 لسنة 2021.',
            ),
          ),
          const SizedBox(height: 12),
          _docType(
            context.tr(en: 'DHA Medical Liability Disclaimer', ar: 'إخلاء المسؤولية الطبية بهيئة الصحة بدبي (DHA)'),
            context.tr(
              en: 'Clarifies DHA clinic licensing operational protocols, emergency consent scopes, and platform disclaimer boundaries.',
              ar: 'يوضح بروتوكولات ترخيص العيادة المدرسية ونطاق موافقة الطوارئ وحدود إخلاء المسؤولية.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _docType(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary, height: 1.5)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary));
}

class _SignedDoc {
  const _SignedDoc(this.name, this.signedDate);
  final String name;
  final String signedDate;
}
