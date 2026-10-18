import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/checkin.dart';
import '../providers/habit_provider.dart';
import '../theme.dart';
import '../widgets/habit_tile.dart';
import '../widgets/progress_ring.dart';

/// Today: the habit list with big check circles, streaks and a progress ring.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final habits = provider.activeHabits;
    final progress = provider.todayProgress;
    final todayKey = CheckIn.dayString(DateTime.now());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            _greeting(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.inkTealDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Small steps, every day.',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.inkTeal.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          // Progress hero card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ProgressRing(
                    done: progress.done,
                    total: progress.total,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progress.total == 0
                              ? 'No habits yet'
                              : progress.done == progress.total
                                  ? 'All done — lovely.'
                                  : '${progress.total - progress.done} to go',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.inkTealDeep,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Checked in for $todayKey',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.inkTeal
                                .withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (habits.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Icon(
                      Icons.spa_outlined,
                      size: 44,
                      color: AppTheme.leafGreen.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Plant your first habit',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.inkTealDeep,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap + below to add one — reading, walking, meditating, anything small.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            AppTheme.inkTeal.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            for (final habit in habits) HabitTile(habit: habit),
        ],
      ),
    );
  }
}
