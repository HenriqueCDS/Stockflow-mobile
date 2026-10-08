import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository _r;
  const GetProductsUseCase(this._r);
  Future<List<ProductEntity>> call({String? name}) => _r.getAll(name: name);
}

class GetProductByIdUseCase {
  final ProductRepository _r;
  const GetProductByIdUseCase(this._r);
  Future<ProductEntity> call(String id) => _r.getById(id);
}

class CreateProductUseCase {
  final ProductRepository _r;
  const CreateProductUseCase(this._r);
  Future<ProductEntity> call(Map<String, dynamic> data) => _r.create(data);
}

class UpdateProductUseCase {
  final ProductRepository _r;
  const UpdateProductUseCase(this._r);
  Future<ProductEntity> call(String id, Map<String, dynamic> data) =>
      _r.update(id, data);
}

class DeactivateProductUseCase {
  final ProductRepository _r;
  const DeactivateProductUseCase(this._r);
  Future<void> call(String id) => _r.deactivate(id);
}

class UseProductUseCase {
  final ProductRepository _r;
  const UseProductUseCase(this._r);
  Future<void> call(String id, {double quantity = 1}) =>
      _r.use(id, quantity: quantity);
}

class DiscardProductUseCase {
  final ProductRepository _r;
  const DiscardProductUseCase(this._r);
  Future<void> call(String id, {double quantity = 1}) =>
      _r.discard(id, quantity: quantity);
}
