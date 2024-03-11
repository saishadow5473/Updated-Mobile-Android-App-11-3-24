import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/new_design/presentation/controllers/dashboardControllers/upComingDetailsController.dart';
import '../../../../health_challenge/views/certificate_detail.dart';
import '../../../data/functions/healthChallengeFunctions.dart';
import '../../../presentation/controllers/healthchallenge/googlefitcontroller.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../../constants/spKeys.dart';
import '../../../../health_challenge/controllers/challenge_api.dart';
import '../../../../health_challenge/models/group_details_model.dart';
import '../../../../health_challenge/models/list_of_users_in_group.dart';
import '../../../../health_challenge/models/update_challenge_target_model.dart';
import '../../../../main.dart';
import '../../../../views/marathon/preCertificate.dart';
import 'package:ihl/new_design/data/model/retriveUpcomingDetails/upcomingDetailsModel.dart';

import '../../../presentation/pages/healthChalleneg/challengeCompleted.dart';

class UpdateChallengeServices {
  static Future updateChallenge(
      {EnrolledChallenge enrolledChallenge, GoogleFitController googleFitController}) async {
    // check current enroll status because once challenge completed it's again again updated completed so that checked the enroll status
    var _enroll = await ChallengeApi().getEnrollDetail(enrolledChallenge.enrollmentId);
    if (_enroll.userProgress != 'completed') {
      GroupDetailModel groupDetailModel;
      var _challengeDetail =
          await ChallengeApi().challengeDetail(challengeId: enrolledChallenge.challengeId);
      var _listGroupUsers = [];
      if (_enroll.challengeMode == "group") {
        groupDetailModel = await ChallengeApi().challengeGroupDetail(groupID: _enroll.groupId);
        _listGroupUsers = await ChallengeApi().listofGroupUsers(groupId: _enroll.groupId);
      }
      if (_enroll.challengeMode == "group" &&
              _listGroupUsers.length >= _challengeDetail.minUsersGroup ||
          _enroll.challengeMode != "group") {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        var _user = _prefs.getString(SPKeys.userData);
        Map res = jsonDecode(_user);
        // Update the user progress in google fit
        await googleFitController.updateGoogleFit(
          int.parse(enrolledChallenge.last_updated ?? DateTime.now().millisecondsSinceEpoch),
        );
        // Get the challenge detail

        var b6;
        var imgB6;
        // Get the email from the user data
        var email = res['User']['email'] ?? localSotrage.read(LSKeys.email);
        // Check if the challenge is a group challenge

        // Get the previous progress
        var _prev = enrolledChallenge.userAchieved / enrolledChallenge.target * 100;
        // Get the current progress
        var _currentTotal =
            (enrolledChallenge.challengeUnit == 'steps' || enrolledChallenge.challengeUnit == 's')
                ? ((enrolledChallenge.userAchieved + googleFitController.steps) /
                        enrolledChallenge.target) *
                    100
                : enrolledChallenge.challengeUnit == 'm'
                    ? (((enrolledChallenge.userAchieved) + (googleFitController.distance)) /
                            enrolledChallenge.target) *
                        100
                    : (((enrolledChallenge.userAchieved) + (googleFitController.distance / 1000)) /
                            enrolledChallenge.target) *
                        100;
        // Get the total progress
        var _total = 0.0;

        // Check if the challenge is a group challenge
        if (enrolledChallenge.challengeMode == 'group') {
          // Get the total progress
          _total =
              (enrolledChallenge.challengeUnit == 'steps' || enrolledChallenge.challengeUnit == 's')
                  ? enrolledChallenge.groupAchieved + googleFitController.steps
                  : enrolledChallenge.challengeUnit == 'm'
                      ? enrolledChallenge.groupAchieved + googleFitController.distance
                      : enrolledChallenge.groupAchieved + googleFitController.distance / 1000;
        } else {
          // Get the total progress
          _total =
              (enrolledChallenge.challengeUnit == 'steps' || enrolledChallenge.challengeUnit == 's')
                  ? enrolledChallenge.userAchieved + googleFitController.steps
                  : enrolledChallenge.challengeUnit == 'm'
                      ? enrolledChallenge.userAchieved + googleFitController.distance
                      : enrolledChallenge.userAchieved + googleFitController.distance / 1000;
        }
        if (_total >= enrolledChallenge.target ||
            enrolledChallenge.challenge_end_time.isBefore(DateTime.now()) &&
                (DateFormat('MM-dd-yyyy').format(enrolledChallenge.challenge_end_time).toString() !=
                    "01-01-2000")) {
          b6 = await preCertifiacte(
              Get.context,
              enrolledChallenge.name,
              "Completed",
              "Hello",
              "Time",
              " ",
              _challengeDetail,
              enrolledChallenge,
              enrolledChallenge.groupId != null ? groupDetailModel.groupName : " ",
              enrolledChallenge.userduration < 1
                  ? 1
                  : (enrolledChallenge.userduration ~/ 1440).toInt().toString());
          imgB6 = await imgPreCertifiacte(
              Get.context,
              enrolledChallenge.name,
              "Completed",
              "Hello",
              "Time",
              " ",
              _challengeDetail,
              enrolledChallenge,
              enrolledChallenge.groupId != null ? groupDetailModel.groupName : " ",
              enrolledChallenge.userduration < 1
                  ? 1
                  : (enrolledChallenge.userduration ~/ 1440).toInt().toString());
        }
        if (enrolledChallenge.challenge_start_time.isBefore(DateTime.now())) {
          if (enrolledChallenge.groupId == null || enrolledChallenge.groupId == '') {
            if (_prev <= 25 &&
                _currentTotal >= 25 &&
                _currentTotal.toInt() < enrolledChallenge.target) {
              await flutterLocalNotificationsPlugin.show(
                1,
                'Water Reminder',
                'Hey,Drink Water now! Since You have Completed 25 percentage of your ${enrolledChallenge.challenge_name} Challenge.',
                waterReminder,
                payload: jsonEncode({'text': 'Water Reminder'}),
              );
            } else if (_prev <= 75 &&
                _currentTotal >= 75 &&
                _currentTotal.toInt() < enrolledChallenge.target) {
              await flutterLocalNotificationsPlugin.show(
                1,
                'Water Reminder',
                'Hey,Drink Water now! Since You have Completed 75 percentage of your ${enrolledChallenge.challenge_name} Challenge',
                waterReminder,
                payload: jsonEncode({'text': 'Water Reminder'}),
              );
            }
            if (enrolledChallenge.userProgress == "progressing") {
              await ChallengeApi().updateChallengeTarget(
                updateChallengeTarget: UpdateChallengeTarget(
                  firstTime: false,
                  challengeEndTime: _challengeDetail.challengeEndTime,
                  achieved: ((enrolledChallenge.challengeUnit == 'steps' ||
                              enrolledChallenge.challengeUnit == 's')
                          ? googleFitController.steps.toInt()
                          : enrolledChallenge.challengeUnit == 'm'
                              ? googleFitController.distance
                              : googleFitController.distance / 1000)
                      .toString(),
                  enrollmentId: enrolledChallenge.enrollmentId,
                  duration: googleFitController.duration.toString(),
                  progressStatus: (_total >= enrolledChallenge.target ||
                          enrolledChallenge.challenge_end_time.isBefore(DateTime.now()) &&
                              (DateFormat('MM-dd-yyyy')
                                      .format(enrolledChallenge.challenge_end_time)
                                      .toString() !=
                                  "01-01-2000"))
                      ? 'completed'
                      : 'progressing',
                  certificateBase64: b6,
                  email: email,
                  certificatePngBase64: imgB6,
                ),
              );
              if (_total >= enrolledChallenge.target ||
                  enrolledChallenge.challenge_end_time.isBefore(DateTime.now()) &&
                      (DateFormat('MM-dd-yyyy')
                              .format(enrolledChallenge.challenge_end_time)
                              .toString() !=
                          "01-01-2000")) {
                if (HealthChallengeFunctions().isRouteValid(Get.currentRoute) &&
                    !Get.isDialogOpen) {
                  //Temp fix for the vibration cause it's crashing the IOS 15 to 17⚪️⚪️
                  // Vibration.vibrate(pattern: [500, 1000, 500]);
                  AudioPlayer().play(AssetSource('audio/challenge_completed.mp3'));
                  Get.defaultDialog(
                      barrierDismissible: false,
                      backgroundColor: Colors.lightBlue.shade50,
                      title: 'Kudos!',
                      titlePadding: const EdgeInsets.only(top: 20, bottom: 5, right: 10, left: 10),
                      titleStyle:
                          TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                      contentPadding: const EdgeInsets.only(top: 0),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 70.w,
                            child: const Text(
                              "You completed the run successfully.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.task_alt,
                            size: 40,
                            color: Colors.blue.shade300,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () async {
                              var _enrolledChallenge = await ChallengeApi()
                                  .getEnrollDetail(enrolledChallenge.enrollmentId);
                              var _challengeDetail = await ChallengeApi()
                                  .challengeDetail(challengeId: enrolledChallenge.challengeId);
                              Get.back();
                              GroupDetailModel _groupModel;
                              _enrolledChallenge.userAchieved = enrolledChallenge.target.toDouble();
                              if (_enrolledChallenge.groupId != null ||
                                  _enrolledChallenge.groupId == '') {
                                _groupModel = await ChallengeApi()
                                    .challengeGroupDetail(groupID: _enrolledChallenge.groupId);
                              }
                              Get.to(ChallengeCompleted(
                                challengeDetail: _challengeDetail,
                                enrolledChallenge: _enrolledChallenge,
                                firstCopmlete: true,
                                currentUserIsAdmin: false,
                                groupDetail: _groupModel,
                              ));
                              // Get.to(CertificateDetail(
                              //   challengeDetail: challengeDetail,
                              //   enrolledChallenge: enrolledChallenge,
                              //   firstCopmlete: false,
                              // ));
                            },
                            child: Container(
                              width: 40.w,
                              decoration: BoxDecoration(
                                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Ok',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ));
                }
                Get.put(UpcomingDetailsController()).updateUpcomingDetails(fromChallenge: false);
              } else {
                null;
              }
            } else {}
          } else {
            ChallengeDetail challengeDetail =
                await ChallengeApi().challengeDetail(challengeId: enrolledChallenge.challengeId);
            List<GroupUser> listofGroupUsers =
                await ChallengeApi().listofGroupUsers(groupId: enrolledChallenge.groupId);

            if (challengeDetail.minUsersGroup > listofGroupUsers.length) {
              return null;
            } else {
              if (_prev <= 25 &&
                  _currentTotal >= 25 &&
                  _currentTotal.toInt() < enrolledChallenge.target) {
                await flutterLocalNotificationsPlugin.show(
                  1,
                  'Water Reminder',
                  'Hey,Drink Water now! Since You have Completed 25 percentage of your ${challengeDetail.challengeName} Challenge.',
                  waterReminder,
                  payload: jsonEncode({'text': 'Water Reminder'}),
                );
              } else if (_prev <= 75 &&
                  _currentTotal >= 75 &&
                  _currentTotal.toInt() < enrolledChallenge.target) {
                await flutterLocalNotificationsPlugin.show(
                  1,
                  'Water Reminder',
                  'Hey,Drink Water now! Since You have Completed 75 percentage of your ${challengeDetail.challengeName} Challenge',
                  waterReminder,
                  payload: jsonEncode({'text': 'Water Reminder'}),
                );
              }
              if (enrolledChallenge.userProgress != null) {
                await ChallengeApi().updateChallengeTarget(
                  updateChallengeTarget: UpdateChallengeTarget(
                    firstTime: false,
                    challengeEndTime: _challengeDetail.challengeEndTime,
                    achieved: ((challengeDetail.challengeUnit == 'steps' ||
                                challengeDetail.challengeUnit == 's')
                            ? googleFitController.steps.toInt()
                            : challengeDetail.challengeUnit == 'm'
                                ? googleFitController.distance
                                : googleFitController.distance / 1000)
                        .toString(),
                    enrollmentId: enrolledChallenge.enrollmentId,
                    duration: googleFitController.duration.toString(),
                    progressStatus: (_total >= enrolledChallenge.target ||
                            challengeDetail.challengeEndTime.isBefore(DateTime.now()) &&
                                (DateFormat('MM-dd-yyyy')
                                        .format(challengeDetail.challengeEndTime)
                                        .toString() !=
                                    "01-01-2000"))
                        ? 'completed'
                        : 'progressing',
                    certificateBase64: b6,
                    email: email,
                    certificatePngBase64: imgB6,
                  ),
                );

                if (_total >= enrolledChallenge.target ||
                    challengeDetail.challengeEndTime.isBefore(DateTime.now()) &&
                        (DateFormat('MM-dd-yyyy')
                                .format(challengeDetail.challengeEndTime)
                                .toString() !=
                            "01-01-2000")) {
                  if (HealthChallengeFunctions().isRouteValid(Get.currentRoute) &&
                      !Get.isDialogOpen) {
                    //Temp fix for the vibration cause it's crashing the IOS 15 to 17⚪️⚪️
                    // Vibration.vibrate(pattern: [500, 1000, 500]);
                    Get.defaultDialog(
                        barrierDismissible: true,
                        backgroundColor: Colors.lightBlue.shade50,
                        title: 'Kudos!',
                        titlePadding:
                            const EdgeInsets.only(top: 20, bottom: 0, right: 10, left: 10),
                        titleStyle:
                            TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                        contentPadding: const EdgeInsets.only(top: 0),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Padding(
                              padding: EdgeInsets.all(15),
                              child: Text(
                                "You completed the run successfully.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.task_alt,
                              size: 40,
                              color: Colors.blue.shade300,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            GestureDetector(
                              onTap: () async {
                                Get.back();
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                var k = jsonDecode(prefs.getString(SPKeys.jUserData));
                                var userUid = k["User"]["id"];
                                var _enrolledChallenge = await ChallengeApi()
                                    .getEnrollDetail(enrolledChallenge.enrollmentId);
                                bool currentUserIsAdmin = false;
                                await ChallengeApi()
                                    .listofGroupUsers(groupId: _enrolledChallenge.groupId)
                                    .then((value) {
                                  for (var i in value) {
                                    if (i.userId == userUid && i.role == "admin") {
                                      currentUserIsAdmin = true;
                                      break;
                                    }
                                  }
                                });
                                GroupDetailModel _groupDetail = await ChallengeApi()
                                    .challengeGroupDetail(groupID: _enrolledChallenge.groupId);
                                Get.to(CertificateDetail(
                                  challengeDetail: challengeDetail,
                                  enrolledChallenge: _enrolledChallenge,
                                  firstCopmlete: true,
                                  currentUserIsAdmin: currentUserIsAdmin,
                                  groupDetail: _groupDetail,
                                ));
                              },
                              child: Container(
                                width: 40.w,
                                decoration: BoxDecoration(
                                    color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                                child: const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Ok',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ));
                    AudioPlayer().play(AssetSource('audio/challenge_completed.mp3'));
                  }
                } else {
                  null;
                }
              } else {}
            }
          }
        }
      } else {
        debugPrint('Minimum User not Joined');
      }
    } else {
      debugPrint('Already Completed');
    }
  }
}
