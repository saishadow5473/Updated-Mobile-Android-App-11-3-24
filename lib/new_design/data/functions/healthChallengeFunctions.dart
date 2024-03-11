import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../health_challenge/controllers/challenge_api.dart';
import '../../../health_challenge/models/sendInviteUserForChallengeModel.dart';
enum DistanceUnit { Kilometers, Meters, Steps }
class HealthChallengeFunctions {
  bool isRouteValid(String currentRoute) {
    return currentRoute != "/VideoCall" ||
        currentRoute != "/SubscriptionCallBackground" ||
        currentRoute != "/ReconnectingVideoCall" ||
        currentRoute != "/LoginEmailScreen" ||
        currentRoute != "/ConsultStagesPage";
  }

  static const String _startTimeKey = 'day_start_time';
  static const String _endTimeKey = 'day_end_time';
  static const String _intervalKey = 'interval';
  List<String> challengeBadges = [
    'newAssets/images/groupChallenge.png',
    'newAssets/images/runningChallenge.png',
    'newAssets/images/stepChallenge.png',
  ];
  static inviteThroughEmailApiCall(String challengeID, referredbyname, refferredtoemail,
      int invitedEmailCount, var _sendInviteEmailController) async {
    if (invitedEmailCount <= 5) {
      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      String userEmail = prefs1.getString("email");
      String userName = prefs1.getString('name') ?? 'Username';
      var response = await ChallengeApi().inviteUserForChallenge(
          sendInviteUserForChallenge: SendInviteUserForChallenge(
              challangeId: challengeID,
              referredbyname: userName,
              referredbyemail: userEmail,
              refferredtoemail: refferredtoemail));
      if (response == "invite success") {
        invitedEmailCount = invitedEmailCount - 1;
        _sendInviteEmailController.clear();
        toastMessageAlert("Invited Successfully!!");
      } else if (response == "already invited") {
        toastMessageAlert("Email already invited");
      } else if (response == "failed") {
        toastMessageAlert("Invite send failed");
      }
    } else {
      toastMessageAlert("Already invited 5 members!!");
    }
  }

  static toastMessageAlert(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static List<String> splitTimeRange(String hourDetail) {
    // Remove any quotation marks from the string
    String jsonString = hourDetail.replaceAll('&quot;', '"');

    // Decode the string into a map
    Map<String, dynamic> decodedMap = jsonDecode(jsonString);

    // Check if the required keys are present in the map
    if (!decodedMap.containsKey(_startTimeKey) ||
        !decodedMap.containsKey(_endTimeKey) ||
        !decodedMap.containsKey(_intervalKey)) {
      return [];
    }

    // Get the start and end times from the map
    String start = decodedMap[_startTimeKey];
    String end = decodedMap[_endTimeKey];
    // Get the interval from the map
    int hour = int.tryParse(decodedMap[_intervalKey].toString().replaceAll(RegExp(r'[^0-9]'), ''));

    // Create a DateTime object from the start and end times
    DateFormat dateFormat = DateFormat('HH:mm');
    DateFormat _intervalDateFormat = DateFormat('hh:mm a');
    DateTime startDateTime = dateFormat.parse(start);
    DateTime endDateTime = dateFormat.parse(end);

    // Create a list to store the intervals
    List<String> timeList = [];

    while (startDateTime.isBefore(endDateTime)) {
      timeList.add(_intervalDateFormat.format(startDateTime));
      startDateTime = startDateTime.add(Duration(hours: hour));
    }

    // Add the last time with PM
    timeList.add(_intervalDateFormat.format(endDateTime));

    return timeList;
  }

  static int getCurrentIntervalIndex(List<Map<String, String>> intervals) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd hh:mm a');
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < intervals.length; i++) {
      String intervalStartDateString =
          '${currentDate.year}-${currentDate.month}-${currentDate.day} ${intervals[i]['start']}';
      String intervalEndDateString =
          '${currentDate.year}-${currentDate.month}-${currentDate.day} ${intervals[i]['end']}';

      DateTime intervalStart = dateFormat.parse(intervalStartDateString);
      DateTime intervalEnd = dateFormat.parse(intervalEndDateString);

      if (currentDate.isAfter(intervalStart) && currentDate.isBefore(intervalEnd)) {
        return i;
      }
    }

    return -1; // Return -1 if the current time is not within any interval
  }

  static List<Map<String, String>> generateDateList(DateTime startDate, int durationInDays) {
    final DateFormat outputFormat = DateFormat('MM/dd/yyyy');

    List<Map<String, String>> dateList = [];

    for (int i = 0; i < durationInDays; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String formattedDate = outputFormat.format(currentDate);
      dateList.add({'date': formattedDate, 'day': 'Day ${i + 1}'});
    }

    return dateList;
  }

  static String findTimeForSession(String sessionName) {
    final DateFormat timeFormat = DateFormat('HH:mm');

    Map<String, String> sessionTimes = {
      'Early Morning': '05:00',
      'Morning': '08:00',
      'Pre-workout snack': '09:30',
      'Post-workout snack': '11:00',
      'Breakfast': '11:30',
      'Mid-morning snack': '10:00',
      'Noon': '12:00',
      'Afternoon': '15:00',
      'Lunch': '13:00',
      'Brunch': '10:30',
      'Evening': '18:00',
      'Snacks': '16:00',
      'Night': '20:00',
      'Bedtime snack': '21:30',
    };

    String sessionTime = sessionTimes[sessionName] ?? '';

    if (sessionTime.isNotEmpty) {
      return '$sessionTime:00';
    } else {
      return 'Session not found';
    }
  }

  static String convertTimeFormat(String timeString) {
    final DateFormat inputFormat = DateFormat('HH:mm');
    final DateFormat outputFormat = DateFormat('HH:mm:ss');

    DateTime dateTime = inputFormat.parse(timeString);
    return outputFormat.format(dateTime);
  }
 static double calculateCaloriesBurned(double distance, double weight, DistanceUnit unit) {
   // Conversion factors
   const double metersPerKm = 1000.0;
   const double stepsPerKm = 1300.0; // Replace with your actual steps-to-km conversion

   // Convert distance to kilometers for uniform calculation
   double distanceInKm;
   switch (unit) {
     case DistanceUnit.Kilometers:
       distanceInKm = distance;
       break;
     case DistanceUnit.Meters:
       distanceInKm = distance / metersPerKm;
       break;
     case DistanceUnit.Steps:
       distanceInKm = distance / stepsPerKm;
       break;
   }

   // Assuming a standard value of 0.75 calories burned per kg per km
   double caloriesPerKgPerKm = 0.75;

   double caloriesBurned = distanceInKm * weight * caloriesPerKgPerKm;
   return caloriesBurned;
 }
}
