// Espelha o DTO do Spring: GET /api/v1/products e POST /api/v1/products
import '../../domain/entities/product_entity.dart';

class ProductModel {
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
  final String? expirationDate;

  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'].toString(),
        name: json['name'] as String,
        sku: json['sku'] as String,
        description: json['description'] as String?,
        category: json['category'] as String?,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        quantityInStock: json['quantityInStock'] as int,
        minimumStock: json['minimumStock'] as int?,
        belowMinimumStock: json['belowMinimumStock'] as bool? ?? false,
        active: json['active'] as bool? ?? true,
        expirationDate: json['expirationDate'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'sku': sku,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        'unitPrice': unitPrice,
        'quantityInStock': quantityInStock,
        if (minimumStock != null) 'minimumStock': minimumStock,
        if (expirationDate != null) 'expirationDate': expirationDate,
      };

  ProductEntity toEntity() => ProductEntity(
        id: id,
        name: name,
        sku: sku,
        description: description,
        category: category,
        unitPrice: unitPrice,
        quantityInStock: quantityInStock,
        minimumStock: minimumStock,
        belowMinimumStock: belowMinimumStock,
        active: active,
        expirationDate: expirationDate,
      );
}
