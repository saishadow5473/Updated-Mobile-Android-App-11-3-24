import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/utils/appColors.dart';
import '../../app/utils/appText.dart';
import '../../app/utils/textStyle.dart';
import '../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../../views/dietJournal/dietJournalNew.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import '../../app/utils/imageAssets.dart';
import '../controllers/healthJournalControllers/getTodayLogController.dart';
import '../pages/basicData/functionalities/percentage_calculations.dart';
import '../pages/basicData/screens/ProfileCompletion.dart';

class HealthJournalCard {
  final TabBarController _tabController = Get.find<TabBarController>();
  ValueNotifier<int> calLeft = ValueNotifier<int>(0);

  Widget staticHealthJournal({Color selectedAfficolor, String fromHome}) {
    return Padding(
      padding: EdgeInsets.only(
        top: 1.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Container(
                  color: AppColors.backgroundScreenColor,
                  width: 70.w,
                  child: Text(AppTexts.healthJournalAsk,
                      style: selectedAfficolor == null
                          ? AppTextStyles.contentHeading
                          : TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.sp,
                              color: selectedAfficolor,
                              fontWeight: FontWeight.w800,
                            )),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10, left: 1.w, right: 1.w),
                child: Material(
                  color: AppColors.backgroundScreenColor,
                  child: InkWell(
                    splashColor: Colors.blue,
                    onTap: () {
                      _tabController.updateSelectedIconValue(value: AppTexts.manageHealth);
                      if (PercentageCalculations().calculatePercentageFilled() != 100) {
                        Get.to(ProfileCompletionScreen());
                      } else {
                        Get.to(DietJournalNew(
                          Screen: "home",
                        ));
                      }
                    },
                    child: Row(
                      children: [
                        Text(AppTexts.logNow,
                            style: TextStyle(color: Colors.black, fontSize: 10.sp)),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13.sp,
                          color: selectedAfficolor ?? AppColors.primaryColor,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _tabController.updateSelectedIconValue(value: AppTexts.manageHealth);
              if (PercentageCalculations().calculatePercentageFilled() != 100) {
                Get.to(ProfileCompletionScreen());
              } else {
                Get.to(DietJournalNew(
                  Screen: "home",
                ));
              }
            },
            child: Card(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 1.5.h, top: 1.h, left: 2.w),
                    child: SizedBox(
                      width: 92.w,
                      child: Text(
                        AppTexts.healthJournalDescription,
                        style: AppTextStyles.secondaryContentFont,
                      ),
                    ),
                  ),
                  Image(
                      height: 21.4.h,
                      width: 100.w,
                      image: ImageAssets.healthLogImage,
                      fit: BoxFit.fill),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget caloriesCard(context, {Color selectedAfficolor, String fromHome}) {
    return GetBuilder<TodayLogController>(
        id: "Today Food",
        init: TodayLogController(),
        builder: (TodayLogController todayLog) {
          return todayLog.dataLoading
              ? Shimmer.fromColors(
                  direction: ShimmerDirection.ltr,
                  period: const Duration(seconds: 2),
                  baseColor: const Color.fromARGB(255, 240, 240, 240),
                  highlightColor: Colors.grey.withOpacity(0.2),
                  child: Container(
                      height: 18.h,
                      width: 97.w,
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Data Loading')))
              : InkWell(
                  onTap: () async {
                    _tabController.updateSelectedIconValue(value: AppTexts.manageHealth);
                    if (PercentageCalculations().calculatePercentageFilled() != 100) {
                      Get.to(ProfileCompletionScreen());
                    } else {
                      fromHome == "home"
                          ? await Get.to(DietJournalNew(
                              Screen: "home",
                            ))
                          : Get.to(DietJournalNew());
                    }
                    if (fromHome == "home") {
                      _tabController.updateSelectedIconValue(value: "Home");
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Container(
                          color: AppColors.backgroundScreenColor,
                          width: 70.w,
                          child: Text(AppTexts.healthJournalAsk,
                              style: selectedAfficolor == null
                                  ? AppTextStyles.contentHeading
                                  : TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11.sp,
                                      color: selectedAfficolor,
                                      fontWeight: FontWeight.w800,
                                    )),
                        ),
                      ),
                      todayLog.caloriesNeed == 0 && todayLog.limitExceed == true
                          ? Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor: Colors.grey.withOpacity(0.3),
                              direction: ShimmerDirection.ltr,
                              child: Container(
                                height: 18.h,
                                width: 97.w,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(8.0),
                                    bottomLeft: Radius.circular(8.0),
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                  ),
                                  color: Colors.red,
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                child: const Text('Hello'),
                              ),
                            )
                          : Container(
                              // color: selectedAfficolor != null
                              //     ? selectedAfficolor.withOpacity(0.2)
                              //     : AppColors.homeCardColor2,
                              color: Colors.white,
                              height: 18.h,
                              width: 97.w,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: MediaQuery.of(context).size.width > 350 &&
                                                MediaQuery.of(context).size.height > 650
                                            ? 46
                                            : 38,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            //0 calories removed and now we're showing extra calories
                                            Text(
                                              (todayLog.caloriesNeed == 1550 ||
                                                          todayLog.caloriesNeed == 1700) &&
                                                      (todayLog.caloriesEaten == 0 ||
                                                          todayLog.caloriesBurnt == 0)
                                                  ? "0"
                                                  : todayLog.limitExceed
                                                      ? todayLog.exceedsCalories.toString()
                                                      : "${todayLog.caloriesNeed}",
                                              style:
                                                  //selectedAfficolor != null
                                                  //     ? TextStyle(
                                                  //   fontFamily: 'Poppins',
                                                  //   fontSize: 13.sp,
                                                  //   color: selectedAfficolor,
                                                  //   fontWeight: FontWeight.w800,
                                                  // )
                                                  todayLog.limitExceed
                                                      ? AppTextStyles.limitExceed
                                                      : AppTextStyles.withinLimit,
                                            ),
                                            Text(
                                              todayLog.limitExceed ? "Cal Extra" : "Cal Left",
                                              style: AppTextStyles.regularFont,
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width > 350 &&
                                                MediaQuery.of(context).size.height > 650
                                            ? 95
                                            : 78,
                                        height: MediaQuery.of(context).size.height > 650 ? 95 : 78,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 9,
                                          backgroundColor: AppColors.backgroundScreenColor,
                                          color: AppColors.calNeed3,
                                          value: 1,
                                        ),
                                      ),
                                      LinearGradientCircularProgressIndicator(
                                        strokeWidth: 10,
                                        radius: 23.8,
                                        // value: todayLog.limitExceed
                                        //     // ? todayLog.caloriesNeed / int.parse(todayLog.totalCalories)
                                        //   ?1
                                        //     : todayLog.caloriesNeed > int.parse(todayLog.totalCalories)
                                        //     ? (todayLog.caloriesNeed /
                                        //     int.parse(todayLog.totalCalories)) -
                                        //     1
                                        //     : todayLog.caloriesNeed != 0
                                        //     ? (todayLog.caloriesGained.toDouble() /
                                        //     double.parse(todayLog.totalCalories))
                                        //  : 1, // Change this value to update the progress
                                        value: todayLog.limitExceed
                                            ? 1
                                            : todayLog.caloriesNeed == 0
                                                ? 1
                                                : (1 -
                                                    (todayLog.caloriesNeed /
                                                        int.parse(todayLog.totalCalories))),
                                        gradientColors: todayLog.limitExceed
                                            ? [AppColors.calExtra, AppColors.calExtraOpc]
                                            : [
                                                AppColors.calNeed,
                                                AppColors.calNeedOpc
                                              ], // Set your gradient colors
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(right: 1.w),
                                            child: Image.asset(
                                              ImageAssets.calConsumed,
                                              height: 5.h,
                                              width: 5.w,
                                              // color: selectedAfficolor ?? AppColors.primaryColor,
                                            ),
                                          ),
                                          Text("Consumed - ${todayLog.caloriesEaten} Cal")
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(right: 1.w),
                                            child: Image.asset(
                                              ImageAssets.calBurnt2,
                                              height: 5.h,
                                              width: 5.w,
                                              // color: selectedAfficolor ?? AppColors.primaryColor,
                                            ),
                                          ),
                                          Text("Burnt - ${todayLog.caloriesBurnt} Cal"),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          _tabController.updateSelectedIconValue(
                                              value: AppTexts.manageHealth);
                                          if (PercentageCalculations()
                                                  .calculatePercentageFilled() !=
                                              100) {
                                            Get.to(ProfileCompletionScreen());
                                          } else {
                                            fromHome == "home"
                                                ? Get.to(DietJournalNew(
                                                    Screen: "home",
                                                  ))
                                                : Get.to(DietJournalNew(Screen: fromHome));
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              selectedAfficolor ?? AppColors.primaryColor,
                                        ),
                                        child: Text(
                                          AppTexts.logNow,
                                          style: TextStyle(fontSize: 11.sp),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                    ],
                  ),
                );
        });
  }
}

class LinearGradientCircularProgressIndicator extends StatelessWidget {
  final double strokeWidth;
  final double radius;
  final double value;
  final List<Color> gradientColors;

  const LinearGradientCircularProgressIndicator({
    Key key,
    this.strokeWidth = 10.0,
    this.radius = 50.0,
    this.value = 0.0,
    @required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: LinearGradientCircularProgressPainter(
        strokeWidth: strokeWidth,
        value: value <= 0 ? 0.0001 : value,
        gradientColors: gradientColors,
      ),
    );
  }
}

class LinearGradientCircularProgressPainter extends CustomPainter {
  final double strokeWidth;
  final double value;
  final List<Color> gradientColors;

  LinearGradientCircularProgressPainter({
    @required this.strokeWidth,
    @required this.value,
    @required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double halfWidth = size.width / 1;
    final double halfHeight = size.height / 1;
    final Offset center = Offset(halfWidth, halfHeight);

    final double radius = math.min(halfWidth, halfHeight);
    final Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.5;

    final Rect rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 7.5);

    final double arcAngle = 2 * math.pi * value;

    final LinearGradient gradient = LinearGradient(
      colors: gradientColors,
      stops: const [0.0, 1.1],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final SweepGradient sweepGradient = SweepGradient(
      colors: gradientColors,
      stops: const [
        0.0,
        0.60,
      ],
      startAngle: 0.0,
      endAngle: arcAngle,
      transform: const GradientRotation(-math.pi / 2),
    );

    paint.shader = gradient.createShader(rect);

    canvas.drawArc(rect, -math.pi / 2, arcAngle, false, paint);

    paint.shader = sweepGradient.createShader(rect);

    canvas.drawArc(rect, -math.pi / 2.15, arcAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
