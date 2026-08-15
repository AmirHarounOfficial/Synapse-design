import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/student_repository.dart';

/// Aggregated data for the secretary dashboard: the current user's
/// notifications (used to derive pending-task counts) and the student roster
/// total (used for the directory tile).
class SecretaryDashboardData {
  const SecretaryDashboardData({
    required this.notifications,
    required this.studentCount,
  });

  final List<AppNotification> notifications;
  final int studentCount;

  int get unreadCount => notifications.where((n) => n.isUnread).length;
}

/// Loads the secretary dashboard from the API: notifications
/// (`GET /notifications`) and the student roster total (`GET /students`).
class SecretaryDashboardCubit extends Cubit<DataState<SecretaryDashboardData>> {
  SecretaryDashboardCubit(this._notificationRepo, this._studentRepo)
      : super(const DataLoading()) {
    load();
  }

  final NotificationRepository _notificationRepo;
  final StudentRepository _studentRepo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final notifications = await _notificationRepo.list();
      final students = await _studentRepo.list();
      emit(DataLoaded(SecretaryDashboardData(
        notifications: notifications.items,
        studentCount: students.total,
      )));
    } catch (e) {
      emit(DataError(NotificationRepository.messageFor(e)));
    }
  }
}
