import 'package:flutter/material.dart';
import 'dart:math';

class AnalogClock extends StatelessWidget {
  final dynamic model;

  AnalogClock(this.model);

  @override
  Widget build(BuildContext context) {
    final time = model.is24HourFormat ? DateTime.now() : model.alternativeTime;
    final hour = time.hour % 12;

    // Calculate the angle for the hour hand.
    final hourAngle = (360 / 12) * (hour + time.minute / 60.0);

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CustomPaint(
          painter: ClockPainter(hourAngle),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final double hourAngle;

  ClockPainter(this.hourAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Draw clock circle
    canvas.drawCircle(center, radius, paint);

    // Draw hour hand
    final hourHandLength = radius * 0.6;
    final hourHandX = center.dx + hourHandLength * sin(-hourAngle * pi / 180);
    final hourHandY = center.dy + hourHandLength * cos(-hourAngle * pi / 180);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), paint);

    // Draw hour numbers
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = (-i * 30) * pi / 180;
      final textX = center.dx + (radius - 30) * sin(angle);
      final textY = center.dy + (radius - 30) * cos(angle);
      textPainter.text = TextSpan(
        text: '$i',
        style: TextStyle(fontSize: 20, color: Colors.black),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
