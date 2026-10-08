// Espelha ProductResponseDTO (GET/PUT /api/v1/products) — API não expõe preço de
// venda, custo médio nem valor de estoque; estoque é ajustado via Stock Movements.
class ProductEntity {
  final String id;
  final String name;
  final String? ean;
  final String? category;
  final String? unit;
  final double currentStock;
  final double? minimumStock;
  final bool active;
  final bool belowMinimum;
  final DateTime? createdAt;
  final String? createdBy;

  const ProductEntity({
    required this.id,
    required this.name,
    this.ean,
    this.category,
    this.unit,
    required this.currentStock,
    this.minimumStock,
    this.active = true,
    this.belowMinimum = false,
    this.createdAt,
    this.createdBy,
  });

  bool get isOutOfStock => currentStock <= 0;
  bool get isLowStock => belowMinimum && currentStock > 0;

  // currentStock/minimumStock vêm como number (podem ter casas decimais
  // conforme a unidade), mas a UI exibe como contagem quando é inteiro.
  String get displayStock => currentStock % 1 == 0
      ? currentStock.toStringAsFixed(0)
      : currentStock.toStringAsFixed(2);
}
