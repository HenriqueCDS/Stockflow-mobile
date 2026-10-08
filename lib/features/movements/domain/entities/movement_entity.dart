// Migrado de: src/pages/History.jsx (estado local movements)
// Espelha StockMovementResponseDTO. Quantidades são number na API (podem ter decimais).
enum MovementType { entry, used, discarded, exit, adjustment, returnType }

class MovementEntity {
  final String id;
  final MovementType type;
  final String movementDate;
  final String productName;
  final double quantity;
  final double quantityBefore;
  final double quantityAfter;
  final String? reason;
  final String? reference;
  final String? createdBy;

  const MovementEntity({
    required this.id,
    required this.type,
    required this.movementDate,
    required this.productName,
    required this.quantity,
    required this.quantityBefore,
    required this.quantityAfter,
    this.reason,
    this.reference,
    this.createdBy,
  });
}
