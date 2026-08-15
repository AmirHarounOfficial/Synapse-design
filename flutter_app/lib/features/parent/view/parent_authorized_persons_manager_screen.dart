import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

/// Ported from `ParentAuthorizedPersonsManager.tsx`, now wired to the API. Lists
/// the authorized pickup persons (derived from `GET /pickups`, which nests each
/// `authorized_person` + its `qr_token`). "View QR Code" opens the full-screen
/// QR, passing the selected person.
class ParentAuthorizedPersonsManagerScreen extends StatelessWidget {
  const ParentAuthorizedPersonsManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthorizedPersonsCubit(sl<PickupRepository>()),
      child: const _AuthorizedPersonsView(),
    );
  }
}

class _AuthorizedPersonsView extends StatelessWidget {
  const _AuthorizedPersonsView();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;
    return SchooKeepScaffold(
      reserveBottomNav: true,
      scrollable: true,
      appBar: SchooKeepAppBar(
        title: isRTL ? 'عمليات الاصطحاب المخوّلة' : 'Authorized Pickups',
        centerTitle: true,
        onBack: () => context.safeBack(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: BlocBuilder<AuthorizedPersonsCubit, DataState<List<AuthorizedPerson>>>(
          builder: (context, state) {
            return switch (state) {
              DataLoading() => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                ),
              DataError(:final message) => _errorView(context, isRTL, message),
              DataLoaded(:final data) => _content(context, isRTL, data),
            };
          },
        ),
      ),
    );
  }

  Widget _errorView(BuildContext context, bool isRTL, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: Column(
          children: [
            const Icon(LucideIcons.wifiOff, size: 36, color: SchooKeepColors.textSecondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: SchooKeepColors.textSecondary)),
            const SizedBox(height: 16),
            SchooKeepButton(
              label: isRTL ? 'إعادة المحاولة' : 'Retry',
              fullWidth: false,
              onPressed: () => context.read<AuthorizedPersonsCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, bool isRTL, List<AuthorizedPerson> people) {
    return Column(
      children: [
        if (people.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              isRTL ? 'لا يوجد أشخاص مخوّلون بعد.' : 'No authorized persons on file yet.',
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
            ),
          ),
        for (final person in people) ...[
          _personCard(context, isRTL, person),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 80,
          child: Material(
            color: SchooKeepColors.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.go('/parent/app/add-authorized-person'),
              child: DottedBorderBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.plus, size: 24, color: SchooKeepColors.primary),
                    const SizedBox(width: 8),
                    Text(isRTL ? 'إضافة شخص' : 'Add Person',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SchooKeepColors.primary)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SchooKeepColors.primary),
          ),
          child: Text(
            isRTL
                ? 'يجب على جميع الأشخاص المخوّلين تقديم رمز QR الفريد الخاص بهم وهوية حكومية صالحة لأمن المدرسة عند الاصطحاب.'
                : 'All authorized persons must present their unique QR code and a valid government-issued ID to school security during pickup.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
          ),
        ),
      ],
    );
  }

  Widget _personCard(BuildContext context, bool isRTL, AuthorizedPerson person) {
    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                child: Text(person.initials,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: SchooKeepColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(person.relationship ?? '',
                        style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary)),
                    if ((person.phone ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(person.phone!,
                          style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SchooKeepColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.go('/parent/app/full-qrcode/${person.id}', extra: person),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.qrCode, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(isRTL ? 'عرض رمز QR' : 'View QR Code',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed-border container matching the `border-2 border-dashed` add card.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Center(child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const radius = Radius.circular(12);
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, radius);
    final path = Path()..addRRect(rrect);
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
