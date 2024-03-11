import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/goal_settings/lose_by_both_goal.dart';
import 'package:ihl/widgets/goalSetting/resuable_alert_box.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoseWeightByBothScreen extends StatefulWidget {
  final String targetWeight;
  final String currentWeight;
  final String goalID;
  final bool fromManageHealth;

  const LoseWeightByBothScreen(
      {Key key, this.targetWeight, this.currentWeight, this.goalID, this.fromManageHealth})
      : super(key: key);

  @override
  _LoseWeightByBothScreenState createState() => _LoseWeightByBothScreenState();
}

class _LoseWeightByBothScreenState extends State<LoseWeightByBothScreen> {
  final key = new GlobalKey();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  var goalCaloriesIntake = '0';
  String goalPlan = 'Sedentary (little/no exercises)';
  double goalDuration = 0.5;
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
    setState(() {
      if (widget.currentWeight == null) {
        currentWeight = double.tryParse(weight).toStringAsFixed(2);
      } else {
        currentWeight = widget.currentWeight;
      }
    });
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
      setState(() {
        goalCaloriesIntake = maleBmr.toStringAsFixed(0);
      });
    } else {
      setState(() {
        goalCaloriesIntake = femaleBmr.toStringAsFixed(0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    dailyTarget(widget.targetWeight);
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
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          if (_formKey.currentState != null && _formKey.currentState.validate()) {
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
            title: const Text('Choose your pace'),
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
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
                  1.h,
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
                            "Be confident in your goal setting.",
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
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Activity Level',
                        style: TextStyle(
                          color: AppColors.textitemTitleColor,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Gap(
                        1.h,
                      ),
                      Container(
                        child: DropdownButton<String>(
                          focusColor: Colors.white,
                          value: goalPlan,
                          isExpanded: true,
                          underline: Container(
                            height: 2.0,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          iconEnabledColor: Colors.black,
                          items: <String>[
                            'Sedentary (little/no exercises)',
                            'Lightly Active (exercise 1-3days/wk)',
                            'Moderately Active (exercise 6-7days/wk)',
                            'Very Active (hard exercise every day)',
                            'High Intense Training (Atheletic training)'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17.sp,
                                ),
                              ),
                            );
                          }).toList(),
                          hint: Text(
                            "Select Activities",
                            style: TextStyle(
                                color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600),
                          ),
                          onChanged: (String value) {
                            setState(() {
                              goalDuration = 0.5;
                              goalPlan = value;
                            });
                          },
                        ),
                      ),
                      Gap(2.h),
                      Text(
                        "With this plan, you're on track to\nlose ${(double.parse(currentWeight) - double.parse(widget.targetWeight)).toPrecision(0)} Kgs by 👇🏻",
                        style: TextStyle(
                          color: AppColors.textLiteColor,
                          fontSize: 16.sp,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(1.5.h),
                      Text(
                        goalDurationDate(),
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18.sp,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(
                        1.5.h,
                      ),
                      Text(
                        'Choose your pace',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16.sp,
                        ),
                      ),
                      Gap(
                        1.5.h,
                      ),
                      Text(
                        '$goalDuration kg / week',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18.sp,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(1.h),
                      Text(
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
                      ),
                      Gap(
                        1.h,
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primaryColor,
                          thumbColor: AppColors.primaryColor,
                          inactiveTrackColor: AppColors.primaryColor.withOpacity(0.4),
                        ),
                        child: Slider(
                          min: 0.1,
                          max: maxDuration(goalPlan),
                          divisions: 10,
                          value: goalDuration,
                          onChanged: (value) {
                            setState(() {
                              goalDuration = value.toPrecision(1);
                            });
                          },
                        ),
                      ),
                      Visibility(
                        visible: (goalDuration < 0.7 && goalDuration > 0.3),
                        replacement: Container(),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            'We suggest this pace for a lasting weight loss success.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textLiteColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            if (int.parse(targetCalorie) > 100 && int.parse(targetCalorie) < 500) {
                              //allow and alert min.
                              alertBox('Strict Minimum Calorie', Colors.amber, true);
                            } else if (int.parse(targetCalorie) > 2000 &&
                                int.parse(targetCalorie) < 3000) {
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
                              Get.to(
                                LoseWeightByBothGoalScreen(
                                    targetWeight: widget.targetWeight,
                                    currentWeight: widget.currentWeight,
                                    targetCalories: targetCalorie,
                                    targetDate: goalDurationDate(),
                                    goalPace: goalDuration.toStringAsFixed(1),
                                    activityLevel: goalPlan,
                                    goalID: widget.goalID),
                              );
                            }

                            // Get.to(
                            //   LoseWeightByBothGoalScreen(
                            //     targetWeight: widget.targetWeight,
                            //     currentWeight: widget.currentWeight,
                            //     targetCalories: targetCalorie,
                            //     targetDate: goalDurationDate(),
                            //     goalPace: goalDuration.toStringAsFixed(1),
                            //     activityLevel: goalPlan,
                            //     goalID:widget.goalID
                            //   ),
                            // );
                          },
                          child: Container(
                              width: 25.w,
                              height: 4.h,
                              margin: EdgeInsets.only(top: 2.h),
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
                Gap(12.h),
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
            Get.to(LoseWeightByBothGoalScreen(
                targetWeight: widget.targetWeight,
                currentWeight: widget.currentWeight,
                targetCalories: targetCalorie,
                targetDate: goalDurationDate(),
                goalPace: goalDuration.toStringAsFixed(1),
                activityLevel: goalPlan,
                goalID: widget.goalID));
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

  double maxDuration(String goalPlan) {
    if (goalPlan == 'Sedentary (little/no exercises)') {
      return 1.0;
    } else if (goalPlan == 'Lightly Active (exercise 1-3days/wk)') {
      return 1.4;
    } else if (goalPlan == 'Moderately Active (exercise 6-7days/wk)') {
      return 1.6;
    } else if (goalPlan == 'Very Active (hard exercise every day)') {
      return 1.8;
    } else if (goalPlan == 'High Intense Training (Atheletic training)') {
      return 2.0;
    } else {
      return 1.0;
    }
  }

  String goalDurationDate() {
    double loseWeight = double.tryParse(currentWeight) - double.tryParse(widget.targetWeight);
    int noOfDays = (loseWeight ~/ goalDuration) * 7;
    targetCalorie =
        ((double.parse(goalCaloriesIntake) * maxDuration(goalPlan)) - (500 * goalDuration))
            .toStringAsFixed(0);
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
//                     Get.to(
//                       LoseWeightByBothGoalScreen(
//                           targetWeight: widget.targetWeight,
//                           currentWeight: widget.currentWeight,
//                           targetCalories: targetCalorie,
//                           targetDate: goalDurationDate(),
//                           goalPace: goalDuration.toStringAsFixed(1),
//                           activityLevel: goalPlan,
//                           goalID:widget.goalID
//                       ),
//                     );
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
