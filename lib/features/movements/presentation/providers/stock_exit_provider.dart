// Migrado de: src/pages/StockExit.jsx
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/movement_usecases.dart';
import 'movements_provider.dart';
import '../../../stock/domain/entities/product_entity.dart';

class StockExitState {
  final ProductEntity? selectedProduct;
  final bool saving;
  final bool success;

  const StockExitState({
    this.selectedProduct,
    this.saving = false,
    this.success = false,
  });

  StockExitState copyWith({
    ProductEntity? selectedProduct,
    bool? saving,
    bool? success,
  }) =>
      StockExitState(
        selectedProduct: selectedProduct ?? this.selectedProduct,
        saving: saving ?? this.saving,
        success: success ?? this.success,
      );
}

final stockExitProvider =
    NotifierProvider<StockExitNotifier, StockExitState>(
  StockExitNotifier.new,
);

class StockExitNotifier extends Notifier<StockExitState> {
  @override
  StockExitState build() => const StockExitState();

  void selectProduct(ProductEntity? product) =>
      state = state.copyWith(selectedProduct: product);

  Future<void> registerExit({
    required int quantity,
    String? reason,
    String? reference,
  }) async {
    if (state.selectedProduct == null) return;
    state = state.copyWith(saving: true, success: false);
    try {
      final uc = RegisterExitUseCase(ref.read(movementRepoProvider));
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

  void reset() => state = const StockExitState();
}
