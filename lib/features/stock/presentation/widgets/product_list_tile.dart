// Migrado de: src/pages/Products.jsx (linhas da tabela)
// Layout HomeStock.pdf · Estoque: miniatura, nome, local e stepper − qtd +.
// Quantidade em vermelho (bad) quando o item está acabando.
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/stock_provider.dart';

class ProductListTile extends StatelessWidget {
  final ProductEntity product;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onTap,
    required this.onLongPress,
    required this.onIncrement,
    this.onDecrement,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final qtyColor = product.isRunningOut ? hs.bad : hs.text;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hs.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.inventory_2_outlined, size: 20, color: hs.muted),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: hs.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.categoryLabel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: hs.muted,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StepButton(
              icon: Icons.remove,
              tooltip: 'Usei 1',
              onTap: busy ? null : onDecrement,
            ),
            SizedBox(
              width: 36,
              child: busy
                  ? Center(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: hs.muted,
                        ),
                      ),
                    )
                  : Text(
                      product.displayStock,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: qtyColor,
                      ),
                    ),
            ),
            _StepButton(
              icon: Icons.add,
              tooltip: 'Adicionar 1',
              onTap: busy ? null : onIncrement,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: hs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: BorderSide(color: hs.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              icon,
              size: 16,
              color: enabled ? hs.text : hs.muted.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
