// import 'package:flutter/material.dart';
// import 'package:fit_kit/fit_kit.dart';
// import 'package:flutter_circular_chart/flutter_circular_chart.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:ihl/utils/fitkit_util.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class FitViewScreen extends StatefulWidget {
//   @override
//   _FitViewState createState() => _FitViewState();
// }

// class _FitViewState extends State<FitViewScreen> {
//   GlobalKey<AnimatedCircularChartState> _chartKey =
//       GlobalKey<AnimatedCircularChartState>();

//   int steps = 0;
//   int val = 0;
//   int calories = 0;
//   double distance = 0.0;

//   void dailyChanges() async {
//     var dailyData = await FitKitHelper.getDailyData();
//     print(dailyData);
//     setState(() {
//       calories = dailyData.calories.toInt();
//       distance = (dailyData.distance / 1000).toDouble();
//     });
//   }

//   void readEnergy() async {
//     //collection of data over the last 5 days
//     final stepResults = await FitKitHelper.getStepCount(days: 5);
//     final energyResults = await FitKitHelper.getEnergy(days: 5);
//     final distanceResults = await FitKitHelper.getDistance(days: 5);
//     List<CircularStackEntry> nextData = <CircularStackEntry>[
//       CircularStackEntry(
//         <CircularSegmentEntry>[
//           //only taking the first of the many results
//           CircularSegmentEntry((1113.0), Colors.blue[700], rankKey: 'Q1'),
//           CircularSegmentEntry(
//               2000 - (1113.0), Colors.blue[100], //out of 2000 calories target
//               rankKey: 'Q2'),
//         ],
//       ),
//       CircularStackEntry(
//         <CircularSegmentEntry>[
//           //only taking the fifth result
//           CircularSegmentEntry(300.0, Colors.greenAccent[700], rankKey: 'Q1'),
//           CircularSegmentEntry(
//               1000 - 300.0, Colors.greenAccent[100], //out of 200 steps target
//               rankKey: 'Q2'),
//         ],
//       ),
//     ];
//     print(stepResults);
//     setState(() {
//       //steps = stepResults.value.toInt();
//       calories = (energyResults.value / 100000).toInt();
//       distance = (distanceResults.value / 100).toDouble();
//       _chartKey.currentState.updateData(nextData);
//     });
//   }

