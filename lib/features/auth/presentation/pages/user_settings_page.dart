// Casa › Usuário / Configurações: editar o nome (PUT /users/me).
// E-mail, perfil de acesso e senha não são alterados por este endpoint.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/hs_ui.dart';
import '../providers/auth_provider.dart';

class UserSettingsPage extends ConsumerStatefulWidget {
  const UserSettingsPage({super.key});

  @override
  ConsumerState<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends ConsumerState<UserSettingsPage> {
  static const _maxName = 100;

  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(
    text: ref.read(authStateProvider).valueOrNull?.user?.name ?? '',
  );
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await ref
          .read(authStateProvider.notifier)
          .updateName(_nameCtrl.text.trim());
      if (mounted) context.showSuccess('Nome atualizado!');
    } catch (e) {
      if (mounted) context.showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final user = ref.watch(authStateProvider).valueOrNull?.user;
    final name = (user?.name ?? '').trim();
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/house'),
        ),
        title: const Text('Usuário'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Row(
            children: [
              InitialsAvatar(name: name.isEmpty ? '?' : name, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Seu perfil' : name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: hs.text,
                      ),
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: hs.muted),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const SectionLabel('Nome'),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  maxLength: _maxName,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe seu nome'
                      : null,
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: hs.onPrimary,
                          ),
                        )
                      : const Text('Salvar nome'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
