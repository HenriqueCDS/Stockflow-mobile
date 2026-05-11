import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<AuthState> login(String email, String password);
  Future<void> logout();
  Future<AuthState> restoreSession();
}
