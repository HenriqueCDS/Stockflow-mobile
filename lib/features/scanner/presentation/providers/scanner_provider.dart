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

  void reset() => state = const ScannerState();
}

final scannerProvider = NotifierProvider<ScannerNotifier, ScannerState>(
  ScannerNotifier.new,
);
