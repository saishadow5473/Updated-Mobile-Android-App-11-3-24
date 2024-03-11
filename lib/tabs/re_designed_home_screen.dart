import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/constants/vitalUI.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/health_challenge/views/health_challenges_types.dart';
import 'package:ihl/models/data_helper.dart';
import 'package:ihl/models/ecg_calculator.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/repositories/marathon_event_api.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/imageutils.dart';
import 'package:ihl/views/dashBoardExpiredSubscriptionTile.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/diet_view.dart';
import 'package:ihl/views/dietJournal/journal_graph.dart';
import 'package:ihl/views/dietJournal/models/get_todays_food_log_model.dart';
import 'package:ihl/views/gamification/stepsScreen.dart';
import 'package:ihl/views/home_screen.dart';
import 'package:ihl/views/marathon/dashboard_marathonCard.dart';
import 'package:ihl/views/other_vitals.dart';
import 'package:ihl/views/teleconsultation/wellness_cart.dart';
import 'package:ihl/widgets/height.dart';
import 'package:ihl/widgets/teleconsulation/dashboard_Consult_historyItemTile.dart';
import 'package:ihl/widgets/teleconsulation/dashboard_subscriptionTile.dart';
import 'package:ihl/widgets/teleconsulation/dashboardappointmentTile.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:strings/strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Getx/controller/google_fit_controller.dart';
import '../Getx/controller/listOfChallengeContoller.dart';
import '../health_challenge/models/challengemodel.dart';
import '../health_challenge/models/get_selfie_image_model.dart';
import '../health_challenge/models/group_details_model.dart';
import '../health_challenge/models/list_of_users_in_group.dart';
import '../health_challenge/models/listchallenge.dart';
import '../health_challenge/models/update_challenge_target_model.dart';
import '../health_challenge/persistent/PersistenGetxController/PersistentGetxController.dart';
import '../health_challenge/persistent/views/persistent_onGoingScreen.dart';
import '../health_challenge/persistent/views/persistnet_certificateScreen.dart';
import '../health_challenge/views/certificate_detail.dart';
import '../health_challenge/views/challenge_details_screen.dart';
import '../health_challenge/views/listofchallenges.dart';
import '../health_challenge/views/on_going_challenge.dart';
import '../helper/checkForUpdate.dart';
import '../main.dart';
import '../new_design/app/utils/localStorageKeys.dart';
import '../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import '../views/dietJournal/activity_tile_view.dart';
import '../views/gamification/dateutils.dart';
import '../views/goal_settings/apis/goal_apis.dart';
import '../views/goal_settings/edit_goal_screen.dart';
import '../views/marathon/preCertificate.dart';
import '../views/otherVitalController/otherVitalController.dart';
import '../views/teleconsultation/viewallneeds.dart';
import 'newMemberServicesTile.dart';

class ReDesignedHomeScreen extends StatefulWidget {
  Function closeDrawer;
  Function openDrawer;
  Function goToProfile;
  var userScore = '0';
  String username;
  final String appointId;
  final Map consultant;
  final bool deepLink;
  ReDesignedHomeScreen(
      {this.closeDrawer,
      this.username,
      this.openDrawer,
      this.userScore,
      this.goToProfile,
      this.consultant,
      this.appointId,
      this.deepLink});
  @override
  _ReDesignedHomeScreenState createState() => _ReDesignedHomeScreenState();
}

