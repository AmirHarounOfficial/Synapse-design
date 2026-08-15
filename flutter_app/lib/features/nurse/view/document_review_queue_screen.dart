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
import '../cubit/document_review_queue_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `DocumentReviewQueue.tsx`, wired to `GET /documents`.
/// Pending / Incomplete / Approved sections of submitted documents.
class DocumentReviewQueueScreen extends StatelessWidget {
  const DocumentReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DocumentReviewQueueCubit(sl<DocumentRepository>()),
      child: const _DocumentReviewQueueView(),
    );
  }
}

class _DocumentReviewQueueView extends StatefulWidget {
  const _DocumentReviewQueueView();

  @override
  State<_DocumentReviewQueueView> createState() =>
      _DocumentReviewQueueViewState();
}

class _DocumentReviewQueueViewState extends State<_DocumentReviewQueueView> {
  bool _approvedExpanded = false;

  static IconData _docIcon(String? type) {
    switch (type) {
      case 'immunization':
        return LucideIcons.syringe;
      case 'consent':
        return LucideIcons.shield;
      default:
        return LucideIcons.fileText;
    }
  }

  static String _docTitle(Document d) {
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

  void _reload() => context.read<DocumentReviewQueueCubit>().load();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentReviewQueueCubit, DataState<List<Document>>>(
      builder: (context, state) {
        final pending = switch (state) {
          DataLoaded(:final data) =>
            data.where((d) => d.status == 'pending').toList(),
          _ => const <Document>[],
        };
        return SchooKeepScaffold(
          reserveBottomNav: true,
          appBar: SchooKeepAppBar(
            centerTitle: true,
            onBack: () => context.safeBack(),
            titleWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Document Review',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                if (pending.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: SchooKeepColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${pending.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          scrollable: state is DataLoaded,
          body: switch (state) {
            DataLoading() => const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
            DataError(:final message) => _errorView(message),
            DataLoaded(:final data) => _content(data),
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
            const Icon(
              LucideIcons.wifiOff,
              size: 36,
              color: SchooKeepColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SchooKeepColors.textSecondary),
            ),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: 'Retry',
              fullWidth: false,
              onPressed: _reload,
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(List<Document> docs) {
    final pending = docs.where((d) => d.status == 'pending').toList();
    final approved = docs.where((d) => d.status == 'approved').toList();
    final incomplete = docs
        .where((d) => d.status == 'incomplete' || d.status == 'rejected')
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _divider('Pending Review', SchooKeepColors.warning),
          const SizedBox(height: 12),
          if (pending.isNotEmpty)
            ...pending.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _pendingCard(d),
              ),
            )
          else
            SchooKeepCard(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      LucideIcons.check,
                      size: 20,
                      color: SchooKeepColors.accent,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'All documents reviewed ✓',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (incomplete.isNotEmpty) ...[
            const SizedBox(height: 24),
            _divider('Incomplete', SchooKeepColors.error),
            const SizedBox(height: 12),
            ...incomplete.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _incompleteCard(d),
              ),
            ),
          ],
          if (approved.isNotEmpty) ...[
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () =>
                  setState(() => _approvedExpanded = !_approvedExpanded),
              child: Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: SchooKeepColors.accent),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'APPROVED',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: SchooKeepColors.accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${approved.length} approved',
                          style: const TextStyle(
                            fontSize: 12,
                            color: SchooKeepColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _approvedExpanded
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown,
                          size: 16,
                          color: SchooKeepColors.accent,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(height: 1, color: SchooKeepColors.accent),
                  ),
                ],
              ),
            ),
            if (_approvedExpanded) ...[
              const SizedBox(height: 12),
              ...approved.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _approvedCard(d),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _divider(String label, Color color) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: color)),
      ],
    );
  }

  Widget _docIconBox(String? type) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(_docIcon(type), size: 20, color: SchooKeepColors.primary),
    );
  }

  String _meta(Document d) {
    final parts = <String>['Student #${d.studentId}'];
    if (d.reviewedAt != null) {
      parts.add(
        '${d.reviewedAt!.month}/${d.reviewedAt!.day}/${d.reviewedAt!.year}',
      );
    }
    return parts.join(' · ');
  }

  Widget _pendingCard(Document d) {
    return AccentCard(
      background: SchooKeepColors.surface,
      accentColor: SchooKeepColors.warning,
      accentWidth: 3,
      radius: 12,
      borderColor: SchooKeepColors.border,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _docIconBox(d.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _docTitle(d),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _meta(d),
                      style: const TextStyle(
                        fontSize: 12,
                        color: SchooKeepColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 80,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SchooKeepColors.background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: SchooKeepColors.border),
                ),
                child: const Icon(
                  LucideIcons.fileText,
                  size: 24,
                  color: SchooKeepColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SchooKeepColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      await context.push('/nurse/documents/review/${d.id}');
                      if (context.mounted) _reload();
                    },
                    child: const Text(
                      'Review',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: SchooKeepColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _requestMoreInfo(d),
                    child: const Text(
                      'Request more info',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: SchooKeepColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _requestMoreInfo(Document d) async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = sl<DocumentRepository>();
    try {
      await repo.review(d.id, 'rejected', notes: 'More information requested.');
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Parent notified to resubmit.')),
        );
      _reload();
    } catch (e) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(DocumentRepository.messageFor(e))),
        );
    }
  }

  Widget _incompleteCard(Document d) {
    return AccentCard(
      background: SchooKeepColors.surface,
      accentColor: SchooKeepColors.error,
      accentWidth: 3,
      radius: 12,
      borderColor: SchooKeepColors.border,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _docIconBox(d.type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Incomplete',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: SchooKeepColors.error,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _docTitle(d),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _meta(d),
                  style: const TextStyle(
                    fontSize: 12,
                    color: SchooKeepColors.textSecondary,
                  ),
                ),
                if ((d.notes ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    d.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SchooKeepColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _approvedCard(Document d) {
    return AccentCard(
      background: SchooKeepColors.surface,
      accentColor: SchooKeepColors.accent,
      accentWidth: 3,
      radius: 12,
      borderColor: SchooKeepColors.border,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _docIconBox(d.type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _docTitle(d),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SchooKeepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _meta(d),
                  style: const TextStyle(
                    fontSize: 12,
                    color: SchooKeepColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const SchooKeepBadge(
                  label: 'Approved',
                  background: SchooKeepColors.greenChipBg,
                  foreground: SchooKeepColors.greenChipText,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
