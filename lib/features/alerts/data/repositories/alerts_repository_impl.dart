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
    final alerts = <AlertEntity>[];
    final today = DateTime.now();

    for (final p in products) {
      // Out-of-stock (critical)
      if (p.quantityInStock == 0) {
        alerts.add(AlertEntity(
          productId: p.id,
          productName: p.name,
          productSku: p.sku,
          type: AlertType.outOfStock,
          severity: AlertSeverity.critical,
          quantityInStock: p.quantityInStock,
          minimumStock: p.minimumStock,
        ));
        continue;
      }

      // Low stock (warning)
      if (p.isLowStock) {
        alerts.add(AlertEntity(
          productId: p.id,
          productName: p.name,
          productSku: p.sku,
          type: AlertType.lowStock,
          severity: AlertSeverity.warning,
          quantityInStock: p.quantityInStock,
          minimumStock: p.minimumStock,
        ));
      }

      // Expiry alerts
      if (p.expirationDate != null && p.expirationDate!.isNotEmpty) {
        final expiry = DateTime.tryParse(p.expirationDate!);
        if (expiry != null) {
          final diff = expiry.difference(today).inDays;
          if (diff < 0) {
            alerts.add(AlertEntity(
              productId: p.id,
              productName: p.name,
              productSku: p.sku,
              type: AlertType.expired,
              severity: AlertSeverity.critical,
              expirationDate: p.expirationDate,
            ));
          } else if (diff <= 30) {
            alerts.add(AlertEntity(
              productId: p.id,
              productName: p.name,
              productSku: p.sku,
              type: AlertType.nearExpiry,
              severity: diff <= 7 ? AlertSeverity.critical : AlertSeverity.warning,
              expirationDate: p.expirationDate,
            ));
          }
        }
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
