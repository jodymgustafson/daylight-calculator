import 'package:material_ui/material_ui.dart';

import 'day_of_year_picker.dart';
import 'daylight_results.dart';
import 'latitude_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daylight Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          // surface: const Color.fromARGB(255, 18, 54, 84),
          // primary: Colors.blueGrey,
        ),
      ),
      home: const DaylightCalculatorPage(),
    );
  }
}

class DaylightCalculatorPage extends StatefulWidget {
  const DaylightCalculatorPage({super.key, this.currentLatitudeLoader});

  final CurrentLatitudeLoader? currentLatitudeLoader;

  @override
  State<DaylightCalculatorPage> createState() => _DaylightCalculatorPageState();
}

class _DaylightCalculatorPageState extends State<DaylightCalculatorPage> {
  double? _latitude = 0;
  late int _dayOfYear;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays + 1;
  }

  void _onLatitudeChanged(double? latitude) {
    setState(() {
      _latitude = latitude;
    });
  }

  void _onDayOfYearChanged(int dayOfYear) {
    setState(() {
      _dayOfYear = dayOfYear;
    });
  }

  @override
  Widget build(BuildContext context) {
    final latitudePicker = widget.currentLatitudeLoader == null
        ? LatitudePicker(onChanged: _onLatitudeChanged)
        : LatitudePicker(
            currentLatitudeLoader: widget.currentLatitudeLoader!,
            onChanged: _onLatitudeChanged,
          );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            latitudePicker,
            const SizedBox(height: 8),
            DayOfYearPicker(onChanged: _onDayOfYearChanged),
            const SizedBox(height: 16),
            if (_latitude == null)
              const Text(
                'Enter a latitude to calculate daylight hours.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
            else
              DaylightResults(latitude: _latitude!, dayOfYear: _dayOfYear),
          ],
        ),
      ),
    );
  }
}
