import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../constants/spKeys.dart';
import '../../../../../health_challenge/controllers/challenge_api.dart';
import '../../../../../health_challenge/models/challenge_detail.dart';
import '../../../../../health_challenge/models/enrolled_challenge.dart';
import '../../../../../health_challenge/models/join_individual.dart';
import '../../../../../views/gamification/dateutils.dart';
import '../../../../../views/splash_screen.dart';
import '../../../../data/functions/healthChallengeFunctions.dart';

class SessionSelectionController extends GetxController {
  RxInt isDaySelected = 0.obs;
  RxInt isSessionSelected = 0.obs;
  RxBool isReminderToggle = false.obs;
  String dayLoadingUpdate = 'DayLoadingUpdate';
  RxBool isLoadinginSubmit = false.obs;
  String dateUpdateId = 'DateUpdate',
      dayTextUpdate = 'DayTextUpdate',
      scrollUpdateId = 'ScrollUpdateId',
      setReminder = "SetReminderUpdate",
      setFinallyCompleted = "SetFinallyCompleted",
      setReminderId = "SetReminderId";
  String selectedDate, selectedTime = '00:00:00', selectedDay = 'Day 1';
  bool challengeEnrolled = false;
  var dateList = [];
  EnrolledChallenge challengeEnrollDetail;
  List<Map> userLogData = [];
  EnrolledChallenge enroll;
  UserDetails userDetails;
  RxBool finallyCompleted = false.obs;
  int targetAdded = 0;
  bool finishTarget = false;
  Map reminderList = {};
  String finishTargetUpdate = 'FinishTargetUpdate';

  updateDayTextValue(String v) {
    selectedDay = v;
    update([dayTextUpdate]);
  }

  updatefinishTarget(bool v) {
    finishTarget = v;
    update([finishTargetUpdate]);
  }

  updateDayLoadingUpdate(bool v) {
    isLoadinginSubmit.value = v;
    update([dayLoadingUpdate]);
  }

  updateSetFinallyCompleted(bool v) {
    finallyCompleted.value = v;
    update([setFinallyCompleted]);
  }

  updateSetReminder(bool v) {
    isReminderToggle.value = v;
    update([setFinallyCompleted]);
  }

  bool joinIndividualOfGroupList = false;
  @override
  void onInit() {
    super.onInit();
    userDetails = UserDetails(
        userId: '',
        name: '',
        city: '',
        gender: '',
        department: '',
        designation: '',
        isGloble: null,
        email: '',
        userStartLocation: '',
        selected_fitness_app: '');
  }

  Future getUserDetails(EnrolledChallenge enrollChallenge) async {
    try {
      enroll = await ChallengeApi().getEnrollDetail(enrollChallenge.enrollmentId);
      reminderList = jsonDecode(enroll.reminder_detail.replaceAll("&quot;", "\""));
      print(reminderList['reminder']);
    } catch (e) {
      print(e);
    }
    update(["setReminderId"]);
    return reminderList;
  }

  Future<void> firstDateGetter(
      EnrolledChallenge enrollChallenge, ChallengeDetail challengeDetail) async {
    DateTime _startDate;
    if (DateFormat('MM-dd-yyyy').format(challengeDetail.challengeStartTime).toString() !=
        "01-01-2000") {
      _startDate = challengeDetail.challengeStartTime;
    } else {
      if (enrollChallenge != null) {
        _startDate = enrollChallenge.userStartTime;
      } else {
        _startDate = DateTime.now();
      }
    }

    userLogData = generateListOfMaps(int.parse(challengeDetail.challengeDurationDays), _startDate);
    // userLogData = enrollChallenge != null
    //     ? userLogData = await ChallengeApi().getLogUserDetails(
    //         enrolId: enrollChallenge.enrollmentId,
    //         startDate: _startDate,
    //       )
    //     : null;
    if (enrollChallenge != null) {
      DateTime _startDateApi = DateTime(
        enrollChallenge.userStartTime.year,
        enrollChallenge.userStartTime.month,
        enrollChallenge.userStartTime.day,
      );
      var _apiData = await ChallengeApi().getLogUserDetails(
        enrolId: enrollChallenge.enrollmentId,
        startDate: _startDateApi,
      );
      userLogData = updateAchievedValue(userLogData, _apiData);
    } else {
      var _apiData = await ChallengeApi().getLogUserDetails(
        enrolId: enrollChallenge.enrollmentId,
        startDate: _startDate,
      );
      userLogData = updateAchievedValue(userLogData, _apiData);
    }
    generateDateandStore(challengeDetail: challengeDetail, enrollChallenge: enrollChallenge);
    update([scrollUpdateId]);
  }

