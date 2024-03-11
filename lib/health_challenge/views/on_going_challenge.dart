import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import '../../Getx/controller/google_fit_controller.dart';
import '../../Getx/controller/listOfChallengeContoller.dart';
import '../../new_design/presentation/controllers/healthchallenge/healthChallengeController.dart';
import '../../new_design/presentation/pages/healthChalleneg/challengeCompleted.dart';
import '../controllers/challenge_api.dart';
import '../models/challenge_detail.dart';
import '../models/enrolled_challenge.dart';
import '../models/group_details_model.dart';
import '../../new_design/presentation/bindings/initialControllerBindings.dart';
import '../../new_design/presentation/controllers/dashboardControllers/upComingDetailsController.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../utils/app_colors.dart';
import '../../views/splash_screen.dart';
import '../../widgets/BasicPageUI.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/api.dart';
import '../../constants/spKeys.dart';
import '../../main.dart';
import '../../new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import '../../views/marathon/preCertificate.dart';
import '../../widgets/offline_widget.dart';
import '../models/sendInviteUserForChallengeModel.dart';
import '../models/update_challenge_target_model.dart';
import '../persistent/PersistenGetxController/PersistentGetxController.dart';
import '../widgets/custom_imageScroller.dart';
import '../widgets/custom_show_start_button_popup.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'group_member_lists.dart';

class OnGoingChallenge extends StatefulWidget {
  OnGoingChallenge(
      {Key key,
      @required this.challengeDetail,
      @required this.navigatedNormal,
      @required this.filteredList,
      this.groupDetail})
      : super(key: key);
  ChallengeDetail challengeDetail;
  EnrolledChallenge filteredList;
  GroupDetailModel groupDetail;
  bool navigatedNormal;
  @override
  State<OnGoingChallenge> createState() => _OnGoingChallengeState();
}

class _OnGoingChallengeState extends State<OnGoingChallenge> with WidgetsBindingObserver {
  final PersistentGetXController controller = Get.put(PersistentGetXController());
  EnrolledChallenge filteredList;
  ValueNotifier<bool> _inviteButton = ValueNotifier<bool>(false);
  String iosVersion='';
  GroupDetailModel groupDetail;
  TextEditingController _sendInviteEmailController = TextEditingController();
  RegExp emailRegExp =
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  bool isLoading = true;
  bool fromAppLifeCycle = false;
  String _userId;
  final HealthRepository _stepController = Get.put(HealthRepository());
  bool fitImplemented = false;
  bool fitInstalled = false;
  int invitedEmailCount = 5;

