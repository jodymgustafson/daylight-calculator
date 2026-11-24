import 'package:flutter_test/flutter_test.dart';

import 'package:daylight_calc/daylight_utils.dart';

void main() {
  test('uses the sunrise/sunset zenith angle by default', () {
    expect(getDaylightHours(35, 100), getDaylightHours(35, 100, true));
    expect(getDaylightHours(35, 100), isNot(getDaylightHours(35, 100, false)));
  });

  test('returns daylight hours within the supported range', () {
    for (final dayOfYear in [0, 80, 186, 365]) {
      final daylightHours = getDaylightHours(35, dayOfYear);
      expect(daylightHours, inInclusiveRange(0, 24));
    }
  });

  test('clips polar daylight hours to zero and twenty-four', () {
    expect(getDaylightHours(90, 10), 0);
    expect(getDaylightHours(90, 186), 24);
    expect(getDaylightHours(-90, 10), 24);
    expect(getDaylightHours(-90, 186), 0);
  });

  test('converts decimal hours to hours and fractional minutes', () {
    expect(toHoursAndMinutes(5.5), (hours: 5, minutes: 30.0));
    final result = toHoursAndMinutes(2.999);
    expect(result.hours, 2);
    expect(result.minutes, closeTo(59.94, 1e-10));
  });
}
