import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/emergency_consent.dart';
import '../../../data/repositories/clinic_repository.dart';

/// Loads the pending emergency consent for the parent to act on, and submits
/// their response (`POST /emergency-consents/{id}/respond`).
class EmergencyConsentResponseCubit extends Cubit<DataState<EmergencyConsent>> {
  EmergencyConsentResponseCubit(this._repo, {this.consentId}) : super(const DataLoading()) {
    load();
  }

  final ClinicRepository _repo;
  final int? consentId;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      if (consentId != null) {
        emit(DataLoaded(await _repo.showConsent(consentId!)));
        return;
      }
      // No id passed: surface the most recent pending consent.
      final page = await _repo.listConsents(status: 'pending');
      if (page.items.isEmpty) {
        emit(const DataError('No pending emergency authorization requests.'));
        return;
      }
      emit(DataLoaded(page.items.first));
    } catch (e) {
      emit(DataError(ClinicRepository.messageFor(e)));
    }
  }

  /// Responds to the loaded consent. [authorize] true → approved, false →
  /// declined. Returns the error message on failure, or null on success.
  Future<String?> respond(bool authorize) async {
    final current = state;
    if (current is! DataLoaded<EmergencyConsent>) {
      return 'No request is loaded to respond to.';
    }
    try {
      final updated = await _repo.respondConsent(
        current.data.id,
        authorize ? 'approved' : 'declined',
      );
      emit(DataLoaded(updated));
      return null;
    } catch (e) {
      return ClinicRepository.messageFor(e);
    }
  }
}
