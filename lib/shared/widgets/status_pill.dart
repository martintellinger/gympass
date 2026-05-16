import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';

/// StatusDot — shared.jsx StatusDot.
class StatusDot extends StatelessWidget {
  final StatusState state;
  final double size;
  const StatusDot({super.key, required this.state, this.size = 8});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: state.dot, shape: BoxShape.circle),
      );
}

/// StatusPill — shared.jsx StatusPill.
class StatusPill extends StatelessWidget {
  final StatusState state;
  final String label;
  const StatusPill({super.key, required this.state, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 4),
      decoration: BoxDecoration(
        color: state.bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // muted shows no dot color in original (state nulled) — keep subtle.
          StatusDot(state: state, size: 6),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppType.ui(
              size: 12,
              weight: FontWeight.w500,
              color: state.fg,
              letterSpacing: -0.1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
