import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Typography helpers — Inter for UI, JetBrains Mono for numbers/dates/codes.
/// (shared.jsx: FontUI = Inter, FontMono = JetBrains Mono.)
class AppType {
  AppType._();

  static TextStyle ui({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color color = T.text,
    double letterSpacing = -0.2,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle mono({
    double size = 15,
    FontWeight weight = FontWeight.w500,
    Color color = T.text,
    double letterSpacing = 0,
    double? height,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: T.bg,
      canvasColor: T.bg,
      colorScheme: const ColorScheme.dark(
        surface: T.surface,
        primary: T.accent,
        secondary: T.accent,
        error: T.error,
        onPrimary: Colors.white,
        onSurface: T.text,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: T.text,
        displayColor: T.text,
      ),
      splashColor: Colors.white10,
      highlightColor: Colors.white10,
      dividerColor: T.border,
    );
  }
}
