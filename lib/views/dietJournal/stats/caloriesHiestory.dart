// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/event_utils.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/dietJournalNew.dart';
import 'package:ihl/views/dietJournal/journal_graph.dart';
import 'package:ihl/views/dietJournal/models/get_activity_log_model.dart';
import 'package:ihl/views/dietJournal/models/get_food_log_model.dart';
import 'package:ihl/views/dietJournal/stats/activity_log_events.dart';
import 'package:ihl/views/dietJournal/stats/foodEvents.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

int tabControllerindex = 0;

class TableEventsExample extends StatefulWidget {
  List<MealsListData> mealsListData;
  TableEventsExample(this.mealsListData);

  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  ValueNotifier<List<Event>> _selectedEvents;
  //CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode =
      RangeSelectionMode.toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;
  DateTime _rangeStart;
  DateTime _rangeEnd;
  List<GetFoodLog> foodDetails;
  List<GetActivityLog> activityLogDetails;
  bool isLoadingFood = true;
  bool isLoadingActivity = true;
  ListApis listApis = ListApis();
  var foodDetailLen = 1;
  var activityDetailLen = 1;
  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    //_selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _onDaySelectedfun(_selectedDay, _selectedDay);
    getData(_selectedDay);
  }

  @override
  void dispose() {
    tabControllerindex = 0;
    _selectedEvents.dispose();
    super.dispose();
  }

  // List<Event> _getEventsForDay(DateTime day) {
  //   // Implementation example

  //   return kEvents[day] ?? [];
  // }

  // List<Event> _getEventsForRange(DateTime start, DateTime end) {
  //   // Implementation example
  //   final days = daysInRange(start, end);

  //   return [
  //     for (final d in days) ..._getEventsForDay(d),
  //   ];
  // }

  // void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
  //   if (!isSameDay(_selectedDay, selectedDay)) {
  //     setState(() {
  //       _selectedDay = selectedDay;
  //       _focusedDay = focusedDay;
  //       _rangeStart = null; // Important to clean those
  //       _rangeEnd = null;
  //       _rangeSelectionMode = RangeSelectionMode.toggledOff;
  //     });

  //     _selectedEvents.value = _getEventsForDay(selectedDay);
  //   }
  // }

  //void _genterateEvnts() {}
  getData(activityDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("selected_food_log_date");
    prefs.setString("selected_food_log_date", activityDate.toString());
    var _selectedDateString = DateFormat("yyyy-MM-dd").format(activityDate);
    DateTime fromDate = DateFormat("yyyy-MM-dd").parse(_selectedDateString);
    var tillDate = _selectedDateString + " 23:59:00";
    var activityFalseList = 0;
    var activityLogHistory =
        await listApis.getUserActivityLogHistoryApi(fromDate: fromDate, tillDate: tillDate);
    setState(() {
      activityLogDetails = activityLogHistory;
      isLoadingActivity = false;
    });

    for (var i = 0; i < activityLogDetails.length; i++) {
      if (activityLogDetails[i].activityDetails.length == 0) {
        setState(() {
          activityFalseList += 1;
        });
      }
      print(activityFalseList);
      if (activityFalseList == activityLogDetails.length) {
        setState(() {
          activityDetailLen = 0;
        });
      } else {
        setState(() {
          activityDetailLen = 1;
        });
      }
    }
    //return ActivityLogEvnets(activityLogDetails, activityDetailLen);
  }

  _onDaySelectedfun(DateTime selectedDate, DateTime FocusedDate) async {
    setState(() {
      _selectedDay = selectedDate;
      _focusedDay = FocusedDate;
    });
    var _selectedDateString = DateFormat("yyyy-MM-dd").format(selectedDate);
    DateTime fromDate = DateFormat("yyyy-MM-dd").parse(_selectedDateString);
    var tillDate = _selectedDateString + " 23:59:00";
    // print(tillDate);
    var foodLogHistory = await ListApis.getUserFoodLogHistoryApi(
      fromDate: fromDate,
      tillDate: tillDate,
    );
    // print(_selectedDateString.toString());
    // print(tillDate);
    // print(foodLogHistory);
    setState(() {
      foodDetails = foodLogHistory;
      isLoadingFood = false;
    });
    print(foodLogHistory);
    verify(foodDetails);
    getData(_selectedDay);

    return FoodLogDetails(widget.mealsListData, foodDetails, foodDetailLen);

    // return (foodLogHistory);
  }

  void verify(foodDetails) {
    var falseList = 0;
    for (var i = 0; i < foodDetails.length; i++) {
      if (foodDetails[i].food.length == 0) {
        setState(() {
          falseList += 1;
        });
      }
      print("$falseList+");
      if (falseList == foodDetails.length) {
        setState(() {
          foodDetailLen = 0;
          //isLoadingFood = false;
        });
      } else {
        setState(() {
          foodDetailLen = 1;
          //isLoadingFood = false;
        });
      }
    }
  }

  // void _onRangeSelected(DateTime start, DateTime end, DateTime focusedDay) {
  //   setState(() {
  //     _selectedDay = null;
  //     _focusedDay = focusedDay;
  //     _rangeStart = start;
  //     _rangeEnd = end;
  //     _rangeSelectionMode = RangeSelectionMode.toggledOn;
  //   });

  //   // `start` or `end` could be null
  //   if (start != null && end != null) {
  //     _selectedEvents.value = _getEventsForRange(start, end);
  //   } else if (start != null) {
  //     _selectedEvents.value = _getEventsForDay(start);
  //   } else if (end != null) {
  //     _selectedEvents.value = _getEventsForDay(end);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      onWillPop: () {
        Get.to(DietJournalNew());
      },
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          initialIndex: tabControllerindex,
          child: Container(
            color: AppColors.bgColorTab,
            // color: FitnessAppTheme.white,
            child: CustomPaint(
              painter: BackgroundPainter(
                  primary: AppColors.primaryAccentColor.withOpacity(0.8),
                  secondary: AppColors.primaryAccentColor),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.arrow_back_ios),
                                color: Colors.white,
                                onPressed: () {
                                  Get.to(DietJournalNew());
                                }
                                //old flow  // => Get.offAll(DietJournalNew(),
                                //     predicate: (route) => Get.currentRoute == Routes.Home),
                                ),
                            Text(
                              'History',
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.w500, color: Colors.white),
                              // style: TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 24.0,
                              //     fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 20.0, bottom: 8.0, top: 8.0, left: 0.8),
                              child: IconButton(
                                icon: Icon(Icons.auto_graph),
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CalorieGraph()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: ScUtil().setHeight(20),
                  // ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            TableCalendar<Event>(
                              firstDay: kFirstDay,
                              lastDay: kLastDay,
                              focusedDay: _focusedDay,
                              rowHeight: 35.0,
                              availableCalendarFormats: {CalendarFormat.month: 'Month'},
                              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                              // rangeStartDay: _rangeStart,
                              // rangeEndDay: _rangeEnd,
                              //calendarFormat: ,
                              // rangeSelectionMode: _rangeSelectionMode,
                              // eventLoader: _getEventsForDay,
                              startingDayOfWeek: StartingDayOfWeek.monday,
                              calendarStyle: CalendarStyle(
                                selectedDecoration: BoxDecoration(
                                    color: AppColors.primaryAccentColor, shape: BoxShape.circle),
                                todayDecoration: BoxDecoration(
                                    color: AppColors.primaryAccentColor.withOpacity(0.3),
                                    shape: BoxShape.circle),
                                // Use `CalendarStyle` to customize the UI
                                // todayTextStyle: TextStyle(
                                //     color: AppColors.primaryAccentColor),
                                // selectedTextStyle: TextStyle(
                                //     color: AppColors.primaryAccentColor),
                                outsideDaysVisible: false,
                              ),
                              onDaySelected: _onDaySelectedfun,
                              //onRangeSelected: _onRangeSelected,
                              // onFormatChanged: (format) {
                              //   if (_calendarFormat != format) {
                              //     setState(() {
                              //       _calendarFormat = format;
                              //     });
                              //   }
                              // },
                              // onPageChanged: (focusedDay) {
                              //   _focusedDay = focusedDay;
                              // },
                            ),
                            //SizedBox(height: .0),
                            Container(
                              child: PreferredSize(
                                preferredSize: Size.fromHeight(kToolbarHeight),
                                child: Text(
                                  'Activity Logs',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                // child: TabBar(
                                //   tabs: [
                                //     // Tab(text: 'Daily'),
                                //     Tab(
                                //       text: "Food Logs",
                                //     ),
                                //     Tab(text: 'Activity Logs'),
                                //   ],
                                //   isScrollable: true,
                                //   indicatorColor: AppColors.primaryAccentColor,
                                //   labelColor: AppColors.primaryAccentColor,
                                //   unselectedLabelColor: Colors.grey,
                                //   labelStyle: TextStyle(fontWeight: FontWeight.w900),
                                // ),
                              ),
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
                                  // child: TabBarView(
                                  //   children: [
                                  //     // DailyTab(),
                                  //     // MonthlyTab(),isLoading
                                  //
                                  //     // isLoadingFood
                                  //     //     ? Center(child: CircularProgressIndicator())
                                  //     //     : FoodLogDetails(
                                  //     //         widget.mealsListData, foodDetails, foodDetailLen),
                                  //
                                  //     // GroupedFillColorBarChart.withSampleData(),
                                  //   ],
                                  // ),
                                  child: isLoadingActivity
                                      ? Center(child: CircularProgressIndicator())
                                      : ActivityLogEvnets(activityLogDetails, activityDetailLen),
                                ),
                              ),
                            ),
                            // isLoading
                            //     ? CircularProgressIndicator()
                            //     : FoodLogDetails(foodDetails, activityLogDetails),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// Column(
