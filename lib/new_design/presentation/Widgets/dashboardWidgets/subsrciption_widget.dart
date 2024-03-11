import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../Modules/online_class/bloc/online_class_api_bloc.dart';
import '../../../../Modules/online_class/bloc/online_class_events.dart';
import '../../../../Modules/online_class/bloc/trainer_status/bloc/trainer_bloc.dart';
import '../../../../Modules/online_class/presentation/pages/view_all_class.dart';
import '../../../../utils/SpUtil.dart';
import '../../../module/online_serivices/bloc/online_services_api_bloc.dart';
import '../../../module/online_serivices/bloc/online_services_api_event.dart';
import '../../../module/online_serivices/bloc/search_animation_bloc/search_animation_bloc.dart';
import '../../../module/online_serivices/functionalities/online_services_dashboard_functionalities.dart';
import '../../../module/online_serivices/onilne_services_main.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../controllers/dashboardControllers/upComingDetailsController.dart';
import '../../pages/basicData/functionalities/percentage_calculations.dart';
import '../../../data/model/retriveUpcomingDetails/upcomingDetailsModel.dart';
import '../../../data/providers/network/apis/classImageApi/classImageApi.dart';
import '../../pages/basicData/screens/ProfileCompletion.dart';
import '../bloc_widgets/consultant_status/consultantstatus_bloc.dart';
import 'affiliation_widgets.dart';
import 'teleconsultation_widget.dart';
import '../../controllers/dashboardControllers/ststusCheckController.dart';
import '../../pages/spalshScreen/splashScreen.dart';
import '../../../../views/dietJournal/activity/activity_detail.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../views/teleconsultation/MySubscription.dart';
import '../../../../views/teleconsultation/specialityType.dart';
import '../../../../views/teleconsultation/videocall/CallWaitingScreen.dart';
import '../../../app/config/crossbarConfig.dart';
import '../../../app/utils/appColors.dart';
import '../../../app/utils/appText.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../clippath/subscriptionTagClipPath.dart';

import '../../pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';

var allClassValues;
Timer endTimer;
Timer startTimer;

