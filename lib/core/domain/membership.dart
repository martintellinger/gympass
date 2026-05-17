/// Membership expiration & renewal — the financially sensitive core of the
/// app (CLAUDE.md business rules §2–§4). Pure functions, no I/O, so they can
/// be unit-tested before the Supabase layer calls them.
///
/// Product assumptions baked in (flagged for confirmation in the handoff):
/// - `billingDay` is 1–31; a null billing day means the 1st.
/// - Expiration always lands on the billing day of its month; if that month
///   is shorter (Feb, 30-day months) it falls back to the **last day of the
///   month** — Stripe-style anchored billing (§3).
/// - Paying while the membership is still valid **adds the new period to the
///   existing expiry**, not to "today" (§4); the billing day is preserved.
/// - A membership is valid up to — but not including — its expiry date
///   (expiry = the day access lapses).
library;

/// Days in (year, month), month 1–12.
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// The [billingDay] of (year, month), clamped to a real calendar day.
DateTime billingDayOf(int year, int month, int? billingDay) {
  // Normalise month overflow/underflow (e.g. month 14 → next year Feb).
  final y = year + ((month - 1) ~/ 12);
  final m = ((month - 1) % 12) + 1;
  final day = (billingDay ?? 1).clamp(1, daysInMonth(y, m));
  return DateTime(y, m, day);
}

/// Whether a membership with [expiry] has lapsed at [now].
/// Valid strictly before the expiry instant.
bool isExpired(DateTime expiry, DateTime now) => !now.isBefore(expiry);

/// New expiry after paying [months] of membership.
///
/// Base is the current expiry when the membership is still valid (renewal
/// stacks on top, §4), otherwise [now] (a fresh or lapsed member starts from
/// today). The result is anchored to [billingDay] of the resulting month.
DateTime nextExpiration({
  required DateTime now,
  DateTime? currentExpiry,
  required int months,
  int? billingDay,
}) {
  assert(months > 0, 'months must be positive');
  final stillValid = currentExpiry != null && currentExpiry.isAfter(now);
  final base = stillValid ? currentExpiry : now;
  return billingDayOf(base.year, base.month + months, billingDay);
}

/// New expiry after a member-initiated pause that ran from [pausedAt] to
/// [resumedAt] (member self-pause: holiday / long-term illness).
///
/// The membership is **frozen** while paused — the remaining time is not
/// consumed — so the expiry slides forward by the whole-day pause duration.
/// The key-deposit forfeit clock (§5) is anchored to the membership end, so
/// shifting the expiry through this function automatically defers the
/// forfeit deadline by the same amount (no separate deposit handling needed).
///
/// A zero/negative span (resumed the same day or clock skew) is a no-op.
DateTime expiryAfterPause({
  required DateTime expiry,
  required DateTime pausedAt,
  required DateTime resumedAt,
}) {
  final from = DateTime(pausedAt.year, pausedAt.month, pausedAt.day);
  final to = DateTime(resumedAt.year, resumedAt.month, resumedAt.day);
  final pausedDays = to.difference(from).inDays;
  if (pausedDays <= 0) return expiry;
  return DateTime(expiry.year, expiry.month, expiry.day + pausedDays,
      expiry.hour, expiry.minute, expiry.second);
}

/// Whole days of membership left at [now] (negative if already lapsed).
/// Counts calendar days, ignoring the time component.
int daysLeft(DateTime expiry, DateTime now) {
  final a = DateTime(now.year, now.month, now.day);
  final b = DateTime(expiry.year, expiry.month, expiry.day);
  return b.difference(a).inDays;
}
