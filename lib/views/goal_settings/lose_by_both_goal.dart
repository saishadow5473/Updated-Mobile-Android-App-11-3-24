import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/new_design/presentation/controllers/healthJournalControllers/getTodayLogController.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/dietJournal.dart';
import 'package:ihl/views/dietJournal/dietJournalNew.dart';
import 'package:ihl/views/goal_settings/apis/goal_apis.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../../new_design/presentation/controllers/healthProgramControllers/healthProgramController.dart';
import '../../new_design/presentation/pages/healthProgram/healthProgramTabs.dart';
import '../../new_design/presentation/pages/home/home_view.dart';

class LoseWeightByBothGoalScreen extends StatefulWidget {
  final String targetWeight;
  final String currentWeight;
  final String targetCalories;
  final String targetDate;
  final String goalPace;
  final String activityLevel;
  final String goalID;

  const LoseWeightByBothGoalScreen(
      {Key key,
      this.targetWeight,
      this.currentWeight,
      this.targetCalories,
      this.targetDate,
      this.goalPace,
      this.goalID,
      this.activityLevel})
      : super(key: key);

  @override
  _LoseWeightByBothGoalScreenState createState() => _LoseWeightByBothGoalScreenState();
}

class _LoseWeightByBothGoalScreenState extends State<LoseWeightByBothGoalScreen> {
  final key = new GlobalKey();
  final _formKey = GlobalKey<FormState>();
  StreamingSharedPreferences preferences;
  bool _autoValidate = false;
  String height = '0';
  bool _proceedLoading = false;
  String bmi = '0';
  var goalCaloriesIntake = '0';
  var oldGoalCaloriesIntake = '0';
  String goalPlan = 'Reduce by Diet';

// Dart code to get the weight when bmi and height in meters given
  double calculateWeight(double bmi, double height) {
    double weight = bmi * height * height;
    return weight;
  }

