import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:sizer/sizer.dart';

class TitleView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;
  final Function onTap;
  final Color color;
  const TitleView({Key key, this.titleTxt = "", this.subTxt = "", this.onTap, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                titleTxt,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                  letterSpacing: 0.2,
                  color: AppColors.textitemTitleColor,
                ),
              ),
            ),
            InkWell(
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              onTap: onTap ?? () {},
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: <Widget>[
                    Text(
                      subTxt,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        letterSpacing: 0.5,
                        color: color ?? AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 38,
                      width: 26,
                      child: Icon(
                        Icons.arrow_forward,
                        color: FitnessAppTheme.darkText,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HomeTitleView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;
  final Function onTap;
  final Color color;
  const HomeTitleView({Key key, this.titleTxt = "", this.subTxt = "", this.onTap, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                titleTxt,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -1,
                  // color: AppColors.textitemTitleColor,
                  // color: Color.fromRGBO(166, 167, 187, 1),
                  color: Color.fromRGBO(
                    132,
                    132,
                    160,
                    1,
                  ),
                ),
              ),
            ),
            InkWell(
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              onTap: onTap ?? () {},
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: <Widget>[
                    Text(
                      subTxt,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          // letterSpacing: 1,
                          // color: color ?? AppColors.primaryColor,
                          color: Color.fromRGBO(77, 122, 209, 1)),
                    ),
                    // SizedBox(
                    //   height: 38,
                    //   width: 26,
                    //   child: Icon(
                    //     Icons.arrow_forward,
                    //     color: FitnessAppTheme.darkText,
                    //     size: 18,
                    //   ),
                    // ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FoodTitleView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;
  final Function onTap;
  const FoodTitleView({Key key, this.titleTxt = "", this.subTxt = "", this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                titleTxt,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  letterSpacing: 0.2,
                  color: AppColors.textitemTitleColor,
                ),
              ),
            ),
            InkWell(
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              onTap: onTap ?? () {},
              child: Padding(
                padding: EdgeInsets.only(left: 8.sp),
                child: Row(
                  children: <Widget>[
                    Text(
                      subTxt,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.normal,
                        fontSize: 14.sp,
                        letterSpacing: 0.5,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
