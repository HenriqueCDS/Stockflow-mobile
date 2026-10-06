import '../entities/nfce_result_entity.dart';

abstract interface class NfceRepository {
  Future<NfceResultEntity> processUrl(String qrCode);
  Future<NfceResultEntity> confirm(String invoiceId);
  Future<void> reject(String invoiceId);
}
