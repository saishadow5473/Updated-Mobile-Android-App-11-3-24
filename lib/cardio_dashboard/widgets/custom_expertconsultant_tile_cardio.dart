import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// ignore: must_be_immutable
class CustomExpertConsultant extends StatelessWidget {
  CustomExpertConsultant({Key key, this.contentText, this.imagePath, this.onTap}) : super(key: key);
  VoidCallback onTap;
  String contentText, imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(9.sp, 10.sp, 9.sp, 10.sp),
      width: 42.w,
      padding: EdgeInsets.only(bottom: 10.sp),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(offset: const Offset(1, 1), color: Colors.grey.shade400, blurRadius: 15),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.sp),
            width: 42.w,
            height: 15.h,
            child: Image.asset(imagePath),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              contentText,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.lightBlue.shade400, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 38.w,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.sp),
                    )),
                onPressed: onTap,
                child: Text(
                  "Book your Spot",
                  style: TextStyle(color: Colors.grey.shade200, fontWeight: FontWeight.bold),
                )),
          )
        ],
      ),
    );
  }
}
