// Migrado de: src/pages/StockEntry.jsx + StockExit.jsx (lista de seleção de produto)
// Lista scrollável com busca inline → mesmo padrão nos wireframes
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import '../../../stock/domain/entities/product_entity.dart';
import '../../../stock/presentation/providers/stock_provider.dart';

class ProductSelectorWidget extends ConsumerStatefulWidget {
  final ProductEntity? selected;
  final void Function(ProductEntity) onSelect;
  final bool hideOutOfStock;

  const ProductSelectorWidget({
    super.key,
    required this.selected,
    required this.onSelect,
    this.hideOutOfStock = false,
  });

  @override
  ConsumerState<ProductSelectorWidget> createState() =>
      _ProductSelectorWidgetState();
}

class _ProductSelectorWidgetState
    extends ConsumerState<ProductSelectorWidget> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockState = ref.watch(stockProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. Escolha o Produto',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Digite o nome ou código…',
            prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textTertiary),
          ),
        ),
        const SizedBox(height: 10),
        stockState.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (e, _) => Text(e.toString()),
          data: (products) {
            final q = _searchCtrl.text.toLowerCase();
            final filtered = products.where((p) {
              if (widget.hideOutOfStock && p.isOutOfStock) return false;
              if (q.isEmpty) return true;
              return p.name.toLowerCase().contains(q) ||
                  p.sku.toLowerCase().contains(q);
            }).toList();

            if (filtered.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Nenhum produto encontrado',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 260,
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = filtered[i];
                  final isSelected = widget.selected?.id == p.id;
                  return InkWell(
                    onTap: p.isOutOfStock && widget.hideOutOfStock
                        ? null
                        : () => widget.onSelect(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentSoft
                            : Colors.transparent,
                        border: isSelected
                            ? Border.all(color: AppColors.accentLine)
                            : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Cód: ${p.sku}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${p.quantityInStock} disponíveis',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: p.isOutOfStock
                                  ? AppColors.danger
                                  : AppColors.good,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
