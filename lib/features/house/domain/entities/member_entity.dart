// Espelha MemberResponseDTO (GET /api/v1/company/members).
class MemberEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  const MemberEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  bool get isOwner => role == 'OWNER';
}
