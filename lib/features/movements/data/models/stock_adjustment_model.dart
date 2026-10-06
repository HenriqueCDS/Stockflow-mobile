// Espelha StockAdjustmentRequestDTO (POST /api/v1/stock-movements/adjust).
// type: ENTRY | EXIT | ADJUSTMENT | RETURN. A API não tem campo "reference"
// nem "reason": ambos são unidos em "notes".
class StockAdjustmentModel {
  final String productId;
  final String type;
  final num quantity;
  final String? notes;

  const StockAdjustmentModel({
    required this.productId,
    required this.type,
    required this.quantity,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'type': type,
        'quantity': quantity,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };

  // Une motivo e referência em um único texto de notas.
  static String? buildNotes({String? reason, String? reference}) {
    final parts = [reason, reference]
        .where((p) => p != null && p.trim().isNotEmpty)
        .map((p) => p!.trim())
        .toList();
    return parts.isEmpty ? null : parts.join(' | ');
  }
}
