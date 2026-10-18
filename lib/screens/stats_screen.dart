import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../services/streak.dart';
import '../theme.dart';
import '../widgets/week_chart.dart';

/// Stats: per-habit streaks, longest streak, 7-day chart, completion rate.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final habits = provider.activeHabits;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          const Text(
            'Stats',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.inkTealDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your consistency, at a glance.',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.inkTeal.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          if (habits.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Add a habit to start collecting stats.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.inkTeal),
                ),
              ),
            )
          else
            for (final habit in habits)
              _StatCard(habit: habit, provider: provider),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Habit habit;
  final HabitProvider provider;

  const _StatCard({required this.habit, required this.provider});

  @override
  Widget build(BuildContext context) {
    final days = provider.daysFor(habit.id);
    final current = provider.currentStreak(habit);
    final longest = StreakService.longestStreak(days);
    final rate = StreakService.completionRate(days);
    final accent = Color(habit.colorValue);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Icon(
                    habitIcons[habit.iconIndex],
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.inkTealDeep,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Metric(
                  label: 'Current streak',
                  value: '$current',
                  suffix: current == 1 ? 'day' : 'days',
                ),
                _Metric(
                  label: 'Longest',
                  value: '$longest',
                  suffix: longest == 1 ? 'day' : 'days',
                ),
                _Metric(
                  label: '30-day rate',
                  value: '${(rate * 100).round()}%',
                  suffix: '',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Last 7 days',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.inkTeal.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            WeekChart(days: days, color: accent),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;

  const _Metric({
    required this.label,
    required this.value,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.inkTeal.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (suffix.isNotEmpty)
                  TextSpan(
                    text: ' $suffix',
                    style: const TextStyle(fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
