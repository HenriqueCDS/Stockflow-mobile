// Migrado de: src/pages/Dashboard.jsx + src/pages/Reports.jsx
// Layout HomeStock.pdf · Dashboard: saudação + casa, gasto do mês / na lista,
// "acabando", locais (categorias) e atividade recente.
// O /dashboard só devolve contagens; listas vêm de stockProvider e
// shoppingListProvider (mesma fonte das outras abas).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import 'package:homestock_mobile/shared/widgets/error_state_widget.dart';
import 'package:homestock_mobile/shared/widgets/hs_ui.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../house/presentation/providers/house_provider.dart';
import '../../../movements/domain/entities/movement_entity.dart';
import '../../../movements/presentation/providers/movements_provider.dart';
import '../../../movements/presentation/widgets/movement_author.dart';
import '../../../shopping_list/presentation/providers/shopping_list_provider.dart';
import '../../../stock/domain/entities/product_entity.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final products = ref.watch(stockProvider).valueOrNull ?? [];
    final shopping = ref.watch(shoppingListProvider).valueOrNull ?? [];
    final house = ref.watch(houseProvider).valueOrNull;
    final members = house?.members ?? const [];
    final recent = [...?ref.watch(movementsProvider(null)).valueOrNull]
      ..sort((a, b) => b.movementDate.compareTo(a.movementDate));
    final user = ref.watch(authStateProvider).valueOrNull?.user;

    final firstName = (user?.name ?? '').trim().split(' ').first;
    final runningOut = products.where((p) => p.isRunningOut).toList()
      ..sort((a, b) => a.currentStock.compareTo(b.currentStock));
    final pending = shopping.where((i) => !i.checked).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => Future.wait([
            ref.read(dashboardProvider.notifier).refresh(),
            ref.refresh(stockProvider.future),
            ref.refresh(shoppingListProvider.future),
            ref.read(movementsProvider(null).notifier).refresh(),
          ]),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _Header(
                greeting: firstName.isEmpty ? 'Olá' : 'Oi, $firstName',
                houseName: house?.company.name ?? 'Minha casa',
                members: house?.members.map((m) => m.name).toList() ?? [],
                hasAlerts: runningOut.isNotEmpty,
              ),
              const SizedBox(height: 20),
              state.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: AppLoadingIndicator(text: 'Carregando informações…'),
                ),
                error: (e, _) => ErrorStateWidget(
                  message: e.toString(),
                  onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
                ),
                data: (dash) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Gasto no mês',
                              value: dash.monthlySpend.toBRL(),
                              caption: '${dash.totalInvoices} notas escaneadas',
                              highlighted: true,
                              onTap: () => context.push('/scan'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: 'Na lista',
                              value: '${pending.length}',
                              caption:
                                  '${pending.where((i) => i.isAutoSynced).length} adicionados auto',
                              onTap: () => context.go('/shopping-list'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (runningOut.isNotEmpty) ...[
                      _RunningOutCard(products: runningOut),
                      const SizedBox(height: 24),
                    ],
                    if (products.isNotEmpty) ...[
                      const SectionLabel('Locais'),
                      const SizedBox(height: 10),
                      _PlacesGrid(products: products),
                      const SizedBox(height: 24),
                    ],
                    const SectionLabel('Atalhos'),
                    const SizedBox(height: 10),
                    const _Shortcuts(),
                    if (recent.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const SectionLabel('Atividade'),
                      const SizedBox(height: 6),
                      ...recent.take(5).map((m) {
                        final author = authorOf(m.createdBy, members);
                        return _ActivityRow(
                          movement: m,
                          author: author,
                          onTap: () => showMovementDetailSheet(
                            context,
                            movement: m,
                            author: author,
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String greeting;
  final String houseName;
  final List<String> members;
  final bool hasAlerts;

  const _Header({
    required this.greeting,
    required this.houseName,
    required this.members,
    required this.hasAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: TextStyle(color: hs.muted, fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                houseName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hs.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/house'),
          child: AvatarStack(names: members),
        ),
        const SizedBox(width: 6),
        IconButton(
          tooltip: 'Notificações',
          onPressed: () => context.push('/alerts'),
          icon: Badge(
            isLabelVisible: hasAlerts,
            backgroundColor: hs.primary,
            smallSize: 8,
            child: Icon(Icons.notifications_none_rounded, color: hs.text),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final bool highlighted;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.caption,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    return HsCard(
      highlighted: highlighted,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: highlighted ? hs.primary : hs.text,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(caption, style: TextStyle(fontSize: 12, color: hs.text2)),
        ],
      ),
    );
  }
}

/// Card "Acabando" (equivalente ao "Vence logo" do PDF; a API não expõe validade).
class _RunningOutCard extends ConsumerWidget {
  final List<ProductEntity> products;

  const _RunningOutCard({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hs = context.hs;
    final shown = products.take(4).toList();
    return HsCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        children: [
          SectionLabel(
            'Acabando',
            color: hs.bad,
            trailing: Text(
              '${products.length} ${products.length == 1 ? 'item' : 'itens'}',
              style: TextStyle(fontSize: 12, color: hs.muted),
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < shown.length; i++) ...[
            Divider(height: 1, color: hs.border),
            InkWell(
              onTap: () => context.push('/stock/${shown[i].id}/edit'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shown[i].name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: hs.text),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            shown[i].categoryLabel,
                            style: TextStyle(fontSize: 12, color: hs.muted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      shown[i].isOutOfStock
                          ? 'acabou'
                          : '${shown[i].displayStock} ${shown[i].unit ?? 'un'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: hs.bad,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (products.length > shown.length) ...[
            Divider(height: 1, color: hs.border),
            TextButton(
              onPressed: () {
                ref.read(stockFilterProvider.notifier).state =
                    const StockFilterRunningOut();
                context.go('/stock');
              },
              child: const Text('Ver todos'),
            ),
          ] else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Grade "Locais": um card por categoria com total e quantos estão acabando.
class _PlacesGrid extends ConsumerWidget {
  final List<ProductEntity> products;

  const _PlacesGrid({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hs = context.hs;
    final groups = <String, List<ProductEntity>>{};
    for (final p in products) {
      groups.putIfAbsent(p.categoryLabel, () => []).add(p);
    }
    final entries = groups.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: entries.take(6).map((e) {
            final out = e.value.where((p) => p.isRunningOut).length;
            return SizedBox(
              width: w,
              child: HsCard(
                onTap: () {
                  ref.read(stockFilterProvider.notifier).state =
                      StockFilterCategory(e.key);
                  context.go('/stock');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: hs.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        '${e.value.length} ${e.value.length == 1 ? 'item' : 'itens'}',
                        if (out > 0) '$out acabando',
                      ].join(' · '),
                      style: TextStyle(fontSize: 12, color: hs.text2),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts();

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final items = [
      (Icons.add_box_outlined, 'Entrada', '/stock/entry'),
      (Icons.indeterminate_check_box_outlined, 'Saída', '/stock/exit'),
      (Icons.history_rounded, 'Histórico', '/stock/history'),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: HsCard(
              padding: const EdgeInsets.symmetric(vertical: 14),
              onTap: () => context.push(items[i].$3),
              child: Column(
                children: [
                  Icon(items[i].$1, size: 22, color: hs.text2),
                  const SizedBox(height: 6),
                  Text(
                    items[i].$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: hs.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Linha de atividade: "Rafael deu entrada em Arroz 5kg", detalhe e tempo.
/// Toque abre os detalhes completos da movimentação.
class _ActivityRow extends StatelessWidget {
  final MovementEntity movement;
  final MovementAuthor author;
  final VoidCallback onTap;

  const _ActivityRow({
    required this.movement,
    required this.author,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final m = movement;
    final color = movementColor(context, m.type);
    final sign = movementReducesStock(m.type) ? '−' : '+';
    final when = DateTime.tryParse(m.movementDate);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            InitialsAvatar(
              name: author.name ?? '?',
              index: author.index,
              size: 34,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: author.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: ' ${movementVerb(m.type)} '),
                        TextSpan(
                          text: m.productName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: hs.text),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${movementLabel(m.type)} · $sign${fmtQty(m.quantity)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            if (when != null) ...[
              const SizedBox(width: 8),
              Text(
                _relative(when),
                style: TextStyle(fontSize: 12, color: hs.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _relative(DateTime t) {
    final d = DateTime.now().difference(t.toLocal());
    if (d.inMinutes < 1) return 'agora';
    if (d.inHours < 1) return '${d.inMinutes}min';
    if (d.inDays < 1) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}
