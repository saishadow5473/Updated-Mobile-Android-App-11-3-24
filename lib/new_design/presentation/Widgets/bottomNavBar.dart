import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../Getx/controller/BannerChallengeController.dart';
import '../../../Modules/online_class/bloc/trainer_status/bloc/trainer_bloc.dart';
import '../../../Modules/online_class/functionalities/upcoming_courses.dart';
import '../../../views/teleconsultation/viewallneeds.dart';
import '../../module/online_serivices/bloc/online_services_api_bloc.dart';
import '../../module/online_serivices/bloc/online_services_api_event.dart';
import '../../module/online_serivices/bloc/search_animation_bloc/search_animation_bloc.dart';
import '../../module/online_serivices/onilne_services_main.dart';
import '../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../pages/basicData/functionalities/percentage_calculations.dart';
import '../../../Modules/online_class/bloc/online_class_api_bloc.dart';
import '../../../Modules/online_class/bloc/online_class_events.dart';
import '../pages/basicData/screens/ProfileCompletion.dart';
import '../pages/onlineServices/consultationStagesVideoCall.dart';
import '../pages/onlineServices/onlineServicesTabs.dart';
import '../pages/social/social.dart';
import 'package:sizer/sizer.dart';

import '../../app/utils/appColors.dart';
import '../../app/utils/appText.dart';
import '../../app/utils/imageAssets.dart';
import '../../app/utils/textStyle.dart';
import '../controllers/dashboardControllers/dashBoardContollers.dart';
import '../pages/healthProgram/healthProgramTabs.dart';
import '../pages/manageHealthscreens/manageHealthScreentabs.dart';
import 'bloc_widgets/consultant_status/consultantstatus_bloc.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TabBarController tabController = Get.find();
    {
      return GetBuilder<TabBarController>(
        id: "navigation_icons",
        builder: (_) {
          return Stack(
              alignment: const FractionalOffset(.5, 1.0),

              //alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(
                    decoration: BoxDecoration(
                        color: AppColors.plainColor,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.2),
                              blurRadius: 3,
                              spreadRadius: 3,
                              offset: const Offset(0, 1))
                        ],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(40.0),
                          topLeft: Radius.circular(40.0),
                        )),
                    height: Platform.isAndroid ? 8.h : 10.h,
                    width: 100.w,
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.h, bottom: 1.h, left: 3.w, right: 3.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Get.toNamed(Routes.teleConsultation);
                                    if (_.selectedBottomIcon != AppTexts.onlineServices) {
                                      _.updateSelectedIconValue(value: AppTexts.onlineServices);
                                      // /*Old Online Services Dashboard*/
                                      // Get.to(ViewallTel  eDashboard(
                                      //   includeHelthEmarket: true,
                                      // ));
                                      // Get.to(ConsultationStagesVideoCall());

                                      /*New Online Services Dashboard*/
                                      TeleConsultationFunctionsAndVariables.allMedicalFilesList();
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
                                      /*New Online Services Dashboard without merge*/
                                      // Get.to(MultiBlocProvider(providers: [
                                      //   BlocProvider(create: (BuildContext context) => TrainerBloc()),
                                      //     BlocProvider(create: (BuildContext context) => ConsultantstatusBloc()),
                                      //   BlocProvider(
                                      //       create: (BuildContext context) => OnlineClassApiBloc()
                                      //         ..add(OnlineClassApiEvent(data: "specialty"))),
                                      //   BlocProvider(
                                      //       create: (BuildContext context) =>
                                      //           StreamOnlineClassApiBloc()
                                      //             ..add(StreamOnlineClassApiEvent(
                                      //                 data: "subscriptionDetails"))),
                                      // ], child: const OnlineServicesTabs()));
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 2.5.h,
                                        child: Image(
                                            image: _.selectedBottomIcon == AppTexts.onlineServices
                                                ? ImageAssets.selectedOnlineServicesImage
                                                : ImageAssets.onlineServicesImage),
                                      ),
                                      Text(
                                        AppTexts.onlineServices,
                                        style: (_.selectedBottomIcon == AppTexts.onlineServices)
                                            ? AppTextStyles.bottomNavigationBar
                                            : AppTextStyles.bottomNavigationBar2,
                                        softWrap: false,
                                      )
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (_.selectedBottomIcon != "Manage Health") {
                                      _.updateSelectedIconValue(value: AppTexts.manageHealth);
                                      //Get.toNamed(Routes.myVitals);
                                      PercentageCalculations().calculatePercentageFilled() != 100
                                          ? Get.to(ProfileCompletionScreen())
                                          : Get.to(ManageHealthScreenTabs());
                                    } //Uncomment this line when working in New Manage Health Screens
                                    // Get.to(() => DashBoardNavigation(
                                    //     title: 'Manage Health',
                                    //     backNav: true,
                                    //     navigationList: NewDashBoardNavigation.manageHealth));
                                  },
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        height: 2.5.h,
                                        child: Image(
                                          image: _.selectedBottomIcon == AppTexts.manageHealth
                                              ? ImageAssets.selectedManageHealth
                                              : ImageAssets.manageHealth,
                                        ),
                                      ),
                                      Text(
                                        AppTexts.manageHealth,
                                        style: (_.selectedBottomIcon == AppTexts.manageHealth)
                                            ? AppTextStyles.bottomNavigationBar
                                            : AppTextStyles.bottomNavigationBar2,
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 14.w,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _.updateSelectedIconValue(value: AppTexts.healthProgramms);
                                    PercentageCalculations().calculatePercentageFilled() != 100
                                        ? Get.to(ProfileCompletionScreen())
                                        : Get.to(HealthProgramTabs(
                                            fromDashboard: false,
                                          )); //TODO New Health Program Tabs
                                    // TODO Old Health Program Dashboard
                                    // Get.to(() => DashBoardNavigation(
                                    //     title: 'Health Programs',
                                    //     backNav: true,
                                    //     navigationList: NewDashBoardNavigation.healthProgram));
                                  },
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 2.5.h,
                                        child: Image(
                                          image: _.selectedBottomIcon == AppTexts.healthProgramms
                                              ? ImageAssets.SelectedhealthProgram
                                              : ImageAssets.healthProgram,
                                        ),
                                      ),
                                      Text(
                                        AppTexts.healthProgramms,
                                        style: (_.selectedBottomIcon == AppTexts.healthProgramms)
                                            ? AppTextStyles.bottomNavigationBar
                                            : AppTextStyles.bottomNavigationBar2,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 4.w),
                                  child: InkWell(
                                    onTap: () {
                                      tabController.updateProgramsTab(val: 0);
                                      Get.put(BannerChallengeController()).challengeVisibleType =
                                          'social';
                                      Get.to(const Social());
                                      // Get.to(() => DashBoardNavigation(
                                      //     title: 'Social',
                                      //     backNav: true,
                                      //     navigationList: Platform.isAndroid
                                      //         ? NewDashBoardNavigation.socialNavigation
                                      //         : NewDashBoardNavigation.socialNavigationIOS));
                                      _.updateSelectedIconValue(value: AppTexts.Social);
                                    },
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 2.5.h,
                                          child: Image(
                                            image: _.selectedBottomIcon == AppTexts.Social
                                                ? ImageAssets.selecetedSocial
                                                : ImageAssets.social,
                                          ),
                                        ),
                                        SizedBox(
                                          child: Text(
                                            AppTexts.Social,
                                            style: (_.selectedBottomIcon == AppTexts.Social)
                                                ? AppTextStyles.bottomNavigationBar
                                                : AppTextStyles.bottomNavigationBar2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
                // Container(
                //   //alignment: Alignment.topCenter,
                //   decoration: const BoxDecoration(
                //       color: Colors.white,
                //       shape: BoxShape.circle,
                //       boxShadow: [
                //         BoxShadow(
                //             color: Colors.grey, spreadRadius: 0.5, blurRadius: 2, offset: Offset(0, 5))
                //       ]),
                //   height: 7.h,
                //   width: 17.w,
                //   child: Padding(
                //     padding: EdgeInsets.all(4.w),
                //     child: InkWell(
                //         onTap: () {
                //           Get.toNamed(Routes.home);
                //         },
                //         child: TitleAvatar(image: "Assets/Icons/Home.png")),
                //   ),
                // ),
              ]);
        },
      );
    }
  }
}
