// Migrado de: src/pages/Products.jsx (formulário inline de create/edit)
// Formulário inline web → página separada com AppBar (UX mobile)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import '../providers/stock_provider.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart' show CreateProductUseCase, UpdateProductUseCase;

class ProductFormPage extends ConsumerStatefulWidget {
  final String? productId;
  const ProductFormPage({super.key, this.productId});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
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
      _skuCtrl.text = p.sku;
      _descCtrl.text = p.description ?? '';
      _catCtrl.text = p.category ?? '';
      _priceCtrl.text = p.unitPrice.toString();
      _qtyCtrl.text = p.quantityInStock.toString();
      _minCtrl.text = p.minimumStock?.toString() ?? '';
    } catch (e) {
      if (mounted) context.showError(e.toString());
    } finally {
      if (mounted) setState(() => _loadingProduct = false);
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _skuCtrl, _descCtrl, _catCtrl, _priceCtrl, _qtyCtrl, _minCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'sku': _skuCtrl.text.trim(),
      if (_descCtrl.text.isNotEmpty) 'description': _descCtrl.text.trim(),
      if (_catCtrl.text.isNotEmpty) 'category': _catCtrl.text.trim(),
      'unitPrice': double.parse(_priceCtrl.text.replaceAll(',', '.')),
      'quantityInStock': int.parse(_qtyCtrl.text),
      if (_minCtrl.text.isNotEmpty) 'minimumStock': int.parse(_minCtrl.text),
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
                    _field(_skuCtrl, 'Código (SKU) *',
                        hint: 'Ex: ARR-5KG-01',
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Informe o SKU' : null),
                    _field(_catCtrl, 'Categoria', hint: 'Ex: Alimentos'),
                    _field(
                      _priceCtrl,
                      'Preço Unitário (R$) *',
                      hint: '0,00',
                      type: TextInputType.number,
                      validator: (v) {
                        final n = double.tryParse(
                            v?.replaceAll(',', '.') ?? '');
                        return n == null || n < 0
                            ? 'Preço inválido'
                            : null;
                      },
                    ),
                    _field(
                      _qtyCtrl,
                      'Quantidade em Estoque *',
                      hint: '0',
                      type: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return n == null || n < 0
                            ? 'Quantidade inválida'
                            : null;
                      },
                    ),
                    _field(
                      _minCtrl,
                      'Quantidade Mínima',
                      hint: 'Alerta abaixo desse valor',
                      type: TextInputType.number,
                    ),
                    _field(_descCtrl, 'Descrição',
                        hint: 'Informações adicionais', maxLines: 3),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0A0A0A),
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
