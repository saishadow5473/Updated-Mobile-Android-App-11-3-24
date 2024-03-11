import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../utils/ScUtil.dart';
import '../../utils/app_colors.dart';
import 'lose_by_diet_goal.dart';
import '../../widgets/goalSetting/resuable_alert_box.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoseWeightByDietScreen extends StatefulWidget {
  final String targetWeight;
  final String currentWeight;
  final String goalID;
  final bool fromManageHealth;

  const LoseWeightByDietScreen(
      {Key key, this.targetWeight, this.currentWeight, this.goalID, this.fromManageHealth})
      : super(key: key);

  @override
  _LoseWeightByDietScreenState createState() => _LoseWeightByDietScreenState();
}

class _LoseWeightByDietScreenState extends State<LoseWeightByDietScreen> {
  final key = new GlobalKey();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  var goalCaloriesIntake = '0';
  var oldGoalCaloriesIntake = '0';
  String goalPlan = 'Reduce by Diet';
  RxDouble goalDuration = 0.5.obs;
  String currentWeight = '0';
  String targetCalorie = '0';

// Dart code to get the weight when bmi and height in meters given
  double calculateWeight(double bmi, double height) {
    double weight = bmi * height * height;
    return weight;
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var height = prefs.get('userLatestHeight').toString();
    var weight = prefs.get('userLatestWeight').toString();
    if (widget.currentWeight == null) {
      currentWeight = double.tryParse(weight).toStringAsFixed(2);
    } else {
      currentWeight = widget.currentWeight;
    }
  }

  void dailyTarget(String weight) async {
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
      goalCaloriesIntake = maleBmr.toStringAsFixed(0);
    } else {
      goalCaloriesIntake = femaleBmr.toStringAsFixed(0);
    }
  }

  void dailyOldTarget(String weight) async {
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
      oldGoalCaloriesIntake = maleBmr.toStringAsFixed(0);
    } else {
      oldGoalCaloriesIntake = femaleBmr.toStringAsFixed(0);
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
    dailyTarget(widget.targetWeight);
    dailyOldTarget(widget.currentWeight);
  }

  bool isAgree = false;

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Get.back();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.backgroundScreenColor,
        appBar: AppBar(
          title: const Text('Lose Weight'),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
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
                          color: AppColors.textLiteColor,
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
                              color: AppColors.textLiteColor,
                              fontSize: ScUtil().setSp(14),
                            ),
                          ),
                          Gap(1.6.h),
                          Text(
                            "Be confident in your goal setting.",
                            style: TextStyle(
                              color: AppColors.textLiteColor,
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
                  padding: EdgeInsets.only(left: 18.sp),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      "With this plan, you're on track to\nlose ${(double.parse(currentWeight) - double.parse(widget.targetWeight)).toPrecision(0)} Kgs by 👇🏻",
                      style: TextStyle(
                        color: AppColors.textLiteColor,
                        fontSize: 16.sp,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(1.5.h),
                    Obx(() => Text(
                          goalDurationDate(),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 18.sp,
                            // fontWeight: FontWeight.bold,
                          ),
                        )),
                    Gap(1.5.h),
                    Text(
                      'Choose your pace',
                      style: TextStyle(
                        color: AppColors.textLiteColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    Gap(1.5.h),
                    Obx(() => Text(
                          '$goalDuration kg / week',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 18.sp,
                            // fontWeight: FontWeight.bold,
                          ),
                        )),
                    Gap(1.h),
                    Obx(() => Text(
                          (goalDuration < 0.7 && goalDuration > 0.3)
                              ? 'Recommended'
                              : (goalDuration >= 0.7)
                                  ? 'Strict'
                                  : 'Relaxed',
                          style: TextStyle(
                            color: (goalDuration < 0.7 && goalDuration > 0.3)
                                ? AppColors.primaryColor
                                : Colors.grey,
                            fontSize: 16,
                            // fontWeight: FontWeight.bold,
                          ),
                        )),
                    Gap(
                      1.h,
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryColor,
                        thumbColor: AppColors.primaryColor,
                        trackHeight: 2.0,
                        inactiveTrackColor: AppColors.primaryColor.withOpacity(0.4),
                      ),
                      child: Obx(() => Slider(
                            min: 0.1,
                            max: 1.0,
                            divisions: 10,
                            value: goalDuration.value,
                            onChanged: (value) {
                              goalDuration.value = value.toPrecision(1);
                            },
                          )),
                    ),
                  ]),
                ),
                Obx(() => AnimatedOpacity(
                      opacity: (goalDuration.value < 0.7 && goalDuration.value > 0.3) ? 1 : 0,
                      duration: const Duration(seconds: 1),
                      child: Center(
                        child: Container(
                          width: 70.w,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          child: const Text(
                            'We suggest this pace for a lasting weight loss success.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textLiteColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    )),
                Gap(2.h),
                GestureDetector(
                  onTap: () {
                    if (int.parse(targetCalorie) > 100 && int.parse(targetCalorie) < 500) {
                      //allow and alert min.
                      alertBox('Strict Minimum Calorie', Colors.amber, true);
                    } else if (int.parse(targetCalorie) > 2000 && int.parse(targetCalorie) < 3000) {
                      //allow and alert max
                      alertBox('Strict Maximum Calorie', Colors.amber, true);
                    } else if (int.parse(targetCalorie) > 3000) {
                      //impossible
                      alertBox(
                          '${int.parse(targetCalorie)} calorie is more than recommended calorie per day !!!',
                          Colors.red,
                          false);
                    } else if (int.parse(targetCalorie) < 100) {
                      //impossible
                      alertBox(
                          '${int.parse(targetCalorie)} calorie is less than recommended calorie per day !!!',
                          Colors.red,
                          false);
                    } else {
                      //simply allow
                      Get.to(LoseWeightByDietGoalScreen(
                        fromManageHealth: widget.fromManageHealth,
                        targetWeight: widget.targetWeight,
                        currentWeight: widget.currentWeight,
                        targetCalories: targetCalorie,
                        targetDate: goalDurationDate(),
                        goalPace: goalDuration.toStringAsFixed(1),
                        goalID: widget.goalID,
                      ));
                    }
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                        width: 30.w,
                        height: 5.h,
                        margin: EdgeInsets.only(top: 1.2.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10.sp)),
                        child: Text('Continue',
                            style: TextStyle(fontSize: 16.sp, color: FitnessAppTheme.white))),
                  ),
                ),
                Gap(10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  alertBox(alertText, txtColor, allow) {
    _buildChild(BuildContext context, StateSetter mystate) => ReusableAlertBox(
          alertText: alertText,
          allow: allow,
          context: context,
          isAgree: isAgree,
          mystate: mystate,
          txtColor: txtColor,
          continueOnTap: () {
            Get.to(LoseWeightByDietGoalScreen(
              fromManageHealth: widget.fromManageHealth,
              targetWeight: widget.targetWeight,
              currentWeight: widget.currentWeight,
              targetCalories: targetCalorie,
              targetDate: goalDurationDate(),
              goalPace: goalDuration.toStringAsFixed(1),
              goalID: widget.goalID,
            ));
          },
        );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter mystate) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: _buildChild(context, mystate),
                );
              },
            ),
          );
        });
  }

  String goalDurationDate() {
    double loseWeight = double.tryParse(currentWeight) - double.tryParse(widget.targetWeight);
    int noOfDays = ((loseWeight ~/ goalDuration.value) * 3.5).toInt();
    /*double loseCalories = (double.tryParse(oldGoalCaloriesIntake)*7) -
        (double.tryParse(goalCaloriesIntake)*goalDuration*7);
    int noOfDays = (((loseCalories/7)/double.tryParse(oldGoalCaloriesIntake))*goalDuration* 7).toInt();*/

    targetCalorie =
        (double.parse(goalCaloriesIntake) - (500 * goalDuration.value)).toStringAsFixed(0);
    DateTime today = DateTime.now();
    DateTime achieveBy = today.add(Duration(days: noOfDays));
    var achieveDate = DateFormat("MMMM d, yyyy").format(achieveBy);
    return achieveDate;
  }
