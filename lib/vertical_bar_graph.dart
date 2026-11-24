import 'package:flutter/material.dart';

class VerticalBarGraph extends StatelessWidget {
  const VerticalBarGraph({
    super.key,
    required this.value,
    this.maxValue = 24,
    this.width = 50,
    this.height = 260,
  }) : assert(maxValue > 0),
       assert(height > 0),
       assert(width > 0);

  final double value;
  final double maxValue;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final boundedValue = value.clamp(0.0, maxValue).toDouble();
    final barHeight = (height * boundedValue / maxValue).clamp(24.0, height);

    return ColoredBox(
      color: Colors.black,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: width,
                height: barHeight,
                child: ColoredBox(
                  color: Colors.yellow,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 0,
              right: 0,
              child: Text(
                (maxValue - value).toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.yellow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
