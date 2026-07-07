// GET /api/v1/dashboard → AsyncNotifier<DashboardEntity>
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/di/core_providers.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';

final _dashboardDsProvider = Provider(
  (ref) => DashboardRemoteDataSourceImpl(ref.read(dioProvider)),
);

final _dashboardRepoProvider = Provider(
  (ref) => DashboardRepositoryImpl(ref.read(_dashboardDsProvider)),
);

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardEntity>(
  DashboardNotifier.new,
);

class DashboardNotifier extends AsyncNotifier<DashboardEntity> {
  @override
  Future<DashboardEntity> build() => _fetch();

  Future<DashboardEntity> _fetch() {
    final useCase = GetDashboardUseCase(ref.read(_dashboardRepoProvider));
    return useCase();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
