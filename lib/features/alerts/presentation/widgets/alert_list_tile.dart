import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import '../../domain/entities/alert_entity.dart';

class AlertListTile extends StatelessWidget {
  final AlertEntity alert;
  const AlertListTile({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (alert.type) {
      AlertType.outOfStock => (AppColors.danger, Icons.remove_shopping_cart_outlined),
      AlertType.lowStock => (AppColors.warn, Icons.inventory_2_outlined),
      AlertType.nearExpiry => (AppColors.warn, Icons.event_busy_outlined),
      AlertType.expired => (AppColors.danger, Icons.dangerous_outlined),
    };

    final severityDot = switch (alert.severity) {
      AlertSeverity.critical => AppColors.danger,
      AlertSeverity.warning => AppColors.warn,
      AlertSeverity.info => AppColors.accent,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.productName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: severityDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  alert.title,
                  style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  alert.subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
