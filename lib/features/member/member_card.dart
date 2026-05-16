import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/store/store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/status_pill.dart';
import '../../l10n/app_localizations.dart';

/// Member Card 09 — fullscreen membership card (Apple Wallet style).
/// Port of docs/design/gympass/project/screens/MemberCard.jsx.
class MemberCardScreen extends ConsumerWidget {
  const MemberCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    final member = store.memberById('pavel');

    final name = member?.name ?? 'Pavel Novák';
    final joined = member?.joined ?? '9 · 2025';
    final expiresAt = member?.expiresAt ?? '23. 6. 2026';
    final tariff = member?.tariff ?? 'Standard';
    final hasKey = member?.hasKey ?? true;
    final state = statusFromKey(member?.state ?? 'ok');

    // JSX: "člen od 9 · 2025" — joined string is "M · YYYY".
    final joinedLabel = L.of(context).cardJoinedSince(joined);

    return ScreenFrame(
      // Scrollable body. JSX page background is pure black (#000).
      child: Container(
              color: Colors.black,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110),
                child: Padding(
                  // JSX: padding 8px 20px 40px.
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // The card. marginTop 12.
                      const SizedBox(height: 12),
                      _MembershipCard(
                        name: name,
                        joinedLabel: joinedLabel,
                        expiresAt: expiresAt,
                        tariff: tariff,
                        hasKey: hasKey,
                        statusState: state,
                      ),
                      // Brightness tip. marginTop 20.
                      const SizedBox(height: 20),
                      _BrightnessTip(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final String name;
  final String joinedLabel;
  final String expiresAt;
  final String tariff;
  final bool hasKey;
  final StatusState statusState;

  const _MembershipCard({
    required this.name,
    required this.joinedLabel,
    required this.expiresAt,
    required this.tariff,
    required this.hasKey,
    required this.statusState,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: T.cardSheen,
          ),
          border: Border.all(color: T.border),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            // Accent corner glow — top -80, right -80, 260x260 radial.
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: T.accentGlowStrong,
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BÝTFIT',
                              style: AppType.ui(
                                size: 11,
                                weight: FontWeight.w700,
                                color: T.text2,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              L.of(context).cardSubtitle,
                              style: AppType.ui(
                                size: 11,
                                weight: FontWeight.w400,
                                color: T.text3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: T.surface,
                          borderRadius: BorderRadius.circular(Radii.s10),
                        ),
                        alignment: Alignment.center,
                        child: const AppIcon('dumbbell',
                            size: 18, color: T.accent),
                      ),
                    ],
                  ),
                  // Name. marginTop 32.
                  const SizedBox(height: 32),
                  Text(
                    name,
                    style: AppType.ui(
                      size: 26,
                      weight: FontWeight.w700,
                      color: T.text,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    joinedLabel,
                    style: AppType.mono(
                      size: 13,
                      weight: FontWeight.w400,
                      color: T.text2,
                    ),
                  ),
                  // Status grid. marginTop 28, 2 columns, gap 16.
                  const SizedBox(height: 28),
                  _StatusGrid(
                    expiresAt: expiresAt,
                    tariff: tariff,
                    hasKey: hasKey,
                    statusState: statusState,
                  ),
                  // Membership ID. marginTop 28.
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'BF-PN-260623',
                      style: AppType.mono(
                        size: 11,
                        weight: FontWeight.w400,
                        color: T.text3,
                        letterSpacing: 2,
                      ),
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

class _StatusGrid extends StatelessWidget {
  final String expiresAt;
  final String tariff;
  final bool hasKey;
  final StatusState statusState;

  const _StatusGrid({
    required this.expiresAt,
    required this.tariff,
    required this.hasKey,
    required this.statusState,
  });

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: AppType.ui(
          size: 10.5,
          weight: FontWeight.w700,
          color: T.text3,
          letterSpacing: 1,
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget cell(Widget label, Widget value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [label, const SizedBox(height: 6), value],
        );

    final keyValue = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: AppIcon('key', size: 14, color: T.text2),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            hasKey
                ? L.of(context).cardKeyWithYou
                : L.of(context).cardKeyAtReception,
            style: AppType.ui(
              size: 15,
              weight: FontWeight.w600,
              color: T.text,
            ),
          ),
        ),
      ],
    );

    final valueStyle = AppType.ui(
      size: 15,
      weight: FontWeight.w600,
      color: T.text,
    );
    final monoValueStyle = AppType.mono(
      size: 15,
      weight: FontWeight.w600,
      color: T.text,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: cell(
                _label(L.of(context).cardLabelStatus),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusPill(
                      state: statusState,
                      label: L.of(context).cardStatusActive),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: cell(
                _label(L.of(context).cardLabelValidUntil),
                Text(expiresAt, style: monoValueStyle),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: cell(
                _label(L.of(context).cardLabelTariff),
                Text(L.of(context).cardTariffValue(tariff),
                    style: valueStyle),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: cell(_label(L.of(context).cardLabelKey), keyValue),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrightnessTip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Space.s14),
      decoration: BoxDecoration(
        color: T.surface,
        border: Border.all(color: T.border),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: AppIcon('alert', size: 14, color: T.text3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              L.of(context).cardBrightnessTip,
              style: AppType.ui(
                size: 12.5,
                weight: FontWeight.w400,
                color: T.text2,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

