import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/data_state.dart';
import '../../../data/models/clinic_visit.dart';
import '../../../data/models/document.dart';
import '../../../data/models/dose_administration.dart';
import '../../../data/models/medication.dart';
import '../../../data/repositories/clinic_repository.dart';
import '../../../data/repositories/document_repository.dart';
import '../../../data/repositories/medication_repository.dart';

/// One recent-activity row: either a logged dose or a clinic visit, normalised
/// for the unified activity list.
class ParentActivity {
  const ParentActivity({required this.kind, required this.label, this.at});

  final ParentActivityKind kind;
  final String label;
  final DateTime? at;
}

enum ParentActivityKind { dose, visit }

/// Aggregated view-model for the parent home dashboard.
class ParentDashboardData {
  const ParentDashboardData({
    required this.lastVisit,
    required this.recentActivity,
    required this.expiringDocument,
  });

  /// Most recent clinic visit (for the overview "last clinic visit" line).
  final ClinicVisit? lastVisit;

  /// Recent doses + visits, newest first.
  final List<ParentActivity> recentActivity;

  /// The document closest to expiring (for the expiry reminder), if any.
  final Document? expiringDocument;
}

/// Loads the parent home dashboard for the given [studentId] (the child).
/// Combines `GET /clinic-visits`, `GET /medications` + `GET /dose-administrations`
/// and `GET /documents` into a single view-model.
class ParentDashboardCubit extends Cubit<DataState<ParentDashboardData>> {
  ParentDashboardCubit(this._clinic, this._meds, this._documents, {this.studentId})
      : super(const DataLoading()) {
    load();
  }

  final ClinicRepository _clinic;
  final MedicationRepository _meds;
  final DocumentRepository _documents;
  final int? studentId;

  Future<void> load() async {
    emit(const DataLoading());
    try {
      final visitsPage = await _clinic.listVisits(studentId: studentId);
      final medsPage = await _meds.list(studentId: studentId);
      final dosesPage = await _meds.doseAdministrations(studentId: studentId);
      final docsPage = await _documents.list(studentId: studentId);

      final medsById = {for (final m in medsPage.items) m.id: m};

      final activity = <ParentActivity>[
        for (final d in dosesPage.items)
          ParentActivity(
            kind: ParentActivityKind.dose,
            label: _doseLabel(d, medsById[d.medicationId]),
            at: _parse(d.administeredAt) ?? _parse(d.scheduledFor),
          ),
        for (final v in visitsPage.items)
          ParentActivity(
            kind: ParentActivityKind.visit,
            label: v.reason ?? 'Clinic visit',
            at: v.visitedAt,
          ),
      ]..sort((a, b) {
          final ad = a.at, bd = b.at;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        });

      // Pick the soonest upcoming (or most recently passed) expiry date.
      Document? expiring;
      DateTime? best;
      for (final doc in docsPage.items) {
        final exp = _parse(doc.expiryDate);
        if (exp == null) continue;
        if (best == null || exp.isBefore(best)) {
          best = exp;
          expiring = doc;
        }
      }

      emit(DataLoaded(ParentDashboardData(
        lastVisit: visitsPage.items.isEmpty ? null : visitsPage.items.first,
        recentActivity: activity.take(3).toList(),
        expiringDocument: expiring,
      )));
    } catch (e) {
      emit(DataError(ClinicRepository.messageFor(e)));
    }
  }

  static String _doseLabel(DoseAdministration d, Medication? m) {
    final name = m?.name ?? 'Medication #${d.medicationId}';
    return '$name ${d.status == 'given' ? 'administered' : (d.status ?? '')}'.trim();
  }

  static DateTime? _parse(String? v) {
    if (v == null || v.isEmpty) return null;
    return DateTime.tryParse(v);
  }
}
