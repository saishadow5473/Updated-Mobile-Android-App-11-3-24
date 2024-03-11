import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:ihl/models/invoice.dart';
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

class ExpiredSubscriptionTile extends StatefulWidget {
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
  ExpiredSubscriptionTile(
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
  _ExpiredSubscriptionTileState createState() => _ExpiredSubscriptionTileState();
}

class _ExpiredSubscriptionTileState extends State<ExpiredSubscriptionTile> {
  String finalDuration;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: AppColors.cardColor,
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
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: double.parse(widget.courseFee.toLowerCase() == 'free'
                                      ? "0"
                                      : widget.courseFee) >=
                                  1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: PopupMenuButton<String>(
                                  onSelected: (k) async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    print(invoiceNumber.toString());
                                    // AwesomeNotifications().cancelAll();
                                    bool permissionGrandted = false;
                                    if (Platform.isAndroid) {
                                      final deviceInfo = await DeviceInfoPlugin().androidInfo;
                                      Map<Permission, PermissionStatus> _status;
                                      if (deviceInfo.version.sdkInt <= 32) {
                                        _status = await [Permission.storage].request();
                                      } else {
                                        _status =
                                            await [Permission.photos, Permission.videos].request();
                                      }
                                      _status.forEach((permission, status) {
                                        if (status == PermissionStatus.granted) {
                                          permissionGrandted = true;
                                        }
                                      });
                                    } else {
                                      permissionGrandted = true;
                                    }
                                    if (permissionGrandted) {
                                      // SharedPreferences prefs =
                                      //     await SharedPreferences.getInstance();
                                      prefs.setString("userFirstNameFromHistory", firstName);
                                      prefs.setString("userLastNameFromHistory", lastName);
                                      prefs.setString("userEmailFromHistory", email);
                                      prefs.setString("userContactFromHistory", mobileNumber);
                                      prefs.setString("subsIdFromHistory", widget.subscription_id);
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
                                      new Future.delayed(new Duration(seconds: 3), () async {
                                        Invoice invoiceModel = await ConsultApi()
                                            .getInvoiceNumber(ihlUserId, widget.subscription_id);
                                        invoiceModel.ihlInvoiceNumbers = prefs.getString('invoice');
                                        subscriptionBillView(context, widget.title, widget.provider,
                                            currentSubscription, invoiceNumber,
                                            invoiceModel: invoiceModel);
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
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        value: 'Download Invoice',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.download,
                                              color: AppColors.primaryColor,
                                            ),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Text('Download Invoice'),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                widget.title,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                              ),
                            ),
                            Text(
                              "Duration: " + finalDuration,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                "Time: " + widget.time,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            Text("By " + widget.provider),
                            SizedBox(
                              height: 5.0,
                            ),
                            widget.isCancelled == true
                                ? Text(
                                    "Subscription Cancelled",
                                    style: TextStyle(color: Colors.red, fontSize: 16.0),
                                  )
                                : widget.isRejected == true
                                    ? Text(
                                        "Subscription Rejected",
                                        style: TextStyle(color: Colors.red, fontSize: 16.0),
                                      )
                                    : Text(
                                        "Subscription Expired",
                                        style: TextStyle(color: Colors.red, fontSize: 16.0),
                                      ),
                            Visibility(
                              // visible: widget.courseFee == '0' || widget.courseFee == 'free'
                              //     ? false
                              //     : true,
                              visible: false,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  primary: AppColors.primaryColor,
                                ),
                                child: Text('Invoice',
                                    style: TextStyle(
                                      fontSize: 16,
                                    )),
                                onPressed: () async {

                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  print(invoiceNumber.toString());
                                  // AwesomeNotifications().cancelAll();
                                  bool permissionGrandted = false;
                                  if (Platform.isAndroid) {
                                    final deviceInfo = await DeviceInfoPlugin().androidInfo;
                                    Map<Permission, PermissionStatus> _status;
                                    if (deviceInfo.version.sdkInt <= 32) {
                                      _status = await [Permission.storage].request();
                                    } else {
                                      _status =
                                          await [Permission.photos, Permission.videos].request();
                                    }
                                    _status.forEach((permission, status) {
                                      if (status == PermissionStatus.granted) {
                                        permissionGrandted = true;
                                      }
                                    });
                                  } else {
                                    permissionGrandted = true;
                                  }
                                  if (permissionGrandted) {
                                    // SharedPreferences prefs =
                                    //     await SharedPreferences.getInstance();
                                    prefs.setString("userFirstNameFromHistory", firstName);
                                    prefs.setString("userLastNameFromHistory", lastName);
                                    prefs.setString("userEmailFromHistory", email);
                                    prefs.setString("userContactFromHistory", mobileNumber);
                                    prefs.setString("subsIdFromHistory", widget.subscription_id);
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
                                    Invoice invoiceModel = await ConsultApi()
                                        .getInvoiceNumber(ihlUserId, widget.subscription_id);
                                    print(invoiceModel.ihlInvoiceNumbers);
                                    new Future.delayed(new Duration(seconds: 3), () {
                                      subscriptionBillView(context, widget.title, widget.provider,
                                          currentSubscription, invoiceNumber,
                                          invoiceModel: invoiceModel);
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
      ],
    );
  }

  @override
  void initState() {
    getData();
    getUserDetails();
    super.initState();
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
    // Commented getUserDetails API and using SharedPreference instead

    // SharedPreferences prefs1 = await SharedPreferences.getInstance();
    // var data1 = prefs1.get('data');
    // Map res = jsonDecode(data1);
    // var iHLUserId = res['User']['id'];
    // final getUserDetails = await http.post(
    //   API.iHLUrl+"/consult/get_user_details",
    //   body: jsonEncode(<String, dynamic>{
    //     'ihl_id': iHLUserId,
    //   }),
    // );
    // if (getUserDetails.statusCode == 200) {
    //   // final userDetailsResponse = await SharedPreferences.getInstance();
    //   // userDetailsResponse.setString(
    //   //     SPKeys.userDetailsResponse, getUserDetails.body);
    // } else {
    //   print(getUserDetails.body);
    // }

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
        // var currentDateTime = new DateTime.now();

        // for (int i = 0; i < currentSubscription.length; i++) {
        //   var duration = currentSubscription[i]["course_duration"];
        //   var time = currentSubscription[i]["course_time"];
        //   var approvelStatus = currentSubscription[i]["approval_status"];

        //   String courseDurationFromApi = duration;
        //   String courseTimeFromApi = time;

        //   String courseStartTime;
        //   String courseEndTime;

        //   String courseStartDuration = courseDurationFromApi.substring(0, 10);

        //   String courseEndDuration = courseDurationFromApi.substring(13, 23);

        //   DateTime startDate =
        //       new DateFormat("yyyy-MM-dd").parse(courseStartDuration);
        //   final DateFormat formatter = DateFormat('yyyy-MM-dd');
        //   String startDateFormattedToString = formatter.format(startDate);

        //   DateTime endDate =
        //       new DateFormat("yyyy-MM-dd").parse(courseEndDuration);
        //   String endDateFormattedToString = formatter.format(endDate);
        //   if (courseTimeFromApi[2].toString() == ':' &&
        //       courseTimeFromApi[13].toString() != ':') {
        //     var tempcourseEndTime = '';
        //     courseStartTime = courseTimeFromApi.substring(0, 8);
        //     for (var i = 0; i < courseTimeFromApi.length; i++) {
        //       if (i == 10) {
        //         tempcourseEndTime += '0';
        //       } else if (i > 10) {
        //         tempcourseEndTime += courseTimeFromApi[i];
        //       }
        //     }
        //     courseEndTime = tempcourseEndTime;
        //   } else if (courseTimeFromApi[2].toString() != ':') {
        //     var tempcourseStartTime = '';
        //     var tempcourseEndTime = '';

        //     for (var i = 0; i < courseTimeFromApi.length; i++) {
        //       if (i == 0) {
        //         tempcourseStartTime = '0';
        //       } else if (i > 0 && i < 8) {
        //         tempcourseStartTime += courseTimeFromApi[i - 1];
        //       } else if (i > 9) {
        //         tempcourseEndTime += courseTimeFromApi[i];
        //       }
        //     }
        //     courseStartTime = tempcourseStartTime;
        //     courseEndTime = tempcourseEndTime;
        //     if (courseEndTime[2].toString() != ':') {
        //       var tempcourseEndTime = '';
        //       for (var i = 0; i <= courseEndTime.length; i++) {
        //         if (i == 0) {
        //           tempcourseEndTime += '0';
        //         } else {
        //           tempcourseEndTime += courseEndTime[i - 1];
        //         }
        //       }
        //       courseEndTime = tempcourseEndTime;
        //     }
        //   } else {
        //     courseStartTime = courseTimeFromApi.substring(0, 8);
        //     courseEndTime = courseTimeFromApi.substring(11, 19);
        //   }

        //   DateTime startTime = DateFormat.jm().parse(courseStartTime);
        //   DateTime endTime = DateFormat.jm().parse(courseEndTime);

        //   String startingTime = DateFormat("HH:mm:ss").format(startTime);
        //   String endingTime = DateFormat("HH:mm:ss").format(endTime);
        //   String startDateAndTime =
        //       startDateFormattedToString + " " + startingTime;
        //   String endDateAndTime = endDateFormattedToString + " " + endingTime;
        //   DateTime finalStartDateTime =
        //       new DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
        //   DateTime finalEndDateTime =
        //       new DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);
        //   if (finalEndDateTime.isAfter(currentDateTime) ||
        //       approvelStatus == "Cancelled" ||
        //       approvelStatus == "cancelled") {
        //     list.add(currentSubscription[i]);
        //   }
        // }
        // hasSubscription = true;
      });
    }
  }
}
