import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../app/utils/appColors.dart';
import '../../controllers/managehealth/stepcounter/googleFitStepController.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

class StepCounterWidgets {
  static Widget last7DaysChart({GoogleFitStepController stepController}) {
    return Obx(() {
      return Visibility(
        visible: stepController.fitConnected.isTrue,
        replacement: SizedBox(
          height: 11.h,
          width: 100.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 28.sp,
                color: AppColors.primaryAccentColor.withOpacity(0.5),
              ),
              SizedBox(height: 1.h),
              Text(
                "No Steps Found !",
                style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryAccentColor,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.8),
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
        child: GetBuilder<GoogleFitStepController>(
            id: 'chartdata',
            builder: (_) => _.weeklyChartLoaded
                ? Shimmer.fromColors(
                    direction: ShimmerDirection.ltr,
                    period: const Duration(seconds: 2),
                    baseColor: const Color.fromARGB(255, 240, 240, 240),
                    highlightColor: Colors.grey.withOpacity(0.2),
                    child: Container(
                        height: 12.h,
                        width: 80.w,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: const Text('Hello')))
                : Hero(
                    tag: 'chart',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(8),
                          // ignore: missing_return
                          Builder(builder: (BuildContext context) {
                            try {
                              double heightOnePersentagee = 16.w / 100;
                              List<double> persentagess = [];
                              List<StepsData> ss = [];
                              ss = ss + _.stepsList;
                              ss.sort(((StepsData a, StepsData b) => (b.steps).compareTo(a.steps)));
                              int i = ss.first.steps;
                              List yAxisData = [
                                double.parse((i + (i / 10)).toString()).toInt(),
                                double.parse((i / 2).toString()).toInt(),
                                double.parse((i / 3).toString()).toInt(),
                                0
                              ];
                              for (StepsData e in _.stepsList) {
                                double currentValuePercentage = ((e.steps / yAxisData[0]) * 100);
                                persentagess.add(double.parse(
                                    (currentValuePercentage.toInt() * heightOnePersentagee)
                                        .toString()));
                              }
                              return SizedBox(
                                height: 25.w,
                                width: 85.w,
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    // ignore: always_specify_types
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: yAxisData
                                            .map((e) => Text(
                                                  e.toString(),
                                                  style: TextStyle(fontSize: 13.5.sp),
                                                ))
                                            .toList(),
                                      ),
                                      ..._.stepsList
                                          .map((StepsData e) => Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    AnimatedContainer(
                                                        duration: const Duration(milliseconds: 500),
                                                        height: ((e.steps / yAxisData[0]) * 100) *
                                                            heightOnePersentagee,
                                                        width: 3.5.w,
                                                        color: AppColors.primaryColor),
                                                    SizedBox(
                                                      height: 4.w,
                                                      child: Text(
                                                        DateFormat('EEEE')
                                                            .format(e.date)
                                                            .substring(0, 1),
                                                        style: TextStyle(fontSize: 14.sp),
                                                      ),
                                                    )
                                                  ])))
                                          .toList(),
                                    ]),
                              );
                            } catch (e) {
                              print(e);
                              // replaceWidget.value = false;
                              // replaceWidget.notifyListeners();

                              return Container(
                                margin: const EdgeInsets.all(8),
                                width: 75.w,
                                height: 10.h,
                                child: Center(
                                  child: Text(
                                    "No Steps Found !",
                                    style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryAccentColor,
                                        fontFamily: 'Poppins',
                                        letterSpacing: 0.8),
                                  ),
                                ),
                              );
                            }
                          })
                        ],
                      ),
                    ),
                  )),
      );
    });
  }


}
