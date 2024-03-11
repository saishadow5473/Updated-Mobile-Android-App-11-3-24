import 'package:flutter/material.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../journal_graph.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/apis/log_apis.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MonthlyTab extends StatefulWidget {
  // const MonthlyTab({ Key key }) : super(key: key);

  @override
  _MonthlyTabState createState() => _MonthlyTabState();
}

class _MonthlyTabState extends State<MonthlyTab> {
  @override
  List<ChartData> graphDataList = [];
  bool nodata = false;
  int target = 0;
  ListApis listApis = ListApis();
  LogApis logapis = LogApis();
  void getData() async {
    String tillDate = DateTime.now().add(Duration(days: 1)).toString().substring(0, 10);
    String fromDate = DateTime.now()
        .subtract(Duration(days: 365)) //365
        .toString()
        .substring(0, 10);
    // DateTime.now().subtract(Duration(days: 29)).toString().substring(0, 10);
    String tabType =
        'monthly'; //pull one year record from today date and add the values of with month match

    graphDataList = await ListApis.getUserFoodLogHistoryApi(
            fromDate: fromDate, tillDate: tillDate, tabType: tabType) ??
        [];
    if (graphDataList.isEmpty) {
      String _tillDate = DateTime.now().add(Duration(days: 1)).toString().substring(0, 10);
      String fromDate = DateTime.now()
          .subtract(Duration(days: 175)) //365
          .toString()
          .substring(0, 10);
      graphDataList = await ListApis.getUserFoodLogHistoryApi(
              fromDate: fromDate, tillDate: _tillDate, tabType: tabType) ??
          [];
    }
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
      target = prefs.getInt('monthly_target');
    });
  }

  @override
  void initState() {
    getData();
    getTarget();
    super.initState();
  }

  List<ChartData> monthlyChartData = [
    ChartData('Jan', 3500),
    ChartData('Feb', 3100),
    ChartData('Mar', 3300),
    ChartData('Apr', 4300),
    ChartData('May', 3800),
    ChartData('Jun', 4000),
    ChartData('Jul', 5000),
    ChartData('Aug', 6000),
    ChartData('Sep', 1000),
    ChartData('Oct', 5000),
    ChartData('Nov', 4000),
    ChartData('Dec', 2000),
  ];
  List<DailyCalorieData> monthlyChartData0 = [
    DailyCalorieData(DateTime(2021, 08, 04), 3500),
    DailyCalorieData(DateTime(2021, 09, 03), 3800),
    DailyCalorieData(DateTime(2021, 10, 01), 3400),
    DailyCalorieData(DateTime(2021, 11, 11), 3400),
    DailyCalorieData(DateTime(2021, 12, 12), 3400),
    DailyCalorieData(DateTime(2022, 01, 01), 3400),
    DailyCalorieData(DateTime(2022, 03, 03), 3400),
    DailyCalorieData(DateTime(2022, 04, 03), 3600),
    DailyCalorieData(DateTime(2022, 05, 03), 3900),
    DailyCalorieData(DateTime(2022, 06, 03), 3700),
  ];
  List<OrdinalSales> mo = [
    OrdinalSales('Jan', 3500),
    OrdinalSales('Feb', 3500),
    OrdinalSales('Mar', 3500),
    // OrdinalSales('Jan', 3500),
  ];
  // monthlyChartData.add(DateTime(2021, 08, 04), 3500)
  ///card property

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 7),
      child: Column(
        children: [
          graphDataList.length != 0
              ? Flexible(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.765,
                    child: Card(
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
                      child: SfCartesianChart(
                          isTransposed: true,
                          margin: EdgeInsets.all(4),
                          series: <BarSeries<ChartData, String>>[
                            BarSeries<ChartData, String>(
                              // Binding the chartData to the dataSource of the bar series.
                              // dataSource: monthlyChartData,
                              dataSource: graphDataList,
                              xValueMapper: (ChartData calorie, _) => calorie.x,
                              yValueMapper: (ChartData calorie, _) => calorie.y,
                            ),
                          ],

                          /* series: <ChartSeries>[
                          LineSeries<DailyCalorieData, DateTime>(
                              dataSource: graphDataList, // monthlyChartData,
                              xValueMapper: (DailyCalorieData sales, _) =>
                                  sales.x,
                              yValueMapper: (DailyCalorieData sales, _) =>
                                  sales.y,
                              // Sets the corner radius
                              enableTooltip: true,)
                        ],*/
                          primaryXAxis: CategoryAxis(
                            majorTickLines: MajorTickLines(width: 0),
                            majorGridLines: MajorGridLines(width: 0),
                            interval: 1,
                            // title: AxisTitle(text: 'Months'),
                            desiredIntervals: 1,
                            labelStyle: TextStyle(fontSize: 10),
                          ),

                          ///before we are usiong this DateTime Axis But now i am honna use category axis
                          ///staRT
                          // primaryXAxis: DateTimeAxis(
                          //     majorTickLines: MajorTickLines(width: 0),
                          //     majorGridLines: MajorGridLines(width: 0),
                          //     labelIntersectAction:
                          //         AxisLabelIntersectAction.rotate90,
                          //     interval: 31,
                          //     title: AxisTitle(text: 'Months'),
                          //     minimum:
                          //         DateTime.now().subtract(Duration(days: 365)),
                          //
                          //     // autoScrollingDelta: 30,
                          //     // autoScrollingMode: AutoScrollingMode.start,
                          //     // autoScrollingDeltaType: DateTimeIntervalType.months,
                          //     maximum: DateTime.now(),
                          //     maximumLabels: 12,
                          //     // associatedAxisName: ,
                          //
                          //     dateFormat: DateFormat.M()),
                          ///before we are usiong this DateTime Axis But now i am honna use category axis
                          ///staRT
                          primaryYAxis: NumericAxis(
                              title: AxisTitle(
                                  text: 'Calories Intake (in kCal)',
                                  textStyle: TextStyle(fontSize: 12)),
                              maximumLabels: 4,
                              majorTickLines: MajorTickLines(width: 0),
                              majorGridLines: MajorGridLines(width: 0),
                              // edgeLabelPlacement: EdgeLabelPlacement.none,
                              labelStyle: TextStyle(fontSize: 10)),
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
                          )),
                    ),
                  ),
                )
              : nodata
                  ? Container(
                      height: 300,
                      width: 320,
                      child: Card(
                          color: CardColors.bgColor,
                          child: Center(
                            child: Text(
                              'No data for this month.\nTry Logging!',
                              textAlign: TextAlign.center,
                            ),
                          )))
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
                            'Your monthly calorie intake would be $target Cal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: CardColors.titleColor,
                            ),
                          ),
                          Text(
                            'Recommended healthy average calorie consumption will be 53k kCal - 58k Cal',
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

/// Bar chart example
// import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as charts;

/// Example of a grouped bar chart with three series, each rendered with
/// different fill colors.
class GroupedFillColorBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  GroupedFillColorBarChart(this.seriesList, {this.animate});

  factory GroupedFillColorBarChart.withSampleData() {
    return new GroupedFillColorBarChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 10,
          margin: EdgeInsets.all(8),
          child: Container(
            padding: EdgeInsets.all(5),
            height: MediaQuery.of(context).size.height / 2,
            child: charts.BarChart(
              seriesList,
              animate: true, animationDuration: Duration(seconds: 2),
              defaultInteractions: false,
              // Configure a stroke width to enable borders on the bars.
              defaultRenderer: new charts.BarRendererConfig(
                  groupingType: charts.BarGroupingType.grouped, strokeWidthPx: 0.0),
            ),
          ),
        ),
      ],
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final desktopSalesData = [
      new OrdinalSales('Jan', 5),
      new OrdinalSales('Feb', 25),
      new OrdinalSales('Mar', 100),
      new OrdinalSales('Apr', 75),
      new OrdinalSales('May', 29),
      new OrdinalSales('Jun', 33),
      new OrdinalSales('Aug', 44),
      new OrdinalSales('Sep', 50),
      new OrdinalSales('Oct', 25),
      new OrdinalSales('Nov', 72),
      new OrdinalSales('Dec', 88),
    ];

    // final tableSalesData = [
    //   new OrdinalSales('2014', 25),
    //   new OrdinalSales('2015', 50),
    //   new OrdinalSales('2016', 10),
    //   new OrdinalSales('2017', 20),
    // ];
    //
    // final mobileSalesData = [
    //   new OrdinalSales('2014', 10),
    //   new OrdinalSales('2015', 50),
    //   new OrdinalSales('2016', 50),
    //   new OrdinalSales('2017', 45),
    // ];

    return [
      // Blue bars with a lighter center color.
      charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault.darker,
        fillColorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
      // Solid red bars. Fill color will default to the series color if no
      // fillColorFn is configured.
      // new charts.Series<OrdinalSales, String>(
      //   id: 'Tablet',
      //   measureFn: (OrdinalSales sales, _) => sales.sales,
      //   data: tableSalesData,
      //   colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      //   domainFn: (OrdinalSales sales, _) => sales.year,
      // ),
      // Hollow green bars.
      // new charts.Series<OrdinalSales, String>(
      //   id: 'Mobile',
      //   domainFn: (OrdinalSales sales, _) => sales.year,
      //   measureFn: (OrdinalSales sales, _) => sales.sales,
      //   data: mobileSalesData,
      //   colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      //   fillColorFn: (_, __) => charts.MaterialPalette.transparent,
      // ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}

class ChartData {
  ChartData(this.x, this.y, {this.category = ""});
  final String x;
  final int y;
  String category = "";
}
