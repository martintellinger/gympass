import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Shared error+retry state for screens backed by an async repository.
/// Shown when a fetch fails (offline / RLS / server) instead of a blank
/// screen, with a retry that re-invalidates the provider.
class LoadError extends StatelessWidget {
  final VoidCallback onRetry;
  const LoadError({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: T.errorSoft,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
              child: const AppIcon('alert', size: 26, color: T.error),
            ),
            const SizedBox(height: 16),
            Text(
              l.errLoadTitle,
              textAlign: TextAlign.center,
              style: AppType.ui(
                size: 16,
                weight: FontWeight.w700,
                color: T.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l.errLoadBody,
              textAlign: TextAlign.center,
              style: AppType.ui(size: 13.5, color: T.text2, height: 1.5),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: l.errRetry,
              icon: const AppIcon('refresh', size: 18),
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
