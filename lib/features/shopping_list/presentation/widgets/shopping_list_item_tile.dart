import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import '../../domain/entities/shopping_list_item_entity.dart';

class ShoppingListItemTile extends StatelessWidget {
  final ShoppingListItemEntity item;
  final VoidCallback onCheck;
  final VoidCallback onRemove;

  const ShoppingListItemTile({
    super.key,
    required this.item,
    required this.onCheck,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        color: AppColors.danger.withOpacity(0.15),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            InkWell(
              onTap: item.checked ? null : onCheck,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.checked
                      ? AppColors.good
                      : Colors.transparent,
                  border: Border.all(
                    color: item.checked ? AppColors.good : AppColors.line2,
                    width: 2,
                  ),
                ),
                child: item.checked
                    ? const Icon(Icons.check, size: 16, color: Color(0xFF0A0A0A))
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration:
                          item.checked ? TextDecoration.lineThrough : null,
                      color: item.checked
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (item.isAutoSynced)
                    const Text(
                      'Estoque baixo',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textTertiary),
                    ),
                ],
              ),
            ),
            Text(
              item.quantity % 1 == 0
                  ? item.quantity.toStringAsFixed(0)
                  : item.quantity.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
