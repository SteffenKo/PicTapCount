import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFFEB7E1C);

  static ColorScheme _scheme(Brightness brightness) {
    final base = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return brightness == Brightness.light
        ? base.copyWith(
            primary: const Color(0xFFEB7E1C),
            onPrimary: Colors.black,
            tertiary: const Color(0xFF00ACDC),
            onTertiary: Colors.black,
            tertiaryContainer: const Color(0xFFCCF3FD),
            onTertiaryContainer: const Color(0xFF003A50),
          )
        : base.copyWith(
            primary: const Color(0xFFF5A040),
            onPrimary: Colors.black,
            tertiary: const Color(0xFF4DCCEC),
            onTertiary: Colors.black,
            tertiaryContainer: const Color(0xFF004D6A),
            onTertiaryContainer: const Color(0xFFCCF3FD),
          );
  }

  static ThemeData _build(Brightness brightness) => ThemeData(
        useMaterial3: true,
        colorScheme: _scheme(brightness),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 3,
          centerTitle: false,
        ),
      );

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
}
