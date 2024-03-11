import 'dart:async';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';

class BarChartSample1 extends StatefulWidget {
  // BarChartSample1({this.graphListData});
  // final graphListData;
  final List<Color> availableColors = [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];

  @override
  State<StatefulWidget> createState() => BarChartSample1State();
}

class BarChartSample1State extends State<BarChartSample1> {
  var graphDataList = [];
  ListApis listApis = ListApis();
  String fromDate;
  String tillDate;
  // LogApis logapis = LogApis();
  void getData() async {
    tillDate = DateTime.now().add(Duration(days: 1)).toString().substring(0, 10);
    fromDate = DateTime.now().subtract(Duration(days: 6)).toString().substring(0, 10);
    String tabType = 'weekly';

    graphDataList = await ListApis.getUserFoodLogHistoryApi(
        fromDate: fromDate, tillDate: tillDate, tabType: tabType);
    if (this.mounted) {
      setState(() {
        graphDataList;
      });
    }
    print(graphDataList.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  final Color barBackgroundColor = const Color(0xff72d8bf);
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              color: AppColors.primaryAccentColor,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_sharp,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                            Text(
                              'Aug ${fromDate.substring(8, 10)} - Aug ${tillDate.substring(8, 10)}',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios_sharp,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 31,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: graphDataList.length != 0
                                ? BarChart(
                                    mainBarData(),
                                    swapAnimationDuration: animDuration,
                                  )
                                : Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          colors: isTouched ? [Colors.yellow] : [barColor],
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 20,
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroupsdummy() => List.generate(7, (i) {
        switch (i) {
          case 1:
            return makeGroupData(0, 400, isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(1, 250, isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(2, 150, isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(3, 300, isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(4, 180, isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(5, 170, isTouched: i == touchedIndex);
          case 7:
            return makeGroupData(6, 50, isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i + 1) {
          case 1:
            return makeGroupData(
                DateTime.fromMillisecondsSinceEpoch(graphDataList[0].calorieDate).weekday,
                graphDataList[0].calorieConsume.toDouble(),
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(
                DateTime.fromMillisecondsSinceEpoch(graphDataList[1].calorieDate).weekday,
                graphDataList[1].calorieConsume.toDouble(),
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(
                DateTime.fromMillisecondsSinceEpoch(graphDataList[2].calorieDate).weekday,
                graphDataList[2].calorieConsume.toDouble(),
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(
                DateTime.fromMillisecondsSinceEpoch(graphDataList[3].calorieDate).weekday,
                graphDataList[3].calorieConsume.toDouble(),
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(
                DateTime.fromMillisecondsSinceEpoch(graphDataList[4].calorieDate).weekday,
                graphDataList[4].calorieConsume.toDouble(),
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(
                DateTime.fromMillisecondsSinceEpoch(graphDataList[5].calorieDate).weekday,
                graphDataList[5].calorieConsume.toDouble(),
                isTouched: i == touchedIndex);
          case 7:
            return makeGroupData(
                DateTime.fromMillisecondsSinceEpoch(graphDataList[6].calorieDate).weekday,
                graphDataList[6].calorieConsume.toDouble(),
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 1:
                  weekDay = 'Monday';
                  break;
                case 2:
                  weekDay = 'Tuesday';
                  break;
                case 3:
                  weekDay = 'Wednesday';
                  break;
                case 4:
                  weekDay = 'Thursday';
                  break;
                case 5:
                  weekDay = 'Friday';
                  break;
                case 6:
                  weekDay = 'Saturday';
                  break;
                case 7:
                  weekDay = 'Sunday';
                  break;
                default:
                  throw Error();
              }
              return BarTooltipItem(
                weekDay + '\n' + (rod.y - 1).toString() + ' Cal',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                // children: <TextSpan>[
                //   TextSpan(
                //     text: (rod.y - 1).toString(),
                //     style: TextStyle(
                //       color: Colors.yellow,
                //       fontSize: 16,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),

                // ],
              );
            }),
        touchCallback: (barTouchResponse) {
          if (this.mounted) {
            setState(() {
              if (barTouchResponse.spot != null &&
                  barTouchResponse.touchInput is! PointerUpEvent &&
                  barTouchResponse.touchInput is! PointerExitEvent) {
                touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
              } else {
                touchedIndex = -1;
              }
            });
          }
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (_, value) {
            return TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
          },
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 1:
                return 'M';
              case 2:
                return 'T';
              case 3:
                return 'W';
              case 4:
                return 'T';
              case 5:
                return 'F';
              case 6:
                return 'S';
              case 7:
                return 'S';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: graphDataList == null ? showingGroupsdummy() : showingGroups(),
    );
  }

  BarChartData randomData() {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          // getTextStyles: (value) =>
          //     const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 1:
                return 'M';
              case 2:
                return 'T';
              case 3:
                return 'W';
              case 4:
                return 'T';
              case 5:
                return 'F';
              case 6:
                return 'S';
              case 7:
                return 'S';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(7, (i) {
        switch (i) {
          case 1:
            return makeGroupData(0, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 2:
            return makeGroupData(1, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 3:
            return makeGroupData(2, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 4:
            return makeGroupData(3, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 5:
            return makeGroupData(4, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 6:
            return makeGroupData(5, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          case 7:
            return makeGroupData(6, Random().nextInt(15).toDouble() + 6,
                barColor: widget.availableColors[Random().nextInt(widget.availableColors.length)]);
          default:
            return throw Error();
        }
      }),
    );
  }

  Future<dynamic> refreshState() async {
    if (this.mounted) {
      setState(() {});
    }
    await Future<dynamic>.delayed(animDuration + const Duration(milliseconds: 50));
    if (isPlaying) {
      await refreshState();
    }
  }
}
