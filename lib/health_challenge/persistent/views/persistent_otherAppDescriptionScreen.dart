import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health/health.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/health_challenge/persistent/views/persistent_onGoingScreen.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../new_design/presentation/pages/home/home_view.dart';
import '../../../utils/app_colors.dart';
import '../../../views/home_screen.dart';
import '../../../views/splash_screen.dart';
import '../../controllers/challenge_api.dart';
import '../../models/challenge_detail.dart';
import '../../models/enrolled_challenge.dart';
import '../../models/join_individual.dart';
import '../../views/on_going_challenge.dart';

class OtherAppsDescription extends StatefulWidget {
  @override
  State<OtherAppsDescription> createState() => _OtherAppsDescriptionState();
}

class _OtherAppsDescriptionState extends State<OtherAppsDescription> {
  ChallengeDetail _challengeDetail;
  bool _buttonLoading = false;
  UserDetails _userDetails;

  @override
  Widget build(BuildContext context) {
    _challengeDetail = gs.read(GSKeys.challengeDetail);
    _userDetails = gs.read(GSKeys.userDetail);
    _userDetails.selected_fitness_app = 'other_apps';
    String distance = "30Km";
    String challangeName = "Challenge Name";
    bool buttonLoading;
    return WillPopScope(
      onWillPop: () {
        if (!_buttonLoading) {
          return Future.value(true);
        } else {
          return Future.value(false);
        }
      },
      child: ScrollessBasicPageUI(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text("Others", style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              if (_buttonLoading) {
              } else {
                Get.back();
              }
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              width: Device.width,
              child: SizedBox(
                height: Device.width / 1.3,
                width: Device.width / 1.3,
                child: Image.asset("assets/images/Group 142.png"),
              ),
            ),
            SizedBox(
              height: 4.h,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(1, 1),
                          spreadRadius: 4,
                          blurRadius: 5,
                          color: Colors.grey.shade300)
                    ]),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: Device.width / 1.2,
                      child: Text(
                        "By selecting other Apps you agree to use any of your favourite GPS enabled distance calculation apps during ${_challengeDetail.challengeName} and you also agree to take a screenshot after completing ${_challengeDetail.targetToAchieve + " " + _challengeDetail.challengeUnit} distance.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 16.5.sp,
                          fontFamily: "Poppins",
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    SizedBox(
                      width: Device.width / 1.2,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Note : ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    fontSize: 16.5.sp)),
                            TextSpan(
                              text:
                                  'Uploaded screenshot will be validated and certificate will be issued.',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 16.5.sp,
                                fontFamily: "Poppins",
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: Device.width / 3,
                          child: ElevatedButton(
                            child: Text('Yes, I Agree',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: Device.width < 300 ? 13 : 15.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontFamily: 'Poppins',
                                    color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: const Color.fromRGBO(25, 169, 229, 1)),
                            onPressed: () async {
                              Get.defaultDialog(
                                  barrierDismissible: false,
                                  backgroundColor: Colors.lightBlue.shade50,
                                  title: 'Joining',
                                  titlePadding: const EdgeInsets.only(
                                      top: 20, bottom: 0, left: 10, right: 10),
                                  titleStyle: TextStyle(
                                      letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                                  contentPadding: const EdgeInsets.only(top: 0),
                                  content: const CircularProgressIndicator());

                              bool individualJoined = false;

                              individualJoined = await ChallengeApi().userJoinIndividual(
                                  joinIndividual: JoinIndividual(
                                      challengeId: _challengeDetail.challengeId,
                                      userDetails: _userDetails));
                              print(individualJoined);
                              if (individualJoined) {
                                getdef(showD: 1);
                                // if (DateFormat('MM-dd-yyyy')
                                //             .format(_challengeDetail.challengeStartTime)
                                //             .toString() !=
                                //         "01-01-2000" &&
                                //     DateTime.now().isAfter(_challengeDetail.challengeStartTime)) {
                                //   getdef(showD: 1);
                                // } else {
                                //   getdef(showD: 2);
                                // }
                              }
                              // Get.to(PersistentOnGoingScreen(challengeStarted: true));
                            },
                          ),
                        ),
                        SizedBox(
                          width: Device.width / 3,
                          child: ElevatedButton(
                            child: Text('Decline',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: Device.width < 300 ? 13 : 15.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontFamily: 'Poppins',
                                    color: Colors.blueGrey)),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: const BorderSide(color: Colors.blueGrey)),
                                backgroundColor: Colors.white),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2.h,
                    )
                  ],
                ),
              ),
            ),
            Platform.isAndroid
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                    child: Container(
                      width: Device.width / 1.1,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(1, 1),
                                spreadRadius: 4,
                                blurRadius: 5,
                                color: Colors.grey.shade300)
                          ]),
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          SizedBox(
                            width: Device.width / 1.2,
                            child: Text(
                              "We recommend to use google fit for better experience",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 16.5.sp,
                                fontFamily: "Poppins",
                                height: 1.3,
                                // letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: Device.width / 2.5,
                            child: ElevatedButton(
                                child: Text('Use ${Platform.isAndroid ? "Google Fit" : "Health"}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: Device.width < 300 ? 13 : 15.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        fontFamily: 'Poppins',
                                        color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: const Color.fromRGBO(25, 169, 229, 1)),
                                onPressed: () async {
                                  _buttonLoading = true;
                                  var prefs = await SharedPreferences.getInstance();

                                  bool t = false;
                                  if (Platform.isAndroid) {
                                    t = await LaunchApp.isAppInstalled(
                                        androidPackageName: "com.google.android.apps.fitness");
                                  } else {
                                    t = true;
                                  }

                                  bool signed = gs.read('fit') ?? false;
                                  signed = prefs.getBool('fit') ?? false;
                                  final types = [
                                    HealthDataType.STEPS,
                                    HealthDataType.ACTIVE_ENERGY_BURNED,
                                    HealthDataType.DISTANCE_DELTA,
                                    HealthDataType.MOVE_MINUTES,
                                  ];

                                  final permissions = [
                                    HealthDataAccess.READ,
                                    HealthDataAccess.READ,
                                    HealthDataAccess.READ,
                                    HealthDataAccess.READ,
                                  ];

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
                                      var _authenticate = await health.requestAuthorization(types,
                                          permissions: permissions);
                                      if (_authenticate) {
                                        final box = GetStorage();
                                        SharedPreferences _prefs =
                                            await SharedPreferences.getInstance();
                                        _prefs.setBool('fit', _authenticate);
                                        box.write("fit", _authenticate);
                                        signed = _authenticate;
                                        _buttonLoading = false;
                                        Get.snackbar('Success', 'Connected Successfully',
                                            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                            backgroundColor: AppColors.primaryAccentColor,
                                            colorText: Colors.white,
                                            duration: const Duration(seconds: 5),
                                            snackPosition: SnackPosition.BOTTOM);
                                      } else {
                                        prefs.setBool("fit", _authenticate);
                                        gs.write("fit", _authenticate);
                                        signed = _authenticate;
                                        Get.back();
                                        _buttonLoading = false;
                                        Get.snackbar(
                                            'Connection Error', 'Unable to connect to Google Fit.',
                                            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                            backgroundColor: AppColors.failure,
                                            colorText: Colors.white,
                                            duration: const Duration(seconds: 5),
                                            snackPosition: SnackPosition.BOTTOM);
                                      }
                                    } catch (e) {
                                      _buttonLoading = false;
                                      Get.snackbar(
                                          'Connection Error', 'Unable to connect to Google Fit.',
                                          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                          backgroundColor: AppColors.failure,
                                          colorText: Colors.white,
                                          duration: const Duration(seconds: 5),
                                          snackPosition: SnackPosition.BOTTOM);
                                    }
                                  }
                                  if (t && signed) {
                                    ChallengeDetail _challengeDetail =
                                        gs.read(GSKeys.challengeDetail);
                                    UserDetails _userDetails = gs.read(GSKeys.userDetail);
                                    bool individualJoined = false;
                                    _userDetails.selected_fitness_app = 'google fit';
                                    individualJoined = await ChallengeApi().userJoinIndividual(
                                        joinIndividual: JoinIndividual(
                                            challengeId: _challengeDetail.challengeId,
                                            userDetails: _userDetails));
                                    if (individualJoined) {
                                      _buttonLoading = false;
                                      Get.defaultDialog(
                                          barrierDismissible: false,
                                          backgroundColor: Colors.lightBlue.shade50,
                                          title: 'Welcome aboard!',
                                          titlePadding: EdgeInsets.only(
                                              top: 20, bottom: 0, left: 10, right: 10),
                                          titleStyle: TextStyle(
                                              letterSpacing: 1,
                                              color: Colors.blue.shade400,
                                              fontSize: 20),
                                          contentPadding: const EdgeInsets.only(top: 0),
                                          content: Column(
                                            children: [
                                              const Divider(
                                                thickness: 2,
                                              ),
                                              Icon(
                                                Icons.task_alt,
                                                size: 50,
                                                color: Colors.blue.shade300,
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  _buttonLoading = false;
                                                  List<EnrolledChallenge> enList =
                                                      await ChallengeApi()
                                                          .listofUserEnrolledChallenges(
                                                              userId: _userDetails.userId);
                                                  enList.retainWhere((element) =>
                                                      element.challengeId ==
                                                      _challengeDetail.challengeId);

                                                  Get.off(OnGoingChallenge(
                                                      groupDetail: null,
                                                      filteredList: enList.first,
                                                      navigatedNormal: false,
                                                      challengeDetail: _challengeDetail));
                                                },
                                                child: Container(
                                                  width: Get.width / 4,
                                                  decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(20)),
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
                                      // if (DateFormat('MM-dd-yyyy')
                                      //         .format(_challengeDetail.challengeStartTime)
                                      //         .toString() !=
                                      //     "01-01-2000") {
                                      //   getdef(
                                      //       showD: 1, challengeDetail: _challengeDetail, userDetails: _userDetails);
                                      // } else if (DateFormat('MM-dd-yyyy')
                                      //             .format(_challengeDetail.challengeStartTime)
                                      //             .toString() !=
                                      //         "01-01-2000" &&
                                      //     DateTime.now().isAfter(_challengeDetail.challengeStartTime)) {
                                      //   getdef(
                                      //       showD: 1, challengeDetail: _challengeDetail, userDetails: _userDetails);
                                      // } else if (DateTime.now().isAfter(_challengeDetail.challengeStartTime)) {
                                      //   getdef(
                                      //       showD: 2, challengeDetail: _challengeDetail, userDetails: _userDetails);
                                      // } else {
                                      //   getdef(
                                      //       showD: 2, challengeDetail: _challengeDetail, userDetails: _userDetails);
                                      // }
                                    }
                                  } else {
                                    await LaunchApp.openApp(
                                        openStore: true,
                                        androidPackageName: "com.google.android.apps.fitness");
                                  }
                                  _buttonLoading = false;
                                }),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                    child: Container(
                      width: Device.width / 1.1,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(1, 1),
                                spreadRadius: 4,
                                blurRadius: 5,
                                color: Colors.grey.shade300)
                          ]),
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          SizedBox(
                            width: Device.width / 1.2,
                            child: Text(
                              "We recommend to use Health for better experience",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 18.sp,
                                fontFamily: "Poppins",
                                height: 1.3,
                                // letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: Device.width / 2.5,
                            child: ElevatedButton(
                              child: Text('Use Health',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: Device.width < 300 ? 13 : 15.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      fontFamily: 'Poppins',
                                      color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  backgroundColor: const Color.fromRGBO(25, 169, 229, 1)),
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
                                final HealthFactory health = HealthFactory();
                                await health.requestAuthorization(types, permissions: permissions);
                                ChallengeDetail _challengeDetail = gs.read(GSKeys.challengeDetail);
                                UserDetails _userDetails = gs.read(GSKeys.userDetail);
                                _userDetails.selected_fitness_app = 'google fit';
                                SharedPreferences _prefs = await SharedPreferences.getInstance();
                                _prefs.setBool('fit', true);
                                gs.write('fit', true);
                                bool individualJoined = false;
                                individualJoined = await ChallengeApi().userJoinIndividual(
                                    joinIndividual: JoinIndividual(
                                        challengeId: _challengeDetail.challengeId,
                                        userDetails: _userDetails));
                                if (individualJoined) {
                                  print(DateFormat('MM-dd-yyyy')
                                      .format(_challengeDetail.challengeStartTime)
                                      .toString());
                                  getdef2(
                                      showD: 1,
                                      challengeDetail: _challengeDetail,
                                      userDetails: _userDetails);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  )
          ],
        )),
      ),
    );
  }

  getdef({int showD}) {
    if (showD == 1) {
      Get.defaultDialog(
          barrierDismissible: false,
          backgroundColor: Colors.lightBlue.shade50,
          title: 'Welcome aboard!',
          titlePadding: EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
          titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
          contentPadding: const EdgeInsets.only(top: 0),
          content: Column(
            children: [
              const Divider(
                thickness: 2,
              ),
              Icon(
                Icons.task_alt,
                size: 50,
                color: Colors.blue.shade300,
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () async {
                  List<EnrolledChallenge> enList = await ChallengeApi()
                      .listofUserEnrolledChallenges(userId: _userDetails.userId);
                  enList.retainWhere(
                      (element) => element.challengeId == _challengeDetail.challengeId);

                  Get.off(PersistentOnGoingScreen(
                      nrmlJoin: false,
                      challengeStarted: true,
                      enrolledChallenge: enList.first,
                      challengeDetail: _challengeDetail));
                },
                child: Container(
                  width: Get.width / 4,
                  decoration:
                      BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
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

    if (showD == 2) {
      Get.defaultDialog(
          barrierDismissible: false,
          backgroundColor: Colors.lightBlue.shade50,
          title: 'Welcome aboard!',
          titlePadding: EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
          titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
          contentPadding: const EdgeInsets.only(top: 0),
          content: Column(
            children: [
              const Divider(
                thickness: 2,
              ),
              Icon(
                Icons.task_alt,
                size: 50,
                color: Colors.blue.shade300,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Run will be active from ${Jiffy(_challengeDetail.challengeStartTime).format("do MMM yyyy")}",
                textAlign: TextAlign.center,
                style: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  // Get.offAll(HomeScreen(introDone: true), transition: Transition.size);
                  Get.off(LandingPage());
                },
                child: Container(
                  width: Get.width / 4,
                  decoration:
                      BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
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
  }

  getdef2({int showD, ChallengeDetail challengeDetail, UserDetails userDetails}) {
    if (showD == 1) {
      Get.defaultDialog(
          barrierDismissible: false,
          backgroundColor: Colors.lightBlue.shade50,
          title: 'Welcome aboard!',
          titlePadding: EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
          titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
          contentPadding: const EdgeInsets.only(top: 0),
          content: Column(
            children: [
              const Divider(
                thickness: 2,
              ),
              Icon(
                Icons.task_alt,
                size: 50,
                color: Colors.blue.shade300,
              ),
              const SizedBox(
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

    if (showD == 2) {
      Get.defaultDialog(
          barrierDismissible: false,
          backgroundColor: Colors.lightBlue.shade50,
          title: 'Welcome aboard!',
          titlePadding: EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
          titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
          contentPadding: const EdgeInsets.only(top: 0),
          content: Column(
            children: [
              const Divider(
                thickness: 2,
              ),
              Icon(
                Icons.task_alt,
                size: 50,
                color: Colors.blue.shade300,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Run will be active from ${Jiffy(challengeDetail.challengeStartTime).format("do MMM yyyy")}",
                textAlign: TextAlign.center,
                style: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  // Get.offAll(HomeScreen(introDone: true), transition: Transition.size);
                  Get.off(LandingPage());
                },
                child: Container(
                  width: Get.width / 4,
                  decoration:
                      BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
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
  }
}
