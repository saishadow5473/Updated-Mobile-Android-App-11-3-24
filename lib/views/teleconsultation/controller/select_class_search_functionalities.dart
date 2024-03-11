import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/api.dart';
import '../../../constants/spKeys.dart';

class SelectClassSearch {
  static List getSuggestion({String pattern, List classes}) {
    List filterClasees = [];
    for (var i in classes) {
      bool isClass = false;
      if (i.containsKey("course_id")) {
        isClass = true;
      } else {
        isClass = false;
      }
      if (i["title"].toString().toLowerCase().contains(pattern.trim().toLowerCase())) {
        if (isClass) {
          if (SelectClassSearch().validClassOrNot(map: i)) {
            filterClasees.add(i);
          }
        } else {
          filterClasees.add(i);
        }
      }
      ;
    }
    filterClasees.map((e) async {
      if (e["course_img_url"] == null || e["course_img_url"] == "") {
        e["course_img_url"] =
            await SelectClassSearch().getCourseImageURL(course_id: e["course_id"]);
      }
    });
    return filterClasees;
  }

  bool validClassOrNot({Map map}) {
    var currentdate = DateTime.now();
    var currentDateTime = new DateTime.now();
    var courseDuration = map["course_duration"];
    String courseEndDuration = courseDuration.substring(13, 23);
    int lastIndexValue = map["course_time"].length - 1;
    String courseEndTimeFullValue = map["course_time"][lastIndexValue]; //02:00 PM - 07:00 PM
    String courseEndTime = courseEndTimeFullValue.substring(
        courseEndTimeFullValue.indexOf("-") + 1, courseEndTimeFullValue.length); //07:00 PM
    courseEndDuration = courseEndDuration + courseEndTime; //20-04-2022 07:00 PM
    // DateTime endDate =
    //     new DateFormat("dd-MM-yyyy hh:mm a").parse(courseEndDuration);
    String courseStartDuration = courseDuration.substring(0, 10);
    DateTime startDate = new DateFormat("dd-MM-yyyy").parse(courseStartDuration);
    DateTime endDate;
    if (courseEndTime != " Invalid DateTime") {
      endDate = new DateFormat("dd-MM-yyyy hh:mm a").parse(courseEndDuration);
    } else {
      endDate = DateTime.now().subtract(Duration(days: 365));
    }
    if (startDate.day == currentdate.day &&
        endDate.day == currentdate.day &&
        endDate.isAfter(currentDateTime)) {
      return true;
    } else if (endDate.isBefore(currentDateTime)) {
      return false;
    } else {
      return true;
    }
  }

  allCourseList({List list}) {
    print(list.toString());
    List classes = [];
    for (int i = 0; i < list.length; i++)
      for (var e in list[i]["courses"]) {
        classes.add(e);
      }
    // classes.removeWhere((map) => SelectClassSearch().validClassOrNot(map: map));
    classes.removeWhere((map) => map["exclusive_only"] == true);
    return classes;
  }

  Future getCourseImageURL({String course_id}) async {
    final response = await post(
      Uri.parse(API.iHLUrl + "/consult/courses_image_fetch"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, dynamic>{
        'classIDList': [course_id],
      }),
    );
    if (response.statusCode == 200) {
      List imageOutput = json.decode(response.body);
      List courseIDAndImage = imageOutput;
      for (var i = 0; i < courseIDAndImage.length; i++) {
        if (course_id == courseIDAndImage[i]['course_id']) {
          String base64Image = courseIDAndImage[i]['base_64'].toString();
          base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
          base64Image = base64Image.replaceAll('}', '');
          base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');

          String courseImage = base64Image;
          return courseImage;
        }
      }
    } else {
      print(response.body);
    }
  }

  subscriptionChecker({Map map}) async {
    var datas = map;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);
    Map teleConsulResponse = json.decode(data);
    if (teleConsulResponse['my_subscriptions'] == null ||
        !(teleConsulResponse['my_subscriptions'] is List) ||
        teleConsulResponse['my_subscriptions'].isEmpty) {}
    // if (this.mounted) {
    //   setState(() {
    var subscriptions = teleConsulResponse['my_subscriptions'];

    //   });
    // }

    for (int i = 0; i < subscriptions.length; i++) {
      var subscriptionID = subscriptions[i]["course_id"];
      var status = subscriptions[i]["approval_status"];

      if (subscriptionID == datas["course_id"] && status == "Accepted" || status == "Approved") {
        print(status);
        print(subscriptionID);
        datas["subscribed"] = "true";
      } else if ((subscriptionID == datas["course_id"]) &&
          (status == "requested" || status == "Requested")) {
        // makeCourseRequested = true;
        datas["subscribed"] = "process";
      }
    }
    if (datas["subscribed"] != "process" && datas["subscribed"] != "true") {
      datas["subscribed"] = "false";
    }
    return datas;
  }

  //for consultation Image base64🚩
  getConsultantAllAppointmentForToday(map) async {
    String consultantImage;
    String image;
    try {
      var bodyGenix = jsonEncode(<String, dynamic>{
        'vendorIdList': [map[0]],
        "consultantIdList": [""],
      });
      var bodyIhl = jsonEncode(<String, dynamic>{
        'consultantIdList': [map[0]],
        "vendorIdList": [""],
      });
      final response = await post(Uri.parse(API.iHLUrl + "/consult/profile_image_fetch"),
          body: map[1] == 'GENIX' ? bodyGenix : bodyIhl);
      if (response.statusCode == 200) {
        var imageOutput = json.decode(response.body);
        // var consultantIDAndImage = imageOutput["ihlbase64list"];
        var consultantIDAndImage =
            map[1] == 'GENIX' ? imageOutput["genixbase64list"] : imageOutput["ihlbase64list"];
        for (var i = 0; i < consultantIDAndImage.length; i++) {
          var chk_id = map[0];
          if (chk_id == consultantIDAndImage[i]['consultant_ihl_id']) {
            String base64Image = consultantIDAndImage[i]['base_64'].toString();
            base64Image = base64Image
                .replaceAll('data:image/jpeg;base64,', '')
                .replaceAll('}', '')
                .replaceAll('data:image/jpegbase64,', '');

            consultantImage = base64Image;

            if (consultantImage == null || consultantImage == "") {
              image = AvatarImage.defaultUrl;
              // image = Image.memory(base64Decode(widget.consultant['profile_picture']));
            } else {
              // widget.consultant['profile_picture'] = consultantImage;
              image = consultantImage;
            }
          }
        }
        return image;
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e.toString());
      return AvatarImage.defaultUrl;
      // widget.consultant['profile_picture'] = AvatarImage.defaultUrl;
      // image = Image.memory(base64Decode(widget.consultant['profile_picture']));
    }
  }
}
