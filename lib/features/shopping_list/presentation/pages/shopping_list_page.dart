// Lista de compras compartilhada — já vem sincronizada pelo backend com
// produtos abaixo do mínimo; o app só lista, adiciona item manual, risca e remove.
// Layout HomeStock.pdf · Lista de compras: sugeridos pelo estoque (auto) em
// destaque, itens da família e comprados riscados.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import 'package:homestock_mobile/shared/widgets/empty_state_widget.dart';
import 'package:homestock_mobile/shared/widgets/error_state_widget.dart';
import 'package:homestock_mobile/shared/widgets/hs_ui.dart';
import '../../domain/entities/shopping_list_item_entity.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/shopping_list_item_tile.dart';

class ShoppingListPage extends ConsumerStatefulWidget {
  const ShoppingListPage({super.key});

  @override
  ConsumerState<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends ConsumerState<ShoppingListPage> {
  final _addCtrl = TextEditingController();
  final _addFocus = FocusNode();

  @override
  void dispose() {
    _addCtrl.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _addCtrl.text.trim();
    if (name.isEmpty) return;
    _addCtrl.clear();
    try {
      await ref.read(shoppingListProvider.notifier).addItem(name, quantity: 1);
    } catch (e) {
      if (mounted) context.showError(e.toString());
    }
  }

  Future<void> _share(List<ShoppingListItemEntity> items) async {
    final pending = items.where((i) => !i.checked).toList();
    if (pending.isEmpty) {
      context.showInfo('Nada pendente para compartilhar.');
      return;
    }
    final text = [
      'Lista de compras · HomeStock',
      ...pending.map((i) => '- ${i.name}'),
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) context.showSuccess('Lista copiada. É só colar na conversa.');
  }

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final state = ref.watch(shoppingListProvider);
    final notifier = ref.read(shoppingListProvider.notifier);
    final items = state.valueOrNull ?? const <ShoppingListItemEntity>[];

    Widget tile(ShoppingListItemEntity item, {EdgeInsetsGeometry? padding}) =>
        ShoppingListItemTile(
          item: item,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          onCheck: () => notifier.checkItem(item.id),
          onRemove: () => notifier.removeItem(item.id),
        );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTitle(
              title: 'Lista de compras',
              trailing: OutlinedButton(
                onPressed: () => _share(items),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: const StadiumBorder(),
                  backgroundColor: hs.surface2,
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
                child: const Text('compartilhar'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: TextField(
                controller: _addCtrl,
                focusNode: _addFocus,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) async {
                  await _add();
                  _addFocus.requestFocus();
                },
                decoration: InputDecoration(
                  hintText: '+ Adicionar item',
                  suffixIcon: IconButton(
                    tooltip: 'Adicionar',
                    icon: Icon(Icons.arrow_upward_rounded, color: hs.primary),
                    onPressed: _add,
                  ),
                ),
              ),
            ),
            Expanded(
              child: state.when(
                skipLoadingOnReload: true,
                loading: () =>
                    const AppLoadingIndicator(text: 'Carregando lista…'),
                error: (e, _) => ErrorStateWidget(
                  message: e.toString(),
                  onRetry: notifier.refresh,
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.checklist_rounded,
                      title: 'Lista vazia',
                      subtitle:
                          'Itens acabando no estoque aparecem aqui sozinhos. Você também pode adicionar à mão.',
                    );
                  }

                  final suggested =
                      items.where((i) => i.isAutoSynced && !i.checked).toList();
                  final family = items
                      .where((i) => !i.isAutoSynced && !i.checked)
                      .toList();
                  final bought = items.where((i) => i.checked).toList();

                  return RefreshIndicator(
                    onRefresh: notifier.refresh,
                    child: ListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 32),
                      children: [
                        if (suggested.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: hs.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: hs.primaryLine),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 14, 12, 10),
                                    child: SectionLabel(
                                      'Sugeridos pelo estoque',
                                      color: hs.primaryInk,
                                      trailing: const _AutoTag(),
                                    ),
                                  ),
                                  for (final item in suggested) ...[
                                    Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                        color: hs.border),
                                    tile(
                                      item,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        if (family.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
                            child: SectionLabel('Da família'),
                          ),
                          ..._separated(family.map(tile).toList()),
                        ],
                        if (bought.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
                            child: SectionLabel('Comprados'),
                          ),
                          ..._separated(bought.map(tile).toList()),
                        ],
                      ],
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

  List<Widget> _separated(List<Widget> tiles) => [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const Divider(height: 1, indent: 20, endIndent: 20),
          tiles[i],
        ],
      ];
}

class _AutoTag extends StatelessWidget {
  const _AutoTag();

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: hs.surface2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: hs.border),
      ),
      child: Text(
        '[ AUTO ]',
        style: TextStyle(
          fontSize: 10,
          letterSpacing: 1.2,
          color: hs.muted,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
