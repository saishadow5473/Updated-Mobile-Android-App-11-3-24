import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/app_colors.dart';
import '../../../../views/dietJournal/calorieGraph/monthly_calorie_tab.dart';
import '../../../app/utils/imageAssets.dart';
import '../../../data/functions/healthJounralFunctions.dart';
import '../../clippath/customGraph.dart';
import 'package:collection/collection.dart';

class NormalHealthJournalWidgets {
  static bool myInsightLoader = false;
  static int time = 0;
  static ValueNotifier<String> selectedCategory = ValueNotifier("Breakfast");
  static ValueNotifier<String> currentIndexValue = ValueNotifier("Day");
  static List<String> contents = ["Day", "Weekly", "Monthly"];
  static List datas = [];
  static List<Map> historyData = [];
  static List<DateTime> currentFreq = constantDate.dayFre;
  static Widget graphHealthJournalIndividual({List datatoDisplay}) {
    historyData = [];
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 3,
                    spreadRadius: 3,
                    offset: Offset(1, 1))
              ]),
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: contents
                          .map(
                            (e) => InkWell(
                                onTap: () async {
                                  time = 0;
                                  // if (e == "Day") {
                                  datas = [];
                                  currentIndexValue.value = e;
                                  if (e != "Day") {
                                    NormalDateTimeFormat.dayFre = constantDate.dayFre;
                                  } else {
                                    currentFreq = constantDate.dayFre;
                                    datas = await HealthJournalFunctions.singleGraphValue(
                                        dateFreq: constantDate.dayFre);
                                  }
                                  if (e != "Monthly") {
                                    NormalDateTimeFormat.monthFre = constantDate.monthFre;
                                  } else {
                                    currentFreq = constantDate.monthFre;
                                    datas = await HealthJournalFunctions.singleGraphValue(
                                        dateFreq: constantDate.monthFre);
                                  }
                                  if (e != "Weekly") {
                                    NormalDateTimeFormat.weekFre = constantDate.weekFre;
                                  } else {
                                    currentFreq = constantDate.weekFre;
                                    datas = await HealthJournalFunctions.singleGraphValue(
                                        dateFreq: constantDate.weekFre);
                                  }
                                  currentIndexValue.notifyListeners();
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  padding: EdgeInsets.only(bottom: 3),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 1.5,
                                              color: currentIndexValue.value == e
                                                  ? AppColors.primaryColor
                                                  : Colors.transparent))),
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                        fontWeight: currentIndexValue.value == e
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                        color: currentIndexValue.value == e
                                            ? AppColors.primaryColor
                                            : Colors.black),
                                  ),
                                )),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 12.px),
                  graphContentIndividual(graphData: datatoDisplay),
                ],
              )),
          SizedBox(height: 15.px),
          if (datatoDisplay.isNotEmpty)
            ...historyData.reversed
                .map((e) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e["name"],
                            style: TextStyle(
                                letterSpacing: 0.3,
                                fontSize: 15.px,
                                fontWeight: FontWeight.normal,
                                color: Color(0XFF333333)),
                          ),
                          SizedBox(
                            height: 8.w,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    ImageAssets.calConsumed,
                                    height: 5.w,
                                    width: 5.w,
                                    color: AppColors.primaryAccentColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text("${e["value"].toString()} Cal",
                                      style: TextStyle(
                                          fontSize: 13.px,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54)),
                                ]),
                          ),
                          SizedBox(height: 5.w)
                          // Divider(),
                        ],
                      ),
                    ))
                .toList(),
          SizedBox(height: 5.h),
        ],
      ),
    );
  }

  static graphContentIndividual({List graphData, Color color}) {
    List<Map> days = [];
    List<int> yAxisData = [];
    var i;
    var ss = [];
    if (graphData.isNotEmpty) {
      days = [];
      for (ChartData chartData in graphData) {
        days.add({"day": chartData.x, "value": chartData.y, "name": chartData.category});
      }

      ss = ss + days;
      ss.sort(((a, b) => (b["value"]).compareTo(a["value"])));
      i = ss.first["value"];
      if (i < 10) {
        yAxisData = [3, 6, 10];
      } else {
        yAxisData = [
          double.parse((i + (i / 10)).toString()).toInt(),
          double.parse((i / 2).toString()).toInt(),
          double.parse((i / 3).toString()).toInt()
        ];
      }
    }
    List<int> allValues = [];
    ss.map((e) => allValues.add(e["value"])).toList();
    int fullKcal = allValues.sum;
    historyData = days;
    // kCalNumber = days.sort((a, b) => (b['day']).compareTo(a['value']));
    ValueNotifier<bool> showArrowShimmer = ValueNotifier<bool>(false);
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: showArrowShimmer,
              builder: (BuildContext context, bool arrowShimmer, Widget widget) {
                return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  if (arrowShimmer)
                    InkWell(
                        onTap: null,
                        child: Shimmer.fromColors(
                            direction: ShimmerDirection.rtl,
                            period: const Duration(seconds: 1),
                            baseColor: Colors.blue.withOpacity(0.2),
                            highlightColor: Colors.blue,
                            child: const Icon(Icons.arrow_back_ios_new_rounded)))
                  else
                    InkWell(
                        onTap: () async {
                          time++;
                          showArrowShimmer.value = true;
                          if (currentIndexValue.value == "Monthly") {
                            List<DateTime> date = HealthJournalFunctions.dateCalculatorSingle(
                              forword: false,
                              start: NormalDateTimeFormat.monthFre.first,
                              end: NormalDateTimeFormat.monthFre[1],
                            );
                            NormalDateTimeFormat.monthFre = date;
                            datas = await HealthJournalFunctions.singleGraphValue(
                                dateFreq: NormalDateTimeFormat.monthFre);
                            currentFreq = date;
                          } else if (currentIndexValue.value == "Weekly") {
                            List<DateTime> date = HealthJournalFunctions.dateCalculatorSingle(
                              forword: false,
                              start: NormalDateTimeFormat.weekFre.first,
                              end: NormalDateTimeFormat.weekFre[1],
                            );
                            NormalDateTimeFormat.weekFre = date;
                            datas = await HealthJournalFunctions.singleGraphValue(
                                dateFreq: NormalDateTimeFormat.weekFre);
                            currentFreq = date;
                          } else {
                            List<DateTime> date = HealthJournalFunctions.dateCalculatorSingle(
                              forword: false,
                              start: NormalDateTimeFormat.dayFre.first,
                              end: NormalDateTimeFormat.dayFre[1],
                            );
                            NormalDateTimeFormat.dayFre = date;
                            currentFreq = NormalDateTimeFormat.dayFre;
                            datas = await HealthJournalFunctions.singleGraphValue(
                                dateFreq: NormalDateTimeFormat.dayFre);
                            currentFreq = date;
                          }
                          Timer(const Duration(seconds: 1), () {
                            showArrowShimmer.value = false;
                          });
                          currentIndexValue.notifyListeners();
                        },
                        child: Icon(Icons.arrow_back_ios_new_rounded)),
                  Container(
                      width: 70.w,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        dateText(dateData: currentFreq),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Image.asset(
                            ImageAssets.calConsumed,
                            height: 5.h,
                            width: 5.w,
                            color: AppColors.primaryAccentColor,
                          ),
                          SizedBox(width: 8),
                          Text("${fullKcal ?? 0} Cal"),
                        ])
                      ])),
                  if (time != 0)
                    if (arrowShimmer)
                      InkWell(
                          onTap: null,
                          child: Shimmer.fromColors(
                              direction: ShimmerDirection.rtl,
                              period: const Duration(seconds: 1),
                              baseColor: Colors.blue.withOpacity(0.2),
                              highlightColor: Colors.blue,
                              child: const Icon(Icons.arrow_forward_ios_rounded)))
                    else
                      InkWell(
                          onTap: () async {
                            time--;
                            showArrowShimmer.value = true;
                            if (currentIndexValue.value == "Monthly") {
                              List<DateTime> date = HealthJournalFunctions.dateCalculatorSingle(
                                forword: true,
                                start: NormalDateTimeFormat.monthFre.first,
                                end: NormalDateTimeFormat.monthFre[1],
                              );
                              NormalDateTimeFormat.monthFre = date;
                              datas = await HealthJournalFunctions.singleGraphValue(
                                  dateFreq: NormalDateTimeFormat.monthFre);
                              currentFreq = date;
                            } else if (currentIndexValue.value == "Weekly") {
                              List<DateTime> date = HealthJournalFunctions.dateCalculatorSingle(
                                forword: true,
                                start: NormalDateTimeFormat.weekFre.first,
                                end: NormalDateTimeFormat.weekFre[1],
                              );
                              NormalDateTimeFormat.weekFre = date;
                              datas = await HealthJournalFunctions.singleGraphValue(
                                  dateFreq: NormalDateTimeFormat.weekFre);
                              currentFreq = date;
                            } else {
                              List<DateTime> date = HealthJournalFunctions.dateCalculatorSingle(
                                forword: true,
                                start: NormalDateTimeFormat.dayFre.first,
                                end: NormalDateTimeFormat.dayFre[1],
                              );
                              NormalDateTimeFormat.dayFre = date;
                              datas = await HealthJournalFunctions.singleGraphValue(
                                  dateFreq: NormalDateTimeFormat.dayFre);
                              currentFreq = date;
                            }
                            Timer(const Duration(seconds: 1), () {
                              showArrowShimmer.value = false;
                            });
                            currentIndexValue.notifyListeners();
                          },
                          child: Icon(Icons.arrow_forward_ios_rounded))
                  else
                    InkWell(
                        child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey,
                    ))
                ]);
              }),
          if (graphData.isNotEmpty && fullKcal != 0 && myInsightLoader == false)
            CustomGraphSingle(
                xAxisFields: days,
                barColor: selectedCategory.value == "Breakfast"
                    ? Color(0XFFF15B3A)
                    : selectedCategory.value == "Lunch"
                        ? Color(0XFF2EC6DE)
                        : selectedCategory.value == "Snacks"
                            ? Color(0XFFFE6292)
                            : Color(0XFF383387),
                yAxixFields: yAxisData),
          if (graphData.isEmpty && myInsightLoader)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Shimmer.fromColors(
                  direction: ShimmerDirection.ltr,
                  period: Duration(seconds: 2),
                  baseColor: Color.fromARGB(255, 240, 240, 240),
                  highlightColor: Colors.grey.withOpacity(0.2),
                  child: Container(
                      height: 25.h,
                      width: 95.w,
                      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Text('Hello'))),
            ),
          if ((graphData.isEmpty || fullKcal == 0) && myInsightLoader == false)
            Container(
              height: 26.h,
              width: 100.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied_rounded,
                    size: 30.w,
                    color: AppColors.primaryAccentColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "No Food Log !",
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryAccentColor,
                        fontFamily: 'Poppins',
                        letterSpacing: 0.8),
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Text dateText({List<DateTime> dateData}) {
    if (currentIndexValue.value == "Monthly") {
      return Text(
        "${DateFormat('yyyy').format(dateData.first)} - ${DateFormat('yyyy').format(dateData[1])}",
        style: TextStyle(fontSize: 15.px, fontWeight: FontWeight.w500),
      );
    } else if (currentIndexValue.value == "Weekly") {
      return Text(
        "${DateFormat('d MMM').format(dateData.first)} - ${DateFormat('d MMM yyyy').format(dateData[1])}",
        // "${DateFormat('EEE, d MMM, yyyy').format(dateData.first)} - 4 Feb 2023",
        style: TextStyle(fontSize: 15.px, fontWeight: FontWeight.w500),
      );
    } else {
      return Text(
        "${DateFormat('EEEE, d MMMM').format(dateData.first)}",
        style: TextStyle(fontSize: 15.px, fontWeight: FontWeight.w500),
      );
    }
  }
}

class NormalDateTimeFormat {
  static List<DateTime> dayFre = [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59),
  ];
  static List<DateTime> monthFre = [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59)
        .subtract(Duration(days: 365)),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59),
  ];
  static List<DateTime> weekFre = [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59)
        .subtract(Duration(days: 6)),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59),
  ];
}

class constantDate {
  static List<DateTime> dayFre = [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59),
  ];
  static List<DateTime> monthFre = [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59)
        .subtract(Duration(days: 365)),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59),
  ];
  static List<DateTime> weekFre = [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59)
        .subtract(Duration(days: 6)),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59),
  ];
}
