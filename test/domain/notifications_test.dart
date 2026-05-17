import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/core/domain/notifications.dart';

void main() {
  final expiry = DateTime(2026, 6, 1);

  group('notificationSchedule (§10 — −14/−3/0/+1/+7/+30)', () {
    test('produces all six triggers in chronological order', () {
      final s = notificationSchedule(expiry);
      expect(s.map((t) => t.offsetDays), [-14, -3, 0, 1, 7, 30]);
      for (var i = 1; i < s.length; i++) {
        expect(s[i].fireAt.isAfter(s[i - 1].fireAt), isTrue);
      }
    });

    test('fires at the configured time of day on the right dates', () {
      final s = notificationSchedule(expiry);
      final zero = s.firstWhere((t) => t.offsetDays == 0);
      expect(zero.fireAt, DateTime(2026, 6, 1, 9));
      final minus14 = s.firstWhere((t) => t.offsetDays == -14);
      expect(minus14.fireAt, DateTime(2026, 5, 18, 9));
      final plus30 = s.firstWhere((t) => t.offsetDays == 30);
      expect(plus30.fireAt, DateTime(2026, 7, 1, 9));
    });

    test('honours a custom time of day', () {
      final s = notificationSchedule(expiry,
          timeOfDay: const Duration(hours: 18, minutes: 30));
      expect(s.firstWhere((t) => t.offsetDays == 0).fireAt,
          DateTime(2026, 6, 1, 18, 30));
    });
  });

  group('nextNotification', () {
    test('returns the upcoming trigger after now', () {
      final n = nextNotification(expiry, DateTime(2026, 5, 30));
      expect(n, isNotNull);
      expect(n!.offsetDays, 0); // -14 passed, next is the expiry-day one
    });

    test('null once every trigger has passed', () {
      expect(nextNotification(expiry, DateTime(2026, 8, 1)), isNull);
    });

    test('first trigger when now is well before expiry', () {
      final n = nextNotification(expiry, DateTime(2026, 1, 1));
      expect(n!.offsetDays, -14);
    });
  });
}
