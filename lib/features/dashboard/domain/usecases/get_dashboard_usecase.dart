import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardUseCase {
  final DashboardRepository _repository;
  const GetDashboardUseCase(this._repository);

  Future<DashboardEntity> call() => _repository.getDashboard();
}
