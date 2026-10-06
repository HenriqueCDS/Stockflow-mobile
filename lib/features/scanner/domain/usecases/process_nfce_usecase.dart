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
