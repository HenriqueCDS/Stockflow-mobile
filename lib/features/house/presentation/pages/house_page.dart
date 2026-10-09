// Novo – feature "Minha casa": dados da casa, código de convite e membros.
// Ações restritas a OWNER (remover membro, rotacionar código) só aparecem se
// UserEntity.role == 'OWNER' (role já é guardado no login, sem chamada extra).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import 'package:homestock_mobile/shared/widgets/confirm_bottom_sheet.dart';
import 'package:homestock_mobile/shared/widgets/error_state_widget.dart';
import 'package:homestock_mobile/core/theme/theme_mode_provider.dart';
import 'package:homestock_mobile/shared/widgets/hs_ui.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../providers/house_provider.dart';

class HousePage extends ConsumerWidget {
  const HousePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(houseProvider);
    final isOwner =
        ref.watch(authStateProvider).valueOrNull?.user?.role == 'OWNER';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageTitle(title: 'Casa'),
            Expanded(child: _body(context, ref, state, isOwner)),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<HouseState> state,
    bool isOwner,
  ) {
    final user = ref.watch(authStateProvider).valueOrNull?.user;
    return state.when(
      loading: () => const AppLoadingIndicator(text: 'Carregando casa…'),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.read(houseProvider.notifier).refresh(),
      ),
      data: (house) => RefreshIndicator(
        onRefresh: () => ref.read(houseProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _UserButton(
              name: user?.name,
              email: user?.email,
              onTap: () => context.push('/user'),
            ),
            const SizedBox(height: 28),
            const SectionLabel('Aparência'),
            const SizedBox(height: 10),
            const _ThemeModeSelector(),
            const SizedBox(height: 28),
            const SectionLabel('Dados da casa'),
            const SizedBox(height: 12),
            _CompanyForm(
              company: house.company,
              onSave: (data) async {
                try {
                  await ref.read(houseProvider.notifier).updateCompany(data);
                  if (context.mounted) {
                    context.showSuccess('Dados da casa atualizados!');
                  }
                } catch (e) {
                  if (context.mounted) context.showError(e.toString());
                }
              },
            ),
            const SizedBox(height: 24),
            _InviteCodeCard(
              inviteCode: house.company.inviteCode,
              isOwner: isOwner,
              onRotate: () async {
                final confirmed = await showConfirmBottomSheet(
                  context: context,
                  title: 'Gerar novo código?',
                  message:
                      'O código atual deixará de funcionar. Quem ainda não entrou na casa precisará do novo código.',
                  confirmLabel: 'Sim, gerar novo',
                );
                if (!confirmed) return;
                try {
                  await ref.read(houseProvider.notifier).rotateInviteCode();
                  if (context.mounted) {
                    context.showSuccess('Novo código gerado!');
                  }
                } catch (e) {
                  if (context.mounted) context.showError(e.toString());
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              'MEMBROS',
              style: TextStyle(
                color: context.hs.muted,
                fontSize: 10,
                letterSpacing: 1.4,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 10),
            ...house.members.map(
              (m) => _MemberTile(
                member: m,
                index: house.members.indexOf(m),
                canRemove: isOwner && !m.isOwner,
                onRemove: () async {
                  final confirmed = await showConfirmBottomSheet(
                    context: context,
                    title: 'Remover membro?',
                    message:
                        '"${m.name}" perderá acesso a esta casa imediatamente.',
                    confirmLabel: 'Sim, remover',
                    danger: true,
                  );
                  if (!confirmed) return;
                  try {
                    await ref.read(houseProvider.notifier).removeMember(m.id);
                    if (context.mounted) {
                      context.showSuccess('"${m.name}" removido.');
                    }
                  } catch (e) {
                    if (context.mounted) context.showError(e.toString());
                  }
                },
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showConfirmBottomSheet(
                  context: context,
                  title: 'Sair da conta?',
                  message: 'Você precisará entrar de novo para ver esta casa.',
                  confirmLabel: 'Sair',
                  danger: true,
                );
                if (confirmed) {
                  await ref.read(authStateProvider.notifier).logout();
                }
              },
              icon: Icon(Icons.logout_rounded, color: context.hs.bad),
              label: Text('Sair', style: TextStyle(color: context.hs.bad)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Casa › botão "Usuário · Configurações" (abre a edição de nome e senha).
class _UserButton extends StatelessWidget {
  final String? name;
  final String? email;
  final VoidCallback onTap;

  const _UserButton({this.name, this.email, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final hasName = (name ?? '').trim().isNotEmpty;
    final subtitle = (email ?? '').isNotEmpty ? email! : 'Editar nome';
    return Semantics(
      button: true,
      label: 'Usuário, configurações',
      child: HsCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            InitialsAvatar(name: hasName ? name! : '?', size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasName ? name! : 'Usuário',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: hs.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: hs.muted),
                  ),
                ],
              ),
            ),
            Text(
              'Configurações',
              style: TextStyle(fontSize: 13, color: hs.text2),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: hs.muted),
          ],
        ),
      ),
    );
  }
}

/// Casa › Aparência: Sistema / Claro / Escuro (persistido).
class _ThemeModeSelector extends ConsumerWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto_outlined, size: 18),
            label: Text('Sistema'),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode_outlined, size: 18),
            label: Text('Claro'),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined, size: 18),
            label: Text('Escuro'),
          ),
        ],
        selected: {ref.watch(themeModeProvider)},
        onSelectionChanged: (s) =>
            ref.read(themeModeProvider.notifier).set(s.first),
      ),
    );
  }
}

