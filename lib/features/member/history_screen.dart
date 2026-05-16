import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/screen_frame.dart';

class _HistoryItem {
  final String type;
  final String date;
  final String month;
  final String title;
  final String amount;
  final String sub;
  final String method;
  const _HistoryItem({
    required this.type,
    required this.date,
    required this.month,
    required this.title,
    required this.amount,
    required this.sub,
    required this.method,
  });
}

const List<_HistoryItem> _kHistoryItems = [
  _HistoryItem(
      type: 'pay',
      date: '23. 3. 2026',
      month: '2026 · březen',
      title: 'Prodloužení (3 měsíce)',
      amount: '2 250 Kč',
      sub: '+90 dní',
      method: 'QR · bank'),
  _HistoryItem(
      type: 'pay',
      date: '22. 12. 2025',
      month: '2025 · prosinec',
      title: 'Prodloužení (3 měsíce)',
      amount: '2 250 Kč',
      sub: '+90 dní',
      method: 'QR · bank'),
  _HistoryItem(
      type: 'pay',
      date: '14. 9. 2025',
      month: '2025 · září',
      title: 'Vstupní platba',
      amount: '850 Kč',
      sub: '+30 dní',
      method: 'QR · bank'),
  _HistoryItem(
      type: 'key',
      date: '14. 9. 2025',
      month: '2025 · září',
      title: 'Vydán klíč',
      amount: '100 Kč',
      sub: 'kauce',
      method: 'cash · Olda'),
  _HistoryItem(
      type: 'signup',
      date: '12. 9. 2025',
      month: '2025 · září',
      title: 'Schválena registrace',
      amount: '',
      sub: '',
      method: ''),
];

class _TypeMeta {
  final String icon;
  final Color color;
  const _TypeMeta(this.icon, this.color);
}

final Map<String, _TypeMeta> _kTypeMeta = {
  'pay': _TypeMeta('refresh', T.accent),
  'key': _TypeMeta('key', T.warn),
  'signup': _TypeMeta('user_check', T.ok),
};

/// History 06 — historie aktivit člena.
class HistoryScreenView extends ConsumerStatefulWidget {
  const HistoryScreenView({super.key});

  @override
  ConsumerState<HistoryScreenView> createState() => _HistoryScreenViewState();
}

class _HistoryScreenViewState extends ConsumerState<HistoryScreenView> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final items = _kHistoryItems
        .where((i) => _filter == 'all' || i.type == _filter)
        .toList();

    // Group by month, preserving insertion order.
    final byMonth = <String, List<_HistoryItem>>{};
    for (final it in items) {
      byMonth.putIfAbsent(it.month, () => []).add(it);
    }

    final totalPaid = _kHistoryItems
        .where((i) => i.type == 'pay')
        .fold<int>(0, (s, i) {
      final digits = i.amount.replaceAll(RegExp(r'\D'), '');
      return s + (digits.isEmpty ? 0 : int.parse(digits));
    });

    return ScreenFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header block
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        L.of(context).histTitle,
                        style: AppType.ui(
                          size: 28,
                          weight: FontWeight.w700,
                          color: T.text,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        L.of(context).histSubtitle,
                        style: AppType.ui(
                          size: 13.5,
                          weight: FontWeight.w400,
                          color: T.text2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Stats — both boxes share the tallest box's height.
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _MiniStat(
                                label: L.of(context).histStatPaid,
                                value: '${_groupThousands(totalPaid)} Kč',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MiniStat(
                                label: L.of(context).histStatMemberSince,
                                value: '9 · 2025',
                                sub: L.of(context).histStatMonthsCount(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FChip(
                              label: L.of(context).histFilterAll(
                                  _kHistoryItems.length),
                              active: _filter == 'all',
                              onTap: () => setState(() => _filter = 'all'),
                            ),
                            const SizedBox(width: 6),
                            _FChip(
                              label: L.of(context).histFilterPayments(3),
                              active: _filter == 'pay',
                              onTap: () => setState(() => _filter = 'pay'),
                            ),
                            const SizedBox(width: 6),
                            _FChip(
                              label: L.of(context).histFilterKey(1),
                              active: _filter == 'key',
                              onTap: () => setState(() => _filter = 'key'),
                            ),
                            const SizedBox(width: 6),
                            _FChip(
                              label: L.of(context).histFilterAccount(1),
                              active: _filter == 'signup',
                              onTap: () => setState(() => _filter = 'signup'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Grouped list
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (byMonth.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 48, horizontal: 12),
                          child: Center(
                            child: Text(
                              L.of(context).histEmptyFilter,
                              textAlign: TextAlign.center,
                              style: AppType.ui(size: 13, color: T.text3),
                            ),
                          ),
                        )
                      else
                        for (final entry in byMonth.entries) ...[
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: AppType.ui(
                              size: 11.5,
                              weight: FontWeight.w600,
                              color: T.text2,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: T.surface,
                            border: Border.all(color: T.border),
                            borderRadius: BorderRadius.circular(Radii.xl),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < entry.value.length;
                                  i++) ...[
                                _HistoryRow(item: entry.value[i]),
                                if (i < entry.value.length - 1)
                                  Container(
                                    height: 1,
                                    margin: const EdgeInsets.only(left: 60),
                                    color: T.divider,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (byMonth.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            L.of(context).histEndNote,
                            textAlign: TextAlign.center,
                            style: AppType.ui(
                              size: 12,
                              weight: FontWeight.w400,
                              color: T.text3,
                              height: 1.5,
                            ),
                          ),
                        ),
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

String _groupThousands(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  const _MiniStat({required this.label, required this.value, this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: T.surface,
        border: Border.all(color: T.border),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      padding: const EdgeInsets.all(Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppType.ui(
              size: 11,
              weight: FontWeight.w600,
              color: T.text2,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppType.mono(
              size: 18,
              weight: FontWeight.w700,
              color: T.text,
              letterSpacing: -0.4,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              style: AppType.mono(
                size: 11.5,
                weight: FontWeight.w400,
                color: T.text3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? T.text : T.surface,
          border: Border.all(color: active ? T.text : T.border),
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
        child: Text(
          label,
          style: AppType.ui(
            size: 12.5,
            weight: FontWeight.w500,
            color: active ? T.bg : T.text,
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final _HistoryItem item;
  const _HistoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final meta = _kTypeMeta[item.type]!;
    final c = meta.color;
    return Padding(
      padding: const EdgeInsets.all(Space.s14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0x22 / 255),
              borderRadius: BorderRadius.circular(Radii.s10),
            ),
            alignment: Alignment.center,
            child: AppIcon(meta.icon, size: 16, color: c),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppType.ui(
                    size: 14.5,
                    weight: FontWeight.w500,
                    color: T.text,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      item.date,
                      style: AppType.mono(
                        size: 12,
                        weight: FontWeight.w400,
                        color: T.text2,
                      ),
                    ),
                    if (item.method.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '·',
                        style: AppType.mono(
                          size: 12,
                          weight: FontWeight.w400,
                          color: T.text3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.method,
                        style: AppType.mono(
                          size: 12,
                          weight: FontWeight.w400,
                          color: T.text2,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (item.amount.isNotEmpty) ...[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.amount,
                  style: AppType.mono(
                    size: 14,
                    weight: FontWeight.w600,
                    color: T.text,
                  ),
                ),
                if (item.sub.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.sub,
                    style: AppType.mono(
                      size: 11,
                      weight: FontWeight.w400,
                      color: T.text3,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
