// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, missing_return, unnecessary_statements, non_constant_identifier_names
import 'dart:convert';
import 'dart:developer';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/expiredSubscriptionTile.dart';
import 'package:ihl/widgets/teleconsulation/DashboardTile.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ihl/constants/spKeys.dart';

class PastExpiredSubscriptions extends StatefulWidget {
  @override
  _PastExpiredSubscriptionsState createState() => _PastExpiredSubscriptionsState();
}

class _PastExpiredSubscriptionsState extends State<PastExpiredSubscriptions> {
  String iHLUserId;
  ExpandableController _expandableController;
  bool expanded = true;
  bool hasSubscription = false;
  List subscriptions = [];
  List expiredSubscriptions;
  var list = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getData();
    _expandableController = ExpandableController(
      initialExpanded: false,
    );
    _expandableController.addListener(() {
      if (this.mounted) {
        setState(() {
          expanded = _expandableController.expanded;
        });
      }
    });
  }

  Future getData() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    iHLUserId = res['User']['id'];

    /*final getUserDetails = await http.post(
      API.iHLUrl+"/consult/get_user_details",
      body: jsonEncode(<String, String>{
        'ihl_id': iHLUserId,
      }),
    );
    if (getUserDetails.statusCode == 200) {
    } else {
      print(getUserDetails.body);
    }*/
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
        expiredSubscriptions = subscriptions
            .where((i) =>
                i["approval_status"] == "expired" ||
                i["approval_status"] == "Expired" ||
                i['approval_status'] == 'accepted' ||
                i['approval_status'] == 'Accepted' ||
                i["approval_status"] == "cancelled" ||
                i["approval_status"] == "Cancelled" ||
                i["approval_status"] == "Rejected" ||
                i["approval_status"] == "rejected")
            .toList();

        var currentDateTime = new DateTime.now();

        for (int i = 0; i < expiredSubscriptions.length; i++) {
          var duration = expiredSubscriptions[i]["course_duration"];
          var time = expiredSubscriptions[i]["course_time"];

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

          list.add(expiredSubscriptions[i]);
        }
        log(list.toString());
        hasSubscription = true;
      });
    }
  }

  ExpiredSubscriptionTile getItem(Map map) {
    return ExpiredSubscriptionTile(
      subscription_id: map["subscription_id"],
      trainerId: map["consultant_id"],
      trainerName: map["consultant_name"],
      title: map["title"],
      duration: map["course_duration"],
      time: map["course_time"],
      provider: map['provider'],
      isExpired: map['approval_status'] == "expired" || map['approval_status'] == "Expired",
      isCancelled: map['approval_status'] == "Cancelled" || map['approval_status'] == "cancelled",
      isRejected: map['approval_status'] == "Rejected" || map['approval_status'] == "rejected",
      courseOn: map['course_on'],
      courseTime: map['course_time'],
      courseId: map['course_id'],
      courseFee: map['course_fees'].toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DashboardTile(
          icon: FontAwesomeIcons.bell,
          text: 'Loading ' + '...',
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
          // color: AppColors.bgColorTab,
          color: FitnessAppTheme.nearlyWhite,
          //ignore: missing_required_param
          child: ExpandablePanel(
            controller: _expandableController,
            theme:
                ExpandableThemeData(hasIcon: false, animationDuration: Duration(milliseconds: 100)),
            header: DashboardTile(
              icon: FontAwesomeIcons.bell,
              text: AppTexts.pastExpiredSubscriptions,
              color: AppColors.orangeAccent,
              trailing: expanded ? Icon(Icons.keyboard_arrow_up) : Icon(Icons.keyboard_arrow_down),
              onTap: () {
                _expandableController.toggle();
              },
            ),
            expanded: hasSubscription == false || subscriptions.length == 0 || list.length == 0
                ? Center(
                    child: Container(
                    child: Text(
                      "No expired subscriptions",
                      style: TextStyle(
                        fontSize: ScUtil().setSp(16),
                      ),
                    ),
                  ))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: expiredSubscriptions.map((e) {
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
