import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../Modules/online_class/bloc/trainer_status/bloc/trainer_bloc.dart';
import '../../../../../Modules/online_class/presentation/pages/view_all_class.dart';
import '../../../../../constants/api.dart';
import '../../../../../constants/routes.dart';
import '../../../../../constants/spKeys.dart';
import '../../../../../health_challenge/networks/network_calls.dart';
import '../../../../../models/freesubscription_model.dart';
import '../../../../../utils/SpUtil.dart';
import '../../../../../widgets/teleconsulation/subscriptionPayment/subscription_payment_page.dart';
import '../../../../presentation/controllers/teleconsultation_onlineServices/common_token_genrator.dart';
import '../../../../presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../Modules/online_class/about_class.dart';
import '../../../../../Modules/online_class/presentation/pages/reviews_and_ratings.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../app/utils/textStyle.dart';
import '../../../../data/providers/network/apis/classImageApi/classImageApi.dart';
import '../../../../presentation/clippath/subscriptionTagClipPath.dart';
import '../../../../presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../../../../presentation/pages/spalshScreen/splashScreen.dart';
import '../../bloc/book_slot_class/book_slot_bloc.dart';
import '../../data/model/class_session_modle.dart';
import '../../data/model/get_spec_class_list.dart';
import '../../functionalities/online_services_dashboard_functionalities.dart';

