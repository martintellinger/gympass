/// Maps raw DB rows → the display-shaped [Member] the UI already consumes.
///
/// This is the single place where the tested pure domain functions
/// (`lib/core/domain/`) get wired to real data: the DB stores
/// `membership_expires_at` + `billing_day_of_month`, and the screens want
/// `daysNum` / a localised `expiresAt` / a derived status pill. Keeping the
/// derivation here means a Supabase repository never re-implements the
/// expiry, pause or deposit math — it parses rows and calls [memberFromRow].
library;

import '../../domain/deposit.dart' as deposit;
import '../../domain/membership.dart' as membership;
import '../../store/models.dart';
import 'db_rows.dart';

/// CZ display date: `23. 6. 2026`.
String _czDate(DateTime d) => '${d.day}. ${d.month}. ${d.year}';

/// "Member since" label used on the card / profile: `9 · 2025`.
String _joinedLabel(DateTime? createdAt) =>
    createdAt == null ? '—' : '${createdAt.month} · ${createdAt.year}';

/// Status pill bucket from the (frozen-aware) days remaining.
/// Mirrors `GymStore.resumeMembership` thresholds so paused→active is stable.
String _statePill(int daysNum) => daysNum < 0
    ? 'error'
    : daysNum <= 7
        ? 'warn'
        : 'ok';

/// Builds the view [Member] from its DB row at [now].
///
/// The expiry shown is the *effective* one: if the member is paused, the
/// membership is frozen, so we slide the stored expiry forward by the elapsed
/// pause span (`domain/membership.dart#expiryAfterPause`) before computing
/// days left — the deposit forfeit clock (§5) rides along automatically.
Member memberFromRow(MemberRow r, {required DateTime now}) {
  final paused = r.pausedAt != null;

  DateTime? effectiveExpiry = r.membershipExpiresAt;
  if (effectiveExpiry != null && paused) {
    effectiveExpiry = membership.expiryAfterPause(
      expiry: effectiveExpiry,
      pausedAt: r.pausedAt!,
      resumedAt: now,
    );
  }

  final daysNum = effectiveExpiry == null
      ? 0
      : membership.daysLeft(effectiveExpiry, now);

  // 'inactive'/'suspended' members and paused ones render muted; otherwise
  // the pill comes from days remaining.
  final muted = paused ||
      r.status == 'suspended' ||
      r.status == 'inactive' ||
      effectiveExpiry == null;
  final state = muted ? 'muted' : _statePill(daysNum);

  return Member(
    id: r.id,
    name: '${r.firstName} ${r.lastName}'.trim(),
    phone: r.phone,
    email: r.email,
    state: state,
    daysNum: daysNum,
    tariff: r.tariffType == 'student' ? 'Student' : 'Standard',
    hasKey: r.keyIssued && !r.keyReturned,
    isic: r.studentProofUrl != null,
    overdue: !muted && daysNum < 0,
    suspended: r.status == 'suspended' || paused,
    joined: _joinedLabel(r.createdAt),
    expiresAt: effectiveExpiry == null ? '—' : _czDate(effectiveExpiry),
    pausedAt: r.pausedAt,
    pauseReason: r.pauseReason,
  );
}

/// Live key-deposit status (§5) for a member row at [now]. Kept separate from
/// [memberFromRow] because the view [Member] has no deposit field yet — the
/// detail screen calls this directly once wired, instead of re-deriving it.
deposit.DepositStatus depositStatusFor(MemberRow r, {required DateTime now}) {
  final end = r.membershipExpiresAt;
  if (end == null) return deposit.DepositStatus.paid;
  return deposit.depositStatus(
    membershipEnd: end,
    keyReturned: r.keyReturned,
    now: now,
  );
}

/// Maps a raw payment row to the view [Payment]. `state` is derived: app
/// payments are confirmed (`ok`); historical Excel imports stay `ok` but are
/// flagged via [PaymentRow.isHistorical] so revenue stats can exclude them
/// (`domain/revenue.dart`, §9).
Payment paymentFromRow(PaymentRow r) => Payment(
      id: r.id,
      memberId: r.memberId,
      date: r.paidAt,
      amount: r.amount,
      type: r.tariff,
      tariff: r.tariff,
      state: 'ok',
    );
