// Migrado de: src/pages/StockEntry.jsx
// useState(selected, quantity, reason, saving) → Notifier<StockEntryState>
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/movement_usecases.dart';
import 'movements_provider.dart';
import '../../../stock/domain/entities/product_entity.dart';

class StockEntryState {
  final ProductEntity? selectedProduct;
  final bool saving;
  final bool success;

  const StockEntryState({
    this.selectedProduct,
    this.saving = false,
    this.success = false,
  });

  StockEntryState copyWith({
    ProductEntity? selectedProduct,
    bool? saving,
    bool? success,
  }) =>
      StockEntryState(
        selectedProduct: selectedProduct ?? this.selectedProduct,
        saving: saving ?? this.saving,
        success: success ?? this.success,
      );
}

final stockEntryProvider =
    NotifierProvider<StockEntryNotifier, StockEntryState>(
  StockEntryNotifier.new,
);

class StockEntryNotifier extends Notifier<StockEntryState> {
  @override
  StockEntryState build() => const StockEntryState();

  void selectProduct(ProductEntity? product) =>
      state = state.copyWith(selectedProduct: product);

  Future<void> registerEntry({
    required int quantity,
    String? reason,
    String? reference,
  }) async {
    if (state.selectedProduct == null) return;
    state = state.copyWith(saving: true, success: false);
    try {
      final uc = RegisterEntryUseCase(ref.read(movementRepoProvider));
      await uc(
        productId: state.selectedProduct!.id,
        quantity: quantity,
        reason: reason,
        reference: reference,
      );
      state = state.copyWith(saving: false, success: true);
    } catch (_) {
      state = state.copyWith(saving: false);
      rethrow;
    }
  }

  void reset() => state = const StockEntryState();
}