class BookClassbeforeSubscription extends StatelessWidget {
  SpecialityClassList classDetail;
  BookClassbeforeSubscription({Key key, @required this.classDetail}) : super(key: key);
  final OnlineServicesFunctions _onlineServicesFunction = OnlineServicesFunctions();
  final String selectedAffi = selectedAffiliationfromuniquenameDashboard ?? "global_services";
  final SelectSlotButtonBloc slotBloc = SelectSlotButtonBloc();
  final ConfirmSubscriptionBloc buttonBloc = ConfirmSubscriptionBloc();
  final CommonTokens commomTkon = CommonTokens();
  final http.Client _client = http.Client();
  @override
  Widget build(BuildContext context) {
    // Assuming _onlineServicesFunction is an instance of the class containing the parseCourseDurationYYMMDD method.
    // classDetail is an instance of the class containing the courseDuration property.
    // Parse start and end dates
    final DateTime parseStartDate =
        _onlineServicesFunction.parseCourseDurationYYMMDD(classDetail.courseDuration)[0];
    final DateTime parseEndDate =
        _onlineServicesFunction.parseCourseDurationYYMMDD(classDetail.courseDuration)[1];
    Map<String, List<List<String>>> sessionMap = {
      "Morning": [],
      "Afternoon": [],
      "Evening": [],
      "Night": []
    };
    // Create formatted date strings
    final String startDateString =
        "${parseStartDate.day}-${parseStartDate.month}-${parseStartDate.year}";
    final String endDateString = "${parseEndDate.day}-${parseEndDate.month}-${parseEndDate.year}";
    List<Session> slotSession = _onlineServicesFunction.splitSessions(classDetail.courseTime);
    for (Session element in slotSession) {
      sessionMap[element.timeOfDay].add([element.startTime, element.endTime]);
    }
    int sessionsAval = _onlineServicesFunction.getNoSessionsAvailable(sessionMap) == 0
        ? 1
        : _onlineServicesFunction.getNoSessionsAvailable(sessionMap);
    return CommonScreenForNavigation(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text("Class Detail", style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 8, right: 8.0),
                    child: Container(
                      height: 27.h,
                      width: 96.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: ClassImage().getCourseImageURL([classDetail.courseId]),
                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        List<String> image = snapshot.data[0]['base_64'].split(',');
                        Uint8List bytes1;
                        bytes1 = const Base64Decoder().convert(image[1].toString());
                        return bytes1 == null
                            ? const Placeholder()
                            : Padding(
                                padding: const EdgeInsets.only(left: 12, right: 12),
                                child: Column(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 20.0),
                                          child: Container(
                                            height: 25.h,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    offset: const Offset(1, 1),
                                                    spreadRadius: 2,
                                                    blurRadius: 2,
                                                    color: Colors.grey.shade300)
                                              ],
                                              border: Border.all(
                                                  width: 0.7.w,
                                                  color: AppColors.primaryColor.withOpacity(0.2)),
                                              borderRadius:
                                                  const BorderRadius.all(Radius.circular(8.0)),
                                              image: DecorationImage(
                                                  image: Image.memory(
                                                    base64Decode(image[1].toString()),
                                                  ).image,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 20.0),
                                          child: SizedBox(
                                            child: ClipPath(
                                              clipper: SubscriptionClipPath(),
                                              child: Container(
                                                color: AppColors.primaryAccentColor,
                                                child: FittedBox(
                                                  fit: BoxFit.fill,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                    child: Text(
                                                      classDetail.feesFor,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: 'Poppins',
                                                          fontSize: 12.sp),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20.0, left: 12, right: 12),
                          child: Shimmer.fromColors(
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
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20.0, left: 12, right: 12),
                          child: Shimmer.fromColors(
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
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 12, right: 12),
                        child: Shimmer.fromColors(
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
                        ),
                      );
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Container(
                  // height: 60.h,
                  width: 96.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
                        child: Text(
                          classDetail.title.capitalizeFirst,
                          style: AppTextStyles.primaryColorText,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 82.w,
                          child: Column(children: [
                            Row(
                              children: [
                                const Text("Trainer"),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Text(classDetail.consultantName)
                              ],
                            ),
                            const Divider(
                              color: Colors.black,
                            ),
                            Row(
                              children: [
                                const Text("Duration"),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Text(classDetail.courseDuration)
                              ],
                            ),
                            const Divider(
                              color: Colors.black,
                            ),
                            Row(
                              children: [
                                const Text("Status"),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Text(classDetail.courseStatus)
                              ],
                            ),
                            const Divider(
                              color: Colors.black,
                            ),
                            Visibility(
                              visible: classDetail.affilationExcusiveData.affilationArray.isNotEmpty
                                  ? int.parse(classDetail.affilationExcusiveData.affilationArray[0]
                                          .affilationPrice) >
                                      0
                                  : classDetail.courseFeesMrp > 0,
                              child: Row(
                                children: [
                                  const Text("Price"),
                                  SizedBox(
                                    width: 23.w,
                                  ),
                                  classDetail.affilationExcusiveData.affilationArray != null &&
                                          classDetail
                                              .affilationExcusiveData.affilationArray.isNotEmpty
                                      ? Text(classDetail.affilationExcusiveData.affilationArray[0]
                                          .affilationPrice)
                                      : Text(classDetail.courseFeesMrp.toString()),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  const Text("₹")
                                ],
                              ),
                            ),
                            Visibility(
                              visible: classDetail.affilationExcusiveData.affilationArray != null &&
                                      classDetail.affilationExcusiveData.affilationArray.isNotEmpty
                                  ? int.parse(classDetail.affilationExcusiveData.affilationArray[0]
                                          .affilationPrice) >
                                      0
                                  : classDetail.courseFeesMrp > 0,
                              child: const Divider(
                                color: Colors.black,
                              ),
                            ),
                          ]),
                        ),
                      ),
                      BlocProvider(
                        create: (BuildContext blocProviderContext) =>
                            SelectSlotButtonBloc()..add(SlotButtonUnSelectionEvent()),
                        child: BlocBuilder<SelectSlotButtonBloc, SlotButtonState>(
                            bloc: slotBloc,
                            builder: (BuildContext blocCntxt, SlotButtonState slotSate) {
                              return Column(
                                children: [
                                  Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 4.2.w,
                                              height: 2.h,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: AppColors.primaryAccentColor),
                                                  borderRadius: BorderRadius.circular(10)),
                                            ),
                                            SizedBox(
                                              width: 3.w,
                                            ),
                                            Text(
                                              "Available Slot",
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                            SizedBox(
                                              width: 3.w,
                                            ),
                                            Container(
                                              width: 4.2.w,
                                              height: 2.h,
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: AppColors.greenColor),
                                                  color: AppColors.greenColor,
                                                  borderRadius: BorderRadius.circular(10)),
                                            ),
                                            SizedBox(
                                              width: 3.w,
                                            ),
                                            Text("Selected Slot",
                                                style: TextStyle(fontSize: 14.sp)),
                                            SizedBox(
                                              width: 3.w,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: sessionsAval * 15.h,
                                        width: 90.w,
                                        child: ListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: sessionMap.keys.length,
                                            itemBuilder: (BuildContext ctx, int sessionLen) {
                                              log(sessionsAval.toString());
                                              log(sessionMap[sessionMap.keys.elementAt(sessionLen)]
                                                  .toString());
                                              return Column(
                                                children: [
                                                  Visibility(
                                                    visible: sessionMap[
                                                            sessionMap.keys.elementAt(sessionLen)]
                                                        .isNotEmpty,
                                                    replacement: Container(),
                                                    child: SizedBox(
                                                      width: 90.w,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceAround,
                                                        children: [
                                                          // Icon(_onlineServicesFunction.getSessionIcon(
                                                          //     sessionMap.keys.elementAt(sessionLen))),
                                                          const Spacer(
                                                            flex: 1,
                                                          ),
                                                          Image.asset(
                                                            'newAssets/Icons/${sessionMap.keys.elementAt(sessionLen)}.png',
                                                            width: 6.w,
                                                            height: 4.h,
                                                          ),
                                                          SizedBox(
                                                            width: 1.5.w,
                                                          ),
                                                          Text(
                                                            sessionMap.keys.elementAt(sessionLen),
                                                            style: const TextStyle(
                                                                color: AppColors.primaryAccentColor,
                                                                fontWeight: FontWeight.bold),
                                                          ),

                                                          const Spacer(
                                                            flex: 12,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: sessionMap[
                                                            sessionMap.keys.elementAt(sessionLen)]
                                                        .isNotEmpty,
                                                    replacement: Container(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(vertical: 5.0),
                                                      child: SizedBox(
                                                          // height: 6.h,
                                                          width: 100.w,
                                                          child: Wrap(
                                                            children: sessionMap[sessionMap.keys
                                                                    .elementAt(sessionLen)]
                                                                .map((e) {
                                                              int slotLen = sessionMap[sessionMap
                                                                      .keys
                                                                      .elementAt(sessionLen)]
                                                                  .indexWhere(
                                                                      (element) => element == e);
                                                              return Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: slotSate
                                                                        is SlotButtonSelectedState
                                                                    ? slotSate.slotTime ==
                                                                            sessionMap[sessionMap
                                                                                    .keys
                                                                                    .elementAt(
                                                                                        sessionLen)]
                                                                                [slotLen][0]
                                                                        ? ElevatedButton(
                                                                            style: ButtonStyle(
                                                                                shape: MaterialStateProperty
                                                                                    .all<
                                                                                        OutlinedBorder>(
                                                                                  RoundedRectangleBorder(
                                                                                    side:
                                                                                        const BorderSide(
                                                                                      color: AppColors
                                                                                          .greenColor, // Change the color to the desired border color
                                                                                      width:
                                                                                          2.0, // Set the border width
                                                                                    ),
                                                                                    borderRadius:
                                                                                        BorderRadius
                                                                                            .circular(
                                                                                                8.0), // Adjust the border radius
                                                                                  ),
                                                                                ),
                                                                                backgroundColor:
                                                                                    MaterialStateProperty
                                                                                        .all<Color>(
                                                                                            AppColors
                                                                                                .greenColor)),
                                                                            onPressed: () {
                                                                              slotBloc.add(SlotButtonUnSelectionEvent(
                                                                                  slotTime: sessionMap[
                                                                                          sessionMap
                                                                                              .keys
                                                                                              .elementAt(
                                                                                                  sessionLen)]
                                                                                      [
                                                                                      slotLen][0]));
                                                                            },
                                                                            child: Text(sessionMap[
                                                                                    sessionMap.keys
                                                                                        .elementAt(
                                                                                            sessionLen)]
                                                                                [slotLen][0]),
                                                                          )
                                                                        : ElevatedButton(
                                                                            style: ButtonStyle(
                                                                                shape: MaterialStateProperty
                                                                                    .all<
                                                                                        OutlinedBorder>(
                                                                                  RoundedRectangleBorder(
                                                                                    side:
                                                                                        const BorderSide(
                                                                                      color: AppColors
                                                                                          .primaryAccentColor, // Change the color to the desired border color
                                                                                      width:
                                                                                          2.0, // Set the border width
                                                                                    ),
                                                                                    borderRadius:
                                                                                        BorderRadius
                                                                                            .circular(
                                                                                                8.0), // Adjust the border radius
                                                                                  ),
                                                                                ),
                                                                                backgroundColor:
                                                                                    MaterialStateProperty
                                                                                        .all<Color>(
                                                                                            AppColors
                                                                                                .appBackgroundColor)),
                                                                            onPressed: () {
                                                                              slotBloc.add(SlotButtonSelectionEvent(
                                                                                  timeSlotList: sessionMap[
                                                                                          sessionMap
                                                                                              .keys
                                                                                              .elementAt(
                                                                                                  sessionLen)]
                                                                                      [slotLen],
                                                                                  slotTime: sessionMap[
                                                                                          sessionMap
                                                                                              .keys
                                                                                              .elementAt(
                                                                                                  sessionLen)]
                                                                                      [
                                                                                      slotLen][0]));
                                                                            },
                                                                            child: Text(
                                                                              sessionMap[sessionMap
                                                                                      .keys
                                                                                      .elementAt(
                                                                                          sessionLen)]
                                                                                  [slotLen][0],
                                                                              style: const TextStyle(
                                                                                  color: AppColors
                                                                                      .primaryAccentColor),
                                                                            ),
                                                                          )
                                                                    : ElevatedButton(
                                                                        style: ButtonStyle(
                                                                            shape: MaterialStateProperty
                                                                                .all<
                                                                                    OutlinedBorder>(
                                                                              RoundedRectangleBorder(
                                                                                side:
                                                                                    const BorderSide(
                                                                                  color: AppColors
                                                                                      .primaryAccentColor, // Change the color to the desired border color
                                                                                  width:
                                                                                      2.0, // Set the border width
                                                                                ),
                                                                                borderRadius:
                                                                                    BorderRadius
                                                                                        .circular(
                                                                                            8.0), // Adjust the border radius
                                                                              ),
                                                                            ),
                                                                            backgroundColor:
                                                                                MaterialStateProperty
                                                                                    .all<Color>(
                                                                                        AppColors
                                                                                            .appBackgroundColor)),
                                                                        onPressed: () {
                                                                          slotBloc.add(SlotButtonSelectionEvent(
                                                                              timeSlotList: sessionMap[
                                                                                      sessionMap
                                                                                          .keys
                                                                                          .elementAt(
                                                                                              sessionLen)]
                                                                                  [slotLen],
                                                                              slotTime: sessionMap[
                                                                                      sessionMap
                                                                                          .keys
                                                                                          .elementAt(
                                                                                              sessionLen)]
                                                                                  [slotLen][0]));
                                                                        },
                                                                        child: Text(
                                                                          sessionMap[sessionMap.keys
                                                                                  .elementAt(
                                                                                      sessionLen)]
                                                                              [slotLen][0],
                                                                          style: const TextStyle(
                                                                              color: AppColors
                                                                                  .primaryAccentColor),
                                                                        ),
                                                                      ),
                                                              );
                                                            }).toList(),
                                                          )
                                                          //  ListView.builder(
                                                          //     scrollDirection: Axis.horizontal,
                                                          //     itemCount: sessionMap[sessionMap.keys
                                                          //             .elementAt(sessionLen)]
                                                          //         .length,
                                                          //     itemBuilder:
                                                          //         (BuildContext cntx, int slotLen) {
                                                          //       return Padding(
                                                          //         padding: const EdgeInsets.all(8.0),
                                                          //         child: slotSate
                                                          //                 is SlotButtonSelectedState
                                                          //             ? slotSate.slotTime ==
                                                          //                     sessionMap[sessionMap
                                                          //                             .keys
                                                          //                             .elementAt(
                                                          //                                 sessionLen)]
                                                          //                         [slotLen][0]
                                                          //                 ? ElevatedButton(
                                                          //                     style: ButtonStyle(
                                                          //                         shape: MaterialStateProperty
                                                          //                             .all<
                                                          //                                 OutlinedBorder>(
                                                          //                           RoundedRectangleBorder(
                                                          //                             side:
                                                          //                                 const BorderSide(
                                                          //                               color: AppColors
                                                          //                                   .greenColor, // Change the color to the desired border color
                                                          //                               width:
                                                          //                                   2.0, // Set the border width
                                                          //                             ),
                                                          //                             borderRadius:
                                                          //                                 BorderRadius
                                                          //                                     .circular(
                                                          //                                         8.0), // Adjust the border radius
                                                          //                           ),
                                                          //                         ),
                                                          //                         backgroundColor:
                                                          //                             MaterialStateProperty
                                                          //                                 .all<Color>(
                                                          //                                     AppColors
                                                          //                                         .greenColor)),
                                                          //                     onPressed: () {
                                                          //                       slotBloc.add(SlotButtonUnSelectionEvent(
                                                          //                           slotTime: sessionMap[
                                                          //                                   sessionMap
                                                          //                                       .keys
                                                          //                                       .elementAt(
                                                          //                                           sessionLen)]
                                                          //                               [
                                                          //                               slotLen][0]));
                                                          //                     },
                                                          //                     child: Text(sessionMap[
                                                          //                             sessionMap.keys
                                                          //                                 .elementAt(
                                                          //                                     sessionLen)]
                                                          //                         [slotLen][0]),
                                                          //                   )
                                                          //                 : ElevatedButton(
                                                          //                     style: ButtonStyle(
                                                          //                         shape: MaterialStateProperty
                                                          //                             .all<
                                                          //                                 OutlinedBorder>(
                                                          //                           RoundedRectangleBorder(
                                                          //                             side:
                                                          //                                 const BorderSide(
                                                          //                               color: AppColors
                                                          //                                   .primaryAccentColor, // Change the color to the desired border color
                                                          //                               width:
                                                          //                                   2.0, // Set the border width
                                                          //                             ),
                                                          //                             borderRadius:
                                                          //                                 BorderRadius
                                                          //                                     .circular(
                                                          //                                         8.0), // Adjust the border radius
                                                          //                           ),
                                                          //                         ),
                                                          //                         backgroundColor:
                                                          //                             MaterialStateProperty
                                                          //                                 .all<Color>(
                                                          //                                     AppColors
                                                          //                                         .appBackgroundColor)),
                                                          //                     onPressed: () {
                                                          //                       slotBloc.add(SlotButtonSelectionEvent(
                                                          //                           timeSlotList: sessionMap[
                                                          //                                   sessionMap
                                                          //                                       .keys
                                                          //                                       .elementAt(
                                                          //                                           sessionLen)]
                                                          //                               [slotLen],
                                                          //                           slotTime: sessionMap[
                                                          //                                   sessionMap
                                                          //                                       .keys
                                                          //                                       .elementAt(
                                                          //                                           sessionLen)]
                                                          //                               [
                                                          //                               slotLen][0]));
                                                          //                     },
                                                          //                     child: Text(
                                                          //                       sessionMap[sessionMap
                                                          //                               .keys
                                                          //                               .elementAt(
                                                          //                                   sessionLen)]
                                                          //                           [slotLen][0],
                                                          //                       style: const TextStyle(
                                                          //                           color: AppColors
                                                          //                               .primaryAccentColor),
                                                          //                     ),
                                                          //                   )
                                                          //             : ElevatedButton(
                                                          //                 style: ButtonStyle(
                                                          //                     shape: MaterialStateProperty
                                                          //                         .all<
                                                          //                             OutlinedBorder>(
                                                          //                       RoundedRectangleBorder(
                                                          //                         side:
                                                          //                             const BorderSide(
                                                          //                           color: AppColors
                                                          //                               .primaryAccentColor, // Change the color to the desired border color
                                                          //                           width:
                                                          //                               2.0, // Set the border width
                                                          //                         ),
                                                          //                         borderRadius:
                                                          //                             BorderRadius
                                                          //                                 .circular(
                                                          //                                     8.0), // Adjust the border radius
                                                          //                       ),
                                                          //                     ),
                                                          //                     backgroundColor:
                                                          //                         MaterialStateProperty
                                                          //                             .all<Color>(
                                                          //                                 AppColors
                                                          //                                     .appBackgroundColor)),
                                                          //                 onPressed: () {
                                                          //                   slotBloc.add(SlotButtonSelectionEvent(
                                                          //                       timeSlotList: sessionMap[
                                                          //                               sessionMap
                                                          //                                   .keys
                                                          //                                   .elementAt(
                                                          //                                       sessionLen)]
                                                          //                           [slotLen],
                                                          //                       slotTime: sessionMap[
                                                          //                               sessionMap
                                                          //                                   .keys
                                                          //                                   .elementAt(
                                                          //                                       sessionLen)]
                                                          //                           [slotLen][0]));
                                                          //                 },
                                                          //                 child: Text(
                                                          //                   sessionMap[sessionMap.keys
                                                          //                           .elementAt(
                                                          //                               sessionLen)]
                                                          //                       [slotLen][0],
                                                          //                   style: const TextStyle(
                                                          //                       color: AppColors
                                                          //                           .primaryAccentColor),
                                                          //                 ),
                                                          //               ),
                                                          //       );
                                                          //     }),
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: BlocProvider(
                                      create: (BuildContext buttonContext) =>
                                          ConfirmSubscriptionBloc(),
                                      child: BlocBuilder<ConfirmSubscriptionBloc,
                                              ConfirmButtonState>(
                                          bloc: buttonBloc,
                                          builder: (BuildContext buttonContext,
                                              ConfirmButtonState buttonState) {
                                            return ElevatedButton(
                                                style: buttonState is ConfimrButtonInitialState
                                                    ? ButtonStyle(
                                                        shape: MaterialStateProperty.all<
                                                            OutlinedBorder>(
                                                          RoundedRectangleBorder(
                                                            side: const BorderSide(
                                                              color: AppColors
                                                                  .appBackgroundColor, // Change the color to the desired border color
                                                              width: 2.0, // Set the border width
                                                            ),
                                                            borderRadius: BorderRadius.circular(
                                                                8.0), // Adjust the border radius
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            MaterialStateProperty.all<Color>(
                                                                AppColors.primaryAccentColor))
                                                    : ButtonStyle(
                                                        shape: MaterialStateProperty.all<
                                                            OutlinedBorder>(
                                                          RoundedRectangleBorder(
                                                            side: BorderSide(
                                                              color: slotSate
                                                                      is SlotButtonSelectedState
                                                                  ? AppColors.appBackgroundColor
                                                                  : AppColors
                                                                      .primaryAccentColor, // Change the color to the desired border color
                                                              width: 2.0, // Set the border width
                                                            ),
                                                            borderRadius: BorderRadius.circular(
                                                                8.0), // Adjust the border radius
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            MaterialStateProperty.all<Color>(
                                                                slotSate is SlotButtonSelectedState
                                                                    ? AppColors.primaryAccentColor
                                                                    : Colors.white)),
                                                onPressed: slotSate is SlotButtonSelectedState
                                                    ? buttonState is ConfimrButtonInitialState
                                                        ? null
                                                        : () async {
                                                            buttonBloc
                                                                .add(ConfirmButtonApiCallEvnet());
                                                            SharedPreferences prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            var response = await callAoi(
                                                                context,
                                                                prefs,
                                                                classDetail,
                                                                slotSate.slotTime,
                                                                slotSate.timeSlotList);
                                                            buttonBloc.add(ConfirmButtonApiResponse(
                                                                apiResponse: response));
                                                            if (response == "Success subscribed") {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute<dynamic>(
                                                                      builder: (BuildContext ctx) =>
                                                                          MultiBlocProvider(
                                                                            providers: [
                                                                              BlocProvider(
                                                                                  create: (BuildContext
                                                                                          context) =>
                                                                                      TrainerBloc()),
                                                                            ],
                                                                            child: ViweAllClass(
                                                                              subcriptionList: const [],
                                                                            ),
                                                                          )));
                                                            }
                                                          }
                                                    : null,
                                                child: buttonState is ConfimrButtonInitialState
                                                    ? SizedBox(
                                                        height: 3.5.h,
                                                        width: 7.w,
                                                        child: const CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    // ? Shimmer.fromColors(
                                                    //     direction: ShimmerDirection.ltr,
                                                    //     period: const Duration(seconds: 2),
                                                    //     highlightColor:
                                                    //         width: 20.w,
                                                    //         height: 1.h,
                                                    //         decoration: BoxDecoration(
                                                    //           color: Colors.white,
                                                    //           borderRadius:
                                                    //               BorderRadius.circular(10),
                                                    //         ),
                                                    //         child: const Text('Hello')))
                                                    : Text(
                                                        "Confirm Subscription",
                                                        style: TextStyle(
                                                            color:
                                                                slotSate is SlotButtonSelectedState
                                                                    ? AppColors.appBackgroundColor
                                                                    : AppColors.primaryAccentColor),
                                                      ));
                                          }),
                                    ),
                                  )
                                ],
                              );
                            }),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              GestureDetector(
                onTap: () {
                  Get.to(AboutClass(
                    courseId: classDetail.courseId,
                    desc: classDetail.courseDescription,
                    title: classDetail.title,
                  ));
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  height: 10.h,
                  width: 96.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent, borderRadius: BorderRadius.circular(20.w)),
                          height: 12.w,
                          width: 12.w,
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'newAssets/Icons/about class.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("About"),
                            SizedBox(
                                width: 55.w,
                                child: Text(classDetail.courseDescription.capitalizeFirst,
                                    overflow: TextOverflow.ellipsis, softWrap: false, maxLines: 1))
                          ],
                        ),
                      ),
                      const Spacer()
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              GestureDetector(
                onTap: () {
                  Get.to(ReviewsAndRatings(
                    ratings: classDetail.ratings.toString(),
                    ratingsList: classDetail.textReviewsData,
                  ));
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  height: 10.h,
                  width: 96.w,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent, borderRadius: BorderRadius.circular(20.w)),
                          height: 12.w,
                          width: 12.w,
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'newAssets/Icons/class rating.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Reviews & Ratings"),
                            SizedBox(
                              height: 1.h,
                            ),
                            SizedBox(
                              width: 55.w,
                              child: RatingBar.builder(
                                ignoreGestures: true,
                                initialRating: double.parse(classDetail.ratings),
                                minRating: 0,
                                itemSize: 2.5.h,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                itemBuilder: (BuildContext context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amberAccent,
                                ),
                                onRatingUpdate: (double value) {},
                              ),
                              // child: Text(courseDetailState.courseDetail.courseDescription,
                              //     softWrap: false,maxLines:1)
                            )
                          ],
                        ),
                      ),
                      const Spacer()
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ));
  }

  callAoi(BuildContext context, SharedPreferences prefs, SpecialityClassList classDetail,
      String selectedTime, List<String> timeSlotList) async {
    if (selectedAffi == "none") {
      int _fees = classDetail.courseFees != 'Free' &&
              classDetail.courseFees != 'free' &&
              classDetail.courseFees != 'FREE' &&
              classDetail.courseFees != 'N/A' &&
              classDetail.courseFees != '0' &&
              classDetail.courseFees != '00' &&
              classDetail.courseFees != '000' &&
              classDetail.courseFees != '0.0'
          ? int.parse(classDetail.courseFees.toString())
          : 0;
      if (classDetail.courseFees == 'Free' ||
          classDetail.courseFees == 'free' ||
          classDetail.courseFees == 'FREE' ||
          classDetail.courseFees == '0' ||
          classDetail.courseFees == '00' ||
          classDetail.courseFees == 0 ||
          _fees == 0 ||
          _fees < 1) {
        String apiToken = prefs.get('auth_token');
        var email = prefs.get('email');
        var data = prefs.get('data');
        Map res = jsonDecode(data);
        var firstName = res['User']['firstName'];
        var lastName = res['User']['lastName'];
        var mobile = res['User']['mobileNumber'];
        var ihlUserID = res['User']['id'];
        var courseDate = SpUtil.getString("selectedDateFromPicker");
        var courseTime = SpUtil.getString("selectedTime") == ""
            ? "${timeSlotList[0]} - ${timeSlotList[1]}"
            : SpUtil.getString("selectedTime");
        List<DateTime> parsedData =
            _onlineServicesFunction.parseCourseDurationDDMMYY(classDetail.courseDuration);
        var startDate =
            "${parsedData[0].month < 10 ? "0${parsedData[0].month}" : "${parsedData[0].month}"}/${parsedData[0].day < 10 ? "0${parsedData[0].day}" : "${parsedData[0].day}"}/${parsedData[0].year}";
        String endDate =
            "${parsedData[1].month < 10 ? "0${parsedData[1].month}" : "${parsedData[1].month}"}/${parsedData[1].day < 10 ? "0${parsedData[1].day}" : "${parsedData[1].day}"}/${parsedData[1].year}";
        print("${startDate} -  ${endDate}");
        //Change date format from 09-12-2020 - 08-06-2021 to 09/12/2020 - 08/06/2021
        Map<String, dynamic> subscribeData = {
          "user_ihl_id": ihlUserID,
          "course_id": classDetail.courseId,
          "name": "$firstName $lastName",
          "email": email.toString(),
          "mobile_number": mobile.toString(),
          "course_type": classDetail.courseType,
          "course_time": "${timeSlotList[0]} - ${timeSlotList[1]}",
          "provider": classDetail.provider,
          "fees_for": classDetail.feesFor,
          "consultant_name": classDetail.consultantName,
          "course_duration": ("$startDate - $endDate"),
          "course_fees": classDetail.courseFees,
          "consultation_id": classDetail.consultantId,
          "approval_status": classDetail.autoApprove ? "Accepted" : 'Requested',
        };
        List<String> courseDurationStart = classDetail.courseDuration.split(" - ");
        String classStartTime = DateFormat('yyyy-MM-dd hh:mm aaa').format(
            DateFormat('dd-MM-yyyy hh:mm aaa').parse("${courseDurationStart[1]} $selectedTime"));
        var _courseDerationDateTime = DateFormat('dd-MM-yyyy').parse(courseDurationStart[0]);
        var _courseDurationFormated = DateFormat('MM/dd/yyyy').format(_courseDerationDateTime);
        FreeSubscription _freeSubScription = FreeSubscription(
            consultantName: classDetail.consultantName,
            affiliationUniqueName: selectedAffi != "none" ? selectedAffi : "global_services",
            approvalStatus: classDetail.autoApprove ? "Accepted" : 'Requested',
            availableSlotCount: classDetail.availableSlotCount,
            availableSlot: classDetail.availableSlot,
            className: classDetail.title,
            consultationId: classDetail.consultantId,
            courseDuration: ("$startDate - $endDate"),
            courseId: classDetail.courseId,
            courseImgUrl: '',
            email: email,
            userMobileNumber: mobile,
            mobileNumber: mobile,
            purposeDetails: jsonEncode(subscribeData),
            courseOn: classDetail.courseOn,
            courseTime: "${timeSlotList[0]} - ${timeSlotList[1]}",
            courseType: classDetail.courseType,
            feesFor: classDetail.feesFor,
            title: classDetail.title,
            provider: classDetail.provider,
            transactionMode: '',
            reasonForVisit: '',
            serviceProvidedDate: classStartTime,
            userEmail: email,
            subscriberCount: classDetail.subscriberCount.toString(),
            userIhlId: ihlUserID,
            name: "$firstName $lastName",
            time: courseTime.toString(),
            date: _courseDurationFormated);
        log(DateTime.now().toString());
        try {
          var _freeSubRes = await Dio().post('${API.iHLUrl}/consult/free_subscription',
              data: _freeSubScription.toJson(),
              options: Options(headers: {
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              }));
          log(DateTime.now().toString());
          if (_freeSubRes.statusCode == 200) {
            final getUserDetails = await _client.post(
              Uri.parse("${API.iHLUrl}/consult/get_user_details"),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              },
              body: jsonEncode(<String, dynamic>{
                'ihl_id': ihlUserID,
              }),
            );
            if (getUserDetails.statusCode == 200) {
              buttonBloc.add(ConfirmButtonApiResponse(apiResponse: "${getUserDetails.statusCode}"));
              final userDetailsResponse = await SharedPreferences.getInstance();
              userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
              localSotrage.write("subNav", true);
              Navigator.push(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext ctx) => ViweAllClass(
                          subscribed: true,
                          subcriptionList: [],
                        )),
              );
            }
          } else {
            AwesomeDialog(
                    context: context,
                    animType: AnimType.TOPSLIDE,
                    headerAnimationLoop: true,
                    dialogType: DialogType.ERROR,
                    dismissOnTouchOutside: false,
                    title: 'Error!',
                    desc: 'Booking Class failed!',
                    btnOkOnPress: () {
                      Navigator.of(context).pop(true);
                    },
                    btnOkColor: Colors.red,
                    btnOkText: 'Try again !',
                    onDismissCallback: (_) {})
                .show();
          }
        } catch (e) {
          print(e);
          AwesomeDialog(
                  context: context,
                  animType: AnimType.TOPSLIDE,
                  headerAnimationLoop: true,
                  dialogType: DialogType.ERROR,
                  dismissOnTouchOutside: false,
                  title: 'Error!',
                  desc: 'Booking Class failed!',
                  btnOkOnPress: () {
                    Navigator.of(context).pop(true);
                  },
                  btnOkColor: Colors.red,
                  btnOkText: 'Try again !',
                  onDismissCallback: (_) {})
              .show();
        }
        /*
          //Code to send notification through crossbar Starts --->

          List<String> receiverIds = [];
          receiverIds
          //.add(widget.details['doctor']['ihl_consultant_id'].toString());
              .add(widget.course['consultant_id'].toString());
          var abcd = [];
          abcd.add('GenerateNotification');
          abcd.add('SubscriptionClass');
          abcd.add('$receiverIds');
          abcd.add('$ihlUserID');
          abcd.add('$subscriptionId');
          print(abcd.toString());
          s.appointmentPublish(
              'GenerateNotification',
              'SubscriptionClass',
              receiverIds,
              ihlUserID,
              subscriptionId.toString());*/
        //Code to send notification through crossbar Ends --->
      } else {
        List<String> courseDurationStart = classDetail.courseDuration.split(" - ");
        String classStartTime = DateFormat('yyyy-MM-dd hh:mm aaa').format(
            DateFormat('dd-MM-yyyy hh:mm aaa').parse("${courseDurationStart[1]} $selectedTime"));
        var _courseDerationDateTime = DateFormat('dd-MM-yyyy').parse(courseDurationStart[0]);
        var _courseDurationFormated = DateFormat('MM/dd/yyyy').format(_courseDerationDateTime);
        List<DateTime> parsedData =
            _onlineServicesFunction.parseCourseDurationDDMMYY(classDetail.courseDuration);
        var startDate =
            "${parsedData[0].month < 10 ? "0${parsedData[0].month}" : "${parsedData[0].month}"}/${parsedData[0].day < 10 ? "0${parsedData[0].day}" : "${parsedData[0].day}"}/${parsedData[0].year}";
        var endDate =
            "${parsedData[1].month < 10 ? "0${parsedData[1].month}" : "${parsedData[1].month}"}/${parsedData[1].day < 10 ? "0${parsedData[1].day}" : "${parsedData[1].day}"}/${parsedData[1].year}";

        var sendData = dataToSend(classDetail.courseFees.toString(), ("$startDate - $endDate"));
        sendData['consultant_id'] = classDetail.consultantId;
        sendData['course_time'] = "${timeSlotList[0]} - ${timeSlotList[1]}";
        sendData['consultant_name'] = classDetail.consultantName;
        sendData['title'] = classDetail.title;
        sendData['AffilationUniqueName'] =
            selectedAffi != 'none' ? selectedAffi : 'global_services';
        sendData['appointment_duration'] = "";
        sendData['affiliationPrice'] = classDetail.courseFees;
        sendData['classStartTime'] = classStartTime;
        sendData['course_duration'] = ("$startDate - $endDate");
        buttonBloc.add(ConfirmButtonApiResponse(apiResponse: "Payment"));
        Navigator.of(context).pushNamed(Routes.SubscriptionPaymentPage, arguments: sendData);
      }
    } else if (selectedAffi != "none") {
      var affiprice = 0;
      classDetail.affilationExcusiveData.affilationArray.forEach((AffilationArray element) {
        if (element.affilationUniqueName == selectedAffi) {
          affiprice = int.parse(element.affilationPrice);
        }
      });

      if (affiprice < 1) {
        String apiToken = prefs.get('auth_token');
        var email = prefs.get('email');
        var data = prefs.get('data');
        Map res = jsonDecode(data);
        var firstName = res['User']['firstName'];
        var lastName = res['User']['lastName'];
        var mobile = res['User']['mobileNumber'];
        var ihlUserID = res['User']['id'];
        var courseDate = SpUtil.getString("selectedDateFromPicker");
        var courseTime = SpUtil.getString("selectedTime") == ""
            ? "${timeSlotList[0]} - ${timeSlotList[1]}"
            : SpUtil.getString("selectedTime");

        List<DateTime> parsedData =
            _onlineServicesFunction.parseCourseDurationDDMMYY(classDetail.courseDuration);
        var startDate =
            "${parsedData[0].month < 10 ? "0${parsedData[0].month}" : "${parsedData[0].month}"}/${parsedData[0].day < 10 ? "0${parsedData[0].day}" : "${parsedData[0].day}"}/${parsedData[0].year}";
        var endDate =
            "${parsedData[1].month < 10 ? "0${parsedData[1].month}" : "${parsedData[1].month}"}/${parsedData[1].day < 10 ? "0${parsedData[1].day}" : "${parsedData[1].day}"}/${parsedData[1].year}";

        //Change date format from 09-12-2020 - 08-06-2021 to 09/12/2020 - 08/06/2021
        Map<String, dynamic> subscribeData = {
          "user_ihl_id": ihlUserID,
          "course_id": classDetail.courseId,
          "name": "$firstName $lastName",
          "email": email,
          "mobile_number": mobile,
          "course_type": classDetail.courseType,
          "course_time": "${timeSlotList[0]} - ${timeSlotList[1]}",
          "provider": classDetail.provider,
          "fees_for": classDetail.feesFor,
          "consultant_name": classDetail.consultantName,
          "course_duration": ("$startDate - $endDate"),
          "course_fees": affiprice,
          "consultation_id": classDetail.consultantId,
          "approval_status": classDetail.autoApprove ? "Accepted" : 'Requested',
        };
        log(subscribeData.toString());
        List<String> courseDurationStart = classDetail.courseDuration.split(" - ");
        String classStartTime = DateFormat('yyyy-MM-dd hh:mm aaa').format(
            DateFormat('dd-MM-yyyy hh:mm aaa').parse("${courseDurationStart[1]} $selectedTime"));
        var _courseDerationDateTime = DateFormat('dd-MM-yyyy').parse(courseDurationStart[0]);
        var _courseDurationFormated = DateFormat('MM/dd/yyyy').format(_courseDerationDateTime);
        FreeSubscription _freeSubScription = FreeSubscription(
            consultantName: classDetail.consultantName,
            affiliationUniqueName: selectedAffi,
            approvalStatus: classDetail.autoApprove ? "Accepted" : 'Requested',
            availableSlotCount: classDetail.availableSlotCount,
            availableSlot: classDetail.availableSlot,
            className: classDetail.title,
            consultationId: classDetail.consultantId,
            courseDuration: ("$startDate - $endDate"),
            courseId: classDetail.courseId,
            courseImgUrl: '',
            email: email,
            userMobileNumber: mobile,
            mobileNumber: mobile,
            purposeDetails: jsonEncode(subscribeData),
            courseOn: classDetail.courseOn,
            courseTime: courseTime.toString(),
            courseType: classDetail.courseType,
            feesFor: classDetail.feesFor,
            title: classDetail.title,
            provider: classDetail.provider,
            transactionMode: '',
            reasonForVisit: '',
            serviceProvidedDate: classStartTime,
            userEmail: email,
            subscriberCount: classDetail.subscriberCount.toString(),
            userIhlId: ihlUserID,
            name: "$firstName $lastName",
            time: courseTime.toString(),
            date: _courseDurationFormated);
        log(_freeSubScription.toJson().toString());
        try {
          var _freeSubRes = await Dio().post('${API.iHLUrl}/consult/free_subscription',
              data: _freeSubScription.toJson(),
              options: Options(headers: {
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              }));
          if (_freeSubRes.statusCode == 200) {
            final getUserDetails = await _client.post(
              Uri.parse("${API.iHLUrl}/consult/get_user_details"),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              },
              body: jsonEncode(<String, dynamic>{
                'ihl_id': ihlUserID,
              }),
            );
            if (getUserDetails.statusCode == 200) {
              buttonBloc.add(ConfirmButtonApiResponse(apiResponse: "${getUserDetails.statusCode}"));
              final userDetailsResponse = await SharedPreferences.getInstance();
              userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
              localSotrage.write("subNav", true);
              Navigator.push(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext ctx) => ViweAllClass(
                          subscribed: true,
                          subcriptionList: [],
                        )),
              );
            }
          } else {
            AwesomeDialog(
                    context: context,
                    animType: AnimType.TOPSLIDE,
                    headerAnimationLoop: true,
                    dialogType: DialogType.ERROR,
                    dismissOnTouchOutside: false,
                    title: 'Error!',
                    desc: 'Booking Class failed!',
                    btnOkOnPress: () {
                      Navigator.of(context).pop(true);
                    },
                    btnOkColor: Colors.red,
                    btnOkText: 'Try again !',
                    onDismissCallback: (_) {})
                .show();
          }
        } catch (e) {
          print(e);
          AwesomeDialog(
                  context: context,
                  animType: AnimType.TOPSLIDE,
                  headerAnimationLoop: true,
                  dialogType: DialogType.ERROR,
                  dismissOnTouchOutside: false,
                  title: 'Error!',
                  desc: 'Booking Class failed!',
                  btnOkOnPress: () {
                    Navigator.of(context).pop(true);
                  },
                  btnOkColor: Colors.red,
                  btnOkText: 'Try again !',
                  onDismissCallback: (_) {})
              .show();
        }
      } else {
        List<String> courseDurationStart = classDetail.courseDuration.split(" - ");
        String classStartTime = DateFormat('yyyy-MM-dd hh:mm aaa').format(
            DateFormat('dd-MM-yyyy hh:mm aaa').parse("${courseDurationStart[1]} $selectedTime"));
        var _courseDerationDateTime = DateFormat('dd-MM-yyyy').parse(courseDurationStart[0]);
        var _courseDurationFormated = DateFormat('MM/dd/yyyy').format(_courseDerationDateTime);
        print(affiprice);
        List<DateTime> parsedData =
            _onlineServicesFunction.parseCourseDurationDDMMYY(classDetail.courseDuration);
        var startDate =
            "${parsedData[0].month < 10 ? "0${parsedData[0].month}" : "${parsedData[0].month}"}/${parsedData[0].day < 10 ? "0${parsedData[0].day}" : "${parsedData[0].day}"}/${parsedData[0].year}";
        var endDate =
            "${parsedData[1].month < 10 ? "0${parsedData[1].month}" : "${parsedData[1].month}"}/${parsedData[1].day < 10 ? "0${parsedData[1].day}" : "${parsedData[1].day}"}/${parsedData[1].year}";
        var sendData = dataToSend(affiprice.toString(), ("$startDate - $endDate"));
        print(affiprice);
        sendData['consultant_id'] = classDetail.consultantId;
        sendData['consultant_name'] = classDetail.consultantName;
        sendData['title'] = classDetail.title;
        sendData['course_time'] = "${timeSlotList[0]} - ${timeSlotList[1]}";
        sendData['AffilationUniqueName'] = selectedAffi ?? "global_services";
        sendData['appointment_duration'] = "";
        sendData['affiliationPrice'] = affiprice.toString();
        sendData['classStartTime'] = classStartTime;
        sendData['course_duration'] = ("$startDate - $endDate");
        buttonBloc.add(ConfirmButtonApiResponse(apiResponse: "Stored"));
        Navigator.of(context).pushNamed(Routes.SubscriptionPaymentPage, arguments: sendData);
        // } else {
        //   print(paymentInitiateResponse.body);
        //   AwesomeDialog(
        //           context: context,
        //           animType: AnimType.TOPSLIDE,
        //           headerAnimationLoop: true,
        //           dialogType: DialogType.ERROR,
        //           dismissOnTouchOutside: false,
        //           title: 'Error!',
        //           desc: 'Payment initiation failed!',
        //           btnOkOnPress: () {
        //             Navigator.of(context).pop(true);
        //           },
        //           btnOkColor: Colors.red,
        //           btnOkText: 'Done',
        //           onDismissCallback: (_) {})
        //       .show();
        // }
      }
    }
  }

  Map dataToSend(String price, var courseDuration) {
    return {
      "title": classDetail.title,
      "course_id": classDetail.courseId,
      "course_on": classDetail.courseOn,
      "course_type": classDetail.courseType,
      "provider": classDetail.provider,
      "fees_for": classDetail.feesFor,
      "consultant_name": classDetail.consultantName,
      "consultant_gender": classDetail.consultantGender,
      "course_fees": price,
      "consultant_id": classDetail.consultantId,
      "subscriber_count": classDetail.subscriberCount,
      "available_slot_count": classDetail.availableSlotCount,
      "course_duration": courseDuration,
      "available_slot": classDetail.availableSlot,
      "approval_status": classDetail.autoApprove ? "Accepted" : 'Requested',
    };
  }

  String getValidFormattedString(originalDateRange) {
    //  String originalDateRange = '14-09-2023 - 27-12-2023';

    List<String> dateParts = originalDateRange.split(' - ');

    String startDateString = dateParts[0];
    String endDateString = dateParts[1];

    DateTime startDate = DateFormat('dd-MM-yyyy').parse(startDateString);
    DateTime endDate = DateFormat('dd-MM-yyyy').parse(endDateString);

    String formattedStartDate = DateFormat('dd/MM/yyyy').format(startDate);
    String formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate);

    String formattedDateRange = '$formattedStartDate - $formattedEndDate';

    return formattedDateRange;
  }
}
