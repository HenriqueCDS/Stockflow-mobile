enum AlertType { outOfStock, lowStock, nearExpiry, expired }

enum AlertSeverity { critical, warning, info }

class AlertEntity {
  final String productId;
  final String productName;
  final String productSku;
  final AlertType type;
  final AlertSeverity severity;
  final int? quantityInStock;
  final int? minimumStock;
  final String? expirationDate;

  const AlertEntity({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.type,
    required this.severity,
    this.quantityInStock,
    this.minimumStock,
    this.expirationDate,
  });

  String get title => switch (type) {
        AlertType.outOfStock => 'Sem estoque',
        AlertType.lowStock => 'Estoque baixo',
        AlertType.nearExpiry => 'Vencimento próximo',
        AlertType.expired => 'Produto vencido',
      };

  String get subtitle {
    if (type == AlertType.outOfStock) return 'Produto sem unidades disponíveis';
    if (type == AlertType.lowStock) {
      return 'Restam $quantityInStock un. (mín: $minimumStock)';
    }
    if (type == AlertType.nearExpiry || type == AlertType.expired) {
      return 'Validade: ${expirationDate ?? '-'}';
    }
    return '';
  }
}
