import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // ── Primitive tokens ──────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF6F4E37);
  static const Color primaryLight = Color(0xFFA67B5B);
  static const Color secondary    = Color(0xFFD4A574);
  static const Color background   = Color(0xFFFAF7F2);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color error        = Color(0xFFB00020);

  // Semantic
  static const Color success   = Color(0xFF2E8B57);
  static const Color warning   = Color(0xFFC2871C);
  static const Color starColor = Color(0xFFE8A93B);
  static const Color heartColor = Color(0xFFD6463C);

  // Dark primitives
  static const Color _darkPrimary   = Color(0xFFD2A982);
  static const Color _darkBg        = Color(0xFF17130F);
  static const Color _darkSurface   = Color(0xFF211C17);

  // ── Light theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFF0E7DF),
      onPrimaryContainer: primary,
      secondary: secondary,
      onSecondary: const Color(0xFF3A2719),
      secondaryContainer: const Color(0xFFEFE6DD),
      onSecondaryContainer: const Color(0xFF3A2719),
      surface: surface,
      onSurface: const Color(0xFF211C18),
      onSurfaceVariant: const Color(0xFF8A8178),
      outline: const Color(0xFFE7DDD2),
      outlineVariant: const Color(0xFFECE4DC),
      error: error,
      onError: Colors.white,
    );
    return _build(cs, Brightness.light);
  }

  // ── Dark theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _darkPrimary,
      onPrimary: const Color(0xFF17130F),
      primaryContainer: const Color(0xFF3A2E24),
      onPrimaryContainer: _darkPrimary,
      secondary: secondary,
      onSecondary: const Color(0xFF17130F),
      surface: _darkSurface,
      onSurface: const Color(0xFFF4EFE9),
      onSurfaceVariant: const Color(0xFFADA398),
      outline: const Color(0xFF332C25),
      outlineVariant: const Color(0xFF2A241E),
      error: const Color(0xFFCF6679),
      onError: const Color(0xFF17130F),
    );
    return _build(cs, Brightness.dark);
  }

  // ── Builder ───────────────────────────────────────────────────────────────
  static ThemeData _build(ColorScheme cs, Brightness brightness) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: isLight ? background : _darkBg,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: cs.onSurface,
        displayColor: cs.onSurface,
      ),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
                .copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.light
                .copyWith(statusBarColor: Colors.transparent),
      ),

      // ── Buttons ─────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          side: BorderSide(color: cs.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // ── Card ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        margin: EdgeInsets.zero,
      ),

      // ── Chips ───────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: cs.surface,
        selectedColor: cs.primary,
        disabledColor: cs.surfaceContainerHighest,
        labelStyle: AppTypography.textTheme.labelMedium,
        secondaryLabelStyle: AppTypography.textTheme.labelMedium
            ?.copyWith(color: cs.onPrimary),
        side: BorderSide(color: cs.outlineVariant),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        showCheckmark: false,
      ),

      // ── Input ───────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
            borderRadius: AppRadius.lgAll,
            borderSide: BorderSide(color: cs.outlineVariant)),
        enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgAll,
            borderSide: BorderSide(color: cs.outlineVariant)),
        focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgAll,
            borderSide: BorderSide(color: cs.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgAll,
            borderSide: BorderSide(color: cs.error)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.lgAll,
            borderSide: BorderSide(color: cs.error, width: 1.5)),
        hintStyle: AppTypography.textTheme.bodyMedium
            ?.copyWith(color: cs.onSurfaceVariant),
        prefixIconColor: cs.onSurfaceVariant,
        suffixIconColor: cs.onSurfaceVariant,
        errorStyle: AppTypography.textTheme.labelMedium
            ?.copyWith(color: cs.error),
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        elevation: 4,
      ),

      // ── Dialog ───────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xxlAll),
        backgroundColor: cs.surface,
        titleTextStyle: AppTypography.textTheme.headlineSmall
            ?.copyWith(color: cs.onSurface),
        contentTextStyle: AppTypography.textTheme.bodyMedium
            ?.copyWith(color: cs.onSurfaceVariant),
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        backgroundColor: cs.surface,
        showDragHandle: true,
        dragHandleColor: cs.outlineVariant,
        dragHandleSize: const Size(40, 4),
        elevation: 0,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
          color: cs.outlineVariant, thickness: 1, space: 0),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        titleTextStyle: AppTypography.textTheme.titleSmall
            ?.copyWith(color: cs.onSurface),
        subtitleTextStyle: AppTypography.textTheme.bodySmall
            ?.copyWith(color: cs.onSurfaceVariant),
        minLeadingWidth: 0,
        minVerticalPadding: AppSpacing.sm,
      ),
    );
  }
}
