import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/nfce_result_entity.dart';
import '../../domain/usecases/process_nfce_usecase.dart';
import '../../data/repositories/nfce_repository_impl.dart';

enum ScanStatus { idle, scanning, processing, success, error }

class ScannerState {
  final ScanStatus status;
  final NfceResultEntity? result;
  final String? errorMessage;

  const ScannerState({
    this.status = ScanStatus.idle,
    this.result,
    this.errorMessage,
  });

  ScannerState copyWith({
    ScanStatus? status,
    NfceResultEntity? result,
    String? errorMessage,
  }) {
    return ScannerState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ScannerNotifier extends Notifier<ScannerState> {
  @override
  ScannerState build() => const ScannerState();

  Future<void> processQrCode(String url) async {
    if (state.status == ScanStatus.processing) return;
    state = state.copyWith(status: ScanStatus.processing, errorMessage: null);

    try {
      final useCase = ProcessNfceUseCase(ref.read(nfceRepositoryProvider));
      final result = await useCase(url);
      state = state.copyWith(status: ScanStatus.success, result: result);
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Confirma a nota lida (atualiza o estoque no backend).
  Future<void> confirmResult() async {
    final invoiceId = state.result?.id;
    if (invoiceId == null) return;
    final useCase = ConfirmNfceUseCase(ref.read(nfceRepositoryProvider));
    await useCase(invoiceId);
  }

  // Revisa um item da nota antes de confirmar; atualiza o resultado com a
  // invoice devolvida pelo backend (já com o item ajustado).
  Future<void> reviewItem(
    String itemId, {
    String? productName,
    String? mergeIntoProductId,
    double? quantity,
    bool? ignored,
  }) async {
    final invoiceId = state.result?.id;
    if (invoiceId == null) return;
    final useCase = ReviewNfceItemUseCase(ref.read(nfceRepositoryProvider));
    final updated = await useCase(
      invoiceId,
      itemId,
      productName: productName,
      mergeIntoProductId: mergeIntoProductId,
      quantity: quantity,
      ignored: ignored,
    );
    state = state.copyWith(result: updated);
  }

  void reset() => state = const ScannerState();
}

final scannerProvider = NotifierProvider<ScannerNotifier, ScannerState>(
  ScannerNotifier.new,
);
