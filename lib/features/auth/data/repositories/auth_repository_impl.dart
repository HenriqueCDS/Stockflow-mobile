import 'package:homestock_mobile/core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/join_request_model.dart';
import '../models/login_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _ds;
  final SecureStorageService _storage;

  AuthRepositoryImpl(this._ds, this._storage);

  Future<AuthState> _persist(LoginResponseModel res) async {
    await _storage.saveTokens(
      access: res.accessToken,
      refresh: res.refreshToken,
    );
    return AuthState.authenticated(res.toEntity());
  }

  @override
  Future<AuthState> login(String email, String password) async {
    final res = await _ds.login(LoginRequestModel(email: email, password: password));
    return _persist(res);
  }

  @override
  Future<AuthState> register({
    required String name,
    required String email,
    required String password,
    required String houseName,
  }) async {
    final res = await _ds.register(RegisterRequestModel(
      name: name,
      email: email,
      password: password,
      houseName: houseName,
    ));
    return _persist(res);
  }

  @override
  Future<AuthState> join({
    required String name,
    required String email,
    required String password,
    required String inviteCode,
  }) async {
    final res = await _ds.join(JoinRequestModel(
      name: name,
      email: email,
      password: password,
      inviteCode: inviteCode,
    ));
    return _persist(res);
  }

  @override
  Future<void> logout() async {
    await _ds.logout();
    await _storage.clearAll();
  }

  @override
  Future<AuthState> restoreSession() async {
    final token = await _storage.getAccessToken();
    if (token == null) return const AuthState.unauthenticated();
    // TODO: decodificar o JWT para restaurar userId/email/role e validar expiração.
    // A API não expõe endpoint de perfil (/auth/me); por ora, presença do token = sessão ativa.
    return const AuthState.authenticated(
      UserEntity(id: '', email: ''),
    );
  }
}
