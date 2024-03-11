import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// ECG GRAPH WIDGET
class HorizontalECGGraph extends StatelessWidget {
  Map ecg;
  HorizontalECGGraph({this.ecg});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ECGChart(
        ecg: ecg,
      ),
    );
  }
}

class ECGChart extends StatelessWidget {
  Map ecg;
  ECGChart({this.ecg});
  @override
  Widget build(BuildContext context) {
    return LineChart(
      mainData(),
    );
  }

  final Color graphColor = Color(0xffff479f);
  LineChartBarData lineChartBarDataFier(List<FlSpot> spots, {color}) {
    color ??= graphColor;
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      colors: [color],
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
  }

  List<LineChartBarData> createBigBoxes() {
    List<LineChartBarData> toSend = [];
    int interval = ((ecg['spots'].length + 1) / 30).toInt();
    for (int i = 0; i < ecg['spots'].length; i += interval) {
      toSend.add(lineChartBarDataFier(
        [
          FlSpot(i.toDouble(), ecg['max'].toDouble()),
          FlSpot(i.toDouble(), ecg['min'].toDouble()),
        ],
      ));
    }
    interval = ((ecg['max'] - ecg['min']) / 4).toInt();

    for (int i = ecg['min'].toInt(); i < ecg['max']; i += interval) {
      toSend.add(lineChartBarDataFier([
        FlSpot(0.0, i.toDouble()),
        FlSpot(ecg['spots'].length.toDouble(), i.toDouble()),
      ], color: graphColor));
    }
    toSend.add(lineChartBarDataFier(ecg['spots'], color: Colors.black));
    return toSend;
  }

  LineChartData mainData() {
    return LineChartData(
      maxY: ecg['max'],
      minY: ecg['min'],
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        checkToShowHorizontalLine: (value) {
          var range = (ecg['max'] - ecg['min']);
          value = value - ecg['min'];
          int interval = (range / 20).toInt();
          if (value % interval == 0) {
            return true;
          }
          return false;
        },
        checkToShowVerticalLine: (value) =>
            (value % ((ecg['spots'].length + 1) / 150).toInt()).toInt() == 0,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: graphColor,
            strokeWidth: .2,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: graphColor,
            strokeWidth: .5,
            dashArray: [2000],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
        bottomTitles: SideTitles(
          showTitles: false,
        ),
        leftTitles: SideTitles(
            showTitles: true,
            interval: 500,
            getTitles: (double val) {
              return val.toInt().toString();
            }),
      ),
      borderData: FlBorderData(
          show: true, border: Border.all(color: graphColor, width: 0.5)),
      lineBarsData: createBigBoxes(),
    );
  }
}
