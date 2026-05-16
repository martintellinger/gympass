import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/nav.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/status_pill.dart';

/// Profile 08 — profil člena (údaje, nastavení, klíč, odhlášení).
class ProfileScreenView extends ConsumerStatefulWidget {
  const ProfileScreenView({super.key});

  @override
  ConsumerState<ProfileScreenView> createState() => _ProfileScreenViewState();
}

class _ProfileScreenViewState extends ConsumerState<ProfileScreenView> {
  bool _push = true;
  bool _outage = true;
  bool _promo = false;
  String _lang = 'cs';
  String _theme = 'dark';

  @override
  Widget build(BuildContext context) {
    final nav = navCb(context);

    return ScreenFrame(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Avatar(name: 'Pavel Novák', size: 64),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pavel Novák',
                              style: AppType.ui(
                                size: 20,
                                weight: FontWeight.w700,
                                color: T.text,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'člen od 9 · 2025',
                              style: AppType.ui(
                                size: 13,
                                weight: FontWeight.w400,
                                color: T.text2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: StatusPill(
                                state: StatusState.ok,
                                label: 'Aktivní · 23 dní',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => nav('card'),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: T.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: T.border),
                          ),
                          child: const AppIcon('edit', size: 14, color: T.text2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Kontakt
                _section('Kontakt', [
                  _row(icon: 'message', label: 'E-mail', value: 'pavel.novak@email.cz'),
                  _divider(),
                  _row(
                    icon: 'bell',
                    label: 'Telefon',
                    value: '+420 728 451 209',
                    mono: true,
                  ),
                ]),

                // Členství
                _section('Členství', [
                  _row(icon: 'dumbbell', label: 'Tarif', value: 'Standard · 3 měs.'),
                  _divider(),
                  _row(
                    icon: 'calendar',
                    label: 'Platí do',
                    value: '23. 6. 2026',
                    mono: true,
                  ),
                  _divider(),
                  _row(
                    icon: 'key',
                    label: 'Klíč',
                    value: 'u tebe',
                    pill: const StatusPill(state: StatusState.ok, label: '100 Kč'),
                  ),
                ]),

                // Notifikace
                _section('Notifikace', [
                  _toggle(
                    icon: 'bell',
                    label: 'Push notifikace',
                    sub: 'Konec členství, schválení žádostí',
                    value: _push,
                    onChange: (v) => setState(() => _push = v),
                  ),
                  _divider(),
                  _toggle(
                    icon: 'tool',
                    label: 'Výpadky a zavírací doba',
                    sub: 'Když je v Klubu něco mimo provoz',
                    value: _outage,
                    onChange: (v) => setState(() => _outage = v),
                  ),
                  _divider(),
                  _toggle(
                    icon: 'tag',
                    label: 'Akce a slevy',
                    sub: 'Občas, ne víc než 1× měsíčně',
                    value: _promo,
                    onChange: (v) => setState(() => _promo = v),
                  ),
                ]),

                // Vzhled & jazyk
                _section('Vzhled & jazyk', [
                  _segment(
                    icon: 'moon',
                    label: 'Téma',
                    value: _theme,
                    options: const [
                      ['dark', 'Tmavé'],
                      ['system', 'Systém'],
                      ['light', 'Světlé'],
                    ],
                    onChange: (k) => setState(() => _theme = k),
                  ),
                  _divider(),
                  _segment(
                    icon: 'globe',
                    label: 'Jazyk',
                    value: _lang,
                    options: const [
                      ['cs', 'CZ'],
                      ['en', 'EN'],
                    ],
                    onChange: (k) => setState(() => _lang = k),
                  ),
                ]),

                // Pomoc
                _section('Pomoc', [
                  _navRow(
                    icon: 'help',
                    label: 'FAQ',
                    sub: 'Časté otázky a pravidla Klubu',
                  ),
                  _divider(),
                  _navRow(
                    icon: 'message',
                    label: 'Napsat Oldovi',
                    sub: 'Odpovídá obvykle do hodiny',
                    onTap: () => nav('thread', arg: 'pavel'),
                  ),
                ]),

                // Sign out
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: T.surface,
                      border: Border.all(color: T.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const AppIcon('logout', size: 16, color: T.error),
                        const SizedBox(width: 12),
                        Text(
                          'Odhlásit',
                          style: AppType.ui(
                            size: 14.5,
                            weight: FontWeight.w500,
                            color: T.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Text(
                    'BýtFit Klub · v1.0.0 · sestaveno 5/2026',
                    textAlign: TextAlign.center,
                    style: AppType.ui(
                      size: 11,
                      weight: FontWeight.w400,
                      color: T.text3,
                      height: 1.5,
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
            child: MemberBottomNav(active: 4, onNav: nav),
          ),
        ],
      ),
    );
  }

  Widget _section(String label, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label.toUpperCase(),
              style: AppType.ui(
                size: 11.5,
                weight: FontWeight.w600,
                color: T.text2,
                letterSpacing: 0.4,
              ),
            ),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.only(left: 50),
        color: T.divider,
      );

  Widget _leadIcon(String icon) => Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: T.surface2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: AppIcon(icon, size: 15, color: T.text2),
      );

  Widget _row({
    required String icon,
    required String label,
    required String value,
    bool mono = false,
    Widget? pill,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _leadIcon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppType.ui(
                    size: 11.5,
                    weight: FontWeight.w400,
                    color: T.text2,
                  ),
                ),
                const SizedBox(height: 2),
                mono
                    ? Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.mono(
                          size: 14,
                          weight: FontWeight.w500,
                          color: T.text,
                          letterSpacing: 0,
                        ),
                      )
                    : Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.ui(
                          size: 14,
                          weight: FontWeight.w500,
                          color: T.text,
                          letterSpacing: -0.1,
                        ),
                      ),
              ],
            ),
          ),
          if (pill != null) ...[
            const SizedBox(width: 12),
            pill,
          ],
        ],
      ),
    );
  }

  Widget _toggle({
    required String icon,
    required String label,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChange,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _leadIcon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppType.ui(
                    size: 14,
                    weight: FontWeight.w500,
                    color: T.text,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: AppType.ui(
                    size: 11.5,
                    weight: FontWeight.w400,
                    color: T.text2,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _Switch(value: value, onChange: () => onChange(!value)),
        ],
      ),
    );
  }

  Widget _segment({
    required String icon,
    required String label,
    required String value,
    required List<List<String>> options,
    required ValueChanged<String> onChange,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _leadIcon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppType.ui(
                size: 14,
                weight: FontWeight.w500,
                color: T.text,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: T.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: T.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: options.map((opt) {
                final k = opt[0];
                final lbl = opt[1];
                final active = value == k;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChange(k),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: active ? T.bg : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      lbl,
                      style: AppType.ui(
                        size: 11.5,
                        weight: FontWeight.w600,
                        color: active ? T.text : T.text2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navRow({
    required String icon,
    required String label,
    required String sub,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _leadIcon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppType.ui(
                      size: 14,
                      weight: FontWeight.w500,
                      color: T.text,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: AppType.ui(
                      size: 11.5,
                      weight: FontWeight.w400,
                      color: T.text2,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const AppIcon('chevron', size: 16, color: T.text3),
          ],
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;
  final VoidCallback onChange;
  const _Switch({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onChange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 42,
        height: 24,
        decoration: BoxDecoration(
          color: value ? T.accent : T.surface2,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: value ? T.accent : T.border),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 160),
              top: 2,
              left: value ? 20 : 2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(0x4D),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
