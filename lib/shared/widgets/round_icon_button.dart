import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import 'app_icon.dart';

/// The circular icon button copy-pasted across ~10 screens as a private
/// `_RoundBtn`/inline 36px circle (back / compose / action). One source.
class RoundIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color background;
  final Color iconColor;
  final bool bordered;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 36,
    this.iconSize = 18,
    this.background = T.surface,
    this.iconColor = T.text,
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: bordered ? Border.all(color: T.border) : null,
        ),
        child: AppIcon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
