import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/di/core_providers.dart';
import '../models/nfce_result_model.dart';

abstract interface class NfceRemoteDatasource {
  Future<NfceResultModel> processUrl(String url);
}

class NfceRemoteDatasourceImpl implements NfceRemoteDatasource {
  final Dio _dio;
  const NfceRemoteDatasourceImpl(this._dio);

  // ⚠ Adjust path to match Spring endpoint for NFC-e processing
  @override
  Future<NfceResultModel> processUrl(String url) async {
    final response = await _dio.post(
      '/nfce/process',
      data: {'url': url},
    );
    return NfceResultModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final nfceRemoteDatasourceProvider = Provider<NfceRemoteDatasource>((ref) {
  return NfceRemoteDatasourceImpl(ref.watch(dioProvider));
});
