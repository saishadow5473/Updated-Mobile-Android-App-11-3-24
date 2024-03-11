import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../Modules/online_class/bloc/online_class_api_bloc.dart';
import '../../../../Modules/online_class/bloc/online_class_events.dart';
import '../../../../Modules/online_class/bloc/trainer_status/bloc/trainer_bloc.dart';
import '../../../../constants/routes.dart';
import '../../../app/config/crossbarConfig.dart';
import '../../../app/utils/appColors.dart';
import '../../../jitsi/genix_signal.dart';
import '../../../jitsi/genix_web_view_call.dart';
import '../../../module/online_serivices/bloc/online_services_api_bloc.dart';
import '../../../module/online_serivices/bloc/online_services_api_event.dart';
import '../../../module/online_serivices/bloc/search_animation_bloc/search_animation_bloc.dart';
import '../../../module/online_serivices/onilne_services_main.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../../pages/basicData/functionalities/percentage_calculations.dart';
import '../../pages/basicData/screens/ProfileCompletion.dart';
import '../../pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../../../../views/teleconsultation/viewallneeds.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../utils/SpUtil.dart';
import '../../../app/utils/appText.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../../app/utils/textStyle.dart';
import '../../../data/model/retriveUpcomingDetails/upcomingDetailsModel.dart';
import '../../pages/onlineServices/myAppointmentsTabs.dart';
import '../../pages/teleconsultation/wait_for_consultant_screen.dart';
import '../bloc_widgets/consultant_status/consultantstatus_bloc.dart';

