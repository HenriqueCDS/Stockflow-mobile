import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _ds;
  DashboardRepositoryImpl(this._ds);

  @override
  Future<DashboardEntity> getDashboard() async {
    final model = await _ds.getDashboard();
    return model.toEntity();
  }
}
