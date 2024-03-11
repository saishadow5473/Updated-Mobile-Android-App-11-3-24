import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../Widgets/healthChallengeWidgets/DashBoardHealthChallengeWidget.dart';
import '../../Widgets/varientBannerWidgets.dart';
import '../../controllers/healthJournalControllers/foodDetailController.dart';
import '../basicData/screens/GenderScreen.dart';
import '../basicData/screens/ProfileCompletion.dart';
import '../profile/updatePhoto.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../basicData/functionalities/percentage_calculations.dart';
import '../basicData/models/basic_data.dart';
import '../../../../cardio_dashboard/views/cardio_dashboard_new.dart';
import '../../../app/config/crossbarConfig.dart';
import '../../../app/utils/appColors.dart';
import '../../../data/providers/network/apis/dashboardApi/retriveUpcommingDetails.dart';
import '../../../data/providers/network/apis/healthTipsApi/healthTipsApi.dart';
import '../../../data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';
import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../Widgets/dashboardWidgets/healthtip_widget.dart';
import '../../Widgets/dashboardWidgets/subsrciption_widget.dart';
import '../../controllers/managehealth/stepcounter/googleFitStepController.dart';
import '../dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../../../../utils/SpUtil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import '../../../../Getx/controller/BannerChallengeController.dart';
import '../../../../Getx/controller/google_fit_controller.dart';
import '../../../../Getx/controller/listOfChallengeContoller.dart';
import '../../../../cardio_dashboard/controllers/controller_for_cardio.dart';
import '../../../../constants/api.dart';
import '../../../../constants/spKeys.dart';
import '../../../../views/otherVitalController/otherVitalController.dart';
import '../../../app/utils/appText.dart';
import '../../../app/utils/constLists.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../../app/utils/textStyle.dart';
import '../../../data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../Widgets/appBar.dart';
import '../../Widgets/dashboardWidgets/teleconsultation_widget.dart';
import '../../Widgets/healthJournalCard.dart';
import '../../Widgets/vitals/vitalCards.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../controllers/dashboardControllers/upComingDetailsController.dart';
import '../../controllers/getTokenContoller/getTokenController.dart';
import '../../controllers/healthJournalControllers/getTodayLogController.dart';
import '../../controllers/healthTipsController/healthTipsController.dart';
import '../../controllers/vitalDetailsController/myVitalsController.dart';
import '../myVitals/vitalsHomeCard.dart';
import '../spalshScreen/splashScreen.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  Home({Key key, this.selectedIndex, @required this.selectedProgram}) : super(key: key);
  int selectedIndex;
  List selectedProgram;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
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
  var userInputWeight;

  // var ihlScore = localSotrage.read(LSKeys.ihlScore);
  Timer timeForHomeScreen;
  Map fitnessClassSpecialties;
  Map res;
  bool showHealthtips = SpUtil.getBool(LSKeys.affiliation ?? false);
  bool connectionInit = false;
  var subscription;

  final RxString _challenge = ''.obs;
  final List<String> _challenges = [
    'Challenge 1',
    'Challenge 2',
    'Challenge 3',
    'Challenge 4',
    'Challenge 5',
  ];
  var platformData;
  var checkinData;

  @override
  void initState() {
    print(BasicDataModel().weight);
    retriveData();
    HealthTipsApi.ihlUniqueName = "global_services";
    checkInternetConnectivity();
    getData();
    bool sso = UpdatingColorsBasedOnAffiliations.ssoAffiliation != null &&
        UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] != null;
    Tabss.tabController = TabController(length: 2, vsync: this, initialIndex: sso ? 1 : 0);
    // if (Tabss.firstTime) {
    //   Tabss.tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    // } else {
    //   Tabss.tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    // }
    // Tabss.firstTime = false;
    selectedAffiliationcompanyNamefromDashboard = '';
    selectedAffiliationfromuniquenameDashboard = '';
    if (widget.selectedIndex != null) {
      Tabss.tabController.index = widget.selectedIndex;
    }

    timeForHomeScreen = Timer.periodic(const Duration(minutes: 15), (Timer timer) async {
      print("Timer is active now");
      await RetriveDetials().upcomingDetails(fromChallenge: false);
    });
    // print(jsonDecode(SpUtil.getString(LSKeys.vitalsData)));
    Future.delayed(Duration.zero, () async {
      _tabController.updateSelectedIconValue(value: "Home");
      _tabController.updateTab(value: 0);
      localSotrage.listenKey("updateCalled", (value) {});
    });
    UpcomingDetailsController().updatingvalues();

    super.initState();
  }

  ValueNotifier<Map<dynamic, dynamic>> response = ValueNotifier<Map<dynamic, dynamic>>({});
  int profilePercentage = 0;
  Future retriveData() async {
    response.value = await SplashScreenApiCalls().loginApi();

    await MyvitalsApi().vitalDatas(response.value);
    String userId = SpUtil.getString(LSKeys.ihlUserId);
    await MyVitalsController().getVitalsCheckinData(userId);
  }

  Future getData() async {
    allClassValues = await UpcomingDetailsController.getPlatformDatas();
    ChangeHealthTips.healthtipslist.value.clear();
    start = 0;
    end = 2;
    ChangeHealthTips.getTips();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userInputWeight = prefs.getString("userInputWeight");
    print(userInputWeight);
    checkinData = localSotrage.read(LSKeys.allScors);
    Object data1 = prefs.get('data');
    final GetStorage box = GetStorage();
    BasicDataModel b = box.read('BasicData');
    print(b);
    int a = PercentageCalculations().checkHowManyFilled();
    profilePercentage = PercentageCalculations().calculatePercentageFilled();
    print(a);
    var updatedData = await CardioController().retriveUserData();
    await MyvitalsApi().vitalDatas(updatedData);
    if (mounted) setState(() {});
    Map res1 = jsonDecode(data1);
    var iHLUserId = res1['User']['id'];

    final http.Response getPlatformData = await _client.post(
      Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, String>{'ihl_id': iHLUserId, 'cache': "true"}),
    );
    if (getPlatformData.statusCode == 200) {
      if (getPlatformData.body != null) {
        prefs.setString(SPKeys.platformData, getPlatformData.body);
        res = jsonDecode(getPlatformData.body);
      }
    }

    //platformData = prefs.get(SPKeys.platformData);

    if (res['consult_type'] == null ||
        res['consult_type'] is! List ||
        res['consult_type'].isEmpty) {
      return;
    }

    fitnessClassSpecialties = res['consult_type'][1];
  }

  @override
  void dispose() {
    print("Timer is Canceled now");
    timeForHomeScreen.cancel();
    super.dispose();
  }

  checkInternetConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        if (connectionInit) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          const SnackBar snackBar = SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            content: Center(child: Text("You're Online")),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        const SnackBar snackBar = SnackBar(
          duration: Duration(days: 1),
          dismissDirection: DismissDirection.none,
          content: Center(
              child: Text(
            'No Internet Connection!',
            style: TextStyle(color: Colors.red),
          )),
        );
        connectionInit = true;
        if (mounted) {
          setState(() {});
        }
        // Find the ScaffoldMessenger in the widget tree
        // and use it to show a SnackBar.
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      // Got a new connectivity status!
    });
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
    Uint8List photoDecoded;
    if (SpUtil.getString(LSKeys.imageMemory) != null) {
      photoDecoded = base64Decode(SpUtil.getString(LSKeys.imageMemory));
    } else {
      photoDecoded = base64Decode(AvatarImage.defaultUrl);
    }
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
          child: (!SpUtil.getBool(LSKeys.affiliation) ?? false)
              ? SingleChildScrollView(
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //collecting missing informations
                      SizedBox(
                        height: 2.h,
                      ),
                      PercentageCalculations().calculatePercentageFilled() != 100
                          ? Padding(
                              padding: EdgeInsets.only(top: 2.5.h, left: 2.5.w, right: 2.5.w),
                              child: Container(
                                child: Container(
                                  padding: EdgeInsets.only(top: 1.3.h, bottom: 1.3.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade100,
                                        blurRadius: 9,
                                        offset: const Offset(4, 8), // Shadow position
                                      ),
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        blurRadius: 9,
                                        offset: const Offset(-3, 7), // Shadow position
                                      ),
                                      BoxShadow(
                                        color: Colors.grey.shade100,
                                        blurRadius: 9,
                                        offset: const Offset(0, -2), // Shadow position
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10.sp),
                                        child: SizedBox(
                                          height: 10.h,
                                          child: Center(
                                            child: Stack(
                                              children: [
                                                // GestureDetector(
                                                //   onTap: () {},
                                                //   child: Container(
                                                //     height: 15.h,
                                                //     width: 28.w,
                                                //     decoration: const BoxDecoration(
                                                //         shape: BoxShape.circle, color: Colors.red
                                                //         // image: DecorationImage(
                                                //         //     fit: BoxFit.cover,
                                                //         //     image: NetworkImage(
                                                //         //         'https://cdn3.iconfinder.com/data/icons/vector-icons-6/96/256-1024.png'))
                                                //         ),
                                                //   ),
                                                // ),
                                                ValueListenableBuilder(
                                                    valueListenable: PhotoChangeNotifier.photo,
                                                    builder: (BuildContext context, String val,
                                                        Widget child) {
                                                      return Container(
                                                        height: 15.h,
                                                        width: 28.w,
                                                        decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: MemoryImage(
                                                                  (PhotoChangeNotifier
                                                                              .photo.value ==
                                                                          null)
                                                                      ? photoDecoded
                                                                      : base64Decode(
                                                                          PhotoChangeNotifier
                                                                              .photo.value))),
                                                          shape: BoxShape.circle,
                                                        ),
                                                      );
                                                    }),
                                                Positioned(
                                                    bottom: .2.h,
                                                    right: 5,
                                                    child: CircularPercentIndicator(
                                                      //  fillColor: Colors.white,
                                                      radius: 21.0,
                                                      lineWidth: 4.0,
                                                      percent: PercentageCalculations()
                                                              .calculatePercentageFilled() /
                                                          100,
                                                      center: Container(
                                                        height: 36,
                                                        width: 36,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius.circular(20)),
                                                        child: Center(
                                                          child: Text(
                                                            '${PercentageCalculations().calculatePercentageFilled()}'
                                                            '%',
                                                            style: TextStyle(fontSize: 7.3.sp),
                                                          ),
                                                        ),
                                                      ),
                                                      progressColor: AppColors.primaryAccentColor,
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: 60.w,
                                            child: const Text(
                                              'To unlock potential of our app complete your profile today!!',
                                              style: TextStyle(),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 2.h,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              // print(PercentageCalculations().calculatePercentageFilled());
                                              PercentageCalculations()
                                                          .calculatePercentageFilled() !=
                                                      100
                                                  ? Get.to(GenderSelectScreen())
                                                  : null;
                                            },
                                            child: Container(
                                              height: 5.h,
                                              width: 45.w,
                                              decoration: BoxDecoration(
                                                  color: AppColors.primaryAccentColor,
                                                  borderRadius: BorderRadius.circular(5)),
                                              child: const Center(
                                                child: Text(
                                                  ' GET STARTED ',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      // SizedBox(height: 11.h),
                      // Padding(
                      //   padding: EdgeInsets.all(2.h),
                      //   child: SearchBarWidget(),
                      // ),
                      // const OfferedPrograms(
                      //   screenTitle: 'Programs we offer',
                      //   screen: ProgramLists.homeList,
                      // ),
                      //Score Card 🚩
                      PercentageCalculations().calculatePercentageFilled() == 100
                          ? Visibility(
                              // visible: true,
                              visible: widget.selectedProgram.isNotEmpty &&
                                  widget.selectedProgram.contains("Heart Health"),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: PercentageCalculations().calculatePercentageFilled() != 100
                                        ? .5.h
                                        : 1.5.h,
                                    left: 2.w,
                                    right: 2.w),
                                child: ihlScore != 0
                                    ? VitalsCard().vitalsCardWithScore(context)
                                    : VitalsCard().vitalsCardWithoutScore(context),
                              ),
                            )
                          : Container(),
                      //Vitals Card 🚩
                      (checkinData == null || vital == null) &&
                              PercentageCalculations().calculatePercentageFilled() != 100
                          ? const SizedBox()
                          : PercentageCalculations().calculatePercentageFilled() != 100
                              ? Container()
                              : Visibility(
                                  visible: widget.selectedProgram.isNotEmpty &&
                                      widget.selectedProgram.contains("Vitals"),
                                  child: ValueListenableBuilder(
                                      valueListenable: CheckAllDataLoaded.data,
                                      builder: (_, val, __) {
                                        return Visibility(
                                          visible: val,
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
                                                    baseColor:
                                                        const Color.fromARGB(255, 240, 240, 240),
                                                    highlightColor: Colors.grey.withOpacity(0.2),
                                                    child: Container(
                                                        height: 13.5.h,
                                                        width: 45.w,
                                                        padding: const EdgeInsets.only(
                                                            left: 8, right: 8, top: 8),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(8)),
                                                        child: const Text('Data Loading'))),
                                                Shimmer.fromColors(
                                                    direction: ShimmerDirection.ltr,
                                                    period: const Duration(seconds: 2),
                                                    baseColor:
                                                        const Color.fromARGB(255, 240, 240, 240),
                                                    highlightColor: Colors.grey.withOpacity(0.2),
                                                    child: Container(
                                                        height: 13.5.h,
                                                        width: 45.w,
                                                        padding: const EdgeInsets.only(
                                                            left: 8, right: 8, top: 8),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(8)),
                                                        child: const Text('Data Loading'))),
                                              ],
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(top: 2.h, right: 1.w, left: 1.5.w),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(left: 1.5.w, bottom: 2),
                                                  child: Container(
                                                    color: AppColors.backgroundScreenColor,
                                                    width: 70.w,
                                                    child: ValueListenableBuilder(
                                                        valueListenable:
                                                            UpdatingColorsBasedOnAffiliations
                                                                .selectedAffiliation,
                                                        builder:
                                                            (BuildContext ctx, i, Widget child) {
                                                          return Text(AppTexts.myVitals,
                                                              style: AppTextStyles.contentHeading);
                                                        }),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 100.h > 700 ? 13.h : 16.h,
                                                  child: ListView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: ProgramLists.vitalDetails.length,
                                                      itemBuilder:
                                                          (BuildContext context, int index) {
                                                        var vital =
                                                            localSotrage.read(LSKeys.vitalsData);
                                                        return vital != null
                                                            ? VitalCardsIndiduval(
                                                                vitalType: ProgramLists
                                                                    .vitalDetails[index],
                                                                icon: AssetImage(
                                                                    'newAssets/Icons/vitalsDetails/${ProgramLists.vitalDetails[index]}.png'),
                                                                show: false,
                                                              )
                                                            : Container();
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      })),
                      Visibility(
                          visible: widget.selectedProgram.isNotEmpty &&
                              widget.selectedProgram.contains("Online Class"),
                          child: GetBuilder<UpcomingDetailsController>(
                              init: Get.put(UpcomingDetailsController()),
                              id: "user_upcoming_detils",
                              builder: (_) {
                                if (_.upComingDetails.subcriptionList != null) {
                                  if (_.upComingDetails.subcriptionList.isEmpty) {
                                    return const SizedBox();
                                    // return SubscriptionWidgets().subscriptionCard(
                                    //     context: context,
                                    //     staticCard: true,
                                    //     affi: fitnessClassSpecialties);
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
                              })),
                      Visibility(
                        visible: widget.selectedProgram.isNotEmpty &&
                            widget.selectedProgram.contains("Teleconsultations"),
                        child: GetBuilder<UpcomingDetailsController>(
                            id: "user_upcoming_detils",
                            init: Get.put(UpcomingDetailsController()),
                            builder: (_) {
                              if (_.upComingDetails.appointmentList != null) {
                                if (_.upComingDetails.appointmentList.isEmpty ||
                                    CheckExpiredAppointments.isExpired) {
                                  return const SizedBox();
                                  // return SizedBox(
                                  //     width: 100.w,
                                  //     child: TeleConsultationWidgets()
                                  //         .teleConsultationDashboardWidget(
                                  //             context: context,
                                  //             staticCard: true,
                                  //             affiColor: AppColors.primaryAccentColor,
                                  //             linerColor: [
                                  //           AppColors.primaryAccentColor.withOpacity(0.5),
                                  //           Colors.blue.shade100.withOpacity(0.5),
                                  //         ]));
                                } else {
                                  CrossBarConnect().consultantStatus(
                                      _.upComingDetails.appointmentList.first.ihlConsultantId);
                                  DateTime desiredDate =
                                      _.upComingDetails.appointmentList.first.appointmentEndTime;

                                  if (_.upComingDetails.appointmentList[0].callstatus.toString() !=
                                      'completed') {
                                    return SizedBox(
                                        width: 100.w,
                                        child: TeleConsultationWidgets()
                                            .teleConsultationDashboardWidget(
                                                context: context,
                                                appointmentList:
                                                    _.upComingDetails.appointmentList[0],
                                                staticCard: false,
                                                affiColor: AppColors.primaryAccentColor,
                                                linerColor: [
                                              AppColors.primaryAccentColor.withOpacity(0.5),
                                              Colors.blue.shade100.withOpacity(0.5),
                                            ]));
                                  } else {
                                    return const SizedBox();
                                    // return SizedBox(
                                    //     width: 100.w,
                                    //     child: TeleConsultationWidgets()
                                    //         .teleConsultationDashboardWidget(
                                    //             context: context,
                                    //             staticCard: true,
                                    //             affiColor: AppColors.primaryAccentColor,
                                    //             linerColor: [
                                    //           AppColors.primaryAccentColor.withOpacity(0.5),
                                    //           Colors.blue.shade100.withOpacity(0.5),
                                    //         ]));
                                  }
                                }
                              } else {
                                return Container();
                              }
                            }),
                      ),
                      Visibility(
                          visible: widget.selectedProgram.isNotEmpty &&
                              widget.selectedProgram.contains("Health Challenge"),
                          child: DashBoardHealthChallengeWidget()
                              .upcomingChallengeWidget(context, top: true)),
                      VariantBannerWidget.bannerWidget(
                        _bannerController,
                        _listofChallengeController,
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      //Health Journal Card 🚩
                      Visibility(
                        visible: widget.selectedProgram.isNotEmpty &&
                            widget.selectedProgram.contains("Calorie Tracker"),
                        child: GetBuilder(
                          id: "Today Food",
                          init: TodayLogController(),
                          builder: (TodayLogController controller) => controller.logDetails.food !=
                                      null ||
                                  controller.logDetails.activity != null
                              ? controller.logDetails.food.isEmpty
                                  ? Padding(
                                      padding: EdgeInsets.only(left: 2.w, top: 1.5.h, right: 1.w),
                                      child: HealthJournalCard().staticHealthJournal(),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(top: 1.h, left: 2.w, right: 1.5.w),
                                      child: HealthJournalCard()
                                          .caloriesCard(context, fromHome: 'home'),
                                    )
                              : Padding(
                                  padding: EdgeInsets.only(left: 1.w, top: 1.5.h, right: 1.w),
                                  child: Shimmer.fromColors(
                                      direction: ShimmerDirection.ltr,
                                      period: const Duration(seconds: 2),
                                      baseColor: const Color.fromARGB(255, 240, 240, 240),
                                      highlightColor: Colors.grey.withOpacity(0.2),
                                      child: Container(
                                          height: 18.h,
                                          width: 97.w,
                                          padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8)),
                                          child: const Text('Data Loading'))),
                                ),
                        ),
                      ),
                      //TeleConsultation Card 🚩
                      Visibility(
                        visible: widget.selectedProgram.isNotEmpty &&
                            widget.selectedProgram.contains("Teleconsultations"),
                        child: GetBuilder<UpcomingDetailsController>(
                            id: "user_upcoming_detils",
                            init: Get.put(UpcomingDetailsController()),
                            builder: (_) {
                              if (_.upComingDetails.appointmentList != null) {
                                if (_.upComingDetails.appointmentList.isEmpty ||
                                    CheckExpiredAppointments.isExpired) {
                                  return SizedBox(
                                      width: 100.w,
                                      child: TeleConsultationWidgets()
                                          .teleConsultationDashboardWidget(
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

                                  if (_.upComingDetails.appointmentList[0].callstatus.toString() !=
                                      'completed') {
                                    return const SizedBox();
                                    // return SizedBox(
                                    //     width: 100.w,
                                    //     child: TeleConsultationWidgets()
                                    //         .teleConsultationDashboardWidget(
                                    //             context: context,
                                    //             appointmentList:
                                    //                 _.upComingDetails.appointmentList[0],
                                    //             staticCard: false,
                                    //             affiColor: AppColors.primaryAccentColor,
                                    //             linerColor: [
                                    //           AppColors.primaryAccentColor.withOpacity(0.5),
                                    //           Colors.blue.shade100.withOpacity(0.5),
                                    //         ]));
                                  } else {
                                    return SizedBox(
                                        width: 100.w,
                                        child: TeleConsultationWidgets()
                                            .teleConsultationDashboardWidget(
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
                      ),
                      Visibility(
                        visible: widget.selectedProgram.isNotEmpty &&
                            widget.selectedProgram.contains("TeleConsultation"),
                        child: SizedBox(
                          height: 1.h,
                        ),
                      ),
                      //Health Challenge Card 🚩
                      /*   Visibility(
                          visible: widget.selectedProgram.isNotEmpty &&
                              widget.selectedProgram.contains("Health Challenge"),
                          child: GetBuilder<UpcomingDetailsController>(
                              init: Get.put(UpcomingDetailsController()),
                              id: "user_enroll_challenge",
                              builder: (_) {
                                return Visibility(
                                  visible: _.upComingDetails.enrolChallengeList != null
                                      ? _.upComingDetails.enrolChallengeList.isNotEmpty
                                          ? false
                                          : true
                                      : true,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: 1.h, left: 1.w, bottom: 1.5.h),
                                        child: Text(
                                          AppTexts.newChallenge,
                                          style: AppTextStyles.cardContent,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            PercentageCalculations().calculatePercentageFilled() !=
                                                    100
                                                ? Get.to(ProfileCompletionScreen())
                                                : Get.to(HealthChallengesComponents(
                                                    list: const ["global", "Global"],
                                                  )),
                                        child: ChallengeCard().noChallenegs(context),
                                      ),
                                    ],
                                  ),
                                );
                              })),*/
                      Visibility(
                        visible: widget.selectedProgram.isNotEmpty &&
                            widget.selectedProgram.contains("Health Challenge"),
                        child: DashBoardHealthChallengeWidget().upcomingChallengeWidget(context),

                        /* GetBuilder<UpcomingDetailsController>(
                              init: Get.put(UpcomingDetailsController()),
                              builder: (_) {
                                if (_.upComingDetails.enrolChallengeList != null) {
                                  return Visibility(
                                    //visible: _.upComingDetails.enrolChallengeList!.isEmpty,
                                    visible: false,
                                    child: Card(
                                      child: Column(children: [
                                        GestureDetector(
                                          child: ChallengeCard().newChallenge(context),
                                          onTap: () => Get.to(HealthChallengesComponents(
                                            list: const ["global", "Global"],
                                          )),
                                        )
                                      ]),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              })
                              */
                      ),
                      /*     Visibility(
                          visible: widget.selectedProgram.isNotEmpty &&
                              widget.selectedProgram.contains("Online Class"),
                          child: GetBuilder<UpcomingDetailsController>(
                              init: Get.put(UpcomingDetailsController()),
                              id: "user_enroll_challenge",
                              builder: (_) {
                                if (_.upComingDetails.enrolChallengeList != null) {
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
                                                padding: const EdgeInsets.only(
                                                    left: 8, right: 8, top: 8),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8)),
                                                child: const Text('Hello')))
                                        : Padding(
                                            padding:
                                                EdgeInsets.only(right: 1.w, left: 1.w, bottom: 1.h),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(10, 14, 14, 10),
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
                              })),*/
                      Visibility(
                          visible: widget.selectedProgram.isNotEmpty &&
                              widget.selectedProgram.contains("Online Class"),
                          child: GetBuilder<UpcomingDetailsController>(
                              init: Get.put(UpcomingDetailsController()),
                              id: "user_upcoming_detils",
                              builder: (_) {
                                if (_.upComingDetails.subcriptionList != null) {
                                  if (_.upComingDetails.subcriptionList.isEmpty) {
                                    return SubscriptionWidgets().subscriptionCard(
                                        context: context,
                                        staticCard: true,
                                        affi: fitnessClassSpecialties);
                                  } else {
                                    return const SizedBox();
                                    // return SubscriptionWidgets().subscriptionCard(
                                    //     context: context,
                                    //     staticCard: false,
                                    //     subcriptionList: _.upComingDetails.subcriptionList.first,
                                    //     affi: fitnessClassSpecialties);
                                  }
                                } else {
                                  return Container();
                                }
                              })),

                      //Health Tips
                      Visibility(
                          visible: widget.selectedProgram.isNotEmpty &&
                              widget.selectedProgram.contains("Health Tips"),
                          child: ValueListenableBuilder(
                              valueListenable: ChangeHealthTips.healthtipslist,
                              builder: (_, val, __) {
                                return Column(
                                  children: [
                                    SizedBox(
                                      height: ChangeHealthTips.healthtipslist.value.isNotEmpty
                                          ? 1.h
                                          : 2.h,
                                    ),
                                    Visibility(
                                        visible: ChangeHealthTips.healthtipslist.value.isNotEmpty,
                                        child: Column(
                                          children: [
                                            HealthTipCard(),
                                            SizedBox(
                                              height: 2.h,
                                            ),
                                          ],
                                        )),
                                  ],
                                );
                              })),

                      //Health Program Card 🚩
                      Visibility(
                          visible: widget.selectedProgram.isNotEmpty &&
                              widget.selectedProgram.contains("Health Tips"),
                          child: GestureDetector(
                            onTap: () {
                              if (PercentageCalculations().calculatePercentageFilled() != 100) {
                                Get.to(ProfileCompletionScreen());
                              } else {
                                _tabController.updateSelectedIconValue(
                                    value: AppTexts.healthProgramms);
                                Get.put(VitalsContoller);
                                Get.find<UpcomingDetailsController>().onClose();
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
                              padding: EdgeInsets.only(
                                  top: 1.5.h, left: 8.sp, bottom: 6.sp, right: 8.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 1.w),
                                    child: Text(
                                      vital != null
                                          ? 'Suggested Health Program'
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
                                        color: AppColors.plainColor,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 23.h,
                                          width: double.infinity,
                                          child: Image.asset(
                                            'newAssets/Icons/heartHealth.png',
                                            fit: BoxFit.fill,
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
                          )),
                      SizedBox(
                        height: .3.h,
                      ),
                      // Card 🚩
                      Container(
                        alignment: Alignment.topCenter,
                        height: 10.h,
                        width: 100.w,
                        color: AppColors.backgroundScreenColor,
                        //   child: Text(
                        //     "Join the new heart health program now !!",
                        //     style: AppTextStyles.cardContent,
                        //   ),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: Tabss.tabController,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SizedBox(height: 11.h),
                          // Padding(
                          //   padding: EdgeInsets.all(2.h),
                          //   child: SearchBarWidget(),
                          // ),
                          // const OfferedPrograms(
                          //   screenTitle: 'Programs we offer',
                          //   screen: ProgramLists.homeList,
                          // ),
                          PercentageCalculations().calculatePercentageFilled() != 100
                              ? Padding(
                                  padding: EdgeInsets.only(left: 1.w, top: 1.5.h, right: 1.w),
                                  child: Container(
                                    padding: EdgeInsets.all(6.sp),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            blurRadius: 4,
                                            offset: const Offset(4, 8), // Shadow position
                                          ),
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            blurRadius: 4,
                                            offset: const Offset(-3, 8), // Shadow position
                                          ),
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            blurRadius: 4,
                                            offset: const Offset(0, -2), // Shadow position
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(12.sp),
                                            child: SizedBox(
                                              height: 10.h,
                                              child: Center(
                                                child: Stack(
                                                  children: [
                                                    // GestureDetector(
                                                    //   onTap: () {},
                                                    //   child: Container(
                                                    //     height: 15.h,
                                                    //     width: 28.w,
                                                    //     decoration: const BoxDecoration(
                                                    //         shape: BoxShape.circle, color: Colors.red
                                                    //         // image: DecorationImage(
                                                    //         //     fit: BoxFit.cover,
                                                    //         //     image: NetworkImage(
                                                    //         //         'https://cdn3.iconfinder.com/data/icons/vector-icons-6/96/256-1024.png'))
                                                    //         ),
                                                    //   ),
                                                    // ),
                                                    ValueListenableBuilder(
                                                        valueListenable: PhotoChangeNotifier.photo,
                                                        builder: (BuildContext context, String val,
                                                            Widget child) {
                                                          return Container(
                                                            height: 15.h,
                                                            width: 28.w,
                                                            decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                  image: MemoryImage(
                                                                      (PhotoChangeNotifier
                                                                                  .photo.value ==
                                                                              null)
                                                                          ? photoDecoded
                                                                          : base64Decode(
                                                                              PhotoChangeNotifier
                                                                                  .photo.value))),
                                                              shape: BoxShape.circle,
                                                            ),
                                                          );
                                                        }),
                                                    Positioned(
                                                        bottom: .2.h,
                                                        right: 10,
                                                        child: CircularPercentIndicator(
                                                          //  fillColor: Colors.white,
                                                          radius: 21.0,
                                                          lineWidth: 4.0,
                                                          percent: PercentageCalculations()
                                                                  .calculatePercentageFilled() /
                                                              100,
                                                          center: Container(
                                                            height: 36,
                                                            width: 36,
                                                            decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius:
                                                                    BorderRadius.circular(20)),
                                                            child: Center(
                                                              child: Text(
                                                                '${PercentageCalculations().calculatePercentageFilled()}'
                                                                '%',
                                                                style: TextStyle(fontSize: 7.3.sp),
                                                              ),
                                                            ),
                                                          ),
                                                          progressColor:
                                                              AppColors.primaryAccentColor,
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: 60.w,
                                                child: const Text(
                                                  'To unlock potential of our app complete your profile today!!',
                                                  style: TextStyle(),
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  // print(PercentageCalculations().calculatePercentageFilled());
                                                  PercentageCalculations()
                                                              .calculatePercentageFilled() !=
                                                          100
                                                      ? Get.to(GenderSelectScreen())
                                                      : null;
                                                },
                                                child: Container(
                                                  height: 5.h,
                                                  width: 45.w,
                                                  decoration: BoxDecoration(
                                                      color: AppColors.primaryAccentColor,
                                                      borderRadius: BorderRadius.circular(5)),
                                                  child: const Center(
                                                    child: Text(
                                                      ' GET STARTED ',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          //Score Card 🚩
                          Visibility(
                            visible: widget.selectedProgram.isNotEmpty &&
                                widget.selectedProgram.contains("Heart Health"),
                            child: Padding(
                              padding: EdgeInsets.only(top: 1.5.h, left: 2.w, right: 2.w),
                              child: ihlScore != 0
                                  ? VitalsCard().vitalsCardWithScore(context)
                                  : VitalsCard().vitalsCardWithoutScore(context),
                            ),
                          ),

                          //Vitals Card 🚩
                          checkinData == null || vital == null
                              ? const SizedBox()
                              : (userInputWeight == null ||
                                      vital["Weight"] == null ||
                                      checkinData["weightKG"] == null ||
                                      checkinData["weightKG"] == " ")
                                  ? Container()
                                  : Visibility(
                                      visible: widget.selectedProgram.isNotEmpty &&
                                          widget.selectedProgram.contains("Vitals"),
                                      child: ValueListenableBuilder(
                                          valueListenable: CheckAllDataLoaded.data,
                                          builder: (_, val, __) {
                                            return Visibility(
                                              visible: val,
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
                                                        baseColor: const Color.fromARGB(
                                                            255, 240, 240, 240),
                                                        highlightColor:
                                                            Colors.grey.withOpacity(0.2),
                                                        child: Container(
                                                            height: 13.5.h,
                                                            width: 45.w,
                                                            padding: const EdgeInsets.only(
                                                                left: 8, right: 8, top: 8),
                                                            decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius:
                                                                    BorderRadius.circular(8)),
                                                            child: const Text('Data Loading'))),
                                                    Shimmer.fromColors(
                                                        direction: ShimmerDirection.ltr,
                                                        period: const Duration(seconds: 2),
                                                        baseColor: const Color.fromARGB(
                                                            255, 240, 240, 240),
                                                        highlightColor:
                                                            Colors.grey.withOpacity(0.2),
                                                        child: Container(
                                                            height: 13.5.h,
                                                            width: 45.w,
                                                            padding: const EdgeInsets.only(
                                                                left: 8, right: 8, top: 8),
                                                            decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius:
                                                                    BorderRadius.circular(8)),
                                                            child: const Text('Data Loading'))),
                                                  ],
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 2.h, right: 1.w, left: 1.w),
                                                child: SizedBox(
                                                  height: 100.h > 700 ? 13.h : 16.h,
                                                  child: ListView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: ProgramLists.vitalDetails.length,
                                                      itemBuilder:
                                                          (BuildContext context, int index) {
                                                        return VitalCardsIndiduval(
                                                          vitalType:
                                                              ProgramLists.vitalDetails[index],
                                                          icon: AssetImage(
                                                              'newAssets/Icons/vitalsDetails/${ProgramLists.vitalDetails[index]}.png'),
                                                          show: false,
                                                        );
                                                      }),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),

                          VariantBannerWidget.bannerWidget(
                            _bannerController,
                            _listofChallengeController,
                          ),
                          //Health Journal Card 🚩
                          Visibility(
                            visible: widget.selectedProgram.isNotEmpty &&
                                widget.selectedProgram.contains("Calorie Tracker"),
                            child: GetBuilder(
                              id: "Today Food",
                              init: TodayLogController(),
                              builder: (TodayLogController controller) => controller
                                              .logDetails.food !=
                                          null ||
                                      controller.logDetails.activity != null
                                  ? controller.logDetails.food.isEmpty
                                      ? Padding(
                                          padding:
                                              EdgeInsets.only(left: 1.w, top: 1.5.h, right: 1.w),
                                          child: HealthJournalCard().staticHealthJournal(),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(top: 1.h, left: 1.w, right: 1.w),
                                          child: HealthJournalCard()
                                              .caloriesCard(context, fromHome: 'home'),
                                        )
                                  : Padding(
                                      padding: EdgeInsets.only(left: 1.w, top: 1.5.h, right: 1.w),
                                      child: HealthJournalCard().staticHealthJournal(),
                                    ),
                            ),
                          ),

                          //TeleConsultation Card 🚩
                          Visibility(
                            visible: widget.selectedProgram.isNotEmpty &&
                                widget.selectedProgram.contains("Teleconsultations"),
                            child: GetBuilder<UpcomingDetailsController>(
                                id: "user_upcoming_detils",
                                init: Get.put(UpcomingDetailsController()),
                                builder: (_) {
                                  if (_.upComingDetails.appointmentList != null) {
                                    if (_.upComingDetails.appointmentList.isEmpty ||
                                        // _.upComingDetails.appointmentList[0].callstatus.toString() ==
                                        //     "completed" ||
                                        CheckExpiredAppointments.isExpired) {
                                      return SizedBox(
                                          width: 100.w,
                                          child: TeleConsultationWidgets()
                                              .teleConsultationDashboardWidget(
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
                                      DateTime desiredDate = _
                                          .upComingDetails.appointmentList.first.appointmentEndTime;
                                      print(
                                          'check call status${_.upComingDetails.appointmentList[0].callstatus}');
                                      if (_.upComingDetails.appointmentList[0].callstatus
                                              .toString() !=
                                          'completed') {
                                        return SizedBox(
                                            width: 100.w,
                                            child: TeleConsultationWidgets()
                                                .teleConsultationDashboardWidget(
                                                    context: context,
                                                    appointmentList:
                                                        _.upComingDetails.appointmentList[0],
                                                    staticCard: false,
                                                    affiColor: AppColors.primaryAccentColor,
                                                    linerColor: [
                                                  AppColors.primaryAccentColor.withOpacity(0.5),
                                                  Colors.blue.shade100.withOpacity(0.5),
                                                ]));
                                      } else {
                                        return SizedBox(
                                            width: 100.w,
                                            child: TeleConsultationWidgets()
                                                .teleConsultationDashboardWidget(
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
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Visibility(
                            visible: widget.selectedProgram.isNotEmpty &&
                                widget.selectedProgram.contains("Health Challenge"),
                            child:
                                DashBoardHealthChallengeWidget().upcomingChallengeWidget(context),
                          ),
                          //Health Challenge Card 🚩
/*
                          GetBuilder<UpcomingDetailsController>(
                              init: Get.put(UpcomingDetailsController()),
                              id: "user_enroll_challenge",
                              builder: (_) {
                                return Visibility(
                                  visible: _.upComingDetails.enrolChallengeList != null
                                      ? _.upComingDetails.enrolChallengeList.isNotEmpty
                                          ? false
                                          : true
                                      : true,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: 1.h, left: 1.w, bottom: 1.5.h),
                                        child: Text(
                                          AppTexts.newChallenge,
                                          style: AppTextStyles.cardContent,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (PercentageCalculations()
                                                  .calculatePercentageFilled() !=
                                              100) {
                                            Get.to(ProfileCompletionScreen());
                                          } else {
                                            Get.to(HealthChallengesComponents(
                                              list: const ["global", "Global"],
                                            ));
                                          }
                                        },
                                        child: ChallengeCard().noChallenegs(context),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                         GetBuilder<UpcomingDetailsController>(
                              init: Get.put(UpcomingDetailsController()),
                              builder: (_) {
                                if (_.upComingDetails.enrolChallengeList != null) {
                                  return Visibility(
                                    //visible: _.upComingDetails.enrolChallengeList!.isEmpty,
                                    visible: false,
                                    child: Card(
                                      child: Column(children: [
                                        GestureDetector(
                                          child: ChallengeCard().newChallenge(context),
                                          onTap: () {
                                            if (PercentageCalculations()
                                                    .calculatePercentageFilled() !=
                                                100) {
                                              Get.to(ProfileCompletionScreen());
                                            } else {
                                              Get.to(HealthChallengesComponents(
                                                list: const ["global", "Global"],
                                              ));
                                            }
                                          },
                                        )
                                      ]),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              }),*/
                          /*    GetBuilder<UpcomingDetailsController>(
                              init: Get.put(UpcomingDetailsController()),
                              id: "user_enroll_challenge",
                              builder: (_) {
                                if (_.upComingDetails.enrolChallengeList != null) {
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
                                                padding: const EdgeInsets.only(
                                                    left: 8, right: 8, top: 8),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8)),
                                                child: const Text('Hello')))
                                        : Padding(
                                            padding:
                                                EdgeInsets.only(right: 1.w, left: 1.w, bottom: 1.h),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(10, 14, 14, 10),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        "Ongoing Challenge",
                                                        style: AppTextStyles.cardContent,
                                                      ),
                                                      const Spacer(),
                                                      TeleConsultationWidgets().viewAll(
                                                        onTap: () {
                                                          if (PercentageCalculations()
                                                                  .calculatePercentageFilled() !=
                                                              100) {
                                                            Get.to(ProfileCompletionScreen());
                                                          } else {
                                                            Get.to(
                                                              HealthChallengesComponents(
                                                                list: const ["global", "Global"],
                                                              ),
                                                            );
                                                          }
                                                        },
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
                              }),*/

                          //Online Class
                          Visibility(
                            visible: widget.selectedProgram.isNotEmpty &&
                                widget.selectedProgram.contains("Online Class"),
                            child: GetBuilder<UpcomingDetailsController>(
                                init: Get.put(UpcomingDetailsController()),
                                id: "user_upcoming_detils",
                                builder: (_) {
                                  if (_.upComingDetails.subcriptionList != null) {
                                    if (_.upComingDetails.subcriptionList.isEmpty) {
                                      return SubscriptionWidgets().subscriptionCard(
                                          context: context,
                                          staticCard: true,
                                          affi: fitnessClassSpecialties);
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
                          ),

                          //Health Tips
                          ValueListenableBuilder(
                              valueListenable: ChangeHealthTips.healthtipslist,
                              builder: (_, val, __) {
                                return Visibility(
                                    visible: ChangeHealthTips.healthtipslist.value.isNotEmpty &&
                                        widget.selectedProgram.isNotEmpty &&
                                        widget.selectedProgram.contains("Health Tips"),
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
                          Visibility(
                            visible: widget.selectedProgram.isNotEmpty &&
                                widget.selectedProgram.contains("Health Tips"),
                            child: GestureDetector(
                              onTap: () {
                                _tabController.updateSelectedIconValue(
                                    value: AppTexts.healthProgramms);
                                Get.put(VitalsContoller);

                                PercentageCalculations().calculatePercentageFilled() != 100
                                    ? Get.to(ProfileCompletionScreen())
                                    : Get.to(CardioDashboardNew(
                                        tabView: false,
                                      ));
                                // Navigator.pushAndRemoveUntil(
                                //     context,
                                //     MaterialPageRoute(builder: (context) => HomeScreen(introDone: true)),
                                //     (Route<dynamic> route) => false);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 8.sp, bottom: 6.sp, right: 8.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 1.w),
                                      child: Text(
                                        vital != null
                                            ? 'Suggested Health Program'
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
                                          color: AppColors.plainColor,
                                          borderRadius: BorderRadius.circular(5)),
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
                          // SizedBox(
                          //   height: 15.h,
                          // ),
                        ],
                      ),
                    ),
                    const AffiliationDashboard(),
                  ],
                )),
    );
  }
}
