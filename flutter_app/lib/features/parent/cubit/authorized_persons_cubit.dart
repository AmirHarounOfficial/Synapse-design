import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/authorized_person.dart';
import '../../../data/repositories/pickup_repository.dart';

/// Loads the authorized pickup persons (and their QR payloads) for the parent's
/// "Authorized Pickups" manager and full-QR screen.
///
/// The API has no standalone authorized-persons endpoint, so the list is
/// derived from `GET /pickups` (each pickup nests its `authorized_person`),
/// de-duplicated by person id.
class AuthorizedPersonsCubit extends Cubit<DataState<List<AuthorizedPerson>>> {
  AuthorizedPersonsCubit(this._repo, {this.studentId}) : super(const DataLoading()) {
    load();
  }

  final PickupRepository _repo;
  final int? studentId;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final List<AuthorizedPerson> people;
      if (studentId != null) {
        people = await _repo.authorizedPersonsForStudent(studentId!);
      } else {
        final page = await _repo.list();
        final byId = <int, AuthorizedPerson>{};
        for (final p in page.items) {
          final person = p.authorizedPerson;
          if (person != null && person.isActive) {
            byId.putIfAbsent(person.id, () => person);
          }
        }
        people = byId.values.toList();
      }
      emit(DataLoaded(people));
    } catch (e) {
      emit(DataError(PickupRepository.messageFor(e)));
    }
  }
}
