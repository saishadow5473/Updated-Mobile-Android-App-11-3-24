// // ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names
//
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:chips_choice/chips_choice.dart';
// import 'package:expandable/expandable.dart';
// // import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:ihl/constants/api.dart';
// import 'package:ihl/constants/routes.dart';
// import 'package:ihl/home_dashboard/health_journal_tabview.dart';
// import 'package:ihl/models/ecg_calculator.dart';
// import 'package:ihl/tabs/profiletab.dart';
// import 'package:ihl/utils/ScUtil.dart';
// import 'package:ihl/utils/commonUi.dart';
// import 'package:ihl/utils/sizeConfig.dart';
// import 'package:ihl/views/dashBoardExpiredSubscriptionTile.dart';
// import 'package:ihl/views/dietJournal/activity/today_activity.dart';
// import 'package:ihl/views/dietJournal/activity_tile_view.dart';
// import 'package:ihl/views/dietJournal/apis/list_apis.dart';
// import 'package:ihl/views/dietJournal/dashBoard_activity_tile_view.dart';
// import 'package:ihl/views/dietJournal/dietJournal.dart';
// import 'package:ihl/views/dietJournal/diet_view.dart';
// import 'package:ihl/views/dietJournal/home_dash_todays_activity_view.dart';
// import 'package:ihl/views/dietJournal/journal_graph.dart';
// import 'package:ihl/views/dietJournal/models/get_todays_food_log_model.dart';
// import 'package:ihl/views/dietJournal/title_widget.dart';
// import 'package:ihl/views/marathon/dashboard_marathonCard.dart';
// import 'package:ihl/views/other_vitals.dart';
// import 'package:ihl/views/teleconsultation/consultation_history_summary.dart';
// import 'package:ihl/views/teleconsultation/exports.dart';
// import 'package:ihl/views/teleconsultation/myAppointments.dart';
// import 'package:ihl/views/teleconsultation/videocall/genix_lab_order_pdf.dart';
// import 'package:ihl/views/teleconsultation/videocall/genix_prescription.dart';
// import 'package:ihl/views/teleconsultation/videocall/videocall.dart';
// import 'package:ihl/views/teleconsultation/wellness_cart.dart';
// // import 'package:ihl/views/dietJournal/todays_activity_view.dart';
// import 'package:ihl/widgets/dashboard/scoreMeter.dart';
// import 'package:ihl/widgets/height.dart';
// import 'package:ihl/widgets/teleconsulation/dashboard_Consult_historyItemTile.dart';
// import 'package:ihl/widgets/teleconsulation/dashboard_history.dart';
// import 'package:ihl/widgets/teleconsulation/dashboard_subscriptionTile.dart';
// import 'package:ihl/widgets/teleconsulation/dashboardappointmentTile.dart';
// import 'package:ihl/widgets/teleconsulation/exports.dart';
// import 'package:ihl/widgets/teleconsulation/upcomingAppointment.dart';
// import 'package:intl/intl.dart';
// import 'package:lottie/lottie.dart';
// import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
// import 'package:strings/strings.dart';
// import 'dart:convert';
// import 'package:ihl/utils/app_colors.dart';
// import 'package:ihl/painters/backgroundPanter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/material.dart';
// import 'package:ihl/constants/vitalUI.dart';
// import 'package:ihl/constants/app_texts.dart';
// import 'package:ihl/widgets/dashboard/liteVitalsCard.dart';
// import 'package:ihl/constants/spKeys.dart';
// import 'package:http/http.dart' as http;
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:ihl/repositories/marathon_event_api.dart';
//
// // ignore: must_be_immutable
// class HomeTab extends StatefulWidget {
//   Function closeDrawer;
//   Function openDrawer;
//   Function goToProfile;
//   var userScore = '0';
//   String username;
//   final String appointId;
//   final Map consultant;
//
//   HomeTab({
//     this.closeDrawer,
//     this.username,
//     this.openDrawer,
//     this.userScore,
//     this.goToProfile,
//     this.consultant,
//     this.appointId,
//   });
//   @override
//   _HomeTabState createState() => _HomeTabState();
// }
//
// class _HomeTabState extends State<HomeTab> {
//   List<Activity> todaysActivityData = [];
//   List<Activity> otherActivityData = [];
//   bool loading = true;
//   List vitalsToShow = [];
//   String name = 'you';
//   Map allScores = {};
//   var data;
//   bool isVerified = true;
//   int surveybmi = 0;
//   var userVitalst;
//   int differenceInTime;
//   int adifferenceInTime;
//   int adifferenceInDays;
//   List completed_appointmentDetails = [];
//   var hislist = [];
//   Map fitnessClassSpecialties;
//   var platformData;
//   Map res;
//   bool requestError = false;
//
//   Future getSubscriptionClassListData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var data1 = prefs.get('data');
//     Map res1 = jsonDecode(data1);
//     var iHLUserId = res1['User']['id'];
//     final getPlatformData = await http.post(
//       Uri.parse(API.iHLUrl + "/consult/GetPlatfromData"),
//       body: jsonEncode(<String, String>{'ihl_id': iHLUserId, 'cache': "true"}),
//     );
//     if (getPlatformData.statusCode == 200) {
//       if (getPlatformData.body != null) {
//         prefs.setString(SPKeys.platformData, getPlatformData.body);
//         res = jsonDecode(getPlatformData.body);
//         setState(() {
//           loading = false;
//         });
//       }
//     } else {
//       setState(() {
//         requestError = true;
//       });
//       print(getPlatformData.body);
//     }
//
//     //platformData = prefs.get(SPKeys.platformData);
//
//     if (res['consult_type'] == null ||
//         !(res['consult_type'] is List) ||
//         res['consult_type'].isEmpty) {
//       return;
//     }
//
//     fitnessClassSpecialties = res['consult_type'][1];
//   }
//
//   // Dashboard completed appointment history method starts
//
//   bool hashistory = false;
//   List appointments = [];
//   List history = [];
//   List completedHistory = [];
//   var hlist = [];
//   bool completedSelected = false;
//   // bool approvedSelected = false;
//   // bool canceledSelected = false;
//   // bool requestedSelected = false;
//   // bool rejectedSelected = false;
//   // bool loading = true;
//   var apps = [];
//   String completediHLUserId;
//   String profilePic;
//
//   List<String> appointmentStatus = [
//     // 'Approved',
//     'Completed',
//     // 'Rejected',
//     // 'Requested',
//     // 'Canceled',
//   ];
//
//   Future getAppointmentHistoryData() async {
//     /*SharedPreferences prefs = await SharedPreferences.getInstance();
//     var data = prefs.get(SPKeys.userDetailsResponse);
//     Map teleConsulResponse;*/
//     SharedPreferences prefs1 = await SharedPreferences.getInstance();
//     var data1 = prefs1.get('data');
//     Map res = jsonDecode(data1);
//     var iHLUserId = res['User']['id'];
//
//     final getUserDetails = await http.post(
//       Uri.parse(API.iHLUrl + "/consult/get_user_details"),
//       body: jsonEncode(<String, dynamic>{
//         'ihl_id': iHLUserId,
//       }),
//     );
//     if (getUserDetails.statusCode == 200) {
//     } else {
//       print(getUserDetails.body);
//     }
//     Map teleConsulResponse;
//
//     if (getUserDetails.body != null) {
//       teleConsulResponse = json.decode(getUserDetails.body);
//       loading = false;
//       if (teleConsulResponse['appointments'] == null ||
//           !(teleConsulResponse['appointments'] is List) ||
//           teleConsulResponse['appointments'].isEmpty) {
//         if (this.mounted) {
//           setState(() {
//             hashistory = false;
//           });
//         }
//         return;
//       }
//       history = teleConsulResponse['appointments'];
//
//       var currentDateTime = new DateTime.now();
//
//       for (int i = 0; i < history.length; i++) {
//         var endTime = history[i]["appointment_end_time"];
//         String appointmentEndTime = endTime;
//
//         if (appointmentEndTime[7] != '-') {
//           String appEndTime = '';
//           for (var i = 0; i < appointmentEndTime.length; i++) {
//             if (i == 5) {
//               appEndTime += '0' + appointmentEndTime[i];
//             } else {
//               appEndTime += appointmentEndTime[i];
//             }
//           }
//           appointmentEndTime = appEndTime;
//         }
//         if (appointmentEndTime[10] != " ") {
//           String appEndTime = '';
//           for (var i = 0; i < appointmentEndTime.length; i++) {
//             if (i == 8) {
//               appEndTime += '0' + appointmentEndTime[i];
//             } else {
//               appEndTime += appointmentEndTime[i];
//             }
//           }
//           appointmentEndTime = appEndTime;
//         }
//
//         String appointmentEndTimeSubstring =
//             appointmentEndTime.substring(11, 19);
//         String appointmentEndDateSubstring =
//             appointmentEndTime.substring(0, 10);
//         DateTime endTimeFormatTime =
//             DateFormat.jm().parse(appointmentEndTimeSubstring);
//         String endTimeString = DateFormat("HH:mm:ss").format(endTimeFormatTime);
//         String fullAppointmentEndDate =
//             appointmentEndDateSubstring + " " + endTimeString;
//         var appointmentEndingTime = DateTime.parse(fullAppointmentEndDate);
// // adifferenceInTime = endTime.difference(startTime).inHours;
//
// //     adifferenceInDays = endDate.difference(startDate).inDays;
//         if (appointmentEndingTime.isBefore(currentDateTime) ||
//             ((history[i]["appointment_status"] == "Completed" ||
//                     history[i]["appointment_status"] == "completed") &&
//                 (history[i]["call_status"] == "Completed" ||
//                     history[i]["call_status"] == "completed")) ||
//             (history[i]["appointment_status"] == "Canceled" ||
//                 history[i]["appointment_status"] == "canceled") ||
//             (history[i]["appointment_status"] == "Rejected" ||
//                 history[i]["appointment_status"] == "rejected")) {
//           hlist.add(history[i]);
//         }
//       }
//
//       List<DateTime> formattedTime = [];
//       List<String> stringFormattedDateTime = [];
//       for (int i = 0; i < hlist.length; i++) {
//         String date = hlist[i]["appointment_start_time"];
//
//         if (date[7] != '-') {
//           String appStartTime = '';
//           for (var i = 0; i < date.length; i++) {
//             if (i == 5) {
//               appStartTime += '0' + date[i];
//             } else {
//               appStartTime += date[i];
//             }
//           }
//           date = appStartTime;
//         }
//         if (date[10] != " ") {
//           String appStartTime = '';
//           for (var i = 0; i < date.length; i++) {
//             if (i == 8) {
//               appStartTime += '0' + date[i];
//             } else {
//               appStartTime += date[i];
//             }
//           }
//           date = appStartTime;
//         }
//         String stringTime = date.substring(11, 19);
//         date = date.substring(0, 10);
//         DateTime formattime = DateFormat.jm().parse(stringTime);
//         String time = DateFormat("HH:mm:ss").format(formattime);
//         String dateToFormat = date + " " + time;
//         var newTime = DateTime.parse(dateToFormat);
//         formattedTime.add(newTime);
//       }
//       formattedTime.sort((a, b) => b.compareTo(a));
//       // List appointmentDetails = [];
//       List temp = [];
//       sort(List apptDetails) {
//         if (apptDetails == null || apptDetails.length == 0) return;
//         for (int i = 0; i < apptDetails.length; i++) {
//           String stringFormattedTime =
//               DateFormat("yyyy-MM-dd hh:mm aaa").format(formattedTime[i]);
//           stringFormattedDateTime.add(stringFormattedTime);
//           temp.add(apptDetails[i]["appointment_start_time"]);
//         }
//         for (int i = 0; i < stringFormattedDateTime.length; i++) {
//           if (temp.contains(stringFormattedDateTime[i])) {
//             int ii = temp.indexOf(stringFormattedDateTime[i]);
//             completed_appointmentDetails.add(apptDetails[ii]);
//           }
//         }
//       }
//
//       // print(apptDetails[ii]);
//
//       sort(hlist);
//       // hlist = completed_appointmentDetails;
//       // print('Appointment 2----------------->');
//       // print(completed_appointmentDetails[2]);
//       // print('Appointment 3----------------->');
//
//       // print(appointmentDetails[3]);
//       // print('Appointment 4----------------->');
//       // var completedResponse = appointmentDetails[3];
//       // print('Appointment status----------------->');
//       // print(completedResponse[appointmentStatus[0]].toString());
//       // print(appointmentDetails[4]);
//       // print('Appointment 5----------------->');
//       // print(appointmentDetails[5]);
//
//       // print(appointmentDetails[6]);
//
//       // final appointmentStatusResponse = await SharedPreferences.getInstance();
//       // appointmentStatusResponse.setString(
//       //     SPKeys.appointmentStatus, completed_appointmentDetails[5].toString());
//
//       apps = hlist;
//
//       if (this.mounted) {
//         setState(() {
//           hashistory = true;
//         });
//       }
//     } else {
//       if (this.mounted) {
//         setState(() {
//           loading = false;
//           hashistory = false;
//         });
//       }
//     }
//   }
//
//   var consultantIDAndImage = [];
//   var base64Image;
//   var consultantImage;
//   var image;
//
//   Future getConsultantImageURL() async {
//     final response = await http.post(
//       Uri.parse(API.iHLUrl + "/consult/profile_image_fetch"),
//       body: jsonEncode(<String, dynamic>{
//         'consultantIdList': [completediHLUserId],
//       }),
//     );
//     if (response.statusCode == 200) {
//       var imageOutput = json.decode(response.body);
//       consultantIDAndImage = imageOutput["ihlbase64list"];
//       for (var i = 0; i < consultantIDAndImage.length; i++) {
//         if (completediHLUserId ==
//             consultantIDAndImage[i]['consultant_ihl_id']) {
//           base64Image = consultantIDAndImage[i]['base_64'].toString();
//           base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
//           base64Image = base64Image.replaceAll('}', '');
//           base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
//           if (this.mounted) {
//             setState(() {
//               consultantImage = base64Image;
//             });
//           }
//           if (consultantImage == null || consultantImage == "") {
//             profilePic = AvatarImage.defaultUrl;
//             image = Image.memory(base64Decode(profilePic));
//           } else {
//             profilePic = consultantImage;
//             image = Image.memory(base64Decode(profilePic));
//           }
//         }
//       }
//     } else {
//       print(response.body);
//     }
//   }
//
//   DashBoardHistoryItem getDashBoardHistoryItem(Map map, var index) {
//     return DashBoardHistoryItem(
//       index: index,
//       appointId: map['appointment_id'],
//       appointmentStartTime: map['appointment_start_time'],
//       appointmentEndTime: map['appointment_end_time'],
//       consultantName:
//           map['consultant_name'] == null ? "N/A" : map['consultant_name'],
//       consultationFees: map['consultation_fees'],
//       appointmentStatus: map['appointment_status'],
//       callStatus: map['call_status'] == null ? "N/A" : map['call_status'],
//     );
//   }
//
//   // Dashboard completed appointment history method ends
//
//   // subscription expired history method starts
//
//   // bool expanded = true;
//   // bool hasSubscription = false;
//   List subscriptions = [];
//   List expiredSubscriptions;
//   var elist = [];
//   // bool loading = true;
//
//   Future getExpiredSubscriptionHistoryData() async {
//     SharedPreferences prefs1 = await SharedPreferences.getInstance();
//     var data1 = prefs1.get('data');
//     Map res = jsonDecode(data1);
//     iHLUserId = res['User']['id'];
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var data = prefs.get(SPKeys.userDetailsResponse);
//     Map teleConsulResponse = json.decode(data);
//     loading = false;
//     if (teleConsulResponse['my_subscriptions'] == null ||
//         !(teleConsulResponse['my_subscriptions'] is List) ||
//         teleConsulResponse['my_subscriptions'].isEmpty) {
//       if (this.mounted) {
//         setState(() {
//           hasSubscription = false;
//         });
//       }
//       return;
//     }
//     if (this.mounted) {
//       setState(() {
//         subscriptions = teleConsulResponse['my_subscriptions'];
//         expiredSubscriptions = subscriptions
//             .where((i) =>
//                 i["approval_status"] == "expired" ||
//                 i["approval_status"] == "Expired" ||
//                 i["approval_status"] == "cancelled" ||
//                 i["approval_status"] == "Cancelled" ||
//                 i["approval_status"] == "Rejected" ||
//                 i["approval_status"] == "rejected")
//             .toList();
//
//         var currentDateTime = new DateTime.now();
//
//         for (int i = 0; i < expiredSubscriptions.length; i++) {
//           var duration = expiredSubscriptions[i]["course_duration"];
//           var time = expiredSubscriptions[i]["course_time"];
//
//           String courseDurationFromApi = duration;
//           String courseTimeFromApi = time;
//
//           String courseStartTime;
//           String courseEndTime;
//
//           String courseStartDuration = courseDurationFromApi.substring(0, 10);
//
//           String courseEndDuration = courseDurationFromApi.substring(13, 23);
//
//           DateTime startDate =
//               new DateFormat("yyyy-MM-dd").parse(courseStartDuration);
//           final DateFormat formatter = DateFormat('yyyy-MM-dd');
//           String startDateFormattedToString = formatter.format(startDate);
//
//           DateTime endDate =
//               new DateFormat("yyyy-MM-dd").parse(courseEndDuration);
//           String endDateFormattedToString = formatter.format(endDate);
//           if (courseTimeFromApi[2].toString() == ':' &&
//               courseTimeFromApi[13].toString() != ':') {
//             var tempcourseEndTime = '';
//             courseStartTime = courseTimeFromApi.substring(0, 8);
//             for (var i = 0; i < courseTimeFromApi.length; i++) {
//               if (i == 10) {
//                 tempcourseEndTime += '0';
//               } else if (i > 10) {
//                 tempcourseEndTime += courseTimeFromApi[i];
//               }
//             }
//             courseEndTime = tempcourseEndTime;
//           } else if (courseTimeFromApi[2].toString() != ':') {
//             var tempcourseStartTime = '';
//             var tempcourseEndTime = '';
//
//             for (var i = 0; i < courseTimeFromApi.length; i++) {
//               if (i == 0) {
//                 tempcourseStartTime = '0';
//               } else if (i > 0 && i < 8) {
//                 tempcourseStartTime += courseTimeFromApi[i - 1];
//               } else if (i > 9) {
//                 tempcourseEndTime += courseTimeFromApi[i];
//               }
//             }
//             courseStartTime = tempcourseStartTime;
//             courseEndTime = tempcourseEndTime;
//             if (courseEndTime[2].toString() != ':') {
//               var tempcourseEndTime = '';
//               for (var i = 0; i <= courseEndTime.length; i++) {
//                 if (i == 0) {
//                   tempcourseEndTime += '0';
//                 } else {
//                   tempcourseEndTime += courseEndTime[i - 1];
//                 }
//               }
//               courseEndTime = tempcourseEndTime;
//             }
//           } else {
//             courseStartTime = courseTimeFromApi.substring(0, 8);
//             courseEndTime = courseTimeFromApi.substring(11, 19);
//           }
//
//           DateTime startTime = DateFormat.jm().parse(courseStartTime);
//           DateTime endTime = DateFormat.jm().parse(courseEndTime);
//
//           String startingTime = DateFormat("H:mm:ss").format(startTime);
//           String endingTime = DateFormat("H:mm:ss").format(endTime);
//           String startDateAndTime =
//               startDateFormattedToString + " " + startingTime;
//           String endDateAndTime = endDateFormattedToString + " " + endingTime;
//           DateTime finalStartDateTime =
//               new DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
//           DateTime finalEndDateTime =
//               new DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);
//           differenceInTime = endTime.difference(startTime).inHours;
//           elist.add(expiredSubscriptions[i]);
//         }
//
//         hasSubscription = true;
//       });
//     }
//   }
//
//   DashBoardExpiredSubscriptionTile getExpiredSubscriptionItem(Map map) {
//     return DashBoardExpiredSubscriptionTile(
//       subscription_id: map["subscription_id"],
//       trainerId: map["consultant_id"],
//       trainerName: map["consultant_name"],
//       title: map["title"],
//       duration: map["course_duration"],
//       time: map["course_time"],
//       provider: map['provider'],
//       isExpired: map['approval_status'] == "expired" ||
//           map['approval_status'] == "Expired",
//       isCancelled: map['approval_status'] == "Cancelled" ||
//           map['approval_status'] == "cancelled",
//       isRejected: map['approval_status'] == "Rejected" ||
//           map['approval_status'] == "rejected",
//       courseOn: map['course_on'],
//       courseTime: map['course_time'],
//       courseId: map['course_id'],
//       courseFee: map['course_fees'].toString(),
//     );
//   }
//
//   // subscription expired history method ends
//
//   /// handle null and empty strings⚡
//   String stringify(dynamic prop) {
//     if (prop == null || prop == '' || prop == ' ' || prop == 'NA') {
//       return AppTexts.notAvailable;
//     }
//     if (prop is double) {
//       double doub = prop;
//       prop = doub.round();
//     }
//     String stringVal = prop.toString();
//     stringVal = stringVal.trim().isEmpty ? AppTexts.notAvailable : stringVal;
//     return stringVal;
//   }
//
//   /// calculate bmi🎇🎇
//   int calcBmi({height, weight}) {
//     double parsedH;
//     double parsedW;
//     if (height == null || weight == null) {
//       return null;
//     }
//
//     parsedH = double.tryParse(height);
//     parsedW = double.tryParse(weight);
//     if (parsedH != null && parsedW != null) {
//       int bmi = parsedW ~/ (parsedH * parsedH);
//       print(bmi);
//       return bmi;
//     }
//     return null;
//   }
//
//   // new bmi formula
//   /// calculate bmi🎇🎇
//   int calcBmiNew({height, weight}) {
//     double parsedH;
//     double parsedW;
//     if (height != null && weight != null && height != '' && weight != '') {
//       parsedH = double.tryParse(height.toString());
//       parsedW = double.tryParse(weight.toString());
//     }
//     if (parsedH != null && parsedW != null) {
//       int bmi = parsedW ~/ (parsedH * parsedW);
//
//       return bmi;
//     }
//     return null;
//   }
//
//   /// returns BMI Class for a BMI 🌈
//   String bmiClassCalc(int bmi) {
//     print(bmi);
//     if (bmi == null) {
//       return AppTexts.notAvailable;
//     }
//     if (bmi > 30) {
//       return AppTexts.obeseBMI;
//     }
//     if (bmi > 25) {
//       return AppTexts.ovwBMI;
//     }
//     if (bmi < 18) {
//       return AppTexts.undwBMI;
//     }
//     return AppTexts.normalBMI;
//   }
//
//   DateTime getDateTimeStamp(String d) {
//     try {
//       return DateTime.fromMillisecondsSinceEpoch(int.tryParse(d
//           .substring(0, d.indexOf('+'))
//           .replaceAll('Date', '')
//           .replaceAll('/', '')
//           .replaceAll('(', '')
//           .replaceAll(')', '')));
//     } catch (e) {
//       return DateTime.now();
//     }
//   }
//
//   // surveyui bmi calculation
//
//   void surveybmiCalc() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var data = prefs.get('data');
//     // data = data == null || data == '' ? '{"User":{}}' : data;
//     Map res = jsonDecode(data);
//     var height = res['User']['heightMeters'].toString();
//     var weight = res['User']['userInputWeightInKG'].toString();
//     double parsedH;
//     double parsedW;
//     parsedH = double.tryParse(height);
//     parsedW = double.tryParse(weight);
//     if (parsedH != null && parsedW != null) {
//       surveybmi = parsedW ~/ (parsedH * parsedH);
//
//       print(surveybmi);
//       //   if (surveybmi == null) {
//       //     return AppTexts.notAvailable;
//       //   }
//       //   if (surveybmi > 30) {
//       //     return AppTexts.obeseBMI;
//       //   }
//       //   if (surveybmi > 25) {
//       //     return AppTexts.ovwBMI;
//       //   }
//       //   if (surveybmi < 18) {
//       //     return AppTexts.undwBMI;
//       //   }
//       //   return AppTexts.normalBMI;
//       // } else {
//       //   return AppTexts.notAvailable;
//     }
//   }
//
//   /// looooooooooooooong code processes JSON response 🌠
//   ///
//   List userVitals;
//   getData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var raw = prefs.get(SPKeys.userData);
//     if (raw == '' || raw == null) {
//       raw = '{}';
//     }
//     data = jsonDecode(raw);
//
//     Map user = data['User'];
//     if (user == null) {
//       user = {};
//     }
//     userVitalst = prefs.getString(SPKeys.vitalsData);
//     if (userVitalst == null || userVitalst == '' || userVitalst == '[]') {
//       if (user['userInputWeightInKG'] == null ||
//           user['userInputWeightInKG'] == '' ||
//           user['heightMeters'] == null ||
//           user['heightMeters'] == '' ||
//           ((user['email'] == null || user['email'] == '') &&
//               (user['mobileNumber'] == null || user['mobileNumber'] == ''))) {
//         isVerified = false;
//         loading = false;
//         if (this.mounted) {
//           setState(() {});
//           return;
//         }
//       }
//       userVitalst = '[{}]';
//     }
//     userVitals = jsonDecode(userVitalst);
//     //get inputted height weight if values are not available
//
//     if (userVitals[0]['weightKG'] == null) {
//       userVitals[0]['weightKG'] = user['userInputWeightInKG'];
//     }
//     if (userVitals[0]['heightMeters'] == null) {
//       userVitals[0]['heightMeters'] = user['heightMeters'];
//     }
//     //Calculate bmi
//     if (userVitals[0]['bmi'] == null) {
//       userVitals[0]['bmi'] = calcBmi(
//           height: userVitals[0]['heightMeters'].toString(),
//           weight: userVitals[0]['weightKG'].toString());
//       userVitals[0]['bmiClass'] = bmiClassCalc(userVitals[0]['bmi']);
//     }
//     allScores = {};
//     //prepare data
//     double finalWeight = 0;
//     double finalHeight = 0;
//     var bcml = "20.00";
//     var bcmh = "25.00";
//     var lowMineral = "2.00";
//     var highMineral = "3.00";
//     var heightinCMS = userVitals[0]['heightMeters'] * 100;
//     var weight = userVitals[0]['weightKG'].toString() == ""
//         ? '0'
//         : userVitals[0]['weightKG'].toString();
//     var gender = user['gender'].toString();
//     var lowSmmReference,
//         lowFatReference,
//         highSmmReference,
//         highFatReference,
//         lowBmcReference,
//         highBmcReference,
//         icll,
//         iclh,
//         ecll,
//         eclh,
//         proteinl,
//         proteinh,
//         waisttoheightratiolow,
//         waisttoheightratiohigh,
//         lowPbfReference,
//         highPbfReference;
//
//     if (gender != 'm') {
//       lowPbfReference = "18.00";
//       highPbfReference = "28.00";
//       var femaleHeightWeight = [
//         [147, 45, 59],
//         [150, 45, 60],
//         [152, 46, 62],
//         [155, 47, 63],
//         [157, 49, 65],
//         [160, 50, 67],
//         [162, 51, 69],
//         [165, 53, 70],
//         [167, 54, 72],
//         [170, 55, 74],
//         [172, 57, 75],
//         [175, 58, 77],
//         [177, 60, 78],
//         [180, 61, 80]
//       ];
//       var j = 0;
//       while (femaleHeightWeight[j][0] <= heightinCMS) {
//         j++;
//         if (j == 13) {
//           break;
//         }
//       }
//       var wtl, wth;
//       if (j == 0) {
//         wtl = femaleHeightWeight[j][1];
//         wth = femaleHeightWeight[j][2];
//       } else {
//         wtl = femaleHeightWeight[j - 1][1];
//         wth = femaleHeightWeight[j - 1][2];
//       }
//       lowSmmReference = (0.36 * wtl);
//       highSmmReference = (0.36 * wth);
//       lowFatReference = (0.18 * double.tryParse(weight));
//       highFatReference = (0.28 * double.tryParse(weight));
//       lowBmcReference = "1.70";
//       highBmcReference = "3.00";
//       icll = (0.3 * wtl);
//       iclh = (0.3 * wth);
//       ecll = (0.2 * wtl);
//       eclh = (0.2 * wth);
//       proteinl = (0.116 * double.tryParse(weight));
//       proteinh = (0.141 * double.tryParse(weight));
//       waisttoheightratiolow = "0.35";
//       waisttoheightratiohigh = "0.53";
//     } else {
//       lowPbfReference = "10.00";
//       highPbfReference = "20.00";
//       var maleHeightWeight = [
//         [155, 55, 66],
//         [157, 56, 67],
//         [160, 57, 68],
//         [162, 58, 70],
//         [165, 59, 72],
//         [167, 60, 74],
//         [170, 61, 75],
//         [172, 62, 77],
//         [175, 63, 79],
//         [177, 64, 81],
//         [180, 65, 83],
//         [182, 66, 85],
//         [185, 68, 87],
//         [187, 69, 89],
//         [190, 71, 91]
//       ];
//       var k = 0;
//       while (maleHeightWeight[k][0] <= heightinCMS) {
//         k++;
//         if (k == 14) {
//           break;
//         }
//       }
//       var wtl, wth;
//       if (k == 0) {
//         wtl = maleHeightWeight[k][1];
//         wth = maleHeightWeight[k][2];
//       } else {
//         wtl = maleHeightWeight[k - 1][1];
//         wth = maleHeightWeight[k - 1][2];
//       }
//       lowSmmReference = (0.42 * wtl);
//       highSmmReference = (0.42 * wth);
//       lowFatReference = (0.10 * double.parse(weight ?? '0'));
//       highFatReference = (0.20 * double.parse(weight ?? '0'));
//       lowBmcReference = "2.00";
//       highBmcReference = "3.70";
//       icll = (0.3 * wtl);
//       iclh = (0.3 * wth);
//       ecll = (0.2 * wtl);
//       eclh = (0.2 * wth);
//       proteinl = (0.109 * double.parse(weight));
//       proteinh = (0.135 * double.parse(weight));
//       waisttoheightratiolow = "0.35";
//       waisttoheightratiohigh = "0.57";
//     }
//
//     var proteinStatus;
//     var ecwStatus;
//     var icwStatus;
//     var mineralStatus;
//     var smmStatus;
//     var bfmStatus;
//     var bcmStatus;
//     var waistHipStatus;
//     var pbfStatus;
//     var waistHeightStatus;
//     var vfStatus;
//     var bmrStatus;
//     var bomcStatus;
//
//     calculateFullBodyProteinStatus(FullBodyProtein) {
//       if (double.parse(FullBodyProtein) < proteinl) {
//         return 'Low';
//       } else if (double.parse(FullBodyProtein) >= proteinl) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyECWStatus(FullBodyECW) {
//       if (double.parse(FullBodyECW) < ecll) {
//         return 'Low';
//       } else if (double.parse(FullBodyECW) >= ecll &&
//           double.parse(FullBodyECW) <= eclh) {
//         return 'Normal';
//       } else if (double.parse(FullBodyECW) > eclh) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyICWStatus(FullBodyICW) {
//       if (double.parse(FullBodyICW) < icll) {
//         return 'Low';
//       } else if (double.parse(FullBodyICW) >= icll &&
//           double.parse(FullBodyICW) <= iclh) {
//         return 'Normal';
//       } else if (double.parse(FullBodyICW) > iclh) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyMineralStatus(FullBodyMineral) {
//       if (double.parse(FullBodyMineral) < double.parse(lowMineral)) {
//         return 'Low';
//       } else if (double.parse(FullBodyMineral) >= double.parse(lowMineral)) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodySMMStatus(FullBodySMM) {
//       if (double.parse(FullBodySMM) < lowSmmReference) {
//         return 'Low';
//       } else if (double.parse(FullBodySMM) >= lowSmmReference) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyBMCStatus(FullBodyBMC) {
//       if (double.parse(FullBodyBMC) < double.parse(lowBmcReference)) {
//         return 'Low';
//       } else if (double.parse(FullBodyBMC) >= double.parse(lowBmcReference)) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyPBFStatus(FullBodyPBF) {
//       if (double.parse(FullBodyPBF) < double.parse(lowPbfReference)) {
//         return 'Low';
//       } else if (double.parse(FullBodyPBF) >= double.parse(lowPbfReference) &&
//           double.parse(FullBodyPBF) <= double.parse(highPbfReference)) {
//         return 'Normal';
//       } else if (double.parse(FullBodyPBF) > double.parse(highPbfReference)) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyBCMStatus(FullBodyBCM) {
//       if (double.parse(FullBodyBCM) < double.parse(bcml)) {
//         return 'Low';
//       } else if (double.parse(FullBodyBCM) >= double.parse(bcml)) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyFATStatus(FullBodyFAT) {
//       if (double.parse(FullBodyFAT) < lowFatReference) {
//         return 'Low';
//       } else if (double.parse(FullBodyFAT) >= lowFatReference &&
//           double.parse(FullBodyFAT) <= highFatReference) {
//         return 'Normal';
//       } else if (double.parse(FullBodyFAT) > highFatReference) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyVFStatus(FullBodyVF) {
//       if (FullBodyVF != "NaN") {
//         if (int.tryParse(FullBodyVF) <= 100) {
//           return 'Normal';
//         } else if (int.tryParse(FullBodyVF) > 100) {
//           return 'High';
//         }
//       }
//     }
//
//     calculateFullBodyBMRStatus(FullBodyBMR) {
//       if (int.parse(FullBodyBMR) < 1200) {
//         return 'Low';
//       } else if (int.parse(FullBodyBMR) >= 1200) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyWHPRStatus(FullBodyWHPR) {
//       if (double.parse(FullBodyWHPR) < 0.80) {
//         return 'Low';
//       } else if (double.parse(FullBodyWHPR) >= 0.80 &&
//           double.parse(FullBodyWHPR) <= 0.90) {
//         return 'Normal';
//       }
//       if (double.parse(FullBodyWHPR) > 0.90) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyWHTRStatus(FullBodyWHTR) {
//       if (double.parse(FullBodyWHTR) < double.parse(waisttoheightratiolow)) {
//         return 'Low';
//       } else if (double.parse(FullBodyWHTR) >=
//               double.parse(waisttoheightratiolow) &&
//           double.parse(FullBodyWHTR) <= double.parse(waisttoheightratiohigh)) {
//         return 'Normal';
//       }
//       if (double.parse(FullBodyWHTR) > double.parse(waisttoheightratiohigh)) {
//         return 'High';
//       }
//     }
//
//     for (var i = 0; i < userVitals.length; i++) {
//       if (userVitals[i]['protien'] != null &&
//           userVitals[i]['protien'] != "NaN") {
//         userVitals[i]['protien'] = userVitals[i]['protien'].toStringAsFixed(2);
//         proteinStatus =
//             calculateFullBodyProteinStatus(userVitals[i]['protien']);
//       }
//       // My code
//       if (userVitals[i]['heightMeters'] != null &&
//           userVitals[i]['heightMeters'] != "NaN") {
//         userVitals[i]['heightMeters'] =
//             userVitals[i]['heightMeters'].toStringAsFixed(2);
//         proteinStatus =
//             calculateFullBodyProteinStatus(userVitals[i]['heightMeters']);
//       }
//       // End
//       if (userVitals[i]['intra_cellular_water'] != null &&
//           userVitals[i]['intra_cellular_water'] != "NaN") {
//         userVitals[i]['intra_cellular_water'] =
//             userVitals[i]['intra_cellular_water'].toStringAsFixed(2);
//         icwStatus =
//             calculateFullBodyICWStatus(userVitals[i]['intra_cellular_water']);
//       }
//
//       if (userVitals[i]['extra_cellular_water'] != null &&
//           userVitals[i]['extra_cellular_water'] != "NaN") {
//         userVitals[i]['extra_cellular_water'] =
//             userVitals[i]['extra_cellular_water'].toStringAsFixed(2);
//         ecwStatus =
//             calculateFullBodyECWStatus(userVitals[i]['extra_cellular_water']);
//       }
//
//       if (userVitals[i]['mineral'] != null &&
//           userVitals[i]['mineral'] != "NaN") {
//         userVitals[i]['mineral'] = userVitals[i]['mineral'].toStringAsFixed(2);
//         mineralStatus =
//             calculateFullBodyMineralStatus(userVitals[i]['mineral']);
//       }
//
//       if (userVitals[i]['skeletal_muscle_mass'] != null &&
//           userVitals[i]['skeletal_muscle_mass'] != "NaN") {
//         userVitals[i]['skeletal_muscle_mass'] =
//             userVitals[i]['skeletal_muscle_mass'].toStringAsFixed(2);
//         smmStatus =
//             calculateFullBodySMMStatus(userVitals[i]['skeletal_muscle_mass']);
//       }
//
//       if (userVitals[i]['body_fat_mass'] != null &&
//           userVitals[i]['body_fat_mass'] != "NaN") {
//         userVitals[i]['body_fat_mass'] =
//             userVitals[i]['body_fat_mass'].toStringAsFixed(2);
//         bfmStatus = calculateFullBodyFATStatus(userVitals[i]['body_fat_mass']);
//       }
//
//       if (userVitals[i]['body_cell_mass'] != null &&
//           userVitals[i]['body_cell_mass'] != "NaN") {
//         userVitals[i]['body_cell_mass'] =
//             userVitals[i]['body_cell_mass'].toStringAsFixed(2);
//         bcmStatus = calculateFullBodyBCMStatus(userVitals[i]['body_cell_mass']);
//       }
//
//       if (userVitals[i]['waist_hip_ratio'] != null &&
//           userVitals[i]['waist_hip_ratio'] != "NaN") {
//         userVitals[i]['waist_hip_ratio'] =
//             userVitals[i]['waist_hip_ratio'].toStringAsFixed(2);
//         waistHipStatus =
//             calculateFullBodyWHPRStatus(userVitals[i]['waist_hip_ratio']);
//       }
//
//       if (userVitals[i]['percent_body_fat'] != null &&
//           userVitals[i]['percent_body_fat'] != "NaN") {
//         userVitals[i]['percent_body_fat'] =
//             userVitals[i]['percent_body_fat'].toStringAsFixed(2);
//         pbfStatus =
//             calculateFullBodyPBFStatus(userVitals[i]['percent_body_fat']);
//       }
//
//       if (userVitals[i]['waist_height_ratio'] != null &&
//           userVitals[i]['waist_height_ratio'] != "NaN") {
//         userVitals[i]['waist_height_ratio'] =
//             userVitals[i]['waist_height_ratio'].toStringAsFixed(2);
//         waistHeightStatus =
//             calculateFullBodyWHTRStatus(userVitals[i]['waist_height_ratio']);
//       }
//
//       if (userVitals[i]['visceral_fat'] != null &&
//           userVitals[i]['visceral_fat'] != "NaN") {
//         userVitals[i]['visceral_fat'] =
//             stringify(userVitals[i]['visceral_fat']);
//         vfStatus = calculateFullBodyVFStatus(userVitals[i]['visceral_fat']);
//       }
//
//       if (userVitals[i]['basal_metabolic_rate'] != null &&
//           userVitals[i]['basal_metabolic_rate'] != "NaN") {
//         userVitals[i]['basal_metabolic_rate'] =
//             stringify(userVitals[i]['basal_metabolic_rate']);
//         bmrStatus =
//             calculateFullBodyBMRStatus(userVitals[i]['basal_metabolic_rate']);
//       }
//
//       if (userVitals[i]['bone_mineral_content'] != null &&
//           userVitals[i]['bone_mineral_content'] != "NaN") {
//         userVitals[i]['bone_mineral_content'] =
//             userVitals[i]['bone_mineral_content'].toStringAsFixed(2);
//         bomcStatus =
//             calculateFullBodyBMCStatus(userVitals[i]['bone_mineral_content']);
//       }
//
//       userVitals[i]['bmi'] ??= calcBmi(
//           height: userVitals[i]['heightMeters'].toString(),
//           weight: userVitals[i]['weight'].toString());
//       finalHeight = doubleFly(userVitals[i]['heightMeters']) ?? finalHeight;
//       finalWeight = doubleFly(userVitals[i]['weightKG']) ?? finalWeight;
//       if (userVitals[i]['systolic'] != null &&
//           userVitals[i]['diastolic'] != null) {
//         userVitals[i]['bp'] = stringify(userVitals[i]['systolic']) +
//             '/' +
//             stringify(userVitals[i]['diastolic']);
//       }
//       userVitals[i]['weightKGClass'] = userVitals[i]['bmiClass'];
//       userVitals[i]['ECGBpmClass'] = userVitals[i]['leadTwoStatus'];
//       userVitals[i]['fatRatioClass'] = userVitals[i]['fatClass'];
//       userVitals[i]['pulseBpmClass'] = userVitals[i]['pulseClass'];
//     }
//     prefs.setDouble(SPKeys.weight, finalWeight);
//     prefs.setDouble(SPKeys.height, finalHeight);
//
//     //Check which vital
//     vitalsOnHome.forEach((f) {
//       allScores[f] = [];
//       allScores[f + 'Class'] = [];
//       for (var i = 0; i < userVitals.length; i++) {
//         if (userVitals[i][f] != '' &&
//             userVitals[i][f] != null &&
//             userVitals[i][f] != 'N/A') {
//           /// round off to nearest 2 decimal 🌊
//           if (userVitals[i][f] is double) {
//             if (decimalVitals.contains(f)) {
//               userVitals[i][f] = (userVitals[i][f] * 100.0).toInt() / 100;
//             } else {
//               userVitals[i][f] = (userVitals[i][f]).toInt();
//             }
//           }
//           Map mapToAdd = {
//             'value': userVitals[i][f],
//             'status': userVitals[i][f + 'Class'] == null
//                 ? 'Unknown'
//                 : camelize(userVitals[i][f + 'Class']),
//             'date': userVitals[i]['dateTimeFormatted'] != null
//                 ? DateTime.tryParse(
//                     userVitals[i]['dateTimeFormatted'].toString())
//                 : getDateTimeStamp(user['accountCreated']),
//             'moreData': {
//               'Address': stringify(userVitals[i]['orgAddress']),
//               'City': stringify(userVitals[i]['IHLMachineLocation']),
//             }
//           };
//           // processing specific to a vital
//           if (f == 'temperature') {
//             if (userVitals[i]['Roomtemperature'] != null) {
//               userVitals[i]['Roomtemperature'] =
//                   doubleFly(userVitals[i]['Roomtemperature']);
//               mapToAdd['moreData']['Room Temperature'] =
//                   '${stringify((userVitals[i]['Roomtemperature'] * 9 / 5) + 32)} ${vitalsUI['temperature']['unit']}';
//             }
//             mapToAdd['value'] =
//                 (((userVitals[i][f] * 900 / 5).toInt()) / 100 + 32)
//                     .toStringAsFixed(2);
//           }
//           if (f == 'bp') {
//             mapToAdd['moreData']['Systolic'] =
//                 userVitals[i]['systolic'].toString();
//             mapToAdd['moreData']['Diastolic'] =
//                 userVitals[i]['diastolic'].toString();
//           }
//           if (f == 'protien') {
//             mapToAdd['protien'] = userVitals[i]['protien'].toString();
//             mapToAdd['status'] = proteinStatus.toString();
//           }
//           // My code start for showing height
//           if (f == 'heightMeters') {
//             mapToAdd['heightMeters'] = userVitals[i]['heightMeters'].toString();
//             mapToAdd['status'] = proteinStatus.toString();
//           }
//           // End
//           if (f == 'intra_cellular_water') {
//             mapToAdd['intra_cellular_water'] =
//                 userVitals[i]['intra_cellular_water'].toString();
//             mapToAdd['status'] = icwStatus.toString();
//           }
//
//           if (f == 'extra_cellular_water') {
//             mapToAdd['extra_cellular_water'] =
//                 userVitals[i]['extra_cellular_water'].toString();
//             mapToAdd['status'] = ecwStatus.toString();
//           }
//
//           if (f == 'mineral') {
//             mapToAdd['mineral'] = userVitals[i]['mineral'].toString();
//             mapToAdd['status'] = mineralStatus.toString();
//           }
//
//           if (f == 'skeletal_muscle_mass') {
//             mapToAdd['skeletal_muscle_mass'] =
//                 userVitals[i]['skeletal_muscle_mass'].toString();
//             mapToAdd['status'] = smmStatus.toString();
//           }
//
//           if (f == 'body_fat_mass') {
//             mapToAdd['body_fat_mass'] =
//                 userVitals[i]['body_fat_mass'].toString();
//             mapToAdd['status'] = bfmStatus.toString();
//           }
//
//           if (f == 'body_cell_mass') {
//             mapToAdd['body_cell_mass'] =
//                 userVitals[i]['body_cell_mass'].toString();
//             mapToAdd['status'] = bcmStatus.toString();
//           }
//
//           if (f == 'waist_hip_ratio') {
//             mapToAdd['waist_hip_ratio'] =
//                 userVitals[i]['waist_hip_ratio'].toString();
//             mapToAdd['status'] = waistHipStatus.toString();
//           }
//
//           if (f == 'percent_body_fat') {
//             mapToAdd['percent_body_fat'] =
//                 userVitals[i]['percent_body_fat'].toString();
//             mapToAdd['status'] = pbfStatus.toString();
//           }
//
//           if (f == 'waist_height_ratio') {
//             mapToAdd['waist_height_ratio'] =
//                 userVitals[i]['waist_height_ratio'].toString();
//             mapToAdd['status'] = waistHeightStatus.toString();
//           }
//
//           if (f == 'visceral_fat') {
//             mapToAdd['visceral_fat'] = userVitals[i]['visceral_fat'].toString();
//             mapToAdd['status'] = vfStatus.toString();
//           }
//
//           if (f == 'basal_metabolic_rate') {
//             mapToAdd['basal_metabolic_rate'] =
//                 userVitals[i]['basal_metabolic_rate'].toString();
//             mapToAdd['status'] = bmrStatus.toString();
//           }
//
//           if (f == 'bone_mineral_content') {
//             mapToAdd['bone_mineral_content'] =
//                 userVitals[i]['bone_mineral_content'].toString();
//             mapToAdd['status'] = bomcStatus.toString();
//           }
//
//           if (f == 'ECGBpm') {
//             mapToAdd['graphECG'] = ECGCalc(
//               isLeadThree: userVitals[i]['LeadMode'] == 3,
//               data1: userVitals[i]['ECGData'],
//               data2: userVitals[i]['ECGData2'],
//               data3: userVitals[i]['ECGData3'],
//             );
//
//             mapToAdd['moreData']['Lead One Status'] =
//                 stringify(userVitals[i]['leadOneStatus']);
//             mapToAdd['moreData']['Lead Two Status'] =
//                 stringify(userVitals[i]['leadTwoStatus']);
//             mapToAdd['moreData']['Lead Three Status'] =
//                 stringify(userVitals[i]['leadThreeStatus']);
//           }
//           allScores[f].add(mapToAdd);
//           if (!vitalsToShow.contains(f)) {
//             vitalsToShow.add(f);
//           }
//         }
//       }
//     });
//     vitalsToShow.toSet();
//     vitalsToShow = vitalsOnHome;
//
//     loading = false;
//     if (this.mounted) {
//       this.setState(() {});
//     }
//   }
//
//   double doubleFly(k) {
//     if (k is num) {
//       return k * 1.0;
//     }
//     if (k is String) {
//       return double.tryParse(k);
//     }
//     return null;
//   }
//
// // weekly calorie graph parameters
//
//   var graphDataList = [];
//   bool nodata = false;
//   int target = 0;
//   String tillDate;
//   String fromDate;
//   void getWeekData() async {
//     tillDate =
//         DateTime.now().add(Duration(days: 1)).toString().substring(0, 10);
//     fromDate =
//         DateTime.now().subtract(Duration(days: 6)).toString().substring(0, 10);
//     String tabType = 'weekly';
//
//     graphDataList = await ListApis.getUserFoodLogHistoryApi(
//             fromDate: fromDate, tillDate: tillDate, tabType: tabType) ??
//         [];
//     if (mounted) {
//       setState(() {
//         if (graphDataList.isEmpty) {
//           nodata = true;
//         }
//         graphDataList;
//       });
//     }
//     // for(int i = 0; i<=graphDataList.length;i++){
//     //   if(graphDataList[i].){}
//     // }
//   }
//
//   getTarget() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       target = prefs.getInt('weekly_target');
//     });
//   }
//
//   List<DailyCalorieData> monthlyChartData = [
//     DailyCalorieData(DateTime(2021, 08, 04), 3500),
//     DailyCalorieData(DateTime(2021, 08, 03), 3800),
//     DailyCalorieData(DateTime(2021, 08, 01), 3400),
//   ];
//   // monthlyChartData.add(DateTime(2021, 08, 04), 3500)
//
// // weekly calorie graph parameters ends
//
// // Tele-consultant parameters
//   String iHLUserId;
//   ExpandableController _expandableController;
//   bool expanded = true;
//   bool hasappointment = false;
//   List appointment = [];
//   List approvedAppointments;
//   // TabController _controller;
//
//   var alist = [];
//   // bool loading = true;
//   List<String> sharedReportAppIdList = [];
//
//   Future getAppointmentData() async {
//     /* SharedPreferences prefs = await SharedPreferences.getInstance();
//     var data = prefs.get(SPKeys.userDetailsResponse);
//
//     Map teleConsulResponse = json.decode(data);*/
//
//     // Commented getUserDetails API and instead getting data from SharedPreference
//
//     SharedPreferences prefs1 = await SharedPreferences.getInstance();
//     var data1 = prefs1.get('data');
//     Map res = jsonDecode(data1);
//     iHLUserId = res['User']['id'];
//
//     final getUserDetails = await http.post(
//       Uri.parse(API.iHLUrl + "/consult/get_user_details"),
//       body: jsonEncode(<String, dynamic>{
//         'ihl_id': iHLUserId,
//       }),
//     );
//     if (getUserDetails.statusCode == 200) {
//     } else {
//       print(getUserDetails.body);
//     }
//
//     Map teleConsulResponse = json.decode(getUserDetails.body);
//
//     loading = false;
//     if (teleConsulResponse['appointments'] == null ||
//         !(teleConsulResponse['appointments'] is List) ||
//         teleConsulResponse['appointments'].isEmpty) {
//       if (this.mounted) {
//         setState(() {
//           hasappointment = false;
//         });
//       }
//       return;
//     }
//     appointment = teleConsulResponse['appointments'];
//     approvedAppointments = appointment
//         .where((i) =>
//             i["appointment_status"] == "Approved" ||
//             i["appointment_status"] == "Accepted" ||
//             i["appointment_status"] == "Requested" ||
//             i["appointment_status"] == "requested")
//         .toList();
//
//     var currentDateTime = new DateTime.now();
//
//     for (int i = 0; i < approvedAppointments.length; i++) {
//       var endTime = approvedAppointments[i]["appointment_end_time"];
//       String appointmentEndTime = endTime;
//       if (appointmentEndTime[7] != '-') {
//         String appEndTime = '';
//         for (var i = 0; i < appointmentEndTime.length; i++) {
//           if (i == 5) {
//             appEndTime += '0' + appointmentEndTime[i];
//           } else {
//             appEndTime += appointmentEndTime[i];
//           }
//         }
//         appointmentEndTime = appEndTime;
//       }
//       if (appointmentEndTime[10] != " ") {
//         String appEndTime = '';
//         for (var i = 0; i < appointmentEndTime.length; i++) {
//           if (i == 8) {
//             appEndTime += '0' + appointmentEndTime[i];
//           } else {
//             appEndTime += appointmentEndTime[i];
//           }
//         }
//         appointmentEndTime = appEndTime;
//       }
//       String appointmentEndTimeSubstring = appointmentEndTime.substring(11, 19);
//       String appointmentEndDateSubstring = appointmentEndTime.substring(0, 10);
//       DateTime endTimeFormatTime =
//           DateFormat.jm().parse(appointmentEndTimeSubstring);
//       String endTimeString = DateFormat("HH:mm:ss").format(endTimeFormatTime);
//       String fullAppointmentEndDate =
//           appointmentEndDateSubstring + " " + endTimeString;
//       var appointmentEndingTime = DateTime.parse(fullAppointmentEndDate);
//
//       if (appointmentEndingTime.isAfter(currentDateTime)) {
//         alist.add(approvedAppointments[i]);
//       }
//     }
//
//     List<DateTime> formattedTime = [];
//     List<String> stringFormattedDateTime = [];
//     for (int i = 0; i < alist.length; i++) {
//       String date = alist[i]["appointment_start_time"];
//       if (date[7] != '-') {
//         String appStartTime = '';
//         for (var i = 0; i < date.length; i++) {
//           if (i == 5) {
//             appStartTime += '0' + date[i];
//           } else {
//             appStartTime += date[i];
//           }
//         }
//         date = appStartTime;
//       }
//       if (date[10] != " ") {
//         String appStartTime = '';
//         for (var i = 0; i < date.length; i++) {
//           if (i == 8) {
//             appStartTime += '0' + date[i];
//           } else {
//             appStartTime += date[i];
//           }
//         }
//         date = appStartTime;
//       }
//       String stringTime = date.substring(11, 19);
//       date = date.substring(0, 10);
//       DateTime formattime = DateFormat.jm().parse(stringTime);
//       String time = DateFormat("HH:mm:ss").format(formattime);
//       String dateToFormat = date + " " + time;
//       var newTime = DateTime.parse(dateToFormat);
//       formattedTime.add(newTime);
//     }
//     formattedTime.sort((a, b) => a.compareTo(b));
//     List appointmentDetails = [];
//     List temp = [];
//     sort(List subscriptionsDetails) {
//       if (subscriptionsDetails == null || subscriptionsDetails.length == 0)
//         return;
//       for (int i = 0; i < subscriptionsDetails.length; i++) {
//         String stringFormattedTime =
//             DateFormat("yyyy-MM-dd hh:mm aaa").format(formattedTime[i]);
//         stringFormattedDateTime.add(stringFormattedTime);
//         temp.add(subscriptionsDetails[i]["appointment_start_time"]);
//       }
//       for (int i = 0; i < stringFormattedDateTime.length; i++) {
//         if (temp.contains(stringFormattedDateTime[i])) {
//           //if two appoinmnets of same day and time then issue comes in ordering
//           //int ii = temp.indexOf(stringFormattedDateTime[i]);
//           appointmentDetails.add(subscriptionsDetails[i]);
//         }
//       }
//     }
//
//     sort(alist);
//     alist = appointmentDetails;
//
//     if (this.mounted) {
//       setState(() {
//         alist = alist.where((i) => i != null).toList();
//       });
//     }
//
//     if (this.mounted) {
//       setState(() {
//         hasappointment = true;
//       });
//     }
//   }
//
//   getSharedAppIdList() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     sharedReportAppIdList = prefs.getStringList('sharedReportAppIdList') ?? [];
//   }
//
// //Changed to check genix in isapproved and ispending
//   DashBoardAppointmentTile getItem(Map map) {
//     return DashBoardAppointmentTile(
//       ihlConsultantId: map["ihl_consultant_id"],
//       name: map["consultant_name"],
//       date: map["appointment_start_time"],
//       endDateTime: map["appointment_end_time"],
//       consultationFees: map['consultation_fees'],
//       isApproved: map['appointment_status'] == "Approved" ||
//           map['appointment_status'] == "Approved",
//       isRejected: map['appointment_status'] == "rejected" ||
//           map['appointment_status'] == "Rejected",
//       isPending: map['appointment_status'] == "requested" ||
//           map['appointment_status'] == "Requested",
//       isCancelled: map['appointment_status'] == "canceled" ||
//           map["appointment_status"] == "Canceled",
//       isCompleted: map['appointment_status'] == "completed" ||
//           map['appointment_status'] == "Completed",
//       appointmentId: map['appointment_id'],
//       callStatus: map['call_status'] ?? "N/A",
//       vendorId: map['vendor_id'],
//       sharedReportAppIdList: sharedReportAppIdList,
//     );
//   }
// //  TeleConsultation End
//
//   // heighttile variables
//   String height = '';
//   String weight = '';
//   var bmi;
//   String weightfromvitalsData = '';
//   bool s;
//   bool feet = false;
//   String score = '';
//   String firstName = '';
//   String lastName = '';
//   Map vitals = {};
//   String IHL_User_ID;
//   String selectedSpecality;
//
//   // end heighttile variable
//   ListApis listApis = ListApis();
//   // heighttile parameters
//   Future<void> getHeightWeightData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var data = prefs.get(SPKeys.userData);
//     double finalWeight = prefs.getDouble(SPKeys.weight);
//     finalWeight = ((finalWeight ?? 0 * 100.0).toInt()) / 100;
//     weightfromvitalsData = finalWeight.toString();
//     data = data == null || data == '' ? '{"User":{}}' : data;
//     Map res = jsonDecode(data);
//     res['User']['user_score'] ??= {};
//     res['User']['user_score']['T'] ??= 'N/A';
//     score = res['User']['user_score']['T'].toString();
//     s = prefs.getBool('allAns');
//     firstName = res['User']['firstName'];
//     firstName ??= '';
//     lastName = res['User']['lastName'];
//     lastName ??= '';
//     prefs.setString('name', firstName + ' ' + lastName);
//     if (res['User']['heightMeters'] is num) {
//       height = (res['User']['heightMeters'] * 100).toInt().toString();
//     }
//     height ??= '';
//     if (weightfromvitalsData == null || weightfromvitalsData == 'null') {
//       weightfromvitalsData = '';
//     }
//     if (res.length == 3) {
//       if (res['LastCheckin']['weightKG'] != null) {
//         weight = ((((res['LastCheckin']['weightKG']) * 100.0).toInt()) / 100)
//                 .toString() ??
//             "";
//       }
//     }
//     if (weight == null || weight == '') {
//       weight = res['User']['userInputWeightInKG'];
//     }
//
//     weight = weight == 'null' ? '' : weight;
//     weight ??= '';
//     bmi = calcBmiNew(weight: weight.toString(), height: height.toString());
//     print(bmi);
//     // userAffiliation = res['User']['affiliate'].toString();
//     // userAffiliation = AppTexts.affiliationOp.contains(userAffiliation)
//     // ? userAffiliation
//     // : 'none';
//     //   if (res['LastCheckin'] != null &&
//     //       (res['LastCheckin']['weightKG'] != null ||
//     //           res['LastCheckin']['weightKG'] != '') &&
//     //       res.length == 3) {
//     //     showWeight = false;
//     //   }
//     //   if (email == '' || email == null) {
//     //     emailFixed = false;
//     //   }
//     //   isloading = false;
//     //   if (this.mounted) {
//     //     this.setState(() {});
//     //   }
//   }
//
// // end heighttile parameters
// // activity data
//   void getDailyActivityData() async {
//     listApis.getUserTodaysFoodLogHistoryApi().then((value) {
//       if (mounted) {
//         setState(() {
//           todaysActivityData = value['activity'];
//           otherActivityData = value['previous_activity'];
//         });
//       }
//     });
//   }
//
//   // get bmi value
//   void getUserBMIDetails() async {
//     SharedPreferences prefs1 = await SharedPreferences.getInstance();
//     IHL_User_ID = prefs1.getString("ihlUserId");
//     selectedSpecality = prefs1.getString("selectedSpecality");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var email = prefs.get('email');
//     var data = prefs.get('data');
//     Map res = jsonDecode(data);
//     var mobileNumber = res['User']['mobileNumber'];
//     var dob = res['User']['dateOfBirth'].toString();
//     // var bmi_ =
//   }
//   // end bmi value
//
// // activity data ends
//   StreamingSharedPreferences preferences;
//   int dailytarget = 0;
//   double newbmi;
//   void getBMI() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var data = prefs.get('data');
//     Map res = jsonDecode(data);
//     if (this.mounted) {
//       setState(() {
//         name = res['User']['firstName'] ?? 'User';
//         // newbmi = res['LastCheckin']['bmi'];
//         print(newbmi);
//       });
//     }
//   }
//
//   bool hasSubscription = false;
//   // List subscriptions = [];
//   List approvedSubscriptions;
//   var slist = [];
//   // Subscription class method
//
//   Future getSubscriptionClassData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var data = prefs.get(SPKeys.userDetailsResponse);
//
//     Map teleConsulResponse = json.decode(data);
//     loading = false;
//     if (teleConsulResponse['my_subscriptions'] == null ||
//         !(teleConsulResponse['my_subscriptions'] is List) ||
//         teleConsulResponse['my_subscriptions'].isEmpty) {
//       if (this.mounted) {
//         setState(() {
//           hasSubscription = false;
//         });
//       }
//       return;
//     }
//     if (this.mounted) {
//       setState(() {
//         subscriptions = teleConsulResponse['my_subscriptions'];
//         approvedSubscriptions = subscriptions
//             .where((i) =>
//                 i["approval_status"] == "Approved" ||
//                 i["approval_status"] == "Accepted" ||
//                 i["approval_status"] == "Requested" ||
//                 i["approval_status"] == "requested")
//             .toList();
//         var currentDateTime = new DateTime.now();
//
//         for (int i = 0; i < approvedSubscriptions.length; i++) {
//           var duration = approvedSubscriptions[i]["course_duration"];
//           var time = approvedSubscriptions[i]["course_time"];
//           var approvelStatus = approvedSubscriptions[i]["approval_status"];
//
//           String courseDurationFromApi = duration;
//           String courseTimeFromApi = time;
//
//           String courseStartTime;
//           String courseEndTime;
//
//           String courseStartDuration = courseDurationFromApi.substring(0, 10);
//
//           String courseEndDuration = courseDurationFromApi.substring(13, 23);
//
//           DateTime startDate =
//               new DateFormat("yyyy-MM-dd").parse(courseStartDuration);
//           final DateFormat formatter = DateFormat('yyyy-MM-dd');
//           String startDateFormattedToString = formatter.format(startDate);
//
//           DateTime endDate =
//               new DateFormat("yyyy-MM-dd").parse(courseEndDuration);
//           String endDateFormattedToString = formatter.format(endDate);
//           if (courseTimeFromApi[2].toString() == ':' &&
//               courseTimeFromApi[13].toString() != ':') {
//             var tempcourseEndTime = '';
//             courseStartTime = courseTimeFromApi.substring(0, 8);
//             for (var i = 0; i < courseTimeFromApi.length; i++) {
//               if (i == 10) {
//                 tempcourseEndTime += '0';
//               } else if (i > 10) {
//                 tempcourseEndTime += courseTimeFromApi[i];
//               }
//             }
//             courseEndTime = tempcourseEndTime;
//           } else if (courseTimeFromApi[2].toString() != ':') {
//             var tempcourseStartTime = '';
//             var tempcourseEndTime = '';
//
//             for (var i = 0; i < courseTimeFromApi.length; i++) {
//               if (i == 0) {
//                 tempcourseStartTime = '0';
//               } else if (i > 0 && i < 8) {
//                 tempcourseStartTime += courseTimeFromApi[i - 1];
//               } else if (i > 9) {
//                 tempcourseEndTime += courseTimeFromApi[i];
//               }
//             }
//             courseStartTime = tempcourseStartTime;
//             courseEndTime = tempcourseEndTime;
//             if (courseEndTime[2].toString() != ':') {
//               var tempcourseEndTime = '';
//               for (var i = 0; i <= courseEndTime.length; i++) {
//                 if (i == 0) {
//                   tempcourseEndTime += '0';
//                 } else {
//                   tempcourseEndTime += courseEndTime[i - 1];
//                 }
//               }
//               courseEndTime = tempcourseEndTime;
//             }
//           } else {
//             courseStartTime = courseTimeFromApi.substring(0, 8);
//             courseEndTime = courseTimeFromApi.substring(11, 19);
//           }
//
//           DateTime startTime = DateFormat.jm().parse(courseStartTime);
//           DateTime endTime = DateFormat.jm().parse(courseEndTime);
//
//           String startingTime = DateFormat("HH:mm:ss").format(startTime);
//           String endingTime = DateFormat("HH:mm:ss").format(endTime);
//           String startDateAndTime =
//               startDateFormattedToString + " " + startingTime;
//           String endDateAndTime = endDateFormattedToString + " " + endingTime;
//           DateTime finalStartDateTime =
//               new DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
//           DateTime finalEndDateTime =
//               new DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);
//           if (finalEndDateTime.isAfter(currentDateTime) ||
//               approvelStatus == "Cancelled" ||
//               approvelStatus == "cancelled") {
//             slist.add(approvedSubscriptions[i]);
//           }
//         }
//         hasSubscription = true;
//       });
//     }
//   }
//
//   DashBoardSubscriptionTile getSubscriptionClassItem(Map map) {
//     return DashBoardSubscriptionTile(
//         subscription_id: map["subscription_id"],
//         trainerId: map["consultant_id"],
//         trainerName: map["consultant_name"],
//         title: map["title"],
//         duration: map["course_duration"],
//         time: map["course_time"],
//         provider: map['provider'],
//         isApproved: map['approval_status'] == "Accepted",
//         isRejected: map['approval_status'] == "Rejected",
//         isRequested: map['approval_status'] == "Requested" ||
//             map['approval_status'] == 'requested',
//         isCancelled: map['approval_status'] == "Cancelled" ||
//             map['approval_status'] == 'cancelled',
//         courseOn: map['course_on'],
//         courseTime: map['course_time'],
//         courseId: map['course_id']);
//   }
//
//   @override
//   void initState() {
//     init();
//     surveybmiCalc();
//     getWeekData();
//     getTarget();
//     getBMI();
//     getEventDetails();
//     super.initState();
//     getData();
//     getUserBMIDetails();
//     getSubscriptionClassListData();
//     getDailyActivityData();
//     getAppointmentData();
//     getHeightWeightData();
//     getSharedAppIdList();
//     getSubscriptionClassData();
//     getExpiredSubscriptionHistoryData();
//     getAppointmentHistoryData();
//     getConsultantImageURL();
//     // getUserDetails();
//
//     _expandableController = ExpandableController(
//       initialExpanded: true,
//     );
//     _expandableController.addListener(() {
//       if (this.mounted) {
//         setState(() {
//           expanded = _expandableController.expanded;
//         });
//       }
//     });
//   }
//
//   ///variable and funciton for event details///start=>
//   List eventDetailList;
//   var userEnrolledMap;
//   getEventDetails() async {
//     SharedPreferences prefs1 = await SharedPreferences.getInstance();
//     var data1 = prefs1.get('data');
//     Map res = jsonDecode(data1);
//     var iHL_User_Id = res['User']['id'];
//     // eventDetailList = await eventDetailApi();
//     // userEnrolledMap = await isUserEnrolledApi(ihl_user_id: iHL_User_Id,event_id: eventDetailList[0]['event_id']);
//
//     // eventDetailApi().then((value) async{
//     eventDetailList = await eventDetailApi();
//
//     if (eventDetailList != null) {
//       // isUserEnrolledApi(ihl_user_id: iHL_User_Id,event_id: eventDetailList[0]['event_id']).then((v){
//       userEnrolledMap = await isUserEnrolledApi(
//           ihl_user_id: iHL_User_Id, event_id: eventDetailList[0]['event_id']);
//       // });
//       print(userEnrolledMap.toString());
//       print(eventDetailList[0]['event_varients']);
//       setState(() {});
//     }
//
//     // });
//   }
//
// // consultation history functions starts
// // counsultation history functions ends
//   void init() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     StreamingSharedPreferences.instance.then((value) {
//       setState(() {
//         preferences = value;
//       });
//     });
//     dailyTarget().then((value) {
//       setState(() {
//         dailytarget = int.parse(value);
//         prefs.setInt('daily_target', dailytarget);
//         prefs.setInt('weekly_target', dailytarget * 7);
//         prefs.setInt(
//             'monthly_target', dailytarget * daysInMonth(DateTime.now()));
//       });
//     });
//   }
//
//   Future<String> dailyTarget() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int dailyTarget = prefs.getInt('daily_target');
//     if (dailyTarget == null || dailyTarget == 0) {
//       var userData = prefs.get('data');
//       preferences.setBool('maintain_weight', true);
//       Map res = jsonDecode(userData);
//       var height;
//       DateTime birthDate;
//       String datePattern = "MM/dd/yyyy";
//       var dob = res['User']['dateOfBirth'].toString();
//       DateTime today = DateTime.now();
//       try {
//         birthDate = DateFormat(datePattern).parse(dob);
//       } catch (e) {
//         birthDate = DateFormat('MM-dd-yyyy').parse(dob);
//       }
//       int age = today.year - birthDate.year;
//       if (res['User']['heightMeters'] is num) {
//         height = (res['User']['heightMeters'] * 100).toInt().toString();
//       }
//       var weight = res['User']['userInputWeightInKG'] ?? '0';
//       if (weight == '') {
//         weight = prefs.get('userLatestWeight').toString();
//       }
//       var m = res['User']['gender'];
//       num maleBmr = (10 * double.parse(weight.toString()) +
//           6.25 * double.parse(height) -
//           (5 * age) +
//           5);
//       num femaleBmr = (10 * double.parse(weight) +
//           6.25 * double.parse(height) -
//           (5 * age) -
//           161);
//       return (m == 'm' || m == 'M' || m == 'male' || m == 'Male')
//           ? maleBmr.toStringAsFixed(0)
//           : femaleBmr.toStringAsFixed(0);
//     } else {
//       bool maintainWeight = prefs.getBool('maintain_weight');
//       if (maintainWeight == null) {
//         preferences.setBool('maintain_weight', true);
//       }
//       return dailyTarget.toString();
//     }
//   }
//
//   int daysInMonth(DateTime date) {
//     var firstDayThisMonth = new DateTime(date.year, date.month, date.day);
//     var firstDayNextMonth = new DateTime(firstDayThisMonth.year,
//         firstDayThisMonth.month + 1, firstDayThisMonth.day);
//     return firstDayNextMonth.difference(firstDayThisMonth).inDays;
//   }
//
//   String heightft() {
//     double h = double.tryParse(height);
//     if (h == null) {
//       return '';
//     }
//     return cmToFeetInch(h.toInt());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var difference;
//     double width = MediaQuery.of(context).size.width;
//     if (width < 600) {
//       width = 500;
//     }
//     if (loading) {
//       return SafeArea(
//         child: Container(
//           color: AppColors.bgColorTab,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 40,
//                     child: TextButton(
//                       child: Icon(
//                         Icons.menu,
//                         size: 30,
//                         color: Colors.white,
//                       ),
//                       onPressed: () {
//                         widget.openDrawer();
//                       },
//                       style: TextButton.styleFrom(
//                         padding: EdgeInsets.all(0),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     if (!isVerified) {
//       return SafeArea(
//         child: Container(
//           color: AppColors.bgColorTab,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 40,
//                     child: TextButton(
//                       child: Icon(
//                         Icons.menu,
//                         size: 30,
//                         color: AppColors.primaryAccentColor,
//                       ),
//                       onPressed: () {
//                         widget.openDrawer();
//                       },
//                       style: TextButton.styleFrom(
//                         padding: EdgeInsets.all(0),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Center(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       size: 100,
//                       color: AppColors.lightTextColor,
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     Text(AppTexts.updateProfile),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     TextButton(
//                       style: TextButton.styleFrom(
//                         backgroundColor: AppColors.primaryAccentColor,
//                         textStyle: TextStyle(color: Colors.white),
//                       ),
//                       child: Text(AppTexts.visitProfile),
//                       onPressed: () {
//                         widget.goToProfile();
//                       },
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return SafeArea(
//       // first container
//       child: Container(
//         // color: Color.fromRGBO(216, 227, 246, 1),
//         color: AppColors.primaryAccentColor.withOpacity(0.8),
//         child: Padding(
//           padding: const EdgeInsets.all(6.0),
//           // second container
//           child: Container(
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(20),
//                 ),
//                 color: Colors.white),
//             child: Padding(
//               padding: const EdgeInsets.all(7),
//               // third container
//               child: Column(
//                 children: [
//                   // menu bar and user name starts
//                   Container(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         SizedBox(
//                           width: 60,
//                           child: TextButton(
//                             child: Icon(
//                               Icons.menu,
//                               size: 30,
//                               color: Color.fromRGBO(24, 31, 57, 1),
//                             ),
//                             onPressed: () {
//                               widget.openDrawer();
//                             },
//                             style: TextButton.styleFrom(
//                               padding: EdgeInsets.all(0),
//                             ),
//                           ),
//                         ),
//                         Column(
//                           children: [
//                             Center(
//                               child: RichText(
//                                 text: TextSpan(
//                                   text: 'Hello!!!' + ' ' + firstName,
//                                   style: TextStyle(
//                                     color: Color.fromRGBO(24, 31, 57, 1),
//                                     fontSize: ScUtil().setSp(17),
//                                     // height: 5.0,
//                                     fontFamily: 'Poppins',
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         // profile pic starts
//                         IconButton(
//                           onPressed: () {
//                             Navigator.of(context)
//                                 .pushNamed(Routes.Profile, arguments: false);
//                             // Get.to(
//                             //   ProfileTab(),
//                             // );
//                           },
//                           icon: Icon(Icons.person_outline_rounded),
//                         )
//                         // profile pic ends
//                       ],
//                     ),
//                   ),
//                   // menu bar and user name ends
//                   Expanded(
//                     flex: 2,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(20),
//                         ),
//                         color: Color.fromRGBO(244, 245, 252, 1),
//                       ),
//                       // 1 main column
//                       child: SingleChildScrollView(
//                         // physics: NeverScrollableScrollPhysics(),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: <Widget>[
//                             SizedBox(
//                               height: 8.0,
//                             ),
//                             // Marathon heading starts
//                             Padding(
//                               padding: const EdgeInsets.only(left: 16.0),
//                               child: Container(
//                                 // color: Colors.amber,
//                                 height: MediaQuery.of(context).size.height / 36,
//                                 width: MediaQuery.of(context).size.width / 1.35,
//
//                                 child: Text(
//                                   '   Events ',
//                                   // textAlign: TextAlign.left,
//                                   style: TextStyle(
//                                     fontFamily: FitnessAppTheme.fontName,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: ScUtil().setSp(15),
//                                     // letterSpacing: -1,
//                                     // color: AppColors.textitemTitleColor,
//                                     // color: Color.fromRGBO(166, 167, 187, 1),
//                                     color: Color.fromRGBO(
//                                       132,
//                                       132,
//                                       160,
//                                       1,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // Marathon headin ends
//                             // Marathon Section starts
//                             SizedBox(height: 8.0),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 16.0),
//                               child: Container(
//                                 width: MediaQuery.of(context).size.width,
//                                 // width: ScUtil().setWidth(width),
//                                 height: ScUtil().setHeight(170),
//                                 child: eventDetailList != null &&
//                                         userEnrolledMap != null
//                                     ? MarathonCard(
//                                         eventDetailList: eventDetailList,
//                                         userEnrolledMap: userEnrolledMap,
//                                       )
//                                     : Column(
//                                         children: [
//                                           Lottie.network(
//                                               "https://assets8.lottiefiles.com/packages/lf20_zjrmnlsu.json",
//                                               height: ScUtil().setHeight(155)),
//                                           Text("Loading...",
//                                               style: TextStyle(
//                                                   fontSize: ScUtil().setSp(10),
//                                                   fontWeight: FontWeight.w600))
//                                         ],
//                                       ),
//                               ),
//                             ),
//                             // Marathon section ends
//                             SizedBox(height: 8.0),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15.0),
//                               child: Container(
//                                 // color: Colors.green,
//                                 child: SingleChildScrollView(
//                                   scrollDirection: Axis.horizontal,
//                                   child: Container(
//                                     child: Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         // consultation history starts
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             // upcoming heading container starts
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 8.0),
//                                               child: Container(
//                                                 // color: Colors.amber,
//                                                 height: MediaQuery.of(context)
//                                                         .size
//                                                         .height /
//                                                     36,
//                                                 width: MediaQuery.of(context)
//                                                         .size
//                                                         .width /
//                                                     1.35,
//                                                 child: Text(
//                                                   'Appointments',
//                                                   // textAlign: TextAlign.left,
//                                                   style: TextStyle(
//                                                     fontFamily: FitnessAppTheme
//                                                         .fontName,
//                                                     fontWeight: FontWeight.w700,
//                                                     fontSize:
//                                                         ScUtil().setSp(15),
//                                                     // letterSpacing: -1,
//                                                     // color: AppColors.textitemTitleColor,
//                                                     // color: Color.fromRGBO(166, 167, 187, 1),
//                                                     color: Color.fromRGBO(
//                                                       132,
//                                                       132,
//                                                       160,
//                                                       1,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             // upcoming heading container ends
//                                             SizedBox(height: 8.0),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 8.0, bottom: 0.0),
//                                               child: Card(
//                                                 shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             30)),
//                                                 child: (alist.length == 0)
//                                                     ?
//
//                                                     // appointment completed history starts
//
//                                                     Container(
//                                                         width: ScUtil()
//                                                             .setWidth(280),
//                                                         height: ScUtil()
//                                                             .setHeight(170),
//                                                         child: Card(
//                                                           shape:
//                                                               RoundedRectangleBorder(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .all(
//                                                               Radius.circular(
//                                                                   20),
//                                                             ),
//                                                           ),
//                                                           color: Color.fromRGBO(
//                                                               35,
//                                                               107,
//                                                               254,
//                                                               0.8),
//                                                           child: Container(
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius.circular(20),
//                                                               gradient: LinearGradient(
//                                                                 begin: Alignment
//                                                                     .bottomCenter,
//                                                                 end: Alignment
//                                                                     .topCenter,
//                                                                 colors: [
//                                                                   Colors.indigo[
//                                                                       900],
//                                                                   //Colors.lightBlue,
//                                                                   Colors.blue,
//                                                                 ],
//                                                                 stops: [
//                                                                   0.0,
//                                                                   1.0
//                                                                 ],
//                                                                 tileMode:
//                                                                     TileMode
//                                                                         .clamp,
//                                                               ),
//                                                             ),
//                                                             child: Column(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .spaceEvenly,
//                                                               children: [
//                                                                 SizedBox(
//                                                                   height: 2.0,
//                                                                 ),
//                                                                 Text(
//                                                                   "No Upcoming Appointments!",
//                                                                   style: TextStyle(
//                                                                       fontSize:
//                                                                           15.0,
//                                                                       letterSpacing:
//                                                                           1.5,
//                                                                       color: Colors
//                                                                           .white,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w600),
//                                                                 ),
//                                                                 SizedBox(
//                                                                   height: 4.0,
//                                                                 ),
//                                                                 TextButton(
//                                                                   style:
//                                                                       ButtonStyle(
//                                                                     backgroundColor:
//                                                                         MaterialStateProperty.all<
//                                                                             Color>(
//                                                                       Colors
//                                                                           .white
//                                                                           .withOpacity(
//                                                                               1),
//                                                                     ),
//                                                                   ),
//                                                                   color: Color
//                                                                       .fromRGBO(
//                                                                           35,
//                                                                           107,
//                                                                           254,
//                                                                           0.8),
//                                                                   child:
//                                                                       Container(
//                                                                     decoration:
//                                                                         BoxDecoration(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               20),
//                                                                       gradient:
//                                                                           LinearGradient(
//                                                                         begin: Alignment
//                                                                             .bottomCenter,
//                                                                         end: Alignment
//                                                                             .topCenter,
//                                                                         colors: [
//                                                                           Colors
//                                                                               .indigo[900],
//                                                                           //Colors.lightBlue,
//                                                                           Colors
//                                                                               .blue,
//                                                                         ],
//                                                                         stops: [
//                                                                           0.0,
//                                                                           1.0
//                                                                         ],
//                                                                         tileMode:
//                                                                             TileMode.clamp,
//                                                                       ),
//                                                                     ),
//                                                                     child:
//                                                                         Column(
//                                                                       crossAxisAlignment:
//                                                                           CrossAxisAlignment
//                                                                               .center,
//                                                                       mainAxisAlignment:
//                                                                           MainAxisAlignment
//                                                                               .spaceEvenly,
//                                                                       children: [
//                                                                         SizedBox(
//                                                                           height:
//                                                                               2.0,
//                                                                         ),
//                                                                         Center(
//                                                                           child:
//                                                                               Text(
//                                                                             // alist.length == 0
//                                                                             "Please wait....",
//                                                                             style: TextStyle(
//                                                                                 fontSize: 15.0,
//                                                                                 letterSpacing: 1.5,
//                                                                                 color: Colors.white,
//                                                                                 fontWeight: FontWeight.w600),
//                                                                             textAlign:
//                                                                                 TextAlign.center,
//                                                                           ),
//                                                                         ),
//                                                                         SizedBox(
//                                                                           height:
//                                                                               1.0,
//                                                                         ),
//                                                                         Text(
//                                                                           '(OR)',
//                                                                           style: TextStyle(
//                                                                               fontSize: 15.0,
//                                                                               letterSpacing: 1.5,
//                                                                               color: Colors.white,
//                                                                               fontWeight: FontWeight.w600),
//                                                                         ),
//                                                                         SizedBox(
//                                                                           height:
//                                                                               1.0,
//                                                                         ),
//                                                                         TextButton(
//                                                                           style:
//                                                                               ButtonStyle(
//                                                                             backgroundColor:
//                                                                                 MaterialStateProperty.all<Color>(
//                                                                               Colors.white.withOpacity(1),
//                                                                             ),
//                                                                             shape:
//                                                                                 MaterialStateProperty.all<RoundedRectangleBorder>(
//                                                                               RoundedRectangleBorder(
//                                                                                 borderRadius: BorderRadius.circular(18.0),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                           onPressed:
//                                                                               () {
//                                                                             Navigator.of(context).pushNamed(Routes.ConsultationType,
//                                                                                 arguments: false);
//                                                                           },
//                                                                           child:
//                                                                               Text(
//                                                                             'Book Appointment',
//                                                                             style:
//                                                                                 TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
//                                                                           ),
//                                                                         )
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               )
//
//                                                             // Center(
//                                                             //     child:
//                                                             //         Column(
//                                                             //       mainAxisAlignment:
//                                                             //           MainAxisAlignment
//                                                             //               .center,
//                                                             //       children: [
//                                                             //         Text(
//                                                             //             'Please Wait.....',
//                                                             //             style: TextStyle(
//                                                             //                 fontSize: 12.0,
//                                                             //                 color: Colors.black,
//                                                             //                 fontWeight: FontWeight.w600)),
//                                                             //         CircularProgressIndicator(
//                                                             //             color:
//                                                             //                 Colors.white),
//                                                             //       ],
//                                                             //     ),
//                                                             //   )
//
//                                                             : Container(
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               20),
//                                                                   gradient:
//                                                                       LinearGradient(
//                                                                     begin: Alignment
//                                                                         .bottomCenter,
//                                                                     end: Alignment
//                                                                         .topCenter,
//                                                                     colors: [
//                                                                       Colors.indigo[
//                                                                           900],
//                                                                       //Colors.lightBlue,
//                                                                       Colors
//                                                                           .blue,
//                                                                     ],
//                                                                     stops: [
//                                                                       0.0,
//                                                                       1.0
//                                                                     ],
//                                                                     tileMode:
//                                                                         TileMode
//                                                                             .clamp,
//                                                                   ),
//                                                                 ),
//                                                                 child: Column(
//                                                                   children: [
//                                                                     ListTile(
//                                                                       contentPadding: EdgeInsets.only(
//                                                                           left:
//                                                                               15.0,
//                                                                           top:
//                                                                               5.0),
//                                                                       title:
//                                                                           Padding(
//                                                                         padding:
//                                                                             const EdgeInsets.only(bottom: 5.0),
//                                                                         child:
//                                                                             Text(
//                                                                           completed_appointmentDetails[3]['consultant_name']
//                                                                               .toString(),
//                                                                           style: TextStyle(
//                                                                               height: ScUtil().setSp(1),
//                                                                               fontSize: ScUtil().setSp(12),
//                                                                               fontWeight: FontWeight.w600,
//                                                                               color: Colors.white),
//                                                                         ),
//                                                                       ),
//                                                                       subtitle:
//                                                                           Text(
//                                                                         'Status:  ' +
//                                                                             completed_appointmentDetails[3]['appointment_status'].toString(),
//                                                                         style: TextStyle(
//                                                                             fontSize:
//                                                                                 ScUtil().setSp(12),
//                                                                             color: Colors.white),
//                                                                       ),
//                                                                       leading:
//                                                                           Container(
//                                                                         decoration: BoxDecoration(
//                                                                             borderRadius: BorderRadius.only(
//                                                                               topLeft: Radius.circular(10.0),
//                                                                               topRight: Radius.circular(10.0),
//                                                                               bottomLeft: Radius.circular(10.0),
//                                                                               bottomRight: Radius.circular(10.0),
//                                                                             ),
//                                                                             color: Colors.white),
//                                                                         width: ScUtil()
//                                                                             .setWidth(40),
//                                                                         height:
//                                                                             ScUtil().setHeight(35),
//                                                                         child:
//                                                                             CircleAvatar(
//                                                                           radius:
//                                                                               50.0,
//                                                                           backgroundImage: image == null
//                                                                               ? null
//                                                                               : image.image,
//                                                                           backgroundColor:
//                                                                               AppColors.primaryAccentColor,
//                                                                         ),
//                                                                         //     Padding(
//                                                                         //   padding:
//                                                                         //       const EdgeInsets.all(4),
//                                                                         //   child:
//                                                                         //       Image.asset(
//                                                                         //     'assets/images/newfdc.png',
//                                                                         //     fit:
//                                                                         //         BoxFit.fitHeight,
//                                                                         //   ),
//                                                                         // ),
//                                                                       ),
//                                                                       trailing:
//                                                                           Padding(
//                                                                         padding:
//                                                                             const EdgeInsets.only(bottom: 18.0),
//                                                                         child: PopupMenuButton<
//                                                                             String>(
//                                                                           // color: Colors.white,
//                                                                           icon:
//                                                                               Icon(
//                                                                             Icons.more_vert,
//                                                                             color:
//                                                                                 Colors.white,
//                                                                           ),
//                                                                           onSelected:
//                                                                               (k) async {
//                                                                             Navigator.of(context).pushNamed(Routes.ConsultationType,
//                                                                                 arguments: false);
//                                                                           },
//                                                                           itemBuilder:
//                                                                               (context) {
//                                                                             return [
//                                                                               PopupMenuItem(
//                                                                                 value: 'Book Appointments',
//                                                                                 child: Row(
//                                                                                   children: [
//                                                                                     Icon(
//                                                                                       Icons.book_outlined,
//                                                                                       color: AppColors.primaryColor,
//                                                                                     ),
//                                                                                     SizedBox(
//                                                                                       width: 4,
//                                                                                     ),
//                                                                                     Text('Book Appointments'),
//                                                                                   ],
//                                                                                 ),
//                                                                               ),
//                                                                             ];
//                                                                           },
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                     SizedBox(
//                                                                       height: MediaQuery.of(context)
//                                                                               .size
//                                                                               .height /
//                                                                           55,
//                                                                     ),
//                                                                     Padding(
//                                                                       padding: const EdgeInsets
//                                                                               .symmetric(
//                                                                           horizontal:
//                                                                               17.0),
//                                                                       child:
//                                                                           Row(
//                                                                         // crossAxisAlignment: CrossAxisAlignment.center,
//                                                                         mainAxisAlignment:
//                                                                             MainAxisAlignment.start,
//                                                                         children: [
//                                                                           Container(
//                                                                             child:
//                                                                                 Icon(
//                                                                               Icons.animation,
//                                                                               color: Colors.white,
//                                                                               size: 15.0,
//                                                                             ),
//                                                                           ),
//                                                                           SizedBox(
//                                                                             width:
//                                                                                 5.0,
//                                                                           ),
//                                                                           Text(
//                                                                             completed_appointmentDetails[3]['booked_date_time'].toString(),
//                                                                             style: TextStyle(
//                                                                                 fontSize: 12.0,
//                                                                                 color: Colors.white,
//                                                                                 fontWeight: FontWeight.w600),
//                                                                           ),
//                                                                           SizedBox(
//                                                                             width:
//                                                                                 22.0,
//                                                                           ),
//                                                                           Container(
//                                                                             child:
//                                                                                 Icon(
//                                                                               Icons.timer,
//                                                                               color: Colors.white,
//                                                                               size: 15.0,
//                                                                             ),
//                                                                           ),
//                                                                           SizedBox(
//                                                                             width:
//                                                                                 5.0,
//                                                                           ),
//                                                                           Text(
//                                                                             completed_appointmentDetails[3]['appointment_duration'].toString(),
//                                                                             style: TextStyle(
//                                                                                 fontSize: 12.0,
//                                                                                 color: Colors.white,
//                                                                                 fontWeight: FontWeight.w600),
//                                                                           ),
//                                                                         ],
//                                                                       ),
//                                                                     ),
//                                                                     SizedBox(
//                                                                       height: ScUtil()
//                                                                           .setHeight(
//                                                                               26),
//                                                                     ),
//                                                                     ElevatedButton(
//                                                                       style: ElevatedButton.styleFrom(
//                                                                           shape: RoundedRectangleBorder(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10.0),
//                                                                           ),
//                                                                           primary: Colors.white,
//                                                                           textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                                                                       onPressed:
//                                                                           () {
//                                                                         Navigator.of(context)
//                                                                             .pushNamed(Routes.ConsultationHistory);
//                                                                       },
//                                                                       child: Text(
//                                                                           'More History',
//                                                                           style:
//                                                                               TextStyle(color: Colors.blueAccent)),
//                                                                     )
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                       )
//
//                                                     // appointment completed history starts
//
//                                                     : Container(
//                                                         // height:
//                                                         //     MediaQuery.of(context).size.height /
//                                                         //         3,
//                                                         // width: MediaQuery.of(context).size.width /
//                                                         //     1.17,
//                                                         child:
//                                                             getItem(alist[0]),
//                                                       ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         // consultation history ends
//                                         SizedBox(
//                                           width: 8.0,
//                                         ),
//                                         // My Fitness class starts
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             Container(
//                                               // color: Colors.amber,
//                                               height: MediaQuery.of(context)
//                                                       .size
//                                                       .height /
//                                                   36,
//                                               width: MediaQuery.of(context)
//                                                       .size
//                                                       .width /
//                                                   1.35,
//                                               child: Row(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Text(
//                                                     'Glance at your classes',
//                                                     // textAlign: TextAlign.left,
//                                                     style: TextStyle(
//                                                       fontFamily:
//                                                           FitnessAppTheme
//                                                               .fontName,
//                                                       fontWeight:
//                                                           FontWeight.w700,
//                                                       fontSize:
//                                                           ScUtil().setSp(15),
//                                                       // letterSpacing: -1,
//                                                       // color: AppColors.textitemTitleColor,
//                                                       // color: Color.fromRGBO(166, 167, 187, 1),
//                                                       color: Color.fromRGBO(
//                                                         132,
//                                                         132,
//                                                         160,
//                                                         1,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   InkWell(
//                                                     onTap: () {
//                                                       Navigator.pushAndRemoveUntil(
//                                                           context,
//                                                           MaterialPageRoute(
//                                                               builder: (context) =>
//                                                                   WellnessCart()),
//                                                           (Route<dynamic>
//                                                                   route) =>
//                                                               false);
//                                                     },
//                                                     child: Text(
//                                                       'More',
//                                                       // textAlign: TextAlign.left,
//                                                       style: TextStyle(
//                                                           fontFamily:
//                                                               FitnessAppTheme
//                                                                   .fontName,
//                                                           fontWeight:
//                                                               FontWeight.w900,
//                                                           fontSize: ScUtil()
//                                                               .setSp(14),
//                                                           // letterSpacing: 1,
//                                                           // color: color ?? AppColors.primaryColor,
//                                                           color: Color.fromRGBO(
//                                                               77, 122, 209, 1)),
//                                                     ),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                             SizedBox(height: 8.0),
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   right: 4.0),
//                                               child: Card(
//                                                 shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             20)),
//                                                 child: (slist.length == 0 ||
//                                                         hasSubscription ==
//                                                             false)
//                                                     ? Container(
//                                                         child: Column(
//                                                           children: [
//                                                             Container(
//                                                               // height: MediaQuery.of(context).size.height / 4.1,
//                                                               // width: MediaQuery.of(context).size.width / 1.24,
//                                                               width: ScUtil()
//                                                                   .setWidth(
//                                                                       280),
//                                                               height: ScUtil()
//                                                                   .setHeight(
//                                                                       170),
//                                                               child: Card(
//                                                                 shape:
//                                                                     RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .all(
//                                                                     Radius
//                                                                         .circular(
//                                                                             20),
//                                                                   ),
//                                                                 ),
//                                                                 color: Color
//                                                                     .fromRGBO(
//                                                                         35,
//                                                                         107,
//                                                                         254,
//                                                                         0.8),
//                                                                 child:
//                                                                     Container(
//                                                                   decoration:
//                                                                       BoxDecoration(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             20),
//                                                                     gradient:
//                                                                         LinearGradient(
//                                                                       begin: Alignment
//                                                                           .bottomCenter,
//                                                                       end: Alignment
//                                                                           .topCenter,
//                                                                       colors: [
//                                                                         Colors.grey[
//                                                                             900],
//                                                                         //Colors.lightBlue,
//                                                                         Colors.red[
//                                                                             900],
//                                                                       ],
//                                                                       stops: [
//                                                                         0.0,
//                                                                         1.0
//                                                                       ],
//                                                                       tileMode:
//                                                                           TileMode
//                                                                               .clamp,
//                                                                     ),
//                                                                   ),
//                                                                   child: Column(
//                                                                     mainAxisAlignment:
//                                                                         MainAxisAlignment
//                                                                             .spaceEvenly,
//                                                                     children: [
//                                                                       SizedBox(
//                                                                         height:
//                                                                             3.0,
//                                                                       ),
//                                                                       Text(
//                                                                         "No Upcoming Classes!",
//                                                                         style: TextStyle(
//                                                                             fontSize:
//                                                                                 15.0,
//                                                                             letterSpacing:
//                                                                                 1.5,
//                                                                             color:
//                                                                                 Colors.white,
//                                                                             fontWeight: FontWeight.w600),
//                                                                       ),
//                                                                       SizedBox(
//                                                                         height:
//                                                                             4.0,
//                                                                       ),
//                                                                       TextButton(
//                                                                         style:
//                                                                             ButtonStyle(
//                                                                           backgroundColor:
//                                                                               MaterialStateProperty.all<Color>(
//                                                                             Colors.white.withOpacity(1),
//                                                                           ),
//                                                                           shape:
//                                                                               MaterialStateProperty.all<RoundedRectangleBorder>(
//                                                                             RoundedRectangleBorder(
//                                                                               borderRadius: BorderRadius.circular(18.0),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         onPressed:
//                                                                             () {
//                                                                           // Navigator.of(context).pushNamed(
//                                                                           //     Routes.WellnessCart,
//                                                                           //     arguments: false);
//                                                                           Navigator
//                                                                               .push(
//                                                                             context,
//                                                                             MaterialPageRoute(
//                                                                               builder: (context) => SpecialityTypeScreen(arg: fitnessClassSpecialties),
//                                                                             ),
//                                                                           );
//                                                                         },
//                                                                         child:
//                                                                             Text(
//                                                                           'Start a New Class',
//                                                                           style: TextStyle(
//                                                                               color: Colors.blue,
//                                                                               fontWeight: FontWeight.bold),
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       )
//                                                     // Padding(
//                                                     //     padding:
//                                                     //         const EdgeInsets
//                                                     //                 .only(
//                                                     //             bottom:
//                                                     //                 0.0),
//                                                     //     child: Column(
//                                                     //       mainAxisAlignment:
//                                                     //           MainAxisAlignment
//                                                     //               .spaceEvenly,
//                                                     //       children: [
//                                                     //         SizedBox(
//                                                     //           height: 2.0,
//                                                     //         ),
//                                                     //         Container(
//                                                     //           child: getExpiredSubscriptionItem(
//                                                     //               elist[elist
//                                                     //                       .length -
//                                                     //                   1]),
//                                                     //         )
//                                                     //       ],
//                                                     //     ),
//                                                     //   )
//
//                                                     : Container(
//                                                         // height:
//                                                         //     MediaQuery.of(context).size.height /
//                                                         //         3,
//                                                         // width: MediaQuery.of(context).size.width /
//                                                         //     1.17,
//                                                         child:
//                                                             getSubscriptionClassItem(
//                                                                 slist[0]),
//                                                       ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         // My Fitness class ends
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // Tele Consultation ends
//                             SizedBox(height: 8.0),
//                             // Health journal starts
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15.0),
//                               child: Container(
//                                 height:
//                                     MediaQuery.of(context).size.height / 2.99,
//                                 width: MediaQuery.of(context).size.width / 1.12,
//                                 // color: Colors.green,
//                                 child: SingleChildScrollView(
//                                   scrollDirection: Axis.horizontal,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(left: 8.0),
//                                     child: Container(
//                                       child: Row(
//                                         children: [
//                                           Column(
//                                             children: [
//                                               // calorie Heading container starts
//                                               Container(
//                                                 // color: Colors.white,
//                                                 height: MediaQuery.of(context)
//                                                         .size
//                                                         .height /
//                                                     30,
//                                                 width: MediaQuery.of(context)
//                                                         .size
//                                                         .width /
//                                                     1.35,
//                                                 child: Row(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.center,
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     Text(
//                                                       'Glance at your calories',
//                                                       // textAlign: TextAlign.left,
//                                                       style: TextStyle(
//                                                         fontFamily:
//                                                             FitnessAppTheme
//                                                                 .fontName,
//                                                         fontWeight:
//                                                             FontWeight.w700,
//                                                         fontSize:
//                                                             ScUtil().setSp(15),
//                                                         // letterSpacing: -1,
//                                                         // color: AppColors.textitemTitleColor,
//                                                         // color: Color.fromRGBO(166, 167, 187, 1),
//                                                         color: Color.fromRGBO(
//                                                           132,
//                                                           132,
//                                                           160,
//                                                           1,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     InkWell(
//                                                       onTap: () {
//                                                         Navigator.pushAndRemoveUntil(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                                 builder:
//                                                                     (context) =>
//                                                                         DietJournal()),
//                                                             (Route<dynamic>
//                                                                     route) =>
//                                                                 false);
//                                                       },
//                                                       child: Text(
//                                                         'More',
//                                                         // textAlign: TextAlign.left,
//                                                         style: TextStyle(
//                                                             fontFamily:
//                                                                 FitnessAppTheme
//                                                                     .fontName,
//                                                             fontWeight:
//                                                                 FontWeight.w900,
//                                                             fontSize: ScUtil()
//                                                                 .setSp(14),
//                                                             // letterSpacing: 1,
//                                                             // color: color ?? AppColors.primaryColor,
//                                                             color:
//                                                                 Color.fromRGBO(
//                                                                     77,
//                                                                     122,
//                                                                     209,
//                                                                     1)),
//                                                       ),
//                                                     )
//                                                   ],
//                                                 ),
//                                               ),
//                                               // calorie Heading container ends
//                                               SizedBox(height: 8.0),
//                                               Container(
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             25.0),
//                                                     // color: Colors.green
//                                                     color: Colors.white),
//                                                 margin: EdgeInsets.only(
//                                                     top: 1.2, bottom: 1),
//                                                 height: MediaQuery.of(context)
//                                                         .size
//                                                         .height /
//                                                     3.5,
//                                                 width: MediaQuery.of(context)
//                                                         .size
//                                                         .width /
//                                                     1.25,
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     // kcals left starts
//                                                     Container(
//                                                       child: Row(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .center,
//                                                         // mainAxisAlignment:
//                                                         //     MainAxisAlignment
//                                                         //         .spaceEvenly,
//                                                         children: [
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                         .symmetric(
//                                                                     horizontal:
//                                                                         20.0,
//                                                                     vertical:
//                                                                         10.0),
//                                                             child: Container(
//                                                               height: MediaQuery.of(
//                                                                           context)
//                                                                       .size
//                                                                       .height /
//                                                                   22,
//                                                               width: MediaQuery.of(
//                                                                           context)
//                                                                       .size
//                                                                       .width /
//                                                                   10,
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .all(
//                                                                   Radius
//                                                                       .circular(
//                                                                           12.0),
//                                                                 ),
//                                                                 color: Colors
//                                                                     .redAccent
//                                                                     .withOpacity(
//                                                                         0.5),
//                                                               ),
//                                                               child: Padding(
//                                                                 padding: const EdgeInsets
//                                                                         .symmetric(
//                                                                     horizontal:
//                                                                         8.0,
//                                                                     vertical:
//                                                                         5.0),
//                                                                 child:
//                                                                     Container(
//                                                                   // color: Color.fromRGBO(
//                                                                   //     146, 52, 236, 0.5),
//                                                                   child: Image
//                                                                       .asset(
//                                                                     'assets/icons/kcals1.png',
//                                                                     height:
//                                                                         30.0,
//                                                                     width: 30.0,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           // kcals values starts
//                                                           Container(
//                                                             height: MediaQuery.of(
//                                                                         context)
//                                                                     .size
//                                                                     .height /
//                                                                 28,
//                                                             width: MediaQuery.of(
//                                                                         context)
//                                                                     .size
//                                                                     .width /
//                                                                 2.9,
//                                                             child: Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(1.0),
//                                                               child: preferences !=
//                                                                       null
//                                                                   ? PreferenceBuilder<
//                                                                           int>(
//                                                                       preference: preferences.getInt(
//                                                                           'burnedCalorie',
//                                                                           defaultValue:
//                                                                               0),
//                                                                       builder: (BuildContext
//                                                                               context,
//                                                                           int burnedCounter) {
//                                                                         return PreferenceBuilder<
//                                                                                 int>(
//                                                                             preference:
//                                                                                 preferences.getInt('eatenCalorie', defaultValue: 0),
//                                                                             builder: (BuildContext context, int eatenCounter) {
//                                                                               // calorie left container
//                                                                               return Container(
//                                                                                 // width: 130,
//                                                                                 height: MediaQuery.of(context).size.height,
//                                                                                 decoration: BoxDecoration(
//                                                                                   color: FitnessAppTheme.white,
//                                                                                   // borderRadius:
//                                                                                   //     BorderRadius
//                                                                                   //         .all(
//                                                                                   //   Radius.circular(
//                                                                                   //       120.0),
//                                                                                   // ),
//                                                                                   // border: ((dailytarget -
//                                                                                   //                 eatenCounter) +
//                                                                                   //             burnedCounter) <
//                                                                                   //         0
//                                                                                   //     ? Border.all(
//                                                                                   //         width: 10,
//                                                                                   //         color: Colors
//                                                                                   //             .green)
//                                                                                   //     : Border.all(
//                                                                                   //         width: 4,
//                                                                                   //         color: AppColors
//                                                                                   //             .primaryColor
//                                                                                   //             .withOpacity(
//                                                                                   //                 0.2)),
//                                                                                 ),
//                                                                                 child: Row(
//                                                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                                                                   children: <Widget>[
//                                                                                     preferences != null
//                                                                                         ? PreferenceBuilder<int>(
//                                                                                             preference: preferences.getInt('burnedCalorie', defaultValue: 0),
//                                                                                             builder: (BuildContext context, int burnedCounter) {
//                                                                                               return PreferenceBuilder<int>(
//                                                                                                   preference: preferences.getInt('eatenCalorie', defaultValue: 0),
//                                                                                                   builder: (BuildContext context, int eatenCounter) {
//                                                                                                     return Text(
//                                                                                                       '${((dailytarget - eatenCounter) + burnedCounter).abs()}',
//                                                                                                       textAlign: TextAlign.center,
//                                                                                                       style: TextStyle(
//                                                                                                         fontFamily: FitnessAppTheme.fontName,
//                                                                                                         fontWeight: FontWeight.w800,
//                                                                                                         fontSize: 20,
//                                                                                                         letterSpacing: 0.0,
//                                                                                                         color: (((dailytarget - eatenCounter) + burnedCounter) > dailytarget)
//                                                                                                             ? Colors.orangeAccent
//                                                                                                             : ((dailytarget - eatenCounter) + burnedCounter) > 0
//                                                                                                                 ? Color.fromRGBO(14, 23, 50, 1)
//                                                                                                                 : Colors.redAccent,
//                                                                                                       ),
//                                                                                                     );
//                                                                                                   });
//                                                                                             },
//                                                                                           )
//                                                                                         : Text(
//                                                                                             '$dailytarget',
//                                                                                             textAlign: TextAlign.center,
//                                                                                             style: TextStyle(
//                                                                                               fontFamily: FitnessAppTheme.fontName,
//                                                                                               fontWeight: FontWeight.normal,
//                                                                                               fontSize: ScUtil().setSp(14),
//                                                                                               letterSpacing: 0.0,
//                                                                                               color: AppColors.primaryColor,
//                                                                                             ),
//                                                                                           ),
//                                                                                     preferences != null
//                                                                                         ? PreferenceBuilder<int>(
//                                                                                             preference: preferences.getInt('burnedCalorie', defaultValue: 0),
//                                                                                             builder: (BuildContext context, int burnedCounter) {
//                                                                                               return PreferenceBuilder<int>(
//                                                                                                 preference: preferences.getInt('eatenCalorie', defaultValue: 0),
//                                                                                                 builder: (BuildContext context, int eatenCounter) {
//                                                                                                   return Text(
//                                                                                                     ((dailytarget - eatenCounter) + burnedCounter) > 0 ? ' Kcal left' : 'Kcal extra',
//                                                                                                     textAlign: TextAlign.start,
//                                                                                                     style: TextStyle(fontFamily: FitnessAppTheme.fontName, fontWeight: FontWeight.bold, fontSize: ScUtil().setSp(11), letterSpacing: 0, color: Color.fromRGBO(145, 149, 162, 1)
//                                                                                                         // color: FitnessAppTheme.grey.withOpacity(0.5),
//                                                                                                         ),
//                                                                                                   );
//                                                                                                 },
//                                                                                               );
//                                                                                             },
//                                                                                           )
//                                                                                         : Text(
//                                                                                             'Kcal left',
//                                                                                             textAlign: TextAlign.center,
//                                                                                             style: TextStyle(
//                                                                                               fontFamily: FitnessAppTheme.fontName,
//                                                                                               fontWeight: FontWeight.bold,
//                                                                                               fontSize: 14,
//                                                                                               letterSpacing: 0.0,
//                                                                                               color: FitnessAppTheme.grey.withOpacity(0.5),
//                                                                                             ),
//                                                                                           ),
//                                                                                   ],
//                                                                                 ),
//                                                                               );
//                                                                             });
//                                                                       })
//                                                                   : Container(
//                                                                       width:
//                                                                           120,
//                                                                       height:
//                                                                           120,
//                                                                       decoration:
//                                                                           BoxDecoration(
//                                                                         color: FitnessAppTheme
//                                                                             .white,
//                                                                         borderRadius:
//                                                                             BorderRadius.all(
//                                                                           Radius.circular(
//                                                                               120.0),
//                                                                         ),
//                                                                         border: Border.all(
//                                                                             width:
//                                                                                 4,
//                                                                             color:
//                                                                                 AppColors.primaryColor.withOpacity(0.2)),
//                                                                       ),
//                                                                       child:
//                                                                           Column(
//                                                                         mainAxisAlignment:
//                                                                             MainAxisAlignment.center,
//                                                                         crossAxisAlignment:
//                                                                             CrossAxisAlignment.center,
//                                                                         children: <
//                                                                             Widget>[
//                                                                           preferences != null
//                                                                               ? PreferenceBuilder<int>(
//                                                                                   preference: preferences.getInt('burnedCalorie', defaultValue: 0),
//                                                                                   builder: (BuildContext context, int burnedCounter) {
//                                                                                     return PreferenceBuilder<int>(
//                                                                                         preference: preferences.getInt('eatenCalorie', defaultValue: 0),
//                                                                                         builder: (BuildContext context, int eatenCounter) {
//                                                                                           return Text(
//                                                                                             '${((dailytarget - eatenCounter) + burnedCounter).abs()}',
//                                                                                             textAlign: TextAlign.center,
//                                                                                             style: TextStyle(
//                                                                                               fontFamily: FitnessAppTheme.fontName,
//                                                                                               fontWeight: FontWeight.normal,
//                                                                                               fontSize: 28,
//                                                                                               letterSpacing: 0.0,
//                                                                                               color: (((dailytarget - eatenCounter) + burnedCounter) > dailytarget)
//                                                                                                   ? Colors.orangeAccent
//                                                                                                   : ((dailytarget - eatenCounter) + burnedCounter) > 0
//                                                                                                       ? AppColors.primaryColor
//                                                                                                       : Colors.redAccent,
//                                                                                             ),
//                                                                                           );
//                                                                                         });
//                                                                                   })
//                                                                               : Text(
//                                                                                   '$dailytarget',
//                                                                                   textAlign: TextAlign.center,
//                                                                                   style: TextStyle(
//                                                                                     fontFamily: FitnessAppTheme.fontName,
//                                                                                     fontWeight: FontWeight.normal,
//                                                                                     fontSize: 28,
//                                                                                     letterSpacing: 0.0,
//                                                                                     color: AppColors.primaryColor,
//                                                                                   ),
//                                                                                 ),
//                                                                           preferences != null
//                                                                               ? PreferenceBuilder<int>(
//                                                                                   preference: preferences.getInt('burnedCalorie', defaultValue: 0),
//                                                                                   builder: (BuildContext context, int burnedCounter) {
//                                                                                     return PreferenceBuilder<int>(
//                                                                                         preference: preferences.getInt('eatenCalorie', defaultValue: 0),
//                                                                                         builder: (BuildContext context, int eatenCounter) {
//                                                                                           return Text(
//                                                                                             ((dailytarget - eatenCounter) + burnedCounter) > 0 ? 'Kcal left' : 'Kcal extra',
//                                                                                             textAlign: TextAlign.center,
//                                                                                             style: TextStyle(
//                                                                                               fontFamily: FitnessAppTheme.fontName,
//                                                                                               fontWeight: FontWeight.bold,
//                                                                                               fontSize: 14,
//                                                                                               letterSpacing: 0.0,
//                                                                                               color: FitnessAppTheme.grey.withOpacity(0.5),
//                                                                                             ),
//                                                                                           );
//                                                                                         });
//                                                                                   })
//                                                                               : Text(
//                                                                                   'Kcal left',
//                                                                                   textAlign: TextAlign.center,
//                                                                                   style: TextStyle(
//                                                                                     fontFamily: FitnessAppTheme.fontName,
//                                                                                     fontWeight: FontWeight.bold,
//                                                                                     fontSize: 14,
//                                                                                     letterSpacing: 0.0,
//                                                                                     color: FitnessAppTheme.grey.withOpacity(0.5),
//                                                                                   ),
//                                                                                 ),
//                                                                         ],
//                                                                       ),
//                                                                     ),
//                                                             ),
//                                                           ),
//                                                           // kcals left ends
//                                                         ],
//                                                       ),
//                                                       // kcals left ends
//                                                     ),
//                                                     // eaten value starts
//                                                     Container(
//                                                       child: Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                     .only(
//                                                                 left: 10.0,
//                                                                 right: 2.0),
//                                                         child: Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceAround,
//                                                           children: [
//                                                             Container(
//                                                               child: Row(
//                                                                 children: [
//                                                                   SizedBox(
//                                                                     width: 20,
//                                                                     height: 30,
//                                                                     child: Image
//                                                                         .asset(
//                                                                             "assets/images/diet/eaten.png"),
//                                                                   ),
//                                                                   Container(
//                                                                     child: Text(
//                                                                       'Eaten: ',
//                                                                       style:
//                                                                           TextStyle(
//                                                                         // fontFamily:
//                                                                         //     FitnessAppTheme
//                                                                         //         .fontName,
//                                                                         fontWeight:
//                                                                             FontWeight.w800,
//                                                                         fontSize:
//                                                                             ScUtil().setSp(14),
//                                                                         letterSpacing:
//                                                                             -0.1,
//                                                                         color: FitnessAppTheme
//                                                                             .dark_grey
//                                                                             .withOpacity(0.5),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .only(
//                                                                         left:
//                                                                             1),
//                                                                     child: preferences !=
//                                                                             null
//                                                                         ? PreferenceBuilder<
//                                                                             int>(
//                                                                             preference:
//                                                                                 preferences.getInt('eatenCalorie', defaultValue: 0),
//                                                                             builder:
//                                                                                 (BuildContext context, int eatenCounter) {
//                                                                               return Text(
//                                                                                 '$eatenCounter',
//                                                                                 textAlign: TextAlign.center,
//                                                                                 style: TextStyle(
//                                                                                   fontFamily: FitnessAppTheme.fontName,
//                                                                                   fontWeight: FontWeight.w600,
//                                                                                   fontSize: ScUtil().setSp(14),
//                                                                                   color: FitnessAppTheme.darkerText,
//                                                                                 ),
//                                                                               );
//                                                                             },
//                                                                           )
//                                                                         : Text(
//                                                                             '0',
//                                                                             textAlign:
//                                                                                 TextAlign.center,
//                                                                             style:
//                                                                                 TextStyle(
//                                                                               fontFamily: FitnessAppTheme.fontName,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontSize: ScUtil().setSp(14),
//                                                                               color: FitnessAppTheme.darkerText,
//                                                                             ),
//                                                                           ),
//                                                                   ),
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .only(
//                                                                         left:
//                                                                             4),
//                                                                     child: Text(
//                                                                       'Kcal',
//                                                                       textAlign:
//                                                                           TextAlign
//                                                                               .center,
//                                                                       style:
//                                                                           TextStyle(
//                                                                         fontFamily:
//                                                                             FitnessAppTheme.fontName,
//                                                                         fontWeight:
//                                                                             FontWeight.w600,
//                                                                         fontSize:
//                                                                             8,
//                                                                         letterSpacing:
//                                                                             -0.2,
//                                                                         color: FitnessAppTheme
//                                                                             .grey
//                                                                             .withOpacity(0.5),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                             // eaten value ends
//
//                                                             // burned value stars
//                                                             Container(
//                                                               child: Row(
//                                                                 children: [
//                                                                   SizedBox(
//                                                                     width: 20,
//                                                                     height: 30,
//                                                                     child: Image
//                                                                         .asset(
//                                                                             "assets/images/diet/burned.png"),
//                                                                   ),
//                                                                   Container(
//                                                                     child: Text(
//                                                                       'Burned: ',
//                                                                       style:
//                                                                           TextStyle(
//                                                                         // fontFamily:
//                                                                         //     FitnessAppTheme
//                                                                         //         .fontName,
//                                                                         fontWeight:
//                                                                             FontWeight.w800,
//                                                                         fontSize:
//                                                                             ScUtil().setSp(14),
//                                                                         letterSpacing:
//                                                                             -0.1,
//                                                                         color: FitnessAppTheme
//                                                                             .dark_grey
//                                                                             .withOpacity(0.5),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   Padding(
//                                                                     padding:
//                                                                         const EdgeInsets
//                                                                             .only(
//                                                                       left: 1,
//                                                                     ),
//                                                                     child: preferences !=
//                                                                             null
//                                                                         ? PreferenceBuilder<
//                                                                                 int>(
//                                                                             preference:
//                                                                                 preferences.getInt('burnedCalorie', defaultValue: 0),
//                                                                             builder: (BuildContext context, int burnedCounter) {
//                                                                               return Text(
//                                                                                 '$burnedCounter',
//                                                                                 textAlign: TextAlign.center,
//                                                                                 style: TextStyle(
//                                                                                   fontFamily: FitnessAppTheme.fontName,
//                                                                                   fontWeight: FontWeight.w600,
//                                                                                   fontSize: ScUtil().setSp(14),
//                                                                                   color: FitnessAppTheme.darkerText,
//                                                                                 ),
//                                                                               );
//                                                                             })
//                                                                         : Text(
//                                                                             '0',
//                                                                             textAlign:
//                                                                                 TextAlign.center,
//                                                                             style:
//                                                                                 TextStyle(
//                                                                               fontFamily: FitnessAppTheme.fontName,
//                                                                               fontWeight: FontWeight.w600,
//                                                                               fontSize: ScUtil().setSp(14),
//                                                                               color: FitnessAppTheme.darkerText,
//                                                                             ),
//                                                                           ),
//                                                                   ),
//                                                                   Padding(
//                                                                     padding: const EdgeInsets
//                                                                             .only(
//                                                                         left:
//                                                                             4),
//                                                                     child: Text(
//                                                                       'Kcal',
//                                                                       textAlign:
//                                                                           TextAlign
//                                                                               .end,
//                                                                       style:
//                                                                           TextStyle(
//                                                                         fontFamily:
//                                                                             FitnessAppTheme.fontName,
//                                                                         fontWeight:
//                                                                             FontWeight.w600,
//                                                                         fontSize:
//                                                                             8,
//                                                                         letterSpacing:
//                                                                             -0.2,
//                                                                         color: FitnessAppTheme
//                                                                             .grey
//                                                                             .withOpacity(0.5),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                             // burned value ends
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     // SizedBox(
//                                                     //   height:15
//                                                     // ),
//                                                     // graph ui starts
//                                                     Padding(
//                                                       padding: const EdgeInsets
//                                                               .symmetric(
//                                                           horizontal: 10.0),
//                                                       child: Container(
//                                                         child: graphDataList
//                                                                     .length !=
//                                                                 0
//                                                             ? Container(
//                                                                 // height: 130,
//                                                                 height: MediaQuery.of(
//                                                                             context)
//                                                                         .size
//                                                                         .height /
//                                                                     6,
//                                                                 child: Card(
//                                                                   // color: CardColors.bgColor,
//                                                                   child:
//                                                                       SfCartesianChart(
//                                                                     // plotAreaBackgroundColor:
//                                                                     //     Colors.greenAccent,
//                                                                     series: <
//                                                                         ChartSeries>[
//                                                                       ColumnSeries<
//                                                                           DailyCalorieData,
//                                                                           DateTime>(
//                                                                         color: Color.fromRGBO(
//                                                                             30,
//                                                                             191,
//                                                                             105,
//                                                                             1),
//                                                                         width:
//                                                                             0.33,
//
//                                                                         borderRadius:
//                                                                             BorderRadius.only(
//                                                                           topLeft:
//                                                                               Radius.circular(10.0),
//                                                                           topRight:
//                                                                               Radius.circular(10.0),
//                                                                         ),
//                                                                         dataSource:
//                                                                             graphDataList, // monthlyChartData,
//                                                                         xValueMapper:
//                                                                             (DailyCalorieData sales, _) =>
//                                                                                 sales.x,
//                                                                         yValueMapper:
//                                                                             (DailyCalorieData sales, _) =>
//                                                                                 sales.y,
//                                                                         // Sets the corner radius
//                                                                         enableTooltip:
//                                                                             true,
//                                                                       )
//                                                                     ],
//                                                                     primaryXAxis:
//                                                                         DateTimeAxis(
//                                                                       intervalType:
//                                                                           DateTimeIntervalType
//                                                                               .days,
//                                                                       // maximumLabels:
//                                                                       //     2,
//                                                                       majorTickLines:
//                                                                           MajorTickLines(
//                                                                               width: 0),
//                                                                       majorGridLines:
//                                                                           MajorGridLines(
//                                                                               width: 0),
//                                                                       enableAutoIntervalOnZooming:
//                                                                           true,
//                                                                       labelIntersectAction:
//                                                                           AxisLabelIntersectAction
//                                                                               .rotate90,
//                                                                       interval:
//                                                                           1,
//                                                                       // title: AxisTitle(
//                                                                       //     text:
//                                                                       //         'Weekly Days'),
//                                                                       dateFormat:
//                                                                           DateFormat(
//                                                                               'EEE'),
//                                                                     ),
//                                                                     primaryYAxis:
//                                                                         NumericAxis(
//                                                                       title:
//                                                                           AxisTitle(
//                                                                         text:
//                                                                             'Calories',
//                                                                         textStyle:
//                                                                             TextStyle(fontSize: 12.0),
//                                                                       ),
//                                                                       maximumLabels:
//                                                                           2,
//                                                                       majorTickLines:
//                                                                           MajorTickLines(
//                                                                               width: 0),
//                                                                       majorGridLines:
//                                                                           MajorGridLines(
//                                                                               width: 0),
//                                                                     ),
//                                                                     trackballBehavior:
//                                                                         TrackballBehavior(
//                                                                       enable:
//                                                                           true,
//                                                                       markerSettings:
//                                                                           TrackballMarkerSettings(
//                                                                         markerVisibility:
//                                                                             TrackballVisibilityMode.hidden,
//                                                                         height:
//                                                                             10,
//                                                                         width:
//                                                                             10,
//                                                                         borderWidth:
//                                                                             1,
//                                                                       ),
//                                                                       activationMode:
//                                                                           ActivationMode
//                                                                               .singleTap,
//                                                                       tooltipDisplayMode:
//                                                                           TrackballDisplayMode
//                                                                               .floatAllPoints,
//                                                                       tooltipSettings: InteractiveTooltip(
//                                                                           format:
//                                                                               'point.x : point.y kCal',
//                                                                           canShowMarker:
//                                                                               false),
//                                                                       shouldAlwaysShow:
//                                                                           true,
//                                                                     ),
//                                                                     enableAxisAnimation:
//                                                                         true,
//                                                                     zoomPanBehavior:
//                                                                         ZoomPanBehavior(
//                                                                       /// To enable the pinch zooming as true.
//                                                                       enablePinching:
//                                                                           true,
//                                                                       zoomMode:
//                                                                           ZoomMode
//                                                                               .xy,
//                                                                       enablePanning:
//                                                                           true,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               )
//                                                             : nodata
//                                                                 ? GestureDetector(
//                                                                     onTap: () {
//                                                                       Navigator.pushAndRemoveUntil(
//                                                                           context,
//                                                                           MaterialPageRoute(
//                                                                               builder: (context) =>
//                                                                                   DietJournal()),
//                                                                           (Route<dynamic> route) =>
//                                                                               false);
//                                                                     },
//                                                                     child:
//                                                                         Container(
//                                                                       height:
//                                                                           130,
//                                                                       width:
//                                                                           300,
//                                                                       child:
//                                                                           Card(
//                                                                         color: CardColors
//                                                                             .bgColor,
//                                                                         child:
//                                                                             Center(
//                                                                           child:
//                                                                               Text(
//                                                                             'No data for this week.\nClick to Log!',
//                                                                             textAlign:
//                                                                                 TextAlign.center,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   )
//                                                                 : Center(
//                                                                     child:
//                                                                         CircularProgressIndicator(),
//                                                                   ),
//                                                       ),
//                                                     ),
//                                                     // graph ui ends
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(
//                                             width: 12.0,
//                                           ),
//                                           // Activity section starts
//                                           // Activity Heading container starts
//                                           Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             children: [
//                                               Container(
//                                                 // color: Colors.amber,
//                                                 height: MediaQuery.of(context)
//                                                         .size
//                                                         .height /
//                                                     37,
//                                                 width: MediaQuery.of(context)
//                                                         .size
//                                                         .width /
//                                                     1.35,
//                                                 child: Row(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.center,
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     Padding(
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                               left: 0.0),
//                                                       child: Text(
//                                                         'Glance at your Activity',
//                                                         // textAlign: TextAlign.left,
//                                                         style: TextStyle(
//                                                           fontFamily:
//                                                               FitnessAppTheme
//                                                                   .fontName,
//                                                           fontWeight:
//                                                               FontWeight.w700,
//                                                           fontSize: ScUtil()
//                                                               .setSp(15),
//                                                           // letterSpacing: -1,
//                                                           // color: AppColors.textitemTitleColor,
//                                                           // color: Color.fromRGBO(166, 167, 187, 1),
//                                                           color: Color.fromRGBO(
//                                                             132,
//                                                             132,
//                                                             160,
//                                                             1,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     InkWell(
//                                                       onTap: () {
//                                                         Get.to(
//                                                           TodayActivityScreen(
//                                                             todaysActivityData:
//                                                                 todaysActivityData,
//                                                             otherActivityData:
//                                                                 otherActivityData,
//                                                           ),
//                                                         );
//                                                       },
//                                                       child: Text(
//                                                         'More',
//                                                         // textAlign: TextAlign.left,
//                                                         style: TextStyle(
//                                                           fontFamily:
//                                                               FitnessAppTheme
//                                                                   .fontName,
//                                                           fontWeight:
//                                                               FontWeight.w900,
//                                                           fontSize: ScUtil()
//                                                               .setSp(14),
//                                                           // letterSpacing: 1,
//                                                           // color: color ?? AppColors.primaryColor,
//                                                           color: Color.fromRGBO(
//                                                               77, 122, 209, 1),
//                                                         ),
//                                                       ),
//                                                     )
//                                                   ],
//                                                 ),
//                                               ),
//                                               SizedBox(height: 13.0),
//                                               Container(
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           25.0),
//                                                   color: Color.fromRGBO(
//                                                       150, 199, 193, 0.2),
//                                                 ),
//                                                 margin: EdgeInsets.only(
//                                                     top: 1.2, bottom: 1),
//                                                 height: MediaQuery.of(context)
//                                                         .size
//                                                         .height /
//                                                     3.5,
//                                                 width: MediaQuery.of(context)
//                                                         .size
//                                                         .width /
//                                                     1.20,
//                                                 child: Column(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     Container(
//                                                       alignment:
//                                                           Alignment.centerRight,
//                                                       child: todaysActivityData
//                                                                   .length ==
//                                                               0
//                                                           ? DashBoardRunningView(
//                                                               onTap: () {
//                                                                 Navigator.push(
//                                                                   context,
//                                                                   MaterialPageRoute(
//                                                                     builder:
//                                                                         (context) =>
//                                                                             TodayActivityScreen(
//                                                                       todaysActivityData:
//                                                                           todaysActivityData,
//                                                                       otherActivityData:
//                                                                           otherActivityData,
//                                                                     ),
//                                                                   ),
//                                                                 );
//                                                               },
//                                                             )
//                                                           : HomeDashBoardTodaysActivityView(
//                                                               todaysActivityList:
//                                                                   todaysActivityData,
//                                                               otherActivityList:
//                                                                   otherActivityData),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           // Activity Heading container ends
//
//                                           // Activity section ends
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//
//                             // Health journal ends
//                             SizedBox(
//                               height: 8.0,
//                             ),
//                             // vital datas starts
//                             Padding(
//                               padding: const EdgeInsets.only(left: 28.0),
//                               child: Container(
//                                 // color: Colors.white,
//                                 height: MediaQuery.of(context).size.height / 30,
//                                 width: MediaQuery.of(context).size.width / 1.35,
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Glance at your vitals',
//                                       // textAlign: TextAlign.left,
//                                       style: TextStyle(
//                                         fontFamily: FitnessAppTheme.fontName,
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: ScUtil().setSp(15),
//                                         // letterSpacing: -1,
//                                         // color: AppColors.textitemTitleColor,
//                                         // color: Color.fromRGBO(166, 167, 187, 1),
//                                         color: Color.fromRGBO(
//                                           132,
//                                           132,
//                                           160,
//                                           1,
//                                         ),
//                                       ),
//                                     ),
//                                     InkWell(
//                                       onTap: () {
//                                         Get.to(VitalTab());
//                                         // Navigator.pushAndRemoveUntil(
//                                         //     context,
//                                         //     MaterialPageRoute(
//                                         //         builder: (context) =>
//                                         //             OtherVitals()),
//                                         //     (Route<dynamic> route) => false);
//                                       },
//                                       child: Text(
//                                         'More',
//                                         // textAlign: TextAlign.left,
//                                         style: TextStyle(
//                                             fontFamily:
//                                                 FitnessAppTheme.fontName,
//                                             fontWeight: FontWeight.w900,
//                                             fontSize: ScUtil().setSp(14),
//                                             // letterSpacing: 1,
//                                             // color: color ?? AppColors.primaryColor,
//                                             color: Color.fromRGBO(
//                                                 77, 122, 209, 1)),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: 15.0),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 30.0),
//                               child: Container(
//                                 // color: Colors.green,
//                                 child: SingleChildScrollView(
//                                   scrollDirection: Axis.horizontal,
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 2.0, vertical: 2.0),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceAround,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         InkWell(
//                                           onTap: () {
//                                             Get.to(
//                                               VitalTab(),
//                                             );
//                                           },
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.all(
//                                                 Radius.circular(20.0),
//                                               ),
//                                               color: Colors.white,
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.grey
//                                                       .withOpacity(0.2),
//                                                   blurRadius: 8,
//                                                   spreadRadius: 2,
//                                                   offset: Offset(1.0, 1.0),
//                                                 )
//                                               ],
//                                             ),
//                                             height: MediaQuery.of(context)
//                                                     .size
//                                                     .height /
//                                                 5.5,
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width /
//                                                 3,
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceEvenly,
//                                                 children: [
//                                                   // height card starts
//                                                   Container(
//                                                     decoration: BoxDecoration(
//                                                       borderRadius:
//                                                           BorderRadius.all(
//                                                         Radius.circular(12.0),
//                                                       ),
//                                                       color: Color.fromRGBO(
//                                                           236, 207, 255, 1),
//                                                     ),
//                                                     child: Padding(
//                                                       padding: const EdgeInsets
//                                                               .symmetric(
//                                                           horizontal: 15.0,
//                                                           vertical: 10.0),
//                                                       child: Container(
//                                                         color: Color.fromRGBO(
//                                                             146, 52, 236, 0.5),
//                                                         child: Image.asset(
//                                                             'assets/icons/h2.png',
//                                                             height: 28.0),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 5.0,
//                                                   ),
//                                                   Text(
//                                                     'Height',
//                                                     style: new TextStyle(
//                                                         fontSize:
//                                                             ScUtil().setSp(14),
//                                                         // color: Colors.teal,
//                                                         color: Color.fromRGBO(
//                                                             67, 147, 207, 1),
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 4.0,
//                                                   ),
//                                                   InkWell(
//                                                     onTap: () {
//                                                       if (this.mounted) {
//                                                         setState(() {
//                                                           feet = !feet;
//                                                         });
//                                                       }
//                                                     },
//                                                     child: Text(
//                                                       feet == false
//                                                           ? height + ' Cms'
//                                                           : heightft(),
//                                                       style: new TextStyle(
//                                                           fontSize: ScUtil()
//                                                               .setSp(14),
//                                                           color: Color.fromRGBO(
//                                                               151, 150, 185, 1),
//                                                           fontWeight:
//                                                               FontWeight.w800),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         // height card ends
//                                         SizedBox(
//                                           width: 25,
//                                         ),
//                                         // weight card
//                                         InkWell(
//                                           onTap: () {
//                                             Get.to(
//                                               VitalTab(),
//                                             );
//                                           },
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                                 borderRadius: BorderRadius.all(
//                                                   Radius.circular(20.0),
//                                                 ),
//                                                 boxShadow: [
//                                                   BoxShadow(
//                                                     color: Colors.grey
//                                                         .withOpacity(0.2),
//                                                     blurRadius: 8,
//                                                     spreadRadius: 2,
//                                                     offset: Offset(1.0, 1.0),
//                                                   )
//                                                 ],
//                                                 color: Colors.white),
//                                             height: MediaQuery.of(context)
//                                                     .size
//                                                     .height /
//                                                 5.5,
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width /
//                                                 3,
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceEvenly,
//                                                 children: [
//                                                   Container(
//                                                     decoration: BoxDecoration(
//                                                       borderRadius:
//                                                           BorderRadius.all(
//                                                         Radius.circular(13.0),
//                                                       ),
//                                                       color: Color.fromRGBO(
//                                                           217, 48, 37, 0.3),
//                                                     ),
//                                                     child: Padding(
//                                                       padding: const EdgeInsets
//                                                               .symmetric(
//                                                           horizontal: 15.0,
//                                                           vertical: 10.0),
//                                                       child: Container(
//                                                         // color: Color.fromRGBO(
//                                                         //     217, 48, 37, 0.5),
//                                                         child: Image.asset(
//                                                             'assets/icons/w6.png',
//                                                             height: 26.0),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 5.0,
//                                                   ),
//                                                   Text(
//                                                     'Weight',
//                                                     style: new TextStyle(
//                                                         fontSize:
//                                                             ScUtil().setSp(14),
//                                                         color: Color.fromRGBO(
//                                                             67, 147, 207, 1),
//                                                         // color: Colors.teal,
//                                                         fontWeight:
//                                                             FontWeight.w800),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 1.0,
//                                                   ),
//                                                   Text(
//                                                     weight == ''
//                                                         ? weightfromvitalsData ==
//                                                                 ''
//                                                             ? '-'
//                                                             : weightfromvitalsData +
//                                                                 ' Kgs'
//                                                         : weight + ' Kgs',
//                                                     style: new TextStyle(
//                                                         fontSize:
//                                                             ScUtil().setSp(14),
//                                                         color: Color.fromRGBO(
//                                                             151, 150, 185, 1),
//                                                         fontWeight:
//                                                             FontWeight.w800),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 25,
//                                         ),
//                                         // weight card ends
//                                         // BMI container starts
//                                         InkWell(
//                                           onTap: () {
//                                             Get.to(
//                                               VitalTab(),
//                                             );
//                                           },
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.all(
//                                                 Radius.circular(20.0),
//                                               ),
//                                               color: Colors.white,
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.grey
//                                                       .withOpacity(0.2),
//                                                   blurRadius: 8,
//                                                   spreadRadius: 2,
//                                                   offset: Offset(1.0, 1.0),
//                                                 )
//                                               ],
//                                             ),
//                                             height: MediaQuery.of(context)
//                                                     .size
//                                                     .height /
//                                                 5.5,
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width /
//                                                 3,
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceEvenly,
//                                                 children: [
//                                                   // BMI card starts
//                                                   Container(
//                                                     decoration: BoxDecoration(
//                                                       borderRadius:
//                                                           BorderRadius.all(
//                                                         Radius.circular(13.0),
//                                                       ),
//                                                       color: Colors.orangeAccent
//                                                           .withOpacity(0.6),
//                                                     ),
//                                                     child: Padding(
//                                                       padding: const EdgeInsets
//                                                               .symmetric(
//                                                           horizontal: 15.0,
//                                                           vertical: 10.0),
//                                                       child: Container(
//                                                         child: Image.asset(
//                                                             'assets/icons/bmi1.png',
//                                                             height: 25.0),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 5.0,
//                                                   ),
//                                                   Text(
//                                                     'BMI',
//                                                     style: new TextStyle(
//                                                         fontSize:
//                                                             ScUtil().setSp(12),
//                                                         // color: Colors.teal,
//                                                         color: Color.fromRGBO(
//                                                             67, 147, 207, 1),
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                   // SizedBox(
//                                                   //   height: 8.0,
//                                                   // ),
//                                                   userVitals[0]['bmi']
//                                                               .toString() ==
//                                                           null
//                                                       ? Text('N/A')
//                                                       : Text(
//                                                           // '$bmiClassCalc[]',
//
//                                                           userVitals[0]['bmi']
//                                                               .toString(),
//                                                           // '32.12',
//                                                           style: new TextStyle(
//                                                               fontSize: ScUtil()
//                                                                   .setSp(14),
//                                                               color: Color
//                                                                   .fromRGBO(
//                                                                       151,
//                                                                       150,
//                                                                       185,
//                                                                       1),
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w800),
//                                                         ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// // This is Old Dashboard file, Comment the above to codes entirely
// // and uncomment the below codes to have old dashboard and viceversa
// /*
// // ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names
//
// import 'package:ihl/models/ecg_calculator.dart';
// import 'package:ihl/widgets/dashboard/scoreMeter.dart';
// import 'package:strings/strings.dart';
// import 'dart:convert';
// import 'package:ihl/utils/app_colors.dart';
// import 'package:ihl/painters/backgroundPanter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/material.dart';
// import 'package:ihl/constants/vitalUI.dart';
// import 'package:ihl/constants/app_texts.dart';
// import 'package:ihl/widgets/dashboard/liteVitalsCard.dart';
// import 'package:ihl/constants/spKeys.dart';
//
// // ignore: must_be_immutable
// class HomeTab extends StatefulWidget {
//   Function closeDrawer;
//   Function openDrawer;
//   Function goToProfile;
//   var userScore = '0';
//   String username;
//   HomeTab({
//     this.closeDrawer,
//     this.username,
//     this.openDrawer,
//     this.userScore,
//     this.goToProfile,
//   });
//   @override
//   _HomeTabState createState() => _HomeTabState();
// }
//
// class _HomeTabState extends State<HomeTab> {
//   bool loading = true;
//   List vitalsToShow = [];
//   String name = 'you';
//   Map allScores = {};
//   var data;
//   bool isVerified = true;
//
//   /// handle null and empty strings⚡
//   String stringify(dynamic prop) {
//     if (prop == null || prop == '' || prop == ' ' || prop == 'NA') {
//       return AppTexts.notAvailable;
//     }
//     if (prop is double) {
//       double doub = prop;
//       prop = doub.round();
//     }
//     String stringVal = prop.toString();
//     stringVal = stringVal.trim().isEmpty ? AppTexts.notAvailable : stringVal;
//     return stringVal;
//   }
//
//   /// calculate bmi🎇🎇
//   int calcBmi({height, weight}) {
//     double parsedH;
//     double parsedW;
//     if (height == null || weight == null) {
//       return null;
//     }
//
//     parsedH = double.tryParse(height);
//     parsedW = double.tryParse(weight);
//     if (parsedH != null && parsedW != null) {
//       int bmi = parsedW ~/ (parsedH * parsedH);
//
//       return bmi;
//     }
//     return null;
//   }
//
//   /// returns BMI Class for a BMI 🌈
//   String bmiClassCalc(int bmi) {
//     if (bmi == null) {
//       return AppTexts.notAvailable;
//     }
//     if (bmi > 30) {
//       return AppTexts.obeseBMI;
//     }
//     if (bmi > 25) {
//       return AppTexts.ovwBMI;
//     }
//     if (bmi < 18) {
//       return AppTexts.undwBMI;
//     }
//     return AppTexts.normalBMI;
//   }
//
//   DateTime getDateTimeStamp(String d) {
//     try {
//       return DateTime.fromMillisecondsSinceEpoch(int.tryParse(d
//           .substring(0, d.indexOf('+'))
//           .replaceAll('Date', '')
//           .replaceAll('/', '')
//           .replaceAll('(', '')
//           .replaceAll(')', '')));
//     } catch (e) {
//       return DateTime.now();
//     }
//   }
//
//   /// looooooooooooooong code processes JSON response 🌠
//   getData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var raw = prefs.get(SPKeys.userData);
//     if (raw == '' || raw == null) {
//       raw = '{}';
//     }
//     data = jsonDecode(raw);
//
//     Map user = data['User'];
//     if (user == null) {
//       user = {};
//     }
//     var userVitalst = prefs.getString(SPKeys.vitalsData);
//     if (userVitalst == null || userVitalst == '' || userVitalst == '[]') {
//       if (user['userInputWeightInKG'] == null ||
//           user['userInputWeightInKG'] == '' ||
//           user['heightMeters'] == null ||
//           user['heightMeters'] == '' ||
//           ((user['email'] == null || user['email'] == '') &&
//               (user['mobileNumber'] == null || user['mobileNumber'] == ''))) {
//         isVerified = false;
//         loading = false;
//         if (this.mounted) {
//           setState(() {});
//           return;
//         }
//       }
//       userVitalst = '[{}]';
//     }
//     List userVitals = jsonDecode(userVitalst);
//     //get inputted height weight if values are not available
//
//     if (userVitals[0]['weightKG'] == null) {
//       userVitals[0]['weightKG'] = user['userInputWeightInKG'];
//     }
//     if (userVitals[0]['heightMeters'] == null) {
//       userVitals[0]['heightMeters'] = user['heightMeters'];
//     }
//     //Calculate bmi
//     if (userVitals[0]['bmi'] == null) {
//       userVitals[0]['bmi'] = calcBmi(
//           height: userVitals[0]['heightMeters'].toString(),
//           weight: userVitals[0]['weightKG'].toString());
//       userVitals[0]['bmiClass'] = bmiClassCalc(userVitals[0]['bmi']);
//     }
//     allScores = {};
//     //prepare data
//     double finalWeight = 0;
//     double finalHeight = 0;
//     var bcml = "20.00";
//     var bcmh = "25.00";
//     var lowMineral = "2.00";
//     var highMineral = "3.00";
//     var heightinCMS = userVitals[0]['heightMeters'] * 100;
//     var weight = userVitals[0]['weightKG'].toString() == ""
//         ? '0'
//         : userVitals[0]['weightKG'].toString();
//     var gender = user['gender'].toString();
//     var lowSmmReference,
//         lowFatReference,
//         highSmmReference,
//         highFatReference,
//         lowBmcReference,
//         highBmcReference,
//         icll,
//         iclh,
//         ecll,
//         eclh,
//         proteinl,
//         proteinh,
//         waisttoheightratiolow,
//         waisttoheightratiohigh,
//         lowPbfReference,
//         highPbfReference;
//
//     if (gender != 'm') {
//       lowPbfReference = "18.00";
//       highPbfReference = "28.00";
//       var femaleHeightWeight = [
//         [147, 45, 59],
//         [150, 45, 60],
//         [152, 46, 62],
//         [155, 47, 63],
//         [157, 49, 65],
//         [160, 50, 67],
//         [162, 51, 69],
//         [165, 53, 70],
//         [167, 54, 72],
//         [170, 55, 74],
//         [172, 57, 75],
//         [175, 58, 77],
//         [177, 60, 78],
//         [180, 61, 80]
//       ];
//       var j = 0;
//       while (femaleHeightWeight[j][0] <= heightinCMS) {
//         j++;
//         if (j == 13) {
//           break;
//         }
//       }
//       var wtl, wth;
//       if (j == 0) {
//         wtl = femaleHeightWeight[j][1];
//         wth = femaleHeightWeight[j][2];
//       } else {
//         wtl = femaleHeightWeight[j - 1][1];
//         wth = femaleHeightWeight[j - 1][2];
//       }
//       lowSmmReference = (0.36 * wtl);
//       highSmmReference = (0.36 * wth);
//       lowFatReference = (0.18 * double.tryParse(weight));
//       highFatReference = (0.28 * double.tryParse(weight));
//       lowBmcReference = "1.70";
//       highBmcReference = "3.00";
//       icll = (0.3 * wtl);
//       iclh = (0.3 * wth);
//       ecll = (0.2 * wtl);
//       eclh = (0.2 * wth);
//       proteinl = (0.116 * double.tryParse(weight));
//       proteinh = (0.141 * double.tryParse(weight));
//       waisttoheightratiolow = "0.35";
//       waisttoheightratiohigh = "0.53";
//     } else {
//       lowPbfReference = "10.00";
//       highPbfReference = "20.00";
//       var maleHeightWeight = [
//         [155, 55, 66],
//         [157, 56, 67],
//         [160, 57, 68],
//         [162, 58, 70],
//         [165, 59, 72],
//         [167, 60, 74],
//         [170, 61, 75],
//         [172, 62, 77],
//         [175, 63, 79],
//         [177, 64, 81],
//         [180, 65, 83],
//         [182, 66, 85],
//         [185, 68, 87],
//         [187, 69, 89],
//         [190, 71, 91]
//       ];
//       var k = 0;
//       while (maleHeightWeight[k][0] <= heightinCMS) {
//         k++;
//         if (k == 14) {
//           break;
//         }
//       }
//       var wtl, wth;
//       if (k == 0) {
//         wtl = maleHeightWeight[k][1];
//         wth = maleHeightWeight[k][2];
//       } else {
//         wtl = maleHeightWeight[k - 1][1];
//         wth = maleHeightWeight[k - 1][2];
//       }
//       lowSmmReference = (0.42 * wtl);
//       highSmmReference = (0.42 * wth);
//       lowFatReference = (0.10 * double.parse(weight ?? '0'));
//       highFatReference = (0.20 * double.parse(weight ?? '0'));
//       lowBmcReference = "2.00";
//       highBmcReference = "3.70";
//       icll = (0.3 * wtl);
//       iclh = (0.3 * wth);
//       ecll = (0.2 * wtl);
//       eclh = (0.2 * wth);
//       proteinl = (0.109 * double.parse(weight));
//       proteinh = (0.135 * double.parse(weight));
//       waisttoheightratiolow = "0.35";
//       waisttoheightratiohigh = "0.57";
//     }
//
//     var proteinStatus;
//     var ecwStatus;
//     var icwStatus;
//     var mineralStatus;
//     var smmStatus;
//     var bfmStatus;
//     var bcmStatus;
//     var waistHipStatus;
//     var pbfStatus;
//     var waistHeightStatus;
//     var vfStatus;
//     var bmrStatus;
//     var bomcStatus;
//
//     calculateFullBodyProteinStatus(FullBodyProtein) {
//       if (double.parse(FullBodyProtein) < proteinl) {
//         return 'Low';
//       } else if (double.parse(FullBodyProtein) >= proteinl) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyECWStatus(FullBodyECW) {
//       if (double.parse(FullBodyECW) < ecll) {
//         return 'Low';
//       } else if (double.parse(FullBodyECW) >= ecll &&
//           double.parse(FullBodyECW) <= eclh) {
//         return 'Normal';
//       } else if (double.parse(FullBodyECW) > eclh) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyICWStatus(FullBodyICW) {
//       if (double.parse(FullBodyICW) < icll) {
//         return 'Low';
//       } else if (double.parse(FullBodyICW) >= icll &&
//           double.parse(FullBodyICW) <= iclh) {
//         return 'Normal';
//       } else if (double.parse(FullBodyICW) > iclh) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyMineralStatus(FullBodyMineral) {
//       if (double.parse(FullBodyMineral) < double.parse(lowMineral)) {
//         return 'Low';
//       } else if (double.parse(FullBodyMineral) >= double.parse(lowMineral)) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodySMMStatus(FullBodySMM) {
//       if (double.parse(FullBodySMM) < lowSmmReference) {
//         return 'Low';
//       } else if (double.parse(FullBodySMM) >= lowSmmReference) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyBMCStatus(FullBodyBMC) {
//       if (double.parse(FullBodyBMC) < double.parse(lowBmcReference)) {
//         return 'Low';
//       } else if (double.parse(FullBodyBMC) >= double.parse(lowBmcReference)) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyPBFStatus(FullBodyPBF) {
//       if (double.parse(FullBodyPBF) < double.parse(lowPbfReference)) {
//         return 'Low';
//       } else if (double.parse(FullBodyPBF) >= double.parse(lowPbfReference) &&
//           double.parse(FullBodyPBF) <= double.parse(highPbfReference)) {
//         return 'Normal';
//       } else if (double.parse(FullBodyPBF) > double.parse(highPbfReference)) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyBCMStatus(FullBodyBCM) {
//       if (double.parse(FullBodyBCM) < double.parse(bcml)) {
//         return 'Low';
//       } else if (double.parse(FullBodyBCM) >= double.parse(bcml)) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyFATStatus(FullBodyFAT) {
//       if (double.parse(FullBodyFAT) < lowFatReference) {
//         return 'Low';
//       } else if (double.parse(FullBodyFAT) >= lowFatReference &&
//           double.parse(FullBodyFAT) <= highFatReference) {
//         return 'Normal';
//       } else if (double.parse(FullBodyFAT) > highFatReference) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyVFStatus(FullBodyVF) {
//       if (FullBodyVF != "NaN") {
//         if (int.tryParse(FullBodyVF) <= 100) {
//           return 'Normal';
//         } else if (int.tryParse(FullBodyVF) > 100) {
//           return 'High';
//         }
//       }
//     }
//
//     calculateFullBodyBMRStatus(FullBodyBMR) {
//       if (int.parse(FullBodyBMR) < 1200) {
//         return 'Low';
//       } else if (int.parse(FullBodyBMR) >= 1200) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyWHPRStatus(FullBodyWHPR) {
//       if (double.parse(FullBodyWHPR) < 0.80) {
//         return 'Low';
//       } else if (double.parse(FullBodyWHPR) >= 0.80 &&
//           double.parse(FullBodyWHPR) <= 0.90) {
//         return 'Normal';
//       }
//       if (double.parse(FullBodyWHPR) > 0.90) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyWHTRStatus(FullBodyWHTR) {
//       if (double.parse(FullBodyWHTR) < double.parse(waisttoheightratiolow)) {
//         return 'Low';
//       } else if (double.parse(FullBodyWHTR) >=
//               double.parse(waisttoheightratiolow) &&
//           double.parse(FullBodyWHTR) <= double.parse(waisttoheightratiohigh)) {
//         return 'Normal';
//       }
//       if (double.parse(FullBodyWHTR) > double.parse(waisttoheightratiohigh)) {
//         return 'High';
//       }
//     }
//
//     for (var i = 0; i < userVitals.length; i++) {
//       if (userVitals[i]['protien'] != null &&
//           userVitals[i]['protien'] != "NaN") {
//         userVitals[i]['protien'] = userVitals[i]['protien'].toStringAsFixed(2);
//         proteinStatus =
//             calculateFullBodyProteinStatus(userVitals[i]['protien']);
//       }
//
//       if (userVitals[i]['intra_cellular_water'] != null &&
//           userVitals[i]['intra_cellular_water'] != "NaN") {
//         userVitals[i]['intra_cellular_water'] =
//             userVitals[i]['intra_cellular_water'].toStringAsFixed(2);
//         icwStatus =
//             calculateFullBodyICWStatus(userVitals[i]['intra_cellular_water']);
//       }
//
//       if (userVitals[i]['extra_cellular_water'] != null &&
//           userVitals[i]['extra_cellular_water'] != "NaN") {
//         userVitals[i]['extra_cellular_water'] =
//             userVitals[i]['extra_cellular_water'].toStringAsFixed(2);
//         ecwStatus =
//             calculateFullBodyECWStatus(userVitals[i]['extra_cellular_water']);
//       }
//
//       if (userVitals[i]['mineral'] != null &&
//           userVitals[i]['mineral'] != "NaN") {
//         userVitals[i]['mineral'] = userVitals[i]['mineral'].toStringAsFixed(2);
//         mineralStatus =
//             calculateFullBodyMineralStatus(userVitals[i]['mineral']);
//       }
//
//       if (userVitals[i]['skeletal_muscle_mass'] != null &&
//           userVitals[i]['skeletal_muscle_mass'] != "NaN") {
//         userVitals[i]['skeletal_muscle_mass'] =
//             userVitals[i]['skeletal_muscle_mass'].toStringAsFixed(2);
//         smmStatus =
//             calculateFullBodySMMStatus(userVitals[i]['skeletal_muscle_mass']);
//       }
//
//       if (userVitals[i]['body_fat_mass'] != null &&
//           userVitals[i]['body_fat_mass'] != "NaN") {
//         userVitals[i]['body_fat_mass'] =
//             userVitals[i]['body_fat_mass'].toStringAsFixed(2);
//         bfmStatus = calculateFullBodyFATStatus(userVitals[i]['body_fat_mass']);
//       }
//
//       if (userVitals[i]['body_cell_mass'] != null &&
//           userVitals[i]['body_cell_mass'] != "NaN") {
//         userVitals[i]['body_cell_mass'] =
//             userVitals[i]['body_cell_mass'].toStringAsFixed(2);
//         bcmStatus = calculateFullBodyBCMStatus(userVitals[i]['body_cell_mass']);
//       }
//
//       if (userVitals[i]['waist_hip_ratio'] != null &&
//           userVitals[i]['waist_hip_ratio'] != "NaN") {
//         userVitals[i]['waist_hip_ratio'] =
//             userVitals[i]['waist_hip_ratio'].toStringAsFixed(2);
//         waistHipStatus =
//             calculateFullBodyWHPRStatus(userVitals[i]['waist_hip_ratio']);
//       }
//
//       if (userVitals[i]['percent_body_fat'] != null &&
//           userVitals[i]['percent_body_fat'] != "NaN") {
//         userVitals[i]['percent_body_fat'] =
//             userVitals[i]['percent_body_fat'].toStringAsFixed(2);
//         pbfStatus =
//             calculateFullBodyPBFStatus(userVitals[i]['percent_body_fat']);
//       }
//
//       if (userVitals[i]['waist_height_ratio'] != null &&
//           userVitals[i]['waist_height_ratio'] != "NaN") {
//         userVitals[i]['waist_height_ratio'] =
//             userVitals[i]['waist_height_ratio'].toStringAsFixed(2);
//         waistHeightStatus =
//             calculateFullBodyWHTRStatus(userVitals[i]['waist_height_ratio']);
//       }
//
//       if (userVitals[i]['visceral_fat'] != null &&
//           userVitals[i]['visceral_fat'] != "NaN") {
//         userVitals[i]['visceral_fat'] =
//             stringify(userVitals[i]['visceral_fat']);
//         vfStatus = calculateFullBodyVFStatus(userVitals[i]['visceral_fat']);
//       }
//
//       if (userVitals[i]['basal_metabolic_rate'] != null &&
//           userVitals[i]['basal_metabolic_rate'] != "NaN") {
//         userVitals[i]['basal_metabolic_rate'] =
//             stringify(userVitals[i]['basal_metabolic_rate']);
//         bmrStatus =
//             calculateFullBodyBMRStatus(userVitals[i]['basal_metabolic_rate']);
//       }
//
//       if (userVitals[i]['bone_mineral_content'] != null &&
//           userVitals[i]['bone_mineral_content'] != "NaN") {
//         userVitals[i]['bone_mineral_content'] =
//             userVitals[i]['bone_mineral_content'].toStringAsFixed(2);
//         bomcStatus =
//             calculateFullBodyBMCStatus(userVitals[i]['bone_mineral_content']);
//       }
//
//       userVitals[i]['bmi'] ??= calcBmi(
//           height: userVitals[i]['heightMeters'].toString(),
//           weight: userVitals[i]['weight'].toString());
//       finalHeight = doubleFly(userVitals[i]['heightMeters']) ?? finalHeight;
//       finalWeight = doubleFly(userVitals[i]['weightKG']) ?? finalWeight;
//       if (userVitals[i]['systolic'] != null &&
//           userVitals[i]['diastolic'] != null) {
//         userVitals[i]['bp'] = stringify(userVitals[i]['systolic']) +
//             '/' +
//             stringify(userVitals[i]['diastolic']);
//       }
//       userVitals[i]['weightKGClass'] = userVitals[i]['bmiClass'];
//       userVitals[i]['ECGBpmClass'] = userVitals[i]['leadTwoStatus'];
//       userVitals[i]['fatRatioClass'] = userVitals[i]['fatClass'];
//       userVitals[i]['pulseBpmClass'] = userVitals[i]['pulseClass'];
//     }
//     prefs.setDouble(SPKeys.weight, finalWeight);
//     prefs.setDouble(SPKeys.height, finalHeight);
//
//     //Check which vital
//     vitalsOnHome.forEach((f) {
//       allScores[f] = [];
//       allScores[f + 'Class'] = [];
//       for (var i = 0; i < userVitals.length; i++) {
//         if (userVitals[i][f] != '' &&
//             userVitals[i][f] != null &&
//             userVitals[i][f] != 'N/A') {
//           /// round off to nearest 2 decimal 🌊
//           if (userVitals[i][f] is double) {
//             if (decimalVitals.contains(f)) {
//               userVitals[i][f] = (userVitals[i][f] * 100.0).toInt() / 100;
//             } else {
//               userVitals[i][f] = (userVitals[i][f]).toInt();
//             }
//           }
//           Map mapToAdd = {
//             'value': userVitals[i][f],
//             'status': userVitals[i][f + 'Class'] == null
//                 ? 'Unknown'
//                 : camelize(userVitals[i][f + 'Class']),
//             'date': userVitals[i]['dateTimeFormatted'] != null
//                 ? DateTime.tryParse(
//                     userVitals[i]['dateTimeFormatted'].toString())
//                 : getDateTimeStamp(user['accountCreated']),
//             'moreData': {
//               'Address': stringify(userVitals[i]['orgAddress']),
//               'City': stringify(userVitals[i]['IHLMachineLocation']),
//             }
//           };
//           // processing specific to a vital
//           if (f == 'temperature') {
//             if (userVitals[i]['Roomtemperature'] != null) {
//               userVitals[i]['Roomtemperature'] =
//                   doubleFly(userVitals[i]['Roomtemperature']);
//               mapToAdd['moreData']['Room Temperature'] =
//                   '${stringify((userVitals[i]['Roomtemperature'] * 9 / 5) + 32)} ${vitalsUI['temperature']['unit']}';
//             }
//             mapToAdd['value'] =
//                 (((userVitals[i][f] * 900 / 5).toInt()) / 100 + 32)
//                     .toStringAsFixed(2);
//           }
//           if (f == 'bp') {
//             mapToAdd['moreData']['Systolic'] =
//                 userVitals[i]['systolic'].toString();
//             mapToAdd['moreData']['Diastolic'] =
//                 userVitals[i]['diastolic'].toString();
//           }
//
//           if (f == 'protien') {
//             mapToAdd['protien'] = userVitals[i]['protien'].toString();
//             mapToAdd['status'] = proteinStatus.toString();
//           }
//
//           if (f == 'intra_cellular_water') {
//             mapToAdd['intra_cellular_water'] =
//                 userVitals[i]['intra_cellular_water'].toString();
//             mapToAdd['status'] = icwStatus.toString();
//           }
//
//           if (f == 'extra_cellular_water') {
//             mapToAdd['extra_cellular_water'] =
//                 userVitals[i]['extra_cellular_water'].toString();
//             mapToAdd['status'] = ecwStatus.toString();
//           }
//
//           if (f == 'mineral') {
//             mapToAdd['mineral'] = userVitals[i]['mineral'].toString();
//             mapToAdd['status'] = mineralStatus.toString();
//           }
//
//           if (f == 'skeletal_muscle_mass') {
//             mapToAdd['skeletal_muscle_mass'] =
//                 userVitals[i]['skeletal_muscle_mass'].toString();
//             mapToAdd['status'] = smmStatus.toString();
//           }
//
//           if (f == 'body_fat_mass') {
//             mapToAdd['body_fat_mass'] =
//                 userVitals[i]['body_fat_mass'].toString();
//             mapToAdd['status'] = bfmStatus.toString();
//           }
//
//           if (f == 'body_cell_mass') {
//             mapToAdd['body_cell_mass'] =
//                 userVitals[i]['body_cell_mass'].toString();
//             mapToAdd['status'] = bcmStatus.toString();
//           }
//
//           if (f == 'waist_hip_ratio') {
//             mapToAdd['waist_hip_ratio'] =
//                 userVitals[i]['waist_hip_ratio'].toString();
//             mapToAdd['status'] = waistHipStatus.toString();
//           }
//
//           if (f == 'percent_body_fat') {
//             mapToAdd['percent_body_fat'] =
//                 userVitals[i]['percent_body_fat'].toString();
//             mapToAdd['status'] = pbfStatus.toString();
//           }
//
//           if (f == 'waist_height_ratio') {
//             mapToAdd['waist_height_ratio'] =
//                 userVitals[i]['waist_height_ratio'].toString();
//             mapToAdd['status'] = waistHeightStatus.toString();
//           }
//
//           if (f == 'visceral_fat') {
//             mapToAdd['visceral_fat'] = userVitals[i]['visceral_fat'].toString();
//             mapToAdd['status'] = vfStatus.toString();
//           }
//
//           if (f == 'basal_metabolic_rate') {
//             mapToAdd['basal_metabolic_rate'] =
//                 userVitals[i]['basal_metabolic_rate'].toString();
//             mapToAdd['status'] = bmrStatus.toString();
//           }
//
//           if (f == 'bone_mineral_content') {
//             mapToAdd['bone_mineral_content'] =
//                 userVitals[i]['bone_mineral_content'].toString();
//             mapToAdd['status'] = bomcStatus.toString();
//           }
//
//           if (f == 'ECGBpm') {
//             mapToAdd['graphECG'] = ECGCalc(
//               isLeadThree: userVitals[i]['LeadMode'] == 3,
//               data1: userVitals[i]['ECGData'],
//               data2: userVitals[i]['ECGData2'],
//               data3: userVitals[i]['ECGData3'],
//             );
//
//             mapToAdd['moreData']['Lead One Status'] =
//                 stringify(userVitals[i]['leadOneStatus']);
//             mapToAdd['moreData']['Lead Two Status'] =
//                 stringify(userVitals[i]['leadTwoStatus']);
//             mapToAdd['moreData']['Lead Three Status'] =
//                 stringify(userVitals[i]['leadThreeStatus']);
//           }
//           allScores[f].add(mapToAdd);
//           if (!vitalsToShow.contains(f)) {
//             vitalsToShow.add(f);
//           }
//         }
//       }
//     });
//     vitalsToShow.toSet();
//     vitalsToShow = vitalsOnHome;
//
//     loading = false;
//     if (this.mounted) {
//       this.setState(() {});
//     }
//   }
//
//   double doubleFly(k) {
//     if (k is num) {
//       return k * 1.0;
//     }
//     if (k is String) {
//       return double.tryParse(k);
//     }
//     return null;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     this.getData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     if (width < 600) {
//       width = 500;
//     }
//     if (loading) {
//       return SafeArea(
//         child: Container(
//           color: AppColors.bgColorTab,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 40,
//                     child: TextButton(
//                       child: Icon(
//                         Icons.menu,
//                         size: 30,
//                         color: Colors.white,
//                       ),
//                       onPressed: () {
//                         widget.openDrawer();
//                       },
//                       style: TextButton.styleFrom(
//                         padding: EdgeInsets.all(0),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     if (!isVerified) {
//       return SafeArea(
//         child: Container(
//           color: AppColors.bgColorTab,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 40,
//                     child: TextButton(
//                       child: Icon(
//                         Icons.menu,
//                         size: 30,
//                         color: AppColors.primaryAccentColor,
//                       ),
//                       onPressed: () {
//                         widget.openDrawer();
//                       },
//                       style: TextButton.styleFrom(
//                         padding: EdgeInsets.all(0),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Center(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       size: 100,
//                       color: AppColors.lightTextColor,
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     Text(AppTexts.updateProfile),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     TextButton(
//                       style: TextButton.styleFrom(
//                         backgroundColor: AppColors.primaryAccentColor,
//                         textStyle: TextStyle(color: Colors.white),
//                       ),
//                       child: Text(AppTexts.visitProfile),
//                       onPressed: () {
//                         widget.goToProfile();
//                       },
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     return SafeArea(
//       child: Column(
//         children: <Widget>[
//           CustomPaint(
//             painter: BackgroundPainter(
//               primary: AppColors.primaryColor.withOpacity(0.7),
//               secondary: AppColors.primaryColor.withOpacity(0.0),
//             ),
//             child: Container(),
//           ),
//           Expanded(
//             child: CustomScrollView(
//               slivers: <Widget>[
//                 SliverToBoxAdapter(
//                   child: Container(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             SizedBox(
//                               width: 40,
//                               child: TextButton(
//                                 child: Icon(
//                                   Icons.menu,
//                                   size: 30,
//                                   color: Colors.white,
//                                 ),
//                                 onPressed: () {
//                                   widget.openDrawer();
//                                 },
//                                 style: TextButton.styleFrom(
//                                   padding: EdgeInsets.all(0),
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               AppTexts.scoreTitle,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 25 * width / 500),
//                             ),
//                             SizedBox(
//                               width: 40,
//                             )
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SliverToBoxAdapter(
//                   child: Center(
//                     child: ScoreMeter(
//                       data: widget.userScore,
//                     ),
//                   ),
//                 ),
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 10),
//                     child: Text(
//                       vitalsToShow.length > 0
//                           ? AppTexts.yoVitals
//                           : AppTexts.noVitals,
//                       style: TextStyle(
//                         fontSize: 20 * width / 500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SliverGrid(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount:
//                         MediaQuery.of(context).size.width > 600 ? 3 : 2,
//                     childAspectRatio: 1.2,
//                   ),
//                   delegate: SliverChildBuilderDelegate(
//                     (BuildContext context, int index) {
//                       return VitalCard(
//                         uiData: vitalsUI[vitalsToShow[index]],
//                         vitalType: vitalsToShow[index],
//                         data: allScores[vitalsToShow[index]],
//                       );
//                     },
//                     childCount: vitalsToShow.length,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );

//   }
// }*/
//
//

// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:expandable/expandable.dart';

// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../constants/api.dart';
import '../constants/routes.dart';
import '../home_dashboard/health_journal_tabview.dart';
import '../models/data_helper.dart';
import '../models/ecg_calculator.dart';
import '../new_design/presentation/pages/home/landingPage.dart';
import 'profiletab.dart';
import '../utils/ScUtil.dart';
import '../utils/SpUtil.dart';
import '../utils/commonUi.dart';
import '../utils/sizeConfig.dart';
import '../views/JointAccount/joint_account_main.dart';
import '../views/dashBoardExpiredSubscriptionTile.dart';
import '../views/dietJournal/activity/activity_list_view.dart';
import '../views/dietJournal/activity/today_activity.dart';
import '../views/dietJournal/activity_tile_view.dart';
import '../views/dietJournal/apis/list_apis.dart';
import '../views/dietJournal/dashBoard_activity_tile_view.dart';
import '../views/dietJournal/dietJournal.dart';
import '../views/dietJournal/diet_view.dart';
import '../views/dietJournal/home_dash_todays_activity_view.dart';
import '../views/dietJournal/journal_graph.dart';
import '../views/dietJournal/models/get_todays_food_log_model.dart';
import '../views/dietJournal/title_widget.dart';
import '../views/home_screen.dart';
import '../views/marathon/dashboard_marathonCard.dart';
import '../views/marathon/marathon_details.dart';
import '../views/marathon/register_user.dart';
import '../views/other_vitals.dart';
import '../views/teleconsultation/consultation_history_summary.dart';
import '../views/teleconsultation/exports.dart';
import '../views/teleconsultation/myAppointments.dart';
import '../views/teleconsultation/videocall/genix_lab_order_pdf.dart';
import '../views/teleconsultation/videocall/genix_prescription.dart';
import '../views/teleconsultation/videocall/videocall.dart';
import '../views/teleconsultation/wellness_cart.dart';

// import 'package:ihl/views/dietJournal/todays_activity_view.dart';
import '../widgets/dashboard/scoreMeter.dart';
import '../widgets/height.dart';
import '../widgets/teleconsulation/dashboard_Consult_historyItemTile.dart';
import '../widgets/teleconsulation/dashboard_history.dart';
import '../widgets/teleconsulation/dashboard_subscriptionTile.dart';
import '../widgets/teleconsulation/dashboardappointmentTile.dart';
import '../widgets/teleconsulation/exports.dart';
import '../widgets/teleconsulation/upcomingAppointment.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:strings/strings.dart';
import 'dart:convert';
import '../utils/app_colors.dart';
import '../painters/backgroundPanter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../constants/vitalUI.dart';
import '../constants/app_texts.dart';
import '../widgets/dashboard/liteVitalsCard.dart';
import '../constants/spKeys.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../repositories/marathon_event_api.dart';

import '../new_design/app/utils/localStorageKeys.dart';
import '../new_design/presentation/pages/home/home_view.dart';
import '../new_design/presentation/pages/spalshScreen/splashScreen.dart';

// ignore: must_be_immutable
class HomeTab extends StatefulWidget {
  Function closeDrawer;
  Function openDrawer;
  Function goToProfile;
  String userScore = '0';
  String username;
  final String appointId;
  final Map consultant;
  final bool deepLink;

  HomeTab(
      {Key key,
      this.closeDrawer,
      this.username,
      this.openDrawer,
      this.userScore,
      this.goToProfile,
      this.consultant,
      this.appointId,
      this.deepLink})
      : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Activity> todaysActivityData = [];
  List<Activity> otherActivityData = [];
  bool loading = true;
  bool isJointAccount = true;
  List vitalsToShow = [];
  String name = 'you';
  Map allScores = {};
  var data;
  bool isVerified = true;
  int surveybmi = 0;
  var userVitalst;
  int differenceInTime;
  int adifferenceInTime;
  int adifferenceInDays;
  List completed_appointmentDetails = [];
  List hislist = [];
  Map fitnessClassSpecialties;
  var platformData;
  Map res;
  bool requestError = false;
  final http.Client _client = http.Client(); //3gb

  Future getSubscriptionClassListData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data1 = prefs.get('data');
    Map res1 = jsonDecode(data1);
    var iHLUserId = res1['User']['id'];
    final http.Response getPlatformData = await _client.post(
      Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, String>{'ihl_id': iHLUserId, 'cache': "true"}),
    );
    if (getPlatformData.statusCode == 200) {
      if (getPlatformData.body != null) {
        prefs.setString(SPKeys.platformData, getPlatformData.body);
        res = jsonDecode(getPlatformData.body);
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          requestError = true;
        });
      }
    }

    //platformData = prefs.get(SPKeys.platformData);

    if (res['consult_type'] == null ||
        res['consult_type'] is! List ||
        res['consult_type'].isEmpty) {
      return;
    }

    fitnessClassSpecialties = res['consult_type'][1];
  }

  // Dashboard completed appointment history method starts

  bool hashistory = false;
  List appointments = [];
  List history = [];
  List completedHistory = [];
  List hlist = [];
  bool completedSelected = false;

  // bool approvedSelected = false;
  // bool canceledSelected = false;
  // bool requestedSelected = false;
  // bool rejectedSelected = false;
  // bool loading = true;
  List apps = [];

  List<String> appointmentStatus = [
    // 'Approved',
    'Completed',
    // 'Rejected',
    // 'Requested',
    // 'Canceled',
  ];

  Future getAppointmentHistoryData() async {
    /*SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);
    Map teleConsulResponse;*/
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    Object data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHLUserId = res['User']['id'];
  }

  DashBoardHistoryItem getDashBoardHistoryItem(Map map, var index) {
    return DashBoardHistoryItem(
      index: index,
      appointId: map['appointment_id'],
      appointmentStartTime: map['appointment_start_time'],
      appointmentEndTime: map['appointment_end_time'],
      consultantName: map['consultant_name'] ?? "N/A",
      consultationFees: map['consultation_fees'],
      appointmentStatus: map['appointment_status'],
      callStatus: map['call_status'] ?? "N/A",
    );
  }

  // Dashboard completed appointment history method ends

  // subscription expired history method starts

  // bool expanded = true;
  // bool hasSubscription = false;
  List subscriptions = [];
  List expiredSubscriptions;
  List elist = [];

  // bool loading = true;

  Future getExpiredSubscriptionHistoryData() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    Object data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    iHLUserId = res['User']['id'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userDetailsResponse);
    Map teleConsulResponse = json.decode(data);
    loading = false;
    if (teleConsulResponse['my_subscriptions'] == null ||
        teleConsulResponse['my_subscriptions'] is! List ||
        teleConsulResponse['my_subscriptions'].isEmpty) {
      if (mounted) {
        setState(() {
          hasSubscription = false;
        });
      }
      return;
    }
    if (mounted) {
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

        DateTime currentDateTime = DateTime.now();

        for (int i = 0; i < expiredSubscriptions.length; i++) {
          var duration = expiredSubscriptions[i]["course_duration"];
          var time = expiredSubscriptions[i]["course_time"];

          String courseDurationFromApi = duration;
          String courseTimeFromApi = time;

          String courseStartTime;
          String courseEndTime;

          String courseStartDuration = courseDurationFromApi.substring(0, 10);

          String courseEndDuration = courseDurationFromApi.substring(13, 23);

          DateTime startDate = DateFormat("yyyy-MM-dd").parse(courseStartDuration);
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          String startDateFormattedToString = formatter.format(startDate);

          DateTime endDate = DateFormat("yyyy-MM-dd").parse(courseEndDuration);
          String endDateFormattedToString = formatter.format(endDate);
          if (courseTimeFromApi[2].toString() == ':' && courseTimeFromApi[13].toString() != ':') {
            String tempcourseEndTime = '';
            courseStartTime = courseTimeFromApi.substring(0, 8);
            for (int i = 0; i < courseTimeFromApi.length; i++) {
              if (i == 10) {
                tempcourseEndTime += '0';
              } else if (i > 10) {
                tempcourseEndTime += courseTimeFromApi[i];
              }
            }
            courseEndTime = tempcourseEndTime;
          } else if (courseTimeFromApi[2].toString() != ':') {
            String tempcourseStartTime = '';
            String tempcourseEndTime = '';

            for (int i = 0; i < courseTimeFromApi.length; i++) {
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
              String tempcourseEndTime = '';
              for (int i = 0; i <= courseEndTime.length; i++) {
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
          String startDateAndTime = "$startDateFormattedToString $startingTime";
          String endDateAndTime = "$endDateFormattedToString $endingTime";
          DateTime finalStartDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
          DateTime finalEndDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);
          differenceInTime = endTime.difference(startTime).inHours;
          elist.add(expiredSubscriptions[i]);
        }

        hasSubscription = true;
      });
    }
  }

  DashBoardExpiredSubscriptionTile getExpiredSubscriptionItem(Map map) {
    return DashBoardExpiredSubscriptionTile(
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

  // subscription expired history method ends

  /// handle null and empty strings⚡
  String stringify(dynamic prop) {
    if (prop == null || prop == '' || prop == ' ' || prop == 'NA') {
      return AppTexts.notAvailable;
    }
    if (prop is double) {
      double doub = prop;
      prop = doub.round();
    }
    String stringVal = prop.toString();
    stringVal = stringVal.trim().isEmpty ? AppTexts.notAvailable : stringVal;
    return stringVal;
  }

  /// calculate bmi🎇🎇
  int calcBmi({height, weight}) {
    double parsedH;
    double parsedW;
    if (height == null || weight == null) {
      return null;
    }

    parsedH = double.tryParse(height);
    parsedW = double.tryParse(weight);
    if (parsedH != null && parsedW != null) {
      int bmi = parsedW ~/ (parsedH * parsedH);
      return bmi;
    }
    return null;
  }

  // new bmi formula
  /// calculate bmi🎇🎇
  int calcBmiNew({height, weight}) {
    double parsedH;
    double parsedW;
    if (height != null && weight != null && height != '' && weight != '') {
      parsedH = double.tryParse(height.toString());
      parsedW = double.tryParse(weight.toString());
    }
    if (parsedH != null && parsedW != null) {
      int bmi = parsedW ~/ (parsedH * parsedW);

      return bmi;
    }
    return null;
  }

  /// returns BMI Class for a BMI 🌈
  String bmiClassCalc(int bmi) {
    if (bmi == null) {
      return AppTexts.notAvailable;
    }
    if (bmi > 30) {
      return AppTexts.obeseBMI;
    }
    if (bmi > 25) {
      return AppTexts.ovwBMI;
    }
    if (bmi < 18) {
      return AppTexts.undwBMI;
    }
    return AppTexts.normalBMI;
  }

  DateTime getDateTimeStamp(String d) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(int.tryParse(d
          .substring(0, d.indexOf('+'))
          .replaceAll('Date', '')
          .replaceAll('/', '')
          .replaceAll('(', '')
          .replaceAll(')', '')));
    } catch (e) {
      return DateTime.now();
    }
  }

  // surveyui bmi calculation

  void surveybmiCalc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get('data');
    // data = data == null || data == '' ? '{"User":{}}' : data;
    Map res = jsonDecode(data);
    String height = res['User']['heightMeters'].toString();
    String weight = res['User']['userInputWeightInKG'].toString();
    double parsedH;
    double parsedW;
    parsedH = double.tryParse(height);
    parsedW = double.tryParse(weight);
    if (parsedH != null && parsedW != null) {
      surveybmi = parsedW ~/ (parsedH * parsedH);

      //   if (surveybmi == null) {
      //     return AppTexts.notAvailable;
      //   }
      //   if (surveybmi > 30) {
      //     return AppTexts.obeseBMI;
      //   }
      //   if (surveybmi > 25) {
      //     return AppTexts.ovwBMI;
      //   }
      //   if (surveybmi < 18) {
      //     return AppTexts.undwBMI;
      //   }
      //   return AppTexts.normalBMI;
      // } else {
      //   return AppTexts.notAvailable;
    }
  }

  /// looooooooooooooong code processes JSON response 🌠
  ///
  List userVitals;

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object raw = prefs.get(SPKeys.userData);
    if (raw == '' || raw == null) {
      raw = '{}';
    }
    data = jsonDecode(raw);

    Map user = data['User'];
    user ??= {};
    userVitalst = prefs.getString(SPKeys.vitalsData);
    if (userVitalst == null || userVitalst == '' || userVitalst == '[]') {
      if (user['userInputWeightInKG'] == null ||
          user['userInputWeightInKG'] == '' ||
          user['heightMeters'] == null ||
          user['heightMeters'] == '' ||
          ((user['email'] == null || user['email'] == '') &&
              (user['mobileNumber'] == null || user['mobileNumber'] == ''))) {
        // isVerified = false;
        // loading = false;

        if (mounted) {
          if (isJointAccount) {
            isVerified = true;
            loading = true;
          }
          // setState(() {});
        } else {
          isVerified = false;
          loading = false;
          return;
        }
      }
      userVitalst = '[{}]';
    }
    userVitals = jsonDecode(userVitalst);
    //get inputted height weight if values are not available

    if (userVitals[0]['weightKG'] == null) {
      userVitals[0]['weightKG'] = user['userInputWeightInKG'];
    }
    if (userVitals[0]['heightMeters'] == null) {
      userVitals[0]['heightMeters'] = user['heightMeters'];
    }
    //Calculate bmi
    if (userVitals[0]['bmi'] == null) {
      userVitals[0]['bmi'] = calcBmi(
          height: userVitals[0]['heightMeters'].toString(),
          weight: userVitals[0]['weightKG'].toString());
      userVitals[0]['bmiClass'] = bmiClassCalc(userVitals[0]['bmi']);
    }
    allScores = {};
    //prepare data
    double finalWeight = 0;
    double finalHeight = 0;
    String bcml = "20.00";
    String bcmh = "25.00";
    String lowMineral = "2.00";
    String highMineral = "3.00";
    var heightinCMS = userVitals[0]['heightMeters'] * 100;
    String weight =
        userVitals[0]['weightKG'].toString() == "" ? '0' : userVitals[0]['weightKG'].toString();
    String gender = user['gender'].toString();
    var lowSmmReference,
        lowFatReference,
        highSmmReference,
        highFatReference,
        lowBmcReference,
        highBmcReference,
        icll,
        iclh,
        ecll,
        eclh,
        proteinl,
        proteinh,
        waisttoheightratiolow,
        waisttoheightratiohigh,
        lowPbfReference,
        highPbfReference;

    if (gender != 'm') {
      lowPbfReference = "18.00";
      highPbfReference = "28.00";
      List<List<int>> femaleHeightWeight = [
        [147, 45, 59],
        [150, 45, 60],
        [152, 46, 62],
        [155, 47, 63],
        [157, 49, 65],
        [160, 50, 67],
        [162, 51, 69],
        [165, 53, 70],
        [167, 54, 72],
        [170, 55, 74],
        [172, 57, 75],
        [175, 58, 77],
        [177, 60, 78],
        [180, 61, 80]
      ];
      int j = 0;
      while (femaleHeightWeight[j][0] <= heightinCMS) {
        j++;
        if (j == 13) {
          break;
        }
      }
      int wtl, wth;
      if (j == 0) {
        wtl = femaleHeightWeight[j][1];
        wth = femaleHeightWeight[j][2];
      } else {
        wtl = femaleHeightWeight[j - 1][1];
        wth = femaleHeightWeight[j - 1][2];
      }
      lowSmmReference = (0.36 * wtl);
      highSmmReference = (0.36 * wth);
      lowFatReference = (0.18 * double.tryParse(weight));
      highFatReference = (0.28 * double.tryParse(weight));
      lowBmcReference = "1.70";
      highBmcReference = "3.00";
      icll = (0.3 * wtl);
      iclh = (0.3 * wth);
      ecll = (0.2 * wtl);
      eclh = (0.2 * wth);
      proteinl = (0.116 * double.tryParse(weight));
      proteinh = (0.141 * double.tryParse(weight));
      waisttoheightratiolow = "0.35";
      waisttoheightratiohigh = "0.53";
    } else {
      lowPbfReference = "10.00";
      highPbfReference = "20.00";
      List<List<int>> maleHeightWeight = [
        [155, 55, 66],
        [157, 56, 67],
        [160, 57, 68],
        [162, 58, 70],
        [165, 59, 72],
        [167, 60, 74],
        [170, 61, 75],
        [172, 62, 77],
        [175, 63, 79],
        [177, 64, 81],
        [180, 65, 83],
        [182, 66, 85],
        [185, 68, 87],
        [187, 69, 89],
        [190, 71, 91]
      ];
      int k = 0;
      while (maleHeightWeight[k][0] <= heightinCMS) {
        k++;
        if (k == 14) {
          break;
        }
      }
      int wtl, wth;
      if (k == 0) {
        wtl = maleHeightWeight[k][1];
        wth = maleHeightWeight[k][2];
      } else {
        wtl = maleHeightWeight[k - 1][1];
        wth = maleHeightWeight[k - 1][2];
      }
      lowSmmReference = (0.42 * wtl);
      highSmmReference = (0.42 * wth);
      lowFatReference = (0.10 * double.parse(weight ?? '0'));
      highFatReference = (0.20 * double.parse(weight ?? '0'));
      lowBmcReference = "2.00";
      highBmcReference = "3.70";
      icll = (0.3 * wtl);
      iclh = (0.3 * wth);
      ecll = (0.2 * wtl);
      eclh = (0.2 * wth);
      proteinl = (0.109 * double.parse(weight));
      proteinh = (0.135 * double.parse(weight));
      waisttoheightratiolow = "0.35";
      waisttoheightratiohigh = "0.57";
    }

    String proteinStatus;
    String ecwStatus;
    String icwStatus;
    String mineralStatus;
    String smmStatus;
    String bfmStatus;
    String bcmStatus;
    String waistHipStatus;
    String pbfStatus;
    String waistHeightStatus;
    String vfStatus;
    String bmrStatus;
    String bomcStatus;

    calculateFullBodyProteinStatus(FullBodyProtein) {
      if (double.parse(FullBodyProtein) < proteinl) {
        return 'Low';
      } else if (double.parse(FullBodyProtein) >= proteinl) {
        return 'Normal';
      }
    }

    calculateFullBodyECWStatus(FullBodyECW) {
      if (double.parse(FullBodyECW) < ecll) {
        return 'Low';
      } else if (double.parse(FullBodyECW) >= ecll && double.parse(FullBodyECW) <= eclh) {
        return 'Normal';
      } else if (double.parse(FullBodyECW) > eclh) {
        return 'High';
      }
    }

    calculateFullBodyICWStatus(FullBodyICW) {
      if (double.parse(FullBodyICW) < icll) {
        return 'Low';
      } else if (double.parse(FullBodyICW) >= icll && double.parse(FullBodyICW) <= iclh) {
        return 'Normal';
      } else if (double.parse(FullBodyICW) > iclh) {
        return 'High';
      }
    }

    calculateFullBodyMineralStatus(FullBodyMineral) {
      if (double.parse(FullBodyMineral) < double.parse(lowMineral)) {
        return 'Low';
      } else if (double.parse(FullBodyMineral) >= double.parse(lowMineral)) {
        return 'Normal';
      }
    }

    calculateFullBodySMMStatus(FullBodySMM) {
      if (double.parse(FullBodySMM) < lowSmmReference) {
        return 'Low';
      } else if (double.parse(FullBodySMM) >= lowSmmReference) {
        return 'Normal';
      }
    }

    calculateFullBodyBMCStatus(FullBodyBMC) {
      if (double.parse(FullBodyBMC) < double.parse(lowBmcReference)) {
        return 'Low';
      } else if (double.parse(FullBodyBMC) >= double.parse(lowBmcReference)) {
        return 'Normal';
      }
    }

    calculateFullBodyPBFStatus(FullBodyPBF) {
      if (double.parse(FullBodyPBF) < double.parse(lowPbfReference)) {
        return 'Low';
      } else if (double.parse(FullBodyPBF) >= double.parse(lowPbfReference) &&
          double.parse(FullBodyPBF) <= double.parse(highPbfReference)) {
        return 'Normal';
      } else if (double.parse(FullBodyPBF) > double.parse(highPbfReference)) {
        return 'High';
      }
    }

    calculateFullBodyBCMStatus(FullBodyBCM) {
      if (double.parse(FullBodyBCM) < double.parse(bcml)) {
        return 'Low';
      } else if (double.parse(FullBodyBCM) >= double.parse(bcml)) {
        return 'Normal';
      }
    }

    calculateFullBodyFATStatus(FullBodyFAT) {
      if (double.parse(FullBodyFAT) < lowFatReference) {
        return 'Low';
      } else if (double.parse(FullBodyFAT) >= lowFatReference &&
          double.parse(FullBodyFAT) <= highFatReference) {
        return 'Normal';
      } else if (double.parse(FullBodyFAT) > highFatReference) {
        return 'High';
      }
    }

    calculateFullBodyVFStatus(FullBodyVF) {
      if (FullBodyVF != "NaN") {
        if (int.tryParse(FullBodyVF) <= 100) {
          return 'Normal';
        } else if (int.tryParse(FullBodyVF) > 100) {
          return 'High';
        }
      }
    }

    calculateFullBodyBMRStatus(FullBodyBMR) {
      if (int.parse(FullBodyBMR) < 1200) {
        return 'Low';
      } else if (int.parse(FullBodyBMR) >= 1200) {
        return 'Normal';
      }
    }

    calculateFullBodyWHPRStatus(FullBodyWHPR) {
      if (double.parse(FullBodyWHPR) < 0.80) {
        return 'Low';
      } else if (double.parse(FullBodyWHPR) >= 0.80 && double.parse(FullBodyWHPR) <= 0.90) {
        return 'Normal';
      }
      if (double.parse(FullBodyWHPR) > 0.90) {
        return 'High';
      }
    }

    calculateFullBodyWHTRStatus(FullBodyWHTR) {
      if (double.parse(FullBodyWHTR) < double.parse(waisttoheightratiolow)) {
        return 'Low';
      } else if (double.parse(FullBodyWHTR) >= double.parse(waisttoheightratiolow) &&
          double.parse(FullBodyWHTR) <= double.parse(waisttoheightratiohigh)) {
        return 'Normal';
      }
      if (double.parse(FullBodyWHTR) > double.parse(waisttoheightratiohigh)) {
        return 'High';
      }
    }

    for (int i = 0; i < userVitals.length; i++) {
      if (userVitals[i]['protien'] != null && userVitals[i]['protien'] != "NaN") {
        userVitals[i]['protien'] = userVitals[i]['protien'].toStringAsFixed(2);
        proteinStatus = calculateFullBodyProteinStatus(userVitals[i]['protien']);
      }
      // My code
      if (userVitals[i]['heightMeters'] != null && userVitals[i]['heightMeters'] != "NaN") {
        userVitals[i]['heightMeters'] = userVitals[i]['heightMeters'].toStringAsFixed(2);
        proteinStatus = calculateFullBodyProteinStatus(userVitals[i]['heightMeters']);
      }
      // End
      if (userVitals[i]['intra_cellular_water'] != null &&
          userVitals[i]['intra_cellular_water'] != "NaN") {
        userVitals[i]['intra_cellular_water'] =
            userVitals[i]['intra_cellular_water'].toStringAsFixed(2);
        icwStatus = calculateFullBodyICWStatus(userVitals[i]['intra_cellular_water']);
      }

      if (userVitals[i]['extra_cellular_water'] != null &&
          userVitals[i]['extra_cellular_water'] != "NaN") {
        userVitals[i]['extra_cellular_water'] =
            userVitals[i]['extra_cellular_water'].toStringAsFixed(2);
        ecwStatus = calculateFullBodyECWStatus(userVitals[i]['extra_cellular_water']);
      }

      if (userVitals[i]['mineral'] != null && userVitals[i]['mineral'] != "NaN") {
        userVitals[i]['mineral'] = userVitals[i]['mineral'].toStringAsFixed(2);
        mineralStatus = calculateFullBodyMineralStatus(userVitals[i]['mineral']);
      }

      if (userVitals[i]['skeletal_muscle_mass'] != null &&
          userVitals[i]['skeletal_muscle_mass'] != "NaN") {
        userVitals[i]['skeletal_muscle_mass'] =
            userVitals[i]['skeletal_muscle_mass'].toStringAsFixed(2);
        smmStatus = calculateFullBodySMMStatus(userVitals[i]['skeletal_muscle_mass']);
      }

      if (userVitals[i]['body_fat_mass'] != null && userVitals[i]['body_fat_mass'] != "NaN") {
        userVitals[i]['body_fat_mass'] = userVitals[i]['body_fat_mass'].toStringAsFixed(2);
        bfmStatus = calculateFullBodyFATStatus(userVitals[i]['body_fat_mass']);
      }

      if (userVitals[i]['body_cell_mass'] != null && userVitals[i]['body_cell_mass'] != "NaN") {
        userVitals[i]['body_cell_mass'] = userVitals[i]['body_cell_mass'].toStringAsFixed(2);
        bcmStatus = calculateFullBodyBCMStatus(userVitals[i]['body_cell_mass']);
      }

      if (userVitals[i]['waist_hip_ratio'] != null && userVitals[i]['waist_hip_ratio'] != "NaN") {
        userVitals[i]['waist_hip_ratio'] = userVitals[i]['waist_hip_ratio'].toStringAsFixed(2);
        waistHipStatus = calculateFullBodyWHPRStatus(userVitals[i]['waist_hip_ratio']);
      }

      if (userVitals[i]['percent_body_fat'] != null && userVitals[i]['percent_body_fat'] != "NaN") {
        userVitals[i]['percent_body_fat'] = userVitals[i]['percent_body_fat'].toStringAsFixed(2);
        pbfStatus = calculateFullBodyPBFStatus(userVitals[i]['percent_body_fat']);
      }

      if (userVitals[i]['waist_height_ratio'] != null &&
          userVitals[i]['waist_height_ratio'] != "NaN") {
        userVitals[i]['waist_height_ratio'] =
            userVitals[i]['waist_height_ratio'].toStringAsFixed(2);
        waistHeightStatus = calculateFullBodyWHTRStatus(userVitals[i]['waist_height_ratio']);
      }

      if (userVitals[i]['visceral_fat'] != null && userVitals[i]['visceral_fat'] != "NaN") {
        userVitals[i]['visceral_fat'] = stringify(userVitals[i]['visceral_fat']);
        vfStatus = calculateFullBodyVFStatus(userVitals[i]['visceral_fat']);
      }

      if (userVitals[i]['basal_metabolic_rate'] != null &&
          userVitals[i]['basal_metabolic_rate'] != "NaN") {
        userVitals[i]['basal_metabolic_rate'] = stringify(userVitals[i]['basal_metabolic_rate']);
        bmrStatus = calculateFullBodyBMRStatus(userVitals[i]['basal_metabolic_rate']);
      }

      if (userVitals[i]['bone_mineral_content'] != null &&
          userVitals[i]['bone_mineral_content'] != "NaN") {
        userVitals[i]['bone_mineral_content'] =
            userVitals[i]['bone_mineral_content'].toStringAsFixed(2);
        bomcStatus = calculateFullBodyBMCStatus(userVitals[i]['bone_mineral_content']);
      }

      userVitals[i]['bmi'] ??= calcBmi(
          height: userVitals[i]['heightMeters'].toString(),
          weight: userVitals[i]['weight'].toString());
      finalHeight = doubleFly(userVitals[i]['heightMeters']) ?? finalHeight;
      finalWeight = doubleFly(userVitals[i]['weightKG']) ?? finalWeight;
      if (userVitals[i]['systolic'] != null && userVitals[i]['diastolic'] != null) {
        userVitals[i]['bp'] =
            '${stringify(userVitals[i]['systolic'])}/${stringify(userVitals[i]['diastolic'])}';
      }
      userVitals[i]['weightKGClass'] = userVitals[i]['bmiClass'];
      userVitals[i]['ECGBpmClass'] = userVitals[i]['leadTwoStatus'];
      userVitals[i]['fatRatioClass'] = userVitals[i]['fatClass'];
      userVitals[i]['pulseBpmClass'] = userVitals[i]['pulseClass'];
    }
    prefs.setDouble(SPKeys.weight, finalWeight);
    prefs.setDouble(SPKeys.height, finalHeight);

    //Check which vital
    for (var f in vitalsOnHome) {
      allScores[f] = [];
      allScores['${f}Class'] = [];
      for (int i = 0; i < userVitals.length; i++) {
        if (userVitals[i][f] != '' && userVitals[i][f] != null && userVitals[i][f] != 'N/A') {
          /// round off to nearest 2 decimal 🌊
          if (userVitals[i][f] is double) {
            if (decimalVitals.contains(f)) {
              userVitals[i][f] = (userVitals[i][f] * 100.0).toInt() / 100;
            } else {
              userVitals[i][f] = (userVitals[i][f]).toInt();
            }
          }
          Map mapToAdd = {
            'value': userVitals[i][f],
            'status': userVitals[i]['${f}Class'] == null
                ? 'Unknown'
                : camelize(userVitals[i]['${f}Class']),
            'date': userVitals[i]['dateTimeFormatted'] != null
                ? DateTime.tryParse(userVitals[i]['dateTimeFormatted'].toString())
                : getDateTimeStamp(user['accountCreated']),
            'moreData': {
              'Address': stringify(userVitals[i]['orgAddress']),
              'City': stringify(userVitals[i]['IHLMachineLocation']),
            }
          };
          // processing specific to a vital
          if (f == 'temperature') {
            if (userVitals[i]['Roomtemperature'] != null) {
              userVitals[i]['Roomtemperature'] = doubleFly(userVitals[i]['Roomtemperature']);
              mapToAdd['moreData']['Room Temperature'] =
                  '${stringify((userVitals[i]['Roomtemperature'] * 9 / 5) + 32)} ${vitalsUI['temperature']['unit']}';
            }
            mapToAdd['value'] =
                (((userVitals[i][f] * 900 / 5).toInt()) / 100 + 32).toStringAsFixed(2);
          }
          if (f == 'bp') {
            mapToAdd['moreData']['Systolic'] = userVitals[i]['systolic'].toString();
            mapToAdd['moreData']['Diastolic'] = userVitals[i]['diastolic'].toString();
          }
          if (f == 'protien') {
            mapToAdd['protien'] = userVitals[i]['protien'].toString();
            mapToAdd['status'] = proteinStatus.toString();
          }
          // My code start for showing height
          if (f == 'heightMeters') {
            mapToAdd['heightMeters'] = userVitals[i]['heightMeters'].toString();
            mapToAdd['status'] = proteinStatus.toString();
          }
          // End
          if (f == 'intra_cellular_water') {
            mapToAdd['intra_cellular_water'] = userVitals[i]['intra_cellular_water'].toString();
            mapToAdd['status'] = icwStatus.toString();
          }

          if (f == 'extra_cellular_water') {
            mapToAdd['extra_cellular_water'] = userVitals[i]['extra_cellular_water'].toString();
            mapToAdd['status'] = ecwStatus.toString();
          }

          if (f == 'mineral') {
            mapToAdd['mineral'] = userVitals[i]['mineral'].toString();
            mapToAdd['status'] = mineralStatus.toString();
          }

          if (f == 'skeletal_muscle_mass') {
            mapToAdd['skeletal_muscle_mass'] = userVitals[i]['skeletal_muscle_mass'].toString();
            mapToAdd['status'] = smmStatus.toString();
          }

          if (f == 'body_fat_mass') {
            mapToAdd['body_fat_mass'] = userVitals[i]['body_fat_mass'].toString();
            mapToAdd['status'] = bfmStatus.toString();
          }

          if (f == 'body_cell_mass') {
            mapToAdd['body_cell_mass'] = userVitals[i]['body_cell_mass'].toString();
            mapToAdd['status'] = bcmStatus.toString();
          }

          if (f == 'waist_hip_ratio') {
            mapToAdd['waist_hip_ratio'] = userVitals[i]['waist_hip_ratio'].toString();
            mapToAdd['status'] = waistHipStatus.toString();
          }

          if (f == 'percent_body_fat') {
            mapToAdd['percent_body_fat'] = userVitals[i]['percent_body_fat'].toString();
            mapToAdd['status'] = pbfStatus.toString();
          }

          if (f == 'waist_height_ratio') {
            mapToAdd['waist_height_ratio'] = userVitals[i]['waist_height_ratio'].toString();
            mapToAdd['status'] = waistHeightStatus.toString();
          }

          if (f == 'visceral_fat') {
            mapToAdd['visceral_fat'] = userVitals[i]['visceral_fat'].toString();
            mapToAdd['status'] = vfStatus.toString();
          }

          if (f == 'basal_metabolic_rate') {
            mapToAdd['basal_metabolic_rate'] = userVitals[i]['basal_metabolic_rate'].toString();
            mapToAdd['status'] = bmrStatus.toString();
          }

          if (f == 'bone_mineral_content') {
            mapToAdd['bone_mineral_content'] = userVitals[i]['bone_mineral_content'].toString();
            mapToAdd['status'] = bomcStatus.toString();
          }

          if (f == 'ECGBpm') {
            mapToAdd['graphECG'] = ECGCalc(
              isLeadThree: userVitals[i]['LeadMode'] == 3,
              data1: userVitals[i]['ECGData'],
              data2: userVitals[i]['ECGData2'],
              data3: userVitals[i]['ECGData3'],
            );

            mapToAdd['moreData']['Lead One Status'] = stringify(userVitals[i]['leadOneStatus']);
            mapToAdd['moreData']['Lead Two Status'] = stringify(userVitals[i]['leadTwoStatus']);
            mapToAdd['moreData']['Lead Three Status'] = stringify(userVitals[i]['leadThreeStatus']);
          }
          allScores[f].add(mapToAdd);
          if (!vitalsToShow.contains(f)) {
            vitalsToShow.add(f);
          }
        }
      }
    }
    vitalsToShow.toSet();
    vitalsToShow = vitalsOnHome;

    loading = false;
    if (mounted) {
      setState(() {});
    }
  }

  double doubleFly(k) {
    if (k is num) {
      return k * 1.0;
    }
    if (k is String) {
      return double.tryParse(k);
    }
    return null;
  }

