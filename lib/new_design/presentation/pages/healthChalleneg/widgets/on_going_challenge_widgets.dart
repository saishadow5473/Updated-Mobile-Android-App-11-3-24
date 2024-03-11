import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../Getx/controller/listOfChallengeContoller.dart';
import '../../../../../constants/api.dart';
import '../../../../../constants/spKeys.dart';
import '../../../../../health_challenge/controllers/challenge_api.dart';
import '../../../../../health_challenge/models/challenge_detail.dart';
import '../../../../../health_challenge/models/enrolled_challenge.dart';
import '../../../../../health_challenge/models/join_individual.dart';
import '../../../../../health_challenge/models/update_challenge_target_model.dart';
import '../../../../../health_challenge/views/health_challenges_types.dart';
import '../../../../../main.dart';
import '../../../../../views/splash_screen.dart';
import '../../../../app/utils/appColors.dart';
import '../../../../../utils/app_text_styles.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../data/functions/healthChallengeFunctions.dart';
import '../../../../app/utils/appText.dart';
import '../../../controllers/healthchallenge/healthChallengeController.dart';
import '../getX_widget_responsive/challange_ui_reponse.dart';

Widget onGoingchallengeLogDetails(
    BuildContext context,
    ChallengeDetail challengeDetail,
    EnrolledChallenge enrolledChallenge,
    TextEditingController _stepsController,
    bool firstTime,
    GlobalKey<FormState> key) {
  String _currentSelectedCity = '';
  SessionSelectionController sessionSelectionController = Get.put(SessionSelectionController());
  ScrollController _scrollController = ScrollController();
  List<String> sessionList = [];
  List<EnrolledChallenge> enList = [];
  List<String> result;
  if (challengeDetail.challengeSessionDetail == "" &&
      challengeDetail.challengeHourDetails == '' &&
      challengeDetail.challengeHourDetails == 'N/A') {
    sessionList = [];
  } else if (challengeDetail.challengeSessionDetail != "" &&
      challengeDetail.challengeSessionDetail != 'N/A') {
    sessionList = challengeDetail.challengeSessionDetail.split(",");
  } else if (challengeDetail.challengeHourDetails != '' &&
      challengeDetail.challengeHourDetails != 'N/A') {
    result = HealthChallengeFunctions.splitTimeRange(challengeDetail.challengeHourDetails);

    for (var interval in result) {
      sessionList.add(interval);
    }
  } else {
    debugPrint(challengeDetail.challengeHourDetails);
    sessionList = [];
  }
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.only(top: 3.h, left: 5.w),
        child: Row(
          children: <Widget>[
          Text(AppTexts.logActivityText, style: AppTextStyles.fontSize14V4RegularStyle),
            const Spacer()
          ],
        ),
      ),
      enrolledChallenge==null?SizedBox(): Padding(
        padding: EdgeInsets.only(top: 3.h, left: 3.w),
        child: SizedBox(
          height: 6.h,
          // width: 90.w,
          child: GetBuilder<SessionSelectionController>(
              id: sessionSelectionController.dateUpdateId,
              initState: (v) async {
                await sessionSelectionController.firstDateGetter(
                    enrolledChallenge, challengeDetail);
                _scrollController.animateTo(
                  sessionSelectionController.isDaySelected.toDouble() * 20.w,
                  duration: Duration(seconds: 3),
                  curve: Curves.fastOutSlowIn,
                );
              },
              builder: (controller) {
                return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    itemCount: sessionSelectionController.dateList.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      return GestureDetector(
                        onTap: () {
                          sessionSelectionController.updateDaySelection(index);
                          sessionSelectionController.selectedDate =
                              sessionSelectionController.dateList[index]['date'];
                          sessionSelectionController.updateDayTextValue(
                              sessionSelectionController.dateList[index]['day']);
                          debugPrint(sessionSelectionController.selectedDate);
                        },
                        child: Obx(() {
                          return Container(
                            decoration: BoxDecoration(
                                color: sessionSelectionController.isDaySelected.value == index
                                    ? AppColors.lightPrimaryColor
                                    : Colors.white,
                                shape: BoxShape.rectangle,
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 2,
                                      color: Colors.grey.withOpacity(0.5),
                                      blurRadius: 3,
                                      offset: const Offset(1, 1))
                                ]),
                            margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.5.w),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 6.w),
                              child: Text("Day ${index + 1}",
                                  style: AppTextStyles.fontSize14b4RegularStyle),
                            ),
                          );
                        }),
                      );
                    });
              }),
        ),
      ),
      enrolledChallenge==null?SizedBox():sessionTile(
        sessionList,
      ),
      enrolledChallenge==null?SizedBox():Visibility(
        visible: challengeDetail.mileStoneTotalTarget != null,
        child: Padding(
          padding: EdgeInsets.only(top: 2.h, left: 5.w, bottom: 2.h),
          child: Row(
            children: <Widget>[
              Text("${AppTexts.enterNoText} ${challengeDetail.challengeUnit} ${challengeDetail.challengeUnit=="Millilitres"?"consumed :":"spent :"}",
                  style: TextStyle(color: Colors.black, fontFamily: 'Poppins', fontSize: 16.sp)),
              const Spacer()
            ],
          ),
        ),
      ),
      enrolledChallenge==null?SizedBox():Visibility(
        visible: challengeDetail.mileStoneTotalTarget != null,
        child: SizedBox(
          height: 8.h,
          width: 35.w,
          child: Form(
            key: key,
            child: TextFormField(
              autofocus: true,
              // enableInteractiveSelection:true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  hintText: 'Enter the ${challengeDetail.challengeUnit.capitalizeFirst}',
                  hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey)),
              controller: _stepsController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Enter the valid value!';
                }
                return null;
              },
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 128, 128, 128)),
            ),
          ),
        ),
      ),

      ///button to submit the text field value
      GetBuilder<SessionSelectionController>(
          id: Get.put(SessionSelectionController()).dayLoadingUpdate,
          builder: (SessionSelectionController controller) => Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.5.h),
                    child: GestureDetector(
                      onTap: () async {

                          controller.targetAdded = int.parse(challengeDetail.targetToAchieve ?? '0') +
                              int.parse(_stepsController.text=='' ? '0':_stepsController.text);
                          controller.isLoadinginSubmit.value=true;
                          controller.updateDayLoadingUpdate(true);
                          SharedPreferences prefs1 = await SharedPreferences.getInstance();
                          String iHLUserId = prefs1.getString("ihlUserId");
                          String userEmail = prefs1.getString("email");
                          if (firstTime) {
                            controller.targetAdded = int.parse(challengeDetail.targetToAchieve??"0") +
                                int.parse(_stepsController.text==''?'0':_stepsController.text);
                            List<EnrolledChallenge> enrolledChallenges = await ChallengeApi()
                                .listofUserEnrolledChallenges(userId: iHLUserId);
                            UserDetails userDetails = UserDetails(
                                userStartLocation:
                                challengeDetail.challenge_start_location_list.toString(),
                                selected_fitness_app: 'google fit',
                                userId: iHLUserId,
                                name: enrolledChallenges[0].name,
                                city: enrolledChallenges[0].city,
                                gender: enrolledChallenges[0].gender,
                                department: enrolledChallenges[0].department,
                                designation:enrolledChallenges[0].designation,
                                email: userEmail,
                                isGloble: challengeDetail.affiliations.contains("global") ||
                                    challengeDetail.affiliations.contains("Global"));
                            gs.write(GSKeys.userDetail, userDetails);
                            controller.joinIndividualOfGroupList = await ChallengeApi()
                                .userJoinIndividual(
                                joinIndividual: JoinIndividual(
                                    challengeId: challengeDetail.challengeId,
                                    userDetails: userDetails));
                            if (controller.joinIndividualOfGroupList) {
                              if (DateTime.now().isAfter(challengeDetail.challengeStartTime)) {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                var ihlId = prefs.getString("ihlUserId");
                                Get.delete<HealthChallengeController>();
                                enList = await ChallengeApi()
                                    .listofUserEnrolledChallenges(userId: ihlId);
                                Get
                                    .find<ListChallengeController>()
                                    .enrolledChallenegeList = enList;
                                enList.retainWhere((element) =>
                                element.challengeId == challengeDetail.challengeId);
                                controller.updateDayLoadingUpdate(false);
                                await ChallengeApi().updateChallengeTarget(
                                  updateChallengeTarget: UpdateChallengeTarget(
                                    enrollmentId: enList.first.enrollmentId,
                                    progressStatus: "progressing",
                                    achieved: _stepsController.text==''?'0':_stepsController.text,
                                    duration: "0",
                                    email: userEmail,
                                    firstTime: true,
                                    challengeEndTime: challengeDetail.challengeEndTime,
                                    challenge_type: challengeDetail.challengeType,
                                    logTime: DateTime.now(),
                                    speed: '',
                                    session: controller.isSessionSelected.value == 0
                                        ? ''
                                        : sessionList[controller.isSessionSelected.value],
                                    challengeStartTime: challengeDetail.challengeStartTime,
                                  ),
                                );
                                Get.snackbar('Success', 'Challenge Enrolled!!!',
                                    margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                    backgroundColor: AppColors.primaryColor,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 5),
                                    snackPosition: SnackPosition.BOTTOM);

                                controller.updateDayLoadingUpdate(true);

                              }
                            }


                          }
                          else {
                            DateTime userProvidedDate = DateFormat("MM/dd/yyyy")
                                .parse(sessionSelectionController.selectedDate==null?sessionSelectionController.dateList[0]['date']:sessionSelectionController.selectedDate);
                            controller.targetAdded = controller.targetAdded +
                                int.parse(_stepsController.text==''?'0':_stepsController.text);
                            // Add current time to the user-provided date
                            DateTime combinedDateTime = DateTime(
                                userProvidedDate.year,
                                userProvidedDate.month,
                                userProvidedDate.day,
                                DateTime
                                    .now()
                                    .hour,
                                DateTime
                                    .now()
                                    .minute,
                                DateTime
                                    .now()
                                    .second);

                            await ChallengeApi().updateChallengeTarget(
                              updateChallengeTarget: UpdateChallengeTarget(
                                enrollmentId: enrolledChallenge.enrollmentId,
                                progressStatus: "progressing",
                                achieved: _stepsController.text==''?'0':_stepsController.text,
                                duration: "0",
                                email: userEmail,
                                firstTime: false,
                                challengeEndTime: challengeDetail.challengeEndTime,
                                challenge_type: challengeDetail.challengeType,
                                logTime: combinedDateTime,
                                speed: '',
                                session: controller.isSessionSelected.value == 0
                                    ? ''
                                    : sessionList[controller.isSessionSelected.value],
                                challengeStartTime: challengeDetail.challengeStartTime,
                              ),
                            );
                            controller.updateDayLoadingUpdate(false);
                            await sessionSelectionController.firstDateGetter(
                                enrolledChallenge, challengeDetail);
                          }
                          controller.isLoadinginSubmit.value=false;
                          controller.updateDayLoadingUpdate(false);
                          controller.finallyCompleted.value=true;
                          controller.updateSetFinallyCompleted(true);
                          if (controller.targetAdded >
                              int.parse(challengeDetail.mileStoneTotalTarget)) {
                            controller.finishTarget=true;
                            controller.updatefinishTarget(true);
                          }
                          _stepsController.text='';

  //                     else{
  //   Get.snackbar('Warning', 'Please Don\'t will the field Empty.',
  //       margin: const EdgeInsets.all(20).copyWith(bottom: 40),
  //       backgroundColor: AppColors.primaryAccentColor,
  //       colorText: Colors.white,
  //       duration: const Duration(seconds: 5),
  //       snackPosition: SnackPosition.BOTTOM);
  // }
  }
                      ,
                      child: Container(
                        height: 4.h,
                        width: 25.w,
                        decoration: BoxDecoration(
                            color: AppColors.primaryAccentColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: Center(
                          child: controller.isLoadinginSubmit.value
                              ? SizedBox(
                                  width: 4.w,
                                  height: 2.h,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ))
                              : Text(
                                  enrolledChallenge==null?'Join':"Submit",
                                  style: AppTextStyles.boldWhiteText,
                                ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: challengeDetail.challengeRemaider && enrolledChallenge!=null,
                    child: SizedBox(
                      height: 12.h,
                      child: Card(
                        elevation: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(
                              Icons.alarm,
                              color: AppColors.primaryColor,
                              size: 25.sp,
                            ),
                            GestureDetector(
                              onTap: ()async{
                                EnrolledChallenge  enroll =
                                await ChallengeApi().getEnrollDetail(enrolledChallenge.enrollmentId);
                                sessionSelectionController.updateSetReminder(true);
                                  TimeOfDay picked = await showTimePicker(
                                    confirmText: 'SET',
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  List<Map<String, dynamic>> myList = [
                                    {
                                      'time':
                                      '${picked.hour}:${picked.minute} ${picked.hour >= 12 ? 'PM' : 'AM'}',
                                      'title': 'Set reminder title'
                                    }
                                  ];
                                  List _d = [];

                                  String _s =
                                      "{\"feature_setting\":{\"health_jornal\":true,\"challenges\":true,\"news_letter\":true,\"ask_ihl\":true,\"hpod_locations\":false,\"teleconsultation\":false,\"online_classes\":false,\"my_vitals\":true,\"step_counter\":false,\"heart_health\":true,\"set_your_goals\":false,\"diabetics_health\":false,\"personal_data\":true,\"health_tips\":true}}";
                                  if(enroll.reminder_detail=="&quot;&quot;"||enroll.reminder_detail=="null"){
                                    enroll.reminder_detail=_s;
                                  }
                                  Map _p = jsonDecode(enroll.reminder_detail.replaceAll("&quot;", "\""));
                                  if (_p.toString().contains('reminder')) {
                                    _d = _p['reminder']??[];
                                    print('yes$_d');
                                    Map<String, dynamic> myMap = {
                                      'time':
                                      '${picked.hour}:${picked.minute}',
                                      'title': 'Set reminder title'
                                    };
                                    _d.add(myMap);
                                    _p['reminder']= _d;
                                    print(_p['reminder']);
                                  } else {
                                    _p['reminder'] = myList;
                                  }
                                  var response = await Dio().post(
                                      '${API.iHLUrl}/healthchallenge/edit_reminder_detail',
                                      data: {
                                        "enrollment_id":enrolledChallenge.enrollmentId,
                                        "challenge_id": challengeDetail.challengeId,
                                        "reminder_detail": jsonEncode(_p)
                                      });
                                  print(response.data);
                                  await sessionSelectionController.getUserDetails(enrolledChallenge);
                                var iosPlatfrom = IOSNotificationDetails();
                                var androidPlatformChannelSpecifics = AndroidNotificationDetails(
                                  'alarm_channel',
                                  'Alarm channel',
                                  channelDescription: 'for alarm_channel',
                                  importance: Importance.max,
                                  priority: Priority.high,
                                  channelShowBadge: true,
                                  // sound: RawResourceAndroidNotificationSound('custom_ringtone'), // Replace with the actual name of your custom ringtone file
                                  ticker: 'ticker',
                                  icon: 'app_icon',
                                );
                                var platformChannelSpecifics = NotificationDetails(
                                  android: androidPlatformChannelSpecifics,
                                  iOS: iosPlatfrom,
                                );
                                Random random = new Random();
                                DateTime scheduledTime = DateTime(
                                  DateTime.now().year,  // You might want to customize the year, month, and day based on your requirements
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  picked.hour,
                                  picked.minute,
                                );
                                FlutterAlarmClock.createAlarm(picked.hour.hours.inHours, picked.minute.minutes.inMinutes,
                                    title: challengeDetail.challengeName);
                                await flutterLocalNotificationsPlugin.schedule(
                                    random.nextInt(100),
                                    challengeDetail.challengeName,
                                    ' (Duration : ${picked.hour}:${picked.minute} in Min)',
                                    scheduledTime, // Example: Set alarm after 10 seconds
                                    platformChannelSpecifics);
                                  print(
                                      '${picked.hour}:${picked.minute} ${picked.hour >= 12 ? 'PM' : 'AM'}');

                              },
                              child: SizedBox(
                                  width: 55.w,
                                  child: Text(AppTexts.askForRemainder,
                                      style: AppTextStyles.fontSize14V5RegularStyle)),
                            ),
                        GetBuilder<SessionSelectionController>(
                            id: "setReminderId",
                            initState: (GetBuilderState<SessionSelectionController> v) async {
                              v.controller.getUserDetails(enrolledChallenge);
                            },
                          builder: (SessionSelectionController controller) =>  Switch(
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.grey,
                                  value:
                                  controller.reminderList==null || controller.reminderList.isEmpty ?false:true,
                                  onChanged: (bool v) async {
                                    EnrolledChallenge  enroll =
                                    await ChallengeApi().getEnrollDetail(enrolledChallenge.enrollmentId);
                                    controller.updateSetReminder(v);
                                    if (v) {
                                      TimeOfDay picked = await showTimePicker(
                                        confirmText: 'SET',
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      List<Map<String, dynamic>> myList = [
                                        {
                                          'time':
                                              '${picked.hour}:${picked.minute} ${picked.hour >= 12 ? 'PM' : 'AM'}',
                                          'title': 'Set reminder title'
                                        }
                                      ];
                                      List _d = [];

                                      String _s =
                                          "{\"feature_setting\":{\"health_jornal\":true,\"challenges\":true,\"news_letter\":true,\"ask_ihl\":true,\"hpod_locations\":false,\"teleconsultation\":false,\"online_classes\":false,\"my_vitals\":true,\"step_counter\":false,\"heart_health\":true,\"set_your_goals\":false,\"diabetics_health\":false,\"personal_data\":true,\"health_tips\":true}}";
                                     if(enroll.reminder_detail=="&quot;&quot;"||enroll.reminder_detail=="null"){
                                       enroll.reminder_detail=_s;
                                     }
                                      Map _p = jsonDecode(enroll.reminder_detail.replaceAll("&quot;", "\""));
                                      if (_p.toString().contains('reminder')) {
                                        _d = _p['reminder']??[];
                                        print('yes$_d');
                                        Map<String, dynamic> myMap = {
                                          'time':
                                              '${picked.hour}:${picked.minute}',
                                          'title': 'Set reminder title'
                                        };
                                        _d.add(myMap);
                                        _p['reminder']= _d;
                                        print(_p['reminder']);
                                      } else {
                                        _p['reminder'] = myList;
                                      }
                                      var response = await Dio().post(
                                          '${API.iHLUrl}/healthchallenge/edit_reminder_detail',
                                          data: {
                                            "enrollment_id":enrolledChallenge.enrollmentId,
                                            "challenge_id": challengeDetail.challengeId,
                                            "reminder_detail": jsonEncode(_p)
                                          });
                                      print(response.data);
                                     await controller.getUserDetails(enrolledChallenge);
                                      print(
                                          '${picked.hour}:${picked.minute} ${picked.hour >= 12 ? 'PM' : 'AM'}');
                                      Get.back();
                                    }
                            }))
                          ],
                        ),
                      ),
                    ))
                ],
              )),
    ],
  );
}


