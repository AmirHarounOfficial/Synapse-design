import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/audit_log.dart';
import '../../../data/repositories/system_repository.dart';
import '../cubit/audit_log_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

class PrincipalAuditLogScreen extends StatelessWidget {
  const PrincipalAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuditLogCubit(sl<SystemRepository>()),
      child: const _PrincipalAuditLogView(),
    );
  }
}

class _PrincipalAuditLogView extends StatefulWidget {
  const _PrincipalAuditLogView();

  @override
  State<_PrincipalAuditLogView> createState() => _PrincipalAuditLogViewState();
}

class _PrincipalAuditLogViewState extends State<_PrincipalAuditLogView> {
  String _activeFilter = 'all';

  static String _categoryOf(AuditLog e) {
    final a = e.action.toLowerCase();
    if (a.contains('login') || a.contains('logout') || a.contains('auth')) return 'login';
    if (a.contains('medication') || a.contains('dose') || a.contains('consent') ||
        a.contains('clinic') || a.contains('referral')) {
      return 'clinical';
    }
    if (a.contains('access') ||
        a.contains('failed') ||
        (a.contains('permission') && a.contains('denied')) ||
        a.contains('security')) {
      return 'security';
    }
    return 'admin';
  }

  static Color _colorOf(String category) => switch (category) {
        'clinical' => const Color(0xFFDC2626),
        'security' => const Color(0xFFF59E0B),
        'login' => const Color(0xFF64748B),
        _ => const Color(0xFF2563EB),
      };

  Future<void> _exportCsv() async {
    final state = context.read<AuditLogCubit>().state;
    if (state is! DataLoaded<List<AuditLog>>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(en: 'Log is still loading — try again in a moment.', ar: 'جاري تحميل السجل — يرجى المحاولة بعد لحظات.'))),
      );
      return;
    }
    final entries = _activeFilter == 'all'
        ? state.data
        : state.data.where((e) => _categoryOf(e) == _activeFilter).toList();
    final buffer = StringBuffer('Action,Category,Subject,Timestamp\n');
    for (final e in entries) {
      final subject = e.entityType != null
          ? '${e.entityType}${e.entityId != null ? ' #${e.entityId}' : ''}'
          : (e.userId != null ? 'User #${e.userId}' : '');
      buffer.writeln('${_csv(e.action)},${_categoryOf(e)},${_csv(subject)},${_csv(_timestamp(context, e))}');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr(
        en: '${entries.length} log entry/entries copied to clipboard as CSV',
        ar: 'تم نسخ ${entries.length} عنصر من السجل للحافظة كملف CSV',
      ))),
    );
  }

  static String _csv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final filters = <(String, String)>[
      ('all', context.tr(en: 'All actions', ar: 'جميع الإجراءات')),
      ('clinical', context.tr(en: 'Clinical', ar: 'سريري وطبي')),
      ('admin', context.tr(en: 'Admin', ar: 'إداري')),
      ('security', context.tr(en: 'Security', ar: 'أمان وتصريح')),
      ('login', context.tr(en: 'Login', ar: 'تسجيل دخول')),
    ];

    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: false,
      appBar: SchooKeepAppBar(
        onBack: () => context.safeBack(),
        titleWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr(en: 'Audit Log', ar: 'سجل التدقيق والنشاطات'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
            ),
            GestureDetector(
              onTap: _exportCsv,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.download, size: 16, color: SchooKeepColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    context.tr(en: 'Export CSV', ar: 'تصدير CSV'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: SchooKeepColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in filters) ...[
                    _filterChip(f.$1, f.$2),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<AuditLogCubit, DataState<List<AuditLog>>>(
              builder: (context, state) {
                return switch (state) {
                  DataLoading() => const Center(child: CircularProgressIndicator()),
                  DataError(:final message) => _errorView(context, message),
                  DataLoaded(:final data) => _list(context, data),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView(BuildContext context, String message) {
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
              label: context.tr(en: 'Retry', ar: 'إعادة المحاولة'),
              fullWidth: false,
              onPressed: () => context.read<AuditLogCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<AuditLog> all) {
    final entries =
        _activeFilter == 'all' ? all : all.where((e) => _categoryOf(e) == _activeFilter).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _immutabilityNotice(context),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  context.tr(en: 'No log entries', ar: 'لا توجد سجلات بعد'),
                  style: const TextStyle(color: SchooKeepColors.textSecondary),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.border),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < entries.length; i++) ...[
                    if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                    _entryTile(context, entries[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    final active = _activeFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? SchooKeepColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : SchooKeepColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _immutabilityNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.info, size: 16, color: SchooKeepColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr(
                en: '⚠ This log is tamper-proof. No entry can be deleted or modified by any user, including administrators.',
                ar: '⚠ هذا السجل غير قابل للتعديل أو الحذف إطلاقاً من قبل أي موظف أو مسؤول طبقاً للأنظمة الأدمينة.',
              ),
              style: const TextStyle(fontSize: 11, color: Color(0xFF92400E), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  static String _timestamp(BuildContext context, AuditLog e) {
    final d = e.createdAt?.toLocal();
    if (d == null) return '';
    final now = DateTime.now();
    final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final s = d.second.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    final time = '$h:$m:$s $ampm';
    if (d.year == now.year && d.month == now.month && d.day == now.day) return time;
    final y = now.subtract(const Duration(days: 1));
    if (d.year == y.year && d.month == y.month && d.day == y.day) {
      return context.tr(en: 'Yesterday $h:$m $ampm', ar: 'الأمس $h:$m $ampm');
    }
    return '${d.month}/${d.day}/${d.year} $time';
  }

  Widget _entryTile(BuildContext context, AuditLog e) {
    final category = _categoryOf(e);
    final color = _colorOf(category);
    final subject = e.entityType != null
        ? '${e.entityType}${e.entityId != null ? ' #${e.entityId}' : ''}'
        : (e.userId != null ? 'User #${e.userId}' : '');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.action,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                if (subject.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subject, style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary)),
                ],
                const SizedBox(height: 2),
                Text(_timestamp(context, e), style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(LucideIcons.lock, size: 16, color: SchooKeepColors.textSecondary),
        ],
      ),
    );
  }
}
