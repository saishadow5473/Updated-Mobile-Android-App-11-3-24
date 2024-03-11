import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class HealthTipShimmer extends StatelessWidget {
  const HealthTipShimmer({
    key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        direction: ShimmerDirection.ltr,
        period: Duration(seconds: 2),
        baseColor: Color.fromARGB(255, 240, 240, 240),
        highlightColor: Colors.grey.withOpacity(0.2),
        child: Container(
            height: 30.h,
            width: 44.w,
            padding: EdgeInsets.only(left: 8, right: 8, top: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Text('Hello')));
  }
}
