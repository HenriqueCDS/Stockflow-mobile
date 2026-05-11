import '../../domain/entities/movement_entity.dart';
import '../../domain/repositories/movement_repository.dart';
import '../datasources/movement_remote_datasource.dart';
import '../models/register_entry_model.dart';
import '../models/register_exit_model.dart';

class MovementRepositoryImpl implements MovementRepository {
  final MovementRemoteDataSource _ds;
  MovementRepositoryImpl(this._ds);

  @override
  Future<void> registerEntry({
    required String productId,
    required int quantity,
    String? reason,
    String? reference,
  }) =>
      _ds.registerEntry(RegisterEntryModel(
        productId: productId,
        quantity: quantity,
        reason: reason,
        reference: reference,
      ));

  @override
  Future<void> registerExit({
    required String productId,
    required int quantity,
    String? reason,
    String? reference,
  }) =>
      _ds.registerExit(RegisterExitModel(
        productId: productId,
        quantity: quantity,
        reason: reason,
        reference: reference,
      ));

  @override
  Future<List<MovementEntity>> getByDateRange(
      DateTime start, DateTime end) async {
    final models = await _ds.getByDateRange(
      start.toIso8601String(),
      end.toIso8601String(),
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<MovementEntity>> getByType(MovementType type) async {
    final typeStr = switch (type) {
      MovementType.entry => 'ENTRY',
      MovementType.exit => 'EXIT',
      MovementType.adjustment => 'ADJUSTMENT',
    };
    final models = await _ds.getByType(typeStr);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<MovementEntity>> getByProduct(String productId) async {
    final models = await _ds.getByProduct(productId);
    return models.map((m) => m.toEntity()).toList();
  }
}
