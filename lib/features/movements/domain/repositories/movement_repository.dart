import '../entities/movement_entity.dart';

abstract interface class MovementRepository {
  Future<void> registerEntry({
    required String productId,
    required int quantity,
    String? reason,
    String? reference,
  });

  Future<void> registerExit({
    required String productId,
    required int quantity,
    String? reason,
    String? reference,
  });

  // A API não filtra por data nem por tipo: retorna o histórico e os filtros
  // são aplicados no app (ver GetMovementsUseCase).
  Future<List<MovementEntity>> getAll();

  Future<List<MovementEntity>> getByProduct(String productId);
}
