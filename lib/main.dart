import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/habit_provider.dart';
import 'screens/habits_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/today_screen.dart';
import 'services/notifications.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Reminders are best-effort: the app works fully without them.
  try {
    await NotificationService.instance.init();
  } catch (_) {
    // Notification plugin unavailable (e.g. desktop test) — continue.
  }
  runApp(const HabitLoopApp());
}

class HabitLoopApp extends StatelessWidget {
  const HabitLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HabitProvider()..load(),
      child: MaterialApp(
        title: 'HabitLoop',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const _Home(),
      ),
    );
  }
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  int _index = 0;

  static const _screens = [
    TodayScreen(),
    HabitsScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: _index == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showAddHabitSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Habit'),
            ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.today_outlined),
              activeIcon: Icon(Icons.today),
              label: 'Today',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.spa_outlined),
              activeIcon: Icon(Icons.spa),
              label: 'Habits',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}
