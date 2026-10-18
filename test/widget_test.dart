import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitloop/models/habit.dart';
import 'package:habitloop/providers/habit_provider.dart';
import 'package:habitloop/screens/today_screen.dart';
import 'package:habitloop/services/storage.dart';
import 'package:habitloop/models/checkin.dart';
import 'package:provider/provider.dart';

/// In-memory storage so widget tests never touch SharedPreferences.
class _MemoryStorage extends StorageService {
  List<Habit> habits = [];
  List<CheckIn> checkIns = [];

  @override
  Future<({List<Habit> habits, List<CheckIn> checkIns})> load() async =>
      (habits: habits, checkIns: checkIns);

  @override
  Future<void> save(List<Habit> habits, List<CheckIn> checkIns) async {
    this.habits = List.of(habits);
    this.checkIns = List.of(checkIns);
  }
}

Habit _habit(String id, String name) => Habit(
      id: id,
      name: name,
      iconIndex: 0,
      colorValue: Colors.teal.toARGB32(),
      createdAt: DateTime(2026, 1, 1),
    );

Future<void> _pumpToday(
  WidgetTester tester,
  HabitProvider provider,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: provider,
      child: const MaterialApp(home: TodayScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('today screen lists habits and empty state', (tester) async {
    final storage = _MemoryStorage();
    final provider = HabitProvider(storage: storage);
    await provider.load();

    await _pumpToday(tester, provider);
    expect(find.text('Plant your first habit'), findsOneWidget);

    await provider.addHabit(_habit('h1', 'Read 20 pages'));
    await tester.pumpAndSettle();
    expect(find.text('Read 20 pages'), findsOneWidget);
    expect(find.text('Plant your first habit'), findsNothing);
  });

  testWidgets('tapping the check circle toggles today', (tester) async {
    final storage = _MemoryStorage();
    final provider = HabitProvider(storage: storage);
    await provider.load();
    await provider.addHabit(_habit('h1', 'Meditate'));

    await _pumpToday(tester, provider);
    expect(provider.isCheckedToday('h1'), isFalse);

    // The check circle is the InkWell inside the habit tile.
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(provider.isCheckedToday('h1'), isTrue);
    expect(find.text('1/1'), findsOneWidget);

    // Tap again to uncheck.
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(provider.isCheckedToday('h1'), isFalse);
  });

  testWidgets('progress ring shows X of Y', (tester) async {
    final storage = _MemoryStorage();
    final provider = HabitProvider(storage: storage);
    await provider.load();
    await provider.addHabit(_habit('h1', 'Walk'));
    await provider.addHabit(_habit('h2', 'Read'));
    await provider.toggleToday('h1');

    await _pumpToday(tester, provider);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('1 to go'), findsOneWidget);
  });
}
