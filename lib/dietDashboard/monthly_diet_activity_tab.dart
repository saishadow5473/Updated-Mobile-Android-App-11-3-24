import 'package:flutter/material.dart';
import './bar_chart_weekly.dart';

class MonthlyDietActivityTab extends StatefulWidget {
  // const MonthlyDietActivityTab({ Key key }) : super(key: key);

  @override
  _MonthlyDietActivityTabState createState() => _MonthlyDietActivityTabState();
}

class _MonthlyDietActivityTabState extends State<MonthlyDietActivityTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: const Color(0xff132240),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChartSample2(),
        ),
      ),
    );
  }
}
