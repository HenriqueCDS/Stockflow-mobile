// Novo – React não tinha autenticação
class UserEntity {
  final String id;
  final String email;
  final String? name;

  const UserEntity({required this.id, required this.email, this.name});
}

class AuthState {
  final UserEntity? user;
  final bool isAuthenticated;

  const AuthState({this.user, this.isAuthenticated = false});

  const AuthState.authenticated(UserEntity u)
      : user = u,
        isAuthenticated = true;

  const AuthState.unauthenticated()
      : user = null,
        isAuthenticated = false;
}
