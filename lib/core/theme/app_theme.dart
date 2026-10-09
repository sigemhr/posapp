import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de colores de alto contraste pensada para mostrador de tiendita
  static const Color primary = Color(0xFF4F46E5);      // Indigo moderno
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color emeraldGreen = Color(0xFF059669);  // Éxito / Cobro / Dinero
  static const Color amberOrange = Color(0xFFEA580C);   // Acciones secundarias / Alertas
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF0F172A);      // Slate 900
  static const Color textMuted = Color(0xFF475569);     // Slate 600

  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: emeraldGreen,
        tertiary: amberOrange,
        surface: surfaceLight,
        onSurface: textMain,
        brightness: Brightness.light,
      ),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: surfaceLight,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textMain,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52), // Touch target amplio para mostrador
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
