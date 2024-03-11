import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../dietDashboard/maintain_weight.dart';
import '../../../../utils/app_colors.dart';
import '../../../../views/goal_settings/gain_weight.dart';
import '../../../../views/goal_settings/maintain_weight_input.dart';
import 'loseWeightScreen.dart';

class MyGoalScreen extends StatelessWidget {
  final bool fromManageHealth;

  MyGoalScreen({Key key, this.fromManageHealth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Management'),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundScreenColor,
      body: Column(
        children: [
          Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 5.h, left: 2.w, right: 3.w),
                height: 12.h,
                padding: EdgeInsets.only(
                  left: 16.sp,
                ),
                color: Colors.white,
                width: double.infinity,
                alignment: Alignment.centerLeft,
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
                  right: -64.sp,
                  child: Transform(
                      transform: Matrix4.rotationY(math.pi),
                      child: Image.asset(
                        'newAssets/arrow.png',
                        width: 57.w,
                      ))),
              Container(
                height: 20.h,
                color: Colors.transparent,
              ),
            ],
          ),
          Gap(
            3.h,
          ),
          _card(
              ontap: () => Get.to(LoseWeightScreen(
                    goalID: '',
                    fromManageHealth: fromManageHealth,
                  )),
              title: 'Lose Weight',
              icon: Icons.trending_down_sharp),
          _card(
              ontap: () => Get.to(MaintainWeightScreen(
                    fromManageHealth: fromManageHealth,
                    goalID: '',
                  )),
              title: 'Maintain Weight',
              icon: Icons.trending_flat_sharp),
          _card(
              ontap: () => Get.to(GainWeightScreen(
                    fromManageHealth: fromManageHealth,
                    goalID: '',
                  )),
              title: 'Gain Weight',
              icon: Icons.trending_up_sharp),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.sp, vertical: 20.sp),
            child: Text(
              'You can update your goals if you change your mind.',
              style: TextStyle(
                color: AppColors.textLiteColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({var ontap, var title, var icon}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.all(12.sp),
        height: 12.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
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
                fontSize: 17.sp,
                color: AppColors.textLiteColor,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
