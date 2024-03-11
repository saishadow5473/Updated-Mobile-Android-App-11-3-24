import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/new_design/presentation/pages/manageHealthscreens/manageHealthScreentabs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/utils/constLists.dart';
import '../../../../app/utils/appColors.dart';
import '../../../../data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../../../data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';
import '../../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import '../../myVitals/myVitalsDashBoard.dart';
import 'myVitalsApi.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:strings/strings.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../../constants/vitalUI.dart';
import '../../../../../models/ecg_calculator.dart';

// import '../../../../../utils/app_colors.dart';
import '../../../../../views/vital_screen.dart';
import '../../../Widgets/vitals/myVitalWidgets.dart';
import '../../../clippath/subscriptionTagClipPath.dart';
import 'ECG_line_Screen.dart';

class PlotterPoints {
  DateTime x;
  String y;

  PlotterPoints(this.x, this.y);
}

// ignore: must_be_immutable
class MyVitalGraphScreen extends StatefulWidget {
  MyVitalGraphScreen({Key key, this.data, this.navPath}) : super(key: key);
  Map data;
  final navPath;

  @override
  State<MyVitalGraphScreen> createState() => _MyVitalGraphScreenState();
}

class _MyVitalGraphScreenState extends State<MyVitalGraphScreen> {
  ValueNotifier<String> selectedType = ValueNotifier("Last 7 days");
  ValueNotifier<bool> arrow = ValueNotifier(false);
  List<String> types = ["Last 7 days", "Weekly", "Monthly"];
  List<PlotterPoints> plotter = [];
  List<dynamic> mapData = [];
  bool showShimmer = true;
  int forward = 0;
  final TabBarController _tabController = Get.find<TabBarController>();

  @override
  void initState() {
    listenVitals.value = true;
    // getPoints();
    // mapData = widget.data["data"];
    getInitialData();
    //  MyvitalsGraphData().getVitalsdata();
    // NewMyVitalGraph().datas = widget.data["data"];
    selectedType.addListener(() {
      NewMyVitalGraph.selectedTypeinGraph = selectedType.value;
    });
    super.initState();
  }

  shimmerFunciton() {
    // NewMyVitalGraph.loader = true;
    selectedType.notifyListeners();
    Timer(const Duration(milliseconds: 700), () {
      NewMyVitalGraph.loader = false;
      selectedType.notifyListeners();
    });
  }

  // final Map<String, Duration> timeToDuration = {
  //   'Last 7 days': Duration(days: 2000),
  //   'Weekly': Duration(days: 2000),
  //   'Monthly': Duration(days: 2000),
  // 'last 3 months': Duration(days: 90),
  // 'last 6 months': Duration(days: 180),
  // 'last year': Duration(days: 365),
  // };

  void updateAllvitalData() async {
    var response1 = await SplashScreenApiCalls().loginApi();
    if (response1 != null) {
      var resjd = response1;
      String encodedValue = jsonEncode(response1);
      if (encodedValue == 'null' ||
          encodedValue == null ||
          resjd == "Object reference not set to an instance of an object." ||
          encodedValue == "Object reference not set to an instance of an object.") {
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(SPKeys.userData, jsonEncode(response1));
        await MyvitalsApi().vitalDatas(response1);
      }
    }
  }

  List<dynamic> yearlyValue = [];
  ValueNotifier<String> vitalValueRecent = ValueNotifier<String>("");
  ValueNotifier<String> vitalStatusRecent = ValueNotifier<String>("");
  //String vitalValueRecent;
  void getInitialData() async {
    try {
      updateAllvitalData();
    } catch (e) {
      print(e);
    }
    NewMyVitalGraph.loader = true;
    firstDayString = firstDayofLastSevendays.toString();
    lastDayString = seventhDayofLastSevendays.toString();
    selectedType.notifyListeners();
    yearlyValue = await MyvitalsGraphData().getVitalsdata(DateTime(currentday.year - 1, 1, 1),
        DateTime(currentday.year - 1, 12, 31), vitalsUI[widget.data["vitalType"]]["acr"]);
    if (yearlyValue.isEmpty) {
      mapData = await MyvitalsGraphData().getVitalsdata(
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now(),
          vitalsUI[widget.data["vitalType"]]["acr"]);
    } else {
      types.removeWhere((String element) => element == "Last 7 days");
      if (!types.contains("Yearly")) types.add("Yearly");
      selectedType.value = "Weekly";
      mapData = await MyvitalsGraphData().getVitalsdata(firstDayofLastSevendays,
          seventhDayofLastSevendays, vitalsUI[widget.data["vitalType"]]["acr"]);
    }

    preFecthingFunction();
    NewMyVitalGraph.loader = false;

    selectedType.notifyListeners();
  }

  bool prefecth = false;

  preFecthingFunction() async {
    arrow.value = true;
    if (selectedType.value == "Weekly") {
      NewMyVitalGraph.mapDataForward = await MyvitalsGraphData().getVitalsdata(
          startOfWeek.add(const Duration(days: 7)),
          endOfWeek.add(const Duration(days: 7)),
          vitalsUI[widget.data["vitalType"]]["acr"]);
      NewMyVitalGraph.mapDataBackward = await MyvitalsGraphData().getVitalsdata(
          startOfWeek.subtract(const Duration(days: 7)),
          endOfWeek.subtract(const Duration(days: 7)),
          vitalsUI[widget.data["vitalType"]]["acr"]);
    } else if (selectedType.value == "Monthly") {
      NewMyVitalGraph.mapDataForward = await MyvitalsGraphData().getVitalsdata(
          DateTime(DateTime.now().year, currentMonth + 1, 1),
          DateTime(DateTime.now().year, currentMonth + 2, 1).subtract(const Duration(days: 1)),
          vitalsUI[widget.data["vitalType"]]["acr"]);
      DateTime subractMont = DateTime(DateTime.now().year, currentMonth - 1, 1);
      int i = subractMont.month + 1;
      NewMyVitalGraph.mapDataBackward = await MyvitalsGraphData().getVitalsdata(
          subractMont,
          DateTime(subractMont.year, i, 1).subtract(const Duration(days: 1)),
          vitalsUI[widget.data["vitalType"]]["acr"]);
    } else if (selectedType.value == "Yearly") {
      NewMyVitalGraph.mapDataForward = await MyvitalsGraphData().getVitalsdata(
          firstYear.add(const Duration(days: 365)),
          lastYear.add(const Duration(days: 365)),
          vitalsUI[widget.data["vitalType"]]["acr"]);
      NewMyVitalGraph.mapDataBackward = await MyvitalsGraphData().getVitalsdata(
          firstYear.subtract(const Duration(days: 365)),
          lastYear.subtract(const Duration(days: 365)),
          vitalsUI[widget.data["vitalType"]]["acr"]);
    } else {
      NewMyVitalGraph.mapDataForward = await MyvitalsGraphData().getVitalsdata(
          firstDayofLastSevendays.add(const Duration(days: 7)),
          seventhDayofLastSevendays.add(const Duration(days: 7)),
          vitalsUI[widget.data["vitalType"]]["acr"]);
      NewMyVitalGraph.mapDataBackward = await MyvitalsGraphData().getVitalsdata(
          firstDayofLastSevendays.subtract(const Duration(days: 7)),
          seventhDayofLastSevendays.subtract(const Duration(days: 7)),
          vitalsUI[widget.data["vitalType"]]["acr"]);
    }
    NewMyVitalGraph.loader = false;
    arrow.value = false;
    vitalValueRecent.value = mapData.first['value'].toString();
    vitalStatusRecent.value = mapData.first['status'].toString();
    vitalValueRecent.notifyListeners();
    log("pre-fecthing Done !!");
    // selectedType.notifyListeners();
  }

  DateTime currentday = DateTime.now();
  int currentMonth = DateTime.now().month;

