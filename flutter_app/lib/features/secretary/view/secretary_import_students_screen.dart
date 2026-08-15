import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `SecretaryImportStudents.tsx`. Full-screen import wizard:
/// download template, upload file (simulated), preview first 5 rows, show UAE
/// validation errors, fix & re-validate, then import. Inline mock data.
class SecretaryImportStudentsScreen extends StatefulWidget {
  const SecretaryImportStudentsScreen({super.key});

  @override
  State<SecretaryImportStudentsScreen> createState() => _SecretaryImportStudentsScreenState();
}

class _PreviewRow {
  const _PreviewRow({
    required this.name,
    required this.eid,
    required this.grade,
    required this.dob,
    required this.parent,
    required this.emirate,
    required this.curriculum,
    required this.insurer,
    required this.policy,
  });
  final String name;
  final String eid;
  final String grade;
  final String dob;
  final String parent;
  final String emirate;
  final String curriculum;
  final String insurer;
  final String policy;
}

class _SecretaryImportStudentsScreenState extends State<SecretaryImportStudentsScreen> {
  String? _uploadedFile;
  List<({int row, String error})> _validationErrors = [];
  bool _validationPassed = false;

  static const List<_PreviewRow> _previewRows = [
    _PreviewRow(name: 'Fatima Al Mansoori', eid: '784-2016-1234567-8', grade: '4th', dob: '2016-03-15', parent: 'almansoori.j@email.ae', emirate: 'Dubai', curriculum: 'IB', insurer: 'Daman', policy: 'DM-98765-01'),
    _PreviewRow(name: 'Zayed Al Hashimi', eid: '784-2015-7654321-0', grade: '5th', dob: '2015-07-22', parent: 'sarah.hashimi@email.ae', emirate: 'Abu Dhabi', curriculum: 'British', insurer: 'GIG Gulf', policy: 'GG-11223-04'),
    _PreviewRow(name: 'Aisha Al Suwaidi', eid: '784-2016-5678901-2', grade: '4th', dob: '2016-05-10', parent: 'carlos.suwaidi@email.ae', emirate: 'Dubai', curriculum: 'IB', insurer: 'Oman Insurance', policy: 'OI-55443-02'),
    _PreviewRow(name: 'Liam Chen', eid: '784-2017-9012345-6', grade: '3rd', dob: '2017-01-08', parent: 'wei.chen@email.ae', emirate: 'Dubai', curriculum: 'American', insurer: 'Nextcare', policy: 'NC-44556-09'),
    _PreviewRow(name: 'Omar Al Marzooqi', eid: '784-2015-3456789-0', grade: '5th', dob: '2015-11-30', parent: 'michael.marzooqi@email.ae', emirate: 'Sharjah', curriculum: 'SABIS', insurer: 'Daman', policy: 'DM-77331-03'),
  ];

  void _handleFileUpload() {
    const invalidEid = '784-1234-5678-9';
    setState(() {
      _uploadedFile = 'students_uae_2026.xlsx';
      _validationErrors = const [
        (row: 12, error: 'Missing required field: Parent Email / البريد الإلكتروني لولي الأمر مفقود'),
        (row: 15, error: 'Invalid date format: Birth Date (Must be YYYY-MM-DD) / صيغة تاريخ الميلاد غير صالحة'),
        (
          row: 18,
          error:
              "Invalid Emirates ID: '$invalidEid'. EID must be 15 digits in 784-YYYY-XXXXXXX-X format / رقم الهوية الإماراتية غير صالح: يجب أن يطابق الصيغة 784-YYYY-XXXXXXX-X"
        ),
      ];
      _validationPassed = false;
    });
  }

  void _handleFixErrors() {
    setState(() {
      _validationErrors = [];
      _validationPassed = true;
    });
  }