class TeleConsultationWidgets {
  Widget teleConsultationDashboardWidget(
      {@required bool staticCard,
      Color affiColor,
      @required List<Color> linerColor,
      AppointmentList appointmentList,
      @required BuildContext context}) {
    final TabBarController _tabController = Get.find<TabBarController>();
    if (staticCard) {
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 0, 10),
              child: Text(
                AppTexts.consultation,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.3.sp,
                  color: affiColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              // PercentageCalculations().calculatePercentageFilled() != 100
              //     ? Get.to(ProfileCompletionScreen())
              //     :
              _tabController.updateSelectedIconValue(value: AppTexts.onlineServices);
              await selectedAffiliationfromuniquenameDashboard == ''
                  // ? Get.to(ViewallTeleDashboard(
                  //     backNav: null,
                  //   ))
                  ? await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(providers: [
                                BlocProvider(
                                  create: (BuildContext context) => SubscrptionFilterBloc()
                                    ..add(FilterSubscriptionEvent(
                                        filterType: "Accepted", endIndex: 30)),
                                ),
                                BlocProvider(
                                    create: (BuildContext context) => SearchAnimationBloc()),
                                BlocProvider(
                                    create: (BuildContext context) => ConsultantstatusBloc()),
                                BlocProvider(create: (BuildContext context) => TrainerBloc()),
                                BlocProvider(
                                    create: (BuildContext context) => OnlineServicesApiBloc()
                                      ..add(OnlineServicesApiEvent(data: "specialty"))),
                                BlocProvider(
                                    create: (BuildContext context) => StreamOnlineServicesApiBloc()
                                      ..add(StreamOnlineServicesApiEvent(
                                          data: "subscriptionDetails"))),
                                BlocProvider(
                                    create: (BuildContext context) => StreamOnlineClassApiBloc()
                                      ..add(StreamOnlineClassApiEvent(data: "subscriptionDetails")))
                              ], child: OnlineServicesDashboard())))
                  : await Get.to(ViewFourPillar());
              _tabController.updateSelectedIconValue(value: "Home");
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(children: [
                    Container(
                      height: 47.5.w,
                      width: 95.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                "newAssets/images/group_of_doctors.png",
                              ))),
                    ),
                    Container(
                      height: 47.5.w,
                      width: 95.w,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.topRight,
                          colors:
                              //  linerColor
                              // ?
                              //             [
                              //   Colors.orangeAccent.withOpacity(0.5),
                              //   Colors.orange.shade100.withOpacity(0.5),
                              // ]
                              // :
                              linerColor,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          // if (PercentageCalculations().calculatePercentageFilled() != 100) {
                          //   Get.to(ProfileCompletionScreen());
                          // } else {
                          _tabController.updateSelectedIconValue(value: AppTexts.onlineServices);
                          selectedAffiliationfromuniquenameDashboard == ''
                              // ? Get.to(ViewallTeleDashboard(
                              //     backNav: null,
                              //   ))
                              ? await Navigator.push(
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
                                          ], child: OnlineServicesDashboard())))
                              : await Get.to(ViewFourPillar());
                          _tabController.updateSelectedIconValue(value: "Home");

                          // }
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              padding: EdgeInsets.fromLTRB(10.sp, 6.sp, 10.sp, 6.sp),
                              decoration: BoxDecoration(boxShadow: const [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 18,
                                    spreadRadius: 1,
                                    offset: Offset(0, 5))
                              ], color: affiColor, borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 1.2.w),
                                  Text(
                                    "Book Appointment Now",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        fontSize: 10.sp,
                                        fontFamily: "Poppins"),
                                  )
                                ],
                              ),
                            )),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  const Text(
                    "Receive a complimentary online consultation \n with our expert doctors. ",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0XFF000000), height: 1.3),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      );
    }
    if (appointmentList.specality == "null") {
      appointmentList.specality = "";
    }
    CrossBarConnect statusController = CrossBarConnect();
    statusController = Get.put(CrossBarConnect());
    statusController.consultantStatus(appointmentList.ihlConsultantId);
    String userId = SpUtil.getString(LSKeys.ihlUserId);
    String name = SpUtil.getString("userName");
    DateTime currentDateTime = DateTime.now();
    DateTime appointmentStartTime1 = appointmentList.appointmentStartTime;

    DateTime fiveMinutesBeforeStartAppointment =
        appointmentStartTime1.subtract(const Duration(minutes: 5));
    DateTime thirtyMinutesAfterStartAppointment =
        appointmentStartTime1.add(const Duration(minutes: 30));
    var image;
    image ??= TabBarController().getConsultantImageUrl(doctor: appointmentList.toJson());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppTexts.todaysConsultation,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.3.sp,
                  color: affiColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              viewAll(
                  onTap: () => PercentageCalculations().calculatePercentageFilled() != 100
                      ? Get.to(ProfileCompletionScreen())
                      : Get.to(MyAppointmentsTabs(fromCall: false)),
                  // ),
                  color: affiColor)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: InkWell(
            onTap: () => log("Consulant Card Tapped"),
            child: Card(
              child: SizedBox(
                width: 100.w,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(children: [
                            FutureBuilder<String>(
                                future: TabBarController().getConsultantImageUrl(
                                    doctor: appointmentList.toJson()), // async work
                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                  try {
                                    return Container(
                                      height: 30.w,
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: MemoryImage(
                                                base64Decode(snapshot.data),
                                              ))),
                                    );
                                  } catch (e) {
                                    return Shimmer.fromColors(
                                      baseColor: Colors.white,
                                      direction: ShimmerDirection.ltr,
                                      highlightColor: Colors.grey.withOpacity(0.2),
                                      child: Container(
                                          height: 30.w,
                                          width: 30.w,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(2),
                                          )),
                                    );
                                  }
                                }),
                            const SizedBox(height: 8),
                          ]),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 10),
                            child: SizedBox(
                              width: 50.w,
                              height: 33.5.w,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(appointmentList.consultantName.capitalize,
                                      style: AppTextStyles.consultantName),
                                  Text(appointmentList.specality, style: AppTextStyles.specAndExp),
                                  Text(
                                      "${DateFormat.jm().format(appointmentList.appointmentStartTime)}  - ${DateFormat.jm().format(appointmentList.appointmentEndTime)}",
                                      style: TextStyle(
                                        color: affiColor,
                                        fontFamily: 'Poppins',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  Text("${appointmentList.experience} experience",
                                      style: AppTextStyles.specAndExp),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 6.w),
                          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                            Icon(
                              Icons.star,
                              size: 4.w,
                              color: affiColor,
                            ),
                            Text(
                              " ${appointmentList.rating} ${AppTexts.ratings}",
                              style: AppTextStyles.ratingTextInConsultant,
                            ),
                          ]),
                          const Spacer(),
                          Obx(
                            () => Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: (statusController.status.value == "Online" ||
                                                statusController.status.value == "Busy") &&
                                            currentDateTime
                                                .isAfter(fiveMinutesBeforeStartAppointment) &&
                                            currentDateTime
                                                .isBefore(thirtyMinutesAfterStartAppointment)
                                        ? (PercentageCalculations().calculatePercentageFilled() !=
                                                100)
                                            ? Get.to(ProfileCompletionScreen())
                                            : currentDateTime.isAfter(
                                                        fiveMinutesBeforeStartAppointment) &&
                                                    currentDateTime.isBefore(
                                                        thirtyMinutesAfterStartAppointment) &&
                                                    (statusController.status.value == "Online" ||
                                                        statusController.status.value == "Busy")
                                                ? appointmentList.vendorId == "GENIX"
                                                    ? () async {
                                                        Get.to(GenixWebViewCall(
                                                          genixCallDetails: GenixCallDetails(
                                                              genixAppointId:
                                                                  appointmentList.appointmentId,
                                                              ihlUserId: userId,
                                                              specality: appointmentList.specality
                                                                  .toString()),
                                                        ));
                                                      }
                                                    : () async {
                                                        TeleConsultationFunctionsAndVariables()
                                                            .permissionCheckerForCall(
                                                                nav: () => Get.offAll(WaitForConsultant(
                                                                    videoCallDetails:
                                                                        VideoCallDetail(
                                                                            appointId:
                                                                                appointmentList
                                                                                    .appointmentId,
                                                                            docId: appointmentList
                                                                                .ihlConsultantId,
                                                                            userID: userId,
                                                                            callType:
                                                                                "appointmentCall",
                                                                            ihlUserName: name))));
                                                        // Get.offNamedUntil(Routes.CallWaitingScreen,
                                                        //     (Route route) => false,
                                                        //     arguments: [
                                                        //       appointmentList.appointmentId,
                                                        //       appointmentList.ihlConsultantId,
                                                        //       userId,
                                                        //       "appointmentCall",
                                                        //       "Completed"
                                                        //     ]);
                                                      }
                                                : null

                                        // () {
                                        // if (PercentageCalculations()
                                        //         .calculatePercentageFilled() !=
                                        //     100) {

                                        // } else {
                                        //   currentDateTime.isAfter(
                                        //               fiveMinutesBeforeStartAppointment) &&
                                        //           currentDateTime.isBefore(
                                        //               thirtyMinutesAfterStartAppointment) &&
                                        //           (statusController.status.value == "Online" ||
                                        //               statusController.status.value == "Busy")
                                        //       ? appointmentList.vendorId == "GENIX"
                                        //           ? () async {
                                        //               // Get.to(GenixWebView(
                                        //               //   appointmentId: appointmentList.appointmentId,
                                        //               // ));
                                        //             }
                                        //           : () async {
                                        //               Get.offNamedUntil(
                                        //                   Routes.CallWaitingScreen,
                                        //                   (Route route) => false,
                                        //                   arguments: [
                                        //                     appointmentList.appointmentId,
                                        //                     appointmentList.ihlConsultantId,
                                        //                     userId,
                                        //                     "appointmentCall",
                                        //                     "Completed"
                                        //                   ]);
                                        //             }
                                        //       : null;
                                        // }
                                        // }
                                        : null,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: 2.w),
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white
                                                    //  statusController.status.value ==
                                                    //             "Online" &&
                                                    //         currentDateTime.isAfter(
                                                    //             fiveMinutesBeforeStartAppointment) &&
                                                    //         currentDateTime.isBefore(
                                                    //             thirtyMinutesAfterStartAppointment)
                                                    //     ? AppColors.plainColor
                                                    // : AppColors.hintTextColor
                                                    )),
                                            child: Icon(Icons.call, size: 3.w),
                                          ),
                                        ),
                                        const Text("Join Call"),
                                      ],
                                    )),
                                const SizedBox(width: 8)
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget viewAll({@required VoidCallback onTap, Color color}) {
    return Material(
      color: AppColors.backgroundScreenColor,
      child: InkWell(
        splashColor: color ?? Colors.blue,
        onTap: () {
          if (PercentageCalculations().calculatePercentageFilled() != 100) {
            Get.to(ProfileCompletionScreen());
          } else {
            onTap();
          }
        },
        child: Row(
          children: [
            Text("View All ",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11.sp, color: Colors.black)),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13.sp,
              color: color ?? AppColors.primaryColor,
            )
          ],
        ),
      ),
    );
  }

  Widget viewAllServices({@required VoidCallback onTap, Color color, bool profileCheckUp = true}) {
    return InkWell(
      // splashColor: color == null ? Colors.blue : color,
      onTap: profileCheckUp
          ? () {
              PercentageCalculations().calculatePercentageFilled() != 100
                  ? Get.to(ProfileCompletionScreen())
                  : onTap();
            }
          : onTap,
      child: Row(
        children: [
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15.sp,
            weight: 10.sp,
            color: color ?? AppColors.primaryColor,
          )
        ],
      ),
    );
  }
}
