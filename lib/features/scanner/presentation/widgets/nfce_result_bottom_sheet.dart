import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import '../../domain/entities/nfce_result_entity.dart';

class NfceResultBottomSheet extends StatelessWidget {
  final NfceResultEntity result;
  final VoidCallback onConfirm;
  final VoidCallback onScanAgain;

  const NfceResultBottomSheet({
    super.key,
    required this.result,
    required this.onConfirm,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line2,
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
                      color: AppColors.good.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle_outline,
                        color: AppColors.good, size: 22),
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
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.descricao,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${item.quantidade.toStringAsFixed(item.quantidade == item.quantidade.roundToDouble() ? 0 : 3)} ${item.unidade}  ×  ${item.valorUnitario.toBRL()}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item.valorTotal.toBRL(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
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
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.accent),
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
}
