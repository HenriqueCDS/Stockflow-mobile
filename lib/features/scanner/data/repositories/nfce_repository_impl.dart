import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/nfce_result_entity.dart';
import '../../domain/repositories/nfce_repository.dart';
import '../datasources/nfce_remote_datasource.dart';

class NfceRepositoryImpl implements NfceRepository {
  final NfceRemoteDatasource _ds;
  const NfceRepositoryImpl(this._ds);

  @override
  Future<NfceResultEntity> processUrl(String url) => _ds.processUrl(url);
}

final nfceRepositoryProvider = Provider<NfceRepository>((ref) {
  return NfceRepositoryImpl(ref.watch(nfceRemoteDatasourceProvider));
});
