// Migrado de: src/pages/Products.jsx
// Layout HomeStock.pdf · Estoque: título + contagem, busca, pílulas de filtro
// (todos · acabando · categorias) e lista com stepper − / +.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import 'package:homestock_mobile/shared/widgets/confirm_bottom_sheet.dart';
import 'package:homestock_mobile/shared/widgets/empty_state_widget.dart';
import 'package:homestock_mobile/shared/widgets/error_state_widget.dart';
import 'package:homestock_mobile/shared/widgets/hs_ui.dart';
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
  final _busy = <String>{};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(
    ProductEntity p,
    Future<void> Function() action,
    String success,
  ) async {
    setState(() => _busy.add(p.id));
    try {
      await action();
      if (mounted) context.showSuccess(success);
    } catch (e) {
      if (mounted) context.showError(e.toString());
    } finally {
      if (mounted) setState(() => _busy.remove(p.id));
    }
  }

  Future<void> _showActions(ProductEntity p) async {
    final notifier = ref.read(stockProvider.notifier);
    final hs = context.hs;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                p.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: hs.text,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar produto'),
              onTap: () => Navigator.pop(sheet, 'edit'),
            ),
            if (!p.isOutOfStock)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Descartei 1 unidade'),
                onTap: () => Navigator.pop(sheet, 'discard'),
              ),
            ListTile(
              leading: Icon(Icons.block, color: hs.bad),
              title: Text('Desativar', style: TextStyle(color: hs.bad)),
              onTap: () => Navigator.pop(sheet, 'deactivate'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case 'edit':
        context.push('/stock/${p.id}/edit');
      case 'discard':
        await _run(p, () => notifier.discard(p.id), '"${p.name}" descartado.');
      case 'deactivate':
        final confirmed = await showConfirmBottomSheet(
          context: context,
          title: 'Desativar produto?',
          message:
              'Tem certeza que deseja desativar "${p.name}"? O histórico será mantido.',
          confirmLabel: 'Sim, desativar',
          danger: true,
        );
        if (confirmed) {
          await _run(p, () => notifier.deactivate(p.id), 'Produto desativado.');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final state = ref.watch(stockProvider);
    final filter = ref.watch(stockFilterProvider);
    final products = state.valueOrNull ?? const <ProductEntity>[];

    final categories = {for (final p in products) p.categoryLabel}.toList()
      ..sort();
    // Mantém visível a categoria vinda do dashboard mesmo se a busca a esconder.
    if (filter is StockFilterCategory &&
        !categories.contains(filter.category)) {
      categories.add(filter.category);
    }
    final labels = ['todos', 'acabando', ...categories];
    final selected = switch (filter) {
      StockFilterAll() => 0,
      StockFilterRunningOut() => 1,
      StockFilterCategory(:final category) => 2 + categories.indexOf(category),
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageTitle(
              title: 'Estoque',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.hasValue)
                    Text(
                      '${products.length} itens',
                      style: TextStyle(fontSize: 13, color: hs.muted),
                    ),
                  IconButton(
                    tooltip: 'Histórico',
                    onPressed: () => context.push('/stock/history'),
                    icon: Icon(Icons.history_rounded, color: hs.text2),
                  ),
                  IconButton(
                    tooltip: 'Novo produto',
                    onPressed: () => context.push('/stock/new'),
                    icon: Icon(Icons.add_rounded, color: hs.text2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (v) => ref.read(stockProvider.notifier).search(v),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar na casa…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(stockProvider.notifier).refresh();
                          },
                        )
                      : null,
                ),
              ),
            ),
            FilterPillBar(
              labels: labels,
              selected: selected,
              onSelected: (i) =>
                  ref.read(stockFilterProvider.notifier).state = switch (i) {
                0 => const StockFilterAll(),
                1 => const StockFilterRunningOut(),
                _ => StockFilterCategory(categories[i - 2]),
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: state.when(
                skipLoadingOnReload: true,
                loading: () =>
                    const AppLoadingIndicator(text: 'Carregando produtos…'),
                error: (e, _) => ErrorStateWidget(
                  message: e.toString(),
                  onRetry: () => ref.read(stockProvider.notifier).refresh(),
                ),
                data: (all) {
                  final visible = all
                      .where((p) => switch (filter) {
                            StockFilterAll() => true,
                            StockFilterRunningOut() => p.isRunningOut,
                            StockFilterCategory(:final category) =>
                              p.categoryLabel == category,
                          })
                      .toList()
                    ..sort((a, b) =>
                        a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                  if (visible.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      title: 'Nenhum produto encontrado',
                      subtitle: 'Adicione produtos ou ajuste a busca.',
                      action: ElevatedButton.icon(
                        onPressed: () => context.push('/stock/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar produto'),
                      ),
                    );
                  }

                  final notifier = ref.read(stockProvider.notifier);
                  return RefreshIndicator(
                    onRefresh: notifier.refresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 78, endIndent: 20),
                      itemBuilder: (_, i) {
                        final p = visible[i];
                        return ProductListTile(
                          product: p,
                          busy: _busy.contains(p.id),
                          onTap: () => context.push('/stock/${p.id}/edit'),
                          onLongPress: () => _showActions(p),
                          onDecrement: p.isOutOfStock
                              ? null
                              : () => _run(p, () => notifier.use(p.id),
                                  '"${p.name}" marcado como usado.'),
                          onIncrement: () => _run(p,
                              () => notifier.restock(p.id), '+1 "${p.name}".'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
