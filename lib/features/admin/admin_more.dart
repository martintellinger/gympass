import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/store/store.dart';
import '../../core/routing/nav.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/widgets/screen_frame.dart';

/// Admin More 17 — "Více": nastavení Klubu, nástěnka, schvalování, FAQ.
class AdminMoreScreen extends ConsumerWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    final nav = navCb(context);

    return ScreenFrame(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Více',
                  style: TextStyle(
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: T.surface,
                    border: Border.all(color: T.border),
                    borderRadius: BorderRadius.circular(14),
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
                              'majitel · BýtFit Klub',
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
                const _SectionLabel('Aktivita'),
                _MoreCard(children: [
                  _MoreRow(
                    icon: 'user_check',
                    label: 'Schvalování registrací',
                    sub: '2 čekající žádosti',
                    badge: 2,
                    onTap: () => nav('approval'),
                  ),
                  const _MoreDivider(),
                  _MoreRow(
                    icon: 'board',
                    label: 'Nástěnka',
                    sub: 'Připnout, mimo provoz, akce',
                    onTap: () => nav('board'),
                  ),
                  const _MoreDivider(),
                  _MoreRow(
                    icon: 'megaphone',
                    label: 'Hromadná zpráva všem',
                    sub: '${store.members.length} členů',
                    onTap: () => nav('broadcast'),
                  ),
                ]),

                // Klub
                const _SectionLabel('Klub'),
                _MoreCard(children: [
                  const _MoreRow(
                    icon: 'tag',
                    label: 'Tarify a ceny',
                    sub: 'Standard 2 250 · Student 1 500 · 6m / 12m',
                  ),
                  const _MoreDivider(),
                  const _MoreRow(
                    icon: 'calendar',
                    label: 'Otevírací doba',
                    sub: 'Po–Pá 6:00–22:00 · So–Ne 8:00–20:00',
                  ),
                  const _MoreDivider(),
                  const _MoreRow(
                    icon: 'key',
                    label: 'Klíče a kauce',
                    sub: '34 vydaných · 2 propadlé kauce',
                  ),
                  const _MoreDivider(),
                  const _MoreRow(
                    icon: 'shield',
                    label: 'Pravidla Klubu',
                    sub: 'Naposledy aktualizováno 3. 4. 2026',
                  ),
                ]),

                // Data
                const _SectionLabel('Data'),
                _MoreCard(children: [
                  const _MoreRow(
                    icon: 'download',
                    label: 'Export plateb (CSV)',
                    sub: 'Pro účetnictví · poslední 12 měsíců',
                  ),
                  const _MoreDivider(),
                  const _MoreRow(
                    icon: 'refresh',
                    label: 'Záloha databáze',
                    sub: 'Poslední záloha · dnes 03:00',
                  ),
                ]),

                // Účet
                const _SectionLabel('Účet'),
                _MoreCard(children: [
                  const _MoreRow(
                    icon: 'help',
                    label: 'Nápověda & FAQ',
                    sub: 'Pravidla aplikace, dotazy',
                  ),
                  const _MoreDivider(),
                  const _MoreRow(
                    icon: 'logout',
                    label: 'Odhlásit Oldu',
                    danger: true,
                  ),
                ]),

                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'BÝTFIT KLUB · v1.0.0',
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AdminBottomNav(
              active: 4,
              onNav: (route) => nav(route),
              unread: store.totalUnread(),
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(14),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
                borderRadius: BorderRadius.circular(100),
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
