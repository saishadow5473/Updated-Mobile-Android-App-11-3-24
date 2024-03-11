import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../new_design/data/providers/network/api_provider.dart';

import '../../../../new_design/module/online_serivices/data/model/get_spec_class_list.dart';
import '../../../../new_design/module/online_serivices/data/model/get_subscribtion_list.dart';
import '../../../../new_design/module/online_serivices/functionalities/online_services_dashboard_functionalities.dart';
import '../model/getClassSpecalityModel.dart';
import 'package:http/http.dart' as http;

class OnlineClassApiCall {
  http.Client _client = http.Client();
  static Dio dio = Dio();
  OnlineServicesFunctions onlineSerivicesFunction = OnlineServicesFunctions();
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
          "end_index": endIndex ?? 8 //mandatory
        }),
      );
      if (_res.statusCode == 200) {
        return getClassSpecialityFromJson(_res.body);
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      print(e);
    }
  }

  static Future class_specialty_name({String query, String specList}) async {
    var response = await dio.post('${API.iHLUrl}/platformservice/class_specialty_name', data: {
      "source": "",
      "speciality_list": ['$specList'],
      "start_index": 1, //mandatory
      "end_index": 5
    });
    try {
      if (response.statusCode == 200) {
        print("success");
      }
      return response.data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  getSubcriptionsDetails() async {
    var response = await dio.post(
      "",
      data: json.encode({}),
      options: Options(
        headers: {},
      ),
    );
  }

  Future<List> getSubscriptionHistory({int endPage, String filterType}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _ihlUserId = prefs.getString("ihlUserId");
    // List<Subscription> _l = [];

    var startIndex = 0;
    var endIndex = endPage + 15;
    // var _res = await Dio().post(
    //   "${API.iHLUrl}/consult/view_all_subcription_pagination",
    //   options: Options(
    //     headers: {
    //       'Content-Type': 'application/json',
    //       'ApiToken': '${API.headerr['ApiToken']}',
    //       'Token': '${API.headerr['Token']}',
    //     },
    //   ),
    //   data: {
    //     'user_ihl_id': _ihlUserId,
    //     "start_index": startIndex,
    //     "end_index": endIndex,
    //     "approval_status": filterType
    //   },
    // );
    var response = await _client.post(
      Uri.parse(
        "${API.iHLUrl}/consult/view_all_subcription_pagination",
      ),
      body: json.encode(
        {
          'user_ihl_id': _ihlUserId,
          "start_index": startIndex,
          "end_index": endIndex,
          "approval_status": filterType
        },
      ),
    );
    List _list;
    if (response.statusCode == 200) {
      GetSubscriptionList subList = getSubscriptionListFromJson(response.body);
      List<Subscription> filtredClassList =
          onlineSerivicesFunction.filterExpiredSubscriptionClass(subList);
      filtredClassList.removeWhere((Subscription element) =>
          element.title == " " || element.courseTime == "" || element.courseTime == "null");
      // if (_res.data['subscriptions'] != null) {
      //   _list = _res.data['subscriptions'];
      // } else {
      //   _list = _res.data['appts_subscriptions'];
      // }
      //   if (subList.subscriptions != null) {
      //     _list = subList.subscriptions;
      //   } else {}
      //
      //   _list.removeWhere((Subscription element) => element.classDetail.isBlank);
      //   _list.removeWhere((Subscription element) => element.courseTime == '');
      //
      //   _l = _list;
      // }
      _list = filtredClassList;
    }

    try {
      if (filterType == "Accepted") {
        return removeDyplicateInClass(list: _list);
      } else {
        return _list;
      }
    } catch (e) {
      return _list;
    }
  }

  List<Subscription> removeDyplicateInClass({List<Subscription> list}) {
    Set<String> uniqueValues = Set<String>();
    List<Subscription> result = <Subscription>[];

    for (var map in list) {
      if (uniqueValues.add(map.courseId.toString() + map.courseTime.toString())) {
        result.add(map);
      }
    }

    return result;
  }

  Future<List> getSubscriptionCompletedHistory({int endPage}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _ihlUserId = prefs.getString("ihlUserId");
    // List<Subscription> _l = [];

    var startIndex = 0;
    var endIndex = endPage + 15;
    // var _res = await Dio().post(
    //   "${API.iHLUrl}/consult/view_all_subcription_pagination",
    //   options: Options(
    //     headers: {
    //       'Content-Type': 'application/json',
    //       'ApiToken': '${API.headerr['ApiToken']}',
    //       'Token': '${API.headerr['Token']}',
    //     },
    //   ),
    //   data: {
    //     'user_ihl_id': _ihlUserId,
    //     "start_index": startIndex,
    //     "end_index": endIndex,
    //     "approval_status": filterType
    //   },
    // );
    var response = await _client.post(
      Uri.parse(
        "${API.iHLUrl}/consult/view_all_subcription_pagination",
      ),
      body: json.encode(
        {
          'user_ihl_id': _ihlUserId,
          "start_index": startIndex,
          "end_index": endIndex,
          "approval_status": "Accepted"
        },
      ),
    );
    List _list;
    if (response.statusCode == 200) {
      GetSubscriptionList subList = getSubscriptionListFromJson(response.body);
      List<Subscription> filtredClassList = onlineSerivicesFunction.getExpeiredClass(subList);
      filtredClassList.removeWhere((Subscription element) =>
          element.title == " " || element.courseTime == "" || element.courseTime == "null");

      _list = filtredClassList;
    }
    return _list;
  }
}
