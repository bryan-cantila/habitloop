import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';

/// Daily habit reminders via scheduled local notifications.
///
/// 100% on-device — no server, no account. Scheduling was implemented
/// against the flutter_local_notifications API; exact alarm behavior
/// (exact vs inexact, doze mode) varies by Android version and needs a
/// physical device to verify end-to-end.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  Future<void> init() async {
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  /// (Re)schedules the daily reminder for [habit], or cancels it when the
  /// habit has no reminder set.
  Future<void> scheduleFor(Habit habit) async {
    if (!_ready) return;
    await _plugin.cancel(habit.id.hashCode);
    final minutes = habit.reminderMinutes;
    if (minutes == null) return;

    await _plugin.zonedSchedule(
      habit.id.hashCode,
      'Time for "${habit.name}"',
      'A small step today keeps your streak alive.',
      _nextInstance(minutes),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habitloop_reminders',
          'Habit reminders',
          channelDescription: 'Daily reminders for your habits',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelFor(Habit habit) async {
    if (!_ready) return;
    await _plugin.cancel(habit.id.hashCode);
  }

  tz.TZDateTime _nextInstance(int minutesSinceMidnight) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutesSinceMidnight ~/ 60,
      minutesSinceMidnight % 60,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
