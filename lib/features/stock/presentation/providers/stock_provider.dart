// Migrado de: src/pages/Products.jsx
// useState(products) + useEffect(productApi.getAll()) → AsyncNotifier<List<ProductEntity>>
// handleSearch → método search() com debounce via notifier
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/di/core_providers.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';

final _productDsProvider = Provider(
  (ref) => ProductRemoteDataSourceImpl(ref.read(dioProvider)),
);

final productRepoProvider = Provider(
  (ref) => ProductRepositoryImpl(ref.read(_productDsProvider)),
);

// Provider principal da lista de produtos
final stockProvider =
    AsyncNotifierProvider<StockNotifier, List<ProductEntity>>(
  StockNotifier.new,
);

class StockNotifier extends AsyncNotifier<List<ProductEntity>> {
  @override
  Future<List<ProductEntity>> build() => _loadAll();

  Future<List<ProductEntity>> _loadAll() {
    final uc = GetProductsUseCase(ref.read(productRepoProvider));
    return uc();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadAll);
  }

  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final uc = GetProductsUseCase(ref.read(productRepoProvider));
      return uc(name: query.trim().isEmpty ? null : query.trim());
    });
  }

  Future<void> deactivate(String id) async {
    final uc = DeactivateProductUseCase(ref.read(productRepoProvider));
    await uc(id);
    await refresh();
  }
}

// View ativa da tela de estoque (lista densa / categoria / urgência)
enum StockView { list, category, urgency }

final stockViewProvider = StateProvider<StockView>((_) => StockView.list);
