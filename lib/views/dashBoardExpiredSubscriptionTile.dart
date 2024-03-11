import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/repositories/api_consult.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ihl/views/view_past_bill/view_subscription_invoice.dart';

class DashBoardExpiredSubscriptionTile extends StatefulWidget {
  final String trainerId;
  final String trainerName;
  final String title;
  final String duration;
  final String time;
  final String provider;
  final bool isExpired;
  final bool isCancelled;
  final bool isRejected;
  final List courseOn;
  final String courseTime;
  final subscription_id;
  final String courseId;
  final String courseFee;

  DashBoardExpiredSubscriptionTile(
      {this.trainerId,
      this.trainerName,
      this.title,
      this.duration,
      this.time,
      this.provider,
      this.isExpired,
      this.isCancelled,
      this.isRejected,
      this.courseTime,
      this.courseOn,
      this.subscription_id,
      this.courseId,
      this.courseFee});
  @override
  _DashBoardExpiredSubscriptionTileState createState() => _DashBoardExpiredSubscriptionTileState();
}

class _DashBoardExpiredSubscriptionTileState extends State<DashBoardExpiredSubscriptionTile> {
  String finalDuration;
  int differenceInDays;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 4.2,
          width: MediaQuery.of(context).size.width / 1.24,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            // color: AppColors.cardColor,
            color: Color.fromRGBO(35, 107, 254, 0.8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      /*Padding(
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
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                                subtitle: widget.isCancelled == true
                                    ? Text(
                                        "Subscription Cancelled",
                                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                                      )
                                    : widget.isRejected == true
                                        ? Text(
                                            "Subscription Rejected",
                                            style: TextStyle(color: Colors.white, fontSize: 16.0),
                                          )
                                        : Text(
                                            "Subscription Expired",
                                            style: TextStyle(color: Colors.white, fontSize: 16.0),
                                          ),
                                leading: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        topRight: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0),
                                      ),
                                      color: Colors.white),
                                  height: 45,
                                  width: 45,
                                  child:

                                      // CircleAvatar(
                                      // radius: 60.0,
                                      // backgroundImage: imageCourse == null
                                      //     ? null
                                      //     : imageCourse.image,
                                      // widget.consultant['course_img_url'] == null
                                      //     ? null
                                      //     : Image.memory(base64Decode(
                                      //             widget.consultant['course_img_url']))
                                      //         .image,
                                      // backgroundColor: AppColors.primaryAccentColor,
                                      // ),
                                      Padding(
                                    padding: const EdgeInsets.all(3.5),
                                    child: Image.asset(
                                      'assets/images/newmt.jpg',
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
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
                                height: MediaQuery.of(context).size.height / 70,
                              ),
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
                                        size: 15.0,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Duration : " + differenceInDays.toString(),
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          ' days',
                                          style: TextStyle(
                                              fontSize: 12.0,
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
                                      width: 10.0,
                                    ),
                                    Container(
                                      child: Icon(
                                        Icons.timer,
                                        color: Colors.white,
                                        size: 15.0,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      'Total:  ' + differenceInTime.toString() + '  hrs',
                                      // widget.time,
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
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
                                  height: MediaQuery.of(context).size.height / 35),
                              Visibility(
                                visible: widget.courseFee == '0' || widget.courseFee == 'free'
                                    ? false
                                    : true,
                                child: Container(
                                  height: MediaQuery.of(context).size.height / 24,
                                  width: MediaQuery.of(context).size.width / 3.5,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        primary: Colors.white),
                                    child: Text('Invoice',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.w600)),
                                    onPressed: () async {

                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      invoiceNumber = prefs.getString('invoice');
                                      print(invoiceNumber.toString());
                                      // AwesomeNotifications().cancelAll();
                                      bool permissionGrandted = false;
                                      if(Platform.isAndroid){
                                        final deviceInfo =
                                        await DeviceInfoPlugin().androidInfo;
                                        Map<Permission, PermissionStatus> _status;
                                        if (deviceInfo.version.sdkInt <= 32) {
                                          _status =
                                          await [Permission.storage].request();
                                        } else {
                                          _status = await [
                                            Permission.photos,
                                            Permission.videos
                                          ].request();
                                        }
                                        _status.forEach((permission, status) {
                                          if (status == PermissionStatus.granted) {
                                            permissionGrandted = true;
                                          }
                                        });}else{
                                        permissionGrandted =true;
                                      }
                                      if (permissionGrandted) {
                                        // SharedPreferences prefs =
                                        //     await SharedPreferences.getInstance();
                                        prefs.setString("userFirstNameFromHistory", firstName);
                                        prefs.setString("userLastNameFromHistory", lastName);
                                        prefs.setString("userEmailFromHistory", email);
                                        prefs.setString("userContactFromHistory", mobileNumber);
                                        prefs.setString(
                                            "subsIdFromHistory", widget.subscription_id);
                                        prefs.setString("useraddressFromHistory", address);
                                        prefs.setString("userareaFromHistory", area);
                                        prefs.setString("usercityFromHistory", city);
                                        prefs.setString("userstateFromHistory", state);
                                        prefs.setString("userpincodeFromHistory", pincode);
                                        Get.snackbar(
                                          '',
                                          'Invoice will be saved in your mobile!',
                                          backgroundColor: AppColors.primaryAccentColor,
                                          colorText: Colors.white,
                                          duration: Duration(seconds: 5),
                                          isDismissible: false,
                                        );
                                        invoiceNumber = ConsultApi()
                                            .getInvoiceNumber(ihlUserId, widget.subscription_id);
                                        print(invoiceNumber);
                                        new Future.delayed(new Duration(seconds: 3), () {
                                          subscriptionBillView(context, widget.title,
                                              widget.provider, currentSubscription, invoiceNumber);
                                        });
                                      } else {
                                        Get.snackbar('Storage Access Denied',
                                            'Allow Storage permission to continue',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            duration: Duration(seconds: 5),
                                            isDismissible: false,
                                            mainButton: TextButton(
                                                onPressed: () async {
                                                  await openAppSettings();
                                                },
                                                child: Text('Allow')));
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    getData();
    getUserDetails();
    getExpiredSubscriptionHistoryData();
    super.initState();
    String courseDurationFromApi = widget.duration;

    String courseStartDuration = courseDurationFromApi.substring(0, 10);

    String courseEndDuration = courseDurationFromApi.substring(13, 23);

    DateTime startDate = new DateFormat("yyyy-MM-dd").parse(courseStartDuration);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String startDateFormattedToString = formatter.format(startDate);

    DateTime endDate = new DateFormat("yyyy-MM-dd").parse(courseEndDuration);
    String endDateFormattedToString = formatter.format(endDate);
    differenceInDays = endDate.difference(startDate).inDays;
    // differenceInTime = endTime.difference(startTime).inMinutes;
    finalDuration = startDateFormattedToString + " - " + endDateFormattedToString;
  }

  String firstName, lastName, email, mobileNumber, age, gender, finalGender;
  String address;
  String pincode;
  String area;
  String state;
  String city;
  //     weight;
  // var bmi;
  int finalAge;
  var currentSubscription;
  var subscriptions;
  var list = [];
  var ihlUserId;
  var invoiceNumber;

  // bool expanded = true;
  bool hasSubscription = false;
  // List subscriptions = [];
  List expiredSubscriptions;
  var elist = [];
  String iHLUserId;
  bool loading = true;
  int differenceInTime;

  Future getExpiredSubscriptionHistoryData() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    iHLUserId = res['User']['id'];
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
                i["approval_status"] == "cancelled" ||
                i["approval_status"] == "Cancelled" ||
                i["approval_status"] == "Rejected" ||
                i["approval_status"] == "rejected")
            .toList();

        // ignore: unused_local_variable
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

          String startingTime = DateFormat("H:mm:ss").format(startTime);
          String endingTime = DateFormat("H:mm:ss").format(endTime);
          String startDateAndTime = startDateFormattedToString + " " + startingTime;
          String endDateAndTime = endDateFormattedToString + " " + endingTime;
          DateTime finalStartDateTime =
              new DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
          DateTime finalEndDateTime = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);
          differenceInTime = endTime.difference(startTime).inHours;
          elist.add(expiredSubscriptions[i]);
        }

        hasSubscription = true;
      });
    }
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);
    firstName = res['User']['firstName'];
    lastName = res['User']['lastName'];
    ihlUserId = res['User']['id'];
    firstName ??= "";
    lastName ??= "";
    email = res['User']['email'];
    mobileNumber = res['User']['mobileNumber'];
    age = res['User']['dateOfBirth'];
    address = res['User']['address'].toString();
    address = address == 'null' ? '' : address;
    area = res['User']['area'].toString();
    area = area == 'null' ? '' : area;
    city = res['User']['city'].toString();
    city = city == 'null' ? '' : city;
    state = res['User']['state'].toString();
    state = state == 'null' ? '' : state;
    pincode = res['User']['pincode'].toString();
    pincode = pincode == 'null' ? '' : pincode;
    gender = res['User']['gender'];
    if (gender == "m" || gender == "M" || gender == "male" || gender == "Male") {
      finalGender = "Male";
    } else {
      finalGender = "Female";
    }
    age = age.replaceAll(" ", "");
    if (age.contains("-")) {
      DateTime tempDate = new DateFormat("dd-MM-yyyy").parse(age);
      DateTime currentDate = DateTime.now();
      finalAge = currentDate.year - tempDate.year;
    } else if (age.contains("/")) {
      DateTime tempDate = new DateFormat("MM/dd/yyyy").parse(age.trim());
      DateTime currentDate = DateTime.now();
      finalAge = currentDate.year - tempDate.year;
    }
    //   invoiceNumber =  ConsultApi().getInvoiceNumber(ihlUserId, widget.subscription_id);
    //   print(invoiceNumber);
    // // SharedPreferences pref = await SharedPreferences.getInstance();
    // invoiceNumber = prefs.getString('invoice');
    // print(invoiceNumber.toString());
  }

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);

    Map teleConsulResponse = json.decode(data);
    // loading = false;
    if (teleConsulResponse['my_subscriptions'] == null ||
        !(teleConsulResponse['my_subscriptions'] is List) ||
        teleConsulResponse['my_subscriptions'].isEmpty) {
      if (this.mounted) {
        setState(() {
          // hasSubscription = false;
        });
      }
      return;
    }
    if (this.mounted) {
      setState(() {
        subscriptions = teleConsulResponse['my_subscriptions'];
        currentSubscription =
            subscriptions.where((i) => i['subscription_id'] == widget.subscription_id).toList();
      });
    }
  }
}
