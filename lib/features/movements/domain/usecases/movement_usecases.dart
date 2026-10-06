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

  // Sem tipo: últimos 30 dias. Com tipo: todo o histórico daquele tipo.
  // Filtros feitos no app porque GET /stock-movements não aceita data nem tipo.
  Future<List<MovementEntity>> call({MovementType? type}) async {
    final all = await _r.getAll();
    if (type != null) {
      return all.where((m) => m.type == type).toList();
    }
    final limit = DateTime.now().subtract(const Duration(days: 30));
    return all.where((m) {
      final date = DateTime.tryParse(m.movementDate);
      return date == null || date.isAfter(limit);
    }).toList();
  }
}
