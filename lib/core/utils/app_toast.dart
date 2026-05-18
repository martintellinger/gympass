import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'haptics.dart';

/// App-wide toast / alert surface.
///
/// Anchored to the **top** of the screen (just below the status bar) and
/// sliding down from there. Bottom-anchored SnackBars were colliding with the
/// persistent tab bar and sticky action buttons, so every toast, alert and
/// confirmation message goes through here instead of `ScaffoldMessenger`.
void showAppToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(milliseconds: 2600),
  bool haptic = true,
}) {
  if (message.isEmpty) return;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  if (haptic) Haptics.success();

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _TopToast(
      message: message,
      duration: duration,
      onDismissed: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _TopToast extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopToast({
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _c.forward();
    Future<void>.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (_leaving || !mounted) return;
    _leaving = true;
    _c.reverse().whenComplete(widget.onDismissed);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topInset + 12,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, child) => Opacity(
          opacity: _t.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _t.value) * -24),
            child: child,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: T.surface2,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(color: T.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: AppType.ui(
                  size: 14,
                  weight: FontWeight.w500,
                  color: T.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
