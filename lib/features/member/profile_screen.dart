import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/nav.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/round_icon_button.dart';
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

  static const _themeKeys = {
    ThemeMode.dark: 'dark',
    ThemeMode.system: 'system',
    ThemeMode.light: 'light',
  };
  static const _themeModes = {
    'dark': ThemeMode.dark,
    'system': ThemeMode.system,
    'light': ThemeMode.light,
  };

  @override
  Widget build(BuildContext context) {
    final nav = navCb(context);

    return ScreenFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back to dashboard (profile is reached from the home header,
                // no longer a bottom-nav tab).
                Align(
                  alignment: Alignment.centerLeft,
                  child: RoundIconButton(
                    icon: 'back',
                    onTap: () => nav('back'),
                  ),
                ),
                const SizedBox(height: 4),
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
                              L.of(context).profMemberSince,
                              style: AppType.ui(
                                size: 13,
                                weight: FontWeight.w400,
                                color: T.text2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: StatusPill(
                                state: StatusState.ok,
                                label: L.of(context).profActiveDays,
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
                _section(L.of(context).profSectionContact, [
                  _row(icon: 'message', label: L.of(context).profEmail, value: 'pavel.novak@email.cz'),
                  _divider(),
                  _row(
                    icon: 'bell',
                    label: L.of(context).profPhone,
                    value: '+420 728 451 209',
                    mono: true,
                  ),
                ]),

                // Členství
                _section(L.of(context).profSectionMembership, [
                  _row(icon: 'dumbbell', label: L.of(context).profTariff, value: L.of(context).profTariffValue),
                  _divider(),
                  _row(
                    icon: 'calendar',
                    label: L.of(context).profValidUntil,
                    value: '23. 6. 2026',
                    mono: true,
                  ),
                  _divider(),
                  _row(
                    icon: 'key',
                    label: L.of(context).profKey,
                    value: L.of(context).profKeyValue,
                    pill: const StatusPill(state: StatusState.ok, label: '100 Kč'),
                  ),
                ]),

                // Notifikace
                _section(L.of(context).profSectionNotifications, [
                  _toggle(
                    icon: 'bell',
                    label: L.of(context).profPushLabel,
                    sub: L.of(context).profPushSub,
                    value: _push,
                    onChange: (v) => setState(() => _push = v),
                  ),
                  _divider(),
                  _toggle(
                    icon: 'tool',
                    label: L.of(context).profOutageLabel,
                    sub: L.of(context).profOutageSub,
                    value: _outage,
                    onChange: (v) => setState(() => _outage = v),
                  ),
                  _divider(),
                  _toggle(
                    icon: 'tag',
                    label: L.of(context).profPromoLabel,
                    sub: L.of(context).profPromoSub,
                    value: _promo,
                    onChange: (v) => setState(() => _promo = v),
                  ),
                ]),

                // Vzhled & jazyk
                _section(L.of(context).appearanceAndLanguage, [
                  _segment(
                    icon: 'moon',
                    label: L.of(context).themeLabel,
                    value: _themeKeys[ref.watch(themeModeProvider)]!,
                    options: [
                      ['dark', L.of(context).themeDark],
                      ['system', L.of(context).themeSystem],
                      ['light', L.of(context).themeLight],
                    ],
                    onChange: (k) => ref
                        .read(themeModeProvider.notifier)
                        .set(_themeModes[k]!),
                  ),
                  _divider(),
                  _segment(
                    icon: 'globe',
                    label: L.of(context).languageLabel,
                    value: ref.watch(localeProvider).languageCode,
                    options: const [
                      ['cs', 'CZ'],
                      ['en', 'EN'],
                    ],
                    onChange: (k) => ref
                        .read(localeProvider.notifier)
                        .set(Locale(k)),
                  ),
                ]),

                // Pomoc
                _section(L.of(context).profSectionHelp, [
                  _navRow(
                    icon: 'help',
                    label: L.of(context).profFaqLabel,
                    sub: L.of(context).profFaqSub,
                  ),
                  _divider(),
                  _navRow(
                    icon: 'message',
                    label: L.of(context).profWriteToOlda,
                    sub: L.of(context).profWriteToOldaSub,
                    onTap: () => nav('thread', arg: 'pavel'),
                  ),
                ]),

                // Sign out
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(Space.s14),
                    decoration: BoxDecoration(
                      color: T.surface,
                      border: Border.all(color: T.border),
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Row(
                      children: [
                        const AppIcon('logout', size: 16, color: T.error),
                        const SizedBox(width: 12),
                        Text(
                          L.of(context).profSignOut,
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
                    L.of(context).profBuildInfo,
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
          borderRadius: BorderRadius.circular(Radii.sm),
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
      padding: const EdgeInsets.symmetric(horizontal: Space.s14, vertical: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: Space.s14, vertical: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: Space.s14, vertical: 12),
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
            padding: const EdgeInsets.all(Space.xxs),
            decoration: BoxDecoration(
              color: T.surface2,
              borderRadius: BorderRadius.circular(Radii.sm),
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
                      horizontal: Space.s10,
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
        padding: const EdgeInsets.symmetric(horizontal: Space.s14, vertical: 12),
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
          borderRadius: BorderRadius.circular(Radii.pill),
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
