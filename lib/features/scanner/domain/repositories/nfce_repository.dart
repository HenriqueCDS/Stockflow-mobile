import '../entities/nfce_result_entity.dart';

abstract interface class NfceRepository {
  Future<NfceResultEntity> processUrl(String qrCode);
  Future<NfceResultEntity> confirm(String invoiceId);
  Future<void> reject(String invoiceId);
  Future<NfceResultEntity> reviewItem(
    String invoiceId,
    String itemId, {
    String? productName,
    String? mergeIntoProductId,
    double? quantity,
    bool? ignored,
  });
}
