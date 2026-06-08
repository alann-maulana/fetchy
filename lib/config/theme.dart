import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'spacing.dart';
import 'shapes.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

const Color _primarySeed = Color(0xFF7C3AED); // Violet
const Color _secondarySeed = Color(0xFF06B6D4); // Cyan

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: SeedColorScheme.fromSeeds(
      brightness: Brightness.light,
      primaryKey: _primarySeed,
      secondaryKey: _secondarySeed,
    ),

    // Typography
    textTheme: GoogleFonts.interTextTheme().copyWith(
      bodyLarge: GoogleFonts.inter(height: 1.6),
      bodyMedium: GoogleFonts.inter(height: 1.5),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: const Color(0xFF1C1B1F),
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
      shape: AppShapes.card,
      clipBehavior: Clip.antiAlias,
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Spacing.inputRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Spacing.inputRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Spacing.inputRadius),
      ),
    ),

    // Navigation
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      indicatorShape: AppShapes.smallCard,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),

    // Chips
    chipTheme: ChipThemeData(
      shape: AppShapes.chip,
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
    ),

    // Dialogs
    dialogTheme: DialogThemeData(
      shape: AppShapes.dialog,
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: AppShapes.smallCard,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      space: 0,
      thickness: 0.5,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0A0A15),
    colorScheme: SeedColorScheme.fromSeeds(
      brightness: Brightness.dark,
      primaryKey: _primarySeed,
      secondaryKey: _secondarySeed,
    ).copyWith(
      primary: const Color(0xFF7C3AED),
      primaryContainer: const Color(0xFF5B21B6),
      secondary: const Color(0xFF06B6D4),
      secondaryContainer: const Color(0xFF0891B2),
      surface: const Color(0xFF13132B),
      onSurface: const Color(0xFFE2E8F0),
      onSurfaceVariant: const Color(0xFF94A3B8),
      error: const Color(0xFFF87171),
      outline: const Color(0x267C3AED), // rgba(124, 58, 237, 0.15)
      outlineVariant: const Color(0x1A7C3AED),
    ),

    // Typography
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.8),
      displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.36),
      displaySmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.2),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, height: 1.0, letterSpacing: 0.24),
      labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, height: 1.0, letterSpacing: 0.4),
      bodySmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, height: 1.4), // caption
    ),

    // AppBar
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: const Color(0xFFE2E8F0),
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF13132B).withValues(alpha: 0.75),
      margin: EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
      shape: AppShapes.card,
      clipBehavior: Clip.antiAlias,
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF13132B).withValues(alpha: 0.6),
      contentPadding: EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Spacing.inputRadius),
        borderSide: const BorderSide(color: Color(0x267C3AED)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Spacing.inputRadius),
        borderSide: const BorderSide(color: Color(0x267C3AED)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Spacing.inputRadius),
        borderSide: const BorderSide(color: Color(0xFF7C3AED)),
      ),
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
    ),

    // Navigation
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: const Color(0xFF0A0A15).withValues(alpha: 0.95),
      indicatorColor: const Color(0xFF7C3AED).withValues(alpha: 0.15),
      indicatorShape: AppShapes.smallCard,
      height: 56,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? const Color(0xFF7C3AED)
            : const Color(0xFF64748B);
        return GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: color);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? const Color(0xFF7C3AED)
            : const Color(0xFF64748B);
        return IconThemeData(color: color, size: 22);
      }),
    ),

    // Chips
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF13132B),
      shape: AppShapes.chip,
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
      labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFE2E8F0)),
    ),

    // Dialogs
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF13132B),
      shape: AppShapes.dialog,
      titleTextStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFFE2E8F0)),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF13132B),
      contentTextStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFE2E8F0)),
      shape: AppShapes.smallCard,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      space: 0,
      thickness: 0.5,
      color: Color(0x267C3AED),
    ),

    // FLOATING ACTION BUTTON
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF7C3AED),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.md),
      ),
    ),
  );
}

extension MethodColors on String {
  Color get methodColor {
    return switch (toUpperCase()) {
      'GET' => const Color(0xFF34D399),     // Success (Emerald/Green)
      'POST' => const Color(0xFF60A5FA),    // Info (Blue)
      'PUT' => const Color(0xFFFBBF24),     // Warning (Amber/Yellow)
      'PATCH' => const Color(0xFF22D3EE),   // Secondary Light (Cyan)
      'DELETE' => const Color(0xFFF87171),  // Error (Red)
      'HEAD' => const Color(0xFF9F67FF),    // Primary Light (Violet)
      'OPTIONS' => const Color(0xFF64748B), // Neutral
      _ => Colors.grey,
    };
  }
}

extension StatusColors on int {
  Color get statusColor {
    if (this >= 200 && this < 300) return const Color(0xFF34D399); // success
    if (this >= 300 && this < 400) return const Color(0xFFFBBF24); // warning
    if (this >= 400 && this < 500) return const Color(0xFFF87171); // error
    if (this >= 500) return const Color(0xFFEF4444);
    return Colors.grey;
  }
}
