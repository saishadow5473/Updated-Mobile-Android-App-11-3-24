import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NewMyVitalGraph {
  List datas;
  static bool loader = false;
  static final DateTime today = DateTime.now();
  List<FlSpot> currentlyShowing;
  List<FlSpot> currentlyShowingSys;
  List<FlSpot> currentlyShowingDias;
  int currentLength;
  static List mapDataForward = [];
  static List mapDataBackward = [];

  /// minimum plotted y value -10 ⏬
  double minY;

  /// maximum plotted y value +10 ⏫
  double maxY;
  static final Widget noData = Center(
    child: Container(
      child: Text("No Records found !"),
    ),
  );

  Widget createBPChart({List data}) {
    datas = data;

    var currentlyShowingDiasSys = createBPDurationSpots(datas);
    currentlyShowingDias = currentlyShowingDiasSys[0];
    currentlyShowingSys = currentlyShowingDiasSys[1];
    currentLength = currentlyShowingSys.length;
    if (currentLength == 1) {
      return Center(
        child: Container(
          child: Text("Atleast two data is needed to plot a graph !"),
        ),
      );
    } else if (currentLength < 2 || currentlyShowingDias == null) {
      return noData;
    }
    return LineChart(
      _showChart([
        lineChartBarDataFier(currentlyShowingDias, [Colors.purple]),
        lineChartBarDataFier(currentlyShowingSys, [Color(0XFF0E9CFF)])
      ], ""),
      swapAnimationDuration: Duration(seconds: 2),
      swapAnimationCurve: Curves.easeIn,
    );
  }

  Widget createChart({List data, var vitalName}) {
    datas = data;
    // if (offset == null) {
    currentlyShowing = createAllSpots(datas);
    currentLength = currentlyShowing.length;
    if (currentLength == 1) {
      return Center(
        child: Container(
          child: Text("Atleast two data is needed to plot a graph !"),
        ),
      );
    } else if (currentLength < 2 || currentlyShowing == null) {
      return noData;
    }
    return LineChart(
      _showChart([
        lineChartBarDataFier(currentlyShowing, [Color(0XFF0E9CFF)]),
      ], vitalName),
      swapAnimationDuration: Duration(seconds: 2),
      swapAnimationCurve: Curves.easeIn,
    );
    // }
    // currentlyShowing = createDurationSpots(datas, offset);
    // currentLength = currentlyShowing.length;
    // if (currentLength == 1) {
    //   return Center(
    //     child: Container(
    //       child: Text("Atleast two data is needed to plot a graph !"),
    //     ),
    //   );
    // } else if (currentLength < 2 || currentlyShowing == null) {
    //   return noData;
    // }
    // return LineChart(_showChart([
    //   lineChartBarDataFier(currentlyShowing, [Color(0XFF0E9CFF)])
    // ]));
  }

  List<List<FlSpot>> createBPDurationSpots(List toMap) {
    List<FlSpot> toSendSys = [];
    List<FlSpot> toSendDys = [];
    DateTime dateCurrentIt;
    for (int i = 0; i < toMap.length; i++) {
      List sysAndDia = toMap[i]["value"].split('/').toList();
      if (sysAndDia.first != null &&
          // i != null &&
          sysAndDia.first != '') {
        double doubleToAdd;
        if (sysAndDia.first is double) {
          doubleToAdd = sysAndDia.first;
        }
        if (sysAndDia.first is int) {
          doubleToAdd = sysAndDia.first.toDouble();
        }
        if (sysAndDia.first is String) {
          doubleToAdd = double.parse(sysAndDia.first);
        }
        if (doubleToAdd != null) {
          toSendSys.add(FlSpot(
            i.toDouble(),
            doubleToAdd,
          ));
          minY ??= doubleToAdd;
          maxY ??= doubleToAdd;
          minY = minY > doubleToAdd ? doubleToAdd : minY;
          maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
        }
        doubleToAdd = null;
        if (sysAndDia[1] is double) {
          doubleToAdd = sysAndDia[1];
        }
        if (sysAndDia[1] is int) {
          doubleToAdd = sysAndDia[1].toDouble();
        }
        if (sysAndDia[1] is String) {
          doubleToAdd = double.parse(sysAndDia[1]);
        }
        if (doubleToAdd != null) {
          toSendDys.add(FlSpot(
            i.toDouble(),
            doubleToAdd,
          ));
          minY ??= doubleToAdd;
          maxY ??= doubleToAdd;
          minY = minY > doubleToAdd ? doubleToAdd : minY;
          maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
        }
      }
    }
    // }

    return [toSendDys, toSendSys];
  }

//create duration spots
  List<FlSpot> createDurationSpots(List toMap, Duration offSet) {
    DateTime offSetDate = today.subtract(offSet);
    DateTime dateCurrentIt;

    List<FlSpot> toSend = [];
    for (int i = 0; i < toMap.length; i++) {
      if (toMap[i]['date'] != null &&
          dateCurrentIt != toMap[i]['date'] &&
          toMap[i]['date'].isAfter(offSetDate)) {
        double doubleToAdd;
        dateCurrentIt = toMap[i]['date'];
        if (toMap[i]['value'] is double) {
          doubleToAdd = toMap[i]['value'];
        }
        if (toMap[i]['value'] is int) {
          doubleToAdd = toMap[i]['value'].toDouble();
        }
        if (toMap[i]['value'] is String) {
          doubleToAdd = double.parse(toMap[i]['value']);
        }
        if (doubleToAdd != null) {
          toSend.add(FlSpot(
            i.toDouble(),
            doubleToAdd,
          ));
          minY ??= doubleToAdd;
          maxY ??= doubleToAdd;
          minY = minY > doubleToAdd ? doubleToAdd : minY;
          maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
        }
      }
    }
    return toSend;
  }

  LineChartBarData lineChartBarDataFier(List<FlSpot> spot, List<Color> grad) {
    return LineChartBarData(
      spots: spot,
      colors: [Color(0XFF0E9CFF)],
      barWidth: 1,
      isCurved: true,
      //curveSmoothness: 0.3,
      preventCurveOvershootingThreshold: 0.1,
      // preventCurveOverShooting: true,
      // dotData: FlDotData(
      //   show: false,
      // ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
              radius: 4, color: Colors.white, strokeWidth: 1, strokeColor: Color(0XFF0E9CFF));
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        colors: grad.map((color) => color.withOpacity(0.5)).toList(),
      ),
    );
  }

  //Create FL spots
  List<FlSpot> createAllSpots(List toMap) {
    List<FlSpot> toSend = [];
    DateTime dateCurrentIt;
    for (int i = 0; i < toMap.length ?? 0; i++) {
      if (dateCurrentIt != toMap[i]['date'] &&
          toMap[i]['value'] != null &&
          i != null &&
          toMap[i]['value'] != '') {
        dateCurrentIt = toMap[i]['date'];
        double doubleToAdd;
        if (toMap[i]['value'] == 'NaN') {
          toMap[i]['value'] = 0.0;
        }
        if (toMap[i]['value'] is double) {
          doubleToAdd = toMap[i]['value'];
        }
        if (toMap[i]['value'] is int) {
          doubleToAdd = toMap[i]['value'].toDouble();
        }
        if (toMap[i]['value'] is String) {
          doubleToAdd = double.parse(toMap[i]['value']);
        }
        if (doubleToAdd != null) {
          toSend.add(FlSpot(
            i.toDouble(),
            doubleToAdd,
          ));
          minY ??= doubleToAdd;
          maxY ??= doubleToAdd;
          minY = minY > doubleToAdd ? doubleToAdd : minY;
          maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
        }
      }
    }
    return toSend;
  }

  List<List<FlSpot>> createBPAllSpots(List toMap) {
    List<FlSpot> toSendSys = [];
    List<FlSpot> toSendDys = [];
    DateTime dateCurrentIt;
    for (int i = 0; i < toMap.length; i++) {
      if (dateCurrentIt != toMap[i]['date'] &&
          toMap[i]['moreData']['Systolic'] != null &&
          i != null &&
          toMap[i]['moreData']['Systolic'] != '') {
        double doubleToAdd;
        dateCurrentIt = toMap[i]['date'];
        if (toMap[i]['moreData']['Systolic'] is double) {
          doubleToAdd = toMap[i]['moreData']['Systolic'];
        }
        if (toMap[i]['moreData']['Systolic'] is int) {
          doubleToAdd = toMap[i]['moreData']['Systolic'].toDouble();
        }
        if (toMap[i]['moreData']['Systolic'] is String) {
          doubleToAdd = double.parse(toMap[i]['moreData']['Systolic']);
        }
        if (doubleToAdd != null) {
          toSendSys.add(FlSpot(
            i.toDouble(),
            doubleToAdd,
          ));
          minY ??= doubleToAdd;
          maxY ??= doubleToAdd;
          minY = minY > doubleToAdd ? doubleToAdd : minY;
          maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
        }
        doubleToAdd = null;
        if (toMap[i]['moreData']['Diastolic'] is double) {
          doubleToAdd = toMap[i]['moreData']['Diastolic'];
        }
        if (toMap[i]['moreData']['Diastolic'] is int) {
          doubleToAdd = toMap[i]['moreData']['Diastolic'].toDouble();
        }
        if (toMap[i]['moreData']['Diastolic'] is String) {
          doubleToAdd = double.parse(toMap[i]['moreData']['Diastolic']);
        }
        if (doubleToAdd != null) {
          toSendDys.add(FlSpot(
            i.toDouble(),
            doubleToAdd,
          ));
          minY ??= doubleToAdd;
          maxY ??= doubleToAdd;
          minY = minY > doubleToAdd ? doubleToAdd : minY;
          maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
        }
      }
    }

    return [toSendDys, toSendSys];
  }

  static String selectedTypeinGraph = "";

  LineChartData _showChart(List<LineChartBarData> listOfData, var VitalType) {
    double minYAxis = minY == null ? 0 : minY - ((maxY ?? 0) / 10);
    double maxYAxis = maxY == null ? 1 : maxY + maxY / 20;
    double interval = VitalType != "basal_metabolic_rate" ? (maxY + 20 - minY) / 4 : 100;
    return LineChartData(
      // minX: 0,
      // Set the minimum value for the x-axis
      // maxX: 10,
      // Set the maximum value for the x-axis
      minY: minYAxis,
      maxY: maxYAxis,
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 1,
          rotateAngle: 0,
          interval: listOfData[0].spots.length < 5 ? 1 : listOfData[0].spots.length / 7,
          getTextStyles: (_, value) {
            return TextStyle(
                color: Color(0xff68737d), fontWeight: FontWeight.bold, fontSize: 12.sp);
          },
          getTitles: (value) {
            DateTime date = datas[value.toInt()]['date'];
            List month = [
              '',
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec'
            ];
            int year = date.year;
            if (year < 2000) {
              year = year - 1900;
            } else {
              year = year - 2000;
            }
            if (selectedTypeinGraph == "Monthly")
              return month[date.month] + ' / ' + year.toString();
            else
              return date.day.toString() + " / " + month[date.month];
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (_, val) {
            return TextStyle(
              color: Color(0xff67727d),
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            );
          },
          interval: maxYAxis < 5 ? 0.4 : interval,
          getTitles: (value) {
            return value.toStringAsFixed(1);
          },
          reservedSize: 25,
          margin: 8,
        ),
        rightTitles: SideTitles(
          showTitles: true,
          getTextStyles: (_, val) {
            return TextStyle(
              color: Colors.transparent,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            );
          },
          interval: (maxY + 20 - minY) / 4,
          getTitles: (value) {
            return value.toInt().toString();
          },
          reservedSize: 20,
          margin: 8,
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 2,
          ),
          left: BorderSide(
            color: Color(0xff4e4965),
            width: 2,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      lineBarsData: listOfData,
    );
  }
}
