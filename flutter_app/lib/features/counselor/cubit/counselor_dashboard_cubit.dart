import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/counselor_tag.dart';
import '../../../data/repositories/counselor_repository.dart';
import '../../../data/repositories/student_repository.dart';

/// Aggregated data for the counselor dashboard: the recent wellbeing tags feed
/// plus a roster total used for the "Active cases" / summary tiles.
class CounselorDashboardData {
  const CounselorDashboardData({
    required this.recentTags,
    required this.studentCount,
  });

  final List<CounselorTag> recentTags;
  final int studentCount;
}

/// Loads the counselor dashboard from the API: recent tags
/// (`GET /counselor-tags`) and the student roster total (`GET /students`).
class CounselorDashboardCubit extends Cubit<DataState<CounselorDashboardData>> {
  CounselorDashboardCubit(this._counselorRepo, this._studentRepo)
      : super(const DataLoading()) {
    load();
  }

  final CounselorRepository _counselorRepo;
  final StudentRepository _studentRepo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final tagsPage = await _counselorRepo.tags();
      final studentsPage = await _studentRepo.list();
      emit(DataLoaded(CounselorDashboardData(
        recentTags: tagsPage.items,
        studentCount: studentsPage.total,
      )));
    } catch (e) {
      emit(DataError(CounselorRepository.messageFor(e)));
    }
  }
}
