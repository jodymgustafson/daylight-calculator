import 'package:daylight_calc/daylight_utils.dart';
import 'package:flutter/material.dart';

class DaylightCurveGraph extends StatelessWidget {
  const DaylightCurveGraph({
    super.key,
    required this.latitude,
    this.height = 260,
    this.daysInYear = 365,
  }) : assert(height > 0),
       assert(daysInYear > 1);

  final double latitude;
  final double height;
  final int daysInYear;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Daylight hours by day of year, from 0 to 24 hours over $daysInYear days',
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 360.0;
            return CustomPaint(
              key: const Key('daylight-curve-graph'),
              size: Size(width, height),
              painter: _DaylightCurvePainter(
                latitude: latitude,
                daysInYear: daysInYear,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DaylightCurvePainter extends CustomPainter {
  const _DaylightCurvePainter({
    required this.latitude,
    required this.daysInYear,
  });

  final double latitude;
  final int daysInYear;

  static const _leftInset = 16.0;
  static const _rightInset = 0.0;
  static const _topInset = 0.0;
  static const _bottomInset = 0.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    final plot = Rect.fromLTRB(
      _leftInset,
      _topInset,
      size.width - _rightInset,
      size.height - _bottomInset,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    _drawCurve(plot, canvas);

    final axisPaint = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 1;

    _drawYAxis(plot, canvas, axisPaint);
    _drawXAxis(plot, canvas, axisPaint);
  }

  void _drawCurve(Rect plot, Canvas canvas) {
    final areaPath = Path()..moveTo(plot.left, plot.bottom);
    final curvePath = Path();
    for (var day = 0; day < daysInYear; day++) {
      final x = plot.left + (day / (daysInYear - 1)) * plot.width;
      final daylightHours = getDaylightHours(latitude, day);
      final y = plot.bottom - (daylightHours / 24) * plot.height;
      if (day == 0) {
        curvePath.moveTo(x, y);
      } else {
        curvePath.lineTo(x, y);
      }
      areaPath.lineTo(x, y);
    }

    areaPath
      ..lineTo(plot.right, plot.bottom)
      ..close();

    canvas.drawPath(areaPath, Paint()..color = Colors.yellow);
    canvas.drawPath(
      curvePath,
      Paint()
        ..color = Colors.yellowAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawXAxis(Rect plot, Canvas canvas, Paint axisPaint) {
    final dayTicks = <int>{1, 100, 200, 300, daysInYear}.toList()..sort();
    for (final day in dayTicks) {
      final x = plot.left + ((day - 1) / (daysInYear - 1)) * plot.width;
      canvas.drawLine(
        Offset(x, plot.bottom),
        Offset(x, plot.bottom - 8),
        axisPaint,
      );
      _drawLabel(
        canvas,
        '$day',
        Offset(x, plot.bottom - 16),
        alignment: Alignment.topCenter,
      );
    }
  }

  void _drawYAxis(Rect plot, Canvas canvas, Paint axisPaint) {
    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..strokeWidth = 1;
    for (final hour in [4, 8, 12, 16, 20]) {
      final y = plot.bottom - (hour / 24) * plot.height;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _drawLabel(
        canvas,
        '$hour',
        Offset(_leftInset - 2, y),
        alignment: Alignment.centerRight,
      );
    }

    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      axisPaint,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset anchor, {
    required Alignment alignment,
  }) {
    final painter = _textPainter(text);
    painter.layout();
    final offset = Offset(
      anchor.dx - painter.width * (alignment.x + 1) / 2,
      anchor.dy - painter.height * (alignment.y + 1) / 2,
    );
    painter.paint(canvas, offset);
  }

  TextPainter _textPainter(String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.blueGrey, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    return painter;
  }

  @override
  bool shouldRepaint(covariant _DaylightCurvePainter oldDelegate) {
    return oldDelegate.latitude != latitude ||
        oldDelegate.daysInYear != daysInYear;
  }
}
