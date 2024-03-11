import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Modules/online_class/bloc/online_class_api_bloc.dart';
import '../../../../Modules/online_class/bloc/online_class_events.dart';
import '../../../../Modules/online_class/bloc/trainer_status/bloc/trainer_bloc.dart';
import '../../../../Modules/online_class/functionalities/upcoming_courses.dart';
import '../../../../constants/api.dart';
import '../../../../constants/spKeys.dart';
import '../../../../notification_controller.dart';
import '../../../../views/splash_screen.dart';
import '../../../module/online_serivices/bloc/online_services_api_bloc.dart';
import '../../../module/online_serivices/bloc/online_services_api_event.dart';
import '../../../module/online_serivices/bloc/search_animation_bloc/search_animation_bloc.dart';
import '../../../module/online_serivices/onilne_services_main.dart';
import '../../Widgets/bloc_widgets/consultant_status/consultantstatus_bloc.dart';
import '../../Widgets/varientBannerWidgets.dart';
import '../../controllers/getTokenContoller/getTokenController.dart';
import '../../controllers/healthTipsController/healthTipsController.dart';
import '../../controllers/vitalDetailsController/myVitalsController.dart';
import '../../../../cardio_dashboard/views/cardio_dashboard_new.dart';
import '../basicData/functionalities/percentage_calculations.dart';
import '../basicData/screens/ProfileCompletion.dart';
import '../hpodLocations/hpodLocations.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/utils/appText.dart';
import '../../../data/providers/network/apis/selectedProgramApi.dart';
import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../askIHL/askIHL.dart';
import '../customizeProgram/CustomizeBLoC.dart';
import '../customizeProgram/customizeProgramEvnet.dart';
import '../customizeProgram/customizeProgramSetting.dart';

import '../customizeProgram/customizeProgramState.dart';
import '../dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../healthProgram/healthProgramTabs.dart';
import '../manageHealthscreens/healthjournalTab.dart';
import '../manageHealthscreens/stepcounter/stepcounterdashboard.dart';
import '../myVitals/myVitalsDashBoard.dart';
import '../healthTips/healthTips.dart';
import '../myVitals/vitalsHomeCard.dart';
import '../newsLetter/newsLetter.dart';
import '../social/challenge.dart';
import '../../../../views/teleconsultation/viewallneeds.dart';
import '../../../app/utils/appColors.dart';
import '../../../app/utils/constLists.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../../app/utils/textStyle.dart';
import '../../Widgets/appBar.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../../../utils/SpUtil.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../dashboard/common_screen_for_navigation.dart';
import 'home_view.dart';

import 'dart:async';

import '../../../app/config/crossbarConfig.dart';
import '../../../data/providers/network/apis/dashboardApi/retriveUpcommingDetails.dart';
import '../../../data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';
import '../../Widgets/dashboardWidgets/healthtip_widget.dart';
import '../../Widgets/dashboardWidgets/subsrciption_widget.dart';
import '../../controllers/managehealth/stepcounter/googleFitStepController.dart';
import '../../../../Getx/controller/BannerChallengeController.dart';
import '../../../../Getx/controller/google_fit_controller.dart';
import '../../../../Getx/controller/listOfChallengeContoller.dart';
import '../../../../health_challenge/views/health_challenges_types.dart';
import '../../../../views/otherVitalController/otherVitalController.dart';
import '../../../data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../Widgets/dashboardWidgets/teleconsultation_widget.dart';
import '../../Widgets/healthChallengeCard.dart';
import '../../Widgets/healthJournalCard.dart';
import '../../Widgets/vitals/vitalCards.dart';
import '../../controllers/dashboardControllers/upComingDetailsController.dart';
import '../../controllers/healthJournalControllers/getTodayLogController.dart';
import '../spalshScreen/splashScreen.dart';
import 'package:http/http.dart' as http;

class LandingPage extends StatefulWidget {
  LandingPage({Key key, this.personalenabled}) : super(key: key);
  bool personalenabled;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  bool sso = false;
  final TabBarController _tabController = Get.put(TabBarController());
  final BannerChallengeController _bannerController = Get.put(BannerChallengeController());
  final ListChallengeController _listofChallengeController = Get.put(ListChallengeController());
  final http.Client _client = http.Client(); //3gb
  //final myvitalController = Get.put(MyVitalsController());
  // Instantiate your class using Get.put() to make it available for all "child" routes there.
  bool aff = SpUtil.getBool(LSKeys.affiliation) ?? false;
  var vital = localSotrage.read(LSKeys.vitalsData);

  // var vital = jsonDecode(SpUtil.getString(LSKeys.vitalsData));
  int ihlScore = SpUtil.getInt(LSKeys.ihlScore);

  // var ihlScore = localSotrage.read(LSKeys.ihlScore);
  Timer timeForHomeScreen;
  Map fitnessClassSpecialties;
  Map res;
  bool showHealthtips = SpUtil.getBool(LSKeys.affiliation ?? false);
  bool connectionInit = false;
  var subscription;
  String ihlId = '';
  final RxString _challenge = ''.obs;
  final List<String> _challenges = [
    'Challenge 1',
    'Challenge 2',
    'Challenge 3',
    'Challenge 4',
    'Challenge 5',
  ];

