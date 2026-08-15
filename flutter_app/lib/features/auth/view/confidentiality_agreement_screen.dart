import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `ConfidentialityAgreement.tsx`. A long legal document gated by a
/// scroll-to-bottom check: a live progress bar tracks scroll position, and the
/// Continue button stays disabled (40% opacity) until the user reaches the end.
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Confidentiality Agreement',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
                ),
                Text('Step 1 of 2', style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          // Amber banner
          Container(
            color: SchooKeepColors.amberChipBg,
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                _AmberBar(),
                SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please scroll to the bottom to continue',
                          style: TextStyle(fontSize: 12, color: SchooKeepColors.amberText),
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
                label: 'Continue',
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

/// The 8px-wide amber accent bar on the left of the info banner.
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
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text('Health Information Privacy & Confidentiality Agreement', style: _heading),
        ),
        _para(
          'This Confidentiality Agreement ("Agreement") is entered into by and between the authorized school health professional ("User") and the educational institution ("School") utilizing the SchooKeep health management system.',
        ),
        _section('1. Purpose'),
        _para(
          'The User acknowledges that in the course of their duties, they will have access to confidential and sensitive health information regarding students, including but not limited to medical histories, diagnoses, treatment plans, medication records, and other protected health information (PHI) as defined under the Health Insurance Portability and Accountability Act (HIPAA) and the Family Educational Rights and Privacy Act (FERPA).',
        ),
        _section('2. Confidentiality Obligations'),
        _para('The User agrees to:'),
        _bullets(const [
          'Maintain the confidentiality of all student health information accessed through the SchooKeep system',
          'Use such information solely for the purpose of providing authorized healthcare services to students',
          'Not disclose, share, or discuss student health information with unauthorized individuals',
          'Access only those records necessary to perform their assigned duties',
          'Comply with all applicable federal and state privacy laws, including HIPAA and FERPA',
        ]),
        _section('3. Security Measures'),
        _para(
          'The User agrees to take all reasonable precautions to prevent unauthorized access to student health information, including:',
        ),
        _bullets(const [
          'Using strong, unique passwords and not sharing login credentials',
          'Logging out of the system when not in active use',
          'Ensuring physical security of devices used to access the system',
          'Reporting any suspected security breaches immediately to the system administrator',
        ]),
        _section('4. Consequences of Breach'),
        _para('The User understands that any breach of this Agreement may result in:'),
        _bullets(const [
          'Immediate termination of system access',
          'Disciplinary action up to and including termination of employment',
          'Civil and/or criminal penalties under applicable law',
          'Personal liability for damages resulting from unauthorized disclosure',
        ]),
        _section('5. Duration'),
        _para(
          "This Agreement remains in effect for the duration of the User's access to the SchooKeep system and continues indefinitely with respect to information accessed during such period.",
        ),
        _section('6. Acknowledgment'),
        _para(
          'By continuing to the signature page, the User acknowledges that they have read, understood, and agree to be bound by the terms of this Confidentiality Agreement. The User further acknowledges their responsibility to protect student health information and their understanding of the serious nature of these obligations.',
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
