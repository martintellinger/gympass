import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/tokens.dart';

/// Wraps a screen with the dark background and pushes content below the real
/// OS status bar (notch / clock / battery come from the device itself, not a
/// mocked bar). Screens own their scroll + bottom nav (as a Stack with the
/// nav Positioned at the bottom, per the design conventions).
class ScreenFrame extends StatelessWidget {
  final Widget child;
  const ScreenFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Dark app background → light status-bar glyphs on both platforms.
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android
        statusBarBrightness: Brightness.dark, // iOS
      ),
      child: Scaffold(
        backgroundColor: T.bg,
        body: SafeArea(bottom: false, child: child),
      ),
    );
  }
}
