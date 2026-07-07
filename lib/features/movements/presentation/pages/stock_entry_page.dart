// Migrado de: src/pages/StockEntry.jsx
// Layout 2 colunas web → página única com seções empilhadas (mobile)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import '../providers/stock_entry_provider.dart';
import '../providers/movements_provider.dart';
import '../widgets/product_selector_widget.dart';
import '../../../stock/presentation/providers/stock_provider.dart';

class StockEntryPage extends ConsumerStatefulWidget {
  const StockEntryPage({super.key});

  @override
  ConsumerState<StockEntryPage> createState() => _StockEntryPageState();
}

class _StockEntryPageState extends ConsumerState<StockEntryPage> {
  final _qtyCtrl = TextEditingController(text: '');
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
    final notifier = ref.read(stockEntryProvider.notifier);
    final state = ref.read(stockEntryProvider);
    if (state.selectedProduct == null) {
      context.showError('Selecione um produto.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    try {
      await notifier.registerEntry(
        quantity: int.parse(_qtyCtrl.text),
        reason: _reasonCtrl.text.trim(),
        reference: _refCtrl.text.trim(),
      );
      // Invalida stocks para refletir nova quantidade
      ref.invalidate(stockProvider);
      if (mounted) {
        _qtyCtrl.clear();
        _reasonCtrl.clear();
        _refCtrl.clear();
        context.showSuccess(
          'Entrada registrada! Estoque atualizado.',
        );
      }
    } catch (e) {
      if (mounted) context.showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockEntryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dar Entrada no Estoque'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(stockEntryProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Seleção de produto ──────────────────────────────────────
            ProductSelectorWidget(
              selected: state.selectedProduct,
              onSelect: (p) =>
                  ref.read(stockEntryProvider.notifier).selectProduct(p),
            ),

            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 20),

            // ── Produto selecionado preview ─────────────────────────────
            if (state.selectedProduct != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentLine),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        color: AppColors.accent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
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
                            'Estoque atual: ${state.selectedProduct!.displayStock} unidades',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Text(
                  '↑ Selecione um produto acima',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 24),

            // ── Formulário ─────────────────────────────────────────────
            const Text(
              '2. Informações da Entrada',
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
                    decoration: const InputDecoration(
                      labelText: 'Quantidade que chegou *',
                      hintText: '0',
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n < 1
                          ? 'Mínimo 1 unidade'
                          : null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Motivo / Observação',
                      hintText: 'Ex: Compra de reposição…',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _refCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Número do pedido / referência',
                      hintText: 'Ex: NF-001, Pedido #123…',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: state.saving ? null : _submit,
              icon: state.saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0A0A0A),
                      ),
                    )
                  : const Icon(Icons.add_box_outlined),
              label: Text(
                state.saving ? 'Registrando…' : 'Confirmar Entrada no Estoque',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
