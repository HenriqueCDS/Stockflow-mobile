import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/nfce_result_entity.dart';
import '../../domain/repositories/nfce_repository.dart';
import '../datasources/nfce_remote_datasource.dart';

class NfceRepositoryImpl implements NfceRepository {
  final NfceRemoteDatasource _ds;
  const NfceRepositoryImpl(this._ds);

  @override
  Future<NfceResultEntity> processUrl(String qrCode) => _ds.processUrl(qrCode);

  @override
  Future<NfceResultEntity> confirm(String invoiceId) => _ds.confirm(invoiceId);

  @override
  Future<void> reject(String invoiceId) => _ds.reject(invoiceId);

  @override
  Future<NfceResultEntity> reviewItem(
    String invoiceId,
    String itemId, {
    String? productName,
    String? mergeIntoProductId,
    double? quantity,
    bool? ignored,
  }) =>
      _ds.reviewItem(
        invoiceId,
        itemId,
        productName: productName,
        mergeIntoProductId: mergeIntoProductId,
        quantity: quantity,
        ignored: ignored,
      );
}

final nfceRepositoryProvider = Provider<NfceRepository>((ref) {
  return NfceRepositoryImpl(ref.watch(nfceRemoteDatasourceProvider));
});
