import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../constants/api.dart';
import '../../../../../constants/spKeys.dart';
import '../model/get_appointment_list_module.dart';
import '../model/get_consultant_list.dart';
import '../model/get_course_detail.dart';
import '../model/get_spec_class_list.dart';
import '../model/get_specality_module.dart';
import '../model/get_subscribtion_list.dart';

class OnlineServicesApiCall {
  http.Client _client = http.Client();
  static Dio dio = Dio();

  getOnlineClassSpecality(List<dynamic> affiliationList, int endIndex) async {
    try {
      var _res = await _client.post(
        Uri.parse(
          "${API.iHLUrl}/platformservice/class_affiliation",
        ),
        body: json.encode({
          "source": "",
          "affilation_list": affiliationList ?? [],
          "start_index": 1, //mandatory
          "end_index": endIndex ?? 12 //mandatory
        }),
      );
      if (_res.statusCode == 200) {
        String filterResponse = _res.body.replaceAll("&amp;", "&");
        return getOnlineServicesSpecialityFromJson(filterResponse);
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      print(e);
    }
  }

  updateUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _ihlUserId = prefs.getString("ihlUserId");
    final getUserDetails = await _client.post(
      Uri.parse("${API.iHLUrl}//consult/get_user_details"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, dynamic>{
        'ihl_id': _ihlUserId,
      }),
    );
    if (getUserDetails.statusCode == 200) {
      final userDetailsResponse = await SharedPreferences.getInstance();
      userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
    }
  }

  getConsultantSpecality(List<dynamic> affiliationList, int endIndex) async {
    try {
      var _res = await _client.post(
        Uri.parse(
          "${API.iHLUrl}/platformservice/medical_health_consultants_speciality",
        ),
        body: json.encode({
          "source": "",
          "affilation_list": affiliationList ?? [],
          "start_index": 1, //mandatory
          "end_index": endIndex ?? 50 //mandatory
        }),
      );
      if (_res.statusCode == 200) {
        try {
          return getOnlineServicesSpecialityFromJson(_res.body);
        } catch (e) {
          print(e);
          return getOnlineServicesSpecialityFromJson("");
        }
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      print(e);
    }
  }

  getConsultantList(List<dynamic> specList, int endIndex) async {
    try {
      var _res = await _client.post(
        Uri.parse(
          "${API.iHLUrl}/platformservice/doctor_consultant_specialty_name",
        ),
        body: json.encode({
          "speciality_list": specList ?? [],
          "start_index": 1, //mandatory
          "end_index": endIndex ?? 25 //mandatory
        }),
      );
      if (_res.statusCode == 200) {
        return jsonDecode(_res.body);
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      print(e);
      if (e is SocketException) {
        // handle network error
        print("No internet connection");
      } else {
        // handle other errors
        print("Something went wrong");
      }
      return getConsultantListFromJson("");
    }
  }

  getAppointmentList({String appointmentStatus, int endIndex}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _ihlUserId = prefs.getString("ihlUserId");

    try {
      var _res = await _client.post(
        Uri.parse(
          "${API.iHLUrl}/consult/get_user_appointment_status_pagination",
        ),
        body: json.encode({
          "user_ihl_id": _ihlUserId,
          "start_index": 0, //mandatory
          "end_index": endIndex ?? 8, //mandatory,
          "appointment_status": appointmentStatus
        }),
      );
      if (_res.statusCode == 200) {
        return getAppointmentListFromJson(_res.body);
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      print(e);
      if (e is SocketException) {
        // handle network error
        print("No internet connection");
      } else {
        // handle other errors
        print("Something went wrong");
      }
      return getConsultantListFromJson("");
    }
  }

  getSubscriptionList(String subscriptionStatus, int endIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _ihlUserId = prefs.getString("ihlUserId");
    try {
      endIndex = endIndex ?? 20;
      print(endIndex);
      var data = json.encode({
        "user_ihl_id": _ihlUserId,
        "start_index": 1, //mandatory
        "end_index": endIndex ?? 25, //mandatory,
        "approval_status": subscriptionStatus
      });
      print(data);
      var _res = await _client.post(
        Uri.parse(
          "${API.iHLUrl}/consult/view_all_subcription_pagination",
        ),
        body: data,
      );
      if (_res.statusCode == 200) {
        return getSubscriptionListFromJson(_res.body);
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      print(e);
      if (e is SocketException) {
        // handle network error
        print("No internet connection");
      } else {
        // handle other errors
        print("Something went wrong");
      }
      return getConsultantListFromJson(null);
    }
  }

  getSpecClassList({int endIndex, int startIndex,String query, String spec}) async {
    try {
      var response = await _client.post(
        Uri.parse(
          "${API.iHLUrl}/platformservice/class_specialty_name",
        ),
        body: json.encode({
          "source": "",
          "speciality_list": spec!=""?[spec]:[],
          "start_index": 1, // mandatory
          "end_index": 120
        }),
      );

      if (response.statusCode == 200) {
        return getSpecClassListFromJson(response.body);
      } else {
        // Handle other HTTP status codes
        print("HTTP Error: ${response.statusCode}");
        // You might want to throw an exception or return a specific error response here.
        return getSpecClassListFromJson("");
      }
    } catch (e) {
      // Handle other types of errors, such as network errors or parsing errors
      print("Error: $e");
      // You might want to throw an exception or return a specific error response here.
      return getSpecClassListFromJson("");
    }
  }

  Future<GetCourseDetail> getCourseDetail({@required String courseId}) async {
    try {
      final http.Response response = await _client.get(
        Uri.parse("${API.iHLUrl}/consult/getClassDetail?classId=$courseId"),
      );

      if (response.statusCode == 200) {
        // Successful response
        GetCourseDetail courseDetail = getCourseDetailFromJson(response.body);
        return courseDetail;
      } else {
        // Handle non-200 status codes
        print("Error: ${response.statusCode}, ${response.body}");
        // You can throw an exception or return an error object here
        throw Exception("Failed to get course detail");
      }
    } catch (e) {
      // Handle other types of exceptions (network errors, timeouts, etc.)
      print("Error: $e");
      // You can throw an exception or return an error object here
      throw Exception("Failed to get course detail");
    }
  }
}
