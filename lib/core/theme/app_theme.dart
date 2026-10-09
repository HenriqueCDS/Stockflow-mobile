// Temas claro e escuro gerados a partir dos mesmos tokens (HsColors).
// Elevação pela cor da superfície (bg → surface → surface2), nunca por sombra.
import 'package:flutter/material.dart';
import 'hs_colors.dart';

abstract final class AppTheme {
  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final hs = brightness == Brightness.dark ? HsColors.dark : HsColors.light;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: hs.primary,
      onPrimary: hs.onPrimary,
      primaryContainer: hs.primarySoft,
      onPrimaryContainer: hs.primaryInk,
      secondary: hs.primary,
      onSecondary: hs.onPrimary,
      surface: hs.surface,
      onSurface: hs.text,
      onSurfaceVariant: hs.text2,
      surfaceContainerHighest: hs.surface2,
      outline: hs.border,
      outlineVariant: hs.border,
      error: hs.bad,
      onError: hs.onPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );

    OutlineInputBorder field(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    return base.copyWith(
      scaffoldBackgroundColor: hs.bg,
      canvasColor: hs.bg,
      dividerColor: hs.border,
      textTheme: base.textTheme.apply(
        bodyColor: hs.text,
        displayColor: hs.text,
      ),
      iconTheme: IconThemeData(color: hs.text2),
      appBarTheme: AppBarTheme(
        backgroundColor: hs.bg,
        foregroundColor: hs.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: hs.text,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: hs.text),
      ),
      cardTheme: CardThemeData(
        color: hs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: hs.border),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: hs.surface,
        modalBackgroundColor: hs.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: hs.border,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: hs.surface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: hs.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: field(hs.border),
        enabledBorder: field(hs.border),
        focusedBorder: field(hs.primary, 1.5),
        errorBorder: field(hs.bad),
        focusedErrorBorder: field(hs.bad, 1.5),
        labelStyle: TextStyle(color: hs.text2),
        hintStyle: TextStyle(color: hs.muted),
        prefixIconColor: hs.muted,
        suffixIconColor: hs.muted,
        errorStyle: TextStyle(color: hs.bad, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: hs.primary,
          foregroundColor: hs.onPrimary,
          disabledBackgroundColor: hs.surface2,
          disabledForegroundColor: hs.muted,
          minimumSize: const Size.fromHeight(52),
          shape: buttonShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: hs.primary,
          foregroundColor: hs.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: buttonShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: hs.text,
          backgroundColor: hs.surface,
          side: BorderSide(color: hs.border),
          minimumSize: const Size.fromHeight(52),
          shape: buttonShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: hs.primaryInk),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: hs.primary,
        foregroundColor: hs.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) =>
                s.contains(WidgetState.selected) ? hs.primarySoft : hs.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? hs.primaryInk : hs.text2,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? hs.primaryInk : hs.text2,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: hs.border)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? hs.primary : null,
        ),
        checkColor: WidgetStatePropertyAll(hs.onPrimary),
        side: BorderSide(color: hs.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: hs.primary,
        refreshBackgroundColor: hs.surface,
        linearTrackColor: hs.surface2,
      ),
      dividerTheme: DividerThemeData(color: hs.border, space: 1, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: hs.surface2,
        selectedColor: hs.primarySoft,
        side: BorderSide(color: hs.border),
        labelStyle: TextStyle(fontSize: 12, color: hs.text2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: hs.text2,
        textColor: hs.text,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: hs.text,
        contentTextStyle: TextStyle(color: hs.bg, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      extensions: [hs],
    );
  }
}
