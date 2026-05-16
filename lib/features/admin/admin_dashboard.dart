import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/nav.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/screen_frame.dart';

/// Admin Dashboard 10 — denní pohled majitele.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = navCb(context);

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
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: T.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: T.border),
                      ),
                      alignment: Alignment.center,
                      child: AppIcon('bell', size: 18, color: T.text2),
                    ),
                  ],
                ),

                // Top stats — 2x2
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Stat(
                        label: L.of(context).adashStatActive,
                        value: '34',
                        sub: L.of(context).adashStatActiveSub('34'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Stat(
                        label: L.of(context).adashStatEndingSoon,
                        value: '5',
                        sub: L.of(context).adashStatEndingSoonSub,
                        color: T.warn,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Stat(
                        label: L.of(context).adashStatOverdue,
                        value: '2',
                        sub: L.of(context).adashStatOverdueSub,
                        color: T.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Stat(
                        label: L.of(context).adashStatRevenue('5/26'),
                        value: '28 950',
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
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _AttentionRow(
                        icon: 'user_check',
                        title: L.of(context).adashAttnPending('2'),
                        sub: 'Jana K., Tomáš H.',
                        accent: true,
                        onTap: () => nav('approval'),
                      ),
                      _divider(),
                      _AttentionRow(
                        icon: 'alert',
                        title: L.of(context).adashAttnOverdue('2'),
                        sub: L.of(context).adashAttnOverdueSub('David, Petr'),
                        warn: true,
                        onTap: () => nav('list', arg: {'filterPreset': 'error'}),
                      ),
                      _divider(),
                      _AttentionRow(
                        icon: 'calendar',
                        title: L.of(context).adashAttnEndingSoon('5'),
                        sub: L.of(context).adashAttnEndingSoonSub,
                        onTap: () => nav('list', arg: {'filterPreset': 'warn'}),
                      ),
                    ],
                  ),
                ),

                // Quick actions
                const SizedBox(height: 24),
                _SectionLabel(L.of(context).adashQuickActions),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: 'message',
                        label: L.of(context).adashActionSendMessage,
                        onTap: () => nav('messages'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAction(
                        icon: 'cash',
                        label: L.of(context).adashActionPayments,
                        onTap: () => nav('payments'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAction(
                        icon: 'user_plus',
                        label: L.of(context).adashActionAddMember,
                        onTap: () => nav('addMember'),
                      ),
                    ),
                  ],
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
                          Text(
                            L.of(context).adashRevenueMonth('květen'),
                            style: AppType.ui(size: 13, color: T.text2),
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
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
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
              Text(
                value,
                style: AppType.mono(
                  size: 28,
                  weight: FontWeight.w700,
                  color: color ?? T.text,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                sub,
                style: AppType.ui(size: 12, color: T.text3),
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
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
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

class _QuickAction extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: T.surface,
            border: Border.all(color: T.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: T.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: AppIcon(icon, size: 18, color: T.accent),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppType.ui(
                  size: 11.5,
                  weight: FontWeight.w500,
                  color: T.text,
                  letterSpacing: -0.1,
                  height: 1.2,
                ),
              ),
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
