// Espelha o DTO retornado por GET /api/v1/stock/reports/general
import '../../domain/entities/general_report_entity.dart';

class GeneralReportModel {
  final int totalProducts;
  final int activeProducts;
  final int productsWithLowStock;
  final int productsOutOfStock;
  final double totalStockValue;
  final List<LowStockProductModel> lowStockProducts;
  final List<LowStockProductModel> outOfStockProducts;

  const GeneralReportModel({
    required this.totalProducts,
    required this.activeProducts,
    required this.productsWithLowStock,
    required this.productsOutOfStock,
    required this.totalStockValue,
    required this.lowStockProducts,
    required this.outOfStockProducts,
  });

  factory GeneralReportModel.fromJson(Map<String, dynamic> json) =>
      GeneralReportModel(
        totalProducts: json['totalProducts'] as int,
        activeProducts: json['activeProducts'] as int,
        productsWithLowStock: json['productsWithLowStock'] as int,
        productsOutOfStock: json['productsOutOfStock'] as int,
        totalStockValue: (json['totalStockValue'] as num).toDouble(),
        lowStockProducts: (json['lowStockProducts'] as List<dynamic>? ?? [])
            .map((e) => LowStockProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        outOfStockProducts: (json['outOfStockProducts'] as List<dynamic>? ?? [])
            .map((e) => LowStockProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  GeneralReportEntity toEntity() => GeneralReportEntity(
        totalProducts: totalProducts,
        activeProducts: activeProducts,
        productsWithLowStock: productsWithLowStock,
        productsOutOfStock: productsOutOfStock,
        totalStockValue: totalStockValue,
        lowStockProducts: lowStockProducts.map((e) => e.toEntity()).toList(),
        outOfStockProducts:
            outOfStockProducts.map((e) => e.toEntity()).toList(),
      );
}

class LowStockProductModel {
  final String id;
  final String name;
  final int quantityInStock;
  final int? minimumStock;

  const LowStockProductModel({
    required this.id,
    required this.name,
    required this.quantityInStock,
    this.minimumStock,
  });

  factory LowStockProductModel.fromJson(Map<String, dynamic> json) =>
      LowStockProductModel(
        id: json['id'].toString(),
        name: json['name'] as String,
        quantityInStock: json['quantityInStock'] as int,
        minimumStock: json['minimumStock'] as int?,
      );

  LowStockProductEntity toEntity() => LowStockProductEntity(
        id: id,
        name: name,
        quantityInStock: quantityInStock,
        minimumStock: minimumStock,
      );
}