  void dailyTarget(String weight) async {
    StreamingSharedPreferences.instance.then((value) {
      setState(() {
        preferences = value;
      });
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    Map res = jsonDecode(userData);
    var height;
    String datePattern = "MM/dd/yyyy";
    var dob = res['User']['dateOfBirth'].toString();
    DateTime today = DateTime.now();
    DateTime birthDate = DateFormat(datePattern).parse(dob);
    int age = today.year - birthDate.year;
    if (res['User']['heightMeters'] is num) {
      height = (res['User']['heightMeters'] * 100).toInt().toString();
    }
    var m = res['User']['gender'];
    num maleBmr =
        (10 * double.parse(weight.toString()) + 6.25 * double.parse(height) - (5 * age) + 5);
    num femaleBmr = (10 * double.parse(weight) + 6.25 * double.parse(height) - (5 * age) - 161);
    if (m == 'm' || m == 'M' || m == 'male' || m == 'Male') {
      setState(() {
        goalCaloriesIntake = maleBmr.toStringAsFixed(0);
      });
    } else {
      setState(() {
        goalCaloriesIntake = femaleBmr.toStringAsFixed(0);
      });
    }
  }

  void dailyOldTarget(String weight) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    Map res = jsonDecode(userData);
    String datePattern = "MM/dd/yyyy";
    var dob = res['User']['dateOfBirth'].toString();
    DateTime today = DateTime.now();
    DateTime birthDate = DateFormat(datePattern).parse(dob);
    int age = today.year - birthDate.year;
    if (res['User']['heightMeters'] is num) {
      height = (res['User']['heightMeters'] * 100).toInt().toString();
    }
    calcBmi(height: height, weight: weight);
    var m = res['User']['gender'];
    num maleBmr =
        (10 * double.parse(weight.toString()) + 6.25 * double.parse(height) - (5 * age) + 5);
    num femaleBmr = (10 * double.parse(weight) + 6.25 * double.parse(height) - (5 * age) - 161);
    if (m == 'm' || m == 'M' || m == 'male' || m == 'Male') {
      setState(() {
        oldGoalCaloriesIntake = maleBmr.toStringAsFixed(0);
      });
    } else {
      setState(() {
        oldGoalCaloriesIntake = femaleBmr.toStringAsFixed(0);
      });
    }
  }

  calcBmi({height, weight}) {
    double parsedH = double.tryParse(height);
    double parsedW = double.tryParse(weight);
    if (parsedH != null && parsedW != null) {
      setState(() {
        bmi = (parsedW ~/ (parsedH * parsedH)).toStringAsFixed(2);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dailyTarget(widget.targetWeight);
    dailyOldTarget(widget.currentWeight ?? '0');
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Get.to(HealthProgramTabs(fromDashboard: false));
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          if (_formKey.currentState.validate()) {
          } else {
            if (this.mounted) {
              setState(() {
                _autoValidate = true;
              });
            }
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.backgroundScreenColor,
          appBar: AppBar(
            title: const Text('Your Goal Set !'),
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 5.h, left: 3.w, right: 3.w),
                    height: 12.h,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      left: 18.sp,
                    ),
                    color: Colors.white,
                    width: double.infinity,
                    child: Text(
                      'Choose your pace',
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Positioned(
                      top: 13.sp,
                      right: -255,
                      child: Transform(
                          transform: Matrix4.rotationY(math.pi),
                          child: Image.asset(
                            'newAssets/arrow.png',
                            width: 235,
                          ))),
                  Container(
                    height: 20.h,
                    color: Colors.transparent,
                  ),
                ],
              ),
              Gap(
                1.5.h,
              ),
              Container(
                height: 15.h,
                padding: const EdgeInsets.all(8.0),
                margin: EdgeInsets.all(8.0.sp),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_circle_down,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Yay! You choose to lose\nyour weight.",
                          style: TextStyle(
                            color: const Color(0xff2d3142),
                            fontSize: ScUtil().setSp(14),
                          ),
                        ),
                        Gap(1.6.h),
                        Text(
                          "Your goal is now set. Stick to it! 😃",
                          style: TextStyle(
                            color: const Color(0xff4c5980),
                            fontSize: ScUtil().setSp(11),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Gap(
                3.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Daily Intake Calories',
                      style: TextStyle(
                        color: AppColors.textLiteColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    Gap(2.5.h),
                    Text(
                      '${widget.targetCalories} Cal / day',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(18.h),
              GestureDetector(
                onTap: !_proceedLoading
                    ? () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        var goalData = await sendDataToAPI();
                        if (widget.goalID == null || widget.goalID == '') {
                          _proceedLoading = true;
                          if (mounted) setState(() {});
                          GoalApis.setGoal(goalData).then((value) {
                            if (value != null) {
                              preferences.setBool('maintain_weight', false);
                              prefs.setInt('daily_target', int.tryParse(widget.targetCalories));
                              final navi = GetStorage();
                              // if (navi.read("setGoalNavigation")) {
                              //   //Get.find<TodayLogController>();
                              //   Get.to(Home());
                              //   // Navigator.pushAndRemoveUntil(
                              //   //     context,
                              //   //     MaterialPageRoute(
                              //   //         builder: (context) =>
                              //   //             HomeScreen(introDone: true)),
                              //   //     (Route<dynamic> route) => false);
                              // } else
                              //   Get.offAll(DietJournal(),
                              //       predicate: (route) => Get.currentRoute == Routes.Home,
                              //       popGesture: true);
                              try {
                                Get.find<TodayLogController>().onInit();
                              } catch (e) {
                                Get.put(TodayLogController());
                              }
                              Get.find<HealthProgramController>().getGoalData();

                              Get.to(HealthProgramTabs(fromDashboard: false));
                            } else {
                              _proceedLoading = false;
                              if (mounted) setState(() {});
                              Get.snackbar(
                                  'Goal not created!', 'Encountered some error. Please try again',
                                  icon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.cancel_outlined, color: Colors.white)),
                                  margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                  duration: Duration(seconds: 5),
                                  snackPosition: SnackPosition.BOTTOM);
                            }
                          });
                        } else {
                          _proceedLoading = true;
                          if (mounted) setState(() {});
                          GoalApis.editGoal(goalData).then((value) {
                            if (value != null) {
                              preferences.setBool('maintain_weight', false);
                              prefs.setInt('daily_target', int.tryParse(widget.targetCalories));
                              Get.to(HealthProgramTabs(fromDashboard: false));
                              // final navi = GetStorage();
                              // if (navi.read("setGoalNavigation")) {
                              //   //Get.find<TodayLogController>();
                              //   Get.to(Home());
                              //   // Navigator.pushAndRemoveUntil(
                              //   //     context,
                              //   //     MaterialPageRoute(
                              //   //         builder: (context) =>
                              //   //             HomeScreen(introDone: true)),
                              //   //     (Route<dynamic> route) => false);
                              // } else
                              //   Get.offAll(DietJournal(),
                              //       predicate: (route) => Get.currentRoute == Routes.Home,
                              //       popGesture: true);
                            } else {
                              _proceedLoading = false;
                              if (mounted) setState(() {});
                              Get.snackbar(
                                  'Goal not changed!', 'Encountered some error. Please try again',
                                  icon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.cancel_outlined, color: Colors.white)),
                                  margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                  duration: Duration(seconds: 5),
                                  snackPosition: SnackPosition.BOTTOM);
                            }
                          });
                        }
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.primaryColor,
                            content: Text('Loading...'),
                          ),
                        );
                      },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      width: 25.w,
                      height: 4.h,
                      margin: EdgeInsets.only(top: 10.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10.sp)),
                      child: Text('Continue',
                          style: TextStyle(fontSize: 16.sp, color: FitnessAppTheme.white))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Map> sendDataToAPI() async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    if (widget.goalID == null || widget.goalID == '') {
      return {
        "ihl_user_id": iHLUserId,
        "weight": widget.currentWeight,
        "height": height,
        "goal_pace": widget.goalPace,
        "target_calorie": widget.targetCalories,
        "target_weight": widget.targetWeight,
        "bmi": bmi,
        "manage_weight": false,
        "goal_date": widget.targetDate,
        "activitiy_level": widget.activityLevel,
        "activities_choosen": [],
        "goal_type": 'lose_weight',
        "goal_sub_type": 'both',
      };
    } else {
      return {
        "ihl_user_id": iHLUserId,
        "goal_id": widget.goalID,
        "weight": widget.currentWeight,
        "height": height,
        "goal_pace": widget.goalPace,
        "target_calorie": widget.targetCalories,
        "target_weight": widget.targetWeight,
        "bmi": bmi,
        "manage_weight": false,
        "goal_date": widget.targetDate,
        "activitiy_level": widget.activityLevel,
        "activities_choosen": [],
        "goal_type": 'lose_weight',
        "goal_sub_type": 'both',
      };
    }
  }
}
