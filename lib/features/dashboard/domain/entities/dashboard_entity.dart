// Espelha DashboardDTO (GET /api/v1/dashboard).
// lowStockProducts aqui é uma CONTAGEM (não uma lista) — a API não devolve
// listas de produtos em baixa/sem estoque, nem data de validade. As prévias
// exibidas na home vêm de stockProvider (mesma fonte usada em Alerts).
class DashboardEntity {
  final int totalProducts;
  final int activeProducts;
  final int lowStockProducts;
  final int totalInvoices;
  final int pendingInvoices;
  final double monthlySpend;
  final List<RecentMovementEntity> recentMovements;

  const DashboardEntity({
    required this.totalProducts,
    required this.activeProducts,
    required this.lowStockProducts,
    required this.totalInvoices,
    required this.pendingInvoices,
    required this.monthlySpend,
    required this.recentMovements,
  });
}

enum MovementType { entry, used, discarded, exit, adjustment, returnType }

class RecentMovementEntity {
  final String id;
  final String productName;
  final MovementType type;
  final double quantity;
  final DateTime? createdAt;

  const RecentMovementEntity({
    required this.id,
    required this.productName,
    required this.type,
    required this.quantity,
    this.createdAt,
  });
}
