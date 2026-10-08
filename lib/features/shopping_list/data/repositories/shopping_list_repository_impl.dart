import '../../domain/entities/shopping_list_item_entity.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../datasources/shopping_list_remote_datasource.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final ShoppingListRemoteDataSource _ds;
  ShoppingListRepositoryImpl(this._ds);

  @override
  Future<List<ShoppingListItemEntity>> getAll() async {
    final models = await _ds.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ShoppingListItemEntity> add(String name, {double? quantity}) async {
    final model = await _ds.add(name, quantity: quantity);
    return model.toEntity();
  }

  @override
  Future<void> check(String id) => _ds.check(id);

  @override
  Future<void> remove(String id) => _ds.remove(id);
}
