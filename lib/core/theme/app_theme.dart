import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // ── Semantic type scale ────────────────────────────────────────────────
  // Named roles mapped to the recurring sizes/weights of the prototype.
  // Prefer these in new/extracted code; `ui`/`mono` stay as the escape
  // hatch for bespoke one-offs. Color/height overridable per use.

  /// Oversized hero numeral (e.g. the remaining-days count).
  static TextStyle hero({Color color = T.text}) =>
      ui(size: 48, weight: FontWeight.w800, color: color, letterSpacing: -1.5);

  /// Landing / persona display.
  static TextStyle display({Color color = T.text}) =>
      ui(size: 32, weight: FontWeight.w700, color: color, letterSpacing: -0.6);

  /// Screen title (board, history, messages…).
  static TextStyle h1({Color color = T.text}) =>
      ui(size: 28, weight: FontWeight.w700, color: color, letterSpacing: -0.8);

  /// Section / card heading.
  static TextStyle h2({Color color = T.text}) =>
      ui(size: 22, weight: FontWeight.w700, color: color, letterSpacing: -0.4);

  /// Prominent row / card title.
  static TextStyle title({Color color = T.text}) =>
      ui(size: 17, weight: FontWeight.w600, color: color);

  /// Default body copy.
  static TextStyle body({Color color = T.text}) =>
      ui(size: 15, weight: FontWeight.w400, color: color, height: 1.4);

  /// Compact body / secondary text.
  static TextStyle bodySm({Color color = T.text2}) =>
      ui(size: 13.5, weight: FontWeight.w400, color: color, height: 1.4);

  /// Field / row label.
  static TextStyle label({Color color = T.text}) =>
      ui(size: 13, weight: FontWeight.w500, color: color);

  /// Tiny meta / caption.
  static TextStyle caption({Color color = T.text2}) =>
      ui(size: 12, weight: FontWeight.w500, color: color);

  /// Uppercase section kicker / overline.
  static TextStyle overline({Color color = T.text2}) => ui(
      size: 12, weight: FontWeight.w600, color: color, letterSpacing: 0.4);
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

  /// Light theme for Material chrome (dialogs, pickers, text selection,
  /// system overlays). The bespoke screen surfaces remain dark by design
  /// — the design brief mandates a dark-primary identity and the screens
  /// are a pixel-faithful port of the dark prototype.
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    const lbg = Color(0xFFF5F5F7);
    const lsurface = Color(0xFFFFFFFF);
    const ltext = Color(0xFF0F0F10);
    return base.copyWith(
      scaffoldBackgroundColor: lbg,
      canvasColor: lbg,
      colorScheme: const ColorScheme.light(
        surface: lsurface,
        primary: T.accent,
        secondary: T.accent,
        error: T.error,
        onPrimary: Colors.white,
        onSurface: ltext,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: ltext,
        displayColor: ltext,
      ),
      splashColor: Colors.black12,
      highlightColor: Colors.black12,
      dividerColor: const Color(0xFFD9D9DE),
    );
  }
}

/// App-wide theme mode (driven by the "Téma" selector in Profile / Více).
/// Defaults to dark — the product's primary identity per the design brief.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// App-wide locale (driven by the "Jazyk" selector). Czech is primary;
/// English is the prepared fallback per the project brief.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('cs');

  void set(Locale locale) => state = locale;
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