class _ReDesignedHomeScreenState extends State<ReDesignedHomeScreen> {
  final List<AppLifecycleState> _stateHistoryList = <AppLifecycleState>[];
  final ListChallengeController _listController = Get.put(ListChallengeController());
  final HealthRepository _stepController = Get.put(HealthRepository());
  bool fitImplemented = false, fitInstalled = false;
  http.Client _client = http.Client(); //3gb
  List<Activity> todaysActivityData = [];
  List<Activity> otherActivityData = [];
  bool loading = true;
  bool isJointAccount = true;
  List vitalsToShow = [];
  ChallengeApi challengeApi = ChallengeApi();
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
  var hislist = [];
  Map fitnessClassSpecialties;
  var platformData;
  Map res;
  bool requestError = false;
  ScrollController _scrollController = ScrollController();
  String _selectedLocation;
  Future getSubscriptionClassListData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data1 = prefs.get('data');
    Map res1 = jsonDecode(data1);
    var iHLUserId = res1['User']['id'];
    final getPlatformData = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/GetPlatfromData"),
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
      if (this.mounted) {
        setState(() {
          requestError = true;
        });
      }
      print(getPlatformData.body);
    }

    //platformData = prefs.get(SPKeys.platformData);

    if (res['consult_type'] == null ||
        !(res['consult_type'] is List) ||
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
  var hlist = [];
  bool completedSelected = false;
  // bool approvedSelected = false;
  // bool canceledSelected = false;
  // bool requestedSelected = false;
  // bool rejectedSelected = false;
  var apps = [];

  List<String> appointmentStatus = [
    // 'Approved',
    'Completed',
    // 'Rejected',
    // 'Requested',
    // 'Canceled',
  ];

  DashBoardHistoryItem getDashBoardHistoryItem(Map map, var index) {
    return DashBoardHistoryItem(
      index: index,
      appointId: map['appointment_id'],
      appointmentStartTime: map['appointment_start_time'],
      appointmentEndTime: map['appointment_end_time'],
      consultantName: map['consultant_name'] == null ? "N/A" : map['consultant_name'],
      consultationFees: map['consultation_fees'],
      appointmentStatus: map['appointment_status'],
      callStatus: map['call_status'] == null ? "N/A" : map['call_status'],
    );
  }

  // Dashboard completed appointment history method ends

  // subscription expired history method starts

  // bool expanded = true;
  // bool hasSubscription = false;
  List subscriptions = [];
  List expiredSubscriptions;
  var elist = [];
  // bool loading = true;

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
      print(bmi);
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

  String dropdownvalue = 'Item 1';

  /// returns BMI Class for a BMI 🌈
  String bmiClassCalc(int bmi) {
    print(bmi);
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
  bool firsttime = false;
  // void firstTimeLog() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   firsttime = prefs.getBool("firstTime") ?? true;
  //   if (mounted) setState(() {});
  // }

  void surveybmiCalc() async {
    final navi = GetStorage();
    navi.write("setGoalNavigation", false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firsttime = prefs.getBool("firstTime") ?? true;
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    var height = res['User']['heightMeters'].toString();
    var weight = res['User']['userInputWeightInKG'].toString();
    double parsedH;
    double parsedW;
    parsedH = double.tryParse(height);
    parsedW = double.tryParse(weight);
    if (parsedH != null && parsedW != null) {
      surveybmi = parsedW ~/ (parsedH * parsedH);
    }
  }

  /// looooooooooooooong code processes JSON response 🌠
  ///
  List userVitals;
  Image photo = maleAvatar;
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

    ///for getting user image
    if (data['User']['hasPhoto'] == true && data['User']['photo'] != null) {
      var photoUrl = data['User']['photo'];
      print(photoUrl);
      photo = imageFromBase64String(data['User']['photo']);
    } else {
      if (data['User']['gender'] == 'm') {
        photo = maleAvatar;
      } else if (data['User']['gender'] == 'f') {
        photo = femaleAvatar;
      } else {
        photo = defAvatar;
      }
    }
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

        if (this.mounted) {
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
    var bcml = "20.00";
    var bcmh = "25.00";
    var lowMineral = "2.00";
    var highMineral = "3.00";
    var heightinCMS = userVitals[0]['heightMeters'] * 100;
    var weight =
        userVitals[0]['weightKG'].toString() == "" ? '0' : userVitals[0]['weightKG'].toString();
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
      lowFatReference = (0.10 * double.tryParse(weight ?? '0'));
      highFatReference = (0.20 * double.tryParse(weight ?? '0'));
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

    for (var i = 0; i < userVitals.length; i++) {
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('ViseralValue', userVitals[i]['visceral_fat']);
        vfStatus = calculateFullBodyVFStatus(userVitals[i]['visceral_fat']);
        if (vfStatus == "high" || vfStatus == "High") {
          var data = prefs.setString("vf_status", vfStatus);
          // var _vfStatus = GetStorage();
          // _vfStatus.write("vf_status", vfStatus);
        }
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
            stringify(userVitals[i]['systolic']) + '/' + stringify(userVitals[i]['diastolic']);
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
            'status': userVitals[i][f + 'Class'] == null
                ? 'Unknown'
                : camelize(userVitals[i][f + 'Class']),
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

// weekly calorie graph parameters

  var graphDataList = [];
  bool nodata = false;
  int target = 0;
  String tillDate;
  String fromDate;
  void getWeekData() async {
    tillDate = DateTime.now().add(Duration(days: 1)).toString().substring(0, 10);
    fromDate = DateTime.now().subtract(Duration(days: 6)).toString().substring(0, 10);
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
    if (this.mounted) {
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

  var alist = [];
  // bool loading = true;
  List<String> sharedReportAppIdList = [];

  Future getAppointmentData() async {
    /* SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userDetailsResponse);

    Map teleConsulResponse = json.decode(data);*/

    // Commented getUserDetails API and instead getting data from SharedPreference

    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
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
    var data = prefs.get(SPKeys.userData);
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
    prefs.setString('name', firstName + ' ' + lastName);
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
  }

// end heighttile parameters
// activity data

  // get bmi value
  void getUserBMIDetails() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    IHL_User_ID = prefs1.getString("ihlUserId");
    selectedSpecality = prefs1.getString("selectedSpecality");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.get('email');
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    var mobileNumber = res['User']['mobileNumber'];
    var dob = res['User']['dateOfBirth'].toString();
    // var bmi_ =
  }
  // end bmi value

// activity data ends
  StreamingSharedPreferences preferences;
  int dailytarget = 0;
  double newbmi;
  void getBMI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    if (this.mounted) {
      setState(() {
        name = res['User']['firstName'] ?? 'User';
      });
    }
  }

  bool hasSubscription = false;
  // List subscriptions = [];
  List approvedSubscriptions;
  var slist = [];
  // Subscription class method
  List<dynamic> goalLists = [];

  Future getSubscriptionClassData() async {
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
        approvedSubscriptions = subscriptions
            .where((i) =>
                i["approval_status"] == "Approved" ||
                i["approval_status"] == "Accepted" ||
                i["approval_status"] == "Requested" ||
                i["approval_status"] == "requested")
            .toList();
        var currentDateTime = new DateTime.now();

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
  void dispose() {
    super.dispose();
  }

  void getGoalData() {
    GoalApis.listGoal().then((value) {
      if (value != null) {
        List<dynamic> activeGoalLists = [];
        for (int i = 0; i < value.length; i++) {
          if (value[i]['goal_status'] == 'active') {
            activeGoalLists.add(value[i]);
          }
        }
        setState(() {
          goalLists = activeGoalLists;
        });
      }
    });
  }

  @override
  void initState() {
    if (WidgetsBinding.instance.lifecycleState != null) {
      _stateHistoryList.add(WidgetsBinding.instance.lifecycleState);
    }

    surveybmiCalc();
    getBMI();
    getEventDetails();
    _initSp();
    getData();
    getGoalData();
    getUserBMIDetails();
    getHeightWeightData();
    getSharedAppIdList();
    userEnrolledChal();
    //Checking latest app is installed starts here
    checkVersion();
    //Checking latest app is installed ends here
    _expandableController = ExpandableController(
      initialExpanded: true,
    );
    _expandableController.addListener(() {
      if (this.mounted) {
        setState(() {
          expanded = _expandableController.expanded;
        });
      }
    });
    super.initState();
  }

  void checkVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var alreadyNotChecked = prefs.get(SPKeys.needToCheckAppVersion);
    if (alreadyNotChecked == 'yes') {
      final _snapChatChecker = AppVersionChecker(appId: "com.indiahealthlink.ihlhealth");
      AppCheckerResult snapValue;
      await Future.wait([
        _snapChatChecker.checkUpdate().then((value) => snapValue = value),
      ]);
      //print(snapValue.toString());
      if (snapValue.canUpdate) {
        double _hSmallDevice = MediaQuery.of(context).size.height;
        double _wSmallDevice = MediaQuery.of(context).size.width;
        Future.delayed(Duration.zero, () {
          showGeneralDialog(
              barrierColor: Colors.black.withOpacity(0.5),
              transitionBuilder: (context, a1, a2, widget) {
                final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
                return Transform(
                  transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
                  child: Opacity(
                    opacity: a1.value,
                    child: Center(
                      child: Platform.isIOS
                          ? Dialog(
                              backgroundColor: Colors.transparent, //must have
                              elevation: 0,
                              child: SizedBox(
                                height: _hSmallDevice > 568 ? 30.h : 35.h,
                                width: _wSmallDevice > 320 ? 90.w : 100.w,
                                child: Stack(
                                  children: [
                                    Positioned(
                                        top: 4.h,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                            color: Colors.white,
                                          ),
                                          height: _hSmallDevice > 568 ? 25.h : 27.h,
                                          width: _wSmallDevice > 320 ? 80.w : 75.w,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              Text("Update App?",
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      color: Colors.black87,
                                                      letterSpacing: 0.7,
                                                      fontWeight: FontWeight.w800)),
                                              Text(
                                                "A new version ${snapValue.newVersion} of hCare is available!\n Currently installed version ${snapValue.currentVersion} ",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.grey,
                                                    letterSpacing: 0.7,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              Text("Would you like to update it now?",
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.grey,
                                                      letterSpacing: 0.7,
                                                      fontWeight: FontWeight.w600)),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text(
                                                          "Not now",
                                                          style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color: AppColors.primaryAccentColor
                                                                  .withOpacity(0.5),
                                                              letterSpacing: 0.7,
                                                              fontWeight: FontWeight.w600),
                                                        )),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        var url = Uri.parse(snapValue.appURL);
                                                        await launchUrl(
                                                          url,
                                                          mode: LaunchMode.externalApplication,
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Update Now",
                                                        style: TextStyle(
                                                            fontSize: 14.sp,
                                                            color: Colors.white,
                                                            letterSpacing: 0.7,
                                                            fontWeight: FontWeight.w600),
                                                      ),
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty.all<Color>(
                                                                  AppColors.primaryAccentColor)),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        radius: 25.sp,
                                        child: ClipRect(
                                          child: Image.asset("assets/images/app-store.png"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          : Dialog(
                              backgroundColor: Colors.transparent, //must have
                              elevation: 0,
                              child: SizedBox(
                                height: _hSmallDevice > 568 ? 30.h : 35.h,
                                width: _wSmallDevice > 320 ? 90.w : 100.w,
                                child: Stack(
                                  children: [
                                    Positioned(
                                        top: 4.h,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                            color: Colors.white,
                                          ),
                                          height: _hSmallDevice > 568 ? 25.h : 27.h,
                                          width: _wSmallDevice > 320 ? 80.w : 75.w,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 4.h),
                                              Text("Update App?",
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      color: Colors.black87,
                                                      letterSpacing: 0.7,
                                                      fontWeight: FontWeight.w800)),
                                              Text(
                                                "A new version ${snapValue.newVersion} of hCare is available!\n Currently installed version ${snapValue.currentVersion} ",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.grey,
                                                    letterSpacing: 0.7,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              Text("Would you like to update it now?",
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.grey,
                                                      letterSpacing: 0.7,
                                                      fontWeight: FontWeight.w600)),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text(
                                                          "Not now",
                                                          style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color: AppColors.primaryAccentColor
                                                                  .withOpacity(0.5),
                                                              letterSpacing: 0.7,
                                                              fontWeight: FontWeight.w600),
                                                        )),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        var url = Uri.parse(snapValue.appURL);
                                                        await launchUrl(
                                                          url,
                                                          mode: LaunchMode.externalApplication,
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Update Now",
                                                        style: TextStyle(
                                                            fontSize: 14.sp,
                                                            color: Colors.white,
                                                            letterSpacing: 0.7,
                                                            fontWeight: FontWeight.w600),
                                                      ),
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty.all<Color>(
                                                                  AppColors.primaryAccentColor)),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        radius: 25.sp,
                                        child: ClipRect(
                                          child: Image.asset(
                                            "assets/images/googlePlayStore.png",
                                            //height: 20.h,
                                            // width: 60.w,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                    ),
                  ),
                );
              },
              transitionDuration: Duration(milliseconds: 200),
              barrierDismissible: true,
              barrierLabel: '',
              context: context,
              pageBuilder: (context, animation1, animation2) {});
        });
        // showDialog(
        //   context: context,
        //   builder: (context) {
        //     final size = MediaQuery.of(context).size;
        //     return Center(
        //       child: !Platform.isIOS
        //           ? Dialog(
        //               backgroundColor: Colors.transparent, //must have
        //               elevation: 0,
        //               child: SizedBox(
        //                 height: 30.h,
        //                 child: Stack(
        //                   children: [
        //                     Positioned(
        //                         top: 4.h,
        //                         child: Container(
        //                           decoration: BoxDecoration(
        //                             borderRadius: BorderRadius.all(Radius.circular(20)),
        //                             color: Colors.white,
        //                           ),
        //                           height: 25.h,
        //                           width: 80.w,
        //                           child: Column(
        //                             mainAxisAlignment: MainAxisAlignment.center,
        //                             crossAxisAlignment: CrossAxisAlignment.center,
        //                             children: [
        //                               SizedBox(
        //                                 height: 5.h,
        //                               ),
        //                               Text("Update App?",
        //                                   style: TextStyle(
        //                                       fontSize: 20.sp,
        //                                       color: Colors.black87,
        //                                       letterSpacing: 0.7,
        //                                       fontWeight: FontWeight.w800)),
        //                               Text(
        //                                 "A new version 10.02.3 of hCare is available!\n Currently installed version 10.0.0",
        //                                 textAlign: TextAlign.center,
        //                                 style: TextStyle(
        //                                     fontSize: 13.sp,
        //                                     color: Colors.grey,
        //                                     letterSpacing: 0.7,
        //                                     fontWeight: FontWeight.w600),
        //                               ),
        //                               Text("Would you like to update it now?",
        //                                   style: TextStyle(
        //                                       fontSize: 13.sp,
        //                                       color: Colors.grey,
        //                                       letterSpacing: 0.7,
        //                                       fontWeight: FontWeight.w600)),
        //                               Padding(
        //                                 padding: const EdgeInsets.all(8.0),
        //                                 child: Row(
        //                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //                                   children: [
        //                                     TextButton(
        //                                         onPressed: null,
        //                                         child: Text(
        //                                           "Not now",
        //                                           style: TextStyle(
        //                                               fontSize: 14.sp,
        //                                               color: AppColors.primaryAccentColor
        //                                                   .withOpacity(0.5),
        //                                               letterSpacing: 0.7,
        //                                               fontWeight: FontWeight.w600),
        //                                         )),
        //                                     ElevatedButton(
        //                                       onPressed: null,
        //                                       child: Text(
        //                                         "Update Now",
        //                                         style: TextStyle(
        //                                             fontSize: 14.sp,
        //                                             color: Colors.white,
        //                                             letterSpacing: 0.7,
        //                                             fontWeight: FontWeight.w600),
        //                                       ),
        //                                       style: ButtonStyle(
        //                                           backgroundColor: MaterialStateProperty.all<Color>(
        //                                               AppColors.primaryAccentColor)),
        //                                     ),
        //                                   ],
        //                                 ),
        //                               )
        //                             ],
        //                           ),
        //                         )),
        //                     Align(
        //                       alignment: Alignment.topCenter,
        //                       child: CircleAvatar(
        //                         backgroundColor: Colors.transparent,
        //                         radius: 25.sp,
        //                         child: ClipRect(
        //                           child: Image.asset("assets/images/app-store.png"),
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ))
        //           : Dialog(
        //               backgroundColor: Colors.transparent, //must have
        //               elevation: 0,
        //               child: SizedBox(
        //                 height: 30.h,
        //                 child: Stack(
        //                   children: [
        //                     Positioned(
        //                         top: 4.h,
        //                         child: Container(
        //                           decoration: BoxDecoration(
        //                             borderRadius: BorderRadius.all(Radius.circular(20)),
        //                             color: Colors.white,
        //                           ),
        //                           height: 25.h,
        //                           width: 80.w,
        //                           child: Column(
        //                             mainAxisAlignment: MainAxisAlignment.center,
        //                             crossAxisAlignment: CrossAxisAlignment.center,
        //                             children: [
        //                               SizedBox(height: 5.h),
        //                               Text("Update App?",
        //                                   style: TextStyle(
        //                                       fontSize: 20.sp,
        //                                       color: Colors.black87,
        //                                       letterSpacing: 0.7,
        //                                       fontWeight: FontWeight.w800)),
        //                               Text(
        //                                 "A new version 10.02.3 of hCare is available!\n Currently installed version 10.0.0",
        //                                 textAlign: TextAlign.center,
        //                                 style: TextStyle(
        //                                     fontSize: 13.sp,
        //                                     color: Colors.grey,
        //                                     letterSpacing: 0.7,
        //                                     fontWeight: FontWeight.w600),
        //                               ),
        //                               Text("Would you like to update it now?",
        //                                   style: TextStyle(
        //                                       fontSize: 13.sp,
        //                                       color: Colors.grey,
        //                                       letterSpacing: 0.7,
        //                                       fontWeight: FontWeight.w600)),
        //                               Padding(
        //                                 padding: const EdgeInsets.all(8.0),
        //                                 child: Row(
        //                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //                                   children: [
        //                                     TextButton(
        //                                         onPressed: null,
        //                                         child: Text(
        //                                           "Not now",
        //                                           style: TextStyle(
        //                                               fontSize: 14.sp,
        //                                               color: AppColors.primaryAccentColor
        //                                                   .withOpacity(0.5),
        //                                               letterSpacing: 0.7,
        //                                               fontWeight: FontWeight.w600),
        //                                         )),
        //                                     ElevatedButton(
        //                                       onPressed: null,
        //                                       child: Text(
        //                                         "Update Now",
        //                                         style: TextStyle(
        //                                             fontSize: 14.sp,
        //                                             color: Colors.white,
        //                                             letterSpacing: 0.7,
        //                                             fontWeight: FontWeight.w600),
        //                                       ),
        //                                       style: ButtonStyle(
        //                                           backgroundColor: MaterialStateProperty.all<Color>(
        //                                               AppColors.primaryAccentColor)),
        //                                     ),
        //                                   ],
        //                                 ),
        //                               )
        //                             ],
        //                           ),
        //                         )),
        //                     Align(
        //                       alignment: Alignment.topCenter,
        //                       child: CircleAvatar(
        //                         backgroundColor: Colors.transparent,
        //                         radius: 25.sp,
        //                         child: ClipRect(
        //                           child: Image.asset(
        //                             "assets/images/googlePlayStore.png",
        //                             //height: 20.h,
        //                             // width: 60.w,
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               )),
        //     );
        //   },
        // );
      }
      prefs.setString(SPKeys.needToCheckAppVersion, "no");
    }
  }

  bool userEnrolled = false;
  ChallengeDetail challengeDetail;
  List<EnrolledChallenge> currentUserEnrolledChallenges = [];
  Stream<List<EnrolledChallenge>> userEnrolledChal() async* {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    String userid = prefs1.getString("ihlUserId");
    await Future.delayed(Duration(milliseconds: 500));
    currentUserEnrolledChallenges = await challengeApi.listofUserEnrolledChallenges(userId: userid);
    currentUserEnrolledChallenges.removeWhere((element) => element.userStatus != "active");
    currentUserEnrolledChallenges.removeWhere((element) => element.userProgress == "completed");
    if (currentUserEnrolledChallenges.isNotEmpty) {
      userEnrolled = true;
      yield currentUserEnrolledChallenges;
    } else {
      userEnrolled = false;
      yield null;
    }
  }

  getListedChallenge() async {
    List userAffiliateList = [];
    int pagination_start = 0;
    int pagination_end = 10;
    if (userAffiliate != null)
      for (int i = 1; i <= userAffiliate.length; i++) {
        userAffiliateList.add(userAffiliate['af_no$i']['affilate_unique_name']);
      }
    List<Challenge> allChallenegeList = await challengeApi.listOfChallenges(
        challenge: ListChallenge(
            challenge_mode: " ",
            email: Get.find<ListChallengeController>().email,
            pagination_end: pagination_end,
            pagination_start: pagination_start,
            affiliation_list: userAffiliateList));
    return allChallenegeList;
  }

  getChallengeDetails(challengeId) async {
    ChallengeDetail challengeDetail = await challengeApi.challengeDetail(challengeId: challengeId);
    return challengeDetail;
  }

  List eventDetailList;
  List userEnrolledMap;
  getEventDetails() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHL_User_Id = res['User']['id'];
    prefs1.setString("ihlUserId", iHL_User_Id);
    eventDetailList = await eventDetailApi();
    removeTheEvenWhenExpiryDateExceed2days() {
      if (eventDetailList != null) {
        eventDetailList.removeWhere((element) {
          if (DateTime.now().isAfter(DateTime.parse(element['event_end_time'].toString()))) {
            if (DateTime.now().difference(DateTime.parse(element['event_end_time'].toString())) >
                Duration(days: 2)) {
              return true;
            }
            return false;
          }
          return false;
        });
      }
    }

    ///remove event from the details if it is end date is exceedes more than 2 days
    await removeTheEvenWhenExpiryDateExceed2days();
    if (eventDetailList != null && eventDetailList.isNotEmpty) {
      var uem = await isUserEnrolledApi(
          ihl_user_id: iHL_User_Id, event_id: eventDetailList[0]['event_id']);
      userEnrolledMap = [];
      if (uem != null) {
        userEnrolledMap.add(uem);
      }
      if (eventDetailList.length > 1) {
        for (int i = 1; i < eventDetailList.length; i++) {
          var uem1 = await isUserEnrolledApi(
              ihl_user_id: iHL_User_Id, event_id: eventDetailList[i]['event_id']);
          if (uem1 != null) {
            userEnrolledMap.add(uem1);
          }
        }
      }
      if (mounted) setState(() {});
    }
  }

// consultation history functions starts
// counsultation history functions ends
  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    StreamingSharedPreferences.instance.then((value) {
      if (this.mounted)
        setState(() {
          preferences = value;
        });
    });
    dailyTarget().then((value) {
      if (this.mounted) {
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
      var userData = prefs.get('data');
      preferences.setBool('maintain_weight', true);
      Map res = jsonDecode(userData);
      var height;
      DateTime birthDate;
      String datePattern = "MM/dd/yyyy";
      var dob = res['User']['dateOfBirth'].toString();
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
    var firstDayThisMonth = new DateTime(date.year, date.month, date.day);
    var firstDayNextMonth =
        new DateTime(firstDayThisMonth.year, firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  String heightft() {
    double h = double.tryParse(height);
    if (h == null) {
      return '';
    }
    return cmToFeetInch(h.toInt());
  }

  final iHLUrl = API.iHLUrl;
  final ihlToken = API.ihlToken;

  String jointAccUserName, jointAccUserID;
  void _initAsync() async {
    await SpUtil.getInstance();
    var email = SpUtil.getString('email');
    var pwd = SpUtil.getString('password');
    authenticate(email, pwd);
  }

  String apiToken;
  // ignore: missing_return
  Future authenticate(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    var careTakerDetails = prefs.getString('data');

    var decodedResponse = jsonDecode(careTakerDetails);
    print(decodedResponse);

    String iHLUserToken = decodedResponse['Token'];

    String iHLUserId = decodedResponse['User']['id'];
    var jointAccountUserDetails = decodedResponse['User']['joint_user_detail_list'];
    print(jointAccountUserDetails);

    jointAccUserID = jointAccountUserDetails['joint_user1']['ihl_user_id'];
    jointAccUserName = jointAccountUserDetails['joint_user1']['ihl_user_name'];

    var authToken = SpUtil.getString('auth_token');
    final response = await _client.post(
      Uri.parse(iHLUrl + '/login/qlogin2'),
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
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('data', response.body);
        prefs.setString('password', password);
        prefs.setString('email', email);
        localSotrage.write(LSKeys.email, email);

        var decodedResponse = jsonDecode(response.body);
        print(decodedResponse);

        String iHLUserToken = decodedResponse['Token'];

        String iHLUserId = decodedResponse['User']['id'];
        var jointAccountUserDetails = decodedResponse['User']['joint_user_detail_list'];
        print(jointAccountUserDetails);

        jointAccUserID = jointAccountUserDetails['joint_user1']['ihl_user_id'];
        jointAccUserName = jointAccountUserDetails['joint_user1']['ihl_user_name'];

        print(jointAccUserID);

        print(jointAccUserName);

        final auth_response = await _client.get(
          // joint account Authentication URL
          Uri.parse(iHLUrl + '/login/kioskLogin?id=2936'),
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
          print(auth_response.body);
          print(reponseToken);
          apiToken = reponseToken.apiToken;
          final JointUserResponse = await _client.post(
            Uri.parse(iHLUrl + '/login/get_user_login'),
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
            print(JointUserResponse.body);
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
    var password = prefs.get(SPKeys.password);
    var email = prefs.get(SPKeys.email);
    var authToken = prefs.get(SPKeys.authToken);

    final response1 = await _client.post(
      Uri.parse(API.iHLUrl + '/login/qlogin2'),
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
        final prefs = await SharedPreferences.getInstance();
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
        print(jointAccountUserDetails);

        jointAccUserID = jointAccountUserDetails['joint_user1']['ihl_user_id'];
        jointAccUserName = jointAccountUserDetails['joint_user1']['ihl_user_name'];
      }
    }
    // joint acc api starts

    final JointUserResponse = await _client.post(
      Uri.parse(iHLUrl + '/login/get_user_login'),
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
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('data', '');

        if (this.mounted) {
          setState(() {
            userLoginSuccess = false;
            // isPwdCorrect = false;
            isLoading = false;
          });
        }

        return userLoginSuccess;
      } else {
        if (this.mounted) {
          setState(() {
            // isPwdCorrect = true;
            userLoginSuccess = true;
          });
        }
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('data', JointUserResponse.body);
        prefs.setString('ihl_user_id', jointAccUserID);
        // prefs.setString('email', email);
        var decodedResponse = jsonDecode(JointUserResponse.body);
        print(decodedResponse);
        String jointAccUserToken = decodedResponse['Token'];
        String iHLUserId = decodedResponse['User']['id'];

        bool introDone = decodedResponse['User']['introDone'];
        bool isJointAccount = decodedResponse['User']['care_taker_details_list']['caretaker_user1']
            ['is_joint_account'];
        SharedPreferences prefs1 = await SharedPreferences.getInstance();
        prefs1.setString("ihlUserId", jointAccUserID);

        final getPlatformData = await _client.post(
          Uri.parse(API.iHLUrl + "/consult/GetPlatfromData"),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
          body: jsonEncode(<String, dynamic>{"ihl_id": jointAccUserID, 'cache': "true"}),
        );
        if (getPlatformData.statusCode == 200) {
          final platformData = await SharedPreferences.getInstance();
          platformData.setString(SPKeys.platformData, getPlatformData.body);
        }
        final vitalData = await _client.get(
          Uri.parse(iHLUrl + '/data/user/' + jointAccUserID + '/checkin'),
          headers: {
            'Content-Type': 'application/json',
            'Token': jointAccUserToken,
            'ApiToken': apiToken
          },
        );
        if (vitalData.statusCode == 200) {
          vitalDataExists = true;
          final sharedUserVitalData = await SharedPreferences.getInstance();
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
        if (this.mounted) {
          setState(() {
            CircularProgressIndicator();
            isLoading = false;
            if (widget.deepLink == true) {
              Get.offNamedUntil(Routes.MyAppointments, (route) => Get.currentRoute == Routes.Home);
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()
                      //  HomeScreen(
                      //       introDone: introDone,
                      //       isJointAccount: isJointAccount,
                      //     ),
                      ),
                  (Route<dynamic> route) => false);
            }
          });
        }
        return userLoginSuccess;
      }
    }
  }

  // switch account ends
  Widget listChallengeScroll() {
    return StreamBuilder(
        stream: userEnrolledChal(),
        builder: (context, AsyncSnapshot<List<EnrolledChallenge>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.withOpacity(0.04),
              highlightColor: AppColors.primaryColor.withOpacity(0.4),
              child: Container(
                width: MediaQuery.of(context).size.width - 30,
                //height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(blurRadius: 4, offset: Offset(1, 1), color: Colors.grey.shade400)
                  ],
                  color: Colors.white,
                ),
              ),
            );
          } else if (snapshot.data == null) {
            return InkWell(
              //onTap: Get.to(),
              child: Container(
                width: MediaQuery.of(context).size.width - 30,
                //height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(blurRadius: 4, offset: Offset(1, 1), color: Colors.grey.shade400)
                  ],
                  color: Colors.white,
                ),
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
                    child: Center(
                      child: Text("New Challenge yet to be assigned",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              letterSpacing: 0.7,
                              fontWeight: FontWeight.w600)),
                    )),
              ),
            );
          }
          return Container(
            height: 200.0,
            child: PageView.builder(
              itemCount: currentUserEnrolledChallenges.length,
              itemBuilder: (context, index) {
                return FutureBuilder<ChallengeDetail>(
                    future: challengeApi.challengeDetail(
                        challengeId: currentUserEnrolledChallenges[index].challengeId),
                    builder: (context, challengeDetailSnapshot) {
                      if (challengeDetailSnapshot.connectionState == ConnectionState.waiting)
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.withOpacity(0.04),
                          highlightColor: AppColors.primaryColor.withOpacity(0.4),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 30,
                            //height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(50),
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8)),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 4,
                                    offset: Offset(1, 1),
                                    color: Colors.grey.shade400)
                              ],
                              color: Colors.white,
                            ),
                          ),
                        );

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            if (userEnrolled) {
                              GroupDetailModel groupDetail;
                              if (currentUserEnrolledChallenges[index].groupId != null) {
                                groupDetail = await ChallengeApi().challengeGroupDetail(
                                    groupID: currentUserEnrolledChallenges[index].groupId);
                              }
                              challengeDetailSnapshot.data.challengeMode == "Individual"
                                  ? Get.to(OnGoingChallenge(
                                      challengeDetail: challengeDetailSnapshot.data,
                                      navigatedNormal: true,
                                      filteredList: currentUserEnrolledChallenges[index]))
                                  : Get.to(OnGoingChallenge(
                                      challengeDetail: challengeDetailSnapshot.data,
                                      navigatedNormal: true,
                                      groupDetail: groupDetail,
                                      filteredList: currentUserEnrolledChallenges[index]));
                            } else {
                              ListChallenge _listChallenge = ListChallenge(
                                  challenge_mode: '',
                                  pagination_start: 0,
                                  email: Get.find<ListChallengeController>().email,
                                  pagination_end: 1000,
                                  affiliation_list: ["global", "Global"]);
                              List<Challenge> _listofChallenges =
                                  await ChallengeApi().listOfChallenges(challenge: _listChallenge);
                              _listofChallenges
                                  .removeWhere((element) => element.challengeStatus == "deactive");
                              List types = [];
                              for (int i = 0; i < _listofChallenges.length; i++) {
                                types.add(_listofChallenges[i].challengeType);
                                //Step Challenge
                                //Weight Loss Challenge
                              }
                              types = types.toSet().toList();
                              if (types.length == 1) {
                                Get.to(ListofChallenges(
                                  list: ["global", "Global"],
                                  challengeType: types[0],
                                ));
                              } else {
                                Get.to(HealthChallengeTypes(
                                  list: ["global", "Global"],
                                ));
                              }
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 40,

                            // height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(50),
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8)),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 4,
                                    offset: Offset(1, 1),
                                    color: Colors.grey.shade400)
                              ],
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      SizedBox(
                                        height: 60,
                                        width: 60,
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              challengeDetailSnapshot.data.challengeImgUrl),
                                        ),
                                      ),
                                      Spacer(),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width / 1.6,
                                        child: Text(
                                          challengeDetailSnapshot.data.challengeName,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.blueGrey.shade600,
                                              letterSpacing: 0.7,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  currentUserEnrolledChallenges[index].userProgress == null ||
                                          currentUserEnrolledChallenges[index].userAchieved == 0
                                      ? Container(
                                          child: Column(
                                          children: [
                                            Text("Run Yet to be started",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                    letterSpacing: 0.7,
                                                    fontWeight: FontWeight.w600)),
                                          ],
                                        ))
                                      : Row(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width / 2.6,
                                              child: Column(
                                                children: [
                                                  Text("Completed",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                          letterSpacing: 0.7,
                                                          fontWeight: FontWeight.w600)),
                                                  challengeDetailSnapshot.data.challengeMode !=
                                                          "individual"
                                                      ? Text(
                                                          '${challengeDetailSnapshot.data.challengeUnit == 'steps' ? currentUserEnrolledChallenges[index].userAchieved : challengeDetailSnapshot.data.challengeUnit == 'm' ? currentUserEnrolledChallenges[index].userAchieved * 0.762 : currentUserEnrolledChallenges[index].userAchieved * 0.0008}',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.lightBlue,
                                                              letterSpacing: 0.7,
                                                              fontWeight: FontWeight.w600))
                                                      : Text(
                                                          '${challengeDetailSnapshot.data.challengeUnit == 'steps' ? currentUserEnrolledChallenges[index].groupAchieved : challengeDetailSnapshot.data.challengeUnit == 'm' ? currentUserEnrolledChallenges[index].groupAchieved * 0.762 : currentUserEnrolledChallenges[index].groupAchieved * 0.0008}',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.lightBlue,
                                                              letterSpacing: 0.7,
                                                              fontWeight: FontWeight.w600))
                                                ],
                                              ),
                                            ),
                                            Spacer(),
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width / 2.6,
                                              child: Column(
                                                children: [
                                                  Text("Target",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                          letterSpacing: 0.7,
                                                          fontWeight: FontWeight.w600)),
                                                  Text(
                                                      "${currentUserEnrolledChallenges[index].target}",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.lightBlue,
                                                          letterSpacing: 0.7,
                                                          fontWeight: FontWeight.w600))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                  Visibility(
                                    visible: currentUserEnrolledChallenges[index].userProgress ==
                                                null ||
                                            currentUserEnrolledChallenges[index].userAchieved == 0
                                        ? false
                                        : true,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 15,
                                        ),
                                        NeumorphicIndicator(
                                          height: 8,
                                          width: MediaQuery.of(context).size.width * 0.75,
                                          orientation: NeumorphicIndicatorOrientation.horizontal,
                                          percent:
                                              currentUserEnrolledChallenges[index].userAchieved /
                                                  currentUserEnrolledChallenges[index].target,
                                          // percent: int.parse(
                                          //             currentUserEnrolledChallenges[
                                          //                         0]
                                          //                     .userAchieved
                                          //                 ) /
                                          //         int.parse(
                                          //             currentUserEnrolledChallenges[
                                          //                     0]
                                          //                 .target))
                                          //     .toString()),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 20,
                                  // ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Visibility(
                                          visible:
                                              currentUserEnrolledChallenges[index].userProgress ==
                                                          null ||
                                                      currentUserEnrolledChallenges[index]
                                                              .userAchieved ==
                                                          0
                                                  ? true
                                                  : false,
                                          child: IconButton(
                                              color: Colors.black26,
                                              iconSize: 40,
                                              onPressed: () {},
                                              icon: Icon(Icons.play_circle)),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              },
              scrollDirection: Axis.horizontal,
            ),
          );
        });
  }

  Widget linkedUsersWidget({String subtitle, title, Widget icon, VoidCallback onTap}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Divider(),
        ListTile(
          // minVerticalPadding: 2,
          // contentPadding: EdgeInsets.symmetric(horizontal: 50.0),
          leading: Container(
            decoration: BoxDecoration(
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
        Divider(),
      ],
    );
  }

  bool _logedSso = false;
  List loadedDoctors = [];

  ///for showing member service
  Map userAffiliate;
  String afNo1, afNo2, afNo3, afNo4, afNo5, afNo6, afNo7, afNo8, afNo9;
  bool afNo1bool,
      afNo2bool,
      afNo3bool,
      afNo4bool,
      afNo5bool,
      afNo6bool,
      afNo7bool,
      afNo8bool,
      afNo9bool;
  String afUnique1,
      afUnique2,
      afUnique3,
      afUnique4,
      afUnique5,
      afUnique6,
      afUnique7,
      afUnique8,
      afUnique9;
  void _initSp() async {
    await SpUtil.getInstance();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userData);
    var _prefValue = prefs.get(
      SPKeys.is_sso,
    );
    _logedSso = _prefValue == 'true' ? true : false;

    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);

    afNo1 ??= "empty";
    afNo2 ??= "empty";
    afNo3 ??= "empty";
    afNo4 ??= "empty";
    afNo5 ??= "empty";
    afNo6 ??= "empty";
    afNo7 ??= "empty";
    afNo8 ??= "empty";
    afNo9 ??= "empty";

    // userAffiliate = res['User']['user_affiliate'];
    var tempUserAff = res['User']['user_affiliate'] ?? [];
    for (int i = 1; i <= tempUserAff.length; i++) {
      if (tempUserAff.containsKey("af_no$i")) {
        if (tempUserAff['af_no$i']['affilate_name'].toString() != '' &&
            tempUserAff['af_no$i']['affilate_name'].toString() != 'null' &&
            tempUserAff['af_no$i']['affilate_unique_name'].toString() != '' &&
            tempUserAff['af_no$i']['affilate_unique_name'].toString() != 'null') {
          if (userAffiliate == null) {
            userAffiliate = {};
          }
          // userAffiliate.assign('af_no$i', tempUserAff['af_no$i']);
          userAffiliate['af_no$i'] = tempUserAff['af_no$i'];
        }
      }
    }
    // tempUserAff.where((e,i) => i['affilate_name'].toString()!='');
    if (userAffiliate != null) {
      if (userAffiliate.containsKey("af_no1")) {
        afNo1 = userAffiliate['af_no1']['affilate_name'] ?? "empty";
        afUnique1 = userAffiliate['af_no1']['affilate_unique_name'] ?? "empty";
        afNo1bool = userAffiliate['af_no1']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no2")) {
        afNo2 = userAffiliate['af_no2']['affilate_name'] ?? "empty";
        afUnique2 = userAffiliate['af_no2']['affilate_unique_name'] ?? "empty";
        afNo2bool = userAffiliate['af_no2']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no3")) {
        afNo3 = userAffiliate['af_no3']['affilate_name'] ?? "empty";
        afUnique3 = userAffiliate['af_no3']['affilate_unique_name'] ?? "empty";
        afNo3bool = userAffiliate['af_no3']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no4")) {
        afNo4 = userAffiliate['af_no4']['affilate_name'] ?? "empty";
        afUnique4 = userAffiliate['af_no4']['affilate_unique_name'] ?? "empty";
        afNo4bool = userAffiliate['af_no4']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no5")) {
        afNo5 = userAffiliate['af_no5']['affilate_name'] ?? "empty";
        afUnique5 = userAffiliate['af_no5']['affilate_unique_name'] ?? "empty";
        afNo5bool = userAffiliate['af_no5']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no6")) {
        afNo6 = userAffiliate['af_no6']['affilate_name'] ?? "empty";
        afUnique6 = userAffiliate['af_no6']['affilate_unique_name'] ?? "empty";
        afNo6bool = userAffiliate['af_no6']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no7")) {
        afNo7 = userAffiliate['af_no7']['affilate_name'] ?? "empty";
        afUnique7 = userAffiliate['af_no7']['affilate_unique_name'] ?? "empty";
        afNo7bool = userAffiliate['af_no7']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no8")) {
        afNo8 = userAffiliate['af_no8']['affilate_name'] ?? "empty";
        afUnique8 = userAffiliate['af_no8']['affilate_unique_name'] ?? "empty";
        afNo8bool = userAffiliate['af_no8']['is_sso'] ?? false;
      }
      if (userAffiliate.containsKey("af_no9")) {
        afNo9 = userAffiliate['af_no9']['affilate_name'] ?? "empty";
        afUnique9 = userAffiliate['af_no9']['affilate_unique_name'] ?? "empty";
        afNo9bool = userAffiliate['af_no9']['is_sso'] ?? false;
      }
    }
    //getListedChallenge();
  }

  var b6 = "";
  var imgB6 = "";
  Future updateStep(
    EnrolledChallenge enrolledChallenge,
    ChallengeDetail challengeDetail,
    ChallengeStart,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.get(SPKeys.email);
    await _stepController.fetchHealthDataFromLastUpdateTime(
        // milliseconds: DateTime(2022, 11, 09, 15).millisecondsSinceEpoch ??
        milliseconds:
            int.parse(enrolledChallenge.last_updated ?? DateTime.now().millisecondsSinceEpoch),
        requested: true);
    GroupDetailModel groupDetailModel;
    if (enrolledChallenge.challengeMode == 'group') {
      groupDetailModel =
          await challengeApi.challengeGroupDetail(groupID: enrolledChallenge.groupId);
    }
    var _prev = enrolledChallenge.userAchieved / enrolledChallenge.target * 100;
    var _currentTotal = challengeDetail.challengeUnit == 'steps'
        ? ((enrolledChallenge.userAchieved + _stepController.steps) / enrolledChallenge.target) *
            100
        : challengeDetail.challengeUnit == 'm'
            ? (((enrolledChallenge.userAchieved) + (_stepController.steps * 0.762)) /
                    enrolledChallenge.target) *
                100
            : (((enrolledChallenge.userAchieved) + (_stepController.steps * 0.0008)) /
                    enrolledChallenge.target) *
                100;
    print('Prev $_prev Total $_currentTotal');
    var _total = 0.0;

    if (enrolledChallenge.challengeMode == 'group') {
      _total = challengeDetail.challengeUnit == 'steps'
          ? enrolledChallenge.groupAchieved + _stepController.steps
          : challengeDetail.challengeUnit == 'm'
              ? enrolledChallenge.groupAchieved + _stepController.steps * 0.762
              : enrolledChallenge.groupAchieved + _stepController.steps * 0.0008;
    } else {
      _total = challengeDetail.challengeUnit == 'steps'
          ? enrolledChallenge.userAchieved + _stepController.steps
          : challengeDetail.challengeUnit == 'm'
              ? enrolledChallenge.userAchieved + _stepController.steps * 0.762
              : enrolledChallenge.userAchieved + _stepController.steps * 0.0008;
    }
    if (_total >= enrolledChallenge.target ||
        challengeDetail.challengeEndTime.isBefore(DateTime.now()) &&
            (DateFormat('MM-dd-yyyy').format(challengeDetail.challengeEndTime).toString() !=
                "01-01-2000")) {
      b6 = await preCertifiacte(
          context,
          enrolledChallenge.name,
          "Completed",
          "Hello",
          "Time",
          " ",
          challengeDetail,
          enrolledChallenge,
          enrolledChallenge.groupId != null ? groupDetailModel.groupName : " ",
          enrolledChallenge.userduration == 0
              ? 1
              : (enrolledChallenge.userduration ~/ 1440).toInt().toString());
      imgB6 = await imgPreCertifiacte(
          context,
          enrolledChallenge.name,
          "Completed",
          "Hello",
          "Time",
          " ",
          challengeDetail,
          enrolledChallenge,
          enrolledChallenge.groupId != null ? groupDetailModel.groupName : " ",
          enrolledChallenge.userduration == 0
              ? 1
              : (enrolledChallenge.userduration ~/ 1440).toInt().toString());
      print(imgB6);
    }
    if (enrolledChallenge.challenge_start_time.isBefore(
        DateTime.now())) if (enrolledChallenge.groupId == null || enrolledChallenge.groupId == '') {
      if (_prev <= 25 &&
          _currentTotal >= 25 &&
          _currentTotal.toInt() < enrolledChallenge.target &&
          _listController.currentUserEnrolledChallenges.length > 0) {
        await flutterLocalNotificationsPlugin.show(
          1,
          'Water Reminder',
          'Hey,Drink Water now! Since You have Completed 25 percentage of your ${challengeDetail.challengeName} Challenge.',
          waterReminder,
          payload: jsonEncode({'text': 'Water Reminder'}),
        );
      } else if (_prev <= 75 &&
          _currentTotal >= 75 &&
          _currentTotal.toInt() < enrolledChallenge.target &&
          _listController.currentUserEnrolledChallenges.length > 0) {
        await flutterLocalNotificationsPlugin.show(
          1,
          'Water Reminder',
          'Hey,Drink Water now! Since You have Completed 75 percentage of your ${challengeDetail.challengeName} Challenge',
          waterReminder,
          payload: jsonEncode({'text': 'Water Reminder'}),
        );
      }
      if (enrolledChallenge.userProgress == "progressing") {
        print('ReDesign line 3270');
        if (_stepController.steps > 0) {
          await ChallengeApi().updateChallengeTarget(
            updateChallengeTarget: UpdateChallengeTarget(
              firstTime: false,
              achieved: (challengeDetail.challengeUnit == 'steps'
                      ? _stepController.steps.toInt()
                      : challengeDetail.challengeUnit == 'm'
                          ? _stepController.steps * 0.762
                          : _stepController.steps * 0.0008)
                  .toString(),
              enrollmentId: enrolledChallenge.enrollmentId,
              duration: _stepController.duration.toString(),
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
          _stepController.update();
        }
        if (mounted) if (_total >= enrolledChallenge.target ||
            challengeDetail.challengeEndTime.isBefore(DateTime.now()) &&
                (DateFormat('MM-dd-yyyy').format(challengeDetail.challengeEndTime).toString() !=
                    "01-01-2000")) {
          _stepController.update();
          //Temp fix for the vibration cause it's crashing the IOS 15 to 17⚪️⚪️
          // Vibration.vibrate(pattern: [500, 1000, 500]);
          AudioPlayer().play(AssetSource('audio/challenge_completed.mp3'));
          Get.defaultDialog(
              barrierDismissible: false,
              backgroundColor: Colors.lightBlue.shade50,
              title: 'Kudos!',
              titlePadding: EdgeInsets.only(top: 20, bottom: 5, right: 10, left: 10),
              titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
              contentPadding: EdgeInsets.only(top: 0),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: Device.width / 1.5,
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
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.task_alt,
                    size: 40,
                    color: Colors.blue.shade300,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () async {
                      Get.back();
                      enrolledChallenge.userAchieved = enrolledChallenge.target.toDouble();
                      enrolledChallenge =
                          await ChallengeApi().getEnrollDetail(enrolledChallenge.enrollmentId);
                      Get.to(CertificateDetail(
                        challengeDetail: challengeDetail,
                        enrolledChallenge: enrolledChallenge,
                        firstCopmlete: false,
                      ));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 4,
                      decoration: BoxDecoration(
                          color: Colors.blue, borderRadius: BorderRadius.circular(20)),
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
        } else {
          null;
        }
      } else {
        if (ChallengeStart == true) {
          print('ReDesign line 3365');
          if (_stepController.steps > 0) {
            await ChallengeApi().updateChallengeTarget(
              updateChallengeTarget: UpdateChallengeTarget(
                  firstTime: false,
                  achieved: (challengeDetail.challengeUnit == 'steps'
                          ? _stepController.steps.toInt()
                          : challengeDetail.challengeUnit == 'm'
                              ? _stepController.steps * 0.762
                              : _stepController.steps * 0.0008)
                      .toString(),
                  enrollmentId: enrolledChallenge.enrollmentId,
                  duration: _stepController.duration.toString(),
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
                  certificatePngBase64: imgB6),
            );
            _stepController.update();
          }
          if (mounted) if (_total >= enrolledChallenge.target ||
              challengeDetail.challengeEndTime.isBefore(DateTime.now()) &&
                  (DateFormat('MM-dd-yyyy').format(challengeDetail.challengeEndTime).toString() !=
                      "01-01-2000")) {
            _stepController.update();
            //Temp fix for the vibration cause it's crashing the IOS 15 to 17⚪️⚪️
            // Vibration.vibrate(pattern: [500, 1000, 500]);
            Get.defaultDialog(
                barrierDismissible: true,
                backgroundColor: Colors.lightBlue.shade50,
                title: 'Kudos!',
                titlePadding: EdgeInsets.only(top: 20, bottom: 5, right: 10, left: 10),
                titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                contentPadding: EdgeInsets.only(top: 0),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: Device.width / 1.5,
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
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.task_alt,
                      size: 40,
                      color: Colors.blue.shade300,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () async {
                        Get.back();
                        enrolledChallenge.userAchieved = enrolledChallenge.target.toDouble();
                        enrolledChallenge =
                            await ChallengeApi().getEnrollDetail(enrolledChallenge.enrollmentId);
                        Get.to(CertificateDetail(
                          challengeDetail: challengeDetail,
                          enrolledChallenge: enrolledChallenge,
                          firstCopmlete: false,
                        ));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 4,
                        decoration: BoxDecoration(
                            color: Colors.blue, borderRadius: BorderRadius.circular(20)),
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
            AudioPlayer().play(AssetSource('audio/challenge_completed.mp3'));
          } else {
            null;
          }
        } else {
          null;
        }
      }
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
            _currentTotal.toInt() < enrolledChallenge.target &&
            _listController.currentUserEnrolledChallenges.length > 0) {
          await flutterLocalNotificationsPlugin.show(
            1,
            'Water Reminder',
            'Hey,Drink Water now! Since You have Completed 25 percentage of your ${challengeDetail.challengeName} Challenge.',
            waterReminder,
            payload: jsonEncode({'text': 'Water Reminder'}),
          );
        } else if (_prev <= 75 &&
            _currentTotal >= 75 &&
            _currentTotal.toInt() < enrolledChallenge.target &&
            _listController.currentUserEnrolledChallenges.length > 0) {
          await flutterLocalNotificationsPlugin.show(
            1,
            'Water Reminder',
            'Hey,Drink Water now! Since You have Completed 75 percentage of your ${challengeDetail.challengeName} Challenge',
            waterReminder,
            payload: jsonEncode({'text': 'Water Reminder'}),
          );
        }
        if (enrolledChallenge.userProgress != null) {
          print('ReDesign line 3489');
          if (_stepController.steps > 0) {
            await ChallengeApi().updateChallengeTarget(
              updateChallengeTarget: UpdateChallengeTarget(
                firstTime: false,
                achieved: (challengeDetail.challengeUnit == 'steps'
                        ? _stepController.steps.toInt()
                        : challengeDetail.challengeUnit == 'm'
                            ? _stepController.steps * 0.762
                            : _stepController.steps * 0.0008)
                    .toString(),
                enrollmentId: enrolledChallenge.enrollmentId,
                duration: _stepController.duration.toString(),
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
            _stepController.update();
          }
          if (mounted) if (_total >= enrolledChallenge.target ||
              challengeDetail.challengeEndTime.isBefore(DateTime.now()) &&
                  (DateFormat('MM-dd-yyyy').format(challengeDetail.challengeEndTime).toString() !=
                      "01-01-2000")) {
            _stepController.update();
      //Temp fix for the vibration cause it's crashing the IOS 15 to 17⚪️⚪️
            // Vibration.vibrate(pattern: [500, 1000, 500]);
            Get.defaultDialog(
                barrierDismissible: true,
                backgroundColor: Colors.lightBlue.shade50,
                title: 'Kudos!',
                titlePadding: EdgeInsets.only(top: 20, bottom: 0, right: 10, left: 10),
                titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                contentPadding: EdgeInsets.only(top: 0),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "You completed the run successfully.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.task_alt,
                      size: 40,
                      color: Colors.blue.shade300,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () async {
                        Get.back();
                        enrolledChallenge.userAchieved = enrolledChallenge.target.toDouble();
                        enrolledChallenge =
                            await ChallengeApi().getEnrollDetail(enrolledChallenge.enrollmentId);
                        Get.to(CertificateDetail(
                          challengeDetail: challengeDetail,
                          enrolledChallenge: enrolledChallenge,
                          firstCopmlete: false,
                        ));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 4,
                        decoration: BoxDecoration(
                            color: Colors.blue, borderRadius: BorderRadius.circular(20)),
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
            AudioPlayer().play(AssetSource('audio/challenge_completed.mp3'));
          } else {
            null;
          }
        } else {}
      }
    }
    _listController.getAfilitaionName();
  }
  //
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if (state == AppLifecycleState.resumed && mounted) {
  //     _listController.getAfilitaionName();
  //     print('************$state**********');
  //
  //     if (Platform.isAndroid) {
  //       if (_listController.currentUserEnrolledChallenges.length > 0) {
  //         final box = GetStorage();
  //         fitImplemented = box.read("fit") ?? false;
  //
  //         fitInstalled =
  //             await LaunchApp.isAppInstalled(androidPackageName: "com.google.android.apps.fitness");
  //         if (fitImplemented && fitInstalled) {
  //           for (int i = 0; i < _listController.currentUserEnrolledChallenges.length; i++) {
  //             print('List $i of ${_listController.currentUserEnrolledChallenges.length}');
  //             if (_listController.currentUserEnrolledChallenges[i].challenge_start_time
  //                 .isBefore(DateTime.now())) {
  //               if (_listController.currentUserEnrolledChallenges[i].selectedFitnessApp !=
  //                   'other_apps') {
  //                 updateStep(
  //                   _listController.currentUserEnrolledChallenges[i],
  //                   _listController.challengeList
  //                       .where((element) =>
  //                           element.challengeId ==
  //                           _listController.currentUserEnrolledChallenges[i].challengeId)
  //                       .first,
  //                   _listController.currentUserEnrolledChallenges[i].userProgress != null
  //                       ? true
  //                       : false,
  //                 );
  //               }
  //             }
  //           }
  //         } else {
  //           print('google fit ');
  //           if (_listController.affiliateCmpnyList.contains('Persistent') ||
  //               _listController.affiliateCmpnyList.contains('persistent') ||
  //               _listController.persistentInvite) {
  //             print('Contain Persistent');
  //           } else {
  //             dialogBox();
  //           }
  //         }
  //       }
  //     } else {
  //       // TODO IOS Code
  //       for (int i = 0; i < _listController.currentUserEnrolledChallenges.length; i++) {
  //         if (_listController.currentUserEnrolledChallenges[i].challenge_start_time
  //             .isBefore(DateTime.now())) {
  //           if (_listController.currentUserEnrolledChallenges[i].selectedFitnessApp != 'other_apps')
  //             updateStep(
  //               _listController.currentUserEnrolledChallenges[i],
  //               _listController.challengeList
  //                   .where((element) =>
  //                       element.challengeId ==
  //                       _listController.currentUserEnrolledChallenges[i].challengeId)
  //                   .first,
  //               _listController.currentUserEnrolledChallenges[i].userProgress != null
  //                   ? true
  //                   : false,
  //             );
  //         }
  //       }
  //     }
  //   }
  // }

  dialogBox() {
    bool e = fitImplemented && fitInstalled;
    return e
        ? Container()
        : Get.defaultDialog(
            title: "",
            titlePadding: EdgeInsets.only(),
            barrierDismissible: false,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 25,
                          backgroundImage: AssetImage("assets/icons/googlefit.png"),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Google Fit",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.blueGrey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      bool t = await LaunchApp.isAppInstalled(
                          androidPackageName: "com.google.android.apps.fitness");
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

                      if (t) {
                        try {
                          GoogleSignIn _googleSignIn = GoogleSignIn(
                            scopes: [
                              'email',
                              'https://www.googleapis.com/auth/contacts.readonly',
                            ],
                          );
                          await _googleSignIn.signOut();
                          HealthFactory health = HealthFactory();
                          await health
                              .requestAuthorization(types, permissions: permissions)
                              .then((value) async {
                            final box = GetStorage();
                            SharedPreferences _prefs = await SharedPreferences.getInstance();
                            _prefs.setBool('fit', true);
                            box.write("fit", value);
                            fitImplemented = value;
                            Get.back();
                            Get.snackbar('Success', 'Connected Successfully',
                                margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                backgroundColor: AppColors.primaryAccentColor,
                                colorText: Colors.white,
                                duration: Duration(seconds: 5),
                                snackPosition: SnackPosition.BOTTOM);
                          });
                        } catch (e) {
                          print(e);
                        }
                      } else {
                        await LaunchApp.openApp(
                            openStore: true, androidPackageName: "com.google.android.apps.fitness");
                      }
                    },
                    child: Text('Connect to Google Fit'),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  ),
                )
              ],
            ),
          );
  }

  Widget detailWidget(EnrolledChallenge enrolledChallenge, ChallengeDetail challengeDetail) {
    if (enrolledChallenge.challenge_start_time.isBefore(DateTime.now()) ||
        DateFormat('MM-dd-yyyy').format(enrolledChallenge.challenge_start_time) == "01-01-2000") {
      return Center(
        child: enrolledChallenge.selectedFitnessApp != "other_apps"
            ? enrolledChallenge.userProgress == null || enrolledChallenge.userProgress == " "
                ? Column(children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 4, 15),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "Run has started on ",
                            style: TextStyle(
                              fontSize: Device.height < 600 ? 12 : 12,
                              color: Colors.grey.shade700,
                              letterSpacing: 0.7,
                            ),
                          ),
                          Text(
                            "${Jiffy(challengeDetail.challengeStartTime).format("do MMM yyyy")}",
                            style: TextStyle(
                                fontSize: Device.height < 600 ? 12 : 12,
                                color: Colors.lightBlue,
                                letterSpacing: 0.7,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            " at ",
                            style: TextStyle(
                              fontSize: Device.height < 600 ? 12 : 12,
                              color: Colors.black,
                              letterSpacing: 0.7,
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm aa').format(challengeDetail.challengeStartTime),
                            style: TextStyle(
                                fontSize: Device.height < 600 ? 12 : 12,
                                color: Colors.lightBlue,
                                letterSpacing: 0.7,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        child: Text('Start',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontFamily: 'Popins',
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          primary: DateTime.now().isAfter(challengeDetail.challengeStartTime)
                              ? AppColors.primaryAccentColor
                              : Colors.grey,
                        ),
                        onPressed: () async {
                          EnrolledChallenge _enrollChallenge =
                              await challengeApi.getEnrollDetail(enrolledChallenge.enrollmentId);
                          if (enrolledChallenge.selectedFitnessApp == "other_apps") {
                            Get.to(PersistentOnGoingScreen(
                                challengeStarted: true,
                                enrolledChallenge: _enrollChallenge,
                                nrmlJoin: false,
                                challengeDetail: challengeDetail));
                          } else {
                            if (enrolledChallenge.challengeMode == "individual") {
                              await challengeApi.updateChallengeTarget(
                                  updateChallengeTarget: UpdateChallengeTarget(
                                enrollmentId: enrolledChallenge.enrollmentId,
                                firstTime: true,
                              ));
                              EnrolledChallenge _enrollChallenge = await challengeApi
                                  .getEnrollDetail(enrolledChallenge.enrollmentId);
                              Get.to(OnGoingChallenge(
                                  groupDetail: null,
                                  challengeDetail: challengeDetail,
                                  navigatedNormal: false,
                                  filteredList: _enrollChallenge));
                            } else {
                              GroupDetailModel groupDetail;
                              if (_enrollChallenge.challengeMode != "individual")
                                groupDetail = await ChallengeApi()
                                    .challengeGroupDetail(groupID: _enrollChallenge.groupId);
                              ChallengeDetail challengeDetail = await ChallengeApi()
                                  .challengeDetail(challengeId: _enrollChallenge.challengeId);
                              List<GroupUser> listofGroupUsers = await ChallengeApi()
                                  .listofGroupUsers(groupId: _enrollChallenge.groupId);
                              if (challengeDetail.minUsersGroup > listofGroupUsers.length) {
                                minUserDialog(challengeDetail);
                              } else {
                                Get.to(OnGoingChallenge(
                                    groupDetail: groupDetail,
                                    challengeDetail: challengeDetail,
                                    navigatedNormal: true,
                                    filteredList: _enrollChallenge));
                              }
                            }
                          }
                        },
                      ),
                    )
                  ])
                : Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: 60,
                              ),
                              Text("Achieved",
                                  style: TextStyle(
                                      fontSize: Device.height < 600 ? 15 : 16,
                                      color: Colors.grey,
                                      letterSpacing: 0.7,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  challengeDetail.challengeUnit == 'steps'
                                      ? 'Steps'
                                      : challengeDetail.challengeUnit == 'm'
                                          ? 'Distance (m)'
                                          : "Distance (km)",
                                  style: TextStyle(
                                      fontSize: 13.sp, color: Colors.grey.withOpacity(0.8))),
                              Text(
                                  "${challengeDetail.challengeUnit == 'steps' ? enrolledChallenge.userAchieved.toInt() : enrolledChallenge.userAchieved.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.lightBlue,
                                      letterSpacing: 0.7,
                                      fontWeight: FontWeight.w600))
                            ],
                          ),
                          SizedBox(
                            width: 60,
                          ),
                          Column(children: [
                            Text("Target",
                                style: TextStyle(
                                    fontSize: Device.height < 600 ? 15 : 16,
                                    color: Colors.grey,
                                    letterSpacing: 0.7,
                                    fontWeight: FontWeight.w600)),
                            Text(
                                challengeDetail.challengeUnit == 'steps'
                                    ? 'Steps'
                                    : challengeDetail.challengeUnit == 'm'
                                        ? 'Distance (m)'
                                        : "Distance (km)",
                                style: TextStyle(
                                    fontSize: 13.sp, color: Colors.grey.withOpacity(0.8))),
                            Text("${challengeDetail.targetToAchieve}",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.lightBlue,
                                    letterSpacing: 0.7,
                                    fontWeight: FontWeight.w600))
                          ])
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: NeumorphicIndicator(
                          orientation: NeumorphicIndicatorOrientation.horizontal,
                          height: 8,
                          width: MediaQuery.of(context).size.width * 0.75,
                          percent: enrolledChallenge.userAchieved / enrolledChallenge.target,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 30,
                            height: Device.height < 600 ? 30 : 40,
                            child: Image.asset("assets/images/diet/burned.png"),
                          ),
                          Text("Burned Calories ",
                              style: TextStyle(
                                  fontSize: Device.height < 600 ? 15 : 16,
                                  color: Colors.grey,
                                  letterSpacing: 0.7,
                                  fontWeight: FontWeight.w600)),
                          Text(
                            (challengeDetail.challengeUnit == "steps"
                                ? ((enrolledChallenge.userAchieved) * 0.04).toStringAsFixed(2)
                                : challengeDetail.challengeUnit == "m"
                                    ? ((enrolledChallenge.userAchieved / 0.762) * 0.04)
                                        .toStringAsFixed(2)
                                    : (((enrolledChallenge.userAchieved / 0.0008)) * 0.04)
                                        .toStringAsFixed(2)),
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.lightBlue,
                                letterSpacing: 0.7,
                                fontWeight: FontWeight.w600),
                          )
                        ], //challengeUnit
                      ),
                    ],
                  )
            : Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  enrolledChallenge.docStatus.toLowerCase() == "requested"
                      ? Text(
                          'Uploaded',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Device.height < 600 ? 15 : 16,
                              color: Colors.grey,
                              letterSpacing: 0.7,
                              fontWeight: FontWeight.w600),
                        )
                      : Text(
                          'Upload now',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Device.height < 600 ? 15 : 16,
                              color: Colors.grey,
                              letterSpacing: 0.7,
                              fontWeight: FontWeight.w600),
                        ),
                ],
              ),
      );
    } else {
      return Column(
        children: [
          Container(
              child: enrolledChallenge.selectedFitnessApp != "other_apps"
                  ? Column(children: [
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 4, 15),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              "Run will start on ",
                              style: TextStyle(
                                fontSize: Device.height < 600 ? 12 : 12,
                                color: Colors.grey.shade700,
                                letterSpacing: 0.7,
                              ),
                            ),
                            Text(
                              "${Jiffy(challengeDetail.challengeStartTime).format("do MMM yyyy")}",
                              style: TextStyle(
                                  fontSize: Device.height < 600 ? 12 : 12,
                                  color: Colors.lightBlue,
                                  letterSpacing: 0.7,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              " at ",
                              style: TextStyle(
                                fontSize: Device.height < 600 ? 12 : 12,
                                color: Colors.black,
                                letterSpacing: 0.7,
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm aa').format(challengeDetail.challengeStartTime),
                              style: TextStyle(
                                  fontSize: Device.height < 600 ? 12 : 12,
                                  color: Colors.lightBlue,
                                  letterSpacing: 0.7,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          child: Text('Start',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontFamily: 'Popins',
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            primary: DateFormat('MM-dd-yyyy')
                                            .format(challengeDetail.challengeStartTime)
                                            .toString() !=
                                        "01-01-2000" &&
                                    DateTime.now().isAfter(challengeDetail.challengeStartTime)
                                ? AppColors.primaryAccentColor
                                : Colors.grey,
                          ),
                          onPressed: () {},
                        ),
                      )
                    ])
                  : Column(
                      children: [
                        SizedBox(height: 30),
                        Text("Upload Option will be enabled on",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                letterSpacing: 0.7,
                                fontWeight: FontWeight.w600)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "${Jiffy(enrolledChallenge.challenge_start_time).format("do MMM yyyy")}",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.lightBlue,
                                  letterSpacing: 0.7,
                                  fontWeight: FontWeight.w600)),
                        )
                      ],
                    )),
        ],
      );
    }
  }

  minUserDialog(ChallengeDetail challengeDetail) => Get.defaultDialog(
      barrierDismissible: false,
      backgroundColor: Colors.lightBlue.shade50,
      title: 'Run will start once the minimum ${challengeDetail.minUsersGroup} users are joined',
      titlePadding: EdgeInsets.only(top: 20, bottom: 0, right: 10, left: 10),
      titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
      contentPadding: EdgeInsets.only(top: 0),
      content: Column(
        children: [
          Divider(
            thickness: 2,
          ),
          Icon(
            Icons.task_alt,
            size: 40,
            color: Colors.blue.shade300,
          ),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 4,
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
  runTypeNavigator({String type, affiName}) async {
    Get.defaultDialog(
      barrierDismissible: false,
      title: 'Loading',
      content: CircularProgressIndicator(),
      titlePadding: EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
      titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
      contentPadding: EdgeInsets.only(top: 0),
    );
    Challenge _challenge;
    if (affiName == "Persistent" || affiName == "persistent") {
      _challenge = _listController.runtypeChallengeList
          .where((element) => element.challengeRunType == type)
          .first;
    } else {
      _challenge = _listController.runtypeIHLChallengeList
          .where((element) => element.challengeRunType == type)
          .first;
    }
    _listController.allChallengeList();
    ChallengeDetail _challengeDetail =
        await challengeApi.challengeDetail(challengeId: _challenge.challengeId);
    List<EnrolledChallenge> _currentEnrolledChallenge =
        await ChallengeApi().listofUserEnrolledChallenges(userId: _listController.userid);
    Get.back();
    if (_currentEnrolledChallenge
        .where((ele) => ele.challengeId == _challenge.challengeId)
        .isEmpty) {
      Get.to(ChallengeDetailsScreen(
        challengeDetail: _challengeDetail,
        fromNotification: true,
      ));
      // Get.to(OnGoingChallenge(challengeDetail: challengeDetail, navigatedNormal: true, filteredList: _listController.currentUserEnrolledChallenges.where((element) => element.challengeId == challengedetail.challengeId).first));
    } else {
      EnrolledChallenge _enrolledChallenge;
      _enrolledChallenge = _currentEnrolledChallenge
          .where((element) => element.challengeId == _challenge.challengeId)
          .first;
      if (_enrolledChallenge.userProgress == 'progressing' ||
          _enrolledChallenge.userProgress == null) {
        if (_enrolledChallenge.selectedFitnessApp == "other_apps") {
          Get.to(PersistentOnGoingScreen(
              challengeStarted: true,
              enrolledChallenge: _enrolledChallenge,
              nrmlJoin: false,
              challengeDetail: _challengeDetail));
        } else {
          Get.to(OnGoingChallenge(
              challengeDetail: _challengeDetail,
              navigatedNormal: false,
              filteredList: _enrolledChallenge));
        }
      } else {
        if (_enrolledChallenge.challengeMode == 'individual') {
          Get.to(CertificateDetail(
            challengeDetail: _challengeDetail,
            enrolledChallenge: _enrolledChallenge,
            groupDetail: null,
            currentUserIsAdmin: false,
            firstCopmlete: false,
          ));
        } else {
          bool currentUserIsAdmin = false;
          GroupDetailModel groupDetailModel;
          String userid = iHLUserId;
          await ChallengeApi().listofGroupUsers(groupId: _enrolledChallenge.groupId).then((value) {
            for (var i in value) {
              if (i.userId == userid && i.role == "admin") {
                currentUserIsAdmin = true;
                break;
              }
            }
          });
          groupDetailModel =
              await ChallengeApi().challengeGroupDetail(groupID: _enrolledChallenge.groupId);
          Get.to(CertificateDetail(
            challengeDetail: _challengeDetail,
            enrolledChallenge: _enrolledChallenge,
            groupDetail: groupDetailModel,
            currentUserIsAdmin: currentUserIsAdmin,
            firstCopmlete: false,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.put(VitalsContoller());
    final controller = Get.put(PersistentGetXController());
    if (firsttime)
      Future.delayed(Duration.zero, () {
        firsttime = false;
        showAlert(context);
      });
    // isVerified = false;
    // loading=true;
    // isJointAccount = true;
    if (loading && isJointAccount) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (!isVerified) {
      return NotVarified();
    }
    if (firsttime) {}
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width * 1.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.0, 0.0),
            end: Alignment(1.0, 0.0),
            colors: [
              Theme.of(context).primaryColorLight,
              Theme.of(context).primaryColorDark,
              // const Color(0xFF6aa6f8),
              // const Color(0xFF1a60be)
            ], // whitish to gray
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            loadUserInfo(),
            Container(
              margin: const EdgeInsets.only(
                top: 40.0,
              ),
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                color: Color(0xFFFFFFFF),
                boxShadow: [
                  new BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20.0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                    ),
                    transform: Matrix4.translationValues(0.0, -30.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            MaterialButton(
                              onPressed: () {
                                ///reAssigning the value to vitals on Home
                                ///because every time
                                Get.find<VitalsContoller>().vitalData();
                                vitalsOnHome = [
                                  'bmi',
                                  'weightKG',
                                  // 'heightMeters',
                                  'temperature',
                                  'pulseBpm',
                                  'fatRatio',
                                  'ECGBpm',
                                  'bp',
                                  'spo2',
                                  'protien',
                                  'extra_cellular_water',
                                  'intra_cellular_water',
                                  'mineral',
                                  'skeletal_muscle_mass',
                                  'body_fat_mass',
                                  'body_cell_mass',
                                  'waist_hip_ratio',
                                  'percent_body_fat',
                                  'waist_height_ratio',
                                  'visceral_fat',
                                  'basal_metabolic_rate',
                                  'bone_mineral_content',
                                ];
                                Get.to(VitalTab(
                                  isShowAsMainScreen: false,
                                ));
                              },
                              color: Theme.of(context).primaryColor,
                              highlightColor: Color(0xFF89b9f0),
                              textColor: Colors.white,
                              child: Icon(
                                Icons.favorite_border,
                                size: 35,
                              ),
                              padding: EdgeInsets.all(16),
                              shape: CircleBorder(),
                              elevation: 10,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: Text(
                                'My\n Vitals',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  // fontFamily: 'Poppins',
                                  fontFamily: 'Poppins',
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  // color: Color(0xFF6f6f6f),
                                  ///
                                  color: FitnessAppTheme.grey,
                                  // fontSize: ScUtil().setSp(14),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            MaterialButton(
                              onPressed: () {
                                Get.to(ViewallTeleDashboard(
                                  backNav: false,
                                ));
                              },
                              color: Theme.of(context).primaryColor,
                              highlightColor: Color(0xFF89b9f0),
                              textColor: Colors.white,
                              child: Icon(
                                FontAwesomeIcons.userMd,
                                size: 35,
                              ),
                              padding: EdgeInsets.all(16),
                              shape: CircleBorder(),
                              elevation: 10,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: Text(
                                'Tele\nConsultation',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  // fontFamily: 'Poppins',
                                  fontFamily: 'Poppins',
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  // color: Color(0xFF6f6f6f),
                                  ///
                                  color: FitnessAppTheme.grey,
                                  // fontSize: ScUtil().setSp(14),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            MaterialButton(
                              onPressed: () {
                                Get.off(WellnessCart());
                              },
                              color: Theme.of(context).primaryColor,
                              highlightColor: Color(0xFF89b9f0),
                              textColor: Colors.white,
                              child: Icon(
                                FontAwesomeIcons.walking,
                                size: 35,
                              ),
                              padding: EdgeInsets.all(16),
                              shape: CircleBorder(),
                              elevation: 10,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: Text(
                                'Health\n E-Market',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  // fontFamily: 'Poppins',
                                  fontFamily: 'Poppins',
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  // color: Color(0xFF6f6f6f),
                                  ///
                                  color: FitnessAppTheme.grey,
                                  // fontSize: ScUtil().setSp(14),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GetBuilder<ListChallengeController>(
                      init: ListChallengeController(),
                      builder: (_) {
                        return Visibility(
                            visible: false,
                            //  ((_.affiliateCmpnyList.contains("persistent") ||
                            //         _.affiliateCmpnyList.contains("Persistent")) ||
                            //     _.persistentInvite),
                            child: Column(
                              children: [
                                SizedBox(
                                    height: 220,
                                    width: MediaQuery.of(context).size.width - 30,
                                    child: InkWell(
                                      onTap: () {
                                        _listController.listOfChalleneg();
                                        Get.defaultDialog(
                                            barrierDismissible: true,
                                            backgroundColor: Colors.lightBlue.shade50,
                                            title: "Select Run Type",
                                            titlePadding: EdgeInsets.only(
                                                top: 20, bottom: 0, right: 10, left: 10),
                                            titleStyle: TextStyle(
                                                letterSpacing: 1,
                                                color: Colors.blue.shade400,
                                                fontSize: 20),
                                            content:
                                                StatefulBuilder(builder: (context, setStateFull) {
                                              return Column(
                                                children: [
                                                  _listController.runtypeChallengeList.isNotEmpty
                                                      ? DropdownButton<String>(
                                                          underline: Container(
                                                            height: 1.0,
                                                            decoration: BoxDecoration(
                                                              border: Border(
                                                                bottom: BorderSide(
                                                                  color: Colors.black,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          hint: _listController.runtypeChallengeList
                                                                      .length !=
                                                                  0
                                                              ? Text('Select Type')
                                                              : Text('No Run '),
                                                          value: _selectedLocation,
                                                          onChanged: (newValue) {
                                                            setStateFull(() {
                                                              _selectedLocation = newValue;
                                                            });
                                                          },
                                                          items: _listController
                                                              .runtypeChallengeList
                                                              .map((Challenge value) {
                                                            return DropdownMenuItem<String>(
                                                              value: value.challengeRunType,
                                                              child: Text(value.challengeRunType),
                                                            );
                                                          }).toList(),
                                                        )
                                                      : Text("No Run is available"),
                                                  _listController.runtypeChallengeList.isNotEmpty
                                                      ? Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: ElevatedButton(
                                                            onPressed: () => runTypeNavigator(
                                                                type: _selectedLocation,
                                                                affiName: "Persistent"),
                                                            child: Text("Proceed"),
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              );
                                            }));
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  "http://ihlapibackup.blob.core.windows.net/higiblobs/HealthChallenge/bnr_hea_chal_39d4b7cb12d94730935a6941b4c6e0f7.png"),
                                              fit: BoxFit.fill,
                                              filterQuality: FilterQuality.high),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(50),
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8)),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 4,
                                                offset: Offset(1, 1),
                                                color: Colors.grey.shade400)
                                          ],
                                          color: Colors.white,
                                        ),
                                      ),
                                    ))
                              ],
                            ));
                      }),
                  // SizedBox(height: 10),
                  GetBuilder<ListChallengeController>(
                      init: ListChallengeController(),
                      builder: (_) {
                        String _selectedType;
                        return Visibility(
                            visible: false,
                            // ((_.affiliateCmpnyList.contains("IHL Care") ||
                            //             _.affiliateCmpnyList.contains("India Health Link")) ||
                            //         _.affiliateCmpnyList.contains("India Health Link Pvt Ltd") ||
                            //         _.affiliateCmpnyList.contains("ihl_care") ||
                            //         _.ihlInvite
                            //     //  ||
                            //     // _.isIHLCareBannerVisibleForUserInvitedThroughEmail),
                            //     ),
                            child: Column(
                              children: [
                                SizedBox(
                                    height: 220,
                                    width: MediaQuery.of(context).size.width - 30,
                                    child: InkWell(
                                      onTap: () {
                                        _listController.listOfChalleneg();
                                        Get.defaultDialog(
                                            barrierDismissible: true,
                                            backgroundColor: Colors.lightBlue.shade50,
                                            title: "Select Run Type",
                                            titlePadding: EdgeInsets.only(
                                                top: 20, bottom: 0, right: 10, left: 10),
                                            titleStyle: TextStyle(
                                                letterSpacing: 1,
                                                color: Colors.blue.shade400,
                                                fontSize: 20),
                                            content:
                                                StatefulBuilder(builder: (context, setStateFull) {
                                              return Column(
                                                children: [
                                                  _listController.runtypeIHLChallengeList.isNotEmpty
                                                      ? DropdownButton<String>(
                                                          underline: Container(
                                                            height: 1.0,
                                                            decoration: BoxDecoration(
                                                              border: Border(
                                                                bottom: BorderSide(
                                                                  color: Colors.black,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          hint: _listController
                                                                      .runtypeIHLChallengeList
                                                                      .length !=
                                                                  0
                                                              ? Text('Run Type')
                                                              : Text('No Run '),
                                                          value: _selectedType,
                                                          onChanged: (newValue) {
                                                            setStateFull(() {
                                                              _selectedType = newValue;
                                                            });
                                                          },
                                                          items: _listController
                                                              .runtypeIHLChallengeList
                                                              .map((Challenge value) {
                                                            return DropdownMenuItem<String>(
                                                              value: value.challengeRunType,
                                                              child: Text(value.challengeRunType),
                                                            );
                                                          }).toList(),
                                                        )
                                                      : Text("No Run is available"),
                                                  _listController.runtypeIHLChallengeList.isNotEmpty
                                                      ? Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              runTypeNavigator(
                                                                  type: _selectedType,
                                                                  affiName: "IHL");
                                                            },
                                                            child: Text("Proceed"),
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              );
                                            }));
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  "http://ihlapibackup.blob.core.windows.net/higiblobs/HealthChallenge/hea_chal_81dd8081ee0f4a0e95f1e58515423a6c.png"),
                                              fit: BoxFit.fill,
                                              filterQuality: FilterQuality.high),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(50),
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8)),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 4,
                                                offset: Offset(1, 1),
                                                color: Colors.grey.shade400)
                                          ],
                                          color: Colors.white,
                                        ),
                                      ),
                                    ))
                              ],
                            ));
                      }),
                  sectionTitle(context, "Calorie Tracker"),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: MediterranesnDietView(
                        isNavigation: true,
                      )),
                  Visibility(
                      visible: eventDetailList != null &&
                          userEnrolledMap != null &&
                          userEnrolledMap.isNotEmpty,
                      child: sectionTitle(context, "Events")),

                  GetBuilder<ListChallengeController>(
                      init: ListChallengeController(),
                      builder: (_) {
                        return Visibility(
                            visible: _.currentUserEnrolledChallenges.length > 0 ||
                                _.completedChallenge.length > 0,
                            child: sectionTitle(context, "Health Challenges"));
                      }),
                  GetBuilder<ListChallengeController>(
                      init: ListChallengeController(),
                      builder: (_) {
                        double _h = MediaQuery.of(context).size.height;
                        return Visibility(
                          visible: _.currentUserEnrolledChallenges.length > 0 ||
                              _.completedChallenge.length > 0,
                          child: Container(
                            height: _h > 568 ? 26.3.h : (_h / 2.8),
                            width: 95.w,
                            margin: EdgeInsets.only(
                                top: ScUtil().setHeight(8.sp),
                                left: ScUtil().setWidth(10.sp),
                                right: ScUtil().setWidth(10.sp)),
                            // child: listChallengeScroll(),
                            child: GetBuilder<ListChallengeController>(
                              init: ListChallengeController(),
                              builder: (_val) {
                                return _val.loading
                                    ? Shimmer.fromColors(
                                        child: Container(
                                          height: 180,
                                          width: MediaQuery.of(context).size.width / 4,
                                        ),
                                        baseColor: Colors.grey.withOpacity(0.04),
                                        highlightColor: AppColors.primaryColor.withOpacity(0.4),
                                      )
                                    : PageView.builder(
                                        controller: PageController(
                                          viewportFraction: 0.92,
                                          initialPage: 0,
                                        ),
                                        itemCount: _val.currentUserEnrolledChallenges.length +
                                            _val.completedChallenge.length,
                                        itemBuilder: (c, index) {
                                          try {
                                            return index < _.currentUserEnrolledChallenges.length
                                                ? InkWell(
                                                    onTap: () async {
                                                      if (_val.currentUserEnrolledChallenges[index]
                                                              .selectedFitnessApp !=
                                                          "other_apps") {
                                                        if (_val
                                                                .currentUserEnrolledChallenges[
                                                                    index]
                                                                .challengeMode ==
                                                            "individual") {
                                                          Get.to(OnGoingChallenge(
                                                              challengeDetail: _val.challengeList
                                                                  .where((element) =>
                                                                      element.challengeId ==
                                                                      _val
                                                                          .currentUserEnrolledChallenges[
                                                                              index]
                                                                          .challengeId)
                                                                  .first,
                                                              navigatedNormal: true,
                                                              filteredList:
                                                                  _val.currentUserEnrolledChallenges[
                                                                      index]));
                                                        } else {
                                                          GroupDetailModel groupDetail;
                                                          if (_val
                                                                  .currentUserEnrolledChallenges[
                                                                      index]
                                                                  .challengeMode !=
                                                              "individual")
                                                            groupDetail = await ChallengeApi()
                                                                .challengeGroupDetail(
                                                                    groupID: _val
                                                                        .currentUserEnrolledChallenges[
                                                                            index]
                                                                        .groupId);
                                                          ChallengeDetail challengeDetail =
                                                              await ChallengeApi().challengeDetail(
                                                                  challengeId: _val
                                                                      .currentUserEnrolledChallenges[
                                                                          index]
                                                                      .challengeId);
                                                          List<GroupUser> listofGroupUsers =
                                                              await ChallengeApi().listofGroupUsers(
                                                                  groupId: _val
                                                                      .currentUserEnrolledChallenges[
                                                                          index]
                                                                      .groupId);
                                                          if (challengeDetail.minUsersGroup >
                                                              listofGroupUsers.length) {
                                                            minUserDialog(challengeDetail);
                                                          } else {
                                                            Get.to(OnGoingChallenge(
                                                                groupDetail: groupDetail,
                                                                challengeDetail: _val.challengeList
                                                                    .where((element) =>
                                                                        element.challengeId ==
                                                                        _val
                                                                            .currentUserEnrolledChallenges[
                                                                                index]
                                                                            .challengeId)
                                                                    .first,
                                                                navigatedNormal: true,
                                                                filteredList:
                                                                    _val.currentUserEnrolledChallenges[
                                                                        index]));
                                                          }
                                                        }
                                                      } else {
                                                        if (DateFormat('MM-dd-yyyy')
                                                                    .format(_val.challengeList
                                                                        .where((element) =>
                                                                            element.challengeId ==
                                                                            _val
                                                                                .currentUserEnrolledChallenges[
                                                                                    index]
                                                                                .challengeId)
                                                                        .first
                                                                        .challengeStartTime)
                                                                    .toString() ==
                                                                "01-01-2000" ||
                                                            DateTime.now().isAfter(_val
                                                                .challengeList
                                                                .where((element) =>
                                                                    element.challengeId ==
                                                                    _val
                                                                        .currentUserEnrolledChallenges[
                                                                            index]
                                                                        .challengeId)
                                                                .first
                                                                .challengeStartTime)) {
                                                          _.enrolledChallenge();
                                                          log('after');
                                                          Get.to(PersistentOnGoingScreen(
                                                            nrmlJoin: false,
                                                            challengeStarted: DateFormat(
                                                                            'MM-dd-yyyy')
                                                                        .format(_val.challengeList
                                                                            .where((element) =>
                                                                                element
                                                                                    .challengeId ==
                                                                                _val
                                                                                    .currentUserEnrolledChallenges[
                                                                                        index]
                                                                                    .challengeId)
                                                                            .first
                                                                            .challengeStartTime)
                                                                        .toString() !=
                                                                    "01-01-2000" &&
                                                                DateTime.now().isAfter(_val
                                                                    .challengeList
                                                                    .where((element) =>
                                                                        element.challengeId ==
                                                                        _val
                                                                            .currentUserEnrolledChallenges[
                                                                                index]
                                                                            .challengeId)
                                                                    .first
                                                                    .challengeStartTime),
                                                            enrolledChallenge:
                                                                _val.currentUserEnrolledChallenges[
                                                                    index],
                                                            challengeDetail: _val.challengeList
                                                                .where((element) =>
                                                                    element.challengeId ==
                                                                    _val
                                                                        .currentUserEnrolledChallenges[
                                                                            index]
                                                                        .challengeId)
                                                                .first,
                                                          ));
                                                        } else {
                                                          null;
                                                        }
                                                      }
                                                    },
                                                    child: GetBuilder(
                                                        init: ListChallengeController(),
                                                        builder: (_val) {
                                                          try {
                                                            ChallengeDetail _details = _val
                                                                .challengeList
                                                                .where((element) =>
                                                                    element.challengeId ==
                                                                    _val
                                                                        .currentUserEnrolledChallenges[
                                                                            index]
                                                                        .challengeId)
                                                                .first;
                                                            return Container(
                                                              margin: EdgeInsets.only(
                                                                  left: index == 0 ? 0 : 10.sp,
                                                                  right: 0.sp,
                                                                  top: 5.sp,
                                                                  bottom: 5.sp),
                                                              //height: 100,
                                                              decoration: BoxDecoration(
                                                                // image: DecorationImage(
                                                                //   image: NetworkImage(
                                                                //       _details.bannerImgUrl),
                                                                //   fit: BoxFit.cover,
                                                                // ),
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(8),
                                                                    topRight: Radius.circular(50),
                                                                    bottomLeft: Radius.circular(8),
                                                                    bottomRight:
                                                                        Radius.circular(8)),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      blurRadius: 4,
                                                                      offset: Offset(1, 1),
                                                                      color: Colors.grey.shade400)
                                                                ],
                                                                color: Colors.white,
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.fromLTRB(
                                                                    3, 5, 0, 10),
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width: 1,
                                                                        ),
                                                                        SizedBox(
                                                                          height: 50,
                                                                          width: 70,
                                                                          child: CircleAvatar(
                                                                            backgroundImage:
                                                                                NetworkImage(_details
                                                                                    .challengeImgUrlThumbnail),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width: 42.w,
                                                                          child: Text(
                                                                            _details.challengeName,
                                                                            softWrap: true,
                                                                            style: TextStyle(
                                                                                fontSize: 18,
                                                                                color: Colors
                                                                                    .blueGrey
                                                                                    .shade600,
                                                                                letterSpacing: 0.7,
                                                                                fontWeight:
                                                                                    FontWeight
                                                                                        .w600),
                                                                          ),
                                                                        ),
                                                                        Spacer(),
                                                                        // GetBuilder<
                                                                        //         PersistentGetXController>(
                                                                        //     init:
                                                                        //         PersistentGetXController(),
                                                                        //     builder: (_camVal) {
                                                                        //       return MaterialButton(
                                                                        //         onPressed: ()
                                                                        //         {
                                                                        //           ((_val.currentUserEnrolledChallenges[index].challenge_start_time.isBefore(DateTime.now()) && _val.currentUserEnrolledChallenges[index].userProgress != null ||
                                                                        //                       DateFormat('MM-dd-yyyy').format(_val.currentUserEnrolledChallenges[index].challenge_start_time) == "01-01-2000" &&
                                                                        //                           _val.currentUserEnrolledChallenges[index].userProgress !=
                                                                        //                               null ||
                                                                        //                       _val.currentUserEnrolledChallenges[index].challenge_start_time.isBefore(DateTime.now()) &&
                                                                        //                           _val.currentUserEnrolledChallenges[index].selectedFitnessApp ==
                                                                        //                               "other_apps") &&
                                                                        //                   _val.imageDatas[index].length <
                                                                        //                       10)
                                                                        //               ? _camVal
                                                                        //                   .imageSelection(
                                                                        //                   isSelfi:
                                                                        //                       true,
                                                                        //                   enrollChallenge:
                                                                        //                       _val.currentUserEnrolledChallenges[
                                                                        //                           index],
                                                                        //                   challengeDetail: _val
                                                                        //                       .challengeList
                                                                        //                       .where((element) =>
                                                                        //                           element.challengeId ==
                                                                        //                           _val.currentUserEnrolledChallenges[index].challengeId)
                                                                        //                       .first,
                                                                        //                 )
                                                                        //               : null;
                                                                        //         },
                                                                        //         color: ((_val.currentUserEnrolledChallenges[index].challenge_start_time.isBefore(DateTime
                                                                        //                             .now()) &&
                                                                        //                         _val.currentUserEnrolledChallenges[index].userProgress !=
                                                                        //                             null ||
                                                                        //                     DateFormat('MM-dd-yyyy').format(_val.currentUserEnrolledChallenges[index].challenge_start_time) ==
                                                                        //                             "01-01-2000" &&
                                                                        //                         _val.currentUserEnrolledChallenges[index].userProgress !=
                                                                        //                             null ||
                                                                        //                     _val.currentUserEnrolledChallenges[index].challenge_start_time.isBefore(DateTime.now()) &&
                                                                        //                         _val.currentUserEnrolledChallenges[index].selectedFitnessApp ==
                                                                        //                             "other_apps") &&
                                                                        //                 _val.imageDatas[index].length <
                                                                        //                     10)
                                                                        //             ? Theme.of(
                                                                        //                     context)
                                                                        //                 .primaryColor
                                                                        //             : Colors.grey
                                                                        //                 .withOpacity(
                                                                        //                     0.04),
                                                                        //
                                                                        //         textColor:
                                                                        //             Colors.white,
                                                                        //         child: Icon(
                                                                        //           Icons.camera_alt,
                                                                        //           size: 15,
                                                                        //         ),
                                                                        //
                                                                        //         shape:
                                                                        //             CircleBorder(),
                                                                        //         //elevation: 10,
                                                                        //       );
                                                                        //     }),
                                                                        GetBuilder<
                                                                                PersistentGetXController>(
                                                                            init:
                                                                                PersistentGetXController(),
                                                                            builder: (_img) {
                                                                              return FutureBuilder<
                                                                                      List<
                                                                                          SelifeImageData>>(
                                                                                  future: ChallengeApi().getSelfieImageData(
                                                                                      enroll_id: _val
                                                                                          .currentUserEnrolledChallenges[
                                                                                              index]
                                                                                          .enrollmentId),
                                                                                  builder:
                                                                                      (ctx, snap) {
                                                                                    if ((snap
                                                                                            .connectionState ==
                                                                                        ConnectionState
                                                                                            .waiting)) {
                                                                                      return Shimmer
                                                                                          .fromColors(
                                                                                        child: Icon(
                                                                                          Icons
                                                                                              .camera_alt,
                                                                                          size: 15,
                                                                                        ),
                                                                                        baseColor: Colors
                                                                                            .grey
                                                                                            .withOpacity(
                                                                                                0.04),
                                                                                        highlightColor: AppColors
                                                                                            .primaryColor
                                                                                            .withOpacity(
                                                                                                0.4),
                                                                                      );
                                                                                    }
                                                                                    if ((snap.data
                                                                                                .length <
                                                                                            10) &&
                                                                                        (_val.currentUserEnrolledChallenges[index].challenge_start_time.isBefore(DateTime
                                                                                                    .now()) &&
                                                                                                _val.currentUserEnrolledChallenges[index].userProgress !=
                                                                                                    null ||
                                                                                            DateFormat('MM-dd-yyyy').format(_val.currentUserEnrolledChallenges[index].challenge_start_time) ==
                                                                                                    "01-01-2000" &&
                                                                                                _val.currentUserEnrolledChallenges[index].userProgress !=
                                                                                                    null ||
                                                                                            _val.currentUserEnrolledChallenges[index].challenge_start_time.isBefore(DateTime.now()) &&
                                                                                                _val.currentUserEnrolledChallenges[index].selectedFitnessApp ==
                                                                                                    "other_apps")) {
                                                                                      return SizedBox(
                                                                                        width: 42,
                                                                                        child:
                                                                                            MaterialButton(
                                                                                          padding:
                                                                                              EdgeInsets
                                                                                                  .zero,
                                                                                          onPressed:
                                                                                              () {
                                                                                            _img.imageSelection(
                                                                                                isSelfi:
                                                                                                    true,
                                                                                                enrollChallenge:
                                                                                                    _val.currentUserEnrolledChallenges[index],
                                                                                                challengeDetail: _val.challengeList.where((element) => element.challengeId == _val.currentUserEnrolledChallenges[index].challengeId).first);
                                                                                          },
                                                                                          color: Theme.of(
                                                                                                  context)
                                                                                              .primaryColor,
                                                                                          shape:
                                                                                              CircleBorder(),
                                                                                          textColor:
                                                                                              Colors
                                                                                                  .white,
                                                                                          child:
                                                                                              Icon(
                                                                                            Icons
                                                                                                .camera_alt,
                                                                                            size:
                                                                                                15,
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                    return MaterialButton(
                                                                                      onPressed:
                                                                                          () {
                                                                                        null;
                                                                                      },
                                                                                      color: Colors
                                                                                          .grey
                                                                                          .withOpacity(
                                                                                              0.04),
                                                                                      shape:
                                                                                          CircleBorder(),
                                                                                      textColor:
                                                                                          Colors
                                                                                              .white,
                                                                                      child: Icon(
                                                                                        Icons
                                                                                            .camera_alt,
                                                                                        size: 15,
                                                                                      ),
                                                                                    );
                                                                                  });
                                                                            }),
                                                                        SizedBox(
                                                                          width: 15,
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    // _val.currentUserEnrolledChallenges[
                                                                    // index].userProgress==null?
                                                                    detailWidget(
                                                                        _val.currentUserEnrolledChallenges[
                                                                            index],
                                                                        _details),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          } catch (e) {
                                                            return Shimmer.fromColors(
                                                              child: Container(
                                                                height: 180,
                                                                alignment: Alignment.center,
                                                                width: MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                child: Text(
                                                                  'Loading....!',
                                                                  style: TextStyle(fontSize: 18.sp),
                                                                ),
                                                              ),
                                                              baseColor:
                                                                  Colors.grey.withOpacity(0.04),
                                                              highlightColor: AppColors.primaryColor
                                                                  .withOpacity(0.4),
                                                            );
                                                          }
                                                        }),
                                                  )
                                                : InkWell(
                                                    onTap: () async {
                                                      //navigate to certificate screen (google fit)
                                                      if (_
                                                              .completedChallenge[index -
                                                                  _val.currentUserEnrolledChallenges
                                                                      .length]
                                                              .challengeMode ==
                                                          'individual') {
                                                        if (_
                                                                .completedChallenge[index -
                                                                    _val.currentUserEnrolledChallenges
                                                                        .length]
                                                                .selectedFitnessApp !=
                                                            "other_apps") {
                                                          Get.to(CertificateDetail(
                                                            challengeDetail:
                                                                _.completedChallengeDetails[index -
                                                                    _val.currentUserEnrolledChallenges
                                                                        .length], //
                                                            enrolledChallenge: _.completedChallenge[
                                                                index -
                                                                    _val.currentUserEnrolledChallenges
                                                                        .length],
                                                            groupDetail: null,
                                                            currentUserIsAdmin: false,
                                                            firstCopmlete: false,
                                                          ));
                                                        } else {
                                                          Get.to(PersistentCertificateScreen(
                                                            //
                                                            enrolledChallenge: _.completedChallenge[
                                                                index -
                                                                    _val.currentUserEnrolledChallenges
                                                                        .length],

                                                            challengedetail:
                                                                _.completedChallengeDetails[index -
                                                                    _val.currentUserEnrolledChallenges
                                                                        .length],
                                                            navNormal: true,
                                                            firstComplete: false,
                                                          ));
                                                        }
                                                      } else {
                                                        bool currentUserIsAdmin = false;
                                                        GroupDetailModel groupDetailModel;
                                                        String userid = iHLUserId;
                                                        await ChallengeApi()
                                                            .listofGroupUsers(
                                                                groupId: _
                                                                    .completedChallenge[index -
                                                                        _val.currentUserEnrolledChallenges
                                                                            .length]
                                                                    .groupId)
                                                            .then((value) {
                                                          for (var i in value) {
                                                            if (i.userId == userid &&
                                                                i.role == "admin") {
                                                              currentUserIsAdmin = true;
                                                              break;
                                                            }
                                                          }
                                                        });
                                                        groupDetailModel = await ChallengeApi()
                                                            .challengeGroupDetail(
                                                                groupID: _
                                                                    .completedChallenge[index -
                                                                        _val.currentUserEnrolledChallenges
                                                                            .length]
                                                                    .groupId);
                                                        Get.to(CertificateDetail(
                                                          challengeDetail:
                                                              _.completedChallengeDetails[index -
                                                                  _val.currentUserEnrolledChallenges
                                                                      .length],
                                                          enrolledChallenge: _.completedChallenge[
                                                              index -
                                                                  _val.currentUserEnrolledChallenges
                                                                      .length],
                                                          groupDetail: groupDetailModel,
                                                          currentUserIsAdmin: currentUserIsAdmin,
                                                          firstCopmlete: false,
                                                        ));
                                                      }
                                                    },
                                                    child: GetBuilder(
                                                        init: ListChallengeController(),
                                                        builder: (_val) {
                                                          try {
                                                            return Container(
                                                              margin: EdgeInsets.only(
                                                                  left: index == 0 ? 0 : 10.sp,
                                                                  right: 10.sp,
                                                                  top: 5.sp,
                                                                  bottom: 5.sp),
                                                              //height: 100,
                                                              decoration: BoxDecoration(
                                                                // image: DecorationImage(
                                                                //   image: NetworkImage(_
                                                                //       .completedChallengeDetails[index -
                                                                //           _val.currentUserEnrolledChallenges
                                                                //               .length]
                                                                //       .bannerImgUrl),
                                                                //   fit: BoxFit.cover,
                                                                // ),
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(8),
                                                                    topRight: Radius.circular(50),
                                                                    bottomLeft: Radius.circular(8),
                                                                    bottomRight:
                                                                        Radius.circular(8)),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      blurRadius: 4,
                                                                      offset: Offset(1, 1),
                                                                      color: Colors.grey.shade400)
                                                                ],
                                                                color: Colors.white,
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.fromLTRB(
                                                                    8, 10, 0, 10),
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width: 2,
                                                                        ),
                                                                        SizedBox(
                                                                          height: 50,
                                                                          width: 55,
                                                                          child: CircleAvatar(
                                                                            backgroundImage: NetworkImage(_
                                                                                .completedChallengeDetails[
                                                                                    index -
                                                                                        _val.currentUserEnrolledChallenges
                                                                                            .length]
                                                                                .challengeImgUrlThumbnail),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width: 44.5.w,
                                                                          child: Text(
                                                                            _
                                                                                .completedChallengeDetails[
                                                                                    index -
                                                                                        _val.currentUserEnrolledChallenges
                                                                                            .length]
                                                                                .challengeName,
                                                                            softWrap: true,
                                                                            style: TextStyle(
                                                                                fontSize: 18,
                                                                                color: Colors
                                                                                    .blueGrey
                                                                                    .shade600,
                                                                                letterSpacing: 0.7,
                                                                                fontWeight:
                                                                                    FontWeight
                                                                                        .w600),
                                                                          ),
                                                                        ),
                                                                        // GetBuilder(
                                                                        //     init:
                                                                        //         PersistentGetXController(),
                                                                        //     builder: (_camVal) {
                                                                        //       return MaterialButton(
                                                                        //         onPressed: () {
                                                                        //           (_.completedChallenge[index - _val.currentUserEnrolledChallenges.length].challenge_start_time.isBefore(
                                                                        //                       DateTime
                                                                        //                           .now()) ||
                                                                        //                   DateFormat('MM-dd-yyyy').format(_.completedChallenge[index - _val.currentUserEnrolledChallenges.length].challenge_start_time) ==
                                                                        //                       "01-01-2000")
                                                                        //               ? _camVal
                                                                        //                   .imageSelection(
                                                                        //                   isSelfi:
                                                                        //                       true,
                                                                        //                   enrollChallenge: _
                                                                        //                           .completedChallenge[
                                                                        //                       index -
                                                                        //                           _val.currentUserEnrolledChallenges.length],
                                                                        //                   challengeDetail: _
                                                                        //                           .completedChallengeDetails[
                                                                        //                       index -
                                                                        //                           _val.currentUserEnrolledChallenges.length],
                                                                        //                 )
                                                                        //               : null;
                                                                        //         },
                                                                        //         color: (_
                                                                        //                     .completedChallengeDetails[index -
                                                                        //                         _val
                                                                        //                             .currentUserEnrolledChallenges.length]
                                                                        //                     .challengeStartTime
                                                                        //                     .isBefore(DateTime
                                                                        //                         .now()) ||
                                                                        //                 DateFormat('MM-dd-yyyy').format(_val
                                                                        //                         .currentUserEnrolledChallenges[
                                                                        //                             index]
                                                                        //                         .challenge_start_time) ==
                                                                        //                     "01-01-2000")
                                                                        //             ? Theme.of(
                                                                        //                     context)
                                                                        //                 .primaryColor
                                                                        //             : Colors.grey
                                                                        //                 .withOpacity(
                                                                        //                     0.04),
                                                                        //         highlightColor:
                                                                        //             Color(
                                                                        //                 0xFF89b9f0),
                                                                        //         textColor:
                                                                        //             Colors.white,
                                                                        //         child: Icon(
                                                                        //           Icons.camera_alt,
                                                                        //           size: 15,
                                                                        //         ),
                                                                        //
                                                                        //         shape:
                                                                        //             CircleBorder(),
                                                                        //         //elevation: 10,
                                                                        //       );
                                                                        //     }),
                                                                        GetBuilder<
                                                                                PersistentGetXController>(
                                                                            init:
                                                                                PersistentGetXController(),
                                                                            builder: (_img) {
                                                                              return FutureBuilder<
                                                                                      List<
                                                                                          SelifeImageData>>(
                                                                                  future: ChallengeApi().getSelfieImageData(
                                                                                      enroll_id: _val
                                                                                          .completedChallenge[index -
                                                                                              _val.currentUserEnrolledChallenges
                                                                                                  .length]
                                                                                          .enrollmentId),
                                                                                  builder:
                                                                                      (ctx, snap) {
                                                                                    if ((snap
                                                                                            .connectionState ==
                                                                                        ConnectionState
                                                                                            .waiting)) {
                                                                                      return MaterialButton(
                                                                                        onPressed:
                                                                                            () {
                                                                                          null;
                                                                                        },
                                                                                        color: Colors
                                                                                            .grey
                                                                                            .withOpacity(
                                                                                                0.04),
                                                                                        shape:
                                                                                            CircleBorder(),
                                                                                        textColor:
                                                                                            Colors
                                                                                                .white,
                                                                                        child: Icon(
                                                                                          Icons
                                                                                              .camera_alt,
                                                                                          size: 15,
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                    if ((snap.data
                                                                                                .length <
                                                                                            10) &&
                                                                                        ((_.completedChallenge[index - _val.currentUserEnrolledChallenges.length].challenge_start_time.isBefore(DateTime
                                                                                                .now()) ||
                                                                                            DateFormat('MM-dd-yyyy').format(_.completedChallenge[index - _val.currentUserEnrolledChallenges.length].challenge_start_time) ==
                                                                                                "01-01-2000"))) {
                                                                                      return MaterialButton(
                                                                                        onPressed:
                                                                                            () {
                                                                                          _img.imageSelection(
                                                                                            isSelfi:
                                                                                                true,
                                                                                            enrollChallenge:
                                                                                                _val.completedChallenge[index -
                                                                                                    _val.currentUserEnrolledChallenges.length],
                                                                                            challengeDetail:
                                                                                                _.completedChallengeDetails[index -
                                                                                                    _val.currentUserEnrolledChallenges.length],
                                                                                          );
                                                                                        },
                                                                                        color: Theme.of(
                                                                                                context)
                                                                                            .primaryColor,
                                                                                        shape:
                                                                                            CircleBorder(),
                                                                                        textColor:
                                                                                            Colors
                                                                                                .white,
                                                                                        child: Icon(
                                                                                          Icons
                                                                                              .camera_alt,
                                                                                          size: 15,
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                    return MaterialButton(
                                                                                      onPressed:
                                                                                          () {
                                                                                        null;
                                                                                      },
                                                                                      color: Colors
                                                                                          .grey
                                                                                          .withOpacity(
                                                                                              0.04),
                                                                                      shape:
                                                                                          CircleBorder(),
                                                                                      textColor:
                                                                                          Colors
                                                                                              .white,
                                                                                      child: Icon(
                                                                                        Icons
                                                                                            .camera_alt,
                                                                                        size: 15,
                                                                                      ),
                                                                                    );
                                                                                  });
                                                                            })
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 60),
                                                                    Center(
                                                                      child: Text("Run Completed",
                                                                          style: TextStyle(
                                                                              fontSize: 18,
                                                                              color: Colors.blueGrey
                                                                                  .shade600,
                                                                              letterSpacing: 0.7,
                                                                              fontWeight:
                                                                                  FontWeight.w600)),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          } catch (e) {
                                                            print(e);
                                                            return Shimmer.fromColors(
                                                              child: Container(
                                                                height: 180,
                                                                alignment: Alignment.center,
                                                                width: MediaQuery.of(context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                child: Text(
                                                                  'Loading....!',
                                                                  style: TextStyle(fontSize: 18.sp),
                                                                ),
                                                              ),
                                                              baseColor:
                                                                  Colors.grey.withOpacity(0.04),
                                                              highlightColor: AppColors.primaryColor
                                                                  .withOpacity(0.4),
                                                            );
                                                          }
                                                        }));
                                          } catch (e) {
                                            print(e);
                                            return Shimmer.fromColors(
                                              child: Container(
                                                height: 180,
                                                width: MediaQuery.of(context).size.width / 4,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Loading....!',
                                                  style: TextStyle(fontSize: 18.sp),
                                                ),
                                              ),
                                              baseColor: Colors.grey.withOpacity(0.04),
                                              highlightColor:
                                                  AppColors.primaryColor.withOpacity(0.4),
                                            );
                                          }
                                        });
                              },
                            ),
                          ),
                        );
                      }),
                  // Visibility(
                  //   visible: true,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(top: 10, bottom: 10),
                  //     child: InkWell(
                  //       onTap: () async {
                  //         if (userEnrolled) {
                  //           GroupDetailModel groupDetail;
                  //           if (currentUserEnrolledChallenges[0].groupId != null) {
                  //             groupDetail = await ChallengeApi().challengeGroupDetail(
                  //                 groupID: currentUserEnrolledChallenges[0].groupId);
                  //           }
                  //           challengeDetail.challengeMode == "Individual"
                  //               ? Get.to(OnGoingChallenge(
                  //                   challengeDetail: challengeDetail,
                  //                   navigatedNormal: true,
                  //                   filteredList: currentUserEnrolledChallenges[0]))
                  //               : Get.to(OnGoingChallenge(
                  //                   challengeDetail: challengeDetail,
                  //                   navigatedNormal: true,
                  //                   groupDetail: groupDetail,
                  //                   filteredList: currentUserEnrolledChallenges[0]));
                  //         } else {
                  //           ListChallenge _listChallenge = ListChallenge(
                  //               challenge_mode: '',
                  //               pagination_start: 0,
                  //               pagination_end: 1000,
                  //               affiliation_list: ["global", "Global"]);
                  //           List<Challenge> _listofChallenges =
                  //               await ChallengeApi().listOfChallenges(challenge: _listChallenge);
                  //           _listofChallenges
                  //               .removeWhere((element) => element.challengeStatus == "deactive");
                  //           List types = [];
                  //           for (int i = 0; i < _listofChallenges.length; i++) {
                  //             types.add(_listofChallenges[i].challengeType);
                  //             //Step Challenge
                  //             //Weight Loss Challenge
                  //           }
                  //           types = types.toSet().toList();
                  //           if (types.length == 1) {
                  //             Get.to(ListofChallenges(
                  //               list: ["global", "Global"],
                  //               challengeType: types[0],
                  //             ));
                  //           } else {
                  //             Get.to(HealthChallengeTypes(
                  //               list: ["global", "Global"],
                  //             ));
                  //           }
                  //         }
                  //       },
                  //       child: userEnrolled
                  //           ? Container(
                  //               width: MediaQuery.of(context).size.width - 40,
                  //               // height: 100,
                  //               decoration: BoxDecoration(
                  //                 borderRadius: BorderRadius.only(
                  //                     topLeft: Radius.circular(8),
                  //                     topRight: Radius.circular(50),
                  //                     bottomLeft: Radius.circular(8),
                  //                     bottomRight: Radius.circular(8)),
                  //                 boxShadow: [
                  //                   BoxShadow(
                  //                       blurRadius: 4,
                  //                       offset: Offset(1, 1),
                  //                       color: Colors.grey.shade400)
                  //                 ],
                  //                 color: Colors.white,
                  //               ),
                  //               child: Padding(
                  //                 padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
                  //                 child: Column(
                  //                   children: [
                  //                     Row(
                  //                       children: [
                  //                         SizedBox(
                  //                           width: 5,
                  //                         ),
                  //                         SizedBox(
                  //                           height: 60,
                  //                           width: 60,
                  //                           child: CircleAvatar(
                  //                             backgroundImage:
                  //                                 NetworkImage(challengeDetail.challengeImgUrl),
                  //                           ),
                  //                         ),
                  //                         Spacer(),
                  //                         SizedBox(
                  //                           width: MediaQuery.of(context).size.width / 1.6,
                  //                           child: Text(
                  //                             challengeDetail.challengeName,
                  //                             style: TextStyle(
                  //                                 fontSize: 18,
                  //                                 color: Colors.blueGrey.shade600,
                  //                                 letterSpacing: 0.7,
                  //                                 fontWeight: FontWeight.w600),
                  //                           ),
                  //                         )
                  //                       ],
                  //                     ),
                  //                     SizedBox(
                  //                       height: 27,
                  //                     ),
                  //                     Row(
                  //                       children: [
                  //                         SizedBox(
                  //                           width: MediaQuery.of(context).size.width / 2.6,
                  //                           child: Column(
                  //                             children: [
                  //                               Text("Completed",
                  //                                   style: TextStyle(
                  //                                       fontSize: 14,
                  //                                       color: Colors.grey,
                  //                                       letterSpacing: 0.7,
                  //                                       fontWeight: FontWeight.w600)),
                  //                               Text(
                  //                                   '${currentUserEnrolledChallenges[0].userAchieved > currentUserEnrolledChallenges[0].target ? currentUserEnrolledChallenges[0].target : currentUserEnrolledChallenges[0].userAchieved}',
                  //                                   style: TextStyle(
                  //                                       fontSize: 13,
                  //                                       color: Colors.lightBlue,
                  //                                       letterSpacing: 0.7,
                  //                                       fontWeight: FontWeight.w600))
                  //                             ],
                  //                           ),
                  //                         ),
                  //                         Spacer(),
                  //                         SizedBox(
                  //                           width: MediaQuery.of(context).size.width / 2.6,
                  //                           child: Column(
                  //                             children: [
                  //                               Text("Target",
                  //                                   style: TextStyle(
                  //                                       fontSize: 14,
                  //                                       color: Colors.grey,
                  //                                       letterSpacing: 0.7,
                  //                                       fontWeight: FontWeight.w600)),
                  //                               Text("${currentUserEnrolledChallenges[0].target}",
                  //                                   style: TextStyle(
                  //                                       fontSize: 13,
                  //                                       color: Colors.lightBlue,
                  //                                       letterSpacing: 0.7,
                  //                                       fontWeight: FontWeight.w600))
                  //                             ],
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                     SizedBox(
                  //                       height: 20,
                  //                     ),
                  //                     NeumorphicIndicator(
                  //                       height: 8,
                  //                       width: MediaQuery.of(context).size.width - 40,
                  //                       orientation: NeumorphicIndicatorOrientation.horizontal,
                  //                       percent: currentUserEnrolledChallenges[0].userAchieved /
                  //                           currentUserEnrolledChallenges[0].target,
                  //                       // percent: int.parse(
                  //                       //             currentUserEnrolledChallenges[
                  //                       //                         0]
                  //                       //                     .userAchieved
                  //                       //                 ) /
                  //                       //         int.parse(
                  //                       //             currentUserEnrolledChallenges[
                  //                       //                     0]
                  //                       //                 .target))
                  //                       //     .toString()),
                  //                     ),
                  //                     SizedBox(
                  //                       height: 20,
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             )
                  //           : Container(
                  //               width: MediaQuery.of(context).size.width - 40,
                  //               height: 100,
                  //               decoration: BoxDecoration(
                  //                 borderRadius: BorderRadius.only(
                  //                     topLeft: Radius.circular(8),
                  //                     topRight: Radius.circular(50),
                  //                     bottomLeft: Radius.circular(8),
                  //                     bottomRight: Radius.circular(8)),
                  //                 boxShadow: [
                  //                   BoxShadow(
                  //                       blurRadius: 4,
                  //                       offset: Offset(1, 1),
                  //                       color: Colors.grey.shade400)
                  //                 ],
                  //                 color: Colors.white,
                  //               ),
                  //               child: Row(
                  //                 children: [
                  //                   Padding(
                  //                     padding: const EdgeInsets.all(8.0),
                  //                     child: Container(
                  //                       height: MediaQuery.of(context).size.width / 5,
                  //                       width: MediaQuery.of(context).size.width / 5,
                  //                       decoration: BoxDecoration(
                  //                           borderRadius: BorderRadius.circular(10),
                  //                           image: DecorationImage(
                  //                               fit: BoxFit.fitWidth,
                  //                               image: AssetImage(
                  //                                 userEnrolled
                  //                                     ? 'assets/icons/challenges2.png'
                  //                                     : 'assets/icons/challenges1.png',
                  //                               ))),
                  //                     ),
                  //                   ),
                  //                   SizedBox(
                  //                     width: 30,
                  //                   ),
                  //                   SizedBox(
                  //                     width: MediaQuery.of(context).size.width / 1.9,
                  //                     child: Text(
                  //                         userEnrolled ? 'Enrolled Challenges' : 'New Challenges',
                  //                         style: TextStyle(
                  //                             fontSize: 16,
                  //                             fontWeight: FontWeight.w600,
                  //                             letterSpacing: 1,
                  //                             color: Colors.blueGrey.shade400)),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //
                  //       // child: Row(
                  //       //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //       //   children: [
                  //       //     Text(
                  //       //       'Health Challanges',
                  //       //       style: TextStyle(
                  //       //           fontSize: 22,
                  //       //           fontWeight: FontWeight.w500,
                  //       //           letterSpacing: 1,
                  //       //           color: Colors.blue.shade400),
                  //       //     ),
                  //       //     Image.network(
                  //       //       'https://cdn-icons-png.flaticon.com/512/3892/3892930.png',
                  //       //       height: 60,
                  //       //       width: 60,
                  //       //     ),
                  //       //   ],
                  //       // ),
                  //     ),
                  //   ),
                  // ),

                  Visibility(
                    ///because it was giving error r
                    visible: eventDetailList != null &&
                        userEnrolledMap != null &&
                        userEnrolledMap.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                      child: Eventss(
                          eventDetailList: eventDetailList, userEnrolledMap: userEnrolledMap),
                    ),
                  ),

                  Visibility(
                      visible: userAffiliate != null &&
                              (afNo1bool == _logedSso ||
                                  afNo2bool == _logedSso ||
                                  afNo3bool == _logedSso ||
                                  afNo4bool == _logedSso ||
                                  afNo5bool == _logedSso ||
                                  afNo6bool == _logedSso ||
                                  afNo7bool == _logedSso ||
                                  afNo8bool == _logedSso ||
                                  afNo9bool == _logedSso)
                          ? true
                          : false,
                      child: sectionTitle(context, "Member Services")),
                  Visibility(
                    visible: userAffiliate != null &&
                            (afNo1bool == _logedSso ||
                                afNo2bool == _logedSso ||
                                afNo3bool == _logedSso ||
                                afNo4bool == _logedSso ||
                                afNo5bool == _logedSso ||
                                afNo6bool == _logedSso ||
                                afNo7bool == _logedSso ||
                                afNo8bool == _logedSso ||
                                afNo9bool == _logedSso)
                        ? true
                        : false,
                    child: MemberServices(
                      afNo1:
                          afNo1 == "" ? "empty" : afNo1.replaceAll('IHL Care', 'India Health Link'),
                      afUnique1: afUnique1 == "" ? "empty" : afUnique1,
                      afNo1bool: _logedSso ? true : _logedSso == afNo1bool,
                      afNo2:
                          afNo2 == "" ? "empty" : afNo2.replaceAll('IHL Care', 'India Health Link'),
                      afUnique2: afUnique2 == "" ? "empty" : afUnique2,
                      afNo2bool: _logedSso ? true : _logedSso == afNo2bool,
                      afNo3:
                          afNo3 == "" ? "empty" : afNo3.replaceAll('IHL Care', 'India Health Link'),
                      afUnique3: afUnique3 == "" ? "empty" : afUnique3,
                      afNo3bool: _logedSso ? true : _logedSso == afNo3bool,
                      afNo4:
                          afNo4 == "" ? "empty" : afNo4.replaceAll('IHL Care', 'India Health Link'),
                      afUnique4: afUnique4 == "" ? "empty" : afUnique4,
                      afNo4bool: _logedSso ? true : _logedSso == afNo4bool,
                      afNo5:
                          afNo5 == "" ? "empty" : afNo5.replaceAll('IHL Care', 'India Health Link'),
                      afUnique5: afUnique5 == "" ? "empty" : afUnique5,
                      afNo5bool: _logedSso ? true : _logedSso == afNo5bool,
                      afNo6:
                          afNo6 == "" ? "empty" : afNo6.replaceAll('IHL Care', 'India Health Link'),
                      afUnique6: afUnique6 == "" ? "empty" : afUnique6,
                      afNo6bool: _logedSso ? true : _logedSso == afNo6bool,
                      afNo7:
                          afNo7 == "" ? "empty" : afNo7.replaceAll('IHL Care', 'India Health Link'),
                      afUnique7: afUnique7 == "" ? "empty" : afUnique7,
                      afNo7bool: _logedSso ?? _logedSso == afNo7bool,
                      afNo8:
                          afNo8 == "" ? "empty" : afNo8.replaceAll('IHL Care', 'India Health Link'),
                      afUnique8: afUnique8 == "" ? "empty" : afUnique8,
                      afNo8bool: _logedSso ? true : _logedSso == afNo8bool,
                      afNo9:
                          afNo9 == "" ? "empty" : afNo9.replaceAll('IHL Care', 'India Health Link'),
                      afUnique9: afUnique9 == "" ? "empty" : afUnique9,
                      afNo9bool: _logedSso ? true : _logedSso == afNo9bool,
                    ),
                  ),
                  sectionTitle(context, "Weight Control"),
                  SetGoal(
                    curvedBorder: true,
                    activeGoal: goalLists,
                    onTap: () {
                      final navi = GetStorage();
                      navi.write("setGoalNavigation", true);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewGoalSettingScreen(
                              goalChangeNavigation: false,
                            ),
                          ),
                          (Route<dynamic> route) => false);
                    },
                  ),
                  sectionTitle(context, "Step Tracker"),
                  StepWalkerCard(
                    todaysActivityData: todaysActivityData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAlert(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.all(0.0),
              content: Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
                decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [Colors.lightBlue.shade300, Colors.blue.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool("firstTime", false);
                        Get.back();
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Stack(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.width / 1.8,
                            width: MediaQuery.of(context).size.width / 1.8,
                            child: Image.asset(
                              "assets/images/badgePopup.png",
                              height: MediaQuery.of(context).size.width / 2.4,
                              width: MediaQuery.of(context).size.width / 2.4,
                            )),
                        Image.asset(
                          "assets/images/badgeParticle.png",
                          height: MediaQuery.of(context).size.width / 1.8,
                          width: MediaQuery.of(context).size.width / 1.8,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Do you want to have a healthy life style? IHL helps you to maintain healthy and energetic lifestyle by introducing new Health Challenges. Ready to tap into the Health Challenges?",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool("firstTime", false);
                        Get.back();
                        Get.to(HealthChallengeTypes(list: ["global", "Global"]));
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(250),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  var userProfileSnapshot = '';
  Widget loadUserInfo() {
    return userProfileSnapshot != null
        ? Container(
            child: userHeader(
              firstName: 'firstn',
              imagePath:
                  'https://images.pexels.com/photos/213780/pexels-photo-213780.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
              email: 'email@gmail.com',
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0, 0.0),
                end: Alignment(1.0, 0.0),
                colors: [
                  Theme.of(context).primaryColorLight,
                  Theme.of(context).primaryColorDark,
                ], // whitish to gray
              ),
            ),
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
  }

  Widget userHeader({
    String firstName,
    String email,
    String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        top: 10.0, //30.0,
        left: 20.0,
        right: 20.0,
        bottom: 25.0,
      ),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(
              right: 25.0,
            ),
            width: 70.0,
            height: 70.0,
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0, 0),
                ),
              ],
              shape: BoxShape.circle,
            ),
            child: InkWell(
              splashColor: AppColors.primaryAccentColor,
              onTap: () {
                Navigator.of(context).pushNamed(Routes.Profile, arguments: false);
              },
              child: ClipOval(
                child: photo != null
                    //     ? CachedNetworkImage(
                    //   imageUrl: imagePath,
                    //   imageBuilder: (context, imageProvider) => Container(
                    //     decoration: BoxDecoration(
                    //       image: DecorationImage(
                    //         image: imageProvider,
                    //         fit: BoxFit.cover,
                    //       ),
                    //     ),
                    //   ),
                    //   placeholder: (context, url) =>
                    //       CircularProgressIndicator(),
                    //   errorWidget: (context, url, error) =>
                    //       Image.asset('assets/images/user.jpg'),
                    // )
                    ? CircleAvatar(
                        backgroundColor: Color(0xfff4f6fa),
                        // radius: 75,
                        child: loading ? CircularProgressIndicator() : null,
                        backgroundImage: photo.image,
                      )
                    : (Container()),
              ),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: FractionalOffset.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome back, \n',
                          style: TextStyle(
                            // fontFamily: 'Poppins',
                            fontFamily: 'Poppins',
                            // fontFamily: 'Poppins-Regular',
                            fontSize: 22.25,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        TextSpan(
                          text: '${widget.username.split(' ').first}',
                          style: TextStyle(
                            // fontFamily: 'Poppins',
                            fontFamily: 'Poppins',
                            // fontFamily: 'Poppins-Regular',
                            fontWeight: FontWeight.w500,
                            fontSize: 22.25,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.userScore != null || widget.userScore != '',
                  child: Align(
                    alignment: FractionalOffset.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 5.0,
                      ),
                      child: Text(
                        // 'How can we help you today?',
                        'IHL Health Score - ${widget.userScore}',
                        style: TextStyle(
                          // fontFamily: 'Poppins',
                          fontFamily: 'Poppins',
                          // fontFamily: 'Poppins-Regular',
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                          // backgroundColor: Colors.white70,
                          // fontStyle: FontStyle.italic,
                          color: Color(0xFFFFFFFF),
                          // color: AppColors.appTextColor
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget doctorList() {
    var doctorSnapshot = '';
    return doctorSnapshot != null
        ? Container(
            child: ListView.builder(
                itemCount: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return doctorCard(
                    firstName: "first",
                    lastName: "last",
                    prefix: "prefix",
                    specialty: "specialty",
                    imagePath: "",
                    rank: 4,
                  );
                }),
          )
        : Container(
            margin: const EdgeInsets.only(
              top: 10.0,
              bottom: 20.0,
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  Widget specialtyList() {
    var specialtySnapshot = '';
    return specialtySnapshot != null
        ? Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
            ),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return specialtyCard(
                    specialtyName: "specialtyName",
                    specialtyDoctorCount: '4',
                    specialtyImagePath:
                        'https://images.pexels.com/photos/213780/pexels-photo-213780.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                  );
                }),
          )
        : Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  Widget specialtyCard(
      {String specialtyName, String specialtyDoctorCount, String specialtyImagePath}) {
    return Container(
        margin: const EdgeInsets.only(
          left: 20.0,
          bottom: 10.0,
        ),
        width: 135,
        child: Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          color: Colors.white,
          child: new InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => CategoryPage(specialtyName)),
              // );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 5.0,
                            bottom: 12.5,
                          ),
                          child: Image.network(
                            specialtyImagePath,
                            height: 60,
                            width: 60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      specialtyName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF6f6f6f),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 3.0,
                      ),
                      child: Text(
                        specialtyDoctorCount + ' Doctors',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF9f9f9f),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class Eventss extends StatelessWidget {
  const Eventss({
    Key key,
    @required this.eventDetailList,
    @required this.userEnrolledMap,
  }) : super(key: key);

  final List eventDetailList;
  final userEnrolledMap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // width: MediaQuery.of(context).size.width,
        // width: ScUtil().setWidth(width),
        // height: ScUtil().setHeight(195),
        child: eventDetailList != null && userEnrolledMap != null
            ? ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: eventDetailList.length,
                itemBuilder: (context, index) {
                  return MarathonCard(
                    eventDetailList: eventDetailList,
                    userEnrolledMap: userEnrolledMap[
                        index], //userEnrolledMap.length==0?[]:userEnrolledMap[index],
                    indexx: index,
                  );
                })
            : Column(
                children: [
                  Lottie.network("https://assets8.lottiefiles.com/packages/lf20_zjrmnlsu.json",
                      height: ScUtil().setHeight(155)),
                  Text("Loading...",
                      style: TextStyle(fontSize: ScUtil().setSp(10), fontWeight: FontWeight.w600))
                ],
              ),
      ),
    );
  }
}

var ssglobaltodaysActivityData;

class StepWalkerCard extends StatefulWidget {
  StepWalkerCard({Key key, this.todaysActivityData});
  var todaysActivityData;

  @override
  _StepWalkerCardState createState() => _StepWalkerCardState();
}

class _StepWalkerCardState extends State<StepWalkerCard> {
  @override
  void initState() {
    // getUserAndStepData();
    // getDailyActivityData();
    getData();
    super.initState();
  }

  getData() async {
    var ihlUserId = await _getIhlUserId();
    final response1 = await _getStepsData(ihlUserId: ihlUserId);
    if (response1.statusCode == 200) {
      List a = json.decode(response1.body);
      double ccal = 0.0;
      int stepsFromApi = 0;
      int ssec = 0;

      if (a.isNotEmpty &&
          DateFormat('dd-MM-yyyy HH:mm:ss')
              .parse(a[a.length - 1]['logged_date'])
              .isSameDate(DateTime.now())) {
        ccal = double.tryParse(a[a.length - 1]['calories_burned']) ?? 0.0;
        stepsFromApi = int.tryParse(a[a.length - 1]['steps_taken']) ?? 0;
        ssec = int.tryParse(a[a.length - 1]['duration']) ?? 0;
      }
      // await assignToRightHeir(stepsFromApi, ccal, ssec);
      // return ssec;
      if (mounted) {
        setState(() {
          sSteps = stepsFromApi;
          _calorieBurn = ccal.toString();
        });
      }
    } else {
      print('decode failed for get steps api');
    }
  }

  _getStepsData({ihlUserId}) async {
    try {
      http.Client _client = http.Client(); //3gb
      final response1 = await _client.get(
        Uri.parse(API.iHLUrl + '/consult/get_stepwalker_details?ihl_user_id=$ihlUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      );
      return response1;
    } catch (e) {
      return [];
    }
  }

  _getIhlUserId() async {
    var prefs = await SharedPreferences.getInstance();
    String raw = prefs.getString(SPKeys.stepCounter);
    if (raw == null || raw == '') {
      raw = '{}';
    }
    extracted = await json.decode(raw);

    ///for ihl user id =>
    var userData = prefs.get(SPKeys.userData);
    userData = userData == null || userData == '' ? '{"User":{}}' : userData;
    Map res = await jsonDecode(userData);
    var ihlUserId = res['User']['id'];
    print('User Id :' + ihlUserId);
    return ihlUserId;
  }

  @override
  Map extracted = {};

  Map allData = {};
  Map graphData = {};
  var sSteps = 0;
  var _calorieBurn = '0';
  ListApis listApis = ListApis();

  void getDailyActivityData() async {
    listApis.getUserTodaysFoodLogHistoryApi().then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            ssglobaltodaysActivityData = value['activity'];
          });
        }
        getInitialStepsValue(ssglobaltodaysActivityData);
      }
    });
  }

  getUserAndStepData() async {
    var prefs = await SharedPreferences.getInstance();
    String raw = prefs.getString(SPKeys.stepCounter);
    if (raw == null || raw == '') {
      raw = '{}';
    }
    extracted = await json.decode(raw);

    ///for ihl user id =>
    // var userData = prefs.get(SPKeys.userData);
    // userData = userData == null || userData == '' ? '{"User":{}}' : userData;
    // Map res = await jsonDecode(userData);
    // var ihlUserId = res['User']['id'];
    // print(ihlUserId);
    // await getData();
    // if (this.mounted) {
    //   setState(() {
    allData = extracted;
    // graphData = allData;
    if (allData.length != 0) {
      var mapKeyskeys = allData.keys;
      graphData[mapKeyskeys.last] = allData[mapKeyskeys.last];
      if (graphData[mapKeyskeys.last] != null) {
        if (this.mounted) {
          setState(() {
            sSteps = graphData[mapKeyskeys.last];
          });
        }
      }
    }
    //   });
    // }
    // return ihlUserId;
  }

  getCalorie(step) {
    // double addCal = step/28.571;//100 meter => 3.5 calk
    double addCal = step / 22.727; //100 meter => 4.4 cal
    // if (this.mounted) {
    //   setState(() {
    // _calorieBurn = addCal.toStringAsFixed(2);
    _calorieBurn = addCal.toInt().toString();
    //   });
    // }
    return _calorieBurn;
  }

  getInitialStepsValue(activities) async {
    ///here we calculate the steps from the calorie and assign to the initialStepsValue variable to show the
    ///we will get this calorie from the getTodaysFoodLogApi ,
    double ccal = 0.0;
    var stepsFromApi = 0;
    double i1;
    if (ccal != 0.0) {
      ccal = 0.0;
    }
    if (activities == null) activities = [];
    for (int i = 0; i < activities.length; i++) {
      // if(activities[i]['activityDetails'][0]['activityDetails'][0]['activityId']=='activity_103'){
      if (activities[i].activityDetails[0].activityDetails[0].activityId == 'activity_103') {
        try {
          i1 = double.tryParse(activities[i].totalCaloriesBurned) ?? 0.0;
        } catch (e) {
          i1 = 0.0;
        }
        ccal = ccal + i1;
      }
    }
    stepsFromApi = await calculateStepsFromBurnedCalorie(ccal);
    if (mounted) {
      setState(() {
        sSteps = stepsFromApi;
      });
    }
    // if(stepsFromApi==0){initialStepsValue=0;}
    // await assignToRightHeir(stepsFromApi, ccal);
    // initialStepsValue = 44;
    ///it will be assigned 0 if today user didn't log any Steps , this should be pretty clear...
  }

  calculateStepsFromBurnedCalorie(calorie) {
    if (calorie != 0 || calorie.toString() != 'null') {
      var sssttteeepppsss = 0;
      //write ythe logoc for the calorie to steps....
      sssttteeepppsss = (calorie * 22.727).toInt(); //100 meter => 4.4 cal
      // if (this.mounted) {
      //   setState(() {
      return sssttteeepppsss;
    } else {
      return 0;
    }
  }

  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        checkPermissionForStepWalkerCard();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Padding(
          padding: EdgeInsets.only(
              left: ScUtil().setWidth(24),
              right: ScUtil().setWidth(24),
              top: ScUtil().setHeight(16),
              bottom: ScUtil().setHeight(18)),
          child: Container(
            decoration: BoxDecoration(
              color: FitnessAppTheme.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                  topRight: Radius.circular(68.0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: FitnessAppTheme.grey.withOpacity(0.2),
                    offset: Offset(1.1, 1.1),
                    blurRadius: 10.0),
              ],
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  // padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  padding:
                      EdgeInsets.only(top: ScUtil().setHeight(16), left: ScUtil().setWidth(10)),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: ScUtil().setWidth(8),
                              right: ScUtil().setWidth(8),
                              top: ScUtil().setHeight(4)),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: ScUtil().setWidth(48),
                                    width: ScUtil().setHeight(2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(0.5),
                                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: ScUtil().setWidth(8),
                                        vertical: ScUtil().setHeight(8)),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: ScUtil().setHeight(4),
                                              bottom: ScUtil().setHeight(2)),
                                          child: Text(
                                            'Today\'s Steps',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w500,
                                              fontSize: ScUtil().setSp(16),
                                              letterSpacing: -0.1,
                                              color: FitnessAppTheme.grey.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            SizedBox(
                                              // width: 30,
                                              // height: 30,
                                              width: ScUtil().setWidth(30),
                                              height: ScUtil().setHeight(30),
                                              child: Image.asset("assets/images/diet/runner.png"),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: ScUtil().setWidth(2),
                                                  bottom: ScUtil().setHeight(3)),
                                              child: Text(
                                                '$sSteps',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: FitnessAppTheme.fontName,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: ScUtil().setSp(14),
                                                  color: FitnessAppTheme.darkerText,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: ScUtil().setWidth(4),
                                                  bottom: ScUtil().setHeight(3)),
                                              child: Text(
                                                'Steps',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: FitnessAppTheme.fontName,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: ScUtil().setSp(11),
                                                  letterSpacing: -0.2,
                                                  color: FitnessAppTheme.grey.withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: ScUtil().setWidth(30),
                                            ),
                                            SizedBox(
                                              // width: 30,
                                              // height: 30,
                                              width: ScUtil().setWidth(30),
                                              height: ScUtil().setHeight(30),
                                              child: Image.asset("assets/images/diet/burned.png"),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: ScUtil().setWidth(2),
                                                  bottom: ScUtil().setHeight(3)),
                                              child: AutoSizeText(
                                                '${getCalorie(sSteps)}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: FitnessAppTheme.fontName,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: ScUtil().setSp(14),
                                                  color: FitnessAppTheme.darkerText,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: ScUtil().setWidth(4),
                                                  bottom: ScUtil().setHeight(3)),
                                              child: Text(
                                                'Cal',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: FitnessAppTheme.fontName,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: ScUtil().setSp(11),
                                                  letterSpacing: -0.2,
                                                  color: FitnessAppTheme.grey.withOpacity(0.5),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: ScUtil().setHeight(8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  checkPermissionForStepWalkerCard() async {
    // await Permission.activityRecognition.request();
    var status = Platform.isAndroid
        ? await Permission.activityRecognition.status
        : await Permission.sensors.status;
    if (status.isGranted) {
      ///here
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StepsScreen(
            activities: ssglobaltodaysActivityData,
          ),
        ),
      );
    } else if (status.isDenied) {
      Platform.isAndroid
          ? await Permission.activityRecognition.request()
          : await Permission.sensors.request();
      status = Platform.isAndroid
          ? await Permission.activityRecognition.status
          : await Permission.sensors.status;
      if (status.isGranted) {
        ///here
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StepsScreen(activities: ssglobaltodaysActivityData),
          ),
        );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: new Text("Activity Access Denied"),
                  content: new Text("Allow Activity permission to continue"),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("Yes"),
                      onPressed: () async {
                        await openAppSettings();
                        Get.back();
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text("No"),
                      onPressed: () => Get.back(),
                    )
                  ],
                ));
        // Get.snackbar(
        //     'Activity Access Denied', 'Allow Activity permission to continue',
        //     backgroundColor: Colors.red,
        //     colorText: Colors.white,
        //     duration: Duration(seconds: 5),
        //     isDismissible: false,
        //     mainButton: TextButton(
        //       //TextButton(
        //       // style: TextButton
        //       //     .styleFrom(
        //       //   primary:
        //       //       Colors.white,
        //       // ),
        //         onPressed: () async {
        //           await openAppSettings();
        //         },
        //         child: Text('Allow')));
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: new Text("Activity Access Denied"),
                content: new Text("Allow Activity permission to continue"),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("Yes"),
                    onPressed: () async {
                      await openAppSettings();
                      Get.back();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text("No"),
                    onPressed: () => Get.back(),
                  )
                ],
              ));
      // Get.snackbar(
      //     'Activity Access Denied', 'Allow Activity permission to continue',
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //     duration: Duration(seconds: 5),
      //     isDismissible: false,
      //     mainButton: TextButton(
      //         onPressed: () async {
      //           await openAppSettings();
      //         },
      //         child: Text('Allow')));
    }
  }
}

extension StringExtension on String {
  String capitalized() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

Widget sectionTitle(context, String title) {
  return Container(
    margin: const EdgeInsets.only(
      top: 5.0,
      left: 20.0,
      right: 20.0,
      bottom: 7.0,
    ),
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              // fontWeight: FontWeight.w600,
              fontSize: 21,
              color: AppColors.primaryAccentColor,
              // fontFamily: 'Poppins',
              fontFamily: 'Poppins',
              // color: FitnessAppTheme.grey,
              // fontSize: ScUtil().setSp(14),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.05,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 10,
          ),
          child: Divider(
            color: Colors.black12,
            height: 1,
            thickness: 1,
          ),
        ),
      ],
    ),
  );
}

Widget doctorCard(
    {String firstName,
    String lastName,
    String prefix,
    String specialty,
    String imagePath,
    num rank,
    BuildContext context}) {
  return Container(
    margin: const EdgeInsets.only(
      left: 20.0,
      right: 20.0,
      top: 10.0,
    ),
    child: Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      color: Colors.white,
      child: new InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        onTap: () {
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => StepsScreen(),
          //   ),
          // );
        },
        child: Container(
          child: Align(
            alignment: FractionalOffset.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      right: 20.0,
                    ),
                    child: ClipOval(
                      child: imagePath != null
                          ? CachedNetworkImage(
                              imageUrl: imagePath,
                              imageBuilder: (context, imageProvider) => Container(
                                width: 70.0,
                                height: 72.5,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Image.asset('assets/images/user.jpg'),
                            )
                          : (Container()),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: FractionalOffset.centerLeft,
                          child: Text(
                            '${prefix.capitalized()} ${firstName.capitalized()} ${lastName.capitalized()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF6f6f6f),
                            ),
                          ),
                        ),
                        Align(
                          alignment: FractionalOffset.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 5.0,
                            ),
                            child: Text(
                              specialty,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9f9f9f),
                              ),
                            ),
                          ),
                        ),
                        // Align(
                        //   alignment: FractionalOffset.centerLeft,
                        //   child: Padding(
                        //     padding: EdgeInsets.only(
                        //       top: 5.0,
                        //     ),
                        //     child: StarRating(
                        //       rating: rank,
                        //       rowAlignment: MainAxisAlignment.start,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class GlobalAppBar extends StatelessWidget with PreferredSizeWidget {
  final openDrawer;

  const GlobalAppBar({Key key, this.openDrawer}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
        onPressed: () {
          openDrawer();
        },
      ),
      actions: <Widget>[
        // IconButton(
        //   icon: const Icon(Icons.search),
        //   onPressed: () {},
        // ),
        Visibility(
          visible: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Card(
              color: Colors.transparent,
              // color: Color(0xFFFEC5D2A),
              // color: Color(0xffd4a942),
              elevation: 2,
              // shadowColor: Colors.white10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Center(
                  child: Row(
                    children: [
                      CustomPaint(
                        size: Size(15,
                            (15).toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                        painter: RPSCustomPainter(),
                      ),
                      // Icon(
                      //   FontAwesomeIcons.award,
                      //   // FontAwesomeIcons.solidFlag,
                      //   size: 14,
                      //   color: FitnessAppTheme.white,
                      //   // color:Colors.black,
                      // ),
                      Text(
                        ' Trial ',
                        style: TextStyle(
                            color: Colors.white,
                            // color: Colors.black,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                      // SizedBox(
                      //   width: ScUtil().setWidth(5),
                      // ),
                      // Icon(
                      //   FontAwesomeIcons.shieldAlt,
                      //   size: ScUtil().setSp(14),
                      //   color: FitnessAppTheme.white,
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.0, 0.0),
            end: Alignment(1.0, 0.0),
            colors: [
              Theme.of(context).primaryColorLight,
              Theme.of(context).primaryColorDark,
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class NotVarified extends StatelessWidget {
  const NotVarified({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.bgColorTab,
        child: Column(
          children: [
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
                  Text(AppTexts.updateProfile, style: TextStyle(color: Colors.blue)),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      // backgroundColor: AppColors.primaryAccentColor,
                      textStyle: TextStyle(color: Colors.blue),
                    ),
                    child: Text(AppTexts.visitProfile),
                    onPressed: () {
                      // widget.goToProfile();
                      Navigator.of(context).pushNamed(Routes.Profile, arguments: false);
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
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0 = Paint()
      // ..color = const Color.fromARGB(255, 26, 134, 220)
      ..color = Color(0xffffac46)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    Path path0 = Path();
    path0.moveTo(size.width * -0.0607375, size.height * -0.0423200);
    path0.lineTo(size.width * 1.0418500, size.height * -0.0458200);
    path0.lineTo(size.width * 0.5955125, size.height * 0.4915000);
    path0.lineTo(size.width * 1.0374125, size.height * 1.0147200);
    path0.lineTo(size.width * -0.0629625, size.height * 1.0147200);
    path0.lineTo(size.width * -0.0607375, size.height * -0.0423200);
    path0.close();

    canvas.drawPath(path0, paint0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
