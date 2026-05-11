// Migrado de: src/pages/Products.jsx (estado local do produto)
// Campo expirationDate adicionado para suporte a alertas de validade (wireframe)
class ProductEntity {
  final String id;
  final String name;
  final String sku;
  final String? description;
  final String? category;
  final double unitPrice;
  final int quantityInStock;
  final int? minimumStock;
  final bool belowMinimumStock;
  final bool active;
  final String? expirationDate; // ISO 8601 opcional

  const ProductEntity({
    required this.id,
    required this.name,
    required this.sku,
    this.description,
    this.category,
    required this.unitPrice,
    required this.quantityInStock,
    this.minimumStock,
    this.belowMinimumStock = false,
    this.active = true,
    this.expirationDate,
  });

  bool get isOutOfStock => quantityInStock == 0;
  bool get isLowStock => belowMinimumStock && quantityInStock > 0;
}
