// Espelha DashboardDTO do Spring (resposta vem dentro do envelope ApiResponseDTO).
import '../../domain/entities/dashboard_entity.dart';

class DashboardModel {
  final int totalProducts;
  final int activeProducts;
  final int lowStockProducts;
  final int totalInvoices;
  final int pendingInvoices;
  final double monthlySpend;
  final List<RecentMovementModel> recentMovements;

  const DashboardModel({
    required this.totalProducts,
    required this.activeProducts,
    required this.lowStockProducts,
    required this.totalInvoices,
    required this.pendingInvoices,
    required this.monthlySpend,
    required this.recentMovements,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
        activeProducts: (json['activeProducts'] as num?)?.toInt() ?? 0,
        lowStockProducts: (json['lowStockProducts'] as num?)?.toInt() ?? 0,
        totalInvoices: (json['totalInvoices'] as num?)?.toInt() ?? 0,
        pendingInvoices: (json['pendingInvoices'] as num?)?.toInt() ?? 0,
        monthlySpend: (json['monthlySpend'] as num?)?.toDouble() ?? 0,
        recentMovements: (json['recentMovements'] as List<dynamic>? ?? [])
            .map((e) => RecentMovementModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  DashboardEntity toEntity() => DashboardEntity(
        totalProducts: totalProducts,
        activeProducts: activeProducts,
        lowStockProducts: lowStockProducts,
        totalInvoices: totalInvoices,
        pendingInvoices: pendingInvoices,
        monthlySpend: monthlySpend,
        recentMovements: recentMovements.map((e) => e.toEntity()).toList(),
      );
}

class RecentMovementModel {
  final String id;
  final String productName;
  final String type;
  final double quantity;
  final String? createdAt;

  const RecentMovementModel({
    required this.id,
    required this.productName,
    required this.type,
    required this.quantity,
    this.createdAt,
  });

  factory RecentMovementModel.fromJson(Map<String, dynamic> json) =>
      RecentMovementModel(
        id: json['id'].toString(),
        productName: json['productName'] as String? ?? '',
        type: json['type'] as String? ?? 'ADJUSTMENT',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        createdAt: json['createdAt'] as String?,
      );

  MovementType get _typeEnum => switch (type) {
        'ENTRY' => MovementType.entry,
        'USED' => MovementType.used,
        'DISCARDED' => MovementType.discarded,
        'EXIT' => MovementType.exit,
        'RETURN' => MovementType.returnType,
        _ => MovementType.adjustment,
      };

  RecentMovementEntity toEntity() => RecentMovementEntity(
        id: id,
        productName: productName,
        type: _typeEnum,
        quantity: quantity,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );
}
