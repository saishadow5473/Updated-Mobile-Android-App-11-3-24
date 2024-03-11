import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'trackActivityWithMap.dart';
import '../../../../app/utils/appColors.dart';
import '../../../controllers/managehealth/stepcounter/googleFitStepController.dart';
import '../../dashboard/common_screen_for_navigation.dart';
import '../manageHealthScreentabs.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class PictureConversion extends StatefulWidget {
  const PictureConversion(
      {Key key,
      this.image,
      this.steps,
      this.calories,
      this.duration,
      this.distance,
      this.startTime,
      this.activeTime})
      : super(key: key);
  final String image, steps, calories, duration, distance, startTime, activeTime;

  @override
  State<PictureConversion> createState() => _PictureConversionState();
}

class _PictureConversionState extends State<PictureConversion> {
  final GoogleFitStepController _stepController = Get.put(GoogleFitStepController());
  @override
  void initState() {
    ChangeCurrentStatus.currentStatus.value = Status.start;
    super.initState();
  }

  @override
  void dispose() {
    ChangeCurrentStatus.currentStatus.value = Status.start;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Uint8List image = base64Decode(widget.image);
    DateTime date = DateTime.parse(widget.startTime);
    return CommonScreenForNavigation(
      appBar: AppBar(
        title: const Text('Track Workout'),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            indexFromStepCounter = 2;
            gTabBarController.index = 2;
            _stepController.onInit();
            Get.to( ManageHealthScreenTabs());
             ChangeCurrentStatus.currentStatus.value = Status.start;
          },
          child: Icon(
            Icons.keyboard_arrow_left,
            size: 28.sp,
          ),
        ),
        elevation: 0,
      ),
      content: WillPopScope(
        onWillPop: () {
          indexFromStepCounter = 2;
          gTabBarController.index = 2;
          _stepController.onInit();
          Get.to( ManageHealthScreenTabs());
           ChangeCurrentStatus.currentStatus.value = Status.start;
        },
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.only(
              left: 20.sp,
              right: 20.sp,
              top: 30.sp,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${getGreeting(date.hour)} Walk'),
                SizedBox(
                  height: 2.sp,
                ),
                Row(
                  children: [
                    SizedBox(
                        height: 4.h, width: 5.w, child: Image.asset("assets/images/walking.png")),
                    SizedBox(
                      width: 5.sp,
                    ),
                    Text(date.day.toString()),
                    SizedBox(
                      width: 2.sp,
                    ),
                    Text(DateFormat.MMMM().format(date)),
                    // Text(' , ${date.hour} hrs ${date.minute} min '),
                    Text(
                        '  ${DateFormat('h:mm a').format(DateTime(date.year, date.month, date.day, date.hour, date.minute))}')
                  ],
                ),
                SizedBox(
                  height: 50.sp,
                ),
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                          height: 6.h,
                          width: 10.w,
                          child: Image.asset(
                            "assets/images/shoeSteps.png",
                            color: AppColors.primaryColor,
                            fit: BoxFit.cover,
                          )),
                      Text(
                        widget.steps,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                      const Text('steps')
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.sp,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [const Text('Active time'), Text(widget.activeTime)],
                    ),
                    SizedBox(
                      height: 8.sp,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Distance'),
                        Text('${double.parse(widget.distance).toStringAsFixed(2)} Meters')
                      ],
                    ),
                    SizedBox(
                      height: 8.sp,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Energy expended'),
                        Text('${double.parse(widget.calories).toStringAsFixed(2)} Cal')
                      ],
                    )
                  ],
                ),
                // SizedBox(
                //   height: 20.sp,
                // ),
                // Container(height: 200, child: Image.memory(image))
              ],
            ),
          ),
        ),
      ),
    );
  }

  // String getGreeting(int hour) {
  //   if (hour >= 5 && hour < 12) {
  //     return "Morning";
  //   } else if (hour >= 12 && hour < 17) {
  //     return "Afternoon";
  //   } else {
  //     return "Night";
  //   }
  // }

  String getGreeting(int hour) {
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 16) {
      return 'Lunch';
    } else if (hour >= 16 && hour < 19) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }
}
