import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/goal_settings/apis/update_weight_api.dart';
import 'package:ihl/views/goal_settings/maintain_weight_goal.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class MaintainWeightScreen extends StatefulWidget {
  final String goalID;
  final bool fromManageHealth;

  const MaintainWeightScreen({Key key, this.goalID, this.fromManageHealth}) : super(key: key);

  @override
  _MaintainWeightScreenState createState() => _MaintainWeightScreenState();
}

class _MaintainWeightScreenState extends State<MaintainWeightScreen> {
  TextEditingController currentWeightController = TextEditingController();
  final key = new GlobalKey();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  double goalDuration = 0.5;
  var _proceedLoading = false.obs;

  void getData() async {
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
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

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
          appBar: AppBar(
            title: const Text('Maintain Weight'),
            elevation: 0,
            centerTitle: true,
          ),
          backgroundColor: AppColors.backgroundScreenColor,
          body: SingleChildScrollView(
            child: Column(children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 5.h, left: 3.w, right: 3.w),
                    height: 12.h,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 18.sp),
                    color: Colors.white,
                    width: double.infinity,
                    child: Text(
                      'Maintain Weight',
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
                padding: const EdgeInsets.all(8.0),
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
                          Icons.arrow_circle_right_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Great! You've chosen to maintain\nyour current weight.",
                            style: TextStyle(
                              color: AppColors.textLiteColor,
                              fontSize: ScUtil().setSp(14),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Gap(1.6.h),
                          Text(
                            "A big shoutout for your dedication!",
                            style: TextStyle(
                              color: AppColors.textLiteColor,
                              fontSize: ScUtil().setSp(11),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gap(2.5.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            fontWeight: FontWeight.w600,
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
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                          ),
                          textStyle: TextStyle(color: Colors.white),
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
                  Gap(2.h),
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Container(
                            width: 32.w,
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
                              controller: currentWeightController,
                              autofocus: true,
                              enabled: true,
                              cursorColor: AppColors.primaryColor,
                              decoration: InputDecoration(
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(top: 13.0.sp),
                                  child: Text(
                                    'Kgs',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18.sp,
                                      // fontWeight:
                                      //     FontWeight.bold,
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
                  ),
                  Gap(20.h),
                  GestureDetector(
                    onTap: !_proceedLoading.value
                        ? () async {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            if (_formKey.currentState.validate()) {
                              ///if weight changed than we update the weight and set the goal otherwise normally set the goal
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              var weight = prefs.get('userLatestWeight').toString();
                              if (currentWeightController.text !=
                                  double.tryParse(weight).toStringAsFixed(2)) {
                                _proceedLoading.value = true;
                                UpdateWeight updateWeightController = UpdateWeight();
                                var isSuccess = await updateWeightController
                                    .updateWeight(currentWeightController.text,false);
                                if (isSuccess) {
                                  _proceedLoading.value = false;
                                  Get.to(MaintainWeightGoalScreen(
                                    fromManageHealth: widget.fromManageHealth,
                                    targetWeight: currentWeightController.text,
                                    goalID: widget.goalID,
                                  ));
                                } else {
                                  _proceedLoading.value = false;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.primaryAccentColor,
                                      content: Text('Failed to update Weight Please try Again...'),
                                    ),
                                  );
                                }
                              } else {
                                Get.to(MaintainWeightGoalScreen(
                                  fromManageHealth: widget.fromManageHealth,
                                  targetWeight: currentWeightController.text,
                                  goalID: widget.goalID,
                                ));
                              }
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
                              SnackBar(
                                backgroundColor: AppColors.greenColor,
                                content: Text('Loading...'),
                              ),
                            );
                          },
                    child: Align(
                      alignment: Alignment.center,
                      child: Obx(() => AnimatedContainer(
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
                                  style: TextStyle(fontSize: 16.sp, color: FitnessAppTheme.white)),
                            ],
                          ))),
                    ),
                  ),
                  Gap(15.h)
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
