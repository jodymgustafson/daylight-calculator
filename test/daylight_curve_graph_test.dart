import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylight_calc/daylight_curve_graph.dart';

void main() {
  testWidgets('renders the daylight curve on the requested graph size', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DaylightCurveGraph(latitude: 45))),
    );

    final graph = tester.widget<CustomPaint>(
      find.byKey(const Key('daylight-curve-graph')),
    );
    expect(graph.size, const Size(400, 260));
    expect(graph.painter, isNotNull);
    expect(
      find.bySemanticsLabel(
        'Daylight hours by day of year, from 0 to 24 hours over 365 days',
      ),
      findsOneWidget,
    );
  });
}
