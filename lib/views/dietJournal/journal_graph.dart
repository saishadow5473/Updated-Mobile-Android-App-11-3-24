import 'package:flutter/material.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/views/dietDashboard/bar_chart_sample1.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/calorieGraph/daily_calorie_tab.dart';
import 'package:ihl/views/dietJournal/calorieGraph/weekly_calorie_tab.dart';
import 'package:ihl/views/dietJournal/calorieGraph/monthly_calorie_tab.dart';

class CalorieGraph extends StatefulWidget {
  @override
  _CalorieGraphState createState() => _CalorieGraphState();
}

class _CalorieGraphState extends State<CalorieGraph> {
  //init state api call
  //we received the proper data
  //we add the data in graph
  var graphDataList = [];
  ListApis listApis = ListApis();
  void getData() async {
    // await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    // return true;
    // graphDataList = await listApis.getUserFoodLogHistoryApi();
    if (this.mounted) {
      setState(() {
        graphDataList;
      });
    }
  }

  @override
  void initState() {
    // getData();
    super.initState();
  }

  Widget weeklyTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Card(
              child: BarChartSample1(),
              color: CardColors.bgColor,
            ),
            SizedBox(
              height: ScUtil().setHeight(30),
            ),
            Card(
              color: CardColors.bgColor,
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
                          '1357',
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
                            'Your average daily calorie intake is 1357 Cal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: CardColors.titleColor,
                            ),
                          ),
                          Text(
                            'Recommended healthy average calorie consumption will be 1200 kCal - 1800 Cal',
                            style: TextStyle(
                              color: CardColors.textColor,
                              height: ScUtil().setHeight(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'History',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScUtil().setSp(20),
                  color: AppColors.lightTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget dailyTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              height: 250,
              child: Card(
                color: CardColors.bgColor,
                child: SfCartesianChart(
                  series: <ChartSeries>[
                    ColumnSeries<DailyCalorieData, DateTime>(
                        dataSource: dailyChartData,
                        xValueMapper: (DailyCalorieData calorie, _) => calorie.x,
                        yValueMapper: (DailyCalorieData calorie, _) => calorie.y,
                        width: 0.6,
                        enableTooltip: true,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15), topRight: Radius.circular(15)))
                  ],
                  primaryXAxis: DateTimeAxis(
                      majorTickLines: MajorTickLines(width: 0),
                      majorGridLines: MajorGridLines(width: 0),
                      intervalType: DateTimeIntervalType.hours,
                      interval: 2,
                      labelIntersectAction: AxisLabelIntersectAction.wrap,
                      dateFormat: DateFormat.jm()),
                  primaryYAxis: NumericAxis(
                      maximumLabels: 3,
                      majorTickLines: MajorTickLines(width: 0),
                      majorGridLines: MajorGridLines(width: 0)),
                  tooltipBehavior: TooltipBehavior(
                      enable: true,
                      header: '',
                      canShowMarker: false,
                      format: 'point.x : point.y Cal',
                      activationMode: ActivationMode.singleTap),
                  enableAxisAnimation: true,
                ),
              ),
            ),
            SizedBox(
              height: ScUtil().setHeight(30),
            ),
            Card(
              color: CardColors.bgColor,
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
                          '1357',
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
                            'Your average daily calorie intake is 1357 Cal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: CardColors.titleColor,
                            ),
                          ),
                          Text(
                            'Recommended healthy average calorie consumption will be 1200 kCal - 1800 Cal',
                            style: TextStyle(
                              color: CardColors.textColor,
                              height: ScUtil().setHeight(2),
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

  List<DailyCalorieData> monthlyChartData = [
    DailyCalorieData(DateTime(2021, 08, 04), 3500),
    DailyCalorieData(DateTime(2021, 08, 03), 3800),
    DailyCalorieData(DateTime(2021, 08, 01), 3400),
  ];
  // monthlyChartData.add(DateTime(2021, 08, 04), 3500)

  Widget monthlyTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Card(
              color: CardColors.bgColor,
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

                /* series: <ChartSeries>[
                  ColumnSeries<DailyCalorieData, DateTime>(
                      dataSource: monthlyChartData,
                      xValueMapper: (DailyCalorieData sales, _) => sales.x,
                      yValueMapper: (DailyCalorieData sales, _) => sales.y,
                      // Sets the corner radius
                      width: 0.4,
                      enableTooltip: true,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)))
                ],*/
                primaryXAxis: DateTimeAxis(
                    majorTickLines: MajorTickLines(width: 0),
                    majorGridLines: MajorGridLines(width: 0),
                    intervalType: DateTimeIntervalType.days,
                    labelIntersectAction: AxisLabelIntersectAction.rotate45,
                    dateFormat: DateFormat.yMd()),
                primaryYAxis: NumericAxis(
                    maximumLabels: 3,
                    majorTickLines: MajorTickLines(width: 0),
                    majorGridLines: MajorGridLines(width: 0)),
                tooltipBehavior: TooltipBehavior(
                    enable: true,
                    header: '',
                    canShowMarker: false,
                    format: 'point.x : point.y Cal',
                    activationMode: ActivationMode.singleTap),
                enableAxisAnimation: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return Scaffold(
      backgroundColor: FitnessAppTheme.white,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Container(
            color: AppColors.bgColorTab,
            // color: FitnessAppTheme.white,
            child: CustomPaint(
              painter: BackgroundPainter(
                  primary: AppColors.primaryAccentColor.withOpacity(0.8),
                  secondary: AppColors.primaryAccentColor),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.arrow_back_ios),
                                color: Colors.white,
                                onPressed: () => Navigator.pop(context)),
                            Text(
                              'Stats Overview',
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w500, color: Colors.white),
                              // style: TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 24.0,
                              //     fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: ScUtil().setWidth(40),
                            )
                          ],
                        ),
                        Container(
                          height: 50,
                          child: PreferredSize(
                            preferredSize: Size.fromHeight(kToolbarHeight),
                            child: TabBar(
                              tabs: [
                                // Tab(text: 'Daily'),
                                Tab(text: 'Weekly'),
                                Tab(text: 'Monthly'),
                              ],
                              isScrollable: true,
                              indicatorColor: Colors.white,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white,
                              labelStyle: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ScUtil().setHeight(20),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: TabBarView(
                          children: [
                            // DailyTab(),
                            // MonthlyTab(),
                            WeeklyTab(),
                            MonthlyTab(),
                            // GroupedFillColorBarChart.withSampleData(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DailyCalorieData {
  /// Holds the datapoint values like x, y, etc.,
  DailyCalorieData(this.x, this.y);

  /// X value of the data point
  final DateTime x;

  /// y value of the data point
  final dynamic y;
}
