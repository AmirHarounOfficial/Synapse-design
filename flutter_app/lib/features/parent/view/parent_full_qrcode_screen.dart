import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/authorized_person.dart';
import '../../../data/repositories/pickup_repository.dart';
import '../cubit/authorized_persons_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentFullQRCode.tsx`, now wired to the API. Shows the pickup QR
/// for an authorized [person] (passed via router `extra`, or looked up by
/// [personId] from `GET /pickups`). The real `qr_token` payload from the API is
/// rendered below the placeholder QR visual (no QR-encoder package is bundled).
class ParentFullQrCodeScreen extends StatelessWidget {
  const ParentFullQrCodeScreen({super.key, required this.personId, this.person});

  final String personId;
  final AuthorizedPerson? person;

  @override
  Widget build(BuildContext context) {
    if (person != null) {
      return _FullQrView(person: person!);
    }
    // Deep-linked without state: resolve the person from the pickups list.
    final id = int.tryParse(personId);
    return BlocProvider(
      create: (_) => AuthorizedPersonsCubit(sl<PickupRepository>()),
      child: BlocBuilder<AuthorizedPersonsCubit, DataState<List<AuthorizedPerson>>>(
        builder: (context, state) {
          return switch (state) {
            DataLoading() => const SchooKeepScaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            DataError(:final message) => SchooKeepScaffold(
                appBar: SchooKeepAppBar(onBack: () => context.safeBack()),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: SchooKeepColors.textSecondary)),
                        const SizedBox(height: 16),
                        SchooKeepButton(
                          label: 'Retry',
                          fullWidth: false,
                          onPressed: () => context.read<AuthorizedPersonsCubit>().load(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            DataLoaded(:final data) => () {
                final match = data.where((p) => p.id == id).toList();
                if (match.isEmpty) {
                  return SchooKeepScaffold(
                    appBar: SchooKeepAppBar(onBack: () => context.safeBack()),
                    body: const Center(
                      child: Text('Authorized person not found.',
                          style: TextStyle(color: SchooKeepColors.textSecondary)),
                    ),
                  );
                }
                return _FullQrView(person: match.first);
              }(),
          };
        },
      ),
    );
  }
}

class _FullQrView extends StatefulWidget {
  const _FullQrView({required this.person});
  final AuthorizedPerson person;

  @override
  State<_FullQrView> createState() => _FullQrViewState();
}

class _FullQrViewState extends State<_FullQrView> {
  int _timeRemaining = 60;
  Timer? _timer;
  late final String _generatedAt;

  @override
  void initState() {
    super.initState();
    _generatedAt = _formatNow();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_timeRemaining <= 1) {
          _timeRemaining = 0;
          _timer?.cancel();
        } else {
          _timeRemaining -= 1;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatNow() {
    final t = TimeOfDay.now();
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    final person = widget.person;
    final personName = person.name;
    final relationship = person.relationship ?? '';
    final childName = person.studentName;
    final qrToken = person.qrToken ?? '';
    final isUrgent = _timeRemaining <= 10;

    return SchooKeepScaffold(
      backgroundColor: SchooKeepColors.surface,
      appBar: SchooKeepAppBar(onBack: () => context.safeBack()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
              child: Text(person.initials,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: SchooKeepColors.primary)),
            ),
            const SizedBox(height: 16),
            Text(personName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
            if (relationship.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(relationship, style: const TextStyle(fontSize: 15, color: SchooKeepColors.textSecondary)),
            ],
            if (childName != null) ...[
              const SizedBox(height: 8),
              Text(
                isRTL ? 'مخوّل لاستلام $childName' : 'Authorized pickup for $childName',
                style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary),
              ),
            ],
            const SizedBox(height: 32),
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: SchooKeepColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SchooKeepColors.textPrimary, width: 4),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const _QrPattern(),
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SchooKeepColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SchooKeepColors.textPrimary, width: 2),
                    ),
                    child: const Text('S',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SchooKeepColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // The real QR payload the security app scans (POST /pickups/scan).
            if (qrToken.isNotEmpty)
              SelectableText(
                qrToken,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: SchooKeepColors.textSecondary,
                ),
              ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SchooKeepColors.primary),
              ),
              child: Text(
                isRTL ? 'اعرض هذا على حارس الأمن عند الاستلام' : 'Show this to the security guard at pickup',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1E40AF)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.clock,
                    size: 16, color: isUrgent ? SchooKeepColors.error : SchooKeepColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  isRTL
                      ? 'ستُقفل هذه الشاشة خلال $_timeRemaining ثانية'
                      : 'This screen will lock in $_timeRemaining seconds',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isUrgent ? SchooKeepColors.error : SchooKeepColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              isRTL ? 'تم الإنشاء الساعة $_generatedAt' : 'Generated at $_generatedAt',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 8x8 deterministic finder-pattern grid that mimics a QR code.
class _QrPattern extends StatelessWidget {
  const _QrPattern();

  static const List<List<int>> _cells = [
    [1, 1, 1, 0, 1, 0, 1, 1],
    [1, 0, 1, 1, 0, 1, 0, 1],
    [1, 1, 0, 0, 1, 1, 1, 0],
    [0, 1, 1, 0, 0, 1, 0, 1],
    [1, 0, 1, 1, 1, 0, 1, 0],
    [0, 1, 0, 1, 0, 1, 1, 1],
    [1, 1, 1, 0, 1, 0, 0, 1],
    [1, 0, 1, 1, 0, 1, 1, 0],
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          for (final row in _cells)
            Expanded(
              child: Row(
                children: [
                  for (final cell in row)
                    Expanded(
                      child: ColoredBox(
                        color: cell == 1 ? SchooKeepColors.textPrimary : SchooKeepColors.surface,
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
