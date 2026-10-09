import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import '../../../movements/presentation/widgets/product_selector_widget.dart';
import '../../../stock/domain/entities/product_entity.dart';
import '../../domain/entities/nfce_result_entity.dart';
import '../providers/scanner_provider.dart';

// Observa scannerProvider diretamente (em vez de receber `result` estático)
// para re-renderizar a lista de itens após cada revisão (PATCH /items/{id}),
// já que o bottom sheet fica aberto durante toda a revisão, antes de confirmar.
class NfceResultBottomSheet extends ConsumerWidget {
  final VoidCallback onConfirm;
  final VoidCallback onScanAgain;

  const NfceResultBottomSheet({
    super.key,
    required this.onConfirm,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(scannerProvider).result;
    if (result == null) return const SizedBox.shrink();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: context.hs.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.hs.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: HsColors.soft(context.hs.good),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.check_circle_outline,
                        color: context.hs.good, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NFC-e Lida com Sucesso',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        Text(
                          result.emitente,
                          style:
                              TextStyle(color: context.hs.text2, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Toque em um item para editar, religar a um produto existente ou ignorar.',
                style: TextStyle(fontSize: 11, color: context.hs.muted),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(indent: 20, endIndent: 20),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: result.itens.length,
                itemBuilder: (_, i) {
                  final item = result.itens[i];
                  return InkWell(
                    onTap: () => _openItemEditor(context, ref, result.id, item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Opacity(
                        opacity: item.ignored ? 0.45 : 1,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.descricao,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      decoration: item.ignored
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantidade.toStringAsFixed(item.quantidade == item.quantidade.roundToDouble() ? 0 : 3)} ${item.unidade}  ×  ${item.valorUnitario.toBRL()}'
                                    '${item.ignored ? '  ·  ignorado' : ''}',
                                    style: TextStyle(
                                        fontSize: 11, color: context.hs.text2),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              item.valorTotal.toBRL(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.edit_outlined,
                                size: 16, color: context.hs.muted),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    result.valorTotal.toBRL(),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: context.hs.primary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onScanAgain,
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: const Text('Escanear outra'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(Icons.add_box_outlined, size: 18),
                      label: const Text('Dar Entrada'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openItemEditor(
    BuildContext context,
    WidgetRef ref,
    String invoiceId,
    NfceItemEntity item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemEditorSheet(invoiceId: invoiceId, item: item),
    );
  }
}

class _ItemEditorSheet extends ConsumerStatefulWidget {
  final String invoiceId;
  final NfceItemEntity item;

  const _ItemEditorSheet({required this.invoiceId, required this.item});

  @override
  ConsumerState<_ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends ConsumerState<_ItemEditorSheet> {
  late final _nameCtrl = TextEditingController(text: widget.item.descricao);
  late final _qtyCtrl =
      TextEditingController(text: widget.item.quantidade.toString());
  late bool _ignored = widget.item.ignored;
  String? _mergeIntoProductId;
  String? _mergeIntoProductName;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMergeProduct() async {
    ProductEntity? picked;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.hs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: ProductSelectorWidget(
          selected: null,
          onSelect: (p) {
            picked = p;
            Navigator.of(context).pop();
          },
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _mergeIntoProductId = picked!.id;
        _mergeIntoProductName = picked!.name;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final newQty = double.tryParse(_qtyCtrl.text.replaceAll(',', '.'));
      await ref.read(scannerProvider.notifier).reviewItem(
            widget.item.id,
            productName: _nameCtrl.text.trim() != widget.item.descricao
                ? _nameCtrl.text.trim()
                : null,
            mergeIntoProductId: _mergeIntoProductId,
            quantity: newQty != widget.item.quantidade ? newQty : null,
            ignored: _ignored != widget.item.ignored ? _ignored : null,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) context.showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.hs.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Editar item',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nome do produto'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qtyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Quantidade'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickMergeProduct,
            icon: const Icon(Icons.link, size: 18),
            label: Text(
              _mergeIntoProductName ?? 'Religar a produto existente',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ignorar este item'),
            subtitle: const Text(
              'Não entra no estoque ao confirmar a nota.',
              style: TextStyle(fontSize: 12),
            ),
            value: _ignored,
            onChanged: (v) => setState(() => _ignored = v),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.hs.onPrimary,
                    ),
                  )
                : const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
