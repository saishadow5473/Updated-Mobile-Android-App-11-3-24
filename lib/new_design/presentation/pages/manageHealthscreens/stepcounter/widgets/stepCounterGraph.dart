import 'package:flutter/material.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../clippath/customGraph.dart';

class CustomGraphSingle extends StatelessWidget {
  CustomGraphSingle(
      {Key key,
      @required this.xAxisFields,
      @required this.barColor,
      @required this.yAxixFields,
      this.multiColorbars})
      : super(key: key);
  List<Map> xAxisFields;
  Color barColor;
  List<Color> multiColorbars;
  List<int> yAxixFields;

  @override
  Widget build(BuildContext context) {
    double graphHeight = 15.5.h;
    yAxixFields.sort();
    xAxisFields.length == 13 ? xAxisFields.removeAt(0) : null;
    double heightOnePersentage = graphHeight / 100;
    List<double> persentages = [];
    for (var e in xAxisFields) {
      double currentValuePercentage = ((e["value"] / yAxixFields.last) * 100);
      currentValuePercentage = double.parse(currentValuePercentage.toStringAsFixed(0));
      persentages.add(double.parse((currentValuePercentage * heightOnePersentage).toString()));
    }
    return Stack(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: [
        SizedBox(
          height: 13.5.h,
          width: 90.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...yAxixFields.reversed.map((e) {
                if (yAxixFields.indexWhere((element) => element == e).toInt() == 1) {
                  return rows(rowName: e.toString(), dottedLine: true);
                }
                return rows(rowName: e.toString());
              }).toList(),
            ],
          ),
        ),
        Positioned(
          bottom: 0.h,
          right: 10.w,
          child: Stack(
            children: [
              Container(
                height: 15.5.h,
                width: 60.w,
                child: Column(
                  children: [
                    Container(
                      height: 15.5.h,
                      width: 80.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: xAxisFields.map((e) {
                          double currentValuePercentage = ((e["value"] / yAxixFields.last) * 100);
                          currentValuePercentage =
                              double.parse(currentValuePercentage.toStringAsFixed(0));
                          return SizedBox(
                            width: 3.5.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedContainer(
                                  curve: Curves.linear,
                                  duration: Duration(seconds: 1),
                                  height: double.parse(
                                      (currentValuePercentage * heightOnePersentage).toString()),
                                  width: 3.w,
                                  color: barColor,
                                ),
                                Text(
                                  e["day"].toString(),
                                  style: TextStyle(fontSize: 13.sp),
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
      ],
    );
  }

  Widget rows({String rowName, bool dottedLine}) {
    // if (dottedLine ?? false)
    // return Row(
    //   children: [
    //     SizedBox(
    //         width: 10.w,
    //         child: Text(
    //           rowName,
    //           style: TextStyle(color: Colors.transparent),
    //         )),
    //     Expanded(
    //         child: CustomPaint(
    //       painter: DottedLinePainter(),
    //     ))
    //   ],
    // );
    return Row(
      children: [
        Text(
          rowName,
          style: TextStyle(fontSize: 12.sp),
        ),
      ],
    );
  }
}
