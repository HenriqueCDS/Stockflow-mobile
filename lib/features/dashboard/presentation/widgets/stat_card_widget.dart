// Migrado de: src/pages/Dashboard.jsx (stat-card divs)
// Wireframe: seção 02-B stat-grid-4
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';

class StatCardWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool highlighted;

  const StatCardWidget({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.accentSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted ? AppColors.accentLine : AppColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 10,
              letterSpacing: 1.2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: valueColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
