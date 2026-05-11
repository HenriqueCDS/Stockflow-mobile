import 'package:homestock_mobile/core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _ds;
  final SecureStorageService _storage;

  AuthRepositoryImpl(this._ds, this._storage);

  @override
  Future<AuthState> login(String email, String password) async {
    final res = await _ds.login(LoginRequestModel(email: email, password: password));
    await _storage.saveTokens(
      access: res.accessToken,
      refresh: res.refreshToken,
    );
    return AuthState.authenticated(res.user.toEntity());
  }

  @override
  Future<void> logout() => _storage.clearAll();

  @override
  Future<AuthState> restoreSession() async {
    final token = await _storage.getAccessToken();
    if (token == null) return const AuthState.unauthenticated();
    // TODO: decodificar JWT ou chamar GET /auth/me para validar expiração
    // Por ora, presença do token = sessão ativa
    return const AuthState.authenticated(
      UserEntity(id: '', email: ''),
    );
  }
}
