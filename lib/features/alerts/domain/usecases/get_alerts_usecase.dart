import '../entities/alert_entity.dart';
import '../repositories/alerts_repository.dart';

class GetAlertsUseCase {
  final AlertsRepository _repo;
  const GetAlertsUseCase(this._repo);

  Future<List<AlertEntity>> call() => _repo.getAlerts();
}
