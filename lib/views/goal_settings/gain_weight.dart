import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/goal_settings/apis/update_weight_api.dart';
import 'package:ihl/views/goal_settings/gain_weight_goal.dart';
import 'package:ihl/widgets/goalSetting/resuable_alert_box.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../new_design/presentation/controllers/healthJournalControllers/getTodayLogController.dart';

class GainWeightScreen extends StatefulWidget {
  final String goalID;
  final bool fromManageHealth;

  const GainWeightScreen({Key key, this.goalID, this.fromManageHealth}) : super(key: key);

  @override
  _GainWeightScreenState createState() => _GainWeightScreenState();
}

class _GainWeightScreenState extends State<GainWeightScreen> {
  final todayLogController = Get.put(TodayLogController());
  TextEditingController currentWeightController = TextEditingController();
  TextEditingController targetWeightController = TextEditingController();
  final key = new GlobalKey();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  double goalDuration = 0.5;
  String goalPlan = 'Diet';
  var goalCaloriesIntake = '0';
  var _proceedLoading = false;

  void dailyTarget(String weight) async {
    var height;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // StreamingSharedPreferences.instance.then((value) {
    //   setState(() {
    //     preferences = value;
    //   });
    // });
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
    // calcBmi(height: height, weight: weight);
    var m = res['User']['gender'];
    num maleBmr =
        (10 * double.parse(weight.toString()) + 6.25 * double.parse(height) - (5 * age) + 5);
    num femaleBmr = (10 * double.parse(weight) + 6.25 * double.parse(height) - (5 * age) - 161);
    if (m == 'm' || m == 'M' || m == 'male' || m == 'Male') {
      if (mounted)
        setState(() {
          goalCaloriesIntake = maleBmr.toStringAsFixed(0);
        });
    } else {
      if (mounted)
        setState(() {
          goalCaloriesIntake = femaleBmr.toStringAsFixed(0);
        });
    }
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    Map res = jsonDecode(userData);
    var weight = prefs.get('userLatestWeight').toString();
    if (weight == 'null' || weight == null) {
      weight = res['User']['userInputWeightInKG'].toString();
    }
    setState(() {
      currentWeightController.text = double.tryParse(weight).toStringAsFixed(2);
    });
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var height = await prefs.get('userLatestHeight').toString();
    // var weight = await prefs.get('userLatestWeight').toString();
    // setState(() {
    //   currentWeightController.text = double.tryParse(weight).toStringAsFixed(2);
    // });
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
    if (widget.goalID != "") {
      targetWeightController.text = todayLogController.targetWeight;
    } else if (targetWeightController.text == '0.0') {
      targetWeightController = null;
    }
  }

