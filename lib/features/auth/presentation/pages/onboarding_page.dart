// Novo – não existe no React
// Wireframe: seção 01 (A hero minimal + B carrossel + C login)
import 'package:flutter/material.dart';
import 'package:homestock_mobile/shared/widgets/hs_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _steps = [
    _Step(
      eyebrow: 'PASSO 01',
      title: 'Escaneou a nota,\nestoque atualizado.',
      body:
          'Aponte para o QR da NFC-e e a gente cuida do resto. Nada de digitar item por item.',
      icon: Icons.qr_code_scanner,
    ),
    _Step(
      eyebrow: 'PASSO 02',
      title: 'Confirme.',
      body: 'Revise os itens em massa e ajuste o que precisar antes de salvar.',
      icon: Icons.checklist_rounded,
    ),
    _Step(
      eyebrow: 'PASSO 03',
      title: 'Acompanhe.',
      body:
          'Métricas, alertas de validade e estoque baixo — tudo em um só lugar.',
      icon: Icons.bar_chart_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  const BrandMark(),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Pular',
                      style: TextStyle(color: context.hs.text2),
                    ),
                  ),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _steps.length,
                itemBuilder: (_, i) => _StepView(step: _steps[i]),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (i) => _Dot(active: i == _page),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_page < _steps.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go('/login');
                      }
                    },
                    child: Text(
                      _page < _steps.length - 1 ? 'Continuar' : 'Começar',
                    ),
                  ),
                  if (_page == 0) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Já tenho conta',
                        style: TextStyle(
                          color: context.hs.text2,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step {
  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;

  const _Step({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
  });
}

class _StepView extends StatelessWidget {
  final _Step step;
  const _StepView({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.hs.primarySoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.hs.primaryLine),
            ),
            child: Center(
              child: Icon(step.icon, size: 80, color: context.hs.primary),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            step.eyebrow,
            style: TextStyle(
              color: context.hs.muted,
              fontSize: 11,
              letterSpacing: 1.6,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            step.body,
            style: TextStyle(
              fontSize: 15,
              color: context.hs.text2,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: active ? 22 : 7,
      height: 7,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: active ? context.hs.primary : context.hs.surface2,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