// weekly calorie graph parameters

  List graphDataList = [];
  bool nodata = false;
  int target = 0;
  String tillDate;
  String fromDate;

  void getWeekData() async {
    tillDate = DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10);
    fromDate = DateTime.now().subtract(const Duration(days: 6)).toString().substring(0, 10);
    String tabType = 'weekly';

    graphDataList = await ListApis.getUserFoodLogHistoryApi(
            fromDate: fromDate, tillDate: tillDate, tabType: tabType) ??
        [];
    if (mounted) {
      setState(() {
        if (graphDataList.isEmpty) {
          nodata = true;
        }
        graphDataList;
      });
    }
    // for(int i = 0; i<=graphDataList.length;i++){
    //   if(graphDataList[i].){}
    // }
  }

  getTarget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        target = prefs.getInt('weekly_target');
      });
    }
  }

  List<DailyCalorieData> monthlyChartData = [
    DailyCalorieData(DateTime(2021, 08, 04), 3500),
    DailyCalorieData(DateTime(2021, 08, 03), 3800),
    DailyCalorieData(DateTime(2021, 08, 01), 3400),
  ];

  // monthlyChartData.add(DateTime(2021, 08, 04), 3500)

// weekly calorie graph parameters ends

// Tele-consultant parameters
  String iHLUserId;
  ExpandableController _expandableController;
  bool expanded = true;
  bool hasappointment = false;
  List appointment = [];
  List approvedAppointments;

  // TabController _controller;

  List alist = [];

  // bool loading = true;
  List<String> sharedReportAppIdList = [];

  Future getAppointmentData() async {
    /* SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);

    Map teleConsulResponse = json.decode(data);*/

    // Commented getUserDetails API and instead getting data from SharedPreference

    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    Object data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    iHLUserId = res['User']['id'];
  }

  getSharedAppIdList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedReportAppIdList = prefs.getStringList('sharedReportAppIdList') ?? [];
  }

