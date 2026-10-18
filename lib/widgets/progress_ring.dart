import 'package:flutter/material.dart';

import '../theme.dart';

/// A soft organic ring showing "done / total" for today.
class ProgressRing extends StatelessWidget {
  final int done;
  final int total;
  final double size;

  const ProgressRing({
    super.key,
    required this.done,
    required this.total,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : done / total;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: fraction,
          track: AppTheme.sandDark.withValues(alpha: 0.45),
          fill: AppTheme.inkTeal,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$done/$total',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.inkTealDeep,
                ),
              ),
              const Text(
                'today',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.inkTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color track;
  final Color fill;

  _RingPainter({
    required this.fraction,
    required this.track,
    required this.fill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const start = -1.5708; // top

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      6.2832 * fraction.clamp(0.0, 1.0),
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}
