import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_providers.dart';
import '../../core/domain/revenue.dart';
import '../../core/format.dart';
import '../../core/routing/nav.dart';
import '../../core/store/models.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/screen_frame.dart';

/// "Jana Kovářová" → "Jana K." for the attention sublines.
String _shortName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length < 2 || parts[1].isEmpty) return parts.first;
  return '${parts.first} ${parts[1][0]}.';
}

String _joinNames(Iterable<String> names, {int max = 3}) {
  final list = names.toList();
  if (list.length <= max) return list.join(', ');
  return '${list.take(max).join(', ')} +${list.length - max}';
}

/// Admin Dashboard 10 — denní pohled majitele.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = navCb(context);

    final members =
        ref.watch(membersProvider).value ?? const <Member>[];
    final pending =
        ref.watch(pendingMembersProvider).value ?? const <Member>[];
    final payments =
        ref.watch(paymentsProvider).value ?? const <Payment>[];

    final total = members.length;
    final activeCount = members.where((m) => m.state == 'ok').length;
    final endingSoon = members.where((m) => m.state == 'warn').toList();
    final overdue = members.where((m) => m.state == 'error').toList();

    final now = DateTime.now();
    final monthRevenue =
        revenueSum(payments, year: now.year, month: now.month);

    // Attention rows are built dynamically — a zero count means the row is
    // simply absent, not shown as "0" (that was the stale hardcoded bug).
    final attention = <Widget>[
      if (pending.isNotEmpty)
        _AttentionRow(
          icon: 'user_check',
          title: L.of(context).adashAttnPending('${pending.length}'),
          sub: _joinNames(pending.map((m) => _shortName(m.name))),
          accent: true,
          onTap: () => nav('approval'),
        ),
      if (overdue.isNotEmpty)
        _AttentionRow(
          icon: 'alert',
          title: L.of(context).adashAttnOverdue('${overdue.length}'),
          sub: L.of(context).adashAttnOverdueSub(
              _joinNames(overdue.map((m) => m.name.split(' ').first))),
          warn: true,
          onTap: () => nav('list', arg: {'filterPreset': 'error'}),
        ),
      if (endingSoon.isNotEmpty)
        _AttentionRow(
          icon: 'calendar',
          title:
              L.of(context).adashAttnEndingSoon('${endingSoon.length}'),
          sub: L.of(context).adashAttnEndingSoonSub,
          onTap: () => nav('list', arg: {'filterPreset': 'warn'}),
        ),
    ];

    return ScreenFrame(
      child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 4,
              bottom: 110,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L.of(context).adashKicker,
                            style: AppType.ui(
                              size: 12.5,
                              weight: FontWeight.w600,
                              color: T.text2,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            L.of(context).adashGreeting,
                            style: AppType.ui(
                              size: 22,
                              weight: FontWeight.w700,
                              color: T.text,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Top stats — 2x2
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Stat(
                        label: L.of(context).adashStatActive,
                        value: '$activeCount',
                        sub: L.of(context).adashStatActiveSub('$total'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Stat(
                        label: L.of(context).adashStatEndingSoon,
                        value: '${endingSoon.length}',
                        sub: L.of(context).adashStatEndingSoonSub,
                        color: T.warn,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Stat(
                        label: L.of(context).adashStatOverdue,
                        value: '${overdue.length}',
                        sub: L.of(context).adashStatOverdueSub,
                        color: T.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Stat(
                        label: L.of(context).adashStatRevenue(
                            '${now.month}/${now.year % 100}'),
                        value: groupThousands(monthRevenue),
                        sub: L.of(context).adashCurrencyCzk,
                      ),
                    ),
                  ],
                ),

                // Vyžaduje pozornost
                const SizedBox(height: 24),
                _SectionLabel(L.of(context).adashNeedsAttention),
                const SizedBox(height: 12),
                AppCard(
                  padding: attention.isEmpty
                      ? const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18)
                      : EdgeInsets.zero,
                  child: attention.isEmpty
                      ? Row(
                          children: [
                            const AppIcon('check',
                                size: 18, color: T.ok),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                L.of(context).adashAttnAllClear,
                                style: AppType.ui(
                                    size: 14, color: T.text2),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < attention.length; i++) ...[
                              if (i > 0) _divider(),
                              attention[i],
                            ],
                          ],
                        ),
                ),

                // Revenue chart
                const SizedBox(height: 24),
                _SectionLabel(
                  L.of(context).adashRevenue,
                  right: Text(
                    L.of(context).adashRevenueRange,
                    style: AppType.ui(size: 12.5, color: T.text2),
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '28 950',
                            style: AppType.mono(
                              size: 28,
                              weight: FontWeight.w700,
                              color: T.text,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              L.of(context).adashRevenueMonth('květen'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppType.ui(size: 13, color: T.text2),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '+8,5 %',
                            style: AppType.mono(
                              size: 12,
                              weight: FontWeight.w600,
                              color: T.ok,
                            ),
                          ),
                        ],
                      ),
                      const _RevenueChart(),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final m in const [
                            'PRO',
                            'LED',
                            'ÚNO',
                            'BŘE',
                            'DUB',
                            'KVĚ',
                          ])
                            Text(
                              m,
                              style: AppType.mono(
                                size: 10.5,
                                weight: FontWeight.w500,
                                color: T.text3,
                                letterSpacing: 0.5,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _divider() => Container(height: 1, color: T.divider);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Widget? right;
  const _SectionLabel(this.text, {this.right});

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

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color? color;
  const _Stat({
    required this.label,
    required this.value,
    required this.sub,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: T.surface,
        border: Border.all(color: T.border),
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      padding: const EdgeInsets.all(Space.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppType.ui(
              size: 11.5,
              weight: FontWeight.w600,
              color: T.text2,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: AppType.mono(
                      size: 28,
                      weight: FontWeight.w700,
                      color: color ?? T.text,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.ui(size: 12, color: T.text3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  final String icon;
  final String title;
  final String sub;
  final bool accent;
  final bool warn;
  final VoidCallback? onTap;
  const _AttentionRow({
    required this.icon,
    required this.title,
    required this.sub,
    this.accent = false,
    this.warn = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color c = accent ? T.accent : (warn ? T.warn : T.text);
    final Color bg = accent ? T.accentSoft : (warn ? T.warnSoft : T.surface2);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Space.s14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(Radii.s10),
                ),
                alignment: Alignment.center,
                child: AppIcon(icon, size: 18, color: c),
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
                        weight: FontWeight.w600,
                        color: T.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: AppType.ui(size: 12.5, color: T.text2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppIcon('chevron', size: 16, color: T.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart();

  @override
  Widget build(BuildContext context) {
    const data = [21500, 24200, 22800, 25400, 26700, 28950];
    final max = data.reduce((a, b) => a > b ? a : b);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < data.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _Bar(
                  fraction: data[i] / max,
                  last: i == data.length - 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double fraction;
  final bool last;
  const _Bar({required this.fraction, required this.last});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight * fraction;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: h,
              decoration: BoxDecoration(
                color: last ? T.accent : T.surface2,
                borderRadius: BorderRadius.circular(6),
                border: last ? null : Border.all(color: T.border),
              ),
            ),
            if (last)
              Positioned(
                bottom: h + 4,
                child: Text(
                  '29k',
                  style: AppType.mono(size: 10, color: T.text2),
                ),
              ),
          ],
        );
      },
    );
  }
}
