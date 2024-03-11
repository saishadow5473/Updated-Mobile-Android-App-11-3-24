import 'package:flutter/material.dart';

class SubscriptionClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // path_2823
    double path_2823_xs = size.width / 146.73;
    double path_2823_ys = size.height / 31.53;

    final Path path_2823 = Path()
      ..moveTo(0 * path_2823_xs, 0 * path_2823_ys)
      ..lineTo(146.73 * path_2823_xs, 0 * path_2823_ys)
      ..lineTo(136.38 * path_2823_xs, 15.8 * path_2823_ys)
      ..lineTo(146.73 * path_2823_xs, 31.53 * path_2823_ys)
      ..lineTo(0 * path_2823_xs, 31.53 * path_2823_ys)
      ..lineTo(0 * path_2823_xs, 0 * path_2823_ys)
      ..close();
    return path_2823;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
