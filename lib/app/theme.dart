import 'package:flutter/material.dart';

/// Senior-friendly tema s visokim kontrastom, velikim gumbima i fontovima.
class HelpiTheme {
  HelpiTheme._();

  // ─── Boje ───────────────────────────────────────────────────────
  static const Color _primary = Color(0xFFEF5B5B);
  static const Color _primaryDark = Color(0xFFD94545);
  static const Color _accent = Color(0xFF009D9D);
  static const Color _error = Color(0xFFC62828);
  static const Color _background = Color(0xFFF5F5F5);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF212121);
  static const Color _textSecondary = Color(0xFF616161);

  // ─── Dimenzije gumba ────────────────────────────────────────────
  static const double buttonHeight = 56.0;
  static const double buttonRadius = 12.0;
  static const double cardRadius = 12.0;

  // ─── Tema ───────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _primary,
      primaryContainer: Color(0xFFFFDAD6),
      secondary: _accent,
      secondaryContainer: Color(0xFFC8E6C9),
      error: _error,
      surface: _surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _textPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _background,

    // ─── AppBar ─────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // ─── Tekst ─────────────────────────────────────
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: _textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // ─── Elevated Button (veliki, zaobljeni) ───────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),

    // ─── Outlined Button ────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _accent,
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        side: const BorderSide(color: _accent, width: 2),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),

    // ─── Text Button ───────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primary,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // ─── Card ───────────────────────────────────────
    cardTheme: CardThemeData(
      color: _surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ─── Input Decoration ───────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: BorderSide(color: _primary.withAlpha(128), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: _primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: _error, width: 2),
      ),
      labelStyle: const TextStyle(fontSize: 16, color: _textSecondary),
      hintStyle: const TextStyle(fontSize: 16, color: _textSecondary),
    ),

    // ─── Bottom Navigation ──────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surface,
      selectedItemColor: _primary,
      unselectedItemColor: _textPrimary,
      selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 14),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // ─── Floating Action Button ─────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // ─── Divider ────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
      space: 1,
    ),
  );
}
