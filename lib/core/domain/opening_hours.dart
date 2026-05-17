/// Club open/closed indicator — CLAUDE.md business rules §14–§15.
///
/// `opening_hours` is **informational only** (when Olda is usually around);
/// key holders have 24/7 access and app functions never depend on it. This
/// computes the header dot:
/// - both times null  → closed all day            (red)
/// - now within hours  → open                      (green)
/// - before today's open → closed, opens later     (yellow)
/// - after today's close → closed for today        (yellow/grey)
///
/// Times are minutes from local midnight (0–1439). A close ≤ open is treated
/// as spanning past midnight (e.g. open 18:00, close 01:00).
library;

class DayHours {
  final int? openMinutes;
  final int? closeMinutes;
  const DayHours(this.openMinutes, this.closeMinutes);

  /// A day with no hours set — the club indicator shows red.
  static const closed = DayHours(null, null);

  bool get hasHours => openMinutes != null && closeMinutes != null;
}

enum ClubStatus {
  open,
  closedOpensLater,
  closedForToday,
  closedAllDay,
}

int _minutesOfDay(DateTime t) => t.hour * 60 + t.minute;

/// Status for [today]'s hours at [now].
ClubStatus clubStatus(DayHours today, DateTime now) {
  if (!today.hasHours) return ClubStatus.closedAllDay;
  final open = today.openMinutes!;
  final close = today.closeMinutes!;
  final m = _minutesOfDay(now);

  if (close > open) {
    if (m < open) return ClubStatus.closedOpensLater;
    if (m >= close) return ClubStatus.closedForToday;
    return ClubStatus.open;
  }
  // Overnight span: open in [open, 24:00) or [0, close).
  if (m >= open || m < close) return ClubStatus.open;
  return ClubStatus.closedOpensLater;
}

/// Minutes until the club next opens today, or null if it is open now or
/// has no hours / has already closed for the day (non-overnight).
int? minutesUntilOpen(DayHours today, DateTime now) {
  if (!today.hasHours) return null;
  final open = today.openMinutes!;
  final m = _minutesOfDay(now);
  if (clubStatus(today, now) == ClubStatus.closedOpensLater && m < open) {
    return open - m;
  }
  return null;
}
