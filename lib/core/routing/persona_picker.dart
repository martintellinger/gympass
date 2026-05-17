import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/screen_frame.dart';

/// Dev persona switcher — stands in for auth until Supabase is wired.
/// Mirrors the prototype's Člen / Majitel switcher.
class PersonaPicker extends StatelessWidget {
  const PersonaPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return ScreenFrame(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppIcon('dumbbell', size: 40, color: T.accent),
            const SizedBox(height: 20),
            Text(l.personaTitle,
                style: AppType.ui(size: 32, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(l.personaSubtitle,
                style: AppType.ui(size: 15, color: T.text2)),
            const SizedBox(height: 32),
            AppButton(
              label: l.personaOpenAsMember,
              full: true,
              icon: const AppIcon('user', size: 20, color: Colors.white),
              onTap: () => context.go('/member/dashboard'),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l.personaOpenAsOwner,
              variant: BtnVariant.ghost,
              full: true,
              icon: const AppIcon('shield', size: 20, color: T.text),
              onTap: () => context.go('/admin'),
            ),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/styleguide'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppIcon('sliders', size: 16, color: T.text2),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text('Design systém / styleguide',
                            overflow: TextOverflow.ellipsis,
                            style: AppType.ui(size: 13, color: T.text2)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
