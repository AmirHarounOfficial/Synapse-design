import '../../core/network/api_client.dart';
import '../models/bias_incident.dart';

class BiasIncidentRepository {
  BiasIncidentRepository([this.api]);

  final ApiClient? api;

  final List<BiasIncident> _items = [
    BiasIncident(
      id: 101,
      studentId: 1,
      studentName: 'Maya Thompson',
      reporterRole: 'teacher',
      reporterName: 'Sarah Jenkins (4th Grade Teacher)',
      location: 'classroom',
      category: 'verbal_slur',
      severity: 'medium',
      status: 'under_review',
      description: 'Reported inappropriate racial remark directed towards a classmate during group activity.',
      immediateActionTaken: 'Separated students, conducted immediate one-on-one reflection, and reinforced classroom anti-bias principles.',
      witnesses: 'Liam Parker, Sophia Chen',
      counselorNotes: 'Scheduled restorative dialogue session with both students for tomorrow morning.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    BiasIncident(
      id: 102,
      studentId: 2,
      studentName: 'Ethan Vance',
      reporterRole: 'bus_driver',
      reporterName: 'Robert Vance (Route #12 Driver)',
      location: 'bus',
      busRouteNumber: 'Route #12',
      category: 'harassment',
      severity: 'high',
      status: 'submitted',
      description: 'Repeated discriminatory chanting overheard on the rear seats of Route #12 near Stop #4.',
      immediateActionTaken: 'Pulled over safely at designated stop, issued verbal warning, and notified transport supervisor.',
      witnesses: 'Bus Monitor A. Rodriguez',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    BiasIncident(
      id: 103,
      studentId: 3,
      studentName: 'Zainab Al-Mansoori',
      reporterRole: 'teacher',
      reporterName: 'David Miller (Science Dept)',
      location: 'hallway',
      category: 'religious_ethnic_bias',
      severity: 'high',
      status: 'action_plan_active',
      description: 'Mocking cultural headwear and heritage during hallway passing period.',
      immediateActionTaken: 'Escorted offending student to guidance office and notified Vice Principal.',
      counselorNotes: 'Parent meeting conducted on May 28. Cultural sensitivity remediation plan assigned.',
      resolutionPlan: '1. Cultural awareness workshop completion\n2. Weekly counselor check-in\n3. Apology reflection letter',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Future<List<BiasIncident>> list({String? status, String? reporterRole}) async {
    if (api != null) {
      try {
        final queryParams = <String, String>{};
        if (status != null && status.isNotEmpty) queryParams['status'] = status;
        if (reporterRole != null && reporterRole.isNotEmpty) queryParams['reporter_role'] = reporterRole;
        final res = await api!.dio.get('/bias-incidents', queryParameters: queryParams);
        if (res.data is Map && res.data['data'] is List) {
          final list = res.data['data'] as List;
          return list.map((json) => BiasIncident.fromJson(json as Map<String, dynamic>)).toList();
        }
      } catch (_) {
        // Fallback to local memory cache if offline or API not initialized
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    var results = List<BiasIncident>.from(_items);
    if (status != null && status.isNotEmpty && status != 'all') {
      results = results.where((i) => i.status == status).toList();
    }
    if (reporterRole != null && reporterRole.isNotEmpty) {
      results = results.where((i) => i.reporterRole == reporterRole).toList();
    }
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  Future<BiasIncident> show(int id) async {
    if (api != null) {
      try {
        final res = await api!.dio.get('/bias-incidents/$id');
        if (res.data is Map && res.data['data'] is Map) {
          return BiasIncident.fromJson(res.data['data'] as Map<String, dynamic>);
        }
      } catch (_) {
        // Fallback to local mock data
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _items.firstWhere(
      (i) => i.id == id,
      orElse: () => throw Exception('Incident #$id not found'),
    );
  }

  Future<BiasIncident> create({
    required int studentId,
    required String studentName,
    required String reporterRole,
    required String reporterName,
    required String location,
    String? busRouteNumber,
    required String category,
    required String severity,
    required String description,
    String? immediateActionTaken,
    String? witnesses,
  }) async {
    final body = <String, dynamic>{
      'student_id': studentId,
      'student_name': studentName,
      'reporter_role': reporterRole,
      'reporter_name': reporterName,
      'location': location,
      'bus_route_number': ?busRouteNumber,
      'category': category,
      'severity': severity,
      'description': description,
      'immediate_action_taken': ?immediateActionTaken,
      'witnesses': ?witnesses,
    };

    if (api != null) {
      try {
        final res = await api!.dio.post('/bias-incidents', data: body);
        if (res.data is Map && res.data['data'] is Map) {
          final created = BiasIncident.fromJson(res.data['data'] as Map<String, dynamic>);
          _items.insert(0, created);
          return created;
        }
      } catch (_) {
        // Fallback to local memory insertion
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));
    final newIncident = BiasIncident(
      id: 100 + _items.length + 1,
      studentId: studentId,
      studentName: studentName,
      reporterRole: reporterRole,
      reporterName: reporterName,
      location: location,
      busRouteNumber: busRouteNumber,
      category: category,
      severity: severity,
      status: 'submitted',
      description: description,
      immediateActionTaken: immediateActionTaken,
      witnesses: witnesses,
      createdAt: DateTime.now(),
    );
    _items.insert(0, newIncident);
    return newIncident;
  }

  Future<BiasIncident> updateStatus(
    int id, {
    required String status,
    String? severity,
    String? counselorNotes,
    String? resolutionPlan,
  }) async {
    final body = <String, dynamic>{
      'status': status,
      'severity': ?severity,
      'counselor_notes': ?counselorNotes,
      'resolution_plan': ?resolutionPlan,
    };

    if (api != null) {
      try {
        final res = await api!.dio.patch('/bias-incidents/$id/status', data: body);
        if (res.data is Map && res.data['data'] is Map) {
          final updated = BiasIncident.fromJson(res.data['data'] as Map<String, dynamic>);
          final idx = _items.indexWhere((i) => i.id == id);
          if (idx != -1) _items[idx] = updated;
          return updated;
        }
      } catch (_) {
        // Fallback to local memory update
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) throw Exception('Incident #$id not found');

    final existing = _items[index];
    final updated = existing.copyWith(
      status: status,
      severity: severity ?? existing.severity,
      counselorNotes: counselorNotes ?? existing.counselorNotes,
      resolutionPlan: resolutionPlan ?? existing.resolutionPlan,
      resolvedAt: status == 'resolved' ? DateTime.now() : existing.resolvedAt,
    );
    _items[index] = updated;
    return updated;
  }
}
