import '../models/checkin.dart';

/// Pure streak mathematics for HabitLoop.
///
/// A streak is a run of consecutive calendar days with a check-in.
/// "Today" counts as done when checked; if today is not checked yet but
/// yesterday was, the streak is still alive (grace) — it only breaks when
/// a full calendar day passes with no check-in.
///
/// Weekly habits ([weeklyTarget] < 7) are scored per ISO week: a week
/// counts when check-ins that week reach the target. The streak is the
/// run of consecutive qualifying weeks ending in the current (or
/// previous, with grace) week.
class StreakService {
  /// Days on which [habitId] was checked, as yyyy-MM-dd keys.
  static Set<String> daysFor(String habitId, Iterable<CheckIn> checkIns) =>
      {for (final c in checkIns) if (c.habitId == habitId) c.day};

  /// Current streak for a daily habit.
  static int currentStreak(
    Set<String> days, {
    DateTime? now,
  }) {
    final today = _dayKey(now ?? DateTime.now());
    final yesterday = _dayKey((now ?? DateTime.now()).subtract(
      const Duration(days: 1),
    ));

    // Anchor: today if checked, else yesterday (grace), else the streak
    // is already broken.
    String anchor;
    if (days.contains(today)) {
      anchor = today;
    } else if (days.contains(yesterday)) {
      anchor = yesterday;
    } else {
      return 0;
    }

    var streak = 0;
    var cursor = CheckIn.parseDay(anchor);
    while (days.contains(_dayKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Longest run of consecutive checked days, ever.
  static int longestStreak(Set<String> days) {
    if (days.isEmpty) return 0;
    final sorted = days.map(CheckIn.parseDay).toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
        run++;
        if (run > best) best = run;
      } else {
        run = 1;
      }
    }
    return best;
  }

  /// Fraction of the last [windowDays] days (ending today) with check-ins.
  static double completionRate(
    Set<String> days, {
    int windowDays = 30,
    DateTime? now,
  }) {
    if (windowDays <= 0) return 0;
    final today = now ?? DateTime.now();
    var hits = 0;
    for (var i = 0; i < windowDays; i++) {
      if (days.contains(
        _dayKey(today.subtract(Duration(days: i))),
      )) {
        hits++;
      }
    }
    return hits / windowDays;
  }

  /// Check-ins grouped per ISO week key ("2026-W42") for weekly habits.
  static Map<String, int> weeklyCounts(Set<String> days) {
    final counts = <String, int>{};
    for (final day in days) {
      final key = _weekKey(CheckIn.parseDay(day));
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  /// Current streak of consecutive weeks meeting [weeklyTarget].
  static int currentWeeklyStreak(
    Set<String> days,
    int weeklyTarget, {
    DateTime? now,
  }) {
    final counts = weeklyCounts(days);
    final ref = now ?? DateTime.now();
    var cursor = _weekKey(ref);
    final thisWeekCount = counts[cursor] ?? 0;

    // Grace: if the current week hasn't hit target yet, the streak is
    // still alive when last week qualified.
    if (thisWeekCount < weeklyTarget) {
      final prev = _weekKey(ref.subtract(const Duration(days: 7)));
      if ((counts[prev] ?? 0) < weeklyTarget) return 0;
      cursor = prev;
    }

    var streak = 0;
    var probe = _weekMonday(cursor);
    while ((counts[_weekKey(probe)] ?? 0) >= weeklyTarget) {
      streak++;
      probe = probe.subtract(const Duration(days: 7));
    }
    return streak;
  }

  // --- helpers ---------------------------------------------------------

  static String _dayKey(DateTime dt) => CheckIn.dayString(dt);

  /// ISO week key. The Thursday of the date's week decides the week-year;
  /// week 1 is the week containing Jan 4.
  static String _weekKey(DateTime dt) {
    final thursday = dt.add(Duration(days: 4 - dt.weekday));
    final week1Monday = _week1Monday(thursday.year);
    final week = 1 + (thursday.difference(week1Monday).inDays ~/ 7);
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }

  /// Monday of ISO week 1 for [year] (the week containing Jan 4).
  static DateTime _week1Monday(int year) {
    final jan4 = DateTime(year, 1, 4);
    return jan4.subtract(Duration(days: jan4.weekday - 1));
  }

  /// Monday of the ISO week named by [key] ("2026-W42").
  static DateTime _weekMonday(String key) {
    final year = int.parse(key.substring(0, 4));
    final week = int.parse(key.substring(6));
    return _week1Monday(year).add(Duration(days: (week - 1) * 7));
  }
}
