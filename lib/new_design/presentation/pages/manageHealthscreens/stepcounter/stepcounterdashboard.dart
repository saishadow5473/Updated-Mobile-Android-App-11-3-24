import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../app/utils/appColors.dart';
import '../../../../app/utils/textStyle.dart';
import '../../../Widgets/appBar.dart';
import '../../../controllers/managehealth/stepcounter/googleFitStepController.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../Widgets/manageHealthWidgets/last7DaysChartWidget.dart';
import '../../../controllers/dashboardControllers/upComingDetailsController.dart';
import 'stepCounterCalendart.dart';
import 'stepcounterSubDashboard.dart';

class StepCounterMainDashboard extends StatelessWidget {
  final List _types = ['Duration', 'Calories', 'Distance'];
  final List<Map> _xData = [{}];
  TextStyle style = TextStyle(fontSize: 15.sp);
  TextStyle todayProgressText = TextStyle(fontSize: 15.sp);
  TextStyle googleFitTextStyle =
      TextStyle(fontWeight: FontWeight.w800, fontSize: 18.sp, color: Colors.grey[700]);
  final GoogleFitStepController stepController = Get.put(GoogleFitStepController());
  ValueNotifier<int> selectedSteps = ValueNotifier<int>(0);

  void triggerVariableAfterDelay() async {
    await Future.delayed(Duration(seconds: 1));
    stepController.todaySteps.refresh();
    selectedSteps.value = stepController.todaySteps.value;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Map> days = [
      {"day": "S", "value": 100},
      {"day": "M", "value": 200},
      {"day": "T", "value": 300},
      {"day": "W", "value": 400},
      {"day": "T", "value": 500},
      {"day": "F", "value": 600},
      {"day": "S", "value": 700},
    ];
    if (!Tabss.featureSettings.stepCounter) {
      return const Center(child: Text("No Step Tracker Available"));
    } else {
      return Container(
        color: AppColors.backgroundScreenColor,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.5.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: .4.h,
              ),
              Text(
                'Step Tracker',
                style: AppTextStyles.HealthChallengeTitle,
              ),
              SizedBox(
                height: 1.h,
              ),
              const Text(
                " Easily view your daily step count! A convenient glance at today's steps.",
                style: TextStyle(
                  color: Color(0xff585859),
                ),
              ),
              // TextButton(onPressed: () => Get.to(MapPage()), child: Text('Map Screen')),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 0.5.w),
                child: Image.asset('assets/images/onGoingRun.png'),
              ),
              Text(
                "Today's Progress",
                style: TextStyle(
                  fontSize: 17.sp,
                  color: const Color(0xff585859),
                ),
              ),
              GestureDetector(
                onTap: () {
                  print(stepController.weeklyChartLoaded);
                  print(stepController.fitConnected.isTrue);
                  if (stepController.fitConnected.isTrue && !stepController.weeklyChartLoaded) {
                    if (stepController.todaySteps.toDouble() > 0) {
                      Get.to(StepCounterSubDashboard(), transition: Transition.cupertino);
                    }
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 1.2.h),
                  height: 15.h,
                  color: AppColors.homeCardColor2,
                  alignment: Alignment.center,
                  child: GetBuilder<GoogleFitStepController>(
                      id: 'chartdata',
                      initState: (_) {
                        // if (stepController.fitConnected.isTrue) {
                        //   stepController.fetchLastSevenDaysSteps();
                        //   stepController.fetchPreviousActivity();
                        // }
                      },
                      builder: (_) {
                        return _.fitConnected.isTrue && _.weeklyChartLoaded
                            ? Shimmer.fromColors(
                                direction: ShimmerDirection.ltr,
                                period: const Duration(seconds: 2),
                                baseColor: const Color.fromARGB(255, 240, 240, 240),
                                highlightColor: Colors.grey.withOpacity(0.2),
                                child: Container(
                                    height: 15.h,
                                    width: 92.5.w,
                                    color: Colors.white,
                                    alignment: Alignment.center,
                                    child: const Text('Hello')))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Stack(
                                    children: [
                                      SizedBox(
                                        height: 40.h,
                                        width: 30.w,
                                        child: Obx(() => SfRadialGauge(
                                              axes: [
                                                RadialAxis(
                                                  showLabels: false,
                                                  showTicks: false,
                                                  startAngle: 170,
                                                  endAngle: 10,
                                                  radiusFactor: 1.08,
                                                  maximum: 10000,
                                                  canScaleToFit: true,
                                                  axisLineStyle: const AxisLineStyle(
                                                    thickness: 0.10,
                                                    color: Color.fromARGB(30, 0, 169, 181),
                                                    thicknessUnit: GaugeSizeUnit.factor,
                                                    cornerStyle: CornerStyle.bothCurve,
                                                  ),
                                                  pointers: <GaugePointer>[
                                                    RangePointer(
                                                        value: stepController.fitConnected.isTrue
                                                            ? stepController.todaySteps.toDouble()
                                                            : 0.0,
                                                        width: 0.10,
                                                        color: AppColors.primaryColor,
                                                        enableAnimation: true,
                                                        animationType: AnimationType.ease,
                                                        sizeUnit: GaugeSizeUnit.factor,
                                                        cornerStyle: CornerStyle.bothCurve),
                                                    MarkerPointer(
                                                        value: stepController.fitConnected.isTrue
                                                            ? stepController.todaySteps.toDouble()
                                                            : 0.0,
                                                        markerHeight: 12.sp,
                                                        markerWidth: 12.sp,
                                                        markerType: MarkerType.circle,
                                                        animationType: AnimationType.bounceOut,
                                                        enableAnimation: true,
                                                        color: Colors.white,
                                                        borderWidth: 3,
                                                        borderColor: Colors.grey[600])
                                                  ],
                                                ),
                                              ],
                                            )),
                                      ),
                                      Container(
                                        height: 40.h,
                                        width: 30.w,
                                        padding: EdgeInsets.only(top: 35.px),
                                        alignment: Alignment.center,
                                        child: Obx(() => Text(
                                              "${stepController.fitConnected.isTrue ? stepController.todaySteps : 0}"
                                              "\nSteps",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 15.sp),
                                            )),
                                      ),
                                    ],
                                  ),
                                  Obx(() => stepController.fitConnected.isFalse
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Platform.isAndroid
                                                    ? Image.asset(
                                                        'newAssets/images/google_fit.png',
                                                        height: 4.h,
                                                      )
                                                    : Image.asset(
                                                        "assets/images/health_app_icon.png",
                                                        // 'newAssets/images/google_fit.png',
                                                        height: 4.h,
                                                      ),
                                                Visibility(
                                                    visible: Platform.isAndroid, child: Gap(2.w)),
                                                Text(
                                                  Platform.isAndroid ? "Google Fit" : "Health",
                                                  style: googleFitTextStyle,
                                                )
                                              ],
                                            ),
                                            Gap(1.h),
                                            ElevatedButton(
                                              onPressed: () async {
                                                bool t = false;
                                                if (Platform.isAndroid) {
                                                  t = await LaunchApp.isAppInstalled(
                                                      androidPackageName:
                                                          "com.google.android.apps.fitness");
                                                } else {
                                                  t = true;
                                                }
                                                if (t) {
                                                  //  Get.back();
                                                  await stepController.getStepsFromGoogleFit();
                                                  stepController.onInit();
                                                  await stepController.fetchLastSevenDaysSteps();
                                                  Get.find<UpcomingDetailsController>().onInit();
                                                } else {
                                                  await LaunchApp.openApp(
                                                      openStore: true,
                                                      androidPackageName:
                                                          "com.google.android.apps.fitness");
                                                }
                                                //    Get.defaultDialog(
                                                //   title: "",
                                                //   titlePadding: EdgeInsets.only(),
                                                //   barrierDismissible: false,
                                                //   content: Column(
                                                //     mainAxisSize: MainAxisSize.min,
                                                //     children: <Widget>[
                                                //       Container(
                                                //         child: Row(
                                                //           mainAxisAlignment: MainAxisAlignment.center,
                                                //           children: <Widget>[
                                                //             SizedBox(
                                                //               height: 50,
                                                //               child: Platform.isAndroid
                                                //                   ? CircleAvatar(
                                                //                       backgroundColor: Colors.white,
                                                //                       radius: 25,
                                                //                       backgroundImage: AssetImage(
                                                //                           "assets/icons/googlefit.png"),
                                                //                     )
                                                //                   : Image.asset(
                                                //                       "assets/images/health_app_logo.jpeg",
                                                //                       // height: 10.h,
                                                //                     ),
                                                //             ),
                                                //             SizedBox(
                                                //               width: 10,
                                                //             ),
                                                //             Text(
                                                //               "${Platform.isAndroid ? "Google Fit" : "Health"}",
                                                //               style: TextStyle(
                                                //                 fontSize: 22,
                                                //                 color: Colors.blueGrey,
                                                //                 fontFamily: 'Poppins',
                                                //                 fontWeight: FontWeight.w600,
                                                //               ),
                                                //             )
                                                //           ],
                                                //         ),
                                                //       ),
                                                //       Padding(
                                                //         padding: const EdgeInsets.only(top: 10),
                                                //         child: ElevatedButton(
                                                //           onPressed: () async {
                                                //             Get.find<UpcomingDetailsController>()
                                                //                 .onClose();
                                                //             bool t = false;
                                                //             if (Platform.isAndroid) {
                                                //               t = await LaunchApp.isAppInstalled(
                                                //                   androidPackageName:
                                                //                       "com.google.android.apps.fitness");
                                                //             } else {
                                                //               t = true;
                                                //             }
                                                //             if (t) {
                                                //               Get.back();
                                                //               await _stepController
                                                //                   .getStepsFromGoogleFit();
                                                //               _stepController.onInit();
                                                //               await _stepController
                                                //                   .fetchLastSevenDaysSteps();
                                                //               Get.find<UpcomingDetailsController>()
                                                //                   .onInit();
                                                //             } else {
                                                //               await LaunchApp.openApp(
                                                //                   openStore: true,
                                                //                   androidPackageName:
                                                //                       "com.google.android.apps.fitness");
                                                //             }
                                                //           },
                                                //           child: Text(
                                                //               'Connect to ${Platform.isAndroid ? "Google Fit" : "Health"}'),
                                                //           style: ElevatedButton.styleFrom(
                                                //               shape: RoundedRectangleBorder()),
                                                //         ),
                                                //       )
                                                //     ],
                                                //   ),
                                                // );

                                                // GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
                                                //   'https://www.googleapis.com/auth/fitness.activity.read'
                                                // ]);
                                                // await _googleSignIn.signOut();
                                                // GoogleSignInAccount account =
                                                //     await _googleSignIn.signIn();
                                                // String userEmail = account.email;
                                                // print(userEmail);
                                                // print(userEmail);
                                                // print(userEmail);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  minimumSize: Size(3.w, 4.h),
                                                  backgroundColor: AppColors.primaryColor),
                                              child: const Text(
                                                'CONNECT',
                                              ),
                                            )
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: _types
                                                      .map((e) => Padding(
                                                            padding: EdgeInsets.symmetric(
                                                                vertical: 0.7.h),
                                                            child:
                                                                Text(e, style: todayProgressText),
                                                          ))
                                                      .toList(),
                                                ),
                                                SizedBox(
                                                  width: 2.w,
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(vertical: 0.7.h),
                                                      child: Obx(() => Text(
                                                            '${stepController.todayDuration} Min',
                                                            style: TextStyle(
                                                                color: AppColors.primaryColor,
                                                                fontSize: 15.sp),
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(vertical: 0.7.h),
                                                      child: Obx(() => Text(
                                                            '${stepController.todayCalories.toStringAsFixed(0)} Cal',
                                                            style: TextStyle(
                                                                color: AppColors.primaryColor,
                                                                fontSize: 15.sp),
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(vertical: 0.7.h),
                                                      child: Obx(() => Text(
                                                            '${stepController.todayDistance > 1000 ? (stepController.todayDistance / 1000).toStringAsFixed(2) : stepController.todayDistance.toStringAsFixed(0)} ${stepController.todayDistance > 1000 ? 'Km' : 'Meters'}',
                                                            style: TextStyle(
                                                                color: AppColors.primaryColor,
                                                                fontSize: 15.sp),
                                                          )),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                          ],
                                        )),
                                  Platform.isIOS
                                      ? Container()
                                      : Container(
                                          height: 15.h,
                                          width: 20.sp,
                                          padding: EdgeInsets.only(top: 2.h, bottom: 10.h),
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) =>
                                                      CupertinoAlertDialog(
                                                        // title: const Text(
                                                        //     "Make sure you connect your Active Google Fit account where all your fit devices are connected"),
                                                        content: const Text(
                                                            "Make sure you connect your Active Google Fit account where all your fit devices are connected"),
                                                        actions: <Widget>[
                                                          CupertinoDialogAction(
                                                            isDefaultAction: true,
                                                            child: const Text("Close"),
                                                            onPressed: () async {
                                                              Get.back();
                                                            },
                                                          ),
                                                        ],
                                                      ));
                                            },
                                            child: Container(
                                              height: 30,
                                              width: 30,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.transparent),
                                              child: const Center(
                                                  child: Icon(
                                                Icons.info,
                                                color: Colors.blueGrey,
                                              )),
                                            ),
                                          ),
                                        )
                                ],
                              );
                      }),
                ),
              ),
              //map

              Obx(() {
                if (stepController.previousActivityImage.value.caloriesBurned != '8122334.000' &&
                    stepController.previousActivityImage.value.trackMapImgUrl != null) {
                  String imageUrl =
                      '${stepController.previousActivityImage.value.trackMapImgUrl.toString()}?timestamp=${DateTime.now().millisecondsSinceEpoch}';

                  // Create a NetworkImage instance with the updated URL
                  NetworkImage networkImage = NetworkImage(imageUrl);

                  // Clear the cache for the updated URL
                  imageCache.evict(networkImage);
                  return Container(
                    color: Colors.white,
                    height: 35.5.h,
                    alignment: Alignment.center,
                    width: size.width / 1,
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 27.5.h,
                          width: size.width / 1,
                          child: Image(
                            image: networkImage,
                            fit: BoxFit.fill,
                          ),
                          // child: Image.network(
                          //  networkImage,
                          //   fit: BoxFit.fill,
                          //   errorBuilder: (context, error, stackTrace) {
                          //     return Shimmer.fromColors(
                          //       direction: ShimmerDirection.ltr,
                          //       enabled: true,
                          //       baseColor: Colors.white,
                          //       highlightColor: Colors.grey.shade300,
                          //       child: Container(
                          //         height: 35.h,
                          //         alignment: Alignment.center,
                          //         width: size.width / 1,
                          //         decoration: BoxDecoration(
                          //           color: Colors.white,
                          //           borderRadius: BorderRadius.circular(5),
                          //         ),
                          //       ),
                          //     );
                          //   },
                          // ),
                        ),
                        SizedBox(
                          height: 0.8.h,
                        ),
                        SizedBox(
                          width: size.width / 1.8,
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Calories burned '),
                              Text(
                                  '${double.parse(stepController.previousActivityImage.value.caloriesBurned).toStringAsFixed(2)}Cal')
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 0.5.h,
                        ),
                        SizedBox(
                          width: size.width / 1.8,
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Distance covered '),
                              Text(
                                  '${double.parse(stepController.previousActivityImage.value.distanceCovered).toStringAsFixed(2)}M')
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              }),
              SizedBox(
                height: 1.5.h,
              ),
              GetBuilder<GoogleFitStepController>(
                  id: 'chartdata',
                  builder: (_) {
                    selectedSteps.value = stepController.todaySteps.value;
                    triggerVariableAfterDelay();

                    return _.fitConnected.isTrue && _.weeklyChartLoaded
                        ? Shimmer.fromColors(
                            direction: ShimmerDirection.ltr,
                            period: const Duration(seconds: 2),
                            baseColor: const Color.fromARGB(255, 240, 240, 240),
                            highlightColor: Colors.grey.withOpacity(0.2),
                            child: Container(
                                height: 15.h,
                                width: 92.5.w,
                                color: Colors.white,
                                alignment: Alignment.center,
                                child: const Text('Hello')))
                        : Visibility(
                            visible: stepController.fitConnected.isTrue,
                            child: ValueListenableBuilder<int>(
                                valueListenable: selectedSteps,
                                builder: (BuildContext context, int value, Widget child) {
                                  return Visibility(
                                    visible: value > 0,
                                    replacement: Container(
                                        padding: const EdgeInsets.all(8),
                                        height: 20.h,
                                        width: 95.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.homeCardColor2,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(12.sp),
                                              child: const Text(
                                                'The account currently linked does not  have any recorded step data. Would you be interested in connecting an alternative account?',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                print(stepController.fitConnected.value);

                                                GoogleSignIn googleSignIn = GoogleSignIn(
                                                  scopes: [
                                                    'email',
                                                    'https://www.googleapis.com/auth/contacts.readonly',
                                                  ],
                                                );
                                                await googleSignIn.signOut();
                                                stepController.fitConnected.value = false;
                                                bool t = false;
                                                if (Platform.isAndroid) {
                                                  t = await LaunchApp.isAppInstalled(
                                                      androidPackageName:
                                                          "com.google.android.apps.fitness");
                                                } else {
                                                  t = true;
                                                }
                                                if (t) {
                                                  //  Get.back();
                                                  print(stepController.fitConnected.value);
                                                  await stepController.getStepsFromGoogleFit();
                                                  stepController.onInit();
                                                  await stepController.fetchLastSevenDaysSteps();
                                                  Get.find<UpcomingDetailsController>().onInit();
                                                } else {
                                                  await LaunchApp.openApp(
                                                      openStore: true,
                                                      androidPackageName:
                                                          "com.google.android.apps.fitness");
                                                }
                                              },
                                              child: Container(
                                                height: 4.h,
                                                width: 28.w,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  color: Colors.white,
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    'Change',
                                                    style: TextStyle(
                                                      color: AppColors.primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      height: 49.2.w,
                                      width: 95.w,
                                      decoration: const BoxDecoration(color: Colors.white),
                                      child: Column(
                                        children: [
                                          const Gap(8),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Gap(8),
                                              SizedBox(
                                                // height: 20.w,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Spacer(),
                                                    Text(
                                                      'Steps',
                                                      style: TextStyle(fontSize: 15.5.sp),
                                                    ),
                                                    Gap(0.5.h),
                                                    Text(
                                                      'Last 7 days',
                                                      style: TextStyle(fontSize: 15.sp),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              SizedBox(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Obx(() => Text(
                                                          '${stepController.todaySteps}',
                                                          style: TextStyle(
                                                            fontSize: 15.5.sp,
                                                          ),
                                                        )),
                                                    Gap(0.5.h),
                                                    Text(
                                                      'Today',
                                                      style: TextStyle(fontSize: 15.sp),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              GetBuilder<GoogleFitStepController>(
                                                  id: 'chartdata',
                                                  initState: (_) {
                                                    // if (stepController.fitConnected.isTrue) {
                                                    //   stepController.fetchLastSevenDaysSteps();
                                                    // }
                                                  },
                                                  builder: (_) {
                                                    return _.fitConnected.isTrue &&
                                                            _.weeklyChartLoaded
                                                        ? InkWell(
                                                            onTap: () {},
                                                            child: Icon(
                                                              Icons.arrow_forward_ios,
                                                              size: 18.sp,
                                                              color: Colors.grey,
                                                            ),
                                                          )
                                                        : InkWell(
                                                            onTap: () async {
                                                              DateTime timestamp = DateTime.now();

                                                              DateTime startOfDay = DateTime(
                                                                  timestamp.year,
                                                                  timestamp.month,
                                                                  timestamp.day);
                                                              DateTime timestamp1 = DateTime.now();

                                                              DateTime endOfDay = DateTime(
                                                                  timestamp1.year,
                                                                  timestamp1.month,
                                                                  timestamp1.day,
                                                                  23,
                                                                  59,
                                                                  59);

                                                              _.fetchHourlyBasis(
                                                                  startOfDay, endOfDay, '');

                                                              _.fetchHourlyBasis(
                                                                  startOfDay, endOfDay, 'b');
                                                              _.fetchHourlyBasis(
                                                                  startOfDay, endOfDay, 'f');
                                                              Get.to(StepCounterCalendart(),
                                                                  transition: Transition.cupertino);

                                                              print('Insight Graph');
                                                            },
                                                            child: Icon(
                                                              Icons.arrow_forward_ios,
                                                              size: 18.sp,
                                                            ),
                                                          );
                                                  })
                                            ],
                                          ),
                                          const Gap(10),
                                          StepCounterWidgets.last7DaysChart(
                                              stepController: stepController)
                                        ],
                                      ),
                                    ),
                                  );
                                }));
                  }),
              SizedBox(
                height: 8.h,
              )
            ],
          ),
        ),
      );
    }
  }

  waitUntilDataLoading(GoogleFitStepController _) async {
    _.onInit();
  }

  emptyFun() {}

  String getMaxValue(value) {
    int roundedValue = ((value + 9999) ~/ 10000) * 10000;
    return roundedValue.toString();
  }
// List example = [
//   {"name": "S", "value": 20},
//   {"name": "M", "value": 400},
//   {"name": "T", "value": 456},
//   {"name": "W", "value": 123},
//   {"name": "T", "value": 245},
//   {"name": "F", "value": 411},
//   {"name": "S", "value": 236},
// ];
}
