import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// A shimmering placeholder block — used while data that genuinely takes
/// >300 ms is loading (file parsing now; Supabase queries once the backend
/// lands). Skeleton, never a spinner, per the design conventions.
class Skeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const Skeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 8,
  });

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(T.surface2, T.border, _c.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// A few stacked skeleton rows that mimic a list while it loads.
class SkeletonList extends StatelessWidget {
  final int rows;
  const SkeletonList({super.key, this.rows = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Skeleton(width: 36, height: 36, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(
                          width: 140 + (i.isEven ? 40 : 0).toDouble(),
                          height: 13),
                      const SizedBox(height: 8),
                      const Skeleton(width: 90, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
