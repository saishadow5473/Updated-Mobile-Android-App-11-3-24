import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';

import 'package:ihl/new_design/presentation/controllers/healthJournalControllers/calendarController.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:ihl/views/dietJournal/activity/edit_activity_log.dart';
import 'package:ihl/widgets/searchFields.dart';
import 'package:intl/intl.dart';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../../views/dietJournal/activity/activity_detail.dart';
import '../../../../../../views/dietJournal/activity/activity_list_view.dart';
import '../../../../../../views/dietJournal/activity/today_activity.dart';
import '../../../../../../views/dietJournal/apis/list_apis.dart';
import '../../../../../../views/gamification/dateutils.dart';
import '../../../../../app/utils/textStyle.dart';
import 'activityHistoryScreen.dart';
import 'activitySearchScreen.dart';
import 'viweAll.dart';

class ActivityLandingScreen extends StatefulWidget {
  final todayLogList;
  ActivityLandingScreen({Key key, this.todayLogList});

  @override
  State<ActivityLandingScreen> createState() => _ActivityLandingScreenState();
}

class _ActivityLandingScreenState extends State<ActivityLandingScreen> {
  @override
  void initState() {
    _selectedDate = "Today";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initDateSync();
    });

    // TODO: implement initState
    super.initState();
  }

  ListApis listApis = ListApis();
  RxBool _navigate = true.obs;
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  TextEditingController _searchController = TextEditingController();
  DateTime _focusDay = DateTime.now();
  String todayDate = DateFormat("yyyy-MM-dd")
      .format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
  String _selectedDate = DateFormat('dd MMM').format(DateTime.now());
  DateTime _selectedDay;
  DateTime dt = DateTime.now();
  final ClendarController _calController = Get.put(ClendarController());
  bool isDateNotInLastWeek(DateTime selectedDate) {
    DateTime currentDate = DateTime.now();
    DateTime lastWeek = currentDate.subtract(const Duration(days: 7));
    return !selectedDate.isBefore(lastWeek);
  }

  initDateSync() async {
    DateTime now = DateTime.now();
    _selectedDay = _calController.focusedDay.value = now;
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
    _calController.updateDate(Date: _selectedDate, focusedDate: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      contentColor: "true",
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            listApis.getUserTodaysFoodLogHistoryApi().then((value) {
              Get.off(TodayActivityScreen(
                todaysActivityData: value['activity'],
                otherActivityData: value['previous_activity'],
              ));
            });
            // Get.back();
          }, //replaces the screen to Main dashboard
          color: Colors.white,
        ),
        title: Padding(padding: EdgeInsets.only(left: 15.w), child: const Text("Log Activity")),
        backgroundColor: HexColor('#6F72CA'),
      ),
      content: WillPopScope(
        onWillPop: () => listApis.getUserTodaysFoodLogHistoryApi().then((value) {
          Get.off(TodayActivityScreen(
            todaysActivityData: value['activity'],
            otherActivityData: value['previous_activity'],
          ));
          return true;
        }),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 8.0, right: 2, bottom: 8),
                    child: Obx(() => Text(_calController.selectedDate.value)),
                  ),
                  Obx(() => _calController.calendarSelected.value == 0
                      ? IconButton(
                          onPressed: () {
                            _calController.updateTab(value: 1);
                          },
                          icon: Icon(
                            Icons.arrow_drop_down_sharp,
                            color: HexColor('#6F72CA'),
                          ))
                      : IconButton(
                          onPressed: () {
                            _calController.updateTab(value: 0);
                          },
                          icon: Icon(
                            Icons.arrow_drop_up_sharp,
                            color: HexColor('#6F72CA'),
                          )))
                ],
              ),
              Obx(() {
                return Visibility(
                  visible: _calController.calendarSelected.value == 0,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            _calController.focusedDay.value =
                                _calController.focusedDay.value.subtract(const Duration(days: 7));
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.arrow_back_ios_rounded)),
                      Expanded(
                        child: TableCalendar(
                          lastDay: DateTime.now(),
                          firstDay: DateTime.now().subtract(const Duration(days: 1200)),
                          focusedDay: _calController.focusedDay.value,
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          rangeStartDay: DateTime.now().subtract(const Duration(days: 1200)),
                          rangeSelectionMode: RangeSelectionMode.toggledOn,
                          calendarFormat: CalendarFormat.week,
                          headerVisible: false,
                          onPageChanged: (DateTime i) => _calController.focusedDay.value = i,
                          calendarStyle: CalendarStyle(
                            rangeStartDecoration:
                                const BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
                            todayDecoration: BoxDecoration(
                                color: Colors.blueGrey.withOpacity(0.2), shape: BoxShape.rectangle),
                            markersAlignment: Alignment.topCenter,
                            outsideTextStyle: TextStyle(
                                fontSize: 15.sp,
                                color: AppColors.blackText,
                                fontWeight: FontWeight.bold),
                            todayTextStyle: TextStyle(
                                fontSize: 15.sp,
                                color: AppColors.blackText,
                                fontWeight: FontWeight.bold),
                            rangeEndTextStyle: TextStyle(
                                fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.bold),
                            defaultTextStyle: TextStyle(
                                fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.bold),
                            weekendTextStyle: TextStyle(
                                fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.bold),
                            selectedTextStyle: TextStyle(
                                fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.bold),
                            selectedDecoration: BoxDecoration(
                                color: HexColor('#6F72CA').withOpacity(0.4),
                                shape: BoxShape.rectangle),
                            withinRangeTextStyle: TextStyle(
                                fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.bold),
                            rangeStartTextStyle: TextStyle(
                                fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                  fontSize: 15.sp,
                                  color: HexColor('#6F72CA'),
                                  fontWeight: FontWeight.bold),
                              weekendStyle: TextStyle(
                                  fontSize: 15.sp,
                                  color: HexColor('#6F72CA'),
                                  fontWeight: FontWeight.bold)),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(fontSize: 14.sp, color: HexColor('#6F72CA')),
                          ),
                          selectedDayPredicate: (DateTime day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (DateTime selectedDay, DateTime focusedDay) async {
                            _navigate.value = isDateNotInLastWeek(focusedDay);
                            gNavigate = _navigate;
                            final yesterday = DateFormat("dd-MM-yyyy").format(DateTime(
                                DateTime.now().year, DateTime.now().month, DateTime.now().day - 1));
                            _selectedDay = selectedDay;
                            _calController.updateDate(
                                Date: DateFormat("dd MMM").format(selectedDay),
                                focusedDate: selectedDay);
                            var endDate =
                                "${DateFormat("yyyy-MM-dd").format(DateTime(selectedDay.year, selectedDay.month, selectedDay.day))} 23:59:00";
                            String startDate = DateFormat("yyyy-MM-dd").format(
                                DateTime(selectedDay.year, selectedDay.month, selectedDay.day));

                            _calController.updateActivityDetails(
                              startDate,
                              endDate,
                            );

                            if (_calController.selectedDate.value ==
                                DateFormat("dd MMM").format(DateTime.now())) {
                              _calController.updateDate(Date: "Today", focusedDate: selectedDay);
                            } else if (yesterday == DateFormat("dd-MM-YYYY").format(selectedDay)) {
                              _calController.updateDate(
                                  Date: "Yesterday", focusedDate: selectedDay);
                            } else {
                              _calController.updateDate(
                                  Date: DateFormat("dd MMM").format(selectedDay),
                                  focusedDate: selectedDay);
                            }
                            dt = selectedDay;
                            _calController.focusedDay.value = focusedDay;
                            if (mounted) setState(() {});
                          },
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            final DateTime _now = DateTime.now();
                            DateTime _currentWeekMonday = _now;
                            while (_currentWeekMonday.weekday != DateTime.monday) {
                              _currentWeekMonday =
                                  _currentWeekMonday.subtract(const Duration(days: 1));
                            }
                            DateTime previousMonday = _calController.focusedDay.value;
                            while (previousMonday.weekday != DateTime.monday) {
                              previousMonday = previousMonday.subtract(const Duration(days: 1));
                            }

                            if (!_calController.focusedDay.value.isSameDate(DateTime.now()) &&
                                !_currentWeekMonday.isSameDate(previousMonday)) {
                              _calController.focusedDay.value =
                                  _calController.focusedDay.value.add(const Duration(days: 7));
                              if (_calController.focusedDay.value
                                  .isAfterOrEqualTo(_currentWeekMonday)) {
                                _calController.focusedDay.value = _now;
                              }
                            }
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.arrow_forward_ios_rounded)),
                    ],
                  ),
                );
              }),
              Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SearchFieldWidget.searchWidget(
                    searchController: _searchController,
                    lable: 'Search Activity',
                    baseColor: HexColor('#6F72CA'),
                    onTap: () {
                      Get.to(ActivitySearchScreen(
                        todayLogList: widget.todayLogList,
                        selectedDate: _selectedDay,
                      ));
                      // if (_navigate.value) {
                      //
                      // }
                    },
                    autoFocus: false,
                    keyBoardDisable: true,
                    onChanged: null,
                  )),
              GetBuilder<ClendarController>(
                  initState: (GetBuilderState<ClendarController> y) => _calController
                      .updateActivityDetails(formattedDate, "$formattedDate 23:59:00"),
                  id: "Activity Data",
                  builder: (ClendarController activity_details) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0, top: 5.0),
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 13.0, top: 12, bottom: 12, right: 18),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Activity Logs",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: HexColor('#6F72CA'),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Visibility(
                                    visible: _calController.activityLogHistory.isNotEmpty,
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(ActivityLogHistoryScreen(
                                          viewHistory: _calController.activityLogHistory,
                                        ));
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            "View All ",
                                            style: TextStyle(
                                              color: HexColor('#6F72CA'),
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios_outlined,
                                              size: 15.sp, color: HexColor('#6F72CA')),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            _calController.loading
                                ? Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    enabled: true,
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey.shade300,
                                    child: Container(
                                      height: 5.h,
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  )
                                : _calController.activityLogHistory != null
                                    ? _calController.activityLogHistory.isEmpty
                                        ? SizedBox(
                                            height: 12.h,
                                            child: Center(
                                                child: _calController.selectedDate.value == "Today"
                                                    ? Text(
                                                        "No Activity have been logged today",
                                                        style: AppTextStyles.ShadowFonts,
                                                      )
                                                    : Text(
                                                        "No Activity Logged on the day",
                                                        style: AppTextStyles.ShadowFonts,
                                                      )),
                                          )
                                        : SizedBox(
                                            height: _calController.activityLogHistory.length > 4
                                                ? 4 * 7.8.h
                                                : _calController.activityLogHistory.length * 8.h,
                                            child: ListView.builder(
                                                itemCount: _calController.activityLogHistory.length,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (BuildContext cntx, int index) {
                                                  return SizedBox(
                                                    height: 7.8.h,
                                                    child: ListTile(
                                                      onTap: () {
                                                        Get.to(EditActivityLogScreen(
                                                          activityId: _calController
                                                              .activityLogHistory[index]
                                                              .activityDetails[0]
                                                              .activityDetails[0]
                                                              .activityId,
                                                          duration: _calController
                                                              .activityLogHistory[index]
                                                              .activityDetails[0]
                                                              .activityDetails[0]
                                                              .activityDuration,
                                                          logTime: _calController
                                                              .activityLogHistory[index]
                                                              .activityLogTime,
                                                          logId: _calController
                                                              .activityLogHistory[index]
                                                              .activityLogId,
                                                          today: false,
                                                        ));
                                                      },
                                                      leading: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            width: 60.w,
                                                            child: Text(
                                                              _calController
                                                                      .activityLogHistory[index]
                                                                      .activityDetails[0]
                                                                      .activityDetails[0]
                                                                      .activityName ??
                                                                  " ",
                                                              style: AppTextStyles.blackText1,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${_calController.activityLogHistory[index].activityDetails[0].activityDetails[0].activityDuration} Minutes',
                                                            style: AppTextStyles.ShadowFonts1,
                                                          )
                                                        ],
                                                      ),
                                                      // subtitle: Text(splitedTxt[0]),
                                                      trailing: SizedBox(
                                                        width: 25.w,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceAround,
                                                          children: [
                                                            Text(
                                                              "${_calController.activityLogHistory[index].totalCaloriesBurned} Cal",
                                                              style: AppTextStyles.ShadowFonts2,
                                                            ),
                                                            Icon(
                                                              Icons.add,
                                                              color: HexColor('#6F72CA'),
                                                            )
                                                            // Obx(() => Icon(
                                                            //   Icons.add,
                                                            //   color: _navigate.value
                                                            //       ? widget.bgColor
                                                            //       : Colors.grey,
                                                            //   size: 21.sp,
                                                            // ))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }))
                                    : Shimmer.fromColors(
                                        direction: ShimmerDirection.ltr,
                                        enabled: true,
                                        baseColor: Colors.white,
                                        highlightColor: Colors.grey.shade300,
                                        child: Container(
                                          height: 5.h,
                                          width: 30.w,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                          ],
                        ),
                      ),
                    );
                  }),
              SizedBox(
                height: 2.h,
              ),
              GetBuilder<ClendarController>(
                  id: "Fav Activity Data",
                  builder: (ClendarController favActivity) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0, top: 5.0),
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 13.0, top: 12, bottom: 12, right: 18),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Favourite Activity",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: HexColor('#6F72CA'),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Visibility(
                                    visible: _calController.favDetails.isNotEmpty,
                                    child: InkWell(
                                      onTap: () {
                                        // Get.to(ActivityDetailScreen(
                                        //   allList: ActivityWidgets.selectedIndex.value
                                        //       .toString(),
                                        //   activityObj: searchResults[index],
                                        //   todayLogList: widget.todayLogList,
                                        //   selectedDate: widget.selectedDate,
                                        // ));
                                        Get.to(ViewAllActivity(
                                          viewAllData: _calController.favDetails,
                                          selctedDate: _selectedDay,
                                          screenType: 'Favourite Activity',
                                        ));
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            "View All ",
                                            style: TextStyle(
                                              color: HexColor('#6F72CA'),
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios_outlined,
                                              size: 15.sp, color: HexColor('#6F72CA')),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            _calController.favLoading
                                ? Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    enabled: true,
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey.shade300,
                                    child: Container(
                                      height: 5.h,
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  )
                                : _calController.favDetails != null
                                    ? _calController.favDetails.isEmpty
                                        ? SizedBox(
                                            height: 12.h,
                                            child: Center(
                                                child: _calController.selectedDate.value == "Today"
                                                    ? Text(
                                                        "No Favourite Activity",
                                                        style: AppTextStyles.ShadowFonts,
                                                      )
                                                    : Text(
                                                        "No Favourite Activity",
                                                        style: AppTextStyles.ShadowFonts,
                                                      )),
                                          )
                                        : SizedBox(
                                            height: _calController.favDetails.length > 4
                                                ? 4 * 7.8.h
                                                : _calController.favDetails.length * 8.h,
                                            child: ListView.builder(
                                                itemCount: _calController.favDetails.length,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (BuildContext cntx, int index) {
                                                  return SizedBox(
                                                    height: 7.8.h,
                                                    child: ListTile(
                                                      onTap: () {
                                                        Get.to(ActivityDetailScreen(
                                                          // allList: index
                                                          //     .toString(),
                                                          activityObj:
                                                              _calController.favDetails[index],
                                                          todayLogList: widget.todayLogList,
                                                          selectedDate: _selectedDay,
                                                        ));
                                                      },
                                                      leading: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            width: 60.w,
                                                            child: Text(
                                                              _calController.favDetails[index]
                                                                      .activityName ??
                                                                  " ",
                                                              style: AppTextStyles.blackText1,
                                                            ),
                                                          ),
                                                          Text(
                                                            _calController.favDetails[index]
                                                                        .activityType ==
                                                                    "L"
                                                                ? "Light Impact"
                                                                : _calController.favDetails[index]
                                                                            .activityType ==
                                                                        "M"
                                                                    ? "Medium Impact"
                                                                    : "High Impact",
                                                            style: AppTextStyles.ShadowFonts1,
                                                          )
                                                        ],
                                                      ),
                                                      // subtitle: Text(splitedTxt[0]),
                                                      trailing: SizedBox(
                                                        width: 25.w,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              "${_calController.favDetails[index].activityMetValue ?? "1"} Cal",
                                                              style: AppTextStyles.ShadowFonts2,
                                                            ),
                                                            Icon(
                                                              Icons.add,
                                                              color: HexColor('#6F72CA'),
                                                            )
                                                            // Obx(() => Icon(
                                                            //   Icons.add,
                                                            //   color: _navigate.value
                                                            //       ? widget.bgColor
                                                            //       : Colors.grey,
                                                            //   size: 21.sp,
                                                            // ))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }))
                                    : Shimmer.fromColors(
                                        direction: ShimmerDirection.ltr,
                                        enabled: true,
                                        baseColor: Colors.white,
                                        highlightColor: Colors.grey.shade300,
                                        child: Container(
                                          height: 5.h,
                                          width: 30.w,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                          ],
                        ),
                      ),
                    );
                  }),
              SizedBox(
                height: 2.h,
              ),
              GetBuilder<ClendarController>(
                  id: "Recent Activity Data",
                  builder: (ClendarController recentActivity) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0, top: 5.0),
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 13.0, top: 12, bottom: 12, right: 18),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Recent Activity",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: HexColor('#6F72CA'),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Visibility(
                                    visible: _calController.recentList.isNotEmpty,
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(ViewAllActivity(
                                          viewAllData: _calController.recentList,
                                          selctedDate: _selectedDay,
                                          screenType: 'Recent Activity',
                                        ));
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            "View All ",
                                            style: TextStyle(
                                              color: HexColor('#6F72CA'),
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios_outlined,
                                              size: 15.sp, color: HexColor('#6F72CA')),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            _calController.recentLoading
                                ? Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    enabled: true,
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey.shade300,
                                    child: Container(
                                      height: 5.h,
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  )
                                : _calController.recentList != null
                                    ? _calController.recentList.isEmpty
                                        ? SizedBox(
                                            height: 12.h,
                                            child: Center(
                                                child: _calController.selectedDate.value == "Today"
                                                    ? Text(
                                                        "No Recent Activity",
                                                        style: AppTextStyles.ShadowFonts,
                                                      )
                                                    : Text(
                                                        "No Recent Activity",
                                                        style: AppTextStyles.ShadowFonts,
                                                      )),
                                          )
                                        : SizedBox(
                                            height: _calController.recentList.length > 4
                                                ? 4 * 7.8.h
                                                : _calController.recentList.length * 8.h,
                                            child: ListView.builder(
                                                itemCount: _calController.recentList.length,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (BuildContext cntx, int index) {
                                                  return SizedBox(
                                                    height: 7.8.h,
                                                    child: ListTile(
                                                      onTap: () {
                                                        Get.to(ActivityDetailScreen(
                                                          // allList: index
                                                          //     .toString(),
                                                          activityObj:
                                                              _calController.recentList[index],
                                                          todayLogList: widget.todayLogList,
                                                          selectedDate: _selectedDay,
                                                        ));
                                                      },
                                                      leading: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            width: 60.w,
                                                            child: Text(
                                                              _calController.recentList[index]
                                                                      .activityName ??
                                                                  " ",
                                                              style: AppTextStyles.blackText1,
                                                            ),
                                                          ),
                                                          Text(
                                                            _calController.recentList[index]
                                                                        .activityType ==
                                                                    "L"
                                                                ? "Light Impact"
                                                                : _calController.recentList[index]
                                                                            .activityType ==
                                                                        "M"
                                                                    ? "Medium Impact"
                                                                    : "High Impact",
                                                            style: AppTextStyles.ShadowFonts1,
                                                          )
                                                        ],
                                                      ),
                                                      // subtitle: Text(splitedTxt[0]),
                                                      trailing: SizedBox(
                                                        width: 25.w,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              "${_calController.recentList[index].activityMetValue ?? "1"} Cal",
                                                              style: AppTextStyles.ShadowFonts2,
                                                            ),
                                                            Icon(
                                                              Icons.add,
                                                              color: HexColor('#6F72CA'),
                                                            )
                                                            // Obx(() => Icon(
                                                            //   Icons.add,
                                                            //   color: _navigate.value
                                                            //       ? widget.bgColor
                                                            //       : Colors.grey,
                                                            //   size: 21.sp,
                                                            // ))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }))
                                    : Shimmer.fromColors(
                                        direction: ShimmerDirection.ltr,
                                        enabled: true,
                                        baseColor: Colors.white,
                                        highlightColor: Colors.grey.shade300,
                                        child: Container(
                                          height: 5.h,
                                          width: 30.w,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                          ],
                        ),
                      ),
                    );
                  }),
              SizedBox(
                height: 10.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShowIcon {
  static ValueNotifier<bool> icon = ValueNotifier<bool>(false);
}