  List<Map<String, dynamic>> updateAchievedValue(
      List<Map<String, dynamic>> generatedList, var apiData) {
    DateTime today = DateTime.now();
    List<Map<String, dynamic>> updatedList = List.from(generatedList);
    apiData.sort((a, b) => DateFormat("MM/dd/yyyy")
        .parse(b['log_time'])
        .compareTo(DateFormat("MM/dd/yyyy").parse(a['log_time'])));

    for (var apiEntry in apiData) {
      for (var i = 0; i < updatedList.length; i++) {
        var generatedEntry = updatedList[i];
        var generatedDate = generatedEntry['datetime'];

        if (generatedDate.isAtSameMomentAs(DateFormat("MM/dd/yyyy").parse(apiEntry['log_time']))) {
          generatedEntry['achieved'] += int.parse(apiEntry['achieved']);
          generatedEntry['logged'] = true;
        }
      }
    }

    return updatedList;
  }

  List<Map<String, dynamic>> generateListOfMaps(int numberOfEntries, DateTime startDate) {
    List<Map<String, dynamic>> resultList = [];
    DateTime _now = DateTime.now();
    DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);

    for (int i = 1; i <= numberOfEntries; i++) {
      bool isExpired =
          _now.isAfter(DateTime(currentDate.year, currentDate.month, currentDate.day, 23, 59, 59));

      Map<String, dynamic> entry = {
        "achieved": 0, // You can replace "$i" with your actual data
        "unit": "minute", // You can replace "minute" with your actual data
        "logged": false, // You can replace "false" with your actual data
        "datetime": currentDate,
        "expired": isExpired
      };

      resultList.add(entry);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return resultList;
  }

  DateTime convertTimestampToDateTime(int timestamp) {
    // Create a DateTime object from the timestamp
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return dateTime;
  }

  void generateDateandStore({ChallengeDetail challengeDetail, EnrolledChallenge enrollChallenge}) {
    // if (challengeDetail.challengeStartTime.isSameDate(DateTime(2000, 01, 01)) &&
    //     userLogData.isEmpty) {
    //   challengeDetail.challengeStartTime = DateTime.now();
    // } else if (challengeDetail.challengeStartTime.isSameDate(DateTime(2000, 01, 01)) &&
    //     userLogData.isNotEmpty) {
    //   userLogData.sort((a, b) {
    //     DateTime timeA = DateFormat('MM/dd/yyyy').parse(a["log_time"]);
    //     DateTime timeB = DateFormat('MM/dd/yyyy').parse(b["log_time"]);
    //     return timeA.compareTo(timeB);
    //   });
    //   challengeDetail.challengeStartTime =
    //       DateFormat('MM/dd/yyyy').parse(userLogData[0]["log_time"]);
    // }
    if (enrollChallenge != null) {
      dateList = HealthChallengeFunctions.generateDateList(
          enrollChallenge.userStartTime, int.parse(challengeDetail.challengeDurationDays));
    } else {
      dateList = HealthChallengeFunctions.generateDateList(
          DateTime.now(), int.tryParse(challengeDetail.challengeDurationDays));
    }
    int todayIndex = findIndexForToday(dateList);
    if (enrollChallenge != null) isDaySelected.value = todayIndex;
    update([dateUpdateId]);
  }

  int findIndexForToday(List<Map<String, String>> dataList) {
    // Get today's date in the format "MM/dd/yyyy"
    String todayDate = DateFormat('MM/dd/yyyy').format(DateTime.now());

    // Iterate over the dataList and check for a match
    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i]['date'] == todayDate) {
        return i; // Return the index if a match is found
      }
    }

    return -1; // Return -1 if today's date is not found in the dataList
  }

  updateDaySelection(int index) {
    isDaySelected.value = index;
    update(["Day Card"]);
  }

  updateSessionSelection(int index) {
    isSessionSelected.value = index;
    update(["Session Card"]);
  }

  checkChallengeIsEnrolled(String challengeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("ihlUserId");

    List<EnrolledChallenge> enList =
        await ChallengeApi().listofUserEnrolledChallenges(userId: userId);
    if (enList.isNotEmpty) {
      for (EnrolledChallenge i in enList) {
        if (i.challengeId == challengeId) {
          challengeEnrolled = true;
          challengeEnrollDetail = i;
        }
      }
    }
    update(["Enroll detail"]);
  }
}
