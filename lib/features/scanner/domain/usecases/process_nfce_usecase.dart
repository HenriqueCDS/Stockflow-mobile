import '../entities/nfce_result_entity.dart';
import '../repositories/nfce_repository.dart';

class ProcessNfceUseCase {
  final NfceRepository _repo;
  const ProcessNfceUseCase(this._repo);

  Future<NfceResultEntity> call(String url) => _repo.processUrl(url);
}
