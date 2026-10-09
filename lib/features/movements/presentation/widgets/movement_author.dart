// Quem fez a movimentação. A API devolve só `createdBy` (texto livre: pode ser o
// id, o e-mail ou o nome); cruzamos com os membros da casa para mostrar o nome.
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';
import 'package:homestock_mobile/shared/extensions/build_context_ext.dart';
import 'package:homestock_mobile/shared/widgets/hs_ui.dart';
import '../../../house/domain/entities/member_entity.dart';
import '../../domain/entities/movement_entity.dart';

class MovementAuthor {
  /// Nome a exibir ("Rafael") ou null quando a API não informa o autor.
  final String? name;

  /// Posição do membro na casa (mesma cor do avatar no dashboard); 0 se desconhecido.
  final int index;

  const MovementAuthor(this.name, this.index);

  String get label => name ?? 'Alguém da casa';
}

final _idLike = RegExp(r'^[0-9a-fA-F-]{8,}$');

MovementAuthor authorOf(String? createdBy, List<MemberEntity> members) {
  final raw = createdBy?.trim() ?? '';
  if (raw.isEmpty) return const MovementAuthor(null, 0);

  final key = raw.toLowerCase();
  final i = members.indexWhere((m) =>
      m.id == raw ||
      m.email.toLowerCase() == key ||
      m.name.toLowerCase() == key);
  if (i >= 0) return MovementAuthor(members[i].name, i);

  // Id que não bate com nenhum membro (ex.: quem já saiu da casa): não mostra o código.
  if (_idLike.hasMatch(raw)) return const MovementAuthor(null, 0);
  return MovementAuthor(raw.contains('@') ? raw.split('@').first : raw, 0);
}

/// Verbo no passado para a frase "Rafael deu entrada em Arroz".
String movementVerb(MovementType t) => switch (t) {
      MovementType.entry => 'deu entrada em',
      MovementType.used => 'usou',
      MovementType.discarded => 'descartou',
      MovementType.exit => 'deu saída em',
      MovementType.adjustment => 'ajustou',
      MovementType.returnType => 'devolveu',
    };

String movementLabel(MovementType t) => switch (t) {
      MovementType.entry => 'Entrada',
      MovementType.used => 'Usado',
      MovementType.discarded => 'Descartado',
      MovementType.exit => 'Saída',
      MovementType.adjustment => 'Ajuste',
      MovementType.returnType => 'Devolução',
    };

bool movementReducesStock(MovementType t) =>
    t == MovementType.exit ||
    t == MovementType.used ||
    t == MovementType.discarded;

Color movementColor(BuildContext context, MovementType t) {
  final hs = context.hs;
  return switch (t) {
    MovementType.entry => hs.good,
    MovementType.used || MovementType.exit || MovementType.discarded => hs.bad,
    MovementType.adjustment || MovementType.returnType => hs.primaryInk,
  };
}

String fmtQty(double v) =>
    v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(3);

/// Folha com todos os detalhes de uma movimentação, incluindo quem a fez.
Future<void> showMovementDetailSheet(
  BuildContext context, {
  required MovementEntity movement,
  required MovementAuthor author,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _MovementDetailSheet(movement: movement, author: author),
  );
}

class _MovementDetailSheet extends StatelessWidget {
  final MovementEntity movement;
  final MovementAuthor author;

  const _MovementDetailSheet({required this.movement, required this.author});

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final m = movement;
    final color = movementColor(context, m.type);
    final sign = movementReducesStock(m.type) ? '−' : '+';
    final hasReason = (m.reason ?? '').trim().isNotEmpty;
    final hasRef = (m.reference ?? '').trim().isNotEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(
                  name: author.name ?? '?',
                  index: author.index,
                  size: 44,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.label,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: hs.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${movementVerb(m.type)} ${m.productName}',
                        style: TextStyle(fontSize: 13, color: hs.text2),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: movementLabel(m.type), color: color),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: hs.border),
            _Row('Quantidade', '$sign${fmtQty(m.quantity)}', valueColor: color),
            _Row(
              'Estoque',
              '${fmtQty(m.quantityBefore)} → ${fmtQty(m.quantityAfter)}',
            ),
            _Row(
              'Quando',
              m.movementDate.isEmpty
                  ? '—'
                  : m.movementDate.toLocaleDateTimePtBR(),
            ),
            _Row('Feito por', author.label),
            if (hasReason) _Row('Motivo', m.reason!.trim()),
            if (hasRef) _Row('Referência', m.reference!.trim()),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(label, style: TextStyle(fontSize: 13, color: hs.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? hs.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
