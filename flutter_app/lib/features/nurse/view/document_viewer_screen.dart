import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/document.dart';
import '../../../data/repositories/document_repository.dart';
import '../cubit/document_viewer_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `DocumentViewer.tsx`, wired to `GET /documents/{id}` with
/// approve / mark-incomplete actions hitting `POST /documents/{id}/review`.
class DocumentViewerScreen extends StatelessWidget {
  const DocumentViewerScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final docId = int.tryParse(id) ?? 0;
    return BlocProvider(
      create: (_) => DocumentViewerCubit(sl<DocumentRepository>(), docId),
      child: const _DocumentViewerView(),
    );
  }
}

class _DocumentViewerView extends StatefulWidget {
  const _DocumentViewerView();

  @override
  State<_DocumentViewerView> createState() => _DocumentViewerViewState();
}

class _DocumentViewerViewState extends State<_DocumentViewerView> {
  int _currentPage = 1;
  static const int _totalPages = 3;
  bool _busy = false;

  static String _typeLabel(Document d) {
    if ((d.title ?? '').isNotEmpty) return d.title!;
    switch (d.type) {
      case 'immunization':
        return 'Immunization Records';
      case 'physician-order':
        return 'Physician Order';
      case 'consent':
        return 'Medication Consent Form';
      case 'insurance':
        return 'Insurance Card';
      default:
        return 'Document';
    }
  }

  void _showApproveDialog(Document d) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: 'Approve Document?',
        message: 'This will approve ${_typeLabel(d)} for Student #${d.studentId}. This action cannot be undone.',
        confirmLabel: 'Approve',
        confirmColor: SchooKeepColors.accent,
        onConfirm: () {
          Navigator.of(ctx).pop();
          _review('approved');
        },
      ),
    );
  }

  void _showIncompleteDialog(Document d) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: 'Mark as Incomplete?',
        message: 'This will notify the parent that ${_typeLabel(d)} needs to be resubmitted.',
        confirmLabel: 'Mark Incomplete',
        confirmColor: SchooKeepColors.warning,
        onConfirm: () {
          Navigator.of(ctx).pop();
          _review('rejected', notes: 'Document marked incomplete — please resubmit.', popOnSuccess: true);
        },
      ),
    );
  }

  Future<void> _review(String status, {String? notes, bool popOnSuccess = false}) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final message = await context.read<DocumentViewerCubit>().review(status, notes: notes);
    if (!mounted) return;
    setState(() => _busy = false);
    if (message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    if (popOnSuccess && context.canPop()) context.safeBack();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentViewerCubit, DataState<Document>>(
      builder: (context, state) {
        final d = state is DataLoaded<Document> ? state.data : null;
        final isApproved = d?.status == 'approved';
        return SchooKeepScaffold(
          reserveBottomNav: true,
          appBar: SchooKeepAppBar(
            centerTitle: true,
            onBack: () => context.safeBack(),
            titleWidget: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(d != null ? _typeLabel(d) : 'Document',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                if (d != null)
                  Text('Student #${d.studentId}',
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          bottomBar: d == null ? null : _bottomBar(d, isApproved),
          body: switch (state) {
            DataLoading() => const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())),
            DataError(:final message) => _errorView(message),
            DataLoaded(:final data) => _content(data, isApproved),
          },
        );
      },
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(
                label: 'Retry', fullWidth: false, onPressed: () => context.read<DocumentViewerCubit>().load()),
          ],
        ),
      ),
    );
  }

  Widget _content(Document d, bool isApproved) {
    final typeLabel = _typeLabel(d);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SchooKeepCard(
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.6,
              children: [
                _metaCell('Student', valueWidget: Text('Student #${d.studentId}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary))),
                _metaCell('Document Type', valueWidget: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(typeLabel,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF1E40AF))),
                  ),
                )),
                _metaCell('Status', valueWidget: Text((d.status ?? 'pending').toUpperCase(),
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.textPrimary))),
                _metaCell('Expiry', valueWidget: Text(d.expiryDate ?? '—',
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.textPrimary))),
              ],
            ),
          ),
          if (isApproved) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SchooKeepColors.greenChipBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.accent),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.greenChipText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.reviewedAt != null
                          ? 'Approved on ${d.reviewedAt!.month}/${d.reviewedAt!.day}/${d.reviewedAt!.year}'
                          : 'Approved',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.greenChipText),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: SchooKeepColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SchooKeepColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: SchooKeepColors.border)),
                  ),
                  child: AspectRatio(
                    aspectRatio: 8.5 / 11,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: SchooKeepColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Document Preview', style: TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text(typeLabel, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _currentPage == 1 ? null : () => setState(() => _currentPage--),
                        child: const Text('Previous',
                            style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                      ),
                      for (var page = 1; page <= _totalPages; page++)
                        GestureDetector(
                          onTap: () => setState(() => _currentPage = page),
                          child: Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: page == _currentPage ? SchooKeepColors.primary : SchooKeepColors.border,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 90,
                        child: Text('Page $_currentPage of $_totalPages',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                      ),
                      TextButton(
                        onPressed: _currentPage == _totalPages ? null : () => setState(() => _currentPage++),
                        child: const Text('Next',
                            style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
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

  Widget _metaCell(String label, {required Widget valueWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        valueWidget,
      ],
    );
  }

  Widget _bottomBar(Document d, bool isApproved) {
    return Container(
      decoration: const BoxDecoration(
        color: SchooKeepColors.surface,
        border: Border(top: BorderSide(color: SchooKeepColors.border)),
      ),
      padding: const EdgeInsets.all(16),
      child: isApproved
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.check, size: 20, color: SchooKeepColors.accent),
                  SizedBox(width: 8),
                  Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.accent),
                  SizedBox(width: 8),
                  Text('Approved ✓',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.accent)),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SchooKeepColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _busy ? null : () => _showApproveDialog(d),
                    child: _busy
                        ? const SizedBox(
                            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(LucideIcons.check, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Approve', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: SchooKeepColors.warning, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _busy ? null : () => _showIncompleteDialog(d),
                    child: const Text('Mark Incomplete — Request resubmission',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.warning)),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: SchooKeepColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: SchooKeepColors.textSecondary)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: confirmColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: onConfirm,
                      child: Text(confirmLabel,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