  void _handleImport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('45 students imported successfully')),
    );
    context.go('/secretary/students');
  }

  /// The official template columns (UAE required fields). Shown in a sheet and
  /// copied to the clipboard as a CSV header row, since this build has no
  /// file-download capability.
  static const List<String> _templateColumns = [
    'Name',
    'Emirates ID (EID)',
    'Grade',
    'Date of Birth (YYYY-MM-DD)',
    'Parent Email',
    'Emirate',
    'Curriculum',
    'UAE Insurer',
    'Policy No',
  ];

  Future<void> _handleDownloadTemplate() async {
    await Clipboard.setData(ClipboardData(text: _templateColumns.join(',')));
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: SchooKeepColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const Text('students_uae_template.xlsx',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Create your spreadsheet with these columns. The header row has been copied to your clipboard. SSN is not used — UAE schools require Emirates ID instead.',
              style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            for (final col in _templateColumns)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(LucideIcons.check, size: 16, color: SchooKeepColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(col,
                          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textPrimary)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SchooKeepColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Got it',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      appBar: SchooKeepAppBar(title: 'Import Students', onBack: () => context.safeBack()),
      bottomBar: _uploadedFile == null
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: SchooKeepColors.surface,
                border: Border(top: BorderSide(color: SchooKeepColors.border)),
              ),
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _validationPassed ? SchooKeepColors.accent : const Color(0xFFE5E7EB),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _validationPassed ? _handleImport : null,
                  child: Text('Import 45 students',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _validationPassed ? Colors.white : const Color(0xFF9CA3AF),
                      )),
                ),
              ),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Download Template
            SchooKeepCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stepNumber('1'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Download Template',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text(
                          'Get the official Excel template with UAE required fields: Emirates ID, Emirate, Curriculum, UAE Insurer, and Policy. SSN is not used.',
                          style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _handleDownloadTemplate,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(LucideIcons.download, size: 16, color: SchooKeepColors.primary),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text('Download students_uae_template.xlsx',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 2: Upload File
            SchooKeepCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _stepNumber('2'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Upload File',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                            SizedBox(height: 4),
                            Text('Accepts .xlsx and .csv files',
                                style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_uploadedFile == null)
                    _uploadDropzone()
                  else
                    _uploadedBanner(_uploadedFile!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Preview Table
            if (_uploadedFile != null) ...[
              SchooKeepCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Preview (First 5 rows)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 12),
                    _previewTable(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Validation Errors
            if (_validationErrors.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(LucideIcons.alertTriangle, size: 20, color: SchooKeepColors.error),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Validation Errors Found',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF991B1B))),
                              const SizedBox(height: 8),
                              for (final e in _validationErrors)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B), height: 1.4),
                                      children: [
                                        TextSpan(
                                            text: 'Row ${e.row}: ',
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: e.error),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _handleFixErrors,
                      child: const Text('Fix errors and re-validate',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: SchooKeepColors.error,
                            decoration: TextDecoration.underline,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Validation Passed
            if (_validationPassed)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6EE7B7)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(LucideIcons.checkCircle, size: 20, color: SchooKeepColors.accent),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Validation Passed',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF065F46))),
                          SizedBox(height: 2),
                          Text('Ready to import 45 students',
                              style: TextStyle(fontSize: 12, color: Color(0xFF065F46))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stepNumber(String n) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: SchooKeepColors.primary, shape: BoxShape.circle),
      child: Text(n, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }

  Widget _uploadDropzone() {
    return InkWell(
      onTap: _handleFileUpload,
      borderRadius: BorderRadius.circular(8),
      child: DottedBorderBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(LucideIcons.upload, size: 32, color: SchooKeepColors.textSecondary),
            SizedBox(height: 8),
            Text('Tap to upload',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
            SizedBox(height: 4),
            Text('.xlsx or .csv', style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _uploadedBanner(String file) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle, size: 20, color: SchooKeepColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                const SizedBox(height: 2),
                const Text('45 students detected', style: TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewTable() {
    const headerStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary);
    const cellStyle = TextStyle(fontSize: 11, color: SchooKeepColors.textPrimary);
    const monoStyle = TextStyle(fontSize: 11, color: SchooKeepColors.textPrimary, fontFamily: 'monospace');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        horizontalMargin: 0,
        headingRowHeight: 36,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 40,
        dividerThickness: 1,
        columns: const [
          DataColumn(label: Text('Name', style: headerStyle)),
          DataColumn(label: Text('Emirates ID (EID)', style: headerStyle)),
          DataColumn(label: Text('Grade', style: headerStyle)),
          DataColumn(label: Text('DOB', style: headerStyle)),
          DataColumn(label: Text('Emirate', style: headerStyle)),
          DataColumn(label: Text('Curriculum', style: headerStyle)),
          DataColumn(label: Text('Parent Email', style: headerStyle)),
          DataColumn(label: Text('Insurer', style: headerStyle)),
          DataColumn(label: Text('Policy No', style: headerStyle)),
        ],
        rows: [
          for (final r in _previewRows)
            DataRow(cells: [
              DataCell(Text(r.name, style: cellStyle)),
              DataCell(Text(r.eid, style: monoStyle)),
              DataCell(Text(r.grade, style: cellStyle)),
              DataCell(Text(r.dob, style: cellStyle)),
              DataCell(Text(r.emirate, style: cellStyle)),
              DataCell(Text(r.curriculum, style: cellStyle)),
              DataCell(Text(r.parent, style: const TextStyle(fontSize: 10, color: SchooKeepColors.textPrimary))),
              DataCell(Text(r.insurer, style: cellStyle)),
              DataCell(Text(r.policy, style: monoStyle)),
            ]),
        ],
      ),
    );
  }
}

/// A 120px-tall dashed-border dropzone matching the source's
/// `border-2 border-dashed border-gray-300 rounded-lg bg-[#F8FAFC]`.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: SchooKeepColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
