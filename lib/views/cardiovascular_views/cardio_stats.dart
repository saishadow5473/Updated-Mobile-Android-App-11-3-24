import 'dart:convert';

import 'package:date_time_format/date_time_format.dart';
import 'package:expandable/expandable.dart';
// import 'package:flutter/material.dart';
// import 'package:ihl/models/vital_graph_helper.dart';
// import 'package:ihl/utils/commonUi.dart';
// import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/models/ecg_calculator.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/painters/backgroundPanter.dart';
// import 'package:ihl/constants/vitalUI.dart';
import 'package:ihl/utils/ScUtil.dart';
// import 'package:ihl/widgets/vitalScreen/vital_graph.dart';
// import 'package:ihl/widgets/vitalScreen/journal_entry.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/views/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../new_design/presentation/pages/home/landingPage.dart';

/// Vital screen 🎈🎈
class CardioGraphView extends StatefulWidget {
  final isGeneric;
  const CardioGraphView({this.isGeneric});
  // static const String id = 'vital_screen';
  @override
  _CardioGraphViewState createState() => _CardioGraphViewState();
}

class _CardioGraphViewState extends State<CardioGraphView> {
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    ///get heart health history -> (:
    try {
      getHeartHealthHistory();
    } catch (e) {
      if (mounted)
        setState(() {
          loadingHistory = false;
          noDataAvailable = true;
        });
    }
    // TODO: implement initState
    super.initState();
  }

  bool loadingHistory = true;
  bool noDataAvailable = false;
  String value;
  String status;
  String vitalType;
  List data;
  var color;
  String iHLUserId;

  getIhlUserId() async {
    final prefs = await SharedPreferences.getInstance();
    iHLUserId = prefs.getString('ihlUserId');
  }

  getHeartHealthHistory() async {
    await getIhlUserId();
    Map routeData = await retrieve_medical_data_API();
    value = routeData['value'].toString();
    status = routeData['status'];
    vitalType = routeData['vitalType'];
    data = routeData['data'];
    // color = cardTheme1['text'][data.last['status']];
    color = colorForStatus(status);
    color ??= Colors.blueAccent;
    if (mounted)
      setState(() {
        loadingHistory = false;
      });
  }

  @override
  Future<bool> willPopFunction() async {
    // Navigator.pushAndRemoveUntil(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => HomeScreen(
    //         introDone: true,
    //       ),
    //     ),
    //     (Route<dynamic> route) => false);
  }

  Widget build(BuildContext context) {
    // color = colorForStatus('Borderline');
    //Low
    //Intermediate
    //Borderline
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    // Map routeData = ModalRoute.of(context).settings.arguments;
    // Map routeData = {
    //   'vitalType': 'weightKG',
    //   'status': 'Overweight',
    //   'value': '88.45',
    //   'data': [
    //     {
    //       'value': '82',
    //       'status': 'Normal',
    //       'date': DateTime.now().subtract(Duration(days: 4)),
    //       // 'date': '2022-03-22 09:29:44.000Z',
    //       'moreData': {'Address': '2nd floor, 23rd cross st', 'City': 'Chennai'}
    //     },
    //     {
    //       'value': '88.45',
    //       'status': 'Overweight',
    //       'date': DateTime.now().subtract(Duration(days: 1)),
    //       'moreData': {'Address': '2nd floor, 23rd cross st', 'City': 'Chennai'}
    //     }
    //   ]
    // };
    // routeData = xyzabc;
    // print(xyzabc);
    // final String value = routeData['value'];
    // final String status = routeData['status'];
    // final String vitalType = routeData['vitalType'];
    // final List data = routeData['data'];
    // var color = cardTheme1['text'][data.last['status']];
    // color ??= Colors.blueAccent;
    scrolltoBottom(int pos) {
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        _scrollController.animateTo(_scrollController.offset + pos,
            duration: Duration(milliseconds: 100), curve: Curves.linear);
      });
    }

    return WillPopScope(
      onWillPop: willPopFunction,
      child: Scaffold(
          body: loadingHistory == false
              ? SafeArea(
                  child: !noDataAvailable
                      ? Container(
                          color: AppColors.bgColorTab,
                          child: CustomPaint(
                            painter: BackgroundPainter(
                                primary: color.withOpacity(0.8), secondary: color.withOpacity(0.0)),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: widget.isGeneric
                                            ? MainAxisAlignment.spaceBetween
                                            : MainAxisAlignment.center,
                                        children: <Widget>[
                                          Visibility(
                                            visible: widget.isGeneric,
                                            child: IconButton(
                                              icon: Icon(Icons.arrow_back_ios),
                                              onPressed: () => Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => LandingPage()
                                                      // HomeScreen(
                                                      //       introDone: true,
                                                      //     )
                                                      ),
                                                  (Route<dynamic> route) => false),
                                              color: Colors.white,
                                            ),
                                          ),
                                          // BackButton(
                                          //   color: Colors.white,
                                          // ),
                                          Text(
                                            diseaseUI[vitalType]['name'].length < 15
                                                ? diseaseUI[vitalType]['name']
                                                : diseaseUI[vitalType]['acr'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScUtil().setSp(30),
                                            ),
                                          ),
                                          Visibility(
                                            visible: widget.isGeneric,
                                            child: SizedBox(
                                              width: ScUtil().setWidth(30),
                                            ),
                                          )
                                        ],
                                      ),
                                      Text(
                                        diseaseUI[vitalType]['name'].length >= 15
                                            ? diseaseUI[vitalType]['name']
                                            : '',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: ScUtil().setSp(15),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              value.toString() + ' ' + diseaseUI[vitalType]['unit'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScUtil().setSp(25),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Hero(
                                              tag: vitalType + 'screen',
                                              child: Image.asset(diseaseUI[vitalType]['icon'],
                                                  height: ScUtil().setSp(30), color: Colors.white),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              //removed autosizetext it caused render issue
                                              status,
                                              maxLines: 4,
                                              textAlign: TextAlign.center,
                                              // maxFontSize: ScUtil().setSp(20),
                                              // minFontSize: ScUtil().setSp(15),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScUtil().setSp(20),
                                              ),
                                            ),
                                          ),
                                        ],
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: SingleChildScrollView(
                                          controller: _scrollController,
                                          child: Column(
                                            children: <Widget>[
                                              Card(
                                                elevation: 5,
                                                child: DiseasesGraph(
                                                  data: data,
                                                  isBP: vitalType == 'bp',
                                                ),
                                                color: FitnessAppTheme.white,
                                              ),
                                              SizedBox(
                                                height: ScUtil().setHeight(30),
                                              ),
                                              Card(
                                                elevation: 5,
                                                color: FitnessAppTheme.white,
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: color.withOpacity(0.8),
                                                        borderRadius: BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                      ),
                                                      padding: EdgeInsets.all(10),
                                                      margin: EdgeInsets.all(10),
                                                      child: Center(
                                                        child: diseaseUI[vitalType]['unit'] != ''
                                                            ? Column(
                                                                children: <Widget>[
                                                                  RichText(
                                                                    text: TextSpan(
                                                                      text: value.toString(),
                                                                      style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize:
                                                                              ScUtil().setSp(20)),
                                                                      children: <TextSpan>[
                                                                        TextSpan(
                                                                            text:
                                                                                '${diseaseUI[vitalType]['unit']} ',
                                                                            style: TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                                color: Colors.white,
                                                                                fontSize: ScUtil()
                                                                                    .setSp(13))),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Text(
                                                                value.toString(),
                                                                style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: ScUtil().setSp(60) /
                                                                        value.length),
                                                              ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceEvenly,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            RichText(
                                                              text: TextSpan(
                                                                text:
                                                                    'Your ${diseaseUI[vitalType]['name']} is ',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: CardColors.titleColor,
                                                                ),
                                                                children: <TextSpan>[
                                                                  TextSpan(
                                                                      text: "$value " +
                                                                          '${diseaseUI[vitalType]['unit']}.',
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: Colors.black,
                                                                          fontSize: 16)),
                                                                  TextSpan(
                                                                    text: '\nStatus:',
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.w800,
                                                                      color: CardColors.titleColor,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' $status',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Colors.black,
                                                                        fontSize: 16),
                                                                  ),
                                                                ],
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
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: ScUtil().setSp(20),
                                                    color: AppColors.lightTextColor,
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children: data.reversed.map((f) {
                                                  return DiseasesJornalEntry(
                                                      date: f['date'],
                                                      icon: diseaseUI[vitalType]['icon'],
                                                      statusColor: colorForStatus(f['status']),
                                                      //         [f['status']] ==
                                                      //     null
                                                      // ? Colors.blueAccent
                                                      // : cardTheme1['text']
                                                      //     [f['status']],
                                                      value: f['value'].toString(),
                                                      status: f['status'],
                                                      unit: diseaseUI[vitalType]['unit'],
                                                      data: f['moreData'],
                                                      bottom: scrolltoBottom,
                                                      ecgGraphData: f['graphECG']);
                                                }).toList(),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Text('Please Take the test first to see history and stats'),
                          ),
                        ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                )),
    );
  }

  colorForStatus(riskLevel) {
    var red = Color(0xffe35988);
    var green = Color(0xff70a649);
    var orange = Color(0xffd8c23f);
    var deepOrange = Color(0xffff9800);
    if (riskLevel == 'Low') {
      // return Colors.lightGreenAccent.shade400;
      return green; //Colors.lightGreenAccent.shade700.withOpacity(1.0);
    } else if (riskLevel == 'Borderline') {
      return orange.withOpacity(1); //Colors.yellow.shade600;
    } else if (riskLevel == 'Intermediate') {
      return deepOrange.withOpacity(1); //Colors.orange.shade200;
    } else if (riskLevel == 'High') {
      return red; //Colors.redAccent.shade400;
    }
  }

  retrieve_medical_data_API() async {
    calculateRiskLevel(score) async {
      score = double.parse(score.toString());
      var txt = score >= 20
          ? 'High'
          : score < 20 && score >= 7.5
              ? 'Intermediate'
              : score < 7.5 && score >= 5
                  ? 'Borderline'
                  : 'Low';
      // if (clr == Colors.yellow) {
      //   clr = await colorForStatus(txt);
      // }
      return txt;
    }

    genericDateTime(DateTime dateTime) {
      String str = dateTime.toString();
      var str1 = str.substring(0, str.indexOf(' '));
      var str2 = str.substring(str1.length + 1, str1.length + 6);
      // return DateTime.parse('$str1 00:00:00');
      var ss = str1 + " " + str2;
      print(ss);
      // return DateTime.parse('$str1 $str2'+':00');
      return '$str1 $str2' + ':00';
    }

    try {
      final response = await http.post(
        Uri.parse(API.iHLUrl + '/empcardiohealth/retrieve_medical_data'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"ihl_user_id": iHLUserId.toString()}),
      );
      if (response.statusCode == 200) {
        // if (true) {
        //   if (true) {
        if (response.body != 'null' && response.body != '') {
          var ress = jsonDecode(response.body);
          // var ress = [
          //   {
          //     "ihl_user_id": "abc_ihl",
          //     "Cholesterol": '319.0',
          //     "systolic_blood_pressure": '120.0',
          //     "diastolic_blood_pressure": '80.0',
          //     "gender": "female",
          //     "is_smoker": 'false',
          //     "has_family_history_diabetes": 'false',
          //     "has_family_history_hypertension": 'false',
          //     "score": '4',
          //     "created_date": DateTime.now().subtract(Duration(days: 5))
          //
          //   },
          //   {
          //     "ihl_user_id": "abc_ihl",
          //     "Cholesterol": '319.0',
          //     "systolic_blood_pressure": '120.0',
          //     "diastolic_blood_pressure": '80.0',
          //     "gender": "female",
          //     "is_smoker": 'false',
          //     "has_family_history_diabetes": 'false',
          //     "has_family_history_hypertension": 'false',
          //     "score": '20',
          //     "store_log_time": DateTime.now().subtract(Duration(days: 2))
          //   }
          // ];
          var latestData = ress[ress.length - 1];
          var mapData = [];
          ress.forEach((element) async {
            print(("${element['created_date']}"));
            mapData.add(
              {
                'value': '${element['score'].toString()}',
                'status': await calculateRiskLevel(element['score'].toString()),
                'date': DateTime.parse("${element['created_date']}"),
                'moreData': element
              },
            );
          });

          Map routeData = {
            'vitalType': 'Heart Health',
            'status': await calculateRiskLevel(latestData['score'].toString()),
            'value': '${latestData['score'].toString()}',
            'data': mapData
          };
          // routeData = xyzabc;
          // print(xyzabc);
          // final String value = routeData['value'];
          // final String status = routeData['status'];
          // final String vitalType = routeData['vitalType'];
          // final List data = routeData['data'];
          // var color = cardTheme1['text'][data.last['status']];
          // color ??= Colors.blueAccent;

          ///manipulate the data  here only then send -> Okay (:

          // return ress;
          return routeData;
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

Map diseaseUI = {
  // 'weightKG': {
  'Heart Health': {
    'acr': 'Heart Health',
    'name': 'Heart Health',
    'tip': 'the tip (:',
    'icon': 'assets/icons/ecg or pulse.png',
    'color': Color(0xff4097d9),
    'unit': '%'
  },
};

/// Vital graph, just pass map containing value and date👀
class DiseasesGraph extends StatefulWidget {
  DiseasesGraph({this.data, this.isBP});
  List data;
  bool isBP;
  @override
  _DiseasesGraphState createState() => _DiseasesGraphState();
}

class _DiseasesGraphState extends State<DiseasesGraph> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  DiseasesGraphClass _DiseasesGraphClass;
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
    _DiseasesGraphClass = DiseasesGraphClass(widget.data);
  }

  @override
  void didUpdateWidget(DiseasesGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    _DiseasesGraphClass = DiseasesGraphClass(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'My progress',
            style: TextStyle(color: CardColors.titleColor, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(18),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 40, bottom: 40),
            child: Container(
                child: SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: widget.isBP == true
                  ? _DiseasesGraphClass.createBPChart(timeToDuration[time])
                  : _DiseasesGraphClass.createChart(timeToDuration[time]),
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

class DiseasesGraphClass {
  static final List<Color> gradientColors = AppColors.graphGradient1;
  static final List<Color> gradientColors2 = AppColors.graphGradient2;
  List data;
  static final DateTime today = DateTime.now();
  List<FlSpot> currentlyShowing;
  List<FlSpot> currentlyShowingSys;
  List<FlSpot> currentlyShowingDias;
  int currentLength;

  /// minimum plotted y value -10 ⏬
  double minY;

  /// maximum plotted y value +10 ⏫
  double maxY;
  static final Widget noData = Center(
    child: Container(
      // color: Colors.red,
      child: Text(
        AppTexts.graphNoData,
        // textAlign: TextAlign.center,
      ),
    ),
  );
  //constructor
  DiseasesGraphClass(
    List li,
  ) {
    data = li;
  }

  /// returns a chart widget for given time offset (only for BP graph)
  Widget createBPChart(Duration offset) {
    if (offset == null) {
      var currentlyShowingDiasSys = createBPAllSpots(data);
      currentlyShowingDias = currentlyShowingDiasSys[0];
      currentlyShowingSys = currentlyShowingDiasSys[1];
      currentLength = currentlyShowingSys.length;
      if (currentLength < 2 || currentlyShowingDias == null) {
        return noData;
      }
      return LineChart(_showChart([
        lineChartBarDataFier(currentlyShowingDias, gradientColors),
        lineChartBarDataFier(currentlyShowingSys, gradientColors2)
      ]));
    }

    var currentlyShowingDiasSys = createBPDurationSpots(data, offset);
    currentlyShowingDias = currentlyShowingDiasSys[0];
    currentlyShowingSys = currentlyShowingDiasSys[1];
    currentLength = currentlyShowingSys.length;
    if (currentLength < 2 || currentlyShowingDias == null) {
      return noData;
    }
    return LineChart(_showChart([
      lineChartBarDataFier(currentlyShowingDias, gradientColors),
      lineChartBarDataFier(currentlyShowingSys, gradientColors2)
    ]));
  }

  Widget createChart(Duration offset) {
    if (offset == null) {
      currentlyShowing = createAllSpots(data);
      currentLength = currentlyShowing.length;
      if (currentLength < 2 || currentlyShowing == null) {
        return noData;
      }
      return LineChart(_showChart([lineChartBarDataFier(currentlyShowing, gradientColors)]));
    }
    currentlyShowing = createDurationSpots(data, offset);
    currentLength = currentlyShowing.length;
    if (currentLength < 2 || currentlyShowing == null) {
      return noData;
    }
    return LineChart(_showChart([lineChartBarDataFier(currentlyShowing, gradientColors)]));
  }

  List<List<FlSpot>> createBPDurationSpots(List toMap, Duration offSet) {
    DateTime offSetDate = today.subtract(offSet);

    List<FlSpot> toSendSys = [];
    List<FlSpot> toSendDys = [];
    DateTime dateCurrentIt;
    for (int i = 0; i < toMap.length; i++) {
      if (toMap[i]['date'] != null &&
          dateCurrentIt != toMap[i]['date'] &&
          toMap[i]['date'].isAfter(offSetDate)) {
        dateCurrentIt = toMap[i]['date'];

        if (toMap[i]['moreData']['Systolic'] != null &&
            i != null &&
            toMap[i]['moreData']['Systolic'] != '') {
          double doubleToAdd;
          if (toMap[i]['moreData']['Systolic'] is double) {
            doubleToAdd = toMap[i]['moreData']['Systolic'];
          }
          if (toMap[i]['moreData']['Systolic'] is int) {
            doubleToAdd = toMap[i]['moreData']['Systolic'].toDouble();
          }
          if (toMap[i]['moreData']['Systolic'] is String) {
            doubleToAdd = double.parse(toMap[i]['moreData']['Systolic']);
          }
          if (doubleToAdd != null) {
            toSendSys.add(FlSpot(
              i.toDouble(),
              doubleToAdd,
            ));
            minY ??= doubleToAdd;
            maxY ??= doubleToAdd;
            minY = minY > doubleToAdd ? doubleToAdd : minY;
            maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
          }
          doubleToAdd = null;
          if (toMap[i]['moreData']['Diastolic'] is double) {
            doubleToAdd = toMap[i]['moreData']['Diastolic'];
          }
          if (toMap[i]['moreData']['Diastolic'] is int) {
            doubleToAdd = toMap[i]['moreData']['Diastolic'].toDouble();
          }
          if (toMap[i]['moreData']['Diastolic'] is String) {
            doubleToAdd = double.parse(toMap[i]['moreData']['Diastolic']);
          }
          if (doubleToAdd != null) {
            toSendDys.add(FlSpot(
              i.toDouble(),
              doubleToAdd,
            ));
            minY ??= doubleToAdd;
            maxY ??= doubleToAdd;
            minY = minY > doubleToAdd ? doubleToAdd : minY;
            maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
          }
        }
      }
    }

    return [toSendDys, toSendSys];
  }

//create duration spots
  List<FlSpot> createDurationSpots(List toMap, Duration offSet) {
    DateTime offSetDate = today.subtract(offSet);
    DateTime dateCurrentIt;

    List<FlSpot> toSend = [];
    for (int i = 0; i < toMap.length; i++) {
      if (toMap[i]['date'] != null &&
          dateCurrentIt != toMap[i]['date'] &&
          toMap[i]['date'].isAfter(offSetDate)) {
        double doubleToAdd;
        dateCurrentIt = toMap[i]['date'];
        if (toMap[i]['value'] is double) {
          doubleToAdd = toMap[i]['value'];
        }
        if (toMap[i]['value'] is int) {
          doubleToAdd = toMap[i]['value'].toDouble();
        }
        if (toMap[i]['value'] is String) {
          doubleToAdd = double.parse(toMap[i]['value']);
        }
        if (doubleToAdd != null) {
          toSend.add(FlSpot(
            i.toDouble(),
            doubleToAdd,
          ));
          minY ??= doubleToAdd;
          maxY ??= doubleToAdd;
          minY = minY > doubleToAdd ? doubleToAdd : minY;
          maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
        }
      }
    }
    return toSend;
  }

  LineChartBarData lineChartBarDataFier(List<FlSpot> spot, List<Color> grad) {
    return LineChartBarData(
      spots: spot,
      colors: [AppColors.primaryAccentColor],
      barWidth: 1,
      isCurved: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: true,
        colors: grad.map((color) => color.withOpacity(0.3)).toList(),
      ),
    );
  }

  //Create FL spots
  List<FlSpot> createAllSpots(List toMap) {
    List<FlSpot> toSend = [];
    DateTime dateCurrentIt;
    for (int i = 0; i < toMap.length; i++) {
      if (dateCurrentIt != toMap[i]['date'] &&
          toMap[i]['value'] != null &&
          i != null &&
          toMap[i]['value'] != '') {
        dateCurrentIt = toMap[i]['date'];
        double doubleToAdd;
        if (toMap[i]['value'] == 'NaN') {
          toMap[i]['value'] = 0.0;
        }
        if (toMap[i]['value'] is double) {
          doubleToAdd = toMap[i]['value'];
        }
        if (toMap[i]['value'] is int) {
          doubleToAdd = toMap[i]['value'].toDouble();
        }
        if (toMap[i]['value'] is String) {
          doubleToAdd = double.parse(toMap[i]['value']);
        }
        if (doubleToAdd != null) {
          toSend.add(FlSpot(
            i.toDouble(),
            doubleToAdd,
          ));
          minY ??= doubleToAdd;
          maxY ??= doubleToAdd;
          minY = minY > doubleToAdd ? doubleToAdd : minY;
          maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
        }
      }
    }
    return toSend;
  }

  List<List<FlSpot>> createBPAllSpots(List toMap) {
    List<FlSpot> toSendSys = [];
    List<FlSpot> toSendDys = [];
    DateTime dateCurrentIt;
    for (int i = 0; i < toMap.length; i++) {
      if (dateCurrentIt != toMap[i]['date'] &&
          toMap[i]['moreData']['Systolic'] != null &&
          i != null &&
          toMap[i]['moreData']['Systolic'] != '') {
        double doubleToAdd;
        dateCurrentIt = toMap[i]['date'];
        if (toMap[i]['moreData']['Systolic'] is double) {
          doubleToAdd = toMap[i]['moreData']['Systolic'];
        }
        if (toMap[i]['moreData']['Systolic'] is int) {
          doubleToAdd = toMap[i]['moreData']['Systolic'].toDouble();
        }
        if (toMap[i]['moreData']['Systolic'] is String) {
          doubleToAdd = double.parse(toMap[i]['moreData']['Systolic']);
        }
        if (doubleToAdd != null) {
          toSendSys.add(FlSpot(
            i.toDouble(),
            doubleToAdd,
          ));
          minY ??= doubleToAdd;
          maxY ??= doubleToAdd;
          minY = minY > doubleToAdd ? doubleToAdd : minY;
          maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
        }
        doubleToAdd = null;
        if (toMap[i]['moreData']['Diastolic'] is double) {
          doubleToAdd = toMap[i]['moreData']['Diastolic'];
        }
        if (toMap[i]['moreData']['Diastolic'] is int) {
          doubleToAdd = toMap[i]['moreData']['Diastolic'].toDouble();
        }
        if (toMap[i]['moreData']['Diastolic'] is String) {
          doubleToAdd = double.parse(toMap[i]['moreData']['Diastolic']);
        }
        if (doubleToAdd != null) {
          toSendDys.add(FlSpot(
            i.toDouble(),
            doubleToAdd,
          ));
          minY ??= doubleToAdd;
          maxY ??= doubleToAdd;
          minY = minY > doubleToAdd ? doubleToAdd : minY;
          maxY = maxY < doubleToAdd ? doubleToAdd : maxY;
        }
      }
    }

    return [toSendDys, toSendSys];
  }

  LineChartData _showChart(List<LineChartBarData> listOfData) {
    return LineChartData(
      minY: minY == null ? 0 : minY - 10,
      maxY: !(maxY == null) ? maxY + 10 : null,
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 0,
          rotateAngle: 0,
          interval: listOfData[0].spots.length < 5 ? 1 : listOfData[0].spots.length / 5,
          getTextStyles: (_, value) {
            return const TextStyle(
                color: Color(0xff68737d), fontWeight: FontWeight.bold, fontSize: 10);
          },
          getTitles: (value) {
            DateTime date = data[value.toInt()]['date'];
            List month = [
              '',
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec'
            ];
            int year = date.year;
            if (year < 2000) {
              year = year - 1900;
            } else {
              year = year - 2000;
            }
            return month[date.month] + '/' + year.toString();
          },
          margin: 5,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (_, val) {
            return const TextStyle(
              color: Color(0xff67727d),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            );
          },
          interval: (maxY + 20 - minY) / 4,
          getTitles: (value) {
            return value.toInt().toString();
          },
          reservedSize: 22,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 2,
          ),
          left: BorderSide(
            color: Color(0xff4e4965),
            width: 2,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      lineBarsData: listOfData,
    );
  }
}

/// create table of more data
Widget tableBuilder({Map data}) {
  print(data);
  // data.removeWhere((key, value) =>
  //     key == 'ihl_user_id' || key == 'gender' || key == 'store_log_time');
  Map copyData = {};
  data.forEach((key, value) {
    if (key == 'Cholesterol') copyData['Cholesterol'] = value;
    if (key == 'systolic_blood_pressure') copyData['Systolic B P'] = value;
    if (key == 'diastolic_blood_pressure') copyData['Diastolic B P'] = value;
    if (key == 'is_smoker') copyData['Smoker ?'] = value.toString() == 'false' ? 'No' : 'Yes';
    if (key == 'has_family_history_diabetes')
      copyData['History of Diabetes?'] = value.toString() == 'false' ? 'No' : 'Yes';
    if (key == 'has_family_history_hypertension')
      copyData['On Hypertension\nTreatment?'] = value.toString() == 'false' ? 'No' : 'Yes';
    if (key == 'score') copyData['Score'] = value;
  });
  if (data.keys.contains('Cholesterol')) data = copyData;
  List<DataRow> rows = [];
  data.forEach((k, v) {
    rows.add(
      DataRow(cells: [
        DataCell(
          Text(
            k.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(v.toString()),
        )
      ]),
    );
  });
  return Center(
    child: Row(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                rows: rows,
                columns: [
                  DataColumn(
                    label: Text('More info'),
                  ),
                  DataColumn(
                    label: Text(''),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// single vital entry
class DiseasesJornalEntry extends StatelessWidget {
  final String icon;
  final DateTime date;
  final String value;
  final String unit;
  final status;
  final statusColor;
  final Map data;
  final ECGCalc ecgGraphData;
  final Function bottom;
  final key = GlobalKey();
  DiseasesJornalEntry({
    this.value,
    this.date,
    this.icon,
    this.status,
    this.unit,
    this.data,
    this.statusColor,
    this.ecgGraphData,
    this.bottom,
  });
  ExpandableController _controller = ExpandableController();

  @override
  Widget build(BuildContext context) {
    String dateToShow = 'N/A';
    String valueToShow = value == 'N/A' ? 'N/A' : value + ' ' + unit;
    if (date != null) {
      dateToShow = DateTimeFormat.relative(date) + ' ago';
    }
    return Column(
      children: <Widget>[
        //ignore: missing_required_param
        ExpandablePanel(
          controller: _controller,
          theme: ExpandableThemeData(
            animationDuration: Duration(milliseconds: 50),
            hasIcon: false,
            useInkWell: true,
            tapBodyToCollapse: true,
          ),
          header: ListTile(
            onTap: () {
              _controller.toggle();
              if (_controller.expanded) {
                bottom(200);
              }
            },
            leading: Image.asset(
              icon,
              color: statusColor,
              height: 30,
            ),
            trailing: Text(
              valueToShow,
              style: TextStyle(
                  color: statusColor,
                  // fontWeight: FontWeight.w800,
                  fontSize: 20),
            ),
            title: Text(
              dateToShow,
              style: TextStyle(
                fontSize: 20,
                color: Color(0xff6d6e71),
              ),
            ),
          ),
          expanded: Container(
            color: Colors.grey[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  DateTimeFormat.format(date, format: DateTimeFormats.american),
                ),
                Text(status),
                tableBuilder(data: data),
                ecgGraphData == null
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: TextButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'View ECG ',
                                style: TextStyle(color: Colors.white),
                              ),
                              Hero(
                                tag: date,
                                child: Icon(
                                  Icons.show_chart,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              'ECG_graph_screen',
                              arguments: {
                                'ecgGraphData': ecgGraphData,
                                'appBarData': {
                                  'color': statusColor,
                                  'value': value,
                                  'status': status,
                                  'date': dateToShow,
                                },
                                'hero': date
                              },
                            );
                          },
                          style: TextButton.styleFrom(backgroundColor: Colors.blue),
                        ),
                      )
              ],
            ),
          ),
        ),
        Divider(
          color: AppColors.dividerColor,
          height: 5,
        )
      ],
    );
  }
}
