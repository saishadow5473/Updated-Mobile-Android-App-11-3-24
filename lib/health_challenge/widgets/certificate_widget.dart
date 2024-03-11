import 'dart:math';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../new_design/data/functions/healthChallengeFunctions.dart';

Widget certificateBadgeWidget(String badgeImage) {
  print(badgeImage);
  if (badgeImage == null) {
    int randomIndex = Random().nextInt(HealthChallengeFunctions().challengeBadges.length);
    badgeImage = HealthChallengeFunctions().challengeBadges[randomIndex];
    return ClipOval(
      child: Image.asset(
        badgeImage,
        width: 50.sp,
        height: 50.sp,
        fit: BoxFit.cover,
      ),
    );
  } else {
    return ClipOval(
      child: Image.network(
        badgeImage,
        width: 50.sp,
        height: 50.sp,
        fit: BoxFit.cover,
      ),
    );
  }
}
