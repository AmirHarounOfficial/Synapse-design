import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/student_repository.dart';

/// Loads the student directory from the API. Reference Cubit for the API-wiring
/// pattern: `Cubit<DataState<T>>`, a `load()` that emits Loading → Loaded/Error.
class StudentListCubit extends Cubit<DataState<List<Student>>> {
  StudentListCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final StudentRepository _repo;

  Future<void> load({String? query, String? grade}) async {
    emit(const DataLoading());
    try {
      final page = await _repo.list(query: query, grade: grade);
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(StudentRepository.messageFor(e)));
    }
  }
}