  bool isAgree = false;

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
            if (mounted) {
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
            title: const Text('Gain Weight'),
            elevation: 0,
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                          'Gain Weight',
                          style: TextStyle(
                            fontSize: 16.sp,
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
                              Icons.arrow_circle_up_rounded,
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
                              "Wonderful! You've chosen\nto gain weight.",
                              style: TextStyle(
                                color: AppColors.textLiteColor,
                                fontSize: ScUtil().setSp(14),
                              ),
                            ),
                            Gap(1.6.h),
                            Text(
                              "We're eager to see your progress.",
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
                  Gap(1.h),
                  Container(
                    margin: EdgeInsets.only(left: 25),
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
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.all(20),
                          showDuration: Duration(seconds: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.9),
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                          ),
                          textStyle: TextStyle(color: Colors.white),
                          preferBelow: true,
                          verticalOffset: 20,
                          child: IconButton(
                            icon: Icon(Icons.info, color: AppColors.primaryColor),
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
                          width: 33.w,
                          margin: EdgeInsets.only(left: 25),
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
                              counterStyle: TextStyle(
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
                                TextInputType.numberWithOptions(decimal: false, signed: false),
                            maxLength: 5,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                  Gap(2.h),
                  Container(
                    margin: EdgeInsets.only(left: 25),
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
                    child: Row(
                      children: [
                        Container(
                          width: 33.w,
                          margin: EdgeInsets.only(left: 25),
                          child: TextFormField(
                            controller: targetWeightController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Target Weight can't\nbe empty";
                              } else if (double.tryParse(value) == null) {
                                return "Invalid Weight";
                              } else if (double.tryParse(currentWeightController.text) == null) {
                                return "Please set current\nweight first!";
                              } else if (double.parse(value) <=
                                  double.tryParse(currentWeightController.text)) {
                                return "Invalid Target weight\nto gain.";
                              } else if (double.tryParse(currentWeightController.text) -
                                      (double.parse(value)) >
                                  1) {
                                return "Invalid Target weight\nto gain.";
                              } else if ((double.tryParse(currentWeightController.text) * 2) <
                                  double.parse(value)) {
                                return "Max. Weight is ${(double.tryParse(currentWeightController.text) * 2).toStringAsFixed(0)} Kgs";
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
                              counterStyle: TextStyle(
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
                      ],
                    ),
                  ),
                  Gap(2.h),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                        onTap: !_proceedLoading
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
                                    setState(() {
                                      _proceedLoading = true;
                                    });
                                    UpdateWeight updateWeightController = UpdateWeight();
                                    var isSuccess = await updateWeightController
                                        .updateWeight(currentWeightController.text,false);
                                    if (isSuccess) {
                                      setState(() {
                                        _proceedLoading = false;
                                      });
                                      proceed();
                                    } else {
                                      setState(() {
                                        _proceedLoading = false;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: AppColors.primaryAccentColor,
                                          content:
                                              Text('Failed to update Weight Please try Again...'),
                                        ),
                                      );
                                    }
                                  } else {
                                    proceed();
                                  }

                                  // Get.to(GainWeightGoalScreen(
                                  //     currentWeight: currentWeightController.text,
                                  //     targetWeight: targetWeightController.text,
                                  //     goalID: widget.goalID));
                                } else {
                                  if (this.mounted) {
                                    setState(() {
                                      _autoValidate = true;
                                    });
                                  }
                                }
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: AppColors.greenColor,
                                    content: Text('Loading...'),
                                  ),
                                );
                              },
                        child: AnimatedContainer(
                            width: !_proceedLoading ? 28.w : 35.w,
                            height: _proceedLoading ? 5.5.h : 5.h,
                            duration: const Duration(milliseconds: 500),
                            margin: EdgeInsets.only(top: 3.h),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(10.sp)),
                            child: Row(
                              mainAxisAlignment: _proceedLoading
                                  ? MainAxisAlignment.spaceEvenly
                                  : MainAxisAlignment.center,
                              children: [
                                _proceedLoading
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(vertical: 11.sp),
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                Text(!_proceedLoading ? 'Continue' : 'Loading',
                                    style:
                                        TextStyle(fontSize: 16.sp, color: FitnessAppTheme.white)),
                              ],
                            ))),
                  ),
                  Gap(10.h)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  proceed() async {
    await dailyTarget(targetWeightController.text);
    if (int.parse(goalCaloriesIntake) > 100 && int.parse(goalCaloriesIntake) < 500) {
      //allow and alert min.
      alertBox('Strict Minimum Calorie', Colors.amber, true);
    } else if (int.parse(goalCaloriesIntake) > 2000 && int.parse(goalCaloriesIntake) < 3000) {
      //allow and alert max
      alertBox('Strict Maximum Calorie', Colors.amber, true);
    } else if (int.parse(goalCaloriesIntake) > 3000) {
      //impossible
      alertBox(
          '${int.parse(goalCaloriesIntake)} calorie is more than recommended calorie per day !!!',
          Colors.red,
          false);
    } else if (int.parse(goalCaloriesIntake) < 100) {
      //impossible
      alertBox(
          '${int.parse(goalCaloriesIntake)} calorie is less than recommended calorie per day !!!',
          Colors.red,
          false);
    } else {
      //simply allow
      Get.to(GainWeightGoalScreen(
          fromManageHealth: widget.fromManageHealth,
          currentWeight: currentWeightController.text,
          targetWeight: targetWeightController.text,
          goalID: widget.goalID));
    }
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
            Get.to(GainWeightGoalScreen(
                fromManageHealth: widget.fromManageHealth,
                currentWeight: currentWeightController.text,
                targetWeight: targetWeightController.text,
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
}
