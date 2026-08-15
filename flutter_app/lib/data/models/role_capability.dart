/// A single capability flag for a role in the permissions matrix.
class RoleCapability {
  const RoleCapability({required this.capability, required this.allowed});

  final String capability;
  final bool allowed;

  factory RoleCapability.fromJson(Map<String, dynamic> j) => RoleCapability(
        capability: j['capability'] as String? ?? '',
        allowed: j['allowed'] as bool? ?? false,
      );
}
