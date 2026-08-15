import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/medication_repository.dart';

/// Loads a medication protocol for physician review and exposes approve/decline
/// actions (`GET /medications/{id}`, `POST /medications/{id}/approve|decline`).
class ProtocolReviewCubit extends Cubit<DataState<Medication>> {
  ProtocolReviewCubit(this._repo, this._id) : super(const DataLoading()) {
    load();
  }

  final MedicationRepository _repo;
  final int _id;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final medication = await _repo.show(_id);
      emit(DataLoaded(medication));
    } catch (e) {
      emit(DataError(MedicationRepository.messageFor(e)));
    }
  }

  /// Approves the protocol. Returns null on success or an error message.
  Future<String?> approve() async {
    try {
      final updated = await _repo.approve(_id);
      emit(DataLoaded(updated));
      return null;
    } catch (e) {
      return MedicationRepository.messageFor(e);
    }
  }

  /// Declines the protocol. Returns null on success or an error message.
  Future<String?> decline() async {
    try {
      final updated = await _repo.decline(_id);
      emit(DataLoaded(updated));
      return null;
    } catch (e) {
      return MedicationRepository.messageFor(e);
    }
  }
}
