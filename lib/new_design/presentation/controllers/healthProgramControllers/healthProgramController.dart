import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../views/goal_settings/apis/goal_apis.dart';

class HealthProgramController extends GetxController with GetSingleTickerProviderStateMixin {
  TabController controller;
  int selectedIndex = 0;
  RxList goalLists = [].obs;
  @override
  void onInit() {
    super.onInit();
    controller =
        TabController(vsync: this, length: 3, animationDuration: const Duration(milliseconds: 800));
    controller.addListener(() {
      selectedIndex = controller.index;
      update(['tabbar']);
    });
    getGoalData();
  }

  void getGoalData() {
    GoalApis.listGoal().then((value) {
      if (value != null) {
        List<dynamic> activeGoalLists = [];
        for (int i = 0; i < value.length; i++) {
          if (value[i]['goal_status'] == 'active') {
            activeGoalLists.add(value[i]);
          }
        }
        goalLists.value = activeGoalLists;
      }
    });
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
