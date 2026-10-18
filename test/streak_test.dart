import 'package:flutter_test/flutter_test.dart';

import 'package:habitloop/models/checkin.dart';
import 'package:habitloop/services/streak.dart';

String d(DateTime dt) => CheckIn.dayString(dt);

Set<String> daysFrom(List<DateTime> dates) =>
    {for (final x in dates) d(x)};

void main() {
  final now = DateTime(2026, 10, 18); // a Sunday, fixed for determinism
  DateTime ago(int n) => DateTime(2026, 10, 18 - n);

  group('currentStreak', () {
    test('counts consecutive days ending today', () {
      final days = daysFrom([ago(0), ago(1), ago(2)]);
      expect(StreakService.currentStreak(days, now: now), 3);
    });

    test('grace: yesterday checked, today not yet -> streak alive', () {
      final days = daysFrom([ago(1), ago(2), ago(3)]);
      expect(StreakService.currentStreak(days, now: now), 3);
    });

    test('broken when yesterday missing', () {
      final days = daysFrom([ago(2), ago(3)]);
      expect(StreakService.currentStreak(days, now: now), 0);
    });

    test('empty set -> 0', () {
      expect(StreakService.currentStreak({}, now: now), 0);
    });

    test('gap inside the run stops the count', () {
      // today, yesterday, then a gap, then two older days
      final days = daysFrom([ago(0), ago(1), ago(3), ago(4)]);
      expect(StreakService.currentStreak(days, now: now), 2);
    });

    test('single check-in today -> 1', () {
      final days = daysFrom([ago(0)]);
      expect(StreakService.currentStreak(days, now: now), 1);
    });
  });

  group('longestStreak', () {
    test('finds the longest run', () {
      final days = daysFrom([
        ago(0),
        ago(1),
        ago(2), // run of 3
        ago(10),
        ago(11),
        ago(12),
        ago(13),
        ago(14), // run of 5
      ]);
      expect(StreakService.longestStreak(days), 5);
    });

    test('empty -> 0, single -> 1', () {
      expect(StreakService.longestStreak({}), 0);
      expect(StreakService.longestStreak(daysFrom([ago(5)])), 1);
    });
  });

  group('completionRate', () {
    test('half the window checked -> 0.5', () {
      final days = daysFrom(
        [for (var i = 0; i < 30; i += 2) ago(i)],
      );
      expect(
        StreakService.completionRate(days, windowDays: 30, now: now),
        closeTo(0.5, 0.001),
      );
    });

    test('zero window -> 0', () {
      expect(
        StreakService.completionRate(daysFrom([ago(0)]),
            windowDays: 0, now: now),
        0,
      );
    });
  });

  group('weekly streaks', () {
    // now = Sunday 2026-10-18. ISO weeks: this week Mon 10-12..Sun 10-18.
    test('three qualifying weeks in a row -> 3', () {
      final days = daysFrom([
        // this week: 3 check-ins (target 3)
        ago(0),
        ago(2),
        ago(4),
        // last week: 4 check-ins
        ago(8),
        ago(9),
        ago(11),
        ago(13),
        // week before: 3 check-ins
        ago(15),
        ago(17),
        ago(19),
      ]);
      expect(
        StreakService.currentWeeklyStreak(days, 3, now: now),
        3,
      );
    });

    test('week below target breaks the streak', () {
      final days = daysFrom([
        ago(0),
        ago(2),
        ago(4), // this week: 3 (target 3) OK
        ago(8), // last week: only 1 -> break
      ]);
      expect(
        StreakService.currentWeeklyStreak(days, 3, now: now),
        1,
      );
    });

    test('grace: current week short but last week qualified', () {
      final days = daysFrom([
        ago(1), // this week: 1 of 3
        ago(8),
        ago(9),
        ago(10), // last week: 3 of 3
      ]);
      expect(
        StreakService.currentWeeklyStreak(days, 3, now: now),
        1,
      );
    });

    test('no qualifying weeks -> 0', () {
      expect(
        StreakService.currentWeeklyStreak(
            daysFrom([ago(30)]), 3, now: now),
        0,
      );
    });
  });
}
