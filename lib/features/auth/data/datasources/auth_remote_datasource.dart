// POST /api/v1/auth/login → ApiResponseDTO<LoginResponseDTO>
// POST /api/v1/auth/register → cria casa nova, ApiResponseDTO<LoginResponseDTO>
// POST /api/v1/auth/join → entra em casa existente via inviteCode, ApiResponseDTO<LoginResponseDTO>
// POST /api/v1/auth/logout → invalida o refresh token no servidor
// GET/PUT /api/v1/users/me → perfil do token; PUT só altera o nome (máx. 100)
import 'package:dio/dio.dart';
import 'package:homestock_mobile/core/network/api_interceptors.dart';
import 'package:homestock_mobile/core/network/api_response.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/join_request_model.dart';
import '../models/user_profile_model.dart';
import '../../domain/entities/user_entity.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<LoginResponseModel> register(RegisterRequestModel request);
  Future<LoginResponseModel> join(JoinRequestModel request);
  Future<void> logout();
  Future<UserEntity> getMe();
  Future<UserEntity> updateName(String name);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final res = await _dio.post('/auth/login', data: request.toJson());
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        LoginResponseModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<LoginResponseModel> register(RegisterRequestModel request) async {
    try {
      final res = await _dio.post('/auth/register', data: request.toJson());
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        LoginResponseModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<LoginResponseModel> join(JoinRequestModel request) async {
    try {
      final res = await _dio.post('/auth/join', data: request.toJson());
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        LoginResponseModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<UserEntity> getMe() async {
    try {
      final res = await _dio.get('/users/me');
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        UserProfileModel.fromJson,
      ).toEntity();
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<UserEntity> updateName(String name) async {
    try {
      final res = await _dio.put('/users/me', data: {'name': name});
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        UserProfileModel.fromJson,
      ).toEntity();
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException {
      // Best-effort: falha ao invalidar no servidor não deve impedir o logout local.
    }
  }
}
