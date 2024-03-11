import 'package:flutter/material.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// ignore: must_be_immutable
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
    yAxixFields.sort();
    xAxisFields.length == 13 ? xAxisFields.removeAt(0) : null;
    double heightOnePersentage = 24.8.h / 100;
    List<double> persentages = [];
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
            height: 25.99.h,
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
                  height: 25.30.h,
                  width: 80.w,
                  child: Column(
                    children: [
                      Container(
                        height: 25.h,
                        width: 79.w,
                        child: Row(
                          mainAxisAlignment: xAxisFields.length < 4
                              ? MainAxisAlignment.spaceEvenly
                              : MainAxisAlignment.spaceBetween,
                          children: xAxisFields.map((e) {
                            double currentValuePercentage = ((e["value"] / yAxixFields.last) * 100);
                            currentValuePercentage =
                                double.parse(currentValuePercentage.toStringAsFixed(0));
                            String subText = (e["day"].toString().contains("pm")) ? "\nPM" : "\nAM";
                            return SizedBox(
                              width: e["day"].toString().contains("AM") ||
                                      e["day"].toString().contains("PM")
                                  ? null
                                  : 6.5.w,
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
                                  e["day"].toString().toLowerCase().contains("am") ||
                                          e["day"].toString().toLowerCase().contains("pm")
                                      ? Text(
                                          e["day"],
                                          style: TextStyle(fontSize: 100.h < 750 ? 8.px : 9.px),
                                        )
                                      : Text(
                                          e["day"].toString().substring(0, 3),
                                          style: TextStyle(fontSize: 100.h < 750 ? 8.px : 9.px),
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

  Widget rows({String rowName, bool dottedLine}) {
    if (dottedLine ?? false)
      return Row(
        children: [
          SizedBox(
              width: 12.w,
              child: Text(
                rowName,
                style: TextStyle(color: AppColors.primaryColor, fontSize: 10.px),
              )),
          Expanded(
              child: CustomPaint(
            painter: DottedLinePainter(),
          ))
        ],
      );
    return Row(
      children: [
        SizedBox(width: 12.w, child: Text(rowName, style: TextStyle(fontSize: 10.px))),
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

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0XFFB6B6B6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double dashWidth = 5.0;
    final double dashSpace = 5.0;
    final int dashCount = (size.width / (dashWidth + dashSpace)).floor();

    final double actualDashWidth = (size.width - (dashSpace * (dashCount - 1))) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final double startX = i * (actualDashWidth + dashSpace);
      final double endX = startX + actualDashWidth;

      canvas.drawLine(
        Offset(startX, 0),
        Offset(endX, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter oldDelegate) => false;
}
