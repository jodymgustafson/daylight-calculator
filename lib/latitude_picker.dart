import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

typedef CurrentLatitudeLoader = Future<double> Function();

class LatitudePicker extends StatefulWidget {
  const LatitudePicker({
    super.key,
    this.onChanged,
    this.currentLatitudeLoader = _loadCurrentLatitude,
  });

  final ValueChanged<double?>? onChanged;
  final CurrentLatitudeLoader currentLatitudeLoader;

  @override
  State<LatitudePicker> createState() => _LatitudePickerState();
}

class _LatitudePickerState extends State<LatitudePicker> {
  final _controller = TextEditingController(text: '0.0');
  bool _isLoading = true;
  bool _hasEdited = false;
  String? _locationMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadLatitude();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadLatitude({bool overwriteUserInput = false}) async {
    setState(() {
      _isLoading = true;
      _locationMessage = null;
    });

    try {
      final latitude = await widget.currentLatitudeLoader();
      if (!latitude.isFinite || latitude < -90 || latitude > 90) {
        throw const _LocationLookupException(
          'The location service returned an invalid latitude.',
        );
      }

      if (!mounted) return;
      final shouldUpdateInput = !_hasEdited || overwriteUserInput;
      setState(() {
        if (shouldUpdateInput) {
          _controller.text = latitude.toStringAsFixed(6);
        }
        _isLoading = false;
      });
      if (shouldUpdateInput) widget.onChanged?.call(latitude);
    } on _LocationLookupException catch (error) {
      _showLocationError(error.message);
    } on TimeoutException {
      _showLocationError(
        'Could not determine your location. Enter your latitude manually.',
      );
    } on PermissionDeniedException {
      _showLocationError(
        'Location permission was denied. Enter your latitude manually or '
        'enable location access.',
      );
    } on LocationServiceDisabledException {
      _showLocationError(
        'Location services are turned off. Enter your latitude manually or '
        'turn them on.',
      );
    } on UnsupportedError {
      _showLocationError(
        'Current location is unavailable on this device. Enter your latitude '
        'manually.',
      );
    }
  }

  void _showLocationError(String message) {
    if (!mounted) return;
    setState(() {
      _locationMessage = message;
      _isLoading = false;
    });
  }

  String? _validateLatitude(String? value) {
    final latitude = double.tryParse(value?.trim() ?? '');
    if (latitude == null || !latitude.isFinite) {
      return 'Enter a valid latitude.';
    }
    if (latitude < -90 || latitude > 90) {
      return 'Latitude must be between -90 and 90.';
    }
    return null;
  }

  void _onInputChanged(String value) {
    _hasEdited = true;
    final latitude = double.tryParse(value.trim());
    widget.onChanged?.call(
      latitude != null && latitude.isFinite && latitude >= -90 && latitude <= 90
          ? latitude
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'Enter latitude from -90 to 90',
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validateLatitude,
                onChanged: _onInputChanged,
              ),
            ),
            const SizedBox(width: 8),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Finding location...'),
                  ],
                ),
              )
            else
              TextButton.icon(
                onPressed: () => _loadLatitude(overwriteUserInput: true),
                icon: const Icon(Icons.my_location),
                label: const Text('Current location'),
              ),
          ],
        ),
        if (_locationMessage != null)
          Text(
            _locationMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}

Future<double> _loadCurrentLatitude() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const _LocationLookupException(
      'Location services are turned off. Enter your latitude manually or '
      'turn them on.',
    );
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw const PermissionDeniedException('Location permission was denied.');
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.low,
      timeLimit: Duration(seconds: 15),
    ),
  );
  return position.latitude;
}

class _LocationLookupException implements Exception {
  const _LocationLookupException(this.message);

  final String message;
}
