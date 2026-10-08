// useState(items) + useEffect(get) → AsyncNotifier<List<ShoppingListItemEntity>>
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/di/core_providers.dart';
import '../../data/datasources/shopping_list_remote_datasource.dart';
import '../../data/repositories/shopping_list_repository_impl.dart';
import '../../domain/entities/shopping_list_item_entity.dart';
import '../../domain/usecases/shopping_list_usecases.dart';

final shoppingListRepoProvider = Provider(
  (ref) => ShoppingListRepositoryImpl(
    ShoppingListRemoteDataSourceImpl(ref.read(dioProvider)),
  ),
);

final shoppingListProvider =
    AsyncNotifierProvider<ShoppingListNotifier, List<ShoppingListItemEntity>>(
  ShoppingListNotifier.new,
);

class ShoppingListNotifier
    extends AsyncNotifier<List<ShoppingListItemEntity>> {
  @override
  Future<List<ShoppingListItemEntity>> build() => _loadAll();

  Future<List<ShoppingListItemEntity>> _loadAll() {
    final uc = GetShoppingListUseCase(ref.read(shoppingListRepoProvider));
    return uc();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadAll);
  }

  Future<void> addItem(String name, {double? quantity}) async {
    final uc = AddShoppingListItemUseCase(ref.read(shoppingListRepoProvider));
    await uc(name, quantity: quantity);
    await refresh();
  }

  Future<void> checkItem(String id) async {
    final uc = CheckShoppingListItemUseCase(ref.read(shoppingListRepoProvider));
    await uc(id);
    await refresh();
  }

  Future<void> removeItem(String id) async {
    final uc = RemoveShoppingListItemUseCase(ref.read(shoppingListRepoProvider));
    await uc(id);
    await refresh();
  }
}
