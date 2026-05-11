// Migrado de: src/pages/History.jsx (estado local movements)
enum MovementType { entry, exit, adjustment }

class MovementEntity {
  final String id;
  final MovementType type;
  final String movementDate;
  final String productName;
  final String productSku;
  final int quantity;
  final int quantityBefore;
  final int quantityAfter;
  final String? reason;
  final String? reference;

  const MovementEntity({
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
}
