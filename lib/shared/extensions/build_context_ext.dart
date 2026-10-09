import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:homestock_mobile/core/theme/hs_colors.dart';

extension AppSnackBar on BuildContext {
  void showSuccess(String message) =>
      _show(message, hs.good, Icons.check_circle_outline);
  void showError(String message) => _show(message, hs.bad, Icons.error_outline);
  void showInfo(String message) =>
      _show(message, hs.primary, Icons.info_outline);

  void _show(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: TextStyle(color: hs.text)),
            ),
          ],
        ),
        backgroundColor: hs.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: hs.border),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

final _brl = intl.NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

extension CurrencyFormat on num {
  String toBRL() {
    return _brl.format(this);
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
