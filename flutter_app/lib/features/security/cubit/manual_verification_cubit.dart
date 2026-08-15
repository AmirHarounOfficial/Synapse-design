import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/authorized_person.dart';
import '../../../data/models/pickup.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/pickup_repository.dart';
import '../../../data/repositories/student_repository.dart';

/// State for the manual-verification flow: search students, inspect the
/// authorized person on file, then release (match) or deny (no match).
sealed class ManualVerificationState {
  const ManualVerificationState();
}

class ManualSearchIdle extends ManualVerificationState {
  const ManualSearchIdle();
}

class ManualSearchLoading extends ManualVerificationState {
  const ManualSearchLoading();
}

class ManualSearchResults extends ManualVerificationState {
  const ManualSearchResults(this.students);
  final List<Student> students;
}

class ManualSearchError extends ManualVerificationState {
  const ManualSearchError(this.message);
  final String message;
}

/// A student was picked; loading their authorized person(s).
class ManualDetailLoading extends ManualVerificationState {
  const ManualDetailLoading(this.student);
  final Student student;
}

class ManualDetailLoaded extends ManualVerificationState {
  const ManualDetailLoaded({required this.student, required this.person, required this.pickup});
  final Student student;

  /// Null when the student has no authorized person on file.
  final AuthorizedPerson? person;

  /// A pending/verified pickup that can be released, if one exists.
  final Pickup? pickup;
}

class ManualDetailError extends ManualVerificationState {
  const ManualDetailError({required this.student, required this.message});
  final Student student;
  final String message;
}

class ManualVerificationCubit extends Cubit<ManualVerificationState> {
  ManualVerificationCubit(this._students, this._pickups) : super(const ManualSearchIdle());

  final StudentRepository _students;
  final PickupRepository _pickups;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const ManualSearchIdle());
      return;
    }
    emit(const ManualSearchLoading());
    try {
      final page = await _students.list(query: query);
      emit(ManualSearchResults(page.items));
    } catch (e) {
      emit(ManualSearchError(StudentRepository.messageFor(e)));
    }
  }

  Future<void> select(Student student) async {
    emit(ManualDetailLoading(student));
    try {
      final page = await _pickups.list(studentId: student.id);
      final queueable = page.items
          .where((p) => p.status == 'pending' || p.status == 'verified')
          .toList();
      AuthorizedPerson? person;
      for (final p in page.items) {
        if (p.authorizedPerson != null && p.authorizedPerson!.isActive) {
          person = p.authorizedPerson;
          break;
        }
      }
      emit(ManualDetailLoaded(
        student: student,
        person: person,
        pickup: queueable.isNotEmpty ? queueable.first : null,
      ));
    } catch (e) {
      emit(ManualDetailError(student: student, message: PickupRepository.messageFor(e)));
    }
  }

  void backToSearch() => emit(const ManualSearchIdle());

  /// Releases the given pickup (match confirmed). Returns true on success.
  Future<bool> release(Pickup pickup) async {
    try {
      await _pickups.release(pickup.id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
