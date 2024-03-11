import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';
import '../../../../../views/dietJournal/apis/log_apis.dart';
import '../../../../../views/dietJournal/models/food_list_tab_model.dart';
import '../../../../../views/dietJournal/models/get_frequent_food_consumed.dart';
import '../../../../../views/dietJournal/models/log_user_food_intake_model.dart';
import '../../../../app/utils/appColors.dart';
import '../../../../app/utils/textStyle.dart';
import '../../../controllers/healthJournalControllers/calendarController.dart';
import '../../../controllers/healthJournalControllers/getTodayLogController.dart';
import '../../../controllers/healthJournalControllers/loadFoodList.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import 'customeFoodDetailScreen.dart';
import 'dataFormats.dart';
import 'editfoodlog.dart';
import 'foodDetailScreen.dart';
import 'logHistoryScreen.dart';
import 'myFavouriteScreen.dart';
import 'myMealsScreen.dart';
import 'searchScreen.dart';
import '../../../../../utils/SpUtil.dart';
import '../../../../../views/dietJournal/MealTypeScreen.dart';
import '../../../../../views/dietJournal/activity/activity_detail.dart';
import '../../../../../views/dietJournal/apis/list_apis.dart';
import '../../../../../views/gamification/dateutils.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../widgets/searchFields.dart';
import '../../../controllers/healthJournalControllers/foodDetailController.dart';
import 'editCusFoodLog.dart';
import 'frequentlyConsumedScreen.dart';

RxBool gNavigate = true.obs;

class LogFoodLanding extends StatefulWidget {
  LogFoodLanding(
      {Key key,
      @required this.mealType,
      @required this.bgColor,
      @required this.mealData,
      @required this.Screen,
      @required this.frequentFood,
      // @required this.fromListOfFoodLogs,
      this.date,
      this.mealListDataKcal});

  final String mealType;
  final bgColor;
  String Screen;
  final mealData;
  List<FreqStatus> frequentFood = [];
  // List<dynamic> fromListOfFoodLogs;
  final DateTime date;
  int mealListDataKcal;

  @override
  State<LogFoodLanding> createState() => _LogFoodLandingState();
}

class _LogFoodLandingState extends State<LogFoodLanding> {
  RxBool _navigate = true.obs;
  List<String> bookmarks = [];
  List foodLogHistory = [];
  var details;
  final ClendarController _calController = Get.put(ClendarController());
  List listUserFood;
  DateTime _selectedDay;
  bool httpres = false;
  ListApis listApis = ListApis();
  List favList = [];
  DateTime dt = DateTime.now();
  String todayDate = DateFormat("yyyy-MM-dd")
      .format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
  TextEditingController _searchController = TextEditingController();
  List<MealsListData> mealsListData = [];
  var groupMealListData;
  TimeOfDay selectedTime = TimeOfDay.now();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FoodDetailController _foodDetailController = Get.put(FoodDetailController());

  @override
  void initState() {
    dataRetive();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initDateSync();
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _calController.foodLogHistory.clear();
    // TODO: implement dispose
    super.dispose();
  }

  initDateSync() async {
    await ListApis.list_user_frequent_food_log().then((GetFrequentFoodConsumed value) {
      widget.frequentFood = value.status;
      setState(() {});
      print('=========${widget.frequentFood}');
    });
    DateTime now;
    String startTimeString;
    if (widget.date == null) {
      now = DateTime.now();
    } else {
      DateTime startTime = DateTime(widget.date.year, widget.date.month, widget.date.day);
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      startTimeString = formatter.format(startTime);
    }
    _selectedDay = _calController.focusedDay.value = widget.date ?? now;
    _calController.selectedDate.value =
        widget.date == null ? "Today" : DateFormat("dd MMM").format(widget.date);
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
    widget.date == null
        ? _calController.updateFoodDetail(formattedDate, "$formattedDate 23:59:00", widget.mealType)
        : _calController.updateFoodDetail(
            startTimeString, "$startTimeString 23:59:00", widget.mealType);

    _calController.updateMealType(widget.mealType);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    _calController.dataGroupedMeal(iHLUserId);
  }

  dataRetive() async {
    await listApis.getUserTodaysFoodLogHistoryApi().then((value) {
      if (mounted) {
        mealsListData = value['food'];
      }
    });
  }

