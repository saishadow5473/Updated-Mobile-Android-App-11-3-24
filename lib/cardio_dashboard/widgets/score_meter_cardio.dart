// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// ignore: must_be_immutable
class ScoreMeterCardio extends StatelessWidget {
  double value;
  ScoreMeterCardio({
    Key key,
    @required this.value,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        animationDuration: 3000,
        axes: <RadialAxis>[
          RadialAxis(
              showLabels: false,
              showTicks: false,
              minimum: 0,
              maximum: 30,
              startAngle: 150,
              endAngle: 30,
              ranges: <GaugeRange>[
                GaugeRange(
                    startValue: 0,
                    endValue: 4.9,
                    color: Colors.yellow,
                    startWidth: 10,
                    endWidth: 10),
                GaugeRange(
                    startValue: 5,
                    endValue: 7.4,
                    color: Colors.green,
                    startWidth: 10,
                    endWidth: 10),
                GaugeRange(
                    startValue: 7.5,
                    endValue: 20,
                    color: Colors.orangeAccent,
                    startWidth: 10,
                    endWidth: 10),
                GaugeRange(
                    startValue: 20, endValue: 30, color: Colors.red, startWidth: 10, endWidth: 10)
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: value,
                  needleLength: 0.55,
                  lengthUnit: GaugeSizeUnit.factor,
                  needleStartWidth: 1,
                  needleEndWidth: 1,
                )
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    widget: Container(
                        child: Text(value.toString(),
                            style: TextStyle(
                                letterSpacing: 1,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue))),
                    angle: 90,
                    positionFactor: 1)
              ])
        ],
      ),
    );
  }
}
