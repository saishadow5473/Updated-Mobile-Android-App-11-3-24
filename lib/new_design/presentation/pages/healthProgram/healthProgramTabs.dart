import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../cardio_dashboard/views/cardio_dashboard_new.dart';
import '../../../../utils/SpUtil.dart';
import '../../../../views/goal_settings/apis/goal_apis.dart';
import '../../../../views/goal_settings/goal_setting_screen.dart';
import '../../../app/utils/appColors.dart';
import '../../../app/utils/constLists.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../../app/utils/textStyle.dart';
import '../../Widgets/appBar.dart';
import '../../controllers/healthJournalControllers/getTodayLogController.dart';
import '../../controllers/healthProgramControllers/healthProgramController.dart';
import '../dashboard/common_screen_for_navigation.dart';
import 'myGoalScreen.dart';

class HealthProgramTabs extends StatelessWidget {
  final bool fromDashboard;

  HealthProgramTabs({
    this.fromDashboard,
  });

  final HealthProgramController _healthProgramController = Get.put(HealthProgramController());

  Future<Map> sendDataToAPI(String goalID) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    return {"ihl_user_id": iHLUserId, "goal_id": goalID, "goal_status": "inactive"};
  }

  @override
  Widget build(BuildContext context) {
    bool aff = SpUtil.getBool(LSKeys.affiliation) ?? false;
    _healthProgramController.controller.index = 0;
    if (fromDashboard) {
      _healthProgramController.controller.index = 1;
    }
    return WillPopScope(
        onWillPop: () {
          return null;
        },
        child: CommonScreenForNavigation(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarOpacity: 0,
            toolbarHeight: 7.5.h,
            flexibleSpace: const CustomeAppBar(screen: ProgramLists.vitalsList),
            backgroundColor: Colors.white,
            elevation: aff ?? false ? 0 : 0,
            shadowColor: AppColors.unSelectedColor,
          ),
          content: Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: 0.4.h),
            height: 100.h,
            width: 100.w,
            child: DefaultTabController(
              length: 2,
              animationDuration: const Duration(milliseconds: 500),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        spreadRadius: 3,
                        color: Colors.grey.shade400,
                        offset: const Offset(1, 1),
                      )
                    ]),
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 2),
                        child: Text(
                          "Health Programs",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.sp),
                      GetBuilder<HealthProgramController>(
                          id: 'tabbar',
                          init: HealthProgramController(),
                          builder: (_) {
                            return SizedBox(
                              height: 16.w,
                              width: 100.w,
                              child: TabBar(
                                controller: _healthProgramController.controller,
                                indicatorColor: const Color(0XFF61C6E7),
                                indicatorWeight: 4,
                                labelPadding: EdgeInsets.symmetric(horizontal: 3.w),
                                isScrollable: true,
                                indicatorPadding: EdgeInsets.zero,
                                onTap: (int value) {
                                  if (value == 2) {
                                    _healthProgramController.controller.index =
                                        _.controller.previousIndex;
                                  }
                                },
                                tabs: [
                                  Tab(
                                    height: 9.h,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 10.w,
                                          width: 10.w,
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 3,
                                                spreadRadius: 3,
                                                color: Colors.grey.shade200,
                                                offset: const Offset(1, 1),
                                              )
                                            ],
                                            color: _.selectedIndex == 0
                                                ? const Color(0XFF61C6E7)
                                                : Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset("newAssets/Icons/Heart Health.png"),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Heart Health",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12.4.sp,
                                              color: _.selectedIndex == 0
                                                  ? const Color(0XFF61C6E7)
                                                  : Colors.black,
                                              fontWeight:
                                                  _.selectedIndex == 0 ? FontWeight.bold : null,
                                              letterSpacing: 0.4),
                                        )
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    height: 9.h,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 10.w,
                                          width: 10.w,
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                              color: _.selectedIndex == 1
                                                  ? const Color(0XFF61C6E7)
                                                  : Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 3,
                                                  spreadRadius: 3,
                                                  color: Colors.grey.shade200,
                                                  offset: const Offset(1, 1),
                                                )
                                              ]),
                                          child:
                                              Image.asset("newAssets/Icons/Weight Management.png"),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Weight Management",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12.4.sp,
                                              color: _.selectedIndex == 1
                                                  ? const Color(0XFF61C6E7)
                                                  : Colors.black,
                                              fontWeight:
                                                  _.selectedIndex == 1 ? FontWeight.bold : null,
                                              letterSpacing: 0.4),
                                        )
                                      ],
                                    ),
                                  ),
                                  //Unslash for Step counter 🥥
                                  Tab(
                                    height: 9.h,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 10.w,
                                          width: 10.w,
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                              color: _.selectedIndex == 2
                                                  ? const Color(0XFF61C6E7)
                                                  : Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 3,
                                                  spreadRadius: 3,
                                                  color: Colors.grey.shade200,
                                                  offset: const Offset(1, 1),
                                                )
                                              ]),
                                          child:
                                              Image.asset("newAssets/Icons/Diabetes.png"),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Diabetics Health",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12.4.sp,
                                              color: Colors.grey,
                                              fontWeight:
                                                  _.selectedIndex == 2 ? FontWeight.bold : null,
                                              letterSpacing: 0.4),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ])),
                Expanded(
                  child: TabBarView(
                    controller: _healthProgramController.controller,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      CardioDashboardNew(cond: true, tabView: true),
                      setGoalTab(false),
                      if (!Tabss.featureSettings.myVitals)
                        const Center(child: Text("No Diabetics Health Available !"))
                      else
                        Container(
                          height: 20.h,
                          color: Colors.purple,
                          alignment: Alignment.center,
                          child: const Text('Third'),
                        ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ));
  }
}

