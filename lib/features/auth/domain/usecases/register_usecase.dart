import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<AuthState> call({
    required String name,
    required String email,
    required String password,
    required String houseName,
  }) =>
      _repository.register(
        name: name,
        email: email,
        password: password,
        houseName: houseName,
      );
}
