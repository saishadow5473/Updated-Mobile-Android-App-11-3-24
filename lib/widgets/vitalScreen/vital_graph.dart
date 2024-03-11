import 'package:flutter/material.dart';
import 'package:ihl/models/vital_graph_helper.dart';
import 'package:ihl/utils/commonUi.dart';

/// Vital graph, just pass map containing value and date👀
class VitalGraph extends StatefulWidget {
  VitalGraph({this.data, this.isBP});
  List data;
  bool isBP;
  @override
  _VitalGraphState createState() => _VitalGraphState();
}

class _VitalGraphState extends State<VitalGraph> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  VitalGraphClass _vitalGraphClass;
  Duration offset;
  String time = 'all';
  final Map<String, Duration> timeToDuration = {
    'all': null,
    'last week': Duration(days: 7),
    'last month': Duration(days: 30),
    'last 3 months': Duration(days: 90),
    'last 6 months': Duration(days: 180),
    'last year': Duration(days: 365),
  };
  @override
  void initState() {
    super.initState();
    _vitalGraphClass = VitalGraphClass(widget.data);
  }

  @override
  void didUpdateWidget(VitalGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    _vitalGraphClass = VitalGraphClass(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'My progress',
            style: TextStyle(
                color: CardColors.titleColor, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(18),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                right: 18.0, left: 12.0, top: 40, bottom: 40),
            child: Container(
                child: SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: widget.isBP == true
                  ? _vitalGraphClass.createBPChart(timeToDuration[time])
                  : _vitalGraphClass.createChart(timeToDuration[time]),
            )),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            DropdownButton(
              hint: Container(
                color: Colors.white,
                child: Text(time),
              ),
              value: time,
              items: [
                DropdownMenuItem(
                  child: Text('Last week'),
                  value: 'last week',
                ),
                DropdownMenuItem(
                  child: Text('Last month'),
                  value: 'last month',
                ),
                DropdownMenuItem(
                  child: Text('last 3 months'),
                  value: 'last 3 months',
                ),
                DropdownMenuItem(
                  child: Text('Last 6 months'),
                  value: 'last 6 months',
                ),
                DropdownMenuItem(
                  child: Text('Last 1 year'),
                  value: 'last year',
                ),
                DropdownMenuItem(
                  child: Text('All'),
                  value: 'all',
                ),
              ],
              elevation: 4,
              onChanged: (value) {
                time = value;
                if (this.mounted) {
                  setState(() {});
                }
              },
            )
          ],
        ),
      ],
    );
  }
}
