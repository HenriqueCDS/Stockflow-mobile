// Espelha ShoppingListItemResponseDTO do Spring (dentro do envelope ApiResponseDTO).
import '../../domain/entities/shopping_list_item_entity.dart';

class ShoppingListItemModel {
  final String id;
  final String? productId;
  final String name;
  final double quantity;
  final bool checked;
  final DateTime? createdAt;

  const ShoppingListItemModel({
    required this.id,
    this.productId,
    required this.name,
    required this.quantity,
    this.checked = false,
    this.createdAt,
  });

  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) =>
      ShoppingListItemModel(
        id: json['id'].toString(),
        productId: json['productId']?.toString(),
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
        checked: json['checked'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  ShoppingListItemEntity toEntity() => ShoppingListItemEntity(
        id: id,
        productId: productId,
        name: name,
        quantity: quantity,
        checked: checked,
        createdAt: createdAt,
      );
}
