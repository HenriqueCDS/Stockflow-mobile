import '../../domain/entities/movement_entity.dart';
import '../../domain/repositories/movement_repository.dart';
import '../datasources/movement_remote_datasource.dart';
import '../models/stock_adjustment_model.dart';

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
      _ds.adjust(StockAdjustmentModel(
        productId: productId,
        type: 'ENTRY',
        quantity: quantity,
        notes: StockAdjustmentModel.buildNotes(reason: reason, reference: reference),
      ));

  @override
  Future<void> registerExit({
    required String productId,
    required int quantity,
    String? reason,
    String? reference,
  }) =>
      _ds.adjust(StockAdjustmentModel(
        productId: productId,
        type: 'EXIT',
        quantity: quantity,
        notes: StockAdjustmentModel.buildNotes(reason: reason, reference: reference),
      ));

  @override
  Future<List<MovementEntity>> getAll() async {
    final models = await _ds.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<MovementEntity>> getByProduct(String productId) async {
    final models = await _ds.getByProduct(productId);
    return models.map((m) => m.toEntity()).toList();
  }
}
