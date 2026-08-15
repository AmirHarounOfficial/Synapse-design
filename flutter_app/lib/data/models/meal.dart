/// Cafeteria meal, matching `MealResource` from the API.
class Meal {
  const Meal({
    required this.id,
    required this.schoolId,
    required this.name,
    this.nameAr,
    this.date,
    this.isHalal = false,
    this.halalCertified = false,
    this.allergens = const [],
  });

  final int id;
  final int schoolId;
  final String name;
  final String? nameAr;
  final String? date; // yyyy-MM-dd
  final bool isHalal;
  final bool halalCertified;
  final List<String> allergens;

  factory Meal.fromJson(Map<String, dynamic> j) => Meal(
        id: (j['id'] as num).toInt(),
        schoolId: (j['school_id'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? '',
        nameAr: j['name_ar'] as String?,
        date: j['date'] as String?,
        isHalal: j['is_halal'] as bool? ?? false,
        halalCertified: j['halal_certified'] as bool? ?? false,
        allergens: (j['allergens'] as List? ?? const []).map((e) => e.toString()).toList(),
      );
}
