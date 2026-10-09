// Linha da lista de compras (HomeStock.pdf · Lista de compras):
// checkbox quadrado laranja, nome riscado quando comprado, deslizar remove.
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import '../../domain/entities/shopping_list_item_entity.dart';

class ShoppingListItemTile extends StatelessWidget {
  final ShoppingListItemEntity item;
  final VoidCallback onCheck;
  final VoidCallback onRemove;
  final EdgeInsetsGeometry padding;

  const ShoppingListItemTile({
    super.key,
    required this.item,
    required this.onCheck,
    required this.onRemove,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  String get _qty => item.quantity % 1 == 0
      ? item.quantity.toStringAsFixed(0)
      : item.quantity.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        color: HsColors.soft(hs.bad),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_outline, color: hs.bad),
      ),
      child: InkWell(
        onTap: item.checked ? null : onCheck,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: item.checked ? hs.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: item.checked ? hs.primary : hs.muted,
                    width: 1.5,
                  ),
                ),
                child: item.checked
                    ? Icon(Icons.check, size: 15, color: hs.onPrimary)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 15,
                        decoration:
                            item.checked ? TextDecoration.lineThrough : null,
                        decorationColor: hs.muted,
                        color: item.checked ? hs.muted : hs.text,
                      ),
                    ),
                    if (item.isAutoSynced && !item.checked) ...[
                      const SizedBox(height: 2),
                      Text(
                        'acabando · estoque',
                        style: TextStyle(fontSize: 12, color: hs.muted),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '$_qty un',
                style: TextStyle(
                  fontSize: 12,
                  color: hs.muted,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
