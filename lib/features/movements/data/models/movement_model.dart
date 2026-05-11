// Espelha o DTO de movimentação retornado pelo Spring
import '../../domain/entities/movement_entity.dart';

class MovementModel {
  final String id;
  final String type;
  final String movementDate;
  final String productName;
  final String productSku;
  final int quantity;
  final int quantityBefore;
  final int quantityAfter;
  final String? reason;
  final String? reference;

  const MovementModel({
    required this.id,
    required this.type,
    required this.movementDate,
    required this.productName,
    required this.productSku,
    required this.quantity,
    required this.quantityBefore,
    required this.quantityAfter,
    this.reason,
    this.reference,
  });

  factory MovementModel.fromJson(Map<String, dynamic> json) => MovementModel(
        id: json['id'].toString(),
        type: json['type'] as String,
        movementDate: json['movementDate'] as String,
        productName: json['productName'] as String,
        productSku: json['productSku'] as String,
        quantity: json['quantity'] as int,
        quantityBefore: json['quantityBefore'] as int,
        quantityAfter: json['quantityAfter'] as int,
        reason: json['reason'] as String?,
        reference: json['reference'] as String?,
      );

  MovementEntity toEntity() => MovementEntity(
        id: id,
        type: _parseType(type),
        movementDate: movementDate,
        productName: productName,
        productSku: productSku,
        quantity: quantity,
        quantityBefore: quantityBefore,
        quantityAfter: quantityAfter,
        reason: reason,
        reference: reference,
      );

  static MovementType _parseType(String t) => switch (t.toUpperCase()) {
        'ENTRY' => MovementType.entry,
        'EXIT' => MovementType.exit,
        _ => MovementType.adjustment,
      };
}
