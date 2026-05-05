import 'package:flutter/material.dart';
import 'colors.dart';

/// Tema scuro stile Solo Leveling.
///
/// Due famiglie di font: monospace per i dettagli "tecnici" (numeri, label,
/// status), e un sans-serif geometrico per titoli grandi (più leggibile,
/// meno "raw" del monospace ovunque).
class AppTheme {
  AppTheme._();

  static const String monoFont = 'monospace';

  /// Stili tipografici riutilizzabili.
  static const TextStyle systemLabel = TextStyle(
    fontFamily: monoFont,
    color: AppColors.blue,
    letterSpacing: 4,
    fontSize: 12,
  );

  static const TextStyle systemTitle = TextStyle(
    fontFamily: monoFont,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 4,
    fontSize: 16,
  );

  static const TextStyle bodyMono = TextStyle(
    fontFamily: monoFont,
    color: Colors.white,
    fontSize: 14,
  );

  static const TextStyle muted = TextStyle(
    fontFamily: monoFont,
    color: Colors.grey,
    fontSize: 11,
    letterSpacing: 1,
  );

  static ThemeData build() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.black,
      primaryColor: AppColors.blue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.blue,
        secondary: AppColors.purple,
        surface: AppColors.surface,
      ),
      textTheme: const TextTheme(
        bodyMedium: bodyMono,
        titleLarge: TextStyle(
          fontFamily: monoFont,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blueDim),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blue),
        ),
        labelStyle: TextStyle(color: Colors.grey, fontFamily: monoFont),
        hintStyle: TextStyle(color: Color(0xFF333355), fontFamily: monoFont),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.blueDim),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: TextStyle(color: AppColors.blue, fontFamily: monoFont),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}