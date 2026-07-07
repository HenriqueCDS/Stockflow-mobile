// Espelha ProductResponseDTO / ProductRequestDTO do Spring.
// Resposta vem dentro do envelope ApiResponseDTO (ver core/network/api_response.dart).
import '../../domain/entities/product_entity.dart';

class ProductModel {
  final String id;
  final String name;
  final String? ean;
  final String? category;
  final String? unit;
  final double currentStock;
  final double? averageCost;
  final double? minimumStock;
  final double totalValue;
  final bool active;
  final bool belowMinimum;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    this.ean,
    this.category,
    this.unit,
    required this.currentStock,
    this.averageCost,
    this.minimumStock,
    this.totalValue = 0,
    this.active = true,
    this.belowMinimum = false,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'].toString(),
        name: json['name'] as String,
        ean: json['ean'] as String?,
        category: json['category'] as String?,
        unit: json['unit'] as String?,
        currentStock: (json['currentStock'] as num?)?.toDouble() ?? 0,
        averageCost: (json['averageCost'] as num?)?.toDouble(),
        minimumStock: (json['minimumStock'] as num?)?.toDouble(),
        totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0,
        active: json['active'] as bool? ?? true,
        belowMinimum: json['belowMinimum'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  // Espelha ProductRequestDTO: {name, ean, category, unit, minimumStock}.
  // Estoque/custo não são enviáveis aqui — só via Stock Movements.
  Map<String, dynamic> toJson() => {
        'name': name,
        if (ean != null && ean!.isNotEmpty) 'ean': ean,
        if (category != null && category!.isNotEmpty) 'category': category,
        if (unit != null && unit!.isNotEmpty) 'unit': unit,
        if (minimumStock != null) 'minimumStock': minimumStock,
      };

  ProductEntity toEntity() => ProductEntity(
        id: id,
        name: name,
        ean: ean,
        category: category,
        unit: unit,
        currentStock: currentStock,
        averageCost: averageCost,
        minimumStock: minimumStock,
        totalValue: totalValue,
        active: active,
        belowMinimum: belowMinimum,
        createdAt: createdAt,
      );
}
