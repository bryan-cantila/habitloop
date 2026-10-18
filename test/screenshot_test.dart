import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitloop/models/checkin.dart';
import 'package:habitloop/models/habit.dart';
import 'package:habitloop/providers/habit_provider.dart';
import 'package:habitloop/screens/stats_screen.dart';
import 'package:habitloop/screens/today_screen.dart';
import 'package:habitloop/services/storage.dart';
import 'package:habitloop/theme.dart';
import 'package:provider/provider.dart';

/// In-memory storage seeded with demo habits + check-ins.
class _DemoStorage extends StorageService {
  List<Habit> habits = [];
  List<CheckIn> checkIns = [];

  _DemoStorage() {
    final now = DateTime.now();
    String day(int ago) =>
        CheckIn.dayString(now.subtract(Duration(days: ago)));
    habits = [
      Habit(
        id: 'h1',
        name: 'Read 20 pages',
        iconIndex: 2,
        colorValue: AppTheme.leafGreen.toARGB32(),
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      Habit(
        id: 'h2',
        name: 'Morning walk',
        iconIndex: 1,
        colorValue: const Color(0xFF4E9B8F).toARGB32(),
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      Habit(
        id: 'h3',
        name: 'Meditate 10 min',
        iconIndex: 6,
        colorValue: const Color(0xFFC97B4A).toARGB32(),
        createdAt: now.subtract(const Duration(days: 40)),
      ),
    ];
    checkIns = [
      for (var a in [0, 1, 2, 3, 4, 6, 7, 8])
        CheckIn(habitId: 'h1', day: day(a)),
      for (var a in [0, 1, 2])
        CheckIn(habitId: 'h2', day: day(a)),
      for (var a in [1, 2, 4, 5])
        CheckIn(habitId: 'h3', day: day(a)),
    ];
  }

  @override
  Future<({List<Habit> habits, List<CheckIn> checkIns})> load() async =>
      (habits: habits, checkIns: checkIns);

  @override
  Future<void> save(List<Habit> habits, List<CheckIn> checkIns) async {
    this.habits = List.of(habits);
    this.checkIns = List.of(checkIns);
  }
}

/// Screenshot capture (run with `flutter test --update-goldens`).
///
/// Renders Today + Stats with demo data at phone size and writes PNGs to
/// docs/. The SDK's Roboto is loaded in setUpAll (FontLoader hangs inside
/// testWidgets on this Flutter version) so text renders properly instead
/// of the test harness's block font.
void main() {
  setUpAll(() async {
    final sdkRoot = Platform.environment['FLUTTER_SDK'];
    if (sdkRoot == null) return;
    Future<void> loadFont(String family, String file) async {
      final f = File('$sdkRoot/bin/cache/artifacts/material_fonts/$file');
      if (!await f.exists()) return;
      final bytes = await f.readAsBytes();
      final loader = FontLoader(family)
        ..addFont(Future.value(ByteData.view(bytes.buffer)));
      await loader.load();
    }

    await loadFont('Roboto', 'Roboto-Regular.ttf');
    await loadFont('Roboto', 'Roboto-Bold.ttf');
    await loadFont('Roboto', 'Roboto-Medium.ttf');
    await loadFont('MaterialIcons', 'MaterialIcons-Regular.otf');
  });

  testWidgets('today screenshot', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final provider = HabitProvider(storage: _DemoStorage());
    await provider.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const TodayScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TodayScreen),
      matchesGoldenFile('../docs/today.png'),
    );
  });

  testWidgets('stats screenshot', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final provider = HabitProvider(storage: _DemoStorage());
    await provider.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const StatsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(StatsScreen),
      matchesGoldenFile('../docs/stats.png'),
    );
  });
}
