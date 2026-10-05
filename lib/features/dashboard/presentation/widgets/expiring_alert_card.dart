// Novo – não existe no React (wireframe: vencendo em breve)
// Recebe ProductEntity (mesma fonte usada em Alerts) pois o /dashboard da API
// só devolve a CONTAGEM de itens em baixa/sem estoque, não a lista deles.
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import '../../../stock/domain/entities/product_entity.dart';

class LowStockAlertCard extends StatelessWidget {
  final List<ProductEntity> products;
  final String title;
  final Color color;
  final Color bgColor;
  final IconData icon;
  final VoidCallback? onViewAll;

  const LowStockAlertCard({
    super.key,
    required this.products,
    required this.title,
    this.color = AppColors.warn,
    this.bgColor = const Color(0x14D97706),
    this.icon = Icons.warning_amber_rounded,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              Text(
                '${products.length}',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...products.take(3).map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${p.displayStock} un',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (products.length > 3 && onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'Ver todos →',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
