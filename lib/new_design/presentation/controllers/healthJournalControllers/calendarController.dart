import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/models/get_activity_log_model.dart';
import 'package:ihl/views/dietJournal/models/get_food_log_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/SpUtil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../views/dietJournal/models/create_food_group_meal_model.dart';
import '../../../../views/dietJournal/models/delete_food_group_meal.dart';
import '../../../../views/dietJournal/models/get_food_group_meal_model.dart';
import '../../../../views/dietJournal/models/user_bookmarked_activity_model.dart';

class ClendarController extends GetxController {
  ListApis listApis = ListApis();
  List<String> foodNamelist = [];
  List foodFoodIdList = [];
  List textGrouping = [];
  List foodQuantityList = [];
  List foodServingUnitList = [];
  List foodTotalCalorieList = [];
  int totalKcal = 0;
  int sum = 0;
  String grpName = '';
  List<GetActivityLog> activityLogHistory = [];
  RxInt calendarSelected = 0.obs;
  Rx<TimeOfDay> initSelectedTime = TimeOfDay.now().obs;
  Rx<bool> futureSelected = false.obs;
  RxString maelType = "Breakfast".obs;
  Rx<HexColor> bgColor = HexColor("#f57f64").obs;
  RxString selectedDate = "Today".obs;
  bool loading = true;
  bool favLoading = false;
  bool fetchGroupMealLoading = false;
  bool groupMealLoading = false;
  bool recentLoading = false;
  Rx<DateTime> focusedDay = DateTime.now().obs;
  bool currentWeek = true;
  List<GetFoodLog> foodLogHistory = [];
  List<BookMarkedActivity> favDetails = [];
  CreateFoodGroupMealModel foodGroupMealDetails;
  DeleteFoodGroupMealModel deleteGroupMealDetails;
  List<BookMarkedActivity> recentList = [];
  List<Status> status = <Status>[];
  int totalGained = 0;
  RxBool deletelog = false.obs;
  Map<String, dynamic> resultMap;

  // RxList<bool> isCheckedList = List.generate(100, (index) => false).obs;
  RxList<RxBool> isCheckedList = List.generate(100, (int index) => false.obs).obs;

  // List<FoodListTileModel> mealsListData = [];
  DateTime now = DateTime.now();

  @override
  void onInit() {
    String endDate =
        "${DateFormat("yyyy-MM-dd").format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))} 23:59:00";
    String startDate = DateFormat("yyyy-MM-dd")
        .format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
    updateFavActivity();
    updateRecentActivity();
    super.onInit();
  }

  ///call made for getFoodGroup List return status all food group will be got
  dataGroupedMeal(String iHLUserId) async {
    status.clear();
    List groupMealListData = await listApis.getFoodGroupScreenApi(ihlUserId: iHLUserId);
    if (groupMealListData != null) {
      status.addAll(groupMealListData.map((e) => Status.fromJson(e)).toList());
      status.removeWhere((Status element) {
       return element.listOfFoodLogs["mealCategory"] !=maelType.value;
      });
      print(status);
    }
    if (status.isNotEmpty) {
      fetchGroupMealLoading = true;
    }
    update(["fetchFoodList"]);
    return status;
  }

  ///this is for checkbox in delete group
  updatedeleteLog() async {
    deletelog.value = !deletelog.value;
    update(["deleteFoodList","fetchFoodList"]);

    return deletelog.value;
  }

  updateGroupMeal() async {
    ///to add ihlUserId done this
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    await dataGroupedMeal(iHLUserId);
  }

  updateTab({@required int value}) {
    calendarSelected.value = value;
  }

  updateDate({@required String Date, @required DateTime focusedDate}) {
    selectedDate.value = Date;
    focusedDay.value = focusedDate;
  }

