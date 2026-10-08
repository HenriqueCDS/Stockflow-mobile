import '../entities/nfce_result_entity.dart';
import '../repositories/nfce_repository.dart';

class ProcessNfceUseCase {
  final NfceRepository _repo;
  const ProcessNfceUseCase(this._repo);

  Future<NfceResultEntity> call(String qrCode) => _repo.processUrl(qrCode);
}

// Dar entrada: confirma a nota e o backend atualiza o estoque.
class ConfirmNfceUseCase {
  final NfceRepository _repo;
  const ConfirmNfceUseCase(this._repo);

  Future<NfceResultEntity> call(String invoiceId) => _repo.confirm(invoiceId);
}

// Revisa um item antes de confirmar: renomear, religar a produto existente,
// ajustar quantidade ou ignorar. Só funciona com a invoice em status FETCHED.
class ReviewNfceItemUseCase {
  final NfceRepository _repo;
  const ReviewNfceItemUseCase(this._repo);

  Future<NfceResultEntity> call(
    String invoiceId,
    String itemId, {
    String? productName,
    String? mergeIntoProductId,
    double? quantity,
    bool? ignored,
  }) =>
      _repo.reviewItem(
        invoiceId,
        itemId,
        productName: productName,
        mergeIntoProductId: mergeIntoProductId,
        quantity: quantity,
        ignored: ignored,
      );
}
