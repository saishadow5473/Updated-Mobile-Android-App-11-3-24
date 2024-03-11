import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/healthJournalControllers/getTodayLogController.dart';
import '../../../../painters/backgroundPanter.dart';
import '../../../../utils/ScUtil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../views/goal_settings/apis/update_weight_api.dart';
import '../../../../views/goal_settings/lose_by_activity.dart';
import '../../../../views/goal_settings/lose_by_both.dart';
import '../../../../views/goal_settings/lose_by_diet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class LoseWeightScreen extends StatefulWidget {
  final String goalID;
  final bool fromManageHealth;

  const LoseWeightScreen({Key key, this.goalID, this.fromManageHealth}) : super(key: key);

  @override
  _LoseWeightScreenState createState() => _LoseWeightScreenState();
}

class _LoseWeightScreenState extends State<LoseWeightScreen> {
  final todayLogController = Get.put(TodayLogController());
  TextEditingController currentWeightController = TextEditingController();
  TextEditingController targetWeightController = TextEditingController();
  final key = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  double goalDuration = 0.5;
  RxString goalPlan = 'Diet'.obs;
  RxBool _proceedLoading = false.obs;

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    Map res = jsonDecode(userData);
    var weight = prefs.get('userLatestWeight').toString();
    if (weight == 'null' || weight == null) {
      weight = res['User']['userInputWeightInKG'].toString();
    }
    currentWeightController.text = double.tryParse(weight).toStringAsFixed(2);
  }

