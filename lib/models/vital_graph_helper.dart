import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/app_colors.dart';

class VitalGraphClass {
  static final List<Color> gradientColors = AppColors.graphGradient1;
  static final List<Color> gradientColors2 = AppColors.graphGradient2;
  List data;
  static final DateTime today = DateTime.now();
  List<FlSpot> currentlyShowing;
  List<FlSpot> currentlyShowingSys;
  List<FlSpot> currentlyShowingDias;
  int currentLength;

  /// minimum plotted y value -10 ⏬
  double minY;

  /// maximum plotted y value +10 ⏫
  double maxY;
  static final Widget noData = Center(
    child: Container(
      child: Text(AppTexts.graphNoData),
    ),
  );
  //constructor
  VitalGraphClass(
    List li,
  ) {
    data = li;
  }

  /// returns a chart widget for given time offset (only for BP graph)
  Widget createBPChart(Duration offset) {
    if (offset == null) {
      var currentlyShowingDiasSys = createBPAllSpots(data);
      currentlyShowingDias = currentlyShowingDiasSys[0];
      currentlyShowingSys = currentlyShowingDiasSys[1];
      currentLength = currentlyShowingSys.length;
      if (currentLength < 2 || currentlyShowingDias == null) {
        return noData;
      }
      return LineChart(_showChart([
        lineChartBarDataFier(currentlyShowingDias, gradientColors),
        lineChartBarDataFier(currentlyShowingSys, gradientColors2)
      ]));
    }

    var currentlyShowingDiasSys = createBPDurationSpots(data, offset);
    currentlyShowingDias = currentlyShowingDiasSys[0];
    currentlyShowingSys = currentlyShowingDiasSys[1];
    currentLength = currentlyShowingSys.length;
    if (currentLength < 2 || currentlyShowingDias == null) {
      return noData;
    }
    return LineChart(_showChart([
      lineChartBarDataFier(currentlyShowingDias, gradientColors),
      lineChartBarDataFier(currentlyShowingSys, gradientColors2)
    ]));
  }

  Widget createChart(Duration offset) {
    if (offset == null) {
      currentlyShowing = createAllSpots(data);
      currentLength = currentlyShowing.length;
      if (currentLength < 2 || currentlyShowing == null) {
        return noData;
      }
      return LineChart(
          _showChart([lineChartBarDataFier(currentlyShowing, gradientColors)]));
    }
    currentlyShowing = createDurationSpots(data, offset);
    currentLength = currentlyShowing.length;
    if (currentLength < 2 || currentlyShowing == null) {
      return noData;
    }
    return LineChart(
        _showChart([lineChartBarDataFier(currentlyShowing, gradientColors)]));
  }

  List<List<FlSpot>> createBPDurationSpots(List toMap, Duration offSet) {
    DateTime offSetDate = today.subtract(offSet);

    List<FlSpot> toSendSys = [];
    List<FlSpot> toSendDys = [];
    DateTime dateCurrentIt;
    for (int i = 0; i < toMap.length; i++) {
      if (toMap[i]['date'] != null &&
          dateCurrentIt != toMap[i]['date'] &&
          toMap[i]['date'].isAfter(offSetDate)) {
        dateCurrentIt = toMap[i]['date'];

        if (toMap[i]['moreData']['Systolic'] != null &&
            i != null &&
            toMap[i]['moreData']['Systolic'] != '') {
          double doubleToAdd;
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
    }

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
      colors: [AppColors.primaryAccentColor],
      barWidth: 1,
      isCurved: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: true,
        colors: grad.map((color) => color.withOpacity(0.3)).toList(),
      ),
    );
  }

  //Create FL spots
  List<FlSpot> createAllSpots(List toMap) {
    List<FlSpot> toSend = [];
    DateTime dateCurrentIt;
    for (int i = 0; i < toMap.length; i++) {
      if (dateCurrentIt != toMap[i]['date'] &&
          toMap[i]['value'] != null &&
          i != null &&
          toMap[i]['value'] != '') {
        dateCurrentIt = toMap[i]['date'];
        double doubleToAdd;
        if(toMap[i]['value']=='NaN'){
          toMap[i]['value']=0.0;
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

  LineChartData _showChart(List<LineChartBarData> listOfData) {
    return LineChartData(
      minY: minY == null ? 0 : minY - 10,
      maxY: !(maxY == null) ? maxY + 10 : null,
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 0,
          rotateAngle: 0,
          interval: listOfData[0].spots.length < 5
              ? 1
              : listOfData[0].spots.length / 5,
          getTextStyles: (_, value) {
            return const TextStyle(
                color: Color(0xff68737d),
                fontWeight: FontWeight.bold,
                fontSize: 10);
          },
          getTitles: (value) {
            DateTime date = data[value.toInt()]['date'];
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
            return month[date.month] + '/' + year.toString();
          },
          margin: 5,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (_, val) {
            return const TextStyle(
              color: Color(0xff67727d),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            );
          },
          interval: (maxY + 20 - minY) / 4,
          getTitles: (value) {
            return value.toInt().toString();
          },
          reservedSize: 22,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
        show: true,
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
