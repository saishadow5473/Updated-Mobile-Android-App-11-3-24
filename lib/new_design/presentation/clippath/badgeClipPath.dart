import 'dart:math';

import 'package:flutter/material.dart';

class BadgeDecoration extends Decoration {
  final Color badgeColor;
  final double badgeSize;
  final TextSpan textSpan;
  final double radius;

  const BadgeDecoration(
      {@required this.badgeColor,
      @required this.badgeSize,
      @required this.textSpan,
      @required this.radius});

  @override
  BoxPainter createBoxPainter([onChanged]) =>
      _BadgePainter(badgeColor, badgeSize, textSpan, radius);
}

class _BadgePainter extends BoxPainter {
  static const double BASELINE_SHIFT = 1;
  static double CORNER_RADIUS = 0;
  final Color badgeColor;
  final double badgeSize;
  final TextSpan textSpan;
  final double radius;

  _BadgePainter(this.badgeColor, this.badgeSize, this.textSpan, this.radius);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    CORNER_RADIUS = radius;
    canvas.save();
    canvas.translate(offset.dx + configuration.size.width - badgeSize, offset.dy);
    canvas.drawPath(buildBadgePath(), getBadgePaint());
    // draw text
    final hyp = sqrt(badgeSize * badgeSize + badgeSize * badgeSize);
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    textPainter.layout(minWidth: hyp, maxWidth: hyp);
    final halfHeight = textPainter.size.height / 2;
    final v = sqrt(halfHeight * halfHeight + halfHeight * halfHeight) + BASELINE_SHIFT;
    canvas.translate(v, -v);
    canvas.rotate(0.785398); // 45 degrees
    textPainter.paint(canvas, Offset(0, 2));
    canvas.restore();
  }

  Paint getBadgePaint() => Paint()
    ..isAntiAlias = true
    ..color = badgeColor;

  Path buildBadgePath() => Path.combine(
      PathOperation.difference,
      Path()
        ..addRRect(RRect.fromLTRBAndCorners(0, 0, badgeSize, badgeSize,
            topRight: Radius.circular(CORNER_RADIUS))),
      Path()
        ..lineTo(0, badgeSize)
        ..lineTo(badgeSize, badgeSize)
        ..close());
}
