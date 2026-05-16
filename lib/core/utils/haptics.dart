import 'package:flutter/services.dart';

/// Centralised, semantic haptic feedback.
///
/// Screens call these by intent, not by platform primitive, so the feel can be
/// tuned in one place. iOS maps these to the Taptic engine; on Android they
/// fall back to the vibration motor (no-op on devices without one).
class Haptics {
  const Haptics._();

  /// A light tap — primary buttons, pressable rows.
  static void tap() => HapticFeedback.lightImpact();

  /// Discrete selection — tab switch, segmented control, toggle.
  static void selection() => HapticFeedback.selectionClick();

  /// An action succeeded — payment marked, member approved, message sent.
  static void success() => HapticFeedback.mediumImpact();

  /// A heavier, attention-grabbing cue — destructive or rejecting action.
  static void warning() => HapticFeedback.heavyImpact();
}
