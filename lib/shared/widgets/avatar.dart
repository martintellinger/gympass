import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Avatar — shared.jsx Avatar. Initials on tinted (alpha 0x26) background.
class Avatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? tint;

  const Avatar({super.key, required this.name, this.size = 40, this.tint});

  static const List<Color> _palette = [
    Color(0xFFFF4D2E),
    Color(0xFFFFCC00),
    Color(0xFF34C759),
    Color(0xFF5AC8FA),
    Color(0xFFBF5AF2),
    Color(0xFFFF9F0A),
    Color(0xFF64D2FF),
  ];

  static Color colorFor(String name) {
    if (name.isEmpty) return _palette[0];
    return _palette[name.codeUnitAt(0) % _palette.length];
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
    return parts.take(2).map((s) => s[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = tint ?? colorFor(name);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.withAlpha(0x26),
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials,
        style: AppType.ui(
          size: size * 0.36,
          weight: FontWeight.w600,
          color: c,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}