Widget setGoalTab(bool fromManageHealth) {
  final HealthProgramController _healthProgramController = Get.put(HealthProgramController());
  Future<Map> sendDataToAPI(String goalID) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    return {"ihl_user_id": iHLUserId, "goal_id": goalID, "goal_status": "inactive"};
  }

  if (!Tabss.featureSettings.setYourGoals) {
    return const Center(child: Text("Set Your Goals is Not Available"));
  } else {
    return Container(
      color: AppColors.backgroundScreenColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 1.2.h),
            Padding(
              padding: EdgeInsets.only(left: 3.w),
              child: Text(
                "Weight Management",
                style: AppTextStyles.primaryColorText,
              ),
            ),
            SizedBox(height: 1.2.h),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 12.sp),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(0, 1),
                        color: Colors.grey.shade400,
                        blurRadius: 3,
                        spreadRadius: 2),
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/icons/weightloss_image.jpg'),
                    Padding(
                      padding: EdgeInsets.only(left: 2.2.w, right: 2.2.w, top: 2.2.h),
                      child: Text(
                        "What is weight management program?",
                        textAlign: TextAlign.left,
                        style: AppTextStyles.boldContnet,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 2.2.w, right: 2.2.w, top: 0.5.h),
                      child: Text(
                        "A weight management program is a structured plan aimed at helping individuals achieve and maintain a healthy body weight.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          height: 0.2.h,
                          fontFamily: 'Poppins',
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 2.2.w, right: 2.2.w, top: 1.4.h),
                      child: Text(
                        "Why should I join?",
                        textAlign: TextAlign.left,
                        style: AppTextStyles.boldContnet,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 2.2.w, right: 2.2.w, top: 0.8.h),
                      child: Text(
                        "Balancing your diet with regular exercise is the key to a healthier you. Customize your plan to suit your individual goals and needs.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          height: 0.2.h,
                          fontFamily: 'Poppins',
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 3.5.h),
                      child: Obx(() => ElevatedButton(
                            onPressed: _healthProgramController.goalLists.isEmpty
                                ? () => Get.to(MyGoalScreen(fromManageHealth: fromManageHealth))
                                : null,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _healthProgramController.goalLists.isEmpty
                                    ? Colors.blue
                                    : Colors.grey,
                                minimumSize: Size(26.w, 4.5.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.sp))),
                            child: Text(
                              'GET STARTED',
                              style: TextStyle(fontSize: 16.5.sp),
                            ),
                          )),
                    ),
                  ],
                )),
            Obx(() => Visibility(
                  replacement: SizedBox(),
                  visible: _healthProgramController.goalLists.isNotEmpty,
                  child: _healthProgramController.goalLists.isEmpty
                      ? SizedBox(
                          width: 100.w,
                          height: 20.h,
                          child: Padding(
                            padding: EdgeInsets.all(12.sp),
                            child: Shimmer.fromColors(
                                direction: ShimmerDirection.ltr,
                                period: const Duration(seconds: 2),
                                baseColor: const Color.fromARGB(255, 240, 240, 240),
                                highlightColor: Colors.grey.withOpacity(0.2),
                                child: Container(
                                    height: 18.h,
                                    width: 97.w,
                                    padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Text('Data Loading'))),
                          ))
                      : Container(
                          decoration: BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                                offset: const Offset(0, 1),
                                color: Colors.grey.shade400,
                                blurRadius: 3,
                                spreadRadius: 2),
                          ]),
                          margin: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 12.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 2.w, top: 1.5.h),
                                child: GestureDetector(
                                  onTap: () => _healthProgramController.getGoalData(),
                                  child: Text(
                                    "Your Active Goal",
                                    textAlign: TextAlign.left,
                                    style: AppTextStyles.boldContnet,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2.2.w, top: 1.h, right: 2.2.w),
                                child: Text(
                                  "Review your past weight goals to track your weight management journey.",
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    height: 0.2.h,
                                    fontFamily: 'Poppins',
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                  itemCount: _healthProgramController.goalLists.length,
                                  shrinkWrap: true,
                                  itemBuilder: (ctx, i) {
                                    var _item = _healthProgramController.goalLists[i];
                                    return Container(
                                        height: 17.5.h,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 10.sp, vertical: 2.h),
                                        padding: EdgeInsets.symmetric(vertical: 1.2.h),
                                        decoration: BoxDecoration(color: Colors.white, boxShadow: [
                                          BoxShadow(
                                              offset: const Offset(0, 2),
                                              color: Colors.grey.shade300,
                                              blurRadius: 3,
                                              spreadRadius: 2),
                                        ]),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: Icon(
                                                  goalType(_item['weight'],
                                                              _item['target_weight']) ==
                                                          'Lose Weight'
                                                      ? Icons.trending_down_rounded
                                                      : goalType(_item['weight'],
                                                                  _item['target_weight']) ==
                                                              'Gain Weight'
                                                          ? Icons.trending_up_rounded
                                                          : Icons.trending_neutral_rounded,
                                                  color: AppColors.primaryColor,
                                                  size: 29.sp),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  goalType(_item['weight'], _item['target_weight']),
                                                  style: TextStyle(fontSize: 16.sp),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${_item['weight']} Kgs   ',
                                                      style: TextStyle(fontSize: 16.sp),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_right_alt_sharp,
                                                      color: AppColors.primaryAccentColor,
                                                      size: 22.sp,
                                                    ),
                                                    Text(
                                                      '   ${_item['target_weight']} Kgs',
                                                      style: TextStyle(fontSize: 16.sp),
                                                    )
                                                  ],
                                                ),
                                                Text(
                                                  'Daily Intake - ${_item['target_calorie'] ?? 'NA'} Cal',
                                                  style: TextStyle(fontSize: 16.sp),
                                                ),
                                                Visibility(
                                                  visible: (_item['goal_type'] == 'lose_weight' ||
                                                      _item['goal_type'] == 'gain_weight'),
                                                  child: Text(
                                                    '${_item['goal_date'] != '' || _item['goal_date'] != null ? 'By ${_item['goal_date'] ?? '-'}' : ''}',
                                                    style: TextStyle(fontSize: 16.sp),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                AwesomeDialog(
                                                    context: Get.context,
                                                    animType: AnimType.TOPSLIDE,
                                                    headerAnimationLoop: true,
                                                    dialogType: DialogType.WARNING,
                                                    dismissOnTouchOutside: true,
                                                    title: 'Confirm ?',
                                                    desc: 'This action will delete your Goal',
                                                    btnOkOnPress: () async {
                                                      SharedPreferences prefs =
                                                          await SharedPreferences.getInstance();
                                                      Get.snackbar('Goal deleted!',
                                                          'Your current goal has been deleted.',
                                                          icon: const Padding(
                                                              padding: EdgeInsets.all(8.0),
                                                              child: Icon(
                                                                  Icons.check_circle_outline,
                                                                  color: Colors.white)),
                                                          margin: const EdgeInsets.all(16)
                                                              .copyWith(bottom: 40),
                                                          backgroundColor: Colors.blue,
                                                          colorText: Colors.white,
                                                          duration: const Duration(seconds: 5),
                                                          snackPosition: SnackPosition.BOTTOM);
                                                      var goalData =
                                                          await sendDataToAPI(_item['goal_id']);
                                                      GoalApis.editGoal(goalData).then((value) {
                                                        if (value != null) {
                                                          prefs.setBool('maintain_weight', true);
                                                          prefs.remove('daily_target');
                                                          _healthProgramController.goalLists
                                                              .removeAt(i);

                                                          try {
                                                            Get.find<TodayLogController>().onInit();
                                                          } catch (e) {
                                                            Get.put(TodayLogController());
                                                          }
                                                        } else {
                                                          Get.snackbar('Goal not deleted!',
                                                              'Encountered some error. Please try again',
                                                              icon: const Padding(
                                                                  padding: EdgeInsets.all(8.0),
                                                                  child: Icon(Icons.cancel_outlined,
                                                                      color: Colors.white)),
                                                              margin: const EdgeInsets.all(16)
                                                                  .copyWith(bottom: 40),
                                                              backgroundColor: Colors.redAccent,
                                                              colorText: Colors.white,
                                                              duration: const Duration(seconds: 5),
                                                              snackPosition: SnackPosition.BOTTOM);
                                                        }
                                                      });
                                                      print('delete goal');
                                                    },
                                                    btnCancelOnPress: () {},
                                                    buttonsTextStyle: const TextStyle().copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.normal),
                                                    btnCancelText: 'Go Back',
                                                    btnOkText: 'Confirm',
                                                    btnCancelColor: Colors.green,
                                                    btnOkColor: Colors.red,
                                                    // btnOkIcon: Icons.check_circle,
                                                    // btnCancelIcon: Icons.check_circle,
                                                    onDismissCallback: (_) {
                                                      debugPrint('Dialog Dissmiss from callback');
                                                    }).show();
                                              },
                                              child: const Icon(
                                                Icons.delete,
                                                size: 23,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => Get.to(GoalSettingScreen(
                                                  goalId: _item['goal_id'],
                                                  goalType: _item['goal_type'])),
                                              child: const Icon(
                                                Icons.edit,
                                                size: 23,
                                                color: AppColors.primaryColor,
                                              ),
                                            )
                                          ],
                                        ));
                                  })
                            ],
                          ),
                        ),
                )),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

