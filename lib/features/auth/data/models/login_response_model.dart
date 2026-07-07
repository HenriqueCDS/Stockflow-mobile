// Espelha LoginResponseDTO (dados vêm sempre dentro do envelope ApiResponseDTO).
// Campos são flat: não há objeto "user" aninhado.
import 'package:homestock_mobile/features/auth/domain/entities/user_entity.dart';

class LoginResponseModel {
  final String accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final String userId;
  final String email;
  final String? name;
  final String? role;

  const LoginResponseModel({
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    required this.userId,
    required this.email,
    this.name,
    this.role,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String?,
        tokenType: json['tokenType'] as String?,
        expiresIn: json['expiresIn'] as int?,
        userId: json['userId'].toString(),
        email: json['email'] as String,
        name: json['name'] as String?,
        role: json['role'] as String?,
      );

  UserEntity toEntity() =>
      UserEntity(id: userId, email: email, name: name, role: role);
}