//Changed to check genix in isapproved and ispending
  DashBoardAppointmentTile getItem(Map map) {
    return DashBoardAppointmentTile(
      ihlConsultantId: map["ihl_consultant_id"],
      name: map["consultant_name"],
      date: map["appointment_start_time"],
      endDateTime: map["appointment_end_time"],
      consultationFees: map['consultation_fees'],
      isApproved:
          map['appointment_status'] == "Approved" || map['appointment_status'] == "Approved",
      isRejected:
          map['appointment_status'] == "rejected" || map['appointment_status'] == "Rejected",
      isPending:
          map['appointment_status'] == "requested" || map['appointment_status'] == "Requested",
      isCancelled:
          map['appointment_status'] == "canceled" || map["appointment_status"] == "Canceled",
      isCompleted:
          map['appointment_status'] == "completed" || map['appointment_status'] == "Completed",
      appointmentId: map['appointment_id'],
      callStatus: map['call_status'] ?? "N/A",
      vendorId: map['vendor_id'],
      sharedReportAppIdList: sharedReportAppIdList,
    );
  }

//  TeleConsultation End

  // heighttile variables
  String height = '';
  String weight = '';
  var bmi;
  String weightfromvitalsData = '';
  bool s;
  bool feet = false;
  String score = '';
  String firstName = '';
  String lastName = '';
  Map vitals = {};
  String IHL_User_ID;
  String selectedSpecality;

  // end heighttile variable
  ListApis listApis = ListApis();

  // heighttile parameters
  Future<void> getHeightWeightData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);
    double finalWeight = prefs.getDouble(SPKeys.weight);
    finalWeight = ((finalWeight ?? 0 * 100.0).toInt()) / 100;
    weightfromvitalsData = finalWeight.toString();
    data = data == null || data == '' ? '{"User":{}}' : data;
    Map res = jsonDecode(data);
    res['User']['user_score'] ??= {};
    res['User']['user_score']['T'] ??= 'N/A';
    score = res['User']['user_score']['T'].toString();
    s = prefs.getBool('allAns');
    firstName = res['User']['firstName'];
    firstName ??= '';
    lastName = res['User']['lastName'];
    lastName ??= '';
    prefs.setString('name', '$firstName $lastName');
    if (res['User']['heightMeters'] is num) {
      height = (res['User']['heightMeters'] * 100).toInt().toString();
    }
    height ??= '';
    if (weightfromvitalsData == null || weightfromvitalsData == 'null') {
      weightfromvitalsData = '';
    }
    if (res.length == 3) {
      if (res['LastCheckin']['weightKG'] != null) {
        weight = ((((res['LastCheckin']['weightKG']) * 100.0).toInt()) / 100).toString() ?? "";
      }
    }
    if (weight == null || weight == '') {
      weight = res['User']['userInputWeightInKG'];
    }

    weight = weight == 'null' ? '' : weight;
    weight ??= '';
    bmi = calcBmiNew(weight: weight.toString(), height: height.toString());
    // userAffiliation = res['User']['affiliate'].toString();
    // userAffiliation = AppTexts.affiliationOp.contains(userAffiliation)
    // ? userAffiliation
    // : 'none';
    //   if (res['LastCheckin'] != null &&
    //       (res['LastCheckin']['weightKG'] != null ||
    //           res['LastCheckin']['weightKG'] != '') &&
    //       res.length == 3) {
    //     showWeight = false;
    //   }
    //   if (email == '' || email == null) {
    //     emailFixed = false;
    //   }
    //   isloading = false;
    //   if (this.mounted) {
    //     this.setState(() {});
    //   }
  }

