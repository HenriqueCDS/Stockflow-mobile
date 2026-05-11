// Migrado de: src/pages/History.jsx
// useState(filter) + useEffect(stockApi.get*()) → AsyncNotifierProvider.family
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/di/core_providers.dart';
import '../../data/datasources/movement_remote_datasource.dart';
import '../../data/repositories/movement_repository_impl.dart';
import '../../domain/entities/movement_entity.dart';
import '../../domain/usecases/movement_usecases.dart';

final movementRepoProvider = Provider((ref) =>
    MovementRepositoryImpl(
      MovementRemoteDataSourceImpl(ref.read(dioProvider)),
    ));

// null = todos (últimos 30 dias)
final movementsProvider = AsyncNotifierProviderFamily<
    MovementsNotifier, List<MovementEntity>, MovementType?>(
  MovementsNotifier.new,
);

class MovementsNotifier
    extends FamilyAsyncNotifier<List<MovementEntity>, MovementType?> {
  @override
  Future<List<MovementEntity>> build(MovementType? arg) {
    return GetMovementsUseCase(ref.read(movementRepoProvider))(type: arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => GetMovementsUseCase(ref.read(movementRepoProvider))(type: arg),
    );
  }
}

final selectedMovementFilterProvider =
    StateProvider<MovementType?>((_) => null);
