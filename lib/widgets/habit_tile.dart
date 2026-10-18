import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme.dart';
import 'streak_badge.dart';

/// One habit row on the Today screen: icon blob, name, streak badge and a
/// big tappable check circle with a subtle scale animation.
class HabitTile extends StatefulWidget {
  final Habit habit;

  const HabitTile({super.key, required this.habit});

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _pop, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final checked = provider.isCheckedToday(widget.habit.id);
    final streak = provider.currentStreak(widget.habit);
    final accent = Color(widget.habit.colorValue);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        onTap: () {
          if (!checked) {
            _pop.forward(from: 0);
          }
          provider.toggleToday(widget.habit.id);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Organic icon blob
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(22),
                  ),
                ),
                child: Icon(
                  habitIcons[widget.habit.iconIndex],
                  color: accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.inkTealDeep,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StreakBadge(streak: streak),
                  ],
                ),
              ),
              // Check circle
              ScaleTransition(
                scale: _scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: checked ? AppTheme.leafGreen : Colors.transparent,
                    border: Border.all(
                      color: checked
                          ? AppTheme.leafGreen
                          : AppTheme.inkTeal.withValues(alpha: 0.35),
                      width: 2.5,
                    ),
                  ),
                  child: checked
                      ? const Icon(
                          Icons.check,
                          color: AppTheme.cream,
                          size: 26,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
