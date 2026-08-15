/// Halal certification record, matching `HalalCertificationResource` from the API.
class HalalCertification {
  const HalalCertification({
    required this.id,
    required this.schoolId,
    required this.supplier,
    required this.certificateNo,
    this.issuedDate,
    this.expiryDate,
    this.status,
  });

  final int id;
  final int schoolId;
  final String supplier;
  final String certificateNo;
  final String? issuedDate; // yyyy-MM-dd
  final String? expiryDate; // yyyy-MM-dd
  final String? status; // valid | expiring | expired

  factory HalalCertification.fromJson(Map<String, dynamic> j) => HalalCertification(
        id: (j['id'] as num).toInt(),
        schoolId: (j['school_id'] as num?)?.toInt() ?? 0,
        supplier: j['supplier'] as String? ?? '',
        certificateNo: j['certificate_no'] as String? ?? '',
        issuedDate: j['issued_date'] as String?,
        expiryDate: j['expiry_date'] as String?,
        status: j['status'] as String?,
      );
}