  updateFoodDetail(var StartDate, var endDate, String myMeal) async {
    foodLogHistory = await ListApis.getUserFoodLogHistoryApi(
      fromDate: StartDate,
      tillDate: endDate,
    );
    try {
      foodLogHistory.removeWhere((GetFoodLog element) =>
          element.food.isEmpty || element.foodTimeCategory.toLowerCase() != myMeal.toLowerCase());
    } catch (e) {
      print(e);
    }

    update(["DayFoodDetails"]);
  }

  updateActivityDetails(var StartDate, var endDate) async {
    loading = true;
    activityLogHistory =
        await listApis.getUserActivityLogHistoryApi(fromDate: StartDate, tillDate: endDate);
    activityLogHistory.removeWhere((GetActivityLog element) => element.activityDetails.isEmpty);
    log('Activity log history ${activityLogHistory.length}');
    loading = false;
    update(["Activity Data"]);
  }

  updateTime(selectedTime, logDate) {
    DateTime formattedDate = DateFormat('yyyy-MM-dd hh:mm')
        .parse(logDate + " ${selectedTime.hour}:${selectedTime.minute}");
    if (formattedDate.isAfter(DateTime.now())) {
      futureSelected.value = true;
    } else {
      futureSelected.value = false;
    }
    print(formattedDate);

    initSelectedTime.value = selectedTime;
  }

  updateMealType(mealType) {
    maelType.value = mealType;
    bgColor.value = mealType == "Breakfast"
        ? HexColor("#f57f64")
        : mealType == "Lunch"
            ? HexColor('#19a9e5')
            : mealType == "Snacks"
                ? HexColor("#FF5287")
                : HexColor("#1E1466");
  }

  updateFavActivity() async {
    favLoading = true;
    update(["Fav Activity Data"]);
    favDetails = await ListApis.getBookMarkedActivity();
    favLoading = false;
    update(["Fav Activity Data"]);
  }

  ///for createFoodGroupMeal conversion variables to string to sent backend
  updateFoodGroupMeal(
      {group_name,
      foodFoodIdList,
      foodNamelist,
      foodQuantityList,
      foodServingUnitList,
      foodTotalCalories,
      total_calorie_count,
      meal_category,
      }) async {
    String modifiedfoodFoodIdListString = removeFirstAndLast(foodFoodIdList.toString());
    String modifiedfoodFoodNameListString = removeFirstAndLast(foodNamelist.toString());
    String modifiedfoodQuantitydListString = removeFirstAndLast(foodQuantityList.toString());
    String modifiedfoodTotalCaloriesListString = removeFirstAndLast(foodTotalCalories.toString());
    String modifiedfoodServingUnitListListString =
        removeFirstAndLast(foodServingUnitList.toString());
    groupMealLoading = true;
    foodGroupMealDetails = await ListApis.createFoodGroupMeal(
        group_name: group_name,
        meal_category:meal_category,
        foodFoodIdList: modifiedfoodFoodIdListString.toString(),
        foodNamelist: modifiedfoodFoodNameListString.toString(),
        foodQuantityList: modifiedfoodQuantitydListString.toString(),
        foodServingUnitList: modifiedfoodServingUnitListListString.toString(),
        foodTotalCaloriesList: modifiedfoodTotalCaloriesListString.toString(),
        total_calorie_count: int.parse(total_calorie_count.toString()));
    print(foodGroupMealDetails);
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    await dataGroupedMeal(iHLUserId);
    groupMealLoading = false;
  }

  updateDeleteFoodGroupMeal({group_id}) async {
    deleteGroupMealDetails = await ListApis.deleteFoodGroupMeal(group_id: group_id);
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    await dataGroupedMeal(iHLUserId);
  }

  String removeFirstAndLast(String input) {
    if (input.length >= 2) {
      // Use substring to remove the first and last characters
      return input.substring(1, input.length - 1);
    } else {
      // Handle the case where the string has less than 2 characters
      return "String is too short";
    }
  }

  updateRecentActivity() async {
    recentLoading = true;
    update(["Recent Activity Data"]);
    recentList = SpUtil.getRecentActivityObjectList('recent_activity') ?? [];
    recentLoading = false;
    update(["Recent Activity Data"]);
  }
}
