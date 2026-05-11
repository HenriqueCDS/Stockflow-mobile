// Migrado de: src/api/api.js → productApi.*
// productApi.getAll()    → GET  /api/v1/products
// productApi.getById()   → GET  /api/v1/products/:id
// productApi.search()    → GET  /api/v1/products/search?name=
// productApi.create()    → POST /api/v1/products
// productApi.update()    → PUT  /api/v1/products/:id
// productApi.deactivate()→ DELETE /api/v1/products/:id
import 'package:dio/dio.dart';
import 'package:homestock_mobile/core/network/api_interceptors.dart';
import '../models/product_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<List<ProductModel>> getAll();
  Future<ProductModel> getById(String id);
  Future<List<ProductModel>> search(String name);
  Future<ProductModel> create(Map<String, dynamic> data);
  Future<ProductModel> update(String id, Map<String, dynamic> data);
  Future<void> deactivate(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio _dio;
  ProductRemoteDataSourceImpl(this._dio);

  List<ProductModel> _parseList(dynamic data) =>
      (data as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

  @override
  Future<List<ProductModel>> getAll() async {
    try {
      final res = await _dio.get('/products');
      return _parseList(res.data);
    } on DioException catch (e) { throw dioErrorToFailure(e); }
  }

  @override
  Future<ProductModel> getById(String id) async {
    try {
      final res = await _dio.get('/products/$id');
      return ProductModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) { throw dioErrorToFailure(e); }
  }

  @override
  Future<List<ProductModel>> search(String name) async {
    try {
      final res = await _dio.get('/products/search', queryParameters: {'name': name});
      return _parseList(res.data);
    } on DioException catch (e) { throw dioErrorToFailure(e); }
  }

  @override
  Future<ProductModel> create(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('/products', data: data);
      return ProductModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) { throw dioErrorToFailure(e); }
  }

  @override
  Future<ProductModel> update(String id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('/products/$id', data: data);
      return ProductModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) { throw dioErrorToFailure(e); }
  }

  @override
  Future<void> deactivate(String id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) { throw dioErrorToFailure(e); }
  }
}
