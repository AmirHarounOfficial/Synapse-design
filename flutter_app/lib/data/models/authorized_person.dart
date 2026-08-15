/// An authorized pickup person, matching the nested `authorized_person` shape
/// in `PickupResource` (the API has no standalone AuthorizedPersonResource).
class AuthorizedPerson {
  const AuthorizedPerson({
    required this.id,
    required this.name,
    this.relationship,
    this.phone,
    this.photoUrl,
    this.qrToken,
    this.isActive = true,
    this.studentId,
    this.studentName,
  });

  final int id;
  final String name;
  final String? relationship;
  final String? phone;
  final String? photoUrl;

  /// The QR payload security scans at pickup (`POST /pickups/scan {qr_token}`).
  final String? qrToken;
  final bool isActive;

  /// Derived from the owning pickup/student when available (not on the nested
  /// resource itself).
  final int? studentId;
  final String? studentName;

  /// First-letter initials derived from the name (the API has no initials field).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  factory AuthorizedPerson.fromJson(
    Map<String, dynamic> j, {
    int? studentId,
    String? studentName,
  }) =>
      AuthorizedPerson(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
        relationship: j['relationship'] as String?,
        phone: j['phone'] as String?,
        photoUrl: j['photo_url'] as String?,
        qrToken: j['qr_token'] as String?,
        isActive: j['is_active'] as bool? ?? true,
        studentId: studentId,
        studentName: studentName,
      );
}