  @override
  void initState() {
    Tabss.ssoFlow();
    // if (Tabss.firstTime) {
    //   tabController.programsTab.value = 0;
    //   Tabss.tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    // } else {
    //   Tabss.tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    // }
    // Tabss.firstTime = false;
    subscripeTopics();
    sso = UpdatingColorsBasedOnAffiliations.ssoAffiliation != null &&
        UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] != null;
    Tabss.tabController = TabController(length: 2, vsync: this, initialIndex: sso ? 1 : 0);
    tabController.onInit();
    if (UpcomingCourses().subscription != null) {
      UpcomingCourses().subscription.cancel();
    }
    asyncFunc();
    // pagesList();
    super.initState();
  }

  asyncFunc() async {
    await tabController.afffliationDetailsGetter();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var _data = prefs.getString(
      SPKeys.userData,
    );
    await MyvitalsApi().vitalDatas(jsonDecode(_data));
  }

  subscripeTopics() async {
    var userAffiliated;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object raw = prefs.get(SPKeys.userData);
    Object password = prefs.get(SPKeys.password);
    if (raw == '' || raw == null) {
      raw = '{}';
    }
    Map data = jsonDecode(raw);
    Map user = data['User'];

    user ??= {};

    userAffiliated = user['user_affiliate'];
    List affUniqueNameList = [];
    if (userAffiliated == null) {
      userAffiliated = [];
    } else {
      userAffiliated.removeWhere((k, v) {
        if (v["affilate_unique_name"] != "" && v["affilate_unique_name"] != "null") {
          affUniqueNameList.add(v["affilate_unique_name"]);
          API.affNmLst.add(v['affilate_name'].toString().replaceAll(' Pvt Ltd', ''));
        }
        return v["affilate_unique_name"] == "";
      });
      debugPrint(API.affNmLst.toString());
    }

    final FCM firebaseMessaging = FCM();
    firebaseMessaging.TopicSubscription(affUniqueNameList);
    isSubscribedToTopic = true;
    debugPrint(isSubscribedToTopic.toString());
  }

  int selectedIndex = 0;
  final TabBarController tabController = Get.put(TabBarController());

  List<Widget> pagesList = [Home()];

  // (sso)?
  //   [
  //    const AffiliationDashboard(),
  //    const ChallengeScreenSocial(),
  //    HealthTips(),
  //    ViewallTeleDashboard(
  //      backNav: null,
  //    ),
  //    const MyvitalsDetails(),
  //    const NewsLetter(),
  //  ]
  //
  //  : [
  //    Home(),
  //    ChallengeScreenSocial(),
  //    HealthTips(),
  //    ViewallTeleDashboard(
  //      backNav: null,
  //    ),
  //    MyvitalsDetails(),
  //    NewsLetter(),
  //  ];
  loadWidgets(List choosenProgram) {
    // pagesList.add(Home());
    for (var element in choosenProgram) {
      switch (element) {
        case 'Vitals':
          pagesList.add(const MyvitalsDetails());
          break;
        case 'Challenges':
          pagesList.add(const ChallengeScreenSocial());
          break;
        case 'Health Tips':
          pagesList.add(HealthTips());
          break;
        case 'Calorie Tracker':
          pagesList.add(const HealthJournalTab());
          break;
        case 'Step Tracker':
          pagesList.add(StepCounterMainDashboard());
          break;
        case 'Heart Health':
          pagesList.add(
            CardioDashboardNew(cond: true, tabView: true),
          );
          break;
        case 'News Letter':
          pagesList.add(const NewsLetter());
          break;
        case 'Weight Management':
          pagesList.add(setGoalTabs());
          break;
        case 'hPod Locations':
          pagesList.add(const HpodLocations());
          break;
        case 'Ask IHL':
          pagesList.add(const AskIHL());
          break;
        case 'Teleconsultations':
          // pagesList.add(ViewallTeleDashboard(
          //   includeHelthEmarket: true,
          // ));
          pagesList.add(const OnlineServicesDashboard());
          break;
        case 'Online Class':
          pagesList.add(ViewallTeleDashboard());
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    localSotrage.write(LSKeys.logged, true);
    String userID = SpUtil.getString(LSKeys.ihlUserId);
    SplashScreenApiCalls().getDetailsApi(ihlUID: userID);
    Get.put(() => GetTokenController());
    Get.put(() => MyVitalsController());
    Get.put(() => HealthRepository());
    Get.put(() => VitalsContoller());
    Get.put(() => UpcomingDetailsController());
    Get.put(() => HealthTipsController());
    Get.put(() => TodayLogController());
    Get.put(() => GoogleFitStepController());
    return CommonScreenForNavigation(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarOpacity: 0,
          toolbarHeight: 7.h,
          flexibleSpace: const CustomeAppBar(
            screen: ProgramLists.homeList,
            // personalenabled: Tabss.personalEnabled,
          ),
          backgroundColor: Colors.white,
          elevation: aff ?? false ? 2 : 0,
          shadowColor: AppColors.unSelectedColor,
        ),
        content: SizedBox(
          height: 100.h,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                RepositoryProvider(
                    create: (BuildContext context) => SelectedDashboard(),
                    child: BlocProvider(
                        create: (BuildContext context) => FetchSelectedProgramBloc(
                              RepositoryProvider.of<SelectedDashboard>(context),
                            )..add(LoadDashboardEvent()),
                        child: BlocBuilder<FetchSelectedProgramBloc, SelectedDashboardState>(
                            builder: (BuildContext context, SelectedDashboardState dataState) {
                          dataState is ProgramLoadedState
                              ? loadWidgets(ProgramLists.homeList)
                              : null;
                          return Column(
                            children: [
                              PhysicalModel(
                                color: AppColors.plainColor,
                                elevation: 2,
                                child: Container(
                                  height: 15.h,
                                  color: AppColors.plainColor,
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 1.h, left: 4.w),
                                              child: Text('Programs we offer',
                                                  style: AppTextStyles.selectedHeadline),
                                            ),
                                            sso
                                                ? Container()
                                                : Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 1.h, left: 1.w, right: 3.w),
                                                    child: SizedBox(
                                                      width: 28.5.w,
                                                      height: 4.h,
                                                      child: ElevatedButton(
                                                        ///
                                                        onPressed: () {
                                                          // RepositoryProvider(
                                                          //   create: (BuildContext context) => SelectedDashboard(),
                                                          // );
                                                          tabController.updateSelectedIconValue(
                                                              value: "");
                                                          Get.to(
                                                            // BlocProvider(
                                                            // create:(BuildContext context)=>SelectedProgramBloc(),
                                                            // child: ProgramCustomSettings())

                                                            ProgramCustomSettings(
                                                              dataState: dataState,
                                                              listOfPrograms:
                                                                  dataState is ProgramLoadedState
                                                                      ? dataState.listOfPrograms
                                                                      : [],
                                                            ),
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            alignment: Alignment.centerLeft,
                                                            backgroundColor: AppColors.plainColor),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.start,
                                                          children: [
                                                            Image.asset(
                                                                'newAssets/Icons/customize.png',
                                                                height: 8.h,
                                                                width: 6.w),
                                                            Text(
                                                              AppTexts.customize,
                                                              style: AppTextStyles.customText,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                          ],
                                        ),
                                        Flexible(
                                            child: ListView.builder(
                                                padding: EdgeInsets.only(
                                                  top: 1.h,
                                                ),
                                                scrollDirection: Axis.horizontal,
                                                // itemCount: Platform.isIOS ? screen.length - 1 : screen.length,
                                                // itemCount: dataState is ProgramLoadedState
                                                //     ? dataState.listOfPrograms.length
                                                //     : 0,
                                                itemCount: ProgramLists.homeList.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  // String tempScreen =
                                                  //     dataState is ProgramLoadedState
                                                  //         ? dataState.listOfPrograms[index]
                                                  //         : "";
                                                  String tempScreen = ProgramLists.homeList[index];
                                                  return Visibility(
                                                    visible: tempScreen != "Home",
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20)),
                                                      width: 20.w,
                                                      child: Column(
                                                        children: [
                                                          InkWell(
                                                            child: Obx(() {
                                                              return tabController
                                                                          .programsTab.value ==
                                                                      index
                                                                  ? Container(
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(
                                                                              color: const Color(
                                                                                  0xff61C6E7),
                                                                              // color: Colors.tealAccent,
                                                                              width: 2),
                                                                          //    color: const Color(0xff61C6E7),
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  20.w)),
                                                                      height: 10.w,
                                                                      width: 10.w,
                                                                      padding:
                                                                          const EdgeInsets.all(8),
                                                                      child: tempScreen !=
                                                                              "Teleconsultations"
                                                                          ? Image.asset(
                                                                              'newAssets/Icons/$tempScreen.png',
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : Image.asset(
                                                                              'newAssets/tele.png',
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                    )
                                                                  : Container(
                                                                      decoration: BoxDecoration(
                                                                          boxShadow: const <
                                                                              BoxShadow>[
                                                                            BoxShadow(
                                                                                color:
                                                                                    Colors.black12,
                                                                                blurRadius: 15.0,
                                                                                offset: Offset(
                                                                                    0.0, 0.75))
                                                                          ],
                                                                          color: Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                  20.w)),
                                                                      height: 10.w,
                                                                      width: 10.w,
                                                                      padding:
                                                                          const EdgeInsets.all(8),
                                                                      child: tempScreen !=
                                                                              "Teleconsultations"
                                                                          ? Image.asset(
                                                                              'newAssets/Icons/$tempScreen.png',
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : Image.asset(
                                                                              'newAssets/tele.png',
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                    );
                                                            }),
                                                            onTap: () async {
                                                              tabController.updateSelectedIconValue(
                                                                  value: "");
                                                              switch (tempScreen.toString()) {
                                                                case 'Home':
                                                                  selectedIndex = index;
                                                                  // tabController.updateSelectedIconValue(value: "Home");
                                                                  tabController.updateProgramsTab(
                                                                      val: selectedIndex);
                                                                  // Get.toNamed(Routes.newsLetter);
                                                                  // Get.to(const NewsLetter());
                                                                  break;
                                                                case 'News Letter':
                                                                  selectedIndex = index;
                                                                  // tabController.updateSelectedIconValue(
                                                                  //     value: "Social");
                                                                  tabController.updateProgramsTab(
                                                                      val: selectedIndex);
                                                                  // Get.toNamed(Routes.newsLetter);
                                                                  // Get.to(const NewsLetter());
                                                                  break;
                                                                case 'Calorie Tracker':
                                                                  selectedIndex = index;
                                                                  // tabController.updateSelectedIconValue(
                                                                  //     value: "Social");
                                                                  tabController.updateProgramsTab(
                                                                      val: selectedIndex);
                                                                  break;
                                                                case 'Health Tips':
                                                                  selectedIndex = index;

                                                                  tabController.updateProgramsTab(
                                                                      val: selectedIndex);
                                                                  //Get.toNamed(Routes.healthTips);
                                                                  // tabController.updateSelectedIconValue(
                                                                  //     value: "Health Programs");
                                                                  // Get.to(HealthTips());
                                                                  break;
                                                                case 'hPod Locations':
                                                                  selectedIndex = index;
                                                                  tabController.updateProgramsTab(
                                                                      val: selectedIndex);
                                                                  // tabController.updateSelectedIconValue(
                                                                  //     value: "Social");
                                                                  // Get.toNamed(Routes.hpodLocations);

                                                                  break;
                                                                case 'Heart Health':
                                                                  selectedIndex = index;
                                                                  tabController.updateProgramsTab(
                                                                      val: selectedIndex);
                                                                  break;
                                                                case 'Ask IHL':
                                                                  selectedIndex = index;
                                                                  tabController.updateProgramsTab(
                                                                      val: selectedIndex);
                                                                  // tabController.updateSelectedIconValue(
                                                                  //     value: "Social");
                                                                  // Get.toNamed(Routes.askIHL);
                                                                  // Get.to(const AskIHL());
                                                                  break;
                                                                case 'Vitals':
                                                                  if (PercentageCalculations()
                                                                          .calculatePercentageFilled() !=
                                                                      100) {
                                                                    Get.to(
                                                                        ProfileCompletionScreen());
                                                                  } else {
                                                                    selectedIndex = index;
                                                                    tabController.updateProgramsTab(
                                                                        val: selectedIndex);
                                                                  }
                                                                  // tabController.updateSelectedIconValue(
                                                                  //     value: 'My Vitals');
                                                                  //Get.toNamed(Routes.myVitals);
                                                                  // Get.to(const ManageHealthScreenTabs());
                                                                  // Get.to(VitalTab(
                                                                  //   isShowAsMainScreen: false,
                                                                  // ));
                                                                  break;
                                                                case 'Online Class':
                                                                  // selectedIndex = index;

                                                                  // tabController.updateProgramsTab(val: selectedIndex);
                                                                  selectedAffiliationfromuniquenameDashboard ==
                                                                          ''
                                                                      ? Get.to(ViewallTeleDashboard(
                                                                          includeHelthEmarket: true,
                                                                          backNav: null,
                                                                        ))
                                                                      : Get.to(ViewFourPillar());
                                                                  break;
                                                                case 'Teleconsultations':
                                                                  _tabController
                                                                      .updateSelectedIconValue(
                                                                          value: AppTexts
                                                                              .onlineServices);
                                                                  if (PercentageCalculations()
                                                                          .calculatePercentageFilled() !=
                                                                      100) {
                                                                    await Get.to(
                                                                        ProfileCompletionScreen());
                                                                  } else {
                                                                    selectedAffiliationfromuniquenameDashboard ==
                                                                            ''
                                                                        ? await Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (BuildContext
                                                                                        context) =>
                                                                                    MultiBlocProvider(
                                                                                        providers: [
                                                                                          BlocProvider(
                                                                                            create: (BuildContext context) => SubscrptionFilterBloc()
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
                                                                                              create: (BuildContext context) => OnlineServicesApiBloc()
                                                                                                ..add(OnlineServicesApiEvent(data: "specialty"))),
                                                                                          BlocProvider(
                                                                                              create: (BuildContext context) => StreamOnlineServicesApiBloc()
                                                                                                ..add(StreamOnlineServicesApiEvent(data: "subscriptionDetails"))),
                                                                                          BlocProvider(
                                                                                              create: (BuildContext context) => StreamOnlineClassApiBloc()
                                                                                                ..add(StreamOnlineClassApiEvent(data: "subscriptionDetails")))
                                                                                        ],
                                                                                        child:
                                                                                            const OnlineServicesDashboard())))
                                                                        : await Get.to(
                                                                            ViewFourPillar());
                                                                    _tabController
                                                                        .updateSelectedIconValue(
                                                                            value: "Home");
                                                                    // Navigator.push(
                                                                    //     context,
                                                                    //     MaterialPageRoute(
                                                                    //         builder: (BuildContext
                                                                    //                 context) =>
                                                                    //             MultiBlocProvider(
                                                                    //                 providers: [
                                                                    //                   BlocProvider(
                                                                    //                     create: (BuildContext context) => SubscrptionFilterBloc()
                                                                    //                       ..add(FilterSubscriptionEvent(
                                                                    //                           filterType:
                                                                    //                               "Accepted",
                                                                    //                           endIndex:
                                                                    //                               30)),
                                                                    //                   ),
                                                                    //                   BlocProvider(
                                                                    //                       create: (BuildContext
                                                                    //                               context) =>
                                                                    //                           SearchAnimationBloc()),
                                                                    //                   BlocProvider(
                                                                    //                       create: (BuildContext
                                                                    //                               context) =>
                                                                    //                           ConsultantstatusBloc()),
                                                                    //                   BlocProvider(
                                                                    //                       create: (BuildContext
                                                                    //                               context) =>
                                                                    //                           TrainerBloc()),
                                                                    //                   BlocProvider(
                                                                    //                       create: (BuildContext
                                                                    //                               context) =>
                                                                    //                           OnlineServicesApiBloc()
                                                                    //                             ..add(OnlineServicesApiEvent(data: "specialty"))),
                                                                    //                   BlocProvider(
                                                                    //                       create: (BuildContext
                                                                    //                               context) =>
                                                                    //                           StreamOnlineServicesApiBloc()
                                                                    //                             ..add(StreamOnlineServicesApiEvent(data: "subscriptionDetails"))),
                                                                    //                   BlocProvider(
                                                                    //                       create: (BuildContext
                                                                    //                               context) =>
                                                                    //                           StreamOnlineClassApiBloc()
                                                                    //                             ..add(StreamOnlineClassApiEvent(data: "subscriptionDetails")))
                                                                    //                 ],
                                                                    //                 child:
                                                                    //                     const OnlineServicesDashboard())));
                                                                  }
                                                                  // selectedIndex = index;

                                                                  // tabController.updateProgramsTab(val: selectedIndex);
                                                                  // selectedAffiliationfromuniquenameDashboard ==
                                                                  //         ''
                                                                  //     ? Get.to(ViewallTeleDashboard(
                                                                  //         backNav: null,
                                                                  //       ))
                                                                  //     : Get.to(
                                                                  //         const ViewFourPillar());
                                                                  break;
                                                                case 'Challenges':
                                                                  selectedIndex = index;
                                                                  Get.put(BannerChallengeController())
                                                                          .challengeVisibleType =
                                                                      'social';
                                                                  tabController.updateProgramsTab(
                                                                      val: selectedIndex);

                                                                  // tabController.updateSelectedIconValue(
                                                                  //     value: "Social");
                                                                  // Get.to(HealthChallengesComponents(
                                                                  //   list: ["global", "Global"],
                                                                  // ));
                                                                  // Get.to(const Social());
                                                                  break;
                                                                case 'Weight Management':
                                                                  selectedIndex = index;
                                                                  tabController.updateProgramsTab(
                                                                      val: selectedIndex);
                                                                  break;
                                                                case 'Step Tracker':
                                                                  selectedIndex = index;
                                                                  tabController.updateProgramsTab(
                                                                      val: selectedIndex);
                                                                  break;
                                                                default:
                                                              }
                                                              // if ('News Letter' == screen[index].toString()) {
                                                              //   Get.toNamed(Routes.newsLetter);
                                                              // }
                                                            },
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                              top: 1.h,
                                                              bottom: 0.5.h,
                                                            ),
                                                            child: Obx(
                                                              () => Text(tempScreen,
                                                                  maxLines: 1,
                                                                  softWrap: false,
                                                                  style: tabController
                                                                              .programsTab.value !=
                                                                          index
                                                                      ? AppTextStyles.iconFonts
                                                                      : AppTextStyles.IconTitles),
                                                            ),
                                                          ),
                                                          Obx(() => tabController
                                                                      .programsTab.value ==
                                                                  index
                                                              ? Padding(
                                                                  padding: tabController
                                                                              .programsTab.value ==
                                                                          0
                                                                      ? EdgeInsets.only(left: 2.w)
                                                                      : EdgeInsets.only(left: .1.w),
                                                                  child: Container(
                                                                    width: 18.w,
                                                                    height: .4.h,
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                            const Color(0xff61C6E7),
                                                                        // color: Colors.tealAccent,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                2)),
                                                                  ),
                                                                )
                                                              : Container())
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                })),
                                      ]),
                                ),
                              ),
                              SizedBox(
                                  height: 67.5.h,
                                  child: TabBarView(
                                      physics: const NeverScrollableScrollPhysics(),
                                      controller: Tabss.tabController,
                                      children: [
                                        ///Personal
                                        dataState is ProgramLoadedState
                                            ? Obx(() {
                                                return SizedBox(
                                                    height: 67.5.h,
                                                    child: tabController.programsTab.value == 0
                                                        ? sso
                                                            ? const Personal()
                                                            : Home(
                                                                selectedProgram:
                                                                    dataState.listOfPrograms,
                                                              )
                                                        : pagesList[
                                                            tabController.programsTab.value ?? 0]);
                                              })
                                            : Shimmer.fromColors(
                                                direction: ShimmerDirection.ltr,
                                                period: const Duration(seconds: 2),
                                                baseColor: const Color.fromARGB(255, 240, 240, 240),
                                                highlightColor: Colors.grey.withOpacity(0.2),
                                                child: Container(
                                                    height: 18.h,
                                                    width: 97.w,
                                                    padding: const EdgeInsets.only(
                                                        left: 8, right: 8, top: 8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(8)),
                                                    child: const Text('Data Loading'))),

                                        ///Affilation
                                        dataState is ProgramLoadedState
                                            ? Obx(() {
                                                return SizedBox(
                                                    height: 67.5.h,
                                                    child: tabController.programsTab.value == 0
                                                        ? sso
                                                            ? AffiliationDashboard(
                                                                selectedProgram:
                                                                    dataState.listOfPrograms,
                                                              )
                                                            : Home(
                                                                selectedProgram:
                                                                    dataState.listOfPrograms,
                                                              )
                                                        : pagesList[
                                                            tabController.programsTab.value ?? 0]);
                                              })
                                            : Shimmer.fromColors(
                                                direction: ShimmerDirection.ltr,
                                                period: const Duration(seconds: 2),
                                                baseColor: const Color.fromARGB(255, 240, 240, 240),
                                                highlightColor: Colors.grey.withOpacity(0.2),
                                                child: Container(
                                                    height: 18.h,
                                                    width: 97.w,
                                                    padding: const EdgeInsets.only(
                                                        left: 8, right: 8, top: 8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(8)),
                                                    child: const Text('Data Loading')))
                                      ]))
                            ],
                          );
                        }))),
                // Obx(() {
                //   return SizedBox(
                //       height: 100.h, child: pagesList()[tabController.programsTab.value ?? 0]);
                // })
              ],
            ),
          ),
        ));
  }
}

