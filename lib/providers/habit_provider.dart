import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/checkin.dart';
import '../models/habit.dart';
import '../services/notifications.dart';
import '../services/storage.dart';
import '../services/streak.dart';

/// Central app state: habits + check-ins, persisted on-device.
class HabitProvider extends ChangeNotifier {
  final StorageService _storage;
  final List<Habit> _habits = [];
  final List<CheckIn> _checkIns = [];
  bool _loaded = false;

  HabitProvider({StorageService? storage})
      : _storage = storage ?? StorageService();

  bool get loaded => _loaded;
  List<Habit> get habits => List.unmodifiable(_habits);
  List<Habit> get activeHabits =>
      _habits.where((h) => !h.archived).toList();
  List<Habit> get archivedHabits =>
      _habits.where((h) => h.archived).toList();

  Future<void> load() async {
    final data = await _storage.load();
    _habits
      ..clear()
      ..addAll(data.habits);
    _checkIns
      ..clear()
      ..addAll(data.checkIns);
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() => _storage.save(_habits, _checkIns);

  Set<String> daysFor(String habitId) =>
      StreakService.daysFor(habitId, _checkIns);

  bool isCheckedToday(String habitId) =>
      daysFor(habitId).contains(CheckIn.dayString(DateTime.now()));

  Future<void> toggleToday(String habitId) async {
    final today = CheckIn.dayString(DateTime.now());
    final existing =
        _checkIns.any((c) => c.habitId == habitId && c.day == today);
    if (existing) {
      _checkIns.removeWhere(
        (c) => c.habitId == habitId && c.day == today,
      );
    } else {
      _checkIns.add(CheckIn(habitId: habitId, day: today));
    }
    await _persist();
    notifyListeners();
  }

  /// "X of Y done today" across active habits.
  ({int done, int total}) get todayProgress {
    final active = activeHabits;
    final done = active.where((h) => isCheckedToday(h.id)).length;
    return (done: done, total: active.length);
  }

  int currentStreak(Habit habit) {
    final days = daysFor(habit.id);
    if (habit.weeklyTarget >= 7) {
      return StreakService.currentStreak(days);
    }
    return StreakService.currentWeeklyStreak(days, habit.weeklyTarget);
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await NotificationService.instance.scheduleFor(habit);
    await _persist();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    final i = _habits.indexWhere((h) => h.id == habit.id);
    if (i != -1) {
      _habits[i] = habit;
      await NotificationService.instance.scheduleFor(habit);
      await _persist();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    final habit = _habits.where((h) => h.id == id).firstOrNull;
    if (habit != null) {
      await NotificationService.instance.cancelFor(habit);
    }
    _habits.removeWhere((h) => h.id == id);
    _checkIns.removeWhere((c) => c.habitId == id);
    await _persist();
    notifyListeners();
  }

  Future<void> setArchived(String id, bool archived) async {
    final i = _habits.indexWhere((h) => h.id == id);
    if (i != -1) {
      _habits[i] = _habits[i].copyWith(archived: archived);
      await _persist();
      notifyListeners();
    }
  }
}
