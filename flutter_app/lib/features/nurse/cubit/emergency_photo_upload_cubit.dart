import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/student.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/document_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../features/auth/data/auth_repository.dart';

/// Resolves the current school + a student, then submits an emergency incident
/// as a clinic visit (`POST /clinic-visits`, is_emergency=true). The captured
/// photo is uploaded via [DocumentRepository.uploadPhoto] when an upload
/// endpoint is available; failures there are non-fatal so the emergency record
/// is still logged.
sealed class EmergencyPhotoUploadState {
  const EmergencyPhotoUploadState();
}

class EmergencyUploadLoading extends EmergencyPhotoUploadState {
  const EmergencyUploadLoading();
}

class EmergencyUploadReady extends EmergencyPhotoUploadState {
  const EmergencyUploadReady({required this.student, required this.schoolId});
  final Student student;
  final int schoolId;
}

class EmergencyUploadError extends EmergencyPhotoUploadState {
  const EmergencyUploadError(this.message);
  final String message;
}

class EmergencyPhotoUploadCubit extends Cubit<EmergencyPhotoUploadState> {
  EmergencyPhotoUploadCubit(this._clinic, this._documents, this._students, this._auth)
      : super(const EmergencyUploadLoading()) {
    load();
  }

  final ClinicRepository _clinic;
  final DocumentRepository _documents;
  final StudentRepository _students;
  final AuthRepository _auth;

  Future<void> load() async {
    emit(const EmergencyUploadLoading());
    try {
      final me = await _auth.me();
      final page = await _students.list(schoolId: me.schoolId);
      if (page.items.isEmpty) {
        emit(const EmergencyUploadError('No students available to file an emergency report for.'));
        return;
      }
      emit(EmergencyUploadReady(student: page.items.first, schoolId: me.schoolId ?? page.items.first.schoolId));
    } catch (e) {
      emit(EmergencyUploadError(ClinicRepository.messageFor(e)));
    }
  }

  /// Submits the emergency report. Returns null on success, or an error message.
  Future<String?> submit({
    required String location,
    required String description,
    required String severity,
    String? photoPath,
  }) async {
    final current = state;
    if (current is! EmergencyUploadReady) return 'Still loading. Please wait.';
    try {
      String? photoUrl;
      if (photoPath != null && photoPath.isNotEmpty) {
        final doc = await _documents.upload(
          filePath: photoPath,
          studentId: current.student.id,
          type: 'emergency_photo',
        );
        photoUrl = doc.fileUrl ?? doc.filePath;
      }
      await _clinic.createVisit(
        studentId: current.student.id,
        schoolId: current.schoolId,
        reason: 'Emergency — $location',
        notes: description,
        severity: severity,
        isEmergency: true,
        photoUrl: photoUrl,
      );
      return null;
    } catch (e) {
      return ClinicRepository.messageFor(e);
    }
  }
}
