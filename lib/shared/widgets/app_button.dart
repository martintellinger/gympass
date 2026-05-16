import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';

enum BtnVariant { primary, ghost, secondary, danger }

/// Btn — shared.jsx Btn. height 52, radius 14, 16/600, gap 8.
class AppButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
      mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          IconTheme(data: IconThemeData(color: fg), child: icon!),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
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

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: height,
          width: full ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: bd,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}
