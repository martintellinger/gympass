import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../l10n/app_localizations.dart';
import '../../core/routing/nav.dart';
import '../../core/data/data_providers.dart';
import '../../core/data/gym_repository_provider.dart';
import '../../core/store/models.dart';
import 'admin_payments.dart' show showAddPaymentSheet;
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/load_error.dart';
import '../../shared/widgets/screen_frame.dart';
import '../../shared/widgets/skeleton.dart';
import '../../shared/widgets/status_pill.dart';

/// Member Detail 12 — port of MemberDetail.jsx.
class MemberDetailScreen extends ConsumerWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mAsync = ref.watch(memberByIdProvider(memberId));
    final nav = navCb(context);
    final repo = ref.read(gymRepositoryProvider);

    if (mAsync.isLoading && !mAsync.hasValue) {
      return const ScreenFrame(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: SkeletonList(rows: 6),
        ),
      );
    }
    if ((mAsync.hasError || mAsync.value == null) && !mAsync.isLoading) {
      return ScreenFrame(
        child: LoadError(
            onRetry: () => ref.invalidate(memberByIdProvider(memberId))),
      );
    }
    final Member m = mAsync.value!;

    Future<void> refresh() async {
      ref.invalidate(memberByIdProvider(memberId));
      ref.invalidate(membersProvider);
    }

    final l = L.of(context);
    final stateLabel = m.state == 'ok'
        ? l.mdetStateActive(m.daysNum)
        : m.state == 'warn'
            ? l.mdetStateEnding(m.daysNum)
            : m.state == 'error'
                ? l.mdetStateOverdue(m.daysNum.abs())
                : l.mdetStateSuspended;

    final memberPayments =
        (ref.watch(paymentsProvider).value ?? const <Payment>[])
            .where((p) => p.memberId == m.id)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final pillState = statusFromKey(m.state == 'muted' ? 'muted' : m.state);

    return ScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleBtn(
                  icon: 'back',
                  size: 18,
                  onTap: () => nav('back'),
                ),
                Text(
                  l.mdetTitle,
                  style: AppType.ui(
                    size: 14,
                    weight: FontWeight.w600,
                    color: T.text2,
                  ),
                ),
                _circleBtn(
                  icon: 'edit',
                  size: 16,
                  onTap: () => nav('addMember', arg: m.id),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero
                  Row(
                    children: [
                      Avatar(name: m.name, size: 72),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppType.ui(
                                size: 22,
                                weight: FontWeight.w700,
                                color: T.text,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${m.tariff}${m.isic ? ' · ISIC' : ''} · ${l.mdetMemberSince(m.joined)}',
                              style: AppType.ui(
                                size: 13,
                                color: T.text2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: StatusPill(
                                state: pillState,
                                label: stateLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Rychlé akce
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailQuick(
                          icon: 'message',
                          label: l.mdetQuickMessage,
                          onTap: () => nav('thread', arg: m.id),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DetailQuick(
                          icon: 'refresh',
                          label: l.mdetQuickExtend,
                          onTap: () => showAddPaymentSheet(
                            context, repo, [m], nav,
                            preselectMemberId: m.id,
                            onSaved: () {
                              ref.invalidate(paymentsProvider);
                              ref.invalidate(
                                  memberByIdProvider(memberId));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Contact
                  const SizedBox(height: 18),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _KV(label: l.mdetKvEmail, value: m.email),
                        const _KVDivider(),
                        _KV(label: l.mdetKvPhone, value: m.phone, mono: true),
                        const _KVDivider(),
                        _KV(
                          label: l.mdetKvTariff,
                          value: '${m.tariff}${m.isic ? ' · ISIC' : ''}',
                        ),
                        const _KVDivider(),
                        _KVPrice(
                          m: m,
                          onEdit: () => nav('addMember', arg: m.id),
                        ),
                        const _KVDivider(),
                        _KV(
                          label: l.mdetKvPaidUntil,
                          value: m.expiresAt,
                          mono: true,
                          last: true,
                        ),
                      ],
                    ),
                  ),

                  // Klimat (vyžaduje pozornost)
                  if (m.state == 'error' || m.state == 'warn') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Space.s14, vertical: 12),
                      decoration: BoxDecoration(
                        color: m.state == 'error' ? T.errorSoft : T.warnSoft,
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      child: Row(
                        children: [
                          AppIcon(
                            'alert',
                            size: 16,
                            stroke: 2,
                            color:
                                m.state == 'error' ? T.error : T.warn,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              m.state == 'error'
                                  ? l.mdetAlertOverdue(m.daysNum.abs())
                                  : l.mdetStateEnding(m.daysNum),
                              style: AppType.ui(
                                size: 13,
                                weight: FontWeight.w500,
                                color: m.state == 'error'
                                    ? T.error
                                    : T.warn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => nav('thread', arg: m.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Space.s10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(0x14),
                                borderRadius: BorderRadius.circular(Radii.pill),
                              ),
                              child: Text(
                                l.mdetWrite,
                                style: AppType.ui(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: m.state == 'error'
                                      ? T.error
                                      : T.warn,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Klíč & kauce
                  _SectionLabel(l.mdetSectionKeyDeposit),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(Space.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: T.accentSoft,
                                borderRadius: BorderRadius.circular(Radii.md),
                              ),
                              child: AppIcon('key',
                                  size: 22, color: T.accent),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.mdetKey,
                                    style: AppType.ui(
                                      size: 15,
                                      weight: FontWeight.w600,
                                      color: T.text,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l.mdetKeyIssued('14. 9. 2025'),
                                    style: AppType.mono(
                                      size: 12.5,
                                      color: T.text2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusPill(
                              state: StatusState.ok,
                              label: l.mdetKeyWithMember,
                            ),
                          ],
                        ),
                        Container(
                          height: 1,
                          color: T.divider,
                          margin: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.mdetDeposit,
                                  style: AppType.ui(
                                    size: 13,
                                    color: T.text2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '100 Kč',
                                  style: AppType.mono(
                                    size: 17,
                                    weight: FontWeight.w700,
                                    color: T.text,
                                  ),
                                ),
                              ],
                            ),
                            StatusPill(
                              state: StatusState.ok,
                              label: l.mdetDepositReceived,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          label: l.mdetMarkReturned,
                          variant: BtnVariant.secondary,
                          full: true,
                          height: 44,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  // Platby
                  _SectionLabel(
                    l.mdetSectionPayments,
                    right: Text(
                      l.mdetPaymentsSince(m.joined),
                      style: AppType.ui(size: 12.5, color: T.text2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: memberPayments.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(Space.xl),
                            child: Center(
                              child: Text(
                                l.mdetNoPayments,
                                style: AppType.ui(size: 13, color: T.text3),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              for (var i = 0;
                                  i < memberPayments.length;
                                  i++)
                                _PayRow(
                                  p: memberPayments[i],
                                  last:
                                      i == memberPayments.length - 1,
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: l.mdetManualPayment,
                    variant: BtnVariant.ghost,
                    full: true,
                    icon: const AppIcon('plus', size: 16),
                    onTap: () => nav('payments'),
                  ),

                  // Danger zone
                  _SectionLabel(l.mdetSectionActions),
                  const SizedBox(height: 12),
                  if (m.isPaused)
                    _ActionRow(
                      icon: 'refresh',
                      label: l.mdetResumeLabel,
                      sub: l.mdetResumeSub,
                      onTap: () async {
                        await repo.resumeMembership(
                          m.id,
                          notice: l.resumeByOwnerNotice,
                        );
                        await refresh();
                      },
                    )
                  else
                    _ActionRow(
                      icon: 'pause',
                      label: l.mdetSuspendLabel,
                      sub: l.mdetSuspendSub,
                      onTap: () async {
                        // Owner pause mid-term — pauseMembership stamps
                        // paused_at so the frozen-expiry domain calc applies.
                        await repo.pauseMembership(
                          m.id,
                          notice: l.pauseOwnerNoticeNoReason,
                        );
                        await refresh();
                      },
                    ),
                  const SizedBox(height: 8),
                  _ActionRow(
                    icon: 'trash',
                    label: l.mdetDeleteLabel,
                    sub: l.mdetDeleteSub,
                    danger: true,
                    onTap: () => _confirmDelete(context, ref, m, nav),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Member m,
    NavCb nav,
  ) {
    final l = L.of(context);
    final repo = ref.read(gymRepositoryProvider);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: T.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
          side: const BorderSide(color: T.border),
        ),
        title: Text(
          l.mdetDeleteDialogTitle,
          style: AppType.ui(
            size: 17,
            weight: FontWeight.w700,
            color: T.text,
          ),
        ),
        content: Text(
          l.mdetDeleteDialogBody(m.name),
          style: AppType.ui(size: 14, color: T.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l.mdetDeleteDialogCancel,
              style: AppType.ui(
                size: 14,
                weight: FontWeight.w600,
                color: T.text2,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await repo.removeMember(m.id);
              ref.invalidate(membersProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
              nav('back');
            },
            child: Text(
              l.mdetDeleteDialogConfirm,
              style: AppType.ui(
                size: 14,
                weight: FontWeight.w600,
                color: T.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({
    required String icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: T.surface,
          shape: BoxShape.circle,
          border: Border.all(color: T.border),
        ),
        child: AppIcon(icon, size: size, color: T.text),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  final bool last;
  const _KV({
    required this.label,
    required this.value,
    this.mono = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: AppType.ui(size: 13, color: T.text2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: mono
                  ? AppType.mono(
                      size: 14,
                      weight: FontWeight.w500,
                      color: T.text,
                    )
                  : AppType.ui(
                      size: 14,
                      weight: FontWeight.w500,
                      color: T.text,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KVPrice extends StatelessWidget {
  final Member m;
  final VoidCallback onEdit;
  const _KVPrice({required this.m, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final tariffDefault = m.tariff == 'Student' ? 500 : 750;
    final price = m.monthlyPrice ?? tariffDefault;
    final isCustom = price != tariffDefault;
    return GestureDetector(
      onTap: onEdit,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              L.of(context).mdetKvPricePerMonth,
              style: AppType.ui(size: 13, color: T.text2),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCustom) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Space.s6, vertical: 2),
                    decoration: BoxDecoration(
                      color: T.accentSoft,
                      borderRadius: BorderRadius.circular(Radii.xs),
                    ),
                    child: Text(
                      L.of(context).mdetCustomBadge,
                      style: AppType.ui(
                        size: 9.5,
                        weight: FontWeight.w700,
                        color: T.accent,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  '$price Kč',
                  style: AppType.mono(
                    size: 14,
                    weight: FontWeight.w600,
                    color: isCustom ? T.accent : T.text,
                  ),
                ),
                const SizedBox(width: 8),
                const AppIcon('edit', size: 13, color: T.text3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KVDivider extends StatelessWidget {
  const _KVDivider();
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: T.divider);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Widget? right;
  const _SectionLabel(this.text, {this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
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
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  final Payment p;
  final bool last;
  const _PayRow({required this.p, required this.last});

  @override
  Widget build(BuildContext context) {
    final date = '${p.date.day}. ${p.date.month}. ${p.date.year}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: T.divider),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: T.okSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: AppIcon('check', size: 16, stroke: 2.4, color: T.ok),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.type,
                  style: AppType.ui(
                    size: 14,
                    weight: FontWeight.w500,
                    color: T.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: AppType.mono(size: 12, color: T.text2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            kc(p.amount),
            style: AppType.mono(
              size: 14,
              weight: FontWeight.w600,
              color: T.text,
            ),
          ),
          const SizedBox(width: 12),
          const AppIcon('download', size: 16, color: T.text3),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String icon;
  final String label;
  final String sub;
  final bool danger;
  final VoidCallback onTap;
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(Space.s14),
        decoration: BoxDecoration(
          color: T.surface,
          border: Border.all(color: T.border),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Row(
          children: [
            AppIcon(icon, size: 18, color: danger ? T.error : T.text2),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppType.ui(
                      size: 14.5,
                      weight: FontWeight.w500,
                      color: danger ? T.error : T.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: AppType.ui(
                      size: 12,
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
}

class _DetailQuick extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _DetailQuick({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: 12),
        decoration: BoxDecoration(
          color: T.surface,
          border: Border.all(color: T.border),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: T.accentSoft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: AppIcon(icon, size: 16, color: T.accent),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppType.ui(
                size: 11.5,
                weight: FontWeight.w500,
                color: T.text,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
