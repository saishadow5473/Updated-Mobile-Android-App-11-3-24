import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/teleconsulation/DashboardTile.dart';
import 'package:ihl/widgets/teleconsulation/exports.dart';
import 'package:ihl/widgets/teleconsulation/subscriptionTile.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveSubscriptions extends StatefulWidget {
  @override
  _ActiveSubscriptionsState createState() => _ActiveSubscriptionsState();
}

class _ActiveSubscriptionsState extends State<ActiveSubscriptions> {
  String iHLUserId;
  ExpandableController _expandableController;
  bool expanded = true;
  bool hasSubscription = false;
  List subscriptions = [];
  List approvedSubscriptions;
  var list = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getData();
    _expandableController = ExpandableController(
      initialExpanded: true,
    );
    _expandableController.addListener(() {
      if (this.mounted) {
        {
          setState(() {
            expanded = _expandableController.expanded;
          });
        }
      }
    });
  }

  Future getData() async {
    // Commented getUserDetails API and using SharedPreference instead
    /*
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    iHLUserId = res['User']['id'];
    final getUserDetails = await http.post(
      API.iHLUrl+"/consult/get_user_details",
      body: jsonEncode(<String, dynamic>{
        'ihl_id': iHLUserId,
      }),
    );
    if (getUserDetails.statusCode == 200) {
      final userDetailsResponse = await SharedPreferences.getInstance();
      userDetailsResponse.setString(
          SPKeys.userDetailsResponse, getUserDetails.body);
    } else {
      print(getUserDetails.body);
    }
    */

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);

    Map teleConsulResponse = json.decode(data);
    loading = false;
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
        approvedSubscriptions = subscriptions
            .where((i) =>
                i["approval_status"] == "Approved" ||
                i["approval_status"] == "Accepted" ||
                i["approval_status"] == "Requested" ||
                i["approval_status"] == "requested")
            .toList();
        var currentDateTime = new DateTime.now();

        for (int i = 0; i < approvedSubscriptions.length; i++) {
          var duration = approvedSubscriptions[i]["course_duration"];
          var time = approvedSubscriptions[i]["course_time"];
          var approvelStatus = approvedSubscriptions[i]["approval_status"];

          String courseDurationFromApi = duration;
          String courseTimeFromApi = time;

          String courseStartTime;
          String courseEndTime;

          String courseStartDuration = courseDurationFromApi.substring(0, 10);

          String courseEndDuration = courseDurationFromApi.substring(13, 23);

          DateTime startDate = new DateFormat("yyyy-MM-dd").parse(courseStartDuration);
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          String startDateFormattedToString = formatter.format(startDate);

          DateTime endDate = new DateFormat("yyyy-MM-dd").parse(courseEndDuration);
          String endDateFormattedToString = formatter.format(endDate);
          if (courseTimeFromApi[2].toString() == ':' && courseTimeFromApi[13].toString() != ':') {
            var tempcourseEndTime = '';
            courseStartTime = courseTimeFromApi.substring(0, 8);
            for (var i = 0; i < courseTimeFromApi.length; i++) {
              if (i == 10) {
                tempcourseEndTime += '0';
              } else if (i > 10) {
                tempcourseEndTime += courseTimeFromApi[i];
              }
            }
            courseEndTime = tempcourseEndTime;
          } else if (courseTimeFromApi[2].toString() != ':') {
            var tempcourseStartTime = '';
            var tempcourseEndTime = '';

            for (var i = 0; i < courseTimeFromApi.length; i++) {
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
              var tempcourseEndTime = '';
              for (var i = 0; i <= courseEndTime.length; i++) {
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
          String startDateAndTime = startDateFormattedToString + " " + startingTime;
          String endDateAndTime = endDateFormattedToString + " " + endingTime;
          DateTime finalStartDateTime =
              new DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
          DateTime finalEndDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);
          if (finalEndDateTime.isAfter(currentDateTime) ||
              approvelStatus == "Cancelled" ||
              approvelStatus == "cancelled") {
            list.add(approvedSubscriptions[i]);
          }
        }
        hasSubscription = true;
      });
    }
  }

//Added new variable to get the external URL form the API ⚪⚪
  SubscriptionTile getItem(Map map) {
    return SubscriptionTile(
      external_url: map["external_url"],
      isCompleted: map["completed"] ?? false,
      subscription_id: map["subscription_id"],
      course_fees: map["course_fees"].toString(),
      trainerId: map["consultant_id"],
      trainerName: map["consultant_name"],
      title: map["title"],
      duration: map["course_duration"],
      time: map["course_time"],
      provider: map['provider'],
      isApproved: map['approval_status'] == "Accepted" || map['approval_status'] == "Approved",
      isRejected: map['approval_status'] == "Rejected",
      isRequested: map['approval_status'] == "Requested" || map['approval_status'] == 'requested',
      isCancelled: map['approval_status'] == "Cancelled" || map['approval_status'] == 'cancelled',
      courseOn: map['course_on'],
      courseTime: map['course_time'],
      courseId: map['course_id'],
      courseType: map['course_type'].toString().toLowerCase().contains('days') ||
              map['course_type'].toString().toLowerCase().contains('daily')
          ? 'daily'
          : map['course_type'],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DashboardTile(
          icon: FontAwesomeIcons.bell,
          text: 'Loading ' + AppTexts.myActiveSubbscriptions + '...',
          color: AppColors.history,
          trailing: CircularProgressIndicator(),
          onTap: () {},
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        child: Container(
          // decoration: BoxDecoration(
          //   color: FitnessAppTheme.white,
          //   borderRadius: BorderRadius.all(
          //     Radius.circular(20),
          //   ),
          //   border: Border.all(color: FitnessAppTheme.grey.withOpacity(0.2),),
          //   boxShadow: <BoxShadow>[
          //     BoxShadow(
          //         color: FitnessAppTheme.grey.withOpacity(0.2),
          //         offset: Offset(1.1, 1.1),
          //         blurRadius: 10.0),
          //   ],
          // ),
          // color: AppColors.bgColorTab,
          color: FitnessAppTheme.nearlyWhite,
          //ignore: missing_required_param
          child: ExpandablePanel(
            controller: _expandableController,
            theme:
                ExpandableThemeData(hasIcon: false, animationDuration: Duration(milliseconds: 100)),
            header: DashboardTile(
              icon: FontAwesomeIcons.solidBell,
              text: AppTexts.myActiveSubbscriptions,
              color: AppColors.orangeAccent,
              trailing: expanded ? Icon(Icons.keyboard_arrow_up) : Icon(Icons.keyboard_arrow_down),
              onTap: () {
                _expandableController.toggle();
              },
            ),
            expanded: hasSubscription == false || list.length == 0
                ? Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50.0,
                        ),
                        Center(
                          child: Text("No Active Subscriptions!", style: TextStyle(fontSize: 18.0)),
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: list.map((e) {
                        return getItem(e);
                      }).toList(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
