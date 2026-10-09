// Espelha o perfil de GET/PUT /api/v1/users/me: {id, name, email, role}.
import 'package:homestock_mobile/features/auth/domain/entities/user_entity.dart';

class UserProfileModel {
  final String id;
  final String? name;
  final String email;
  final String? role;

  const UserProfileModel({
    required this.id,
    this.name,
    required this.email,
    this.role,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        id: json['id'].toString(),
        name: json['name'] as String?,
        email: json['email'] as String,
        role: json['role'] as String?,
      );

  UserEntity toEntity() =>
      UserEntity(id: id, email: email, name: name, role: role);
}
