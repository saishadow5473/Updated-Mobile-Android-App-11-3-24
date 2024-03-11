import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/new_design/presentation/Widgets/healthjournalWidgets/normalHealthJournalWidgets.dart';
import 'package:ihl/views/dietJournal/calorieGraph/monthly_calorie_tab.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../views/dietJournal/dietJournal.dart';
import '../../../app/utils/imageAssets.dart';
import '../../../data/functions/healthJounralFunctions.dart';
import '../../clippath/customGraph.dart';
import 'package:ihl/new_design/app/utils/appText.dart';
import '../../controllers/healthJournalControllers/getTodayLogController.dart';
import 'package:ihl/new_design/app/utils/textStyle.dart';

class HealthJournalWidget {
  static ValueNotifier<String> changed = ValueNotifier("Weekly");
  static ValueNotifier<String> selectedDropDownValue = ValueNotifier("Breakfast");
  static ValueNotifier<Color> colorForDropDownAndMap = ValueNotifier(Colors.orange);
  static bool loader = false;
  static List datas = [];
  static int time = 0;
  // static List myInsDatas = [];
  static List<String> contents = ["Day", "Weekly", "Monthly"];
  static List<Map> categoriesList = [
    {"name": "Breakfast", "color": Color(0XFFF15B3A)},
    {"name": "Lunch", "color": Color(0XFF2EC6DE)},
    {"name": "Snacks", "color": Color(0XFFFE6292)},
    {"name": "Dinner", "color": Color(0XFF383387)},
  ];
  static Widget graphHealthJournal({List datatoDisplay, Color color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300, blurRadius: 3, spreadRadius: 3, offset: Offset(1, 1))
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
                              // if (e == "Day") {
                              time = 0;
                              changed.value = e;
                              HealthJournalWidget.datas = [];
                              if (e != "Day") {
                                DateTimeHolderFordashboard.dayFre = constantDate.dayFre;
                              } else {
                                freqs = DateTimeHolderFordashboard.dayFre;
                                HealthJournalWidget.datas =
                                    await HealthJournalFunctions.graphValues(
                                        dateFreq: DateTimeHolderFordashboard.dayFre);
                              }
                              if (e != "Monthly") {
                                DateTimeHolderFordashboard.monthFre = constantDate.monthFre;
                              } else {
                                freqs = DateTimeHolderFordashboard.monthFre;
                                HealthJournalWidget.datas =
                                    await HealthJournalFunctions.graphValues(
                                        dateFreq: DateTimeHolderFordashboard.monthFre);
                              }
                              if (e != "Weekly") {
                                DateTimeHolderFordashboard.weekFre = constantDate.weekFre;
                              } else {
                                freqs = DateTimeHolderFordashboard.weekFre;
                                HealthJournalWidget.datas =
                                    await HealthJournalFunctions.graphValues(
                                        dateFreq: DateTimeHolderFordashboard.weekFre);
                              }
                              changed.notifyListeners();
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              padding: EdgeInsets.only(bottom: 3),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1.5,
                                          color: changed.value == e
                                              ? AppColors.primaryColor
                                              : Colors.transparent))),
                              child: Text(
                                e,
                                style: TextStyle(
                                    fontWeight:
                                        changed.value == e ? FontWeight.w500 : FontWeight.w400,
                                    color:
                                        changed.value == e ? AppColors.primaryColor : Colors.black),
                              ),
                            )),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 12.px),
              graphContent(graphData: datatoDisplay, color: color)
            ],
          )),
    );
  }

  static List<DateTime> freqs = [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(Duration(
      days: changed.value == "Monthly"
          ? 368
          : changed.value == "Weekly"
              ? 6
              : 1,
    )),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59),
  ];
  static graphContent({List graphData, Color color}) {
    List<Map> days = [];
    List<int> yAxisData = [];
    var i;
    var ss = [];
    if (graphData.isNotEmpty) {
      days = [];
      for (ChartData chartData in graphData) {
        days.add({"day": chartData.x, "value": chartData.y});
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
    // kCalNumber = days.sort((a, b) => (b['day']).compareTo(a['value']));
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
                          time++;
                          showArrowShimmer.value = true;
                          if (changed.value == "Monthly") {
                            List<DateTime> date = HealthJournalFunctions.dateCalculator(
                              forword: false,
                              start: DateTimeHolderFordashboard.monthFre.first,
                              end: DateTimeHolderFordashboard.monthFre[1],
                            );
                            DateTimeHolderFordashboard.monthFre = date;
                            HealthJournalWidget.datas = await HealthJournalFunctions.graphValues(
                                dateFreq: DateTimeHolderFordashboard.monthFre);
                            freqs = date;
                          } else if (changed.value == "Weekly") {
                            List<DateTime> date = HealthJournalFunctions.dateCalculator(
                              forword: false,
                              start: DateTimeHolderFordashboard.weekFre.first,
                              end: DateTimeHolderFordashboard.weekFre[1],
                            );
                            DateTimeHolderFordashboard.weekFre = date;
                            HealthJournalWidget.datas = await HealthJournalFunctions.graphValues(
                                dateFreq: DateTimeHolderFordashboard.weekFre);
                            freqs = date;
                          } else {
                            List<DateTime> date = HealthJournalFunctions.dateCalculator(
                              forword: false,
                              start: DateTimeHolderFordashboard.dayFre.first,
                              end: DateTimeHolderFordashboard.dayFre[1],
                            );
                            DateTimeHolderFordashboard.dayFre = date;
                            freqs = DateTimeHolderFordashboard.dayFre;
                            HealthJournalWidget.datas = await HealthJournalFunctions.graphValues(
                                dateFreq: DateTimeHolderFordashboard.dayFre);
                            freqs = date;
                          }
                          Timer(const Duration(seconds: 1), () => showArrowShimmer.value = false);
                          changed.notifyListeners();
                        },
                        child: const Icon(Icons.arrow_back_ios_new_rounded)),
                  SizedBox(
                      width: 70.w,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        dateText(dateData: freqs),
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
                            if (changed.value == "Monthly") {
                              List<DateTime> date = HealthJournalFunctions.dateCalculator(
                                forword: true,
                                start: DateTimeHolderFordashboard.monthFre.first,
                                end: DateTimeHolderFordashboard.monthFre[1],
                              );
                              DateTimeHolderFordashboard.monthFre = date;
                              HealthJournalWidget.datas = await HealthJournalFunctions.graphValues(
                                  dateFreq: DateTimeHolderFordashboard.monthFre);
                              freqs = date;
                            } else if (changed.value == "Weekly") {
                              List<DateTime> date = HealthJournalFunctions.dateCalculator(
                                forword: true,
                                start: DateTimeHolderFordashboard.weekFre.first,
                                end: DateTimeHolderFordashboard.weekFre[1],
                              );
                              DateTimeHolderFordashboard.weekFre = date;
                              HealthJournalWidget.datas = await HealthJournalFunctions.graphValues(
                                  dateFreq: DateTimeHolderFordashboard.weekFre);
                              freqs = date;
                            } else {
                              List<DateTime> date = HealthJournalFunctions.dateCalculator(
                                forword: true,
                                start: DateTimeHolderFordashboard.dayFre.first,
                                end: DateTimeHolderFordashboard.dayFre[1],
                              );
                              DateTimeHolderFordashboard.dayFre = date;
                              HealthJournalWidget.datas = await HealthJournalFunctions.graphValues(
                                  dateFreq: DateTimeHolderFordashboard.dayFre);
                              freqs = date;
                            }
                            Timer(const Duration(seconds: 1), () => showArrowShimmer.value = false);

                            changed.notifyListeners();
                          },
                          child: Icon(Icons.arrow_forward_ios_rounded))
                  else
                    InkWell(
                        child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey,
                    )),
                ]);
              }),
          if (graphData.isNotEmpty && fullKcal != 0 && loader == false)
            CustomGraphSingle(xAxisFields: days, barColor: color, yAxixFields: yAxisData),
          if (loader)
            Shimmer.fromColors(
              direction: ShimmerDirection.ltr,
              period: Duration(seconds: 2),
              baseColor: Colors.white,
              highlightColor: Colors.grey,
              child: Container(
                  height: 30.h,
                  child: Container(
                      margin: EdgeInsets.all(8),
                      width: 90.w,
                      height: 55.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Hello'))),
            ),
          if (graphData.isEmpty || fullKcal == 0)
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
            )
        ],
      ),
    );
  }

  static Text dateText({List<DateTime> dateData}) {
    if (changed.value == "Monthly") {
      return Text(
        "${DateFormat('yyyy').format(dateData.first)} - ${DateFormat('yyyy').format(dateData[1])}",
        style: TextStyle(fontSize: 14.px, fontWeight: FontWeight.w500),
      );
    } else if (changed.value == "Weekly") {
      return Text(
        "${DateFormat('d MMM').format(dateData.first)} - ${DateFormat('d MMM yyyy').format(dateData[1])}",
        // "${DateFormat('EEE, d MMM, yyyy').format(dateData.first)} - 4 Feb 2023",
        style: TextStyle(fontSize: 14.px, fontWeight: FontWeight.w500),
      );
    } else {
      return Text(
        "${DateFormat('EEEE, d MMMM').format(dateData.first)}",
        style: TextStyle(fontSize: 14.px, fontWeight: FontWeight.w500),
      );
    }
  }

  Widget caloriesCard(context, {Color selectedAfficolor}) {
    return GetBuilder<TodayLogController>(
        key: ValueKey('HJFJ_GPM05063'),
        id: "Today Food",
        init: TodayLogController(),
        builder: (todayLog) {
          return Padding(
            padding: const EdgeInsets.all(7.0),
            child: Container(
              color: selectedAfficolor != null
                  ? selectedAfficolor.withOpacity(0.2)
                  : AppColors.homeCardColor2,
              height: 18.h,
              width: 99.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.backgroundScreenColor,
                        radius: MediaQuery.of(context).size.width > 350 ? 43 : 35,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${todayLog.caloriesNeed}",
                              style: selectedAfficolor != null
                                  ? TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13.sp,
                                      color: selectedAfficolor,
                                      fontWeight: FontWeight.w800,
                                    )
                                  : AppTextStyles.headerText2,
                            ),
                            Text(
                              todayLog.limitExceed
                                  ? "Cal Extra"
                                  : todayLog.caloriesNeed != int.parse(todayLog.totalCalories)
                                      ? "Cal Need"
                                      : "Cal Taken",
                              style: AppTextStyles.regularFont,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 350
                            ? MediaQuery.of(context).size.width * 0.232
                            : 70,
                        height: MediaQuery.of(context).size.height > 650
                            ? MediaQuery.of(context).size.height * 0.12
                            : 70,
                        child: CircularProgressIndicator(
                          backgroundColor: AppColors.primaryColor,
                          color: AppColors.plainColor,
                          value: 1,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 350
                            ? MediaQuery.of(context).size.width * 0.232
                            : 70,
                        height: MediaQuery.of(context).size.height > 650
                            ? MediaQuery.of(context).size.height * 0.12
                            : 70,
                        child: CircularProgressIndicator(
                          color: todayLog.limitExceed
                              ? AppColors.primaryColor
                              : todayLog.caloriesNeed > int.parse(todayLog.totalCalories)
                                  ? AppColors.primaryColor
                                  : selectedAfficolor != null
                                      ? selectedAfficolor
                                      : AppColors.primaryColor,
                          value: todayLog.limitExceed
                              ? todayLog.caloriesNeed / int.parse(todayLog.totalCalories)
                              : todayLog.caloriesNeed > int.parse(todayLog.totalCalories)
                                  ? (todayLog.caloriesNeed / int.parse(todayLog.totalCalories)) - 1
                                  : todayLog.caloriesNeed != 0
                                      ? (todayLog.caloriesGained.toDouble() /
                                          double.parse(todayLog.totalCalories))
                                      : 1, // Change this value to update the progress
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Image.asset(
                              ImageAssets.caloriesTaken2,
                              height: 5.h,
                              width: 5.w,
                              color: selectedAfficolor != null
                                  ? selectedAfficolor
                                  : AppColors.primaryColor,
                            ),
                          ),
                          Text(
                            "Eaten - ${todayLog.caloriesEaten} Cal",
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Image.asset(
                              ImageAssets.caloriesBurntBlue,
                              height: 5.h,
                              width: 5.w,
                              color: selectedAfficolor != null
                                  ? selectedAfficolor
                                  : AppColors.primaryColor,
                            ),
                          ),
                          Text(
                            "Burnt - ${todayLog.caloriesBurnt} Cal",
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      )
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(DietJournal(
                        Screen: "home",
                      ));
                    },
                    child: Text(
                      AppTexts.logNow,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedAfficolor != null ? selectedAfficolor : AppColors.primaryColor,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}

class DateTimeHolderFordashboard {
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
