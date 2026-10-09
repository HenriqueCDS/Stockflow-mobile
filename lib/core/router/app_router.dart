// Migrado de: src/App.jsx (Routes) + src/components/Navbar.jsx
// React Router v6 → go_router ShellRoute
// Barra inferior (HomeStock.pdf): Início · Estoque · SCAN NFC-E · Lista · Casa
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/user_settings_page.dart';
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
import '../../features/house/presentation/pages/house_page.dart';
import '../../features/shopping_list/presentation/pages/shopping_list_page.dart';
import '../theme/hs_colors.dart';

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
      final isPublic = path.startsWith('/onboarding') ||
          path.startsWith('/login') ||
          path.startsWith('/register');

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
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      // Camera em tela cheia – fora do shell para não mostrar bottom nav
      GoRoute(
        path: '/scan/camera',
        builder: (_, state) => CameraScanPage(
          showTutorial: state.uri.queryParameters['tutorial'] == 'true',
        ),
      ),
      GoRoute(path: '/alerts', builder: (_, __) => const AlertsPage()),
      GoRoute(
        path: '/user',
        builder: (_, __) => const UserSettingsPage(),
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
          GoRoute(
              path: '/scan', builder: (_, __) => const ScannerLandingPage()),
          GoRoute(path: '/house', builder: (_, __) => const HousePage()),
          GoRoute(
            path: '/shopping-list',
            builder: (_, __) => const ShoppingListPage(),
          ),
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
    if (currentPath.startsWith('/shopping-list')) return 3;
    if (currentPath.startsWith('/house')) return 4;
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
              context.go('/shopping-list');
            case 4:
              context.go('/house');
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
    final hs = context.hs;
    return Container(
      decoration: BoxDecoration(
        color: hs.surface,
        border: Border(top: BorderSide(color: hs.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _NavTab(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
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
              Expanded(child: _ScanButton(onTap: () => onTap(2))),
              _NavTab(
                icon: Icons.checklist_rounded,
                activeIcon: Icons.checklist_rounded,
                label: 'Lista',
                index: 3,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavTab(
                icon: Icons.house_outlined,
                activeIcon: Icons.house_rounded,
                label: 'Casa',
                index: 4,
                current: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão central laranja do scanner NFC-e.
class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    return Semantics(
      button: true,
      label: 'Escanear NFC-e',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: hs.primary,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: hs.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.qr_code_scanner,
                color: hs.onPrimary,
                size: 24,
              ),
            ),
          ],
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
    final color = active ? context.hs.text : context.hs.muted;
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        child: InkWell(
          onTap: () => onTap(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(active ? activeIcon : icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
