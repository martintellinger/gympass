/// Key deposit (kauce) lifecycle — CLAUDE.md business rule §5.
///
/// The 100 Kč key deposit forfeits **automatically 30 days after the
/// membership expires** if the key has not been returned. Returning the key
/// settles it regardless of timing.
library;

const depositGraceDays = 30;

enum DepositStatus {
  /// Deposit held, nothing owed yet.
  paid,

  /// Key returned — deposit settled / refundable.
  returned,

  /// 30+ days past expiry without the key back → deposit is kept.
  forfeited,
}

/// Deposit status at [now] for a membership that ended at [membershipEnd].
///
/// Returning the key always wins (even after the grace window — the owner
/// can still hand the money back). Otherwise the deposit forfeits once
/// [now] reaches `membershipEnd + 30 days`.
DepositStatus depositStatus({
  required DateTime membershipEnd,
  required bool keyReturned,
  required DateTime now,
}) {
  if (keyReturned) return DepositStatus.returned;
  final forfeitFrom = membershipEnd.add(const Duration(days: depositGraceDays));
  if (!now.isBefore(forfeitFrom)) return DepositStatus.forfeited;
  return DepositStatus.paid;
}

/// Whole days until the deposit forfeits (negative once forfeited).
/// Null when the key is already returned (nothing to forfeit).
int? daysUntilForfeit({
  required DateTime membershipEnd,
  required bool keyReturned,
  required DateTime now,
}) {
  if (keyReturned) return null;
  final forfeitFrom = membershipEnd.add(const Duration(days: depositGraceDays));
  final a = DateTime(now.year, now.month, now.day);
  final b = DateTime(forfeitFrom.year, forfeitFrom.month, forfeitFrom.day);
  return b.difference(a).inDays;
}
