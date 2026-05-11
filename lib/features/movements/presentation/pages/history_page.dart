// Migrado de: src/pages/History.jsx
// Tabela com filtro de tipo → ListView com FilterChips e pull-to-refresh
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import 'package:homestock_mobile/shared/widgets/empty_state_widget.dart';
import 'package:homestock_mobile/shared/widgets/error_state_widget.dart';
import '../providers/movements_provider.dart';
import '../widgets/movement_list_tile.dart';
import '../../domain/entities/movement_entity.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(selectedMovementFilterProvider);
    final state = ref.watch(movementsProvider(filter));

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Movimentações')),
      body: Column(
        children: [
          // ── Filtros ──────────────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _FilterChip(label: 'Todos', value: null, current: filter, ref: ref),
                _FilterChip(label: 'Entradas', value: MovementType.entry, current: filter, ref: ref),
                _FilterChip(label: 'Saídas', value: MovementType.exit, current: filter, ref: ref),
                _FilterChip(label: 'Ajustes', value: MovementType.adjustment, current: filter, ref: ref),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: state.when(
              loading: () => const AppLoadingIndicator(text: 'Carregando…'),
              error: (e, _) => ErrorStateWidget(
                message: e.toString(),
                onRetry: () =>
                    ref.read(movementsProvider(filter).notifier).refresh(),
              ),
              data: (movements) => movements.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.history,
                      title: 'Nenhuma movimentação encontrada',
                    )
                  : RefreshIndicator(
                      color: AppColors.accent,
                      backgroundColor: AppColors.surface,
                      onRefresh: () => ref
                          .read(movementsProvider(filter).notifier)
                          .refresh(),
                      child: ListView.separated(
                        itemCount: movements.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 70),
                        itemBuilder: (_, i) =>
                            MovementListTile(movement: movements[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final MovementType? value;
  final MovementType? current;
  final WidgetRef ref;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.current,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () =>
            ref.read(selectedMovementFilterProvider.notifier).state = value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? AppColors.accent : AppColors.line2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF0A0A0A) : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
