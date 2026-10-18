/// A habit the user wants to repeat.
///
/// [weeklyTarget] is how many days per week count as "on track"
/// (7 = every day). [reminderMinutes] is minutes since midnight for the
/// daily reminder, or null when reminders are off.
class Habit {
  final String id;
  final String name;
  final int iconIndex;
  final int colorValue;
  final int weeklyTarget;
  final bool archived;
  final int? reminderMinutes;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.name,
    required this.iconIndex,
    required this.colorValue,
    this.weeklyTarget = 7,
    this.archived = false,
    this.reminderMinutes,
    required this.createdAt,
  });

  Habit copyWith({
    String? name,
    int? iconIndex,
    int? colorValue,
    int? weeklyTarget,
    bool? archived,
    int? reminderMinutes,
    bool clearReminder = false,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      iconIndex: iconIndex ?? this.iconIndex,
      colorValue: colorValue ?? this.colorValue,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
      archived: archived ?? this.archived,
      reminderMinutes:
          clearReminder ? null : (reminderMinutes ?? this.reminderMinutes),
      createdAt: createdAt,
    );
  }

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        iconIndex: json['iconIndex'] as int,
        colorValue: json['colorValue'] as int,
        weeklyTarget: (json['weeklyTarget'] as num?)?.toInt() ?? 7,
        archived: (json['archived'] as bool?) ?? false,
        reminderMinutes: (json['reminderMinutes'] as num?)?.toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconIndex': iconIndex,
        'colorValue': colorValue,
        'weeklyTarget': weeklyTarget,
        'archived': archived,
        'reminderMinutes': reminderMinutes,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Human-readable reminder label, e.g. "7:30 AM".
  String? get reminderLabel {
    final mins = reminderMinutes;
    if (mins == null) return null;
    final h24 = mins ~/ 60;
    final m = mins % 60;
    final suffix = h24 >= 12 ? 'PM' : 'AM';
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '$h12:${m.toString().padLeft(2, '0')} $suffix';
  }
}
