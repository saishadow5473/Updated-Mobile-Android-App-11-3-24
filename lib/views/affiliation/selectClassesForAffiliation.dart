import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/affiliation/selectClassCardForAffiliation.dart';
import 'package:ihl/views/affiliation/selectConsultantForAffiliation.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
bool clickLoading = false;
class SelectClassesForAffiliation extends StatefulWidget {
  String companyName;
  Map arg;bool navigateToDashBoard;

  SelectClassesForAffiliation({this.arg, this.companyName,this.navigateToDashBoard});

  @override
  _SelectClassesForAffiliationState createState() => _SelectClassesForAffiliationState();
}

class _SelectClassesForAffiliationState extends State<SelectClassesForAffiliation> {
  List results = [];
  var affCourses = [];
bool navi=false;
  @override
  void initState() {
    super.initState();
    // filterCoursesForAffiliation();
    if(widget.navigateToDashBoard??false){
      asyncfun();
    }
    results ??= [];
    getUserDetails();
    for (int i = 0; i < results.length; i++) {
      courseID.add(results[i]['course_id'].toString());
    }
  }
asyncfun()async{
    navi=true;
 if(mounted) setState(() {

  });
    await func();

  }
  var courseID = [];
  var courseIDAndImage = [];
  var base64Image;
  var courseImage;
  bool hasSubscription = false;
  bool makeCourseSubscribed = false;
  List subscriptions = [];
  bool affiliateActiveClassAvailable = false;
  var affCurrentDateTim = DateTime.now();
  http.Client _client = http.Client(); //3gb
  // bool noClassIsActive = true;
  func() async {
    // Future getDataDiagnostic(var companyName, var specalityType, var consultation_type_name) async {
      ///"specality_name" -> "Corporate Wellness"
      // if (mounted) {
      //   setState(() {
      //     clickLoading = true;
      //   });
      // }
      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      var data1 = prefs1.get('data');
      Map res1 = jsonDecode(data1);
      var iHLUserId = res1['User']['id'];

      final getPlatformData = await _client.post(
        Uri.parse(API.iHLUrl + "/consult/GetPlatfromData"),
        body: jsonEncode(<String, String>{'ihl_id': iHLUserId, 'cache': "true"}),
      );
      if (getPlatformData.statusCode == 200) {
        if (getPlatformData.body != null) {
          Map res = jsonDecode(getPlatformData.body);
          final platformData = await SharedPreferences.getInstance();
          platformData.setString(SPKeys.platformData, getPlatformData.body);
          if (res['consult_type'] == null ||
              !(res['consult_type'] is List) ||
              res['consult_type'].isEmpty) {
            return;
          }
          var consultationType = res['consult_type'];
          String consultation_type_name="Fitness Class";
          for (int i = 0; i < consultationType.length; i++) {
            if (consultationType[i]["consultation_type_name"] == "$consultation_type_name") {
              // "Health Consultation") {
              for (int j = 0; j < consultationType[i]["specality"].length; j++) {
                // "Fitness Class":"Health Consultation")
                if (consultationType[i]["specality"][j]["specality_name"].replaceAll('amp;', '') == "Events & Programs") {
                  // if (mounted) {
                  //   setState(() {
                  //     clickLoading = false;
                  //   });
                  // }
                  // if (consultation_type_name == "Health Consultation") {
                  // //   Navigator.push(
                  // //       context,
                  // //       MaterialPageRoute(
                  // //           builder: (context) => SelectConsultantForAffiliation(
                  // //             companyName: companyName,
                  // //             arg: consultationType[i]["specality"][j],
                  // //             liveCall: true,gotohomescreen:true ,)));
                  // }
                  // else
                    if (consultation_type_name == "Fitness Class") {
                      widget.arg=consultationType[i]["specality"][j];
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => SelectClassesForAffiliation(
                  //         companyName: companyName,
                  //         arg: consultationType[i]["specality"][j],navigateToDashBoard: true,
                  //       ),
                  //     ),
                  //   );
                  }
                  break;
                }
              }
            }
          }
          // if (mounted) {
          //   setState(() {
          //     clickLoading = false;
          //     print('after loop end , no result found');
          //   });
          // }
        }
      }
    // }

  }

  Future getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);
    Map teleConsulResponse = json.decode(data);
    if (teleConsulResponse['my_subscriptions'] == null ||
        !(teleConsulResponse['my_subscriptions'] is List) ||
        teleConsulResponse['my_subscriptions'].isEmpty) {
      if (this.mounted) {
        setState(() {
          hasSubscription = false;
        });
      }
      return;
    }
    if (this.mounted) {
      setState(() {
        subscriptions = teleConsulResponse['my_subscriptions'];
        hasSubscription = true;
      });
    }