//
// alertBox(alertText,txtColor,allow) {
//   _buildChild(BuildContext context) => Container(
//     height: 350,
//     decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.rectangle,
//         borderRadius: BorderRadius.all(Radius.circular(12))),
//     child: Column(
//       children: <Widget>[
//         Container(
//           child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 children: [
//                   SizedBox(
//                     width: 100,
//                     height: 100,
//                     child: Image.network(
//                         'https://i.postimg.cc/gj4Dfy7g/Objective-PNG-Free-Download.png'),
//                   ),
//                   // Icon(
//                   //   FontAwesomeIcons.palette,
//                   //   size: 80,
//                   //   color: Colors.white,
//                   // ),
//                   // SizedBox(
//                   //   height: 20,
//                   // ),
//                 ],
//               )),
//           width: double.infinity,
//           decoration: BoxDecoration(
//               color: Colors.green,//AppColors.primaryColor,
//               shape: BoxShape.rectangle,
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12))),
//         ),
//         SizedBox(
//           height: 24,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(right: 16, left: 16),
//           child: Text(
//             alertText,//+'\n'+targetCalorie.toString(),
//             style: TextStyle(color: txtColor, fontSize: 20),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         SizedBox(
//           height: 60,
//         ),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: allow?MainAxisAlignment.spaceEvenly:MainAxisAlignment.center,
//           children: [
//             // SizedBox(
//             //   width: MediaQuery.of(context).size.width / 10,
//             // ),
//             Visibility(
//               visible: allow,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   elevation: 0.5,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   primary: AppColors.primaryColor,
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                       top: 13.0, bottom: 13.0, right: 15, left: 15),
//                   child: Text(
//                     'Continue',
//                     style: TextStyle(
//                         fontSize: 15, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 onPressed: () async {
//                   if(allow){
//                     Get.to(LoseWeightByDietGoalScreen(
//                       targetWeight: widget.targetWeight,
//                       currentWeight: widget.currentWeight,
//                       targetCalories: targetCalorie,
//                       targetDate: goalDurationDate(),
//                       goalPace: goalDuration.toStringAsFixed(1),
//                       goalID: widget.goalID,
//                     ));
//                   }
//                 },
//               ),
//             ),
//
//             // SizedBox(
//             //   width: MediaQuery.of(context).size.width / 8,
//             // ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 elevation: 0.5,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 primary: AppColors.primaryColor,
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                     top: 13.0, bottom: 13.0, right: 15, left: 15),
//                 child: Text(
//                   'Change',
//                   style: TextStyle(
//                       fontSize: 15, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
//   showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async => false,
//           child: Dialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16)),
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             child: _buildChild(context),
//           ),
//         );
//       });
// }
}
