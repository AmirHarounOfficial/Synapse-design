import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/pickup.dart';
import '../../../data/repositories/pickup_repository.dart';

/// Outcome of a QR scan against `POST /pickups/scan`.
sealed class ScanState {
  const ScanState();
}

class ScanIdle extends ScanState {
  const ScanIdle();
}

class ScanVerifying extends ScanState {
  const ScanVerifying();
}

/// QR matched an active authorized person → a verified pickup was created.
class ScanMatched extends ScanState {
  const ScanMatched(this.pickup);
  final Pickup pickup;
}

/// QR was not recognized / person inactive (HTTP 404).
class ScanNotRecognized extends ScanState {
  const ScanNotRecognized();
}

/// Any other failure (network, server) — show [message] and allow retry.
class ScanFailed extends ScanState {
  const ScanFailed(this.message);
  final String message;
}

/// Drives the real-camera QR scanner: on a detected code, calls the verify
/// endpoint and emits matched / not-recognized / failed.
class PickupScanCubit extends Cubit<ScanState> {
  PickupScanCubit(this._repo) : super(const ScanIdle());

  final PickupRepository _repo;
  bool _busy = false;

  Future<void> verify(String qrToken) async {
    if (_busy) return;
    _busy = true;
    emit(const ScanVerifying());
    try {
      final pickup = await _repo.scan(qrToken);
      emit(ScanMatched(pickup));
    } catch (e) {
      if (PickupRepository.isNotRecognized(e)) {
        emit(const ScanNotRecognized());
      } else {
        emit(ScanFailed(PickupRepository.messageFor(e)));
      }
    } finally {
      _busy = false;
    }
  }

  /// Reset to idle so the camera can scan again.
  void reset() {
    _busy = false;
    emit(const ScanIdle());
  }
}
