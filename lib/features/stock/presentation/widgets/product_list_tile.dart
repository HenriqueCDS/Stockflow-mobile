// Migrado de: src/pages/Products.jsx (linhas da tabela)
// Tabela web → ListTile com swipe actions (UX mobile)
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import '../../domain/entities/product_entity.dart';
import 'stock_status_chip.dart';

class ProductListTile extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return false; // usa onDeactivate explicitamente
      },
      background: Container(
        color: AppColors.danger.withOpacity(0.15),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Thumbnail placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          product.ean ?? '—',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (product.category != null) ...[
                          const Text(
                            ' · ',
                            style: TextStyle(color: AppColors.textTertiary),
                          ),
                          Text(
                            product.category!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Qty + status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.displayStock,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: product.isOutOfStock
                          ? AppColors.danger
                          : product.isLowStock
                              ? AppColors.warn
                              : AppColors.good,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StockStatusChip(product: product),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
