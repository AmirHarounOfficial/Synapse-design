import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/student_repository.dart';

/// Loads a single student record for the Secretary student-detail screen
/// (`GET /students/{id}`).
class SecretaryStudentDetailCubit extends Cubit<DataState<Student>> {
  SecretaryStudentDetailCubit(this._repo, this._id) : super(const DataLoading()) {
    load();
  }

  final StudentRepository _repo;
  final int _id;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final student = await _repo.show(_id);
      emit(DataLoaded(student));
    } catch (e) {
      emit(DataError(StudentRepository.messageFor(e)));
    }
  }
}
