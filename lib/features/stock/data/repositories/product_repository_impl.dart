import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _ds;
  ProductRepositoryImpl(this._ds);

  @override
  Future<List<ProductEntity>> getAll({String? name}) async {
    final models = await _ds.getAll(name: name);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ProductEntity> getById(String id) async {
    final model = await _ds.getById(id);
    return model.toEntity();
  }

  @override
  Future<ProductEntity> create(Map<String, dynamic> data) async {
    final model = await _ds.create(data);
    return model.toEntity();
  }

  @override
  Future<ProductEntity> update(String id, Map<String, dynamic> data) async {
    final model = await _ds.update(id, data);
    return model.toEntity();
  }

  @override
  Future<void> deactivate(String id) => _ds.deactivate(id);
}
