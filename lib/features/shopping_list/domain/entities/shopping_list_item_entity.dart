// Espelha ShoppingListItemResponseDTO (GET /api/v1/shopping-list).
// A lista já vem sincronizada pelo backend com produtos abaixo do mínimo —
// o app só lista, adiciona item manual, risca e remove.
class ShoppingListItemEntity {
  final String id;
  final String? productId;
  final String name;
  final double quantity;
  final bool checked;
  final DateTime? createdAt;

  const ShoppingListItemEntity({
    required this.id,
    this.productId,
    required this.name,
    required this.quantity,
    this.checked = false,
    this.createdAt,
  });

  // Itens sincronizados automaticamente a partir do estoque baixo têm productId;
  // itens manuais (POST /shopping-list) não.
  bool get isAutoSynced => productId != null;
}
