import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/counselor_tag.dart';
import '../../../data/repositories/counselor_repository.dart';

/// Loads a student's wellbeing-tag history from the API
/// (`GET /counselor-tags?student_id=`).
class CounselorTagsCubit extends Cubit<DataState<List<CounselorTag>>> {
  CounselorTagsCubit(this._repo, {this.studentId}) : super(const DataLoading()) {
    load();
  }

  final CounselorRepository _repo;
  final int? studentId;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final page = await _repo.tags(studentId: studentId);
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(CounselorRepository.messageFor(e)));
    }
  }
}
