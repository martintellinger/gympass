import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/kv_row.dart';
import '../../shared/widgets/round_icon_button.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/section_label.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/widgets/status_pill.dart';

/// Živý styleguide — referenční přehled design systému (tokeny, typografie,
/// komponenty). Není součástí produktového flow; slouží ke kontrole, že
/// jednotlivé primitivy renderují konzistentně. Odkaz vede z PersonaPicker.
class StyleguideScreen extends StatelessWidget {
  const StyleguideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Space.lg, Space.md, Space.lg, Space.md),
            child: Row(
              children: [
                RoundIconButton(
                  icon: 'back',
                  onTap: () => context.pop(),
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Design systém', style: AppType.h2()),
                      Text('BýtFit Klub · referenční přehled',
                          style: AppType.caption()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  Space.lg, Space.sm, Space.lg, Space.s32),
              children: const [
                _ColorsSection(),
                SizedBox(height: Space.s28),
                _TypographySection(),
                SizedBox(height: Space.s28),
                _StatusSection(),
                SizedBox(height: Space.s28),
                _ButtonsSection(),
                SizedBox(height: Space.s28),
                _CardsSection(),
                SizedBox(height: Space.s28),
                _AvatarsSection(),
                SizedBox(height: Space.s28),
                _SkeletonSection(),
                SizedBox(height: Space.s28),
                _SpacingSection(),
                SizedBox(height: Space.s28),
                _RadiiSection(),
                SizedBox(height: Space.s28),
                _IconsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section scaffold ───────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section(this.title, {required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title),
        const SizedBox(height: Space.md),
        child,
      ],
    );
  }
}

// ── Colors ─────────────────────────────────────────────────────────────────

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  @override
  Widget build(BuildContext context) {
    const swatches = <(String, Color)>[
      ('bg', T.bg),
      ('surface', T.surface),
      ('surface2', T.surface2),
      ('border', T.border),
      ('text', T.text),
      ('text2', T.text2),
      ('text3', T.text3),
      ('accent', T.accent),
      ('accentSoft', T.accentSoft),
      ('ok', T.ok),
      ('warn', T.warn),
      ('error', T.error),
      ('event', T.event),
    ];
    return _Section(
      'Barvy',
      child: Wrap(
        spacing: Space.md,
        runSpacing: Space.md,
        children: [
          for (final (name, color) in swatches) _Swatch(name, color),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final String name;
  final Color color;
  const _Swatch(this.name, this.color);

  @override
  Widget build(BuildContext context) {
    final hex = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: T.border),
            ),
          ),
          const SizedBox(height: Space.s6),
          Text(name, style: AppType.label()),
          Text(hex, style: AppType.mono(size: 10, color: T.text2)),
        ],
      ),
    );
  }
}

// ── Typography ─────────────────────────────────────────────────────────────

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      'Typografie — Inter',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Type('hero · 48 / 800', Text('128', style: AppType.hero())),
            _Type('display · 32 / 700',
                Text('Vyberte si roli', style: AppType.display())),
            _Type('h1 · 28 / 700', Text('Nástěnka', style: AppType.h1())),
            _Type('h2 · 22 / 700',
                Text('Sekce karty', style: AppType.h2())),
            _Type('title · 17 / 600',
                Text('Pavel Novák', style: AppType.title())),
            _Type('body · 15 / 400',
                Text('Běžný text odstavce.', style: AppType.body())),
            _Type('bodySm · 13.5 / 400',
                Text('Sekundární text.', style: AppType.bodySm())),
            _Type('label · 13 / 500',
                Text('Popisek pole', style: AppType.label())),
            _Type('caption · 12 / 500',
                Text('Drobná meta', style: AppType.caption())),
            _Type('overline · 12 / 600',
                Text('SEKCE'.toUpperCase(), style: AppType.overline())),
            _Type('mono · JetBrains Mono',
                Text('850 Kč · 17. 5. 2026', style: AppType.mono(size: 14)),
                last: true),
          ],
        ),
      ),
    );
  }
}

class _Type extends StatelessWidget {
  final String spec;
  final Widget sample;
  final bool last;
  const _Type(this.spec, this.sample, {this.last = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(spec, style: AppType.caption(color: T.text3)),
          const SizedBox(height: Space.xs),
          sample,
        ],
      ),
    );
  }
}

// ── Status ─────────────────────────────────────────────────────────────────

class _StatusSection extends StatelessWidget {
  const _StatusSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      'Stavové prvky',
      child: AppCard(
        child: Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            StatusPill(state: StatusState.ok, label: 'Aktivní'),
            StatusPill(state: StatusState.warn, label: 'Končí brzy'),
            StatusPill(state: StatusState.error, label: 'Expirováno'),
            StatusPill(state: StatusState.muted, label: 'Pozastaveno'),
            StatusDot(state: StatusState.ok),
            StatusDot(state: StatusState.warn),
            StatusDot(state: StatusState.error),
            StatusDot(state: StatusState.muted),
          ],
        ),
      ),
    );
  }
}

