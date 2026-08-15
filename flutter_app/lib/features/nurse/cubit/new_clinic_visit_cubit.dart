import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/student.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../features/auth/data/auth_repository.dart';

/// State for logging a new clinic visit. Resolves the current nurse's school
/// and a student to attach the visit to, then POSTs to `/clinic-visits`.
sealed class NewClinicVisitState {
  const NewClinicVisitState();
}

class NewClinicVisitLoading extends NewClinicVisitState {
  const NewClinicVisitLoading();
}

class NewClinicVisitReady extends NewClinicVisitState {
  const NewClinicVisitReady({required this.student, required this.schoolId, this.submitting = false});
  final Student student;
  final int schoolId;
  final bool submitting;

  NewClinicVisitReady copyWith({bool? submitting}) =>
      NewClinicVisitReady(student: student, schoolId: schoolId, submitting: submitting ?? this.submitting);
}

class NewClinicVisitError extends NewClinicVisitState {
  const NewClinicVisitError(this.message);
  final String message;
}

class NewClinicVisitCubit extends Cubit<NewClinicVisitState> {
  NewClinicVisitCubit(this._clinic, this._students, this._auth) : super(const NewClinicVisitLoading()) {
    load();
  }

  final ClinicRepository _clinic;
  final StudentRepository _students;
  final AuthRepository _auth;

  Future<void> load() async {
    emit(const NewClinicVisitLoading());
    try {
      final me = await _auth.me();
      final page = await _students.list(schoolId: me.schoolId);
      if (page.items.isEmpty) {
        emit(const NewClinicVisitError('No students available to log a visit for.'));
        return;
      }
      final schoolId = me.schoolId ?? page.items.first.schoolId;
      emit(NewClinicVisitReady(student: page.items.first, schoolId: schoolId));
    } catch (e) {
      emit(NewClinicVisitError(ClinicRepository.messageFor(e)));
    }
  }

  /// Submits the visit. Returns true on success. Caller passes the form values.
  Future<bool> submit({
    required String reason,
    required String notes,
    required bool isEmergency,
    String? severity,
  }) async {
    final current = state;
    if (current is! NewClinicVisitReady) return false;
    emit(current.copyWith(submitting: true));
    try {
      await _clinic.createVisit(
        studentId: current.student.id,
        schoolId: current.schoolId,
        reason: reason,
        notes: notes,
        severity: severity,
        isEmergency: isEmergency,
      );
      emit(current.copyWith(submitting: false));
      return true;
    } catch (e) {
      emit(NewClinicVisitError(ClinicRepository.messageFor(e)));
      return false;
    }
  }
}
