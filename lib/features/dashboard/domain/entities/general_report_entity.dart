// Migrado de: src/pages/Dashboard.jsx + src/pages/Reports.jsx
// Ambas as pages usavam reportApi.getGeneralReport() — unificadas em uma entity
class GeneralReportEntity {
  final int totalProducts;
  final int activeProducts;
  final int productsWithLowStock;
  final int productsOutOfStock;
  final double totalStockValue;
  final List<LowStockProductEntity> lowStockProducts;
  final List<LowStockProductEntity> outOfStockProducts;

  const GeneralReportEntity({
    required this.totalProducts,
    required this.activeProducts,
    required this.productsWithLowStock,
    required this.productsOutOfStock,
    required this.totalStockValue,
    required this.lowStockProducts,
    required this.outOfStockProducts,
  });
}

class LowStockProductEntity {
  final String id;
  final String name;
  final int quantityInStock;
  final int? minimumStock;

  const LowStockProductEntity({
    required this.id,
    required this.name,
    required this.quantityInStock,
    this.minimumStock,
  });
}
