// Espelha CompanyResponseDTO do Spring (resposta dentro do envelope ApiResponseDTO).
import '../../domain/entities/company_entity.dart';

class CompanyModel {
  final String id;
  final String name;
  final String tenantId;
  final String inviteCode;
  final String? email;
  final String? phone;
  final String? address;
  final bool active;
  final DateTime? createdAt;

  const CompanyModel({
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

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        tenantId: json['tenantId']?.toString() ?? '',
        inviteCode: json['inviteCode'] as String? ?? '',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        active: json['active'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  // Espelha o body do PUT /company: {name, email?, phone?, address?} (sem cnpj).
  Map<String, dynamic> toJson() => {
        'name': name,
        if (email != null && email!.isNotEmpty) 'email': email,
        if (phone != null && phone!.isNotEmpty) 'phone': phone,
        if (address != null && address!.isNotEmpty) 'address': address,
      };

  CompanyEntity toEntity() => CompanyEntity(
        id: id,
        name: name,
        tenantId: tenantId,
        inviteCode: inviteCode,
        email: email,
        phone: phone,
        address: address,
        active: active,
        createdAt: createdAt,
      );
}
