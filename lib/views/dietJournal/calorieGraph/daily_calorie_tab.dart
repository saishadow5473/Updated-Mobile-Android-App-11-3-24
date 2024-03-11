// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, missing_return, unnecessary_statements, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../journal_graph.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';

class DailyTab extends StatefulWidget {
  // const DailyTab({ Key key }) : super(key: key);

  @override
  _DailyTabState createState() => _DailyTabState();
}

class _DailyTabState extends State<DailyTab> {
  List<DailyCalorieData> graphDataList = [];
  bool nodata = false;
  int target = 0;
  //  LogApis logapis = LogApis();
  void getData() async {
    // logapis.logUserFoodIntakeApi();
    // await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    // return true;
    String tillDate = DateTime.now().toString().substring(0, 10);
    String fromDate = DateTime.now().subtract(Duration(days: 7)).toString().substring(0, 10);
    String tabType = 'daily';
    var listApis = ListApis();
    graphDataList = await listApis.getUserTodaysFoodLogHistoryApi(graph: true);
    graphDataList.removeWhere((element) => element.y.toString() == '0'
        // || element.y.toString() == '56'
        );
    setState(() {
      if (graphDataList.isEmpty) {
        nodata = true;
      }
      graphDataList;
    });
  }

  getTarget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      target = prefs.getInt('daily_target');
    });
  }

  @override
  void initState() {
    getData();
    getTarget();
    super.initState();
  }

  final List<DailyCalorieData> dailyChartData = [
    DailyCalorieData(DateTime(2021, 08, 04, 09, 33), 35),
    DailyCalorieData(DateTime(2021, 08, 04, 10, 43), 38),
    DailyCalorieData(DateTime(2021, 08, 04, 11, 34), 34),
    DailyCalorieData(DateTime(2021, 08, 04, 13, 30), 52),
    DailyCalorieData(DateTime(2021, 08, 04, 18, 13), 40),
    DailyCalorieData(DateTime(2021, 08, 04, 20, 00), 38),
    DailyCalorieData(DateTime(2021, 08, 04, 22, 01), 34),
    DailyCalorieData(DateTime(2021, 08, 04, 23, 56), 52),
  ];

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            graphDataList.length != 0
                ? Container(
                    height: 500,
                    child: Card(
                      // color: CardColors.bgColor,
                      color: FitnessAppTheme.white,
                      shadowColor: FitnessAppTheme.grey.withOpacity(0.2),
                      elevation: 2,
                      borderOnForeground: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                          side: BorderSide(
                            width: 1,
                            color: FitnessAppTheme.nearlyWhite,
                          )),
                      /*   child: SfCartesianChart(
                          series: <ChartSeries>[
                            LineSeries<DailyCalorieData, DateTime>(
                              dataSource: graphDataList,
                              // dailyChartData,
                              xValueMapper: (DailyCalorieData calorie, _) =>
                                  calorie.x,
                              yValueMapper: (DailyCalorieData calorie, _) =>
                                  calorie.y,
                              enableTooltip: true,
                            )
                          ],
                          trackballBehavior: TrackballBehavior(
                            enable: true,
                            markerSettings: TrackballMarkerSettings(
                              markerVisibility: TrackballVisibilityMode.hidden,
                              height: 10,
                              width: 10,
                              borderWidth: 1,
                            ),
                            activationMode: ActivationMode.singleTap,
                            tooltipDisplayMode:
                                TrackballDisplayMode.floatAllPoints,
                            tooltipSettings: InteractiveTooltip(
                                format: 'point.x : point.y kCal',
                                canShowMarker: false),
                            shouldAlwaysShow: true,
                          ),
                          primaryXAxis: DateTimeAxis(
                              majorTickLines: MajorTickLines(width: 0),
                              majorGridLines: MajorGridLines(width: 0),
                              enableAutoIntervalOnZooming: true,
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              title: AxisTitle(text: 'Time'),
                              labelIntersectAction:
                                  AxisLabelIntersectAction.rotate90,
                              dateFormat: DateFormat.jm()),
                          primaryYAxis: NumericAxis(
                            majorTickLines: MajorTickLines(width: 0),
                            majorGridLines: MajorGridLines(width: 0),
                            title: AxisTitle(text: 'Calories Intake (in kCal)'),
                          ),
                          // tooltipBehavior: TooltipBehavior(
                          //     enable: true,
                          //     header: '',
                          //     canShowMarker: false,
                          //     format: 'point.x : point.y kCal',
                          //     activationMode: ActivationMode.singleTap),
                          enableAxisAnimation: true,
                          zoomPanBehavior: ZoomPanBehavior(
                            enablePinching: true,
                            zoomMode: ZoomMode.xy,
                            enablePanning: true,
                          )),
                     */
                      child: SfCartesianChart(
                          isTransposed: true,
                          series: <BarSeries<DailyCalorieData, DateTime>>[
                            BarSeries<DailyCalorieData, DateTime>(
                              // Binding the chartData to the dataSource of the bar series.
                              dataSource: graphDataList,
                              xValueMapper: (DailyCalorieData calorie, _) => calorie.x,
                              yValueMapper: (DailyCalorieData calorie, _) => calorie.y,
                            ),
                          ],
                          trackballBehavior: TrackballBehavior(
                            enable: true,
                            markerSettings: TrackballMarkerSettings(
                              markerVisibility: TrackballVisibilityMode.hidden,
                              height: 10,
                              width: 10,
                              borderWidth: 1,
                            ),
                            activationMode: ActivationMode.singleTap,
                            tooltipDisplayMode: TrackballDisplayMode.floatAllPoints,
                            tooltipSettings: InteractiveTooltip(
                                format: 'point.x : point.y Cal', canShowMarker: false),
                            shouldAlwaysShow: true,
                          ),
                          primaryXAxis: DateTimeAxis(
                              majorTickLines: MajorTickLines(width: 0),
                              majorGridLines: MajorGridLines(width: 0),
                              enableAutoIntervalOnZooming: true,
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              title: AxisTitle(text: 'Time'),
                              labelIntersectAction: AxisLabelIntersectAction.rotate90,
                              dateFormat: DateFormat.jm()),
                          primaryYAxis: NumericAxis(
                            majorTickLines: MajorTickLines(width: 0),
                            majorGridLines: MajorGridLines(width: 0),
                            title: AxisTitle(text: 'Calories Intake (in kCal)'),
                          ),
                          // tooltipBehavior: TooltipBehavior(
                          //     enable: true,
                          //     header: '',
                          //     canShowMarker: false,
                          //     format: 'point.x : point.y kCal',
                          //     activationMode: ActivationMode.singleTap),
                          enableAxisAnimation: true,
                          zoomPanBehavior: ZoomPanBehavior(
                            enablePinching: true,
                            zoomMode: ZoomMode.xy,
                            enablePanning: true,
                          )),
                    ),
                  )
                : nodata
                    ? Container(
                        height: 250,
                        width: 300,
                        child: Card(
                            color: CardColors.bgColor,
                            child: Center(
                              child: Text(
                                'No data for Today.\nTry Logging!',
                                textAlign: TextAlign.center,
                              ),
                            )))
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
            SizedBox(
              height: ScUtil().setHeight(30),
            ),
            Card(
              // color: CardColors.bgColor,
              color: FitnessAppTheme.white,
              shadowColor: FitnessAppTheme.grey.withOpacity(0.5),
              elevation: 2,
              borderOnForeground: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                  side: BorderSide(
                    width: 1,
                    color: FitnessAppTheme.nearlyWhite,
                  )),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccentColor.withOpacity(0.8),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    child: Center(
                        child: Column(
                      children: <Widget>[
                        Text(
                          '$target',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScUtil().setSp(30),
                          ),
                        ),
                        Text(
                          'Cal',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    )),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Your average daily calorie intake is $target Cal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: CardColors.titleColor,
                            ),
                          ),
                          Text(
                            'Recommended healthy average calorie consumption will be 1600 kCal - 2200 Cal',
                            style: TextStyle(
                              color: CardColors.textColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