String goalType(String currentWeight, String targetWeight) {
  if (double.tryParse(currentWeight) > double.tryParse(targetWeight)) {
    return 'Lose Weight';
  } else if (double.tryParse(currentWeight) < double.tryParse(targetWeight)) {
    return 'Gain Weight';
  } else {
    return 'Maintain Weight';
  }
}

class setGoalTabs extends StatelessWidget {
  setGoalTabs({Key key}) : super(key: key);
  final HealthProgramController _healthProgramController = Get.put(HealthProgramController());

  Future<Map> sendDataToAPI(String goalID) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    return {"ihl_user_id": iHLUserId, "goal_id": goalID, "goal_status": "inactive"};
  }

  String goalType(String currentWeight, String targetWeight) {
    if (double.tryParse(currentWeight) > double.tryParse(targetWeight)) {
      return 'Lose Weight';
    } else if (double.tryParse(currentWeight) < double.tryParse(targetWeight)) {
      return 'Gain Weight';
    } else {
      return 'Maintain Weight';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundScreenColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 1.2.h),
            Padding(
              padding: EdgeInsets.only(left: 3.w),
              child: Text(
                "Weight Management",
                style: AppTextStyles.primaryColorText,
              ),
            ),
            SizedBox(height: 1.2.h),
            Padding(
              padding: EdgeInsets.only(left: 3.w, right: 3.w),
              child: Text(
                "Set your weight goals: Choose to either gain, lose, or maintain for a healthier lifestyle.",
                textAlign: TextAlign.justify,
                style: AppTextStyles.regularFont2,
              ),
            ),
            SizedBox(height: 2.3.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp),
              child: Image.asset('assets/icons/weightloss_image.jpg'),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              child: Obx(() => ElevatedButton(
                    onPressed: _healthProgramController.goalLists.isEmpty
                        ? () => Get.to(MyGoalScreen(fromManageHealth: false))
                        : null,
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(28.w, 5.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.sp))),
                    child: Text(
                      'SET NOW',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  )),
            ),
            Obx(() => Visibility(
                  visible: _healthProgramController.goalLists.isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 3.w),
                        child: GestureDetector(
                          onTap: () => _healthProgramController.getGoalData(),
                          child: Text(
                            'Your Active Goal',
                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 17.sp),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 3.w, right: 3.w, top: 1.h),
                        child: Text(
                          "Review your past weight goals to track your weight management journey.",
                          textAlign: TextAlign.justify,
                          style: AppTextStyles.regularFont2,
                        ),
                      ),
                      ListView.builder(
                          itemCount: _healthProgramController.goalLists.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext ctx, int i) {
                            var _item = _healthProgramController.goalLists[i];
                            return Container(
                                height: 16.h,
                                margin: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 2.h),
                                padding: EdgeInsets.symmetric(vertical: 1.2.h),
                                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                                  BoxShadow(
                                      offset: const Offset(0, 2),
                                      color: Colors.grey.shade300,
                                      blurRadius: 3,
                                      spreadRadius: 2),
                                ]),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Icon(
                                          goalType(_item['weight'], _item['target_weight']) ==
                                                  'Lose Weight'
                                              ? Icons.trending_down_rounded
                                              : goalType(_item['weight'], _item['target_weight']) ==
                                                      'Gain Weight'
                                                  ? Icons.trending_up_rounded
                                                  : Icons.trending_neutral_rounded,
                                          color: AppColors.primaryColor,
                                          size: 35.sp),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(goalType(_item['weight'], _item['target_weight'])),
                                        Row(
                                          children: [
                                            Text('${_item['weight']} Kgs   '),
                                            Icon(
                                              Icons.arrow_right_alt_sharp,
                                              color: AppColors.primaryAccentColor,
                                              size: 22.sp,
                                            ),
                                            Text('   ${_item['target_weight']} Kgs')
                                          ],
                                        ),
                                        Text(
                                            'Daily Intake - ${_item['target_calorie'] ?? 'NA'} Cal'),
                                        Visibility(
                                          visible: _item['target_weight'] == 'Lose Weight',
                                          child: Text(
                                              _item['goal_date'] != '' || _item['goal_date'] != null
                                                  ? 'By ${_item['goal_date'] ?? '-'}'
                                                  : ''),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        AwesomeDialog(
                                            context: Get.context,
                                            animType: AnimType.TOPSLIDE,
                                            headerAnimationLoop: true,
                                            dialogType: DialogType.WARNING,
                                            dismissOnTouchOutside: true,
                                            title: 'Confirm ?',
                                            desc: 'This action will delete your Goal',
                                            btnOkOnPress: () async {
                                              SharedPreferences prefs =
                                                  await SharedPreferences.getInstance();
                                              Get.snackbar('Goal deleted!',
                                                  'Your current goal has been deleted.',
                                                  icon: const Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: Icon(Icons.check_circle_outline,
                                                          color: Colors.white)),
                                                  margin:
                                                      const EdgeInsets.all(20).copyWith(bottom: 40),
                                                  backgroundColor: Colors.blue,
                                                  colorText: Colors.white,
                                                  duration: const Duration(seconds: 5),
                                                  snackPosition: SnackPosition.BOTTOM);
                                              Map goalData = await sendDataToAPI(_item['goal_id']);
                                              GoalApis.editGoal(goalData).then((value) {
                                                if (value != null) {
                                                  prefs.setBool('maintain_weight', true);
                                                  prefs.remove('daily_target');
                                                  _healthProgramController.goalLists.removeAt(i);

                                                  try {
                                                    Get.find<TodayLogController>().onInit();
                                                  } catch (e) {
                                                    Get.put(TodayLogController());
                                                  }
                                                } else {
                                                  Get.snackbar('Goal not deleted!',
                                                      'Encountered some error. Please try again',
                                                      icon: const Padding(
                                                          padding: EdgeInsets.all(8.0),
                                                          child: Icon(Icons.cancel_outlined,
                                                              color: Colors.white)),
                                                      margin: const EdgeInsets.all(20)
                                                          .copyWith(bottom: 40),
                                                      backgroundColor: Colors.redAccent,
                                                      colorText: Colors.white,
                                                      duration: const Duration(seconds: 5),
                                                      snackPosition: SnackPosition.BOTTOM);
                                                }
                                              });
                                              print('delete goal');
                                            },
                                            btnCancelOnPress: () {},
                                            buttonsTextStyle: const TextStyle().copyWith(
                                                color: Colors.white, fontWeight: FontWeight.normal),
                                            btnCancelText: 'Go Back',
                                            btnOkText: 'Confirm',
                                            btnCancelColor: Colors.green,
                                            btnOkColor: Colors.red,
                                            // btnOkIcon: Icons.check_circle,
                                            // btnCancelIcon: Icons.check_circle,
                                            onDismissCallback: (_) {
                                              debugPrint('Dialog Dissmiss from callback');
                                            }).show();
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Get.to(GoalSettingScreen(
                                          goalId: _item['goal_id'], goalType: _item['goal_type'])),
                                      child: const Icon(
                                        Icons.edit,
                                        color: AppColors.primaryColor,
                                      ),
                                    )
                                  ],
                                ));
                          })
                    ],
                  ),
                )),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
