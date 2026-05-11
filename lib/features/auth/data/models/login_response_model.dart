// Assumption: POST /api/v1/auth/login retorna {accessToken, refreshToken?, user: {id, email, name?}}
import 'package:homestock_mobile/features/auth/domain/entities/user_entity.dart';

class LoginResponseModel {
  final String accessToken;
  final String? refreshToken;
  final _UserModel user;

  const LoginResponseModel({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String?,
        user: _UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class _UserModel {
  final String id;
  final String email;
  final String? name;

  const _UserModel({required this.id, required this.email, this.name});

  factory _UserModel.fromJson(Map<String, dynamic> json) => _UserModel(
        id: json['id'].toString(),
        email: json['email'] as String,
        name: json['name'] as String?,
      );

  UserEntity toEntity() => UserEntity(id: id, email: email, name: name);
}
