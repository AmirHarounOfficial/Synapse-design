import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/halal_certification.dart';
import '../../../data/repositories/cafeteria_repository.dart';

/// Loads Halal certifications (`GET /halal-certifications`, ordered by expiry).
/// The list is exposed as a whole so screens can pick the most relevant cert
/// (e.g. the soonest-expiring / currently-valid one) for their banner.
class HalalCertificationCubit extends Cubit<DataState<List<HalalCertification>>> {
  HalalCertificationCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final CafeteriaRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.halalCertifications();
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(CafeteriaRepository.messageFor(e)));
    }
  }
}
