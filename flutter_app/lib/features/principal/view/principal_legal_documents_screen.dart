import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `PrincipalLegalDocuments.tsx`. Jurisdiction banner, government
/// systems integration, DPO certificate, pending actions, signed documents,
/// parent-consent status, legal framework, and document-type explainers.
/// "Synapse" is rendered as "SchooKeep" per the brand rule.
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
      title: 'Legal & Compliance',
      onBack: () => context.safeBack(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _jurisdictionBanner(),
            const SizedBox(height: 16),
            _govIntegration(),
            const SizedBox(height: 16),
            _dpoCard(context),
            const SizedBox(height: 16),
            _pendingSection(context),
            const SizedBox(height: 16),
            _signedDocsSection(context),
            const SizedBox(height: 16),
            _consentStatusCard(context),
            const SizedBox(height: 16),
            _legalFramework(),
            const SizedBox(height: 16),
            _documentTypes(),
          ],
        ),
      ),
    );
  }

  Widget _jurisdictionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFEFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA5F3FC)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ACTIVE JURISDICTION',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0E7490), letterSpacing: 1.2)),
                SizedBox(height: 2),
                Text('🇦🇪 Emirate of Dubai (دبي)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF164E63))),
                SizedBox(height: 4),
                Text('Governed by UAE PDPL & DHA School Health Guidelines',
                    style: TextStyle(fontSize: 12, color: Color(0xFF0891B2))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF0E7490), borderRadius: BorderRadius.circular(4)),
            child: const Text('DHA COMPLIANT',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _govIntegration() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Government Systems Integration'),
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HASANA (حصنة) Integration',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('Dubai DHA Immunization Sync',
                          style: TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(4)),
                  child: const Text('Authorized & Active',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SchooKeepColors.accent)),
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

  /// Re-upload sheet — no in-app file picker, so offer the upload entry points
  /// as a bottom sheet (matches the in-app feedback convention).
  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('Upload DPO certificate',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.fileText, color: SchooKeepColors.primary),
              title: const Text('Choose PDF from device'),
              subtitle: const Text('UAE PDPL DPO appointment certificate · Max 5MB'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _snack(context, 'Certificate upload started…');
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: SchooKeepColors.primary),
              title: const Text('Scan document'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _snack(context, 'Document scanner opening…');
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
        title: const Text('Review & Re-sign DPA'),
        content: const Text(
            'The Data Processing Agreement renewal is due June 1, 2026. Re-signing renews the agreement for another term under the UAE PDPL.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dlgCtx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dlgCtx, true), child: const Text('Re-sign')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      _snack(context, 'DPA re-signed — renewal recorded');
    }
  }

  Widget _dpoCard(BuildContext context) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Data Protection Officer (DPO)'),
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
                const Text('DPO Registration Certificate',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Upload your UAE PDPL DPO appointment certificate (PDF, Max 5MB)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text('dpo_certificate_dubai.pdf',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                      ),
                      SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 6,
                            height: 6,
                            child: DecoratedBox(
                                decoration: BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                          ),
                          SizedBox(width: 4),
                          Text('Verified',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showUploadSheet(context),
                  child: const Text('Re-upload certificate',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.primary)),
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
        const Row(
          children: [
            Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.warning),
            SizedBox(width: 8),
            Text('Pending Actions',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.warning)),
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
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.fileText, size: 20, color: SchooKeepColors.warning),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Renewal Required',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                        SizedBox(height: 4),
                        Text('DPA renewal due June 1, 2026',
                            style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
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
                  child: const Text('Review & Re-sign',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
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
        const _SectionTitle('Signed Documents'),
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
    final formatted = DateFormatter.formatGregorianLong(date, 'en');
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
                Text('Signed $formatted', style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _snack(context, 'Opening "${doc.name}"…'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.eye, size: 16, color: SchooKeepColors.primary),
                SizedBox(width: 4),
                Text('View', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
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
          const _SectionTitle('Parent Consent Status'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('$_consentActive of $_consentTotal students have active parent consent',
                    style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
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
              const Text('Incomplete consents',
                  style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              GestureDetector(
                onTap: () => _snack(context,
                    '$_consentIncomplete student${_consentIncomplete == 1 ? '' : 's'} missing parent consent — follow-up required'),
                child: const Text('$_consentIncomplete incomplete',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.warning)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legalFramework() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Legal Framework',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 8),
          _frameworkLine('UAE PDPL', ' (Federal Decree-Law No. 45 of 2021) governs general data privacy protections'),
          _frameworkLine(
              'DHA Guidelines', ' protect student clinical data and DHA school clinic operating procedures'),
          _frameworkLine('HASANA Sync Protocols', ' dictate mandatory reporting of childhood immunizations'),
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

  Widget _documentTypes() {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Document Types',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          _docType('Platform Data Processing Agreement (DPA)',
              'Defines how student data is processed, stored, and protected by the SchooKeep platform in accordance with the UAE PDPL.'),
          const SizedBox(height: 12),
          _docType('UAE PDPL Controller-Processor Declaration',
              'Delineates the responsibilities of the school (Controller) and SchooKeep (Processor) under the Federal Decree-Law No. 45 of 2021.'),
          const SizedBox(height: 12),
          _docType('DHA Medical Liability Disclaimer',
              'Clarifies DHA clinic licensing operational protocols, emergency consent scopes, and platform disclaimer boundaries.'),
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
