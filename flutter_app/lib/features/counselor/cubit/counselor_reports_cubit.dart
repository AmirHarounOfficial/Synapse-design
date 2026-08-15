import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/counselor_report.dart';
import '../../../data/repositories/counselor_repository.dart';

/// Loads the counselor's reports from the API (`GET /counselor-reports`).
class CounselorReportsCubit extends Cubit<DataState<List<CounselorReport>>> {
  CounselorReportsCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final CounselorRepository _repo;

  Future<void> load({String? status}) async {
    emit(const DataLoading());
    try {
      final page = await _repo.reports(status: status);
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(CounselorRepository.messageFor(e)));
    }
  }
}