  String firstDayString =
      DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String lastDayString =
      DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));

  // DateTime startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday));
  DateTime firstDayofLastSevendays =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .subtract(const Duration(days: 7));
  DateTime seventhDayofLastSevendays =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .add(const Duration(days: 1))
          .subtract(const Duration(minutes: 1));
  DateTime firstYear = DateTime(DateTime.now().year, 1, 1);
  DateTime lastYear = DateTime(DateTime.now().year, 12, 31);
  DateTime startOfWeek = currentweekDayFinder();

  // DateTime endOfWeek =
  //     DateTime.now().subtract(Duration(days: DateTime.now().weekday)).add(Duration(days: 7));
  DateTime endOfWeek =
      currentweekDayFinder().add(const Duration(days: 7)).subtract(const Duration(minutes: 1));

  static DateTime currentweekDayFinder() {
    final DateTime now1 = DateTime.now();
    final DateTime now = DateTime(now1.year, now1.month, now1.day);
    log("Current Day => ${DateFormat('EEEE').format(now)}");
    if (now.weekday == DateTime.sunday) {
      return now;
    }
    return DateTime(now.year, now.month, now.day - now.weekday);
  }

  void modifyList(bias) async {
    // NewMyVitalGraph.loader = true;
    mapData = [];
    selectedType.notifyListeners();
    print('Start Date: $firstDayString');
    print('End Date: $lastDayString');
    if (selectedType.value == 'Monthly') {
      if (bias == 'forward') {
        if (currentMonth != DateTime.now().month) {
          currentMonth = currentMonth + 1;
          DateTime firstDayOfMonth = DateTime(DateTime.now().year, currentMonth, 1);
          DateTime lastDayOfMonth = DateTime(DateTime.now().year, currentMonth + 1, 0);

          DateFormat dateFormat = DateFormat('yyyy-MM-dd');
          firstDayString = dateFormat.format(firstDayOfMonth);
          lastDayString = dateFormat.format(lastDayOfMonth);
          mapData = NewMyVitalGraph.mapDataForward;
          // mapData = await MyvitalsGraphData().getVitalsdata(DateTime.parse(firstDayString),
          //     DateTime.parse(lastDayString), vitalsUI[widget.data["vitalType"]]["acr"]);
        }
      } else {
        currentMonth = currentMonth - 1;
        DateTime firstDayOfMonth = DateTime(DateTime.now().year, currentMonth, 1);
        DateTime lastDayOfMonth = DateTime(DateTime.now().year, currentMonth + 1, 0);

        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        firstDayString = dateFormat.format(firstDayOfMonth);
        lastDayString = dateFormat.format(lastDayOfMonth);
        mapData = NewMyVitalGraph.mapDataBackward;
        // mapData = await MyvitalsGraphData().getVitalsdata(DateTime.parse(firstDayString),
        //     DateTime.parse(lastDayString), vitalsUI[widget.data["vitalType"]]["acr"]);
        print('Start Date: $firstDayString');
        print('End Date: $lastDayString');
      }
    }
    if (selectedType.value == 'Weekly') {
      print(startOfWeek);
      if (bias == 'forward') {
        if (DateTime.parse(endOfWeek.toString()).isBefore(DateTime.now())) {
          startOfWeek = startOfWeek.add(const Duration(days: 7));
          endOfWeek = endOfWeek.add(const Duration(days: 7));
          DateFormat dateFormat = DateFormat('yyyy-MM-dd');
          firstDayString = dateFormat.format(startOfWeek);
          lastDayString = dateFormat.format(endOfWeek);
          mapData = NewMyVitalGraph.mapDataForward;
          // mapData = await MyvitalsGraphData().getVitalsdata(DateTime.parse(firstDayString),
          //     DateTime.parse(lastDayString), vitalsUI[widget.data["vitalType"]]["acr"]);
        }
      } else {
        startOfWeek = startOfWeek.subtract(const Duration(days: 7));
        // endOfWeek = startOfWeek.add(Duration(days: 7));
        endOfWeek = endOfWeek.subtract(const Duration(days: 7));
        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        firstDayString = dateFormat.format(startOfWeek);
        lastDayString = dateFormat.format(endOfWeek);
        mapData = NewMyVitalGraph.mapDataBackward;
        // mapData = await MyvitalsGraphData().getVitalsdata(DateTime.parse(firstDayString),
        //     DateTime.parse(lastDayString), vitalsUI[widget.data["vitalType"]]["acr"]);
      }
    }
    if (selectedType.value == 'Last 7 days') {
      print(firstDayofLastSevendays);

      if (bias == 'forward') {
        if (DateTime.parse(seventhDayofLastSevendays.toString()).day != DateTime.now().day) {
          firstDayofLastSevendays = firstDayofLastSevendays.add(const Duration(days: 7));
          seventhDayofLastSevendays = seventhDayofLastSevendays.add(const Duration(days: 7));
          DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
          lastDayString = dateFormat.format(seventhDayofLastSevendays);
          firstDayString = dateFormat.format(firstDayofLastSevendays);
          mapData = NewMyVitalGraph.mapDataForward;
          // mapData = await MyvitalsGraphData().getVitalsdata(DateTime.parse(firstDayString),
          //     DateTime.parse(lastDayString), vitalsUI[widget.data["vitalType"]]["acr"]);
        }
      } else {
        firstDayofLastSevendays = firstDayofLastSevendays.subtract(const Duration(days: 7));
        seventhDayofLastSevendays = seventhDayofLastSevendays.subtract(const Duration(days: 7));
        DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
        firstDayString = dateFormat.format(firstDayofLastSevendays);
        lastDayString = dateFormat.format(seventhDayofLastSevendays);
        mapData = NewMyVitalGraph.mapDataBackward;
        // mapData = await MyvitalsGraphData().getVitalsdata(DateTime.parse(firstDayString),
        //     DateTime.parse(lastDayString), vitalsUI[widget.data["vitalType"]]["acr"]);
      }
    }
    if (selectedType.value == 'Yearly') {
      if (bias == 'forward') {
        if (firstYear.year != currentday.year) {
          firstYear = firstYear.add(const Duration(days: 365));
          lastYear = lastYear.add(const Duration(days: 365));
          DateFormat dateFormat = DateFormat('yyyy-MM-dd');
          firstDayString = dateFormat.format(firstYear);
          lastDayString = dateFormat.format(lastYear);
          mapData = NewMyVitalGraph.mapDataForward;
          // mapData = await MyvitalsGraphData().getVitalsdata(DateTime.parse(firstDayString),
          //     DateTime.parse(lastDayString), vitalsUI[widget.data["vitalType"]]["acr"]);
        }
      } else {
        firstYear = firstYear.subtract(const Duration(days: 365));
        lastYear = lastYear.subtract(const Duration(days: 365));
        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        firstDayString = dateFormat.format(firstYear);
        lastDayString = dateFormat.format(lastYear);
        mapData = NewMyVitalGraph.mapDataBackward;
        // mapData = await MyvitalsGraphData().getVitalsdata(DateTime.parse(firstDayString),
        //     DateTime.parse(lastDayString), vitalsUI[widget.data["vitalType"]]["acr"]);
      }
    }
    NewMyVitalGraph.loader = false;
    selectedType.notifyListeners();
    preFecthingFunction();
  }

  @override
  Widget build(BuildContext context) {
    String vitalType = widget.data["vitalType"];
    double vitalValue = vitalType == "bp" ? 0 : double.parse(widget.data['value'] ?? "0.0");
    String titleText = "${vitalsUI[vitalType]["acr"]} - " + vitalsUI[vitalType]["name"];
    String smallWord = vitalsUI[vitalType]["acr"].toString();
    if (smallWord == "MINERAL" ||
        smallWord == "WEIGHT" ||
        smallWord == "PROTEIN" ||
        smallWord == "PULSE") {
      titleText = smallWord.toLowerCase().capitalizeFirst;
    }
    final List data = widget.data['data'];
    data.removeWhere((element) => element["value"] == 0);
    vitalValueRecent.value = widget.data['value'];
    vitalStatusRecent.value = widget.data['status'];

    return WillPopScope(
      onWillPop: () {
        if (widget.navPath == "home") {
          _tabController.updateSelectedIconValue(value: "Home");
        }
        Get.back();
        return null;
      },
      child: CommonScreenForNavigation(
        content: ValueListenableBuilder(
            valueListenable: listenVitals,
            builder: (_, v, __) {
              if (v == true) {
                //mapData.clear();
                types = ["Last 7 days", "Weekly", "Monthly"];
                yearlyValue.clear();
                mapData.clear();

                getInitialData();

                // preFecthingFunction();
                // // vitalValue = mapData.first['value'];
              }
              return Scaffold(
                backgroundColor: AppColors.backgroundScreenColor,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: AppColors.primaryColor,
                  leading: IconButton(
                    onPressed: () {
                      if (widget.navPath == "home") {
                        _tabController.updateSelectedIconValue(value: "Home");
                      }
                      Get.off(ManageHealthScreenTabs(
                        naviBack: 0,
                      ));
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  title: FittedBox(child: Text(titleText)),
                  centerTitle: true,
                ),
                body: ValueListenableBuilder(
                    valueListenable: vitalStatusRecent,
                    builder: (_, s, __) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 10.px),
                              if (smallWord != "BMR" && smallWord != "ECG" && smallWord != "WEIGHT")
                                Container(
                                  color: vitalType == "spo2" && s.toString() == "Low"
                                      ? colorForStatus("High").withOpacity(0.2)
                                      : colorForStatus(s.toString()).withOpacity(0.2),
                                  width: 100.w,
                                  height: 11.h,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 2.w),
                                      SizedBox(
                                          height: 6.h,
                                          child: Image.asset(
                                              "newAssets/Icons/vitalsDetails/${imageforVital(vitalName: titleText)}.png")),
                                      SizedBox(width: 7.w),
                                      SizedBox(
                                        height: 10.5.h,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ValueListenableBuilder(
                                                valueListenable: vitalValueRecent,
                                                builder: (_, c, __) {
                                                  return FittedBox(
                                                    child: Text(
                                                      "Your ${vitalsUI[vitalType]["name"]} is ${c.toString()} ${ProgramLists.vitalsUnitG[vitalType]}",
                                                      style: TextStyle(
                                                          letterSpacing: 0.1, fontSize: 14.2.sp),
                                                    ),
                                                  );
                                                }),
                                            SizedBox(height: 0.5.h),
                                            Wrap(
                                              children: [
                                                Text("Status : ",
                                                    style: TextStyle(
                                                        letterSpacing: 0.3, fontSize: 15.sp)),
                                                SizedBox(
                                                  width: 40.w,
                                                  child: Text(
                                                    s.contains('Doctor Attention Needed')
                                                        ? 'Clinical Screening Recommended'
                                                        : s.toString().capitalizeFirst,
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                        color: s.contains('Doctor Attention Needed')
                                                            ? const Color.fromARGB(255, 216, 163, 4)
                                                            : s.toString() == "Low" &&
                                                                    vitalType == 'spo2'
                                                                ? colorForStatus("High")
                                                                : colorForStatus(s.toString()),
                                                        letterSpacing: 0.3,
                                                        fontSize: 15.sp),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: SizedBox(
                                            height: 3.w,
                                            width: 8.w,
                                            child: ClipPath(
                                              clipper: SubscriptionClipPath(),
                                              child: Container(
                                                  color:
                                                      s.toString() == "Low" && vitalType == 'spo2'
                                                          ? colorForStatus("High")
                                                          : colorForStatus(s.toString())),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              if (smallWord != "BMR" && smallWord != "ECG" && smallWord != "WEIGHT")
                                SizedBox(height: 3.h),
                              if (smallWord != "BMR" && smallWord != "ECG" && smallWord != "WEIGHT")
                                Visibility(
                                  visible: vitalsUI[vitalType]['acr'] != 'WEIGHT',
                                  child: Container(
                                      color: Colors.white,
                                      width: 100.w,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Container(
                                            child: vitalsUI[vitalType]['acr'] == 'BMI'
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                      SizedBox(height: 10.px),
                                                      SizedBox(
                                                        width: 80.w,
                                                        child: SfLinearGauge(
                                                            interval: vitalValue > 50 ? 20 : 10.0,
                                                            axisLabelStyle: TextStyle(
                                                                fontFamily: "Poppins",
                                                                color: Colors.black,
                                                                fontSize: 12.px),
                                                            ranges: <LinearGaugeRange>[
                                                              LinearGaugeRange(
                                                                startValue: 10,
                                                                endValue: 18.5,
                                                                color: colorForStatus('Low'),
                                                              ),
                                                              LinearGaugeRange(
                                                                startValue: 18.5,
                                                                endValue: 23,
                                                                color: colorForStatus('Normal'),
                                                              ),
                                                              LinearGaugeRange(
                                                                startValue: 23,
                                                                endValue: vitalValue > 50
                                                                    ? maximumValueSetter(
                                                                        value: vitalValue)
                                                                    : 50,
                                                                color: colorForStatus('High'),
                                                              ),
                                                              // LinearGaugeRange(
                                                              //   startValue: 25,
                                                              //   endValue: vitalValue > 50
                                                              //       ? maximumValueSetter(value: vitalValue)
                                                              //       : 50,
                                                              //   color: colorForStatus('Obese'),
                                                              // )
                                                            ],
                                                            minimum: 10,
                                                            maximum: vitalValue > 50
                                                                ? maximumValueSetter(
                                                                    value: vitalValue)
                                                                : 50,
                                                            markerPointers: [
                                                              LinearShapePointer(value: vitalValue)
                                                            ]),
                                                      ),
                                                      Visibility(
                                                          visible:
                                                              vitalsUI[vitalType]['acr'] == 'BMI',
                                                          child: SizedBox(height: 20.px)),
                                                      Visibility(
                                                          visible:
                                                              vitalsUI[vitalType]['acr'] == 'BMI',
                                                          child: statusInfo(
                                                              title: 'Low',
                                                              prefix: "< ",
                                                              value: "18.5")),
                                                      Visibility(
                                                          visible:
                                                              vitalsUI[vitalType]['acr'] == 'BMI',
                                                          child: SizedBox(height: 10.px)),
                                                      Visibility(
                                                          visible:
                                                              vitalsUI[vitalType]['acr'] == 'BMI',
                                                          child: statusInfo(
                                                              title: 'Normal', value: "18.5-22.9")),
                                                      Visibility(
                                                          visible:
                                                              vitalsUI[vitalType]['acr'] == 'BMI',
                                                          child: SizedBox(height: 10.px)),
                                                      Visibility(
                                                          visible:
                                                              vitalsUI[vitalType]['acr'] == 'BMI',
                                                          child: statusInfo(
                                                              title: 'High',
                                                              prefix: "≥ ",
                                                              value: "23.0")),
                                                      Visibility(
                                                          visible:
                                                              vitalsUI[vitalType]['acr'] == 'BMI',
                                                          child: SizedBox(height: 10.px)),
                                                      // Visibility(
                                                      //   visible: vitalsUI[vitalType]['acr'] == 'BMI',
                                                      //   child: statusInfo(
                                                      //       title: "Obese", value: " 25", differentStyle: true),
                                                      // ),
                                                    ],
                                                  )
                                                : vitalsUI[vitalType]['acr'] == 'SPO2'
                                                    ? Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceEvenly,
                                                        children: <Widget>[
                                                          SizedBox(height: 10.px),
                                                          SizedBox(
                                                            width: 80.w,
                                                            child: SfLinearGauge(
                                                                interval: 10.0,
                                                                axisLabelStyle: TextStyle(
                                                                    fontFamily: "Poppins",
                                                                    color: Colors.black,
                                                                    fontSize: 12.px),
                                                                ranges: <LinearGaugeRange>[
                                                                  LinearGaugeRange(
                                                                    startValue: 50,
                                                                    endValue: 94.99,
                                                                    color: colorForStatus(
                                                                        'Check with healthcare provider'),
                                                                  ),
                                                                  LinearGaugeRange(
                                                                    startValue: 95,
                                                                    endValue: vitalValue >= 100
                                                                        ? (vitalValue.toInt() + 5)
                                                                            .toDouble()
                                                                        : 100,
                                                                    color: colorForStatus('Normal'),
                                                                  ),
                                                                ],
                                                                minimum: 50,
                                                                maximum: vitalValue >= 100
                                                                    ? (vitalValue.toInt() + 5)
                                                                        .toDouble()
                                                                    : 100,
                                                                markerPointers: [
                                                                  LinearShapePointer(
                                                                      value: vitalValue)
                                                                ]),
                                                          ),
                                                          SizedBox(height: 10.px),
                                                          statusInfo(
                                                              title: 'Low',
                                                              prefix: "< ",
                                                              value: "95",
                                                              color: colorForStatus(
                                                                  'Check with healthcare provider')),
                                                          SizedBox(height: 20.px),
                                                          statusInfo(
                                                              title: 'Normal',
                                                              prefix: "≥ ",
                                                              value: "95",
                                                              differentStyle: true,
                                                              color: colorForStatus('Normal')),
                                                          SizedBox(height: 10.px),
                                                        ],
                                                      )
                                                    : vitalsUI[vitalType]['acr'] == 'PROTEIN'
                                                        ? _vitallownrmlHignProteinStatus(
                                                            value: widget.data['value'],
                                                            context: context,
                                                            min: 0.0,
                                                            interval: 5.0,
                                                            max:
                                                                double.parse(gproteinh.toString()) +
                                                                    10.0,
                                                            low: double.parse(gproteinl.toString()),
                                                            high:
                                                                double.parse(gproteinh.toString()))
                                                        : vitalsUI[vitalType]['acr'] ==
                                                                'Cholesterol'
                                                            ? Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.spaceEvenly,
                                                                children: <Widget>[
                                                                  SizedBox(height: 10.px),
                                                                  SizedBox(
                                                                    width: 80.w,
                                                                    child: SfLinearGauge(
                                                                        interval: 100,
                                                                        axisLabelStyle: TextStyle(
                                                                            fontFamily: "Poppins",
                                                                            color: Colors.black,
                                                                            fontSize: 12.px),
                                                                        ranges: <LinearGaugeRange>[
                                                                          LinearGaugeRange(
                                                                            startValue: 140,
                                                                            endValue: 200,
                                                                            color: colorForStatus(
                                                                                'Normal'),
                                                                          ),
                                                                          LinearGaugeRange(
                                                                            startValue: 200,
                                                                            endValue: 239,
                                                                            color: colorForStatus(
                                                                                'Border Line'),
                                                                          ),
                                                                          LinearGaugeRange(
                                                                            startValue: 239,
                                                                            endValue: vitalValue >
                                                                                    400
                                                                                ? (vitalValue
                                                                                            .toInt() +
                                                                                        5)
                                                                                    .toDouble()
                                                                                : 400,
                                                                            color: colorForStatus(
                                                                                'Obese'),
                                                                          )
                                                                        ],
                                                                        minimum: 140,
                                                                        maximum: vitalValue > 400
                                                                            ? (vitalValue.toInt() +
                                                                                    5)
                                                                                .toDouble()
                                                                            : 400,
                                                                        markerPointers: [
                                                                          LinearShapePointer(
                                                                              value: double.parse(
                                                                                  widget.data[
                                                                                      'value']))
                                                                        ]),
                                                                  ),
                                                                  SizedBox(height: 20.px),
                                                                  statusInfo(
                                                                      title: 'Healthy',
                                                                      value: "200",
                                                                      lessthan: true,
                                                                      color:
                                                                          colorForStatus('Normal')),
                                                                  statusInfo(
                                                                      title: 'BorderLine High',
                                                                      value: "200",
                                                                      twoValues: true,
                                                                      value2: "239",
                                                                      color: colorForStatus(
                                                                          'Border Line')),
                                                                  statusInfo(
                                                                      title: "High",
                                                                      value: "240",
                                                                      color:
                                                                          colorForStatus('Obese'),
                                                                      differentStyle: true),
                                                                  SizedBox(height: 20.px),
                                                                ],
                                                              )
                                                            : _switchVitalData(
                                                                data: vitalsUI[vitalType]['acr'],
                                                                value: widget.data['value'],
                                                                context: context,
                                                              ),
                                          )
                                        ],
                                      )),
                                ),
                              SizedBox(height: 20.px),
                              Container(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: selectedType,
                                      builder: (BuildContext context, value, Widget child) =>
                                          Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            SizedBox(height: 10.px),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: types
                                                  .map(
                                                    (String e) => InkWell(
                                                        onTap: () async {
                                                          forward = 0;
                                                          NewMyVitalGraph.loader = true;
                                                          selectedType.value = e;
                                                          if (selectedType.value == 'Monthly') {
                                                            currentMonth = DateTime.now().month;
                                                            String firstDayString1 =
                                                                DateFormat('yyyy-MM-dd').format(
                                                                    DateTime(DateTime.now().year,
                                                                        DateTime.now().month, 1));
                                                            String lastDayString1 =
                                                                DateFormat('yyyy-MM-dd').format(
                                                                    DateTime(
                                                                        DateTime.now().year,
                                                                        DateTime.now().month + 1,
                                                                        0));
                                                            firstDayString = firstDayString1;
                                                            lastDayString = lastDayString1;
                                                            mapData = await MyvitalsGraphData()
                                                                .getVitalsdata(
                                                                    DateTime.parse(firstDayString1),
                                                                    DateTime.parse(lastDayString1),
                                                                    vitalsUI[widget
                                                                        .data["vitalType"]]["acr"]);
                                                          }
                                                          if (selectedType.value == 'Weekly') {
                                                            DateTime startOfWeek =
                                                                currentweekDayFinder();
                                                            DateTime endOfWeek =
                                                                currentweekDayFinder()
                                                                    .add(const Duration(days: 7))
                                                                    .subtract(
                                                                        const Duration(minutes: 1));
                                                            DateFormat dateFormat =
                                                                DateFormat('yyyy-MM-dd');
                                                            firstDayString =
                                                                dateFormat.format(startOfWeek);
                                                            lastDayString =
                                                                dateFormat.format(endOfWeek);
                                                            mapData = await MyvitalsGraphData()
                                                                .getVitalsdata(
                                                                    DateTime.parse(firstDayString),
                                                                    DateTime.parse(lastDayString),
                                                                    vitalsUI[widget
                                                                        .data["vitalType"]]["acr"]);
                                                          }
                                                          if (selectedType.value == 'Last 7 days') {
                                                            DateFormat dateFormat =
                                                                DateFormat('yyyy-MM-dd HH:mm:ss');
                                                            firstDayString = dateFormat
                                                                .format(firstDayofLastSevendays);
                                                            lastDayString = dateFormat
                                                                .format(seventhDayofLastSevendays);
                                                            mapData = await MyvitalsGraphData()
                                                                .getVitalsdata(
                                                                    DateTime.parse(firstDayString),
                                                                    DateTime.parse(lastDayString),
                                                                    vitalsUI[widget
                                                                        .data["vitalType"]]["acr"]);
                                                          }
                                                          if (selectedType.value == 'Yearly') {
                                                            String firstDayString1 =
                                                                DateFormat('yyyy-MM-dd').format(
                                                                    DateTime(
                                                                        currentday.year, 1, 1));
                                                            String lastDayString1 =
                                                                DateFormat('yyyy-MM-dd').format(
                                                                    DateTime(
                                                                        currentday.year, 12, 31));
                                                            firstDayString = firstDayString1;
                                                            lastDayString = lastDayString1;
                                                            mapData = await MyvitalsGraphData()
                                                                .getVitalsdata(
                                                                    DateTime.parse(firstDayString1),
                                                                    DateTime.parse(lastDayString1),
                                                                    vitalsUI[widget
                                                                        .data["vitalType"]]["acr"]);
                                                          }
                                                          defaultValueSetter();
                                                          NewMyVitalGraph.loader = false;
                                                          selectedType.notifyListeners();
                                                          preFecthingFunction();
                                                        },
                                                        child: AnimatedContainer(
                                                          duration:
                                                              const Duration(milliseconds: 300),
                                                          padding: const EdgeInsets.only(bottom: 3),
                                                          decoration: BoxDecoration(
                                                              border: Border(
                                                                  bottom: BorderSide(
                                                                      width: 1.5,
                                                                      color: selectedType.value == e
                                                                          ? AppColors.primaryColor
                                                                          : Colors.transparent))),
                                                          child: Text(
                                                            e,
                                                            style: TextStyle(
                                                                fontWeight: selectedType.value == e
                                                                    ? FontWeight.w500
                                                                    : FontWeight.w400,
                                                                color: selectedType.value == e
                                                                    ? AppColors.primaryColor
                                                                    : Colors.black),
                                                          ),
                                                        )),
                                                  )
                                                  .toList(),
                                            ),
                                            SizedBox(height: 20.px),
                                            ValueListenableBuilder(
                                                valueListenable: arrow,
                                                builder: (BuildContext context, bool value,
                                                    Widget widget) {
                                                  return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        if (NewMyVitalGraph.loader != true &&
                                                            value != true)
                                                          InkWell(
                                                              onTap: () async {
                                                                forward--;
                                                                modifyList('backward');
                                                                shimmerFunciton();
                                                              },
                                                              child: const Icon(
                                                                  Icons.arrow_back_ios_new_rounded))
                                                        else
                                                          InkWell(
                                                              onTap: null,
                                                              child: Shimmer.fromColors(
                                                                  direction: ShimmerDirection.rtl,
                                                                  period:
                                                                      const Duration(seconds: 1),
                                                                  baseColor:
                                                                      Colors.blue.withOpacity(0.2),
                                                                  highlightColor: Colors.blue,
                                                                  child: const Icon(Icons
                                                                      .arrow_back_ios_new_rounded))),
                                                        SizedBox(
                                                            width: 70.w,
                                                            child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  dateText(dateData: [
                                                                    DateTime.parse(firstDayString),
                                                                    DateTime.parse(lastDayString),
                                                                  ]),
                                                                ])),
                                                        if (forward != 0 &&
                                                            NewMyVitalGraph.loader != true &&
                                                            value != true)
                                                          InkWell(
                                                              onTap: () async {
                                                                forward++;
                                                                modifyList('forward');
                                                                shimmerFunciton();
                                                              },
                                                              child: const Icon(
                                                                  Icons.arrow_forward_ios_rounded))
                                                        else if (forward != 0)
                                                          Shimmer.fromColors(
                                                              direction: ShimmerDirection.ltr,
                                                              period: const Duration(seconds: 1),
                                                              baseColor:
                                                                  Colors.blue.withOpacity(0.2),
                                                              highlightColor: Colors.blue,
                                                              child: const Icon(
                                                                  Icons.arrow_forward_ios_rounded))
                                                        else
                                                          InkWell(
                                                              onTap: null,
                                                              child: Icon(
                                                                Icons.arrow_forward_ios_rounded,
                                                                color: Colors.grey.shade300,
                                                              ))
                                                      ]);
                                                }),
                                            SizedBox(height: 20.px),
                                            // PointerGraphForVital(
                                            //   points: plotter,
                                            //   width: 100.w,
                                            //   height: 70.w,
                                            // ),
                                            NewMyVitalGraph.loader
                                                ? Shimmer.fromColors(
                                                    direction: ShimmerDirection.ltr,
                                                    period: const Duration(seconds: 2),
                                                    baseColor:
                                                        const Color.fromARGB(255, 240, 240, 240),
                                                    highlightColor: Colors.grey.withOpacity(0.2),
                                                    child: Container(
                                                        width: 100.w,
                                                        height: 30.h,
                                                        padding: const EdgeInsets.only(
                                                            left: 8, right: 8, top: 8),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(8)),
                                                        child: const Text('Hello')))
                                                : ValueListenableBuilder(
                                                    valueListenable: selectedType,
                                                    builder: (__, val, _) {
                                                      return SizedBox(
                                                        width: 100.w,
                                                        height: 30.h,
                                                        child: widget.data["vitalType"] == "bp"
                                                            ? NewMyVitalGraph().createBPChart(
                                                                data: mapData.reversed.toList())
                                                            : NewMyVitalGraph().createChart(
                                                                data: mapData.reversed.toList(),
                                                                vitalName:
                                                                    widget.data["vitalType"]),
                                                      );
                                                    }),
                                            SizedBox(height: 3.h),
                                            if (NewMyVitalGraph.loader != true)
                                              ...mapData.reversed.map((e) {
                                                DateTime date = e["date"];

                                                print(e["kiosk_info"]);
                                                String city = '';
                                                String address = '';
                                                bool isMoreInfoNull = (e["kiosk_info"] == null);
                                                if (!isMoreInfoNull) {
                                                  isMoreInfoNull == e["kiosk_info"].isEmpty;
                                                }

                                                if (!isMoreInfoNull) {
                                                  if (e["kiosk_info"]["City"] != null &&
                                                      e["kiosk_info"]["City"]
                                                              .toString()
                                                              .toLowerCase() !=
                                                          "na") {
                                                    city = e["kiosk_info"]["City"];
                                                  }
                                                } else {
                                                  city = 'NA';
                                                }

                                                if (!isMoreInfoNull) {
                                                  if (e["kiosk_info"]["Address1"] != null &&
                                                      e["kiosk_info"]["Address1"]
                                                              .toString()
                                                              .toLowerCase() !=
                                                          "na") {
                                                    address = e["kiosk_info"]["Address1"];
                                                  }
                                                } else {
                                                  if (address == '' && !isMoreInfoNull) {
                                                    if (e["kiosk_info"]["Address2"] != null &&
                                                        e["kiosk_info"]["Address2"]
                                                                .toString()
                                                                .toLowerCase() !=
                                                            "na") {
                                                      address = e["kiosk_info"]["Address2"];
                                                    }
                                                  } else {
                                                    address = 'NA';
                                                  }
                                                }

                                                isMoreInfoNull = (city == '' && address == '');

                                                String status = capitalize(e["status"] ?? "N/A");
                                                if (e['status'].toString().contains('A')) {
                                                  print(e['status']);
                                                }
                                                return SizedBox(
                                                  width: MediaQuery.of(context).size.width / 1,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Theme(
                                                        data: Theme.of(context).copyWith(
                                                          dividerColor: Colors.transparent,
                                                          visualDensity: VisualDensity.compact,
                                                        ),
                                                        child: ExpansionTile(
                                                          expandedAlignment: Alignment.centerLeft,
                                                          title: Text(DateFormat('EEEE, d MMMM')
                                                              .format(date)),
                                                          subtitle: smallWord == "TEMP"
                                                              ? Text(
                                                                  '${((((e["value"] * 9 / 5) + 32) * 100).truncateToDouble() / 100).toString()} ${ProgramLists.vitalsUnitG[vitalType]}',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontFamily: "Poppins",
                                                                      color: smallWord == "BMR" ||
                                                                              smallWord == "ECG"
                                                                          ? null
                                                                          : colorForStatus(
                                                                              e["status"]),
                                                                      fontSize: 15.px),
                                                                )
                                                              : Text(
                                                                  '${e["value"]} ${ProgramLists.vitalsUnitG[vitalType]}',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontFamily: "Poppins",
                                                                      color: smallWord == "SPO2" &&
                                                                              (e["status"] ==
                                                                                      "Low" ||
                                                                                  e["status"] ==
                                                                                      "low")
                                                                          ? colorForStatus("High")
                                                                          : smallWord == "BMR" ||
                                                                                  smallWord == "ECG"
                                                                              ? null
                                                                              : colorForStatus(
                                                                                  e["status"]),
                                                                      fontSize: 15.px),
                                                                ),
                                                          trailing: const Icon(
                                                            Icons.arrow_drop_down_sharp,
                                                          ),
                                                          children: [
                                                            Text(
                                                              DateTimeFormat.format(date,
                                                                  format:
                                                                      DateTimeFormats.americanAbbr),
                                                            ),
                                                            if (smallWord != "BMR" &&
                                                                smallWord != "ECG" &&
                                                                vitalType != "WEIGHT")
                                                              Text(
                                                                status,
                                                                style: TextStyle(
                                                                    fontFamily: "Poppins",
                                                                    color: smallWord == "SPO2" &&
                                                                            (status == "Low" ||
                                                                                status == "low")
                                                                        ? colorForStatus("High")
                                                                        : colorForStatus(
                                                                            e["status"]),
                                                                    fontSize: 15.px),
                                                              ),
                                                            isMoreInfoNull
                                                                ? Container()
                                                                : Container(
                                                                    padding:
                                                                        const EdgeInsets.all(8),
                                                                    width: 60.w,
                                                                    child: Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                "More Info",
                                                                                style: TextStyle(
                                                                                    fontSize:
                                                                                        14.px),
                                                                              ),
                                                                              const Spacer()
                                                                            ],
                                                                          ),
                                                                          const Divider(),
                                                                          SizedBox(
                                                                            height: 4.8.h,
                                                                            child: Row(
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment
                                                                                      .start,
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment
                                                                                      .spaceBetween,
                                                                              children: [
                                                                                SizedBox(
                                                                                  width: 16.w,
                                                                                  child: Text(
                                                                                    "Address",
                                                                                    style: TextStyle(
                                                                                        fontSize:
                                                                                            13.px),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    address,
                                                                                    textAlign:
                                                                                        TextAlign
                                                                                            .center,
                                                                                    style: TextStyle(
                                                                                        fontSize:
                                                                                            13.px),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          //  const Divider(),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment
                                                                                    .spaceBetween,
                                                                            children: [
                                                                              SizedBox(
                                                                                width: 16.w,
                                                                                child: Text(
                                                                                  "City",
                                                                                  style: TextStyle(
                                                                                      fontSize:
                                                                                          13.px),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  city,
                                                                                  textAlign:
                                                                                      TextAlign
                                                                                          .center,
                                                                                  style: TextStyle(
                                                                                      fontSize:
                                                                                          13.px),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const Divider(),
                                                                          if (widget.data[
                                                                                  "vitalType"] ==
                                                                              "ECGBpm")
                                                                            Padding(
                                                                              padding:
                                                                                  const EdgeInsets
                                                                                          .only(
                                                                                      left: 35,
                                                                                      right: 35),
                                                                              child: TextButton(
                                                                                onPressed:
                                                                                    () async {
                                                                                  var data = await MyvitalsGraphData()
                                                                                      .getEcgGraph(e[
                                                                                          'Checkin_id']);
                                                                                  ECGCalc
                                                                                      ecgGraphData =
                                                                                      ECGCalc(
                                                                                    isLeadThree:
                                                                                        e['leadmode'] ==
                                                                                            3,
                                                                                    data1: data[
                                                                                        'ECGData'],
                                                                                    data2: data[
                                                                                        'ECGData2'],
                                                                                    data3: data[
                                                                                        'ECGData3'],
                                                                                  );
                                                                                  Get.to(
                                                                                    ECGforNewScreen(
                                                                                        ecgValue: {
                                                                                          'ecgGraphData':
                                                                                              ecgGraphData,
                                                                                          'appBarData':
                                                                                              {
                                                                                            'color':
                                                                                                Colors.amber,
                                                                                            'value':
                                                                                                e['value'],
                                                                                            'status':
                                                                                                e['status'],
                                                                                            'date':
                                                                                                e['date'].toString(),
                                                                                          },
                                                                                          'hero':
                                                                                              date
                                                                                        },
                                                                                        statusCard:
                                                                                            Container()
                                                                                        // Container(
                                                                                        //   color: colorForStatus(widget
                                                                                        //           .data["status"]
                                                                                        //           .toString())
                                                                                        //       .withOpacity(0.2),
                                                                                        //   width: 100.w,
                                                                                        //   height: 11.5.h,
                                                                                        //   child: Row(
                                                                                        //     children: [
                                                                                        //       SizedBox(width: 2.w),
                                                                                        //       SizedBox(
                                                                                        //           height: 6.h,
                                                                                        //           child: Image.asset(
                                                                                        //               "newAssets/Icons/vitalsDetails/${imageforVital(vitalName: titleText)}.png")),
                                                                                        //       SizedBox(width: 7.w),
                                                                                        //       SizedBox(
                                                                                        //         height: 10.h,
                                                                                        //         child: Column(
                                                                                        //           mainAxisAlignment:
                                                                                        //               MainAxisAlignment
                                                                                        //                   .center,
                                                                                        //           crossAxisAlignment:
                                                                                        //               CrossAxisAlignment
                                                                                        //                   .start,
                                                                                        //           children: [
                                                                                        //             Text(
                                                                                        //               "Your ${vitalsUI[vitalType]["name"]} is ${widget.data["value"]}",
                                                                                        //               style: TextStyle(
                                                                                        //                   letterSpacing:
                                                                                        //                       0.1,
                                                                                        //                   fontSize:
                                                                                        //                       14.6.sp),
                                                                                        //             ),
                                                                                        //             SizedBox(
                                                                                        //                 height: 0.5.h),
                                                                                        //             Wrap(
                                                                                        //               children: [
                                                                                        //                 Text("Status : ",
                                                                                        //                     style: TextStyle(
                                                                                        //                         letterSpacing:
                                                                                        //                             0.3,
                                                                                        //                         fontSize:
                                                                                        //                             15.sp)),
                                                                                        //                 SizedBox(
                                                                                        //                   width: 40.w,
                                                                                        //                   child: Text(
                                                                                        //                     widget.data["status"]
                                                                                        //                             .contains(
                                                                                        //                                 'Doctor Attention Needed')
                                                                                        //                         ? 'Clinical Screening Recommended'
                                                                                        //                         : widget
                                                                                        //                             .data[
                                                                                        //                                 "status"]
                                                                                        //                             .toString()
                                                                                        //                             .capitalizeFirst,
                                                                                        //                     style: TextStyle(
                                                                                        //                         color: widget.data["status"].contains(
                                                                                        //                                 'Doctor Attention Needed')
                                                                                        //                             ? Color.fromARGB(
                                                                                        //                                 255,
                                                                                        //                                 216,
                                                                                        //                                 163,
                                                                                        //                                 4)
                                                                                        //                             : colorForStatus(widget.data["status"]
                                                                                        //                                 .toString()),
                                                                                        //                         letterSpacing:
                                                                                        //                             0.3,
                                                                                        //                         fontSize:
                                                                                        //                             15.sp),
                                                                                        //                   ),
                                                                                        //                 )
                                                                                        //               ],
                                                                                        //             )
                                                                                        //           ],
                                                                                        //         ),
                                                                                        //       ),
                                                                                        //       Spacer(),
                                                                                        //       Padding(
                                                                                        //         padding: const EdgeInsets
                                                                                        //             .fromLTRB(8, 8, 0, 8),
                                                                                        //         child: Align(
                                                                                        //           alignment:
                                                                                        //               Alignment.topRight,
                                                                                        //           child: SizedBox(
                                                                                        //             height: 3.w,
                                                                                        //             width: 8.w,
                                                                                        //             child: ClipPath(
                                                                                        //               clipper:
                                                                                        //                   SubscriptionClipPath(),
                                                                                        //               child: Container(
                                                                                        //                   color: colorForStatus(widget
                                                                                        //                       .data[
                                                                                        //                           "status"]
                                                                                        //                       .toString())),
                                                                                        //             ),
                                                                                        //           ),
                                                                                        //         ),
                                                                                        //       )
                                                                                        //     ],
                                                                                        //   ),
                                                                                        // ),

                                                                                        ),
                                                                                  );
                                                                                },
                                                                                style: TextButton
                                                                                    .styleFrom(
                                                                                        backgroundColor:
                                                                                            Colors
                                                                                                .blue),
                                                                                child: Row(
                                                                                  mainAxisAlignment:
                                                                                      MainAxisAlignment
                                                                                          .center,
                                                                                  children: <
                                                                                      Widget>[
                                                                                    const Text(
                                                                                      'View ECG ',
                                                                                      style: TextStyle(
                                                                                          color: Colors
                                                                                              .white),
                                                                                    ),
                                                                                    Hero(
                                                                                      tag: date,
                                                                                      child:
                                                                                          const Icon(
                                                                                        Icons
                                                                                            .show_chart,
                                                                                        color: Colors
                                                                                            .white,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            )
                                                                        ]),
                                                                  ),
                                                          ],
                                                          onExpansionChanged: (bool expanded) {},
                                                        ),
                                                      ),
                                                      if (mapData[0] != e)
                                                        Divider(
                                                          indent: 8,
                                                          endIndent: 8,
                                                          color: Colors.grey.withOpacity(0.2),
                                                          thickness: 1.2,
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // if (mapData.isNotEmpty ?? false)
                                    //   Divider(
                                    //     indent: 8,
                                    //     endIndent: 8,
                                    //     color: Colors.grey.withOpacity(0.2),
                                    //     thickness: 1.2,
                                    //   ),
                                  ],
                                ),
                              ),
                              if (mapData.isEmpty ?? true) SizedBox(height: 6.h),
                              SizedBox(height: 10.h)
                            ],
                          ),
                        ),
                      );
                    }),
              );
            }),
      ),
    );
  }

  Widget statusInfo(
      {bool differentStyle,
      String title,
      String prefix,
      String value,
      Color color,
      bool lessthan,
      bool twoValues,
      String value2}) {
    if (title.toString().contains('Acceptable') || title.toString().contains('acceptable')) {
      return SizedBox(
        width: 80.w,
        child: Row(
          children: [
            Container(
              height: 4.w,
              width: 4.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffef940f),
              ),
            ),
            SizedBox(width: 3.w),
            SizedBox(width: 40.w, child: Text("$title:")),
            SizedBox(width: 2.w),
            // const Text("Acceptable"),
            ProgramLists.vitalsUnitG[widget.data["vitalType"]].length >= 3
                ? Row(children: [
                    Text(
                      prefix ?? "",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: color ?? colorForStatus(title),
                          fontSize: 19.sp),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: const Color(0xffef940f),
                          fontSize: 16.sp),
                    ),
                    Text(
                      ' ${ProgramLists.vitalsUnitG[widget.data["vitalType"]]}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: const Color(0xffef940f),
                          fontSize: 10.px),
                    )
                  ])
                : Row(
                    children: [
                      Text(
                        prefix ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: color ?? colorForStatus(title),
                            fontSize: 19.sp),
                      ),
                      Text(
                        '$value ${ProgramLists.vitalsUnitG[widget.data["vitalType"]]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: const Color(0xffef940f),
                            fontSize: 16.sp),
                      ),
                    ],
                  ),
          ],
        ),
      );
    }
    // else if (title.toString().contains('Clinical Screening Recommended') ||
    //     title.toString().contains('Check with healthcare provider')) {
    else if (title.toString().length > 10) {
      return SizedBox(
        width: 80.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 4.w,
              width: 4.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color ?? colorForStatus(title),
              ),
            ),
            SizedBox(width: 3.w),
            SizedBox(
                width: 40.w,
                child: Text(
                  "$title:",
                  softWrap: true,
                  style: TextStyle(fontSize: 14.px),
                )),
            SizedBox(width: 2.w),
            // const Text("Acceptable"),
            ProgramLists.vitalsUnitG[widget.data["vitalType"]].length >= 3
                ? Row(children: [
                    Text(
                      prefix ?? "",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: color ?? colorForStatus(title),
                          fontSize: 19.sp),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: color ?? colorForStatus(title),
                          fontSize: 16.px),
                    ),
                    Text(
                      ' ${ProgramLists.vitalsUnitG[widget.data["vitalType"]]}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: color ?? colorForStatus(title),
                          fontSize: 10.px),
                    )
                  ])
                : Row(
                    children: [
                      Text(
                        prefix ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: color ?? colorForStatus(title),
                            fontSize: 19.sp),
                      ),
                      Text(
                        '$value ${ProgramLists.vitalsUnitG[widget.data["vitalType"]]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: color ?? colorForStatus(title),
                            fontSize: 16.sp),
                      ),
                    ],
                  ),
          ],
        ),
      );
    }
    if (twoValues ?? false) {
      return SizedBox(
        width: 65.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4.w,
              width: 4.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color ?? colorForStatus(title),
              ),
            ),
            SizedBox(width: 3.w),
            SizedBox(width: 40.w, child: Text("$title:")),
            SizedBox(width: 2.w),
            Text(
              '$value ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  color: color ?? colorForStatus(title),
                  fontSize: 16.sp),
            ),
            const Text("to"),
            Text(
              ' $value2 ${ProgramLists.vitalsUnitG[widget.data["vitalType"]]}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  color: color ?? colorForStatus(title),
                  fontSize: 16.sp),
            ),
          ],
        ),
      );
    }

    if (lessthan ?? false) {
      return SizedBox(
        width: 65.w,
        child: Row(
          children: [
            Container(
              height: 4.w,
              width: 4.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color ?? colorForStatus(title),
              ),
            ),
            SizedBox(width: 3.w),
            SizedBox(width: 40.w, child: Text("$title:")),
            SizedBox(width: 2.w),
            const Text("less than"),
            Row(
              children: [
                Text(
                  prefix ?? "",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                      color: color ?? colorForStatus(title),
                      fontSize: 19.sp),
                ),
                Text(
                  '$value ${ProgramLists.vitalsUnitG[widget.data["vitalType"]]}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                      color: color ?? colorForStatus(title),
                      fontSize: 16.sp),
                ),
              ],
            ),
          ],
        ),
      );
    }
    if (differentStyle ?? false) {
      return SizedBox(
        width: 80.w,
        child: Row(
          children: [
            Container(
              height: 4.w,
              width: 4.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color ?? colorForStatus(title),
              ),
            ),
            SizedBox(width: 3.w),
            SizedBox(width: 40.w, child: Text("$title:")),
            SizedBox(width: 2.w),
            // const Text("Above "),
            ProgramLists.vitalsUnitG[widget.data["vitalType"]].length >= 3
                ? Row(children: [
                    Text(
                      prefix ?? "",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: color ?? colorForStatus(title),
                          fontSize: 19.sp),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: const Color(0xffBA1616),
                          fontSize: 16.px),
                    ),
                    Text(
                      ' ${ProgramLists.vitalsUnitG[widget.data["vitalType"]]}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: const Color(0xffBA1616),
                          fontSize: 10.px),
                    )
                  ])
                : Row(
                    children: [
                      Text(
                        prefix ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: color ?? colorForStatus(title),
                            fontSize: 19.sp),
                      ),
                      Text(
                        '$value ${ProgramLists.vitalsUnitG[widget.data["vitalType"]]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: color ?? colorForStatus(title),
                            fontSize: 16.sp),
                      ),
                    ],
                  ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: 80.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 4.w,
              width: 4.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color ?? colorForStatus(title),
              ),
            ),
            SizedBox(width: 3.w),
            capitalize(title) == "Low" || capitalize(title) == "Underweight"
                ? SizedBox(width: 40.w, child: Text("$title :"))
                : SizedBox(width: 40.w, child: Text("$title :")),
            SizedBox(width: 2.w),
            ProgramLists.vitalsUnitG[widget.data["vitalType"]].length >= 3
                ? Row(children: [
                    Text(
                      prefix ?? "",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: color ?? colorForStatus(title),
                          fontSize: 19.sp),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: color ?? colorForStatus(title),
                          fontSize: 16.sp),
                    ),
                    Text(
                      ' ${ProgramLists.vitalsUnitG[widget.data["vitalType"]]}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: color ?? colorForStatus(title),
                          fontSize: 10.px),
                    )
                  ])
                : Row(
                    children: [
                      Text(
                        prefix ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: color ?? colorForStatus(title),
                            fontSize: 19.sp),
                      ),
                      Text(
                        '$value ${ProgramLists.vitalsUnitG[widget.data["vitalType"]]}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: color ?? colorForStatus(title),
                            fontSize: 16.sp),
                      ),
                    ],
                  ),
          ],
        ),
      );
    }
  }

  Widget dateText({List<DateTime> dateData}) {
    if (selectedType.value == "Monthly") {
      return Text(
        DateFormat('MMMM yyyy').format(dateData.last),
        style: TextStyle(fontSize: 15.px, fontWeight: FontWeight.w500),
      );
    } else if (selectedType.value == "Weekly") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${DateFormat('d MMM yyyy').format(dateData.first)} - ${DateFormat('d MMM yyyy').format(dateData[1])}",
            // "${DateFormat('EEE, d MMM, yyyy').format(dateData.first)} - 4 Feb 2023",
            style: TextStyle(fontSize: 15.px, fontWeight: FontWeight.w500),
          ),
          // Text(
          //   DateFormat('yyyy').format(dateData.first),
          //   // "${DateFormat('EEE, d MMM, yyyy').format(dateData.first)} - 4 Feb 2023",
          //   style: TextStyle(fontSize: 15.px, fontWeight: FontWeight.w500),
          // ),
        ],
      );
    } else if (selectedType.value == "Yearly") {
      return Text(
        DateFormat('yyyy').format(dateData.first),
        // "${DateFormat('EEE, d MMM, yyyy').format(dateData.first)} - 4 Feb 2023",
        style: TextStyle(fontSize: 15.px, fontWeight: FontWeight.w500),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${DateFormat('d MMMM').format(dateData.first)} - ${DateFormat('d MMMM').format(dateData[1])}",
            // "${DateFormat('EEE, d MMM, yyyy').format(dateData.first)} - 4 Feb 2023",
            style: TextStyle(fontSize: 15.px, fontWeight: FontWeight.w500),
          ),
          Text(
            DateFormat('yyyy').format(dateData.first),
            // "${DateFormat('EEE, d MMM, yyyy').format(dateData.first)} - 4 Feb 2023",
            style: TextStyle(fontSize: 15.px, fontWeight: FontWeight.w500),
          ),
        ],
      );
    }
  }

  colorForStatus(riskLevel) {
    riskLevel = riskLevel.toString().capitalizeFirst;
    if (riskLevel == 'Underweight') {
      return const Color(0xfffdc135);
    } else if (riskLevel == 'Normal') {
      return const Color(0xff7ac744);
    } else if (riskLevel == 'Overweight') {
      return const Color(0xffFE712C);
    } else if (riskLevel == 'Obese' || riskLevel == "High") {
      return const Color(0xffBA1616);
    } else if (riskLevel == 'Border Line') {
      return const Color(0xfffd712c);
    } else if (riskLevel == "Low") {
      return const Color(0xfffdc135);
    } else if (riskLevel == 'Elevated') {
      return const Color(0xffFE712C);
    } else if (riskLevel == 'Acceptable') {
      return const Color(0xffFE712C);
    } else {
      return const Color(0xffBA1616);
    }
  }

  Widget _vitallownrmlStatus(
      {value, BuildContext context, lowStart, lowEnd, nrmlStart, nrmlEnd, interval, min, max}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(height: 10.px),
        SizedBox(
          width: 80.w,
          child: SfLinearGauge(
              axisLabelStyle:
                  TextStyle(fontFamily: "Poppins", color: Colors.black, fontSize: 12.px),
              interval: double.parse(value) > nrmlEnd ? interval + 5 : interval,
              ranges: <LinearGaugeRange>[
                LinearGaugeRange(
                  startValue: lowStart,
                  endValue: lowEnd,
                  color: colorForStatus('Underweight'),
                ),
                LinearGaugeRange(
                  startValue: nrmlStart,
                  endValue: double.parse(value) > nrmlEnd
                      ? (double.parse(value).toInt() + 5).toDouble()
                      : max,
                  color: colorForStatus('Normal'),
                ),
              ],
              minimum: min,
              maximum:
                  double.parse(value) > max ? (double.parse(value).toInt() + 5).toDouble() : max,
              markerPointers: [LinearShapePointer(value: double.parse(value))]),
        ),
        SizedBox(height: 15.px),
        statusInfo(
            title: 'Low',
            prefix: "< ",
            value: "${lowEnd.toStringAsFixed(2)}",
            color: colorForStatus('Underweight')),
        SizedBox(height: 10.px),
        statusInfo(
            title: 'Normal',
            prefix: "≥ ",
            value: "${nrmlStart.toStringAsFixed(2)}",
            differentStyle: true),
        SizedBox(height: 20.px),
      ],
    );
  }

  Widget _vitallownrmlHignProteinStatus(
      {value, BuildContext context, interval, low, min, max, high}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(height: 10.px),
        SizedBox(
          width: 80.w,
          child: SfLinearGauge(
              axisLabelStyle:
                  TextStyle(fontFamily: "Poppins", color: Colors.black, fontSize: 12.px),
              interval: interval,
              ranges: <LinearGaugeRange>[
                LinearGaugeRange(
                  startValue: 0,
                  endValue: low,
                  color: colorForStatus('Underweight'),
                ),
                LinearGaugeRange(
                  startValue: low,
                  endValue: high,
                  color: colorForStatus('Normal'),
                ),
                LinearGaugeRange(
                  startValue: high,
                  endValue: max,
                  color: colorForStatus('High'),
                ),
              ],
              minimum: min,
              maximum:
                  double.parse(value) > max ? (double.parse(value).toInt() + 5).toDouble() : max,
              markerPointers: [LinearShapePointer(value: double.parse(value))]),
        ),
        SizedBox(height: 15.px),
        statusInfo(
            title: 'Low',
            prefix: "< ",
            value: "${low.toStringAsFixed(2)}",
            color: colorForStatus('Underweight')),
        SizedBox(height: 10.px),
        statusInfo(
          title: 'Normal',
          value: "${low.toStringAsFixed(2)}-${high.toStringAsFixed(2)}",
          // differentStyle: true
        ),
        SizedBox(height: 20.px),
        statusInfo(
            title: 'High', prefix: "> ", value: "${high.toStringAsFixed(2)}", differentStyle: true),
        SizedBox(height: 20.px),
      ],
    );
  }

  Widget _switchVitalData({
    String data,
    value,
    context,
  }) {
    switch (data) {
      case 'Cholesterol':
        return _vitallownrmlhighStatus(
            value: value,
            interval: 4.0,
            max: double.parse(value) >= 40.0 ? double.parse(value) + 10 : 40.0,
            min: 0.0,
            context: context,
            nrmlStart: gecll,
            nrmlEnd: geclh,
            obeseEnd: double.parse(value) >= 40.0 ? double.parse(value) + 10 : 40.0,
            obeseStart: geclh,
            highShow: true);
        break;
      case 'ECW':
        return _vitallownrmlhighStatus(
            value: value,
            interval: 3.0,
            max: double.parse(value) >= 18.0 ? double.parse(value) + 10 : 18.0,
            min: 5.0,
            context: context,
            nrmlStart: gecll,
            nrmlEnd: geclh,
            obeseEnd: double.parse(value) >= 18.0 ? double.parse(value) + 10 : 18.0,
            obeseStart: geclh,
            highShow: true);
        break;
      case 'ICW':
        return _vitallownrmlhighStatus(
          context: context,
          value: value,
          interval: 12.0,
          max: double.parse(value) >= 50.0 ? double.parse(value) + 10 : 50.0,
          min: 8.0,
          nrmlStart: gicll,
          nrmlEnd: giclh,
          obeseStart: giclh,
          obeseEnd: double.parse(value) >= 50.0 ? double.parse(value) + 10 : 50.0,
          highShow: true,
        );
        break;
      case 'MINERAL':
        return _vitallownrmlStatus(
            context: context,
            value: value,
            interval: 1.0,
            max: double.parse(value) >= 5.0 ? (double.parse(value) + 20).toInt().toDouble() : 5.0,
            min: 1.0,
            nrmlStart: 2.00,
            nrmlEnd: 5.0,
            lowStart: 0.0,
            lowEnd: 2.0);
        break;
      case 'SMM':
        return _vitallownrmlStatus(
            context: context,
            value: value,
            interval: 10.0,
            max: double.parse(value) >= 80.0 ? (double.parse(value) + 20).toInt().toDouble() : 80.0,
            min: 10.0,
            nrmlStart: glowSmmReference,
            nrmlEnd: 80.0,
            lowStart: 0.0,
            lowEnd: glowSmmReference);
        break;
      case 'BMC':
        return _vitallownrmlStatus(
            context: context,
            value: value,
            interval: 1.0,
            max: double.parse(value) >= 5.0 ? (double.parse(value) + 20).toInt().toDouble() : 5.0,
            min: 1.0,
            nrmlStart: glowBmcReference,
            nrmlEnd: 5.0,
            lowStart: 1.0,
            lowEnd: glowBmcReference);
        break;
      case 'PBF':
        return _vitalnrmlElevatedHighStatus(
            value: value,
            interval: 10.0,
            max: double.parse(value) >= 60.0 ? double.parse(value) + 20 : 60.0,
            min: 0.0,
            eleStart: gacceptablePbfReference + 0.01,
            eleEnd: ghighPbfReference,
            nrmlStart: glowPbfReference,
            nrmlEnd: gacceptablePbfReference,
            highStart: ghighPbfReference,
            highEnd: double.parse(value) >= 60.0 ? double.parse(value) + 20 : 60.0);
        break;
      case 'BCM':
        return _vitallownrmlStatus(
            context: context,
            value: value,
            interval: 5.0,
            max: double.parse(value) >= 30.0 ? (double.parse(value) + 20).toInt().toDouble() : 30.0,
            min: 5.0,
            nrmlStart: 20.0,
            nrmlEnd: 50.0,
            lowStart: 0.0,
            lowEnd: 20.0);
        break;
      case 'BFM':
        return _vitalnrmlElevatedHighStatus(
            value: value,
            interval: 10.0,
            max: double.parse(value) >= 50.0 ? double.parse(value) + 20 : 50.0,
            min: 0.0,
            eleStart: gacceptableFatReference + 0.01,
            eleEnd: ghighFatReference,
            nrmlStart: glowFatReference,
            nrmlEnd: gacceptableFatReference,
            highStart: ghighFatReference,
            highEnd: double.parse(value) >= 50.0 ? double.parse(value) + 20 : 50.0);
        // return _vitallownrmlhighStatus(
        //     context: context,
        //     value: value,
        //     interval: 5.0,
        //     max: 50.0,
        //     min: 0.0,
        //     nrmlStart: glowFatReference,
        //     nrmlEnd: ghighFatReference,
        //     highShow: true,
        //     obeseStart: ghighFatReference,
        //     obeseEnd: 50.0);
        break;
      case 'VF':
        return _viseralFat(
          context: context,
          value: value,
          interval: 50.0,
          max: double.parse(value) >= 200.0 ? double.parse(value) + 20 : 200.0,
          min: 1.0,
          nrmlStart: 1.0,
          nrmlEnd: 100.0,
          highShow: true,
          acceptableStart: 101.0,
          acceptableEnd: 120.0,
          obeseStart: 120.0,
          highStart: 120.0,
          i: 0,
          obeseEnd: double.parse(value) >= 200.0 ? double.parse(value) + 20 : 200.0,
        );
        break;
      case 'BMR':
        return _vitallownrmlStatus(
          context: context,
          value: value,
          interval: 300.0,
          max: double.parse(value) >= 2500.0 ? double.parse(value) + 100.0 : 2500.0,
          min: 1000.0,
          lowStart: 0.0,
          lowEnd: 1200.00,
          nrmlStart: 1200.0,
          nrmlEnd: double.parse(value) >= 2500.0 ? double.parse(value) + 100.0 : 2500.0,
        );
        break;
      case 'WtHR':
        return _vitallownrmlhighStatus(
          context: context,
          value: value,
          interval: 1.0,
          max: double.parse(value) >= 4.0 ? double.parse(value) + 2 : 4.0,
          min: 0.2,
          nrmlStart: gwaisttoheightratiolow,
          nrmlEnd: gwaisttoheightratiohigh,
          highShow: true,
          obeseStart: gwaisttoheightratiohigh,
          obeseEnd: double.parse(value) >= 4.0 ? double.parse(value) + 2 : 4.0,
        );
        break;
      case 'WAIST HIP':
        return _vitallownrmlhighStatus(
          context: context,
          value: value,
          interval: 0.4,
          max: double.parse(value) >= 3.0 ? double.parse(value) + 2 : 3.0,
          min: 0.2,
          nrmlStart: 0.80,
          nrmlEnd: 0.90,
          highShow: true,
          obeseStart: 0.90,
          obeseEnd: double.parse(value) >= 3.0 ? double.parse(value) + 2 : 3.0,
        );
        break;
      case 'TEMP':
        return _vitallownrmlhighStatus(
            context: context,
            value: value,
            interval: 5.0,
            max: double.parse(value) >= 115.0 ? double.parse(value) + 10 : 115.0,
            min: 85.0,
            nrmlStart: 95.00,
            nrmlEnd: 99.50,
            highShow: true,
            obeseStart: 99.50,
            obeseEnd: double.parse(value) >= 115.0 ? double.parse(value) + 10 : 115.0);

        break;
      case 'PULSE':
        return _vitallownrmlhighStatus(
            context: context,
            interval: 25.0,
            min: 20.0,
            max: double.parse(value) >= 120.0 ? double.parse(value) + 20 : 120.0,
            nrmlStart: 60.0,
            nrmlEnd: 99.00,
            obeseStart: 99.00,
            obeseEnd: double.parse(value) >= 120.0 ? double.parse(value) + 20 : 120.0,
            value: value,
            highShow: true,
            isPulse: true);
        break;
      case 'FAT':
        return _vitallownrmlhighStatus(
          context: context,
          value: value,
          interval: 10.0,
          max: double.parse(value) >= 50.0 ? double.parse(value) + 20 : 50.0,
          min: 0.0,
          nrmlStart: glowFatReference,
          nrmlEnd: ghighFatReference,
          highShow: true,
          obeseStart: ghighFatReference,
          obeseEnd: double.parse(value) >= 50.0 ? double.parse(value) + 20 : 50.0,
        );
        break;
      case 'ECG':
        return _vitalnrmlHighStatus(
          context: context,
          value: value,
          interval: 20.0,
          min: 60.0,
          max: double.parse(value) >= 150.0 ? double.parse(value) + 20 : 150.0,
          nrmlStart: 60.0,
          nrmlEnd: 100.0,
          highStart: 100.0,
          highEnd: double.parse(value) >= 150.0 ? double.parse(value) + 20 : 150.0,
        );
        break;

      case 'BP':
        var a = value.split('/');
        return _vitalNrmlAcceptableClinicalHighStatus(
          isBp: true,
          context: context,
          value: a[0],
          interval: 10.0,
          max: double.parse(a[0]) >= 150.0 ? double.parse(a[0]) + 20 : 150.0,
          min: 80.0,
          nrmlStart: 30.00,
          nrmlEnd: 129.00,
          accStart: 130.0,
          accEnd: 139.00,
          ClinicalStart: 140.00,
        );
        break;
      default:
        return const Text('No Range Found');
    }
  }

  Widget _vitalnrmlHighStatus(
      {value,
      BuildContext context,
      nrmlStart,
      nrmlEnd,
      highStart,
      highEnd,
      interval,
      min,
      max,
      bool isBp}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(height: 15.px),
        SizedBox(
          width: 80.w,
          child: SfLinearGauge(
              axisLabelStyle:
                  TextStyle(fontFamily: "Poppins", color: Colors.black, fontSize: 12.px),
              interval: interval,
              ranges: <LinearGaugeRange>[
                LinearGaugeRange(
                  startValue: nrmlStart,
                  endValue: nrmlEnd,
                  color: colorForStatus('Normal'),
                ),
                LinearGaugeRange(
                  startValue: highStart,
                  endValue: double.parse(value) > highEnd
                      ? (double.parse(value).toInt() + 5).toDouble()
                      : highEnd,
                  color: colorForStatus('Obese'),
                ),
              ],
              minimum: min,
              maximum:
                  double.parse(value) > max ? (double.parse(value).toInt() + 5).toDouble() : max,
              markerPointers: isBp ?? false
                  ? [
                      LinearWidgetPointer(
                        value: double.parse(value),
                        position: LinearElementPosition.outside,
                        dragBehavior: LinearMarkerDragBehavior.constrained,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Systolic"),
                            Icon(
                              Icons.arrow_drop_down_outlined,
                              size: 8.w,
                            )
                          ],
                        ),
                      ),
                    ]
                  : [LinearShapePointer(value: double.parse(value))]),
        ),
        SizedBox(height: 15.px),
        statusInfo(
            title: 'Normal',
            value: "${nrmlStart.toStringAsFixed(2)}-${nrmlEnd.toStringAsFixed(2)}"),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       primary: colorForStatus('Normal'),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(5.0),
        //       ),
        //     ),
        //     child: Text(
        //       'Normal : $nrmlStart - $nrmlEnd',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     onPressed: () {
        //       //  Navigator.pop(context);
        //     },
        //   ),
        // ),
        SizedBox(height: 15.px),
        statusInfo(
            title: "High",
            color: colorForStatus('Obese'),
            value: highStart.toStringAsFixed(2),
            differentStyle: true),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.6,
        //   // Will take 50% of screen space
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       primary: colorForStatus('Obese'),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(5.0),
        //       ),
        //     ),
        //     child: Text(
        //       'High : $highStart and above',
        //       style: TextStyle(
        //         color: Colors.white,
        //       ),
        //     ),
        //     onPressed: () {
        //       //  Navigator.pop(context);
        //     },
        //   ),
        // ),
        SizedBox(height: 10.px)
      ],
    );
  }

  Widget _vitallownrmlhighStatus(
      {String value,
      BuildContext context,
      obeseStart,
      obeseEnd,
      nrmlStart,
      nrmlEnd,
      interval,
      min,
      max,
      bool highShow,
      bool isPulse}) {
    isPulse = isPulse ?? false;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: 15.px),
        SizedBox(
          width: 80.w,
          child: SfLinearGauge(
              axisLabelStyle:
                  TextStyle(fontFamily: "Poppins", color: Colors.black, fontSize: 12.px),
              interval: interval,
              ranges: <LinearGaugeRange>[
                LinearGaugeRange(
                  startValue: min,
                  endValue: nrmlStart,
                  color: colorForStatus('Underweight'),
                ),
                LinearGaugeRange(
                  startValue: nrmlStart,
                  endValue: nrmlEnd,
                  color: colorForStatus('Normal'),
                ),
                highShow
                    ? LinearGaugeRange(
                        startValue: nrmlEnd,
                        endValue: double.parse(value) > max
                            ? (double.parse(value).toInt() + 5).toDouble()
                            : max,
                        color: colorForStatus('Obese'),
                      )
                    : LinearGaugeRange(startValue: 0, endValue: 0, color: colorForStatus('Normal')),
              ],
              minimum: min,
              maximum:
                  double.parse(value) > max ? (double.parse(value).toInt() + 5).toDouble() : max,
              markerPointers: [LinearShapePointer(value: double.parse(value))]),
        ),
        SizedBox(height: 15.px),
        isPulse
            ? statusInfo(
                title: "Low",
                prefix: "< ",
                value: "${nrmlStart.toStringAsFixed(0)}",
                color: colorForStatus('Underweight'))
            : statusInfo(
                title: "Low",
                prefix: "< ",
                value: "${nrmlStart.toStringAsFixed(2)}",
                color: colorForStatus('Underweight')),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       primary: colorForStatus('Underweight'),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(5.0),
        //       ),
        //     ),
        //     child: Text(
        //       'Low : Below $nrmlStart',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     onPressed: () {
        //       // Navigator.pop(context);
        //     },
        //   ),
        // ),
        SizedBox(height: 15.px),
        isPulse
            ? statusInfo(
                title: 'Normal',
                value: "${nrmlStart.toStringAsFixed(0)} - ${nrmlEnd.toStringAsFixed(0)}")
            : statusInfo(
                title: 'Normal',
                value: "${nrmlStart.toStringAsFixed(2)}-${nrmlEnd.toStringAsFixed(2)}"),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       primary: colorForStatus('Normal'),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(5.0),
        //       ),
        //     ),
        //     child: Text(
        //       'Normal : $nrmlStart - $nrmlEnd',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     onPressed: () {
        //       // Navigator.pop(context);
        //     },
        //   ),
        // ),
        SizedBox(height: 15.px),
        highShow
            ? isPulse
                ? statusInfo(
                    title: "High",
                    prefix: "> ",
                    value: "${obeseStart.toStringAsFixed(0)}",
                    differentStyle: true,
                    color: colorForStatus('Obese'))
                : statusInfo(
                    title: "High",
                    prefix: "> ",
                    value: "${obeseStart.toStringAsFixed(2)}",
                    differentStyle: true,
                    color: colorForStatus('Obese'))
            // Container(
            //     width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         primary: colorForStatus('Obese'),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(5.0),
            //         ),
            //       ),
            //       child: Text(
            //         'High : $nrmlEnd above ',
            //         style: TextStyle(color: Colors.white),
            //       ),
            //       onPressed: () {
            //         // Navigator.pop(context);
            //       },
            //     ),
            //   )
            : const SizedBox.shrink(),
        SizedBox(height: 15.px)
      ],
    );
  }

  Widget _viseralFat(
      {String value,
      BuildContext context,
      obeseStart,
      obeseEnd,
      nrmlStart,
      acceptableStart,
      acceptableEnd,
      nrmlEnd,
      interval,
      highStart,
      min,
      max,
      bool highShow,
      int i,
      bool isPulse}) {
    isPulse = isPulse ?? false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: 15.px),
        SizedBox(
          width: 80.w,
          child: SfLinearGauge(
              axisLabelStyle:
                  TextStyle(fontFamily: "Poppins", color: Colors.black, fontSize: 12.px),
              interval: interval,
              ranges: <LinearGaugeRange>[
                LinearGaugeRange(
                  startValue: nrmlStart,
                  endValue: nrmlEnd + 1,
                  color: colorForStatus('Normal'),
                ),
                LinearGaugeRange(
                  startValue: acceptableStart,
                  endValue: acceptableEnd,
                  color: colorForStatus('Acceptable'),
                ),
                highShow
                    ? LinearGaugeRange(
                        startValue: highStart,
                        endValue: max,
                        color: colorForStatus('High'),
                      )
                    : LinearGaugeRange(startValue: 0, endValue: 0, color: colorForStatus('Normal')),
              ],
              // : [LinearBarPointer(value: 10),LinearBarPointer(value: 13)],

              minimum: min,
              maximum:
                  double.parse(value) > max ? (double.parse(value).toInt() + 5).toDouble() : max,
              markerPointers: [LinearShapePointer(value: double.parse(value))]),
        ),
        SizedBox(height: 15.px),
        isPulse
            ? statusInfo(
                title: "Normal",
                value: "${nrmlStart.toStringAsFixed(0)}-${nrmlEnd.toStringAsFixed(0)}",
                color: colorForStatus('Normal'))
            : statusInfo(
                title: "Normal",
                // prefix: "< ",
                value: "${nrmlStart.toStringAsFixed(0)}-${nrmlEnd.toStringAsFixed(0)}",
                color: colorForStatus('Normal')),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       primary: colorForStatus('Underweight'),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(5.0),
        //       ),
        //     ),
        //     child: Text(
        //       'Low : Below $nrmlStart',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     onPressed: () {
        //       // Navigator.pop(context);
        //     },
        //   ),
        // ),
        SizedBox(height: 15.px),
        isPulse
            ? statusInfo(
                title: 'Acceptable',
                value: "${acceptableStart.toStringAsFixed(0)}-${acceptableEnd.toStringAsFixed(0)}")
            : statusInfo(
                title: 'Acceptable',
                value: "${acceptableStart.toStringAsFixed(0)}-${acceptableEnd.toStringAsFixed(0)}"),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       primary: colorForStatus('Normal'),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(5.0),
        //       ),
        //     ),
        //     child: Text(
        //       'Normal : $nrmlStart - $nrmlEnd',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     onPressed: () {
        //       // Navigator.pop(context);
        //     },
        //   ),
        // ),
        SizedBox(height: 15.px),
        highShow
            ? isPulse
                ? statusInfo(
                    title: "High",
                    value: highStart.toStringAsFixed(0),
                    differentStyle: true,
                    color: colorForStatus('Obese'))
                : statusInfo(
                    title: "High",
                    prefix: "> ",
                    value: "${highStart.toStringAsFixed(0)}",
                    differentStyle: true,
                    color: colorForStatus('Obese'))
            // Container(
            //     width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         primary: colorForStatus('Obese'),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(5.0),
            //         ),
            //       ),
            //       child: Text(
            //         'High : $nrmlEnd above ',
            //         style: TextStyle(color: Colors.white),
            //       ),
            //       onPressed: () {
            //         // Navigator.pop(context);
            //       },
            //     ),
            //   )
            : const SizedBox.shrink(),
        SizedBox(height: 15.px)
      ],
    );
  }

  Widget _temp(
      {String value,
      obeseStart,
      nrmlStart,
      nrmlEnd,
      interval,
      min,
      max,
      bool highShow,
      bool isPulse}) {
    isPulse = isPulse ?? false;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: 15.px),
        SizedBox(
          width: 80.w,
          child: SfLinearGauge(
              axisLabelStyle:
                  TextStyle(fontFamily: "Poppins", color: Colors.black, fontSize: 12.px),
              interval: interval,
              ranges: <LinearGaugeRange>[
                LinearGaugeRange(
                  startValue: nrmlStart,
                  endValue: nrmlEnd,
                  color: colorForStatus('Normal'),
                ),
                LinearGaugeRange(
                  startValue: nrmlEnd,
                  endValue: double.parse(value) > max
                      ? (double.parse(value).toInt() + 5).toDouble()
                      : max,
                  color: colorForStatus('Obese'),
                )
              ],
              minimum: min,
              maximum:
                  double.parse(value) > max ? (double.parse(value).toInt() + 5).toDouble() : max,
              markerPointers: [LinearShapePointer(value: double.parse(value))]),
        ),
        SizedBox(height: 15.px),
        // isPulse
        //     ? statusInfo(
        //     title: "Low",
        //     value: nrmlStart.toStringAsFixed(0),
        //     color: colorForStatus('Underweight'))
        //     : statusInfo(
        //     title: "Low", value: nrmlStart.toString(), color: colorForStatus('Underweight')),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       primary: colorForStatus('Underweight'),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(5.0),
        //       ),
        //     ),
        //     child: Text(
        //       'Low : Below $nrmlStart',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     onPressed: () {
        //       // Navigator.pop(context);
        //     },
        //   ),
        // ),
        SizedBox(height: 15.px),
        isPulse
            ? statusInfo(
                title: 'Normal',
                value: "${nrmlStart.toStringAsFixed(0)}-${nrmlEnd.toStringAsFixed(0)}")
            : statusInfo(title: 'Normal', value: "$nrmlStart-$nrmlEnd"),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       primary: colorForStatus('Normal'),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(5.0),
        //       ),
        //     ),
        //     child: Text(
        //       'Normal : $nrmlStart - $nrmlEnd',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     onPressed: () {
        //       // Navigator.pop(context);
        //     },
        //   ),
        // ),
        SizedBox(height: 15.px),
        highShow
            ? isPulse
                ? statusInfo(
                    title: "High",
                    value: obeseStart.toStringAsFixed(0),
                    differentStyle: true,
                    color: colorForStatus('Obese'))
                : statusInfo(
                    title: "High",
                    value: obeseStart.toStringAsFixed(2),
                    differentStyle: true,
                    color: colorForStatus('Obese'))
            // Container(
            //     width: MediaQuery.of(context).size.width * 0.6, // Will take 50% of screen space
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         primary: colorForStatus('Obese'),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(5.0),
            //         ),
            //       ),
            //       child: Text(
            //         'High : $nrmlEnd above ',
            //         style: TextStyle(color: Colors.white),
            //       ),
            //       onPressed: () {
            //         // Navigator.pop(context);
            //       },
            //     ),
            //   )
            : const SizedBox.shrink(),
        SizedBox(height: 15.px)
      ],
    );
  }

  Widget _vitalnrmlElevatedHighStatus(
      {value,
      nrmlStart,
      nrmlEnd,
      highStart,
      highEnd,
      eleStart,
      eleEnd,
      interval,
      min,
      max,
      bool isBp}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(height: 15.px),
        SizedBox(
          width: 80.w,
          child: SfLinearGauge(
              axisLabelStyle:
                  TextStyle(fontFamily: "Poppins", color: Colors.black, fontSize: 12.px),
              interval: interval,
              ranges: <LinearGaugeRange>[
                LinearGaugeRange(
                  startValue: 0.0,
                  endValue: nrmlEnd,
                  color: colorForStatus('Low'),
                ),
                LinearGaugeRange(
                  startValue: nrmlStart,
                  endValue: nrmlEnd,
                  color: colorForStatus('Normal'),
                ),
                LinearGaugeRange(
                  startValue: eleStart,
                  endValue: eleEnd,
                  color: colorForStatus('Acceptable'),
                ),
                LinearGaugeRange(
                  startValue: highStart,
                  endValue: double.parse(value) > highEnd
                      ? (double.parse(value).toInt() + 5).toDouble()
                      : highEnd,
                  color: colorForStatus('Obese'),
                ),
              ],
              minimum: min,
              maximum: max,
              // double.parse(value) > max ? (double.parse(value).toInt() + 5).toDouble() : max,
              markerPointers: isBp ?? false
                  ? [
                      LinearWidgetPointer(
                        value: double.parse(value),
                        position: LinearElementPosition.outside,
                        dragBehavior: LinearMarkerDragBehavior.constrained,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Systolic"),
                            Icon(
                              Icons.arrow_drop_down_outlined,
                              size: 8.w,
                            )
                          ],
                        ),
                      ),
                    ]
                  : [LinearShapePointer(value: double.parse(value))]),
        ),
        SizedBox(height: 15.px),
        statusInfo(title: 'Low', prefix: "< ", value: "${nrmlStart.toStringAsFixed(2)}"),
        SizedBox(height: 15.px),
        statusInfo(
            title: 'Normal',
            value: "${nrmlStart.toStringAsFixed(2)}-${nrmlEnd.toStringAsFixed(2)}"),
        SizedBox(height: 15.px),
        statusInfo(
            title: 'Acceptable',
            value: "${eleStart.toStringAsFixed(2)}-${eleEnd.toStringAsFixed(2)}"),
        SizedBox(height: 15.px),
        statusInfo(
            title: "High",
            color: colorForStatus('Obese'),
            prefix: "> ",
            value: "${highStart.toStringAsFixed(2)}",
            differentStyle: true),
        SizedBox(height: 10.px)
      ],
    );
  }

  Widget _vitalNrmlAcceptableClinicalHighStatus(
      {value,
      BuildContext context,
      nrmlStart,
      nrmlEnd,
      ClinicalStart,
      accStart,
      accEnd,
      interval,
      min,
      max,
      bool isBp}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 15.px),
        SizedBox(
          width: 90.w,
          child: SfLinearGauge(
              axisLabelStyle:
                  TextStyle(fontFamily: "Poppins", color: Colors.black, fontSize: 12.px),
              interval: interval,
              ranges: <LinearGaugeRange>[
                LinearGaugeRange(
                  startValue: nrmlStart,
                  endValue: nrmlEnd + 0.99,
                  color: colorForStatus('Normal'),
                ),
                LinearGaugeRange(
                  startValue: accStart,
                  endValue: accEnd + 0.99,
                  color: colorForStatus('Acceptable'),
                ),
                LinearGaugeRange(
                  startValue: ClinicalStart,
                  endValue: max,
                  color: colorForStatus('Obese'),
                ),
              ],
              minimum: min,
              maximum:
                  double.parse(value) > max ? (double.parse(value).toInt() + 5).toDouble() : max,
              markerPointers: isBp ?? false
                  ? [
                      LinearWidgetPointer(
                        value: double.parse(value),
                        position: LinearElementPosition.outside,
                        dragBehavior: LinearMarkerDragBehavior.constrained,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Systolic"),
                            Icon(
                              Icons.arrow_drop_down_outlined,
                              size: 8.w,
                            )
                          ],
                        ),
                      ),
                    ]
                  : [LinearShapePointer(value: double.parse(value))]),
        ),
        SizedBox(height: 15.px),
        statusInfo(title: 'Normal', prefix: "≤ ", value: "${nrmlEnd.toStringAsFixed(0)}"),
        SizedBox(height: 15.px),
        statusInfo(
            title: 'Acceptable',
            value: "${accStart.toStringAsFixed(0)}-${accEnd.toStringAsFixed(0)}"),
        SizedBox(height: 15.px),
        statusInfo(
            title: "Clinical Screening Recommended",
            color: colorForStatus('Obese'),
            prefix: "≥ ",
            value: '${ClinicalStart.toStringAsFixed(0)}',
            differentStyle: true),
        SizedBox(height: 10.px)
      ],
    );
  }

  Widget _vitalowlnrmlElevatedHighStatus(
      {value,
      lowEnd,
      nrmlStart,
      nrmlEnd,
      highStart,
      highEnd,
      eleStart,
      eleEnd,
      interval,
      min,
      max,
      bool isBp}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(height: 15.px),
        SizedBox(
          width: 80.w,
          child: SfLinearGauge(
              axisLabelStyle:
                  TextStyle(fontFamily: "Poppins", color: Colors.black, fontSize: 12.px),
              interval: interval,
              ranges: <LinearGaugeRange>[
                LinearGaugeRange(
                  startValue: 1.0,
                  endValue: lowEnd + 0.99,
                  color: colorForStatus('Low'),
                ),
                LinearGaugeRange(
                  startValue: nrmlStart,
                  endValue: nrmlEnd + 0.99,
                  color: colorForStatus('Normal'),
                ),
                LinearGaugeRange(
                  startValue: eleStart,
                  endValue: eleEnd + 0.99,
                  color: colorForStatus('Elevated'),
                ),
                LinearGaugeRange(
                  startValue: highStart,
                  endValue: double.parse(value) > highEnd
                      ? (double.parse(value).toInt() + 5).toDouble()
                      : highEnd,
                  color: colorForStatus('High'),
                ),
              ],
              minimum: min,
              maximum:
                  double.parse(value) > max ? (double.parse(value).toInt() + 5).toDouble() : max,
              markerPointers: isBp ?? false
                  ? [
                      LinearWidgetPointer(
                        value: double.parse(value),
                        position: LinearElementPosition.outside,
                        dragBehavior: LinearMarkerDragBehavior.constrained,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Systolic"),
                            Icon(
                              Icons.arrow_drop_down_outlined,
                              size: 8.w,
                            )
                          ],
                        ),
                      ),
                    ]
                  : [LinearShapePointer(value: double.parse(value))]),
        ),
        SizedBox(height: 15.px),
        statusInfo(title: 'Low', value: "${lowEnd.toStringAsFixed(0)}"),
        SizedBox(height: 15.px),
        statusInfo(
            title: 'Normal',
            value: "${nrmlStart.toStringAsFixed(0)}-${nrmlEnd.toStringAsFixed(0)}"),
        SizedBox(height: 15.px),
        statusInfo(
            title: 'Elevated',
            value: "${eleStart.toStringAsFixed(0)}-${eleEnd.toStringAsFixed(0)}"),
        SizedBox(height: 15.px),
        statusInfo(
            title: "High",
            color: colorForStatus('Obese'),
            value: highStart.toStringAsFixed(0),
            differentStyle: true),
        SizedBox(height: 10.px)
      ],
    );
  }

  double maximumValueSetter({double value}) {
    String val = value.toStringAsFixed(2);
    String val1 = val.substring(0, val.length - 1);
    double doublevalue1 = double.parse(val1);
    doublevalue1 = doublevalue1 + 1;

    // val = doublevalue1 > 90 ? "130" : 100;
    val = "${doublevalue1 + 10}";
    return double.parse(val);
  }

  defaultValueSetter() {
    firstDayofLastSevendays =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .subtract(const Duration(days: 7));
    seventhDayofLastSevendays =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .add(const Duration(days: 1))
            .subtract(const Duration(minutes: 1));
    firstYear = DateTime(DateTime.now().year, 1, 1);
    lastYear = DateTime(DateTime.now().year, 12, 31);
    startOfWeek = currentweekDayFinder();
    endOfWeek =
        currentweekDayFinder().add(const Duration(days: 7)).subtract(const Duration(minutes: 1));
  }

  static String imageforVital({String vitalName}) {
    if (vitalName.toLowerCase().contains("bmi")) return "BMI";
    if (vitalName.toLowerCase().contains("weight")) return "Weight";
    if (vitalName.toLowerCase().contains("ecw")) return "ECW";
    if (vitalName.toLowerCase().contains("icw")) return "ICW";
    if (vitalName.toLowerCase().contains("bfm")) return "BFM";
    if (vitalName.toLowerCase().contains("bcm")) return "BCM";
    if (vitalName.toLowerCase().contains("waist hip")) return "Waist Hip";
    if (vitalName.toLowerCase().contains("pbf")) return "PBF";
    if (vitalName.toLowerCase().contains("wthr")) return "WtHR";
    if (vitalName.toLowerCase().contains("bmc")) return "BMC";
    if (vitalName.toLowerCase().contains("mineral")) return "Mineral";
    if (vitalName.toLowerCase().contains("temp")) return "TEMP";
    if (vitalName.toLowerCase().contains("bp")) return "BP";
    if (vitalName.toLowerCase().contains("spo2")) return "SPO2";
    if (vitalName.toLowerCase().contains("pulse")) return "Pulse";
    if (vitalName.toLowerCase().contains("ecg")) return "ECG";
    if (vitalName.toLowerCase().contains("vf")) return "VF";
    if (vitalName.toLowerCase().contains("protein")) return "Protein";
    if (vitalName.toLowerCase().contains("bmr")) return "BMR";
    if (vitalName.toLowerCase().contains("smm")) return "SMM";
    if (vitalName.toLowerCase().contains("cholesterol")) return "Cholesterol";
    return "BMI";
  }
}
