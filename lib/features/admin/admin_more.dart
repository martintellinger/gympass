import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/data_providers.dart';
import '../../core/routing/nav.dart';
import '../../core/utils/haptics.dart';
import '../auth/application/auth_notifier.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../l10n/app_localizations.dart';

/// Admin More 17 — "Více": nastavení Klubu, nástěnka, schvalování, FAQ.
class AdminMoreScreen extends ConsumerWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberCount =
        ref.watch(membersProvider).value?.length ?? 0;
    final nav = navCb(context);
    final l = L.of(context);

    return ScreenFrame(
      child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.amoreTitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: T.text,
                  ),
                ),

                // Olda — vizitka
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(Space.s14),
                  decoration: BoxDecoration(
                    color: T.surface,
                    border: Border.all(color: T.border),
                    borderRadius: BorderRadius.circular(Radii.lg),
                  ),
                  child: Row(
                    children: [
                      const Avatar(name: 'Oldřich Klub', size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Oldřich Klub',
                              style: AppType.ui(
                                size: 15.5,
                                weight: FontWeight.w700,
                                color: T.text,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l.amoreOwnerSubtitle,
                              style: AppType.ui(
                                size: 12.5,
                                color: T.text2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppIcon('chevron', size: 16, color: T.text3),
                    ],
                  ),
                ),

                // Aktivita
                _SectionLabel(l.amoreSectionActivity),
                _MoreCard(children: [
                  _MoreRow(
                    icon: 'user_check',
                    label: l.amoreApprovalsLabel,
                    sub: l.amoreApprovalsSub,
                    badge: 2,
                    onTap: () => nav('approval'),
                  ),
                  const _MoreDivider(),
                  _MoreRow(
                    icon: 'board',
                    label: l.amoreBoardLabel,
                    sub: l.amoreBoardSub,
                    onTap: () => nav('adminBoard'),
                  ),
                  const _MoreDivider(),
                  _MoreRow(
                    icon: 'megaphone',
                    label: l.amoreBroadcastLabel,
                    sub: l.amoreBroadcastSub(memberCount),
                    onTap: () => nav('broadcast'),
                  ),
                ]),

                // Klub
                _SectionLabel(l.amoreSectionClub),
                _MoreCard(children: [
                  _MoreRow(
                    icon: 'tag',
                    label: l.amoreTariffsLabel,
                    sub: l.amoreTariffsSub,
                  ),
                  const _MoreDivider(),
                  _MoreRow(
                    icon: 'calendar',
                    label: l.amoreHoursLabel,
                    sub: l.amoreHoursSub,
                  ),
                  const _MoreDivider(),
                  _MoreRow(
                    icon: 'key',
                    label: l.amoreKeysLabel,
                    sub: l.amoreKeysSub,
                  ),
                  const _MoreDivider(),
                  _MoreRow(
                    icon: 'shield',
                    label: l.amoreRulesLabel,
                    sub: l.amoreRulesSub,
                  ),
                ]),

                // Data
                _SectionLabel(l.amoreSectionData),
                _MoreCard(children: [
                  _MoreRow(
                    icon: 'copy',
                    label: l.amoreImportLabel,
                    sub: l.amoreImportSub,
                    onTap: () => nav('excelImport'),
                  ),
                  const _MoreDivider(),
                  _MoreRow(
                    icon: 'download',
                    label: l.amoreExportLabel,
                    sub: l.amoreExportSub,
                  ),
                  const _MoreDivider(),
                  _MoreRow(
                    icon: 'refresh',
                    label: l.amoreBackupLabel,
                    sub: l.amoreBackupSub,
                  ),
                ]),

                // Účet
                _SectionLabel(l.amoreSectionAccount),
                _MoreCard(children: [
                  _MoreRow(
                    icon: 'help',
                    label: l.amoreHelpLabel,
                    sub: l.amoreHelpSub,
                  ),
                  const _MoreDivider(),
                  _MoreRow(
                    icon: 'logout',
                    label: l.amoreLogoutLabel,
                    danger: true,
                    onTap: () async {
                      Haptics.warning();
                      if (authNotifier.backendEnabled) {
                        // Real auth: sign-out flips the auth state; the
                        // router's refreshListenable redirects to /login.
                        await authNotifier.signOut();
                      } else if (context.mounted) {
                        // In-memory preview: back to the dev persona picker.
                        context.go('/');
                      }
                    },
                  ),
                ]),

                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    l.amoreVersion,
                    textAlign: TextAlign.center,
                    style: AppType.mono(
                      size: 11,
                      color: T.text3,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: AppType.ui(
          size: 11.5,
          weight: FontWeight.w600,
          color: T.text2,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _MoreCard extends StatelessWidget {
  const _MoreCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: T.surface,
        border: Border.all(color: T.border),
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(children: children),
    );
  }
}

class _MoreDivider extends StatelessWidget {
  const _MoreDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 56),
      color: T.divider,
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.icon,
    required this.label,
    this.sub,
    this.badge,
    this.danger = false,
    this.onTap,
  });

  final String icon;
  final String label;
  final String? sub;
  final int? badge;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: danger ? T.errorSoft : T.surface2,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: AppIcon(
              icon,
              size: 16,
              color: danger ? T.error : T.text,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppType.ui(
                    size: 14.5,
                    weight: FontWeight.w500,
                    color: danger ? T.error : T.text,
                    letterSpacing: -0.2,
                  ),
                ),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub!,
                    style: AppType.ui(size: 12, color: T.text2),
                  ),
                ],
              ],
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: T.accent,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
              child: Text(
                '$badge',
                style: AppType.mono(
                  size: 11,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          if (onTap != null) ...[
            const SizedBox(width: 12),
            AppIcon('chevron', size: 16, color: T.text3),
          ],
        ],
      ),
    );

    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}
