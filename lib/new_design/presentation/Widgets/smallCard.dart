import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../app/utils/textStyle.dart';

class SmallCard extends StatelessWidget {
  const SmallCard({key, @required this.cardName, @required this.image, @required this.onTap});
  final String cardName;
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        height: 6.h,
        padding: EdgeInsets.only(
          left: 18,
        ),
        child: Row(
          children: [
            CircleAvatar(
                radius: (3.h),
                backgroundColor: Colors.white,
                child: Container(
                  height: 3.5.h,
                  child: Image.asset(
                    image,
                    //fit: BoxFit.fitHeight,
                  ),
                )),
            SizedBox(
              width: 6.w,
            ),
            Text(
              cardName,
              style: AppTextStyles.designation,
            )
          ],
        ),
      ),
    );
  }
}
