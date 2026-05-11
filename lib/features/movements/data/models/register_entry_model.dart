// Espelha o request body de POST /api/v1/stock/entries
class RegisterEntryModel {
  final String productId;
  final int quantity;
  final String? reason;
  final String? reference;

  const RegisterEntryModel({
    required this.productId,
    required this.quantity,
    this.reason,
    this.reference,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        'type': 'ENTRY',
        if (reason != null && reason!.isNotEmpty) 'reason': reason,
        if (reference != null && reference!.isNotEmpty) 'reference': reference,
      };
}
