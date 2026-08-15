import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/student.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../features/auth/data/auth_repository.dart';

/// Backs the teacher clinic referral form. Student search hits `GET /students`;
/// submitting a referral creates a clinic visit (`POST /clinic-visits`).
///
/// NOTE: the backend has no dedicated teacher-referral endpoint, and clinic
/// visit writes are nurse-only (`role:nurse`). A teacher submit will therefore
/// be rejected (403) by the API; the screen surfaces that mapped message.
class TeacherClinicReferralCubit extends Cubit<DataState<List<Student>>> {
  TeacherClinicReferralCubit(this._clinic, this._students, this._auth) : super(const DataLoaded([]));

  final ClinicRepository _clinic;
  final StudentRepository _students;
  final AuthRepository _auth;

  int? _schoolId;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const DataLoaded([]));
      return;
    }
    emit(const DataLoading());
    try {
      final page = await _students.list(query: query, schoolId: _schoolId);
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(ClinicRepository.messageFor(e)));
    }
  }

  /// Submits the referral as a clinic visit. Returns null on success, else the
  /// mapped error message.
  Future<String?> submit({
    required Student student,
    required String description,
    required String severity,
    required String location,
    required bool isEmergency,
  }) async {
    try {
      final schoolId = _schoolId ?? student.schoolId;
      if (schoolId == 0) {
        final me = await _auth.me();
        _schoolId = me.schoolId;
      }
      await _clinic.createVisit(
        studentId: student.id,
        schoolId: _schoolId ?? student.schoolId,
        reason: 'Teacher referral — $location',
        notes: description,
        severity: severity,
        isEmergency: isEmergency,
      );
      return null;
    } catch (e) {
      return ClinicRepository.messageFor(e);
    }
  }
}
