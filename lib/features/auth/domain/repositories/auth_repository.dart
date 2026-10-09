import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<AuthState> login(String email, String password);
  Future<AuthState> register({
    required String name,
    required String email,
    required String password,
    required String houseName,
  });
  Future<AuthState> join({
    required String name,
    required String email,
    required String password,
    required String inviteCode,
  });
  Future<void> logout();
  Future<UserEntity> updateName(String name);
  Future<AuthState> restoreSession();
}
