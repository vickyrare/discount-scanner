import 'package:flutter/material.dart';

class AppTheme {
  static const Color navy = Color(0xFF11324D);
  static const Color teal = Color(0xFF1FA6A0);
  static const Color mint = Color(0xFFE7F7F2);
  static const Color amber = Color(0xFFF6B74B);
  static const Color ink = Color(0xFF17212B);
  static const Color lightSurface = Color(0xFFF6F8FA);
  static const Color darkSurface = Color(0xFF101820);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: teal,
      brightness: Brightness.light,
      primary: teal,
      secondary: amber,
      surface: Colors.white,
      onSurface: ink,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: lightSurface,
      appBarTheme: _appBarTheme(scheme, ink),
      cardColor: Colors.white,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: teal,
      brightness: Brightness.dark,
      primary: teal,
      secondary: amber,
      surface: const Color(0xFF17212B),
      onSurface: Colors.white,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: darkSurface,
      appBarTheme: _appBarTheme(scheme, Colors.white),
      cardColor: const Color(0xFF17212B),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: scheme.outlineVariant),
        selectedColor: scheme.primary,
        checkmarkColor: scheme.onPrimary,
        labelStyle: TextStyle(color: scheme.onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        backgroundColor: scheme.surface,
        elevation: 0,
      ),
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme scheme, Color foreground) {
    return AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: foreground,
      titleTextStyle: TextStyle(
        color: foreground,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: foreground),
    );
  }
}
