import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon.dart';
import '../application/auth_notifier.dart';
import 'widgets.dart';

/// 03 — Waiting for the owner's approval (brief §4.1 step 5 / §screens 3).
/// Also covers the "confirm your e-mail" case (signed in, no profile row yet).
class PendingScreen extends ConsumerStatefulWidget {
  const PendingScreen({super.key});

  @override
  ConsumerState<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends ConsumerState<PendingScreen> {
  bool _busy = false;

  Future<void> _refresh() async {
    setState(() => _busy = true);
    await ref.read(authNotifierProvider).refreshProfile();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final auth = ref.watch(authNotifierProvider);
    final awaiting = auth.snapshot.awaitingProfile;

    return AuthScaffold(
      title: awaiting ? l.authConfirmEmailTitle : l.authPendingTitle,
      subtitle: awaiting ? l.authConfirmEmailBody : l.authPendingBody,
      children: [
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: T.warnSoft,
            borderRadius: BorderRadius.circular(Radii.lg),
          ),
          child: Row(
            children: [
              const AppIcon('history', size: 22, color: T.warn),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  awaiting ? l.authConfirmEmailBody : l.authPendingBody,
                  style: AppType.ui(size: 13.5, color: T.text, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: _busy ? l.authBusy : l.authRefresh,
          full: true,
          icon: const AppIcon('refresh', size: 18, color: Colors.white),
          onTap: _busy ? null : _refresh,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: l.authSignOut,
          variant: BtnVariant.ghost,
          full: true,
          onTap: _busy
              ? null
              : () => ref.read(authNotifierProvider).signOut(),
        ),
      ],
    );
  }
}
