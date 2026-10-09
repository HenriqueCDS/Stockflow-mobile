// Migrado de: src/pages/StockExit.jsx
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import '../providers/stock_exit_provider.dart';
import '../widgets/product_selector_widget.dart';
import '../../../stock/presentation/providers/stock_provider.dart';

class StockExitPage extends ConsumerStatefulWidget {
  const StockExitPage({super.key});

  @override
  ConsumerState<StockExitPage> createState() => _StockExitPageState();
}

class _StockExitPageState extends ConsumerState<StockExitPage> {
  final _qtyCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(stockExitProvider.notifier);
    final state = ref.read(stockExitProvider);
    if (state.selectedProduct == null) {
      context.showError('Selecione um produto.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    try {
      await notifier.registerExit(
        quantity: int.parse(_qtyCtrl.text),
        reason: _reasonCtrl.text.trim(),
        reference: _refCtrl.text.trim(),
      );
      ref.invalidate(stockProvider);
      if (mounted) {
        _qtyCtrl.clear();
        _reasonCtrl.clear();
        _refCtrl.clear();
        context.showSuccess('Saída registrada! Estoque atualizado.');
      }
    } catch (e) {
      if (mounted) context.showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockExitProvider);
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    final wouldGoNegative = state.selectedProduct != null &&
        qty > state.selectedProduct!.currentStock;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Saída'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(stockExitProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductSelectorWidget(
              selected: state.selectedProduct,
              onSelect: (p) =>
                  ref.read(stockExitProvider.notifier).selectProduct(p),
              hideOutOfStock: false,
            ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 20),
            if (state.selectedProduct != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: state.selectedProduct!.isOutOfStock
                      ? HsColors.soft(context.hs.bad)
                      : context.hs.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.selectedProduct!.isOutOfStock
                        ? context.hs.bad.withValues(alpha: 0.35)
                        : context.hs.primaryLine,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.selectedProduct!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Disponível: ${state.selectedProduct!.displayStock} unidades',
                      style: TextStyle(
                        fontSize: 13,
                        color: state.selectedProduct!.isOutOfStock
                            ? context.hs.bad
                            : context.hs.text2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (state.selectedProduct!.isOutOfStock)
                      Text(
                        '⚠ Produto sem estoque disponível',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.hs.bad,
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              '2. Informações da Saída',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Quantidade que saiu *',
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1) return 'Mínimo 1 unidade';
                      if (state.selectedProduct != null &&
                          n > state.selectedProduct!.currentStock) {
                        return 'Maior que o estoque disponível (${state.selectedProduct!.displayStock})';
                      }
                      return null;
                    },
                  ),
                  if (wouldGoNegative)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: context.hs.bad, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Quantidade maior que o estoque!',
                            style: TextStyle(
                              color: context.hs.bad,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Motivo / Destino',
                      hintText: 'Ex: Venda, uso interno, doação…',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _refCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Referência',
                      hintText: 'Ex: Pedido #123…',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.hs.bad,
                foregroundColor: context.hs.bg,
              ),
              onPressed: (state.saving ||
                      state.selectedProduct == null ||
                      state.selectedProduct!.isOutOfStock)
                  ? null
                  : _submit,
              icon: state.saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.remove_circle_outline),
              label: Text(
                state.saving ? 'Registrando…' : 'Confirmar Saída do Estoque',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