// ── Buttons ────────────────────────────────────────────────────────────────

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      'Tlačítka',
      child: Column(
        children: [
          AppButton(label: 'Primary', full: true, onTap: () {}),
          const SizedBox(height: Space.sm),
          AppButton(
              label: 'Ghost',
              variant: BtnVariant.ghost,
              full: true,
              onTap: () {}),
          const SizedBox(height: Space.sm),
          AppButton(
              label: 'Secondary',
              variant: BtnVariant.secondary,
              full: true,
              onTap: () {}),
          const SizedBox(height: Space.sm),
          AppButton(
              label: 'Danger',
              variant: BtnVariant.danger,
              full: true,
              onTap: () {}),
          const SizedBox(height: Space.sm),
          AppButton(
            label: 'S ikonou',
            full: true,
            icon: const AppIcon('qr', size: 20, color: Colors.white),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ── Cards ──────────────────────────────────────────────────────────────────

class _CardsSection extends StatelessWidget {
  const _CardsSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      'Karty a řádky',
      child: AppCard(
        child: Column(
          children: [
            const KVRow(label: 'Tarif', value: 'Standard'),
            const KVRow(label: 'Cena', value: '850 Kč', mono: true),
            const KVRow(
              label: 'Stav',
              valueWidget: StatusPill(state: StatusState.ok, label: 'Aktivní'),
            ),
            const Divider(color: T.border, height: Space.xxl),
            Row(
              children: [
                Expanded(
                  child: Text('AppCard · surface, border, radius 16',
                      style: AppType.bodySm()),
                ),
                const AppIcon('chevron', size: 18, color: T.text2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatars ────────────────────────────────────────────────────────────────

class _AvatarsSection extends StatelessWidget {
  const _AvatarsSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      'Avatary',
      child: Wrap(
        spacing: Space.md,
        runSpacing: Space.md,
        children: const [
          Avatar(name: 'Pavel Novák'),
          Avatar(name: 'Olda Majitel'),
          Avatar(name: 'Jana Dvořáková'),
          Avatar(name: 'Tomáš Svoboda'),
          Avatar(name: 'Eva Černá', size: 56),
        ],
      ),
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────────────────

class _SkeletonSection extends StatelessWidget {
  const _SkeletonSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      'Skeleton (loading >300 ms)',
      child: AppCard(child: const SkeletonList(rows: 3)),
    );
  }
}

// ── Spacing ────────────────────────────────────────────────────────────────

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  @override
  Widget build(BuildContext context) {
    const steps = <(String, double)>[
      ('xs', Space.xs),
      ('sm', Space.sm),
      ('md', Space.md),
      ('lg', Space.lg),
      ('xl', Space.xl),
      ('xxl', Space.xxl),
      ('s32', Space.s32),
    ];
    return _Section(
      'Spacing (2-pt rytmus)',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (name, v) in steps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.xs),
                child: Row(
                  children: [
                    SizedBox(
                        width: 44,
                        child: Text(name, style: AppType.label())),
                    SizedBox(
                        width: 36,
                        child: Text('${v.toInt()}',
                            style: AppType.mono(size: 12, color: T.text2))),
                    Container(
                      width: v,
                      height: 14,
                      decoration: BoxDecoration(
                        color: T.accent,
                        borderRadius: BorderRadius.circular(Radii.xs),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Radii ──────────────────────────────────────────────────────────────────

class _RadiiSection extends StatelessWidget {
  const _RadiiSection();

  @override
  Widget build(BuildContext context) {
    const steps = <(String, double)>[
      ('sm', Radii.sm),
      ('md', Radii.md),
      ('lg', Radii.lg),
      ('xl', Radii.xl),
      ('pill', Radii.pill),
    ];
    return _Section(
      'Zaoblení rohů',
      child: Wrap(
        spacing: Space.md,
        runSpacing: Space.md,
        children: [
          for (final (name, r) in steps)
            Column(
              children: [
                Container(
                  width: 64,
                  height: 48,
                  decoration: BoxDecoration(
                    color: T.surface2,
                    border: Border.all(color: T.border),
                    borderRadius: BorderRadius.circular(r),
                  ),
                ),
                const SizedBox(height: Space.s6),
                Text(name, style: AppType.caption()),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Icons ──────────────────────────────────────────────────────────────────

class _IconsSection extends StatelessWidget {
  const _IconsSection();

  static const _names = [
    'home', 'card', 'history', 'bell', 'user', 'qr', 'arrowRight',
    'arrowLeft', 'check', 'x', 'plus', 'search', 'filter', 'key', 'shield',
    'alert', 'trend', 'message', 'download', 'copy', 'wallet', 'refresh',
    'more', 'chevron', 'back', 'dumbbell', 'sliders', 'edit', 'user_check',
    'trash', 'pause', 'cash', 'send', 'user_plus', 'calendar', 'isic',
    'board', 'megaphone', 'spark', 'globe', 'moon', 'help', 'logout',
    'pin', 'tool', 'tag',
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      'Ikony (${_names.length})',
      child: AppCard(
        child: Wrap(
          spacing: Space.lg,
          runSpacing: Space.lg,
          children: [
            for (final n in _names)
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    AppIcon(n, size: 22, color: T.text),
                    const SizedBox(height: Space.s6),
                    Text(n,
                        textAlign: TextAlign.center,
                        style: AppType.caption(color: T.text2)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
