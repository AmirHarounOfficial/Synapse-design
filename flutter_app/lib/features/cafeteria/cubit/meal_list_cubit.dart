import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/meal.dart';
import '../../../data/repositories/cafeteria_repository.dart';

/// Loads cafeteria meals (`GET /meals`, ordered by date desc). Used by the
/// delivery-history screen as the closest available record source (the backend
/// has no dedicated delivery-log endpoint).
class MealListCubit extends Cubit<DataState<List<Meal>>> {
  MealListCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final CafeteriaRepository _repo;

  Future<void> load({String? date}) async {
    emit(const DataLoading());
    try {
      final page = await _repo.meals(date: date);
      emit(DataLoaded(page.items));
    } catch (e) {
      emit(DataError(CafeteriaRepository.messageFor(e)));
    }
  }
}
