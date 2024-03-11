import 'package:flutter/material.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/calorieGraph/monthly_calorie_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../journal_graph.dart';

class WeeklyTab extends StatefulWidget {
  // const WeeklyTab({ Key key }) : super(key: key);

  @override
  _WeeklyTabState createState() => _WeeklyTabState();
}

class _WeeklyTabState extends State<WeeklyTab> {
  var graphDataList = [];
  bool nodata = false;
  int target = 0;
  String tillDate;
  String fromDate;
  void getData() async {
    tillDate = DateTime.now().add(Duration(days: 1)).toString().substring(0, 10);
    fromDate = DateTime.now().subtract(Duration(days: 6)).toString().substring(0, 10);
    String tabType = 'weekly';

    graphDataList = await ListApis.getUserFoodLogHistoryApi(
            fromDate: fromDate, tillDate: tillDate, tabType: tabType) ??
        [];
    // graphDataList = [
    //   ChartData('Mon', 0),
    //   ChartData('Tue', 200),
    // ];
    // graphDataList.removeWhere((element) => element.y.toString() == '0');
    if (mounted) {
      setState(() {
        if (graphDataList.isEmpty) {
          nodata = true;
        }
        graphDataList;
      });
    }
    // for(int i = 0; i<=graphDataList.length;i++){
    //   if(graphDataList[i].){}
    // }
  }

  getTarget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      target = prefs.getInt('weekly_target');
    });
  }

  @override
  void initState() {
    getData();
    getTarget();
    super.initState();
  }

  List<DailyCalorieData> monthlyChartData = [
    DailyCalorieData(DateTime(2021, 08, 04), 3500),
    DailyCalorieData(DateTime(2021, 08, 03), 3800),
    DailyCalorieData(DateTime(2021, 08, 01), 3400),
  ];
  // monthlyChartData.add(DateTime(2021, 08, 04), 3500)

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        children: [
          graphDataList.length != 0
              ? Flexible(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.765,
                    child: Card(
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
                        ),
                      ),
                      child: SfCartesianChart(
                        isTransposed: true,
                        series: <BarSeries<ChartData, String>>[
                          BarSeries<ChartData, String>(
                            // Binding the chartData to the dataSource of the bar series.
                            dataSource: graphDataList,
                            xValueMapper: (ChartData calorie, _) => calorie.x,
                            yValueMapper: (ChartData calorie, _) => calorie.y,
                          ),
                        ],

                        /*series: <ChartSeries>[
                          LineSeries<DailyCalorieData, DateTime>(
                              dataSource: graphDataList, // monthlyChartData,
                              xValueMapper: (DailyCalorieData sales, _) =>
                                  sales.x,
                              yValueMapper: (DailyCalorieData sales, _) =>
                                  sales.y,
                              // Sets the corner radius
                              enableTooltip: true,)
                        ],*/
                        // primaryXAxis: DateTimeAxis(
                        //     majorTickLines: MajorTickLines(width: 0),
                        //     majorGridLines: MajorGridLines(width: 0),
                        //     enableAutoIntervalOnZooming: true,
                        //     labelIntersectAction:
                        //         AxisLabelIntersectAction.rotate90,
                        //     interval: 1,
                        //     // title: AxisTitle(text: 'Weekly Days'),
                        //     dateFormat: DateFormat('EEE')),
                        primaryXAxis: CategoryAxis(
                          majorTickLines: MajorTickLines(width: 0),
                          majorGridLines: MajorGridLines(width: 0),
                          interval: 1,
                          // title: AxisTitle(text: 'Months'),
                          desiredIntervals: 1,
                          labelStyle: TextStyle(fontSize: 10),
                        ),

                        primaryYAxis: NumericAxis(
                            labelStyle: TextStyle(fontSize: 10),
                            title: AxisTitle(
                                text: 'Calories Intake (in kCal)',
                                textStyle: TextStyle(fontSize: 12)),
                            maximumLabels: 4,
                            majorTickLines: MajorTickLines(width: 0),
                            majorGridLines: MajorGridLines(width: 0)),
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
                        enableAxisAnimation: true,
                        zoomPanBehavior: ZoomPanBehavior(
                          /// To enable the pinch zooming as true.
                          enablePinching: true,
                          zoomMode: ZoomMode.xy,
                          enablePanning: true,
                        ),
                      ),
                    ),
                  ),
                )
              : nodata
                  ? Container(
                      height: 250,
                      width: 300,
                      child: Card(
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
                        child: Center(
                          child: Text(
                            'No data for this week.\nTry Logging!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
          // SizedBox(
          //   height: ScUtil().setHeight(30),
          // ),
          Visibility(
            visible: false,
            child: Card(
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Your weekly calorie intake would be $target Cal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: CardColors.titleColor,
                            ),
                          ),
                          Text(
                            'Recommended healthy average calorie consumption will be 10000 kCal - 14000 Cal',
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
          ),
        ],
      ),
    );
  }
}
