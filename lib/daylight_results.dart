import 'package:daylight_calc/daylight_utils.dart';
import 'package:flutter/material.dart';

import 'daylight_curve_graph.dart';
import 'vertical_bar_graph.dart';

class DaylightResults extends StatelessWidget {
  const DaylightResults({
    super.key,
    required this.latitude,
    required this.dayOfYear,
  });

  final double latitude;
  final int dayOfYear;

  @override
  Widget build(BuildContext context) {
    final calculationDayOfYear = dayOfYear - 1;
    final daylightHours = getDaylightHours(
      latitude,
      calculationDayOfYear,
      true,
    );
    final daylight = toHoursAndMinutes(daylightHours);
    final darkness = toHoursAndMinutes(24 - daylightHours);
    final daylightChange = getDaylightChange(latitude, calculationDayOfYear);
    final change = toHoursAndMinutes(daylightChange / 60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daylight: ${daylight.hours} hours, ${daylight.minutes.toStringAsFixed(1)} minutes',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Darkness: ${darkness.hours} hours, ${darkness.minutes.toStringAsFixed(1)} minutes',
          style: const TextStyle(fontSize: 24),
        ),
        Text(
          change.hours == 0
              ? 'Change from previous day: ${change.minutes.toStringAsFixed(1)} minutes'
              : 'Change from previous day: ${change.hours} hours, ${change.minutes.toStringAsFixed(1)} minutes',
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          'Axial tilt: ${getDeclination(calculationDayOfYear).toStringAsFixed(2)} degrees',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            VerticalBarGraph(value: daylightHours),
            Expanded(child: DaylightCurveGraph(latitude: latitude)),
          ],
        ),
      ],
    );
  }
}
