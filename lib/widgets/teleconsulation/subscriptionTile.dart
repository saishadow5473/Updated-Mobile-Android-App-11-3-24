// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/teleconsultation/mySubscriptions.dart';
import 'package:ihl/widgets/teleconsulation/selectClassSlot.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:strings/strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Getx/controller/SubscriptionHistoryController.dart';
import '../../models/invoice.dart';
import '../../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import '../../repositories/api_consult.dart';
import '../../views/teleconsultation/MySubscription.dart';
import '../../views/view_past_bill/view_subscription_invoice.dart';

// ignore: must_be_immutable
class SubscriptionTile extends StatefulWidget {
  final String trainerId;
  final String trainerName;
  final String title;
  final String duration;
  final String time;
  final String provider;
  bool isApproved;
  bool isRejected;
  bool isRequested;
  bool isCancelled;
  bool isCompleted =
      false; // purpose of the value hide the join class button on completed subscription
  final List courseOn;
  final String courseTime;
  final subscription_id;
  final String courseId;
  final String courseType;
  final String course_fees;
  String external_url;

  SubscriptionTile(
      {this.trainerId,
      this.external_url,
      this.course_fees,
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
      this.isCompleted,
      this.subscription_id,
      this.courseId,
      this.courseType});

  @override
  _SubscriptionTileState createState() => _SubscriptionTileState();
}

class _SubscriptionTileState extends State<SubscriptionTile> {
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

  Text status() {
    if (widget.isRequested == true) {
      return const Text(
        "Subscription under Request",
        style: TextStyle(color: AppColors.primaryAccentColor),
      );
    }
    if (widget.isApproved == true) {
      return const Text(
        "Subscription Approved",
        style: TextStyle(color: Colors.green),
      );
    }
    if (widget.isRejected == true) {
      return const Text(
        "Subscription Rejected",
        style: TextStyle(color: Colors.red),
      );
    }
    if (widget.isCancelled == true) {
      return const Text(
        "Subscription Cancelled",
        style: TextStyle(color: Colors.red),
      );
    }
    return const Text(
      "Subscription under Request",
      style: TextStyle(color: AppColors.primaryAccentColor),
    );
  }

  void httpStatus() async {
    http.Response response = await _client.post(
      Uri.parse('${API.iHLUrl}/consult/getConsultantLiveStatus'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, dynamic>{
        "consultant_id": [widget.trainerId]
      }),
    );
    if (response.statusCode == 200) {
      if (response.body != '"[]"') {
        String parsedString = response.body.replaceAll('&quot', '"');
        String parsedString1 = parsedString.replaceAll(";", "");
        String parsedString2 = parsedString1.replaceAll('"[', '[');
        String parsedString3 = parsedString2.replaceAll(']"', ']');
        dynamic finalOutput = json.decode(parsedString3);
        String doctorId = widget.trainerId;
        if (doctorId == finalOutput[0]['consultant_id']) {
          trainerStatus = camelize(finalOutput[0]['status'].toString());
          if (trainerStatus == null ||
              trainerStatus == "" ||
              trainerStatus == "null" ||
              trainerStatus == "Null") {
            trainerStatus = "Offline";
          } else {
            trainerStatus = camelize(finalOutput[0]['status'].toString());
          }
          if (this.mounted) setState(() {});
        }
      } else {}
    } else {}
  }

  void cancelSubscription(String subscriptionId, String canceledBy, String reason) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _controller = Get.put(SubScriptionHistoryController());
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    iHLUserId = res['User']['id'];

    var apiToken = prefs.get('auth_token');
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/cancel_subscription'),