// Dart code to get the weight when bmi and height in meters given
  double calculateWeight(double bmi, double height) {
    double weight = bmi * height * height;
    return weight;
  }

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

      return bmi;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    getData();
    if (widget.goalID != '') {
      targetWeightController.text = todayLogController.targetWeight;
    }
    if (targetWeightController.text == '0.0') {
      targetWeightController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var weightInside;
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
          if (_formKey.currentState.validate()) {
          } else {
            _autoValidate = true;
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text('Lose Weight'),
            elevation: 0,
            centerTitle: true,
          ),
          backgroundColor: AppColors.backgroundScreenColor,
          body: Form(
            key: _formKey,
            child: ListView(
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
                        'Lose Weight',
                        style: TextStyle(
                          fontSize: 17.sp,
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
                  3.h,
                ),
                Container(
                  height: 15.h,
                  margin: EdgeInsets.symmetric(horizontal: 12.0.sp),
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
                        child: Center(
                          child: Icon(
                            Icons.arrow_circle_down,
                            size: 25.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 2.sp),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Great choice! You've\nopted to lose weight.",
                              style: TextStyle(
                                color: AppColors.textLiteColor,
                                fontSize: ScUtil().setSp(14),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Gap(1.6.h),
                            Text(
                              "We're excited to witness your transformation.",
                              style: TextStyle(
                                color: AppColors.textLiteColor,
                                fontSize: ScUtil().setSp(10.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(1.h),
                Container(
                  margin: const EdgeInsets.only(left: 25),
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your current weight',
                        style: TextStyle(
                          color: AppColors.textLiteColor,
                          fontSize: 16.sp,
                        ),
                      ),
                      Tooltip(
                        key: key,
                        message: 'Note: The weight displayed here is based on your last update. '
                            'Please enter your recent weight, if any ',
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.all(20),
                        showDuration: const Duration(seconds: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.9),
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                        ),
                        textStyle: const TextStyle(color: Colors.white),
                        preferBelow: true,
                        verticalOffset: 20,
                        child: IconButton(
                          icon: const Icon(Icons.info, color: AppColors.primaryColor),
                          onPressed: () {
                            final dynamic tooltip = key.currentState;
                            tooltip.ensureTooltipVisible();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 32.w,
                        margin: const EdgeInsets.only(left: 25),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Current Weight can't\nbe empty";
                            } else if (double.tryParse(value) == null) {
                              return "Invalid Weight";
                            } else if (double.parse(value) > 200) {
                              return "Max. Weight cannot surpass 200 Kg";
                            } else if (double.parse(value) < 40) {
                              return "Min. Weight is 40 Kgs";
                            }
                            return null;
                          },
                          autofocus: true,
                          enabled: true,
                          controller: currentWeightController,
                          cursorColor: AppColors.primaryColor,
                          decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(top: 13.0.sp),
                              child: Text(
                                'Kgs',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            counterText: '',
                            counterStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 0,
                            ),
                            focusColor: AppColors.primaryColor,
                            enabledBorder: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 18.sp,
                            // fontWeight: FontWeight.bold,
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: false, signed: false),
                          maxLength: 5,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                Gap(2.h),
                Container(
                  margin: const EdgeInsets.only(left: 25),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Your Target weight',
                    style: TextStyle(
                      color: AppColors.textLiteColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                Gap(2.h),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: 33.w,
                    margin: const EdgeInsets.only(left: 25),
                    child: TextFormField(
                      controller: targetWeightController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Target Weight can't\nbe empty";
                        } else if (double.tryParse(value) == null) {
                          return "Invalid Weight";
                        } else if (double.tryParse(currentWeightController.text) == null) {
                          return "Please set current\nweight first!";
                        } else if (double.parse(value) >=
                            double.tryParse(currentWeightController.text)) {
                          return "Invalid Target weight\nto lose.";
                        } else if (double.tryParse(currentWeightController.text) -
                                (double.parse(value)) <
                            1) {
                          return "Invalid Target weight\nto lose.";
                        } else if (double.parse(value) < 45)
                        // (double.parse(currentWeightController
                        //         .text)/2))
                        {
                          return "Min. Weight is 45 Kgs";
                          // "${(double.parse(currentWeightController
                          //       .text)/2).toStringAsFixed(0)} Kgs";
                        }
                        return null;
                      },
                      cursorColor: AppColors.primaryColor,
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(top: 13.0.sp),
                          child: Text(
                            'Kgs',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        hintText: '00.00',
                        hintStyle: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18.sp,
                          // fontWeight: FontWeight.bold,
                        ),
                        counterText: '',
                        counterStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 0,
                        ),
                        enabled: true,
                        focusColor: AppColors.primaryColor,
                        enabledBorder: InputBorder.none,
                      ),
                      style: TextStyle(color: AppColors.primaryColor, fontSize: 18.sp),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                    ),
                  ),
                ),
                Gap(2.h),
                Container(
                  margin: const EdgeInsets.only(left: 25),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Choose your plan',
                    style: TextStyle(
                      color: AppColors.textLiteColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                Gap(0.5.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Obx(() => DropdownButton<String>(
                        focusColor: Colors.white,
                        value: goalPlan.value,
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
                        items: <String>['Diet', 'Exercise', 'Both Diet and Exercise']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: AppColors.textLiteColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        hint: const Text(
                          "Select goal plan",
                          style: TextStyle(
                              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        onChanged: (String value) {
                          goalPlan.value = value;
                        },
                      )),
                ),
                Gap(5.h),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: !_proceedLoading.value
                        ? () async {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            if (_formKey.currentState.validate()) {
                              ///if weight changed than we update the weight and set the goal otherwise normally set the goal
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              var userData = prefs.get('data');
                              Map res = jsonDecode(userData);
                              print(res['User']['userInputWeightInKG'].toString());
                              if (weightInside == null) {
                                weightInside = res['User']['userInputWeightInKG'].toString();
                              } else {
                                weightInside = prefs.get('userLatestWeight').toString();
                              }
                              if (currentWeightController.text !=
                                  double.tryParse(weightInside).toStringAsFixed(2)) {
                                _proceedLoading.value = true;

                                UpdateWeight updateWeightController = UpdateWeight();
                                var isSuccess = await updateWeightController
                                    .updateWeight(currentWeightController.text,false);
                                if (isSuccess) {
                                  _proceedLoading.value = false;

                                  proceed();
                                } else {
                                  _proceedLoading.value = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppColors.primaryAccentColor,
                                      content: Text('Failed to update Weight Please try Again...'),
                                    ),
                                  );
                                }
                              } else {
                                proceed();
                              }
                            } else {
                              _autoValidate = true;
                            }
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.primaryColor,
                                content: Text('Loading...'),
                              ),
                            );
                          },
                    child: Obx(
                      () => AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: !_proceedLoading.value ? 28.w : 35.w,
                          height: _proceedLoading.isTrue ? 5.5.h : 5.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(10.sp)),
                          child: Row(
                              mainAxisAlignment: _proceedLoading.isTrue
                                  ? MainAxisAlignment.spaceEvenly
                                  : MainAxisAlignment.center,
                              children: [
                                _proceedLoading.isTrue
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(vertical: 11.sp),
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                Text(!_proceedLoading.value ? 'Continue' : 'Loading',
                                    style:
                                        TextStyle(fontSize: 16.sp, color: FitnessAppTheme.white)),
                              ])),
                    ),
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

  void proceed() {
    if (goalPlan == 'Diet') {
      Get.to(LoseWeightByDietScreen(
          fromManageHealth: widget.fromManageHealth,
          targetWeight: targetWeightController.text,
          currentWeight: currentWeightController.text,
          goalID: widget.goalID));
    } else if (goalPlan == 'Exercise') {
      Get.to(LoseWeightByActivityScreen(
          fromManageHealth: widget.fromManageHealth,
          targetWeight: targetWeightController.text,
          currentWeight: currentWeightController.text,
          goalID: widget.goalID));
    } else {
      Get.to(LoseWeightByBothScreen(
          fromManageHealth: widget.fromManageHealth,
          targetWeight: targetWeightController.text,
          currentWeight: currentWeightController.text,
          goalID: widget.goalID));
    }
  }
}
