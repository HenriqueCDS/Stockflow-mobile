// Migrado de: src/pages/History.jsx (linhas da tabela de movimentações)
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import '../../domain/entities/movement_entity.dart';

class MovementListTile extends StatelessWidget {
  final MovementEntity movement;
  const MovementListTile({super.key, required this.movement});

  // Inteiro quando não há decimais (ex.: "3"), senão com até 3 casas (ex.: "1.5").
  static String _fmt(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(3);

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (movement.type) {
      MovementType.entry => (context.hs.good, Icons.arrow_downward_rounded, 'Entrada'),
      MovementType.used => (context.hs.bad, Icons.check_circle_outline, 'Usado'),
      MovementType.discarded => (context.hs.bad, Icons.delete_outline, 'Descartado'),
      MovementType.exit => (context.hs.bad, Icons.arrow_upward_rounded, 'Saída'),
      MovementType.adjustment => (context.hs.primary, Icons.sync_rounded, 'Ajuste'),
      MovementType.returnType => (context.hs.primary, Icons.undo_rounded, 'Devolução'),
    };

    final isNegative = switch (movement.type) {
      MovementType.exit || MovementType.used || MovementType.discarded => true,
      _ => false,
    };
    final sign = isNegative ? '-' : '+';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      movement.movementDate.toLocaleDateTimePtBR(),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.hs.muted,
                      ),
                    ),
                  ],
                ),
                if (movement.reason != null && movement.reason!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      movement.reason!,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.hs.text2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${_fmt(movement.quantity)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                '${_fmt(movement.quantityBefore)} → ${_fmt(movement.quantityAfter)}',
                style: TextStyle(
                  fontSize: 11,
                  color: context.hs.muted,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
