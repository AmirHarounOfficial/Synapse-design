/// Student + nested allergen, matching `StudentResource` from the API.
class StudentAllergen {
  const StudentAllergen({required this.allergen, this.allergenAr, this.severity, this.notes});

  final String allergen;
  final String? allergenAr;
  final String? severity; // mild | moderate | severe
  final String? notes;

  factory StudentAllergen.fromJson(Map<String, dynamic> j) => StudentAllergen(
        allergen: j['allergen'] as String? ?? '',
        allergenAr: j['allergen_ar'] as String?,
        severity: j['severity'] as String?,
        notes: j['notes'] as String?,
      );
}

class Student {
  const Student({
    required this.id,
    required this.schoolId,
    required this.name,
    this.nameAr,
    this.grade,
    this.section,
    this.emiratesId,
    this.dateOfBirth,
    this.gender,
    this.photoUrl,
    this.bloodType,
    this.curriculum,
    this.medicalSummary,
    this.profileActive = true,
    this.allergens = const [],
  });

  final int id;
  final int schoolId;
  final String name;
  final String? nameAr;
  final String? grade;
  final String? section;
  final String? emiratesId;
  final String? dateOfBirth;
  final String? gender;
  final String? photoUrl;
  final String? bloodType;
  final String? curriculum;
  final String? medicalSummary;
  final bool profileActive;
  final List<StudentAllergen> allergens;

  /// First-letter initials derived from the name (the API has no initials field).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  factory Student.fromJson(Map<String, dynamic> j) => Student(
        id: (j['id'] as num).toInt(),
        schoolId: (j['school_id'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? '',
        nameAr: j['name_ar'] as String?,
        grade: j['grade'] as String?,
        section: j['section'] as String?,
        emiratesId: j['emirates_id'] as String?,
        dateOfBirth: j['date_of_birth'] as String?,
        gender: j['gender'] as String?,
        photoUrl: j['photo_url'] as String?,
        bloodType: j['blood_type'] as String?,
        curriculum: j['curriculum'] as String?,
        medicalSummary: j['medical_summary'] as String?,
        profileActive: j['profile_active'] as bool? ?? true,
        allergens: (j['allergens'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(StudentAllergen.fromJson)
            .toList(),
      );
}