    for (int i = 0; i < subscriptions.length; i++) {
      var subscriptionID = subscriptions[i]["course_id"];
      var status = subscriptions[i]["approval_status"];
      for (var i = 0; i < results.length; i++) {
        if ((results[i]['course_id'] == subscriptionID) && status == "Accepted" ||
            status == "Approved") {
          results[i]['isSubscribed'] = 'true';
          if (this.mounted) {
            setState(() {
              makeCourseSubscribed = true;
            });
          }
        } else {
          results[i]['isSubscribed'] = 'false';
        }
      }
    }
    navi=false;
    setState(() {

    });
  }

  Future getCourseImageURL() async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/courses_image_fetch"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, dynamic>{
        'classIDList': courseID,
      }),
    );
    if (response.statusCode == 200) {
      List imageOutput = json.decode(response.body);
      courseIDAndImage = imageOutput;
      for (var i = 0; i < courseIDAndImage.length; i++) {
        if (results[i]['course_id'] == courseIDAndImage[i]['course_id']) {
          base64Image = courseIDAndImage[i]['base_64'].toString();
          base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
          base64Image = base64Image.replaceAll('}', '');
          base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
          if (this.mounted) {
            setState(() {
              // courseImage = imageFromBase64String(base64Image);
              courseImage = base64Image;
            });
          }

          results[i]['course_img_url'] = courseImage;
        }
      }
    } else {
      print(response.body);
    }
  }

  /// get card widget
  Widget getCard(Map map, int index) {
    var currentDateTime = new DateTime.now();
    var courseDuration = map["course_duration"];
    String courseEndDuration = courseDuration.substring(13, 23);
    int lastIndexValue = map["course_time"].length - 1;
    String courseEndTimeFullValue = map["course_time"][lastIndexValue]; //02:00 PM - 07:00 PM
    String courseEndTime = courseEndTimeFullValue.substring(
        courseEndTimeFullValue.indexOf("-") + 1, courseEndTimeFullValue.length); //07:00 PM
    courseEndDuration = courseEndDuration + courseEndTime; //20-04-2022 07:00 PM
    DateTime endDate;
    if (courseEndTime != " Invalid DateTime") {
      endDate = new DateFormat("dd-MM-yyyy hh:mm a").parse(courseEndDuration);
    } else {
      endDate = DateTime.now().subtract(Duration(days: 365));
    }

    if (endDate.isBefore(currentDateTime)) {
      return Container();
    } else {
      // noClassIsActive = false;
      return SelectClassCardForAffiliation(index, widget.arg['courses'], map, widget.companyName);
    }
  }

  filterCoursesForAffiliation() {
    var flat = widget.arg['courses'];

    var affiliatedCourses = [];

    for (int i = 0; i < flat.length; i++) {
      if (flat[i]['affilation_excusive_data'] != null) {
        if (flat[i]['affilation_excusive_data'].length != 0) {
          if (flat[i]['affilation_excusive_data']['affilation_array'].length != 0) {
            affiliatedCourses.add(flat[i]);
          }
        }
      }
    }

    List<dynamic> newList = [];
    List<dynamic> newList1 = [];

    if (affiliatedCourses.length != 0) {
      for (int i = 0; i < affiliatedCourses.length; i++) {
        var affiliationArray = [];
        affiliationArray.add(affiliatedCourses[i]['affilation_excusive_data']['affilation_array']);

        var affFlatCourses = affiliationArray.expand((i) => i).toList();

        newList =
            affFlatCourses?.map((m) => m != null ? m['affilation_unique_name'] : "")?.toList() ??
                [];

        newList1 =
            affFlatCourses?.map((m) => m != null ? m['affilation_name'] : "")?.toList() ?? [];

        if (newList.contains(widget.companyName) || newList1.contains(widget.companyName)) {
          affCourses.add(affiliatedCourses[i]);
          if (this.mounted) {
            setState(() {
              affiliationArray.clear();
              newList.clear();
              newList1.clear();
            });
          }
        } else {
          affiliationArray.clear();
          if (this.mounted) {
            setState(() {
              newList.clear();
              newList1.clear();
            });
          }
        }
      }
    }

    print(affCourses);
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < affCourses.length; i++) {
      var courseDuration = affCourses[i]["course_duration"];
      String courseEndDuration = courseDuration.substring(13, 23);
      int lastIndexValue = affCourses[i]["course_time"].length - 1;
      String courseEndTimeFullValue =
          affCourses[i]["course_time"][lastIndexValue]; //02:00 PM - 07:00 PM
      String courseEndTime = courseEndTimeFullValue.substring(
          courseEndTimeFullValue.indexOf("-") + 1, courseEndTimeFullValue.length); //07:00 PM
      courseEndDuration = courseEndDuration + courseEndTime; //20-04-2022 07:00 PM
      DateTime endDat = new DateFormat("dd-MM-yyyy hh:mm a").parse(courseEndDuration);
      //DateTime endDat = new DateFormat("dd-MM-yyyy").parse(courseEndDuration);
      if (endDat.isAfter(affCurrentDateTim)
          // ||
          // (endDat.day == affCurrentDateTim.day &&
          //     endDat.month == affCurrentDateTim.month)
          ) {
        affiliateActiveClassAvailable = true;
        break;
      }
    }
    return ScrollessBasicPageUI(
        appBar: Column(
          children: [
            SizedBox(
              width: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                ),
                // Text(
                //   AppTexts.selectClass,
                //   style: TextStyle(color: Colors.white, fontSize: 25),
                // ),

                // SizedBox(
                //   width: ScUtil().setWidth(50),
                // ),
                // Spacer(),
                Flexible(
                  child: Text(
                 "Events & Programs",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
                // Spacer(),
                SizedBox(
                  width: 40,
                ),
              ],
            ),
          ],
        ),
        body: affCourses.length == 0
            ? Center(
                child: Text('No classes available for Events & Programs'),
              )
            : affiliateActiveClassAvailable == false // || noClassIsActive
                ? Center(
                    child: Text('No classes available for ' +
                        widget.arg['specality_name'].toString().replaceAll('amp;', '')),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return getCard(affCourses[index], index);
                      },
                      itemCount: affCourses.length,
                    ),
                  ));
  }
}