class Personal extends StatefulWidget {
  const Personal({Key key}) : super(key: key);

  @override
  State<Personal> createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {
  bool sso = false;
  final TabBarController _tabController = Get.put(TabBarController());
  final BannerChallengeController _bannerController = Get.put(BannerChallengeController());
  final ListChallengeController _listofChallengeController = Get.put(ListChallengeController());
  final http.Client _client = http.Client(); //3gb
  //final myvitalController = Get.put(MyVitalsController());
  // Instantiate your class using Get.put() to make it available for all "child" routes there.
  bool aff = SpUtil.getBool(LSKeys.affiliation) ?? false;
  var vital = localSotrage.read(LSKeys.vitalsData);

  // var vital = jsonDecode(SpUtil.getString(LSKeys.vitalsData));
  int ihlScore = SpUtil.getInt(LSKeys.ihlScore);

  // var ihlScore = localSotrage.read(LSKeys.ihlScore);
  Timer timeForHomeScreen;
  Map fitnessClassSpecialties;
  Map res;
  bool showHealthtips = SpUtil.getBool(LSKeys.affiliation ?? false);
  bool connectionInit = false;
  var subscription;
  String ihlId = '';
  final RxString _challenge = ''.obs;
  final List<String> _challenges = [
    'Challenge 1',
    'Challenge 2',
    'Challenge 3',
    'Challenge 4',
    'Challenge 5',
  ];

  // ValueNotifier<String> response = ValueNotifier<String>('');
  ValueNotifier<Map<dynamic, dynamic>> response = ValueNotifier<Map<dynamic, dynamic>>({});

  @override
  void initState() {
    retriveData();
    // TODO: implement initState
    super.initState();
  }

  Future retriveData() async {
    response.value = await SplashScreenApiCalls().loginApi();

    await MyvitalsApi().vitalDatas(response.value);
    String userId = SpUtil.getString(LSKeys.ihlUserId);
    await MyVitalsController().getVitalsCheckinData(userId);
  }

  @override
  Widget build(BuildContext context) {
    Get.put(BannerChallengeController()).challengeVisibleType = 'main';
    localSotrage.write(LSKeys.logged, true);
    String userID = SpUtil.getString(LSKeys.ihlUserId);
    SplashScreenApiCalls().getDetailsApi(ihlUID: userID);
    Get.put(() => GetTokenController());
    Get.put(() => MyVitalsController());
    Get.put(() => HealthRepository());
    Get.put(() => VitalsContoller());
    Get.put(() => UpcomingDetailsController());
    Get.put(() => HealthTipsController());
    Get.put(() => TodayLogController());
    Get.put(() => GoogleFitStepController());
    return SingleChildScrollView(
      child: ValueListenableBuilder(
        valueListenable: response,
        builder: (BuildContext context, qlogvalue, Widget child) => Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 11.h),
            // Padding(
            //   padding: EdgeInsets.all(2.h),
            //   child: SearchBarWidget(),
            // ),
            //Score Card 🚩
            Padding(
              padding: EdgeInsets.only(top: 1.5.h, left: 2.w, right: 2.w),
              child: ihlScore != 0 && qlogvalue != null
                  ? VitalsCard().vitalsCardWithScore(context)
                  : VitalsCard().vitalsCardWithoutScore(context),
            ),
            //Vitals Card 🚩
            ValueListenableBuilder(
                valueListenable: CheckAllDataLoaded.data,
                builder: (_, val, __) {
                  return Visibility(
                    visible: val && qlogvalue != null,
                    replacement: Container(
                      height: 15.h,
                      width: 97.w,
                      padding: EdgeInsets.all(8.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Shimmer.fromColors(
                              direction: ShimmerDirection.ltr,
                              period: const Duration(seconds: 2),
                              baseColor: const Color.fromARGB(255, 240, 240, 240),
                              highlightColor: Colors.grey.withOpacity(0.2),
                              child: Container(
                                  height: 13.5.h,
                                  width: 45.w,
                                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Data Loading'))),
                          Shimmer.fromColors(
                              direction: ShimmerDirection.ltr,
                              period: const Duration(seconds: 2),
                              baseColor: const Color.fromARGB(255, 240, 240, 240),
                              highlightColor: Colors.grey.withOpacity(0.2),
                              child: Container(
                                  height: 13.5.h,
                                  width: 45.w,
                                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Data Loading'))),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.h, right: 1.w, left: 1.w),
                      child: SizedBox(
                        height: 100.h > 700 ? 13.h : 16.h,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: ProgramLists.vitalDetails.length,
                            itemBuilder: (BuildContext context, int index) {
                              return VitalCardsIndiduval(
                                vitalType: ProgramLists.vitalDetails[index],
                                icon: AssetImage(
                                    'newAssets/Icons/vitalsDetails/${ProgramLists.vitalDetails[index]}.png'),
                                show: false,
                              );
                            }),
                      ),
                    ),
                  );
                }),

            VariantBannerWidget.bannerWidget(
              _bannerController,
              _listofChallengeController,
            ),
            //Health Journal Card 🚩
            GetBuilder(
              id: "Today Food",
              init: TodayLogController(),
              builder: (TodayLogController controller) =>
                  (controller.logDetails.food != null || controller.logDetails.activity != null) &&
                          qlogvalue != null
                      ? controller.logDetails.food.isEmpty
                          ? Padding(
                              padding: EdgeInsets.only(left: 1.w, top: 1.5.h, right: 1.w),
                              child: HealthJournalCard().staticHealthJournal(),
                            )
                          : Padding(
                              padding: EdgeInsets.only(top: 1.h, left: 1.w, right: 1.w),
                              child: HealthJournalCard().caloriesCard(context),
                            )
                      : Padding(
                          padding: EdgeInsets.only(left: 1.w, top: 1.5.h, right: 1.w),
                          child: HealthJournalCard().staticHealthJournal(),
                        ),
            ),

            //TeleConsultation Card 🚩
            GetBuilder<UpcomingDetailsController>(
                id: "user_upcoming_detils",
                init: Get.put(UpcomingDetailsController()),
                builder: (_) {
                  if (_.upComingDetails.appointmentList != null && qlogvalue != null) {
                    if (_.upComingDetails.appointmentList.isEmpty ||
                        // _.upComingDetails.appointmentList[0].callstatus.toString() ==
                        //     "completed" ||
                        CheckExpiredAppointments.isExpired) {
                      return SizedBox(
                          width: 100.w,
                          child: TeleConsultationWidgets().teleConsultationDashboardWidget(
                              context: context,
                              staticCard: true,
                              affiColor: AppColors.primaryAccentColor,
                              linerColor: [
                                AppColors.primaryAccentColor.withOpacity(0.5),
                                Colors.blue.shade100.withOpacity(0.5),
                              ]));
                    } else {
                      CrossBarConnect().consultantStatus(
                          _.upComingDetails.appointmentList.first.ihlConsultantId);
                      DateTime desiredDate =
                          _.upComingDetails.appointmentList.first.appointmentEndTime;
                      print('check call status${_.upComingDetails.appointmentList[0].callstatus}');
                      if (_.upComingDetails.appointmentList[0].callstatus.toString() !=
                          'completed') {
                        return SizedBox(
                            width: 100.w,
                            child: TeleConsultationWidgets().teleConsultationDashboardWidget(
                                context: context,
                                appointmentList: _.upComingDetails.appointmentList[0],
                                staticCard: false,
                                affiColor: AppColors.primaryAccentColor,
                                linerColor: [
                                  AppColors.primaryAccentColor.withOpacity(0.5),
                                  Colors.blue.shade100.withOpacity(0.5),
                                ]));
                      } else {
                        return SizedBox(
                            width: 100.w,
                            child: TeleConsultationWidgets().teleConsultationDashboardWidget(
                                context: context,
                                staticCard: true,
                                affiColor: AppColors.primaryAccentColor,
                                linerColor: [
                                  AppColors.primaryAccentColor.withOpacity(0.5),
                                  Colors.blue.shade100.withOpacity(0.5),
                                ]));
                      }
                    }
                  } else {
                    return Container();
                  }
                }),
            SizedBox(
              height: 1.h,
            ),

            //Health Challenge Card 🚩

            GetBuilder<UpcomingDetailsController>(
                init: Get.put(UpcomingDetailsController()),
                id: "user_upcoming_detils",
                builder: (_) {
                  return Visibility(
                    visible: _.upComingDetails.enrolChallengeList != null && qlogvalue != null
                        ? _.upComingDetails.enrolChallengeList.isNotEmpty
                            ? false
                            : true
                        : true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 1.h, left: 1.w, bottom: 1.5.h),
                          child: Text(
                            AppTexts.newChallenge,
                            style: AppTextStyles.cardContent,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => PercentageCalculations().calculatePercentageFilled() != 100
                              ? Get.to(ProfileCompletionScreen())
                              : Get.to(HealthChallengesComponents(
                                  list: const ["global", "Global"],
                                )),
                          child: ChallengeCard().noChallenegs(context),
                        ),
                      ],
                    ),
                  );
                }),
            GetBuilder<UpcomingDetailsController>(
                init: Get.put(UpcomingDetailsController()),
                builder: (_) {
                  if (_.upComingDetails.enrolChallengeList != null && qlogvalue != null) {
                    return Visibility(
                      //visible: _.upComingDetails.enrolChallengeList!.isEmpty,
                      visible: false,
                      child: Card(
                        child: Column(children: [
                          GestureDetector(
                            child: ChallengeCard().newChallenge(context),
                            onTap: () => PercentageCalculations().calculatePercentageFilled() != 100
                                ? Get.to(ProfileCompletionScreen())
                                : Get.to(HealthChallengesComponents(
                                    list: const ["global", "Global"],
                                  )),
                          )
                        ]),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }),
            GetBuilder<UpcomingDetailsController>(
                init: Get.put(UpcomingDetailsController()),
                id: "user_enroll_challenge",
                builder: (_) {
                  if (_.upComingDetails.enrolChallengeList != null && qlogvalue != null) {
                    if (_.upComingDetails.enrolChallengeList.isNotEmpty) {
                      return _.loading
                          ? Shimmer.fromColors(
                              direction: ShimmerDirection.ltr,
                              period: const Duration(seconds: 2),
                              baseColor: const Color.fromARGB(255, 240, 240, 240),
                              highlightColor: Colors.grey.withOpacity(0.2),
                              child: Container(
                                  height: 25.h,
                                  width: 95.w,
                                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Hello')))
                          : Padding(
                              padding: EdgeInsets.only(right: 1.w, left: 1.w, bottom: 1.h),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 14, 14, 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Ongoing Challenge",
                                          style: AppTextStyles.cardContent,
                                        ),
                                        const Spacer(),
                                        TeleConsultationWidgets().viewAll(
                                          onTap: () => Get.to(
                                            HealthChallengesComponents(
                                              list: const ["global", "Global"],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Card(
                                    child: ChallengeCard().enrolledChallenge(context),
                                  ),
                                ],
                              ),
                            );
                    }
                  }
                  return Container();
                }),
            GetBuilder<UpcomingDetailsController>(
                init: Get.put(UpcomingDetailsController()),
                id: "user_upcoming_detils",
                builder: (_) {
                  if (_.upComingDetails.subcriptionList != null && qlogvalue != null) {
                    if (_.upComingDetails.subcriptionList.isEmpty) {
                      return SubscriptionWidgets().subscriptionCard(
                          context: context, staticCard: true, affi: fitnessClassSpecialties);
                    } else {
                      return SubscriptionWidgets().subscriptionCard(
                          context: context,
                          staticCard: false,
                          subcriptionList: _.upComingDetails.subcriptionList.first,
                          affi: fitnessClassSpecialties);
                    }
                  } else {
                    return Container();
                  }
                }),

            //Health Tips
            ValueListenableBuilder(
                valueListenable: ChangeHealthTips.healthtipslist,
                builder: (_, val, __) {
                  return Visibility(
                      visible:
                          ChangeHealthTips.healthtipslist.value.isNotEmpty && qlogvalue != null,
                      child: Column(
                        children: [
                          SizedBox(height: 1.h),
                          Column(
                            children: [
                              HealthTipCard(),
                              SizedBox(
                                height: 2.h,
                              ),
                            ],
                          ),
                        ],
                      ));
                }),

            //Health Program Card 🚩
            GestureDetector(
              onTap: () {
                if (PercentageCalculations().calculatePercentageFilled() != 100) {
                  Get.to(ProfileCompletionScreen());
                } else {
                  _tabController.updateSelectedIconValue(value: AppTexts.healthProgramms);
                  Get.put(VitalsContoller);
                  Get.to(CardioDashboardNew(
                    tabView: false,
                  ));
                  // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => HomeScreen(introDone: true)),
                  //     (Route<dynamic> route) => false);
                }
              },
              child: Padding(
                padding: EdgeInsets.only(left: 8.sp, bottom: 6.sp, right: 8.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 1.w),
                      child: Text(
                        vital != null && qlogvalue != null
                            ? 'Suggested Health Program '
                            : "New Health Program",
                        style: AppTextStyles.cardContent,
                      ),
                    ),
                    SizedBox(
                      height: 1.5.h,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 2.h,
                      ),
                      decoration: BoxDecoration(
                          color: AppColors.plainColor, borderRadius: BorderRadius.circular(5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 23.h,
                            width: double.infinity,
                            child: Image.asset(
                              'newAssets/Icons/heartHealth.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Center(
                              child: Text(
                            'Need to improve your heart health ?',
                            style: AppTextStyles.unSelectedText,
                          ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: .3.h,
            ),
            // Card 🚩
            Container(
              alignment: Alignment.topCenter,
              height: 10.h,
              width: 100.w,
              color: AppColors.backgroundScreenColor,
              // child: Text(
              //   "Join the new heart health program now !!",
              //   style: AppTextStyles.cardContent,
              // ),
            ),
            SizedBox(
              height: 28.h,
            ),
          ],
        ),
      ),
    );
  }
}
