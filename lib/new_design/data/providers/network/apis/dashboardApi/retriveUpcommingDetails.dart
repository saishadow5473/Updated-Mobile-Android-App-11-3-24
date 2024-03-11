import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/Getx/controller/listOfChallengeContoller.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/new_design/presentation/controllers/dashboardControllers/upComingDetailsController.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../constants/spKeys.dart';
import '../../../../../../health_challenge/controllers/challenge_api.dart';
import '../../../../../../health_challenge/models/challenge_detail.dart';
import '../../../../../../health_challenge/models/list_of_users_in_group.dart';
import '../../../../../presentation/controllers/teleconsultation_onlineServices/teleconsultation_apiCalls.dart';
import '../../../../model/retriveUpcomingDetails/upcomingDetailsModel.dart';
import '../../api_end_points.dart';
import '../../api_provider.dart';
import '../../networks.dart';
import 'package:ihl/constants/api.dart' as oldAPI;

class RetriveDetials {
  upcomingDetails({
    List affilist,
    @required bool fromChallenge,
  }) async {
    // var userID = localSotrage.read(LSKeys.ihlUserId);
    fromChallenge = fromChallenge ?? false;
    String userID = SpUtil.getString(LSKeys.ihlUserId);
    ListChallengeController _listChallengeController = Get.put(ListChallengeController());
    List li = (affilist == null ||
            affilist.isEmpty ||
            affilist.contains(null) ||
            affilist.contains("Global"))
        ? []
        : affilist;
    try {
      dynamic data = await TeleConsultationApiCalls.upcomingDetailAPI(userID: userID, li: li);

      if (data != null) {
        if (data['Appointment_list'].isNotEmpty) {
          CheckExpiredAppointments().checkApi(data['Appointment_list'][0]['appointment_end_time']);
        }
      }

      UpcomingDetails upcomingDetails = UpcomingDetails.fromJson(data);
      upcomingDetails.appointmentList
          .removeWhere((element) => element.appointmentEndTime.isBefore(DateTime.now()));
      List<EnrolledChallenge> tempList = upcomingDetails.enrolChallengeList;
      if (upcomingDetails.enrolChallengeList.isNotEmpty) {
        tempList.removeWhere((EnrolledChallenge element) =>
            element.userProgress == "completed" || element.groupProgress == "completed");
        tempList.removeWhere((element) => element.userStatus != "active");
        tempList.removeWhere((element) => element.challengeType != 'Step Challenge');
      }
      upcomingDetails.enrolChallengeList = tempList;
      try {
        var _list = SpUtil.getObjectList('enrollList') ?? [];
        if (_list != upcomingDetails.enrolChallengeList) {
          SpUtil.putObjectList('enrollList', upcomingDetails.enrolChallengeList);
        }
        Get.find<UpcomingDetailsController>().upComingDetails = upcomingDetails;
        if (fromChallenge) {
          Get.find<UpcomingDetailsController>().update(['user_enroll_challenge']);
        } else {
          Get.find<UpcomingDetailsController>()
              .update(['user_upcoming_detils', 'user_enroll_challenge']);
        }
      } catch (e) {
        Get.put(UpcomingDetailsController()).upComingDetails = upcomingDetails;
        if (fromChallenge) {
          Get.put(UpcomingDetailsController()).update(['user_enroll_challenge']);
        } else {
          Get.put(UpcomingDetailsController())
              .update(['user_upcoming_detils', 'user_enroll_challenge']);
        }
      }
      var _list = SpUtil.getObjectList('enrollList') ?? [];
      if (_list != upcomingDetails.enrolChallengeList) {
        SpUtil.putObjectList('enrollList', upcomingDetails.enrolChallengeList);
      }
      return upcomingDetails;
    } on DioError catch (error) {
      throw NetworkCallsCardio.checkAndThrowError(error.type);
    }
  }

  getPlatformDatas() async {
    // var userID = localSotrage.read(LSKeys.ihlUserId);
    String userID = SpUtil.getString(LSKeys.ihlUserId);
    try {
      var response = await dio.post("${API.iHLUrl}/consult/GetPlatfromData",
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
          ),
          data: {'ihl_id': userID, 'cache': "true"});

      if (response.statusCode == 200 && response.data != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(SPKeys.platformData, jsonEncode(response.data));
        return response.data;
      }
    } on DioError catch (e) {
      throw NetworkCallsCardio.checkAndThrowError(e.type);
    }
  }

  Future<String> getConsultantImageURL({Map doctor}) async {
    if (doctor['profile_picture'] == null) {
      List map = doctor['vendor_id'] == "GENIX"
          ? [doctor['vendor_consultant_id'], doctor['vendor_id']]
          : [doctor['ihl_consultant_id'], doctor['vendor_id']];
      String bodyGenix = jsonEncode(<String, dynamic>{
        'vendorIdList': [map[0]],
        "consultantIdList": [""],
      });
      String bodyIhl = jsonEncode(<String, dynamic>{
        'consultantIdList': [map[0]],
        "vendorIdList": [""],
      });
      var response = await dio.post(
        "${API.iHLUrl}/consult/profile_image_fetch",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: map[1] == "GENIX" ? bodyGenix : bodyIhl,
      );
      if (response.statusCode == 200) {
        var imageOutput = response.data;
        var consultantImage, base64Image;
        var consultantIDAndImage =
            map[1] == 'GENIX' ? imageOutput["genixbase64list"] : imageOutput["ihlbase64list"];
        for (int i = 0; i < consultantIDAndImage.length; i++) {
          // if (doctor['ihl_consultant_id'] ==
          if (map[0] == consultantIDAndImage[i]['consultant_ihl_id']) {
            base64Image = consultantIDAndImage[i]['base_64'].toString();
            base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
            base64Image = base64Image.replaceAll('}', '');
            base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');

            consultantImage = base64Image;
            if (consultantImage == null || consultantImage == "") {
              doctor['profile_picture'] = AvatarImage.defaultUrl;
            } else {
              doctor['profile_picture'] = consultantImage;
            }
          }
        }
        return doctor["profile_picture"];
      } else {
        return AvatarImage.defaultUrl;
      }
    }
    return AvatarImage.defaultUrl;
  }

  Future<String> getCourseImageURL({SubcriptionList subcriptionList}) async {
    var response = await dio.post(
      "${API.iHLUrl}/consult/courses_image_fetch",
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${oldAPI.API.headerr['ApiToken']}',
          'Token': '${oldAPI.API.headerr['Token']}',
        },
      ),
      data: jsonEncode(<String, dynamic>{
        "classIDList": subcriptionList.courseId,
      }),
    );
    if (response.statusCode == 200) {
      List imageOutput = response.data;
      List courseIDAndImage = imageOutput;
      for (int i = 0; i < courseIDAndImage.length; i++) {
        if (subcriptionList.courseId == courseIDAndImage[i]['course_id']) {
          String courseImage = courseIDAndImage[i]['base_64'].toString();
          courseImage = courseImage.replaceAll('data:image/jpeg;base64,', '');
          courseImage = courseImage.replaceAll('}', '');
          courseImage = courseImage.replaceAll('data:image/jpegbase64,', '');

          return courseImage;
        }
      }
    } else {
      print(response.data);
    }
  }
}

class CheckExpiredAppointments {
  static bool isExpired = false;
  void checkApi(String endTime) {
    DateTime end = DateFormat("yyyy-MM-dd hh:mm a").parse(endTime);
    DateTime now = DateTime.now();
    if (now.isAfter(end)) {
      isExpired = true;
    }
  }
}
