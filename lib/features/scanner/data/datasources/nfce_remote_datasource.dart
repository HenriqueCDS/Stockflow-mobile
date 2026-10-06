import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/di/core_providers.dart';
import 'package:homestock_mobile/core/network/api_interceptors.dart';
import 'package:homestock_mobile/core/network/api_response.dart';
import '../models/nfce_result_model.dart';

// POST /api/v1/nfce/process            → ApiResponseDTO<InvoiceResponseDTO> (status FETCHED)
// POST /api/v1/nfce/{invoiceId}/confirm → ApiResponseDTO<InvoiceResponseDTO> (atualiza o estoque)
// POST /api/v1/nfce/{invoiceId}/reject  → ApiResponseDTO<Void>
abstract interface class NfceRemoteDatasource {
  Future<NfceResultModel> processUrl(String qrCode);
  Future<NfceResultModel> confirm(String invoiceId);
  Future<void> reject(String invoiceId);
}

class NfceRemoteDatasourceImpl implements NfceRemoteDatasource {
  final Dio _dio;
  const NfceRemoteDatasourceImpl(this._dio);

  @override
  Future<NfceResultModel> processUrl(String qrCode) async {
    try {
      final res = await _dio.post('/nfce/process', data: {'qrCode': qrCode});
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        NfceResultModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<NfceResultModel> confirm(String invoiceId) async {
    try {
      final res = await _dio.post('/nfce/$invoiceId/confirm');
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        NfceResultModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<void> reject(String invoiceId) async {
    try {
      await _dio.post('/nfce/$invoiceId/reject');
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }
}

final nfceRemoteDatasourceProvider = Provider<NfceRemoteDatasource>((ref) {
  return NfceRemoteDatasourceImpl(ref.watch(dioProvider));
});
