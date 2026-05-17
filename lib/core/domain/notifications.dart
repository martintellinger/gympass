/// Expiry-notification schedule — CLAUDE.md business rule §10.
///
/// Triggers fire at −14, −3, 0, +1, +7, +30 days relative to the membership
/// expiry, at a fixed local time of day (default 09:00). Pure scheduling
/// only — delivery (FCM/APNs) and `notification_preferences` filtering are a
/// later phase that consumes this.
library;

const notificationOffsetsDays = <int>[-14, -3, 0, 1, 7, 30];

class NotificationTrigger {
  /// Offset in days from the expiry date (negative = before expiry).
  final int offsetDays;
  final DateTime fireAt;
  const NotificationTrigger(this.offsetDays, this.fireAt);

  @override
  String toString() => 'NotificationTrigger($offsetDays, $fireAt)';
}

/// All triggers for a membership expiring on [expiry], in chronological
/// order. [timeOfDay] is the local wall-clock time each notification fires.
List<NotificationTrigger> notificationSchedule(
  DateTime expiry, {
  Duration timeOfDay = const Duration(hours: 9),
}) {
  final day = DateTime(expiry.year, expiry.month, expiry.day);
  return [
    for (final off in notificationOffsetsDays)
      NotificationTrigger(
        off,
        day.add(Duration(days: off)) + timeOfDay,
      ),
  ]..sort((a, b) => a.fireAt.compareTo(b.fireAt));
}

/// The next trigger strictly after [now], or null when all have passed.
NotificationTrigger? nextNotification(
  DateTime expiry,
  DateTime now, {
  Duration timeOfDay = const Duration(hours: 9),
}) {
  for (final t in notificationSchedule(expiry, timeOfDay: timeOfDay)) {
    if (t.fireAt.isAfter(now)) return t;
  }
  return null;
}

extension on DateTime {
  DateTime operator +(Duration d) => add(d);
}