class _CompanyForm extends StatefulWidget {
  final CompanyEntity company;
  final void Function(Map<String, dynamic> data) onSave;

  const _CompanyForm({required this.company, required this.onSave});

  @override
  State<_CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends State<_CompanyForm> {
  late final _nameCtrl = TextEditingController(text: widget.company.name);
  late final _emailCtrl =
      TextEditingController(text: widget.company.email ?? '');
  late final _phoneCtrl =
      TextEditingController(text: widget.company.phone ?? '');
  late final _addressCtrl =
      TextEditingController(text: widget.company.address ?? '');
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _addressCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    widget.onSave({
      'name': _nameCtrl.text.trim(),
      if (_emailCtrl.text.trim().isNotEmpty) 'email': _emailCtrl.text.trim(),
      if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
      if (_addressCtrl.text.trim().isNotEmpty)
        'address': _addressCtrl.text.trim(),
    });
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Nome da casa'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'E-mail'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Telefone'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressCtrl,
          decoration: const InputDecoration(labelText: 'Endereço'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.hs.onPrimary,
                  ),
                )
              : const Text('Salvar alterações'),
        ),
      ],
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  final String inviteCode;
  final bool isOwner;
  final VoidCallback onRotate;

  const _InviteCodeCard({
    required this.inviteCode,
    required this.isOwner,
    required this.onRotate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.hs.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.hs.primaryLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CÓDIGO DE CONVITE',
            style: TextStyle(
              color: context.hs.muted,
              fontSize: 10,
              letterSpacing: 1.4,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  inviteCode,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: context.hs.primary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy_rounded, color: context.hs.primary),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: inviteCode));
                  if (context.mounted) {
                    context.showSuccess('Código copiado!');
                  }
                },
              ),
            ],
          ),
          Text(
            'Compartilhe este código para que alguém entre na sua casa.',
            style: TextStyle(fontSize: 12, color: context.hs.text2),
          ),
          if (isOwner) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRotate,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Gerar novo código'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MemberEntity member;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;

  const _MemberTile({
    required this.member,
    required this.index,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          InitialsAvatar(name: member.name, index: index, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(member.email,
                    style: TextStyle(fontSize: 12, color: context.hs.muted)),
              ],
            ),
          ),
          StatusBadge(
            label: member.isOwner ? 'Dono' : 'Membro',
            color: member.isOwner ? context.hs.primaryInk : context.hs.text2,
          ),
          if (canRemove)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: context.hs.bad),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
