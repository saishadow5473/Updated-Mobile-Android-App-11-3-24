import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'trackActivityWithMap.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../app/utils/appColors.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import 'stepCounterCalendart.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../Widgets/manageHealthWidgets/last7DaysChartWidget.dart';
import '../../../controllers/managehealth/stepcounter/googleFitStepController.dart';

class StepCounterSubDashboard extends StatelessWidget {
  final GoogleFitStepController _stepController = Get.find();
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  final TextStyle _textStyle =
      TextStyle(color: AppColors.primaryColor, fontSize: 16.sp, fontWeight: FontWeight.w600);

  StepCounterSubDashboard({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        title: const Text('Step Tracker'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 28.sp,
          ),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      content: SizedBox(
        height: 100.h,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => ClipRect(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: EdgeInsets.only(top: 2.5.h),
                                height: 17.h,
                                child: SfRadialGauge(
                                  axes: <RadialAxis>[
                                    RadialAxis(
                                      canScaleToFit: false,
                                      minimum: 0,
                                      maximum: double.parse(
                                          getMaxValue(_stepController.todaySteps.toInt())),
                                      startAngle: 270,
                                      endAngle: 270,
                                      showLabels: false,
                                      showTicks: false,
                                      axisLineStyle: AxisLineStyle(
                                        thickness: 14.sp,
                                        color: Colors.grey.withOpacity(0.2),
                                        thicknessUnit: GaugeSizeUnit.logicalPixel,
                                        cornerStyle: CornerStyle.bothFlat,
                                        gradient: const SweepGradient(
                                          colors: <Color>[Colors.grey, Colors.grey],
                                          stops: <double>[0.25, 0.75],
                                        ),
                                      ),
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                            positionFactor: 0.1,
                                            angle: 90,
                                            widget: Text(
                                              '${_stepController.todaySteps} / ${getMaxValue(_stepController.todaySteps.toInt())}',
                                              style: TextStyle(fontSize: 16.sp),
                                            ))
                                      ],
                                      pointers: <GaugePointer>[
                                        RangePointer(
                                          value: _stepController.todaySteps.toDouble(),
                                          width: 14.sp,
                                          color: AppColors.primaryColor,
                                          enableAnimation: true,
                                          animationType: AnimationType.bounceOut,
                                          cornerStyle: CornerStyle.bothCurve,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset(
                      'newAssets/images/shoe.png',
                      height: 8.h,
                      width: 8.w,
                    ),
                    Text(
                      '  Steps',
                      style: TextStyle(fontSize: 16.sp),
                    )
                  ]),
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: _stepController.todayCalories.toStringAsFixed(0),
                                  style: _textStyle),
                              const TextSpan(text: '\nCal'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: _stepController.todayDistance > 1000
                                      ? (_stepController.todayDistance / 1000).toStringAsFixed(2)
                                      : _stepController.todayDistance.toStringAsFixed(0),
                                  style: _textStyle),
                              TextSpan(
                                  text: _stepController.todayDistance > 1000 ? '\nKm' : '\nMeters'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: '${_stepController.todayDuration}', style: _textStyle),
                              const TextSpan(
                                text: '\nMin',
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    height: 49.w,
                    width: 100.w,
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
                                        '${_stepController.todaySteps}',
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
                            InkWell(
                              onTap: () {
                                Get.to( StepCounterCalendart());
                              },
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.sp,
                              ),
                            )
                          ],
                        ),
                        const Gap(10),
                        StepCounterWidgets.last7DaysChart(stepController: _stepController)
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 2.h),
                    height: 18.h,
                    color: AppColors.homeCardColor2.withOpacity(0.5),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Image.asset('newAssets/images/track_workout_logo.png'),
                        SizedBox(
                            width: 55.w,
                            child: const Text(
                              'Set a pace for your walks \n\nFollow along with the beat to turn walking into a simple, effective way to exercise',
                              textAlign: TextAlign.center,
                            ))
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 90.h,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.sp, right: 20.sp),
                    child: PopupMenuButton(
                      position: PopupMenuPosition.under,
                      itemBuilder: (BuildContext ctx) => [
                        PopupMenuItem(
                          onTap: () async {
                            // isLoading.value = true;
                            // bool locationStatus = await Permission.location.isDenied;
                            // if (locationStatus) {
                            //   await Permission.location.request();
                            // }

                            // if (locationStatus) {
                            //   print('still denied');
                            //   showDialog(
                            //       context: context,
                            //       builder: (BuildContext context) => CupertinoAlertDialog(
                            //             title: const Text(
                            //                 "For Track Workout Location Permission Needed !"),
                            //             content:
                            //                 const Text("Allow location permission to continue"),
                            //             actions: <Widget>[
                            //               CupertinoDialogAction(
                            //                 isDefaultAction: true,
                            //                 child: const Text("Yes"),
                            //                 onPressed: () async {
                            //                   await openAppSettings();
                            //                   Get.back();
                            //                 },
                            //               ),
                            //               CupertinoDialogAction(
                            //                 child: const Text("No"),
                            //                 onPressed: () => Get.back(),
                            //               )
                            //             ],
                            //           ));
                            // }
                            // if (!locationStatus) {
                            //   Position position = await Geolocator.getCurrentPosition(
                            //     desiredAccuracy: LocationAccuracy.best,
                            //   );
                            //   if (position != null) {
                            //     Get.to(TrackActivityWithMap(
                            //       initialPos: position,
                            //     ));
                            //   }
                            // }

                            //  isLoading.value = false;
                          },
                          height: 5.h,
                          child: GestureDetector(
                            onTap: () async {
                              isLoading.value = true;
                              bool locationStatus = await Permission.location.isDenied;
                              if (locationStatus) {
                                await Permission.location.request();
                              }

                              if (locationStatus) {
                                print('still denied');
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) => CupertinoAlertDialog(
                                          title: const Text(
                                              "For Track Workout Location Permission Needed !"),
                                          content:
                                              const Text("Allow location permission to continue"),
                                          actions: <Widget>[
                                            CupertinoDialogAction(
                                              isDefaultAction: true,
                                              child: const Text("Yes"),
                                              onPressed: () async {
                                                await openAppSettings();
                                                Get.back();
                                              },
                                            ),
                                            CupertinoDialogAction(
                                              child: const Text("No"),
                                              onPressed: () => Get.back(),
                                            )
                                          ],
                                        ));
                              }
                              if (!locationStatus) {
                                Position position = await Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.best,
                                );
                                if (position != null) {
                                  Get.to(TrackActivityWithMap(
                                    initialPos: position,
                                  ));
                                }
                              }

                              isLoading.value = false;
                            },
                            child: ValueListenableBuilder(
                                valueListenable: isLoading,
                                builder: (_, v, __) {
                                  return v
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const CircularProgressIndicator(
                                              color: AppColors.primaryColor,
                                            ),
                                            SizedBox(
                                              width: 4.w,
                                            ),
                                            const Icon(
                                              Icons.directions_walk,
                                              color: AppColors.primaryColor,
                                            )
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: const [
                                            Text('Track workout'),
                                            Icon(
                                              Icons.directions_walk,
                                              color: AppColors.primaryColor,
                                            )
                                          ],
                                        );
                                }),
                          ),
                        )
                      ],
                      child: Container(
                        height: 12.h,
                        width: 12.w,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.primaryColor),
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              )
            ],
          ),
        ),
      ),
    );
    // Scaffold(
    //   backgroundColor: Colors.white,

    //   floatingActionButton: PopupMenuButton(
    //     position: PopupMenuPosition.under,
    //     itemBuilder: (ct) => [
    //       PopupMenuItem(
    //         onTap: () async {
    //           isLoading.value = true;
    //           bool _locationStatus = await Permission.location.isDenied;
    //           if (_locationStatus) {
    //             await Permission.location.request();
    //           }
    //           var position = await Geolocator.getCurrentPosition(
    //             desiredAccuracy: LocationAccuracy.best,
    //           );
    //           if (position != null)
    //             Get.to(TrackActivityWithMap(
    //               initialPos: position,
    //             ));
    //           isLoading.value = false;
    //         },
    //         height: 5.h,
    //         child: ValueListenableBuilder(
    //             valueListenable: isLoading,
    //             builder: (_, v, __) {
    //               return v
    //                   ? Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                       children: [
    //                         CircularProgressIndicator(
    //                           color: AppColors.primaryColor,
    //                         ),
    //                         SizedBox(
    //                           width: 4.w,
    //                         ),
    //                         Icon(
    //                           Icons.directions_walk,
    //                           color: AppColors.primaryColor,
    //                         )
    //                       ],
    //                     )
    //                   : Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                       children: [
    //                         Text('Track workout'),
    //                         Icon(
    //                           Icons.directions_walk,
    //                           color: AppColors.primaryColor,
    //                         )
    //                       ],
    //                     );
    //             }),
    //       )
    //     ],
    //     child: Container(
    //       height: 12.h,
    //       width: 12.w,
    //       child: Icon(Icons.add),
    //       decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryColor),
    //     ),
    //   ),
    //   floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    // );
  }

  String getMaxValue(value) {
    int roundedValue = ((value + 9999) ~/ 10000) * 10000;
    return roundedValue.toString();
  }
}