  logSteps(
      {ihlUserId, distanceCovered, duration, caloriesBurned, steps, google_fit, logTime}) async {
    try {
      http.Client _client = http.Client(); //3gb

      final response1 = await _client.post(
        Uri.parse(API.iHLUrl + '/consult/log_stepwalker_details'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, dynamic>{
          "ihl_user_id": "$ihlUserId",
          "distance_covered": "$distanceCovered",
          "duration": "$duration",
          "calories_burned": "$caloriesBurned",
          "steps_travelled": "$steps",
          "log_time": "$logTime",
          "google_fit": false
        }),
      );
      if (response1.statusCode == 200) {
        // print('====${response1.body.toString()}');
        var finalOutPut = json.decode(response1.body);
        if (finalOutPut['status'] == 'success' &&
            finalOutPut['response'] == "logged successfully") {
          Get.snackbar('Logged!', '${steps} logged successfully.',
              icon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.check_circle, color: Colors.white)),
              margin: const EdgeInsets.all(20).copyWith(bottom: 40),
              backgroundColor: HexColor('#6F72CA'),
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM);
        }
        return true;
      } else {
        print('====${response1.body.toString()}');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  calcuGrp() {
    return widget.filteredList.groupAchieved;
  }

  calculate() {
    return widget.filteredList.userAchieved;
  }

  var b6 = "";
  var imgB6 = "";
  Future updateStep() async {
    _stepController.update();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);
    String email = res['User']['email'];
    var _prev = widget.filteredList.userAchieved / widget.filteredList.target * 100;
    var _currentTotal = (widget.challengeDetail.challengeUnit == 'steps' ||
            widget.challengeDetail.challengeUnit == 's')
        ? ((widget.filteredList.userAchieved + _stepController.steps) /
                widget.filteredList.target) *
            100
        : widget.challengeDetail.challengeUnit == 'm'
            ? (((widget.filteredList.userAchieved) + (_stepController.distance)) /
                    widget.filteredList.target) *
                100
            : (((widget.filteredList.userAchieved) + (_stepController.distance / 1000)) /
                    widget.filteredList.target) *
                100;
    log('Line ongoing 159');
    var _total;
    print(imgPreCertifiacte(
        Get.context,
        widget.filteredList.name,
        "widget.event_status",
        " widget.event_varient",
        "widget.time_taken",
        "widget.emp_id",
        widget.challengeDetail,
        widget.filteredList,
        widget.filteredList.groupId != null ? groupDetail.groupName : " ",
        widget.filteredList.userduration < 1
            ? 1
            : (widget.filteredList.userduration ~/ 1440).toString()));
    if (widget.filteredList.challengeMode == 'group') {
      _total = (widget.challengeDetail.challengeUnit == 'steps' ||
              widget.challengeDetail.challengeUnit == 's')
          ? widget.filteredList.groupAchieved + _stepController.steps
          : widget.challengeDetail.challengeUnit == 'm'
              ? widget.filteredList.groupAchieved + _stepController.distance
              : widget.filteredList.groupAchieved + _stepController.distance / 1000;
    } else {
      _total = (widget.challengeDetail.challengeUnit == 'steps' ||
              widget.challengeDetail.challengeUnit == 's')
          ? widget.filteredList.userAchieved + _stepController.steps
          : widget.challengeDetail.challengeUnit == 'm'
              ? widget.filteredList.userAchieved + _stepController.distance
              : widget.filteredList.userAchieved + _stepController.distance / 1000;
      if (_prev <= 25 &&
          _currentTotal.toInt() >= 25 &&
          _currentTotal.toInt() < widget.filteredList.target) {
        await flutterLocalNotificationsPlugin.show(
          1,
          'Water Reminder',
          'Hey,Drink Water now! Since You have Completed 25 percentage of your ${widget.challengeDetail.challengeName} Challenge',
          waterReminder,
          payload: jsonEncode({'text': 'Water Reminder'}),
        );
      }
      if (_prev <= 75 &&
          _currentTotal.toInt() >= 75 &&
          _currentTotal.toInt() < widget.filteredList.target) {
        await flutterLocalNotificationsPlugin.show(
          1,
          'Water Reminder',
          'Hey,Drink Water now! Since You have Completed 75 percentage of your ${widget.challengeDetail.challengeName} Challenge',
          waterReminder,
          payload: jsonEncode({'text': 'Water Reminder'}),
        );
      }
    }
    if (_total >= widget.filteredList.target ||
        widget.challengeDetail.challengeEndTime.isBefore(DateTime.now()) &&
            (DateFormat('MM-dd-yyyy').format(widget.challengeDetail.challengeEndTime).toString() !=
                "01-01-2000")) {
      Get.put(UpcomingDetailsController()).updateUpcomingDetails(fromChallenge: false);
      b6 = await preCertifiacte(
          Get.context,
          widget.filteredList.name,
          "widget.event_status",
          " widget.event_varient",
          "widget.time_taken",
          "widget.emp_id",
          widget.challengeDetail,
          widget.filteredList,
          widget.filteredList.groupId != null ? groupDetail.groupName : " ",
          widget.filteredList.userduration == 0
              ? 1
              : (widget.filteredList.userduration ~/ 1440).toString());
      imgB6 = await imgPreCertifiacte(
          context,
          widget.filteredList.name,
          "widget.event_status",
          " widget.event_varient",
          "widget.time_taken",
          "widget.emp_id",
          widget.challengeDetail,
          widget.filteredList,
          widget.filteredList.groupId != null ? groupDetail.groupName : " ",
          widget.filteredList.userduration == 0
              ? 1
              : (widget.filteredList.userduration ~/ 1440).toString());
    }
    try {
      print('On Going Line 234');
      var _enroll = await ChallengeApi().getEnrollDetail(widget.filteredList.enrollmentId);
      if (_enroll.userProgress != "completed") {
        await ChallengeApi().updateChallengeTarget(
          updateChallengeTarget: UpdateChallengeTarget(
              firstTime: false,
              challengeEndTime: widget.challengeDetail.challengeEndTime,
              achieved: ((widget.challengeDetail.challengeUnit == 'steps' ||
                          widget.challengeDetail.challengeUnit == 's')
                      ? _stepController.steps.toInt()
                      : widget.challengeDetail.challengeUnit == 'm'
                          ? _stepController.distance
                          : _stepController.distance / 1000)
                  .toString(),
              enrollmentId: widget.filteredList.enrollmentId,
              duration: _stepController.duration.toString(),
              certificateBase64: b6,
              email: email,
              certificatePngBase64: imgB6,
              progressStatus: (_total >= widget.filteredList.target ||
                      widget.challengeDetail.challengeEndTime.isBefore(DateTime.now()) &&
                          (DateFormat('MM-dd-yyyy')
                                  .format(widget.challengeDetail.challengeEndTime)
                                  .toString() !=
                              "01-01-2000"))
                  ? 'completed'
                  : 'progressing'),
        );
      }
    } catch (e) {
      print(e);
    }
    if (_total >= widget.filteredList.target ||
        widget.challengeDetail.challengeEndTime.isBefore(DateTime.now()) &&
            (DateFormat('MM-dd-yyyy').format(widget.challengeDetail.challengeEndTime).toString() !=
                "01-01-2000")) {
      Get.put(ListChallengeController()).enrolledChallenge();

      Get.defaultDialog(
          barrierDismissible: false,
          onWillPop: () => Future.value(false),
          backgroundColor: Colors.lightBlue.shade50,
          title: 'Kudos!',
          titlePadding: const EdgeInsets.only(top: 20, bottom: 5, right: 10, left: 10),
          titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
          contentPadding: const EdgeInsets.only(top: 0),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                  var _enrolledChallenge =
                      await ChallengeApi().getEnrollDetail(widget.filteredList.enrollmentId);
                  var _challengeDetail = await ChallengeApi()
                      .challengeDetail(challengeId: widget.filteredList.challengeId);
                  Get.back();
                  GroupDetailModel _groupModel;
                  _enrolledChallenge.userAchieved = _enrolledChallenge.target.toDouble();
                  if (_enrolledChallenge.groupId != null || _enrolledChallenge.groupId == '') {
                    _groupModel = await ChallengeApi()
                        .challengeGroupDetail(groupID: _enrolledChallenge.groupId);
                  }
                  WidgetsBinding.instance.removeObserver(this);
                  Get.to(ChallengeCompleted(
                    challengeDetail: _challengeDetail,
                    enrolledChallenge: _enrolledChallenge,
                    firstCopmlete: true,
                    currentUserIsAdmin: currentUserIsAdmin ?? false,
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
      AudioPlayer().play(AssetSource('audio/challenge_completed.mp3'));
    } else {
      null;
    }
    // await logSteps(
    //     // steps: _stepCountValue.toString(),
    //     // steps: _currentStep,
    //     steps: _stepController.steps,
    //     caloriesBurned: _stepController.cal.toStringAsFixed(2),
    //     distanceCovered: _stepController.distance,
    //     duration: _stepController.duration,
    //     logTime: genericDateTime(DateTime.now()).toString(),
    //     ihlUserId: '$_userId',
    //     google_fit: true);
  }

  genericDateTime(DateTime dateTime) {
    String str = dateTime.toString();
    var str1 = str.substring(0, str.indexOf(' '));
    var str2 = str.substring(str1.length + 1, str1.length + 6);
    // return DateTime.parse('$str1 00:00:00');
    var ss = str1 + " " + str2;

    // return DateTime.parse('$str1 $str2'+':00');
    return '$str1 $str2' + ':00';
  }
  void getIosVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    iosVersion = iosInfo.systemVersion;
    print('iOS Version: $iosVersion');
  }
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // startButtonEnable();
    Get.put(HealthRepository());
    fun();
    gs.write('CurrentPage', false);
    Get.delete<HealthChallengeController>();
    getIosVersion();
    //  getEnrolledChallenge();
    //       checkReferInviteCount(widget.challengeDetail.challengeId);
    super.initState();
  }

  fun() async {
    widget.filteredList = await ChallengeApi().getEnrollDetail(widget.filteredList.enrollmentId);
    Future.delayed(const Duration(microseconds: 1), () {
      if (widget.filteredList.userProgress == null) {
        this.startButtonEnable();
      } else if (widget.filteredList.userProgress == 'progressing') {
        getEnrolledChallenge(false);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fromAppLifeCycle = true;
      getEnrolledChallenge(false);
    }
    super.didChangeAppLifecycleState(state);
  }

  startButtonEnable() {
    customPopup().startButton(
        context: context,
        nrmlnavi: widget.navigatedNormal,
        onTap: DateTime.now().isAfter(widget.challengeDetail.challengeStartTime)
            ? () {
                Get.back();
                getEnrolledChallenge(true);
                showingDia();
              }
            : () {
                //Check already show snackbar or not, if not showing snackbar display snackbar
                if (!Get.isSnackbarOpen) {
                  Get.snackbar('Note',
                      "The 'Start' button activates on ${Jiffy(widget.challengeDetail.challengeStartTime).format("do MMM yyyy")} at ${DateFormat("hh:mm a").format(widget.challengeDetail.challengeStartTime)}",
                      margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                      backgroundColor: AppColors.primaryAccentColor,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      icon: const Icon(Icons.info_outlined),
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
        color: DateTime.now().isAfter(widget.challengeDetail.challengeStartTime));
  }

  firstIn() {
    if ((widget.filteredList.userAchieved == 0 || widget.filteredList.userAchieved == null) &&
        _stepController.steps == 0 &&
        (DateTime.now().isAfter(widget.challengeDetail.challengeStartTime))) {
      if (!fromAppLifeCycle && Get.currentRoute == "/OnGoingChallenge") {
        showingDia();
      }
    }
  }
  // indiduvalChallenges(){

  // }
  String userName = '';

  bool currentUserIsAdmin = false;
  getEnrolledChallenge(bool firsttime) async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    String userid = prefs1.getString("ihlUserId");
    _userId = userid;
    isLoading = true;
    widget.filteredList = await ChallengeApi().getEnrollDetail(widget.filteredList.enrollmentId);
    if (widget.challengeDetail.challengeMode == "group") {
      getGroupDetails(widget.filteredList.groupId);

      //isLoading = false;
      await ChallengeApi().listofGroupUsers(groupId: widget.filteredList.groupId).then((value) {
        for (var i in value) {
          if (i.userId == userid && i.role == "admin") {
            currentUserIsAdmin = true;
            break;
          }
        }
      });
    }

    if (firsttime) {
      final box = GetStorage();
      fitImplemented = box.read("fit") ?? false;
      if (Platform.isAndroid) {
        fitInstalled =
            await LaunchApp.isAppInstalled(androidPackageName: "com.google.android.apps.fitness");
        if (fitInstalled) {
          if (!fitImplemented) {
            dialogBox();
          }
        }
      } else if (Platform.isIOS) {
        if (int.parse(iosVersion) < 17.0) {
          Get.defaultDialog(
              title: 'Permission Needed',
              content: Container(
                  height: 70.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        20.sp,
                      ),
                      color: Colors.white),
                  child: SizedBox(
                    height: 80.h,
                    width: 80.w,
                    child: PageView(
                      scrollDirection: Axis.vertical,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Ensure you've granted \n all necessary app permissions.",
                              style: TextStyle(fontSize: 20.sp),
                              textAlign: TextAlign.center,
                            ),
                            Image.asset(
                              'assets/images/SH1.jpg',
                              height: 50.h,
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/images/SH2.jpg',
                          height: 50.h,
                        ),
                        Image.asset(
                          'assets/images/SH3.jpg',
                          height: 50.h,
                        ),
                        Image.asset(
                          'assets/images/SH4.jpg',
                          height: 50.h,
                        ),
                      ],
                    ),
                  )));
          fitInstalled = true;
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          _prefs.setBool('fit', true);
          box.write("fit", true);
        }
        else {
          Get.defaultDialog(
              title: 'Permission Needed',
              content: Container(
                  height: 70.h,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        20.sp,
                      ),
                      color: Colors.white),
                  child: SizedBox(
                    height: 80.h,
                    width: 80.w,
                    child: PageView(
                      scrollDirection: Axis.vertical,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Ensure you've granted \n all necessary app permissions.",
                              style: TextStyle(fontSize: 20.sp),
                              textAlign: TextAlign.center,
                            ),
                            Image.asset(
                              'assets/images/17.0.ONE.png',
                              height: 50.h,
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/images/17.0.TWO.png',
                          height: 50.h,
                        ),
                        Image.asset(
                          'assets/images/17.0.THREE.png',
                          height: 50.h,
                        ),
                      ],
                    ),
                  )));
          fitInstalled = true;
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          _prefs.setBool('fit', true);
          box.write("fit", true);
          // }
        }
      }
      print('On Going Line 465');

      await ChallengeApi().updateChallengeTarget(
        updateChallengeTarget: UpdateChallengeTarget(
          firstTime: true,
          enrollmentId: widget.filteredList.enrollmentId,
        ),
      );
      _stepController.update();
      Get.find<UpcomingDetailsController>().updateUpcomingDetails(fromChallenge: false);
      widget.filteredList.userProgress = 'progressing';
      if (mounted) setState(() {});
      _stepController.isLoading = false;
    } else {
      if (Platform.isAndroid) {
        final box = GetStorage();
        fitImplemented = box.read("fit") ?? false;
        fitInstalled =
            await LaunchApp.isAppInstalled(androidPackageName: "com.google.android.apps.fitness");
        if (fitImplemented && fitInstalled) {
          if (DateTime.now().isAfter(widget.challengeDetail.challengeStartTime)) {
            await _stepController.fetchHealthDataFromLastUpdateTime(
                // milliseconds: DateTime(2022, 11, 09, 15).millisecondsSinceEpoch ??
                milliseconds: int.parse(
                    widget.filteredList.last_updated ?? DateTime.now().millisecondsSinceEpoch),
                requested: fitImplemented);
            log('Ongoing Screen Line 495');
            updateStep();
          } else {
            Get.defaultDialog(
                barrierDismissible: false,
                backgroundColor: Colors.lightBlue.shade50,
                title: Get.find<ListChallengeController>()
                            .affiliateCmpnyList
                            .contains("persistent") &&
                        widget.challengeDetail.affiliations.contains("persistent") &&
                        widget.challengeDetail.challengeMode == "individual"
                    ? 'Run will be active from ${Jiffy(widget.challengeDetail.challengeStartTime).format("do MMM yyyy")} at ${DateFormat("hh:mm a").format(widget.challengeDetail.challengeStartTime)}'
                    : 'Run will be active from ${Jiffy(widget.challengeDetail.challengeStartTime).format("do MMM yyyy")} at ${DateFormat("hh:mm a").format(widget.challengeDetail.challengeStartTime)}',
                titlePadding: const EdgeInsets.only(top: 20, bottom: 0, right: 10, left: 10),
                titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                contentPadding: const EdgeInsets.only(top: 0),
                content: Column(
                  children: <Widget>[
                    const Divider(
                      thickness: 2,
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
                      onTap: () {
                        WidgetsBinding.instance.removeObserver(this);
                        Get.off(LandingPage(), binding: InitialBindings());
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 4,
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
          firstIn();
        } else {
          dialogBox();
        }
      } else if (Platform.isIOS) {
        if (widget.filteredList.userAchieved == 0) {
          int _index = 0;
          if (int.parse(iosVersion) < 17.0) {
            Get.defaultDialog(
                title: 'Enable Permissions',
                content: Container(
                    height: 70.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          20.sp,
                        ),
                        color: Colors.white),
                    child: SizedBox(
                      height: 80.h,
                      width: 80.w,
                      child: PageView(
                        scrollDirection: Axis.vertical,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                'Please Enable the \nRequired Permissions',
                                style: TextStyle(fontSize: 20.sp),
                                textAlign: TextAlign.center,
                              ),
                              Image.asset(
                                'assets/images/SH1.jpg',
                                height: 50.h,
                              ),
                            ],
                          ),
                          Image.asset(
                            'assets/images/SH2.jpg',
                            height: 50.h,
                          ),
                          Image.asset(
                            'assets/images/SH3.jpg',
                            height: 50.h,
                          ),
                          Image.asset(
                            'assets/images/SH4.jpg',
                            height: 50.h,
                          ),
                        ],
                      ),
                    )));
          } else {
            Get.defaultDialog(
                title: 'Enable Permissions',
                content: Container(
                    height: 70.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          20.sp,
                        ),
                        color: Colors.white),
                    child: SizedBox(
                      height: 80.h,
                      width: 80.w,
                      child: PageView(
                        scrollDirection: Axis.vertical,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Ensure you've granted \n all necessary app permissions.",
                                style: TextStyle(fontSize: 20.sp),
                                textAlign: TextAlign.center,
                              ),
                              Image.asset(
                                'assets/images/17.0.ONE.png',
                                height: 50.h,
                              ),
                            ],
                          ),
                          Image.asset(
                            'assets/images/17.0.TWO.png',
                            height: 50.h,
                          ),
                          Image.asset(
                            'assets/images/17.0.THREE.png',
                            height: 50.h,
                          ),
                        ],
                      ),
                    )));
          }
        }
        await _stepController.fetchHealthDataFromLastUpdateTime(
            // milliseconds: DateTime(2022, 11, 28).millisecondsSinceEpoch ,
            milliseconds: int.parse(
                widget.filteredList.last_updated ?? DateTime.now().millisecondsSinceEpoch),
            requested: true);
        log('On Going Screen 599');
        updateStep();
      }
    }
    await checkReferInviteCount(widget.challengeDetail.challengeId);
    Get.put(UpcomingDetailsController()).updateUpcomingDetails(fromChallenge: false);
    //print(widget.filteredList.userAchieved);
  }

  getGroupDetails(String groupID) async {
    // groupDetails = await ChallengeApi()
    //     .listOfGroups(challengeId: widget.challengeDetail.challengeId);
    if (groupID != null) groupDetail = await ChallengeApi().challengeGroupDetail(groupID: groupID);
  }

  notEnrolled(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          width: 95.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)
            ],
          ),
          child: Center(
            child: Text("Enroll to this challenge",
                style: TextStyle(
                    fontSize: 20.sp, fontWeight: FontWeight.w500, color: Colors.blueGrey)),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Get.find<ListChallengeController>();
    final controller = Get.put(PersistentGetXController());
    debugPrint('Build Method');
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (widget.navigatedNormal) {
          gs.write('CurrentPage', true);
          WidgetsBinding.instance.removeObserver(this);

          Navigator.of(context).pop(true);
        } else {
          WidgetsBinding.instance.removeObserver(this);

          Get.off(LandingPage(), binding: InitialBindings());
          // Get.off(HomeScreen(introDone: true), transition: Transition.size);
        }
      },
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: BasicPageUI(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: Colors.white,
                onPressed: () {
                  if (widget.navigatedNormal) {
                    debugPrint('Nrml');
                    WidgetsBinding.instance.removeObserver(this);

                    Navigator.pop(context);
                  } else {
                    debugPrint('Call binding');
                    Get.put(TabBarController());
                    WidgetsBinding.instance.removeObserver(this);

                    Get.off(LandingPage(), binding: InitialBindings());
                    // Get.off(HomeScreen(introDone: true),
                    //     transition: Transition.size);
                  }
                }),
            title: Text(
              widget.challengeDetail.challengeName,
              style: TextStyle(fontSize: 18.5.sp, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: 95.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)
                      ],
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            // Align(
                            //   alignment: Alignment.centerRight,
                            //   child: MaterialButton(
                            //     padding: EdgeInsets.only(right: 0),
                            //     color: Colors.lightBlue,
                            //     shape: CircleBorder(),
                            //     onPressed:
                            //         DateTime.now().isAfter(widget.challengeDetail.challengeStartTime)
                            //             ? () {
                            //                 controller.imageSelection(
                            //                     isSelfi: true, enrollChallenge: widget.filteredList);
                            //               }
                            //             : null,
                            //     child: Icon(
                            //       Icons.photo_camera,
                            //       color: Colors.white,
                            //     ),
                            //   ),
                            // ),
                            CircleAvatar(
                              radius: 35.sp, // Image radius
                              backgroundImage: NetworkImage(widget.challengeDetail.challengeImgUrl),
                            ),
                            Container(
                              padding: EdgeInsets.all(14.sp),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(16.sp)),
                              child: RichText(
                                text: TextSpan(
                                  // Note: Styles for TextSpans must be explicitly defined.
                                  // Child text spans will inherit styles from parent
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'BIB ',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: AppColors.appItemTitleTextColor,
                                          fontSize: 17.sp,
                                        )),
                                    widget.filteredList.user_bib_no != null
                                        ? TextSpan(
                                            text: '- ${widget.filteredList.user_bib_no ?? ''}',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.normal,
                                              color: AppColors.primaryColor,
                                              fontSize: 17.sp,
                                            ))
                                        : TextSpan(
                                            text: '- 1234',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.normal,
                                              color: AppColors.primaryColor,
                                              fontSize: 17.sp,
                                            )),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                              ),
                              child: Text(
                                widget.challengeDetail.challengeName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                    color: Colors.blueGrey),
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
                GetBuilder<PersistentGetXController>(
                    id: 'photoUpload',
                    init: PersistentGetXController(),
                    builder: (context) {
                      return CustomImageScroller(
                        enrolledChallenge: widget.filteredList,
                        challengeDetail: widget.challengeDetail,
                      );
                    }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 95.w,
                    // height: Get.find<ListChallengeController>()
                    //         .affiliateCmpnyList
                    //         .contains(widget.challengeDetail.affiliations)
                    //     ? height > 568
                    //         ? 105.h
                    //         : 120.h
                    //     : height > 568
                    //         ? 85.h
                    //         : 70.h,
                    constraints: const BoxConstraints(
                      maxHeight: double.infinity,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 7.h,
                            width: 95.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              boxShadow: <BoxShadow>[
                                BoxShadow(color: Colors.grey, offset: Offset(3, 3), blurRadius: 6)
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                widget.challengeDetail.challengeMode == "individual"
                                    ? SizedBox(
                                        width: 1.w,
                                      )
                                    : SizedBox(
                                        width: 1.w,
                                      ),
                                widget.challengeDetail.challengeMode == "individual"
                                    ? Text("My Run",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white))
                                    : Text(widget.groupDetail.groupName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white)),
                                Visibility(
                                  visible: widget.challengeDetail.challengeMode != "individual" &&
                                      currentUserIsAdmin,
                                  child: IconButton(
                                    onPressed: () {
                                      WidgetsBinding.instance.removeObserver(this);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => GroupMemberList(
                                                  challengeDetail: widget.challengeDetail,
                                                  filteredData: widget.filteredList,
                                                )),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.play_arrow,
                                    ),
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                          GetBuilder<HealthRepository>(
                            id: _stepController.widgetUpdate,
                            init: HealthRepository(),
                            initState: (_) {},
                            builder: (_) {
                              return FutureBuilder(
                                  future: ChallengeApi()
                                      .getEnrollDetail(widget.filteredList.enrollmentId),
                                  builder: (context, SnapShot) {
                                    if (SnapShot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                          height: 45.h,
                                          width: 90.w,
                                          alignment: Alignment.center,
                                          child: SizedBox(
                                            width: 90.w,
                                            height: 80.h,
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey.withOpacity(0.04),
                                              highlightColor:
                                                  AppColors.primaryColor.withOpacity(0.4),
                                              child: const Text(
                                                'Loading.....!',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 40.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ));
                                    } else if (SnapShot.connectionState == ConnectionState.done) {
                                      widget.filteredList = SnapShot.data;

                                      return Column(
                                        children: <Widget>[
                                          Container(
                                            height: 20.h,
                                            width: 95.w,
                                            decoration: const BoxDecoration(
                                              color: AppColors.appBackgroundColor,
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(1, 1),
                                                    blurRadius: 6)
                                              ],
                                            ),
                                            child: widget.filteredList.userProgress == null
                                                ? Center(
                                                    child: Text(
                                                      'Run yet to start',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 18.sp,
                                                          fontWeight: FontWeight.w600,
                                                          letterSpacing: 1,
                                                          color: Colors.blueGrey),
                                                    ),
                                                  )
                                                : Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceEvenly,
                                                        // crossAxisAlignment:
                                                        //     CrossAxisAlignment.end,
                                                        children: <Widget>[
                                                          SizedBox(
                                                            width: width / 3.4,
                                                            child: Column(
                                                              children: <Widget>[
                                                                Column(
                                                                  children: <Widget>[
                                                                    const Text("Achieved",
                                                                        // widget.challengeDetail
                                                                        //             .challengeMode ==
                                                                        //         "individual"
                                                                        //     ? "Achieved"
                                                                        //     : "Contribution",
                                                                        style: FitnessAppTheme
                                                                            .challengeKeyText),
                                                                    Text(
                                                                        (widget.challengeDetail
                                                                                        .challengeUnit ==
                                                                                    'steps' ||
                                                                                widget.challengeDetail
                                                                                        .challengeUnit ==
                                                                                    's')
                                                                            ? 'Steps'
                                                                            : widget.challengeDetail
                                                                                        .challengeUnit ==
                                                                                    'm'
                                                                                ? 'Distance (m)'
                                                                                : "Distance (km)",
                                                                        style: TextStyle(
                                                                            fontSize: 12.sp,
                                                                            color: Colors.grey
                                                                                .withOpacity(0.8)))
                                                                  ],
                                                                ),
                                                                widget.challengeDetail
                                                                            .challengeMode ==
                                                                        "individual"
                                                                    ? Builder(builder: (_) {
                                                                        double _val = calculate();
                                                                        return Text(
                                                                            '${_val > widget.filteredList.target ? widget.filteredList.target : (widget.challengeDetail.challengeUnit == 'steps' || widget.challengeDetail.challengeUnit == 's') ? _val.toStringAsFixed(0) : _val.toStringAsFixed(2)}',
                                                                            style: FitnessAppTheme
                                                                                .challengeValueText);
                                                                      })
                                                                    : Builder(builder: (_) {
                                                                        double _val = calcuGrp();
                                                                        return Text(
                                                                            '${_val > widget.filteredList.target ? widget.filteredList.target : (widget.challengeDetail.challengeUnit == 'steps' || widget.challengeDetail.challengeUnit == 's') ? _val.toStringAsFixed(0) : _val.toStringAsFixed(2)}'
                                                                            // ? widget.filteredList
                                                                            //     .groupAchieved
                                                                            ,
                                                                            style: FitnessAppTheme
                                                                                .challengeValueText);
                                                                      })
                                                              ],
                                                            ),
                                                          ),
                                                          widget.challengeDetail.challengeMode ==
                                                                  "individual"
                                                              ? SizedBox(
                                                                  width: width / 3.4,
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Column(
                                                                        children: <Widget>[
                                                                          const Text("Pending",
                                                                              // widget.challengeDetail
                                                                              //             .challengeMode ==
                                                                              //         "individual"
                                                                              //     ? "Remaining"
                                                                              //     : "Yet to Achieve",
                                                                              style: FitnessAppTheme
                                                                                  .challengeKeyText),
                                                                          Text(
                                                                              (widget.challengeDetail
                                                                                              .challengeUnit ==
                                                                                          'steps' ||
                                                                                      widget.challengeDetail
                                                                                              .challengeUnit ==
                                                                                          's')
                                                                                  ? 'Steps'
                                                                                  : widget.challengeDetail
                                                                                              .challengeUnit ==
                                                                                          'm'
                                                                                      ? 'Distance (m)'
                                                                                      : "Distance (km)",
                                                                              style: TextStyle(
                                                                                  fontSize: 12.sp,
                                                                                  color: Colors.grey
                                                                                      .withOpacity(
                                                                                          0.8)))
                                                                        ],
                                                                      ),
                                                                      Builder(builder: (_) {
                                                                        double typeTotal =
                                                                            calculate();
                                                                        return Text(
                                                                            widget.filteredList
                                                                                        .userAchieved !=
                                                                                    null
                                                                                ? '${typeTotal > widget.filteredList.target ? 0 : (widget.challengeDetail.challengeUnit == 'steps' || widget.challengeDetail.challengeUnit == 's') ? (widget.filteredList.target - typeTotal).toStringAsFixed(0) : (widget.filteredList.target - typeTotal).toStringAsFixed(2)}'

                                                                                // ? '${int.parse(widget.filteredList.target) - int.parse(widget.filteredList.userAchieved)}'
                                                                                : "0",
                                                                            style: FitnessAppTheme
                                                                                .challengeValueText);
                                                                      })
                                                                    ],
                                                                  ),
                                                                )
                                                              : SizedBox(
                                                                  width: width / 3.4,
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Column(
                                                                        children: <Widget>[
                                                                          const Text("Pending",
                                                                              style: FitnessAppTheme
                                                                                  .challengeKeyText),
                                                                          Text(
                                                                              (widget.challengeDetail
                                                                                              .challengeUnit ==
                                                                                          'steps' ||
                                                                                      widget.challengeDetail
                                                                                              .challengeUnit ==
                                                                                          's')
                                                                                  ? 'Steps'
                                                                                  : widget.challengeDetail
                                                                                              .challengeUnit ==
                                                                                          'm'
                                                                                      ? 'Distance (m)'
                                                                                      : "Distance (km)",
                                                                              style: TextStyle(
                                                                                  fontSize: 12.sp,
                                                                                  color: Colors.grey
                                                                                      .withOpacity(
                                                                                          0.8)))
                                                                        ],
                                                                      ),
                                                                      GetBuilder(
                                                                          id: _stepController
                                                                              .updateStep,
                                                                          init: HealthRepository(),
                                                                          builder: (_) {
                                                                            double typeTotal =
                                                                                calcuGrp();
                                                                            return Text(
                                                                                widget.filteredList
                                                                                            .userAchieved !=
                                                                                        null
                                                                                    ? '${typeTotal > widget.filteredList.target ? 0 : (widget.challengeDetail.challengeUnit == 'steps' || widget.challengeDetail.challengeUnit == 's') ? (widget.filteredList.target - typeTotal).toStringAsFixed(0) : (widget.filteredList.target - typeTotal).toStringAsFixed(2)}'

                                                                                    // ? '${int.parse(widget.filteredList.target) - int.parse(widget.filteredList.userAchieved)}'
                                                                                    : "0",
                                                                                style: FitnessAppTheme
                                                                                    .challengeValueText);
                                                                          })
                                                                    ],
                                                                  ),
                                                                ),
                                                          SizedBox(
                                                            width: width / 4.5,
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Column(
                                                                children: <Widget>[
                                                                  Column(
                                                                    children: <Widget>[
                                                                      const Text("Total",
                                                                          style: FitnessAppTheme
                                                                              .challengeKeyText),
                                                                      Text(
                                                                          (widget.challengeDetail
                                                                                          .challengeUnit ==
                                                                                      'steps' ||
                                                                                  widget.challengeDetail
                                                                                          .challengeUnit ==
                                                                                      's')
                                                                              ? 'Steps'
                                                                              : widget.challengeDetail
                                                                                          .challengeUnit ==
                                                                                      'm'
                                                                                  ? 'Distance (m)'
                                                                                  : "Distance (km)",
                                                                          style: TextStyle(
                                                                              fontSize: 12.sp,
                                                                              color: Colors.grey
                                                                                  .withOpacity(
                                                                                      0.8)))
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    children: <Widget>[
                                                                      Text(
                                                                          widget.filteredList !=
                                                                                  null
                                                                              ? '${widget.filteredList.target}'
                                                                              : "0",
                                                                          style: FitnessAppTheme
                                                                              .challengeValueText),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      widget.challengeDetail.challengeMode ==
                                                              "individual"
                                                          ? Builder(builder: (_) {
                                                              double _total = calculate();
                                                              return Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: NeumorphicIndicator(
                                                                  orientation:
                                                                      NeumorphicIndicatorOrientation
                                                                          .horizontal,
                                                                  height: 2.h,
                                                                  width: 75.w,
                                                                  percent: _total /
                                                                      widget.filteredList.target,
                                                                ),
                                                              );
                                                            })
                                                          : Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Builder(builder: (_) {
                                                                double _totalSteps = calcuGrp();
                                                                return NeumorphicIndicator(
                                                                  orientation:
                                                                      NeumorphicIndicatorOrientation
                                                                          .horizontal,
                                                                  height: 2.h,
                                                                  width: 75.w,
                                                                  percent: _totalSteps /
                                                                      widget.filteredList.target,
                                                                );
                                                              }),
                                                            ),
                                                    ],
                                                  ),
                                          ),
                                          Visibility(
                                            visible: widget.filteredList.userProgress != null,
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 15.0),
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: 7.h,
                                                    width: 95.w,
                                                    decoration: const BoxDecoration(
                                                      color: AppColors.primaryColor,
                                                      boxShadow: <BoxShadow>[
                                                        BoxShadow(
                                                            color: Colors.grey,
                                                            offset: Offset(3, 3),
                                                            blurRadius: 6)
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        const SizedBox(
                                                          width: 1,
                                                        ),
                                                        Text(
                                                            widget.challengeDetail.challengeMode ==
                                                                    "individual"
                                                                ? "My Progression"
                                                                : "My Contribution",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                fontSize: 18.sp,
                                                                fontWeight: FontWeight.w500,
                                                                color: Colors.white)),
                                                        // Expanded(
                                                        //   flex: 1,
                                                        //   child: Icon(
                                                        //     Icons.play_arrow,
                                                        //     color: Colors.white,
                                                        //   ),
                                                        // )
                                                        const SizedBox(
                                                          width: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    // height: 15.h,
                                                    width: 95.w,
                                                    decoration: const BoxDecoration(
                                                      color: AppColors.appBackgroundColor,
                                                      boxShadow: <BoxShadow>[
                                                        BoxShadow(
                                                            color: Colors.grey,
                                                            offset: Offset(1, 1),
                                                            blurRadius: 6)
                                                      ],
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceEvenly,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.end,
                                                          children: <Widget>[
                                                            Column(
                                                              children: <Widget>[
                                                                Visibility(
                                                                  visible: widget.challengeDetail
                                                                          .challengeMode !=
                                                                      "individual",
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      const Text("Achieved",
                                                                          style: FitnessAppTheme
                                                                              .challengeKeyText),
                                                                      Text(
                                                                          (widget.challengeDetail
                                                                                          .challengeUnit ==
                                                                                      'steps' ||
                                                                                  widget.challengeDetail
                                                                                          .challengeUnit ==
                                                                                      's')
                                                                              ? 'Steps'
                                                                              : widget.challengeDetail
                                                                                          .challengeUnit ==
                                                                                      'm'
                                                                                  ? 'Distance (m)'
                                                                                  : "Distance (km)",
                                                                          style: TextStyle(
                                                                              fontSize: 13.sp,
                                                                              color: Colors.grey
                                                                                  .withOpacity(
                                                                                      0.8)))
                                                                    ],
                                                                  ),
                                                                ),
                                                                Builder(builder: (_) {
                                                                  double typeTotal = calculate();
                                                                  return Text(
                                                                      '${typeTotal > widget.filteredList.target ? widget.filteredList.target : (widget.challengeDetail.challengeUnit == 'steps' || widget.challengeDetail.challengeUnit == 's') ? typeTotal.toStringAsFixed(0) : typeTotal.toStringAsFixed(2)}',
                                                                      style: FitnessAppTheme
                                                                          .challengeValueText);
                                                                }),
                                                                Builder(builder: (_) {
                                                                  var typeTotal = calculate();
                                                                  return Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(8.0),
                                                                    child: NeumorphicIndicator(
                                                                      orientation:
                                                                          NeumorphicIndicatorOrientation
                                                                              .horizontal,
                                                                      height: 2.h,
                                                                      width: 75.w,
                                                                      percent: typeTotal /
                                                                          widget
                                                                              .filteredList.target,
                                                                    ),
                                                                  );
                                                                })
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets.only(
                                                              top: 10,
                                                              left: 10,
                                                              bottom: 10,
                                                              right: 10),
                                                          child: Divider(thickness: 1),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.center,
                                                          children: <Widget>[
                                                            SizedBox(
                                                              width: 30,
                                                              height: 40,
                                                              child: Image.asset(
                                                                  "assets/images/diet/burned.png"),
                                                            ),
                                                            const Text(
                                                              "Burned Calories ",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.w600,
                                                                  letterSpacing: 1,
                                                                  color: Colors.blueGrey),
                                                            ),
                                                            GetBuilder<HealthRepository>(
                                                                id: _stepController.caloryUpdate,
                                                                initState: (_) {
                                                                  _stepController
                                                                      .caloriesCalculationFromChallengeStart(
                                                                          widget.filteredList
                                                                              .enrollmentId,
                                                                          fromChallengeChange:
                                                                              false);
                                                                },
                                                                builder: (_) {
                                                                  return Text(
                                                                    _.burnedCalories
                                                                        .toStringAsFixed(2),
                                                                    style: FitnessAppTheme
                                                                        .challengeValueText,
                                                                  );
                                                                }),
                                                            const Text(
                                                              " Cal",
                                                              style: FitnessAppTheme
                                                                  .challengeValueText,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  });
                            },
                          ),
                          // Get.find<ListChallengeController>()
                          //         .affiliateCmpnyList
                          //         .where((element) => widget
                          //             .challengeDetail.affiliations
                          //             .contains(element))
                          //         .isNotEmpty
                          Visibility(
                            visible: (Get.find<ListChallengeController>().affiliateCmpnyList.any(
                                    (element) =>
                                        widget.challengeDetail.affiliations.contains(element)) &&
                                !Get.find<ListChallengeController>()
                                    .affiliateCmpnyList
                                    .contains('Global')),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 7.h,
                                    width: 95.w,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryColor,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey, offset: Offset(3, 3), blurRadius: 6)
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 1,
                                        ),
                                        Text(
                                            widget.challengeDetail.challengeMode == "individual"
                                                ? "Send invite"
                                                : "Send invite",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white)),
                                        // Expanded(
                                        //   flex: 1,
                                        //   child: Icon(
                                        //     Icons.play_arrow,
                                        //     color: Colors.white,
                                        //   ),
                                        // )
                                        const SizedBox(
                                          width: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    // height: 15.h,
                                    width: 95.w,
                                    decoration: const BoxDecoration(
                                      color: AppColors.appBackgroundColor,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey, offset: Offset(1, 1), blurRadius: 6)
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          "Invite up-to 5 family members\n ($invitedEmailCount/5 invite left)",
                                          style: TextStyle(
                                              fontSize: height > 568 ? 14.sp : 16.sp,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1,
                                              color: Colors.blueGrey),
                                          textAlign: TextAlign.center,
                                        ),
                                        Padding(
                                          // padding:  EdgeInsets.only(left: 3.w,right: 3.w),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18, vertical: 15),

                                          child: Material(
                                            borderRadius:
                                                const BorderRadius.all(Radius.circular(15)),
                                            elevation: 2,
                                            child: TextField(
                                              controller: _sendInviteEmailController,
                                              keyboardType: TextInputType.emailAddress,
                                              onChanged: (String v) {
                                                if (!_sendInviteEmailController.value.text.isEmpty &&
                                                    !_sendInviteEmailController
                                                        .value.text.isEmpty &&
                                                    emailRegExp.hasMatch(
                                                        _sendInviteEmailController.value.text)) {
                                                  _inviteButton.value = true;
                                                } else {
                                                  _inviteButton.value = false;
                                                }
                                              },
                                              // inputFormatters: [
                                              //   FilteringTextInputFormatter.allow(
                                              //       RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))
                                              // ],
                                              decoration: InputDecoration(
                                                // suffixIcon: Icon(
                                                //   Icons.edit,
                                                //   color: Colors.black45,
                                                // ),
                                                errorText: emailValueCheck(),

                                                contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 18, vertical: 7),
                                                hintText: "Email of friends/family member",
                                                hintStyle: TextStyle(
                                                    color: Colors.black26, fontSize: 16.sp),
                                                border: const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(Radius.circular(15)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 0.5.h,
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                          width: 30.w,
                                          child: ValueListenableBuilder(
                                              valueListenable: _inviteButton,
                                              builder: (_, val, __) {
                                                return ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                    backgroundColor: invitedEmailCount == 5
                                                        ? AppColors.primaryAccentColor
                                                        : _inviteButton.value
                                                            ? AppColors.primaryAccentColor
                                                            : Colors.grey,
                                                  ),
                                                  onPressed: () {
                                                    if (!_sendInviteEmailController
                                                            .value.text.isEmpty &&
                                                        emailRegExp.hasMatch(
                                                            _sendInviteEmailController
                                                                .value.text)) {
                                                      inviteThroughEmailApiCall(
                                                          widget.challengeDetail.challengeId,
                                                          widget.filteredList.name,
                                                          _sendInviteEmailController.value.text);
                                                    }
                                                  },
                                                  child: Text('Invite',
                                                      style: TextStyle(
                                                          fontSize: 17.sp,
                                                          fontFamily: 'Poppins',
                                                          fontWeight: FontWeight.bold,
                                                          letterSpacing: 1,
                                                          color: Colors.white)),
                                                );
                                              }),
                                        ),
                                        SizedBox(
                                          height: 2.h,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                          child: Text(
                                            " By inviting your friends / family members will receive an welcome Email to download hCare APP subsequently, when they register with same Email Id they get access to this challenge.",
                                            style: TextStyle(
                                                fontSize: 12.5.sp,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1,
                                                color: Colors.blueGrey),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 25),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  emailValueCheck() {
    if (_sendInviteEmailController.value.text.isEmpty) {
      return null;
    } else if (!emailRegExp.hasMatch(_sendInviteEmailController.value.text)) {
      return "Invalid Email";
    } else
      return null;
  }

  inviteThroughEmailApiCall(String challengeID, referredbyname, refferredtoemail) async {
    if (invitedEmailCount <= 5) {
      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      String userEmail = prefs1.getString("email");
      var response = await ChallengeApi().inviteUserForChallenge(
          sendInviteUserForChallenge: SendInviteUserForChallenge(
              challangeId: challengeID,
              referredbyname: referredbyname,
              referredbyemail: userEmail,
              refferredtoemail: refferredtoemail));
      if (response == "invite success") {
        setState(() {
          invitedEmailCount = invitedEmailCount - 1;
        });
        _sendInviteEmailController.clear();
        toastMessageAlert("Invited Successfully!!");
      } else if (response == "already invited") {
        toastMessageAlert("Email already invited");
      } else if (response == "failed") {
        toastMessageAlert("Invite send failed");
      }
    } else {
      toastMessageAlert("Already invited 5 members!!");
    }
  }

  toastMessageAlert(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  checkReferInviteCount(String challengeID) async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    String refer_by_email = prefs1.getString("email");
    var response = await ChallengeApi()
        .challengeReferInviteCount(challangeId: challengeID, refer_by_email: refer_by_email);
    if (response != null) {
      try {
        setState(() {
          invitedEmailCount = 5 - int.parse(response);
        });
      } catch (e) {}
    }
  }

  dialogBox() {
    bool e = fitImplemented && fitInstalled;
    return e
        ? Container()
        : Get.defaultDialog(
            title: "",
            titlePadding: const EdgeInsets.only(),
            barrierDismissible: false,
            content: WillPopScope(
              onWillPop: () {
                Get.back();
                // return Get.off(HomeScreen(introDone: true),
                //     transition: Transition.size);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          height: 50,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 25,
                            backgroundImage: AssetImage("assets/icons/googlefit.png"),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
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
                        bool t;
                        if (Platform.isAndroid) {
                          t = await LaunchApp.isAppInstalled(
                              androidPackageName: "com.google.android.apps.fitness");
                        } else {
                          t = true;
                        }

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
                          GoogleSignIn _googleSignIn = GoogleSignIn(
                            scopes: [
                              'email',
                              'https://www.googleapis.com/auth/contacts.readonly',
                            ],
                          );
                          await _googleSignIn.signOut();
                          HealthFactory health = HealthFactory();
                          SharedPreferences _prefs = await SharedPreferences.getInstance();
                          final box = GetStorage();
                          try {
                            var _authenticate =
                                await health.requestAuthorization(types, permissions: permissions);
                            if (_authenticate) {
                              _prefs.setBool('fit', true);
                              box.write("fit", _authenticate);
                              fitImplemented = _authenticate;
                              Get.back();
                              getEnrolledChallenge(false);
                              Get.snackbar('Success', 'Connected Successfully',
                                  margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                  backgroundColor: AppColors.primaryAccentColor,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 5),
                                  snackPosition: SnackPosition.BOTTOM);
                            } else {
                              _prefs.setBool("fit", _authenticate);
                              box.write("fit", _authenticate);
                              fitImplemented = _authenticate;
                              Get.back();
                              Get.snackbar('Connection Error', 'Unable to connect to Google Fit.',
                                  margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                  backgroundColor: AppColors.failure,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 5),
                                  snackPosition: SnackPosition.BOTTOM);
                            }
                          } catch (e) {
                            _prefs.setBool("fit", false);
                            box.write("fit", false);
                            fitImplemented = false;
                            Get.back();
                            Get.snackbar('Connection Error', 'Unable to connect to Google Fit.',
                                margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                backgroundColor: AppColors.failure,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 5),
                                snackPosition: SnackPosition.BOTTOM);
                          }
                        } else {
                          await LaunchApp.openApp(
                              openStore: true,
                              androidPackageName: "com.google.android.apps.fitness");
                        }
                      },
                      child: const Text('Connect to Google Fit'),
                      style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                    ),
                  )
                ],
              ),
            ),
          );
  }

  showingDia() {
    Get.defaultDialog(
        barrierDismissible: false,
        onWillPop: () => null,
        backgroundColor: Colors.lightBlue.shade50,
        title: Get.find<ListChallengeController>().affiliateCmpnyList.contains("persistent") &&
                widget.challengeDetail.affiliations.contains("persistent") &&
                widget.challengeDetail.challengeMode == "individual"
            ? "Get Ready"
            : 'Get Ready',
        titlePadding: const EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
        titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
        contentPadding: const EdgeInsets.only(top: 0),
        content: Column(
          children: <Widget>[
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
            Get.find<ListChallengeController>().affiliateCmpnyList.contains("persistent") &&
                    widget.challengeDetail.affiliations.contains("persistent") &&
                    widget.challengeDetail.challengeMode == "individual"
                ? Text(
                    "Begin your walk \n run now!",
                    textAlign: TextAlign.center,
                    style: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                  )
                : Text(
                    "Begin your walk \n run now!",
                    textAlign: TextAlign.center,
                    style: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                  ),
            const SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                // Get.off(HomeScreen(introDone: true),
                //     transition: Transition.size);
                Navigator.pop(context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 4,
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

  isSendInviteEligible() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.get(SPKeys.userData);
    var userid = prefs.getString("ihlUserId");
    var res = json.decode(userData);
    var affListUser = res['User']['email'];
  }
}
