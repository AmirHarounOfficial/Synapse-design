import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/emergency_consent.dart';
import '../../../data/repositories/clinic_repository.dart';

/// Loads the most recent pending emergency consent so the nurse can watch its
/// status while awaiting the parent's response (`GET /emergency-consents`).
///
/// NOTE: the API has no endpoint to *create* an emergency consent, so this
/// screen surfaces the latest pending request rather than issuing a new one.
class EmergencyConsentRequestCubit extends Cubit<DataState<EmergencyConsent?>> {
  EmergencyConsentRequestCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final ClinicRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.listConsents(status: 'pending');
      emit(DataLoaded(page.items.isEmpty ? null : page.items.first));
    } catch (e) {
      emit(DataError(ClinicRepository.messageFor(e)));
    }
  }
}
