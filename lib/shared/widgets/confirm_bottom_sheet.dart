// Migrado de: src/components/ConfirmModal.jsx
// Modal centrado no web → bottom sheet no mobile (padrão Material)
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';

Future<bool> showConfirmBottomSheet({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  bool danger = false,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ConfirmSheet(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      danger: danger,
    ),
  );
  return result ?? false;
}

class _ConfirmSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool danger;

  const _ConfirmSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.danger,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: danger
                      ? AppColors.danger.withOpacity(0.12)
                      : AppColors.warn.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: danger ? AppColors.danger : AppColors.warn,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        danger ? AppColors.danger : AppColors.accent,
                    foregroundColor: danger
                        ? Colors.white
                        : const Color(0xFF0A0A0A),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
