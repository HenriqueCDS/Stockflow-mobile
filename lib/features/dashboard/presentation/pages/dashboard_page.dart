// Migrado de: src/pages/Dashboard.jsx + src/pages/Reports.jsx
// Padrão: useState/useEffect local → ref.watch(dashboardProvider)
// Wireframe: seção 02 (A hero scan + B stats grid + C timeline)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import 'package:homestock_mobile/shared/widgets/error_state_widget.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/expiring_alert_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Olá 👋',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Meu Estoque',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.line),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Quick Action: Scanner ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                  child: GestureDetector(
                    onTap: () => context.push('/scan/camera'),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accentLine,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              color: Color(0xFF0A0A0A),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Escanear NFC-e',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Atualize o estoque em segundos',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Stats / Content ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: state.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: AppLoadingIndicator(text: 'Carregando informações…'),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: ErrorStateWidget(
                      message: e.toString(),
                      onRetry: () =>
                          ref.read(dashboardProvider.notifier).refresh(),
                    ),
                  ),
                  data: (report) => Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Valor total destaque
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1e293b), Color(0xFF334155)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'VALOR TOTAL DO ESTOQUE',
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 10,
                                  letterSpacing: 1.4,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                report.totalStockValue.toBRL(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Stats grid 4
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.6,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            StatCardWidget(
                              label: 'Total de produtos',
                              value: '${report.totalProducts}',
                              highlighted: true,
                              valueColor: AppColors.accent,
                            ),
                            StatCardWidget(
                              label: 'Produtos ativos',
                              value: '${report.activeProducts}',
                              valueColor: AppColors.good,
                            ),
                            StatCardWidget(
                              label: 'Estoque baixo',
                              value: '${report.productsWithLowStock}',
                              valueColor: AppColors.warn,
                            ),
                            StatCardWidget(
                              label: 'Sem estoque',
                              value: '${report.productsOutOfStock}',
                              valueColor: AppColors.danger,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Alertas de estoque baixo
                        if (report.lowStockProducts.isNotEmpty)
                          LowStockAlertCard(
                            title: 'ESTOQUE BAIXO',
                            products: report.lowStockProducts,
                            color: AppColors.warn,
                            bgColor: const Color(0x0AFAC775),
                            icon: Icons.warning_amber_rounded,
                            onViewAll: () => context.go('/alerts'),
                          ),

                        if (report.outOfStockProducts.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          LowStockAlertCard(
                            title: 'SEM ESTOQUE',
                            products: report.outOfStockProducts,
                            color: AppColors.danger,
                            bgColor: const Color(0x0AEF4F4F),
                            icon: Icons.trending_down_rounded,
                            onViewAll: () => context.go('/alerts'),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Ações rápidas
                        const Text(
                          'AÇÕES RÁPIDAS',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_box_outlined, 'Dar Entrada', AppColors.good, '/stock/entry'),
      (Icons.remove_circle_outline, 'Registrar Saída', AppColors.danger,
          '/stock/exit'),
      (Icons.inventory_2_outlined, 'Produtos', AppColors.accent, '/stock'),
      (Icons.history, 'Histórico', AppColors.textSecondary, '/stock/history'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions
          .map(
            (a) => GestureDetector(
              onTap: () => context.push(a.$4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Icon(a.$1, size: 20, color: a.$3),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        a.$2,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