class SubscriptionWidgets {
  final OnlineServicesFunctions _onlineServicesFunction = OnlineServicesFunctions();
  final TabBarController _tabController = Get.find<TabBarController>();
  Widget subscriptionCard({
    @required BuildContext context,
    @required bool staticCard,
    SubcriptionList subcriptionList,
    Color afficolor,
    Map affi,
  }) {
    if (staticCard) {
      return Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 0, 10),
              child: Text(
                "Online Session",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.3.sp,
                  letterSpacing: 0.5,
                  color: afficolor ?? AppColors.primaryAccentColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              String uniqueName = UpdatingColorsBasedOnAffiliations.ssoAffiliation.toString();
              log(uniqueName);
              // if (PercentageCalculations().calculatePercentageFilled() != 100) {
              //   Get.to(ProfileCompletionScreen());
              // } else {
              if (eMarketaff || uniqueName.contains("null") == true) {
                if (affi == null) {
                  // Get.to(SpecialityTypeScreen(arg: allClassValues));
                  _tabController.updateSelectedIconValue(
                      value: AppTexts.onlineServices);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(providers: [
                            BlocProvider(
                              create: (BuildContext context) =>
                              SubscrptionFilterBloc()
                                ..add(FilterSubscriptionEvent(
                                    filterType: "Accepted", endIndex: 30)),
                            ),
                            BlocProvider(
                                create: (BuildContext context) =>
                                    SearchAnimationBloc()),
                            BlocProvider(
                                create: (BuildContext context) =>
                                    ConsultantstatusBloc()),
                            BlocProvider(
                                create: (BuildContext context) => TrainerBloc()),
                            BlocProvider(
                                create: (BuildContext context) =>
                                OnlineServicesApiBloc()
                                  ..add(OnlineServicesApiEvent(
                                      data: "specialty"))),
                            BlocProvider(
                                create: (BuildContext context) =>
                                StreamOnlineServicesApiBloc()
                                  ..add(StreamOnlineServicesApiEvent(
                                      data: "subscriptionDetails"))),
                            BlocProvider(
                                create: (BuildContext context) =>
                                StreamOnlineClassApiBloc()
                                  ..add(StreamOnlineClassApiEvent(
                                      data: "subscriptionDetails")))
                          ], child: OnlineServicesDashboard())));
                  // Get.to(SpecialityTypeScreen(arg: allClassValues));
                  // openTocDialog(context,
                  //     on_Tap: Get.to(SpecialityTypeScreen(arg: allClassValues)),
                  //     ontap_Available: true);
                } else {
                  Get.to(SpecialityTypeScreen(arg: affi));
                  eMarketaff = true;
                }
              } else {
                Get.to( ViewFourPillar());
                // Get.to(ClassAndConsultantScreen(
                //   companyName: selectedAffiliationfromuniquenameDashboard,
                //   // companyName: "Dev Testing",
                // ));
              }
              // }
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6.0,
                      spreadRadius: 1,
                      offset: const Offset(1, -1)),
                ],
              ),
              child: Card(
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 47.5.w,
                      width: 95.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                "newAssets/images/online_class_static_card.png",
                              ))),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Explore our latest sessions. Subscribe and start your wellness journey.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Poppins",
                          color: const Color(0XFF000000),
                          // letterSpacing: 0.4,
                          height: 1.3,
                          fontSize: 11.sp),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: InkWell(
                          onTap: () {
                            String uniqueName =
                                UpdatingColorsBasedOnAffiliations.ssoAffiliation.toString();
                            log(uniqueName);
                            // if (PercentageCalculations().calculatePercentageFilled() != 100) {
                            //   Get.to(ProfileCompletionScreen());
                            // } else {
                            if (eMarketaff || uniqueName.contains("null") == true) {
                              _tabController.updateSelectedIconValue(
                                  value: AppTexts.onlineServices);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(providers: [
                                        BlocProvider(
                                          create: (BuildContext context) =>
                                          SubscrptionFilterBloc()
                                            ..add(FilterSubscriptionEvent(
                                                filterType: "Accepted",
                                                endIndex: 30)),
                                        ),
                                        BlocProvider(
                                            create: (BuildContext context) =>
                                                SearchAnimationBloc()),
                                        BlocProvider(
                                            create: (BuildContext context) =>
                                                ConsultantstatusBloc()),
                                        BlocProvider(
                                            create: (BuildContext context) =>
                                                TrainerBloc()),
                                        BlocProvider(
                                            create: (BuildContext context) =>
                                            OnlineServicesApiBloc()
                                              ..add(OnlineServicesApiEvent(
                                                  data: "specialty"))),
                                        BlocProvider(
                                            create: (BuildContext context) =>
                                            StreamOnlineServicesApiBloc()
                                              ..add(StreamOnlineServicesApiEvent(
                                                  data: "subscriptionDetails"))),
                                        BlocProvider(
                                            create: (BuildContext context) =>
                                            StreamOnlineClassApiBloc()
                                              ..add(StreamOnlineClassApiEvent(
                                                  data: "subscriptionDetails")))
                                      ], child: OnlineServicesDashboard())));
                              // if (affi == null) {
                              //   Get.to(SpecialityTypeScreen(arg: allClassValues));
                              //   // openTocDialog(context,
                              //   //     on_Tap: Get.to(SpecialityTypeScreen(arg: allClassValues)),
                              //   //     ontap_Available: true);
                              // } else {
                              //   Get.to(SpecialityTypeScreen(arg: affi));
                              //   eMarketaff = true;
                              // }
                            } else {
                              Get.to( ViewFourPillar());
                              // Get.to(ClassAndConsultantScreen(
                              //   companyName: selectedAffiliationfromuniquenameDashboard,
                              //   // companyName: "Dev Testing",
                              // ));
                            }
                            // }
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(18.sp, 8.sp, 18.sp, 8.sp),
                            decoration: BoxDecoration(
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.grey.shade400,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 3))
                                ],
                                color: afficolor ?? AppColors.primaryAccentColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(
                              "BOOK YOUR SPOT",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  fontSize: 9.sp,
                                  fontFamily: "Poppins"),
                            ),
                          ),
                        )),
                    SizedBox(height: 2.5.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    String courseTime = subcriptionList.courseTime.length == 18
        ? subcriptionList.courseTime
        : _onlineServicesFunction.adjustHourLength(subcriptionList.courseTime);
    bool enableButton = false;
    DateTime courseStartDate =
        DateFormat("yyyy-MM-dd").parse(subcriptionList.courseDuration.substring(0, 12));
    String temp = subcriptionList.courseDuration.substring(13, 23);
    //unslash for the hard code run ⚪⚪
    // temp = "2023-11-16";
    // courseTime = "09:01 AM - 04:22 PM";
    DateTime courseEndDate = DateFormat("yyyy-MM-dd").parse(temp);
    DateTime currentDate = DateFormat("yyyy-MM-dd").parse(DateTime.now().toString());
    String currentDateTime = DateFormat.jm().format(DateTime.now());
    int finalCurrentTime = currentDateTime.length == 7
        ? currentDateTime.substring(5, 7) == "PM"
            ? currentDateTime.substring(0, 2) == "12"
                ? int.parse(currentDateTime.substring(0, 1))
                : int.parse(currentDateTime.substring(0, 1)) + 12
            : int.parse(currentDateTime.substring(0, 1))
        : currentDateTime.substring(6, 8) == "PM"
            ? currentDateTime.substring(0, 2) == "12"
                ? int.parse(currentDateTime.substring(0, 2))
                : int.parse(currentDateTime.substring(0, 2)) + 12
            : int.parse(currentDateTime.substring(0, 2));

    int finalCurrentMinute = currentDateTime.length == 7
        ? int.parse(currentDateTime.substring(2, 4))
        : int.parse(currentDateTime.substring(3, 5));
    String courseStartTime = courseTime.length == 17
        ? courseTime.substring(0, 7)
        : courseTime.length == 18
            ? courseTime[1] == ":"
                ? courseTime.substring(0, 7)
                : courseTime.substring(0, 8)
            : courseTime.substring(0, 8);
    int finalStartTime = courseStartTime.length == 7
        ? courseStartTime.substring(5, 7) == "PM"
            ? courseStartTime.substring(0, 1) == "12"
                ? int.parse(courseStartTime.substring(0, 1))
                : int.parse(courseStartTime.substring(0, 1)) + 12
            : int.parse(courseStartTime.substring(0, 1))
        : courseStartTime.substring(6, 8) == "PM"
            ? courseStartTime.substring(0, 2) == "12"
                ? int.parse(courseStartTime.substring(0, 2))
                : int.parse(courseStartTime.substring(0, 2)) + 12
            : int.parse(courseStartTime.substring(0, 2));
    int finalStartMinute = courseStartTime.length == 7
        ? int.parse(courseStartTime.substring(2, 4))
        : int.parse(courseStartTime.substring(3, 5));
    CrossBarConnect statusController = Get.put(CrossBarConnect());
    StatusController apiStatusController = Get.put(StatusController());
    statusController.consultantStatus(subcriptionList.consultantId);
    apiStatusController.updateStatus(subcriptionList.consultantId);
    List<String> courseList = <String>[];
    courseList.add(subcriptionList.courseId);
    int secheduledTime = finalCurrentTime <= finalStartTime ? finalStartTime - finalCurrentTime : 1;
    int duration = secheduledTime == 0 || secheduledTime == 1
        ? finalCurrentMinute <= finalStartMinute
            ? finalStartMinute - finalCurrentMinute
            : 0
        : 60;
    bool externalUrlIsNull =
        subcriptionList.externalUrl == null || subcriptionList.externalUrl == "";
    if (externalUrlIsNull) {
      Timer(Duration(minutes: duration), () async {
        finalCurrentMinute = finalStartMinute;
        await apiStatusController.updateStatus(subcriptionList.consultantId);
      });
    }
    else {
      bool startIsAM = courseTime.substring(6, 8).toLowerCase().contains("am");
      bool endIsAM = courseTime.substring(18, courseTime.length).toLowerCase().contains("am");
      log("${courseTime.substring(14, 16)} << min  Hour>> ${courseTime.substring(12, 13)}");
      List<String> list = courseTime.split('').toList();
      int startMin;

      startMin = int.parse(courseTime.substring(3, 5));
      int startHour = int.parse(courseTime.substring(0, 2));

      int endMin;
      try {
        endMin = int.parse(courseTime.substring(14, 16)); // Issue Fixed by Jabaseelan
      } catch (e) {
        endMin = int.parse(courseTime.substring(13, 14)); // Issue Fixed by Jabaseelan
      }
      int endHour = int.parse(courseTime.substring(11, 13));
      !startIsAM ? startHour += 12 : null;
      !endIsAM ? endHour += 12 : null;
      DateTime startTime =
          DateTime(currentDate.year, currentDate.month, currentDate.day, startHour, startMin);

      DateTime endTime =
          DateTime(currentDate.year, currentDate.month, currentDate.day, endHour, endMin);
      DateTime currentTime = DateTime.now();
      Duration difference = Duration(minutes: endTime.minute - currentTime.minute);
      int dur = 0;
      if (currentTime.isAfter(startTime)) {
        log("start timing $dur");
        dur = startTime.difference(currentTime).inMinutes;
      } else {
        dur = 0;
      }
      log("end timing${difference.inMinutes}");
      if (endTime.isAfter(currentTime) && courseEndDate.isAfter(currentTime)) {
        log("Timer Enabled for the External URL ${subcriptionList.externalUrl}");
        if (dur <= 0) {
          enableButton = true;
          endTimer ??= Timer(difference, () async {
            log("Join button switched to disable state");
            enableButton = false;
            // finalCurrentMinute = finalStartMinute;
            endTimer.cancel();
            Get.put(UpcomingDetailsController()).update(<String>["user_upcoming_detils"]);
          });
        } else {
          startTimer ??= Timer(Duration(minutes: dur), () async {
            log("Join button switched to enable state");
            enableButton = true;
            finalCurrentMinute = finalStartMinute;
            startTimer.cancel();
            Get.put(UpcomingDetailsController()).update(<String>["user_upcoming_detils"]);
          });
          endTimer ??= Timer(difference, () async {
            log("Join button switched to disable state");
            enableButton = false;
            // finalCurrentMinute = finalStartMinute;
            endTimer.cancel();
            Get.put(UpcomingDetailsController()).update(<String>["user_upcoming_detils"]);
          });
        }
      }
    }

    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: <Widget>[
                Text(
                  AppTexts.mySubscription,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.3.sp,
                    color: afficolor ?? AppColors.primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                TeleConsultationWidgets().viewAll(
                    onTap: () {
                      if (PercentageCalculations().calculatePercentageFilled() != 100) {
                        Get.to(ProfileCompletionScreen());
                      } else {
                        localSotrage.write("healthEmarketNavigation", false);
                        // Get.to(const MySubscription(
                        //   afterCall: false,
                        //   onlineCourse: true,
                        // ));
                        /*New View all subscription*/
                        _tabController.updateSelectedIconValue(
                            value: AppTexts.onlineServices);
                        Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                                builder: (BuildContext ctx) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                            create: (BuildContext context) => TrainerBloc()),
                                      ],
                                      child: ViweAllClass(
                                        subcriptionList: const [],
                                          isHome :"Yes"

                                      ),
                                    )));
                      }
                    },
                    color: afficolor)
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: Card(
            elevation: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(clipBehavior: Clip.none, children: <Widget>[
                  FutureBuilder<dynamic>(
                    builder: (BuildContext ctx, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        List<String> image = snapshot.data[0]['base_64'].split(',');
                        Uint8List bytes1;
                        bytes1 = const Base64Decoder().convert(image[1].toString());
                        return SizedBox(
                          height: 47.5.w,
                          width: 95.w,
                          child: bytes1 == null
                              ? const Placeholder()
                              : Image.memory(bytes1, fit: BoxFit.fill),
                        );
                      }
                      if (snapshot.hasError) {
                        return Shimmer.fromColors(
                          direction: ShimmerDirection.ltr,
                          enabled: true,
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.shade300,
                          child: Container(
                            height: 40.5.w,
                            width: 90.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          direction: ShimmerDirection.ltr,
                          enabled: true,
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.shade400,
                          child: Container(
                            height: 40.5.w,
                            width: 90.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }
                      return Shimmer.fromColors(
                        baseColor: Colors.white,
                        direction: ShimmerDirection.ltr,
                        highlightColor: Colors.grey.withOpacity(0.2),
                        child: Container(
                          height: 47.5.w,
                          width: 95.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    },
                    future: ClassImage().getCourseImageURL(courseList),
                  ),
                  SizedBox(
                    child: ClipPath(
                      clipper: SubscriptionClipPath(),
                      child: Container(
                        color: afficolor ?? AppColors.primaryAccentColor,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Text(
                              subcriptionList.course_frequency,
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'Poppins', fontSize: 12.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 1.8.h),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${subcriptionList.title}: ${subcriptionList.course_description} "
                        .toString()
                        .replaceAll("&#39;", "")
                        .replaceAll('&amp;n', '&')
                        .replaceAll('&quot;n', " ")
                        .replaceAll("&#160;n", " ")
                        .capitalize,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0XFF000000)),
                  ),
                ),
                SizedBox(height: 1.4.h),
                Row(
                  children: <Widget>[
                    SizedBox(width: 8.w),
                    const Spacer(
                      flex: 3,
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text("${subcriptionList.current_available}  "),
                        Text(
                          subcriptionList.courseTime,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.3.sp,
                            color: afficolor ?? AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const Spacer(),
                    Visibility(
                      visible: externalUrlIsNull,
                      replacement: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 12.sp, 0),
                        child: SizedBox(
                            height: 8.w,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: afficolor ?? AppColors.primaryAccentColor),
                                onPressed: enableButton
                                    ? () async {
                                        Uri url = Uri.parse(subcriptionList.externalUrl);
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      }
                                    : null,
                                child: const FittedBox(child: Text('JOIN')))),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 12.sp, 0),
                        child: SizedBox(
                            height: 8.w,
                            child: Obx(
                              () => ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: afficolor ?? AppColors.primaryAccentColor),
                                  onPressed: externalUrlIsNull &&
                                              apiStatusController.apiStatus.value == "Online" ||
                                          apiStatusController.apiStatus.value == "Busy"
                                      ? (statusController.status.value == "Online" ||
                                              statusController.status.value == "Busy")
                                          ? (currentDate.isAfterOrEqualTo(courseStartDate)) &&
                                                  currentDate.isBeforeOrEqualTo(courseEndDate)
                                              ? finalCurrentTime == finalStartTime &&
                                                      finalCurrentMinute >= finalStartMinute
                                                  ? () async {
                                                      SharedPreferences prefs =
                                                          await SharedPreferences.getInstance();
                                                      String userID =
                                                          localSotrage.read(LSKeys.ihlUserId);
                                                      prefs.setString(
                                                          "userIDFromSubscriptionCall",
                                                          userID ??
                                                              SpUtil.getString(LSKeys.ihlUserId));
                                                      prefs.setString(
                                                          "consultantIDFromSubscriptionCall",
                                                          subcriptionList.consultantId);
                                                      prefs.setString(
                                                          "subscriptionIDFromSubscriptionCall",
                                                          subcriptionList.subscriptionId);
                                                      prefs.setString(
                                                          "courseNameFromSubscriptionCall",
                                                          subcriptionList.title);
                                                      prefs.setString(
                                                          "courseIDFromSubscriptionCall",
                                                          subcriptionList.courseId);
                                                      prefs.setString(
                                                          "trainerNameFromSubscriptionCall",
                                                          subcriptionList.consultantName);
                                                      prefs.setString(
                                                          'providerFromSubscriptionCall',
                                                          subcriptionList.provider);
                                                      Get.off(
                                                        CallWaitingScreen(
                                                          appointmentDetails: <dynamic>[
                                                            subcriptionList.courseId,
                                                            userID,
                                                            subcriptionList.consultantId,
                                                            "SubscriptionCall",
                                                            subcriptionList.consultantId,
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  : null
                                              : null
                                          : null
                                      : null,
                                  child: const FittedBox(child: Text('JOIN'))),
                            )),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 1.8.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
