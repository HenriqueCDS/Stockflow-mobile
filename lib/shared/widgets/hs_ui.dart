// Blocos visuais repetidos nas telas do HomeStock (HomeStock.pdf · seção 5):
// título grande, rótulo de seção monoespaçado, pílula de filtro, card e avatar.
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';

/// Logo do HomeStock (assets/images) + nome, usado em onboarding e login.
class BrandMark extends StatelessWidget {
  final double size;
  final double fontSize;

  const BrandMark({super.key, this.size = 28, this.fontSize = 15});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/homestock-logo.png',
          width: size,
          height: size,
          filterQuality: FilterQuality.medium,
          semanticLabel: 'Logo HomeStock',
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'HomeStock',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: fontSize,
              color: context.hs.text,
            ),
          ),
        ),
      ],
    );
  }
}

/// Título de página grande ("Estoque", "Lista de compras") com ação à direita.
class PageTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const PageTitle({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: context.hs.text,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Rótulo de seção em caixa alta e monoespaçado ("VENCE LOGO", "LOCAIS").
class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final Widget? trailing;

  const SectionLabel(this.text, {super.key, this.color, this.trailing});

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color ?? context.hs.muted,
        fontSize: 11,
        letterSpacing: 1.6,
        fontWeight: FontWeight.w600,
        fontFamily: 'monospace',
      ),
    );
    if (trailing == null) return label;
    return Row(children: [Expanded(child: label), trailing!]);
  }
}

/// Pílula de filtro: ativa em primarySoft + texto laranja, inativa em surface2.
class FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const FilterPill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    return Material(
      color: active ? hs.primarySoft : hs.surface2,
      shape: StadiumBorder(
        side: BorderSide(color: active ? hs.primaryLine : hs.border),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? hs.primaryInk : hs.text2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Linha horizontal rolável de [FilterPill].
class FilterPillBar extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  final EdgeInsetsGeometry padding;

  const FilterPillBar({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => FilterPill(
          label: labels[i],
          active: i == selected,
          onTap: () => onSelected(i),
        ),
      ),
    );
  }
}

/// Card padrão: surface + borda fina, sem sombra. [highlighted] usa o laranja.
class HsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;
  final VoidCallback? onTap;

  const HsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final radius = BorderRadius.circular(14);
    return Material(
      color: highlighted ? hs.primarySoft : hs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: highlighted ? hs.primaryLine : hs.border),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Badge de status: fundo a 14% da cor, texto na cor cheia.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: HsColors.soft(color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Avatar com a inicial do nome, em fundo suave da cor do membro.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final int index;
  final double size;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.index = 0,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    final hs = context.hs;
    final palette = [hs.primary, hs.good, hs.warn, hs.text2];
    final color = palette[index % palette.length];
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.alphaBlend(HsColors.soft(color), hs.bg),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// Pilha de avatares sobrepostos (membros da casa no cabeçalho do dashboard).
class AvatarStack extends StatelessWidget {
  final List<String> names;
  final int max;

  const AvatarStack({super.key, required this.names, this.max = 3});

  @override
  Widget build(BuildContext context) {
    const size = 30.0;
    const step = 20.0;
    final shown = names.take(max).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: size + step * (shown.length - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: step * i,
              child: InitialsAvatar(name: shown[i], index: i, size: size),
            ),
        ],
      ),
    );
  }
}
