import 'package:flutter/material.dart';

/// Background Painter 🎨 takes primary color(background) and secondary color (circle)
class BackgroundPainter extends CustomPainter {
  Color primary;
  Color secondary;
  BackgroundPainter({this.primary, this.secondary});
  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint();
    primaryPaint.style = PaintingStyle.fill;
    primaryPaint.color = primary;
    canvas.drawCircle(
        Offset(size.width / 2, -3 * size.width / 10), size.width, primaryPaint);

    primaryPaint.color = secondary;
    canvas.drawCircle(Offset(size.width * 4 / 5, size.width / 20),
        size.width / 4, primaryPaint);
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BackgroundPainter oldDelegate) => false;
}


class CustomBackgroundPainter extends CustomPainter {
  Color primary;
  Color secondary;
  CustomBackgroundPainter({this.primary, this.secondary});
  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint();
    primaryPaint.style = PaintingStyle.fill;
    primaryPaint.color = primary;
    canvas.drawCircle(
        Offset(size.width / 2, -3 * size.width / 10), size.width, primaryPaint);

    primaryPaint.color = secondary;
    canvas.drawCircle(Offset(size.width * 4.2 / 5, size.width*0.5 / 20),
        size.width / 4, primaryPaint);
  }

  @override
  bool shouldRepaint(CustomBackgroundPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(CustomBackgroundPainter oldDelegate) => false;
}
