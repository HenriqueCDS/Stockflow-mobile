// Migrado de: src/api/api.js → stockApi.*
// stockApi.registerEntry()           → POST /api/v1/stock/entries
// stockApi.registerExit()            → POST /api/v1/stock/exits
// stockApi.getMovementsByDateRange() → GET  /api/v1/stock/reports/movements?startDate=&endDate=
// stockApi.getMovementsByType()      → GET  /api/v1/stock/reports/movements/type/:type
// stockApi.getMovementsByProduct()   → GET  /api/v1/stock/reports/movements/product/:id
import 'package:dio/dio.dart';
import 'package:homestock_mobile/core/network/api_interceptors.dart';
import '../models/movement_model.dart';
import '../models/register_entry_model.dart';
import '../models/register_exit_model.dart';

abstract interface class MovementRemoteDataSource {
  Future<void> registerEntry(RegisterEntryModel model);
  Future<void> registerExit(RegisterExitModel model);
  Future<List<MovementModel>> getByDateRange(String start, String end);
  Future<List<MovementModel>> getByType(String type);
  Future<List<MovementModel>> getByProduct(String productId);
}

class MovementRemoteDataSourceImpl implements MovementRemoteDataSource {
  final Dio _dio;
  MovementRemoteDataSourceImpl(this._dio);

  List<MovementModel> _list(dynamic data) =>
      (data as List<dynamic>)
          .map((e) => MovementModel.fromJson(e as Map<String, dynamic>))
          .toList();

  @override
  Future<void> registerEntry(RegisterEntryModel model) async {
    try {
      await _dio.post('/stock/entries', data: model.toJson());
    } on DioException catch (e) { throw dioErrorToFailure(e); }
  }

  @override
  Future<void> registerExit(RegisterExitModel model) async {
    try {
      await _dio.post('/stock/exits', data: model.toJson());
    } on DioException catch (e) { throw dioErrorToFailure(e); }
  }

  @override
  Future<List<MovementModel>> getByDateRange(String start, String end) async {
    try {
      final res = await _dio.get('/stock/reports/movements',
          queryParameters: {'startDate': start, 'endDate': end});
      return _list(res.data);
    } on DioException catch (e) { throw dioErrorToFailure(e); }
  }

  @override
  Future<List<MovementModel>> getByType(String type) async {
    try {
      final res = await _dio.get('/stock/reports/movements/type/$type');
      return _list(res.data);
    } on DioException catch (e) { throw dioErrorToFailure(e); }
  }

  @override
  Future<List<MovementModel>> getByProduct(String productId) async {
    try {
      final res =
          await _dio.get('/stock/reports/movements/product/$productId');
      return _list(res.data);
    } on DioException catch (e) { throw dioErrorToFailure(e); }
  }
}
