import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// QRCode — pixel-faithful port of shared.jsx QRCode.
/// Deterministic pseudo-random 25x25 grid + 3 finder patterns. `seed` varies it.
class QrCode extends StatelessWidget {
  final double size;
  final int seed;
  const QrCode({super.key, this.size = 240, this.seed = 0});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _QrPainter(seed));
}

class _QrPainter extends CustomPainter {
  final int seed;
  static const int n = 25;
  _QrPainter(this.seed);

  bool _s(int x, int y) =>
      ((x * 37 + y * 23 + (x ^ y) * 13 + seed * 19 + seed * seed * 7) % 11) < 5;

  bool _isFinder(int a, int b, int x, int y) =>
      x >= a && x < a + 7 && y >= b && y < b + 7;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / n;
    final white = Paint()..color = Colors.white;
    final dark = Paint()..color = T.bg; // #0F0F10

    canvas.drawRect(Offset.zero & size, white);

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final inFinder = _isFinder(0, 0, x, y) ||
            _isFinder(n - 7, 0, x, y) ||
            _isFinder(0, n - 7, x, y);
        if (inFinder) continue;
        if (_s(x, y)) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell, cell),
            dark,
          );
        }
      }
    }

    void finder(int ox, int oy) {
      final dx = ox * cell, dy = oy * cell;
      canvas.drawRect(Rect.fromLTWH(dx, dy, cell * 7, cell * 7), dark);
      canvas.drawRect(
          Rect.fromLTWH(dx + cell, dy + cell, cell * 5, cell * 5), white);
      canvas.drawRect(
          Rect.fromLTWH(dx + cell * 2, dy + cell * 2, cell * 3, cell * 3),
          dark);
    }

    finder(0, 0);
    finder(n - 7, 0);
    finder(0, n - 7);
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.seed != seed;
}
