import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/haptics.dart';

enum BtnVariant { primary, ghost, secondary, danger }

/// Btn — shared.jsx Btn. height 52, radius 14, 16/600, gap 8.
///
/// Adds a subtle press-scale + a light haptic so every primary action in the
/// app feels physical, without each call site repeating the boilerplate.
class AppButton extends StatefulWidget {
  final String label;
  final BtnVariant variant;
  final Widget? icon;
  final bool full;
  final VoidCallback? onTap;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.variant = BtnVariant.primary,
    this.icon,
    this.full = false,
    this.onTap,
    this.height = 52,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final variant = widget.variant;
    final icon = widget.icon;
    final onTap = widget.onTap;
    final (Color bg, Color fg, Border? bd) = switch (variant) {
      BtnVariant.primary => (T.accent, Colors.white, null),
      BtnVariant.ghost => (
          Colors.transparent,
          T.text,
          Border.all(color: T.border)
        ),
      BtnVariant.secondary => (T.surface2, T.text, null),
      BtnVariant.danger => (T.errorSoft, T.error, null),
    };

    final content = Row(
      mainAxisSize: widget.full ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          IconTheme(data: IconThemeData(color: fg), child: icon),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: AppType.ui(
              size: 16,
              weight: FontWeight.w600,
              color: fg,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );

    final enabled = onTap != null;

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled
              ? () {
                  Haptics.tap();
                  onTap();
                }
              : null,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: widget.height,
            width: widget.full ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: bd,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}
