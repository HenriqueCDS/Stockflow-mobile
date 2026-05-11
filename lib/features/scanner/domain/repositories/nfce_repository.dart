import '../entities/nfce_result_entity.dart';

abstract interface class NfceRepository {
  Future<NfceResultEntity> processUrl(String url);
}
