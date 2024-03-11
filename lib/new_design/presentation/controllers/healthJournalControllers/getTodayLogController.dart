import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../pages/spalshScreen/splashScreen.dart';
import '../../../../views/goal_settings/apis/goal_apis.dart';
import 'package:intl/intl.dart';

import '../../../data/model/healthJournalModel/getTodayLog.dart';
import '../../../data/providers/network/apis/healthJournalApi/healthJournalApi.dart';

class TodayLogController extends GetxController {
  GetTodayLogModel todayLogDetails = GetTodayLogModel();
  GetTodayLogModel logDetails = GetTodayLogModel();
  HealthJournalApi healthJournalApi = HealthJournalApi();
  bool dataLoading = false;
  List sortedData = [];
  int caloriesEaten = 0;
  int completedCal = 0;
  int caloriesBurnt = 0;
  int caloriesGained = 0;
  int caloriesNeed = 0;
  String totalCalories = "0";
  String targetWeight = "0.0";
  int exceedsCalories = 0;
  List goalLists = [];
  bool limitExceed = false;
  @override
  void onInit() {
    dataLoading = true;
    getTodayLog();
    getGoalData();

    super.onInit();
  }

  Future<void> getTodayLog() async {
    sortedData = [];
    caloriesEaten = 0;
    completedCal = 0;
    caloriesBurnt = 0;
    caloriesGained = 0;
    caloriesNeed = 0;
    totalCalories = localSotrage.read(LSKeys.caloriesNeed) ?? "0"; // Use the null-aware operator

    final String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final todayLogDetails = await healthJournalApi.getTodayLog();
    logDetails = todayLogDetails;
    void filterLogs(entries) {
      entries.removeWhere((element) => currentDate != element.logTime.substring(0, 10));
    }

    if (todayLogDetails.food != null) {
      filterLogs(todayLogDetails.food);
      caloriesEaten = todayLogDetails.food.fold(0, (sum, entry) {
        final double caloriesGained = double.tryParse(entry.totalCaloriesGained ?? '0') ?? 0;
        return sum + caloriesGained.toInt();
      });
    }

    if (todayLogDetails.activity != null) {
      filterLogs(todayLogDetails.activity);
      caloriesBurnt = todayLogDetails.activity.fold(0, (sum, entry) {
        return sum + int.parse(entry.totalCaloriesBurned);
      });
    }

    caloriesNeed = (int.parse(totalCalories) - caloriesEaten + caloriesBurnt);
    exceedsCalories = (int.parse(totalCalories) - caloriesEaten).abs();
    if (caloriesNeed <= 0) {
      limitExceed = true;
    } else {
      limitExceed = false;
    }

    // caloriesNeed += caloriesBurnt;
    // caloriesGained = caloriesEaten - caloriesBurnt;
    dataLoading = false;
    update(["Today Food"]);
  }

  getGoalData() {
    goalLists = [];
    final GetStorage navi = GetStorage();
    GoalApis.listGoal().then((List value) async {
      if (value != null) {
        List<dynamic> activeGoalLists = [];
        for (int i = 0; i < value.length; i++) {
          if (value[i]['goal_status'] == 'active') {
            activeGoalLists.add(value[i]);
          }
        }
        goalLists = activeGoalLists;
        if (goalLists.isEmpty) {
          localSotrage.write(LSKeys.caloriesNeed, localSotrage.read(LSKeys.ogCaloriesNeed));
          navi.write("setGoalNavigation", false);
          dataLoading = false;
          update(["Today Food"]);
        } else {
          localSotrage.write(LSKeys.caloriesNeed, goalLists[0]["target_calorie"]);
          totalCalories = goalLists[0]["target_calorie"];
          //updating caloriesNeed whenever totalCalories changed
          caloriesNeed = (int.parse(totalCalories) - caloriesEaten + caloriesBurnt);
          targetWeight = goalLists[0]["target_weight"];
          // caloriesNeed = int.parse(goalLists[0]["target_calorie"]);
          navi.write("setGoalNavigation", true);
          dataLoading = false;
          update(["Today Food"]);
        }
      }
    });
  }
}

class LogEntry {
  final String logTime;
  final String totalCaloriesGained;
  final String totalCaloriesBurned;

  LogEntry({
    @required this.logTime,
    @required this.totalCaloriesGained,
    @required this.totalCaloriesBurned,
  });
}

class LogButtonLoader extends GetxController {
  RxBool isButtonLoading = false.obs;
  updateButtonLoading(bool value) {
    isButtonLoading.value = value;
    update(['LogButtonLoader']);
  }
}
