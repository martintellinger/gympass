import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/routing/nav.dart';
import '../../core/store/models.dart';
import '../../core/store/store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/round_icon_button.dart';
import '../../shared/widgets/screen_frame.dart';

/// Admin Payments 14 — monthly summary, status filters, search, payment list.
class AdminPaymentsScreen extends ConsumerStatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  ConsumerState<AdminPaymentsScreen> createState() =>
      _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends ConsumerState<AdminPaymentsScreen> {
  String _filter = 'all'; // all | ok | pending | overdue
  String _q = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _memberName(GymStore s, String id) => s.memberById(id)?.name ?? '—';

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    final nav = navCb(context);

    final payments = store.payments;

    int countFor(bool Function(Payment) test) => payments.where(test).length;
    final counts = {
      'all': payments.length,
      'ok': countFor((p) => p.state == 'ok'),
      'pending': countFor((p) => p.state == 'pending'),
      'overdue': countFor((p) => p.state == 'overdue'),
    };

    final filtered = payments.where((p) {
      if (_filter != 'all' && p.state != _filter) return false;
      if (_q.isNotEmpty &&
          !_memberName(store, p.memberId)
              .toLowerCase()
              .contains(_q.toLowerCase())) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    int sumFor(bool Function(Payment) test) =>
        payments.where(test).fold(0, (acc, p) => acc + p.amount);

    final monthRevenue = sumFor((p) =>
        p.state == 'ok' && p.date.month == 5 && p.date.year == 2026);
    final ytdRevenue =
        sumFor((p) => p.state == 'ok' && p.date.year == 2026);
    final overdueTotal = sumFor((p) => p.state == 'overdue');

    return ScreenFrame(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
              // Header + summary + search + filter chips
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          L.of(context).apayTitle,
                          style: AppType.ui(
                            size: 28,
                            weight: FontWeight.w700,
                            color: T.text,
                            letterSpacing: -0.8,
                          ),
                        ),
                        Row(
                          children: [
                            RoundIconButton(
                              icon: 'download',
                              size: 40,
                              onTap: () => nav('payments',
                                  toast: L.of(context).apayToastExportReady),
                            ),
                            const SizedBox(width: 8),
                            RoundIconButton(
                              icon: 'plus',
                              size: 40,
                              background: T.accent,
                              iconColor: Colors.white,
                              bordered: false,
                              onTap: () => nav('payments',
                                  toast: L.of(context).apayToastAddPayment),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Monthly summary card
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: T.surface,
                        border: Border.all(color: T.border),
                        borderRadius: BorderRadius.circular(Radii.lg),
                      ),
                      padding: const EdgeInsets.all(Space.s14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                L.of(context).apayMonthLabel,
                                style: AppType.ui(
                                  size: 11.5,
                                  weight: FontWeight.w600,
                                  color: T.text2,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              Text(
                                L.of(context).apayYtd(groupThousands(ytdRevenue)),
                                style: AppType.mono(
                                  size: 11.5,
                                  color: T.text3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                groupThousands(monthRevenue),
                                style: AppType.mono(
                                  size: 30,
                                  weight: FontWeight.w700,
                                  color: T.text,
                                  letterSpacing: -1,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Kč',
                                style: AppType.ui(
                                  size: 14,
                                  color: T.text2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 14,
                            runSpacing: 6,
                            children: [
                              _SummaryStat(
                                color: T.ok,
                                label: L.of(context)
                                    .apayStatReceived(counts['ok']!),
                              ),
                              _SummaryStat(
                                color: T.warn,
                                label: L.of(context)
                                    .apayStatPending(counts['pending']!),
                              ),
                              _SummaryStat(
                                color: T.error,
                                label: L.of(context).apayStatDebt(
                                    groupThousands(overdueTotal)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Search
                    const SizedBox(height: 12),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: T.surface,
                        border: Border.all(color: T.border),
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const AppIcon('search', size: 16, color: T.text2),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (v) => setState(() => _q = v),
                              cursorColor: T.accent,
                              style: AppType.ui(size: 14, color: T.text),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: L.of(context).apaySearchHint,
                                hintStyle:
                                    AppType.ui(size: 14, color: T.text3),
                              ),
                            ),
                          ),
                          if (_q.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() => _q = '');
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: AppIcon('x',
                                    size: 14, color: T.text3),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Filter chips
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          _PChip(
                            label: L.of(context)
                                .apayFilterAll(counts['all']!),
                            active: _filter == 'all',
                            onTap: () => setState(() => _filter = 'all'),
                          ),
                          const SizedBox(width: 6),
                          _PChip(
                            label: L.of(context)
                                .apayFilterReceived(counts['ok']!),
                            active: _filter == 'ok',
                            dot: T.ok,
                            onTap: () => setState(() => _filter = 'ok'),
                          ),
                          const SizedBox(width: 6),
                          _PChip(
                            label: L.of(context)
                                .apayFilterPending(counts['pending']!),
                            active: _filter == 'pending',
                            dot: T.warn,
                            onTap: () =>
                                setState(() => _filter = 'pending'),
                          ),
                          const SizedBox(width: 6),
                          _PChip(
                            label: L.of(context)
                                .apayFilterOverdue(counts['overdue']!),
                            active: _filter == 'overdue',
                            dot: T.error,
                            onTap: () =>
                                setState(() => _filter = 'overdue'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: T.bg,
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              L.of(context).apayRecordsHeader(filtered.length),
                              style: AppType.ui(
                                size: 11.5,
                                weight: FontWeight.w600,
                                color: T.text2,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          if (_q.isNotEmpty)
                            Text(
                              L.of(context).apayFilterActive(_q),
                              style: AppType.ui(
                                size: 11.5,
                                weight: FontWeight.w600,
                                color: T.accent,
                                letterSpacing: 0,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (filtered.isEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            L.of(context).apayEmpty,
                            style:
                                AppType.ui(size: 13, color: T.text3),
                          ),
                        ),
                      )
                    else
                      ...filtered.map((p) => _PaymentRow(
                            payment: p,
                            memberName:
                                _memberName(store, p.memberId),
                            onTap: () => nav('detail',
                                arg: p.memberId),
                            onRemind: () {
                              store.sendMessage(
                                p.memberId,
                                L.of(context).apayReminderMessage(
                                    groupThousands(p.amount)),
                              );
                              nav('thread',
                                  arg: p.memberId,
                                  toast: L.of(context)
                                      .apayToastReminderSent);
                            },
                          )),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final Color color;
  final String label;
  const _SummaryStat({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppType.ui(size: 12, color: color),
        ),
      ],
    );
  }
}

class _PChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color? dot;
  final VoidCallback onTap;
  const _PChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.dot,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? T.text : T.surface,
          border: Border.all(color: active ? T.text : T.border),
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppType.ui(
                size: 13,
                weight: FontWeight.w500,
                color: active ? T.bg : T.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Payment payment;
  final String memberName;
  final VoidCallback onTap;
  final VoidCallback onRemind;
  const _PaymentRow({
    required this.payment,
    required this.memberName,
    required this.onTap,
    required this.onRemind,
  });

  @override
  Widget build(BuildContext context) {
    final p = payment;
    final isOK = p.state == 'ok';
    final isPending = p.state == 'pending';
    final isOverdue = p.state == 'overdue';

    final c = isOK ? T.ok : (isPending ? T.warn : T.error);
    final cSoft =
        isOK ? T.okSoft : (isPending ? T.warnSoft : T.errorSoft);
    final iconName =
        isOK ? 'check' : (isPending ? 'refresh' : 'alert');

    final dateStr = '${p.date.day}. ${p.date.month}. ${p.date.year}';

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: T.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Space.xs, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cSoft,
                      borderRadius: BorderRadius.circular(Radii.s10),
                    ),
                    child: Center(
                      child: AppIcon(iconName, size: 16, color: c),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memberName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.ui(
                            size: 14.5,
                            weight: FontWeight.w600,
                            color: T.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              dateStr,
                              style: AppType.mono(
                                  size: 12.5, color: T.text2),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '·',
                              style: AppType.ui(
                                  size: 12.5, color: T.text3),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                p.type,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppType.ui(
                                    size: 12.5, color: T.text2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${groupThousands(p.amount)} Kč',
                        style: AppType.mono(
                          size: 14,
                          weight: FontWeight.w600,
                          color: isOverdue ? T.error : T.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.tariff.toUpperCase(),
                        style: AppType.mono(
                          size: 10.5,
                          color: T.text3,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isPending || isOverdue)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(52, 0, 4, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onRemind,
                    child: Container(
                      height: 30,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: T.accentSoft,
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon('send',
                              size: 12, color: T.accent),
                          const SizedBox(width: 6),
                          Text(
                            L.of(context).apayRemind,
                            style: AppType.ui(
                              size: 12.5,
                              weight: FontWeight.w600,
                              color: T.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 30,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: T.surface2,
                      border: Border.all(color: T.border),
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppIcon('check',
                            size: 12, color: T.text),
                        const SizedBox(width: 6),
                        Text(
                          L.of(context).apayMarkPaid,
                          style: AppType.ui(
                            size: 12.5,
                            weight: FontWeight.w500,
                            color: T.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
