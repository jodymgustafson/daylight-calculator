import 'dart:math' as math;

final _piOver180 = math.pi / 180;

double _degToRad(double degrees) => degrees * _piOver180;
double _radToDeg(double radians) => radians / _piOver180;

final _radPerDay = _degToRad(360 / 365);
final _equinoxOffset = 81; // March 21st is the 81st day of the year
final _zenithAngle = _degToRad(90.833); // Sun's zenith angle for sunrise/sunset

/// Calculates the number of daylight hours for a given latitude and day of the year.
/// latitude: The latitude in degrees (-90 to 90).
/// dayOfYear: The day of the year (0 to 364).
/// useZenithAngle: Whether to use the zenith angle for sunrise/sunset calculations.
/// returns: The number of daylight hours (0 to 24).
double getDaylightHours(
  num latitude,
  num dayOfYear, [
  bool useZenithAngle = true,
]) {
  // Calculate the declination of the sun in degrees
  final declDegrees = getDeclination(dayOfYear);

  // Convert latitude and declination to radians
  final latRad = _degToRad(latitude.toDouble());
  final declRad = _degToRad(declDegrees);

  // Calculate the hour angle (omega) in radians taking into account
  // the zenith angle for sunrise/sunset
  final cosOmega = useZenithAngle
      ? (math.cos(_zenithAngle) - math.sin(latRad) * math.sin(declRad)) /
            (math.cos(latRad) * math.cos(declRad))
      : -math.tan(latRad) * math.tan(declRad);

  // Handle polar day and polar night cases
  if (cosOmega < -1) {
    return 24.0; // Polar day
  } else if (cosOmega > 1) {
    return 0.0; // Polar night
  }

  // Convert degrees to hours
  final omegaDeg = _radToDeg(math.acos(cosOmega));
  final daylight = (2 * omegaDeg) / 15;

  return daylight.clamp(0.0, 24.0).toDouble();
}

/// Calculates the change in daylight hours from the previous day for a
/// given latitude and day of the year.
/// latitude: The latitude in degrees (-90 to 90).
/// dayOfYear: The day of the year (0 to 364).
/// returns: The change in daylight hours in minutes.
double getDaylightChange(num latitude, num dayOfYear) {
  final todayDaylight = getDaylightHours(latitude, dayOfYear);
  final yesterdayDaylight = getDaylightHours(latitude, dayOfYear - 1);
  return 60 * (todayDaylight - yesterdayDaylight);
}

/// Converts a decimal number of hours into a tuple of whole hours and minutes.
/// hours: The decimal number of hours.
/// returns: A tuple containing whole hours and minutes.
({int hours, double minutes}) toHoursAndMinutes(double hours) {
  final wholeHours = hours.truncate();
  final minutes = (hours - wholeHours) * 60;
  return (hours: wholeHours, minutes: minutes);
}

/// Calculates the declination of the sun for a given day of the year (aka axial tilt).
/// dayOfYear: The day of the year (0 to 364).
/// returns: The declination in degrees.
double getDeclination(num dayOfYear) {
  return 23.44 * math.sin(_radPerDay * (dayOfYear - _equinoxOffset));
}
