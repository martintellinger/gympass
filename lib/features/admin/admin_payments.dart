import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_providers.dart';
import '../../core/data/gym_repository.dart';
import '../../core/data/gym_repository_provider.dart';
import '../../core/format.dart';
import '../../core/routing/nav.dart';
import '../../core/store/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/load_error.dart';
import '../../shared/widgets/round_icon_button.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/skeleton.dart';

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

  @override
  Widget build(BuildContext context) {
    final nav = navCb(context);
    final repo = ref.read(gymRepositoryProvider);
    final paymentsAsync = ref.watch(paymentsProvider);

    if (paymentsAsync.isLoading && !paymentsAsync.hasValue) {
      return const ScreenFrame(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SkeletonList(rows: 7),
        ),
      );
    }
    if (paymentsAsync.hasError && !paymentsAsync.hasValue) {
      return ScreenFrame(
        child:
            LoadError(onRetry: () => ref.invalidate(paymentsProvider)),
      );
    }

    final payments = paymentsAsync.value ?? const <Payment>[];
    final members =
        ref.watch(membersProvider).value ?? const <Member>[];
    final nameById = {for (final m in members) m.id: m.name};
    String memberName(String id) => nameById[id] ?? '—';

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
          !memberName(p.memberId)
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
                        RoundIconButton(
                          icon: 'plus',
                          size: 40,
                          background: T.accent,
                          iconColor: Colors.white,
                          bordered: false,
                          onTap: () => showAddPaymentSheet(
                            context,
                            repo,
                            members,
                            nav,
                            onSaved: () =>
                                ref.invalidate(paymentsProvider),
                          ),
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
                                memberName(p.memberId),
                            onTap: () => nav('detail',
                                arg: p.memberId),
                            onConfirm: () async {
                              final paid =
                                  L.of(context).apayToastMarkedPaid;
                              final failed = L
                                  .of(context)
                                  .apayToastActionFailed;
                              try {
                                await repo.confirmPayment(p.id);
                              } catch (_) {
                                if (!context.mounted) return;
                                nav('payments', toast: failed);
                                return;
                              }
                              if (!context.mounted) return;
                              ref.invalidate(paymentsProvider);
                              nav('payments', toast: paid);
                            },
                            onRemind: () async {
                              final msg = L.of(context).apayReminderMessage(
                                  groupThousands(p.amount));
                              final sent =
                                  L.of(context).apayToastReminderSent;
                              final failed = L
                                  .of(context)
                                  .apayToastActionFailed;
                              try {
                                await repo.sendOwnerMessage(
                                    p.memberId, msg,
                                    from: 'olda');
                              } catch (_) {
                                if (!context.mounted) return;
                                nav('payments', toast: failed);
                                return;
                              }
                              if (!context.mounted) return;
                              ref.invalidate(adminThreadsProvider);
                              nav('thread',
                                  arg: p.memberId, toast: sent);
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
  final VoidCallback onConfirm;
  final VoidCallback onRemind;
  const _PaymentRow({
    required this.payment,
    required this.memberName,
    required this.onTap,
    required this.onConfirm,
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
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
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
                  GestureDetector(
                    onTap: onConfirm,
                    child: Container(
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
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One configurable tariff/period combo (MVP set — CLAUDE.md §1). Olda can
/// add more once the real `tariffs` table lands; the picker is data-driven
/// so this list is the only thing to grow.
class _TariffOption {
  final String tariff;
  final int months;
  final int amount;
  const _TariffOption(this.tariff, this.months, this.amount);
}

const _kTariffOptions = <_TariffOption>[
  _TariffOption('Standard', 1, 850),
  _TariffOption('Standard', 3, 2250),
  _TariffOption('Student', 1, 750),
  _TariffOption('Student', 3, 1950),
];

/// Owner add-payment sheet. Reused from the payments screen and from a
/// member's detail ("Platba" / "Prodloužit"), where [preselectMemberId]
/// locks it to that member.
void showAddPaymentSheet(
  BuildContext context,
  GymRepository repo,
  List<Member> members,
  NavCb nav, {
  String? preselectMemberId,
  VoidCallback? onSaved,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddPaymentSheet(
      repo: repo,
      members: members,
      nav: nav,
      preselectMemberId: preselectMemberId,
      onSaved: onSaved,
    ),
  );
}

class _AddPaymentSheet extends StatefulWidget {
  final GymRepository repo;
  final List<Member> members;
  final NavCb nav;
  final String? preselectMemberId;
  final VoidCallback? onSaved;
  const _AddPaymentSheet({
    required this.repo,
    required this.members,
    required this.nav,
    this.preselectMemberId,
    this.onSaved,
  });

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  String? _memberId;
  int _optIdx = 1;

  @override
  void initState() {
    super.initState();
    _memberId = widget.preselectMemberId;
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final members = [...widget.members]
      ..sort((a, b) => a.name.compareTo(b.name));
    final canSave = _memberId != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.86,
      ),
      decoration: const BoxDecoration(
        color: T.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        border: Border(top: BorderSide(color: T.border)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: T.border,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l.apayAddTitle,
              style: AppType.ui(
                  size: 20, weight: FontWeight.w700, letterSpacing: -0.4)),
          const SizedBox(height: 16),
          Text(l.apayAddMember.toUpperCase(),
              style: AppType.ui(
                  size: 11.5,
                  weight: FontWeight.w600,
                  color: T.text2,
                  letterSpacing: 0.4)),
          const SizedBox(height: 8),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: T.bg,
                border: Border.all(color: T.border),
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: members.length,
                itemBuilder: (_, i) {
                  final m = members[i];
                  final sel = m.id == _memberId;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _memberId = m.id),
                    child: Container(
                      color: sel ? T.accentSoft : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      child: Row(
                        children: [
                          Avatar(name: m.name, size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(m.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppType.ui(
                                    size: 14,
                                    weight: FontWeight.w500,
                                    color: sel ? T.accent : T.text)),
                          ),
                          if (sel)
                            const AppIcon('check',
                                size: 16, color: T.accent),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l.apayAddTariff.toUpperCase(),
              style: AppType.ui(
                  size: 11.5,
                  weight: FontWeight.w600,
                  color: T.text2,
                  letterSpacing: 0.4)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _kTariffOptions.length; i++)
                _OptChip(
                  label: l.apayAddTariffOption(
                    _kTariffOptions[i].tariff,
                    _kTariffOptions[i].months,
                    groupThousands(_kTariffOptions[i].amount),
                  ),
                  active: i == _optIdx,
                  onTap: () => setState(() => _optIdx = i),
                ),
            ],
          ),
          const SizedBox(height: 20),
          AppButton(
            label: l.apayAddSave,
            full: true,
            icon: canSave
                ? const AppIcon('check', size: 20, color: Colors.white)
                : null,
            onTap: canSave
                ? () async {
                    final opt = _kTariffOptions[_optIdx];
                    final nav = widget.nav;
                    final added = l.apayToastPaymentAdded;
                    final failed = l.apayToastActionFailed;
                    try {
                      await widget.repo.addManualPayment(
                        memberId: _memberId!,
                        amount: opt.amount,
                        tariff: opt.tariff,
                        type: l.apayAddTariffOption(
                          opt.tariff,
                          opt.months,
                          groupThousands(opt.amount),
                        ),
                      );
                    } catch (_) {
                      if (context.mounted) Navigator.of(context).pop();
                      nav('payments', toast: failed);
                      return;
                    }
                    widget.onSaved?.call();
                    if (context.mounted) Navigator.of(context).pop();
                    nav('payments', toast: added);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _OptChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _OptChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? T.accent : T.bg,
          border: Border.all(color: active ? T.accent : T.border),
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppType.ui(
            size: 13,
            weight: FontWeight.w600,
            color: active ? Colors.white : T.text,
          ),
        ),
      ),
    );
  }
}
