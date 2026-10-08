// Novo – feature "Minha casa": dados da casa, código de convite e membros.
// Ações restritas a OWNER (remover membro, rotacionar código) só aparecem se
// UserEntity.role == 'OWNER' (role já é guardado no login, sem chamada extra).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/theme/app_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/app_loading_indicator.dart';
import 'package:homestock_mobile/shared/widgets/confirm_bottom_sheet.dart';
import 'package:homestock_mobile/shared/widgets/error_state_widget.dart';
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
      appBar: AppBar(title: const Text('Minha casa')),
      body: state.when(
        loading: () => const AppLoadingIndicator(text: 'Carregando casa…'),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.read(houseProvider.notifier).refresh(),
        ),
        data: (house) => RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          onRefresh: () => ref.read(houseProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
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
              const Text(
                'MEMBROS',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 10),
              ...house.members.map(
                (m) => _MemberTile(
                  member: m,
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
            ],
          ),
        ),
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
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0A0A0A),
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
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CÓDIGO DE CONVITE',
            style: TextStyle(
              color: AppColors.textTertiary,
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.accent,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: AppColors.accent),
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
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
  final bool canRemove;
  final VoidCallback onRemove;

  const _MemberTile({
    required this.member,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.surface2,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline,
                size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(member.email,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (member.isOwner ? AppColors.accent : AppColors.surface2)
                  .withOpacity(member.isOwner ? 0.15 : 1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              member.isOwner ? 'OWNER' : 'MEMBER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: member.isOwner
                    ? AppColors.accent
                    : AppColors.textSecondary,
              ),
            ),
          ),
          if (canRemove)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.danger),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
