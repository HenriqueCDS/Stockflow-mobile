import '../entities/product_entity.dart';

abstract interface class ProductRepository {
  Future<List<ProductEntity>> getAll({String? name});
  Future<ProductEntity> getById(String id);
  Future<ProductEntity> create(Map<String, dynamic> data);
  Future<ProductEntity> update(String id, Map<String, dynamic> data);
  Future<void> deactivate(String id);
  Future<void> use(String id, {double quantity = 1});
  Future<void> discard(String id, {double quantity = 1});
}
