import 'package:flutter/material.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';

import 'package:sizer/sizer.dart';

class TitleAvatar extends StatelessWidget {
  final String image;
  const TitleAvatar({Key key, @required this.image}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
        color: AppColors.plainColor,
        elevation: 5.0,
        shape: BoxShape.circle,
        child: CircleAvatar(
            radius: (2.5.h),
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(1.5.w),
              child: Container(
                height: 3.5.h,
                child: Image.asset(
                  image,
                  //fit: BoxFit.fitHeight,
                ),
              ),
            )));
  }
}
