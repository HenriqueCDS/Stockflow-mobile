// Novo – registro/criação de conta (pivot casa/família: sem CNPJ).
// Dois modos: criar casa nova (POST /auth/register) ou entrar com código de
// convite de uma casa existente (POST /auth/join). Mesmo visual de login_page.dart.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _createFormKey = GlobalKey<FormState>();
  final _createNameCtrl = TextEditingController();
  final _createEmailCtrl = TextEditingController();
  final _createPasswordCtrl = TextEditingController();
  final _createHouseNameCtrl = TextEditingController();

  final _joinFormKey = GlobalKey<FormState>();
  final _joinNameCtrl = TextEditingController();
  final _joinEmailCtrl = TextEditingController();
  final _joinPasswordCtrl = TextEditingController();
  final _joinInviteCodeCtrl = TextEditingController();

  bool _obscureCreate = true;
  bool _obscureJoin = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [
      _createNameCtrl,
      _createEmailCtrl,
      _createPasswordCtrl,
      _createHouseNameCtrl,
      _joinNameCtrl,
      _joinEmailCtrl,
      _joinPasswordCtrl,
      _joinInviteCodeCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submitCreate() async {
    if (!_createFormKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).register(
          name: _createNameCtrl.text.trim(),
          email: _createEmailCtrl.text.trim(),
          password: _createPasswordCtrl.text,
          houseName: _createHouseNameCtrl.text.trim(),
        );
    if (!mounted) return;
    final s = ref.read(authStateProvider);
    if (s.hasError) context.showError(s.error.toString());
  }

  Future<void> _submitJoin() async {
    if (!_joinFormKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).join(
          name: _joinNameCtrl.text.trim(),
          email: _joinEmailCtrl.text.trim(),
          password: _joinPasswordCtrl.text,
          inviteCode: _joinInviteCodeCtrl.text.trim(),
        );
    if (!mounted) return;
    final s = ref.read(authStateProvider);
    if (s.hasError) context.showError(s.error.toString());
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 4, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CRIAR CONTA',
                    style: TextStyle(
                      color: context.hs.muted,
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Vamos começar.',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: TabBar(
                controller: _tabController,
                labelColor: context.hs.primary,
                unselectedLabelColor: context.hs.text2,
                indicatorColor: context.hs.primary,
                tabs: const [
                  Tab(text: 'Criar casa nova'),
                  Tab(text: 'Entrar com código'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCreateHouseForm(loading),
                  _buildJoinHouseForm(loading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateHouseForm(bool loading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _createFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _createNameCtrl,
              decoration: const InputDecoration(labelText: 'Seu nome'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _createEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _createPasswordCtrl,
              obscureText: _obscureCreate,
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCreate
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: context.hs.muted,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCreate = !_obscureCreate),
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _createHouseNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome da casa',
                hintText: 'Ex: Casa da Família Silva',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Dê um nome para a casa'
                  : null,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: loading ? null : _submitCreate,
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.hs.onPrimary,
                      ),
                    )
                  : const Text('Criar casa e conta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinHouseForm(bool loading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _joinFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _joinNameCtrl,
              decoration: const InputDecoration(labelText: 'Seu nome'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _joinEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _joinPasswordCtrl,
              obscureText: _obscureJoin,
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureJoin
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: context.hs.muted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureJoin = !_obscureJoin),
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _joinInviteCodeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Código de convite',
                hintText: 'Peça para quem já mora na casa',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe o código de convite'
                  : null,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: loading ? null : _submitJoin,
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.hs.onPrimary,
                      ),
                    )
                  : const Text('Entrar na casa'),
            ),
          ],
        ),
      ),
    );
  }
}
