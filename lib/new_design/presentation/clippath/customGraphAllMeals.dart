import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../utils/app_colors.dart';
import '../../../views/dietJournal/calorieGraph/monthly_calorie_tab.dart';
import 'customGraph.dart';

class CustomGraphAllMeals extends StatelessWidget {
  CustomGraphAllMeals(
      {Key key,
      @required this.xAxisFields,
      @required this.yAxixFields,
      this.category,
      this.multiColorbars})
      : super(key: key);
  List<Map> xAxisFields;
  List<Color> multiColorbars;
  List<int> yAxixFields;
  String category;

  @override
  Widget build(BuildContext context) {
    yAxixFields.sort();
    double heightOnePersentage = 24.8.h / 100;
    List<double> persentages = [];
    if (category != "Weekly")
      for (var e in xAxisFields) {
        double currentValuePercentage = ((e["value"] / yAxixFields.last) * 100);
        currentValuePercentage = double.parse(currentValuePercentage.toStringAsFixed(0));
        persentages.add(double.parse((currentValuePercentage * heightOnePersentage).toString()));
      }
    return Container(
      width: 100.w,
      child: Stack(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          Container(
            height: 26.h,
            width: 100.w,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...yAxixFields.reversed.map((e) {
                      if (yAxixFields.indexWhere((element) => element == e).toInt() == 1) {
                        return rows(rowName: e.toString(), dottedLine: true);
                      }
                      return rows(rowName: e.toString());
                    }).toList(),
                    Row(
                      children: [
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -0.h,
            right: 0,
            child: Stack(
              children: [
                Container(
                  height: 25.h,
                  width: 80.w,
                  child: Column(
                    children: [
                      Container(
                        height: 25.h,
                        width: 79.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: xAxisFields.map((e) {
                            double currentValuePercentage = ((e["value"] / yAxixFields.last) * 100);
                            currentValuePercentage =
                                double.parse(currentValuePercentage.toStringAsFixed(0));
                            return SizedBox(
                              // width: 6.5.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (category == "Weekly")
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedContainer(
                                          curve: Curves.linear,
                                          duration: Duration(seconds: 1),
                                          height: double.parse(
                                              (currentValuePercentage * heightOnePersentage)
                                                  .toString()),
                                          width: 1.w,
                                          decoration: boxDecoration(multiColorbars[
                                              xAxisFields.indexWhere(
                                                  (element) => element["xValue"] == e["xValue"])]),
                                        ),
                                        SizedBox(width: 0.2.h),
                                        AnimatedContainer(
                                          curve: Curves.linear,
                                          decoration: boxDecoration(multiColorbars[
                                              xAxisFields.indexWhere(
                                                  (element) => element["xValue"] == e["xValue"])]),
                                          duration: Duration(seconds: 1),
                                          height: double.parse(
                                              (currentValuePercentage * heightOnePersentage)
                                                  .toString()),
                                          width: 1.w,
                                        ),
                                        SizedBox(width: 0.2.h),
                                        AnimatedContainer(
                                          curve: Curves.linear,
                                          duration: Duration(seconds: 1),
                                          height: double.parse(
                                              (currentValuePercentage * heightOnePersentage)
                                                  .toString()),
                                          width: 1.w,
                                          decoration: boxDecoration(multiColorbars[
                                              xAxisFields.indexWhere(
                                                  (element) => element["xValue"] == e["xValue"])]),
                                        ),
                                        SizedBox(width: 0.2.h),
                                        AnimatedContainer(
                                          curve: Curves.linear,
                                          duration: Duration(seconds: 1),
                                          height: double.parse(
                                              (currentValuePercentage * heightOnePersentage)
                                                  .toString()),
                                          width: 1.w,
                                          decoration: boxDecoration(multiColorbars[
                                              xAxisFields.indexWhere(
                                                  (element) => element["xValue"] == e["xValue"])]),
                                        ),
                                      ],
                                    ),
                                  if (category == "Day")
                                    AnimatedContainer(
                                      curve: Curves.linear,
                                      duration: Duration(seconds: 1),
                                      height: double.parse(
                                          (currentValuePercentage * heightOnePersentage)
                                              .toString()),
                                      width: 10.w,
                                      color: multiColorbars[xAxisFields.indexWhere(
                                          (element) => element["xValue"] == e["xValue"])],
                                    ),
                                  Text(
                                    e["xValue"].toString(),
                                    style: TextStyle(fontSize: 100.h < 750 ? 8.px : 11.px),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 100.h < 700 ? 28.2.h : 27.8.h,
          )
        ],
      ),
    );
  }

  BoxDecoration boxDecoration(Color color) {
    return BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)));
  }

  Widget rows({String rowName, bool dottedLine}) {
    if (dottedLine ?? false)
      return Row(
        children: [
          SizedBox(
              width: 12.w,
              child: Text(
                rowName,
                style: TextStyle(color: AppColors.primaryColor, fontSize: 9.px),
              )),
          Expanded(
              child: CustomPaint(
            painter: DottedLinePainter(),
          ))
        ],
      );
    return Row(
      children: [
        SizedBox(
            width: 12.w,
            child: Text(
              rowName,
              style: TextStyle(fontSize: 9.px,),
            )),
        Expanded(
          child: Container(
            height: 1,
            color: Color(0XFFB6B6B6),
          ),
        ),
      ],
    );
  }
}

class CustomGraphAllMealsWeek extends StatelessWidget {
  CustomGraphAllMealsWeek(
      {Key key,
      @required this.xAxisFields,
      @required this.yAxixFields,
      this.category,
      this.multiColorbars})
      : super(key: key);
  List<Map> xAxisFields;
  List<Color> multiColorbars;
  List<int> yAxixFields;
  String category;

  @override
  Widget build(BuildContext context) {
    yAxixFields.sort();
    double heightOnePersentage = 24.8.h / 100;
    List<double> persentages = [];
    if (category != "Weekly")
      for (var e in xAxisFields) {
        double currentValuePercentage = ((e["value"] / yAxixFields.last) * 100);
        currentValuePercentage = double.parse(currentValuePercentage.toStringAsFixed(0));
        persentages.add(double.parse((currentValuePercentage * heightOnePersentage).toString()));
      }
    return Container(
      width: 100.w,
      child: Stack(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          Container(
            height: 26.h,
            width: 100.w,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...yAxixFields.reversed.map((e) {
                      if (yAxixFields.indexWhere((element) => element == e).toInt() == 1) {
                        return rows(rowName: e.toString(), dottedLine: true);
                      }
                      return rows(rowName: e.toString());
                    }).toList(),
                    Row(
                      children: [
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -0.h,
            right: 0,
            child: Stack(
              children: [
                Container(
                  height: 25.h,
                  width: 80.w,
                  child: Column(
                    children: [
                      Container(
                        height: 25.h,
                        width: 79.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: xAxisFields.map((e) {
                            double currentValuePercentage = ((e["value"] / yAxixFields.last) * 100);
                            currentValuePercentage =
                                double.parse(currentValuePercentage.toStringAsFixed(0));
                            return SizedBox(
                              // width: 6.5.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedContainer(
                                        curve: Curves.linear,
                                        duration: Duration(seconds: 1),
                                        height: double.parse(
                                            ((e["categData"]["Breakfast"] / yAxixFields.last) *
                                                    100 *
                                                    heightOnePersentage)
                                                .toString()),
                                        width: 1.w,
                                        decoration: boxDecoration(categoryColor[0]),
                                      ),
                                      SizedBox(width: 0.2.h),
                                      AnimatedContainer(
                                        curve: Curves.linear,
                                        decoration: boxDecoration(categoryColor[1]),
                                        duration: Duration(seconds: 1),
                                        height: double.parse(
                                            ((e["categData"]["Lunch"] / yAxixFields.last) *
                                                    100 *
                                                    heightOnePersentage)
                                                .toString()),
                                        width: 1.w,
                                      ),
                                      SizedBox(width: 0.2.h),
                                      AnimatedContainer(
                                        curve: Curves.linear,
                                        duration: Duration(seconds: 1),
                                        height: double.parse(
                                            ((e["categData"]["Snacks"] / yAxixFields.last) *
                                                    100 *
                                                    heightOnePersentage)
                                                .toString()),
                                        width: 1.w,
                                        decoration: boxDecoration(categoryColor[2]),
                                      ),
                                      SizedBox(width: 0.2.h),
                                      AnimatedContainer(
                                        curve: Curves.linear,
                                        duration: Duration(seconds: 1),
                                        height: double.parse(
                                            ((e["categData"]["Dinner"] / yAxixFields.last) *
                                                    100 *
                                                    heightOnePersentage)
                                                .toString()),
                                        width: 1.w,
                                        decoration: boxDecoration(categoryColor[3]),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    e["xValue"].toString().substring(0, 3),
                                    style: TextStyle(fontSize: 100.h < 750 ? 8.px : 11.px),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 100.h < 700 ? 28.2.h : 27.8.h,
          )
        ],
      ),
    );
  }

  List<Color> categoryColor = [
    Color(0XFFF15B3A),
    Color(0XFF2EC6DE),
    Color(0XFFFE6292),
    Color(0XFF383387)
  ];
  BoxDecoration boxDecoration(Color color) {
    return BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)));
  }

  Widget rows({String rowName, bool dottedLine}) {
    if (dottedLine ?? false)
      return Row(
        children: [
          SizedBox(
              width: 10.w,
              child: Text(
                rowName,
                style: TextStyle(color: AppColors.primaryColor, fontSize: 15.sp),
              )),
          Expanded(
              child: CustomPaint(
            painter: DottedLinePainter(),
          ))
        ],
      );
    return Row(
      children: [
        SizedBox(width: 12.w, child: Text(rowName, style: TextStyle(fontSize: 15.sp))),
        Expanded(
          child: Container(
            height: 1,
            color: Color(0XFFB6B6B6),
          ),
        ),
      ],
    );
  }
}
