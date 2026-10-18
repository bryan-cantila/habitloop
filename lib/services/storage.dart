import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/checkin.dart';
import '../models/habit.dart';

/// On-device persistence via SharedPreferences.
///
/// Honest scope for a demo: habits + check-ins as JSON. A production app
/// with thousands of check-ins would move to drift/isar.
class StorageService {
  static const _habitsKey = 'habitloop_habits_v1';
  static const _checkInsKey = 'habitloop_checkins_v1';

  Future<({List<Habit> habits, List<CheckIn> checkIns})> load() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString(_habitsKey);
    final checkInsJson = prefs.getString(_checkInsKey);

    final habits = <Habit>[];
    if (habitsJson != null) {
      for (final item in jsonDecode(habitsJson) as List) {
        habits.add(Habit.fromJson(item as Map<String, dynamic>));
      }
    }
    final checkIns = <CheckIn>[];
    if (checkInsJson != null) {
      for (final item in jsonDecode(checkInsJson) as List) {
        checkIns.add(CheckIn.fromJson(item as Map<String, dynamic>));
      }
    }
    return (habits: habits, checkIns: checkIns);
  }

  Future<void> save(List<Habit> habits, List<CheckIn> checkIns) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _habitsKey,
      jsonEncode([for (final h in habits) h.toJson()]),
    );
    await prefs.setString(
      _checkInsKey,
      jsonEncode([for (final c in checkIns) c.toJson()]),
    );
  }
}
