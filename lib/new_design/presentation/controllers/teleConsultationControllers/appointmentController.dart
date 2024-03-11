import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Getx/controller/listOfChallengeContoller.dart';
import '../../../../constants/api.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../pages/spalshScreen/splashScreen.dart';

class MyAppointmentController extends GetxController {
  final ListChallengeController listChallengeController = Get.put(ListChallengeController());
  List selectedList = [];
  bool switchLoading = false;
  ScrollController controller = ScrollController();
  var filterType = 'Requested';
  bool isLoading = true;
  List<String> sharedReportAppIdList = [];
  String _ihlUserId;
  getSharedAppIdList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedReportAppIdList = prefs.getStringList('sharedReportAppIdList') ?? [];
  }

  addItems() async {
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.position.pixels) {
        fetch();
      }
    });
  }

  fetch() async {
    List _l = await upComingAppointments(pageIndex: selectedList.length, filterType: filterType);
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
    selectedList = await upComingAppointments(pageIndex: 0, filterType: filterType);
    addItems();
    super.onInit();
  }

  Future<List> upComingAppointments({
    filterType,
    int pageIndex,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ihlUserId = prefs.getString("ihlUserId");
    List _l = [];

    var startIndex = pageIndex;
    var endIndex = pageIndex + 5;
    var _upComingAppointmentRes = await Dio().post(
      API.iHLUrl + "/consult/get_user_appointment_status_pagination",
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
        "appointment_status": filterType
      },
    );

    if (_upComingAppointmentRes.statusCode == 200) {
      List approvedAppointments = _upComingAppointmentRes.data['Appointments'];

      var currentDateTime = new DateTime.now();

      for (int i = 0; i < approvedAppointments.length; i++) {
        var endTime = approvedAppointments[i]["appointment_end_time"];
        String appointmentEndTime = endTime;
        if (appointmentEndTime[7] != '-') {
          String appEndTime = '';
          for (var i = 0; i < appointmentEndTime.length; i++) {
            if (i == 5) {
              appEndTime += '0' + appointmentEndTime[i];
            } else {
              appEndTime += appointmentEndTime[i];
            }
          }
          appointmentEndTime = appEndTime;
        }
        if (appointmentEndTime[10] != " ") {
          String appEndTime = '';
          for (var i = 0; i < appointmentEndTime.length; i++) {
            if (i == 8) {
              appEndTime += '0' + appointmentEndTime[i];
            } else {
              appEndTime += appointmentEndTime[i];
            }
          }
          appointmentEndTime = appEndTime;
        }
        DateTime appointmentendTime =
            DateFormat('yyyy-MM-dd HH:mm a').parse(approvedAppointments[i]["appointment_end_time"]);
        String appointmentEndTimeSubstring = DateFormat('hh:mm a').format(appointmentendTime);
        String appointmentEndDateSubstring = DateFormat('yyyy-MM-dd').format(appointmentendTime);
        DateTime endTimeFormatTime = DateFormat.jm().parse(appointmentEndTimeSubstring);
        String endTimeString = DateFormat("HH:mm:ss").format(endTimeFormatTime);
        String fullAppointmentEndDate = appointmentEndDateSubstring + " " + endTimeString;
        var appointmentEndingTime = DateTime.parse(fullAppointmentEndDate);

        // if (appointmentEndingTime.isAfter(currentDateTime)) {
        _l.add(approvedAppointments[i]);
        // }
      }

      List<DateTime> formattedTime = [];
      List<String> stringFormattedDateTime = [];
      for (int i = 0; i < _l.length; i++) {
        String date = _l[i]["appointment_start_time"];
        if (date[7] != '-') {
          String appStartTime = '';
          for (var i = 0; i < date.length; i++) {
            if (i == 5) {
              appStartTime += '0' + date[i];
            } else {
              appStartTime += date[i];
            }
          }
          date = appStartTime;
        }
        if (date[10] != " ") {
          String appStartTime = '';
          for (var i = 0; i < date.length; i++) {
            if (i == 8) {
              appStartTime += '0' + date[i];
            } else {
              appStartTime += date[i];
            }
          }
          date = appStartTime;
        }
        String stringTime = date.substring(11, 19);
        date = date.substring(0, 10);
        DateTime formattime = DateFormat.jm().parse(stringTime);
        String time = DateFormat("HH:mm:ss").format(formattime);
        String dateToFormat = date + " " + time;
        var newTime = DateTime.parse(dateToFormat);
        formattedTime.add(newTime);
      }
      formattedTime.sort((a, b) => a.compareTo(b));
      List appointmentDetails = [];
      List temp = [];
      sort(List subscriptionsDetails) {
        if (subscriptionsDetails == null || subscriptionsDetails.length == 0) return;
        for (int i = 0; i < subscriptionsDetails.length; i++) {
          String stringFormattedTime = DateFormat("yyyy-MM-dd hh:mm aaa").format(formattedTime[i]);
          stringFormattedDateTime.add(stringFormattedTime);
          temp.add(subscriptionsDetails[i]["appointment_start_time"]);
        }
        for (int i = 0; i < stringFormattedDateTime.length; i++) {
          if (temp.contains(stringFormattedDateTime[i])) {
            //if two appoinmnets of same day and time then issue comes in ordering
            //int ii = temp.indexOf(stringFormattedDateTime[i]);
            appointmentDetails.add(subscriptionsDetails[i]);
          }
        }
      }

// _l = appointmentDetails;// Removed Expiry Appointments
      sort(_l);
      isLoading = false;
      update(['appointmentLoading', 'listupdated']);
      return _l;
    } else {
      return _l;
    }
  }

  updateList() async {
    switchLoading = true;
    update(["listupdated"]);
    selectedList = await upComingAppointments(pageIndex: 0, filterType: filterType);
    switchLoading = false;
    update(["listupdated",]);
  }
}
