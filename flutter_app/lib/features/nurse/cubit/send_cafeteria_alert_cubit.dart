import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/student.dart';
import '../../../data/repositories/cafeteria_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../auth/data/auth_repository.dart';

/// State for the nurse "Send Cafeteria Alert" flow: live student search plus
/// the POST that creates the allergen alert.
sealed class SendAlertState {
  const SendAlertState();
}

class SendAlertIdle extends SendAlertState {
  const SendAlertIdle({this.results = const [], this.searching = false});
  final List<Student> results;
  final bool searching;
}

class SendAlertSubmitting extends SendAlertState {
  const SendAlertSubmitting();
}

class SendAlertSuccess extends SendAlertState {
  const SendAlertSuccess(this.sentAt);
  final String sentAt;
}

class SendAlertFailure extends SendAlertState {
  const SendAlertFailure(this.message);
  final String message;
}

/// Wires the send-cafeteria-alert screen to the API: it searches students via
/// `GET /students` and posts the alert via `POST /cafeteria-alerts`, deriving
/// the required `school_id` from the signed-in nurse (`GET /auth/me`).
class SendCafeteriaAlertCubit extends Cubit<SendAlertState> {
  SendCafeteriaAlertCubit(this._cafeteria, this._students, this._auth)
      : super(const SendAlertIdle());

  final CafeteriaRepository _cafeteria;
  final StudentRepository _students;
  final AuthRepository _auth;

  int _seq = 0;
  int? _cachedSchoolId;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const SendAlertIdle());
      return;
    }
    final seq = ++_seq;
    emit(const SendAlertIdle(searching: true));
    try {
      final page = await _students.list(query: query);
      if (seq != _seq) return; // a newer search superseded this one
      emit(SendAlertIdle(results: page.items));
    } catch (_) {
      if (seq != _seq) return;
      emit(const SendAlertIdle());
    }
  }

  void clearResults() => emit(const SendAlertIdle());

  /// Posts the alert. [title] and [message] are composed by the screen from the
  /// selected dietary/allergen restrictions.
  Future<void> send({
    required int studentId,
    required String title,
    required String message,
    bool isHalalIssue = false,
    String? createdForDate,
  }) async {
    emit(const SendAlertSubmitting());
    try {
      final schoolId = await _resolveSchoolId();
      await _cafeteria.createAlert(
        schoolId: schoolId,
        studentId: studentId,
        title: title,
        message: message,
        severity: 'warning',
        isHalalIssue: isHalalIssue,
        createdForDate: createdForDate,
      );
      emit(SendAlertSuccess(_nowTime()));
    } catch (e) {
      emit(SendAlertFailure(CafeteriaRepository.messageFor(e)));
    }
  }

  Future<int> _resolveSchoolId() async {
    final cached = _cachedSchoolId;
    if (cached != null) return cached;
    final user = await _auth.me();
    final id = user.schoolId;
    if (id == null) {
      throw StateError('No school is associated with your account.');
    }
    _cachedSchoolId = id;
    return id;
  }

  static String _nowTime() {
    final now = DateTime.now();
    final h24 = now.hour;
    final period = h24 < 12 ? 'AM' : 'PM';
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '${h12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
  }
}
