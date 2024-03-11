import 'package:flutter/material.dart';
import 'package:customgauge/customgauge.dart';
import 'package:flutter_circular_text/circular_text.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/constants/routes.dart';

// ignore: must_be_immutable
class ScoreMeter extends StatefulWidget {
  double score;
  ScoreMeter({String data}) {
    score = double.tryParse(data);
  }

  @override
  _ScoreMeterState createState() => _ScoreMeterState();
}

class _ScoreMeterState extends State<ScoreMeter> {
  var s;

  void _initSp() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _initSp();
    //s = SpUtil.getBool('allAns', defValue: true);
    s = SpUtil.getBool('allAns');
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.height;
    double customRadius;
    if (w > 845) {
      w = 189;
      customRadius = 88;
    } else {
      w = 153;
      customRadius = 70;
    }
    // if (widget.score == null || widget.score == 0 || s == false) {
    if (widget.score == null || widget.score == 0) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          child: Stack(
            children: [
              Icon(
                Icons.help,
                color: Colors.white,
                size: 60,
              ),
              Positioned(
                  right: 2,
                  top: 6,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.red,
                  ))
            ],
          ),
          style: TextButton.styleFrom(
            textStyle: TextStyle(color: Colors.white),
            backgroundColor: AppColors.primaryAccentColor,
            shape: CircleBorder(),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Complete Health Assessment to get your IHL score !',
                    ),
                  ),
                  TextButton(
                      child: Text('Let\'s go'),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(Routes.Survey, arguments: false);
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: AppColors.primaryAccentColor,
                      ))
                ],
              ),
              duration: Duration(seconds: 5),
            ));
          },
        ),
      );
    }
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
          ),
          CustomGauge(
            gaugeSize: w,
            minValue: 0,
            maxValue: 800,
            segments: [
              GaugeSegment(
                'Low',
                200,
                Colors.red,
              ),
              GaugeSegment(
                'Slightly Low',
                200,
                Colors.deepOrangeAccent,
              ),
              GaugeSegment(
                'Correct',
                200,
                Colors.orange,
              ),
              GaugeSegment(
                'Excellent',
                200,
                Colors.green,
              ),
            ],
            needleColor: Colors.white,
            currentValue: widget.score,
            valueWidget: Container(
              child: Text(
                '\n' + widget.score.toInt().toString(),
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            displayWidget: Container(
              child: Text('\n\n'),
            ),
            showMarkers: false,
          ),
          Positioned(
            left: 5,
            top: 5,
            child: CircularText(
              radius: customRadius,
              children: [
                TextItem(
                  text: Text(
                    "Excellent",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  space: 7,
                  startAngle: 10,
                  startAngleAlignment: StartAngleAlignment.center,
                  direction: CircularTextDirection.clockwise,
                ),
                TextItem(
                  text: Text(
                    "V.Good",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  space: 8,
                  startAngle: -60,
                  startAngleAlignment: StartAngleAlignment.center,
                  direction: CircularTextDirection.clockwise,
                ),
                TextItem(
                  text: Text(
                    "Good",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  space: 8,
                  startAngle: -110,
                  startAngleAlignment: StartAngleAlignment.end,
                  direction: CircularTextDirection.clockwise,
                ),
                TextItem(
                  text: Text(
                    "Average",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  space: 8,
                  startAngle: -190,
                  startAngleAlignment: StartAngleAlignment.center,
                  direction: CircularTextDirection.clockwise,
                ),
              ],
              position: CircularTextPosition.inside,
            ),
          )
        ],
      ),
    );
  }
}
