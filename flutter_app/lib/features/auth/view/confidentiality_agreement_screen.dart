import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class ConfidentialityAgreementScreen extends StatefulWidget {
  const ConfidentialityAgreementScreen({super.key});

  @override
  State<ConfidentialityAgreementScreen> createState() => _ConfidentialityAgreementScreenState();
}

class _ConfidentialityAgreementScreenState extends State<ConfidentialityAgreementScreen> {
  final ScrollController _scroll = ScrollController();
  double _progress = 0;
  bool _atBottom = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    final offset = _scroll.offset;
    final progress = max > 0 ? (offset / max) * 100 : 0.0;
    final atBottom = max <= 0 || offset >= max - 10;
    if (progress != _progress || atBottom != _atBottom) {
      setState(() {
        _progress = progress.clamp(0, 100);
        _atBottom = atBottom;
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SchooKeepColors.background,
      child: Column(
        children: [
          const StatusBarSpacer(),
          // App bar with step counter
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: SchooKeepColors.surface,
              border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr(en: 'Confidentiality Agreement', ar: 'اتفاقية سرية البيانات'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                ),
                Text(
                  context.tr(en: 'Step 1 of 2', ar: 'الخطوة 1 من 2'),
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ),
          // Amber banner
          Container(
            color: SchooKeepColors.amberChipBg,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const _AmberBar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr(
                            en: 'Please scroll to the bottom to continue',
                            ar: 'يرجى التمرير حتى نهاية الصفحة للمتابعة',
                          ),
                          style: const TextStyle(fontSize: 12, color: SchooKeepColors.amberText),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Progress bar
          SizedBox(
            height: 4,
            child: Row(
              children: [
                Expanded(
                  flex: (_progress * 10).round().clamp(0, 1000),
                  child: const ColoredBox(color: SchooKeepColors.primary),
                ),
                Expanded(
                  flex: (1000 - (_progress * 10).round()).clamp(0, 1000),
                  child: const ColoredBox(color: SchooKeepColors.border),
                ),
              ],
            ),
          ),
          // Scrollable document
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: const _AgreementBody(),
            ),
          ),
          // Bottom CTA
          Container(
            decoration: const BoxDecoration(
              color: SchooKeepColors.surface,
              border: Border(top: BorderSide(color: SchooKeepColors.border)),
            ),
            padding: const EdgeInsets.all(16),
            child: Opacity(
              opacity: _atBottom ? 1 : 0.4,
              child: SchooKeepButton(
                label: context.tr(en: 'Continue', ar: 'المتابعة للتوقيع'),
                enabled: _atBottom,
                onPressed: () => context.go('/signature'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmberBar extends StatelessWidget {
  const _AmberBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 40,
      color: SchooKeepColors.warning,
    );
  }
}

class _AgreementBody extends StatelessWidget {
  const _AgreementBody();

  static const _heading = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary);
  static const _subheading = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary);
  static const _body = TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary, height: 1.7);

  Widget _para(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(text, style: _body),
      );

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(title, style: _subheading),
      );

  Widget _bullets(List<String> items) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ', style: _body),
                    Expanded(child: Text(item, style: _body)),
                  ],
                ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            context.tr(
              en: 'Health Information Privacy & Confidentiality Agreement',
              ar: 'اتفاقية سرية وخصوصية المعلومات الصحية المدرسية',
            ),
            style: _heading,
          ),
        ),
        _para(
          context.tr(
            en: 'This Confidentiality Agreement ("Agreement") is entered into by and between the authorized school health professional ("User") and the educational institution ("School") utilizing the SchooKeep health management system.',
            ar: 'تم إبرام اتفاقية السرية هذه بين الكادر الإداري والطبي المصرح له والمؤسسة التعليمية التي تستخدم نظام SchooKeep لإدارة الصحة المدرسية.',
          ),
        ),
        _section(context.tr(en: '1. Purpose', ar: '1. الغرض')),
        _para(
          context.tr(
            en: 'The User acknowledges that in the course of their duties, they will have access to confidential and sensitive health information regarding students, including but not limited to medical histories, diagnoses, treatment plans, medication records, and other protected health information (PHI) as defined under applicable laws.',
            ar: 'يقر المستخدم بأنه أثناء أداء مهامه، سيكون لديه إمكانية الوصول إلى معلومات صحية سرية وحساسة تتعلق بالطلاب والسجلات الطبية المحمية بموجب القوانين ذات الصلة.',
          ),
        ),
        _section(context.tr(en: '2. Confidentiality Obligations', ar: '2. التزامات السرية')),
        _para(context.tr(en: 'The User agrees to:', ar: 'يطبق المستخدم القواعد التالية:')),
        _bullets([
          context.tr(en: 'Maintain confidentiality of all student health info', ar: 'الحفاظ على سرية جميع السجلات الصحية للطلاب'),
          context.tr(en: 'Use info solely for authorized services', ar: 'استخدام المعلومات فقط لأغراض الخدمات المصرح بها'),
          context.tr(en: 'Not disclose info with unauthorized individuals', ar: 'عدم مشاركة معلومات الطلاب مع أشخاص غير مصرح لهم'),
          context.tr(en: 'Comply with applicable privacy laws (PDPL & DHA)', ar: 'الالتزام بقوانين حماية البيانات واللوائح الصحية'),
        ]),
        _section(context.tr(en: '3. Acknowledgment', ar: '3. الإقرار والتأكيد')),
        _para(
          context.tr(
            en: 'By continuing to the signature page, the User acknowledges that they have read, understood, and agree to be bound by the terms of this Confidentiality Agreement.',
            ar: 'بالمتابعة إلى صفحة التوقيع، يقر المستخدم بأنه قرأ وفهم ووافق على الالتزام بشروط هذه الاتفاقية.',
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
