import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/goal_settings/gain_weight.dart';

import 'package:ihl/views/goal_settings/maintain_weight_input.dart';
import 'package:ihl/views/home_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../new_design/presentation/pages/healthProgram/loseWeightScreen.dart';

class GoalSettingScreen extends StatefulWidget {
  final String goalId;
  final String goalType;
  const GoalSettingScreen({Key key, this.goalId, this.goalType}) : super(key: key);

  @override
  _GoalSettingScreenState createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  bool loseWeight = false;
  bool maintainWeight = true;
  bool gainWeight = false;

  @override
  void initState() {
    if (widget.goalType == 'lose_weight') {
      loseWeight = true;
      maintainWeight = false;
      gainWeight = false;
    } else if (widget.goalType == 'gain_weight') {
      loseWeight = false;
      maintainWeight = false;
      gainWeight = true;
    }
    super.initState();
  }

  Widget _card({var ontap, var title, var icon, bool border}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.all(12.sp),
        height: 12.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: border ? AppColors.primaryColor : FitnessAppTheme.white,
            ),
            borderRadius: BorderRadius.circular(3),
            color: FitnessAppTheme.white,
            boxShadow: [
              BoxShadow(color: Colors.grey[400], blurRadius: 4, offset: const Offset(0, 3))
            ]),
        child: Row(
          children: <Widget>[
            SizedBox(width: 15.sp),
            Icon(icon, color: AppColors.primaryColor, size: 35.sp),
            SizedBox(width: 25.sp),
            Text(
              '$title',
              style: TextStyle(
                fontSize: 18.sp,
                color: AppColors.textLiteColor,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Get.back();
        /*widget.goalId == null
            ? Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(
                          introDone: true,
                        )),
                (Route<dynamic> route) => false)
            : Get.back();*/
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Weight Management'),
            elevation: 0,
            centerTitle: true,
          ),
          backgroundColor: AppColors.backgroundScreenColor,
          body: Column(
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
                      'What is your desired goal?',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textLiteColor,
                      ),
                    ),
                  ),
                  Positioned(
                      top: 13.sp,
                      right: -67.sp,
                      child: Transform(
                          transform: Matrix4.rotationY(math.pi),
                          child: Image.asset(
                            'newAssets/arrow.png',
                            width: 60.w,
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
              Gap(
                3.h,
              ),
              _card(
                  ontap: () {
                    setState(() {
                      loseWeight = !loseWeight;
                      gainWeight = maintainWeight = false;
                    });
                    Get.to(LoseWeightScreen(goalID: widget.goalId));
                  },
                  title: 'Lose Weight',
                  border: loseWeight,
                  icon: Icons.trending_down_sharp),
              _card(
                  ontap: () {
                    setState(() {
                      maintainWeight = !maintainWeight;
                      loseWeight = gainWeight = false;
                    });
                    Get.to(MaintainWeightScreen(
                      goalID: widget.goalId,
                    ));
                  },
                  title: 'Maintain Weight',
                  border: maintainWeight,
                  icon: Icons.trending_flat_sharp),
              _card(
                  ontap: () {
                    setState(() {
                      gainWeight = !gainWeight;
                      loseWeight = maintainWeight = false;
                    });
                    Get.to(GainWeightScreen(
                      goalID: widget.goalId,
                    ));
                  },
                  border: gainWeight,
                  title: 'Gain Weight',
                  icon: Icons.trending_up_sharp),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 4.h),
                child: Text(
                  'You can update your goals if you change your mind.',
                  style: TextStyle(
                    color: AppColors.textLiteColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String choosenGoal() {
    if (loseWeight == true) {
      return 'loseWeight';
    } else if (gainWeight == true) {
      return 'gainWeight';
    } else {
      return 'maintainWeight';
    }
  }

  void proceed() {
    if (loseWeight == true) {
      Get.to(LoseWeightScreen(
        goalID: widget.goalId,
      ));
    } else if (gainWeight == true) {
      Get.to(GainWeightScreen(
        goalID: widget.goalId,
      ));
    } else {
      Get.to(MaintainWeightScreen(
        goalID: widget.goalId,
      ));
    }
  }
}
