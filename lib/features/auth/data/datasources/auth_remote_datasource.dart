// Assumption: POST /api/v1/auth/login → {accessToken, refreshToken, user}
// Se o Spring usar /auth/token ou outro path, ajuste _kLoginPath.
import 'package:dio/dio.dart';
import 'package:homestock_mobile/core/network/api_interceptors.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  static const _kLoginPath = '/auth/login';

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final res = await _dio.post(_kLoginPath, data: request.toJson());
      return LoginResponseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }
}
