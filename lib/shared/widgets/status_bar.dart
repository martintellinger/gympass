import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// StatusBar — custom dark iOS-like bar. shared.jsx StatusBar.
/// height 54, paddingTop 14, side padding 32, time 17/600 white.
class AppStatusBar extends StatelessWidget {
  final String time;
  const AppStatusBar({super.key, this.time = '9:41'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Padding(
        padding: const EdgeInsets.only(top: 14, left: 32, right: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              time,
              style: AppType.ui(
                size: 17,
                weight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            const Row(
              children: [
                _Signal(),
                SizedBox(width: 7),
                _Wifi(),
                SizedBox(width: 7),
                _Battery(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Signal extends StatelessWidget {
  const _Signal();
  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 18, height: 11, child: CustomPaint(painter: _SignalPainter()));
}

class _SignalPainter extends CustomPainter {
  const _SignalPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    const bars = [
      [0.0, 7.0, 4.0],
      [4.5, 5.0, 6.0],
      [9.0, 2.5, 8.5],
      [13.5, 0.0, 11.0],
    ];
    for (final b in bars) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(b[0], b[1], 3, b[2]), const Radius.circular(0.6)),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _Wifi extends StatelessWidget {
  const _Wifi();
  @override
  Widget build(BuildContext context) => const Icon(Icons.wifi, size: 15, color: Colors.white);
}

class _Battery extends StatelessWidget {
  const _Battery();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 11,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withAlpha(102)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1.6),
            ),
          ),
        ),
        const SizedBox(width: 1),
        Container(
          width: 1.5,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(102),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}
