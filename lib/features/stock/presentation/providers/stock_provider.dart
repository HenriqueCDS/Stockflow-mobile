// Migrado de: src/pages/Products.jsx
// useState(products) + useEffect(productApi.getAll()) → AsyncNotifier<List<ProductEntity>>
// handleSearch → método search() com debounce via notifier
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/di/core_providers.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../../movements/domain/usecases/movement_usecases.dart';
import '../../../movements/presentation/providers/movements_provider.dart';

final _productDsProvider = Provider(
  (ref) => ProductRemoteDataSourceImpl(ref.read(dioProvider)),
);

final productRepoProvider = Provider(
  (ref) => ProductRepositoryImpl(ref.read(_productDsProvider)),
);

// Provider principal da lista de produtos
final stockProvider = AsyncNotifierProvider<StockNotifier, List<ProductEntity>>(
  StockNotifier.new,
);

class StockNotifier extends AsyncNotifier<List<ProductEntity>> {
  String? _query;

  @override
  Future<List<ProductEntity>> build() => _load();

  Future<List<ProductEntity>> _load() {
    final uc = GetProductsUseCase(ref.read(productRepoProvider));
    return uc(name: _query);
  }

  /// Recarrega mantendo a lista atual na tela (sem estado de loading),
  /// usado após ações por item (−, +, descartar).
  Future<void> _reloadSilently() async {
    state = await AsyncValue.guard(_load);
  }

  Future<void> refresh() async {
    _query = null;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> search(String query) async {
    _query = query.trim().isEmpty ? null : query.trim();
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> deactivate(String id) async {
    final uc = DeactivateProductUseCase(ref.read(productRepoProvider));
    await uc(id);
    await _reloadSilently();
  }

  Future<void> use(String id, {double quantity = 1}) async {
    final uc = UseProductUseCase(ref.read(productRepoProvider));
    await uc(id, quantity: quantity);
    await _reloadSilently();
  }

  Future<void> discard(String id, {double quantity = 1}) async {
    final uc = DiscardProductUseCase(ref.read(productRepoProvider));
    await uc(id, quantity: quantity);
    await _reloadSilently();
  }

  /// Botão "+" da linha: entrada de 1 unidade via /stock-movements.
  Future<void> restock(String id, {int quantity = 1}) async {
    final uc = RegisterEntryUseCase(ref.read(movementRepoProvider));
    await uc(productId: id, quantity: quantity, reason: 'Ajuste rápido');
    await _reloadSilently();
  }
}

// Filtro da tela de estoque (pílulas "todos · acabando · <categoria>").
// O dashboard também escreve aqui ao tocar em um card de "Locais".
sealed class StockFilter {
  const StockFilter();
}

class StockFilterAll extends StockFilter {
  const StockFilterAll();
}

class StockFilterRunningOut extends StockFilter {
  const StockFilterRunningOut();
}

class StockFilterCategory extends StockFilter {
  final String category;
  const StockFilterCategory(this.category);
}

final stockFilterProvider =
    StateProvider<StockFilter>((_) => const StockFilterAll());

const uncategorizedLabel = 'Sem categoria';

extension ProductCategoryX on ProductEntity {
  String get categoryLabel => (category == null || category!.trim().isEmpty)
      ? uncategorizedLabel
      : category!;

  /// "Acabando" no guia de cores = sem estoque ou abaixo do mínimo.
  bool get isRunningOut => isOutOfStock || isLowStock;
}
