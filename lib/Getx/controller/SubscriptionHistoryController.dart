import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api.dart';
import 'listOfChallengeContoller.dart';

class SubScriptionHistoryController extends GetxController {
  final ListChallengeController listChallengeController = Get.put(ListChallengeController());
  List selectedList = [];
  String _ihlUserId;
  bool switchLoading = false;
  bool completed = false;
  ScrollController controller = ScrollController();
  var filterType = 'Accepted';
  bool isLoading = true;

  addItems() async {
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.position.pixels) {
        fetch();
      }
    });
  }

  fetch() async {
    List _l = await getSubscriptionHistory(
      endPage: selectedList.length,
    );
    if (completed) {
      //TODO added completed filed in subscription list
      _l = filterNonExpiredCourses(_l);
    }
    selectedList.addAll(_l);
    update(['listupdated']);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void onInit() async {
    selectedList = await getSubscriptionHistory(
      endPage: 0,
    );
    addItems();
    super.onInit();
  }

  Future<List> getSubscriptionHistory({
    int endPage,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ihlUserId = prefs.getString("ihlUserId");
    List _l = [];

    var startIndex = endPage;
    var endIndex = endPage + 10;
    var _res = await Dio().post(
      API.iHLUrl + "/consult/view_all_subcription_pagination",
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      ),
      data: {
        'user_ihl_id': _ihlUserId,
        "start_index": startIndex,
        "end_index": endIndex,
        "approval_status": filterType
      },
    );
    if (_res.statusCode == 200) {
      List _list;
      if (_res.data['subscriptions'] != null) {
        _list = _res.data['subscriptions'];
      } else {
        _list = _res.data['appts_subscriptions'];
      }

      _list.removeWhere((element) => element['class_detail'] == 'not available');
      _list.removeWhere((element) => element['course_time'] == '');

      _l = _list;
      // switch (filterType) {
      //   case "Rejected":
      //     _l = await expiredSubscriptionFilter(_list);
      //     break;
      //   case "Cancelled":
      //     _l = await expiredSubscriptionFilter(_list);
      //     break;
      //   case "Accepted":
      //     _l = await activeSubscriptionFilter(_list);
      //     break;
      //   case "requested":
      //     _l = await activeSubscriptionFilter(_list);
      //     break;
      // }
    }
    isLoading = false;
    update(['subscriptionLoading', 'listupdated']);
    return _l;
  }

  updateList({bool completed}) async {
    switchLoading = true;
    this.completed = completed;
    update(["listupdated"]);
    selectedList = await getSubscriptionHistory(
      endPage: 0,
    );
    if (this.completed ?? false) {
      selectedList = filterNonExpiredCourses(selectedList);
    }
    switchLoading = false;
    update(["listupdated"]);
  }

  List filterNonExpiredCourses(var courses) {
    DateTime currentDate = DateTime.now();

    var nonExpiredCourses = [];

    for (var course in courses) {
      List<String> dateRange = course["course_duration"].split(" - ");
      DateTime courseEndDate = DateTime.parse(course["course_duration"].split(" - ")[1]);

      if (currentDate.isAfter(courseEndDate)) {
        course['completed'] = true;
        nonExpiredCourses.add(course);
      } else {
        debugPrint('Not Expired');
      }
    }

    return nonExpiredCourses;
  }
}
