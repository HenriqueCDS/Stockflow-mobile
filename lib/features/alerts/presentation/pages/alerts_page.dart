// Wireframe 04-C: urgency view — lista de alertas agrupada por severidade
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import 'package:homestock_mobile/shared/widgets/empty_state_widget.dart';
import 'package:homestock_mobile/shared/widgets/error_state_widget.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alert_list_tile.dart';
import '../../domain/entities/alert_entity.dart';

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Lista de Compras',
            onPressed: () => context.push('/shopping-list'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(alertsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const AppLoadingIndicator(text: 'Carregando alertas…'),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.read(alertsProvider.notifier).refresh(),
        ),
        data: (alerts) {
          if (alerts.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.check_circle_outline,
              title: 'Tudo em ordem!',
              subtitle: 'Nenhum alerta de estoque ou validade no momento.',
            );
          }

          final critical =
              alerts.where((a) => a.severity == AlertSeverity.critical).toList();
          final warning =
              alerts.where((a) => a.severity == AlertSeverity.warning).toList();

          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref.read(alertsProvider.notifier).refresh(),
            child: ListView(
              children: [
                if (critical.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Críticos',
                    count: critical.length,
                    color: AppColors.danger,
                  ),
                  ...critical.map((a) => Column(
                        children: [
                          AlertListTile(alert: a),
                          const Divider(height: 1, indent: 72),
                        ],
                      )),
                ],
                if (warning.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Atenção',
                    count: warning.length,
                    color: AppColors.warn,
                  ),
                  ...warning.map((a) => Column(
                        children: [
                          AlertListTile(alert: a),
                          const Divider(height: 1, indent: 72),
                        ],
                      )),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