//                 children: [
//                   TableCalendar<Event>(
//                     firstDay: kFirstDay,
//                     lastDay: kLastDay,
//                     focusedDay: _focusedDay,
//                     selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//                     rangeStartDay: _rangeStart,
//                     rangeEndDay: _rangeEnd,
//                     calendarFormat: _calendarFormat,
//                     rangeSelectionMode: _rangeSelectionMode,
//                     eventLoader: _getEventsForDay,
//                     startingDayOfWeek: StartingDayOfWeek.monday,
//                     calendarStyle: CalendarStyle(
//                       // Use `CalendarStyle` to customize the UI
//                       outsideDaysVisible: false,
//                     ),
//                     onDaySelected: _onDaySelected,
//                     onRangeSelected: _onRangeSelected,
//                     onFormatChanged: (format) {
//                       if (_calendarFormat != format) {
//                         setState(() {
//                           _calendarFormat = format;
//                         });
//                       }
//                     },
//                     onPageChanged: (focusedDay) {
//                       _focusedDay = focusedDay;
//                     },
//                   ),
//                   const SizedBox(height: 8.0),
//                   Expanded(
//                     child: ValueListenableBuilder<List<Event>>(
//                       valueListenable: _selectedEvents,
//                       builder: (context, value, _) {
//                         return ListView.builder(
//                           itemCount: value.length,
//                           itemBuilder: (context, index) {
//                             return Container(
//                               margin: const EdgeInsets.symmetric(
//                                 horizontal: 12.0,
//                                 vertical: 4.0,
//                               ),
//                               decoration: BoxDecoration(
//                                 border: Border.all(),
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               child: ListTile(
//                                 onTap: () => print('${value[index]}'),
//                                 title: Text('${value[index]}'),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
