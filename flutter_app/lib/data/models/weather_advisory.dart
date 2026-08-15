/// A weather/AQI advisory, matching `WeatherAdvisoryResource` from the API.
class WeatherAdvisory {
  const WeatherAdvisory({
    required this.id,
    this.schoolId,
    required this.kind,
    this.severity,
    required this.message,
    this.messageAr,
    this.active = false,
    this.startsAt,
    this.endsAt,
    this.createdAt,
  });

  final int id;
  final int? schoolId;
  final String kind; // haboob | aqi-dust | heat | flooding | other | ...
  final String? severity;
  final String message;
  final String? messageAr;
  final bool active;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? createdAt;

  factory WeatherAdvisory.fromJson(Map<String, dynamic> j) => WeatherAdvisory(
        id: (j['id'] as num).toInt(),
        schoolId: (j['school_id'] as num?)?.toInt(),
        kind: j['kind'] as String? ?? '',
        severity: j['severity'] as String?,
        message: j['message'] as String? ?? '',
        messageAr: j['message_ar'] as String?,
        active: j['active'] as bool? ?? false,
        startsAt: _date(j['starts_at']),
        endsAt: _date(j['ends_at']),
        createdAt: _date(j['created_at']),
      );

  static DateTime? _date(Object? v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
}
