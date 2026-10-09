// Item de notificação (HomeStock.pdf · Notificações): ponto na cor do status,
// frase curta, detalhe monoespaçado e ação "Ver".
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import '../../domain/entities/alert_entity.dart';

class AlertListTile extends StatelessWidget {
  final AlertEntity alert;
  final VoidCallback? onView;

  const AlertListTile({super.key, required this.alert, this.onView});

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final (color, headline) = switch (alert.type) {
      AlertType.outOfStock => (hs.bad, '${alert.productName} acabou'),
      AlertType.lowStock => (hs.bad, '${alert.productName} está acabando'),
      AlertType.nearExpiry => (hs.warn, '${alert.productName} vence logo'),
      AlertType.expired => (hs.bad, '${alert.productName} venceu'),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: hs.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: hs.muted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          if (onView != null) ...[
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: onView,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 34),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: const StadiumBorder(),
                backgroundColor: hs.surface2,
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              child: const Text('Ver'),
            ),
          ],
        ],
      ),
    );
  }
}
