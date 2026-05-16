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