// end heighttile parameters
// activity data
  void getDailyActivityData() async {
    listApis.getUserTodaysFoodLogHistoryApi().then((value) {
      if (mounted) {
        setState(() {
          todaysActivityData = value['activity'];
          otherActivityData = value['previous_activity'];
        });
      }
    });
  }

  // get bmi value
  void getUserBMIDetails() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    IHL_User_ID = prefs1.getString("ihlUserId");
    selectedSpecality = prefs1.getString("selectedSpecality");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object email = prefs.get('email');
    Object data = prefs.get('data');
    Map res = jsonDecode(data);
    var mobileNumber = res['User']['mobileNumber'];
    String dob = res['User']['dateOfBirth'].toString();
    // var bmi_ =
  }

  // end bmi value

// activity data ends
  StreamingSharedPreferences preferences;
  int dailytarget = 0;
  double newbmi;

  void getBMI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get('data');
    Map res = jsonDecode(data);
    if (mounted) {
      setState(() {
        name = res['User']['firstName'] ?? 'User';
        // newbmi = res['LastCheckin']['bmi'];
      });
    }
  }

  bool hasSubscription = false;

  // List subscriptions = [];
  List approvedSubscriptions;
  List slist = [];

  // Subscription class method

  Future getSubscriptionClassData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userDetailsResponse);

    Map teleConsulResponse = json.decode(data);
    loading = false;
    if (teleConsulResponse['my_subscriptions'] == null ||
        teleConsulResponse['my_subscriptions'] is! List ||
        teleConsulResponse['my_subscriptions'].isEmpty) {
      if (mounted) {
        setState(() {
          hasSubscription = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        subscriptions = teleConsulResponse['my_subscriptions'];
        approvedSubscriptions = subscriptions
            .where((i) =>
                i["approval_status"] == "Approved" ||
                i["approval_status"] == "Accepted" ||
                i["approval_status"] == "Requested" ||
                i["approval_status"] == "requested")
            .toList();
        DateTime currentDateTime = DateTime.now();

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

          DateTime startDate = DateFormat("yyyy-MM-dd").parse(courseStartDuration);
          final DateFormat formatter = DateFormat('yyyy-MM-dd');
          String startDateFormattedToString = formatter.format(startDate);

          DateTime endDate = DateFormat("yyyy-MM-dd").parse(courseEndDuration);
          String endDateFormattedToString = formatter.format(endDate);
          if (courseTimeFromApi[2].toString() == ':' && courseTimeFromApi[13].toString() != ':') {
            String tempcourseEndTime = '';
            courseStartTime = courseTimeFromApi.substring(0, 8);
            for (int i = 0; i < courseTimeFromApi.length; i++) {
              if (i == 10) {
                tempcourseEndTime += '0';
              } else if (i > 10) {
                tempcourseEndTime += courseTimeFromApi[i];
              }
            }
            courseEndTime = tempcourseEndTime;
          } else if (courseTimeFromApi[2].toString() != ':') {
            String tempcourseStartTime = '';
            String tempcourseEndTime = '';

            for (int i = 0; i < courseTimeFromApi.length; i++) {
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
              String tempcourseEndTime = '';
              for (int i = 0; i <= courseEndTime.length; i++) {
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
          String startDateAndTime = "$startDateFormattedToString $startingTime";
          String endDateAndTime = "$endDateFormattedToString $endingTime";
          DateTime finalStartDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
          DateTime finalEndDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);
          if (finalEndDateTime.isAfter(currentDateTime) ||
              approvelStatus == "Cancelled" ||
              approvelStatus == "cancelled") {
            slist.add(approvedSubscriptions[i]);
          }
        }
        hasSubscription = true;
      });
    }
  }

  DashBoardSubscriptionTile getSubscriptionClassItem(Map map) {
    return DashBoardSubscriptionTile(
        subscription_id: map["subscription_id"],
        trainerId: map["consultant_id"],
        trainerName: map["consultant_name"],
        title: map["title"],
        duration: map["course_duration"],
        time: map["course_time"],
        provider: map['provider'],
        isApproved: map['approval_status'] == "Accepted",
        isRejected: map['approval_status'] == "Rejected",
        isRequested: map['approval_status'] == "Requested" || map['approval_status'] == 'requested',
        isCancelled: map['approval_status'] == "Cancelled" || map['approval_status'] == 'cancelled',
        courseOn: map['course_on'],
        courseTime: map['course_time'],
        courseId: map['course_id']);
  }

  @override
  void initState() {
    _initAsync();
    init();
    surveybmiCalc();
    getWeekData();
    getTarget();
    getBMI();
    getEventDetails();
    super.initState();
    getData();
    getUserBMIDetails();
    getSubscriptionClassListData();
    getDailyActivityData();
    getAppointmentData();
    getHeightWeightData();
    getSharedAppIdList();
    getSubscriptionClassData();
    getExpiredSubscriptionHistoryData();
    getAppointmentHistoryData();
    // getUserDetails();

    _expandableController = ExpandableController(
      initialExpanded: true,
    );
    _expandableController.addListener(() {
      if (mounted) {
        setState(() {
          expanded = _expandableController.expanded;
        });
      }
    });
  }

  ///variable and funciton for event details///start=>
  List eventDetailList;
  var userEnrolledMap;

  getEventDetails() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    Object data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHL_User_Id = res['User']['id'];
    // eventDetailList = await eventDetailApi();
    // userEnrolledMap = await isUserEnrolledApi(ihl_user_id: iHL_User_Id,event_id: eventDetailList[0]['event_id']);

    // eventDetailApi().then((value) async{
    eventDetailList = await eventDetailApi();

    if (eventDetailList != null) {
      // isUserEnrolledApi(ihl_user_id: iHL_User_Id,event_id: eventDetailList[0]['event_id']).then((v){
      userEnrolledMap = await isUserEnrolledApi(
          ihl_user_id: iHL_User_Id, event_id: eventDetailList[0]['event_id']);
      // });
      if (mounted) {
        setState(() {});
      }
    }

    // });
  }

