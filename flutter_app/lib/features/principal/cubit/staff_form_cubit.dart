import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/staff.dart';
import '../../../data/repositories/staff_repository.dart';

/// Backs both `/principal/add-staff` and `/principal/edit-staff/:id`. In add
/// mode it starts immediately ready with no staff to prefill; in edit mode it
/// loads the existing member via `GET /staff/{id}` before the form prefills.
sealed class StaffFormState {
  const StaffFormState();
}

class StaffFormLoading extends StaffFormState {
  const StaffFormLoading();
}

class StaffFormError extends StaffFormState {
  const StaffFormError(this.message);
  final String message;
}

class StaffFormReady extends StaffFormState {
  const StaffFormReady({this.staff, this.submitting = false});

  /// Non-null in edit mode (the member being edited); null when adding.
  final Staff? staff;
  final bool submitting;

  StaffFormReady copyWith({bool? submitting}) =>
      StaffFormReady(staff: staff, submitting: submitting ?? this.submitting);
}

class StaffFormCubit extends Cubit<StaffFormState> {
  StaffFormCubit(this._repo, {this.staffId}) : super(const StaffFormLoading()) {
    load();
  }

  final StaffRepository _repo;
  final int? staffId;

  Future<void> load() async {
    if (staffId == null) {
      emit(const StaffFormReady());
      return;
    }
    emit(const StaffFormLoading());
    try {
      final staff = await _repo.show(staffId!);
      emit(StaffFormReady(staff: staff));
    } catch (e) {
      emit(StaffFormError(StaffRepository.messageFor(e)));
    }
  }

  /// Creates a new staff member. Returns true on success.
  Future<bool> submitCreate({
    required String name,
    required String email,
    required String role,
    String? phone,
    String? title,
  }) async {
    final current = state;
    if (current is! StaffFormReady) return false;
    emit(current.copyWith(submitting: true));
    try {
      await _repo.create(name: name, email: email, role: role, phone: phone, title: title);
      return true;
    } catch (e) {
      emit(StaffFormError(StaffRepository.messageFor(e)));
      return false;
    }
  }

  /// Updates the existing staff member. Returns true on success.
  Future<bool> submitUpdate({
    required int id,
    String? name,
    String? role,
    String? phone,
    String? title,
    bool? isActive,
  }) async {
    final current = state;
    if (current is! StaffFormReady) return false;
    emit(current.copyWith(submitting: true));
    try {
      await _repo.update(id, name: name, role: role, phone: phone, title: title, isActive: isActive);
      return true;
    } catch (e) {
      emit(StaffFormError(StaffRepository.messageFor(e)));
      return false;
    }
  }

  /// Deactivates the staff member. Returns true on success.
  Future<bool> deactivate(int id) async {
    final current = state;
    if (current is! StaffFormReady) return false;
    emit(current.copyWith(submitting: true));
    try {
      await _repo.deactivate(id);
      return true;
    } catch (e) {
      emit(StaffFormError(StaffRepository.messageFor(e)));
      return false;
    }
  }
}
