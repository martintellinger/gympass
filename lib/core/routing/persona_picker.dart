import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/screen_frame.dart';

/// Dev persona switcher — stands in for auth until Supabase is wired.
/// Mirrors the prototype's Člen / Majitel switcher.
class PersonaPicker extends StatelessWidget {
  const PersonaPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppIcon('dumbbell', size: 40, color: T.accent),
            const SizedBox(height: 20),
            Text('BýtFit Klub',
                style: AppType.ui(size: 32, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Vyber, jak appku otevřít.',
                style: AppType.ui(size: 15, color: T.text2)),
            const SizedBox(height: 32),
            AppButton(
              label: 'Otevřít jako člen',
              full: true,
              icon: const AppIcon('user', size: 20, color: Colors.white),
              onTap: () => context.go('/member/dashboard'),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Otevřít jako Olda (majitel)',
              variant: BtnVariant.ghost,
              full: true,
              icon: const AppIcon('shield', size: 20, color: T.text),
              onTap: () => context.go('/admin'),
            ),
          ],
        ),
      ),
    );
  }
}
