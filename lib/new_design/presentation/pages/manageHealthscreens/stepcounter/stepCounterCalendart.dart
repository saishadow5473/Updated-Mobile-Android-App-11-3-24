import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/managehealth/stepcounter/googleFitStepController.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import '../../../../../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../clippath/customGraph.dart';

class StepCounterCalendart extends StatelessWidget {
  final GoogleFitStepController _stepController = Get.put(GoogleFitStepController());

  StepCounterCalendart({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    ValueNotifier<int> selectedIndex = ValueNotifier(0);
    //DateTime startOfWeek = DateTime.parse(startDate).subtract(Duration(days: DateTime.parse(startDate).weekday - 1));
    //DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    List<Widget> data = [
      chart(DateTime.now().toString(), DateTime.now().toString(), 'Day'),
      chart(
          DateTime.parse(DateTime.now().toIso8601String())
              .subtract(Duration(days: DateTime.parse(DateTime.now().toString()).weekday - 1))
              .toString(),
          DateTime.now().add(const Duration(days: 5)).toString(),
          'Weekly'),
      chart(DateTime.now().toString(), DateTime.now().toString(), 'Monthly'),
    ];
    List<String> tabs = ['Day', 'Weekly', 'Monthly'];
    final GoogleFitStepController stepController = Get.put(GoogleFitStepController());
    return CommonScreenForNavigation(
      content: Scaffold(
        backgroundColor: AppColors.appBackgroundColor,
        appBar: AppBar(
          title: const Text('Steps'),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.keyboard_arrow_left,
              size: 28.sp,
            ),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: EdgeInsets.only(top: 14.sp, left: 13.sp, right: 13.sp),
                  margin: EdgeInsets.fromLTRB(15.sp, 13.sp, 15.sp, 10.sp),
                  decoration: BoxDecoration(
                      color: selectedIndex == 0 ? Colors.transparent : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                            offset: Offset(1, 1),
                            color: Colors.grey,
                            blurRadius: 3,
                            spreadRadius: 3)
                      ]),
                  //  height: 48.h,
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: tabs.map((String e) {
                            return Container(
                              alignment: Alignment.center,
                              width: 20.w,
                              child: GestureDetector(
                                  onTap: () async {
                                    if (e == 'Day') {
                                      pos = 0;
                                      showShimmer.value = true;
                                      selectedIndex.value = 0;
                                      whichFirst = '';

                                      stepsCount.value = 0;
                                      stepsListHourlyWise.value.clear();
                                      mStartDate.value = DateTime.now();
                                      mendDate.value = DateTime.now();
                                      DateTime timestamp = DateTime.now();

                                      DateTime startOfDay =
                                          DateTime(timestamp.year, timestamp.month, timestamp.day);
                                      DateTime timestamp1 = DateTime.now();

                                      DateTime endOfDay = DateTime(timestamp1.year,
                                          timestamp1.month, timestamp1.day, 23, 59, 59);

                                      // fetchDataBasedOnDate(startOfDay, endOfDay);
                                      await stepController.fetchHourlyBasis(
                                          startOfDay, endOfDay, '');
                                      // fetchHourlyBasis(startOfDay, endOfDay,'f');
                                      await stepController.fetchHourlyBasis(
                                          startOfDay, endOfDay, 'b');
                                      await stepController.fetchHourlyBasis(
                                          startOfDay, endOfDay, 'f');
                                      showShimmer.value = false;
                                    }
                                    if (e == 'Weekly') {
                                      pos = 0;
                                      showShimmer.value = true;
                                      selectedIndex.value = 1;
                                      whichFirst = '';
                                      stepsCountw.value = 0;
                                      stepsListDateWise.value.clear();
                                      DateTime startOfWeek = currentweekDayFinder();

                                      DateTime endOfWeek = currentweekDayFinder()
                                          .add(const Duration(days: 7))
                                          .subtract(const Duration(minutes: 1));
                                      mStartDate.value = startOfWeek;
                                      mendDate.value = endOfWeek;

                                      DateTime startOfWeek1 = currentweekDayFinder();

                                      DateTime endOfWeek1 = currentweekDayFinder()
                                          .add(const Duration(days: 7))
                                          .subtract(const Duration(minutes: 1));

                                      await stepController.fetchDataBasedOnDate(
                                          DateTime.parse(startOfWeek1.toString()),
                                          DateTime.parse(endOfWeek1.toString()),
                                          '');
                                      await stepController.fetchDataBasedOnDate(
                                          DateTime.parse(startOfWeek1.toString()),
                                          DateTime.parse(endOfWeek1.toString()),
                                          'b');
                                      await stepController.fetchDataBasedOnDate(
                                          DateTime.parse(startOfWeek1.toString()),
                                          DateTime.parse(endOfWeek1.toString()),
                                          'f');
                                      showShimmer.value = false;
                                    }
                                    if (e == 'Monthly') {
                                      pos = 0;
                                      showShimmer.value = true;
                                      selectedIndex.value = 2;
                                      whichFirst = '';
                                      stepsCountM.value = 0;
                                      stepsListMonthlyWise.value.clear();
                                      mStartDate.value = DateTime.now();
                                      mendDate.value = DateTime.now();
                                      DateTime monthStart =
                                          DateTime(DateTime.now().year, DateTime.now().month, 1);
                                      await stepController.fetchDataMonthly(monthStart, '');
                                      await stepController.fetchDataMonthly(monthStart, 'b');
                                      await stepController.fetchDataMonthly(monthStart, 'f');
                                      showShimmer.value = false;
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Text(e),
                                      SizedBox(
                                        height: 0.5.h,
                                      ),
                                      ValueListenableBuilder(
                                          valueListenable: selectedIndex,
                                          builder: (_, s, __) {
                                            return Container(
                                              height: 0.4.h,
                                              width: 20.w,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  color: s == tabs.indexOf(e)
                                                      ? Colors.blue
                                                      : Colors.white),
                                            );
                                          })
                                    ],
                                  )),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        height: 1.5.h,
                      ),
                      ValueListenableBuilder(
                          valueListenable: selectedIndex,
                          // ignore: missing_return
                          builder: (_, val, __) {
                            if (val == 2) {
                              return chart(
                                  DateTime.now().toString(), DateTime.now().toString(), 'Monthly');
                            } else if (val == 1) {
                              DateTime startOfWeek = currentweekDayFinder();

                              DateTime endOfWeek = currentweekDayFinder()
                                  .add(const Duration(days: 7))
                                  .subtract(const Duration(minutes: 1));
                              return chart(
                                  // DateTime.parse(DateTime.now().toIso8601String())
                                  //     .subtract(Duration(
                                  //         days: DateTime.parse(DateTime.now().toString()).weekday -
                                  //             1))
                                  //     .toString(),
                                  // DateTime.now().add(Duration(days: 5)).toString(),
                                  startOfWeek.toString(),
                                  endOfWeek.toString(),
                                  'Weekly');
                            } else if (val == 0) {
                              return chart(
                                  DateTime.now().toString(), DateTime.now().toString(), 'Day');
                            }
                          }),
                    ],
                  )),
              SizedBox(
                height: 1.h,
              ),
              ValueListenableBuilder(
                  valueListenable: selectedIndex,
                  builder: (_, val, __) {
                    if (val == 1) {
                      return ValueListenableBuilder(
                          valueListenable: stepsListDateWise,
                          builder: (_, v, __) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: 14.sp, left: 17.sp, right: 17.sp, bottom: 45.sp),
                              child: Column(
                                children: v.map<Widget>((e) {
                                  return e.steps == 0
                                      ? Container()
                                      : Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text('${getDayName(e.date)} , '),
                                                  Text('${e.date.day} '),
                                                  Text(getMonthName(e.date.month, e.date.year)),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                      height: 3.h,
                                                      width: 5.w,
                                                      child: Image.asset(
                                                          "assets/images/shoeSteps.png")),
                                                  SizedBox(
                                                    width: 1.w,
                                                  ),
                                                  Text(
                                                    '${e.steps} steps',
                                                    style: TextStyle(
                                                        color: Colors.black.withOpacity(0.7),
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                            ],
                                          ),
                                        );
                                }).toList(),
                              ),
                            );
                          });
                    }
                    if (val == 2) {
                      return ValueListenableBuilder(
                          valueListenable: showShimmer,
                          builder: (_, show, __) {
                            return show
                                ? Container()
                                : ValueListenableBuilder(
                                    valueListenable: stepsListMonthlyWise,
                                    builder: (_, v, __) {
                                      List<StepsData> range1 = [];
                                      List<StepsData> range2 = [];
                                      List<StepsData> range3 = [];
                                      List<StepsData> range4 = [];
                                      int range1Total = 0;
                                      int range2Total = 0;

                                      int range3Total = 0;
                                      int range4Total = 0;
                                      print(v.length);
                                      if (v.length != 0) {
                                        for (var stepData in v) {
                                          print(stepData.date.day);
                                          if (stepData.date.day >= 1 && stepData.date.day <= 7) {
                                            range1.add(stepData);
                                          } else if (stepData.date.day >= 8 &&
                                              stepData.date.day <= 14) {
                                            range2.add(stepData);
                                          } else if (stepData.date.day >= 15 &&
                                              stepData.date.day <= 21) {
                                            range3.add(stepData);
                                          } else if (stepData.date.day >= 22 &&
                                              stepData.date.day <= v.length) {
                                            range4.add(stepData);
                                          }
                                        }

                                        for (int i = 0; i < 7; i++) {
                                          range1Total += range1[i].steps;
                                          range2Total += range2[i].steps;
                                          range3Total += range3[i].steps;
                                          range4Total += range4[i].steps;
                                        }
                                      }
                                      print(range1Total + range2Total + range3Total + range4Total);
                                      return v.length == 0
                                          ? Container()
                                          : Padding(
                                              padding: EdgeInsets.only(
                                                  top: 14.sp,
                                                  left: 17.sp,
                                                  right: 17.sp,
                                                  bottom: 45.sp),
                                              child: (range1Total +
                                                          range2Total +
                                                          range3Total +
                                                          range4Total) ==
                                                      0
                                                  ? Container()
                                                  : Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                          range1Total == 0
                                                              ? Container()
                                                              : Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                        '1-7 ${getMonthName(range1.first.date.month, range1.first.date.year)}'),
                                                                    SizedBox(
                                                                      height: .5.h,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(
                                                                            height: 3.h,
                                                                            width: 5.w,
                                                                            child: Image.asset(
                                                                                "assets/images/shoeSteps.png")),
                                                                        SizedBox(
                                                                          width: 1.w,
                                                                        ),
                                                                        Text('$range1Total steps'),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: 1.h,
                                                                    ),
                                                                  ],
                                                                ),
                                                          range2Total == 0
                                                              ? Container()
                                                              : Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                        '8-14 ${getMonthName(range1.first.date.month, range1.first.date.year)}'),
                                                                    SizedBox(
                                                                      height: .5.h,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(
                                                                            height: 3.h,
                                                                            width: 5.w,
                                                                            child: Image.asset(
                                                                                "assets/images/shoeSteps.png")),
                                                                        SizedBox(
                                                                          width: 1.w,
                                                                        ),
                                                                        Text('$range2Total steps'),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: 1.h,
                                                                    ),
                                                                  ],
                                                                ),
                                                          range3Total == 0
                                                              ? Container()
                                                              : Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                        '15-21 ${getMonthName(range1.first.date.month, range1.first.date.year)}'),
                                                                    SizedBox(
                                                                      height: .5.h,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(
                                                                            height: 3.h,
                                                                            width: 5.w,
                                                                            child: Image.asset(
                                                                                "assets/images/shoeSteps.png")),
                                                                        SizedBox(
                                                                          width: 1.w,
                                                                        ),
                                                                        Text('$range3Total steps'),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: 1.h,
                                                                    ),
                                                                  ],
                                                                ),
                                                          range4Total == 0
                                                              ? Container()
                                                              : Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                        '22-${v.length} ${getMonthName(range1.first.date.month, range1.first.date.year)}'),
                                                                    SizedBox(
                                                                      height: .5.h,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(
                                                                            height: 3.h,
                                                                            width: 5.w,
                                                                            child: Image.asset(
                                                                                "assets/images/shoeSteps.png")),
                                                                        SizedBox(
                                                                          width: 1.w,
                                                                        ),
                                                                        Text(
                                                                          '$range4Total steps',
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                        ]),
                                            );
                                    });
                          });
                    }
                    if (val == 0) {
                      return ValueListenableBuilder(
                          valueListenable: showShimmer,
                          builder: (_, show, __) {
                            return show
                                ? Container()
                                : ValueListenableBuilder(
                                    valueListenable: stepsListHourlyWise,
                                    builder: (_, v, __) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            top: 14.sp, left: 17.sp, right: 17.sp, bottom: 45.sp),
                                        child: Column(
                                          children: v.map<Widget>((e) {
                                            print('${e.date} ${e.steps} ${e.activeTime}');
                                            return e.activeTime == 0
                                                ? Container()
                                                : Container(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.start,
                                                          children: [
                                                            // Text(getDayName(e.timeStamp) + ' , '),
                                                            SizedBox(
                                                                height: 4.h,
                                                                width: 5.w,
                                                                child: Image.asset(
                                                                    "assets/images/walking.png")),
                                                            SizedBox(
                                                              width: 1.w,
                                                            ),
                                                            Text(formatHour(e.date))
                                                            // Text(e.timeStamp.day.toString() + ' '),
                                                            // Text(getMonthName(e.timeStamp.month, e.timeStamp.year)),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: .6.h,
                                                        ),
                                                        Text(
                                                          getTimeCategory(e.date),
                                                          style: const TextStyle(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.w600),
                                                        ),
                                                        SizedBox(
                                                          height: .6.h,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              '${e.activeTime}mins',
                                                              style: TextStyle(
                                                                  color:
                                                                      Colors.black.withOpacity(0.7),
                                                                  fontWeight: FontWeight.w600),
                                                            ),
                                                            SizedBox(
                                                              width: 1.1.w,
                                                            ),
                                                            SizedBox(
                                                                height: 3.h,
                                                                width: 5.w,
                                                                child: Image.asset(
                                                                    "assets/images/shoeSteps.png")),
                                                            SizedBox(
                                                              width: 1.w,
                                                            ),
                                                            Text(
                                                              '${e.steps} steps',
                                                              style: TextStyle(
                                                                  color:
                                                                      Colors.black.withOpacity(0.7),
                                                                  fontWeight: FontWeight.w600),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 1.h,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                          }).toList(),
                                        ),
                                      );
                                    });
                          });
                    } else {
                      return const Text('data');
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  String formatHour(int hour) {
    if (hour == 0) {
      return '12:00 am';
    }
    if (hour > 11) {
      int a = hour - 12;
      if (a == 0) {
        return '12:00 pm';
      } else {
        return '$a:00 pm';
      }
    } else {
      return '$hour:00 am';
    }
  }

  String getTimeCategory(int hour) {
    if (hour >= 5 && hour < 12) {
      return 'Morning Walk';
    } else if (hour >= 12 && hour < 15) {
      return 'Lunch Walk';
    } else if (hour >= 15 && hour < 18) {
      return 'Evening Walk';
    } else {
      return 'Night Walk';
    }
  }

  String whichFirst = '';

  int pos = 0;

  ValueNotifier<DateTime> mStartDate = ValueNotifier(DateTime.parse(DateTime.now().toString()));

  ValueNotifier<DateTime> mendDate = ValueNotifier(DateTime.parse(DateTime.now().toString()));

  Widget chart(String startDate, String endDate, String selectedType) {
    mStartDate.value = DateTime.parse(startDate);
    mendDate.value = DateTime.parse(endDate);
    final GoogleFitStepController stepController = Get.put(GoogleFitStepController());
    ValueNotifier<int> dateCount =
        ValueNotifier(getDaysInMonth(mendDate.value.month, mendDate.value.year));
    ValueNotifier<List<Widget>> myProducts = ValueNotifier(
        List.generate(dateCount.value, (int index) => numberContainer(index.toString())).toList());
    myProducts.value.remove(0);
    print(myProducts.value.length);

    myProducts.notifyListeners();
    return Container(
      child: ValueListenableBuilder(
          valueListenable: mStartDate,
          builder: (_, v, __) {
            return ValueListenableBuilder(
                valueListenable: mendDate,
                builder: (_, b, __) {
                  return ValueListenableBuilder(
                      valueListenable: showArrows,
                      builder: (_, arrows, __) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                showArrows.value
                                    ? GestureDetector(
                                        onTap: () async {
                                          if (selectedType == 'Day') {
                                            pos--;
                                            mStartDate.value =
                                                mStartDate.value.subtract(const Duration(days: 1));
                                            mendDate.value =
                                                mendDate.value.subtract(const Duration(days: 1));
                                            DateTime timestamp =
                                                DateTime.parse(mStartDate.value.toString());

                                            DateTime startOfDay = DateTime(
                                                timestamp.year, timestamp.month, timestamp.day);
                                            DateTime timestamp1 =
                                                DateTime.parse(mendDate.value.toString());

                                            DateTime endOfDay = DateTime(timestamp1.year,
                                                timestamp1.month, timestamp1.day, 23, 59, 59);
                                            // await _stepController.fetchDataBasedOnDate(startOfDay, endOfDay);

                                            if (whichFirst == 'f') {
                                              await stepController.fetchHourlyBasis(
                                                  startOfDay, endOfDay, '');

                                              await stepController.fetchHourlyBasis(
                                                  startOfDay, endOfDay, 'b');
                                              num a = 0;
                                              for (StepsDataHourly element
                                                  in stepsListHourlyWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCount.value = a;
                                              // stepsCount.notifyListeners();
                                            } else {
                                              List<StepsDataHourly> t =
                                                  stepsListHourlyWiseBackWards1;
                                              stepsListHourlyWise.value = t;
                                              num a = 0;
                                              for (StepsDataHourly element
                                                  in stepsListHourlyWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCount.value = a;
                                              //   stepsCount.notifyListeners();
                                              //  stepsListHourlyWise.dispose();
                                              await stepController.fetchHourlyBasis(
                                                  startOfDay, endOfDay, 'b');
                                            }
                                          }
                                          if (selectedType == 'Weekly') {
                                            pos--;
                                            mStartDate.value =
                                                mStartDate.value.subtract(const Duration(days: 7));
                                            // endOfWeek = startOfWeek.add(Duration(days: 7));
                                            mendDate.value =
                                                mendDate.value.subtract(const Duration(days: 7));
                                            if (whichFirst == 'f') {
                                              await stepController.fetchDataBasedOnDate(
                                                  mStartDate.value, mendDate.value, '');

                                              await stepController.fetchDataBasedOnDate(
                                                  mStartDate.value, mendDate.value, 'b');
                                              num a = 0;
                                              for (StepsData element in stepsListDateWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCountw.value = a;
                                              // stepsCount.notifyListeners();
                                            } else {
                                              List<StepsData> t = stepsListWeeklyWiseBackWards;
                                              stepsListDateWise.value = t;
                                              num a = 0;
                                              for (StepsData element in stepsListDateWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCountw.value = a;
                                              await stepController.fetchDataBasedOnDate(
                                                  DateTime.parse(mStartDate.value.toString()),
                                                  DateTime.parse(mendDate.value.toString()),
                                                  'b');
                                            }
                                          }
                                          if (selectedType == 'Monthly') {
                                            pos--;
                                            print(mStartDate.toString());
                                            mStartDate.value = DateTime(mStartDate.value.year,
                                                mStartDate.value.month - 1, 1);
                                            print(mStartDate.toString());
                                            mendDate.value = DateTime(mendDate.value.year,
                                                    mendDate.value.month, 1, 23, 59)
                                                .subtract(const Duration(days: 1));
                                            if (whichFirst == 'f') {
                                              await stepController.fetchDataMonthly(
                                                  mStartDate.value, '');

                                              await stepController.fetchDataMonthly(
                                                  mStartDate.value, 'b');
                                              num a = 0;
                                              for (StepsData element
                                                  in stepsListMonthlyWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCountM.value = a;
                                              // stepsCount.notifyListeners();
                                            } else {
                                              List<StepsData> t = stepsListMonthlyWiseBackWards;
                                              stepsListMonthlyWise.value = t;
                                              num a = 0;
                                              for (StepsData element
                                                  in stepsListMonthlyWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCountM.value = a;
                                              await stepController.fetchDataMonthly(
                                                  DateTime.parse(mStartDate.value.toString()), 'b');
                                            }
                                          }
                                          whichFirst = 'b';
                                        },
                                        child: const Icon(Icons.arrow_back_ios))
                                    : Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.grey.shade100,
                                      ),
                                Column(
                                  children: [
                                    Text(dateFormat(v, b, selectedType.toString())),
                                    if (selectedType == 'Day')
                                      ValueListenableBuilder(
                                          valueListenable: showShimmer,
                                          builder: (_, show, __) {
                                            return show
                                                ? Container()
                                                : ValueListenableBuilder(
                                                    valueListenable: stepsCount,
                                                    builder: (_, c, __) {
                                                      return Row(
                                                        children: [
                                                          SizedBox(
                                                              height: 3.h,
                                                              width: 5.w,
                                                              child: Image.asset(
                                                                  "assets/images/shoeSteps.png")),
                                                          SizedBox(
                                                            width: 2.w,
                                                          ),
                                                          Text(c.toString()),
                                                        ],
                                                      );
                                                    });
                                          }),
                                    if (selectedType == 'Weekly')
                                      ValueListenableBuilder(
                                          valueListenable: showShimmer,
                                          builder: (_, show, __) {
                                            return show
                                                ? Container()
                                                : ValueListenableBuilder(
                                                    valueListenable: stepsCountw,
                                                    builder: (_, c, __) {
                                                      return Row(
                                                        children: [
                                                          SizedBox(
                                                              height: 3.h,
                                                              width: 5.w,
                                                              child: Image.asset(
                                                                  "assets/images/shoeSteps.png")),
                                                          SizedBox(
                                                            width: 2.w,
                                                          ),
                                                          Text(c.toString()),
                                                        ],
                                                      );
                                                    });
                                          }),
                                    if (selectedType == 'Monthly')
                                      ValueListenableBuilder(
                                          valueListenable: showShimmer,
                                          builder: (_, show, __) {
                                            return show
                                                ? Container()
                                                : ValueListenableBuilder(
                                                    valueListenable: stepsCountM,
                                                    builder: (_, c, __) {
                                                      return Row(
                                                        children: [
                                                          SizedBox(
                                                              height: 3.h,
                                                              width: 5.w,
                                                              child: Image.asset(
                                                                  "assets/images/shoeSteps.png")),
                                                          SizedBox(
                                                            width: 2.w,
                                                          ),
                                                          Text(c.toString()),
                                                        ],
                                                      );
                                                    });
                                          })
                                  ],
                                ),
                                showArrows.value && pos != 0
                                    ? GestureDetector(
                                        onTap: () async {
                                          if (selectedType == 'Day' &&
                                              !mendDate.value.isAfter(DateTime.now()
                                                  .subtract(const Duration(days: 1)))) {
                                            pos++;
                                            mStartDate.value =
                                                mStartDate.value.add(const Duration(days: 1));
                                            mendDate.value =
                                                mendDate.value.add(const Duration(days: 1));
                                            DateTime timestamp =
                                                DateTime.parse(mStartDate.value.toString());

                                            DateTime startOfDay = DateTime(
                                                timestamp.year, timestamp.month, timestamp.day);
                                            DateTime timestamp1 =
                                                DateTime.parse(mendDate.value.toString());

                                            DateTime endOfDay = DateTime(timestamp1.year,
                                                timestamp1.month, timestamp1.day, 23, 59, 59);
                                            // await _stepController.fetchDataBasedOnDate(startOfDay, endOfDay);

                                            if (whichFirst == 'b') {
                                              await stepController.fetchHourlyBasis(
                                                  startOfDay, endOfDay, '');

                                              await stepController.fetchHourlyBasis(
                                                  startOfDay, endOfDay, 'f');
                                              num a = 0;
                                              for (StepsDataHourly element
                                                  in stepsListHourlyWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCount.value = a;
                                              // stepsCount.notifyListeners();
                                            } else {
                                              stepsListHourlyWise.value =
                                                  stepsListHourlyWiseForwards1;
                                              num a = 0;
                                              for (StepsDataHourly element
                                                  in stepsListHourlyWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCount.value = a;
                                              // stepsCount.notifyListeners();
                                              // stepsListHourlyWise.notifyListeners();
                                              await stepController.fetchHourlyBasis(
                                                  startOfDay, endOfDay, 'f');
                                            }
                                          }
                                          if (selectedType == 'Weekly'

                                              //  &&
                                              //     mendDate.value.isBefore(mendDate.value)

                                              &&
                                              pos != 0) {
                                            pos++;
                                            print(mendDate.value.isBefore(DateTime.now().add(
                                                Duration(
                                                    days: DateTime.sunday -
                                                        DateTime.now().weekday))));
                                            print(DateTime.now()
                                                .add(Duration(
                                                    days: DateTime.sunday - DateTime.now().weekday))
                                                .toString());
                                            mStartDate.value =
                                                mStartDate.value.add(const Duration(days: 7));
                                            mendDate.value =
                                                mendDate.value.add(const Duration(days: 7));
                                            if (whichFirst == 'b') {
                                              await stepController.fetchDataBasedOnDate(
                                                  mStartDate.value, mendDate.value, '');

                                              await stepController.fetchDataBasedOnDate(
                                                  mStartDate.value, mendDate.value, 'f');
                                              num a = 0;
                                              for (StepsData element in stepsListDateWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCountw.value = a;
                                              // stepsCount.notifyListeners();
                                            } else {
                                              List<StepsData> t = stepsListWeeklyWiseForwards;
                                              stepsListDateWise.value = t;
                                              num a = 0;
                                              for (StepsData element in stepsListDateWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCountw.value = a;
                                              await stepController.fetchDataBasedOnDate(
                                                  DateTime.parse(mStartDate.value.toString()),
                                                  DateTime.parse(mendDate.value.toString()),
                                                  'f');
                                            }
                                          }
                                          if (selectedType == 'Monthly' &&
                                              !mStartDate.value.isAfter(DateTime.now())) {
                                            pos++;
                                            print(mStartDate.toString());
                                            mStartDate.value = DateTime(mStartDate.value.year,
                                                    mStartDate.value.month + 1, 1)
                                                .add(const Duration(days: 1));
                                            print(mStartDate.toString());
                                            mendDate.value = mStartDate.value;
                                            if (whichFirst == 'b') {
                                              await stepController.fetchDataMonthly(
                                                  mStartDate.value, '');

                                              await stepController.fetchDataMonthly(
                                                  mStartDate.value, 'f');
                                              num a = 0;
                                              for (StepsData element
                                                  in stepsListMonthlyWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCountM.value = a;
                                              // stepsCount.notifyListeners();
                                            } else {
                                              List<StepsData> t = stepsListMonthlyWiseForwards;
                                              stepsListMonthlyWise.value = t;
                                              num a = 0;
                                              for (StepsData element
                                                  in stepsListMonthlyWise.value) {
                                                a += element.steps;
                                              }
                                              stepsCountM.value = a;
                                              await stepController.fetchDataMonthly(
                                                  DateTime.parse(mStartDate.value.toString()), 'f');
                                            }
                                          }
                                          whichFirst = 'f';
                                        },
                                        child: const Icon(Icons.arrow_forward_ios_outlined))
                                    : Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey.shade100,
                                      ),
                              ],
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            if (selectedType == 'Monthly')
                              ValueListenableBuilder(
                                  valueListenable: stepsCountM,
                                  builder: (_, records, __) {
                                    return ValueListenableBuilder(
                                        valueListenable: showShimmer,
                                        builder: (_, shimmer, __) {
                                          return shimmer
                                              ? Column(
                                                  children: [
                                                    Shimmer.fromColors(
                                                      direction: ShimmerDirection.ltr,
                                                      enabled: true,
                                                      baseColor: Colors.white,
                                                      highlightColor: Colors.grey.shade300,
                                                      child: Container(
                                                        height: 28.h,
                                                        width: 85.w,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 2.h,
                                                    )
                                                  ],
                                                )
                                              : records == 0
                                                  ? SizedBox(
                                                      height: 28.h,
                                                      width: 85.w,
                                                      child: const Center(
                                                        child: Text('No steps recorded'),
                                                      ),
                                                    )
                                                  : ValueListenableBuilder(
                                                      valueListenable: stepsListMonthlyWise,
                                                      builder: (_, data, __) {
                                                        List<StepsData> temp1 = data;
                                                        temp1.sort((StepsData a, StepsData b) =>
                                                            a.date.compareTo(b.date));
                                                        DateTime firstDate = temp1.first.date;
                                                        String dayname = getDayName(firstDate);
                                                        List<StepsData> temp = data;
                                                        if (data != []) {
                                                          if (dayname == 'Saturday') {
                                                            for (int i = 0; i < 6; i++) {
                                                              temp.insert(
                                                                  i,
                                                                  StepsData(
                                                                      DateTime(
                                                                          2028, 7, 27, 12, 30, 0),
                                                                      0));
                                                            }
                                                          }
                                                          if (dayname == 'Monday') {
                                                            for (int i = 0; i < 1; i++) {
                                                              temp.insert(
                                                                  i,
                                                                  StepsData(
                                                                      DateTime(
                                                                          2028, 7, 27, 12, 30, 0),
                                                                      0));
                                                            }
                                                          }
                                                          if (dayname == 'Tuesday') {
                                                            for (int i = 0; i < 2; i++) {
                                                              temp.insert(
                                                                  i,
                                                                  StepsData(
                                                                      DateTime(
                                                                          2028, 7, 27, 12, 30, 0),
                                                                      0));
                                                            }
                                                          }
                                                          if (dayname == 'Wednesday') {
                                                            for (int i = 0; i < 3; i++) {
                                                              temp.insert(
                                                                  i,
                                                                  StepsData(
                                                                      DateTime(
                                                                          2028, 7, 27, 12, 30, 0),
                                                                      0));
                                                            }
                                                          }
                                                          if (dayname == 'Thursday') {
                                                            for (int i = 0; i < 4; i++) {
                                                              temp.insert(
                                                                  i,
                                                                  StepsData(
                                                                      DateTime(
                                                                          2028, 7, 27, 12, 30, 0),
                                                                      0));
                                                            }
                                                          }
                                                          if (dayname == 'Friday') {
                                                            for (int i = 0; i < 5; i++) {
                                                              temp.insert(
                                                                  i,
                                                                  StepsData(
                                                                      DateTime(
                                                                          2028, 7, 27, 12, 30, 0),
                                                                      0));
                                                            }
                                                          }
                                                        }
                                                        return Column(
                                                          children: [
                                                            SizedBox(
                                                              height: dayname == 'Friday' ||
                                                                      dayname == 'Saturday'
                                                                  ? 32.h
                                                                  : 29.h,
                                                              width: 85.w,
                                                              child: temp != []
                                                                  ? GridView.count(
                                                                      shrinkWrap: true,
                                                                      crossAxisCount: 7,
                                                                      crossAxisSpacing: 1.w,
                                                                      mainAxisSpacing: 0.5.h,
                                                                      // scrollDirection: null,
                                                                      children: temp.map<Widget>(
                                                                          (StepsData e) {
                                                                        return FractionallySizedBox(
                                                                          widthFactor:
                                                                              getSize(e.steps),
                                                                          heightFactor:
                                                                              getSize(e.steps),
                                                                          child: Container(
                                                                            decoration: BoxDecoration(
                                                                                shape:
                                                                                    BoxShape.circle,
                                                                                color: e.steps == 0
                                                                                    ? Colors
                                                                                        .transparent
                                                                                    : const Color
                                                                                            .fromARGB(
                                                                                        255,
                                                                                        192,
                                                                                        214,
                                                                                        252)),
                                                                            child:
                                                                                e.date.year != 2028
                                                                                    ? Center(
                                                                                        child: Text(
                                                                                        e.date.day
                                                                                            .toString(),
                                                                                        style: const TextStyle(
                                                                                            color: Colors
                                                                                                .blue),
                                                                                      ))
                                                                                    : Container(),
                                                                          ),
                                                                        );
                                                                      }).toList())
                                                                  : const SizedBox(),
                                                            ),
                                                            SizedBox(
                                                              width: 82.w,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.spaceBetween,
                                                                children: const [
                                                                  Text('Sun'),
                                                                  Text('Mon'),
                                                                  Text('Tue'),
                                                                  Text('Wed'),
                                                                  Text('Thu'),
                                                                  Text('Fri'),
                                                                  Text('Sat')
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 2.h,
                                                            )
                                                          ],
                                                        );
                                                      });
                                        });
                                  }),
                            if (selectedType == 'Weekly')
                              ValueListenableBuilder(
                                  valueListenable: stepsListDateWise,
                                  builder: (_, List<StepsData> data, __) {
                                    List<Map> d = [
                                      // {"day": "sun", "value": 200},
                                      // {"day": "mon", "value": 300},
                                      // {"day": "tue", "value": 500},
                                      // {"day": "wed", "value": 100},
                                      // {"day": "thu", "value": 250},
                                      // {"day": "fri", "value": 280},
                                      // {"day": "sat", "value": 20},
                                    ];

                                    for (StepsData e in data) {
                                      d.add({'day': getDayName(e.date), 'value': e.steps});
                                    }
                                    int i = 0;
                                    List temp = [];
                                    temp.addAll(d);
                                    temp.sort(((a, b) => (b["value"]).compareTo(a["value"])));

                                    if (temp.isNotEmpty) i = temp.first["value"] ?? 0;
                                    List<int> yAxisData = [
                                      double.parse((i + (i / 10)).toString()).toInt(),
                                      double.parse((i / 2).toString()).toInt(),
                                      double.parse((i / 3).toString()).toInt()
                                    ];
                                    return data != []
                                        ? ValueListenableBuilder(
                                            valueListenable: showShimmer,
                                            builder: (_, shimmer, __) {
                                              return shimmer
                                                  ? Column(
                                                      children: [
                                                        Shimmer.fromColors(
                                                          direction: ShimmerDirection.ltr,
                                                          enabled: true,
                                                          baseColor: Colors.white,
                                                          highlightColor: Colors.grey.shade300,
                                                          child: Container(
                                                            height: 28.h,
                                                            width: 85.w,
                                                            decoration: BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius:
                                                                  BorderRadius.circular(5),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 1.h,
                                                        )
                                                      ],
                                                    )
                                                  : ValueListenableBuilder(
                                                      valueListenable: stepsCountw,
                                                      builder: (_, records, __) {
                                                        return records == 0
                                                            ? SizedBox(
                                                                height: 28.h,
                                                                width: 85.w,
                                                                child: const Center(
                                                                  child: Text('No steps recorded'),
                                                                ),
                                                              )
                                                            : Column(
                                                                children: [
                                                                  CustomGraphSingle(
                                                                      xAxisFields: d,
                                                                      barColor:
                                                                          AppColors.primaryColor,
                                                                      yAxixFields: yAxisData),
                                                                  SizedBox(
                                                                    height: 1.h,
                                                                  )
                                                                ],
                                                              );
                                                      });
                                            })
                                        // ? Container(
                                        //     padding: EdgeInsets.only(
                                        //         left: 10.sp, right: 18.sp, top: 20.sp),
                                        //     height: 30.h,
                                        //     child: BarChart(
                                        //       BarChartData(
                                        //           borderData: FlBorderData(
                                        //             show: true, // Show border around the chart
                                        //             border: Border.all(
                                        //                 color: Colors.transparent,
                                        //                 width:
                                        //                     5), // Adjust the width to add padding
                                        //           ),
                                        //           // barGroups: getBarGroups(),
                                        //           barGroups: data.map<BarChartGroupData>((e) {
                                        //             return BarChartGroupData(
                                        //               x: e.date.day,
                                        //               barRods: [
                                        //                 BarChartRodData(
                                        //                     width: 12,
                                        //                     y: double.parse(e.steps.toString()),
                                        //                     colors: [Colors.blue],
                                        //                     borderRadius: BorderRadius.zero)
                                        //               ],
                                        //             );
                                        //           }).toList(),
                                        //           titlesData: FlTitlesData(
                                        //               leftTitles: SideTitles(
                                        //                 showTitles: true,
                                        //                 //getTextStyles: (value) => TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                        //                 margin: 16,
                                        //                 getTitles: (double value) {
                                        //                   switch (value.toInt()) {
                                        //                     case 100:
                                        //                       return "100";

                                        //                     case 500:
                                        //                       return "500";

                                        //                     case 2500:
                                        //                       return "2500";
                                        //                     case 5000:
                                        //                       return "5000";
                                        //                     case 8000:
                                        //                       return "8000";
                                        //                     // Add more cases for more intervals as needed.
                                        //                     default:
                                        //                       return '';
                                        //                   }
                                        //                 },
                                        //               ),
                                        //               bottomTitles: SideTitles(
                                        //                 showTitles: true,
                                        //                 getTitles: (value) {
                                        //                   print(data);
                                        //                   print(value);
                                        //                   int index = data.indexWhere((stepData) =>
                                        //                       stepData.date.day == value);

                                        //                   if (index == 0) {
                                        //                     return 'Sun';
                                        //                   }
                                        //                   if (index == 1) {
                                        //                     return 'Mon';
                                        //                   }
                                        //                   if (index == 2) {
                                        //                     return 'Tue';
                                        //                   }
                                        //                   if (index == 3) {
                                        //                     return 'Wed';
                                        //                   }
                                        //                   if (index == 4) {
                                        //                     return 'Thur';
                                        //                   }

                                        //                   if (index == 5) {
                                        //                     return 'Fri';
                                        //                   }

                                        //                   if (index == 6) {
                                        //                     return 'Sat';
                                        //                   } else {
                                        //                     return '';
                                        //                   }
                                        //                 },
                                        //                 interval: 1,
                                        //               ))),
                                        //     ),
                                        //   )

                                        : const SizedBox();
                                  }),
                            if (selectedType == 'Day')
                              ValueListenableBuilder(
                                  valueListenable: showShimmer,
                                  builder: (_, shimmer, __) {
                                    return shimmer
                                        ? Column(
                                            children: [
                                              Shimmer.fromColors(
                                                direction: ShimmerDirection.ltr,
                                                enabled: true,
                                                baseColor: Colors.white,
                                                highlightColor: Colors.grey.shade300,
                                                child: Container(
                                                  height: 28.h,
                                                  width: 85.w,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              )
                                            ],
                                          )
                                        : ValueListenableBuilder(
                                            valueListenable: stepsCount,
                                            builder: (_, records, __) {
                                              return records == 0
                                                  ? SizedBox(
                                                      height: 28.h,
                                                      width: 85.w,
                                                      child: const Center(
                                                        child: Text('No steps recorded'),
                                                      ),
                                                    )
                                                  : ValueListenableBuilder(
                                                      valueListenable: stepsListHourlyWise,
                                                      builder: (_, data, __) {
                                                        int minValue = data
                                                            .map((data) => data.steps)
                                                            .reduce((a, b) => a < b ? a : b);

                                                        int maxValue = data
                                                            .map((data) => data.steps)
                                                            .reduce((a, b) => a > b ? a : b);
                                                        int middleValue =
                                                            (minValue + maxValue) ~/ 2;
                                                        double maxt = maxValue / 3;
                                                        double m = middleValue / 2;
                                                        print(maxt);
                                                        List a = [];
                                                        for (var e in data) {
                                                          a.add(e.steps);
                                                        }
                                                        int nearestStep = a.reduce((a, b) =>
                                                            (a - maxt).abs() < (b - maxt).abs()
                                                                ? a
                                                                : b);

                                                        // int minY = minValue - 0; // Adjust the range as needed
                                                        // int maxY = maxValue + 100; // Adjust the range as needed
                                                        print(nearestStep);

                                                        List<int> yThresholdValues = [
                                                          minValue,
                                                          middleValue,
                                                          maxValue,
                                                        ];
                                                        return data != []
                                                            ?
                                                            // : Container(
                                                            //     padding: EdgeInsets.only(
                                                            //         left: 10.sp,
                                                            //         right: 18.sp,
                                                            //         top: 20.sp),
                                                            //     height: 30.h,
                                                            //     child: BarChart(BarChartData(
                                                            //       borderData: FlBorderData(
                                                            //         show:
                                                            //             true, // Show border around the chart
                                                            //         border: Border.all(
                                                            //             color: Colors.transparent,
                                                            //             width:
                                                            //                 15), // Adjust the width to add padding
                                                            //       ),
                                                            //       barGroups: data
                                                            //           .map<BarChartGroupData>((e) {
                                                            //         return BarChartGroupData(
                                                            //           x: e.date,
                                                            //           barRods: [
                                                            //             BarChartRodData(
                                                            //                 width: 4,
                                                            //                 y: double.parse(
                                                            //                     e.steps.toString()),
                                                            //                 colors: [Colors.blue])
                                                            //           ],
                                                            //         );
                                                            //       }).toList(),
                                                            //       gridData: FlGridData(
                                                            //         show: true,
                                                            //         drawHorizontalLine: true,
                                                            //         // horizontalInterval:
                                                            //         //     double.parse(
                                                            //         //         yThresholdValues[0]
                                                            //         //             .toString()),
                                                            //         checkToShowHorizontalLine:
                                                            //             (value) {
                                                            //           print(value);
                                                            //         },
                                                            //         // getDrawingHorizontalLine:
                                                            //         //     (value) {
                                                            //         //   if (a.contains(value)) {
                                                            //         //     return FlLine(
                                                            //         //       color: Colors.grey,
                                                            //         //       strokeWidth: 1,
                                                            //         //       dashArray: yThresholdValues
                                                            //         //                   .indexOf(value
                                                            //         //                       .toInt()) ==
                                                            //         //               1
                                                            //         //           ? [2, 2]
                                                            //         //           : null,
                                                            //         //     );
                                                            //         //   } else {
                                                            //         //     return FlLine(
                                                            //         //         color:
                                                            //         //             Colors.transparent);
                                                            //         //   }
                                                            //         // },
                                                            //       ),
                                                            //       titlesData: FlTitlesData(
                                                            //           leftTitles: SideTitles(
                                                            //             showTitles: true,
                                                            //             //getTextStyles: (value) => TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                                            //             getTitles: (value) {
                                                            //               if (yThresholdValues
                                                            //                   .contains(
                                                            //                       value.toInt())) {
                                                            //                 return value
                                                            //                     .toInt()
                                                            //                     .toString();
                                                            //               }
                                                            //               return '';
                                                            //             },
                                                            //             reservedSize: 40,
                                                            //             margin: 12,
                                                            //             rotateAngle: 0,
                                                            //             interval: 1,
                                                            //             // getTitles: (double value) {
                                                            //             //   switch (value.toInt()) {
                                                            //             //     case 50:
                                                            //             //       return "50";
                                                            //             //     case 250:
                                                            //             //       return "250";
                                                            //             //     // case 250:
                                                            //             //     //   return "250";
                                                            //             //     case 500:
                                                            //             //       return "500";
                                                            //             //     case 750:
                                                            //             //       return "750";
                                                            //             //     case 1000:
                                                            //             //       return "1000";
                                                            //             //     case 2500:
                                                            //             //       return "2500";
                                                            //             //     case 5000:
                                                            //             //       return "5000";
                                                            //             //     case 8000:
                                                            //             //       return "8000";
                                                            //             //     // Add more cases for more intervals as needed.
                                                            //             //     default:
                                                            //             //       return '';
                                                            //             //   }
                                                            //             // },
                                                            //           ),
                                                            //           bottomTitles: SideTitles(
                                                            //             showTitles: true,
                                                            //             getTitles: (value) {
                                                            //               switch (
                                                            //                   value.toInt() % 24) {
                                                            //                 case 0:
                                                            //                   return "12am";
                                                            //                 case 4:
                                                            //                   return "4am";
                                                            //                 case 8:
                                                            //                   return "8am";
                                                            //                 case 12:
                                                            //                   return "12pm";
                                                            //                 case 16:
                                                            //                   return "4pm";
                                                            //                 case 20:
                                                            //                   return "8pm";
                                                            //                 default:
                                                            //                   return '';
                                                            //               }
                                                            //             },
                                                            //             interval: 1,
                                                            //           )),
                                                            //     )

                                                            //         // BarChartData(
                                                            //         //   titlesData: FlTitlesData(
                                                            //         //       bottomTitles: SideTitles(
                                                            //         //     showTitles: true,
                                                            //         //     // getTitles: getMonthName,
                                                            //         //     interval: 2,
                                                            //         //   )),

                                                            //         //   ],
                                                            //         // ),
                                                            //         ),
                                                            //   )

                                                            SizedBox(
                                                                height: 26.h,
                                                                child: AnimatedOpacity(
                                                                  opacity: 1.0,
                                                                  duration: const Duration(
                                                                      milliseconds: 4000),
                                                                  child: SfCartesianChart(
                                                                      // backgroundColor: Colors.white,

                                                                      plotAreaBorderWidth: 0,
                                                                      borderWidth: 0,
                                                                      borderColor:
                                                                          Colors.transparent,
                                                                      primaryXAxis: CategoryAxis(
                                                                        interval: 4,
                                                                        majorTickLines:
                                                                            const MajorTickLines(
                                                                                width: 0),
                                                                        majorGridLines:
                                                                            const MajorGridLines(
                                                                          width:
                                                                              0, // Set to 0 to hide the major grid lines
                                                                        ),
                                                                      ),
                                                                      primaryYAxis: NumericAxis(
                                                                        labelStyle: const TextStyle(
                                                                          fontFamily: 'Poppins',
                                                                        ),
                                                                        axisLine: const AxisLine(
                                                                            width: 0),
                                                                        majorTickLines:
                                                                            const MajorTickLines(
                                                                                width: 0),
                                                                        // majorGridLines:
                                                                        //     MajorGridLines(width: 0),
                                                                        interval:
                                                                            yThresholdValues[2]
                                                                                .toDouble(),
                                                                      ),
                                                                      // tooltipBehavior:
                                                                      //     TooltipBehavior(
                                                                      //         enable: true),
                                                                      series: <
                                                                          ChartSeries<
                                                                              StepsDataHourly,
                                                                              String>>[
                                                                        StackedColumnSeries<
                                                                            StepsDataHourly,
                                                                            String>(
                                                                          dataSource: data,
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  5),

                                                                          xValueMapper:
                                                                              (StepsDataHourly
                                                                                      sales,
                                                                                  _) {
                                                                            int value = int.parse(
                                                                                sales.date
                                                                                    .toString());
                                                                            // if (value == 0 ||
                                                                            //     value == 4 ||
                                                                            //     value == 8 ||
                                                                            //     value == 12 ||
                                                                            //     value == 16 ||
                                                                            //     value == 20) {
                                                                            //   String period =
                                                                            //       value < 12
                                                                            //           ? 'am'
                                                                            //           : 'pm';
                                                                            //   int hour = value % 12;
                                                                            //   if (hour == 0) {
                                                                            //     hour = 12;
                                                                            //   }
                                                                            //   return '$hour$period';
                                                                            // }
                                                                            // return '';
                                                                            String period =
                                                                                value < 12
                                                                                    ? 'am'
                                                                                    : 'pm';
                                                                            int hour = value % 12;
                                                                            if (hour == 0) {
                                                                              return '12$period';
                                                                            } else {
                                                                              return '$hour$period';
                                                                            }

                                                                            // switch (
                                                                            //     sales.date.toInt()) {
                                                                            //   case 0:
                                                                            //     return "12am";
                                                                            //   case 4:
                                                                            //     return "4am";
                                                                            //   case 8:
                                                                            //     return "8am";
                                                                            //   case 12:
                                                                            //     return "12pm";
                                                                            //   case 16:
                                                                            //     return "4pm";
                                                                            //   case 20:
                                                                            //     return "8pm";
                                                                            //   case 24:
                                                                            //     return "12am";
                                                                            //   default:
                                                                            //     return '';
                                                                            // }
                                                                          },
                                                                          yValueMapper:
                                                                              (StepsDataHourly
                                                                                          sales,
                                                                                      _) =>
                                                                                  sales.steps,
                                                                          color: Colors
                                                                              .blue, // Set custom color for this series
                                                                          width: .30,
                                                                        )
                                                                      ]),
                                                                ),
                                                              )
                                                            : const SizedBox();
                                                      });
                                            });
                                  }),
                          ],
                        );
                      });
                });
          }),
    );
  }

  Container numberContainer(String count) {
    return Container(
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 192, 214, 252)),
      child: Center(
          child: Text(
        count,
        style: const TextStyle(color: Colors.blue),
      )),
    );
  }

  String getDayName(DateTime dateTime) {
    return DateFormat('EEEE').format(dateTime);
  }

  //the circle container (Highlighted stack) size will change based on the steps count.......
  double calculateContainerSize(int value) {
    // Adjust these constants as needed to control the size change rate
    const double minValue = 50.0;
    const double maxValue = 400.0;
    const double minContainerSize = 40.0;
    const double maxContainerSize = 100.0;

    double scaledValue = (value - minValue) / (maxValue - minValue);
    double newSize = minContainerSize + (scaledValue * (maxContainerSize - minContainerSize));

    return newSize;
  }

  double getSize(int steps) {
    if (steps > 0 && steps < 500) {
      return 0.45;
    }
    if (steps > 500 && steps < 1000) {
      return 0.55;
    }
    if (steps > 1000 && steps < 1500) {
      return 0.6;
    }
    if (steps > 1500 && steps < 2000) {
      return 0.65;
    }
    if (steps > 2000 && steps < 3000) {
      return 0.7;
    }
    if (steps > 3000 && steps < 4000) {
      return 0.8;
    }
    if (steps > 4000 && steps < 5000) {
      return 0.9;
    }
    if (steps > 5000 && steps < 27000) {
      return 1.0;
    }
    // if (steps > 4500) {
    //   return 1.4;
    // }
    // if (steps > 10000) {
    //   return 1.5;
    // }
    // if (steps > 20000) {
    //   return 1.6;
    // }
    // if (steps > 40000) {
    //   return 1.7;
    // }
    return 0.5;
  }

  dateFormat(DateTime now1, DateTime now2, String selectType) {
    if (selectType == 'Weekly') {
      String formattedTime1 = DateFormat('d MMM').format(now1);
      String formattedTime2 = DateFormat('d MMM').format(now2);

      int year1 = now1.year;
      int year2 = now2.year;

      String monthName1 = DateFormat('MMM').format(now1);
      String monthName2 = DateFormat('MMM').format(now2);

      String displayString;
      if (year1 == year2) {
        if (monthName1 == monthName2) {
          displayString = '$formattedTime1 - $formattedTime2 $year1';
        } else {
          displayString = '$formattedTime1 - $formattedTime2 $year1';
        }
      } else {
        displayString = '$formattedTime1 $year1 - $formattedTime2 $year2';
      }
      print(displayString);
      return displayString;
    } else if (selectType == 'Day') {
      bool isSameDay = now1.year == now2.year && now1.month == now2.month && now1.day == now2.day;

      String formattedTime1 = DateFormat('EEEE, d MMMM').format(now1);
      String formattedTime2 = isSameDay ? '' : DateFormat('EEEE, d MMMM').format(now2);

      String displayString;
      if (isSameDay) {
        displayString = formattedTime1;
      } else {
        displayString = '$formattedTime1 - $formattedTime2';
      }
      return displayString;
    } else if (selectType == 'Monthly') {
      bool isSameMonthAndYear = now1.year == now2.year && now1.month == now2.month;

      String formattedTime1 = DateFormat('MMMM y').format(now1);
      String formattedTime2 = isSameMonthAndYear ? '' : DateFormat('MMMM y').format(now2);

      String displayString;
      if (isSameMonthAndYear) {
        displayString = formattedTime1;
      } else {
        displayString = '$formattedTime1 - $formattedTime2';
      }
      return displayString;
    }
  }

  String getMonthName(int monthNumber, int year) {
    DateTime dateTime = DateTime(year, monthNumber); // You can use any year here, it doesn't matter
    return DateFormat('MMMM').format(dateTime);
  }

  int getDaysInMonth(int month, int year) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Invalid month: $month. Month should be between 1 and 12.');
    }

    if (month == 2) {
      // February
      return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      // April, June, September, November
      return 30;
    } else {
      return 31;
    }
  }

  List<BarChartGroupData> getBarGroups() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(width: 12, y: 8, colors: [Colors.blue], borderRadius: BorderRadius.zero)
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(width: 12, y: 4, colors: [Colors.blue], borderRadius: BorderRadius.zero)
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(width: 12, y: 6, colors: [Colors.blue], borderRadius: BorderRadius.zero)
        ],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(width: 12, y: 5, colors: [Colors.blue], borderRadius: BorderRadius.zero)
        ],
      ),
      BarChartGroupData(
        x: 7,
        barRods: [
          BarChartRodData(width: 12, y: 10, colors: [Colors.blue], borderRadius: BorderRadius.zero)
        ],
      ),
      // Add more BarChartGroupData as needed
    ];
  }

  List<BarChartGroupData> getBarGroupsForDays() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(width: 5, y: 6, colors: [Colors.blue])
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(width: 5, y: 11, colors: [Colors.blue])
        ],
      ),
      BarChartGroupData(
        x: 7,
        barRods: [
          BarChartRodData(width: 5, y: 5, colors: [Colors.blue])
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(width: 5, y: 7, colors: [Colors.blue])
        ],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(width: 5, y: 3, colors: [Colors.blue])
        ],
      ),
      BarChartGroupData(
        x: 7,
        barRods: [
          BarChartRodData(width: 5, y: 5, colors: [Colors.blue])
        ],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(width: 5, y: 3, colors: [Colors.blue])
        ],
      ),
      // Add more BarChartGroupData as needed
    ];
  }

  List<FlSpot> dummyData1 = [
    FlSpot(1, 1.0),
    FlSpot(2, 12.0),
    FlSpot(3, 12.0),
    FlSpot(5, 15.0),
  ];

  final List<FlSpot> dummyData2 = List.generate(8, (int index) {
    return FlSpot(index.toDouble(), index * Random().nextDouble());
  });

  final List<FlSpot> dummyData3 = List.generate(8, (int index) {
    return FlSpot(index.toDouble(), index * Random().nextDouble());
  });

  String getHours(int value) {
    switch (value.toInt()) {
      case 0:
        return "12am";
      case 3:
        return "4am";
      case 6:
        return "8am";
      case 9:
        return "12pm";
      case 12:
        return "4pm";
      case 15:
        return "8pm";
      case 18:
        return "12am";
      default:
        return '';
    }
  }

  DateTime currentweekDayFinder() {
    final DateTime now1 = DateTime.now();
    final DateTime now = DateTime(now1.year, now1.month, now1.day);
    // log("Current Day => " + DateFormat('EEEE').format(now));
    if (now.weekday == DateTime.sunday) {
      return now;
    }
    return DateTime(now.year, now.month, now.day - now.weekday);
  }
}

class ChartData {
  DateTime date;
  double values;
  ChartData(this.date, this.values);
}

class StepsModel {
  String TimeStamp, Step_travelled;
  //, Duration, Calories, Distance;
  StepsModel(this.TimeStamp, this.Step_travelled
      //, this.Duration, this.Calories, this.Distance
      );
}
