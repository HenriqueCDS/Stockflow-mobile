// GET    /api/v1/shopping-list         → ApiResponseDTO<List<ShoppingListItemResponseDTO>>
// POST   /api/v1/shopping-list         → ApiResponseDTO<ShoppingListItemResponseDTO> (item manual)
// POST   /api/v1/shopping-list/{id}/check → 204 (marca como comprado)
// DELETE /api/v1/shopping-list/{id}    → 204
import 'package:dio/dio.dart';
import 'package:homestock_mobile/core/network/api_interceptors.dart';
import 'package:homestock_mobile/core/network/api_response.dart';
import '../models/shopping_list_item_model.dart';

abstract interface class ShoppingListRemoteDataSource {
  Future<List<ShoppingListItemModel>> getAll();
  Future<ShoppingListItemModel> add(String name, {double? quantity});
  Future<void> check(String id);
  Future<void> remove(String id);
}

class ShoppingListRemoteDataSourceImpl implements ShoppingListRemoteDataSource {
  final Dio _dio;
  ShoppingListRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ShoppingListItemModel>> getAll() async {
    try {
      final res = await _dio.get('/shopping-list');
      final json = res.data as Map<String, dynamic>;
      final list = json['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ShoppingListItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<ShoppingListItemModel> add(String name, {double? quantity}) async {
    try {
      final res = await _dio.post('/shopping-list', data: {
        'name': name,
        if (quantity != null) 'quantity': quantity,
      });
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        ShoppingListItemModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<void> check(String id) async {
    try {
      await _dio.post('/shopping-list/$id/check');
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<void> remove(String id) async {
    try {
      await _dio.delete('/shopping-list/$id');
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }
}