  bool isDateNotInLastWeek(DateTime selectedDate) {
    DateTime currentDate = DateTime.now();
    DateTime lastWeek = currentDate.subtract(const Duration(days: 7));
    return !selectedDate.isBefore(lastWeek);
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> setofMealValuesList = [];
    // List<FoodListTileModel> recentList = SpUtil.getRecentObjectList('recent_food') ?? [];
    var favFoodList = _foodDetailController.favFoods;
    int mealTypeId = widget.mealType == "Breakfast"
        ? 0
        : widget.mealType == "Lunch"
            ? 1
            : widget.mealType == "Snacks"
                ? 2
                : 3;

    return WillPopScope(
      onWillPop: () async {
        return Get.off(MealTypeScreen(
          mealsListData: mealsListData[mealTypeId],
          mealData: widget.mealData,
          Screen: widget.Screen,
        ));
      },
      child: CommonScreenForNavigation(
        contentColor: "True",
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              // await listApis.getUserTodaysFoodLogHistoryApi().then((value) {
              //   if (mounted) {
              //     mealsListData = value['food'];
              //
              //     //loaded = true;
              //   }
              // });

              Get.off(MealTypeScreen(
                mealsListData: mealsListData[mealTypeId],
                mealData: widget.mealData,
                Screen: widget.Screen,
              ));
            }, //replaces the screen to Main dashboard
            color: Colors.white,
          ),
          centerTitle: true,
          title: Text("Log ${widget.mealType}"),
          backgroundColor: widget.bgColor,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1.h),
              Row(
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
                            color: widget.bgColor,
                          ))
                      : IconButton(
                          onPressed: () {
                            _calController.updateTab(value: 0);
                          },
                          icon: Icon(
                            Icons.arrow_drop_up_sharp,
                            color: widget.bgColor,
                          )))
                ],
              ),
              Obx(() {
                return Visibility(
                  visible: _calController.calendarSelected.value == 0,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () async {
                            // _calController.focusedDay.value =
                            //     _calController.focusedDay.value.subtract(const Duration(days: 7));
                            DateTime weekDate = DateFormat("yyyy-MM-dd").parse(_calController
                                .focusedDay.value
                                .subtract(const Duration(days: 7))
                                .toString());
                            // String startDate = DateFormat("yyyy-MM-dd")
                            //     .format(DateTime(weekDate.year, weekDate.month, weekDate.day));

                            _calController.selectedDate.value =
                                DateFormat("dd MMM").format(weekDate);
                            _calController.focusedDay.value = weekDate;

                            _calController.currentWeek = false;
                            if (mounted) setState(() {});
                            _navigate.value = isDateNotInLastWeek(_calController.focusedDay.value);
                            gNavigate = _navigate;

                            // if (!isSameDay(_selectedDay, selectedDay)) {
                            // Call `setState()` when updating the selected day
                            final String yesterday = DateFormat("dd-MM-yyyy").format(DateTime(
                                DateTime.now().year, DateTime.now().month, DateTime.now().day - 1));
                            _selectedDay = _calController.focusedDay.value;
                            _calController.updateDate(
                                Date: DateFormat("dd MMM").format(_calController.focusedDay.value),
                                focusedDate: _calController.focusedDay.value);
                            String endDate =
                                "${DateFormat("yyyy-MM-dd").format(DateTime(_calController.focusedDay.value.year, _calController.focusedDay.value.month, _calController.focusedDay.value.day))} 23:59:00";
                            String startDate = DateFormat("yyyy-MM-dd").format(DateTime(
                                _calController.focusedDay.value.year,
                                _calController.focusedDay.value.month,
                                _calController.focusedDay.value.day));
                            _calController.updateFoodDetail(
                                startDate, "$startDate 23:59:00", widget.mealType);
                            _calController.updateFoodDetail(startDate, endDate, widget.mealType);

                            if (_calController.selectedDate.value ==
                                DateFormat("dd MMM").format(DateTime.now())) {
                              _calController.updateDate(
                                  Date: "Today", focusedDate: _calController.focusedDay.value);
                            } else if (yesterday ==
                                DateFormat("dd-MM-YYYY").format(_calController.focusedDay.value)) {
                              _calController.updateDate(
                                  Date: "Yesterday", focusedDate: _calController.focusedDay.value);
                            } else {
                              _calController.updateDate(
                                  Date:
                                      DateFormat("dd MMM").format(_calController.focusedDay.value),
                                  focusedDate: _calController.focusedDay.value);
                            }
                            dt = _calController.focusedDay.value;
                            // _calController.focusedDay.value = focusedDay;
                            final DateTime _now = DateTime.now();
                            DateTime startOfWeek = _now.subtract(Duration(days: _now.weekday - 1));

                            // Get the end of the current week (Sunday)
                            DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

                            // Replace this with your selected date
                            DateTime selectedDate =
                                _calController.focusedDay.value; // Replace with your actual date

                            // Check if the selected date is within the current week
                            _calController.currentWeek = selectedDate
                                    .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                                selectedDate.isBefore(endOfWeek.add(const Duration(days: 1)));

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
                                color: widget.bgColor.withOpacity(0.4), shape: BoxShape.rectangle),
                            withinRangeTextStyle: TextStyle(
                                fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.bold),
                            rangeStartTextStyle: TextStyle(
                                fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                  fontSize: 15.sp,
                                  color: widget.bgColor,
                                  fontWeight: FontWeight.bold),
                              weekendStyle: TextStyle(
                                  fontSize: 15.sp,
                                  color: widget.bgColor,
                                  fontWeight: FontWeight.bold)),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(fontSize: 14.sp, color: widget.bgColor),
                          ),
                          selectedDayPredicate: (DateTime day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (DateTime selectedDay, DateTime focusedDay) async {
                            _navigate.value = isDateNotInLastWeek(focusedDay);
                            gNavigate = _navigate;

                            // if (!isSameDay(_selectedDay, selectedDay)) {
                            // Call `setState()` when updating the selected day
                            final String yesterday = DateFormat("dd-MM-yyyy").format(DateTime(
                                DateTime.now().year, DateTime.now().month, DateTime.now().day - 1));
                            _selectedDay = selectedDay;
                            _calController.updateDate(
                                Date: DateFormat("dd MMM").format(selectedDay),
                                focusedDate: selectedDay);
                            String endDate =
                                "${DateFormat("yyyy-MM-dd").format(DateTime(selectedDay.year, selectedDay.month, selectedDay.day))} 23:59:00";
                            String startDate = DateFormat("yyyy-MM-dd").format(
                                DateTime(selectedDay.year, selectedDay.month, selectedDay.day));

                            _calController.updateFoodDetail(startDate, endDate, widget.mealType);

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
                            final DateTime _now = DateTime.now();
                            DateTime startOfWeek = _now.subtract(Duration(days: _now.weekday - 1));

                            // Get the end of the current week (Sunday)
                            DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

                            // Replace this with your selected date
                            DateTime selectedDate = focusedDay; // Replace with your actual date

                            // Check if the selected date is within the current week
                            _calController.currentWeek = selectedDate
                                    .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                                selectedDate.isBefore(endOfWeek.add(const Duration(days: 1)));

                            if (mounted) setState(() {});
                          },
                        ),
                      ),
                      IconButton(
                          onPressed: _calController.currentWeek
                              ? null
                              : () async {
                                  final DateTime _now = DateTime.now();
                                  DateTime _currentWeekMonday = _now;
                                  while (_currentWeekMonday.weekday != DateTime.monday) {
                                    _currentWeekMonday =
                                        _currentWeekMonday.subtract(const Duration(days: 1));
                                  }
                                  DateTime previousMonday = _calController.focusedDay.value;
                                  while (previousMonday.weekday != DateTime.monday) {
                                    previousMonday =
                                        previousMonday.subtract(const Duration(days: 1));
                                  }

                                  if (!_calController.focusedDay.value.isSameDate(DateTime.now()) &&
                                      !_currentWeekMonday.isSameDate(previousMonday)) {
                                    _calController.focusedDay.value = _calController
                                        .focusedDay.value
                                        .add(const Duration(days: 7));
                                    if (_calController.focusedDay.value
                                        .isAfterOrEqualTo(_currentWeekMonday)) {
                                      _calController.focusedDay.value = _now;
                                    }
                                  }
                                  // Get the start of the current week (Monday)
                                  DateTime startOfWeek =
                                      _now.subtract(Duration(days: _now.weekday - 1));

                                  // Get the end of the current week (Sunday)
                                  DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

                                  // Replace this with your selected date
                                  DateTime selectedDate = _calController
                                      .focusedDay.value; // Replace with your actual date
                                  DateTime weekDate =
                                      DateFormat("yyyy-MM-dd").parse(selectedDate.toString());
                                  String startDate = DateFormat("yyyy-MM-dd").format(
                                      DateTime(weekDate.year, weekDate.month, weekDate.day));

                                  // Check if the selected date is within the current week
                                  _calController.currentWeek = selectedDate
                                          .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                                      selectedDate.isBefore(endOfWeek.add(const Duration(days: 1)));
                                  _calController.updateDate(
                                      Date: DateFormat("dd MMM").format(weekDate),
                                      focusedDate: weekDate);
                                  _calController.updateFoodDetail(
                                      startDate, "$startDate 23:59:00", widget.mealType);
                                  if (mounted) setState(() {});
                                },
                          // onPressed: null,
                          icon: const Icon(Icons.arrow_forward_ios_rounded)),
                    ],
                  ),
                );
              }),
              Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SearchFieldWidget.searchWidget(
                    searchController: _searchController,
                    lable: 'Search Food or Meal',
                    baseColor: widget.bgColor,
                    onTap: () {
                      if (_navigate.value) {
                        Get.to(SearchScreen(
                          baseColor: widget.bgColor,
                          mealType: widget.mealType,
                          selectedDate: _selectedDay ?? todayDate,
                          mealData: widget.mealData,
                        ));
                      } else {
                        Get.snackbar('Food logging is not allowed for past date', 'Past date alert',
                            icon: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.check_circle, color: Colors.white)),
                            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                            backgroundColor: widget.bgColor,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 5),
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    autoFocus: false,
                    keyBoardDisable: true,
                    onChanged: null,
                  )),
              GetBuilder<ClendarController>(
                  init: ClendarController(),
                  id: "fetchFoodList",
                  builder: (ClendarController logedFood) {
                    ClendarController deleteController = Get.find();
                    return logedFood.status.isEmpty
                        ? const SizedBox()
                        : Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0, top: 5.0),
                            child: Card(
                                elevation: 2,
                                child:
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 13.0, top: 12, bottom: 12, right: 18),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Grouped Meal",
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: widget.bgColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        GetBuilder<ClendarController>(
                                            id: "deleteFoodList",
                                            builder: (ClendarController deleteLogAll) {
                                              return InkWell(
                                                onTap: () {
                                                  logedFood.updatedeleteLog();

                                                  // Get.to(LogHistoryScreen(
                                                  //   baseColor: widget.bgColor,
                                                  //   viewHistory: logedFood.foodLogHistory,
                                                  //   mealData: widget.mealData,
                                                  // ));
                                                },
                                                child: deleteLogAll.deletelog.value
                                                    ? Icon(Icons.close_rounded,
                                                        size: 20.sp, color: widget.bgColor)
                                                    : Icon(Icons.delete,
                                                        size: 20.sp, color: widget.bgColor),
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height: logedFood.deletelog.value
                                          ? ((7.h * logedFood.status.length) -
                                                  0.3.h * logedFood.status.length) +
                                              12.h
                                          : (7.h * logedFood.status.length) -
                                              0.3.h * logedFood.status.length,
                                      child: ListView.builder(
                                          // itemCount: logedFood.status.length > 3
                                          //     ? 4
                                          //     : logedFood.status.length,
                                          itemCount: logedFood.status.length,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext cntx, int index) {
                                            setofMealValuesList.clear();
                                            for (int index = 0;
                                                index < logedFood.status.length;
                                                index++) {
                                              // var parsedString = logedFood
                                              //     .status[index].listOfFoodLogs
                                              //     .replaceAll("&#39;", "\"")
                                              //     .toString();
                                              Map<String, dynamic> setofMeal;
                                              try {
                                                setofMeal = logedFood.status[index].listOfFoodLogs;
                                              } catch (e) {
                                                print("defective food Group");
                                              }
                                              print(setofMeal["mealCategory"]);
                                              // Assuming you want to add the first value from each 'setofMeal' into the list
                                              setofMeal != null
                                                  ? setofMeal["mealCategory"] == widget.mealType
                                                      ? setofMealValuesList
                                                          .add(setofMeal.values.toList().first)
                                                      : null
                                                  : null;
                                            }

                                            // Now 'setofMealValuesList' contains all the values from the 'setofMeal' maps
                                            print('Decoded Values List: $setofMealValuesList');

                                            return logedFood.status.isEmpty
                                                ? Shimmer.fromColors(
                                                    direction: ShimmerDirection.ltr,
                                                    period: const Duration(seconds: 2),
                                                    baseColor:
                                                        const Color.fromARGB(255, 240, 240, 240),
                                                    highlightColor: Colors.grey.withOpacity(0.2),
                                                    child: Container(
                                                        height: 18.h,
                                                        width: 97.w,
                                                        padding: const EdgeInsets.only(
                                                            left: 8, right: 8, top: 8),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(8)),
                                                        child: const Text('Data Loading')))
                                                : GetBuilder<ClendarController>(
                                                    init: ClendarController(),
                                                    id: "deleteFoodList",
                                                    builder: (ClendarController deleteLogAll) {
                                                      // String json = logedFood
                                                      //     .status[index].listOfFoodLogs
                                                      //     .replaceAll("&#39;", "\"");

                                                      // Parse the JSON string into a map
                                                      logedFood.resultMap =
                                                          logedFood.status[index].listOfFoodLogs;
                                                      // Display the map
                                                      // logedFood.resultMap.forEach((key, value) {
                                                      //   print('$key: $value');
                                                      // });
                                                      return Visibility(
                                                        visible:
                                                            logedFood.resultMap['mealCategory'] ==
                                                                widget.mealType,
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              // height: 7.8.h,
                                                              child: ListTile(
                                                                onTap: () {},
                                                                leading: SizedBox(
                                                                  width: 60.w,
                                                                  child: Row(
                                                                    children: [
                                                                      deleteLogAll.deletelog.value
                                                                          ? Obx(() {
                                                                              return Checkbox(
                                                                                value: deleteController
                                                                                    .isCheckedList[
                                                                                        index]
                                                                                    .value,
                                                                                onChanged:
                                                                                    (bool value) {
                                                                                  deleteController
                                                                                          .isCheckedList =
                                                                                      List.generate(
                                                                                          10,
                                                                                          (int index) =>
                                                                                              false
                                                                                                  .obs).obs;
                                                                                  deleteController
                                                                                      .isCheckedList[
                                                                                          index]
                                                                                      .value = value;

                                                                                  // isCheckedList[index] = value;
                                                                                  setState(() {});
                                                                                },
                                                                              );
                                                                            })
                                                                          : const SizedBox(),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .start,
                                                                        children: [
                                                                          Text(
                                                                            logedFood.status[index]
                                                                                    .groupName ??
                                                                                " ",
                                                                            style: AppTextStyles
                                                                                .blackText1,
                                                                          ),
                                                                          Text(
                                                                            logedFood.resultMap[
                                                                                            'foodName']
                                                                                        .toString()
                                                                                        .length >
                                                                                    25
                                                                                ? '${logedFood.resultMap['foodName'].toString().replaceAll('[', '').replaceAll(']', '').substring(0, 14)}...'
                                                                                : logedFood
                                                                                    .resultMap[
                                                                                        'foodName']
                                                                                    .toString()
                                                                                    .replaceAll(
                                                                                        '[', '')
                                                                                    .replaceAll(
                                                                                        ']', ''),
                                                                            style: AppTextStyles
                                                                                .ShadowFonts1,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                // subtitle: Text(splitedTxt[0]),
                                                                trailing: SizedBox(
                                                                  width: 25.w,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        "${logedFood.status[index].totalCalorieCount} Cal",
                                                                        style: AppTextStyles
                                                                            .ShadowFonts2,
                                                                      ),
                                                                      InkWell(
                                                                          onTap: () async {
                                                                            // String json = logedFood
                                                                            //     .status[index]
                                                                            //     .listOfFoodLogs
                                                                            //     .replaceAll(
                                                                            //         "&#39;", "\"");

                                                                            // Parse the JSON string into a map
                                                                            logedFood.resultMap =
                                                                                logedFood
                                                                                    .status[index]
                                                                                    .listOfFoodLogs;
                                                                            print(logedFood
                                                                                .resultMap);
                                                                            String _chosenType;
                                                                            LogUserFood logFood;
                                                                            final SharedPreferences
                                                                                prefs =
                                                                                await SharedPreferences
                                                                                    .getInstance();
                                                                            String iHLUserId =
                                                                                prefs.getString(
                                                                                    'ihlUserId');
                                                                            String selectedDateTemp;
                                                                            // logedFood.resultMap.clear();
                                                                            if (_selectedDay
                                                                                    .runtimeType ==
                                                                                DateTime) {
                                                                              selectedDateTemp =
                                                                                  DateFormat(
                                                                                          'yyyy-MM-dd')
                                                                                      .format(
                                                                                          _selectedDay);
                                                                            }
                                                                            bool checkPastWeek = DateFmt()
                                                                                .isWithinPastWeek(
                                                                                    selectedDateTemp);
                                                                            if (checkPastWeek) {
                                                                              String foodLogTime =
                                                                                  "${_selectedDay.runtimeType == DateTime ? selectedDateTemp : _selectedDay == null ? todayDate : _selectedDay.toString()} ${selectedTime.hour}:${selectedTime.minute}:00";
                                                                              String logEndTime =
                                                                                  "${_selectedDay.runtimeType == DateTime ? selectedDateTemp : _selectedDay == null ? todayDate : _selectedDay.toString()} 23:59:00";
                                                                              DateTime tempDate =
                                                                                  DateFormat(
                                                                                          "yyyy-MM-dd HH:mm:ss")
                                                                                      .parse(
                                                                                          foodLogTime);

                                                                              int epochTime = tempDate
                                                                                  .millisecondsSinceEpoch;
                                                                              for (int i = 0;
                                                                                  i <
                                                                                      logedFood
                                                                                          .resultMap[
                                                                                              'foodName']
                                                                                          .length;
                                                                                  i++) {
                                                                                FoodDetail fooddetail = FoodDetail(
                                                                                    foodId: logedFood
                                                                                        .resultMap['foodId']
                                                                                            [i]
                                                                                        .toString(),
                                                                                    foodName: logedFood
                                                                                        .resultMap['foodName']
                                                                                            [i]
                                                                                        .toString(),
                                                                                    foodQuantity: logedFood
                                                                                        .resultMap['foodQuantity']
                                                                                            [i]
                                                                                        .toString(),
                                                                                    quantityUnit: logedFood
                                                                                        .resultMap[
                                                                                            'quantityUnit'][i]
                                                                                        .toString());
                                                                                _chosenType =
                                                                                    _calController
                                                                                        .maelType
                                                                                        .value;

                                                                                logFood = LogUserFood(
                                                                                    userIhlId:
                                                                                        iHLUserId,
                                                                                    foodLogTime:
                                                                                        tempDate,
                                                                                    epochLogTime:
                                                                                        epochTime,
                                                                                    foodTimeCategory:
                                                                                        _chosenType,
                                                                                    caloriesGained: logedFood
                                                                                        .resultMap[
                                                                                            'Calories']
                                                                                            [i]
                                                                                        .toString(),
                                                                                    food: [
                                                                                      Food(
                                                                                          foodDetails: [
                                                                                            fooddetail
                                                                                          ])
                                                                                    ]);
                                                                                LogApis.logUserFoodIntakeApi(
                                                                                        data:
                                                                                            logFood)
                                                                                    .then(
                                                                                        (LogUserFoodIntakeResponse
                                                                                            value) {
                                                                                  if (value !=
                                                                                      null) {
                                                                                    ListApis.getUserTodaysFoodLogApi(
                                                                                            _chosenType)
                                                                                        .then(
                                                                                            (value) {
                                                                                      DateTime
                                                                                          startDate =
                                                                                          DateFormat(
                                                                                                  "yyyy-MM-dd")
                                                                                              .parse(
                                                                                                  foodLogTime);

                                                                                      Get.delete<
                                                                                          FoodDataLoaderController>();
                                                                                      Get.delete<
                                                                                          TodayLogController>();
                                                                                      listApis
                                                                                          .getUserTodaysFoodLogHistoryApi()
                                                                                          .then(
                                                                                              (value) {
                                                                                        if (mounted) {
                                                                                          mealsListData =
                                                                                              value[
                                                                                                  'food'];
                                                                                        }
                                                                                      });
                                                                                      DateTime now;
                                                                                      String
                                                                                          startTimeString;
                                                                                      if (widget
                                                                                              .date ==
                                                                                          null) {
                                                                                        now = DateTime
                                                                                            .now();
                                                                                      } else {
                                                                                        DateTime startTime = DateTime(
                                                                                            widget
                                                                                                .date
                                                                                                .year,
                                                                                            widget
                                                                                                .date
                                                                                                .month,
                                                                                            widget
                                                                                                .date
                                                                                                .day);
                                                                                        DateFormat
                                                                                            formatter =
                                                                                            DateFormat(
                                                                                                'yyyy-MM-dd');
                                                                                        startTimeString =
                                                                                            formatter
                                                                                                .format(startTime);
                                                                                      }
                                                                                      // _selectedDay =
                                                                                      //     _calController
                                                                                      //         .focusedDay
                                                                                      //         .value = widget
                                                                                      //             .date ??
                                                                                      //         now;
                                                                                      _calController
                                                                                          .selectedDate
                                                                                          .value = widget
                                                                                                  .date ==
                                                                                              null
                                                                                          ? "Today"
                                                                                          : DateFormat(
                                                                                                  "dd MMM")
                                                                                              .format(
                                                                                                  widget.date);
                                                                                      String
                                                                                          formattedDate =
                                                                                          DateFormat(
                                                                                                  'yyyy-MM-dd')
                                                                                              .format(
                                                                                                  _selectedDay);
                                                                                      widget.date ==
                                                                                              null
                                                                                          ? _calController.updateFoodDetail(
                                                                                              formattedDate,
                                                                                              "$formattedDate 23:59:00",
                                                                                              widget
                                                                                                  .mealType)
                                                                                          : _calController.updateFoodDetail(
                                                                                              startTimeString,
                                                                                              "$startTimeString 23:59:00",
                                                                                              widget
                                                                                                  .mealType);

                                                                                      _calController
                                                                                          .updateMealType(
                                                                                              widget
                                                                                                  .mealType);
                                                                                      Get.to(
                                                                                          LogFoodLanding(
                                                                                        mealType: _calController
                                                                                            .maelType
                                                                                            .value,
                                                                                        bgColor: _calController
                                                                                            .bgColor
                                                                                            .value,
                                                                                        mealData: widget
                                                                                            .mealData,
                                                                                        date:
                                                                                            startDate,
                                                                                      ));
                                                                                    });
                                                                                  }
                                                                                });

                                                                                if (logedFood
                                                                                            .resultMap[
                                                                                                'foodName']
                                                                                            .length -
                                                                                        1 ==
                                                                                    i) {
                                                                                  Get.snackbar(
                                                                                      'Logged!',
                                                                                      '${camelize(logedFood.resultMap['foodName'].toString().replaceAll('[', '').replaceAll(']', ''))} logged successfully.',
                                                                                      icon: const Padding(
                                                                                          padding:
                                                                                              EdgeInsets.all(
                                                                                                  8.0),
                                                                                          child: Icon(Icons.check_circle,
                                                                                              color: Colors
                                                                                                  .white)),
                                                                                      margin: const EdgeInsets.all(20)
                                                                                          .copyWith(
                                                                                              bottom:
                                                                                                  40),
                                                                                      backgroundColor:
                                                                                          _calController
                                                                                              .bgColor
                                                                                              .value,
                                                                                      colorText:
                                                                                          Colors.white,
                                                                                      duration: const Duration(seconds: 5),
                                                                                      snackPosition: SnackPosition.BOTTOM);
                                                                                }
                                                                              }
                                                                            } else {
                                                                              Get.snackbar(
                                                                                  'You can only log food for the past week',
                                                                                  'logging for periods longer than a week is not permitted.',
                                                                                  icon: const Padding(
                                                                                      padding:
                                                                                          EdgeInsets.all(
                                                                                              8.0),
                                                                                      child: Icon(Icons.cancel_sharp,
                                                                                          color: Colors
                                                                                              .white)),
                                                                                  margin: const EdgeInsets.all(20)
                                                                                      .copyWith(
                                                                                          bottom:
                                                                                              40),
                                                                                  backgroundColor:
                                                                                      _calController
                                                                                          .bgColor
                                                                                          .value,
                                                                                  colorText:
                                                                                      Colors.white,
                                                                                  duration: const Duration(seconds: 5),
                                                                                  snackPosition: SnackPosition.BOTTOM);
                                                                            }
                                                                          },
                                                                          child: Icon(
                                                                            Icons.add,
                                                                            color: _navigate.value
                                                                                ? widget.bgColor
                                                                                : Colors.grey,
                                                                            size: 21.sp,
                                                                          ))
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            deleteLogAll.deletelog.value &&
                                                                    logedFood.status.length - 1 ==
                                                                        index
                                                                ? Container(
                                                                    height: 9.h,
                                                                    width: 100.w,
                                                                    margin: EdgeInsets.only(
                                                                        left: 15.sp,
                                                                        right: 15.sp,
                                                                        bottom: 14.sp),
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color: Colors.grey)),
                                                                    child: Center(
                                                                      child: ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius
                                                                                    .circular(4.0),
                                                                          ),
                                                                          backgroundColor:
                                                                              widget.bgColor,
                                                                          textStyle:
                                                                              const TextStyle(
                                                                                  color:
                                                                                      Colors.white),
                                                                        ),
                                                                        onPressed: () {
                                                                          // Handle button press
                                                                          deleteLogAll.deletelog
                                                                              .value = false;
                                                                          int idex =
                                                                              deleteController
                                                                                  .isCheckedList
                                                                                  .indexOf(true);

                                                                          logedFood
                                                                              .updateDeleteFoodGroupMeal(
                                                                                  group_id: logedFood
                                                                                      .status[idex]
                                                                                      .foodLogGroupId);
                                                                          deleteController
                                                                                  .isCheckedList =
                                                                              List.generate(
                                                                                      10,
                                                                                      (int index) =>
                                                                                          false.obs)
                                                                                  .obs;
                                                                        },
                                                                        child: Padding(
                                                                          padding:
                                                                              EdgeInsets.all(14.sp),
                                                                          child: Text(
                                                                              'Delete Group',
                                                                              style: TextStyle(
                                                                                  fontSize: 16.sp,
                                                                                  color:
                                                                                      Colors.white,
                                                                                  fontWeight:
                                                                                      FontWeight
                                                                                          .w600)),
                                                                        ),
                                                                      ),
                                                                    ),

                                                                    // SizedBox(
                                                                    //   width: 20.w,
                                                                    // ),
                                                                    // Icon(
                                                                    //   Icons.info,
                                                                    //   color: widget.bgColor,
                                                                    // )
                                                                  )
                                                                : const SizedBox()
                                                          ],
                                                        ),
                                                      );
                                                    });
                                          })),
                                  // logedFood.status.isNotEmpty
                                  //     ?
                                  //     : SizedBox(),
                                ])));
                  }),
              GetBuilder<ClendarController>(
                init: ClendarController(),
                id: "DayFoodDetails",
                builder: (ClendarController logedFood) {
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
                                  "${widget.mealType} Consumed",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: widget.bgColor,
                                      fontWeight: FontWeight.w600),
                                ),
                                logedFood.foodLogHistory != null
                                    ? Visibility(
                                        visible: logedFood.foodLogHistory.isNotEmpty,
                                        child: InkWell(
                                          onTap: () {
                                            Get.to(LogHistoryScreen(
                                              baseColor: widget.bgColor,
                                              viewHistory: logedFood.foodLogHistory,
                                              mealData: widget.mealData,
                                            ));
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                "View All ",
                                                style: TextStyle(
                                                  color: logedFood.foodLogHistory.isEmpty
                                                      ? Colors.grey
                                                      : widget.bgColor,
                                                  fontSize: 15.sp,
                                                ),
                                              ),
                                              Icon(Icons.arrow_forward_ios_outlined,
                                                  size: 15.sp,
                                                  color: logedFood.foodLogHistory.isEmpty
                                                      ? Colors.grey
                                                      : widget.bgColor),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Shimmer.fromColors(
                                        direction: ShimmerDirection.ltr,
                                        enabled: true,
                                        baseColor: Colors.white,
                                        highlightColor: Colors.grey.shade300,
                                        child: Container(
                                          height: 3.h,
                                          width: 5.w,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          // _calController.selectedDate.value != "Today"
                          //     ?
                          if (logedFood.foodLogHistory == null)
                            Shimmer.fromColors(
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
                          if (logedFood.foodLogHistory.isEmpty)
                            SizedBox(
                              height: 12.h,
                              child: Center(
                                  child: _calController.selectedDate.value == "Today"
                                      ? Text(
                                          "No Foods have been logged ",
                                          style: AppTextStyles.ShadowFonts,
                                        )
                                      : Text(
                                          "No Food Logged on the day",
                                          style: AppTextStyles.ShadowFonts,
                                        )),
                            )
                          else
                            SizedBox(
                                height: logedFood.foodLogHistory.length > 4
                                    ? 32.h
                                    : 7.2.h * logedFood.foodLogHistory.length,
                                child: ListView.builder(
                                    itemCount: logedFood.foodLogHistory.length > 4
                                        ? 4
                                        : logedFood.foodLogHistory.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (BuildContext cntx, int index) {
                                      return Container(
                                        // color: Colors.green,
                                        height: 7.8.h,
                                        child: ListTile(
                                          onTap: () {
                                            if (_navigate.value) {
                                              if (logedFood.foodLogHistory[index].food[0]
                                                      .foodDetails[0].foodId.length <
                                                  20) {
                                                Get.to(EditFoodLog(
                                                  foodId: logedFood.foodLogHistory[index].food[0]
                                                      .foodDetails[0].foodId,
                                                  mealType: widget.mealType,
                                                  mealData: widget.mealData,
                                                  logedData: logedFood.foodLogHistory[index],
                                                  bgcolor: widget.bgColor,
                                                  foodLogId:
                                                      logedFood.foodLogHistory[index].foodLogId,
                                                ));
                                              } else {
                                                Get.to(CustomEditFoodLog(
                                                  foodId: logedFood.foodLogHistory[index].food[0]
                                                      .foodDetails[0].foodId,
                                                  mealType: widget.mealType,
                                                  mealData: widget.mealData,
                                                  logedData: logedFood.foodLogHistory[index],
                                                  bgcolor: widget.bgColor,
                                                  foodLogId:
                                                      logedFood.foodLogHistory[index].foodLogId,
                                                ));
                                              }
                                            }
                                          },
                                          leading: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 60.w,
                                                child: Text(
                                                  logedFood.foodLogHistory[index].food[0]
                                                          .foodDetails[0].foodName ??
                                                      " ",
                                                  style: AppTextStyles.blackText1,
                                                ),
                                              ),
                                              Text(
                                                '${logedFood.foodLogHistory[index].food[0].foodDetails[0].foodQuantity} ${logedFood.foodLogHistory[index].food[0].foodDetails[0].quantityUnit}',
                                                style: AppTextStyles.ShadowFonts1,
                                              )
                                            ],
                                          ),
                                          // subtitle: Text(splitedTxt[0]),
                                          trailing: SizedBox(
                                            width: 25.w,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "${logedFood.foodLogHistory[index].totalCaloriesGained} Cal",
                                                  style: AppTextStyles.ShadowFonts2,
                                                ),
                                                Obx(() => Icon(
                                                      Icons.add,
                                                      color: _navigate.value
                                                          ? widget.bgColor
                                                          : Colors.grey,
                                                      size: 21.sp,
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    })),

                          logedFood.foodLogHistory.length > 1
                              ? Container(
                                  height: 9.h,
                                  width: 100.w,
                                  margin: EdgeInsets.only(left: 15.sp, right: 15.sp, bottom: 14.sp),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      const Spacer(),
                                      const Spacer(),
                                      Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            backgroundColor: widget.bgColor,
                                            textStyle: const TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () {
                                            // Handle button press
                                            List<String> foodNamelistquotedWords = [];
                                            List<String> foodIdlistquotedWords = [];
                                            List<dynamic> foodIdListWords = [];
                                            List<String> foodQuantitylistquotedWords = [];
                                            List<String> foodTotalCaloriesquotedWords = [];
                                            List<String> foodServingTypelistquotedWords = [];
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                final TextEditingController _textEditingController =
                                                    TextEditingController();
                                                return AlertDialog(
                                                    title: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text(
                                                          'Group name',
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              height: 1.6,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        const Spacer(),
                                                        Align(
                                                          alignment: Alignment.topRight,
                                                          child: InkWell(
                                                            onTap: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Icon(
                                                              Icons.close,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    content: SizedBox(
                                                      width: 100.w,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(8.sp),
                                                        child: Form(
                                                          key: formKey,
                                                          child: TextFormField(
                                                            controller: _textEditingController,
                                                            decoration: const InputDecoration(
                                                              labelText: 'Enter group name',
                                                            ),
                                                            validator: (String v) {
                                                              if (v.isEmpty) {
                                                                return 'Field is empty!!!';
                                                              } else if (logedFood.status
                                                                  .contains(v)) {
                                                                return 'Not a valid fruit';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      Center(
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(4.0),
                                                            ),
                                                            backgroundColor: widget.bgColor,
                                                            textStyle: const TextStyle(
                                                                color: Colors.white),
                                                          ),
                                                          onPressed: () async {
                                                            if (formKey.currentState != null &&
                                                                formKey.currentState.validate()) {
                                                              logedFood.foodNamelist.clear();
                                                              logedFood.foodServingUnitList.clear();
                                                              logedFood.foodFoodIdList.clear();
                                                              logedFood.foodQuantityList.clear();
                                                              logedFood.textGrouping.clear();
                                                              listApis
                                                                  .getUserTodaysFoodLogHistoryApi()
                                                                  .then((value) {
                                                                if (mounted) {
                                                                  mealsListData = value['food'];
                                                                }
                                                              });
                                                              // Handle button press
                                                              logedFood.grpName =
                                                                  _textEditingController.text;

                                                              for (int i = 0;
                                                                  i <
                                                                      logedFood
                                                                          .foodLogHistory.length;
                                                                  i++) {
                                                                logedFood.foodNamelist.add(logedFood
                                                                    .foodLogHistory[i]
                                                                    .food[0]
                                                                    .foodDetails[0]
                                                                    .foodName);
                                                                foodNamelistquotedWords = logedFood
                                                                    .foodNamelist
                                                                    .map((String word) => "'$word'")
                                                                    .toList();
                                                                logedFood.foodFoodIdList.add(
                                                                    logedFood
                                                                        .foodLogHistory[i]
                                                                        .food[0]
                                                                        .foodDetails[0]
                                                                        .foodId);
                                                                foodIdListWords = logedFood
                                                                    .foodFoodIdList
                                                                    .map((e) => e)
                                                                    .toList();
                                                                foodIdlistquotedWords = logedFood
                                                                    .foodFoodIdList
                                                                    .map((word) => "'$word'")
                                                                    .toList();

                                                                logedFood.foodQuantityList.add(
                                                                    logedFood
                                                                        .foodLogHistory[i]
                                                                        .food[0]
                                                                        .foodDetails[0]
                                                                        .foodQuantity);
                                                                foodQuantitylistquotedWords =
                                                                    logedFood.foodQuantityList
                                                                        .map((word) => "'$word'")
                                                                        .toList();
                                                                logedFood.foodServingUnitList.add(
                                                                    logedFood
                                                                        .foodLogHistory[i]
                                                                        .food[0]
                                                                        .foodDetails[0]
                                                                        .quantityUnit);
                                                                logedFood.foodTotalCalorieList.add(
                                                                    logedFood.foodLogHistory[i]
                                                                        .totalCaloriesGained);
                                                                foodTotalCaloriesquotedWords =
                                                                    logedFood.foodTotalCalorieList
                                                                        .map((word) => "'$word'")
                                                                        .toList();
                                                                List<int> intList = logedFood
                                                                    .foodTotalCalorieList
                                                                    .map(
                                                                        (value) => int.parse(value))
                                                                    .toList();

                                                                // Adding values in the int list
                                                                logedFood.sum = intList.reduce(
                                                                    (int value, int element) =>
                                                                        value + element);

                                                                foodServingTypelistquotedWords =
                                                                    logedFood.foodServingUnitList
                                                                        .map((word) => "'$word'")
                                                                        .toList();
                                                              }
                                                              for (int i = 0;
                                                                  i < logedFood.status.length;
                                                                  i++) {
                                                                logedFood.textGrouping.add(
                                                                    logedFood.status[i].groupName);
                                                              }
                                                              print(logedFood.foodLogHistory);
                                                              if (!setofMealValuesList.any(
                                                                  (element) => const ListEquality()
                                                                      .equals(element,
                                                                          foodIdListWords))) {
                                                                if (!logedFood.textGrouping
                                                                    .contains(_textEditingController
                                                                        .text)) {
                                                                  logedFood.updateFoodGroupMeal(
                                                                      group_name:
                                                                          _textEditingController
                                                                              .text,
                                                                      foodFoodIdList:
                                                                          foodIdlistquotedWords,
                                                                      foodNamelist:
                                                                          foodNamelistquotedWords,
                                                                      foodQuantityList:
                                                                          foodQuantitylistquotedWords,
                                                                      foodServingUnitList:
                                                                          foodServingTypelistquotedWords,
                                                                      foodTotalCalories:
                                                                          foodTotalCaloriesquotedWords,
                                                                      meal_category:
                                                                          widget.mealType,
                                                                      total_calorie_count:
                                                                          logedFood.sum ?? 100);
                                                                  logedFood.foodNamelist = [];
                                                                  logedFood.foodFoodIdList = [];
                                                                  logedFood.textGrouping = [];
                                                                  logedFood.foodQuantityList = [];
                                                                  logedFood.foodServingUnitList =
                                                                      [];
                                                                  logedFood.foodTotalCalorieList =
                                                                      [];
                                                                  logedFood.totalKcal = 0;
                                                                  logedFood.sum = 0;
                                                                  logedFood.grpName = '';

                                                                  Get.back();
                                                                } else {
                                                                  ScaffoldMessenger.of(context)
                                                                      .hideCurrentSnackBar();
                                                                  SnackBar snackBar = SnackBar(
                                                                    backgroundColor: widget.bgColor,
                                                                    duration:
                                                                        const Duration(seconds: 2),
                                                                    content: const Center(
                                                                        child: Text(
                                                                            "Group Name Already Exists!!!")),
                                                                  );
                                                                  ScaffoldMessenger.of(context)
                                                                      .showSnackBar(snackBar);
                                                                  Get.back();
                                                                }
                                                              } else {
                                                                ScaffoldMessenger.of(context)
                                                                    .hideCurrentSnackBar();
                                                                SnackBar snackBar = SnackBar(
                                                                  backgroundColor: widget.bgColor,
                                                                  duration:
                                                                      const Duration(seconds: 2),
                                                                  content: const Center(
                                                                      child: Text(
                                                                          "Group Meal Set Already Exists!!!")),
                                                                );
                                                                ScaffoldMessenger.of(context)
                                                                    .showSnackBar(snackBar);
                                                                Get.back();
                                                              }
                                                            }
                                                          },
                                                          child: Padding(
                                                            padding: EdgeInsets.all(12.sp),
                                                            child: Text('OKAY',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    fontSize: 16.sp,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w600)),
                                                          ),
                                                        ),
                                                      )
                                                    ]);
                                              },
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(16.sp),
                                            child: Text('Group My Meal',
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Align(
                                                  alignment: Alignment.topRight,
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Icon(
                                                      Icons.close,
                                                    ),
                                                  ),
                                                ),
                                                content: Container(
                                                  padding:
                                                      const EdgeInsets.only(left: 12, right: 12),
                                                  child: const Text(
                                                      'The "Group my meals" option enables you to merge all the items you have consumed into a single group,allowing you to effortlessly log the entire group instead of individually logging each item again for future reference.',
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15,
                                                          letterSpacing: 0.1)),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Icon(
                                          Icons.info,
                                          color: widget.bgColor,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  // SizedBox(
                                  //   width: 20.w,
                                  // ),
                                  // Icon(
                                  //   Icons.info,
                                  //   color: widget.bgColor,
                                  // )
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0, top: 5.0),
                child: Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 13.0, top: 12, bottom: 12, right: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Frequently Consumed",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: widget.bgColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            Visibility(
                              visible:
                                  widget.frequentFood == null || widget.frequentFood.isNotEmpty,
                              child: InkWell(
                                onTap: () {
                                  String selectedDateTemp;
                                  if (_selectedDay.runtimeType == DateTime) {
                                    selectedDateTemp =
                                        DateFormat('yyyy-MM-dd').format(_selectedDay);
                                  }
                                  Get.to(FrequentlyConsumedScreen(
                                    freqList: widget.frequentFood,
                                    baseColor: widget.bgColor,
                                    mealData: widget.mealData,
                                    logDate: _selectedDay.runtimeType == DateTime
                                        ? selectedDateTemp
                                        : _selectedDay == null
                                            ? todayDate
                                            : _selectedDay.toString(),
                                    mealType: widget.mealType,
                                    range: _navigate.value,
                                  ));
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "View All ",
                                      style: TextStyle(
                                        color: widget.frequentFood == null ||
                                                widget.frequentFood.isNotEmpty
                                            ? widget.bgColor
                                            : Colors.grey,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 15.sp,
                                      color: widget.frequentFood == null ||
                                              widget.frequentFood.isNotEmpty
                                          ? widget.bgColor
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      widget.frequentFood == null || widget.frequentFood.isNotEmpty
                          ? SizedBox(
                              height: widget.frequentFood == null || widget.frequentFood.length > 4
                                  ? 6.7.h * 4
                                  : 6.7.h * widget.frequentFood.length,
                              child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      widget.frequentFood == null || widget.frequentFood.length > 4
                                          ? 4
                                          : widget.frequentFood.length,
                                  itemBuilder: (BuildContext cntx, int index) {
                                    FreqStatus currentFood = widget.frequentFood != null
                                        ? widget.frequentFood[index]
                                        : FreqStatus();

                                    String sSize =
                                        currentFood.listOfFoodLogs[0]['quantity_unit'] ?? "";
                                    // List<String> splitedTxt = widget
                                    //     .frequentFood[index].listOfFoodLogs[0]['quantity']
                                    //     .split("|");
                                    return ListTile(
                                      onTap: () {
                                        if (_navigate.value) {
                                          // if (widget.frequentFood.length < 20) {
                                          String selectedDateTemp;
                                          Get.delete<FoodDataLoaderController>();
                                          if (_selectedDay.runtimeType == DateTime) {
                                            selectedDateTemp =
                                                DateFormat('yyyy-MM-dd').format(_selectedDay);
                                          }
                                          Get.to(FoodDetailScreen(
                                              title: currentFood.listOfFoodLogs.first['name'] ?? '',
                                              baseColor: widget.bgColor,
                                              foodId: currentFood.listOfFoodLogs[0]['food_id'],
                                              mealType: widget.mealType,
                                              logDate: _selectedDay.runtimeType == DateTime
                                                  ? selectedDateTemp
                                                  : _selectedDay == null
                                                      ? todayDate
                                                      : _selectedDay.toString(),
                                              mealData: widget.mealData));
                                          //   }
                                          //   else {
                                          //     Get.delete<CustomeFoodDataLoaderController>();
                                          //     Get.to(CustomeFoodDetailScreen(
                                          //       foodName: widget.frequentFood[index].listOfFoodLogs[0]['name'],
                                          //       foodId: widget.frequentFood[index].listOfFoodLogs[0]['food_id'],
                                          //       mealType: widget.mealType,
                                          //       mealData: widget.mealData,
                                          //       baseColor: widget.bgColor,
                                          //       logDate: _selectedDay == null
                                          //           ? todayDate
                                          //           : _selectedDay.toString(),
                                          //     ));
                                          //   }
                                          // }
                                        }
                                      },
                                      leading: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentFood.listOfFoodLogs[0]['name'],
                                            style: AppTextStyles.blackText1,
                                          ),
                                          Text(
                                            currentFood.listOfFoodLogs[0]['quantity'] + sSize,
                                            style: AppTextStyles.ShadowFonts1,
                                          )
                                        ],
                                      ),
                                      // subtitle: Text(splitedTxt[0]),
                                      trailing: SizedBox(
                                        width: 25.w,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${currentFood.listOfFoodLogs[0]['quantity'].toString()} Cal',
                                              style: AppTextStyles.ShadowFonts2,
                                            ),
                                            Icon(
                                              Icons.add,
                                              color: _navigate.value ? widget.bgColor : Colors.grey,
                                              size: 21.sp,
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: SizedBox(
                                height: 12.h,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "No Recents",
                                          style: AppTextStyles.ShadowFonts,
                                        ),
                                        Text(
                                          "Continue Searching for food",
                                          style: AppTextStyles.ShadowFonts,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                    ],
                  ),
                ),
              ),
              GetBuilder<FoodDetailController>(
                init: FoodDetailController(),
                id: 'FoodDetailsScreen',
                builder: (FoodDetailController favFood) {
                  // Get.find<FoodDetailController>().getBookMarkedFoodDetail();
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
                                  "My Favourites",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: widget.bgColor,
                                      fontWeight: FontWeight.w600),
                                ),
                                Visibility(
                                  visible: favFood.favList.isNotEmpty,
                                  child: Row(
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            String selectedDateTemp;
                                            if (_selectedDay.runtimeType == DateTime) {
                                              selectedDateTemp =
                                                  DateFormat('yyyy-MM-dd').format(_selectedDay);
                                            }
                                            Get.to(MyFavouriteScreen(
                                              range: _navigate.value,
                                              myFavour: favFood.favList,
                                              baseColor: widget.bgColor,
                                              mealType: widget.mealType,
                                              logDate: _selectedDay.runtimeType == DateTime
                                                  ? selectedDateTemp
                                                  : _selectedDay == null
                                                      ? todayDate
                                                      : _selectedDay.toString(),
                                              mealData: widget.mealData,
                                            ));
                                          },
                                          child: Text(
                                            "View All ",
                                            style: TextStyle(
                                              color: favFood.favList.isEmpty
                                                  ? Colors.grey
                                                  : widget.bgColor,
                                              fontSize: 15.sp,
                                            ),
                                          )),
                                      Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 15.sp,
                                        color:
                                            favFood.favList.isEmpty ? Colors.grey : widget.bgColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          favFood.favList.isEmpty
                              ? SizedBox(
                                  height: 12.h,
                                  child: Center(
                                      child: Text(
                                    "Food is not added to Favourites",
                                    style: AppTextStyles.ShadowFonts,
                                  )),
                                )
                              : SizedBox(
                                  height: favFood.favList.length > 4
                                      ? 6.5.h * 4
                                      : 6.5.h * favFood.favList.length,
                                  child: ListView.builder(
                                      itemCount:
                                          favFood.favList.length > 4 ? 4 : favFood.favList.length,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (BuildContext cntx, int index) {
                                        List<String> splitedTxt =
                                            favFood.favList[index].subtitle.split("|");
                                        // bookmarks.contains(favFood.favList[index].foodItemID)?
                                        return SizedBox(
                                            height: 6.h,
                                            child: ListTile(
                                              onTap: () async {
                                                // Get.find<FoodDetailController>();
                                                if (_navigate.value) {
                                                  if (favFood.favList[index].foodItemID.length <
                                                      20) {
                                                    String selectedDateTemp;
                                                    Get.delete<FoodDataLoaderController>();
                                                    if (_selectedDay.runtimeType == DateTime) {
                                                      selectedDateTemp = DateFormat('yyyy-MM-dd')
                                                          .format(_selectedDay);
                                                    }
                                                    Get.to(FoodDetailScreen(
                                                      title: favFood.favList[index].title,
                                                      foodId: favFood.favList[index].foodItemID,
                                                      mealType: widget.mealType,
                                                      mealData: widget.mealData,
                                                      baseColor: widget.bgColor,
                                                      logDate: _selectedDay.runtimeType == DateTime
                                                          ? selectedDateTemp
                                                          : _selectedDay == null
                                                              ? todayDate
                                                              : _selectedDay.toString(),
                                                    ));
                                                  } else {
                                                    Get.delete<FoodDataLoaderController>();
                                                    Get.to(CustomeFoodDetailScreen(
                                                      foodName: favFood.favList[index].title,
                                                      foodId: favFood.favList[index].foodItemID,
                                                      mealType: widget.mealType,
                                                      mealData: widget.mealData,
                                                      baseColor: widget.bgColor,
                                                      logDate: _selectedDay == null
                                                          ? todayDate
                                                          : _selectedDay.toString(),
                                                    ));
                                                  }
                                                }
                                              },
                                              leading: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(favFood.favList[index].title ?? " ",
                                                      style: AppTextStyles.blackText1),
                                                  Text(splitedTxt[0],
                                                      style: AppTextStyles.ShadowFonts1)
                                                ],
                                              ),
                                              // subtitle: Text(splitedTxt[0]),
                                              trailing: SizedBox(
                                                width: 25.w,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      splitedTxt[1],
                                                      style: AppTextStyles.ShadowFonts2,
                                                    ),
                                                    Obx(() => Icon(
                                                          Icons.add,
                                                          color: _navigate.value
                                                              ? widget.bgColor
                                                              : Colors.grey,
                                                          size: 21.sp,
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            ));
                                      }))
                        ],
                      ),
                    ),
                  );
                },
              ),
              GetBuilder<FoodDetailController>(
                id: "Custome food widget",
                builder: (FoodDetailController cusFood) {
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
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'My Meals',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: widget.bgColor,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      TextSpan(
                                        text: '\n(Custom food)',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w300),
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: cusFood.customFoodlist.isNotEmpty,
                                  child: InkWell(
                                    onTap: () {
                                      String selectedDateTemp;
                                      if (_selectedDay.runtimeType == DateTime) {
                                        selectedDateTemp =
                                            DateFormat('yyyy-MM-dd').format(_selectedDay);
                                      }
                                      Get.to(MyMealScreen(
                                        myMeal: cusFood.customFoodlist,
                                        baseColor: widget.bgColor,
                                        mealType: widget.mealType,
                                        mealData: widget.mealData,
                                        logDate: _selectedDay == null
                                            ? todayDate
                                            : _selectedDay.toString(),
                                      ));
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "View All ",
                                          style: TextStyle(
                                            color: cusFood.customFoodlist.isEmpty
                                                ? Colors.grey
                                                : widget.bgColor,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          size: 15.sp,
                                          color: cusFood.customFoodlist.isEmpty
                                              ? Colors.grey
                                              : widget.bgColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          cusFood.customFoodlist.isEmpty
                              ? SizedBox(
                                  height: 12.h,
                                  child: Center(
                                      child: Text(
                                    "No Recipes Created",
                                    style: AppTextStyles.ShadowFonts,
                                  )),
                                )
                              : SizedBox(
                                  height: cusFood.customFoodlist.length > 3
                                      ? 7.h * 4
                                      : 10.h * cusFood.customFoodlist.length,
                                  child: ListView.builder(
                                      itemCount: cusFood.customFoodlist.length > 4
                                          ? 4
                                          : cusFood.customFoodlist.length,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (BuildContext cntx, int index) {
                                        List<String> splitedTxt =
                                            cusFood.customFoodlist[index].subtitle.split("|");
                                        return SizedBox(
                                          height: 6.h,
                                          child: ListTile(
                                            onTap: () {
                                              if (_navigate.value) {
                                                Get.delete<CustomeFoodDataLoaderController>();
                                                Get.to(CustomeFoodDetailScreen(
                                                  foodName: cusFood.customFoodlist[index].title,
                                                  foodId: cusFood.customFoodlist[index].foodItemID,
                                                  mealType: widget.mealType,
                                                  mealData: widget.mealData,
                                                  baseColor: widget.bgColor,
                                                  logDate: _selectedDay == null
                                                      ? todayDate
                                                      : _selectedDay.toString(),
                                                ));
                                              }
                                            },
                                            leading: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  child: Text(
                                                      cusFood.customFoodlist[index].title ?? " ",
                                                      style: AppTextStyles.blackText1),
                                                  width: 60.w,
                                                ),
                                                Text(splitedTxt[0],
                                                    style: AppTextStyles.ShadowFonts1)
                                              ],
                                            ),
                                            // subtitle: Text(splitedTxt[0]),
                                            trailing: SizedBox(
                                              width: 25.w,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    splitedTxt[1],
                                                    style: AppTextStyles.ShadowFonts2,
                                                  ),
                                                  Obx(() => Icon(
                                                        Icons.add,
                                                        color: _navigate.value
                                                            ? widget.bgColor
                                                            : Colors.grey,
                                                        size: 21.sp,
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }))
                        ],
                      ),
                    ),
                  );
                },
              ),
              Container(height: 15.h)
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
