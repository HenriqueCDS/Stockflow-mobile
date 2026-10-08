import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class JoinHouseUseCase {
  final AuthRepository _repository;
  const JoinHouseUseCase(this._repository);

  Future<AuthState> call({
    required String name,
    required String email,
    required String password,
    required String inviteCode,
  }) =>
      _repository.join(
        name: name,
        email: email,
        password: password,
        inviteCode: inviteCode,
      );
}
