import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/nav.dart';
import '../../core/store/store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/status_pill.dart';

/// Member Dashboard 04 — home screen for the logged-in member.
/// Port of docs/design/gympass/project/screens/MemberDashboard.jsx.
class MemberDashboardScreen extends ConsumerWidget {
  const MemberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = navCb(context);
    final store = ref.watch(storeProvider);
    final member = store.memberById('pavel');
    final firstName = (member?.name ?? 'Pavel Novák').split(' ').first;

    return ScreenFrame(
      child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top header — minimal
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BÝTFIT',
                        style: AppType.ui(
                          size: 13,
                          weight: FontWeight.w600,
                          color: T.text2,
                          letterSpacing: 0.4,
                        ),
                      ),
                      _BoardBell(onTap: () => nav('board')),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Text(
                        L.of(context).dashGreeting(firstName),
                        style: AppType.ui(
                          size: 15,
                          color: T.text2,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8 - 4),

                      // Big status
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              L.of(context).dashStatusHeadline,
                              style: AppType.ui(
                                size: 32,
                                weight: FontWeight.w700,
                                color: T.text,
                                letterSpacing: -1,
                                height: 1.15,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '23',
                                    style: AppType.ui(
                                      size: 64,
                                      weight: FontWeight.w700,
                                      color: T.accent,
                                      letterSpacing: -2.4,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    L.of(context).dashDaysUnit,
                                    style: AppType.ui(
                                      size: 28,
                                      weight: FontWeight.w500,
                                      color: T.text2,
                                      letterSpacing: -0.6,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expiry date
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            const AppIcon('calendar',
                                size: 14, color: T.text2),
                            const SizedBox(width: 6),
                            Text(
                              L.of(context).dashExpiryDate,
                              style: AppType.mono(
                                size: 14,
                                weight: FontWeight.w500,
                                color: T.text2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Primary CTA
                      const SizedBox(height: 24),
                      AppButton(
                        label: L.of(context).dashExtendMembership,
                        full: true,
                        onTap: () => nav('qr'),
                      ),

                      // Secondary CTA — report fault
                      const SizedBox(height: 10),
                      AppButton(
                        label: L.of(context).dashReportFault,
                        variant: BtnVariant.ghost,
                        full: true,
                        height: 44,
                        icon: const AppIcon('tool', size: 16),
                        onTap: () => nav('fault'),
                      ),

                      // Member card preview
                      const SizedBox(height: 28),
                      _SectionLabel(text: L.of(context).dashYourCard),
                      const SizedBox(height: 12),
                      _MemberCardPreview(onTap: () => nav('card')),

                      // Poslední aktivity
                      const SizedBox(height: 24),
                      _SectionLabel(
                        text: L.of(context).dashRecentActivity,
                        right: Text(
                          L.of(context).dashAll,
                          style: AppType.ui(
                            size: 12.5,
                            color: T.text2,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: const [
                            _ActivityRow(
                              icon: 'refresh',
                              title: 'Prodloužení (3 měsíce)',
                              date: '23. 3. 2026',
                              amount: '+90 dní',
                              amountSub: '2 250 Kč',
                            ),
                            _ActivityDivider(),
                            _ActivityRow(
                              icon: 'refresh',
                              title: 'Prodloužení (3 měsíce)',
                              date: '22. 12. 2025',
                              amount: '+90 dní',
                              amountSub: '2 250 Kč',
                            ),
                            _ActivityDivider(),
                            _ActivityRow(
                              icon: 'key',
                              title: 'Vydán klíč + kauce',
                              date: '14. 9. 2025',
                              amount: '100 Kč',
                              amountSub: '',
                              muted: true,
                            ),
                          ],
                        ),
                      ),

                      // Nástěnka preview
                      const SizedBox(height: 24),
                      _SectionLabel(
                        text: L.of(context).dashBoard,
                        right: GestureDetector(
                          onTap: () => nav('board'),
                          child: Text(
                            L.of(context).dashBoardAll,
                            style: AppType.ui(
                              size: 12.5,
                              color: T.accent,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _BoardPreview(onTap: () => nav('board')),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

/// SectionLabel — uppercase, 12.5/600, text2, optional right widget.
class _SectionLabel extends StatelessWidget {
  final String text;
  final Widget? right;
  const _SectionLabel({required this.text, this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text.toUpperCase(),
          style: AppType.ui(
            size: 12.5,
            weight: FontWeight.w600,
            color: T.text2,
            letterSpacing: 0.4,
          ),
        ),
        ?right,
      ],
    );
  }
}

/// Board bell button with unread indicator (top-right of header).
class _BoardBell extends StatelessWidget {
  final VoidCallback onTap;
  const _BoardBell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: T.surface,
                shape: BoxShape.circle,
                border: Border.all(color: T.border),
              ),
              alignment: Alignment.center,
              child: const AppIcon('board', size: 18, color: T.text2),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: T.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: T.bg, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Member card preview — gradient card with dumbbell icon + status.
class _MemberCardPreview extends StatelessWidget {
  final VoidCallback onTap;
  const _MemberCardPreview({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: T.cardSheenSoft,
            ),
            border: Border.all(color: T.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              // soft accent radial glow, top-right
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: T.accentGlow,
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: T.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: T.border),
                      ),
                      alignment: Alignment.center,
                      child: const AppIcon('dumbbell',
                          size: 22, color: T.accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pavel Novák',
                            style: AppType.ui(
                              size: 15,
                              weight: FontWeight.w600,
                              color: T.text,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              StatusPill(
                                  state: StatusState.ok,
                                  label: L.of(context).dashStatusActive),
                              const SizedBox(width: 6),
                              const AppIcon('key', size: 12, color: T.text2),
                              const SizedBox(width: 4),
                              Text(
                                L.of(context).dashKeyWithYou,
                                style: AppType.ui(
                                  size: 12,
                                  color: T.text2,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const AppIcon('chevron', size: 18, color: T.text3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single activity row inside the activities card.
class _ActivityRow extends StatelessWidget {
  final String icon;
  final String title;
  final String date;
  final String amount;
  final String amountSub;
  final bool muted;

  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.amountSub,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: T.surface2,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: AppIcon(
              icon,
              size: 16,
              stroke: 1.8,
              color: muted ? T.text2 : T.text,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppType.ui(
                    size: 14.5,
                    weight: FontWeight.w500,
                    color: T.text,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: AppType.mono(
                    size: 12.5,
                    weight: FontWeight.w500,
                    color: T.text2,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppType.mono(
                  size: 14,
                  weight: FontWeight.w600,
                  color: muted ? T.text2 : T.text,
                ),
              ),
              if (amountSub.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  amountSub,
                  style: AppType.mono(
                    size: 12,
                    weight: FontWeight.w500,
                    color: T.text3,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Divider between activity rows — indented 56px from the left.
class _ActivityDivider extends StatelessWidget {
  const _ActivityDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 56),
      color: T.divider,
    );
  }
}

/// Nástěnka preview card — pinned post with accent rail.
class _BoardPreview extends StatelessWidget {
  final VoidCallback onTap;
  const _BoardPreview({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: T.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: T.accent),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            L.of(context).dashPinned,
                            style: AppType.ui(
                              size: 9.5,
                              weight: FontWeight.w700,
                              color: T.accent,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          L.of(context).dashBoardTimeAgo,
                          style: AppType.mono(
                            size: 11.5,
                            weight: FontWeight.w500,
                            color: T.text3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      L.of(context).dashBoardPostTitle,
                      style: AppType.ui(
                        size: 15,
                        weight: FontWeight.w600,
                        color: T.text,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      L.of(context).dashBoardPostBody,
                      style: AppType.ui(
                        size: 13.5,
                        color: T.text2,
                        letterSpacing: -0.2,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
