import 'package:ihl/utils/commonUi.dart';
import 'package:flutter/services.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ihl/models/ecg_calculator.dart';
import 'package:ihl/widgets/vitalScreen/HorizontalECG.dart';
import 'package:ihl/painters/backgroundPanter.dart';

class ECGGraphScreen extends StatefulWidget {
  static String id = 'ECG_graph_screen';
  ECGGraphScreen({Key key, @required this.ecgValue}) : super(key: key);
  @override
  final Map ecgValue;
  _ECGGraphScreenState createState() => _ECGGraphScreenState();
}

class _ECGGraphScreenState extends State<ECGGraphScreen> {
  Map map;
  String string;

  bool showing = false;
  Future<bool> time(int delay) async {
    return Future.delayed(Duration(seconds: delay), () => true);
  }

  Widget createFullScreen(Map map, String string) {
    if (!showing) {
      return Container();
    }
    return FutureBuilder(
      future: time(2),
      initialData: false,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return SafeArea(
          child: Scaffold(
            body: Center(
              child: snapshot.data == false
                  ? CircularProgressIndicator()
                  : RotatedBox(
                      quarterTurns: 1,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: Card(
                          color: AppColors.bgColorTab,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        string + ':',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: CardColors.titleColor),
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: TextButton(
                                          child: Icon(Icons.fullscreen_exit),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.all(0),
                                          ),
                                          onPressed: () {
                                            showing = false;
                                            if (this.mounted) {
                                              setState(() {});
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height / 4,
                                  width: MediaQuery.of(context).size.height,
                                  child: HorizontalECGGraph(
                                    ecg: map[string],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map routeData = widget.ecgValue;
    ECGCalc ecg = routeData['ecgGraphData'];
    Map values = ecg.getMap();
    Color color = routeData['appBarData']['color'];
    String value = routeData['appBarData']['value'];
    String status = routeData['appBarData']['status'];
    String date = routeData['appBarData']['date'];
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

        if (showing == true) {
          showing = false;
          if (this.mounted) {
            setState(() {});
          }
          return false;
        }
        return true;
      },
      child: Stack(
        children: [
          Scaffold(
            body: SafeArea(
              child: Container(
                color: AppColors.bgColorTab,
                child: CustomPaint(
                  painter: BackgroundPainter(primary: color.withOpacity(0.8), secondary: color),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                BackButton(
                                  color: Colors.white,
                                ),
                                Text(
                                  'ECG graphs',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: (30),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                )
                              ],
                            ),
                            Text(
                              date,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 15,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Center(
                                    child: Text(
                                      value.toString() + ' ' + 'bpm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: (25),
                                      ),
                                    ),
                                  ),
                                ),
                                Hero(
                                  tag: routeData['hero'],
                                  child: Icon(
                                    Icons.show_chart,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Center(
                                    child: Text(
                                      status,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: (20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.appBackgroundColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ListView.builder(
                                itemCount: values.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String key = values.keys.elementAt(index);
                                  return Column(
                                    children: <Widget>[
                                      Card(
                                        color: AppColors.bgColorTab,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 10),
                                                  child: Text(
                                                    key.toString() + ':',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.appTextColor),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 40,
                                                  child: TextButton(
                                                    child: Icon(Icons.fullscreen),
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.all(0),
                                                    ),
                                                    onPressed: () {
                                                      showing = true;
                                                      string = key;
                                                      map = values;
                                                      if (this.mounted) {
                                                        setState(() {});
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: (MediaQuery.of(context).size.width) * 4 / 30,
                                              width: MediaQuery.of(context).size.width,
                                              child: HorizontalECGGraph(
                                                ecg: values[key],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          createFullScreen(map, string)
        ],
      ),
    );
  }
}
