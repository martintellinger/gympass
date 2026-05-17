import 'package:flutter_test/flutter_test.dart';

import 'package:bytfit_klub/core/domain/opening_hours.dart';

DateTime at(int h, int m) => DateTime(2026, 5, 16, h, m);

void main() {
  group('clubStatus (§14 — informational indicator)', () {
    const day = DayHours(9 * 60, 21 * 60); // 09:00–21:00

    test('no hours set → closed all day (red)', () {
      expect(clubStatus(DayHours.closed, at(12, 0)), ClubStatus.closedAllDay);
      expect(clubStatus(const DayHours(540, null), at(12, 0)),
          ClubStatus.closedAllDay);
    });

    test('within hours → open (green)', () {
      expect(clubStatus(day, at(9, 0)), ClubStatus.open);
      expect(clubStatus(day, at(14, 30)), ClubStatus.open);
      expect(clubStatus(day, at(20, 59)), ClubStatus.open);
    });

    test('before opening → closed, opens later (yellow)', () {
      expect(clubStatus(day, at(7, 0)), ClubStatus.closedOpensLater);
    });

    test('at/after close → closed for today', () {
      expect(clubStatus(day, at(21, 0)), ClubStatus.closedForToday);
      expect(clubStatus(day, at(23, 0)), ClubStatus.closedForToday);
    });

    test('overnight span (18:00–01:00) reads as open across midnight', () {
      const night = DayHours(18 * 60, 1 * 60);
      expect(clubStatus(night, at(20, 0)), ClubStatus.open);
      expect(clubStatus(night, at(0, 30)), ClubStatus.open);
      expect(clubStatus(night, at(12, 0)), ClubStatus.closedOpensLater);
    });
  });

  group('minutesUntilOpen', () {
    const day = DayHours(9 * 60, 21 * 60);

    test('counts down before opening', () {
      expect(minutesUntilOpen(day, at(8, 30)), 30);
    });

    test('null when already open', () {
      expect(minutesUntilOpen(day, at(10, 0)), isNull);
    });

    test('null after close (no longer opening today)', () {
      expect(minutesUntilOpen(day, at(22, 0)), isNull);
    });

    test('null when there are no hours', () {
      expect(minutesUntilOpen(DayHours.closed, at(8, 0)), isNull);
    });
  });
}
