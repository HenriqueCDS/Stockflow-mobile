import '../entities/shopping_list_item_entity.dart';
import '../repositories/shopping_list_repository.dart';

class GetShoppingListUseCase {
  final ShoppingListRepository _r;
  const GetShoppingListUseCase(this._r);
  Future<List<ShoppingListItemEntity>> call() => _r.getAll();
}

class AddShoppingListItemUseCase {
  final ShoppingListRepository _r;
  const AddShoppingListItemUseCase(this._r);
  Future<ShoppingListItemEntity> call(String name, {double? quantity}) =>
      _r.add(name, quantity: quantity);
}

class CheckShoppingListItemUseCase {
  final ShoppingListRepository _r;
  const CheckShoppingListItemUseCase(this._r);
  Future<void> call(String id) => _r.check(id);
}

class RemoveShoppingListItemUseCase {
  final ShoppingListRepository _r;
  const RemoveShoppingListItemUseCase(this._r);
  Future<void> call(String id) => _r.remove(id);
}