Widget sessionTile(
  List<String> sessionList,
) {
  bool sessionS = true;
  SessionSelectionController sessionSelectionController = Get.put(SessionSelectionController());
  if (sessionList.toString().contains("quot") || sessionList.isEmpty) {
    sessionS = false;
  }
  return Visibility(
    visible: sessionS,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
      child: SizedBox(
        height: 6.h,
        // width: 90.w,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sessionList.length,
            itemBuilder: (BuildContext ctx, int index) {
              return GestureDetector(
                onTap: () {
                  sessionSelectionController.updateSessionSelection(index);
                  try {
                    sessionSelectionController.selectedTime =
                        HealthChallengeFunctions.convertTimeFormat(sessionList[index]);
                  } catch (e) {
                    sessionSelectionController.selectedTime =
                        HealthChallengeFunctions.findTimeForSession(sessionList[index]);
                  }
                },
                child: Obx(() {
                  return Container(
                    // elevation: 3,
                    decoration: BoxDecoration(
                        color: sessionSelectionController.isSessionSelected.value == index
                            ? AppColors.lightPrimaryColor
                            : Colors.white,
                        shape: BoxShape.rectangle,
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 2,
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 3,
                              offset: const Offset(1, 1))
                        ]),
                    margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.5.w),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 6.w),
                      child:
                          Text(sessionList[index], style: AppTextStyles.fontSize14b4RegularStyle),
                    ),
                  );
                }),
              );
            }),
      ),
    ),
  );
}
