// Migrado de: src/App.jsx (Routes) + src/components/Navbar.jsx
// React Router v6 → go_router ShellRoute
// Sidebar fixa web → BottomNavigationBar + FAB central (wireframe)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/stock/presentation/pages/stock_page.dart';
import '../../features/stock/presentation/pages/product_form_page.dart';
import '../../features/movements/presentation/pages/stock_entry_page.dart';
import '../../features/movements/presentation/pages/stock_exit_page.dart';
import '../../features/movements/presentation/pages/history_page.dart';
import '../../features/scanner/presentation/pages/scanner_landing_page.dart';
import '../../features/scanner/presentation/pages/camera_scan_page.dart';
import '../../features/alerts/presentation/pages/alerts_page.dart';
import '../theme/app_colors.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(false);

  ref.listen<AsyncValue<AuthState>>(authStateProvider, (_, next) {
    authNotifier.value = next.valueOrNull?.isAuthenticated ?? false;
  });

  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.value;
      final path = state.uri.path;
      final isPublic =
          path.startsWith('/onboarding') || path.startsWith('/login');

      if (!isLoggedIn && !isPublic) return '/login';
      if (isLoggedIn && isPublic) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      // Camera em tela cheia – fora do shell para não mostrar bottom nav
      GoRoute(
        path: '/scan/camera',
        builder: (_, state) => CameraScanPage(
          showTutorial: state.uri.queryParameters['tutorial'] == 'true',
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const DashboardPage()),
          GoRoute(
            path: '/stock',
            builder: (_, __) => const StockPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const ProductFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (_, s) =>
                    ProductFormPage(productId: s.pathParameters['id']),
              ),
              GoRoute(
                path: 'entry',
                builder: (_, __) => const StockEntryPage(),
              ),
              GoRoute(
                path: 'exit',
                builder: (_, __) => const StockExitPage(),
              ),
              GoRoute(
                path: 'history',
                builder: (_, __) => const HistoryPage(),
              ),
            ],
          ),
          GoRoute(path: '/scan', builder: (_, __) => const ScannerLandingPage()),
          GoRoute(path: '/alerts', builder: (_, __) => const AlertsPage()),
        ],
      ),
    ],
  );
});

// ─── Main Shell (BottomNav + FAB) ────────────────────────────────────────────

class MainShell extends StatelessWidget {
  final String currentPath;
  final Widget child;

  const MainShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  int get _currentIndex {
    if (currentPath.startsWith('/stock')) return 1;
    if (currentPath.startsWith('/scan')) return 2;
    if (currentPath.startsWith('/alerts')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/stock');
            case 2:
              context.push('/scan/camera');
            case 3:
              context.go('/alerts');
          }
        },
      ),
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _AppBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavTab(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Início',
                index: 0,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavTab(
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'Estoque',
                index: 1,
                current: currentIndex,
                onTap: onTap,
              ),
              // FAB central (wireframe: "SCAN NFC-E")
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner,
                          color: Color(0xFF0A0A0A),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _NavTab(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Alertas',
                index: 3,
                current: currentIndex,
                onTap: onTap,
              ),
              // "Você" placeholder (perfil – fora do escopo MVP)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline,
                        size: 22, color: AppColors.textTertiary),
                    const SizedBox(height: 2),
                    const Text(
                      'Você',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
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

class _NavTab extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              size: 22,
              color: active ? AppColors.textPrimary : AppColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color:
                    active ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
