// Migrado de: src/pages/Products.jsx
// Tabela web → ListView com chips de filtro e 3 vistas (wireframe seção 04)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import 'package:homestock_mobile/shared/widgets/confirm_bottom_sheet.dart';
import 'package:homestock_mobile/shared/widgets/empty_state_widget.dart';
import 'package:homestock_mobile/shared/widgets/error_state_widget.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/stock_provider.dart';
import '../widgets/product_list_tile.dart';

class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key});

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockProvider);
    final view = ref.watch(stockViewProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estoque',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/stock/history'),
                    icon: const Icon(Icons.history),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            // ── Search ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    ref.read(stockProvider.notifier).search(v),
                decoration: InputDecoration(
                  hintText: 'Buscar produto, marca, código…',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(stockProvider.notifier).refresh();
                          },
                        )
                      : null,
                ),
              ),
            ),

            // ── View toggle chips ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
              child: Row(
                children: StockView.values.map((v) {
                  final labels = ['Lista', 'Categoria', 'Urgência'];
                  final active = view == v;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => ref
                          .read(stockViewProvider.notifier)
                          .state = v,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color:
                              active ? AppColors.accentSoft : AppColors.surface2,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: active
                                ? AppColors.accentLine
                                : AppColors.line,
                          ),
                        ),
                        child: Text(
                          labels[v.index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: state.when(
                loading: () =>
                    const AppLoadingIndicator(text: 'Carregando produtos…'),
                error: (e, _) => ErrorStateWidget(
                  message: e.toString(),
                  onRetry: () => ref.read(stockProvider.notifier).refresh(),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      title: 'Nenhum produto encontrado',
                      subtitle: 'Adicione produtos ou ajuste a busca.',
                      action: ElevatedButton.icon(
                        onPressed: () => context.push('/stock/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Produto'),
                      ),
                    );
                  }

                  // Urgência: ordena por criticidade
                  final List<ProductEntity> sorted = List.of(products);
                  if (view == StockView.urgency) {
                    sorted.sort((a, b) {
                      if (a.isOutOfStock && !b.isOutOfStock) return -1;
                      if (!a.isOutOfStock && b.isOutOfStock) return 1;
                      if (a.isLowStock && !b.isLowStock) return -1;
                      if (!a.isLowStock && b.isLowStock) return 1;
                      return a.name.compareTo(b.name);
                    });
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.surface,
                    onRefresh: () =>
                        ref.read(stockProvider.notifier).refresh(),
                    child: ListView.separated(
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 70),
                      itemBuilder: (_, i) => ProductListTile(
                        product: sorted[i],
                        onEdit: () =>
                            context.push('/stock/${sorted[i].id}/edit'),
                        onDeactivate: () async {
                          final confirmed = await showConfirmBottomSheet(
                            context: context,
                            title: 'Desativar produto?',
                            message:
                                'Tem certeza que deseja desativar "${sorted[i].name}"? O histórico será mantido.',
                            confirmLabel: 'Sim, desativar',
                            danger: true,
                          );
                          if (confirmed) {
                            await ref
                                .read(stockProvider.notifier)
                                .deactivate(sorted[i].id);
                            if (context.mounted) {
                              context.showSuccess('Produto desativado.');
                            }
                          }
                        },
                        onUse: sorted[i].isOutOfStock
                            ? null
                            : () async {
                                try {
                                  await ref
                                      .read(stockProvider.notifier)
                                      .use(sorted[i].id);
                                  if (context.mounted) {
                                    context.showSuccess(
                                        '"${sorted[i].name}" marcado como usado.');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    context.showError(e.toString());
                                  }
                                }
                              },
                        onDiscard: sorted[i].isOutOfStock
                            ? null
                            : () async {
                                try {
                                  await ref
                                      .read(stockProvider.notifier)
                                      .discard(sorted[i].id);
                                  if (context.mounted) {
                                    context.showSuccess(
                                        '"${sorted[i].name}" descartado.');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    context.showError(e.toString());
                                  }
                                }
                              },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/stock/new'),
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF0A0A0A),
        child: const Icon(Icons.add),
      ),
    );
  }
}
