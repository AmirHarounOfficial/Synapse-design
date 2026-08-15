import 'bus_boarding_event.dart';

/// A bus route + its boarding events, matching `BusRouteResource`.
class BusRoute {
  const BusRoute({
    required this.id,
    this.schoolId,
    required this.name,
    this.driverId,
    this.busNumber,
    this.period,
    this.status,
    this.events = const [],
  });

  final int id;
  final int? schoolId;
  final String name;
  final int? driverId;
  final String? busNumber;
  final String? period; // morning | afternoon
  final String? status;
  final List<BusBoardingEvent> events;

  factory BusRoute.fromJson(Map<String, dynamic> j) => BusRoute(
        id: (j['id'] as num).toInt(),
        schoolId: (j['school_id'] as num?)?.toInt(),
        name: j['name'] as String? ?? '',
        driverId: (j['driver_id'] as num?)?.toInt(),
        busNumber: j['bus_number'] as String?,
        period: j['period'] as String?,
        status: j['status'] as String?,
        events: (j['events'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(BusBoardingEvent.fromJson)
            .toList(),
      );
}
