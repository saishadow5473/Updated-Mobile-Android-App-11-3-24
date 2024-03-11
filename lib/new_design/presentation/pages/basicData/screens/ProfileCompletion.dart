import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/utils/appColors.dart';
import '../../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../functionalities/percentage_calculations.dart';
import '../screens/GenderScreen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfileCompletionScreen extends StatelessWidget {
  ProfileCompletionScreen({Key key}) : super(key: key);
  final TabBarController tabBarController = Get.find();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        tabBarController.updateSelectedIconValue(value: "Home");
        Get.back();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryAccentColor,
          title: const Text('Complete your profile'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              size: 28.sp,
            ),
            onPressed: () {
              tabBarController.updateSelectedIconValue(value: "Home");
              Get.back();
            },
          ),
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 9.h,
            ),
            Container(
              height: 24.h,
              width: 100.w,
              decoration: const BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage('newAssets/images/profileCompletion.png'))),
            ),
            SizedBox(
              height: 6.h,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 5.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: const [],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 3.w,
                      ),
                      child: Text(
                          'Profile - ${PercentageCalculations().calculatePercentageFilled()}%'),
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Center(
                    child: LinearPercentIndicator(
                      width: 90.w,
                      lineHeight: 5.0,
                      percent: double.parse(
                          (PercentageCalculations().calculatePercentageFilled() / 100).toString()),
                      backgroundColor: Colors.grey,
                      progressColor: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  SizedBox(
                    width: 80.w,
                    child: Text(
                      'Please complete your profile to proceed with this feature',
                      style: TextStyle(fontSize: 16.sp),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 12.h,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                  onTap: () {
                    Get.to(GenderSelectScreen());
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: AppColors.primaryAccentColor,
                          borderRadius: BorderRadius.circular(5)),
                      height: 4.5.h,
                      width: 28.w,
                      child: const Center(
                          child: Text(
                        ' PROCEED ',
                        style: TextStyle(color: Colors.white),
                      )))),
            ),
          ],
        ),
      ),
    );
  }
}
