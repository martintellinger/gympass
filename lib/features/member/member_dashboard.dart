import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_providers.dart';
import '../../core/format.dart';
import '../../core/routing/nav.dart';
import '../../core/store/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/widgets/status_pill.dart';

/// Parses the member's `expiresAt` display string ("23. 6. 2026") back to a
/// date for the timeline math. Returns null for "—" / unparseable.
DateTime? _parseCzDate(String s) {
  final m = RegExp(r'(\d{1,2})\.\s*(\d{1,2})\.\s*(\d{4})').firstMatch(s);
  if (m == null) return null;
  return DateTime(
      int.parse(m.group(3)!), int.parse(m.group(2)!), int.parse(m.group(1)!));
}

/// Member Dashboard 04 — home screen for the logged-in member.
/// Port of docs/design/gympass/project/screens/MemberDashboard.jsx.
class MemberDashboardScreen extends ConsumerWidget {
  const MemberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = navCb(context);
    final member = ref.watch(currentMemberProvider).value;

    if (member == null) {
      return const ScreenFrame(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: SkeletonList(rows: 6),
        ),
      );
    }

    final firstName = member.name.split(' ').first;
    final days = member.daysNum < 0 ? 0 : member.daysNum;

    final myPayments =
        (ref.watch(paymentsProvider).value ?? const <Payment>[])
            .where((p) => p.memberId == member.id && p.state == 'ok')
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final posts = ref.watch(boardPostsProvider).value ?? const <BoardPost>[];
    final BoardPost? topPost = posts.isEmpty
        ? null
        : (posts.firstWhere((p) => p.pinned, orElse: () => posts.first));

    // Timeline: period start = most recent payment, end = expiry date.
    final now = DateTime.now();
    final lastPay = myPayments.isNotEmpty ? myPayments.first.date : null;
    final expiryD = _parseCzDate(member.expiresAt);
    Widget? timeline;
    if (lastPay != null &&
        expiryD != null &&
        expiryD.isAfter(lastPay)) {
      final total = expiryD.difference(lastPay).inDays;
      final elapsed = now.difference(lastPay).inDays;
      timeline = _MembershipTimeline(
        startLabel: '${lastPay.day}. ${lastPay.month}.',
        endLabel: '${expiryD.day}. ${expiryD.month}.',
        progress: total <= 0 ? 1.0 : elapsed / total,
      );
    }

    return ScreenFrame(
      child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top header — minimal
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                  child: Text(
                    'BÝTFIT',
                    style: AppType.ui(
                      size: 13,
                      weight: FontWeight.w600,
                      color: T.text2,
                      letterSpacing: 0.4,
                    ),
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$days',
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
                              member.expiresAt,
                              style: AppType.mono(
                                size: 14,
                                weight: FontWeight.w500,
                                color: T.text2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Membership timeline — visual progress until expiry
                      if (timeline != null) ...[
                        const SizedBox(height: 18),
                        timeline,
                      ],

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
                      _MemberCardPreview(
                        name: member.name,
                        state: member.state,
                        hasKey: member.hasKey,
                        onTap: () => nav('card'),
                      ),

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
                        padding: myPayments.isEmpty
                            ? const EdgeInsets.all(Space.s14)
                            : EdgeInsets.zero,
                        child: myPayments.isEmpty
                            ? Text(
                                L.of(context).histEmptyFilter,
                                style: AppType.ui(
                                    size: 13.5, color: T.text3),
                              )
                            : Column(
                                children: [
                                  for (var i = 0;
                                      i <
                                          (myPayments.length > 4
                                              ? 4
                                              : myPayments.length);
                                      i++) ...[
                                    if (i > 0) const _ActivityDivider(),
                                    _ActivityRow(
                                      icon: 'refresh',
                                      title: myPayments[i].type,
                                      date:
                                          '${myPayments[i].date.day}. ${myPayments[i].date.month}. ${myPayments[i].date.year}',
                                      amount:
                                          '${groupThousands(myPayments[i].amount)} Kč',
                                      amountSub: myPayments[i].tariff,
                                    ),
                                  ],
                                ],
                              ),
                      ),

                      // Nástěnka preview
                      if (topPost != null) ...[
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
                        _BoardPreview(
                            post: topPost, onTap: () => nav('board')),
                      ],
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

/// Membership timeline — a thin progress track showing how far through the
/// current paid period the member is, with the period bounds as endpoints.
class _MembershipTimeline extends StatelessWidget {
  final String startLabel;
  final String endLabel;

  /// 0.0–1.0 — fraction of the period elapsed.
  final double progress;

  const _MembershipTimeline({
    required this.startLabel,
    required this.endLabel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            const trackH = 6.0;
            const thumb = 12.0;
            final fillW = (c.maxWidth * p).clamp(0.0, c.maxWidth);
            return SizedBox(
              height: thumb,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: trackH,
                      decoration: BoxDecoration(
                        color: T.surface2,
                        borderRadius: BorderRadius.circular(trackH / 2),
                      ),
                    ),
                  ),
                  // Filled portion
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: trackH,
                      width: fillW,
                      decoration: BoxDecoration(
                        color: T.accent,
                        borderRadius: BorderRadius.circular(trackH / 2),
                      ),
                    ),
                  ),
                  // Current-position thumb
                  Positioned(
                    left: (fillW - thumb / 2).clamp(0.0, c.maxWidth - thumb),
                    top: 0,
                    child: Container(
                      width: thumb,
                      height: thumb,
                      decoration: BoxDecoration(
                        color: T.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: T.bg, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              startLabel,
              style: AppType.mono(
                size: 11.5,
                weight: FontWeight.w500,
                color: T.text3,
              ),
            ),
            Text(
              endLabel,
              style: AppType.mono(
                size: 11.5,
                weight: FontWeight.w500,
                color: T.text2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Board bell button with unread indicator (top-right of header).

/// Member card preview — gradient card with dumbbell icon + status.
class _MemberCardPreview extends StatelessWidget {
  final String name;
  final String state;
  final bool hasKey;
  final VoidCallback onTap;
  const _MemberCardPreview({
    required this.name,
    required this.state,
    required this.hasKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.s18),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: T.cardSheenSoft,
            ),
            border: Border.all(color: T.border),
            borderRadius: BorderRadius.circular(Radii.s18),
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
                padding: const EdgeInsets.all(Space.s18),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: T.bg,
                        borderRadius: BorderRadius.circular(Radii.md),
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
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                                  state: statusFromKey(state),
                                  label: L.of(context).dashStatusActive),
                              if (hasKey) ...[
                                const SizedBox(width: 6),
                                const AppIcon('key',
                                    size: 12, color: T.text2),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    L.of(context).dashKeyWithYou,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppType.ui(
                                      size: 12,
                                      color: T.text2,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ],
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

  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.amountSub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Space.s14),
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
              color: T.text,
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
                  color: T.text,
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
  final BoardPost post;
  final VoidCallback onTap;
  const _BoardPreview({required this.post, required this.onTap});

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
                        if (post.pinned) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Space.s6, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: T.accent),
                              borderRadius: BorderRadius.circular(Radii.xs),
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
                        ],
                        Text(
                          fmtRelDay(post.at, DateTime.now()),
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
                      post.title,
                      style: AppType.ui(
                        size: 15,
                        weight: FontWeight.w600,
                        color: T.text,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
