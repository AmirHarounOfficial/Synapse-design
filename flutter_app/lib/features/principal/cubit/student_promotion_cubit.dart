import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/analytics_repository.dart';

/// Drives the year-end promotion action (`POST /students/promote`).
sealed class StudentPromotionState {
  const StudentPromotionState();
}

class StudentPromotionIdle extends StudentPromotionState {
  const StudentPromotionIdle();
}

class StudentPromotionSubmitting extends StudentPromotionState {
  const StudentPromotionSubmitting();
}

class StudentPromotionDone extends StudentPromotionState {
  const StudentPromotionDone(this.summary);

  /// Raw response summary (e.g. `promoted_count`, `graduated_count`).
  final Map<String, dynamic> summary;
}

class StudentPromotionError extends StudentPromotionState {
  const StudentPromotionError(this.message);
  final String message;
}

class StudentPromotionCubit extends Cubit<StudentPromotionState> {
  StudentPromotionCubit(this._repo) : super(const StudentPromotionIdle());

  final AnalyticsRepository _repo;

  Future<void> promote({String? fromGrade}) async {
    emit(const StudentPromotionSubmitting());
    try {
      final summary = await _repo.promoteStudents(fromGrade: fromGrade);
      emit(StudentPromotionDone(summary));
    } catch (e) {
      emit(StudentPromotionError(AnalyticsRepository.messageFor(e)));
    }
  }
}
