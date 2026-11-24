import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylight_calc/day_of_year_picker.dart';
import 'package:daylight_calc/daylight_utils.dart';
import 'package:daylight_calc/latitude_picker.dart';
import 'package:daylight_calc/main.dart';

void main() {
  testWidgets('defaults to today and maps slider dates to month and day', (
    WidgetTester tester,
  ) async {
    final today = DateTime.now();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DayOfYearPicker())),
    );

    final dayField = tester.widget<TextFormField>(
      find.byKey(const Key('day-of-year-day')),
    );
    expect(dayField.controller!.text, today.day.toString());
    expect(
      tester.widget<Slider>(find.byKey(const Key('day-of-year-slider'))).value,
      today.difference(DateTime(today.year, 1, 1)).inDays + 1,
    );
    expect(
      tester.widget<Slider>(find.byKey(const Key('day-of-year-slider'))).min,
      1,
    );

    tester
        .widget<Slider>(find.byKey(const Key('day-of-year-slider')))
        .onChanged!(365);
    await tester.pump();

    final lastDay = DateTime(today.year, 1, 1).add(const Duration(days: 364));
    expect(
      tester
          .widget<DropdownButtonFormField<int>>(
            find.byType(DropdownButtonFormField<int>),
          )
          .initialValue,
      lastDay.month,
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('day-of-year-day')))
          .controller!
          .text,
      lastDay.day.toString(),
    );
  });

  testWidgets('month and day changes update the day-of-year slider', (
    WidgetTester tester,
  ) async {
    final year = DateTime.now().year;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DayOfYearPicker())),
    );

    tester
        .widget<DropdownButtonFormField<int>>(
          find.byType(DropdownButtonFormField<int>),
        )
        .onChanged!(1);
    await tester.pump();
    await tester.enterText(find.byKey(const Key('day-of-year-day')), '31');
    await tester.pump();
    expect(
      tester.widget<Slider>(find.byKey(const Key('day-of-year-slider'))).value,
      31,
    );

    tester
        .widget<DropdownButtonFormField<int>>(
          find.byType(DropdownButtonFormField<int>),
        )
        .onChanged!(2);
    await tester.pump();
    final day = DateTime(year, 3, 0).day;
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('day-of-year-day')))
          .controller!
          .text,
      day.toString(),
    );
    expect(
      tester.widget<Slider>(find.byKey(const Key('day-of-year-slider'))).value,
      DateTime(year, 2, day).difference(DateTime(year, 1, 1)).inDays + 1,
    );
  });

  testWidgets('Today button resets the date and slider', (
    WidgetTester tester,
  ) async {
    final changedDayOfYears = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DayOfYearPicker(onChanged: changedDayOfYears.add)),
      ),
    );

    tester
        .widget<Slider>(find.byKey(const Key('day-of-year-slider')))
        .onChanged!(1);
    await tester.pump();
    await tester.tap(find.text('Today'));
    await tester.pump();

    final today = DateTime.now();
    expect(
      tester
          .widget<DropdownButtonFormField<int>>(
            find.byType(DropdownButtonFormField<int>),
          )
          .initialValue,
      today.month,
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('day-of-year-day')))
          .controller!
          .text,
      today.day.toString(),
    );
    expect(
      tester.widget<Slider>(find.byKey(const Key('day-of-year-slider'))).value,
      today.difference(DateTime(today.year, 1, 1)).inDays + 1,
    );
    expect(
      changedDayOfYears.last,
      today.difference(DateTime(today.year, 1, 1)).inDays + 1,
    );
  });

  testWidgets('updates daylight hours when latitude and day change', (
    WidgetTester tester,
  ) async {
    final today = DateTime.now();
    final todayDayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    await tester.pumpWidget(
      MaterialApp(
        home: DaylightCalculatorPage(currentLatitudeLoader: () async => 0.0),
      ),
    );
    await tester.pumpAndSettle();

    final initialDaylight = toHoursAndMinutes(
      getDaylightHours(0, todayDayOfYear),
    );
    expect(
      find.text(
        'Daylight: ${initialDaylight.hours} hours, '
        '${initialDaylight.minutes.toStringAsFixed(1)} minutes',
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).first, '35');
    await tester.pump();
    tester
        .widget<Slider>(find.byKey(const Key('day-of-year-slider')))
        .onChanged!(100);
    await tester.pump();

    final updatedDaylight = toHoursAndMinutes(getDaylightHours(35, 99));
    expect(
      find.text(
        'Daylight: ${updatedDaylight.hours} hours, '
        '${updatedDaylight.minutes.toStringAsFixed(1)} minutes',
      ),
      findsOneWidget,
    );
  });

  testWidgets('loads the current latitude as the input default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LatitudePicker(currentLatitudeLoader: () async => 37.7749),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final latitudeField = tester.widget<TextFormField>(
      find.byType(TextFormField),
    );
    expect(latitudeField.controller!.text, '37.774900');
  });

  testWidgets('accepts latitude bounds and rejects values outside them', (
    WidgetTester tester,
  ) async {
    final changedLatitudes = <double?>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LatitudePicker(
            currentLatitudeLoader: () async => 0,
            onChanged: changedLatitudes.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '-90');
    await tester.pump();
    expect(find.text('Latitude must be between -90 and 90.'), findsNothing);
    expect(changedLatitudes.last, -90);

    await tester.enterText(find.byType(TextFormField), '90');
    await tester.pump();
    expect(find.text('Latitude must be between -90 and 90.'), findsNothing);
    expect(changedLatitudes.last, 90);

    await tester.enterText(find.byType(TextFormField), '90.01');
    await tester.pump();
    expect(find.text('Latitude must be between -90 and 90.'), findsOneWidget);
    expect(changedLatitudes.last, isNull);
  });
}
