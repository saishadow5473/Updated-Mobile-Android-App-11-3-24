import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/new_design/data/model/healthJournalModel/healthJournalAllMealsWeeklyModel.dart';
import 'package:ihl/new_design/presentation/Widgets/healthjournalWidgets/normalHealthJournalWidgets.dart';
import 'package:ihl/views/dietJournal/calorieGraph/monthly_calorie_tab.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/utils/imageAssets.dart';
import '../../../data/functions/healthJounralFunctions.dart';
import '../../clippath/customGraph.dart';
import '../../clippath/customGraphAllMeals.dart';
import 'package:collection/collection.dart';

class MyInsightsWidgets {
  static int time = 0;
  static ValueNotifier<String> myInsigtschanged = ValueNotifier("Day");
  static List<String> contents = ["Day", "Weekly", "Monthly"];
  static List<Map> categoriesList = [
    {"name": "Breakfast", "color": Color(0XFFF15B3A)},
    {"name": "Lunch", "color": Color(0XFF2EC6DE)},
    {"name": "Snacks", "color": Color(0XFFFE6292)},
    {"name": "Dinner", "color": Color(0XFF383387)},
  ];
  static List<Map> historyData = [];
  static List keys = ["All Meals", "Breakfast", "Lunch", "Snacks", "Dinner"];
  static List myInsigtsdatas = [];
  static ValueNotifier<int> selectedIndex = ValueNotifier(0);
  static List<DateTime> allMealsfreq = constantDate.dayFre;
  static Widget graphMyInsights({List datatoDisplay}) {
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
                            (String e) => InkWell(
                                onTap: () async {
                                  time = 0;
                                  myInsigtsdatas = [];
                                  myInsigtschanged.value = e;
                                  if (e != "Day") {
                                    DateTimeHolderForMyInsights.dayFre = constantDate.dayFre;
                                  } else {
                                    allMealsfreq = DateTimeHolderForMyInsights.dayFre;
                                    myInsigtsdatas = await HealthJournalFunctions.allDataGraphValue(
                                        selectedCate: ["Breakfast", "Lunch", "Snacks", "Dinner"],
                                        dateFreq: DateTimeHolderForMyInsights.dayFre);
                                  }
                                  if (e != "Monthly") {
                                    DateTimeHolderForMyInsights.monthFre = constantDate.monthFre;
                                  } else {
                                    allMealsfreq = DateTimeHolderForMyInsights.monthFre;
                                    myInsigtsdatas = await HealthJournalFunctions.allDataGraphValue(
                                        selectedCate: ["Breakfast", "Lunch", "Snacks", "Dinner"],
                                        dateFreq: DateTimeHolderForMyInsights.monthFre);
                                  }
                                  if (e != "Weekly") {
                                    DateTimeHolderForMyInsights.weekFre = constantDate.weekFre;
                                  } else {
                                    allMealsfreq = DateTimeHolderForMyInsights.weekFre;
                                    myInsigtsdatas = await HealthJournalFunctions.allDataGraphValue(
                                        selectedCate: ["Breakfast", "Lunch", "Snacks", "Dinner"],
                                        dateFreq: DateTimeHolderForMyInsights.weekFre);
                                  }
                                  myInsigtschanged.notifyListeners();
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  padding: EdgeInsets.only(bottom: 3),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 1.5,
                                              color: myInsigtschanged.value == e
                                                  ? AppColors.primaryColor
                                                  : Colors.transparent))),
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                        fontWeight: myInsigtschanged.value == e
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                        color: myInsigtschanged.value == e
                                            ? AppColors.primaryColor
                                            : Colors.black),
                                  ),
                                )),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 12.px),
                  graphContentforMyInsights(
                    catog: myInsigtschanged.value,
                    graphData: datatoDisplay,
                  ),
                  SizedBox(height: 12.px),
                  if (myInsigtschanged.value != "Monthly")
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: categoriesList
                            .map((Map e) => Row(
                                  children: [
                                    Container(
                                      height: 3.w,
                                      width: 3.w,
                                      decoration:
                                          BoxDecoration(color: e["color"], shape: BoxShape.circle),
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(e["name"]),
                                  ],
                                ))
                            .toList()),
                  SizedBox(height: 12.px),
                ],
              )),
          SizedBox(height: 16.px),
          ...historyData
              .map((Map e) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          myInsigtschanged.value == "Weekly"
                              ? e["name"]
                              : (e["xValue"] ?? e["day"]),
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
          SizedBox(height: 9.h)
        ],
      ),
    );
  }

  static graphContentforMyInsights({List graphData, String catog}) {
    List<Map> categorys = [];
    int i = 0;
    List<int> yAxisData = [];
    int fullKcal;
    if (catog == "Day") {
      if (graphData != null || graphData.isNotEmpty) {
        for (ChartData chartData in graphData) {
          categorys.add({"xValue": chartData.x, "value": chartData.y});
        }
        List ss = [];
        ss = ss + categorys;
        ss.sort(((a, b) => (b["value"]).compareTo(a["value"])));
        if (ss.length != 0) i = ss.first["value"] ?? 0;
        if (i < 10) {
          yAxisData = [3, 6, 10];
        } else
          yAxisData = [
            double.parse((i + (i / 10)).toString()).toInt(),
            double.parse((i / 2).toString()).toInt(),
            double.parse((i / 3).toString()).toInt()
          ];
        List<int> allValues = [];
        ss.map((e) => allValues.add(e["value"])).toList();
        fullKcal = allValues.sum;
        historyData = categorys;
      }
    } else if (catog == "Weekly") {
      List<Map> chartdatas = [];
      List week = [];
      week = graphData;
      week.map((e) {
        chartdatas.add({
          "xValue": e.xValue,
          "value": e.fullValue,
          "categData": {"Breakfast": 0, "Lunch": 0, "Snacks": 0, "Dinner": 0},
          "name": e.name
        });
      }).toList();
      for (Map e in chartdatas) {
        int i = week.indexWhere((element) => element.xValue == e["xValue"]);
        List li = ["Breakfast", "Lunch", "Snacks", "Dinner"];
        li.map((ee) {
          var s = week[i]
              .categoryWiseData
              .where((element) => element.categoryName == ee)
              .first
              .catFullValue;
          e["categData"][ee] = s;
        }).toList();
      }
      List ss = [];
      ss = ss + chartdatas;
      ss.sort(((a, b) => (b["value"]).compareTo(a["value"])));
      if (ss.length != 0) i = ss.first["value"] ?? 0;
      if (i < 10) {
        yAxisData = [3, 6, 10];
      } else
        yAxisData = [
          double.parse((i + (i / 10)).toString()).toInt(),
          double.parse((i / 2).toString()).toInt(),
          double.parse((i / 3).toString()).toInt()
        ];
      List<int> allValues = [];
      ss.map((e) => allValues.add(e["value"])).toList();
      fullKcal = allValues.sum;
      historyData = chartdatas;
      categorys = chartdatas;
    } else {
      if (graphData.isNotEmpty) {
        List ss = [];

        categorys = [];
        for (ChartData chartData in graphData) {
          categorys.add({"day": chartData.x, "value": chartData.y});
        }

        ss = ss + categorys;
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
      categorys.map((Map e) => allValues.add(e["value"])).toList();
      historyData = categorys;
      fullKcal = allValues.sum;
    }
    ValueNotifier<bool> showArrowShimmer = ValueNotifier<bool>(false);
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
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
                          showArrowShimmer.value = true;
                          time++;
                          if (myInsigtschanged.value == "Monthly") {
                            List<DateTime> date = HealthJournalFunctions.myInsigtsdateCalculator(
                              forword: false,
                              start: DateTimeHolderForMyInsights.monthFre.first,
                              end: DateTimeHolderForMyInsights.monthFre[1],
                            );
                            DateTimeHolderForMyInsights.monthFre = date;
                            myInsigtsdatas = await HealthJournalFunctions.allDataGraphValue(
                                selectedCate: ["Breakfast", "Lunch", "Snacks", "Dinner"],
                                dateFreq: DateTimeHolderForMyInsights.monthFre);
                            allMealsfreq = date;
                          } else if (myInsigtschanged.value == "Weekly") {
                            List<DateTime> date = HealthJournalFunctions.myInsigtsdateCalculator(
                              forword: false,
                              start: DateTimeHolderForMyInsights.weekFre.first,
                              end: DateTimeHolderForMyInsights.weekFre[1],
                            );
                            DateTimeHolderForMyInsights.weekFre = date;
                            myInsigtsdatas = await HealthJournalFunctions.allDataGraphValue(
                                selectedCate: ["Breakfast", "Lunch", "Snacks", "Dinner"],
                                dateFreq: DateTimeHolderForMyInsights.weekFre);
                            allMealsfreq = date;
                          } else {
                            List<DateTime> date = HealthJournalFunctions.myInsigtsdateCalculator(
                              forword: false,
                              start: DateTimeHolderForMyInsights.dayFre.first,
                              end: DateTimeHolderForMyInsights.dayFre[1],
                            );
                            DateTimeHolderForMyInsights.dayFre = date;
                            allMealsfreq = DateTimeHolderForMyInsights.dayFre;
                            myInsigtsdatas = await HealthJournalFunctions.allDataGraphValue(
                                selectedCate: ["Breakfast", "Lunch", "Snacks", "Dinner"],
                                dateFreq: DateTimeHolderForMyInsights.dayFre);
                            allMealsfreq = date;
                          }
                          Timer(const Duration(seconds: 1), () {
                            showArrowShimmer.value = false;
                          });
                          myInsigtschanged.notifyListeners();
                        },
                        child: Icon(Icons.arrow_back_ios_new_rounded)),
                  Container(
                      width: 70.w,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        dateText(dateData: allMealsfreq),
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
                            showArrowShimmer.value = true;
                            time--;
                            if (myInsigtschanged.value == "Monthly") {
                              List<DateTime> date = HealthJournalFunctions.myInsigtsdateCalculator(
                                forword: true,
                                start: DateTimeHolderForMyInsights.monthFre.first,
                                end: DateTimeHolderForMyInsights.monthFre[1],
                              );
                              DateTimeHolderForMyInsights.monthFre = date;
                              myInsigtsdatas = await HealthJournalFunctions.allDataGraphValue(
                                  selectedCate: ["Breakfast", "Lunch", "Snacks", "Dinner"],
                                  dateFreq: DateTimeHolderForMyInsights.monthFre);
                              allMealsfreq = date;
                            } else if (myInsigtschanged.value == "Weekly") {
                              List<DateTime> date = HealthJournalFunctions.myInsigtsdateCalculator(
                                forword: true,
                                start: DateTimeHolderForMyInsights.weekFre.first,
                                end: DateTimeHolderForMyInsights.weekFre[1],
                              );
                              DateTimeHolderForMyInsights.weekFre = date;
                              myInsigtsdatas = await HealthJournalFunctions.allDataGraphValue(
                                  selectedCate: ["Breakfast", "Lunch", "Snacks", "Dinner"],
                                  dateFreq: DateTimeHolderForMyInsights.weekFre);
                              allMealsfreq = date;
                            } else {
                              List<DateTime> date = HealthJournalFunctions.myInsigtsdateCalculator(
                                forword: true,
                                start: DateTimeHolderForMyInsights.dayFre.first,
                                end: DateTimeHolderForMyInsights.dayFre[1],
                              );
                              DateTimeHolderForMyInsights.dayFre = date;
                              myInsigtsdatas = await HealthJournalFunctions.allDataGraphValue(
                                  selectedCate: ["Breakfast", "Lunch", "Snacks", "Dinner"],
                                  dateFreq: DateTimeHolderForMyInsights.dayFre);
                              allMealsfreq = date;
                            }
                            Timer(const Duration(seconds: 1), () {
                              showArrowShimmer.value = false;
                            });
                            myInsigtschanged.notifyListeners();
                          },
                          child: const Icon(Icons.arrow_forward_ios_rounded))
                  else
                    const InkWell(
                        child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey,
                    ))
                ]);
              }),
          if (graphData.isEmpty)
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
            )
          else if (myInsigtschanged.value == "Day" && fullKcal != 0)
            CustomGraphAllMeals(
                xAxisFields: categorys,
                yAxixFields: yAxisData,
                multiColorbars: [
                  Color(0XFFF15B3A),
                  Color(0XFF2EC6DE),
                  Color(0XFFFE6292),
                  Color(0XFF383387),
                ],
                category: catog)
          else if (myInsigtschanged.value == "Monthly" && fullKcal != 0)
            CustomGraphSingle(
                xAxisFields: categorys, barColor: AppColors.primaryColor, yAxixFields: yAxisData)
          else if (myInsigtschanged.value == "Weekly" && fullKcal != 0)
            CustomGraphAllMealsWeek(
                xAxisFields: categorys,
                yAxixFields: yAxisData,
                multiColorbars: [
                  Color(0XFFF15B3A),
                  Color(0XFF2EC6DE),
                  Color(0XFFFE6292),
                  Color(0XFF383387)
                ],
                category: catog),
          if (graphData.isNotEmpty && fullKcal == 0)
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
                    "No Food Logged !",
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
    if (myInsigtschanged.value == "Monthly") {
      return Text(
        "${DateFormat('yyyy').format(dateData.first)} - ${DateFormat('yyyy').format(dateData[1])}",
        style: TextStyle(fontSize: 15.px, fontWeight: FontWeight.w500),
      );
    } else if (myInsigtschanged.value == "Weekly") {
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

class DateTimeHolderForMyInsights {
  static List<DateTime> dayFre = [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59)
        .subtract(Duration(hours: 23, minutes: 59)),
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
