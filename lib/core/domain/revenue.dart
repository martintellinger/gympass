/// Revenue aggregation — CLAUDE.md business rule §9.
///
/// Only confirmed (`ok`) payments count. Historical payments imported from
/// the Excel (`is_historical = true`) are **excluded from revenue stats by
/// default** and tallied separately. The `Payment` model has no historical
/// flag yet (it lands with the migration/backend), so callers pass an
/// [isHistorical] predicate; the inline sums in admin_payments can move here
/// once the flag exists.
library;

import '../store/models.dart';

bool _confirmed(Payment p) => p.state == 'ok';

/// Sum of confirmed payments in [year] (optionally a single [month]).
/// Historical payments are excluded unless [includeHistorical] is true.
int revenueSum(
  Iterable<Payment> payments, {
  required int year,
  int? month,
  bool includeHistorical = false,
  bool Function(Payment)? isHistorical,
}) {
  var total = 0;
  for (final p in payments) {
    if (!_confirmed(p)) continue;
    if (p.date.year != year) continue;
    if (month != null && p.date.month != month) continue;
    if (!includeHistorical && (isHistorical?.call(p) ?? false)) continue;
    total += p.amount;
  }
  return total;
}

/// Sum of payments currently past due (`overdue`) — money owed, not revenue.
int overdueTotal(Iterable<Payment> payments) {
  var total = 0;
  for (final p in payments) {
    if (p.state == 'overdue') total += p.amount;
  }
  return total;
}
