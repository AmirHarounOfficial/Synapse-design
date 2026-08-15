import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/after_hours_request.dart';
import '../../../data/repositories/after_hours_repository.dart';
import '../cubit/after_hours_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `PrincipalAfterHoursAccess.tsx`, wired to
/// `GET/POST /after-hours-requests` via [AfterHoursCubit]. Lists real access
/// requests with their status, lets the principal approve/deny pending ones,
/// and files new requests with a reason and an optional access window.
class PrincipalAfterHoursAccessScreen extends StatelessWidget {
  const PrincipalAfterHoursAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AfterHoursCubit(sl<AfterHoursRepository>()),
      child: const _PrincipalAfterHoursAccessView(),
    );
  }
}

class _PrincipalAfterHoursAccessView extends StatefulWidget {
  const _PrincipalAfterHoursAccessView();

  @override
  State<_PrincipalAfterHoursAccessView> createState() => _PrincipalAfterHoursAccessViewState();
}

class _PrincipalAfterHoursAccessViewState extends State<_PrincipalAfterHoursAccessView> {
  final _reason = TextEditingController();
  DateTime? _windowStart;
  DateTime? _windowEnd;
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _reload() => context.read<AfterHoursCubit>().load();

  Future<void> _pickWindow({required bool start}) async {
    final now = DateTime.now();
    final base = start ? _windowStart : _windowEnd;
    final date = await showDatePicker(
      context: context,
      initialDate: base ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base ?? now),
    );
    if (!mounted) return;
    final picked = DateTime(date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);
    setState(() {
      if (start) {
        _windowStart = picked;
      } else {
        _windowEnd = picked;
      }
    });
  }

  Future<void> _handleCreate() async {
    if (_reason.text.trim().isEmpty || _submitting) return;
    setState(() => _submitting = true);
    final ok = await context.read<AfterHoursCubit>().create(
          reason: _reason.text.trim(),
          windowStart: _windowStart?.toIso8601String(),
          windowEnd: _windowEnd?.toIso8601String(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      setState(() {
        _reason.clear();
        _windowStart = null;
        _windowEnd = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Access request submitted.')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not submit the request.')));
    }
  }

  Future<void> _respond(int id, String status) async {
    final label = status == 'approved' ? 'Approve' : 'Deny';
    final ok = await _confirm('$label this access request?');
    if (!ok || !mounted) return;
    final done = await context.read<AfterHoursCubit>().respond(id, status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(done ? 'Request ${status == 'approved' ? 'approved' : 'denied'}.' : 'Action failed.')),
    );
  }

  Future<bool> _confirm(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SchooKeepScaffold(
      scrollable: true,
      title: 'After-Hours Access',
      onBack: () => context.safeBack(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoBox(),
            const SizedBox(height: 16),
            const Text('Access Requests',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            const SizedBox(height: 12),
            BlocBuilder<AfterHoursCubit, DataState<List<AfterHoursRequest>>>(
              builder: (context, state) {
                return switch (state) {
                  DataLoading() => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  DataError(:final message) => _errorBanner(message),
                  DataLoaded(:final data) => _requestList(data),
                };
              },
            ),
            const SizedBox(height: 16),
            _createForm(),
          ],
        ),
      ),
    );
  }

  Widget _infoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 16, color: SchooKeepColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'By default, staff access is blocked outside school hours (7:30 AM – 5:00 PM Mon–Fri). Review requests below or file a new one.',
              style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner(String error) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.error),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.alertCircle, size: 20, color: SchooKeepColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(error,
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.error, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SchooKeepButton(label: 'Retry', fullWidth: false, onPressed: _reload),
      ],
    );
  }

  Widget _requestList(List<AfterHoursRequest> requests) {
    if (requests.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SchooKeepColors.border),
        ),
        child: const Center(
          child: Text('No access requests yet.',
              style: TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
        ),
      );
    }
    return Column(
      children: [
        for (final r in requests) ...[
          _requestCard(r),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _requestCard(AfterHoursRequest r) {
    final status = (r.status ?? 'pending').toLowerCase();
    final (bg, fg) = _statusStyle(status);
    final isPending = status == 'pending';
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(r.requesterName ?? 'Staff member',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
              ),
              const SizedBox(width: 8),
              SchooKeepBadge(label: _statusLabel(status), background: bg, foreground: fg, fontSize: 11),
            ],
          ),
          if ((r.reason ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(r.reason!, style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary, height: 1.4)),
          ],
          if (r.windowStart != null || r.windowEnd != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.clock, size: 14, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('${_fmt(r.windowStart)} – ${_fmt(r.windowEnd)}',
                      style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ),
              ],
            ),
          ],
          if (r.createdAt != null) ...[
            const SizedBox(height: 4),
            Text('Requested ${_fmt(r.createdAt)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _actionButton('Approve', SchooKeepColors.accent, () => _respond(r.id, 'approved')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionButton('Deny', SchooKeepColors.error, () => _respond(r.id, 'denied')),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 44,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _createForm() {
    final enabled = _reason.text.trim().isNotEmpty && !_submitting;
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Request',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
          const SizedBox(height: 12),
          _label('Reason (required)'),
          TextField(
            controller: _reason,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Why is after-hours access needed?',
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.all(12),
              filled: true,
              fillColor: SchooKeepColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: SchooKeepColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _label('Access window (optional)'),
          Row(
            children: [
              Expanded(child: _windowField('Start', _windowStart, () => _pickWindow(start: true))),
              const SizedBox(width: 8),
              Expanded(child: _windowField('End', _windowEnd, () => _pickWindow(start: false))),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: enabled ? SchooKeepColors.primary : const Color(0xFFE2E8F0),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: enabled ? _handleCreate : null,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Submit Request',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: enabled ? Colors.white : const Color(0xFF94A3B8))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _windowField(String label, DateTime? value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: SchooKeepColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.calendar, size: 16, color: SchooKeepColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == null ? label : _fmt(value),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    color: value == null ? const Color(0xFF94A3B8) : SchooKeepColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
      );

  static (Color, Color) _statusStyle(String status) {
    switch (status) {
      case 'approved':
        return (SchooKeepColors.greenChipBg, SchooKeepColors.greenChipText);
      case 'denied':
        return (const Color(0xFFFEE2E2), SchooKeepColors.error);
      case 'pending':
      default:
        return (SchooKeepColors.amberChipBg, SchooKeepColors.amberText);
    }
  }

  static String _statusLabel(String status) {
    if (status.isEmpty) return 'Pending';
    return '${status[0].toUpperCase()}${status.substring(1)}';
  }

  static String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '${months[local.month - 1]} ${local.day}, ${local.year} $h12:$m $ampm';
  }
}
