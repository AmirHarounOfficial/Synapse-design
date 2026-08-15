/// A staff member, matching `StaffResource` from the API.
class Staff {
  const Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.title,
    this.isActive = true,
    this.avatarUrl,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? title;
  final bool isActive;
  final String? avatarUrl;

  factory Staff.fromJson(Map<String, dynamic> j) => Staff(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
        email: j['email'] as String? ?? '',
        role: j['role'] as String? ?? '',
        phone: j['phone'] as String?,
        title: j['title'] as String?,
        isActive: j['is_active'] as bool? ?? true,
        avatarUrl: j['avatar_url'] as String?,
      );
}
