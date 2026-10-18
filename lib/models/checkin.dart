/// A single check-in: one habit completed on one calendar day.
///
/// Stored as a `yyyy-MM-dd` date string so it is timezone-agnostic and
/// trivially serializable.
class CheckIn {
  final String habitId;
  final String day; // yyyy-MM-dd

  const CheckIn({required this.habitId, required this.day});

  factory CheckIn.today(String habitId) =>
      CheckIn(habitId: habitId, day: CheckIn.dayString(DateTime.now()));

  factory CheckIn.fromJson(Map<String, dynamic> json) => CheckIn(
        habitId: json['habitId'] as String,
        day: json['day'] as String,
      );

  Map<String, dynamic> toJson() => {'habitId': habitId, 'day': day};

  /// Normalizes any DateTime to its calendar-day key.
  static String dayString(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  static DateTime parseDay(String day) {
    final parts = day.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckIn && habitId == other.habitId && day == other.day;

  @override
  int get hashCode => Object.hash(habitId, day);
}
