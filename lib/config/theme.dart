import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'spacing.dart';
import 'shapes.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

const Color _primarySeed = Color(0xFF6366F1);
const Color _secondarySeed = Color(0xFF06B6D4);
const Color _tertiarySeed = Color(0xFF8B5CF6);

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: SeedColorScheme.fromSeeds(
      brightness: Brightness.light,
      primaryKey: _primarySeed,
      secondaryKey: _secondarySeed,
      tertiaryKey: _tertiarySeed,

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
    dividerTheme: DividerThemeData(
      space: 0,
      thickness: 0.5,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: SeedColorScheme.fromSeeds(
      brightness: Brightness.dark,
      primaryKey: _primarySeed,
      secondaryKey: _secondarySeed,
      tertiaryKey: _tertiarySeed,

    ),

    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: GoogleFonts.inter(height: 1.6),
      bodyMedium: GoogleFonts.inter(height: 1.5),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),

    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: const Color(0xFFE6E1E5),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
      shape: AppShapes.card,
      clipBehavior: Clip.antiAlias,
    ),

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

    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      indicatorShape: AppShapes.smallCard,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),

    chipTheme: ChipThemeData(
      shape: AppShapes.chip,
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
    ),

    dialogTheme: DialogThemeData(
      shape: AppShapes.dialog,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: AppShapes.smallCard,
    ),

    dividerTheme: DividerThemeData(
      space: 0,
      thickness: 0.5,
    ),
  );
}

extension MethodColors on String {
  Color get methodColor {
    return switch (toUpperCase()) {
      'GET' => const Color(0xFF22C55E),
      'POST' => const Color(0xFF3B82F6),
      'PUT' => const Color(0xFFF59E0B),
      'PATCH' => const Color(0xFF10B981),
      'DELETE' => const Color(0xFFEF4444),
      'HEAD' => const Color(0xFFA855F7),
      'OPTIONS' => const Color(0xFF1D4ED8),
      _ => Colors.grey,
    };
  }
}

extension StatusColors on int {
  Color get statusColor {
    if (this >= 200 && this < 300) return const Color(0xFF22C55E);
    if (this >= 300 && this < 400) return const Color(0xFFF59E0B);
    if (this >= 400 && this < 500) return const Color(0xFFEF4444);
    if (this >= 500) return const Color(0xFFDC2626);
    return Colors.grey;
  }
}
