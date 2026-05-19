import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_providers.dart';
import '../../core/data/gym_repository_provider.dart';
import '../../core/routing/nav.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/haptics.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
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
    final me = ref.watch(currentMemberProvider).value;
    final paused = me?.isPaused ?? false;

    return ScreenFrame(
      child: SingleChildScrollView(
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
                              child: paused
                                  ? StatusPill(
                                      state: StatusState.muted,
                                      label: L.of(context).profPaused,
                                    )
                                  : StatusPill(
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
                        // Shortcut to the digital membership card (09). It is
                        // NOT a profile editor — members don't edit their own
                        // data in MVP (the owner manages it from Member
                        // Detail), so this shows a card icon, not a pencil,
                        // to stop reading as "edit profile".
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
                          child: const AppIcon('card', size: 15, color: T.text2),
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
                  _divider(),
                  if (paused)
                    // Members pause, but only Olda resumes (product rule) —
                    // surface that and route them to message him.
                    _actionRow(
                      icon: 'pause',
                      label: L.of(context).profPaused,
                      sub: L.of(context).profResumeByOwnerSub,
                      locked: true,
                      onTap: () => navCb(context)('mthread', arg: 'olda'),
                    )
                  else if ((me?.daysNum ?? 1) <= 0)
                    // Self-pause is only allowed once the prepaid period has
                    // run out; pausing mid-term is the owner's call.
                    _actionRow(
                      icon: 'pause',
                      label: L.of(context).profPauseLabel,
                      sub: L.of(context).profPauseSub,
                      onTap: () => _openPauseSheet(),
                    )
                  else
                    _actionRow(
                      icon: 'pause',
                      label: L.of(context).profPauseLabel,
                      sub: L.of(context).profPauseSubLocked,
                      locked: true,
                      onTap: () => _openPauseLockedSheet(),
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
                    onTap: () => nav('mthread', arg: 'olda'),
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

  /// A tappable row for the pause / resume membership action. [accent] tints
  /// it with the brand colour (used for "Resume").
  Widget _actionRow({
    required String icon,
    required String label,
    required String sub,
    required VoidCallback onTap,
    bool accent = false,
    bool locked = false,
  }) {
    final tint = locked
        ? T.text2
        : accent
            ? T.accent
            : T.text;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.s14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent ? T.accentSoft : T.surface2,
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: AppIcon(icon,
                  size: 15, color: accent ? T.accent : T.text2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppType.ui(
                      size: 14,
                      weight: FontWeight.w600,
                      color: tint,
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

  Future<void> _openPauseSheet() async {
    final l = L.of(context);
    final reasons = <String, String>{
      'holiday': l.pauseReasonHoliday,
      'illness': l.pauseReasonIllness,
      'other': l.pauseReasonOther,
    };
    String? selected;
    final confirmed = await _sheet<bool>(
      builder: (ctx, setSheet) => [
        _sheetHeader(l.pauseSheetTitle, l.pauseSheetBody),
        const SizedBox(height: 18),
        Text(
          l.pauseReasonHeading.toUpperCase(),
          style: AppType.ui(
            size: 11.5,
            weight: FontWeight.w600,
            color: T.text2,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reasons.entries.map((e) {
            final on = selected == e.key;
            return GestureDetector(
              onTap: () {
                Haptics.selection();
                setSheet(() => selected = on ? null : e.key);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Space.s14, vertical: 9),
                decoration: BoxDecoration(
                  color: on ? T.accentSoft : T.bg,
                  borderRadius: BorderRadius.circular(Radii.pill),
                  border: Border.all(color: on ? T.accent : T.border),
                ),
                child: Text(
                  e.value,
                  style: AppType.ui(
                    size: 13,
                    weight: FontWeight.w500,
                    color: on ? T.accent : T.text2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        AppButton(
          label: l.pauseConfirm,
          full: true,
          onTap: () => Navigator.of(ctx).pop(true),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;
    final reasonLabel = selected != null ? reasons[selected] : null;
    await ref.read(gymRepositoryProvider).pauseMembership(
          ref.read(currentMemberIdProvider),
          reason: selected,
          notice: reasonLabel != null
              ? l.pauseOwnerNotice(reasonLabel)
              : l.pauseOwnerNoticeNoReason,
        );
    ref.invalidate(currentMemberProvider);
    if (mounted) navCb(context)('profile', toast: l.pausedToast);
  }

  Future<void> _openPauseLockedSheet() async {
    final l = L.of(context);
    final write = await _sheet<bool>(
      builder: (ctx, setSheet) => [
        _sheetHeader(l.pauseLockedTitle, l.pauseLockedBody),
        const SizedBox(height: 22),
        AppButton(
          label: l.profWriteToOlda,
          full: true,
          icon: const AppIcon('message', size: 16),
          onTap: () => Navigator.of(ctx).pop(true),
        ),
      ],
    );
    if (write == true && mounted) navCb(context)('mthread', arg: 'olda');
  }

  Widget _sheetHeader(String title, String body) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppType.ui(
              size: 20,
              weight: FontWeight.w700,
              color: T.text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppType.ui(size: 13, color: T.text2, height: 1.5),
          ),
        ],
      );

  /// Themed bottom sheet matching the FaultReport sheet styling. The
  /// [builder] receives the sheet context and a setState for local sheet UI.
  Future<R?> _sheet<R>({
    required List<Widget> Function(
            BuildContext ctx, void Function(void Function()) setSheet)
        builder,
  }) {
    return showModalBottomSheet<R>(
      context: context,
      // Render above the shell so the floating bottom-nav bar doesn't sit on
      // top of the sheet (the branch navigator is *under* the nav bar) — this
      // was hiding the sheet's action button behind the tab bar.
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: T.scrim,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: T.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(top: 4, bottom: 18),
                      decoration: BoxDecoration(
                        color: T.surface2,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  ...builder(ctx, setSheet),
                ],
              ),
            ),
          ),
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
