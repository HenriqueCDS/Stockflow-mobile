// Migrado de: sem equivalente no React (não havia auth)
// Padrão: sem estado global → AsyncNotifier<AuthState>
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/di/core_providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/join_house_usecase.dart';

final _authDsProvider = Provider(
  (ref) => AuthRemoteDataSourceImpl(ref.read(dioProvider)),
);

final _authRepoProvider = Provider(
  (ref) => AuthRepositoryImpl(
    ref.read(_authDsProvider),
    ref.read(secureStorageProvider),
  ),
);

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final repo = ref.read(_authRepoProvider);
    return repo.restoreSession();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final useCase = LoginUseCase(ref.read(_authRepoProvider));
    state = await AsyncValue.guard(() => useCase(email, password));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String houseName,
  }) async {
    state = const AsyncLoading();
    final useCase = RegisterUseCase(ref.read(_authRepoProvider));
    state = await AsyncValue.guard(() => useCase(
          name: name,
          email: email,
          password: password,
          houseName: houseName,
        ));
  }

  Future<void> join({
    required String name,
    required String email,
    required String password,
    required String inviteCode,
  }) async {
    state = const AsyncLoading();
    final useCase = JoinHouseUseCase(ref.read(_authRepoProvider));
    state = await AsyncValue.guard(() => useCase(
          name: name,
          email: email,
          password: password,
          inviteCode: inviteCode,
        ));
  }

  Future<void> logout() async {
    final useCase = LogoutUseCase(ref.read(_authRepoProvider));
    await useCase();
    state = const AsyncData(AuthState.unauthenticated());
  }
}
