// Cadastro/edição de produto — espelha ProductRequestDTO: {name, ean, category, unit, minimumStock}.
// Preço e quantidade em estoque não são definidos aqui: custo médio é calculado
// pelo backend a partir dos movimentos e o estoque é ajustado via Entrada/Saída.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import '../providers/stock_provider.dart';
import '../../domain/usecases/get_products_usecase.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final String? productId;
  const ProductFormPage({super.key, this.productId});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _eanCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _minCtrl = TextEditingController();

  bool _loading = false;
  bool _loadingProduct = false;

  bool get _isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => _loadingProduct = true);
    try {
      final uc = GetProductByIdUseCase(ref.read(productRepoProvider));
      final p = await uc(widget.productId!);
      _nameCtrl.text = p.name;
      _eanCtrl.text = p.ean ?? '';
      _catCtrl.text = p.category ?? '';
      _unitCtrl.text = p.unit ?? '';
      _minCtrl.text = p.minimumStock?.toString() ?? '';
    } catch (e) {
      if (mounted) context.showError(e.toString());
    } finally {
      if (mounted) setState(() => _loadingProduct = false);
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _eanCtrl, _catCtrl, _unitCtrl, _minCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      if (_eanCtrl.text.trim().isNotEmpty) 'ean': _eanCtrl.text.trim(),
      if (_catCtrl.text.trim().isNotEmpty) 'category': _catCtrl.text.trim(),
      if (_unitCtrl.text.trim().isNotEmpty) 'unit': _unitCtrl.text.trim(),
      if (_minCtrl.text.trim().isNotEmpty)
        'minimumStock': double.parse(_minCtrl.text.replaceAll(',', '.')),
    };

    try {
      final repo = ref.read(productRepoProvider);
      if (_isEditing) {
        await UpdateProductUseCase(repo)(widget.productId!, data);
      } else {
        await CreateProductUseCase(repo)(data);
      }
      await ref.read(stockProvider.notifier).refresh();
      if (mounted) {
        context.showSuccess(
          _isEditing ? 'Produto atualizado!' : 'Produto cadastrado!',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Produto' : 'Novo Produto'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loadingProduct
          ? const AppLoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field(_nameCtrl, 'Nome do Produto *',
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Informe o nome' : null),
                    _field(_eanCtrl, 'Código de Barras (EAN)',
                        hint: 'Ex: 7891234567890', type: TextInputType.number),
                    _field(_catCtrl, 'Categoria', hint: 'Ex: Alimentos'),
                    _field(_unitCtrl, 'Unidade', hint: 'Ex: UN, KG, CX'),
                    _field(
                      _minCtrl,
                      'Estoque Mínimo',
                      hint: 'Alerta abaixo desse valor',
                      type:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = double.tryParse(v.replaceAll(',', '.'));
                        return n == null || n < 0 ? 'Valor inválido' : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'O estoque atual é ajustado por Entrada/Saída, não por aqui.',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.hs.muted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.hs.onPrimary,
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? 'Salvar Alterações'
                                  : 'Cadastrar Produto',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    String? hint,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}
