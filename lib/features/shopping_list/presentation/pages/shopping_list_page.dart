// Lista de compras compartilhada — já vem sincronizada pelo backend com
// produtos abaixo do mínimo; o app só lista, adiciona item manual, risca e remove.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import 'package:homestock_mobile/shared/widgets/empty_state_widget.dart';
import 'package:homestock_mobile/shared/widgets/error_state_widget.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/shopping_list_item_tile.dart';

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  Future<void> _addItem(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adicionar item',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome do item'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(sheetContext).pop(true),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );

    if (added == true && nameCtrl.text.trim().isNotEmpty) {
      final quantity = double.tryParse(qtyCtrl.text.replaceAll(',', '.'));
      try {
        await ref
            .read(shoppingListProvider.notifier)
            .addItem(nameCtrl.text.trim(), quantity: quantity);
      } catch (e) {
        if (context.mounted) context.showError(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shoppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(shoppingListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const AppLoadingIndicator(text: 'Carregando lista…'),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.read(shoppingListProvider.notifier).refresh(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: 'Lista vazia',
              subtitle:
                  'Itens de estoque baixo aparecem aqui automaticamente, ou adicione um item manual.',
              action: ElevatedButton.icon(
                onPressed: () => _addItem(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Item'),
              ),
            );
          }

          final pending = items.where((i) => !i.checked).toList();
          final checked = items.where((i) => i.checked).toList();

          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref.read(shoppingListProvider.notifier).refresh(),
            child: ListView(
              children: [
                if (pending.isNotEmpty)
                  ...pending.map((item) => ShoppingListItemTile(
                        item: item,
                        onCheck: () => ref
                            .read(shoppingListProvider.notifier)
                            .checkItem(item.id),
                        onRemove: () => ref
                            .read(shoppingListProvider.notifier)
                            .removeItem(item.id),
                      )),
                if (checked.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                    child: Text(
                      'COMPRADOS',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  ...checked.map((item) => ShoppingListItemTile(
                        item: item,
                        onCheck: () {},
                        onRemove: () => ref
                            .read(shoppingListProvider.notifier)
                            .removeItem(item.id),
                      )),
                ],
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(context, ref),
        backgroundColor: AppColors.accent,
        foregroundColor: const Color(0xFF0A0A0A),
        child: const Icon(Icons.add),
      ),
    );
  }
}
