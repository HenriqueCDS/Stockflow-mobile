import '../entities/shopping_list_item_entity.dart';

abstract interface class ShoppingListRepository {
  Future<List<ShoppingListItemEntity>> getAll();
  Future<ShoppingListItemEntity> add(String name, {double? quantity});
  Future<void> check(String id);
  Future<void> remove(String id);
}
