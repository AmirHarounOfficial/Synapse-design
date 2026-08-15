import 'package:equatable/equatable.dart';

/// Authenticated user returned by `/api/auth/login` and `/api/auth/me`.
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.nameAr,
    this.schoolId,
    this.schoolName,
    this.title,
    this.avatarUrl,
    this.locale,
  });

  final int id;
  final String name;
  final String? nameAr;
  final String email;
  final String role;
  final int? schoolId;
  final String? schoolName;
  final String? title;
  final String? avatarUrl;
  final String? locale;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final school = json['school'] as Map<String, dynamic>?;
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String?,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      schoolId: json['school_id'] as int?,
      schoolName: school?['name'] as String?,
      title: json['title'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      locale: json['locale'] as String?,
    );
  }

  /// The home route for this user's role (mirrors the role landing routes).
  String get homeRoute => switch (role) {
        'nurse' => '/nurse/dashboard',
        'parent' => '/parent/app/home',
        'teacher' => '/teacher/home',
        'cafeteria' => '/cafeteria/alerts',
        'security' => '/security/pickups',
        'bus_driver' => '/bus/route',
        'counselor' => '/counselor/home',
        'secretary' => '/secretary/home',
        'principal' => '/principal/home',
        'physician' => '/physician/dashboard',
        'vice_principal' => '/vice-principal/home',
        _ => '/',
      };

  @override
  List<Object?> get props => [id, email, role, schoolId];
}
