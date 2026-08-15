import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:signature/signature.dart';

import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Ported from `ReportCoSignature.tsx` (`/physician/co-sign/:id`). Report
/// metadata, a scrollable document preview, physician review notes, an
/// interactive signature pad (+ UAE Pass alternative), a PIN-gated co-signature
/// (demo PIN 1234 or 9999), and export / submit CTAs once signed.
class ReportCoSignatureScreen extends StatefulWidget {
  const ReportCoSignatureScreen({super.key, required this.id});

  final String id;

  @override
  State<ReportCoSignatureScreen> createState() => _ReportCoSignatureScreenState();
}

class _ReportCoSignatureScreenState extends State<ReportCoSignatureScreen> {
  final _report = (
    title: 'Monthly Clinical Immunization Summary',
    dateRange: '01/05/2026 - 31/05/2026',
    nurseName: 'Emily Smith',
    nurseLicense: 'RN-4521',
    signedDate: '10/06/2026',
    schoolName: 'Lincoln Elementary School',
    totalVisits: 142,
    medsAdministered: 98,
    referralsSent: 12,
    emergencies: 1,
  );

  final TextEditingController _reviewNotes = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2.5,
    penColor: SchooKeepColors.textPrimary,
    exportBackgroundColor: Colors.transparent,
  );

  bool _isSigned = false;
  String _signatureDate = '';

  @override
  void dispose() {
    _reviewNotes.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  void _toast(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? SchooKeepColors.error : SchooKeepColors.physicianTeal,
      ),
    );
  }

  void _handleCoSign() {
    final isRTL = context.isRTL;
    final pinController = TextEditingController();
    var pinError = false;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
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
                  Text(isRTL ? 'رمز أمان التوقيع' : 'Verification PIN Required',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    isRTL
                        ? 'أدخل رمز PIN الخاص بملفك الطبي لإقرار التوقيع المشترك.'
                        : 'Enter your 4-digit verification PIN to confirm report co-signature.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, letterSpacing: 8),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••',
                      filled: true,
                      fillColor: SchooKeepColors.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: pinError ? SchooKeepColors.error : SchooKeepColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: pinError ? SchooKeepColors.error : SchooKeepColors.physicianTeal, width: 2),
                      ),
                    ),
                  ),
                  Text(isRTL ? '(رمز الدخول التجريبي: 1234 أو 9999)' : '(Demo code: 1234 or 9999)',
                      style: const TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
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
                              backgroundColor: SchooKeepColors.physicianTeal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              final pin = pinController.text;
                              if (pin == '1234' || pin == '9999') {
                                Navigator.of(dialogContext).pop();
                                _onPinVerified();
                              } else {
                                setDialogState(() => pinError = true);
                                pinController.clear();
                                _toast(isRTL ? 'رمز PIN غير صحيح' : 'Incorrect verification PIN.', error: true);
                              }
                            },
                            child: Text(isRTL ? 'تأكيد التوقيع' : 'Confirm',
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
      ),
    ).whenComplete(pinController.dispose);
  }

  void _onPinVerified() {
    final isRTL = context.isRTL;
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    setState(() {
      _isSigned = true;
      _signatureDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} at $timeStr';
    });
    _toast(isRTL ? 'تم التوقيع بنجاح' : 'Co-signature added successfully!');
  }

  void _handleSubmitToPrincipal() {
    final isRTL = context.isRTL;
    _toast(isRTL ? 'تم إرسال التقرير بنجاح للمدير' : 'Report submitted to Principal successfully!');
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/physician/dashboard');
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
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isRTL ? 'التوقيع المشترك للتقرير' : 'Report Co-Signature',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            Text(isRTL ? 'مراجعة وتوقيع' : 'Review & Sign',
                style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _metadataCard(isRTL),
          const SizedBox(height: 16),
          _documentPreview(isRTL),
          const SizedBox(height: 16),
          _reviewNotesField(isRTL),
          const SizedBox(height: 16),
          _signatureArea(isRTL),
          const SizedBox(height: 16),
          _ctas(isRTL),
        ],
      ),
    );
  }

  Widget _metadataCard(bool isRTL) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                child: const Icon(LucideIcons.fileText, size: 20, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_report.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('${isRTL ? 'النطاق الزمني:' : 'Period:'} ${_report.dateRange}',
                        style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isRTL ? 'الممرضة: ${_report.nurseName}' : 'Nurse: ${_report.nurseName}',
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              Text(isRTL ? 'ترخيص: ${_report.nurseLicense}' : 'License: ${_report.nurseLicense}',
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _documentPreview(bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isRTL ? 'معاينة التقرير الطبي' : 'REPORT DOCUMENT PREVIEW',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: SchooKeepColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(_report.schoolName.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                      const SizedBox(height: 2),
                      const Text('SCHOOL HEALTH CLINIC CLINICAL SUMMARY',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                      const SizedBox(height: 2),
                      const Text('Compliance Ref: DHA/HRS/HPSD/ST-22',
                          style: TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: SchooKeepColors.border),
                const SizedBox(height: 12),
                Text(
                  'This report summarizes clinical activity at the ${_report.schoolName} health center for the period ${_report.dateRange}. All activities were conducted under standard DHA clinical protocols.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937), height: 1.6),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SchooKeepColors.border),
                  ),
                  child: Column(
                    children: [
                      _statRow('Metric Indicator', 'Value', bold: true, divider: true),
                      _statRow('Total Student Clinic Visits', '${_report.totalVisits}'),
                      _statRow('Medication Administrations', '${_report.medsAdministered}'),
                      _statRow('Escalated Hospital Referrals', '${_report.referralsSent}'),
                      _statRow('Critical Emergency Transport', '${_report.emergencies}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'All student medication administrations were executed pursuant to approved parent consent configurations. No adverse incidents occurred.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1F2937), height: 1.6),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: SchooKeepColors.border),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SUBMITTED BY:', style: TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
                          Text(_report.nurseName,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Text('Signed: ${_report.signedDate}',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 16),
                      child: Text('Emily Smith',
                          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                    ),
                  ],
                ),
                if (_isSigned) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: SchooKeepColors.border),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CO-SIGNED BY:', style: TextStyle(fontSize: 10, color: SchooKeepColors.textSecondary)),
                            const Text('Dr. Amina Al-Hashimi',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDFA),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFF99F6E4)),
                              ),
                              child: Text('Approved: $_signatureDate',
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: SchooKeepColors.physicianTeal)),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.only(end: 16),
                        child: Text('Dr. Amina H.',
                            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: SchooKeepColors.physicianTeal)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statRow(String label, String value, {bool bold = false, bool divider = false}) {
    final style = TextStyle(
      fontSize: 11,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: SchooKeepColors.textPrimary,
    );
    return Container(
      padding: EdgeInsets.only(bottom: divider ? 4 : 0, top: divider ? 0 : 2),
      decoration: divider
          ? const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))))
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }

  Widget _reviewNotesField(bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isRTL ? 'ملاحظات الطبيب (اختياري)' : 'PHYSICIAN REVIEW NOTES',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textSecondary, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        TextField(
          controller: _reviewNotes,
          enabled: !_isSigned,
          maxLines: 3,
          style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
          decoration: InputDecoration(
            hintText: isRTL
                ? 'أدخل أي ملاحظات مرافقة للتقرير هنا...'
                : 'Enter any review notes or caveats to submit with the signed document...',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: _isSigned ? const Color(0xFFF8FAFC) : SchooKeepColors.surface,
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: SchooKeepColors.border),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: SchooKeepColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: SchooKeepColors.physicianTeal),
            ),
          ),
        ),
      ],
    );
  }

  Widget _signatureArea(bool isRTL) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isRTL ? 'توقيع الطبيب المعتمد' : 'Physician Approval Signature',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SchooKeepColors.textPrimary)),
              if (!_isSigned)
                GestureDetector(
                  onTap: () => _signatureController.clear(),
                  child: Text(isRTL ? 'مسح التوقيع' : 'Clear Pad',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isSigned) ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1D5DB), width: 2, style: BorderStyle.solid),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Center(
                    child: Text(isRTL ? 'ارسم توقيعك هنا' : 'Draw your signature here',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ),
                  Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.transparent,
                    height: 120,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _uaePassOption(isRTL),
          ] else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4EA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA3E635)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle, size: 20, color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isRTL ? 'تم التوقيع المشترك وتأمين الملف' : 'Dual-Authentication Co-Signed',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF137333))),
                        Text(
                          isRTL ? 'المستند محمي تشفيرياً · $_signatureDate' : 'Cryptographically secured · $_signatureDate',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF137333)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Inline port of `UAEPassSignOption.tsx`.
  Widget _uaePassOption(bool isRTL) {
    return Column(
      children: [
        const Divider(height: 1, color: SchooKeepColors.border),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Divider(color: SchooKeepColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(isRTL ? 'أو التوقيع بواسطة' : 'OR SIGN WITH',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SchooKeepColors.textSecondary, letterSpacing: 0.8)),
            ),
            const Expanded(child: Divider(color: SchooKeepColors.border)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2563EB), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _toast(isRTL
                ? 'تكامل الهوية الرقمية (UAE Pass) قيد التطوير وسيتم تفعيله قريباً.'
                : 'UAE Pass integration is in progress and will be available soon.'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: SchooKeepColors.textPrimary, borderRadius: BorderRadius.circular(4)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('UAE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF06B6D4))),
                      SizedBox(width: 2),
                      Text('PASS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(isRTL ? 'التوقيع الرقمي بالهوية الرقمية' : 'Sign with UAE Pass',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ctas(bool isRTL) {
    if (_isSigned) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: SchooKeepColors.surface,
                  side: const BorderSide(color: SchooKeepColors.physicianTeal, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _toast(isRTL ? 'بدء تحميل ملف PDF...' : 'Exporting signed report PDF...'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.download, size: 16, color: SchooKeepColors.physicianTeal),
                    const SizedBox(width: 6),
                    Text(isRTL ? 'تصدير بصيغة PDF' : 'Export PDF',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SchooKeepColors.physicianTeal)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SchooKeepColors.physicianTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleSubmitToPrincipal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.send, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(isRTL ? 'إرسال لمدير المدرسة' : 'Submit to Principal',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: SchooKeepColors.physicianTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _handleCoSign,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.lock, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(isRTL ? 'إضافة توقيعي المشترك' : 'Add Co-Signature',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