//   @override
//   void initState() {
//     readEnergy();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('IHL Fitness'),
//         centerTitle: true,
//         brightness: Brightness.dark,
//         actions: [
//           IconButton(
//             onPressed: () async => await FitKitHelper.revokeFit(),
//             icon: Icon(Icons.disabled_by_default),
//           ),
//           IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(Icons.more_horiz),
//           ),
//         ],
//       ),
//       body: StreamBuilder(
//           stream: FitKit.stepsCount,
//           builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//             if (!snapshot.hasData) {
//               print(snapshot.data);
//               return Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.connectionState == ConnectionState.done) {
//               print('done');
//             }
//             //dailyChanges();
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 Container(
//                   height: 100,
//                   margin: EdgeInsets.only(top: 80),
//                   child: AnimatedCircularChart(
//                     edgeStyle: SegmentEdgeStyle.round,
//                     holeLabel: 'Today\n${snapshot.data['steps']}/\n5000',
//                     labelStyle: TextStyle(
//                       color: Colors.blue,
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     key: _chartKey,
//                     duration: Duration(seconds: 2),
//                     initialChartData: <CircularStackEntry>[
//                       CircularStackEntry(
//                         <CircularSegmentEntry>[
//                           CircularSegmentEntry(
//                             0,
//                             Colors.blue,
//                           ),
//                           CircularSegmentEntry(
//                             100,
//                             Colors.grey,
//                           )
//                         ],
//                       ),
//                     ],
//                     size: Size(250, 250),
//                   ),
//                 ),
//                 SizedBox(height: 80),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: <Widget>[
//                     Row(
//                       children: [
//                         Icon(
//                           FontAwesomeIcons.fire,
//                           color: Colors.green,
//                         ),
//                         SizedBox(
//                           width: 2,
//                         ),
//                         Text(
//                           "Calories",
//                           style: TextStyle(color: Colors.green),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Icon(
//                           FontAwesomeIcons.walking,
//                           color: Colors.blue,
//                         ),
//                         SizedBox(
//                           width: 2,
//                         ),
//                         Text(
//                           "Steps",
//                           style: TextStyle(color: Colors.blue),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 40),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: <Widget>[
//                     Text(
//                       'Calories Burned\n ${snapshot.data['calories'].toInt()} Cal',
//                       textAlign: TextAlign.center,
//                     ),
//                     Text(
//                       'Steps Walked\n${snapshot.data['steps']}',
//                       textAlign: TextAlign.center,
//                     ),
//                     Text(
//                       'Distance Walked\n${((snapshot.data['distance']) / 1000).toStringAsFixed(2)} Kms',
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 //_buildDefaultRadialBarChart(snapshot.data['steps'])
//               ],
//             );
//           }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           readEnergy();
//         },
//         child: Icon(Icons.replay_sharp),
//       ),
//     );
//   }

//   SfCircularChart _buildDefaultRadialBarChart(int step) {
//     return SfCircularChart(
//       key: GlobalKey(),
//       title: ChartTitle(text: 'Shot put distance'),
//       series: _getRadialBarDefaultSeries(step),
//       tooltipBehavior:
//           TooltipBehavior(enable: true, format: 'point.x : point.y'),
//     );
//   }

//   /// Returns default radial series.
//   List<RadialBarSeries<ChartSampleData, String>> _getRadialBarDefaultSeries(
//       int step) {
//     List<ChartSampleData> chartData = <ChartSampleData>[
//       ChartSampleData(
//           x: 'Steps',
//           y: step,
//           text: '100%',
//           pointColor: const Color.fromRGBO(248, 177, 149, 1.0)),
//       ChartSampleData(
//           x: 'Runs',
//           y: 2000,
//           text: '100%',
//           pointColor: const Color.fromRGBO(248, 177, 149, 1.0)),
//     ];
//     return <RadialBarSeries<ChartSampleData, String>>[
//       RadialBarSeries<ChartSampleData, String>(
//           maximumValue: 3000,
//           dataLabelSettings: const DataLabelSettings(
//               isVisible: true, textStyle: TextStyle(fontSize: 10.0)),
//           dataSource: chartData,
//           cornerStyle: CornerStyle.bothCurve,
//           gap: '10%',
//           radius: '90%',
//           xValueMapper: (ChartSampleData data, _) => data.x as String,
//           yValueMapper: (ChartSampleData data, _) => data.y,
//           pointRadiusMapper: (ChartSampleData data, _) => data.text,
//           pointColorMapper: (ChartSampleData data, _) => data.pointColor,
//           dataLabelMapper: (ChartSampleData data, _) => data.x as String)
//     ];
//   }
// }

// ///Chart sample data
// class ChartSampleData {
//   /// Holds the datapoint values like x, y, etc.,
//   ChartSampleData(
//       {this.x,
//       this.y,
//       this.xValue,
//       this.yValue,
//       this.secondSeriesYValue,
//       this.thirdSeriesYValue,
//       this.pointColor,
//       this.size,
//       this.text,
//       this.open,
//       this.close,
//       this.low,
//       this.high,
//       this.volume});

//   /// Holds x value of the datapoint
//   final dynamic x;

//   /// Holds y value of the datapoint
//   final num y;

//   /// Holds x value of the datapoint
//   final dynamic xValue;

//   /// Holds y value of the datapoint
//   final num yValue;

//   /// Holds y value of the datapoint(for 2nd series)
//   final num secondSeriesYValue;

//   /// Holds y value of the datapoint(for 3nd series)
//   final num thirdSeriesYValue;

//   /// Holds point color of the datapoint
//   final Color pointColor;

//   /// Holds size of the datapoint
//   final num size;

//   /// Holds datalabel/text value mapper of the datapoint
//   final String text;

//   /// Holds open value of the datapoint
//   final num open;

//   /// Holds close value of the datapoint
//   final num close;

//   /// Holds low value of the datapoint
//   final num low;

//   /// Holds high value of the datapoint
//   final num high;

//   /// Holds open value of the datapoint
//   final num volume;
// }
