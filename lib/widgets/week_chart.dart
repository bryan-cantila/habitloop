import 'package:flutter/material.dart';

import '../models/checkin.dart';
import '../theme.dart';

/// 7-day mini bar chart (CustomPainter) — last 7 days of check-ins.
class WeekChart extends StatelessWidget {
  final Set<String> days;
  final Color color;

  const WeekChart({super.key, required this.days, required this.color});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final values = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return days.contains(CheckIn.dayString(day));
    });
    final labels = List.generate(7, (i) {
      const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      final day = now.subtract(Duration(days: 6 - i));
      return names[day.weekday - 1];
    });
    return SizedBox(
      height: 92,
      child: CustomPaint(
        painter: _WeekPainter(
          values: values,
          labels: labels,
          active: color,
          inactive: AppTheme.sandDark.withValues(alpha: 0.4),
          textColor: AppTheme.inkTeal,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _WeekPainter extends CustomPainter {
  final List<bool> values;
  final List<String> labels;
  final Color active;
  final Color inactive;
  final Color textColor;

  _WeekPainter({
    required this.values,
    required this.labels,
    required this.active,
    required this.inactive,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const labelH = 20.0;
    final barArea = size.height - labelH;
    final slot = size.width / values.length;
    final barW = (slot * 0.52).clamp(10.0, 28.0);

    for (var i = 0; i < values.length; i++) {
      final cx = slot * i + slot / 2;
      final tall = values[i];
      final barH = tall ? barArea * 0.92 : barArea * 0.22;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, barArea - barH / 2),
          width: barW,
          height: barH,
        ),
        const Radius.circular(999),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = tall ? active : inactive,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontFamily: 'Roboto',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, barArea + 4));
    }
  }

  @override
  bool shouldRepaint(_WeekPainter old) =>
      old.values.toString() != values.toString();
}
