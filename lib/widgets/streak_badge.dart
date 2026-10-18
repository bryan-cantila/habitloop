import 'package:flutter/material.dart';

import '../theme.dart';

/// Small flame badge showing the current streak count.
class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final hot = streak >= 7;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: hot ? AppTheme.clay : AppTheme.leafLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 14,
            color: hot ? AppTheme.cream : AppTheme.leafGreen,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: hot ? AppTheme.cream : AppTheme.inkTeal,
            ),
          ),
        ],
      ),
    );
  }
}
