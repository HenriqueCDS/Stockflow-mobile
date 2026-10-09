// Tokens de cor do HomeStock (HomeStock-Guia-Temas.md · seção 1).
// Widgets usam sempre o token (context.hs.text, context.hs.bad…), nunca hex.
import 'package:flutter/material.dart';

@immutable
class HsColors extends ThemeExtension<HsColors> {
  const HsColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text,
    required this.text2,
    required this.muted,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.primaryLine,
    required this.primaryInk,
    required this.good,
    required this.warn,
    required this.bad,
  });

  /// Fundo da tela.
  final Color bg;

  /// Cards, barra inferior, bottom sheets.
  final Color surface;

  /// Campos, chips, linhas, thumbnails.
  final Color surface2;

  /// Divisores e contornos.
  final Color border;

  /// Texto principal.
  final Color text;

  /// Texto secundário.
  final Color text2;

  /// Legendas e placeholders.
  final Color muted;

  /// Laranja da marca: botão, FAB, item ativo.
  final Color primary;

  /// Texto/ícone sobre o laranja (nunca branco).
  final Color onPrimary;

  /// Fundo de destaque laranja (10% claro / 14% escuro).
  final Color primarySoft;

  /// Contorno de cards/chips em destaque.
  final Color primaryLine;

  /// Laranja para texto pequeno: #B84F00 no claro (contraste), #FF7A00 no escuro.
  final Color primaryInk;

  /// Normal, comprado.
  final Color good;

  /// Vencendo.
  final Color warn;

  /// Acabando, erro.
  final Color bad;

  static const _orange = Color(0xFFFF7A00);
  static const _onOrange = Color(0xFF1A0E00);

  static const light = HsColors(
    bg: Color(0xFFFAFAF7),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF4F4F0),
    border: Color(0xFFE5E5DE),
    text: Color(0xFF18181B),
    text2: Color(0xFF3F3F46),
    muted: Color(0xFF8B8B82),
    primary: _orange,
    onPrimary: _onOrange,
    primarySoft: Color(0x1AFF7A00),
    primaryLine: Color(0x66FF7A00),
    primaryInk: Color(0xFFB84F00),
    good: Color(0xFF16A34A),
    warn: Color(0xFFD97706),
    bad: Color(0xFFDC2626),
  );

  static const dark = HsColors(
    bg: Color(0xFF0E0E10),
    surface: Color(0xFF18181B),
    surface2: Color(0xFF1F1F23),
    border: Color(0xFF2A2A30),
    text: Color(0xFFECECEE),
    text2: Color(0xFFB5B5BB),
    muted: Color(0xFF6B6B73),
    primary: _orange,
    onPrimary: _onOrange,
    primarySoft: Color(0x24FF7A00),
    primaryLine: Color(0x59FF7A00),
    primaryInk: _orange,
    good: Color(0xFF4ADE80),
    warn: Color(0xFFF59E0B),
    bad: Color(0xFFF87171),
  );

  /// Fundo de badge de status: cor cheia a 14% (guia · Regras).
  static Color soft(Color c) => c.withValues(alpha: 0.14);

  @override
  HsColors copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? border,
    Color? text,
    Color? text2,
    Color? muted,
    Color? primary,
    Color? onPrimary,
    Color? primarySoft,
    Color? primaryLine,
    Color? primaryInk,
    Color? good,
    Color? warn,
    Color? bad,
  }) =>
      HsColors(
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        surface2: surface2 ?? this.surface2,
        border: border ?? this.border,
        text: text ?? this.text,
        text2: text2 ?? this.text2,
        muted: muted ?? this.muted,
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        primarySoft: primarySoft ?? this.primarySoft,
        primaryLine: primaryLine ?? this.primaryLine,
        primaryInk: primaryInk ?? this.primaryInk,
        good: good ?? this.good,
        warn: warn ?? this.warn,
        bad: bad ?? this.bad,
      );

  @override
  HsColors lerp(ThemeExtension<HsColors>? other, double t) {
    if (other is! HsColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return HsColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      border: l(border, other.border),
      text: l(text, other.text),
      text2: l(text2, other.text2),
      muted: l(muted, other.muted),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primarySoft: l(primarySoft, other.primarySoft),
      primaryLine: l(primaryLine, other.primaryLine),
      primaryInk: l(primaryInk, other.primaryInk),
      good: l(good, other.good),
      warn: l(warn, other.warn),
      bad: l(bad, other.bad),
    );
  }
}

extension HsTheme on BuildContext {
  HsColors get hs => Theme.of(this).extension<HsColors>()!;
}
