// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/teleconsultation/active_subscriptions.dart';
import 'package:ihl/views/teleconsultation/myAppointments.dart';
import 'package:ihl/views/teleconsultation/mySubscriptions.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';
import 'package:get/get.dart';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';

import '../../views/teleconsultation/MySubscription.dart';

// ignore: must_be_immutable
class DashBoardSubscriptionTile extends StatefulWidget {
  final String trainerId;
  final String trainerName;
  final String title;
  final String duration;
  final String time;
  final String provider;
  final courses;
  final Map consultant;
  bool isApproved;
  bool isRejected;
  bool isRequested;
  bool isCancelled;
  final List courseOn;
  final String courseTime;
  final subscription_id;
  final String courseId;
  String courseImgUrl;

  DashBoardSubscriptionTile(
      {this.trainerId,
      this.trainerName,
      this.title,
      this.duration,
      this.time,
      this.provider,
      this.isApproved,
      this.isRejected,
      this.isRequested,
      this.isCancelled,
      this.courseTime,
      this.courseOn,
      this.subscription_id,
      this.courseId,
      this.courses,
      this.consultant,
      this.courseImgUrl});

  @override
  _DashBoardSubscriptionTileState createState() => _DashBoardSubscriptionTileState();
}

class _DashBoardSubscriptionTileState extends State<DashBoardSubscriptionTile> {
  http.Client _client = http.Client(); //3gb
  bool approve = false;
  bool reject = false;
  bool isChecking = false;
  bool makeValidateVisible = false;
  final reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String finalDuration;
  int differenceInDays;
  int differenceInTime;
  bool enableJoinCall = false;
  String trainerStatus = 'Offline';
  dynamic currentTime = DateFormat.jm().format(DateTime.now());

  String iHLUserId;

  bool hasSubscription = false;
  bool makeCourseSubscribed = false;
  bool makeCourseRequested = false;
  List subscriptions = [];

  var courseIDAndImage = [];
  var base64Image;
  var courseImage;
  var imageCourse;

