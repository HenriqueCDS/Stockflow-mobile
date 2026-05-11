// Migrado de: src/pages/Products.jsx (badges de situação)
// Wireframe: seção 04-C urgência badges
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import '../../domain/entities/product_entity.dart';

class StockStatusChip extends StatelessWidget {
  final ProductEntity product;

  const StockStatusChip({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.isOutOfStock) {
      return _Chip(
        label: 'Sem estoque',
        color: AppColors.danger,
      );
    }
    if (product.isLowStock) {
      return _Chip(
        label: 'Estoque baixo',
        color: AppColors.warn,
        icon: Icons.warning_amber_rounded,
      );
    }
    return _Chip(label: 'Normal', color: AppColors.good);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