// consultation history functions starts
// counsultation history functions ends
  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    StreamingSharedPreferences.instance.then((StreamingSharedPreferences value) {
      if (mounted) {
        setState(() {
          preferences = value;
        });
      }
    });
    dailyTarget().then((String value) {
      if (mounted) {
        setState(() {
          dailytarget = int.parse(value);
          prefs.setInt('daily_target', dailytarget);
          prefs.setInt('weekly_target', dailytarget * 7);
          prefs.setInt('monthly_target', dailytarget * daysInMonth(DateTime.now()));
        });
      }
    });
  }

  Future<String> dailyTarget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dailyTarget = prefs.getInt('daily_target');
    if (dailyTarget == null || dailyTarget == 0) {
      Object userData = prefs.get('data');
      preferences.setBool('maintain_weight', true);
      Map res = jsonDecode(userData);
      String height;
      DateTime birthDate;
      String datePattern = "MM/dd/yyyy";
      String dob = res['User']['dateOfBirth'].toString();
      DateTime today = DateTime.now();
      try {
        birthDate = DateFormat(datePattern).parse(dob);
      } catch (e) {
        birthDate = DateFormat('MM-dd-yyyy').parse(dob);
      }
      int age = today.year - birthDate.year;
      if (res['User']['heightMeters'] is num) {
        height = (res['User']['heightMeters'] * 100).toInt().toString();
      }
      var weight = res['User']['userInputWeightInKG'] ?? '0';
      if (weight == '') {
        weight = prefs.get('userLatestWeight').toString();
      }
      var m = res['User']['gender'];
      num maleBmr =
          (10 * double.parse(weight.toString()) + 6.25 * double.parse(height) - (5 * age) + 5);
      num femaleBmr = (10 * double.parse(weight) + 6.25 * double.parse(height) - (5 * age) - 161);
      return (m == 'm' || m == 'M' || m == 'male' || m == 'Male')
          ? maleBmr.toStringAsFixed(0)
          : femaleBmr.toStringAsFixed(0);
    } else {
      bool maintainWeight = prefs.getBool('maintain_weight');
      if (maintainWeight == null) {
        preferences.setBool('maintain_weight', true);
      }
      return dailyTarget.toString();
    }
  }

  int daysInMonth(DateTime date) {
    DateTime firstDayThisMonth = DateTime(date.year, date.month, date.day);
    DateTime firstDayNextMonth =
        DateTime(firstDayThisMonth.year, firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  String heightft() {
    double h = double.tryParse(height);
    if (h == null) {
      return '';
    }
    return cmToFeetInch(h.toInt());
  }

  final String iHLUrl = API.iHLUrl;
  final String ihlToken = API.ihlToken;

  String jointAccUserName, jointAccUserID;

  void _initAsync() async {
    await SpUtil.getInstance();
    String email = SpUtil.getString('email');
    String pwd = SpUtil.getString('password');
    authenticate(email, pwd);
  }

  String apiToken;

  // ignore: missing_return
  Future authenticate(String email, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String careTakerDetails = prefs.getString('data');

    var decodedResponse = jsonDecode(careTakerDetails);

    String iHLUserToken = decodedResponse['Token'];

    String iHLUserId = decodedResponse['User']['id'];
    var jointAccountUserDetails = decodedResponse['User']['joint_user_detail_list'];

    jointAccUserID = jointAccountUserDetails['joint_user1']['ihl_user_id'];
    jointAccUserName = jointAccountUserDetails['joint_user1']['ihl_user_name'];

    String authToken = SpUtil.getString('auth_token');
    final http.Response response = await _client.post(
      Uri.parse('$iHLUrl/login/qlogin2'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      if (response.body == 'null') {
        return 'Login failed';
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('data', response.body);
        prefs.setString('password', password);
        prefs.setString('email', email);
        localSotrage.write(LSKeys.email, email);

        var decodedResponse = jsonDecode(response.body);

        String iHLUserToken = decodedResponse['Token'];

        String iHLUserId = decodedResponse['User']['id'];
        var jointAccountUserDetails = decodedResponse['User']['joint_user_detail_list'];

        jointAccUserID = jointAccountUserDetails['joint_user1']['ihl_user_id'];
        jointAccUserName = jointAccountUserDetails['joint_user1']['ihl_user_name'];

        final http.Response auth_response = await _client.get(
          // joint account Authentication URL
          Uri.parse('$iHLUrl/login/kioskLogin?id=2936'),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
          // headers: {'ApiToken': ihlToken},
        );
        if (auth_response.statusCode == 200) {
          JointAccountSignup reponseToken =
              JointAccountSignup.fromJson(json.decode(auth_response.body));
          apiToken = reponseToken.apiToken;
          final http.Response JointUserResponse = await _client.post(
            Uri.parse('$iHLUrl/login/get_user_login'),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
            // headers: {
            //   'Content-Type': 'application/json',
            //   // 'ApiToken': apikey,
            //   'ApiToken': apiToken,
            //   // 'Token': guestUserToken
            //   // 'ApiToken':
            //   //     "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
            // },
            body: jsonEncode(<String, String>{
              'id': jointAccUserID,
            }),
          );
          if (JointUserResponse.statusCode == 200) {
          } else {
            return throw Exception('failed');
          }
        }
      }
    } else {
      throw Exception('Authorization Failed');
    }
  }

  bool userLoginSuccess = false;
  bool isLoading = false;
  bool isPwdCorrect;
  bool vitalDataExists = false;

  // switch account starts

  Future switchAccounts(String jointAccUserID) async {
    // final prefs = await SharedPreferences.getInstance();

    // var careTakerDetails = prefs.getString('data');
    // var authToken = prefs.get(SPKeys.authToken);
    // var decodedResponse = jsonDecode(careTakerDetails);
    // print(decodedResponse);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object password = prefs.get(SPKeys.password);
    Object email = prefs.get(SPKeys.email);
    Object authToken = prefs.get(SPKeys.authToken);

    final http.Response response1 = await _client.post(
      Uri.parse('${API.iHLUrl}/login/qlogin2'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    if (response1.statusCode == 200) {
      if (response1.body == 'null') {
        // logOut(deepLink: deepLink);
        return;
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(SPKeys.userData, response1.body);
        prefs.setString(SPKeys.password, password);
        prefs.setString(SPKeys.email, email);
        var decodedResponse = jsonDecode(response1.body);
        String iHLUserToken = decodedResponse['Token'];
        String iHLUserId = decodedResponse['User']['id'];
        bool introDone = decodedResponse['User']['introDone'];

        // String iHLUserToken = decodedResponse['Token'];

        // String iHLUserId = decodedResponse['User']['id'];
        var jointAccountUserDetails = decodedResponse['User']['joint_user_detail_list'];

        jointAccUserID = jointAccountUserDetails['joint_user1']['ihl_user_id'];
        jointAccUserName = jointAccountUserDetails['joint_user1']['ihl_user_name'];
      }
    }
    // joint acc api starts

    final http.Response JointUserResponse = await _client.post(
      Uri.parse('$iHLUrl/login/get_user_login'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      // headers: {
      //   'Content-Type': 'application/json',
      //   // 'ApiToken': apikey,
      //   'ApiToken': authToken,
      //   // 'Token': guestUserToken
      //   // 'ApiToken':
      //   //     "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
      // },
      body: jsonEncode(<String, String>{
        'id': jointAccUserID,
      }),
    );

    if (JointUserResponse.statusCode == 200) {
      if (JointUserResponse.body == 'null') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('data', '');

        if (mounted) {
          setState(() {
            userLoginSuccess = false;
            // isPwdCorrect = false;
            isLoading = false;
          });
        }

        return userLoginSuccess;
      } else {
        if (mounted) {
          setState(() {
            // isPwdCorrect = true;
            userLoginSuccess = true;
          });
        }
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('data', JointUserResponse.body);
        prefs.setString('ihl_user_id', jointAccUserID);
        // prefs.setString('email', email);
        var decodedResponse = jsonDecode(JointUserResponse.body);
        String jointAccUserToken = decodedResponse['Token'];
        String iHLUserId = decodedResponse['User']['id'];

        bool introDone = decodedResponse['User']['introDone'];
        bool isJointAccount = decodedResponse['User']['care_taker_details_list']['caretaker_user1']
            ['is_joint_account'];
        SharedPreferences prefs1 = await SharedPreferences.getInstance();
        prefs1.setString("ihlUserId", jointAccUserID);

        final http.Response getPlatformData = await _client.post(
          Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
          body: jsonEncode(<String, dynamic>{"ihl_id": jointAccUserID, 'cache': "true"}),
        );
        if (getPlatformData.statusCode == 200) {
          final SharedPreferences platformData = await SharedPreferences.getInstance();
          platformData.setString(SPKeys.platformData, getPlatformData.body);
        }

        final http.Response vitalData = await _client.get(
          Uri.parse('$iHLUrl/data/user/$jointAccUserID/checkin'),
          headers: {
            'Content-Type': 'application/json',
            'Token': jointAccUserToken,
            'ApiToken': apiToken
          },
        );
        if (vitalData.statusCode == 200) {
          vitalDataExists = true;
          final SharedPreferences sharedUserVitalData = await SharedPreferences.getInstance();
          sharedUserVitalData.setString('userVitalData', vitalData.body);
          vitalDataExists = true;
          prefs.setString('disclaimer', 'no');
          prefs.setString('refund', 'no');
          prefs.setString('terms', 'no');
          prefs.setString('grievance', 'no');
          prefs.setString('privacy', 'no');
        } else {
          vitalDataExists = false;
          throw Exception('No Vital Data for this user');
        }
        if (mounted) {
          setState(() {
            const CircularProgressIndicator();
            isLoading = false;
            if (widget.deepLink == true) {
              Get.offNamedUntil(
                  Routes.MyAppointments, (Route route) => Get.currentRoute == Routes.Home);
            } else {
              Get.to(LandingPage());
            }
          });
        }
        return userLoginSuccess;
      }
    }
  }

  // switch account ends

  Widget linkedUsersWidget({String subtitle, title, Widget icon, VoidCallback onTap}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Divider(),
        ListTile(
          // minVerticalPadding: 2,
          // contentPadding: EdgeInsets.symmetric(horizontal: 50.0),
          leading: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: Colors.white),
            // height: 45,
            // width: 42,
            width: ScUtil().setWidth(40),
            height: ScUtil().setHeight(35),
            child:
                // CircleAvatar(
                //   radius: 50.0,
                //   backgroundImage:
                //       image == null ? null : image.image,
                //   backgroundColor: AppColors.primaryAccentColor,
                // ),

                Image.asset('assets/images/newfdc.png'),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Text(
              jointAccUserName,
              style: TextStyle(
                  // fontSize: 16.0,
                  fontSize: ScUtil().setSp(13),
                  fontWeight: FontWeight.w600,
                  color: Colors.blue),
            ),
          ),
          subtitle: Text(
            jointAccUserID,
            style: TextStyle(
              color: AppColors.primaryAccentColor,
              fontSize: ScUtil().setSp(11),
            ),
          ),

          onTap: () {
            // switchAccounts(jointAccUserID);
          },
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var difference;
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      width = 500;
    }
    if (loading && isJointAccount) {
      return SafeArea(
        child: Container(
          color: AppColors.bgColorTab,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: TextButton(
                      onPressed: () {
                        widget.openDrawer();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                      ),
                      child: Icon(
                        Icons.menu,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      );
    }

    if (!isVerified) {
      return SafeArea(
        child: Container(
          color: AppColors.bgColorTab,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: TextButton(
                      onPressed: () {
                        widget.openDrawer();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                      ),
                      child: Icon(
                        Icons.menu,
                        size: 30,
                        color: AppColors.primaryAccentColor,
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 100,
                      color: AppColors.lightTextColor,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(AppTexts.updateProfile, style: TextStyle(color: Colors.blue)),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        // backgroundColor: AppColors.primaryAccentColor,
                        textStyle: const TextStyle(color: Colors.blue),
                      ),
                      child: const Text(AppTexts.visitProfile),
                      onPressed: () {
                        widget.goToProfile();
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      // first container
      child: Container(
        // color: Color.fromRGBO(216, 227, 246, 1),
        color: AppColors.primaryAccentColor.withOpacity(0.8),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          // second container
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(7),
              // third container
              child: Column(
                children: [
                  // menu bar and user name starts
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 60,
                          child: TextButton(
                            onPressed: () {
                              widget.openDrawer();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0),
                            ),
                            child: Icon(
                              Icons.menu,
                              size: 30,
                              color: Color.fromRGBO(24, 31, 57, 1),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Hello!!!' ' ' + firstName,
                                  style: TextStyle(
                                    color: const Color.fromRGBO(24, 31, 57, 1),
                                    fontSize: ScUtil().setSp(17),
                                    // height: 5.0,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // profile pic starts
                        IconButton(
                          onPressed: () {
                            // AwesomeDialog(
                            //         // showCloseIcon: true,
                            //         // closeIcon: Icon(Icons.close_rounded),
                            //         customHeader:
                            //             Icon(Icons.person, size: 50.0),
                            //         context: context,
                            //         animType: AnimType.RIGHSLIDE,
                            //         headerAnimationLoop: true,
                            //         dialogType: DialogType.INFO,
                            //         dismissOnTouchOutside: true,
                            //         body: Column(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.spaceEvenly,
                            //           children: [
                            //             Container(
                            //               // decoration: BoxDecoration(
                            //               //   border: Border.all(width: 1.0),
                            //               //   borderRadius:
                            //               //       BorderRadius.circular(1.0),
                            //               //   color: Colors.white,
                            //               // ),
                            //               child: Padding(
                            //                 padding: const EdgeInsets.all(5.0),
                            //                 child: Text(
                            //                   'Switch to Other Accounts',
                            //                   style: TextStyle(
                            //                     fontFamily:
                            //                         FitnessAppTheme.fontName,
                            //                     fontWeight: FontWeight.w600,
                            //                     fontSize: ScUtil().setSp(15),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //             SizedBox(
                            //               height: ScUtil().setHeight(10.0),
                            //             ),
                            //             jointAccUserName == null &&
                            //                     jointAccUserID == null
                            //                 ? Container(
                            //                     height:
                            //                         ScUtil().setHeight(50.0),
                            //                     width: ScUtil().setWidth(190.0),
                            //                     child: Card(
                            //                       color: AppColors.cardColor,
                            //                       child: Center(
                            //                         child: Text(
                            //                           'No Account is linked',
                            //                           textAlign:
                            //                               TextAlign.center,
                            //                           style: TextStyle(
                            //                             fontFamily:
                            //                                 FitnessAppTheme
                            //                                     .fontName,
                            //                             fontWeight:
                            //                                 FontWeight.w600,
                            //                             fontSize:
                            //                                 ScUtil().setSp(15),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   )
                            //                 : Container(
                            //                     height:
                            //                         ScUtil().setHeight(150.0),
                            //                     width: ScUtil().setWidth(315.0),
                            //                     // height: MediaQuery.of(context).size.height / 4.2,
                            //                     // width: MediaQuery.of(context).size.width / 1.21,
                            //                     child: Card(
                            //                       color: AppColors.cardColor,
                            //                       elevation: 2.0,
                            //                       child: ListView.builder(
                            //                         itemCount: 1,
                            //                         itemBuilder:
                            //                             (context, index) {
                            //                           return linkedUsersWidget();

                            //                           // linkedUsersWidget(
                            //                           //     title:
                            //                           //         jointAccUserName ?? '',
                            //                           //     subtitle:
                            //                           //         jointAccUserID ?? '');
                            //                         },
                            //                       ),
                            //                     ),
                            //                   ),
                            //           ],
                            //         ),
                            //         // title: 'Success!',
                            //         // desc:
                            //         //     'Your Profile was successfully registered in IHL',
                            //         btnOkOnPress: () {
                            //           Get.to(
                            //             JointAccount(),
                            //           );
                            //           debugPrint(
                            //               'Dialog Dissmiss from callback');
                            //           debugPrint('OnClcik');
                            //         },
                            //         btnOkText: 'Add New Account',
                            //         btnOkIcon: Icons.person_add,
                            //         onDismissCallback: (_) {
                            //           // Navigator.pop(context);
                            //         })
                            //     .show();
                            Navigator.of(context).pushNamed(Routes.Profile, arguments: false);
                          },
                          icon: const Icon(Icons.person_outline_rounded),
                        )
                        // profile pic ends
                      ],
                    ),
                  ),
                  // menu bar and user name ends
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Color.fromRGBO(244, 245, 252, 1),
                      ),
                      // 1 main column
                      child: SingleChildScrollView(
                        // physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              height: 8.0,
                            ),
                            // Marathon heading starts
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: SizedBox(
                                // color: Colors.amber,
                                height: MediaQuery.of(context).size.height / 36,
                                width: MediaQuery.of(context).size.width / 1.35,

                                child: Text(
                                  '   Events ',
                                  // textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: ScUtil().setSp(15),
                                    // letterSpacing: -1,
                                    // color: AppColors.textitemTitleColor,
                                    // color: Color.fromRGBO(166, 167, 187, 1),
                                    color: const Color.fromRGBO(
                                      132,
                                      132,
                                      160,
                                      1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Marathon headin ends
                            // Marathon Section starts
                            SizedBox(height: ScUtil().setHeight(10)),
                            // IconButton(
                            //   icon:Icon(Icons.add,
                            //
                            //   ),
                            //   onPressed: (){
                            //     Get.to(
                            //       MarathonDetails( indexed:0,
                            //         img: eventDetailList[0]['event_image'].toString(),
                            //         description: eventDetailList[0]['event_description'].toString(),
                            //         name: eventDetailList[0]['event_name'].toString()+' by ' +
                            //             eventDetailList[0]['event_host'].toString(),
                            //         start: false,
                            //         eventDetailList: eventDetailList,
                            //         userEnrolledMap: userEnrolledMap,
                            //
                            //       ),
                            //     );
                            //     // Get.to(UserRegister(
                            //     //   eventDetailList: eventDetailList,
                            //     // ));
                            //   },
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Center(
                                child: Container(
                                  // width: MediaQuery.of(context).size.width,
                                  // width: ScUtil().setWidth(width),
                                  // height: ScUtil().setHeight(195),
                                  child: eventDetailList != null && userEnrolledMap != null
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: eventDetailList.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return MarathonCard(
                                              eventDetailList: eventDetailList,
                                              userEnrolledMap: userEnrolledMap,
                                              indexx: index,
                                            );
                                          })
                                      : Column(
                                          children: [
                                            Lottie.network(
                                                "https://assets8.lottiefiles.com/packages/lf20_zjrmnlsu.json",
                                                height: ScUtil().setHeight(155)),
                                            Text("Loading...",
                                                style: TextStyle(
                                                    fontSize: ScUtil().setSp(10),
                                                    fontWeight: FontWeight.w600))
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            // Marathon section ends
                            SizedBox(height: ScUtil().setHeight(12)),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Container(
                                // color: Colors.green,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        // consultation history starts
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            // upcoming heading container starts
                                            Padding(
                                              padding: const EdgeInsets.only(left: 14.0),
                                              child: SizedBox(
                                                // color: Colors.amber,
                                                // height: MediaQuery.of(context)
                                                //         .size
                                                //         .height /
                                                //     36,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width /
                                                //     1.35,
                                                width: ScUtil().setWidth(105),
                                                height: ScUtil().setHeight(20),
                                                child: Text(
                                                  'Appointments',
                                                  // textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontFamily: FitnessAppTheme.fontName,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: ScUtil().setSp(15),
                                                    // letterSpacing: -1,
                                                    // color: AppColors.textitemTitleColor,
                                                    // color: Color.fromRGBO(166, 167, 187, 1),
                                                    color: const Color.fromRGBO(
                                                      132,
                                                      132,
                                                      160,
                                                      1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // upcoming heading container ends
                                            SizedBox(height: ScUtil().setHeight(0)),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(26)),
                                                child: (alist.isEmpty)
                                                    ? SizedBox(
                                                        // height: MediaQuery.of(context).size.height / 4.1,
                                                        // width: MediaQuery.of(context).size.width / 1.24,
                                                        width: ScUtil().setWidth(290),
                                                        // height: ScUtil()
                                                        //     .setHeight(200),
                                                        child: Card(
                                                          shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(
                                                              Radius.circular(20),
                                                            ),
                                                          ),
                                                          color: const Color.fromRGBO(
                                                              35, 107, 254, 0.8),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(20),
                                                              gradient: LinearGradient(
                                                                begin: Alignment.bottomCenter,
                                                                end: Alignment.topCenter,
                                                                colors: [
                                                                  Colors.indigo[900],
                                                                  //Colors.lightBlue,
                                                                  Colors.blue,
                                                                ],
                                                                stops: const [0.0, 1.0],
                                                                tileMode: TileMode.clamp,
                                                              ),
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.spaceEvenly,
                                                              children: [
                                                                SizedBox(
                                                                  height: ScUtil().setHeight(18),
                                                                ),
                                                                Text(
                                                                  "No Upcoming Appointments!",
                                                                  style: TextStyle(
                                                                      fontSize: ScUtil().setSp(12),
                                                                      letterSpacing: 1.5,
                                                                      color: Colors.white,
                                                                      fontWeight: FontWeight.w600),
                                                                ),
                                                                SizedBox(
                                                                  height: ScUtil().setHeight(58),
                                                                ),
                                                                TextButton(
                                                                  style: ButtonStyle(
                                                                    backgroundColor:
                                                                        MaterialStateProperty.all<
                                                                            Color>(
                                                                      Colors.white.withOpacity(1),
                                                                    ),
                                                                    shape:
                                                                        MaterialStateProperty.all<
                                                                            RoundedRectangleBorder>(
                                                                      RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                18.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.of(context).pushNamed(
                                                                        Routes.ConsultationType,
                                                                        arguments: false);
                                                                  },
                                                                  child: Text(
                                                                    'Book Appointment',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            ScUtil().setSp(12),
                                                                        color: Colors.blue,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: ScUtil().setHeight(18),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    // appointment completed history starts
                                                    // Container(
                                                    //     // height: 160,
                                                    //     height: MediaQuery.of(
                                                    //                 context)
                                                    //             .size
                                                    //             .height /
                                                    //         3.5,
                                                    //     child:
                                                    //         completed_appointmentDetails
                                                    //                 .isEmpty
                                                    //             ? Center(
                                                    //                 child:
                                                    //                     Column(
                                                    //                   mainAxisAlignment:
                                                    //                       MainAxisAlignment.center,
                                                    //                   children: [
                                                    //                     Text('Please Wait.....',
                                                    //                         style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.w600)),
                                                    //                     CircularProgressIndicator(color: Colors.white),
                                                    //                   ],
                                                    //                 ),
                                                    //               )
                                                    //             : Container(
                                                    //                 child:
                                                    //                     Column(
                                                    //                   children: [
                                                    //                     ListTile(
                                                    //                       contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                                                    //                       title: Padding(
                                                    //                         padding: const EdgeInsets.only(bottom: 5.0),
                                                    //                         child: Text(
                                                    //                           completed_appointmentDetails[3]['consultant_name'].toString(),
                                                    //                           style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.white),
                                                    //                         ),
                                                    //                       ),
                                                    //                       subtitle: Text(
                                                    //                         'Status:  ' + completed_appointmentDetails[3]['appointment_status'].toString(),
                                                    //                         style: TextStyle(fontSize: 16.0, color: Colors.white),
                                                    //                       ),
                                                    //                       leading: Container(
                                                    //                         decoration: BoxDecoration(
                                                    //                             borderRadius: BorderRadius.only(
                                                    //                               topLeft: Radius.circular(10.0),
                                                    //                               topRight: Radius.circular(10.0),
                                                    //                               bottomLeft: Radius.circular(10.0),
                                                    //                               bottomRight: Radius.circular(10.0),
                                                    //                             ),
                                                    //                             color: Colors.white),
                                                    //                         height: 45,
                                                    //                         width: 45,
                                                    //                         child:
                                                    //                             // CircleAvatar(
                                                    //                             //   // radius: 60.0,
                                                    //                             //   backgroundImage: imageCourse == null
                                                    //                             //       ? null
                                                    //                             //       : imageCourse.image,
                                                    //                             // widget.consultant['course_img_url'] == null
                                                    //                             //     ? null
                                                    //                             //     : Image.memory(base64Decode(
                                                    //                             //             widget.consultant['course_img_url']))
                                                    //                             //         .image,
                                                    //                             // backgroundColor: AppColors.primaryAccentColor,
                                                    //                             // ),
                                                    //                             Padding(
                                                    //                           padding: const EdgeInsets.all(4),
                                                    //                           child: Image.asset(
                                                    //                             'assets/images/newfdc.png',
                                                    //                             fit: BoxFit.fitHeight,
                                                    //                           ),
                                                    //                         ),
                                                    //                       ),
                                                    //                       trailing: Padding(
                                                    //                         padding: const EdgeInsets.only(bottom: 18.0),
                                                    //                         child: PopupMenuButton<String>(
                                                    //                           // color: Colors.white,
                                                    //                           icon: Icon(
                                                    //                             Icons.more_vert,
                                                    //                             color: Colors.white,
                                                    //                           ),
                                                    //                           onSelected: (k) async {
                                                    //                             Navigator.of(context).pushNamed(Routes.ConsultationType, arguments: false);
                                                    //                           },
                                                    //                           itemBuilder: (context) {
                                                    //                             return [
                                                    //                               PopupMenuItem(
                                                    //                                 value: 'Book Appointments',
                                                    //                                 child: Row(
                                                    //                                   children: [
                                                    //                                     Icon(
                                                    //                                       Icons.book_outlined,
                                                    //                                       color: AppColors.primaryColor,
                                                    //                                     ),
                                                    //                                     SizedBox(
                                                    //                                       width: 4,
                                                    //                                     ),
                                                    //                                     Text('Book Appointments'),
                                                    //                                   ],
                                                    //                                 ),
                                                    //                               ),
                                                    //                             ];
                                                    //                           },
                                                    //                         ),
                                                    //                       ),
                                                    //                     ),
                                                    //                     SizedBox(
                                                    //                       height: MediaQuery.of(context).size.height / 75,
                                                    //                     ),
                                                    //                     Padding(
                                                    //                       padding: const EdgeInsets.symmetric(horizontal: 17.0),
                                                    //                       child: Row(
                                                    //                         // crossAxisAlignment: CrossAxisAlignment.center,
                                                    //                         mainAxisAlignment: MainAxisAlignment.start,
                                                    //                         children: [
                                                    //                           Container(
                                                    //                             child: Icon(
                                                    //                               Icons.animation,
                                                    //                               color: Colors.white,
                                                    //                               size: 15.0,
                                                    //                             ),
                                                    //                           ),
                                                    //                           SizedBox(
                                                    //                             width: 5.0,
                                                    //                           ),
                                                    //                           Text(
                                                    //                             completed_appointmentDetails[3]['booked_date_time'].toString(),
                                                    //                             style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.w600),
                                                    //                           ),
                                                    //                           SizedBox(
                                                    //                             width: 22.0,
                                                    //                           ),
                                                    //                           Container(
                                                    //                             child: Icon(
                                                    //                               Icons.timer,
                                                    //                               color: Colors.white,
                                                    //                               size: 15.0,
                                                    //                             ),
                                                    //                           ),
                                                    //                           SizedBox(
                                                    //                             width: 5.0,
                                                    //                           ),
                                                    //                           Text(
                                                    //                             completed_appointmentDetails[3]['appointment_duration'].toString(),
                                                    //                             style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.w600),
                                                    //                           ),
                                                    //                         ],
                                                    //                       ),
                                                    //                     ),
                                                    //                     SizedBox(
                                                    //                       height: 25,
                                                    //                     ),
                                                    //                     ElevatedButton(
                                                    //                       style: ElevatedButton.styleFrom(
                                                    //                           shape: RoundedRectangleBorder(
                                                    //                             borderRadius: BorderRadius.circular(10.0),
                                                    //                           ),
                                                    //                           primary: Colors.white,
                                                    //                           textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                    //                       onPressed: () {
                                                    //                         Navigator.of(context).pushNamed(Routes.ConsultationHistory);
                                                    //                       },
                                                    //                       child: Text('More History', style: TextStyle(color: Colors.blueAccent)),
                                                    //                     )
                                                    //                   ],
                                                    //                 ),
                                                    //               ),
                                                    //   )
                                                    // appointment completed history starts
                                                    : Container(
                                                        // height:
                                                        //     MediaQuery.of(context).size.height /
                                                        //         3,
                                                        // width: MediaQuery.of(context).size.width /
                                                        //     1.17,
                                                        child: getItem(alist[0]),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // consultation history ends
                                        SizedBox(
                                          width: ScUtil().setWidth(3),
                                        ),
                                        // My Fitness class starts
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              // color: Colors.amber,
                                              // height: MediaQuery.of(context)
                                              //         .size
                                              //         .height /
                                              //     36,
                                              // width: MediaQuery.of(context)
                                              //         .size
                                              //         .width /
                                              //     1.35,
                                              width: ScUtil().setWidth(270),
                                              height: ScUtil().setHeight(20),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Glance at your classes',
                                                    // textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontFamily: FitnessAppTheme.fontName,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: ScUtil().setSp(15),
                                                      // letterSpacing: -1,
                                                      // color: AppColors.textitemTitleColor,
                                                      // color: Color.fromRGBO(166, 167, 187, 1),
                                                      color: const Color.fromRGBO(
                                                        132,
                                                        132,
                                                        160,
                                                        1,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (BuildContext context) =>
                                                                  WellnessCart()),
                                                          (Route<dynamic> route) => false);
                                                    },
                                                    child: Text(
                                                      'More',
                                                      // textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontFamily: FitnessAppTheme.fontName,
                                                          fontWeight: FontWeight.w900,
                                                          fontSize: ScUtil().setSp(14),
                                                          // letterSpacing: 1,
                                                          // color: color ?? AppColors.primaryColor,
                                                          color: const Color.fromRGBO(
                                                              77, 122, 209, 1)),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: ScUtil().setHeight(2)),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 4.0),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(25)),
                                                child: (slist.isEmpty || hasSubscription == false)
                                                    ? Container(
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              // height: MediaQuery.of(context).size.height / 4.1,
                                                              // width: MediaQuery.of(context).size.width / 1.24,
                                                              width: ScUtil().setWidth(280),
                                                              // height: ScUtil()
                                                              //     .setHeight(
                                                              //         170),
                                                              child: Card(
                                                                shape: const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.all(
                                                                    Radius.circular(25),
                                                                  ),
                                                                ),
                                                                color: const Color.fromRGBO(
                                                                    35, 107, 254, 0.8),
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(25),
                                                                    gradient: LinearGradient(
                                                                      begin: Alignment.bottomCenter,
                                                                      end: Alignment.topCenter,
                                                                      colors: [
                                                                        Colors.grey[900],
                                                                        //Colors.lightBlue,
                                                                        Colors.red[900],
                                                                      ],
                                                                      stops: const [0.0, 1.0],
                                                                      tileMode: TileMode.clamp,
                                                                    ),
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      SizedBox(
                                                                        height:
                                                                            ScUtil().setHeight(18),
                                                                      ),
                                                                      Text(
                                                                        "No Upcoming Classes!",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                ScUtil().setSp(12),
                                                                            letterSpacing: 1.5,
                                                                            color: Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            ScUtil().setHeight(58),
                                                                      ),
                                                                      TextButton(
                                                                        style: ButtonStyle(
                                                                          backgroundColor:
                                                                              MaterialStateProperty
                                                                                  .all<Color>(
                                                                            Colors.white
                                                                                .withOpacity(1),
                                                                          ),
                                                                          shape: MaterialStateProperty
                                                                              .all<
                                                                                  RoundedRectangleBorder>(
                                                                            RoundedRectangleBorder(
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(
                                                                                          18.0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        onPressed: () {
                                                                          // Navigator.of(context).pushNamed(
                                                                          //     Routes.WellnessCart,
                                                                          //     arguments: false);
                                                                          Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (BuildContext
                                                                                      context) =>
                                                                                  SpecialityTypeScreen(
                                                                                      arg:
                                                                                          fitnessClassSpecialties),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Text(
                                                                          'Start a New Class',
                                                                          style: TextStyle(
                                                                              fontSize: ScUtil()
                                                                                  .setSp(12),
                                                                              color: Colors.blue,
                                                                              fontWeight:
                                                                                  FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            ScUtil().setHeight(15),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    // Padding(
                                                    //     padding:
                                                    //         const EdgeInsets
                                                    //                 .only(
                                                    //             bottom:
                                                    //                 0.0),
                                                    //     child: Column(
                                                    //       mainAxisAlignment:
                                                    //           MainAxisAlignment
                                                    //               .spaceEvenly,
                                                    //       children: [
                                                    //         SizedBox(
                                                    //           height: 2.0,
                                                    //         ),
                                                    //         Container(
                                                    //           child: getExpiredSubscriptionItem(
                                                    //               elist[elist
                                                    //                       .length -
                                                    //                   1]),
                                                    //         )
                                                    //       ],
                                                    //     ),
                                                    //   )

                                                    : Container(
                                                        // height:
                                                        //     MediaQuery.of(context).size.height /
                                                        //         3,
                                                        // width: MediaQuery.of(context).size.width /
                                                        //     1.17,
                                                        child: getSubscriptionClassItem(slist[0]),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // My Fitness class ends
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Tele Consultation ends
                            SizedBox(height: ScUtil().setHeight(5)),
                            // Health journal starts
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Container(
                                // height:
                                //     MediaQuery.of(context).size.height / 2.99,
                                // width: MediaQuery.of(context).size.width / 1.12,
                                // width: ScUtil().setWidth(320),
                                // height: ScUtil().setHeight(250),
                                // color: Colors.green,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              // calorie Heading container starts
                                              SizedBox(
                                                // color: Colors.white,
                                                // height: MediaQuery.of(context)
                                                //         .size
                                                //         .height /
                                                //     30,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width /
                                                //     1.35,
                                                width: ScUtil().setWidth(280),
                                                height: ScUtil().setHeight(20),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Glance at your calories',
                                                      // textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontFamily: FitnessAppTheme.fontName,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: ScUtil().setSp(15),
                                                        // letterSpacing: -1,
                                                        // color: AppColors.textitemTitleColor,
                                                        // color: Color.fromRGBO(166, 167, 187, 1),
                                                        color: const Color.fromRGBO(
                                                          132,
                                                          132,
                                                          160,
                                                          1,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (BuildContext context) =>
                                                                    DietJournal()),
                                                            (Route<dynamic> route) => false);
                                                      },
                                                      child: Text(
                                                        'More',
                                                        // textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                            fontFamily: FitnessAppTheme.fontName,
                                                            fontWeight: FontWeight.w900,
                                                            fontSize: ScUtil().setSp(14),
                                                            // letterSpacing: 1,
                                                            // color: color ?? AppColors.primaryColor,
                                                            color: const Color.fromRGBO(
                                                                77, 122, 209, 1)),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              // calorie Heading container ends
                                              SizedBox(height: ScUtil().setHeight(8)),
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(25.0),
                                                    // color: Colors.green
                                                    color: Colors.white),
                                                margin: const EdgeInsets.only(top: 1.2, bottom: 1),
                                                // height: MediaQuery.of(context)
                                                //         .size
                                                //         .height /
                                                //     3.5,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width /
                                                //     1.25,
                                                width: ScUtil().setWidth(290),
                                                // height: ScUtil().setHeight(250),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    // kcals left starts
                                                    Container(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.center,
                                                        // mainAxisAlignment:
                                                        //     MainAxisAlignment
                                                        //         .spaceEvenly,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 20.0, vertical: 10.0),
                                                            child: Container(
                                                              // height: MediaQuery.of(
                                                              //             context)
                                                              //         .size
                                                              //         .height /
                                                              //     22,
                                                              // width: MediaQuery.of(
                                                              //             context)
                                                              //         .size
                                                              //         .width /
                                                              //     10,
                                                              // height: 45,
                                                              // width: 42,
                                                              // width: ScUtil()
                                                              //     .setWidth(50),
                                                              // height: ScUtil()
                                                              //     .setHeight(
                                                              //         50),
                                                              width: ScUtil().setWidth(50),
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius.all(
                                                                  Radius.circular(12.0),
                                                                ),
                                                                color: Colors.redAccent
                                                                    .withOpacity(0.5),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.symmetric(
                                                                    horizontal: 8.0, vertical: 5.0),
                                                                child: Container(
                                                                  // color: Color.fromRGBO(
                                                                  //     146, 52, 236, 0.5),
                                                                  child: Image.asset(
                                                                    'assets/icons/kcals1.png',
                                                                    // height:
                                                                    //     30.0,
                                                                    // width: 30.0,
                                                                    width: ScUtil().setWidth(40),
                                                                    height: ScUtil().setHeight(40),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          // kcals values starts
                                                          SizedBox(
                                                            // height: MediaQuery.of(
                                                            //             context)
                                                            //         .size
                                                            //         .height /
                                                            //     28,
                                                            // width: MediaQuery.of(
                                                            //             context)
                                                            //         .size
                                                            //         .width /
                                                            //     2.9,
                                                            width: ScUtil().setWidth(120),
                                                            height: ScUtil().setHeight(35),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(1.0),
                                                              child: preferences != null
                                                                  ? PreferenceBuilder<int>(
                                                                      preference: preferences
                                                                          .getInt('burnedCalorie',
                                                                              defaultValue: 0),
                                                                      builder:
                                                                          (BuildContext context,
                                                                              int burnedCounter) {
                                                                        return PreferenceBuilder<
                                                                                int>(
                                                                            preference:
                                                                                preferences.getInt(
                                                                                    'eatenCalorie',
                                                                                    defaultValue:
                                                                                        0),
                                                                            builder: (BuildContext
                                                                                    context,
                                                                                int eatenCounter) {
                                                                              // calorie left container
                                                                              return Container(
                                                                                // width: 130,
                                                                                height:
                                                                                    MediaQuery.of(
                                                                                            context)
                                                                                        .size
                                                                                        .height,
                                                                                decoration:
                                                                                    const BoxDecoration(
                                                                                  color:
                                                                                      FitnessAppTheme
                                                                                          .white,
                                                                                  // borderRadius:
                                                                                  //     BorderRadius
                                                                                  //         .all(
                                                                                  //   Radius.circular(
                                                                                  //       120.0),
                                                                                  // ),
                                                                                  // border: ((dailytarget -
                                                                                  //                 eatenCounter) +
                                                                                  //             burnedCounter) <
                                                                                  //         0
                                                                                  //     ? Border.all(
                                                                                  //         width: 10,
                                                                                  //         color: Colors
                                                                                  //             .green)
                                                                                  //     : Border.all(
                                                                                  //         width: 4,
                                                                                  //         color: AppColors
                                                                                  //             .primaryColor
                                                                                  //             .withOpacity(
                                                                                  //                 0.2)),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisAlignment:
                                                                                      MainAxisAlignment
                                                                                          .center,
                                                                                  crossAxisAlignment:
                                                                                      CrossAxisAlignment
                                                                                          .center,
                                                                                  children: <
                                                                                      Widget>[
                                                                                    preferences !=
                                                                                            null
                                                                                        ? PreferenceBuilder<
                                                                                            int>(
                                                                                            preference: preferences.getInt(
                                                                                                'burnedCalorie',
                                                                                                defaultValue:
                                                                                                    0),
                                                                                            builder:
                                                                                                (BuildContext context,
                                                                                                    int burnedCounter) {
                                                                                              return PreferenceBuilder<int>(
                                                                                                  preference: preferences.getInt('eatenCalorie', defaultValue: 0),
                                                                                                  builder: (BuildContext context, int eatenCounter) {
                                                                                                    return Text(
                                                                                                      '${((dailytarget - eatenCounter) + burnedCounter).abs()}',
                                                                                                      textAlign: TextAlign.center,
                                                                                                      style: TextStyle(
                                                                                                        fontFamily: FitnessAppTheme.fontName,
                                                                                                        fontWeight: FontWeight.w800,
                                                                                                        fontSize: ScUtil().setSp(20),
                                                                                                        letterSpacing: 0.0,
                                                                                                        color: (((dailytarget - eatenCounter) + burnedCounter) > dailytarget)
                                                                                                            ? Colors.orangeAccent
                                                                                                            : ((dailytarget - eatenCounter) + burnedCounter) > 0
                                                                                                                ? const Color.fromRGBO(14, 23, 50, 1)
                                                                                                                : Colors.redAccent,
                                                                                                      ),
                                                                                                    );
                                                                                                  });
                                                                                            },
                                                                                          )
                                                                                        : Text(
                                                                                            '$dailytarget',
                                                                                            textAlign:
                                                                                                TextAlign.center,
                                                                                            style:
                                                                                                TextStyle(
                                                                                              fontFamily:
                                                                                                  FitnessAppTheme.fontName,
                                                                                              fontWeight:
                                                                                                  FontWeight.normal,
                                                                                              fontSize:
                                                                                                  ScUtil().setSp(14),
                                                                                              letterSpacing:
                                                                                                  0.0,
                                                                                              color:
                                                                                                  AppColors.primaryColor,
                                                                                            ),
                                                                                          ),
                                                                                    preferences !=
                                                                                            null
                                                                                        ? PreferenceBuilder<
                                                                                            int>(
                                                                                            preference: preferences.getInt(
                                                                                                'burnedCalorie',
                                                                                                defaultValue:
                                                                                                    0),
                                                                                            builder:
                                                                                                (BuildContext context,
                                                                                                    int burnedCounter) {
                                                                                              return PreferenceBuilder<
                                                                                                  int>(
                                                                                                preference:
                                                                                                    preferences.getInt('eatenCalorie', defaultValue: 0),
                                                                                                builder:
                                                                                                    (BuildContext context, int eatenCounter) {
                                                                                                  return Text(
                                                                                                    ((dailytarget - eatenCounter) + burnedCounter) > 0 ? ' Cal left' : 'Cal extra',
                                                                                                    textAlign: TextAlign.start,
                                                                                                    style: TextStyle(fontFamily: FitnessAppTheme.fontName, fontWeight: FontWeight.bold, fontSize: ScUtil().setSp(11), letterSpacing: 0, color: const Color.fromRGBO(145, 149, 162, 1)
                                                                                                        // color: FitnessAppTheme.grey.withOpacity(0.5),
                                                                                                        ),
                                                                                                  );
                                                                                                },
                                                                                              );
                                                                                            },
                                                                                          )
                                                                                        : Text(
                                                                                            'Cal left',
                                                                                            textAlign:
                                                                                                TextAlign.center,
                                                                                            style:
                                                                                                TextStyle(
                                                                                              fontFamily:
                                                                                                  FitnessAppTheme.fontName,
                                                                                              fontWeight:
                                                                                                  FontWeight.bold,
                                                                                              fontSize:
                                                                                                  14,
                                                                                              letterSpacing:
                                                                                                  0.0,
                                                                                              color: FitnessAppTheme
                                                                                                  .grey
                                                                                                  .withOpacity(0.5),
                                                                                            ),
                                                                                          ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            });
                                                                      })
                                                                  : Container(
                                                                      width: 120,
                                                                      height: 120,
                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            FitnessAppTheme.white,
                                                                        borderRadius:
                                                                            const BorderRadius.all(
                                                                          Radius.circular(120.0),
                                                                        ),
                                                                        border: Border.all(
                                                                            width: 4,
                                                                            color: AppColors
                                                                                .primaryColor
                                                                                .withOpacity(0.2)),
                                                                      ),
                                                                      child: Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .center,
                                                                        children: <Widget>[
                                                                          preferences != null
                                                                              ? PreferenceBuilder<
                                                                                      int>(
                                                                                  preference:
                                                                                      preferences.getInt(
                                                                                          'burnedCalorie',
                                                                                          defaultValue:
                                                                                              0),
                                                                                  builder: (BuildContext
                                                                                          context,
                                                                                      int burnedCounter) {
                                                                                    return PreferenceBuilder<
                                                                                            int>(
                                                                                        preference: preferences.getInt(
                                                                                            'eatenCalorie',
                                                                                            defaultValue:
                                                                                                0),
                                                                                        builder: (BuildContext
                                                                                                context,
                                                                                            int eatenCounter) {
                                                                                          return Text(
                                                                                            '${((dailytarget - eatenCounter) + burnedCounter).abs()}',
                                                                                            textAlign:
                                                                                                TextAlign.center,
                                                                                            style:
                                                                                                TextStyle(
                                                                                              fontFamily:
                                                                                                  FitnessAppTheme.fontName,
                                                                                              fontWeight:
                                                                                                  FontWeight.normal,
                                                                                              fontSize:
                                                                                                  28,
                                                                                              letterSpacing:
                                                                                                  0.0,
                                                                                              color: (((dailytarget - eatenCounter) + burnedCounter) > dailytarget)
                                                                                                  ? Colors.orangeAccent
                                                                                                  : ((dailytarget - eatenCounter) + burnedCounter) > 0
                                                                                                      ? AppColors.primaryColor
                                                                                                      : Colors.redAccent,
                                                                                            ),
                                                                                          );
                                                                                        });
                                                                                  })
                                                                              : Text(
                                                                                  '$dailytarget',
                                                                                  textAlign:
                                                                                      TextAlign
                                                                                          .center,
                                                                                  style:
                                                                                      const TextStyle(
                                                                                    fontFamily:
                                                                                        FitnessAppTheme
                                                                                            .fontName,
                                                                                    fontWeight:
                                                                                        FontWeight
                                                                                            .normal,
                                                                                    fontSize: 28,
                                                                                    letterSpacing:
                                                                                        0.0,
                                                                                    color: AppColors
                                                                                        .primaryColor,
                                                                                  ),
                                                                                ),
                                                                          preferences != null
                                                                              ? PreferenceBuilder<
                                                                                      int>(
                                                                                  preference:
                                                                                      preferences.getInt(
                                                                                          'burnedCalorie',
                                                                                          defaultValue:
                                                                                              0),
                                                                                  builder: (BuildContext
                                                                                          context,
                                                                                      int burnedCounter) {
                                                                                    return PreferenceBuilder<
                                                                                            int>(
                                                                                        preference: preferences.getInt(
                                                                                            'eatenCalorie',
                                                                                            defaultValue:
                                                                                                0),
                                                                                        builder: (BuildContext
                                                                                                context,
                                                                                            int eatenCounter) {
                                                                                          return Text(
                                                                                            ((dailytarget - eatenCounter) + burnedCounter) >
                                                                                                    0
                                                                                                ? 'Cal left'
                                                                                                : 'Cal extra',
                                                                                            textAlign:
                                                                                                TextAlign.center,
                                                                                            style:
                                                                                                TextStyle(
                                                                                              fontFamily:
                                                                                                  FitnessAppTheme.fontName,
                                                                                              fontWeight:
                                                                                                  FontWeight.bold,
                                                                                              fontSize:
                                                                                                  14,
                                                                                              letterSpacing:
                                                                                                  0.0,
                                                                                              color: FitnessAppTheme
                                                                                                  .grey
                                                                                                  .withOpacity(0.5),
                                                                                            ),
                                                                                          );
                                                                                        });
                                                                                  })
                                                                              : Text(
                                                                                  'Cal left',
                                                                                  textAlign:
                                                                                      TextAlign
                                                                                          .center,
                                                                                  style: TextStyle(
                                                                                    fontFamily:
                                                                                        FitnessAppTheme
                                                                                            .fontName,
                                                                                    fontWeight:
                                                                                        FontWeight
                                                                                            .bold,
                                                                                    fontSize: 14,
                                                                                    letterSpacing:
                                                                                        0.0,
                                                                                    color: FitnessAppTheme
                                                                                        .grey
                                                                                        .withOpacity(
                                                                                            0.5),
                                                                                  ),
                                                                                ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                            ),
                                                          ),
                                                          // kcals left ends
                                                        ],
                                                      ),
                                                      // kcals left ends
                                                    ),
                                                    // eaten value starts
                                                    Container(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(
                                                            left: 10.0, right: 2.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceAround,
                                                          children: [
                                                            Container(
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 20,
                                                                    height: 30,
                                                                    child: Image.asset(
                                                                        "assets/images/diet/eaten.png"),
                                                                  ),
                                                                  Container(
                                                                    child: Text(
                                                                      'Eaten: ',
                                                                      style: TextStyle(
                                                                        // fontFamily:
                                                                        //     FitnessAppTheme
                                                                        //         .fontName,
                                                                        fontWeight: FontWeight.w800,
                                                                        fontSize:
                                                                            ScUtil().setSp(14),
                                                                        letterSpacing: -0.1,
                                                                        color: FitnessAppTheme
                                                                            .dark_grey
                                                                            .withOpacity(0.5),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(
                                                                        left: 1),
                                                                    child: preferences != null
                                                                        ? PreferenceBuilder<int>(
                                                                            preference:
                                                                                preferences.getInt(
                                                                                    'eatenCalorie',
                                                                                    defaultValue:
                                                                                        0),
                                                                            builder: (BuildContext
                                                                                    context,
                                                                                int eatenCounter) {
                                                                              return Text(
                                                                                '$eatenCounter',
                                                                                textAlign: TextAlign
                                                                                    .center,
                                                                                style: TextStyle(
                                                                                  fontFamily:
                                                                                      FitnessAppTheme
                                                                                          .fontName,
                                                                                  fontWeight:
                                                                                      FontWeight
                                                                                          .w600,
                                                                                  fontSize: ScUtil()
                                                                                      .setSp(14),
                                                                                  color:
                                                                                      FitnessAppTheme
                                                                                          .darkerText,
                                                                                ),
                                                                              );
                                                                            },
                                                                          )
                                                                        : Text(
                                                                            '0',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: TextStyle(
                                                                              fontFamily:
                                                                                  FitnessAppTheme
                                                                                      .fontName,
                                                                              fontWeight:
                                                                                  FontWeight.w600,
                                                                              fontSize: ScUtil()
                                                                                  .setSp(14),
                                                                              color: FitnessAppTheme
                                                                                  .darkerText,
                                                                            ),
                                                                          ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(
                                                                        left: 4),
                                                                    child: Text(
                                                                      'Cal',
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        fontFamily: FitnessAppTheme
                                                                            .fontName,
                                                                        fontWeight: FontWeight.w600,
                                                                        fontSize: 8,
                                                                        letterSpacing: -0.2,
                                                                        color: FitnessAppTheme.grey
                                                                            .withOpacity(0.5),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // eaten value ends
                                                            ///
                                                            // SizedBox(
                                                            //     width: ScUtil()
                                                            //         .setWidth(
                                                            //             30)),
                                                            // burned value stars
                                                            Container(
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 20,
                                                                    height: 30,
                                                                    child: Image.asset(
                                                                        "assets/images/diet/burned.png"),
                                                                  ),
                                                                  Container(
                                                                    child: Text(
                                                                      'Burned: ',
                                                                      style: TextStyle(
                                                                        // fontFamily:
                                                                        //     FitnessAppTheme
                                                                        //         .fontName,
                                                                        fontWeight: FontWeight.w800,
                                                                        fontSize:
                                                                            ScUtil().setSp(14),
                                                                        letterSpacing: -0.1,
                                                                        color: FitnessAppTheme
                                                                            .dark_grey
                                                                            .withOpacity(0.5),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(
                                                                      left: 1,
                                                                    ),
                                                                    child: preferences != null
                                                                        ? PreferenceBuilder<int>(
                                                                            preference:
                                                                                preferences.getInt(
                                                                                    'burnedCalorie',
                                                                                    defaultValue:
                                                                                        0),
                                                                            builder: (BuildContext
                                                                                    context,
                                                                                int burnedCounter) {
                                                                              return Text(
                                                                                '$burnedCounter',
                                                                                textAlign: TextAlign
                                                                                    .center,
                                                                                style: TextStyle(
                                                                                  fontFamily:
                                                                                      FitnessAppTheme
                                                                                          .fontName,
                                                                                  fontWeight:
                                                                                      FontWeight
                                                                                          .w600,
                                                                                  fontSize: ScUtil()
                                                                                      .setSp(14),
                                                                                  color:
                                                                                      FitnessAppTheme
                                                                                          .darkerText,
                                                                                ),
                                                                              );
                                                                            })
                                                                        : Text(
                                                                            '0',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: TextStyle(
                                                                              fontFamily:
                                                                                  FitnessAppTheme
                                                                                      .fontName,
                                                                              fontWeight:
                                                                                  FontWeight.w600,
                                                                              fontSize: ScUtil()
                                                                                  .setSp(14),
                                                                              color: FitnessAppTheme
                                                                                  .darkerText,
                                                                            ),
                                                                          ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(
                                                                        left: 4),
                                                                    child: Text(
                                                                      'Cal',
                                                                      textAlign: TextAlign.end,
                                                                      style: TextStyle(
                                                                        fontFamily: FitnessAppTheme
                                                                            .fontName,
                                                                        fontWeight: FontWeight.w600,
                                                                        fontSize: 8,
                                                                        letterSpacing: -0.2,
                                                                        color: FitnessAppTheme.grey
                                                                            .withOpacity(0.5),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // burned value ends
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // SizedBox(
                                                    //   height:15
                                                    // ),
                                                    // graph ui starts
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 10.0),
                                                      child: Container(
                                                        child: graphDataList.isNotEmpty
                                                            ? SizedBox(
                                                                width: ScUtil().setWidth(272),
                                                                height: ScUtil().setHeight(115),
                                                                // height: 130,
                                                                // height: MediaQuery.of(
                                                                //             context)
                                                                //         .size
                                                                //         .height /
                                                                //     6,
                                                                child: Card(
                                                                  // color: CardColors.bgColor,
                                                                  child: SfCartesianChart(
                                                                    // plotAreaBackgroundColor:
                                                                    //     Colors.greenAccent,
                                                                    series: <ChartSeries>[
                                                                      ColumnSeries<DailyCalorieData,
                                                                          DateTime>(
                                                                        color: const Color.fromRGBO(
                                                                            30, 191, 105, 1),
                                                                        width: 0.33,

                                                                        borderRadius:
                                                                            const BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(10.0),
                                                                          topRight:
                                                                              Radius.circular(10.0),
                                                                        ),
                                                                        dataSource: graphDataList,
                                                                        // monthlyChartData,
                                                                        xValueMapper:
                                                                            (DailyCalorieData sales,
                                                                                    _) =>
                                                                                sales.x,
                                                                        yValueMapper:
                                                                            (DailyCalorieData sales,
                                                                                    _) =>
                                                                                sales.y,
                                                                        // Sets the corner radius
                                                                        enableTooltip: true,
                                                                      )
                                                                    ],
                                                                    primaryXAxis: DateTimeAxis(
                                                                      intervalType:
                                                                          DateTimeIntervalType.days,
                                                                      // maximumLabels:
                                                                      //     2,
                                                                      majorTickLines:
                                                                          const MajorTickLines(
                                                                              width: 0),
                                                                      majorGridLines:
                                                                          const MajorGridLines(
                                                                              width: 0),
                                                                      enableAutoIntervalOnZooming:
                                                                          true,
                                                                      labelIntersectAction:
                                                                          AxisLabelIntersectAction
                                                                              .rotate90,
                                                                      interval: 1,
                                                                      // title: AxisTitle(
                                                                      //     text:
                                                                      //         'Weekly Days'),
                                                                      dateFormat: DateFormat('EEE'),
                                                                    ),
                                                                    primaryYAxis: NumericAxis(
                                                                      title: AxisTitle(
                                                                        text: 'Calories',
                                                                        textStyle: const TextStyle(
                                                                            fontSize: 12.0),
                                                                      ),
                                                                      maximumLabels: 2,
                                                                      majorTickLines:
                                                                          const MajorTickLines(
                                                                              width: 0),
                                                                      majorGridLines:
                                                                          const MajorGridLines(
                                                                              width: 0),
                                                                    ),
                                                                    trackballBehavior:
                                                                        TrackballBehavior(
                                                                      enable: true,
                                                                      markerSettings:
                                                                          const TrackballMarkerSettings(
                                                                        markerVisibility:
                                                                            TrackballVisibilityMode
                                                                                .hidden,
                                                                        height: 10,
                                                                        width: 10,
                                                                        borderWidth: 1,
                                                                      ),
                                                                      activationMode:
                                                                          ActivationMode.singleTap,
                                                                      tooltipDisplayMode:
                                                                          TrackballDisplayMode
                                                                              .floatAllPoints,
                                                                      tooltipSettings:
                                                                          const InteractiveTooltip(
                                                                              format:
                                                                                  'point.x : point.y Cal',
                                                                              canShowMarker: false),
                                                                      shouldAlwaysShow: true,
                                                                    ),
                                                                    enableAxisAnimation: true,
                                                                    zoomPanBehavior:
                                                                        ZoomPanBehavior(
                                                                      /// To enable the pinch zooming as true.
                                                                      enablePinching: true,
                                                                      zoomMode: ZoomMode.xy,
                                                                      enablePanning: true,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : nodata
                                                                ? GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.pushAndRemoveUntil(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (BuildContext
                                                                                      context) =>
                                                                                  DietJournal()),
                                                                          (Route<dynamic> route) =>
                                                                              false);
                                                                    },
                                                                    child: SizedBox(
                                                                      height: 130,
                                                                      width: 300,
                                                                      child: Card(
                                                                        color: CardColors.bgColor,
                                                                        child: const Center(
                                                                          child: Text(
                                                                            'No data for this week.\nClick to Log!',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : SizedBox(
                                                                    height: ScUtil().setHeight(100),
                                                                    child: const Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    ),
                                                                  ),
                                                      ),
                                                    ),
                                                    // graph ui ends
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: ScUtil().setWidth(12),
                                          ),
                                          // Activity section starts
                                          // Activity Heading container starts
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                // color: Colors.amber,
                                                // height: MediaQuery.of(context)
                                                //         .size
                                                //         .height /
                                                //     37,
                                                // width: MediaQuery.of(context)
                                                //         .size
                                                //         .width /
                                                // 1.35,
                                                width: ScUtil().setWidth(280),
                                                height: ScUtil().setHeight(20),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 0.0),
                                                      child: Text(
                                                        'Glance at your Activity',
                                                        // textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          fontFamily: FitnessAppTheme.fontName,
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: ScUtil().setSp(15),
                                                          // letterSpacing: -1,
                                                          // color: AppColors.textitemTitleColor,
                                                          // color: Color.fromRGBO(166, 167, 187, 1),
                                                          color: const Color.fromRGBO(
                                                            132,
                                                            132,
                                                            160,
                                                            1,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Get.to(
                                                          TodayActivityScreen(
                                                            todaysActivityData: todaysActivityData,
                                                            otherActivityData: otherActivityData,
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        'More',
                                                        // textAlign: TextAlign.left,
                                                        style: TextStyle(
                                                          fontFamily: FitnessAppTheme.fontName,
                                                          fontWeight: FontWeight.w900,
                                                          fontSize: ScUtil().setSp(14),
                                                          // letterSpacing: 1,
                                                          // color: color ?? AppColors.primaryColor,
                                                          color:
                                                              const Color.fromRGBO(77, 122, 209, 1),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              // Activity Heading container ends
                                              SizedBox(height: ScUtil().setHeight(8)),
                                              ScUtil.screenHeight > 800
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(25.0),
                                                        color: const Color.fromRGBO(
                                                            150, 199, 193, 0.2),
                                                        // color: Colors.white
                                                      ),
                                                      margin: const EdgeInsets.only(
                                                          top: 1.2, bottom: 1),
                                                      // height: MediaQuery.of(context)
                                                      //         .size
                                                      //         .height /
                                                      //     3.6,
                                                      // width: MediaQuery.of(context)
                                                      //         .size
                                                      //         .width /
                                                      //     1.20,
                                                      width: ScUtil().setWidth(295),
                                                      // height: ScUtil().setHeight(180),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            // alignment: Alignment
                                                            //     .centerRight,
                                                            child: todaysActivityData.isEmpty
                                                                ? DashBoardRunningView(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (BuildContext
                                                                                  context) =>
                                                                              TodayActivityScreen(
                                                                            todaysActivityData:
                                                                                todaysActivityData,
                                                                            otherActivityData:
                                                                                otherActivityData,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  )
                                                                : HomeDashBoardTodaysActivityView(
                                                                    todaysActivityList:
                                                                        todaysActivityData,
                                                                    otherActivityList:
                                                                        otherActivityData),
                                                          ),
                                                          SizedBox(
                                                            height: ScUtil().setHeight(30),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(right: 5.0),
                                                            child: SizedBox(
                                                              // height: MediaQuery.of(context).size.height / 4.1,
                                                              // width: MediaQuery.of(context).size.width / 1.24,
                                                              width: ScUtil().setWidth(290),
                                                              height: ScUtil().setHeight(210),
                                                              child: todaysActivityData.isEmpty
                                                                  ? Card(
                                                                      shape:
                                                                          const RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(
                                                                          Radius.circular(25),
                                                                        ),
                                                                      ),
                                                                      color: const Color.fromRGBO(
                                                                          35, 107, 254, 0.8),
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  25),
                                                                          gradient: LinearGradient(
                                                                            begin: Alignment
                                                                                .bottomCenter,
                                                                            end:
                                                                                Alignment.topCenter,
                                                                            colors: [
                                                                              Colors.indigo[900],
                                                                              //Colors.lightBlue,
                                                                              Colors.blue[600],
                                                                            ],
                                                                            stops: const [0.0, 1.0],
                                                                            tileMode:
                                                                                TileMode.clamp,
                                                                          ),
                                                                        ),
                                                                        child: Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment
                                                                                  .spaceEvenly,
                                                                          children: [
                                                                            SizedBox(
                                                                              height: ScUtil()
                                                                                  .setHeight(18),
                                                                            ),
                                                                            Text(
                                                                              "No Activity today!",
                                                                              style: TextStyle(
                                                                                  fontSize: ScUtil()
                                                                                      .setSp(12),
                                                                                  letterSpacing:
                                                                                      1.5,
                                                                                  color:
                                                                                      Colors.white,
                                                                                  fontWeight:
                                                                                      FontWeight
                                                                                          .w600),
                                                                            ),
                                                                            SizedBox(
                                                                              height: ScUtil()
                                                                                  .setHeight(58),
                                                                            ),
                                                                            TextButton(
                                                                              style: ButtonStyle(
                                                                                backgroundColor:
                                                                                    MaterialStateProperty
                                                                                        .all<Color>(
                                                                                  Colors.white
                                                                                      .withOpacity(
                                                                                          1),
                                                                                ),
                                                                                shape: MaterialStateProperty
                                                                                    .all<
                                                                                        RoundedRectangleBorder>(
                                                                                  RoundedRectangleBorder(
                                                                                    borderRadius:
                                                                                        BorderRadius
                                                                                            .circular(
                                                                                                18.0),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              onPressed: () {
                                                                                // Navigator.of(context).pushNamed(
                                                                                //     Routes.WellnessCart,
                                                                                //     arguments: false);
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (BuildContext
                                                                                              context) =>
                                                                                          ActivityListScreen()),
                                                                                );
                                                                              },
                                                                              child: Text(
                                                                                'Start Logging',
                                                                                style: TextStyle(
                                                                                    fontSize:
                                                                                        ScUtil()
                                                                                            .setSp(
                                                                                                12),
                                                                                    color:
                                                                                        Colors.blue,
                                                                                    fontWeight:
                                                                                        FontWeight
                                                                                            .bold),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height: ScUtil()
                                                                                  .setHeight(15),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container(
                                                                      // decoration:
                                                                      //     BoxDecoration(
                                                                      //         color:
                                                                      //             AppColors.cardColor),
                                                                      child:
                                                                          HomeDashBoardTodaysActivityView(
                                                                              todaysActivityList:
                                                                                  todaysActivityData,
                                                                              otherActivityList:
                                                                                  otherActivityData),
                                                                    ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                            ],
                                          ),

                                          // Activity section ends
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Health journal ends
                            SizedBox(
                              height: ScUtil().setHeight(8),
                            ),
                            // vital datas starts
                            Padding(
                              padding: const EdgeInsets.only(left: 28.0),
                              child: SizedBox(
                                // color: Colors.white,
                                // height: MediaQuery.of(context).size.height / 30,
                                // width: MediaQuery.of(context).size.width / 1.35,
                                width: ScUtil().setWidth(280),
                                height: ScUtil().setHeight(20),

                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Glance at your vitals',
                                      // textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w700,
                                        fontSize: ScUtil().setSp(15),
                                        // letterSpacing: -1,
                                        // color: AppColors.textitemTitleColor,
                                        // color: Color.fromRGBO(166, 167, 187, 1),
                                        color: const Color.fromRGBO(
                                          132,
                                          132,
                                          160,
                                          1,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.to(VitalTab());
                                        // Navigator.pushAndRemoveUntil(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             OtherVitals()),
                                        //     (Route<dynamic> route) => false);
                                      },
                                      child: Text(
                                        'More',
                                        // textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontFamily: FitnessAppTheme.fontName,
                                            fontWeight: FontWeight.w900,
                                            fontSize: ScUtil().setSp(14),
                                            // letterSpacing: 1,
                                            // color: color ?? AppColors.primaryColor,
                                            color: const Color.fromRGBO(77, 122, 209, 1)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: ScUtil().setHeight(8)),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Container(
                                // color: Colors.green,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Get.to(
                                              VitalTab(),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(20.0),
                                              ),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.2),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                  offset: const Offset(1.0, 1.0),
                                                )
                                              ],
                                            ),
                                            // height: MediaQuery.of(context)
                                            //         .size
                                            //         .height /
                                            //     5.5,
                                            // width: MediaQuery.of(context)
                                            //         .size
                                            //         .width /
                                            //     3,
                                            width: ScUtil().setWidth(115),
                                            // height: ScUtil().setHeight(110),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  // height card starts
                                                  Container(
                                                    decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(12.0),
                                                      ),
                                                      color: Color.fromRGBO(236, 207, 255, 1),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 15.0, vertical: 10.0),
                                                      child: Container(
                                                        color:
                                                            const Color.fromRGBO(146, 52, 236, 0.5),
                                                        child: Image.asset('assets/icons/h2.png',
                                                            height: ScUtil().setHeight(30)),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: ScUtil().setHeight(5),
                                                  ),
                                                  Text(
                                                    'Height',
                                                    style: TextStyle(
                                                        fontSize: ScUtil().setSp(14),
                                                        // color: Colors.teal,
                                                        color:
                                                            const Color.fromRGBO(67, 147, 207, 1),
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                  SizedBox(
                                                    height: ScUtil().setHeight(3),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      if (mounted) {
                                                        setState(() {
                                                          feet = !feet;
                                                        });
                                                      }
                                                    },
                                                    child: Text(
                                                      feet == false ? '$height Cms' : heightft(),
                                                      style: TextStyle(
                                                          fontSize: ScUtil().setSp(14),
                                                          color: const Color.fromRGBO(
                                                              151, 150, 185, 1),
                                                          fontWeight: FontWeight.w800),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // height card ends
                                        SizedBox(
                                          width: ScUtil().setWidth(20),
                                        ),
                                        // weight card
                                        InkWell(
                                          onTap: () {
                                            Get.to(
                                              VitalTab(),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(20.0),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.2),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                    offset: const Offset(1.0, 1.0),
                                                  )
                                                ],
                                                color: Colors.white),
                                            // height: MediaQuery.of(context)
                                            //         .size
                                            //         .height /
                                            //     5.5,
                                            // width: MediaQuery.of(context)
                                            //         .size
                                            //         .width /
                                            //     3,
                                            width: ScUtil().setWidth(115),
                                            // height: ScUtil().setHeight(110),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Container(
                                                    decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(13.0),
                                                      ),
                                                      color: Color.fromRGBO(217, 48, 37, 0.3),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 15.0, vertical: 10.0),
                                                      child: Container(
                                                        // color: Color.fromRGBO(
                                                        //     217, 48, 37, 0.5),
                                                        child: Image.asset('assets/icons/w6.png',
                                                            height: ScUtil().setHeight(30)),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: ScUtil().setHeight(5),
                                                  ),
                                                  Text(
                                                    'Weight',
                                                    style: TextStyle(
                                                        fontSize: ScUtil().setSp(14),
                                                        color:
                                                            const Color.fromRGBO(67, 147, 207, 1),
                                                        // color: Colors.teal,
                                                        fontWeight: FontWeight.w800),
                                                  ),
                                                  SizedBox(
                                                    height: ScUtil().setHeight(3),
                                                  ),
                                                  Text(
                                                    weight == ''
                                                        ? weightfromvitalsData == ''
                                                            ? '-'
                                                            : '$weightfromvitalsData Kgs'
                                                        : '$weight Kgs',
                                                    style: TextStyle(
                                                        fontSize: ScUtil().setSp(14),
                                                        color:
                                                            const Color.fromRGBO(151, 150, 185, 1),
                                                        fontWeight: FontWeight.w800),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: ScUtil().setWidth(20),
                                        ),
                                        // weight card ends
                                        // BMI container starts
                                        InkWell(
                                          onTap: () {
                                            Get.to(
                                              VitalTab(),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(20.0),
                                              ),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.2),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                  offset: const Offset(1.0, 1.0),
                                                )
                                              ],
                                            ),
                                            // height: MediaQuery.of(context)
                                            //         .size
                                            //         .height /
                                            //     5.5,
                                            // width: MediaQuery.of(context)
                                            //         .size
                                            //         .width /
                                            //     3,
                                            width: ScUtil().setWidth(115),
                                            // height: ScUtil().setHeight(110),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  // BMI card starts
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(13.0),
                                                      ),
                                                      color: Colors.orangeAccent.withOpacity(0.6),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 15.0, vertical: 10.0),
                                                      child: Container(
                                                        child: Image.asset('assets/icons/bmi1.png',
                                                            height: ScUtil().setHeight(30)),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: ScUtil().setHeight(5)),
                                                  Text(
                                                    'BMI',
                                                    style: TextStyle(
                                                        fontSize: ScUtil().setSp(14),
                                                        // color: Colors.teal,
                                                        color:
                                                            const Color.fromRGBO(67, 147, 207, 1),
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                  SizedBox(
                                                    height: ScUtil().setHeight(3),
                                                  ),
                                                  userVitals[0]['bmi'].toString() == null
                                                      ? const Text('N/A')
                                                      : Text(
                                                          // '$bmiClassCalc[]',

                                                          userVitals[0]['bmi'].toString(),
                                                          // '32.12',
                                                          style: TextStyle(
                                                              fontSize: ScUtil().setSp(14),
                                                              color: const Color.fromRGBO(
                                                                  151, 150, 185, 1),
                                                              fontWeight: FontWeight.w800),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// This is Old Dashboard file, Comment the above to codes entirely
// and uncomment the below codes to have old dashboard and viceversa
/*
// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names

import 'package:ihl/models/ecg_calculator.dart';
import 'package:ihl/widgets/dashboard/scoreMeter.dart';
import 'package:strings/strings.dart';
import 'dart:convert';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:ihl/constants/vitalUI.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/widgets/dashboard/liteVitalsCard.dart';
import 'package:ihl/constants/spKeys.dart';

// ignore: must_be_immutable
class HomeTab extends StatefulWidget {
  Function closeDrawer;
  Function openDrawer;
  Function goToProfile;
  var userScore = '0';
  String username;
  HomeTab({
    this.closeDrawer,
    this.username,
    this.openDrawer,
    this.userScore,
    this.goToProfile,
  });
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool loading = true;
  List vitalsToShow = [];
  String name = 'you';
  Map allScores = {};
  var data;
  bool isVerified = true;

  /// handle null and empty strings⚡
  String stringify(dynamic prop) {
    if (prop == null || prop == '' || prop == ' ' || prop == 'NA') {
      return AppTexts.notAvailable;
    }
    if (prop is double) {
      double doub = prop;
      prop = doub.round();
    }
    String stringVal = prop.toString();
    stringVal = stringVal.trim().isEmpty ? AppTexts.notAvailable : stringVal;
    return stringVal;
  }

  /// calculate bmi🎇🎇
  int calcBmi({height, weight}) {
    double parsedH;
    double parsedW;
    if (height == null || weight == null) {
      return null;
    }

    parsedH = double.tryParse(height);
    parsedW = double.tryParse(weight);
    if (parsedH != null && parsedW != null) {
      int bmi = parsedW ~/ (parsedH * parsedH);

      return bmi;
    }
    return null;
  }

  /// returns BMI Class for a BMI 🌈
  String bmiClassCalc(int bmi) {
    if (bmi == null) {
      return AppTexts.notAvailable;
    }
    if (bmi > 30) {
      return AppTexts.obeseBMI;
    }
    if (bmi > 25) {
      return AppTexts.ovwBMI;
    }
    if (bmi < 18) {
      return AppTexts.undwBMI;
    }
    return AppTexts.normalBMI;
  }

  DateTime getDateTimeStamp(String d) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(int.tryParse(d
          .substring(0, d.indexOf('+'))
          .replaceAll('Date', '')
          .replaceAll('/', '')
          .replaceAll('(', '')
          .replaceAll(')', '')));
    } catch (e) {
      return DateTime.now();
    }
  }

  /// looooooooooooooong code processes JSON response 🌠
  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var raw = prefs.get(SPKeys.userData);
    if (raw == '' || raw == null) {
      raw = '{}';
    }
    data = jsonDecode(raw);

    Map user = data['User'];
    if (user == null) {
      user = {};
    }
    var userVitalst = prefs.getString(SPKeys.vitalsData);
    if (userVitalst == null || userVitalst == '' || userVitalst == '[]') {
      if (user['userInputWeightInKG'] == null ||
          user['userInputWeightInKG'] == '' ||
          user['heightMeters'] == null ||
          user['heightMeters'] == '' ||
          ((user['email'] == null || user['email'] == '') &&
              (user['mobileNumber'] == null || user['mobileNumber'] == ''))) {
        isVerified = false;
        loading = false;
        if (this.mounted) {
          setState(() {});
          return;
        }
      }
      userVitalst = '[{}]';
    }
    List userVitals = jsonDecode(userVitalst);
    //get inputted height weight if values are not available

    if (userVitals[0]['weightKG'] == null) {
      userVitals[0]['weightKG'] = user['userInputWeightInKG'];
    }
    if (userVitals[0]['heightMeters'] == null) {
      userVitals[0]['heightMeters'] = user['heightMeters'];
    }
    //Calculate bmi
    if (userVitals[0]['bmi'] == null) {
      userVitals[0]['bmi'] = calcBmi(
          height: userVitals[0]['heightMeters'].toString(),
          weight: userVitals[0]['weightKG'].toString());
      userVitals[0]['bmiClass'] = bmiClassCalc(userVitals[0]['bmi']);
    }
    allScores = {};
    //prepare data
    double finalWeight = 0;
    double finalHeight = 0;
    var bcml = "20.00";
    var bcmh = "25.00";
    var lowMineral = "2.00";
    var highMineral = "3.00";
    var heightinCMS = userVitals[0]['heightMeters'] * 100;
    var weight = userVitals[0]['weightKG'].toString() == ""
        ? '0'
        : userVitals[0]['weightKG'].toString();
    var gender = user['gender'].toString();
    var lowSmmReference,
        lowFatReference,
        highSmmReference,
        highFatReference,
        lowBmcReference,
        highBmcReference,
        icll,
        iclh,
        ecll,
        eclh,
        proteinl,
        proteinh,
        waisttoheightratiolow,
        waisttoheightratiohigh,
        lowPbfReference,
        highPbfReference;

    if (gender != 'm') {
      lowPbfReference = "18.00";
      highPbfReference = "28.00";
      var femaleHeightWeight = [
        [147, 45, 59],
        [150, 45, 60],
        [152, 46, 62],
        [155, 47, 63],
        [157, 49, 65],
        [160, 50, 67],
        [162, 51, 69],
        [165, 53, 70],
        [167, 54, 72],
        [170, 55, 74],
        [172, 57, 75],
        [175, 58, 77],
        [177, 60, 78],
        [180, 61, 80]
      ];
      var j = 0;
      while (femaleHeightWeight[j][0] <= heightinCMS) {
        j++;
        if (j == 13) {
          break;
        }
      }
      var wtl, wth;
      if (j == 0) {
        wtl = femaleHeightWeight[j][1];
        wth = femaleHeightWeight[j][2];
      } else {
        wtl = femaleHeightWeight[j - 1][1];
        wth = femaleHeightWeight[j - 1][2];
      }
      lowSmmReference = (0.36 * wtl);
      highSmmReference = (0.36 * wth);
      lowFatReference = (0.18 * double.tryParse(weight));
      highFatReference = (0.28 * double.tryParse(weight));
      lowBmcReference = "1.70";
      highBmcReference = "3.00";
      icll = (0.3 * wtl);
      iclh = (0.3 * wth);
      ecll = (0.2 * wtl);
      eclh = (0.2 * wth);
      proteinl = (0.116 * double.tryParse(weight));
      proteinh = (0.141 * double.tryParse(weight));
      waisttoheightratiolow = "0.35";
      waisttoheightratiohigh = "0.53";
    } else {
      lowPbfReference = "10.00";
      highPbfReference = "20.00";
      var maleHeightWeight = [
        [155, 55, 66],
        [157, 56, 67],
        [160, 57, 68],
        [162, 58, 70],
        [165, 59, 72],
        [167, 60, 74],
        [170, 61, 75],
        [172, 62, 77],
        [175, 63, 79],
        [177, 64, 81],
        [180, 65, 83],
        [182, 66, 85],
        [185, 68, 87],
        [187, 69, 89],
        [190, 71, 91]
      ];
      var k = 0;
      while (maleHeightWeight[k][0] <= heightinCMS) {
        k++;
        if (k == 14) {
          break;
        }
      }
      var wtl, wth;
      if (k == 0) {
        wtl = maleHeightWeight[k][1];
        wth = maleHeightWeight[k][2];
      } else {
        wtl = maleHeightWeight[k - 1][1];
        wth = maleHeightWeight[k - 1][2];
      }
      lowSmmReference = (0.42 * wtl);
      highSmmReference = (0.42 * wth);
      lowFatReference = (0.10 * double.parse(weight ?? '0'));
      highFatReference = (0.20 * double.parse(weight ?? '0'));
      lowBmcReference = "2.00";
      highBmcReference = "3.70";
      icll = (0.3 * wtl);
      iclh = (0.3 * wth);
      ecll = (0.2 * wtl);
      eclh = (0.2 * wth);
      proteinl = (0.109 * double.parse(weight));
      proteinh = (0.135 * double.parse(weight));
      waisttoheightratiolow = "0.35";
      waisttoheightratiohigh = "0.57";
    }

    var proteinStatus;
    var ecwStatus;
    var icwStatus;
    var mineralStatus;
    var smmStatus;
    var bfmStatus;
    var bcmStatus;
    var waistHipStatus;
    var pbfStatus;
    var waistHeightStatus;
    var vfStatus;
    var bmrStatus;
    var bomcStatus;

    calculateFullBodyProteinStatus(FullBodyProtein) {
      if (double.parse(FullBodyProtein) < proteinl) {
        return 'Low';
      } else if (double.parse(FullBodyProtein) >= proteinl) {
        return 'Normal';
      }
    }

    calculateFullBodyECWStatus(FullBodyECW) {
      if (double.parse(FullBodyECW) < ecll) {
        return 'Low';
      } else if (double.parse(FullBodyECW) >= ecll &&
          double.parse(FullBodyECW) <= eclh) {
        return 'Normal';
      } else if (double.parse(FullBodyECW) > eclh) {
        return 'High';
      }
    }

    calculateFullBodyICWStatus(FullBodyICW) {
      if (double.parse(FullBodyICW) < icll) {
        return 'Low';
      } else if (double.parse(FullBodyICW) >= icll &&
          double.parse(FullBodyICW) <= iclh) {
        return 'Normal';
      } else if (double.parse(FullBodyICW) > iclh) {
        return 'High';
      }
    }

    calculateFullBodyMineralStatus(FullBodyMineral) {
      if (double.parse(FullBodyMineral) < double.parse(lowMineral)) {
        return 'Low';
      } else if (double.parse(FullBodyMineral) >= double.parse(lowMineral)) {
        return 'Normal';
      }
    }

    calculateFullBodySMMStatus(FullBodySMM) {
      if (double.parse(FullBodySMM) < lowSmmReference) {
        return 'Low';
      } else if (double.parse(FullBodySMM) >= lowSmmReference) {
        return 'Normal';
      }
    }

    calculateFullBodyBMCStatus(FullBodyBMC) {
      if (double.parse(FullBodyBMC) < double.parse(lowBmcReference)) {
        return 'Low';
      } else if (double.parse(FullBodyBMC) >= double.parse(lowBmcReference)) {
        return 'Normal';
      }
    }

    calculateFullBodyPBFStatus(FullBodyPBF) {
      if (double.parse(FullBodyPBF) < double.parse(lowPbfReference)) {
        return 'Low';
      } else if (double.parse(FullBodyPBF) >= double.parse(lowPbfReference) &&
          double.parse(FullBodyPBF) <= double.parse(highPbfReference)) {
        return 'Normal';
      } else if (double.parse(FullBodyPBF) > double.parse(highPbfReference)) {
        return 'High';
      }
    }

    calculateFullBodyBCMStatus(FullBodyBCM) {
      if (double.parse(FullBodyBCM) < double.parse(bcml)) {
        return 'Low';
      } else if (double.parse(FullBodyBCM) >= double.parse(bcml)) {
        return 'Normal';
      }
    }

    calculateFullBodyFATStatus(FullBodyFAT) {
      if (double.parse(FullBodyFAT) < lowFatReference) {
        return 'Low';
      } else if (double.parse(FullBodyFAT) >= lowFatReference &&
          double.parse(FullBodyFAT) <= highFatReference) {
        return 'Normal';
      } else if (double.parse(FullBodyFAT) > highFatReference) {
        return 'High';
      }
    }

    calculateFullBodyVFStatus(FullBodyVF) {
      if (FullBodyVF != "NaN") {
        if (int.tryParse(FullBodyVF) <= 100) {
          return 'Normal';
        } else if (int.tryParse(FullBodyVF) > 100) {
          return 'High';
        }
      }
    }

    calculateFullBodyBMRStatus(FullBodyBMR) {
      if (int.parse(FullBodyBMR) < 1200) {
        return 'Low';
      } else if (int.parse(FullBodyBMR) >= 1200) {
        return 'Normal';
      }
    }

    calculateFullBodyWHPRStatus(FullBodyWHPR) {
      if (double.parse(FullBodyWHPR) < 0.80) {
        return 'Low';
      } else if (double.parse(FullBodyWHPR) >= 0.80 &&
          double.parse(FullBodyWHPR) <= 0.90) {
        return 'Normal';
      }
      if (double.parse(FullBodyWHPR) > 0.90) {
        return 'High';
      }
    }

    calculateFullBodyWHTRStatus(FullBodyWHTR) {
      if (double.parse(FullBodyWHTR) < double.parse(waisttoheightratiolow)) {
        return 'Low';
      } else if (double.parse(FullBodyWHTR) >=
              double.parse(waisttoheightratiolow) &&
          double.parse(FullBodyWHTR) <= double.parse(waisttoheightratiohigh)) {
        return 'Normal';
      }
      if (double.parse(FullBodyWHTR) > double.parse(waisttoheightratiohigh)) {
        return 'High';
      }
    }

    for (var i = 0; i < userVitals.length; i++) {
      if (userVitals[i]['protien'] != null &&
          userVitals[i]['protien'] != "NaN") {
        userVitals[i]['protien'] = userVitals[i]['protien'].toStringAsFixed(2);
        proteinStatus =
            calculateFullBodyProteinStatus(userVitals[i]['protien']);
      }

      if (userVitals[i]['intra_cellular_water'] != null &&
          userVitals[i]['intra_cellular_water'] != "NaN") {
        userVitals[i]['intra_cellular_water'] =
            userVitals[i]['intra_cellular_water'].toStringAsFixed(2);
        icwStatus =
            calculateFullBodyICWStatus(userVitals[i]['intra_cellular_water']);
      }

      if (userVitals[i]['extra_cellular_water'] != null &&
          userVitals[i]['extra_cellular_water'] != "NaN") {
        userVitals[i]['extra_cellular_water'] =
            userVitals[i]['extra_cellular_water'].toStringAsFixed(2);
        ecwStatus =
            calculateFullBodyECWStatus(userVitals[i]['extra_cellular_water']);
      }

      if (userVitals[i]['mineral'] != null &&
          userVitals[i]['mineral'] != "NaN") {
        userVitals[i]['mineral'] = userVitals[i]['mineral'].toStringAsFixed(2);
        mineralStatus =
            calculateFullBodyMineralStatus(userVitals[i]['mineral']);
      }

      if (userVitals[i]['skeletal_muscle_mass'] != null &&
          userVitals[i]['skeletal_muscle_mass'] != "NaN") {
        userVitals[i]['skeletal_muscle_mass'] =
            userVitals[i]['skeletal_muscle_mass'].toStringAsFixed(2);
        smmStatus =
            calculateFullBodySMMStatus(userVitals[i]['skeletal_muscle_mass']);
      }

      if (userVitals[i]['body_fat_mass'] != null &&
          userVitals[i]['body_fat_mass'] != "NaN") {
        userVitals[i]['body_fat_mass'] =
            userVitals[i]['body_fat_mass'].toStringAsFixed(2);
        bfmStatus = calculateFullBodyFATStatus(userVitals[i]['body_fat_mass']);
      }

      if (userVitals[i]['body_cell_mass'] != null &&
          userVitals[i]['body_cell_mass'] != "NaN") {
        userVitals[i]['body_cell_mass'] =
            userVitals[i]['body_cell_mass'].toStringAsFixed(2);
        bcmStatus = calculateFullBodyBCMStatus(userVitals[i]['body_cell_mass']);
      }

      if (userVitals[i]['waist_hip_ratio'] != null &&
          userVitals[i]['waist_hip_ratio'] != "NaN") {
        userVitals[i]['waist_hip_ratio'] =
            userVitals[i]['waist_hip_ratio'].toStringAsFixed(2);
        waistHipStatus =
            calculateFullBodyWHPRStatus(userVitals[i]['waist_hip_ratio']);
      }

      if (userVitals[i]['percent_body_fat'] != null &&
          userVitals[i]['percent_body_fat'] != "NaN") {
        userVitals[i]['percent_body_fat'] =
            userVitals[i]['percent_body_fat'].toStringAsFixed(2);
        pbfStatus =
            calculateFullBodyPBFStatus(userVitals[i]['percent_body_fat']);
      }

      if (userVitals[i]['waist_height_ratio'] != null &&
          userVitals[i]['waist_height_ratio'] != "NaN") {
        userVitals[i]['waist_height_ratio'] =
            userVitals[i]['waist_height_ratio'].toStringAsFixed(2);
        waistHeightStatus =
            calculateFullBodyWHTRStatus(userVitals[i]['waist_height_ratio']);
      }

      if (userVitals[i]['visceral_fat'] != null &&
          userVitals[i]['visceral_fat'] != "NaN") {
        userVitals[i]['visceral_fat'] =
            stringify(userVitals[i]['visceral_fat']);
        vfStatus = calculateFullBodyVFStatus(userVitals[i]['visceral_fat']);
      }

      if (userVitals[i]['basal_metabolic_rate'] != null &&
          userVitals[i]['basal_metabolic_rate'] != "NaN") {
        userVitals[i]['basal_metabolic_rate'] =
            stringify(userVitals[i]['basal_metabolic_rate']);
        bmrStatus =
            calculateFullBodyBMRStatus(userVitals[i]['basal_metabolic_rate']);
      }

      if (userVitals[i]['bone_mineral_content'] != null &&
          userVitals[i]['bone_mineral_content'] != "NaN") {
        userVitals[i]['bone_mineral_content'] =
            userVitals[i]['bone_mineral_content'].toStringAsFixed(2);
        bomcStatus =
            calculateFullBodyBMCStatus(userVitals[i]['bone_mineral_content']);
      }

      userVitals[i]['bmi'] ??= calcBmi(
          height: userVitals[i]['heightMeters'].toString(),
          weight: userVitals[i]['weight'].toString());
      finalHeight = doubleFly(userVitals[i]['heightMeters']) ?? finalHeight;
      finalWeight = doubleFly(userVitals[i]['weightKG']) ?? finalWeight;
      if (userVitals[i]['systolic'] != null &&
          userVitals[i]['diastolic'] != null) {
        userVitals[i]['bp'] = stringify(userVitals[i]['systolic']) +
            '/' +
            stringify(userVitals[i]['diastolic']);
      }
      userVitals[i]['weightKGClass'] = userVitals[i]['bmiClass'];
      userVitals[i]['ECGBpmClass'] = userVitals[i]['leadTwoStatus'];
      userVitals[i]['fatRatioClass'] = userVitals[i]['fatClass'];
      userVitals[i]['pulseBpmClass'] = userVitals[i]['pulseClass'];
    }
    prefs.setDouble(SPKeys.weight, finalWeight);
    prefs.setDouble(SPKeys.height, finalHeight);

    //Check which vital
    vitalsOnHome.forEach((f) {
      allScores[f] = [];
      allScores[f + 'Class'] = [];
      for (var i = 0; i < userVitals.length; i++) {
        if (userVitals[i][f] != '' &&
            userVitals[i][f] != null &&
            userVitals[i][f] != 'N/A') {
          /// round off to nearest 2 decimal 🌊
          if (userVitals[i][f] is double) {
            if (decimalVitals.contains(f)) {
              userVitals[i][f] = (userVitals[i][f] * 100.0).toInt() / 100;
            } else {
              userVitals[i][f] = (userVitals[i][f]).toInt();
            }
          }
          Map mapToAdd = {
            'value': userVitals[i][f],
            'status': userVitals[i][f + 'Class'] == null
                ? 'Unknown'
                : camelize(userVitals[i][f + 'Class']),
            'date': userVitals[i]['dateTimeFormatted'] != null
                ? DateTime.tryParse(
                    userVitals[i]['dateTimeFormatted'].toString())
                : getDateTimeStamp(user['accountCreated']),
            'moreData': {
              'Address': stringify(userVitals[i]['orgAddress']),
              'City': stringify(userVitals[i]['IHLMachineLocation']),
            }
          };
          // processing specific to a vital
          if (f == 'temperature') {
            if (userVitals[i]['Roomtemperature'] != null) {
              userVitals[i]['Roomtemperature'] =
                  doubleFly(userVitals[i]['Roomtemperature']);
              mapToAdd['moreData']['Room Temperature'] =
                  '${stringify((userVitals[i]['Roomtemperature'] * 9 / 5) + 32)} ${vitalsUI['temperature']['unit']}';
            }
            mapToAdd['value'] =
                (((userVitals[i][f] * 900 / 5).toInt()) / 100 + 32)
                    .toStringAsFixed(2);
          }
          if (f == 'bp') {
            mapToAdd['moreData']['Systolic'] =
                userVitals[i]['systolic'].toString();
            mapToAdd['moreData']['Diastolic'] =
                userVitals[i]['diastolic'].toString();
          }

          if (f == 'protien') {
            mapToAdd['protien'] = userVitals[i]['protien'].toString();
            mapToAdd['status'] = proteinStatus.toString();
          }

          if (f == 'intra_cellular_water') {
            mapToAdd['intra_cellular_water'] =
                userVitals[i]['intra_cellular_water'].toString();
            mapToAdd['status'] = icwStatus.toString();
          }

          if (f == 'extra_cellular_water') {
            mapToAdd['extra_cellular_water'] =
                userVitals[i]['extra_cellular_water'].toString();
            mapToAdd['status'] = ecwStatus.toString();
          }

          if (f == 'mineral') {
            mapToAdd['mineral'] = userVitals[i]['mineral'].toString();
            mapToAdd['status'] = mineralStatus.toString();
          }

          if (f == 'skeletal_muscle_mass') {
            mapToAdd['skeletal_muscle_mass'] =
                userVitals[i]['skeletal_muscle_mass'].toString();
            mapToAdd['status'] = smmStatus.toString();
          }

          if (f == 'body_fat_mass') {
            mapToAdd['body_fat_mass'] =
                userVitals[i]['body_fat_mass'].toString();
            mapToAdd['status'] = bfmStatus.toString();
          }

          if (f == 'body_cell_mass') {
            mapToAdd['body_cell_mass'] =
                userVitals[i]['body_cell_mass'].toString();
            mapToAdd['status'] = bcmStatus.toString();
          }

          if (f == 'waist_hip_ratio') {
            mapToAdd['waist_hip_ratio'] =
                userVitals[i]['waist_hip_ratio'].toString();
            mapToAdd['status'] = waistHipStatus.toString();
          }

          if (f == 'percent_body_fat') {
            mapToAdd['percent_body_fat'] =
                userVitals[i]['percent_body_fat'].toString();
            mapToAdd['status'] = pbfStatus.toString();
          }

          if (f == 'waist_height_ratio') {
            mapToAdd['waist_height_ratio'] =
                userVitals[i]['waist_height_ratio'].toString();
            mapToAdd['status'] = waistHeightStatus.toString();
          }

          if (f == 'visceral_fat') {
            mapToAdd['visceral_fat'] = userVitals[i]['visceral_fat'].toString();
            mapToAdd['status'] = vfStatus.toString();
          }

          if (f == 'basal_metabolic_rate') {
            mapToAdd['basal_metabolic_rate'] =
                userVitals[i]['basal_metabolic_rate'].toString();
            mapToAdd['status'] = bmrStatus.toString();
          }

          if (f == 'bone_mineral_content') {
            mapToAdd['bone_mineral_content'] =
                userVitals[i]['bone_mineral_content'].toString();
            mapToAdd['status'] = bomcStatus.toString();
          }

          if (f == 'ECGBpm') {
            mapToAdd['graphECG'] = ECGCalc(
              isLeadThree: userVitals[i]['LeadMode'] == 3,
              data1: userVitals[i]['ECGData'],
              data2: userVitals[i]['ECGData2'],
              data3: userVitals[i]['ECGData3'],
            );

            mapToAdd['moreData']['Lead One Status'] =
                stringify(userVitals[i]['leadOneStatus']);
            mapToAdd['moreData']['Lead Two Status'] =
                stringify(userVitals[i]['leadTwoStatus']);
            mapToAdd['moreData']['Lead Three Status'] =
                stringify(userVitals[i]['leadThreeStatus']);
          }
          allScores[f].add(mapToAdd);
          if (!vitalsToShow.contains(f)) {
            vitalsToShow.add(f);
          }
        }
      }
    });
    vitalsToShow.toSet();
    vitalsToShow = vitalsOnHome;

    loading = false;
    if (this.mounted) {
      this.setState(() {});
    }
  }

  double doubleFly(k) {
    if (k is num) {
      return k * 1.0;
    }
    if (k is String) {
      return double.tryParse(k);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      width = 500;
    }
    if (loading) {
      return SafeArea(
        child: Container(
          color: AppColors.bgColorTab,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: TextButton(
                      child: Icon(
                        Icons.menu,
                        size: 30,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        widget.openDrawer();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(0),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      );
    }
    if (!isVerified) {
      return SafeArea(
        child: Container(
          color: AppColors.bgColorTab,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: TextButton(
                      child: Icon(
                        Icons.menu,
                        size: 30,
                        color: AppColors.primaryAccentColor,
                      ),
                      onPressed: () {
                        widget.openDrawer();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(0),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 100,
                      color: AppColors.lightTextColor,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(AppTexts.updateProfile),
                    SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primaryAccentColor,
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      child: Text(AppTexts.visitProfile),
                      onPressed: () {
                        widget.goToProfile();
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SafeArea(
      child: Column(
        children: <Widget>[
          CustomPaint(
            painter: BackgroundPainter(
              primary: AppColors.primaryColor.withOpacity(0.7),
              secondary: AppColors.primaryColor.withOpacity(0.0),
            ),
            child: Container(),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 40,
                              child: TextButton(
                                child: Icon(
                                  Icons.menu,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  widget.openDrawer();
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(0),
                                ),
                              ),
                            ),
                            Text(
                              AppTexts.scoreTitle,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25 * width / 500),
                            ),
                            SizedBox(
                              width: 40,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ScoreMeter(
                      data: widget.userScore,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      vitalsToShow.length > 0
                          ? AppTexts.yoVitals
                          : AppTexts.noVitals,
                      style: TextStyle(
                        fontSize: 20 * width / 500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    childAspectRatio: 1.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return VitalCard(
                        uiData: vitalsUI[vitalsToShow[index]],
                        vitalType: vitalsToShow[index],
                        data: allScores[vitalsToShow[index]],
                      );
                    },
                    childCount: vitalsToShow.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