  Future getSubscriptionsUserDetails() async {
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

      if (subscriptionID == widget.courseId && status == "Accepted" || status == "Approved") {
        if (this.mounted) {
          setState(() {
            makeCourseSubscribed = true;
          });
        }
      }
      print(widget.courseId);
      if (subscriptionID == widget.courseId && status == "requested" || status == "Requested") {
        if (this.mounted) {
          setState(() {
            makeCourseRequested = true;
          });
        }
      }
    }
  }

  Future getCourseImageURL() async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/courses_image_fetch"),
      body: jsonEncode(<String, dynamic>{
        'classIDList': [widget.courseId],
      }),
    );
    if (response.statusCode == 200) {
      List imageOutput = json.decode(response.body);
      courseIDAndImage = imageOutput;
      for (var i = 0; i < courseIDAndImage.length; i++) {
        if (widget.courseId == courseIDAndImage[i]['course_id']) {
          base64Image = courseIDAndImage[i]['base_64'].toString();
          base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
          base64Image = base64Image.replaceAll('}', '');
          base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
          if (this.mounted) {
            setState(() {
              courseImage = base64Image;
            });
          }
          widget.courseImgUrl = courseImage;
          imageCourse = Image.memory(base64Decode(widget.courseImgUrl));
        }
      }
    } else {
      print(response.body);
    }
  }

  Text status() {
    if (widget.isRequested == true) {
      return Text(
        AppTexts.mySubscriptionReqPen,
        style: TextStyle(color: FitnessAppTheme.nearlyWhite, fontSize: ScUtil().setSp(12)),
      );
    }
    if (widget.isApproved == true) {
      return Text(
        AppTexts.mySubscriptionReqAccepted,
        style: TextStyle(color: Colors.green, fontSize: ScUtil().setSp(12)),
      );
    }
    if (widget.isRejected == true) {
      return Text(
        "Subscription Rejected",
        style: TextStyle(color: Colors.red),
      );
    }
    if (widget.isCancelled == true) {
      return Text(
        "Subscription Cancelled",
        style: TextStyle(color: Colors.red),
      );
    }
    return Text(
      AppTexts.mySubscriptionReqPen,
      style: TextStyle(color: AppColors.primaryAccentColor, fontSize: ScUtil().setSp(12)),
    );
  }

  void httpStatus() async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/getConsultantLiveStatus'),
      body: jsonEncode(<String, dynamic>{
        "consultant_id": [widget.trainerId]
      }),
    );
    if (response.statusCode == 200) {
      if (response.body != '"[]"') {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString1 = parsedString.replaceAll(";", "");
        var parsedString2 = parsedString1.replaceAll('"[', '[');
        var parsedString3 = parsedString2.replaceAll(']"', ']');
        var finalOutput = json.decode(parsedString3);
        var doctorId = widget.trainerId;
        if (doctorId == finalOutput[0]['consultant_id']) {
          trainerStatus = camelize(finalOutput[0]['status'].toString());
          if (this.mounted) {
            setState(() {
              if (trainerStatus == null ||
                  trainerStatus == "" ||
                  trainerStatus == "null" ||
                  trainerStatus == "Null") {
                trainerStatus = "Offline";
              } else {
                trainerStatus = camelize(finalOutput[0]['status'].toString());
              }
            });
          }
        }
      } else {}
    } else {}
  }

  void cancelSubscription(var subscriptionId, var canceledBy, var reason) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var data = prefs.get('data');
    Map res = jsonDecode(data);
    iHLUserId = res['User']['id'];

    var apiToken = prefs.get('auth_token');
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/cancel_subscription'),
      headers: {'ApiToken': apiToken},
      body: jsonEncode(<String, dynamic>{
        "subscription_id": subscriptionId.toString(),
        "canceled_by": canceledBy.toString(),
        "reason": reason.toString(),
      }),
    );
    if (response.statusCode == 200) {
      if (response.body != '"[]"') {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString1 = parsedString.replaceAll(";", "");
        var parsedString2 = parsedString1.replaceAll('"[', '[');
        var parsedString3 = parsedString2.replaceAll(']"', ']');
        var finalOutput = json.decode(parsedString3);
        var status = finalOutput["status"];
        if (status == "cancel_success") {
          // Updating getUserDetails API

          if (this.mounted) {
            setState(() {
              isChecking = false;
            });
          }
          nonCurativeApproveDeclineHostAPI(widget.provider, widget.subscription_id, "Cancelled");
          AwesomeDialog(
                  context: context,
                  animType: AnimType.TOPSLIDE,
                  headerAnimationLoop: true,
                  dialogType: DialogType.SUCCES,
                  dismissOnTouchOutside: false,
                  title: 'Success!',
                  desc: "Subscription Cancelled Successfully!",
                  btnOkOnPress: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MySubscription(
                                  afterCall: false,
                                )),
                        (Route<dynamic> route) => false);
                  },
                  btnOkColor: Colors.green,
                  btnOkText: 'Proceed',
                  btnOkIcon: Icons.check,
                  onDismissCallback: (_) {})
              .show();
        }
      }
    } else {
      AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: true,
              dialogType: DialogType.ERROR,
              dismissOnTouchOutside: false,
              title: 'Failed!',
              desc: "Subscription Cancellation Unsuccessful. Please Try Again.",
              btnOkOnPress: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MySubscription(
                              afterCall: false,
                            )),
                    (Route<dynamic> route) => false);
              },
              btnOkColor: Colors.red,
              btnOkText: 'Proceed',
              btnOkIcon: Icons.refresh,
              onDismissCallback: (_) {})
          .show();
      print(response.body);
    }
  }

  Future nonCurativeApproveDeclineHostAPI(String company_name, String subsID, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiToken = prefs.get('auth_token');
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/approve_or_reject_subscription'),
      headers: {'ApiToken': apiToken},
      body: jsonEncode(<String, String>{
        "company_name": company_name,
        "subscription_id": subsID,
        "subscription_status": status,
      }),
    );
    if (response.statusCode == 200) {
      var parsedString = response.body.replaceAll('"', '');
      if ((parsedString == "Database Updated") && (status == "Approved")) {
        if (this.mounted) {
          setState(() {
            approve = true;
          });
        }
      } else if ((parsedString == "Database Updated") && (status == "Rejected")) {
        if (this.mounted) {
          setState(() {
            reject = true;
          });
        }
      } else if (response.body == "Not Updated") {
        if (status == "Approved") {
        } else {}
      }
    } else {
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentDateTime = new DateTime.now();
    var difference;
    String courseDurationFromApi = widget.duration;
    String courseTimeFromApi = widget.courseTime;
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
    DateTime finalStartDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
    DateTime finalEndDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);
    DateTime startTimeOnly = new DateFormat("HH:mm:ss").parse(startingTime);
    DateTime endTimeOnly = new DateFormat("HH:mm:ss").parse(endingTime);
    var classStartingTime = DateTime.parse(startDateAndTime);

    differenceInTime = endTime.difference(startTime).inMinutes;

    differenceInDays = endDate.difference(startDate).inDays;

    DateTime fiveMinutesBeforeStartTime = finalStartDateTime.subtract(Duration(minutes: 5));
    DateTime minutesAfterStartTime = classStartingTime.add(Duration(minutes: differenceInTime));
    if ((currentDateTime.isBefore(finalEndDateTime) &&
            currentDateTime.isAfter(finalStartDateTime)) &&
        currentDateTime.isAfter(fiveMinutesBeforeStartTime) &&
        currentDateTime.isBefore(minutesAfterStartTime) &&
        (currentDateTime.hour >= startTime.hour && currentDateTime.hour < endTime.hour) &&
        (trainerStatus == "Online" || trainerStatus == "Busy") &&
        (widget.courseOn.contains("Monday") ||
            widget.courseOn.contains("Tuesday") ||
            widget.courseOn.contains("Wednesday") ||
            widget.courseOn.contains("Thursday") ||
            widget.courseOn.contains("Friday") ||
            widget.courseOn.contains("Saturday") ||
            widget.courseOn.contains("Sunday"))) {
      if (this.mounted) {
        setState(() {
          enableJoinCall = true;
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          enableJoinCall = false;
        });
      }
    }

    return Column(
      children: [
        Container(
          // height: MediaQuery.of(context).size.height / 4.1,
          // width: MediaQuery.of(context).size.width / 1.24,
          width: ScUtil().setWidth(285),
          // height: ScUtil().setHeight(199),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
            ),
            // color: AppColors.cardColor,
            color: Color.fromRGBO(35, 107, 254, 0.8),

            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.grey[900],
                    //Colors.lightBlue,
                    Colors.red[900],
                  ],
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      /* Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          FontAwesomeIcons.video,
                          color: AppColors.startConsult,
                        ),
                      ),*/
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.only(left: 15.0),
                                title: Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                        fontSize: ScUtil().setSp(15),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                                subtitle: status(),
                                leading: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0),
                                      ),
                                      color: Colors.white),
                                  // width: ScUtil().setWidth(40),
                                  // height: ScUtil().setHeight(35),
                                  height: 45,
                                  width: 42,
                                  child: CircleAvatar(
                                    // radius: 60.0,
                                    backgroundImage: imageCourse == null ? null : imageCourse.image,
                                    // widget.consultant['course_img_url'] == null
                                    //     ? null
                                    //     : Image.memory(base64Decode(
                                    //             widget.consultant['course_img_url']))
                                    //         .image,
                                    backgroundColor: AppColors.primaryAccentColor,
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(3.5),
                                  //   child: Image.asset(
                                  //     'assets/images/newmt.jpg',
                                  //     fit: BoxFit.fitHeight,
                                  //   ),
                                  // ),
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(bottom: 18.0),
                                  child: PopupMenuButton<String>(
                                    // color: Colors.white,
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                    ),
                                    onSelected: (k) async {
                                      Navigator.of(context)
                                          .pushNamed(Routes.MySubscriptions, arguments: false);
                                      // Navigator.of(context).pushNamed(
                                      //     Routes.ConsultationType,
                                      //     arguments: false);
                                      // Get.to(ActiveSubscriptions());
                                      // Get.to(
                                      //   ShareDocumentFromMyAppointment(
                                      //     ihlConsultantId: widget.ihlConsultantId,
                                      //     appointmentId: widget.appointmentId,
                                      //   ),
                                      // );
                                    },
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                          value: 'View Other Classes',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.book_outlined,
                                                color: AppColors.primaryColor,
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Text('View Other Classes'),
                                            ],
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                  // height: MediaQuery.of(context).size.height / 80,
                                  height: ScUtil().setHeight(10)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 17.0),
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Icon(
                                        Icons.animation,
                                        color: Colors.white,
                                        size: ScUtil().setSp(18),
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScUtil().setWidth(4),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Duration : " + differenceInDays.toString(),
                                          style: TextStyle(
                                              fontSize: ScUtil().setSp(12),
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          ' days',
                                          style: TextStyle(
                                              fontSize: ScUtil().setSp(12),
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Text(
                                    //       'In',
                                    //       style: TextStyle(
                                    //           fontSize: 12.0,
                                    //           color: Colors.white,
                                    //           fontWeight: FontWeight.w600),
                                    //     ),
                                    //     SizedBox(width: 3.0),
                                    //     Text(
                                    //       difference.toString(),
                                    //       // widget.date.toString().substring(0, 10),
                                    //       style: TextStyle(
                                    //           fontSize: 12.0,
                                    //           color: Colors.white,
                                    //           fontWeight: FontWeight.w600),
                                    //     ),
                                    //     SizedBox(width: 3.0),
                                    //     difference == 1
                                    //         ? Text(
                                    //             'day',
                                    //             style: TextStyle(
                                    //                 fontSize: 12.0,
                                    //                 color: Colors.white,
                                    //                 fontWeight: FontWeight.w600),
                                    //           )
                                    //         : Text(
                                    //             'days',
                                    //             style: TextStyle(
                                    //                 fontSize: 12.0,
                                    //                 color: Colors.white,
                                    //                 fontWeight: FontWeight.w600),
                                    //           )
                                    //   ],
                                    // ),
                                    SizedBox(
                                      // width: 22.0,
                                      width: ScUtil().setWidth(28),
                                    ),
                                    Container(
                                      child: Icon(
                                        Icons.timer,
                                        color: Colors.white,
                                        size: ScUtil().setSp(18),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      // widget.time,
                                      differenceInTime.toString() + ' hrs',
                                      style: TextStyle(
                                          fontSize: ScUtil().setSp(12),
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),

                              // Text(
                              //   "Trainer:  " + widget.provider,
                              //   style: TextStyle(
                              //       fontSize: 14.0,
                              //       color: Colors.white,
                              //       fontWeight: FontWeight.w600),
                              // ),
                              SizedBox(
                                  // height: 15.0,
                                  // height:
                                  // MediaQuery.of(context).size.height / 80),
                                  height: ScUtil().setHeight(20)),
                              widget.isApproved
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          width: 130.0,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              primary: enableJoinCall ? Colors.green : Colors.grey,
                                              textStyle: TextStyle(color: Colors.white),
                                            ),
                                            onPressed: enableJoinCall
                                                ? () async {
                                                    SharedPreferences prefs =
                                                        await SharedPreferences.getInstance();
                                                    var data = prefs.get('data');
                                                    Map res = jsonDecode(data);
                                                    var iHLUserId = res['User']['id'];

                                                    prefs.setString(
                                                        "userIDFromSubscriptionCall", iHLUserId);
                                                    prefs.setString(
                                                        "consultantIDFromSubscriptionCall",
                                                        widget.trainerId);
                                                    prefs.setString(
                                                        "subscriptionIDFromSubscriptionCall",
                                                        widget.subscription_id);
                                                    prefs.setString(
                                                        "courseNameFromSubscriptionCall",
                                                        widget.title);
                                                    prefs.setString("courseIDFromSubscriptionCall",
                                                        widget.courseId);
                                                    prefs.setString(
                                                        "trainerNameFromSubscriptionCall",
                                                        widget.trainerName);
                                                    Get.offNamedUntil(
                                                        Routes.CallWaitingScreen, (route) => false,
                                                        arguments: [
                                                          widget.courseId.toString(),
                                                          iHLUserId.toString(),
                                                          widget.trainerId,
                                                          "SubscriptionCall",
                                                          widget.subscription_id,
                                                        ]);
                                                  }
                                                : () async {
                                                    showDialog<bool>(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text('Info'),
                                                          content: Text(
                                                              'You can Join when the Session Starts'),
                                                          actions: <Widget>[
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                primary: Color(0xff4393CF),
                                                                textStyle:
                                                                    TextStyle(color: Colors.white),
                                                              ),
                                                              child: Text(
                                                                'Okay',
                                                                style:
                                                                    TextStyle(color: Colors.white),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                            label: Text("Join Class"),
                                            icon: Icon(Icons.phone),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 130.0,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              primary: AppColors.primaryColor,
                                              textStyle: TextStyle(color: Colors.white),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  String reasonRadioBtnVal = "";
                                                  return AlertDialog(
                                                      title: Text(
                                                        'Please provide the reason for cancellation!',
                                                        style: TextStyle(color: Color(0xff4393cf)),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      content: StatefulBuilder(
                                                        builder: (BuildContext context,
                                                            StateSetter setState) {
                                                          return SingleChildScrollView(
                                                            child: Form(
                                                              key: _formKey,
                                                              // ignore: deprecated_member_use
                                                              autovalidateMode: AutovalidateMode
                                                                  .onUserInteraction,
                                                              child: Column(
                                                                children: [
                                                                  Column(
                                                                    children: <Widget>[
                                                                      Row(
                                                                        children: [
                                                                          new Radio<String>(
                                                                            value:
                                                                                'You\'re not interested/satisfied',
                                                                            groupValue:
                                                                                reasonRadioBtnVal,
                                                                            onChanged:
                                                                                (String value) {
                                                                              if (this.mounted) {
                                                                                setState(() {
                                                                                  reasonRadioBtnVal =
                                                                                      value;
                                                                                });
                                                                              }
                                                                            },
                                                                          ),
                                                                          Expanded(
                                                                            child: new Text(
                                                                              'You\'re not interested/satisfied',
                                                                              style: new TextStyle(
                                                                                  fontSize: 16.0),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Radio<String>(
                                                                            value:
                                                                                "Trainer not interested",
                                                                            groupValue:
                                                                                reasonRadioBtnVal,
                                                                            onChanged:
                                                                                (String value) {
                                                                              if (this.mounted) {
                                                                                setState(() {
                                                                                  reasonRadioBtnVal =
                                                                                      value;
                                                                                });
                                                                              }
                                                                            },
                                                                          ),
                                                                          Expanded(
                                                                            child: new Text(
                                                                              'Trainer not interested',
                                                                              style: new TextStyle(
                                                                                fontSize: 16.0,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      TextFormField(
                                                                        controller:
                                                                            reasonController,
                                                                        validator: (value) {
                                                                          if (value.isEmpty) {
                                                                            return 'Please provide the reason!';
                                                                          }
                                                                          return null;
                                                                        },
                                                                        decoration: InputDecoration(
                                                                          contentPadding:
                                                                              EdgeInsets.symmetric(
                                                                                  vertical: 15,
                                                                                  horizontal: 18),
                                                                          labelText: "Other reason",
                                                                          fillColor: Colors.white24,
                                                                          border: new OutlineInputBorder(
                                                                              borderRadius:
                                                                                  new BorderRadius
                                                                                          .circular(
                                                                                      15.0),
                                                                              borderSide:
                                                                                  new BorderSide(
                                                                                      color: Colors
                                                                                          .blueGrey)),
                                                                        ),
                                                                        maxLines: 1,
                                                                        textInputAction:
                                                                            TextInputAction.done,
                                                                      ),
                                                                      Visibility(
                                                                        visible: makeValidateVisible
                                                                            ? true
                                                                            : false,
                                                                        child: Text(
                                                                          "Please select the reason!",
                                                                          style: TextStyle(
                                                                              color: Colors.red),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10.0,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius
                                                                                    .circular(10.0),
                                                                          ),
                                                                          primary: AppColors
                                                                              .primaryColor,
                                                                          textStyle: TextStyle(
                                                                              color: Colors.white),
                                                                        ),
                                                                        child: Text(
                                                                          'Go Back',
                                                                          style: TextStyle(
                                                                              color: Colors.white),
                                                                        ),
                                                                        onPressed:
                                                                            isChecking == true
                                                                                ? null
                                                                                : () {
                                                                                    Navigator.pop(
                                                                                        context);
                                                                                  },
                                                                      ),
                                                                      // SizedBox(width: 10.0),
                                                                      ElevatedButton(
                                                                          style: ElevatedButton
                                                                              .styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(
                                                                                          10.0),
                                                                            ),
                                                                            primary: AppColors
                                                                                .primaryColor,
                                                                            textStyle: TextStyle(
                                                                                color:
                                                                                    Colors.white),
                                                                          ),
                                                                          child: isChecking == true
                                                                              ? SizedBox(
                                                                                  height: 20.0,
                                                                                  width: 20.0,
                                                                                  child:
                                                                                      new CircularProgressIndicator(
                                                                                    valueColor:
                                                                                        AlwaysStoppedAnimation<
                                                                                                Color>(
                                                                                            Colors
                                                                                                .white),
                                                                                  ),
                                                                                )
                                                                              : Text(
                                                                                  'Submit',
                                                                                  style: TextStyle(
                                                                                      color: Colors
                                                                                          .white),
                                                                                ),
                                                                          onPressed: isChecking ==
                                                                                  true
                                                                              ? null
                                                                              : () {
                                                                                  if (reasonRadioBtnVal
                                                                                      .isNotEmpty) {
                                                                                    if (this
                                                                                        .mounted) {
                                                                                      setState(() {
                                                                                        isChecking =
                                                                                            true;
                                                                                        makeValidateVisible =
                                                                                            false;
                                                                                      });
                                                                                    }
                                                                                    cancelSubscription(
                                                                                        widget
                                                                                            .subscription_id,
                                                                                        "user",
                                                                                        reasonRadioBtnVal);
                                                                                  } else if (reasonController
                                                                                      .text
                                                                                      .isNotEmpty) {
                                                                                    if (this
                                                                                        .mounted) {
                                                                                      setState(() {
                                                                                        isChecking =
                                                                                            true;
                                                                                        makeValidateVisible =
                                                                                            false;
                                                                                      });
                                                                                    }
                                                                                    cancelSubscription(
                                                                                        widget
                                                                                            .subscription_id,
                                                                                        "user",
                                                                                        reasonController
                                                                                            .text);
                                                                                  } else {
                                                                                    if (this
                                                                                        .mounted) {
                                                                                      setState(() {
                                                                                        makeValidateVisible =
                                                                                            true;
                                                                                      });
                                                                                    }
                                                                                  }
                                                                                  // if (reasonRadioBtnVal == null || reasonRadioBtnVal == "") {
                                                                                  //   if (this.mounted) {
                                                                                  //     setState(() {
                                                                                  //       makeValidateVisible = true;
                                                                                  //     });
                                                                                  //   }
                                                                                  // } else {
                                                                                  //   if (this.mounted) {
                                                                                  //     setState(() {
                                                                                  //       makeValidateVisible = false;
                                                                                  //       isChecking = true;
                                                                                  //     });
                                                                                  //   }
                                                                                  //   cancelSubscription(widget.subscription_id, "user", reasonRadioBtnVal ?? reasonController.text);
                                                                                  // }
                                                                                }),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ));
                                                },
                                              );
                                            },
                                            label: Text("Cancel"),
                                            icon: Icon(Icons.cancel),
                                          ),
                                        ),
                                      ],
                                    )
                                  : widget.isRequested
                                      ? Container(
                                          // height: MediaQuery.of(context)
                                          //         .size
                                          //         .height /
                                          //     20,
                                          height: ScUtil().setHeight(28),
                                          // width: ScUtil().setWidth(100),
                                          child: ButtonTheme(
                                            minWidth: 240.0,
                                            // height: 40.0,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                primary: Colors.white,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                          title: Text(
                                                            'Please provide the reason for cancellation!',
                                                            style:
                                                                TextStyle(color: Color(0xff4393cf)),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                          content: StatefulBuilder(
                                                            builder: (BuildContext context,
                                                                StateSetter setState) {
                                                              return SingleChildScrollView(
                                                                child: Form(
                                                                  key: _formKey,
                                                                  // ignore: deprecated_member_use
                                                                  autovalidateMode: AutovalidateMode
                                                                      .onUserInteraction,
                                                                  child: Column(
                                                                    children: [
                                                                      Column(
                                                                        children: <Widget>[
                                                                          TextFormField(
                                                                            controller:
                                                                                reasonController,
                                                                            validator: (value) {
                                                                              if (value.isEmpty) {
                                                                                return 'Please provide the reason!';
                                                                              }
                                                                              return null;
                                                                            },
                                                                            decoration:
                                                                                InputDecoration(
                                                                              contentPadding:
                                                                                  EdgeInsets
                                                                                      .symmetric(
                                                                                          vertical:
                                                                                              15,
                                                                                          horizontal:
                                                                                              18),
                                                                              labelText:
                                                                                  "Specify your reason",
                                                                              fillColor:
                                                                                  Colors.white24,
                                                                              border: new OutlineInputBorder(
                                                                                  borderRadius:
                                                                                      new BorderRadius
                                                                                              .circular(
                                                                                          15.0),
                                                                                  borderSide:
                                                                                      new BorderSide(
                                                                                          color: Colors
                                                                                              .blueGrey)),
                                                                            ),
                                                                            maxLines: 1,
                                                                            textInputAction:
                                                                                TextInputAction
                                                                                    .done,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height: 10.0,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .spaceEvenly,
                                                                        children: [
                                                                          ElevatedButton(
                                                                            style: ElevatedButton
                                                                                .styleFrom(
                                                                              shape:
                                                                                  RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                    BorderRadius
                                                                                        .circular(
                                                                                            10.0),
                                                                              ),
                                                                              primary: AppColors
                                                                                  .primaryColor,
                                                                              textStyle: TextStyle(
                                                                                  color:
                                                                                      Colors.white),
                                                                            ),
                                                                            child: Text(
                                                                              'Go Back',
                                                                              style: TextStyle(
                                                                                  color:
                                                                                      Colors.white),
                                                                            ),
                                                                            onPressed:
                                                                                isChecking == true
                                                                                    ? null
                                                                                    : () {
                                                                                        Navigator.pop(
                                                                                            context);
                                                                                      },
                                                                          ),
                                                                          ElevatedButton(
                                                                              style: ElevatedButton
                                                                                  .styleFrom(
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius:
                                                                                      BorderRadius
                                                                                          .circular(
                                                                                              10.0),
                                                                                ),
                                                                                primary: AppColors
                                                                                    .primaryColor,
                                                                                textStyle: TextStyle(
                                                                                    color: Colors
                                                                                        .white),
                                                                              ),
                                                                              child:
                                                                                  isChecking == true
                                                                                      ? SizedBox(
                                                                                          height:
                                                                                              20.0,
                                                                                          width:
                                                                                              20.0,
                                                                                          child:
                                                                                              new CircularProgressIndicator(
                                                                                            valueColor:
                                                                                                AlwaysStoppedAnimation<Color>(Colors.white),
                                                                                          ),
                                                                                        )
                                                                                      : Text(
                                                                                          'Submit',
                                                                                          style: TextStyle(
                                                                                              color:
                                                                                                  Colors.white),
                                                                                        ),
                                                                              onPressed:
                                                                                  isChecking == true
                                                                                      ? null
                                                                                      : () {
                                                                                          if (_formKey
                                                                                              .currentState
                                                                                              .validate()) {
                                                                                            if (this
                                                                                                .mounted) {
                                                                                              setState(
                                                                                                  () {
                                                                                                isChecking =
                                                                                                    true;
                                                                                              });
                                                                                            }
                                                                                            cancelSubscription(
                                                                                                widget.subscription_id,
                                                                                                "user",
                                                                                                reasonController.text);
                                                                                          } else {
                                                                                            if (this
                                                                                                .mounted) {
                                                                                              setState(
                                                                                                  () {
                                                                                                _autoValidate =
                                                                                                    true;
                                                                                              });
                                                                                            }
                                                                                          }
                                                                                        }),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ));
                                                    });
                                              },
                                              child: Text(
                                                "Cancel Subscription",
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: ScUtil().setSp(12),
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              // icon: Icon(Icons.cancel),
                                            ),
                                          ),
                                        )
                                      : Container(),
                              SizedBox(height: ScUtil().setHeight(4)),
                              Visibility(
                                visible: ((currentDateTime.isBefore(finalEndDateTime) &&
                                            currentDateTime.isAfter(finalStartDateTime)) &&
                                        currentDateTime.isAfter(fiveMinutesBeforeStartTime) &&
                                        (currentDateTime.hour >= startTime.hour &&
                                            currentDateTime.hour < endTime.hour) &&
                                        trainerStatus == "Offline" &&
                                        (widget.courseOn.contains("Monday") ||
                                            widget.courseOn.contains("Tuesday") ||
                                            widget.courseOn.contains("Wednesday") ||
                                            widget.courseOn.contains("Thursday") ||
                                            widget.courseOn.contains("Friday") ||
                                            widget.courseOn.contains("Saturday") ||
                                            widget.courseOn.contains("Sunday")) &&
                                        widget.isApproved)
                                    ? true
                                    : false,
                                child: Text("Trainer is offline",
                                    style: TextStyle(fontSize: 16, color: Colors.red)),
                              ),
                              /*Visibility(
                                visible: (currentDateTime.isBefore(endDate) &&
                                        currentDateTime.isAfter(startDate) &&
                                        currentDateTime.isAfter(
                                            fiveMinutesBeforeStartTime) &&
                                        currentDateTime
                                            .isBefore(minutesAfterStartTime) &&
                                        trainerStatus == "Busy")
                                    ? true
                                    : false,
                                child: Text("Trainer is Busy",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.red)),
                              ),*/
                              SizedBox(
                                height: ScUtil().setHeight(8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScUtil().setHeight(2)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Session session1, session;
  Client client;
  bool showMissedCallMessage = false;
  bool callDeclinedByDoctor = false;

  void connect() async {
    client = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
  }

  void getTrainerStatus() async {
    if (session != null) {
      session.close();
    }
    connect();
    session = await client.connect().first;
    try {
      final subscription = await session.subscribe('ihl_update_doctor_status_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) {
        Map data = event.arguments[0];
        var status = data['data']['status'];
        if (data['sender_id'] == widget.trainerId) {
          if (this.mounted) {
            setState(() {
              trainerStatus = status;
            });
          }
        }
      });
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  void subscribeSubscriptionApproved() async {
    if (session1 != null) {
      session1.close();
    }
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var userId = prefs1.get("ihlUserId");
    connect();
    session1 = await client.connect().first;
    try {
      final subscription = await session1.subscribe('ihl_subscription_status_update_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) async {
        Map data = event.arguments[0];
        var status = data['data']['status'];
        var receivedSubscriptionID = data['data']['subscription_id'];
        if (widget.subscription_id == receivedSubscriptionID) {
          if (data['receiver_ids'][0] == userId) {
            if (status == "Accepted") {
              if (this.mounted) {
                setState(() {
                  widget.isApproved = true;
                  widget.isRequested = false;
                });
              } // Updating getUserDetails API
            } else if (status == "Rejected") {
              if (this.mounted) {
                setState(() {
                  widget.isRejected = true;
                  widget.isRequested = false;
                });
              } // Updating getUserDetails API
            } else if (status == "Cancelled") {
              if (this.mounted) {
                setState(() {
                  widget.isApproved = false;
                  widget.isRejected = false;
                  widget.isRequested = false;
                  widget.isCancelled = true;
                });
              } // Updating getUserDetails API
            }
          } else {
            print("appointment update from crossbar $data");
          }
        }
      });
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  Widget _buildApprovalInfoCard(context) {
    DateTime current = DateTime.now();
    var currentDateTime = new DateTime.now();
    DateTime endDate;
    DateTime startDate;
    DateTime fiveMinutesBeforeStartTime;
    DateTime minutesAfterStartTime;
    Stream timer = Stream.periodic(Duration(seconds: 5), (i) {
      current = current.add(Duration(seconds: 5));
      return current;
    });

    String courseDurationFromApi = widget.duration;
    String courseTimeFromApi = widget.courseTime;
    List courseOn = widget.courseOn;

    String courseStartTime;
    String courseEndTime;

    String courseStartDuration = courseDurationFromApi.substring(0, 10);

    String courseEndDuration = courseDurationFromApi.substring(13, 23);

    startDate = new DateFormat("yyyy-MM-dd").parse(courseStartDuration);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String startDateFormattedToString = formatter.format(startDate);

    endDate = new DateFormat("yyyy-MM-dd").parse(courseEndDuration);
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
    DateTime finalStartDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
    DateTime finalEndDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);
    DateTime startTimeOnly = new DateFormat("HH:mm:ss").parse(startingTime);
    DateTime endTimeOnly = new DateFormat("HH:mm:ss").parse(endingTime);
    var classStartingTime = DateTime.parse(startDateAndTime);

    differenceInTime = endTime.difference(startTime).inHours;

    differenceInDays = endDate.difference(startDate).inDays;

    fiveMinutesBeforeStartTime = finalStartDateTime.subtract(Duration(minutes: 5));
    minutesAfterStartTime = classStartingTime.add(Duration(hours: differenceInTime));
    if ((currentDateTime.isBefore(finalEndDateTime) &&
            currentDateTime.isAfter(finalStartDateTime)) &&
        currentDateTime.isAfter(fiveMinutesBeforeStartTime) &&
        (currentDateTime.hour >= startTime.hour && currentDateTime.hour < endTime.hour) &&
        (trainerStatus != "Offline" || trainerStatus != "offline") &&
        (widget.courseOn.contains("Monday") ||
            widget.courseOn.contains("Tuesday") ||
            widget.courseOn.contains("Wednesday") ||
            widget.courseOn.contains("Thursday") ||
            widget.courseOn.contains("Friday") ||
            widget.courseOn.contains("Saturday") ||
            widget.courseOn.contains("Sunday"))) {
      if (this.mounted) {
        setState(() {
          enableJoinCall = true;
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          enableJoinCall = false;
        });
      }
    }

    timer.listen((data) {
      String courseDurationFromApi = widget.duration;
      String courseTimeFromApi = widget.courseTime;
      List courseOn = widget.courseOn;

      String courseStartTime;
      String courseEndTime;

      String courseStartDuration = courseDurationFromApi.substring(0, 10);

      String courseEndDuration = courseDurationFromApi.substring(13, 23);

      startDate = new DateFormat("yyyy-MM-dd").parse(courseStartDuration);
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      String startDateFormattedToString = formatter.format(startDate);

      endDate = new DateFormat("yyyy-MM-dd").parse(courseEndDuration);
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
      DateTime finalStartDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
      DateTime finalEndDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);
      DateTime startTimeOnly = new DateFormat("HH:mm:ss").parse(startingTime);
      DateTime endTimeOnly = new DateFormat("HH:mm:ss").parse(endingTime);
      var classStartingTime = DateTime.parse(startDateAndTime);

      differenceInTime = endTime.difference(startTime).inHours;

      differenceInDays = endDate.difference(startDate).inDays;

      fiveMinutesBeforeStartTime = finalStartDateTime.subtract(Duration(minutes: 5));
      minutesAfterStartTime = classStartingTime.add(Duration(hours: differenceInTime));
      if ((currentDateTime.isBefore(finalEndDateTime) &&
              currentDateTime.isAfter(finalStartDateTime)) &&
          currentDateTime.isAfter(fiveMinutesBeforeStartTime) &&
          (currentDateTime.hour >= startTime.hour && currentDateTime.hour < endTime.hour) &&
          (trainerStatus != "Offline" || trainerStatus != "offline") &&
          (widget.courseOn.contains("Monday") ||
              widget.courseOn.contains("Tuesday") ||
              widget.courseOn.contains("Wednesday") ||
              widget.courseOn.contains("Thursday") ||
              widget.courseOn.contains("Friday") ||
              widget.courseOn.contains("Saturday") ||
              widget.courseOn.contains("Sunday"))) {
        if (this.mounted) {
          setState(() {
            enableJoinCall = true;
          });
        }
      } else {
        if (this.mounted) {
          setState(() {
            enableJoinCall = false;
          });
        }
      }
    });

    return Column(
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 5),
            child: Card(
              color: AppColors.cardColor,
              elevation: 6,
              child: ListTile(
                hoverColor: AppColors.cardColor,
                title: Text(
                  widget.title,
                  style: TextStyle(fontSize: 14.0),
                ),
                subtitle: Column(
                  children: [
                    Text(widget.time),
                    Visibility(
                      visible: (currentDateTime.isBefore(endDate) &&
                              currentDateTime.isAfter(startDate) &&
                              currentDateTime.isAfter(fiveMinutesBeforeStartTime) &&
                              currentDateTime.isBefore(minutesAfterStartTime) &&
                              trainerStatus == "Offline")
                          ? true
                          : false,
                      child: Text("Trainer is offline",
                          style: TextStyle(fontSize: 12, color: Colors.red)),
                    ),
                    /*Visibility(
                      visible: (currentDateTime.isBefore(endDate) &&
                              currentDateTime.isAfter(startDate) &&
                              currentDateTime
                                  .isAfter(fiveMinutesBeforeStartTime) &&
                              currentDateTime.isBefore(minutesAfterStartTime) &&
                              trainerStatus == "Busy")
                          ? true
                          : false,
                      child: Text("Trainer is Busy",
                          style: TextStyle(fontSize: 12, color: Colors.red)),
                    ),*/
                  ],
                ),
                trailing: ElevatedButton.icon(
                    onPressed: enableJoinCall
                        ? () async {
                            final prefs = await SharedPreferences.getInstance();
                            var data = prefs.get('data');
                            Map res = jsonDecode(data);
                            var iHLUserId = res['User']['id'];

                            Get.offNamedUntil(Routes.CallWaitingScreen, (route) => false,
                                arguments: [
                                  widget.courseId.toString(),
                                  iHLUserId.toString(),
                                  widget.trainerId,
                                  "SubscriptionCall",
                                ]);
                          }
                        : () async {
                            showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Info'),
                                  content: Text(
                                      'You can join the call at least 5 mins before course start time'),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text(
                                        'Okay',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0),
                      ),
                      primary: enableJoinCall ? Colors.green : Colors.grey,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    icon: Icon(
                      Icons.phone,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Join",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            )),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    httpStatus();
    subscribeSubscriptionApproved();
    getTrainerStatus();
    getSubscriptionsUserDetails();
    getCourseImageURL();

    String courseDurationFromApi = widget.duration;

    String courseStartDuration = courseDurationFromApi.substring(0, 10);

    String courseEndDuration = courseDurationFromApi.substring(13, 23);

    DateTime startDate = new DateFormat("yyyy-MM-dd").parse(courseStartDuration);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String startDateFormattedToString = formatter.format(startDate);

    DateTime endDate = new DateFormat("yyyy-MM-dd").parse(courseEndDuration);
    String endDateFormattedToString = formatter.format(endDate);

    finalDuration = startDateFormattedToString + " - " + endDateFormattedToString;
  }

  @override
  void dispose() {
    super.dispose();
    session?.close();
    session1?.close();
  }
}
