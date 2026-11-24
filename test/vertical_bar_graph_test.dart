import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daylight_calc/vertical_bar_graph.dart';

void main() {
  testWidgets('renders a yellow bar over a black background with its value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: VerticalBarGraph(value: 12.5))),
    );

    final colors = tester
        .widgetList<ColoredBox>(find.byType(ColoredBox))
        .map((box) => box.color)
        .toList();
    expect(colors, contains(Colors.black));
    expect(colors, contains(Colors.yellow));
    expect(find.text('12.5'), findsOneWidget);
    expect(tester.widget<Text>(find.text('12.5')).style!.color, Colors.black);
    expect(find.text('11.5'), findsOneWidget);
    expect(tester.widget<Text>(find.text('11.5')).style!.color, Colors.yellow);
  });
}
