import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/dose_administration.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/medication_repository.dart';

/// A dose administration joined with its medication (for display labels).
class DailyDoseEntry {
  const DailyDoseEntry({required this.administration, this.medication});

  final DoseAdministration administration;
  final Medication? medication;

  String get medicationName => medication?.displayName ?? 'Medication #${administration.medicationId}';
}

/// Loads today's dose administrations and joins each to its medication so the
/// timeline can show medication names (`GET /dose-administrations?date=today`).
class DailyDoseCubit extends Cubit<DataState<List<DailyDoseEntry>>> {
  DailyDoseCubit(this._repo) : super(const DataLoading()) {
    load();
  }

  final MedicationRepository _repo;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final doses = await _repo.doseAdministrations(date: dateStr);
      final meds = await _repo.list();
      final byId = {for (final m in meds.items) m.id: m};
      final entries = doses.items
          .map((d) => DailyDoseEntry(administration: d, medication: byId[d.medicationId]))
          .toList();
      emit(DataLoaded(entries));
    } catch (e) {
      emit(DataError(MedicationRepository.messageFor(e)));
    }
  }
}
