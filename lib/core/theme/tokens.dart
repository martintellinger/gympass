import 'package:flutter/material.dart';

/// Design tokens — 1:1 port of the `T` object in
/// docs/design/gympass/project/screens/shared.jsx.
///
/// Dark theme is primary. The accent is tweakable; in the prototype it is a
/// CSS variable `--bf-accent` defaulting to #FF4D2E.
class T {
  T._();

  static const Color bg = Color(0xFF0F0F10);
  static const Color surface = Color(0xFF1A1A1C);
  static const Color surface2 = Color(0xFF232326);
  static const Color border = Color(0xFF2A2A2D);
  static const Color divider = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)

  static const Color text = Color(0xFFF5F5F7);
  static const Color text2 = Color(0xFF8E8E93);
  static const Color text3 = Color(0xFF5E5E63);

  /// Tweakable accent (var(--bf-accent, #FF4D2E)).
  static const Color accent = Color(0xFFFF4D2E);
  static const Color accentSoft = Color(0x24FF4D2E); // rgba(255,77,46,0.14)

  static const Color ok = Color(0xFF34C759);
  static const Color warn = Color(0xFFFFCC00);
  static const Color error = Color(0xFFFF3B30);

  static const Color okSoft = Color(0x2434C759); // 0.14
  static const Color warnSoft = Color(0x24FFCC00);
  static const Color errorSoft = Color(0x24FF3B30);

  static const Color mutedSoft = Color(0x2A8E8E93); // rgba(142,142,147,0.16)

  /// Board "event" post accent (iOS systemBlue).
  static const Color event = Color(0xFF5AC8FA);

  // ── Scrims (overlay dimming for sheets / modals / image captions) ──
  static const Color scrimLight = Color(0x66000000); // 0.40
  static const Color scrimMedium = Color(0x99000000); // 0.60
  static const Color scrim = Color(0xA6000000); // 0.65
  static const Color scrimStrong = Color(0xB3000000); // 0.70
  static const Color scrimSheet = Color(0x80000000); // 0.50 modal barrier

  /// Heavy translucent panel backgrounds (frosted bars / composers).
  static const Color glassBar = Color(0xF20F0F10); // bg @ 0.95
  static const Color glassBarSoft = Color(0xCC141416); // surface @ 0.80

  // ── Elevated surface gradients (card sheen, prototype-faithful) ──
  static const List<Color> cardSheen = [Color(0xFF161618), Color(0xFF0E0E10)];
  static const List<Color> cardSheenSoft = [
    Color(0xFF1E1E20),
    Color(0xFF161618)
  ];
  static const List<Color> cardSheenRaised = [
    Color(0xFF1A1A1C),
    Color(0xFF232326)
  ];

  /// Radial accent glow used behind hero cards.
  static const List<Color> accentGlowStrong = [
    Color(0x38FF4D2E),
    Color(0x00FF4D2E)
  ];
  static const List<Color> accentGlow = [Color(0x2EFF4D2E), Color(0x00FF4D2E)];
}

/// Spacing scale (4-pt grid). Use instead of ad-hoc magic numbers.
class Space {
  Space._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  /// Bottom content inset that clears the persistent tab bar.
  static const double navClearance = 110;
}

/// Corner-radius scale.
class Radii {
  Radii._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

/// Status keys used by StatusPill / StatusDot.
enum StatusState { ok, warn, error, muted }

extension StatusStateColors on StatusState {
  Color get fg => switch (this) {
        StatusState.ok => T.ok,
        StatusState.warn => T.warn,
        StatusState.error => T.error,
        StatusState.muted => T.text2,
      };

  Color get bg => switch (this) {
        StatusState.ok => T.okSoft,
        StatusState.warn => T.warnSoft,
        StatusState.error => T.errorSoft,
        StatusState.muted => T.mutedSoft,
      };

  Color get dot => switch (this) {
        StatusState.ok => T.ok,
        StatusState.warn => T.warn,
        StatusState.error => T.error,
        StatusState.muted => T.text3,
      };
}

StatusState statusFromKey(String? key) => switch (key) {
      'ok' => StatusState.ok,
      'warn' => StatusState.warn,
      'error' => StatusState.error,
      _ => StatusState.muted,
    };
