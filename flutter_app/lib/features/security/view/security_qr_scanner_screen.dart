import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/pickup_repository.dart';
import '../cubit/pickup_scan_cubit.dart';

/// Ported from `SecurityQRScanner.tsx`, now backed by a REAL [MobileScanner]
/// camera preview. On a detected QR the `POST /pickups/scan` endpoint is called:
/// a match routes to the authorized-confirmation screen (passing the verified
/// pickup); a no-match routes to manual verification. The dark overlay +
/// corner-bracket framing is kept over the live preview.
class SecurityQrScannerScreen extends StatelessWidget {
  const SecurityQrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PickupScanCubit(sl<PickupRepository>()),
      child: const _ScannerView(),
    );
  }
}

class _ScannerView extends StatefulWidget {
  const _ScannerView();

  @override
  State<_ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<_ScannerView> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final cubit = context.read<PickupScanCubit>();
    if (cubit.state is! ScanIdle) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null) return;
    cubit.verify(raw);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PickupScanCubit, ScanState>(
      listener: (context, state) {
        if (state is ScanMatched) {
          context.go('/security/authorized-confirmation', extra: state.pickup);
        }
      },
      builder: (context, state) {
        final Color bg = switch (state) {
          ScanMatched() => SchooKeepColors.accent,
          ScanNotRecognized() => SchooKeepColors.error,
          ScanFailed() => SchooKeepColors.error,
          _ => Colors.black,
        };

        return ColoredBox(
          color: bg,
          child: Column(
            children: [
              SizedBox(height: SchooKeepTheme.statusBarHeight, child: ColoredBox(color: bg)),
              Expanded(
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: switch (state) {
                    ScanNotRecognized() => _unauthorizedView(context, null),
                    ScanFailed(:final message) => _unauthorizedView(context, message),
                    _ => _scannerView(context, state),
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _scannerView(BuildContext context, ScanState state) {
    final verifying = state is ScanVerifying || state is ScanMatched;
    return Stack(
      children: [
        // REAL live camera preview.
        Positioned.fill(
          child: MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Camera unavailable: ${error.errorCode}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ),
        // Dark dimming layer over the preview.
        const Positioned.fill(child: ColoredBox(color: Colors.black38)),
        // Scan area with corner brackets.
        Center(
          child: SizedBox(
            width: 256,
            height: 256,
            child: Stack(
              children: const [
                _Corner(alignment: Alignment.topLeft, top: true, left: true),
                _Corner(alignment: Alignment.topRight, top: true, left: false),
                _Corner(alignment: Alignment.bottomLeft, top: false, left: true),
                _Corner(alignment: Alignment.bottomRight, top: false, left: false),
              ],
            ),
          ),
        ),
        // Instruction panel.
        Positioned(
          left: 16,
          right: 16,
          bottom: 32,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text("Scan the pickup person's QR code",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                Text(
                    verifying
                        ? 'Verifying…'
                        : 'Position the QR code within the frame above',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                const SizedBox(height: 16),
                if (verifying) const CircularProgressIndicator(color: Colors.white),
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
                  ),
                  child: _simButton(
                    label: 'Manual Verification Instead',
                    color: Colors.white.withValues(alpha: 0.2),
                    onTap: () => context.go('/security/manual-verification'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _simButton({required String label, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _unauthorizedView(BuildContext context, String? customMessage) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 384),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(LucideIcons.x, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('NOT RECOGNIZED',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Text(
                  customMessage ??
                      'This QR code is not in our authorized pickup database for any current student.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.9))),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => context.go('/security/manual-verification'),
                  child: const Text('Manual Verification Required',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: SchooKeepColors.error)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => context.read<PickupScanCubit>().reset(),
                  child: const Text('Scan Again',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.alignment, required this.top, required this.left});
  final Alignment alignment;
  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: Colors.white, width: 4);
    return Align(
      alignment: alignment,
      child: Container(
        width: 48,
        height: 48,
        // A borderRadius is illegal on a non-uniform Border (asserts in debug),
        // so the scanner corner brackets are drawn as plain L-shapes.
        decoration: BoxDecoration(
          border: Border(
            top: top ? side : BorderSide.none,
            bottom: top ? BorderSide.none : side,
            left: left ? side : BorderSide.none,
            right: left ? BorderSide.none : side,
          ),
        ),
      ),
    );
  }
}
