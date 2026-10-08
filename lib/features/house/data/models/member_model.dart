// Espelha MemberResponseDTO do Spring (resposta dentro do envelope ApiResponseDTO).
import '../../domain/entities/member_entity.dart';

class MemberModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  const MemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'MEMBER',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  MemberEntity toEntity() => MemberEntity(
        id: id,
        name: name,
        email: email,
        role: role,
        createdAt: createdAt,
      );
}
