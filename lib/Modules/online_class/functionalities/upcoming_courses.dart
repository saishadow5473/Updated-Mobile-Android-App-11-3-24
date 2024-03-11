import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/api.dart';
import '../bloc/trainer_status/bloc/trainer_bloc.dart';
import 'package:intl/intl.dart';

BuildContext contextForJoincall;

class UpcomingCourses {
  int differenceInDays;
  int differenceInTime;
  bool enableJoinCall = false;
  StreamSubscription<DocumentSnapshot> subscription;
  String trainerStatus = 'Offline';
  bool joinCourseButton(String duration, String courseTime, String trainerStatus, String courseType,
      String courseOn) {
    // testing hardcodes
    // String duration = "2023-11-06 - 2024-01-04";
    // String courseTime = "10:50 AM - 11:30 AM";
    // String trainerStatus = "Online";
    // String courseType = "60 Days";
    // String courseOn = "Monday";
    DateTime currentDateTime = DateTime.now();
    String courseDurationFromApi = duration;
    String courseTimeFromApi = courseTime;
    String courseStartTime;
    String courseEndTime;
    var splitDuration = courseDurationFromApi.split(" - ");
    String courseStartDuration = splitDuration[0];

    String courseEndDuration = splitDuration[1];

    DateTime startDate = DateFormat("yyyy-MM-dd").parse(courseStartDuration);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String startDateFormattedToString = formatter.format(startDate);

    DateTime endDate = DateFormat("yyyy-MM-dd").parse(courseEndDuration);
    String endDateFormattedToString = formatter.format(endDate);

    if (courseTimeFromApi[2].toString() == ':' && courseTimeFromApi[13].toString() != ':') {
      String tempcourseEndTime = '';
      courseStartTime = courseTimeFromApi.substring(0, 8);
      for (int i = 0; i < courseTimeFromApi.length; i++) {
        if (i == 10) {
          tempcourseEndTime += '0';
        } else if (i > 10) {
          tempcourseEndTime += courseTimeFromApi[i];
        }
      }
      courseEndTime = tempcourseEndTime;
    } else if (courseTimeFromApi[2].toString() != ':') {
      String tempcourseStartTime = '';
      String tempcourseEndTime = '';

      for (int i = 0; i < courseTimeFromApi.length; i++) {
        if (i == 0) {
          tempcourseStartTime = '0';
        } else if (i > 0 && i < 8) {
          tempcourseStartTime += courseTimeFromApi[i - 1];
        } else if (i > 9) {
          tempcourseEndTime += courseTimeFromApi[i];
        }
      }
      courseStartTime = tempcourseStartTime;
      courseEndTime = tempcourseEndTime;
      if (courseEndTime[2].toString() != ':') {
        String tempcourseEndTime = '';
        for (int i = 0; i <= courseEndTime.length; i++) {
          if (i == 0) {
            tempcourseEndTime += '0';
          } else {
            tempcourseEndTime += courseEndTime[i - 1];
          }
        }
        courseEndTime = tempcourseEndTime;
      }
    } else {
      courseStartTime = courseTimeFromApi.substring(0, 8);
      courseEndTime = courseTimeFromApi.substring(11, 19);
    }
    DateTime startTime = DateFormat.jm().parse(courseStartTime);
    DateTime endTime = DateFormat.jm().parse(courseEndTime);

    String startingTime = DateFormat("HH:mm:ss").format(startTime);
    String endingTime = DateFormat("HH:mm:ss").format(endTime);
    String startDateAndTime = "$startDateFormattedToString $startingTime";
    String endDateAndTime = "$endDateFormattedToString $endingTime";
    DateTime finalStartDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
    DateTime finalEndDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);

    ///from here
    DateTime todaysDate = DateFormat("yyyy-MM-dd").parse(DateTime.now().toString());
    String formattedTodaysDate = formatter.format(todaysDate);
    String startTimeWithTodaysDateString = "$formattedTodaysDate $startingTime";
    String endTimeWithTodaysDateString = "$formattedTodaysDate $endingTime";
    DateTime TodaysDateWithStartTime = DateFormat("yyyy-MM-dd HH:mm:ss")
        .parse(startTimeWithTodaysDateString)
        .subtract(const Duration(minutes: 0));
    DateTime TodaysDateWithEndTime =
        DateFormat("yyyy-MM-dd HH:mm:ss").parse(endTimeWithTodaysDateString);

    ///till here

    DateTime startTimeOnly = DateFormat("HH:mm:ss").parse(startingTime);
    DateTime endTimeOnly = DateFormat("HH:mm:ss").parse(endingTime);
    DateTime classStartingTime = DateTime.parse(startDateAndTime);

    differenceInTime = endTime.difference(startTime).inMinutes;

    differenceInDays = endDate.difference(startDate).inDays;
    // print(currentDateTime.hour);
    // print(startTime.hour);
    // print(endTime.hour);

    DateTime fiveMinutesBeforeStartTime = finalStartDateTime.subtract(const Duration(minutes: 5));
    DateTime minutesAfterStartTime = classStartingTime.add(Duration(minutes: differenceInTime));

    // print('is before${currentDateTime.isBefore(finalEndDateTime)}');
    // print('is After 0${currentDateTime.isAfter(fiveMinutesBeforeStartTime)}');
    // print('is After 1${currentDateTime.isAfter(fiveMinutesBeforeStartTime)}');
    // print('is After 2${currentDateTime.isAfter(TodaysDateWithStartTime)} $TodaysDateWithStartTime');
    // print('is before 2${currentDateTime.isBefore(TodaysDateWithEndTime)}');

    if ((currentDateTime.isBefore(finalEndDateTime) &&
            currentDateTime.isAfter(fiveMinutesBeforeStartTime)) &&
        (
            // currentDateTime.isAfter(TodaysDateWithStartTime) &&
            currentDateTime.isBefore(TodaysDateWithEndTime)) &&
        (trainerStatus == "Online" || trainerStatus == "Busy") &&
        (
            // courseType.toLowerCase() == "daily" ||
            (courseOn.contains("Monday") ||
                courseOn.contains("Tuesday") ||
                courseOn.contains("Wednesday") ||
                courseOn.contains("Thursday") ||
                courseOn.contains("Friday") ||
                courseOn.contains("Saturday") ||
                courseOn.contains("Sunday")))) {
      enableJoinCall = true;
      // print(enableJoinCall.toString() + "kkk");
      return enableJoinCall;
    } else {
      enableJoinCall = false;
      return enableJoinCall;
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  trainerStatusFromFirebase(s, id) async {
    //003a17e3ba6549789606885463eed4a5
    final DocumentReference<Map<String, dynamic>> userDoc =
        FireStoreCollections.consultantOnlineStatus.doc(id);
    subscription = userDoc.snapshots().listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        // print(snapshot.data()['status']);
        final trainerBloc = contextForJoincall.read<TrainerBloc>();
        trainerBloc
            .add(ListenTrainerStatusEvent(snapshot.data()['status'] == 'Online' ? true : false));
      }
    });
  }
}
