import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import 'status_bar.dart';

/// Wraps a screen with the dark background + custom status bar, matching the
/// prototype phone chrome. Screens own their scroll + bottom nav (as a Stack
/// with the nav Positioned at the bottom, per the design conventions).
class ScreenFrame extends StatelessWidget {
  final Widget child;
  final String statusTime;
  const ScreenFrame({super.key, required this.child, this.statusTime = '9:41'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      body: Column(
        children: [
          SafeArea(bottom: false, child: AppStatusBar(time: statusTime)),
          Expanded(child: child),
        ],
      ),
    );
  }
}
