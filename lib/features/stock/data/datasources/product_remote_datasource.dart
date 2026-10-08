// GET    /api/v1/products        → paginado (ApiResponseDTO<PageResponseDTO<ProductResponseDTO>>)
//        Filtros: page, size, sort, name, ean, category, active, belowMinimum
//        Não existe mais /products/search — busca por nome é feita via query param.
// GET    /api/v1/products/{id}   → ApiResponseDTO<ProductResponseDTO>
// POST   /api/v1/products        → ApiResponseDTO<ProductResponseDTO>
// PUT    /api/v1/products/{id}   → ApiResponseDTO<ProductResponseDTO>
// DELETE /api/v1/products/{id}   → soft delete
// POST   /api/v1/products/{id}/use?quantity=1     → ApiResponseDTO<StockMovementResponseDTO>
// POST   /api/v1/products/{id}/discard?quantity=1 → ApiResponseDTO<StockMovementResponseDTO>
import 'package:dio/dio.dart';
import 'package:homestock_mobile/core/network/api_interceptors.dart';
import 'package:homestock_mobile/core/network/api_response.dart';
import '../models/product_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<List<ProductModel>> getAll({String? name});
  Future<ProductModel> getById(String id);
  Future<ProductModel> create(Map<String, dynamic> data);
  Future<ProductModel> update(String id, Map<String, dynamic> data);
  Future<void> deactivate(String id);
  Future<void> use(String id, {double quantity = 1});
  Future<void> discard(String id, {double quantity = 1});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio _dio;
  ProductRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ProductModel>> getAll({String? name}) async {
    try {
      final res = await _dio.get('/products', queryParameters: {
        'size': 200,
        'sort': 'name',
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      });
      final page = unwrapApiResponse(
        res.data as Map<String, dynamic>,
        (data) => data,
      );
      final content = page['content'] as List<dynamic>? ?? [];
      return content
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<ProductModel> getById(String id) async {
    try {
      final res = await _dio.get('/products/$id');
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        ProductModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<ProductModel> create(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/products', data: data);
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        ProductModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<ProductModel> update(String id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('/products/$id', data: data);
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        ProductModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<void> deactivate(String id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<void> use(String id, {double quantity = 1}) async {
    try {
      await _dio.post('/products/$id/use',
          queryParameters: {'quantity': quantity});
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<void> discard(String id, {double quantity = 1}) async {
    try {
      await _dio.post('/products/$id/discard',
          queryParameters: {'quantity': quantity});
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }
}
