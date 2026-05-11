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

  Future<List<MovementEntity>> getByDateRange(
      DateTime start, DateTime end);

  Future<List<MovementEntity>> getByType(MovementType type);

  Future<List<MovementEntity>> getByProduct(String productId);
}
