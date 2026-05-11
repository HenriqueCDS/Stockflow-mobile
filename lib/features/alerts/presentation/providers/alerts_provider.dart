import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
import '../../data/repositories/alerts_repository_impl.dart';

class AlertsNotifier extends AsyncNotifier<List<AlertEntity>> {
  @override
  Future<List<AlertEntity>> build() => _fetch();

  Future<List<AlertEntity>> _fetch() {
    final useCase = GetAlertsUseCase(ref.read(alertsRepositoryProvider));
    return useCase();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final alertsProvider =
    AsyncNotifierProvider<AlertsNotifier, List<AlertEntity>>(
  AlertsNotifier.new,
);
