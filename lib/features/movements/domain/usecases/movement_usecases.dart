// Migrado de: src/pages/StockEntry.jsx, StockExit.jsx, History.jsx
import '../entities/movement_entity.dart';
import '../repositories/movement_repository.dart';

class RegisterEntryUseCase {
  final MovementRepository _r;
  const RegisterEntryUseCase(this._r);

  Future<void> call({
    required String productId,
    required int quantity,
    String? reason,
    String? reference,
  }) =>
      _r.registerEntry(
        productId: productId,
        quantity: quantity,
        reason: reason,
        reference: reference,
      );
}

class RegisterExitUseCase {
  final MovementRepository _r;
  const RegisterExitUseCase(this._r);

  Future<void> call({
    required String productId,
    required int quantity,
    String? reason,
    String? reference,
  }) =>
      _r.registerExit(
        productId: productId,
        quantity: quantity,
        reason: reason,
        reference: reference,
      );
}

class GetMovementsUseCase {
  final MovementRepository _r;
  const GetMovementsUseCase(this._r);

  // Retorna últimos 30 dias quando type == null
  Future<List<MovementEntity>> call({MovementType? type}) {
    if (type != null) return _r.getByType(type);
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    return _r.getByDateRange(start, now);
  }
}
