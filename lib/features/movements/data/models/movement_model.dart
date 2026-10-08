// Espelha StockMovementResponseDTO do Spring (dentro de PageResponseDTO).
import '../../domain/entities/movement_entity.dart';

class MovementModel {
  final String id;
  final String type;
  final String createdAt;
  final String productName;
  final double quantity;
  final double stockBefore;
  final double stockAfter;
  final String? notes;
  final String? reference;
  final String? createdBy;

  const MovementModel({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.productName,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    this.notes,
    this.reference,
    this.createdBy,
  });

  factory MovementModel.fromJson(Map<String, dynamic> json) => MovementModel(
        id: json['id'].toString(),
        type: json['type'] as String? ?? 'ADJUSTMENT',
        createdAt: json['createdAt'] as String? ?? '',
        productName: json['productName'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        stockBefore: (json['stockBefore'] as num?)?.toDouble() ?? 0,
        stockAfter: (json['stockAfter'] as num?)?.toDouble() ?? 0,
        notes: json['notes'] as String?,
        reference: json['reference'] as String?,
        createdBy: json['createdBy'] as String?,
      );

  MovementEntity toEntity() => MovementEntity(
        id: id,
        type: _parseType(type),
        movementDate: createdAt,
        productName: productName,
        quantity: quantity,
        quantityBefore: stockBefore,
        quantityAfter: stockAfter,
        reason: notes,
        reference: reference,
        createdBy: createdBy,
      );

  static MovementType _parseType(String t) => switch (t.toUpperCase()) {
        'ENTRY' => MovementType.entry,
        'USED' => MovementType.used,
        'DISCARDED' => MovementType.discarded,
        'EXIT' => MovementType.exit,
        'RETURN' => MovementType.returnType,
        _ => MovementType.adjustment,
      };
}
