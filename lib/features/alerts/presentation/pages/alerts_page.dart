// Notificações (HomeStock.pdf): aberta pelo sino do dashboard, fora da barra
// inferior. Filtro por tipo e agrupamento por severidade.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import 'package:homestock_mobile/shared/widgets/empty_state_widget.dart';
import 'package:homestock_mobile/shared/widgets/error_state_widget.dart';
import 'package:homestock_mobile/shared/widgets/hs_ui.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alert_list_tile.dart';
import '../../domain/entities/alert_entity.dart';

class AlertsPage extends ConsumerStatefulWidget {
  const AlertsPage({super.key});

  @override
  ConsumerState<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends ConsumerState<AlertsPage> {
  static const _filters = ['tudo', 'estoque', 'validade'];
  int _filter = 0;

  bool _matches(AlertEntity a) => switch (_filter) {
        1 => a.type == AlertType.outOfStock || a.type == AlertType.lowStock,
        2 => a.type == AlertType.nearExpiry || a.type == AlertType.expired,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertsProvider);
    final notifier = ref.read(alertsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Notificações'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: notifier.refresh,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          FilterPillBar(
            labels: _filters,
            selected: _filter,
            onSelected: (i) => setState(() => _filter = i),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.when(
              loading: () =>
                  const AppLoadingIndicator(text: 'Carregando notificações…'),
              error: (e, _) => ErrorStateWidget(
                message: e.toString(),
                onRetry: notifier.refresh,
              ),
              data: (all) {
                final alerts = all.where(_matches).toList();
                if (alerts.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.check_circle_outline,
                    title: 'Tudo em ordem!',
                    subtitle: 'Nenhum aviso de estoque ou validade agora.',
                  );
                }

                final groups = [
                  ('Críticos', AlertSeverity.critical),
                  ('Atenção', AlertSeverity.warning),
                  ('Outros', AlertSeverity.info),
                ];

                return RefreshIndicator(
                  onRefresh: notifier.refresh,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      for (final (label, severity) in groups)
                        ..._section(
                          label,
                          alerts.where((a) => a.severity == severity).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _section(String label, List<AlertEntity> alerts) {
    if (alerts.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 2),
        child: SectionLabel(label),
      ),
      for (var i = 0; i < alerts.length; i++) ...[
        if (i > 0) const Divider(height: 1, indent: 42, endIndent: 20),
        AlertListTile(
          alert: alerts[i],
          onView: () => context.push('/stock/${alerts[i].productId}/edit'),
        ),
      ],
    ];
  }
}
