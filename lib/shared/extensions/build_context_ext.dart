import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';

extension AppSnackBar on BuildContext {
  void showSuccess(String message) => _show(message, AppColors.good);
  void showError(String message) => _show(message, AppColors.danger);
  void showInfo(String message) => _show(message, AppColors.accent);

  void _show(String message, Color color) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color.withOpacity(0.15),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

extension CurrencyFormat on num {
  String toBRL() {
    return 'R\$ ${toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

extension DateFormat on String {
  String toLocaleDateTimePtBR() {
    try {
      final dt = DateTime.parse(this).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year;
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$d/$m/$y $h:$min';
    } catch (_) {
      return this;
    }
  }
}
