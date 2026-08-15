import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'parent_emergency_consent_screen.dart' show DottedBorderBox;
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentPrivacyAgreement.tsx`. Scroll-to-bottom privacy document
/// then a signature step. The source canvas signature is replicated with the
/// shared mock signature pad (tap to sign) — see [DottedBorderBox]. Progress
/// bar at 50%.
class ParentPrivacyAgreementScreen extends StatefulWidget {
  const ParentPrivacyAgreementScreen({super.key});

  @override
  State<ParentPrivacyAgreementScreen> createState() =>
      _ParentPrivacyAgreementScreenState();
}

class _ParentPrivacyAgreementScreenState
    extends State<ParentPrivacyAgreementScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _scrolledToBottom = false;
  bool _isSigning = false;
  bool _signed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrolledToBottom &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 10) {
      setState(() => _scrolledToBottom = true);
    }
  }

  void _handleContinue() {
    if (_signed) {
      context.go('/parent/onboarding/documents');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: false,
      backgroundColor: SchooKeepColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProgressBar(fraction: 0.5),
          SchooKeepAppBar(
            title: context.tr(
              en: 'Step 2 of 4 — Privacy & Data Agreement',
              ar: 'الخطوة 2 من 4 — اتفاقية الخصوصية والبيانات',
            ),
            centerTitle: true,
            onBack: () => context.safeBack(),
          ),
          Expanded(
            child: _isSigning ? _buildSigning(context) : _buildDocument(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDocument(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    en: 'Privacy & Data Usage Agreement',
                    ar: 'اتفاقية الخصوصية واستخدام البيانات',
                  ),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ..._sections(context),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SchooKeepColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SchooKeepColors.border),
                  ),
                  child: Text(
                    context.tr(
                      en: 'By signing below, I acknowledge that I have read, understand, and agree to all terms of this Privacy & Data Usage Agreement.',
                      ar: 'بالتوقيع أدناه، أقر بأنني قرأت وفهمت ووافقت على جميع شروط اتفاقية الخصوصية واستخدام البيانات هذه.',
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: SchooKeepColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: SchooKeepColors.surface,
            border: Border(top: BorderSide(color: SchooKeepColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_scrolledToBottom) ...[
                Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, size: 16, color: SchooKeepColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(
                        en: 'Scroll to bottom to continue',
                        ar: 'مرر إلى الأسفل للمتابعة',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              SchooKeepButton(
                label: context.tr(en: 'Continue to Sign', ar: 'متابعة للتوقيع'),
                enabled: _scrolledToBottom,
                onPressed: () => setState(() => _isSigning = true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _sections(BuildContext context) {
    final sections = <({String title, String body})>[
      (
        title: context.tr(en: '1. Digital Health Record Storage', ar: '1. تخزين السجلات الصحية الرقمية'),
        body: context.tr(
          en: "I consent to the digital storage of my child's health records within the SchooKeep platform. Records are encrypted at rest and in transit using AES-256 encryption and stored on HIPAA-compliant servers located in the United States.",
          ar: 'أوافق على التخزين الرقمي للسجلات الصحية لطفلي داخل منصة SchooKeep. يتم تشفير السجلات أثناء التخزين والنقل باستخدام تشفير AES-256 وتخزينها على خوادم متوافقة مع HIPAA.',
        ),
      ),
      (
        title: context.tr(en: '2. Data Access and Sharing', ar: '2. الوصول إلى البيانات ومشاركتها'),
        body: context.tr(
          en: 'Health records will only be accessible to authorized school personnel with a legitimate educational interest, including: school nurses, administrators, and designated teachers for students with accommodation plans. No data will be shared with third parties without explicit written consent, except as required by law.',
          ar: 'لن تكون السجلات الصحية متاحة إلا لموظفي المدرسة المعتمدين الذين لديهم مصلحة تعليمية مشروعة، بما في ذلك ممرضات المدرسة والإداريين والمعلمين المعينين. لن تتم مشاركة أي بيانات مع أطراف ثالثة دون موافقة كتابية صريحة، إلا حسب ما يقتضيه القانون.',
        ),
      ),
      (
        title: context.tr(en: '3. FERPA Compliance', ar: '3. الامتثال لقانون FERPA'),
        body: context.tr(
          en: "All data handling complies with the Family Educational Rights and Privacy Act (FERPA). You have the right to inspect and review your child's health records, request corrections, and control the disclosure of personally identifiable information.",
          ar: 'يتوافق التعامل مع جميع البيانات مع قانون الحقوق التعليمية والخصوصية للأسرة (FERPA). لديك الحق في فحص ومراجعة السجلات الصحية لطفلك وطلب التصحيحات والتحكم في الكشف عن المعلومات الشخصية.',
        ),
      ),
      (
        title: context.tr(en: '4. Anonymized Research Data Use', ar: '4. استخدام بيانات البحث المجهولة'),
        body: context.tr(
          en: 'De-identified, aggregated data may be used for research purposes to improve health outcomes for K-12 students. All personally identifiable information is removed before data is used for research. Individual students cannot be identified from research data.',
          ar: 'قد تُستخدم البيانات المجمعة مجهولة الهوية لأغراض البحث لتحسين النتائج الصحية للطلاب. تتم إزالة جميع المعلومات الشخصية قبل استخدام البيانات للبحث. لا يمكن التعرف على الطلاب الأفراد من بيانات البحث.',
        ),
      ),
      (
        title: context.tr(en: '5. Data Retention and Deletion', ar: '5. الاحتفاظ بالبيانات وحذفها'),
        body: context.tr(
          en: 'Health records are retained for seven years after the student graduates or withdraws from the district, as required by state law. You may request deletion of non-legally required data at any time by submitting a written request to the school nurse.',
          ar: 'يتم الاحتفاظ بالسجلات الصحية لمدة سبع سنوات بعد تخرج الطالب أو انسحابه، كما يقتضي القانون. يمكنك طلب حذف البيانات غير المطلوبة قانونياً في أي وقت بتقديم طلب كتابي إلى ممرضة المدرسة.',
        ),
      ),
      (
        title: context.tr(en: '6. Parent/Guardian Access Rights', ar: '6. حقوق وصول ولي الأمر'),
        body: context.tr(
          en: "You have 24/7 access to your child's health records through the SchooKeep parent portal. You will receive real-time notifications for: clinic visits, medication administration, health alerts, and document updates. You may export all records in PDF format at any time.",
          ar: 'لديك وصول على مدار الساعة إلى السجلات الصحية لطفلك من خلال بوابة أولياء الأمور SchooKeep. ستتلقى إشعارات فورية لزيارات العيادة وإعطاء الأدوية والتنبيهات الصحية وتحديثات الوثائق. يمكنك تصدير جميع السجلات بصيغة PDF في أي وقت.',
        ),
      ),
      (
        title: context.tr(en: '7. Security Breach Notification', ar: '7. إشعار خرق الأمان'),
        body: context.tr(
          en: "In the unlikely event of a data breach affecting your child's information, you will be notified within 72 hours via email and push notification. The notification will include details about what data was affected and steps being taken to protect your child's information.",
          ar: 'في حالة حدوث خرق للبيانات يؤثر على معلومات طفلك، سيتم إشعارك خلال 72 ساعة عبر البريد الإلكتروني والإشعارات الفورية. سيتضمن الإشعار تفاصيل حول البيانات المتأثرة والخطوات المتخذة لحماية معلومات طفلك.',
        ),
      ),
      (
        title: context.tr(en: '8. Third-Party Service Providers', ar: '8. مقدمو الخدمات من أطراف ثالثة'),
        body: context.tr(
          en: 'SchooKeep uses HIPAA-compliant third-party services for: cloud hosting (AWS), authentication (Auth0), and analytics (privacy-focused, no personal data shared). All vendors have signed Business Associate Agreements (BAAs).',
          ar: 'تستخدم SchooKeep خدمات أطراف ثالثة متوافقة مع HIPAA للاستضافة السحابية (AWS) والمصادقة (Auth0) والتحليلات (تركز على الخصوصية، دون مشاركة بيانات شخصية). وقّع جميع البائعين اتفاقيات الشركاء التجاريين (BAAs).',
        ),
      ),
      (
        title: context.tr(en: '9. Communication Preferences', ar: '9. تفضيلات التواصل'),
        body: context.tr(
          en: 'You consent to receive health-related notifications via: push notifications, SMS text messages, and email. You may update notification preferences at any time in app settings. Critical emergency notifications cannot be disabled.',
          ar: 'توافق على تلقي الإشعارات المتعلقة بالصحة عبر: الإشعارات الفورية والرسائل النصية والبريد الإلكتروني. يمكنك تحديث تفضيلات الإشعارات في أي وقت في إعدادات التطبيق. لا يمكن تعطيل إشعارات الطوارئ الحرجة.',
        ),
      ),
      (
        title: context.tr(en: '10. Agreement Duration and Revocation', ar: '10. مدة الاتفاقية وإلغاؤها'),
        body: context.tr(
          en: "This agreement remains in effect until revoked in writing or until your child is no longer enrolled in the school district. Revocation of consent may affect your child's ability to participate in certain school health services and activities.",
          ar: 'تظل هذه الاتفاقية سارية حتى يتم إلغاؤها كتابياً أو حتى لا يعود طفلك مسجلاً في المنطقة المدرسية. قد يؤثر إلغاء الموافقة على قدرة طفلك على المشاركة في خدمات وأنشطة صحية مدرسية معينة.',
        ),
      ),
    ];
    return [
      for (final s in sections) ...[
        const SizedBox(height: 8),
        Text(
          s.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: SchooKeepColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          s.body,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: SchooKeepColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
      ],
    ];
  }

  Widget _buildSigning(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr(en: 'Sign Below', ar: 'وقّع أدناه'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: SchooKeepColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              en: 'Draw your signature with your finger or stylus',
              ar: 'ارسم توقيعك بإصبعك أو القلم',
            ),
            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GestureDetector(
              onTap: _signed ? null : () => setState(() => _signed = true),
              child: DottedBorderBox(
                child: Center(
                  child: _signed
                      ? const Text(
                          'Jennifer Thompson',
                          style: TextStyle(
                            fontSize: 28,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF1F2937),
                            fontFamily: 'cursive',
                          ),
                        )
                      : Text(
                          context.tr(en: 'Tap to sign', ar: 'اضغط للتوقيع'),
                          style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SchooKeepColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.border),
            ),
            child: Column(
              children: [
                _kvRow(context.tr(en: 'Date', ar: 'التاريخ'), 'May 25, 2026'),
                const SizedBox(height: 8),
                _kvRow(
                  context.tr(en: 'Parent/Guardian', ar: 'ولي الأمر'),
                  'Jennifer Thompson',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SchooKeepButton(
                  label: context.tr(en: 'Clear', ar: 'مسح'),
                  variant: SchooKeepButtonVariant.outline,
                  onPressed: () => setState(() => _signed = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SchooKeepButton(
                  label: context.tr(en: 'Sign & Continue', ar: 'وقّع وتابع'),
                  enabled: _signed,
                  onPressed: _handleContinue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kvRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: SchooKeepColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: Row(
        children: [
          Expanded(
            flex: (fraction * 1000).round(),
            child: const ColoredBox(color: SchooKeepColors.primary),
          ),
          Expanded(
            flex: 1000 - (fraction * 1000).round(),
            child: const ColoredBox(color: Color(0xFFF3F4F6)),
          ),
        ],
      ),
    );
  }
}