      headers: {
        'Content-Type': 'application/json',
        'ApiToken': API.headerr['ApiToken'] != "null"
            ? '${API.headerr['ApiToken']}'
            : "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
        'Token': '${API.headerr['Token']}',
      },
      // headers: {'ApiToken': apiToken},
      body: jsonEncode(<String, dynamic>{
        "subscription_id": subscriptionId.toString(),
        "canceled_by": canceledBy.toString(),
        "reason": reason.toString(),
      }),
    );
    debugPrint(response.body.toString());
    if (response.statusCode == 200) {
      if (response.body != '"[]"') {
        String parsedString = response.body.replaceAll('&quot', '"');
        String parsedString1 = parsedString.replaceAll(";", "");
        String parsedString2 = parsedString1.replaceAll('"[', '[');
        String parsedString3 = parsedString2.replaceAll(']"', ']');
        dynamic finalOutput = json.decode(parsedString3);
        String status = finalOutput["status"];
        if (status == "cancel_success") {
          ///first updating the database
          await nonCurativeApproveDeclineHostAPI(
              widget.provider, widget.subscription_id, "Cancelled");
          // Updating getUserDetails API
          final getUserDetails =
              await _client.post(Uri.parse("${API.iHLUrl}/consult/get_user_details"),
                  headers: {
                    'Content-Type': 'application/json',
                    'ApiToken': '${API.headerr['ApiToken']}',
                    'Token': '${API.headerr['Token']}',
                  },
                  body: jsonEncode(<String, String>{
                    'ihl_id': iHLUserId,
                  }));

          // nonCurativeApproveDeclineHostAPI(
          //     widget.provider, widget.subscription_id, "Cancelled");
          AwesomeDialog(
                  context: context,
                  animType: AnimType.topSlide,
                  headerAnimationLoop: true,
                  dialogType: DialogType.success,
                  dismissOnTouchOutside: false,
                  dismissOnBackKeyPress: false,
                  title: 'Success!',
                  desc: "Subscription Cancelled Successfully!",
                  btnOkOnPress: () async {
                    if (getUserDetails.statusCode == 200) {
                      if (mounted) {
                        setState(() {
                          isChecking = false;
                        });
                      }
                      final userDetailsResponse = await SharedPreferences.getInstance();
                      userDetailsResponse.remove(SPKeys.userDetailsResponse);
                      userDetailsResponse.setString(
                          SPKeys.userDetailsResponse, getUserDetails.body);
                    } else {
                      debugPrint(getUserDetails.body.toString());
                    }
                    localSotrage.write("healthEmarketNavigation", false);
                    _controller.updateList();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const MySubscription(afterCall: false, cancelEnabled: true)),
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
          animType: AnimType.topSlide,
          headerAnimationLoop: true,
          dialogType: DialogType.error,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          autoDismiss: false,
          title: 'Failed!',
          desc: "Subscription Cancellation Unsuccessful. Please Try Again.",
          btnOkOnPress: () {
            localSotrage.write("healthEmarketNavigation", false);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const MySubscription(afterCall: false, cancelEnabled: true)),
                (Route<dynamic> route) => false);
          },
          btnOkColor: Colors.red,
          btnOkText: 'Proceed',
          btnOkIcon: Icons.refresh,
          onDismissCallback: (_) => null).show();
      print(response.body);
    }
  }

  Future nonCurativeApproveDeclineHostAPI(String company_name, String subsID, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiToken = prefs.get('auth_token');
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/approve_or_reject_subscription'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      // headers: {'ApiToken': apiToken},
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

    ///from here
    var todays_Date = new DateFormat("yyyy-MM-dd").parse(DateTime.now().toString());
    var formatted_todays_date = formatter.format(todays_Date);
    String startTimeWithTodaysDateString = formatted_todays_date + " " + startingTime;
    String endTimeWithTodaysDateString = formatted_todays_date + " " + endingTime;
    DateTime TodaysDateWithStartTime = new DateFormat("yyyy-MM-dd HH:mm:ss")
        .parse(startTimeWithTodaysDateString)
        .subtract(const Duration(minutes: 0));
    DateTime TodaysDateWithEndTime =
        new DateFormat("yyyy-MM-dd HH:mm:ss").parse(endTimeWithTodaysDateString);

    ///till here

    DateTime startTimeOnly = new DateFormat("HH:mm:ss").parse(startingTime);
    DateTime endTimeOnly = new DateFormat("HH:mm:ss").parse(endingTime);
    var classStartingTime = DateTime.parse(startDateAndTime);

    differenceInTime = endTime.difference(startTime).inMinutes;

    differenceInDays = endDate.difference(startDate).inDays;

    DateTime fiveMinutesBeforeStartTime = finalStartDateTime.subtract(const Duration(minutes: 5));
    DateTime minutesAfterStartTime = classStartingTime.add(Duration(minutes: differenceInTime));

    if ((currentDateTime.isBefore(finalEndDateTime) &&
            // currentDateTime.isAfter(finalStartDateTime)) &&
            currentDateTime.isAfter(fiveMinutesBeforeStartTime)) &&
        currentDateTime.isAfter(fiveMinutesBeforeStartTime) &&
        // currentDateTime.isBefore(minutesAfterStartTime) &&
        (currentDateTime.isAfter(TodaysDateWithStartTime) &&
            currentDateTime.isBefore(TodaysDateWithEndTime)) &&
        // (currentDateTime.hour >= startTime.hour &&
        //     currentDateTime.hour <= endTime.hour) &&
        // // currentDateTime.hour < endTime.hour) &&
        (trainerStatus == "Online" || trainerStatus == "Busy") &&
        (widget.courseType.toLowerCase() == "daily" ||
            (widget.courseOn.contains("Monday") ||
                    widget.courseOn.contains("Tuesday") ||
                    widget.courseOn.contains("Wednesday") ||
                    widget.courseOn.contains("Thursday") ||
                    widget.courseOn.contains("Friday") ||
                    widget.courseOn.contains("Saturday") ||
                    widget.courseOn.contains("Sunday")) &&
                external_url == null)) {
      if (this.mounted) {
        setState(() {
          enableJoinCall = true;
        });
      }
    } else {
      //Checking enternal url for class⚪⚪
      if (external_url != null && finalEndDateTime.isAfter(currentDateTime)) {
        log("Timer triggered for the class ${widget.title}");
        log(TodaysDateWithStartTime.difference(currentDateTime).inMinutes.toString());
        //it is used to get the diffrence between the provided time and the current time so we can
        // easily calculate when we need to enable the join class button ⚪⚪
        Duration dur = TodaysDateWithStartTime.difference(currentDateTime);
        // this is to set duration as zero, cause we need to enable the join class button once the duration is zero.
        // in some of scenario's we has negative values to avoid that type of scenario's i have provided a condition
        // to avoid the negative values.⚪⚪⚪
        if (dur.inMinutes < 0) {
          dur = Duration.zero;
          log(dur.inMinutes.toString());
        }
        //the de value stores the end time in minitues to disable the join class button⚪⚪
        int de = TodaysDateWithEndTime.subtract(
                Duration(hours: currentDateTime.hour, minutes: currentDateTime.minute))
            .minute;
        if (TodaysDateWithEndTime.isAfter(currentDateTime) && de > 0) {
          //This timer is used to enable the class by assigning the start time in Duration type $dur ⚪⚪
          triggerClass ??= Timer(dur, () {
            //After the time has arrived we need to enable the button so in this case we are enabling it in below code ⚪⚪
            enableJoinCall = true;
            log("enable join call button triggered");
            if (mounted) setState(() {});
          });
          //This timer is used to disable the class by assigning the end time in mintues $de ⚪⚪
          endclassTimer = Timer(Duration(minutes: de), () {
            // After the time has reached the class's end time this timer will disables the join call button ⚪⚪
            enableJoinCall = false;
            log("disable join call button triggered");
            if (mounted) setState(() {});
          });
          //this is used  to just know the timer is on Current state or not ⚪⚪
          debugPrint("${endclassTimer != null} end class timer ${endclassTimer.tick}");
          debugPrint("${triggerClass != null} start class timer ${triggerClass.tick}");
        }
        if (de < 0 && dur.inMinutes < 0) {
          enableJoinCall = false;
          setState(() {});
        }
      } else {
        if (mounted) {
          setState(() {
            enableJoinCall = false;
          });
        }
      }
    }
    DateTime duration = DateTime.parse(widget.duration.toString().substring(13, 23));
    DateTime datenow = DateTime.parse(DateTime.now().toString().substring(0, 10));
    // print(duration.isBefore(datenow));
    return duration.isBefore(datenow)
        ? SizedBox()
        : Column(
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
                          /* Padding(
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
                                    visible: double.parse(
                                            widget.course_fees.toString().toLowerCase() == 'free'
                                                ? "0"
                                                : widget.course_fees.toString()) >=
                                        1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: PopupMenuButton<String>(
                                        onSelected: (k) async {
                                          var currentSubscription =
                                              await getDataSubID(subID: widget.subscription_id);
                                          String address;
                                          String pincode;
                                          String area;
                                          String state;
                                          String city;
                                          SharedPreferences prefs =
                                              await SharedPreferences.getInstance();
                                          var data = prefs.get('data');
                                          Map res = jsonDecode(data);
                                          prefs.setString(
                                              "useraddressFromHistory", res['User']['address']);
                                          prefs.setString(
                                              "userareaFromHistory", res['User']['area']);
                                          prefs.setString(
                                              "usercityFromHistory", res['User']['city']);
                                          prefs.setString(
                                              "userstateFromHistory", res['User']['state']);
                                          prefs.setString(
                                              "userpincodeFromHistory", res['User']['pincode']);
                                          String ihlId = prefs.getString("ihlUserId");
                                          String apiToken = prefs.get('auth_token');
                                          var email = prefs.get('email');

                                          var firstName = res['User']['firstName'];
                                          var lastName = res['User']['lastName'];
                                          var mobile = res['User']['mobileNumber'];

                                          // AwesomeNotifications().cancelAll();
                                          bool permissionGrandted = false;
                                          if (Platform.isAndroid) {
                                            final deviceInfo = await DeviceInfoPlugin().androidInfo;
                                            Map<Permission, PermissionStatus> _status;
                                            if (deviceInfo.version.sdkInt <= 32) {
                                              _status = await [Permission.storage].request();
                                            } else {
                                              _status = await [Permission.photos, Permission.videos]
                                                  .request();
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
                                            prefs.setString("userFirstNameFromHistory", firstName);
                                            prefs.setString("userLastNameFromHistory", lastName);
                                            prefs.setString("userEmailFromHistory", email);
                                            prefs.setString("userContactFromHistory", mobile);
                                            prefs.setString(
                                                "subsIdFromHistory", widget.subscription_id);
                                            Get.snackbar(
                                              '',
                                              'Invoice will be saved in your mobile!',
                                              backgroundColor: AppColors.primaryAccentColor,
                                              colorText: Colors.white,
                                              duration: const Duration(seconds: 5),
                                              isDismissible: false,
                                            );
                                            Invoice invoiceModel = await ConsultApi()
                                                .getInvoiceNumber(ihlId, widget.subscription_id);
                                            invoiceModel.ihlInvoiceNumbers =
                                                prefs.getString('invoice');
                                            Future<void>.delayed(const Duration(seconds: 3), () {
                                              subscriptionBillView(
                                                  context,
                                                  widget.title,
                                                  widget.provider,
                                                  currentSubscription,
                                                  invoiceModel.ihlInvoiceNumbers,
                                                  invoiceModel: invoiceModel);
                                            });
                                          } else {
                                            Get.snackbar('Storage Access Denied',
                                                'Allow Storage permission to continue',
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                                duration: const Duration(seconds: 5),
                                                isDismissible: false,
                                                mainButton: TextButton(
                                                    onPressed: () async {
                                                      await openAppSettings();
                                                    },
                                                    child: const Text('Allow')));
                                          }
                                        },
                                        itemBuilder: (context) {
                                          return [
                                            PopupMenuItem(
                                              value: 'Download Invoice',
                                              child: Row(
                                                children: const <Widget>[
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
                                  Text(
                                    widget.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16.0),
                                  ),
                                  Text(
                                    "Duration: $finalDuration",
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  Text(
                                    "Time: ${widget.time}",
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  Text("By ${widget.trainerName}"),
                                  status(),
                                  widget.isApproved && !widget.isCompleted
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                backgroundColor:
                                                    enableJoinCall ? Colors.green : Colors.grey,
                                                textStyle: const TextStyle(color: Colors.white),
                                              ),
                                              onPressed: enableJoinCall
                                                  ? () async {
                                                      //if the class has external_url we are navigating to the provided url's content ⚪⚪
                                                      if (external_url != null) {
                                                        Uri url = Uri.parse(external_url);
                                                        await launchUrl(url,
                                                            mode: LaunchMode.externalApplication);
                                                      } else {
                                                        SharedPreferences prefs =
                                                            await SharedPreferences.getInstance();
                                                        var data = prefs.get('data');
                                                        Map res = jsonDecode(data);
                                                        String iHLUserId = res['User']['id'];

                                                        prefs.setString(
                                                            "userIDFromSubscriptionCall",
                                                            iHLUserId);
                                                        prefs.setString(
                                                            "consultantIDFromSubscriptionCall",
                                                            widget.trainerId);
                                                        prefs.setString(
                                                            "subscriptionIDFromSubscriptionCall",
                                                            widget.subscription_id);
                                                        prefs.setString(
                                                            "courseNameFromSubscriptionCall",
                                                            widget.title);
                                                        prefs.setString(
                                                            "courseIDFromSubscriptionCall",
                                                            widget.courseId);
                                                        prefs.setString(
                                                            "trainerNameFromSubscriptionCall",
                                                            widget.trainerName);
                                                        prefs.setString(
                                                            'providerFromSubscriptionCall',
                                                            widget.provider);
                                                        Get.offNamedUntil(Routes.CallWaitingScreen,
                                                            (route) => false,
                                                            arguments: [
                                                              widget.courseId.toString(),
                                                              iHLUserId.toString(),
                                                              widget.trainerId,
                                                              "SubscriptionCall",
                                                              widget.subscription_id,
                                                            ]);
                                                      }
                                                    }
                                                  : () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: const Text('Info'),
                                                            content: const Text(
                                                                'You can Join when the Session Starts'),
                                                            actions: <Widget>[
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      const Color(0xff4393CF),
                                                                  textStyle: const TextStyle(
                                                                      color: Colors.white),
                                                                ),
                                                                child: const Text(
                                                                  'Okay',
                                                                  style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontFamily: "Poppins"),
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
                                              label: const Text(
                                                "Join Class",
                                                style: TextStyle(fontFamily: "Poppins"),
                                              ),
                                              icon: const Icon(Icons.phone),
                                            ),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                backgroundColor: AppColors.primaryColor,
                                                textStyle: const TextStyle(
                                                    color: Colors.white, fontFamily: 'Poppins'),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (BuildContext context) {
                                                    String reasonRadioBtnVal = "";
                                                    return AlertDialog(
                                                        title: const Text(
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
                                                                  children: <Widget>[
                                                                    Column(
                                                                      children: <Widget>[
                                                                        Row(
                                                                          children: <Widget>[
                                                                            Radio<String>(
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
                                                                            const Expanded(
                                                                              child: Text(
                                                                                'You\'re not interested/satisfied',
                                                                                style: TextStyle(
                                                                                    fontSize: 16.0),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        //this is to hide the trainer not interested text to avoid showing the unwanted content on the
                                                                        // pop up . That's why we are hided the content.⚪⚪
                                                                        Visibility(
                                                                            visible: external_url ==
                                                                                null,
                                                                            child: const SizedBox(
                                                                                height: 10)),
                                                                        Visibility(
                                                                          visible:
                                                                              external_url == null,
                                                                          child: Row(
                                                                            children: <Widget>[
                                                                              Radio<String>(
                                                                                value:
                                                                                    "Trainer not interested",
                                                                                groupValue:
                                                                                    reasonRadioBtnVal,
                                                                                onChanged:
                                                                                    (String value) {
                                                                                  if (this
                                                                                      .mounted) {
                                                                                    setState(() {
                                                                                      reasonRadioBtnVal =
                                                                                          value;
                                                                                    });
                                                                                  }
                                                                                },
                                                                              ),
                                                                              const Expanded(
                                                                                child: Text(
                                                                                  'Trainer not interested',
                                                                                  style: TextStyle(
                                                                                    fontSize: 16.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
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
                                                                          decoration:
                                                                              InputDecoration(
                                                                            contentPadding:
                                                                                const EdgeInsets
                                                                                        .symmetric(
                                                                                    vertical: 15,
                                                                                    horizontal: 18),
                                                                            labelText:
                                                                                "Other reason",
                                                                            fillColor:
                                                                                Colors.white24,
                                                                            border: OutlineInputBorder(
                                                                                borderRadius:
                                                                                    BorderRadius
                                                                                        .circular(
                                                                                            15.0),
                                                                                borderSide:
                                                                                    const BorderSide(
                                                                                        color: Colors
                                                                                            .blueGrey)),
                                                                          ),
                                                                          maxLines: 1,
                                                                          textInputAction:
                                                                              TextInputAction.done,
                                                                        ),
                                                                        Visibility(
                                                                          visible:
                                                                              makeValidateVisible
                                                                                  ? true
                                                                                  : false,
                                                                          child: const Text(
                                                                            "Please select the reason!",
                                                                            style: TextStyle(
                                                                                color: Colors.red),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 10.0,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: <Widget>[
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
                                                                            backgroundColor:
                                                                                AppColors
                                                                                    .primaryColor,
                                                                            textStyle:
                                                                                const TextStyle(
                                                                                    color: Colors
                                                                                        .white),
                                                                          ),
                                                                          onPressed:
                                                                              isChecking == true
                                                                                  ? null
                                                                                  : () {
                                                                                      Navigator.pop(
                                                                                          context);
                                                                                    },
                                                                          child: const Text(
                                                                            'Go Back',
                                                                            style: TextStyle(
                                                                                fontFamily:
                                                                                    "Poppins",
                                                                                color:
                                                                                    Colors.white),
                                                                          ),
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
                                                                              backgroundColor:
                                                                                  AppColors
                                                                                      .primaryColor,
                                                                              textStyle:
                                                                                  const TextStyle(
                                                                                      color: Colors
                                                                                          .white),
                                                                            ),
                                                                            onPressed:
                                                                                isChecking == true
                                                                                    ? null
                                                                                    : () {
                                                                                        if (reasonRadioBtnVal
                                                                                            .isNotEmpty) {
                                                                                          if (this
                                                                                              .mounted) {
                                                                                            setState(
                                                                                                () {
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
                                                                                            setState(
                                                                                                () {
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
                                                                                            setState(
                                                                                                () {
                                                                                              makeValidateVisible =
                                                                                                  true;
                                                                                            });
                                                                                          }
                                                                                        }
                                                                                      },
                                                                            child: isChecking ==
                                                                                    true
                                                                                ? const SizedBox(
                                                                                    height: 20.0,
                                                                                    width: 20.0,
                                                                                    child:
                                                                                        CircularProgressIndicator(
                                                                                      valueColor: AlwaysStoppedAnimation<
                                                                                              Color>(
                                                                                          Colors
                                                                                              .white),
                                                                                    ),
                                                                                  )
                                                                                : const Text(
                                                                                    'Submit',
                                                                                    style: TextStyle(
                                                                                        fontFamily:
                                                                                            "Poppins",
                                                                                        color: Colors
                                                                                            .white),
                                                                                  )),
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
                                              label: const Text(
                                                " Cancel  ",
                                              ),
                                              icon: const Icon(Icons.cancel),
                                            ),
                                          ],
                                        )
                                      : widget.isRequested
                                          ? ButtonTheme(
                                              minWidth: 240.0,
                                              height: 40.0,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  backgroundColor: AppColors.primaryColor,
                                                  textStyle: const TextStyle(color: Colors.white),
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                            title: const Text(
                                                              'Please provide the reason for cancellation!',
                                                              style: TextStyle(
                                                                  color: Color(0xff4393cf)),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                            content: StatefulBuilder(
                                                              builder: (BuildContext context,
                                                                  StateSetter setState) {
                                                                return SingleChildScrollView(
                                                                  child: Form(
                                                                    key: _formKey,
                                                                    // ignore: deprecated_member_use
                                                                    autovalidateMode:
                                                                        AutovalidateMode
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
                                                                                    const EdgeInsets
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
                                                                                    borderSide: new BorderSide(
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
                                                                        const SizedBox(
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
                                                                                textStyle:
                                                                                    const TextStyle(
                                                                                        color: Colors
                                                                                            .white),
                                                                              ),
                                                                              child: const Text(
                                                                                'Go Back',
                                                                                style: TextStyle(
                                                                                    color: Colors
                                                                                        .white),
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
                                                                                style:
                                                                                    ElevatedButton
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
                                                                                  textStyle:
                                                                                      const TextStyle(
                                                                                          color: Colors
                                                                                              .white),
                                                                                ),
                                                                                onPressed:
                                                                                    isChecking ==
                                                                                            true
                                                                                        ? null
                                                                                        : () {
                                                                                            if (_formKey
                                                                                                .currentState
                                                                                                .validate()) {
                                                                                              if (this
                                                                                                  .mounted) {
                                                                                                setState(() {
                                                                                                  isChecking = true;
                                                                                                });
                                                                                              }
                                                                                              cancelSubscription(
                                                                                                  widget.subscription_id,
                                                                                                  "user",
                                                                                                  reasonController.text);
                                                                                            } else {
                                                                                              if (this
                                                                                                  .mounted) {
                                                                                                setState(() {
                                                                                                  _autoValidate = true;
                                                                                                });
                                                                                              }
                                                                                            }
                                                                                          },
                                                                                child: isChecking ==
                                                                                        true
                                                                                    ? SizedBox(
                                                                                        height:
                                                                                            20.0,
                                                                                        width: 20.0,
                                                                                        child:
                                                                                            CircularProgressIndicator(
                                                                                          valueColor: const AlwaysStoppedAnimation<
                                                                                                  Color>(
                                                                                              Colors
                                                                                                  .white),
                                                                                        ),
                                                                                      )
                                                                                    : const Text(
                                                                                        'Submit',
                                                                                        style: TextStyle(
                                                                                            color: Colors
                                                                                                .white),
                                                                                      )),
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
                                                label: const Text("Cancel Subscription"),
                                                icon: const Icon(Icons.cancel),
                                              ),
                                            )
                                          : Container(),
                                  const SizedBox(height: 5.0),
                                  Visibility(
                                    visible: ((currentDateTime.isBefore(finalEndDateTime) &&
                                                currentDateTime.isAfter(finalStartDateTime)) &&
                                            currentDateTime.isAfter(fiveMinutesBeforeStartTime) &&
                                            // (currentDateTime.hour >= startTime.hour &&
                                            //     currentDateTime.hour <
                                            //         endTime.hour) &&
                                            (currentDateTime.isAfter(TodaysDateWithStartTime) &&
                                                currentDateTime.isBefore(TodaysDateWithEndTime)) &&
                                            trainerStatus == "Offline" &&
                                            (widget.courseType.toLowerCase() == "daily" ||
                                                (widget.courseOn.contains("Monday") ||
                                                    widget.courseOn.contains("Tuesday") ||
                                                    widget.courseOn.contains("Wednesday") ||
                                                    widget.courseOn.contains("Thursday") ||
                                                    widget.courseOn.contains("Friday") ||
                                                    widget.courseOn.contains("Saturday") ||
                                                    widget.courseOn.contains("Sunday"))) &&
                                            widget.isApproved &&
                                            external_url == null)
                                        ? true
                                        : false,
                                    child: const Text("Trainer is offline",
                                        style: TextStyle(fontSize: 16, color: Colors.red)),
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
              final getUserDetails =
                  await _client.post(Uri.parse(API.iHLUrl + "/consult/get_user_details"),
                      headers: {
                        'Content-Type': 'application/json',
                        'ApiToken': '${API.headerr['ApiToken']}',
                        'Token': '${API.headerr['Token']}',
                      },
                      body: jsonEncode(<String, String>{
                        'ihl_id': userId,
                      }));
              if (getUserDetails.statusCode == 200) {
                final userDetailsResponse = await SharedPreferences.getInstance();
                userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
              } else {}
            } else if (status == "Rejected") {
              if (this.mounted) {
                setState(() {
                  widget.isRejected = true;
                  widget.isRequested = false;
                });
              } // Updating getUserDetails API
              final getUserDetails =
                  await _client.post(Uri.parse(API.iHLUrl + "/consult/get_user_details"),
                      headers: {
                        'Content-Type': 'application/json',
                        'ApiToken': '${API.headerr['ApiToken']}',
                        'Token': '${API.headerr['Token']}',
                      },
                      body: jsonEncode(<String, String>{
                        'ihl_id': userId,
                      }));
              if (getUserDetails.statusCode == 200) {
                final userDetailsResponse = await SharedPreferences.getInstance();
                userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
              }
            } else if (status == "Cancelled") {
              if (this.mounted) {
                setState(() {
                  widget.isApproved = false;
                  widget.isRejected = false;
                  widget.isRequested = false;
                  widget.isCancelled = true;
                });
              } // Updating getUserDetails API
              final getUserDetails =
                  await _client.post(Uri.parse(API.iHLUrl + "/consult/get_user_details"),
                      headers: {
                        'Content-Type': 'application/json',
                        'ApiToken': '${API.headerr['ApiToken']}',
                        'Token': '${API.headerr['Token']}',
                      },
                      body: jsonEncode(<String, String>{
                        'ihl_id': userId,
                      }));
              if (getUserDetails.statusCode == 200) {
                final userDetailsResponse = await SharedPreferences.getInstance();
                userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
                print("Updated");
              } else {
                print(getUserDetails.body);
              }
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

  String external_url;
  Timer triggerClass;
  Timer endclassTimer;

  @override
  void initState() {
    super.initState();
    httpStatus();
    // courseDetail();
    if (widget.external_url != null && widget.external_url != "") {
      external_url = widget.external_url;
    }
    subscribeSubscriptionApproved();
    getTrainerStatus();

    String courseDurationFromApi = widget.duration;

    String courseStartDuration = courseDurationFromApi.substring(0, 10);

    String courseEndDuration = courseDurationFromApi.substring(13, 23);

    DateTime startDate = new DateFormat("yyyy-MM-dd").parse(courseStartDuration);
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
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
    //While the the page is killed the timer needs to cancel.
    //so the timer will not work after exiting from this screen.⚪⚪
    if (triggerClass != null) triggerClass.cancel();
    if (endclassTimer != null) endclassTimer.cancel();
  }
}
