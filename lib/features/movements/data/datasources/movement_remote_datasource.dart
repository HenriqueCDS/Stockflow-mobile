// Migrado de: src/api/api.js → stockApi.*
// Registrar entrada/saída/ajuste → POST /api/v1/stock-movements/adjust
// Histórico (todas)              → GET  /api/v1/stock-movements?page=&size=
// Histórico por produto          → GET  /api/v1/stock-movements/product/{productId}
// Respostas paginadas vêm dentro do envelope ApiResponseDTO<PageResponseDTO<...>>.
import 'package:dio/dio.dart';
import 'package:homestock_mobile/core/network/api_interceptors.dart';
import 'package:homestock_mobile/core/network/api_response.dart';
import '../models/movement_model.dart';
import '../models/stock_adjustment_model.dart';

abstract interface class MovementRemoteDataSource {
  Future<void> adjust(StockAdjustmentModel model);
  Future<List<MovementModel>> getAll({int page = 0, int size = 100});
  Future<List<MovementModel>> getByProduct(String productId);
}

class MovementRemoteDataSourceImpl implements MovementRemoteDataSource {
  final Dio _dio;
  MovementRemoteDataSourceImpl(this._dio);

  List<MovementModel> _pageContent(Map<String, dynamic> json) {
    final page = unwrapApiResponse(json, (data) => data);
    final content = page['content'] as List<dynamic>? ?? [];
    return content
        .map((e) => MovementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> adjust(StockAdjustmentModel model) async {
    try {
      final res = await _dio.post(
        '/stock-movements/adjust',
        data: model.toJson(),
      );
      // Valida o envelope (success/erro); o corpo com a movimentação não é usado aqui.
      unwrapApiResponse(res.data as Map<String, dynamic>, (data) => data);
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<List<MovementModel>> getAll({int page = 0, int size = 100}) async {
    try {
      final res = await _dio.get('/stock-movements', queryParameters: {
        'page': page,
        'size': size,
      });
      return _pageContent(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<List<MovementModel>> getByProduct(String productId) async {
    try {
      final res = await _dio.get('/stock-movements/product/$productId');
      return _pageContent(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }
}
