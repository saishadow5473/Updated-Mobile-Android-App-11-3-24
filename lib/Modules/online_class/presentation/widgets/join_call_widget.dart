import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../new_design/app/utils/appColors.dart';
import '../../../../new_design/app/utils/localStorageKeys.dart';
import '../../../../new_design/module/online_serivices/data/model/get_subscribtion_list.dart';
import '../../../../new_design/module/online_serivices/functionalities/online_services_dashboard_functionalities.dart';
import '../../../../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import '../../../../utils/SpUtil.dart';
import '../../../../views/teleconsultation/videocall/CallWaitingScreen.dart';
import '../../bloc/trainer_status/bloc/trainer_bloc.dart';
import '../../functionalities/upcoming_courses.dart';

class joinCallwidget extends StatelessWidget {
  //common widget created for reusable purpose
  Subscription subcriptionList;
  bool noTime;
  Widget ui;
  String formatedClassDuration;
  joinCallwidget({Key key, this.subcriptionList, this.ui, @required this.noTime}) : super(key: key);
  OnlineServicesFunctions onlineSerivicesFunction = OnlineServicesFunctions();
  DateTime currentDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    List<DateTime> courseDay =
        onlineSerivicesFunction.parseDateRange(subcriptionList.courseDuration);

    return BlocBuilder<TrainerBloc, TrainerAvailabilityState>(
      builder: (BuildContext context, TrainerAvailabilityState state) {
        bool externalUrlIsNull =
            subcriptionList.externalUrl == null || subcriptionList.externalUrl == "";
        if (subcriptionList.courseTime.length == 19) {
          formatedClassDuration = subcriptionList.courseTime;
        } else {
          formatedClassDuration =
              onlineSerivicesFunction.adjustHourLength(subcriptionList.courseTime);
        }
        bool enableExternal = false;

        //The below funciton is used to trigger the timer based on the provided course time.
        //The timer's are only active when the creator uses external url option while creaiting
        // a class ✅
        if (!externalUrlIsNull) {
          Timer endTimer;
          Timer startTimer;
          String temp = subcriptionList.courseDuration.substring(13, 23);
          DateTime courseEndDate = DateFormat("yyyy-MM-dd").parse(temp);
          //unslash the below line to use hard coded time ✅
          // courseTime = "06:45 PM - 06:49 PM";
          String courseTime = formatedClassDuration;
          bool startIsAM = courseTime.substring(6, 8).toLowerCase().contains("am");
          bool endIsAM = courseTime.substring(18, courseTime.length).toLowerCase().contains("am");
          //Storing the start time hour and min
          int startMin = int.parse(courseTime.substring(3, 5));
          int startHour = int.parse(courseTime.substring(0, 2));

          //Storing the end time hour and min
          int endMin;
          try {
            endMin = int.parse(courseTime.substring(14, 16));
          } catch (e) {
            endMin = int.parse(courseTime.substring(13, 14));
          }
          int endHour = int.parse(courseTime.substring(11, 13));
          !startIsAM ? startHour += 12 : null;
          !endIsAM ? endHour += 12 : null;
          DateTime currentDate = DateTime.now();
          DateTime startTime =
              DateTime(currentDate.year, currentDate.month, currentDate.day, startHour, startMin);

          DateTime endTime =
              DateTime(currentDate.year, currentDate.month, currentDate.day, endHour, endMin);
          DateTime currentTime = DateTime.now();
          Duration difference = endTime.difference(currentTime);
          int dur = 0;
          //The below function is used to get the start time difference to trigger the
          //start timer to enable the join call button ✅
          if (startTime.isAfter(currentTime)) {
            dur = startTime.difference(currentTime).inMinutes;
          } else {
            dur = 0;
          }
          if (endTime.isAfter(currentTime) && courseEndDate.isAfter(currentTime)) {
            //if the Time is already arrived so no need to trigger the start time
            //instead of triggering the start timer we are triggering the join call
            //Disbale time that's the End Timer . We are activating the end Timer to
            //disble the join call button ✅
            if (dur <= 0) {
              enableExternal = true;
              endTimer ??= Timer(difference, () async {
                log("Join button switched to disable state");
                enableExternal = false;
                endTimer.cancel();
                context.read<TrainerBloc>().add(ListenTrainerStatusEvent(false));
              });
            } else {
              //There is two timer under this else statement.
              //this timer's are used to enable and disable the button automatically
              //Based on the provided course time. ✅
              startTimer ??= Timer(Duration(minutes: dur), () async {
                log("Join button switched to enable state");
                enableExternal = true;
                startTimer.cancel();
                context.read<TrainerBloc>().add(ListenTrainerStatusEvent(false));
              });
              endTimer ??= Timer(difference, () async {
                log("Join button switched to disable state");
                enableExternal = false;
                endTimer.cancel();
                context.read<TrainerBloc>().add(ListenTrainerStatusEvent(false));
              });
            }
          }
        }
        if (state is InitialTrainerState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              noTime
                  ? Container()
                  : onlineSerivicesFunction.checkCurrentDate(courseDay[0], courseDay[1])
                      ? Text("Today ", style: TextStyle(fontSize: 13.sp))
                      : Text("Upcoming ", style: TextStyle(fontSize: 13.sp)),
              noTime
                  ? Container()
                  : Text(
                      formatedClassDuration,
                      style: TextStyle(fontSize: 14.sp, color: AppColors.primaryAccentColor),
                    ),
              noTime
                  ? Container()
                  : onlineSerivicesFunction.checkCurrentDate(courseDay[0], courseDay[1])
                      ? SizedBox(width: 7.w)
                      : SizedBox(width: 1.w),
              noTime
                  ? const ElevatedButton(onPressed: null, child: Text("Join Now"))
                  : Container(
                      height: 3.5.h,
                      width: 22.w,
                      decoration: BoxDecoration(
                          color: Colors.grey, borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                        child: Text('Join', style: TextStyle(color: Colors.white)),
                      ),
                    )
            ],
          );
        } else if (state is UpdatedTrainerState) {
          final bool isOnline = state.isOnline;
          final String statusText = isOnline ? 'Online' : 'Offline';
          return Builder(builder: (BuildContext context) {
            String courseOn;
            if (subcriptionList.courseOn.isNotEmpty) {
              courseOn = subcriptionList.courseOn[0];
            } else {
              courseOn = 'Monday';
            }

            bool joinCall = UpcomingCourses().joinCourseButton(
                subcriptionList.courseDuration,
                formatedClassDuration,
                statusText,
                subcriptionList.courseType,
                courseOn ?? 'Monday');
            if (isCurrentDateWithinRange(subcriptionList.courseDuration)) {
              if (isTenMinsBefore(formatedClassDuration)) {
                Timer timer;

                timer = Timer.periodic(const Duration(minutes: 2), (Timer timer) {
                  joinCall = UpcomingCourses().joinCourseButton(
                      subcriptionList.courseDuration,
                      formatedClassDuration,
                      statusText,
                      subcriptionList.courseType,
                      courseOn ?? 'Monday');
                  // UpcomingCourses()
                  //     .trainerStatusFromFirebase(context.read, subcriptionList.consultantId);
                });
                if (isAfterHours(formatedClassDuration)) {
                  timer.cancel();
                }
                print("final $joinCall");
              } else {
                joinCall = false;
              }
            }
            return Row(
              mainAxisAlignment: noTime ? MainAxisAlignment.center : MainAxisAlignment.spaceAround,
              children: <Widget>[
                noTime
                    ? Container()
                    : onlineSerivicesFunction.checkCurrentDate(courseDay[0], courseDay[1])
                        ? Text("Today ", style: TextStyle(fontSize: 14.sp))
                        : Text("Upcoming ", style: TextStyle(fontSize: 14.sp)),
                noTime
                    ? Container()
                    : Text(
                        formatedClassDuration,
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primaryAccentColor,
                            fontWeight: FontWeight.bold),
                      ),
                noTime
                    ? Container()
                    : onlineSerivicesFunction.checkCurrentDate(courseDay[0], courseDay[1])
                        ? SizedBox(width: 7.w)
                        : SizedBox(width: 1.w),
                Visibility(
                    visible: externalUrlIsNull,
                    replacement: Visibility(
                      visible: enableExternal,
                      replacement: noTime
                          ? const ElevatedButton(onPressed: null, child: Text("Join Now"))
                          : Container(
                              height: 3.5.h,
                              width: 22.w,
                              decoration: BoxDecoration(
                                  color: Colors.grey, borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                child: Text('Join', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                      child: noTime
                          ? ElevatedButton(
                              onPressed: () async {
                                //The below function is used to trigger the External Url To the
                                //respective platform ✅
                                Uri url = Uri.parse(subcriptionList.externalUrl);
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              },
                              child: const Text("Join Now"))
                          : GestureDetector(
                              onTap: () async {
                                //The below function is used to trigger the External Url To the
                                //respective platform ✅
                                Uri url = Uri.parse(subcriptionList.externalUrl);
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              },
                              child: Container(
                                height: 3.5.h,
                                width: 22.w,
                                decoration: BoxDecoration(
                                    color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                                child: const Center(
                                  child: Text('Join', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),
                    ),
                    child: joinCall
                        ? noTime
                            ? ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  var userID = localSotrage.read(LSKeys.ihlUserId);
                                  prefs.setString("userIDFromSubscriptionCall",
                                      userID ?? SpUtil.getString(LSKeys.ihlUserId));
                                  prefs.setString("consultantIDFromSubscriptionCall",
                                      subcriptionList.consultantId);
                                  prefs.setString("subscriptionIDFromSubscriptionCall",
                                      subcriptionList.subscriptionId);
                                  prefs.setString(
                                      "courseNameFromSubscriptionCall", subcriptionList.title);
                                  prefs.setString(
                                      "courseIDFromSubscriptionCall", subcriptionList.courseId);
                                  prefs.setString("trainerNameFromSubscriptionCall",
                                      subcriptionList.consultantName);
                                  prefs.setString(
                                      'providerFromSubscriptionCall', subcriptionList.provider);
                                  // Get.off(
                                  //   CallWaitingScreen(
                                  //     appointmentDetails: [
                                  //       subcriptionList.courseId,
                                  //       userID,
                                  //       subcriptionList.consultantId,
                                  //       "SubscriptionCall",
                                  //       subcriptionList.consultantId,
                                  //     ],
                                  //   ),
                                  // );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => CallWaitingScreen(
                                        appointmentDetails: [
                                          subcriptionList.courseId,
                                          userID,
                                          subcriptionList.consultantId,
                                          "SubscriptionCall",
                                          subcriptionList.consultantId,
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Join Now"))
                            : GestureDetector(
                                onTap: () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  var userID = localSotrage.read(LSKeys.ihlUserId);
                                  prefs.setString("userIDFromSubscriptionCall",
                                      userID ?? SpUtil.getString(LSKeys.ihlUserId));
                                  prefs.setString("consultantIDFromSubscriptionCall",
                                      subcriptionList.consultantId);
                                  prefs.setString("subscriptionIDFromSubscriptionCall",
                                      subcriptionList.subscriptionId);
                                  prefs.setString(
                                      "courseNameFromSubscriptionCall", subcriptionList.title);
                                  prefs.setString(
                                      "courseIDFromSubscriptionCall", subcriptionList.courseId);
                                  prefs.setString("trainerNameFromSubscriptionCall",
                                      subcriptionList.consultantName);
                                  prefs.setString(
                                      'providerFromSubscriptionCall', subcriptionList.provider);
                                  // Get.off(
                                  //   CallWaitingScreen(
                                  //     appointmentDetails: [
                                  //       subcriptionList.courseId,
                                  //       userID,
                                  //       subcriptionList.consultantId,
                                  //       "SubscriptionCall",
                                  //       subcriptionList.consultantId,
                                  //     ],
                                  //   ),
                                  // );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => CallWaitingScreen(
                                        appointmentDetails: [
                                          subcriptionList.courseId,
                                          userID,
                                          subcriptionList.consultantId,
                                          "SubscriptionCall",
                                          subcriptionList.consultantId,
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 3.5.h,
                                  width: 22.w,
                                  decoration: BoxDecoration(
                                      color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                                  child: const Center(
                                    child: Text('Join', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              )
                        : noTime
                            ? const ElevatedButton(onPressed: null, child: Text("Join Now"))
                            : Container(
                                height: 3.5.h,
                                width: 22.w,
                                decoration: BoxDecoration(
                                    color: Colors.grey, borderRadius: BorderRadius.circular(10)),
                                child: const Center(
                                  child: Text('Join', style: TextStyle(color: Colors.white)),
                                ),
                              )) // Row(
                ,
                // )
              ],
            );
          });
        } else if (state is StatusError) {
          return Text('Error: ${state.error}');
        }
        return Container(); // Handle other states if needed
      },
    );
  }

  bool isTenMinsBefore(String timeRange) {
    DateTime currentTime = DateTime.now();
    List<String> timeParts = timeRange.split(" - ");
    List<String> timeComponents = timeParts[0].split(RegExp(r'[: ]'));
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);
    String amPm = timeComponents[2];
    if (amPm == "PM" || amPm == "pm") {
      hour += 12;
    }

    // DateTime(dateOfDay.year, dateOfDay.month, dateOfDay.day, picked.hour, picked.minute);
    DateTime targetTime =
        DateTime(currentTime.year, currentTime.month, currentTime.day, hour, minute);

    // Get the current time

    // Calculate the time 10 minutes ago
    DateTime after15 = targetTime.add(const Duration(minutes: 45));
    DateTime tenMinutesAgo = targetTime.subtract(const Duration(minutes: 10));
//&& currentTime.isBefore(targetTime)
    if (currentTime.isAfter(tenMinutesAgo)) {
      if (currentTime.isBefore(after15)) {
        return true;
      }
      return false;
    } else {
      return false;
    }
  }

  bool isAfterHours(String timeRange) {
    DateTime currentTime = DateTime.now();
    List<String> timeParts = timeRange.split(" - ");
    List<String> timeComponents = timeParts[0].split(RegExp(r'[: ]'));
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);
    // DateTime(dateOfDay.year, dateOfDay.month, dateOfDay.day, picked.hour, picked.minute);
    DateTime targetTime = DateFormat("yyyy-MM-dd h:mm a").parse(
        "${currentTime.year}-${currentTime.month}-${currentTime.day} ${timeComponents[0]}:${timeComponents[1]} ${timeComponents[2]}");
    // DateFormat("yyyy-MM-dd h:mm a").parse("${currentDate.year}-${currentDate.month}-${currentDate.day} $hour:$minute ");

    // Get the current time

    // Calculate the time 10 minutes ago
    DateTime tenMinutesAgo = targetTime.subtract(const Duration(minutes: 10));

    // Check if the current time is equal to "12:31 AM" and before 10 minutes ago
    if (tenMinutesAgo.isBefore(targetTime)) {
      return true;
    } else {
      return false;
    }
  }

  bool isCurrentDateWithinRange(String dateRange) {
    List<String> dateParts = dateRange.split(" - ");
    if (dateParts.length == 2) {
      DateTime startDate = DateFormat('yyyy-MM-dd').parse(dateParts[0]);
      DateTime endDate = DateFormat('yyyy-MM-dd').parse(dateParts[1]);

      DateTime currentDate = DateTime.now();

      if (currentDate.isAfter(startDate) && currentDate.isBefore(endDate)) {
        return true;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }
}
