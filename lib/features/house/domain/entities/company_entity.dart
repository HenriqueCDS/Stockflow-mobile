// Espelha CompanyResponseDTO (GET/PUT /api/v1/company).
// Rota do backend continua "/company" mesmo após o pivot para app doméstico
// (não foi renomeada para "house").
class CompanyEntity {
  final String id;
  final String name;
  final String tenantId;
  final String inviteCode;
  final String? email;
  final String? phone;
  final String? address;
  final bool active;
  final DateTime? createdAt;

  const CompanyEntity({
    required this.id,
    required this.name,
    required this.tenantId,
    required this.inviteCode,
    this.email,
    this.phone,
    this.address,
    this.active = true,
    this.createdAt,
  });
}
