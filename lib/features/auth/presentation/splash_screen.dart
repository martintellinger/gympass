import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/app_icon.dart';
import '../../../shared/widgets/screen_frame.dart';

/// Shown while the initial Supabase session is being resolved (before the
/// router knows where to send the user).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenFrame(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon('dumbbell', size: 40, color: T.accent),
            SizedBox(height: 24),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.4, color: T.text2),
            ),
          ],
        ),
      ),
    );
  }
}
