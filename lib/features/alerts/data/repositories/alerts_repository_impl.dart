// Alerts are derived client-side from stock data — no dedicated backend endpoint needed.
// If a dedicated GET /alerts endpoint is added later, swap _buildFromProducts() for an API call.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/features/stock/domain/entities/product_entity.dart';
import 'package:homestock_mobile/features/stock/presentation/providers/stock_provider.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alerts_repository.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  final Ref _ref;
  const AlertsRepositoryImpl(this._ref);

  @override
  Future<List<AlertEntity>> getAlerts() async {
    final stockAsync = _ref.read(stockProvider);
    final products = stockAsync.value ?? [];
    return _buildFromProducts(products);
  }

  List<AlertEntity> _buildFromProducts(List<ProductEntity> products) {
    // API não expõe data de validade no produto — só estoque atual/mínimo,
    // então só dá para derivar alertas de falta/baixo estoque por aqui.
    final alerts = <AlertEntity>[];

    for (final p in products) {
      if (p.isOutOfStock) {
        alerts.add(AlertEntity(
          productId: p.id,
          productName: p.name,
          productSku: p.ean ?? '',
          type: AlertType.outOfStock,
          severity: AlertSeverity.critical,
          quantityInStock: p.currentStock.round(),
          minimumStock: p.minimumStock?.round(),
        ));
        continue;
      }

      if (p.isLowStock) {
        alerts.add(AlertEntity(
          productId: p.id,
          productName: p.name,
          productSku: p.ean ?? '',
          type: AlertType.lowStock,
          severity: AlertSeverity.warning,
          quantityInStock: p.currentStock.round(),
          minimumStock: p.minimumStock?.round(),
        ));
      }
    }

    // Sort: critical first
    alerts.sort((a, b) => a.severity.index.compareTo(b.severity.index));
    return alerts;
  }
}

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepositoryImpl(ref);
});
