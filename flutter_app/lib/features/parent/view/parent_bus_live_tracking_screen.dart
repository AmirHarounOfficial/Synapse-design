import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/data_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/bus_repository.dart';
import '../cubit/bus_tracking_cubit.dart';
import 'package:schookeep/core/router/safe_back.dart';

/// Ported from `ParentBusLiveTracking.tsx`, now wired to the bus-routes API and
/// using a REAL [FlutterMap] (OpenStreetMap tiles). The backend exposes no live
/// GPS, so the bus marker uses a static UAE coordinate (noted in the UI); the
/// route name + latest boarding status come from `GET /bus-routes/{id}`.
class ParentBusLiveTrackingScreen extends StatelessWidget {
  const ParentBusLiveTrackingScreen({super.key});

  /// Fallback coordinate (Dubai) used because the API has no live GPS feed.
  static const LatLng _fallbackBus = LatLng(25.2048, 55.2708);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BusTrackingCubit(sl<BusRepository>()),
      child: const _BusTrackingView(),
    );
  }
}

class _BusTrackingView extends StatelessWidget {
  const _BusTrackingView();

  @override
  Widget build(BuildContext context) {
    final isRTL = context.isRTL;

    return BlocBuilder<BusTrackingCubit, DataState<BusTrackingData>>(
      builder: (context, state) {
        final routeName = state is DataLoaded<BusTrackingData>
            ? state.data.route.name
            : (isRTL ? 'المسار' : 'Route');
        return SchooKeepScaffold(
          scrollable: false,
          appBar: SchooKeepAppBar(
            onBack: () => context.safeBack(),
            titleWidget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isRTL ? 'تتبع الحافلة' : 'Bus Tracking',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
                Text(routeName,
                    style: const TextStyle(fontSize: 13, color: SchooKeepColors.textSecondary)),
              ],
            ),
          ),
          body: switch (state) {
            DataLoading() => const Center(child: CircularProgressIndicator()),
            DataError(:final message) => _errorView(context, message),
            DataLoaded(:final data) => _content(context, isRTL, data),
          },
        );
      },
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
              label: 'Retry',
              fullWidth: false,
              onPressed: () => context.read<BusTrackingCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, bool isRTL, BusTrackingData data) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mapView(isRTL),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _statusCard(isRTL, data),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(
                isRTL
                    ? 'الموقع التقريبي معروض — لا تتوفر إحداثيات حية من الخادم بعد.'
                    : 'Approximate location shown — the server does not provide a live GPS feed yet.',
                style: const TextStyle(fontSize: 11, color: SchooKeepColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapView(bool isRTL) {
    return SizedBox(
      height: 468,
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: ParentBusLiveTrackingScreen._fallbackBus,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'ae.schookeep.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: ParentBusLiveTrackingScreen._fallbackBus,
                width: 120,
                height: 64,
                child: _BusPin(label: isRTL ? 'الحافلة' : 'Bus'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusCard(bool isRTL, BusTrackingData data) {
    final boarding = data.latestBoarding;
    final childName = boarding?.student?.name;
    final stop = boarding?.stopName;

    return SchooKeepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              data.route.status?.isNotEmpty == true
                  ? data.route.status!
                  : (isRTL ? 'قيد التشغيل' : 'En route'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SchooKeepColors.warning),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.route.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary),
          ),
          if ((data.route.busNumber ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(LucideIcons.bus, size: 12, color: SchooKeepColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  isRTL ? 'حافلة ${data.route.busNumber}' : 'Bus ${data.route.busNumber}',
                  style: const TextStyle(fontSize: 12, color: SchooKeepColors.textSecondary),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: SchooKeepColors.border),
          const SizedBox(height: 12),
          if (childName != null)
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Color(0xFFEDE9FE), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(_initials(childName),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF7C3AED))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: childName, style: const TextStyle(fontWeight: FontWeight.w500)),
                        TextSpan(
                          text: isRTL
                              ? ' صعد${stop != null ? ' في $stop' : ''}'
                              : ' boarded${stop != null ? ' at $stop' : ''}',
                        ),
                      ],
                    ),
                    style: const TextStyle(fontSize: 14, color: SchooKeepColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: SchooKeepColors.greenChipBg, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.check, size: 14, color: SchooKeepColors.accent),
                ),
              ],
            )
          else
            Text(
              isRTL ? 'لم يتم تسجيل صعود بعد.' : 'No boarding recorded yet.',
              style: const TextStyle(fontSize: 14, color: SchooKeepColors.textSecondary),
            ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _BusPin extends StatelessWidget {
  const _BusPin({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: SchooKeepColors.accent,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: const Icon(LucideIcons.bus, size: 24, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: SchooKeepColors.surface,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
          ),
          child: Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SchooKeepColors.textPrimary)),
        ),
      ],
    );
  }
}
