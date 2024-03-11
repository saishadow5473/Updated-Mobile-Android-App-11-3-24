import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health/health.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/join_individual.dart';
import 'package:ihl/health_challenge/persistent/views/persistent_otherAppDescriptionScreen.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/spKeys.dart';
import '../../new_design/presentation/pages/home/home_view.dart';
import '../../utils/app_colors.dart';
import '../../views/splash_screen.dart';
import '../controllers/challenge_api.dart';
import '../models/enrolled_challenge.dart';
import '../views/on_going_challenge.dart';

class CustomDialog {
  googleFitDia() {
    Get.defaultDialog(
      title: '',
      titlePadding: EdgeInsets.only(),
      // barrierDismissible: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
            onPressed: () async {
              final types = [
                HealthDataType.STEPS,
                HealthDataType.ACTIVE_ENERGY_BURNED,
              ];
              if (Platform.isIOS) {
                types.add(HealthDataType.DISTANCE_WALKING_RUNNING);
                types.add(HealthDataType.EXERCISE_TIME);
              } else {
                types.add(HealthDataType.DISTANCE_DELTA);
                types.add(HealthDataType.MOVE_MINUTES);
              }
              final permissions = [
                HealthDataAccess.READ,
                HealthDataAccess.READ,
                HealthDataAccess.READ,
                HealthDataAccess.READ,
              ];
              if (Platform.isAndroid) {
                bool t = await LaunchApp.isAppInstalled(
                    androidPackageName: "com.google.android.apps.fitness");
                bool signed = gs.read('fit') ?? false;

                if (t && !signed) {
                  try {
                    GoogleSignIn _googleSignIn = GoogleSignIn(
                      scopes: [
                        'email',
                        'https://www.googleapis.com/auth/contacts.readonly',
                      ],
                    );
                    final HealthFactory health = HealthFactory();
                    await _googleSignIn.signOut();
                    await health
                        .requestAuthorization(types, permissions: permissions)
                        .then((value) async {
                      SharedPreferences _prefs = await SharedPreferences.getInstance();
                      _prefs.setBool('fit', value);
                      final box = GetStorage();
                      box.write('fit', value);
                      signed = value;
                      Get.back();
                      Get.snackbar('Success', 'Connected Successfully',
                          margin: EdgeInsets.all(20).copyWith(bottom: 40),
                          backgroundColor: AppColors.primaryAccentColor,
                          colorText: Colors.white,
                          duration: Duration(seconds: 5),
                          snackPosition: SnackPosition.BOTTOM);
                    });
                  } catch (e) {}
                }
                if (t && signed) {
                  ChallengeDetail _challengeDetail = gs.read(GSKeys.challengeDetail);
                  UserDetails _userDetails = gs.read(GSKeys.userDetail);
                  bool individualJoined = false;
                  individualJoined = await ChallengeApi().userJoinIndividual(
                      joinIndividual: JoinIndividual(
                          challengeId: _challengeDetail.challengeId, userDetails: _userDetails));
                  if (individualJoined) {
                    print(DateFormat('MM-dd-yyyy')
                        .format(_challengeDetail.challengeStartTime)
                        .toString());
                    getdef(showD: 1, challengeDetail: _challengeDetail, userDetails: _userDetails);
                  }
                } else {
                  await LaunchApp.openApp(
                      openStore: true, androidPackageName: "com.google.android.apps.fitness");
                }
              } else {
                final HealthFactory health = HealthFactory();
                await health.requestAuthorization(types, permissions: permissions);
                ChallengeDetail _challengeDetail = gs.read(GSKeys.challengeDetail);
                UserDetails _userDetails = gs.read(GSKeys.userDetail);
                SharedPreferences _prefs = await SharedPreferences.getInstance();
                _prefs.setBool('fit', true);
                gs.write('fit', true);
                bool individualJoined = false;
                individualJoined = await ChallengeApi().userJoinIndividual(
                    joinIndividual: JoinIndividual(
                        challengeId: _challengeDetail.challengeId, userDetails: _userDetails));
                if (individualJoined) {
                  print(DateFormat('MM-dd-yyyy')
                      .format(_challengeDetail.challengeStartTime)
                      .toString());
                  getdef(showD: 1, challengeDetail: _challengeDetail, userDetails: _userDetails);
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    height: Platform.isAndroid ? 20.sp : 25.sp,
                    child: Platform.isAndroid
                        ? Image.asset("assets/icons/googlefit.png")
                        : Image.asset(
                            "assets/icons/health_icon.png",
                            height: 25.sp,
                          ),
                  ),
                ),
                Text(
                  Platform.isAndroid ? "Google Fit" : "Health",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              padding: Platform.isAndroid
                  ? EdgeInsets.fromLTRB(28, 7, 28, 7)
                  : EdgeInsets.fromLTRB(40, 7, 40, 7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.to(OtherAppsDescription());
            },
            child: Text(
              'Other Apps',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueGrey.shade300,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.fromLTRB(35, 7, 35, 7),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.lightBlue),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getdef({int showD, ChallengeDetail challengeDetail, UserDetails userDetails}) {
    if (showD == 1)
      Get.defaultDialog(
          barrierDismissible: false,
          backgroundColor: Colors.lightBlue.shade50,
          title: 'Welcome aboard!',
          titlePadding: EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
          titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
          contentPadding: EdgeInsets.only(top: 0),
          content: Column(
            children: [
              Divider(
                thickness: 2,
              ),
              Icon(
                Icons.task_alt,
                size: 50,
                color: Colors.blue.shade300,
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () async {
                  List<EnrolledChallenge> enList =
                      await ChallengeApi().listofUserEnrolledChallenges(userId: userDetails.userId);
                  enList
                      .retainWhere((element) => element.challengeId == challengeDetail.challengeId);

                  Get.off(OnGoingChallenge(
                      groupDetail: null,
                      filteredList: enList.first,
                      navigatedNormal: false,
                      challengeDetail: challengeDetail));
                },
                child: Container(
                  width: Get.width / 4,
                  decoration:
                      BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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

    if (showD == 2)
      Get.defaultDialog(
          barrierDismissible: false,
          backgroundColor: Colors.lightBlue.shade50,
          title: 'Welcome aboard!',
          titlePadding: EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
          titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
          contentPadding: EdgeInsets.only(top: 0),
          content: Column(
            children: [
              Divider(
                thickness: 2,
              ),
              Icon(
                Icons.task_alt,
                size: 50,
                color: Colors.blue.shade300,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Run will be active from ${Jiffy(challengeDetail.challengeStartTime).format("do MMM yyyy")}",
                textAlign: TextAlign.center,
                style: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  Get.offAll(LandingPage());
                },
                child: Container(
                  width: Get.width / 4,
                  decoration:
                      BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
}
