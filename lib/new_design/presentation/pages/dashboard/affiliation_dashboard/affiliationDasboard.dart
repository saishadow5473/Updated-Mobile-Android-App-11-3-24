import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/health_challenge/views/new_challenge_category.dart';
import '../../../../../Modules/online_class/bloc/class_and_consultant_bloc/bloc/classandconsultantbloc_bloc.dart';
import '../../../../../Modules/online_class/bloc/trainer_status/bloc/trainer_bloc.dart';
import '../../../../../Modules/online_class/presentation/pages/class_and_consultant_list.dart';
import '../../../../../Modules/online_class/presentation/pages/view_all_class.dart';
import '../../../../../health_challenge/networks/network_calls.dart';
import '../../../../app/utils/textStyle.dart';

import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../../widgets/signin_email.dart';
import '../../../../app/utils/appText.dart';
import '../../../../app/utils/constLists.dart';
import '../../../../data/model/affiliation_details_model.dart';
import '../../../../data/model/loginModel/userDataModel.dart';
import '../../../../data/providers/network/apis/healthTipsApi/healthTipsApi.dart';
import '../../../../../views/otherVitalController/otherVitalController.dart';
import 'package:flutter/material.dart';
import '../../../../../Getx/controller/BannerChallengeController.dart';
import '../../../../../Getx/controller/listOfChallengeContoller.dart';

import '../../../../data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../../../data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';
import '../../../Widgets/appBar.dart';
import '../../../Widgets/healthChallengeWidgets/DashBoardHealthChallengeWidget.dart';
import '../../../Widgets/varientBannerWidgets.dart';
import 'package:get/get.dart';
import '../../../Widgets/dashboardWidgets/healthtip_widget.dart';
import '../../../Widgets/vitals/vitalCards.dart';
import '../../../controllers/healthTipsController/healthTipsController.dart';
import '../../../controllers/healthchallenge/googlefitcontroller.dart';
import '../../../../../utils/SpUtil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../../cardio_dashboard/views/cardio_dashboard_new.dart';
import '../../../../../constants/api.dart';
import '../../../../../constants/spKeys.dart';
import '../../../../../health_challenge/views/health_challenges_types.dart';
import '../../../../../views/affiliation/class_and_consultants_screen.dart';
import '../../../../../views/affiliation/selectClassesForAffiliation.dart';
import '../../../../../views/affiliation/selectConsultantForAffiliation.dart';
import '../../../../../views/teleconsultation/MySubscription.dart';
import '../../../../app/config/crossbarConfig.dart';
import '../../../../app/utils/appColors.dart';
import '../../../../app/utils/localStorageKeys.dart';
import '../../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../../Widgets/dashboardWidgets/subsrciption_widget.dart';
import '../../../Widgets/dashboardWidgets/teleconsultation_widget.dart';
import '../../../Widgets/healthJournalCard.dart';
import '../../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../../controllers/dashboardControllers/upComingDetailsController.dart';
import '../../../controllers/healthJournalControllers/getTodayLogController.dart';
import '../../../controllers/vitalDetailsController/myVitalsController.dart';
import '../../basicData/functionalities/percentage_calculations.dart';
import '../../basicData/screens/GenderScreen.dart';
import '../../basicData/screens/ProfileCompletion.dart';
import '../../myVitals/vitalsHomeCard.dart';
import '../../profile/updatePhoto.dart';
import '../../spalshScreen/splashScreen.dart';
import 'package:http/http.dart' as http;

import '../common_screen_for_navigation.dart';

bool eMarketaff = true;
bool isCorporateWellness = false;
String selectedAffiliationfromuniquenameDashboard = '';
String selectedAffiliationcompanyNamefromDashboard = '';
int selectedAffiliationIndex = 0;
AfNo gAfNo;
Color affiColor = AppColors.primaryColor;

List options = [
  {
    'colors': '',
    'image': 'newAssets/Icons/financial.png',
    'text': 'Physical Wellbeing',
    'icon': '',
    'onTap': () {
      Get.to(ClassAndConsultantScreen(
        companyName: selectedAffiliationfromuniquenameDashboard,
        category: 'Physical Wellbeing',
      ));
      // Get.to(ClassAndConsultantScreen(
      //   companyName: UpdatingColorsBasedOnAffiliations.selectedAffiliation.value,
      //   category: 'Physical Wellbeing',
      // ));
    }
  },
  {
    'colors': '',
    'image': 'newAssets/Icons/physical.png',
    'text': 'Emotional Wellbeing',
    'icon': '',
    'onTap': () {
      Get.to(ClassAndConsultantScreen(
        companyName: selectedAffiliationfromuniquenameDashboard,
        category: 'Emotional Wellbeing',
      ));
    }
  },
  {
    'colors': '',
    'image': 'newAssets/Icons/socials.png',
    'text': 'Financial Wellbeing',
    'icon': '',
    'onTap': () {
      Get.to(ClassAndConsultantScreen(
        companyName: selectedAffiliationfromuniquenameDashboard,
        category: 'Financial Wellbeing',
      ));
    }
  },
  {
    'colors': '',
    'image': 'newAssets/Icons/emotional.png',
    'text': 'Social Wellbeing',
    'icon': '',
    'onTap': () {
      Get.to(ClassAndConsultantScreen(
        companyName: selectedAffiliationfromuniquenameDashboard,
        category: 'Social Wellbeing',
      ));
    }
  },
  {
    'colors': AppColors.hightStatusColor,
    'image': '',
    'text': 'Health E-Market',
    'icon': FontAwesomeIcons.weightHanging,
    'onTap': () {
      Get.to(ClassAndConsultantScreen(
        companyName: selectedAffiliationfromuniquenameDashboard,
        category: "Health E-Market",
        //SmithFit✅✅
        // categorySmit: "Health E-Market",
      ));
    }
  },
  {
    'colors': AppColors.subscription,
    'image': '',
    'text': 'Subscription',
    'icon': FontAwesomeIcons.solidBell,
    'onTap': () {
      Get.to(const MySubscription(
        afterCall: false,
        onlineCourse: true,
      ));
    }
  },
  {
    'colors': AppColors.nearlyDarkBlue,
    'image': '',
    'text': 'Health Challenges',
    'icon': FontAwesomeIcons.solidThumbsUp,
    'onTap': () => PercentageCalculations().calculatePercentageFilled() != 100
        ? Get.to(ProfileCompletionScreen())
        : Get.to(HealthChallengesComponents(
            list: const ["global", "Global"],
          ))
  },
  {
    'colors': AppColors.primaryAccentColor.withOpacity(0.7),
    'image': '',
    'text': 'Events & Programs',
    'icon': FontAwesomeIcons.building,
    'onTap': () {
      PercentageCalculations().calculatePercentageFilled() != 100
          ? Get.to(ProfileCompletionScreen())
          : Get.to(SelectClassesForAffiliation(
              companyName: selectedAffiliationfromuniquenameDashboard,
              arg: const {'Events & Programs': 'Events & Programs'},
              navigateToDashBoard: true,
            ));
    }
  },
  // {
  //   'colors': AppColors.primaryAccentColor.withOpacity(0.7),
  //   'image': 'assets/images/Smitfit_playstore.png',
  //   'text': 'Connect to SmitFit',
  //   'icon': '',
  //   'onTap': () async {
  //
  //     if (Platform.isIOS) {
  //       bool a = await launchUrl(Uri.parse('com.smit.fit://'),
  //           mode: LaunchMode.externalApplication);
  //       print(a);
  //       if (a == false) {
  //         Get.to(AffilicationAppDescription(
  //           iHLUserId: iHLUserId,
  //           userMobile: userMobile,
  //           userEmail: userEmail,
  //         ));
  //       }
  //     } else {
  //       var isAppInstalledResult = await LaunchApp.isAppInstalled(
  //           androidPackageName: 'com.smitfit', iosUrlScheme: 'com.smit.fit://'
  //         // openStore: false
  //       );
  //       isAppInstalledResult
  //           ? LaunchApp.openApp(
  //               androidPackageName: 'com.smitfit',
  //               iosUrlScheme: 'com.smit.fit://',
  //               appStoreLink:
  //                   'https://apps.apple.com/in/app/smit-fit/id1525550488')
  //           : Get.to(AffilicationAppDescription(
  //               iHLUserId: iHLUserId,
  //               userMobile: userMobile,
  //               userEmail: userEmail,
  //             ));
  //     }
  //
  //   }
  // },
];

class AffiliationDashboard extends StatefulWidget {
  final List<String> selectedProgram;

  const AffiliationDashboard({Key key, this.selectedProgram}) : super(key: key);

  @override
  State<AffiliationDashboard> createState() => _AffiliationDashboardState();
}

class _AffiliationDashboardState extends State<AffiliationDashboard> {
  // const AffiliationDashboard({Key key}) : super(key: key);
  final TabBarController tabBarController = Get.find();
  AfNo currentAffi;
  var subscription;
  bool connectionInit = false;
  final UpcomingDetailsController upcomingDetailsController = Get.put(UpcomingDetailsController());
  final HealthTipsController healthTipsController = Get.put(HealthTipsController());
  final TodayLogController todayLogController = Get.put(TodayLogController());
  final GoogleFitController googleFitController = Get.put(GoogleFitController());
  static ValueNotifier<int> affiEntered = ValueNotifier(0);
  final BannerChallengeController _bannerController = Get.put(BannerChallengeController());
  final ListChallengeController _listofChallengeController = Get.put(ListChallengeController());
  Map fitnessClassSpecialties;
  Map res;
  final http.Client _client = http.Client();
  List<AfNo> userAffiliateDatas = [];
  ValueNotifier<String> selectedSso = ValueNotifier('');
  bool firstAffi; //3gb
  var vital;
  final RxBool _vitalLoaded = false.obs;
  @override
  void initState() {
    checkInternetConnectivity();
    print(UpdatingColorsBasedOnAffiliations.selectedAffiliation.value);
    updateVitalsEveryTime();
    affiEntered.value = 0;
    eMarketaff = false;
    if (userAffiliateDatas != null) {
      userAffiliateDatas.clear();
    }
    if (selectedAffiliationfromuniquenameDashboard == "ihl_care" ||
        selectedAffiliationfromuniquenameDashboard == "IHL CARE" ||
        selectedAffiliationfromuniquenameDashboard == "IHL") {
      isCorporateWellness = true;
    }
    tabBarController.programsTab.value = 0;
    getData();
    Future.delayed(Duration.zero, () async {
      tabBarController.updateSelectedIconValue(value: "Home");
      localSotrage.listenKey("updateCalled", (value) {});
    });
    super.initState();
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
  void dispose() {
    userAffiliateDatas.clear();

    super.dispose();
  }

  Future getDataDiagnostic(var companyName, var specalityType, var consultationTypeName) async {
    ///"specality_name" -> "Corporate Wellness"
    print('specalityType======$specalityType');
    print('consultation_type_name====$consultationTypeName');

    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    Object data1 = prefs1.get('data');
    Map res1 = jsonDecode(data1);
    var iHLUserId = res1['User']['id'];

    final http.Response getPlatformData = await _client.post(
      Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
      body: jsonEncode(<String, String>{'ihl_id': iHLUserId, 'cache': "true"}),
    );
    if (getPlatformData.statusCode == 200) {
      if (getPlatformData.body != null) {
        Map res = jsonDecode(getPlatformData.body);
        final SharedPreferences platformData = await SharedPreferences.getInstance();
        platformData.setString(SPKeys.platformData, getPlatformData.body);
        if (res['consult_type'] == null ||
            res['consult_type'] is! List ||
            res['consult_type'].isEmpty) {
          return;
        }
        var consultationType = res['consult_type'];

        for (int i = 0; i < consultationType.length; i++) {
          if (consultationType[i]["consultation_type_name"] == "$consultationTypeName") {
            // "Health Consultation") {
            for (int j = 0; j < consultationType[i]["specality"].length; j++) {
              // "Fitness Class":"Health Consultation")
              if (consultationType[i]["specality"][j]["specality_name"].replaceAll('amp;', '') ==
                  "$specalityType") {
                if (consultationTypeName == "Health Consultation") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SelectConsultantForAffiliation(
                                companyName: companyName,
                                arg: consultationType[i]["specality"][j],
                                liveCall: true,
                              )));
                } else if (consultationTypeName == "Fitness Class") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => SelectClassesForAffiliation(
                        companyName: companyName,
                        arg: consultationType[i]["specality"][j],
                        navigateToDashBoard: true,
                      ),
                    ),
                  );
                }
                break;
              }
            }
          }
        }
        if (mounted) {}
      }
    }
  }

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data1 = prefs.get('data');
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
    } else {
      print(getPlatformData.body);
    }

    //platformData = prefs.get(SPKeys.platformData);

    if (res['consult_type'] == null ||
        res['consult_type'] is! List ||
        res['consult_type'].isEmpty) {
      return;
    }

    fitnessClassSpecialties = res['consult_type'][1];
  }

  ValueNotifier<Map<dynamic, dynamic>> response = ValueNotifier<Map<dynamic, dynamic>>({});

  void updateVitalsEveryTime() async {
    print('######################## Vitals Apis called ########################');
    // CheckAllDataLoaded.data.value = false;
    response.value = await SplashScreenApiCalls().loginApi();
    // Listen vital changes and update the widget
    localSotrage.listenKey((LSKeys.vitalsData), (v) {
      vital = localSotrage.read(LSKeys.vitalsData);
      _vitalLoaded.value = true;
    });
    await MyvitalsApi().vitalDatas(response.value);
    String userId = SpUtil.getString(LSKeys.ihlUserId);
    await MyVitalsController().getVitalsCheckinData(userId);
    print('######################## Vitals Apis Finished ########################');
  }

  @override
  Widget build(BuildContext context) {
    bool expand = true;

    // Instantiate your class using Get.put() to make it available for all "child" routes there.
    // var vital = jsonDecode(SpUtil.getString(LSKeys.vitalsData));
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
        child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(children: [
              // Padding(
              //   padding: EdgeInsets.all(2.h),
              //   child: SearchBarWidget(),
              // ),

              const SizedBox(height: 10),
              if (UpdatingColorsBasedOnAffiliations.ssoAffiliation != null &&
                  UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] !=
                      null)
                GetBuilder<TabBarController>(
                  id: "User Affiliations",
                  initState: (_) async {
                    if (tabBarController.userData == null) {
                      await tabBarController.afffliationDetailsGetter();
                    }
                  },
                  builder: (TabBarController controller) {
                    print(controller.userData == null);
                    if (controller.userData == null) {
                      return Shimmer.fromColors(
                          direction: ShimmerDirection.ltr,
                          period: const Duration(seconds: 2),
                          baseColor: const Color.fromARGB(255, 240, 240, 240),
                          highlightColor: Colors.grey.withOpacity(0.2),
                          child: Container(
                              height: 15.h,
                              width: 100.w,
                              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                              decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Data Loading')));
                    }
                    if (controller.userData.userAffiliate.afNo1.affilateName == null ||
                        controller.userData.userAffiliate.afNo1.affilateName == "") {
                      return Shimmer.fromColors(
                          direction: ShimmerDirection.ltr,
                          period: const Duration(seconds: 2),
                          baseColor: const Color.fromARGB(255, 240, 240, 240),
                          highlightColor: Colors.grey.withOpacity(0.2),
                          child: Container(
                              height: 15.h,
                              width: 100.w,
                              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                              decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Data Loading')));
                    } else {
                      UserAffiliate userAffiliate = controller.userData?.userAffiliate;
                      if (userAffiliate.afNo1.affilateUniqueName != null) {
                        userAffiliateDatas.add(userAffiliate.afNo1);
                      }
                      if (userAffiliate.afNo2.affilateUniqueName != null) {
                        userAffiliateDatas.add(userAffiliate.afNo2);
                      }
                      if (userAffiliate.afNo3.affilateUniqueName != null) {
                        userAffiliateDatas.add(userAffiliate.afNo3);
                      }
                      if (userAffiliate.afNo4.affilateUniqueName != null) {
                        userAffiliateDatas.add(userAffiliate.afNo4);
                      }
                      if (userAffiliate.afNo5.affilateUniqueName != null) {
                        userAffiliateDatas.add(userAffiliate.afNo5);
                      }
                      if (userAffiliate.afNo6.affilateUniqueName != null) {
                        userAffiliateDatas.add(userAffiliate.afNo6);
                      }
                      if (userAffiliate.afNo7.affilateUniqueName != null) {
                        userAffiliateDatas.add(userAffiliate.afNo7);
                      }
                      if (userAffiliate.afNo8.affilateUniqueName != null) {
                        userAffiliateDatas.add(userAffiliate.afNo8);
                      }
                      if (userAffiliate.afNo9.affilateUniqueName != null) {
                        userAffiliateDatas.add(userAffiliate.afNo9);
                      }
                      userAffiliateDatas =
                          TabBarController().removeDuplicateAffis(list: userAffiliateDatas);
                      String ssoAffi = UpdatingColorsBasedOnAffiliations
                          .ssoAffiliation["affiliation_unique_name"];
                      AfNo current;
                      try {
                        current = userAffiliateDatas.where((AfNo element) {
                          return element.affilateUniqueName == ssoAffi;
                        }).first;
                      } catch (e) {
                        current = userAffiliate.afNo1;
                        UpdatingColorsBasedOnAffiliations
                            .ssoAffiliation["affiliation_unique_name"] = current.affilateUniqueName;
                        UpdatingColorsBasedOnAffiliations.affiMap.value = <String, dynamic>{
                          "affiliation_unique_name": current.affilateUniqueName
                        };
                      }
                      //temp fix
                      Tabss.featureSettings =
                          // current.featureSettings;
                          FeatureSettings(
                              healthJornal: true,
                              challenges: true,
                              newsLetter: true,
                              askIhl: true,
                              hpodLocations: true,
                              teleconsultation: true,
                              onlineClasses: true,
                              myVitals: true,
                              stepCounter: true,
                              heartHealth: true,
                              setYourGoals: true,
                              diabeticsHealth: true,
                              healthTips: true,
                              personalData: false);
                      if (userAffiliateDatas
                          .any((AfNo element) => element.affilateUniqueName == ssoAffi)) {
                        String desiredValue = "ihl_care";
                        log("it contains $ssoAffi affiliation");
                        AfNo ihlCareAffi;
                        if (selectedAffiliationfromuniquenameDashboard == '') {
                          ihlCareAffi = userAffiliateDatas
                              .where((AfNo e) => e.affilateUniqueName == ssoAffi)
                              .toList()
                              .first;
                          selectedAffiliationfromuniquenameDashboard =
                              ihlCareAffi.affilateUniqueName;
                          selectedAffiliationcompanyNamefromDashboard = ihlCareAffi.affilateName;
                          //   CheckUpcomingDataIsLoaded.showShimmer.value = true;
                        } else {
                          ihlCareAffi = gAfNo;
                        }
                        // print(ihlCareAffi.affilateUniqueName);
                        // userAffiliateDatas.sort((a, b) {
                        //   if (a.affilateUniqueName == desiredValue) {
                        //     return -1; // Move "ihl_care" to the front
                        //   } else if (b.affilateUniqueName == desiredValue) {
                        //     return 1; // Move "ihl_care" to the back
                        //   } else {
                        //     return a.affilateUniqueName.compareTo(b
                        //         .affilateUniqueName); // Maintain the original order for other elements
                        //   }
                        // });

                        start = 0;
                        end = 1;
                        HealthTipsApi.ihlUniqueName = ssoAffi;
                        ChangeHealthTips.healthtipslist.value.clear();
                        ChangeHealthTips.getTips();
                        // upcomingDetailsController.onInit();
                        // CheckUpcomingDataIsLoaded.showShimmer.value = true;
                        // upcomingDetailsController.upComingDetails.enrolChallengeList.clear();
                        // if (upcomingDetailsController.upComingDetails.enrolChallengeList != null) {
                        //   upcomingDetailsController.upComingDetails.enrolChallengeList.clear();
                        //   upcomingDetailsController.update(['user_enroll_challenge']);
                        // }
                        upcomingDetailsController.updateUpcomingDetails(fromChallenge: false);
                      } else {
                        HealthTipsApi.ihlUniqueName = current.affilateUniqueName;
                        selectedAffiliationfromuniquenameDashboard = current.affilateUniqueName;
                        UpdatingColorsBasedOnAffiliations.selectedAffiliation.value =
                            current.affilateUniqueName;
                        CheckUpcomingDataIsLoaded.showShimmer.value = true;
                        //  upcomingDetailsController.upComingDetails.enrolChallengeList.clear();
                        // if (upcomingDetailsController.upComingDetails.enrolChallengeList != null) {
                        //   upcomingDetailsController.upComingDetails.enrolChallengeList.clear();
                        //   upcomingDetailsController.update(['user_enroll_challenge']);
                        // }
                        upcomingDetailsController.updateUpcomingDetails(fromChallenge: false);
                      }
                      // userAffiliateDatas.removeAt(userAffiliateDatas.length - 1);

                      // AffiliationWidgets.affiBoardChanges(
                      //     affi: current, userAffiliateDatas: userAffiliateDatas);
                      UpdatingColorsBasedOnAffiliations.updateColor(
                          colorCode: int.parse("0XFF${current.affiliate_theme_color}"));
                      UpdatingColorsBasedOnAffiliations.selectedAffiliation.value =
                          current.affilateUniqueName;
                      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                      // UpdatingColorsBasedOnAffiliations.affiMap.notifyListeners();
                      return ValueListenableBuilder<Map<String, dynamic>>(
                          valueListenable: UpdatingColorsBasedOnAffiliations.affiMap,
                          builder: (BuildContext _, Map<String, dynamic> val, Widget child) {
                            Color col = UpdatingColorsBasedOnAffiliations.affiColorCode.value == 0
                                ? AppColors.primaryAccentColor
                                : Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value);
                            if (affiEntered.value == 0) {
                              String uniqueName = UpdatingColorsBasedOnAffiliations
                                  .ssoAffiliation["affiliation_unique_name"];
                              currentAffi = userAffiliateDatas.where((AfNo element) {
                                return element.affilateUniqueName == uniqueName;
                              }).first;
                              // affiEntered.value++;
                            }
                            return Padding(
                              padding: EdgeInsets.only(
                                top: 1.5.h,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 100.w,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(width: 5.w),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(0, 8.sp, 0, 8.sp),
                                          child: Container(
                                            height: 15.w,
                                            width: 15.w,
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                image: DecorationImage(
                                                    fit: BoxFit.contain,
                                                    image: NetworkImage(currentAffi.imgUrl))),
                                          ),
                                        ),
                                        // const Spacer(),
                                        Expanded(
                                          child: Text(
                                            currentAffi.affilateName == "Wework Member" ||
                                                    currentAffi.affilateName == "Wework"
                                                ? '${currentAffi.affilateName} India'
                                                : currentAffi.affilateName,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12.3.sp,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                        Visibility(
                                          visible: userAffiliateDatas.length != 1,
                                          replacement: SizedBox(width: 15.w),
                                          child: Container(
                                            height: 15.w,
                                            alignment: Alignment.topRight,
                                            child: SizedBox(
                                              width: 26.w,
                                              height: 9.w,
                                              child: PopupMenuButton<String>(
                                                  tooltip: "Affiliation Switch",
                                                  // constraints: BoxConstraints.expand(height: 25.w),
                                                  padding: EdgeInsets.zero,
                                                  icon: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      color: Colors.white,
                                                      boxShadow: <BoxShadow>[
                                                        BoxShadow(
                                                            blurRadius: 4,
                                                            spreadRadius: 1,
                                                            color: Colors.black.withOpacity(0.2),
                                                            offset: const Offset(0, 0))
                                                      ],
                                                      // borderRadius: BorderRadius.circular(5.sp),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        SizedBox(width: 1.w),
                                                        Text(
                                                          "Switch",
                                                          style: TextStyle(
                                                              fontFamily: 'Poppins',
                                                              fontSize: 9.sp),
                                                        ),
                                                        SizedBox(
                                                          height: 7.w,
                                                          width: 7.w,
                                                          child: Image.asset(
                                                              "newAssets/Icons/swap.png"),
                                                        ),
                                                        SizedBox(width: 1.w),
                                                      ],
                                                    ),
                                                  ),
                                                  itemBuilder: (BuildContext context) =>
                                                      userAffiliateDatas.map((AfNo e) {
                                                        return PopupMenuItem<String>(
                                                          value: e.affilateUniqueName,
                                                          child: Row(
                                                            children: <Widget>[
                                                              SizedBox(
                                                                  height: 3.h,
                                                                  width: 3.h,
                                                                  child: Image.network(e.imgUrl)),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(e.affilateName.toString())
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                  offset: Offset(-2.5.h, 4.5.h),
                                                  color: Colors.white,
                                                  elevation: 6,
                                                  onSelected: (String value) async {
                                                    //removed all the dead codes for simplicity
                                                    SharedPreferences prefs =
                                                        await SharedPreferences.getInstance();
                                                    AfNo selectedAffi =
                                                        userAffiliateDatas.where((AfNo element) {
                                                      return element.affilateUniqueName == value;
                                                    }).first;
                                                    selectedSso.value =
                                                        selectedAffi.affilateUniqueName;
                                                    Object isSso = prefs.get(SPKeys.is_sso);
                                                    // if isSSo true we're showing pop-up and forced user to logout
                                                    if (selectedAffi.isSso) {
                                                      // ignore: use_build_context_synchronously
                                                      _showAlertDialog(
                                                          context,
                                                          selectedAffi.isSso,
                                                          selectedAffi.affilateName,
                                                          value,
                                                          selectedAffi);
                                                    } else {
                                                      // if isSSo false directly switching the affiliations and updating required login things
                                                      HealthTipsApi.ihlUniqueName = value;
                                                      AffiliationWidgets.affiBoardChanges(
                                                          affi: selectedAffi,
                                                          userAffiliateDatas: userAffiliateDatas);
                                                      UpdatingColorsBasedOnAffiliations
                                                              .ssoAffiliation[
                                                          "affiliation_unique_name"] = value;
                                                      UpdatingColorsBasedOnAffiliations
                                                          .affiMap.value = <String, dynamic>{
                                                        "affiliation_unique_name": value
                                                      };
                                                      String uniqueName =
                                                          UpdatingColorsBasedOnAffiliations
                                                                  .ssoAffiliation[
                                                              "affiliation_unique_name"];
                                                      try {
                                                        BannerChallengeController c =
                                                            Get.put(BannerChallengeController());
                                                        c.getChallenges();
                                                      } catch (e) {
                                                        print(e);
                                                      }
                                                    }
                                                  }),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                      // return Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      // ValueListenableBuilder(
                      //     valueListenable: UpdatingColorsBasedOnAffiliations.affiColorCode,
                      //     builder: (context, index, child) {
                      //       Color col = UpdatingColorsBasedOnAffiliations.affiColorCode.value == 0
                      //           ? AppColors.primaryAccentColor
                      //           : Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value);
                      //       return Padding(
                      //         padding: const EdgeInsets.fromLTRB(14, 0, 8, 8),
                      //         child: Text(
                      //           AppTexts.memberService,
                      //           style: TextStyle(
                      //             fontFamily: 'Poppins',
                      //             fontSize: 12.3.sp,
                      //             color: col,
                      //             fontWeight: FontWeight.w800,
                      //           ),
                      //         ),
                      //       );
                      //     }),
                      // Padding(
                      //     //   padding: EdgeInsets.only(left: 10.sp, top: 10.sp),
                      //     //   child: Text(
                      //     //     "Check various services available exclusively for you",
                      //     //     style: TextStyle(
                      //     //         fontFamily: "Poppins",
                      //     //         color: const Color(0XFF000000),
                      //     //         // height: 1.3,
                      //     //         fontSize: 11.sp),
                      //     //   ),
                      //     // ),
                      //     // SingleChildScrollView(
                      //     //   scrollDirection: Axis.horizontal,
                      //     //   child: ValueListenableBuilder(
                      //     //       valueListenable:
                      //     //           UpdatingColorsBasedOnAffiliations.selectedAffiliation,
                      //     //       builder: (context, index, child) {
                      //     //         return Row(
                      //     //             crossAxisAlignment: CrossAxisAlignment.start,
                      //     //             children: [
                      //     //               ...AffiliationWidgets().affiliationCard(
                      //     //                   userAffiliateDatas: userAffiliateDatas),
                      //     //             ]);
                      //     //       }),
                      //     // ),
                      //   ],
                      // );
                    }
                  },
                ),
              PercentageCalculations().calculatePercentageFilled() != 100
                  ? Padding(
                      padding: EdgeInsets.only(top: 1.5.h, left: 0.2.w, right: 0.2.w),
                      child: Container(
                        padding: EdgeInsets.all(5.sp),
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
                                            builder:
                                                (BuildContext context, String val, Widget child) {
                                              return Container(
                                                height: 15.h,
                                                width: 28.w,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: MemoryImage((PhotoChangeNotifier
                                                                  .photo.value ==
                                                              null)
                                                          ? photoDecoded
                                                          : base64Decode(
                                                              PhotoChangeNotifier.photo.value))),
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
                                                    borderRadius: BorderRadius.circular(20)),
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
                                      PercentageCalculations().calculatePercentageFilled() != 100
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
              GetBuilder<UpcomingDetailsController>(
                  // init: UpcomingDetailsController(),
                  id: "user_upcoming_detils",
                  builder: (_) {
                    return ValueListenableBuilder(
                        valueListenable: UpdatingColorsBasedOnAffiliations.selectedAffiliation,
                        builder: (BuildContext ctx, index, Widget child) {
                          if (_.upComingDetails.subcriptionList != null) {
                            if (_.upComingDetails.subcriptionList.isEmpty) {
                              return const SizedBox();
                            } else {
                              return SubscriptionWidgets().subscriptionCard(
                                  context: context,
                                  afficolor:
                                      Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value),
                                  staticCard: false,
                                  subcriptionList: _.upComingDetails.subcriptionList.first,
                                  affi: fitnessClassSpecialties);
                            }
                          } else {
                            return Container();
                          }
                        });
                  }),
              //TeleConsultation Card 🚩
              GetBuilder<UpcomingDetailsController>(
                  id: "user_upcoming_detils",
                  builder: (_) {
                    return ValueListenableBuilder(
                        valueListenable: UpdatingColorsBasedOnAffiliations.affiColorCode,
                        builder: (BuildContext context, index, Widget child) {
                          Color col = UpdatingColorsBasedOnAffiliations.affiColorCode.value == 0
                              ? AppColors.primaryAccentColor
                              : Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value);
                          List<Color> listColor =
                              UpdatingColorsBasedOnAffiliations.affiColorCode.value == 0
                                  ? [
                                      AppColors.primaryAccentColor.withOpacity(0.5),
                                      Colors.blue.shade100.withOpacity(0.5),
                                    ]
                                  : [
                                      Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value)
                                          .withOpacity(0.4),
                                      Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value)
                                          .withOpacity(0.12)
                                    ];
                          if (_.upComingDetails.appointmentList != null) {
                            if (_.upComingDetails.appointmentList.isEmpty) {
                              return SizedBox(
                                  width: 100.w,
                                  child: ValueListenableBuilder(
                                      valueListenable:
                                          UpdatingColorsBasedOnAffiliations.affiColorCode,
                                      builder: (BuildContext context, index, Widget child) {
                                        return const SizedBox();
                                        // return Visibility(
                                        //   visible: Tabss.featureSettings.teleconsultation,
                                        //   child: TeleConsultationWidgets()
                                        //       .teleConsultationDashboardWidget(
                                        //           staticCard: true,
                                        //           affiColor: col,
                                        //           linerColor: listColor,
                                        //           context: context),
                                        // );
                                      }));
                            } else {
                              CrossBarConnect().consultantStatus(
                                  _.upComingDetails.appointmentList.first.ihlConsultantId);
                              return SizedBox(
                                  width: 100.w,
                                  child: TeleConsultationWidgets().teleConsultationDashboardWidget(
                                      context: context,
                                      appointmentList: _.upComingDetails.appointmentList[0],
                                      staticCard: false,
                                      affiColor: col,
                                      linerColor: listColor));
                            }
                          } else {
                            return Container();
                          }
                        });
                  }),
              DashBoardHealthChallengeWidget().upcomingChallengeWidget(context, top: true),
              ValueListenableBuilder<String>(
                valueListenable: UpdatingColorsBasedOnAffiliations.selectedAffiliation,
                builder: (BuildContext context, String index, Widget child) {
                  Color col = Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Our Services",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.3.sp,
                            color: col,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.36),
                        TeleConsultationWidgets().viewAll(
                            onTap: () async {
                              TabBarController tab = Get.find<TabBarController>();
                              tab.updateSelectedIconValue(value: AppTexts.onlineServices);

                              PercentageCalculations().calculatePercentageFilled() != 100
                                  ? await Get.to(ProfileCompletionScreen())
                                  : await Get.to(ViewFourPillar(context));
                              tab.updateSelectedIconValue(value: "Home");
                            },
                            color: col),
                      ],
                    ),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.000003.h, right: 1.w, left: 1.w),
                child: SizedBox(
                    height: 70.w,
                    width: 100.w,
                    child: ValueListenableBuilder<String>(
                        valueListenable: UpdatingColorsBasedOnAffiliations.selectedAffiliation,
                        builder: (BuildContext context, String val, Widget child) {
                          return GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: options.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, childAspectRatio: 2 / 1.4
                                // crossAxisSpacing: 4.0,
                                // mainAxisSpacing: 4.0
                                ),
                            itemBuilder: (BuildContext context, int index) {
                              if (UpdatingColorsBasedOnAffiliations.selectedAffiliation.value ==
                                      "dev_testing" &&
                                  index == options.length - 1) {
                                return Container();
                              }
                              // if (selectedAffiliationfromuniquenameDashboard == "dev_testing" &&
                              //     index == options.length - 2) {
                              //   return Container();
                              // }
                              // if (selectedAffiliationfromuniquenameDashboard == "ihl_care" &&
                              //     index == options.length - 1) {
                              //   return Container();
                              // }
                              return GestureDetector(
                                onTap: options[index]['text'] == "Health Challenges"
                                    ? () async {
                                        // Get.to(NewChallengeCategory());
                                        await NetworkCalls().getChallengeCategory();
                                        Get.to(HealthChallengesComponents(
                                          list: const ["global", "Global"],
                                        ));
                                      }
                                    : options[index]['text'] == "Subscription"
                                        ? () {
                                            tabBarController.updateSelectedIconValue(
                                                value: AppTexts.onlineServices);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute<dynamic>(
                                                    builder: (BuildContext ctx) =>
                                                        MultiBlocProvider(
                                                          providers: [
                                                            BlocProvider(
                                                                create: (BuildContext context) =>
                                                                    TrainerBloc()),
                                                          ],
                                                          child: ViweAllClass(
                                                              subcriptionList: const [],
                                                              isHome: "Yes"),
                                                        )));
                                          }
                                        : () async {
                                            tabBarController.updateSelectedIconValue(
                                                value: AppTexts.onlineServices);
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext context) =>
                                                        MultiBlocProvider(
                                                            providers: [
                                                              BlocProvider(
                                                                  create: (BuildContext context) =>
                                                                      ClassandconsultantblocBloc()),
                                                            ],
                                                            child: ClassAndConsultantListPage(
                                                              category: options[index]['text'],
                                                            ))));

                                            tabBarController.updateSelectedIconValue(value: "Home");
                                          },
                                // onTap: options[index]['onTap'],
                                child: Card(
                                  color: AppColors.plainColor,
                                  elevation: 3,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(height: 2.h),
                                        Center(
                                          child: Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: SizedBox(
                                                  height: 8.h,
                                                  width: 60.w,
                                                  child: options[index]['image']
                                                          .toString()
                                                          .contains('png')
                                                      ? Image(
                                                          image:
                                                              AssetImage(options[index]['image']))
                                                      : options[index]['icon']
                                                                  .toString()
                                                                  .contains('Customicons') ||
                                                              options[index]['icon']
                                                                  .toString()
                                                                  .contains('AppColors')
                                                          ? Icon(
                                                              options[index]['icon'],
                                                              size: 160.0,
                                                              color: options[index]['colors'],
                                                            )
                                                          : Icon(
                                                              options[index]['icon'],
                                                              size: 30.0,
                                                              color: options[index]['colors'],
                                                            )
                                                  // Row(
                                                  //   children: [
                                                  //     Padding(
                                                  //         padding:
                                                  //         const EdgeInsets
                                                  //             .all(6.0),
                                                  //         child: options[index]
                                                  //         [
                                                  //         'image']
                                                  //             .toString()
                                                  //             .contains(
                                                  //             'svg')
                                                  //             ? SvgPicture
                                                  //             .asset(
                                                  //           options[index]
                                                  //           [
                                                  //           'image'],
                                                  //         )
                                                  //             : options[index]['icon'].toString().contains(
                                                  //             'Customicons') ||
                                                  //             options[index]['icon']
                                                  //                 .toString()
                                                  //                 .contains('AppColors')
                                                  //             ? Icon(
                                                  //           options[index]
                                                  //           [
                                                  //           'icon'],
                                                  //           size:
                                                  //           160.0,
                                                  //           color:
                                                  //           options[index]['colors'],
                                                  //         )
                                                  //             : Icon(
                                                  //           options[index]
                                                  //           [
                                                  //           'icon'],
                                                  //           size:
                                                  //           30.0,
                                                  //           color:
                                                  //           options[index]['colors'],
                                                  //         )),
                                                  //     SizedBox(
                                                  //       width: MediaQuery.of(
                                                  //           context)
                                                  //           .size
                                                  //           .width *
                                                  //           0.03,
                                                  //     ),
                                                  //     Expanded(
                                                  //         child: Text(
                                                  //           '${options[index]['text']}',
                                                  //           maxLines: 1,
                                                  //           style: TextStyle(
                                                  //               fontSize: 12),
                                                  //         ))
                                                  //   ],
                                                  // ),
                                                  )),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.03,
                                        ),
                                        Expanded(
                                            child: Text(
                                          '${options[index]['text']}',
                                          maxLines: 1,
                                          style: const TextStyle(fontSize: 12),
                                        ))
                                      ]),
                                ),
                              );
                            },
                          );
                        })),
              ),

              ValueListenableBuilder<String>(
                  valueListenable: selectedSso,
                  builder: (BuildContext context, String i, Widget child) {
                    Color color = Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value);
                    return Visibility(
                        visible: i == "ihl_care" ||
                            UpdatingColorsBasedOnAffiliations
                                    .ssoAffiliation["affiliation_unique_name"] ==
                                "ihl_care",
                        child: Padding(
                          padding: EdgeInsets.only(top: 1.5.h, left: 2.w, right: 2.w),
                          child: SpUtil.getInt(LSKeys.ihlScore) != 0
                              ? VitalsCard().vitalsCardWithScore(context)
                              : VitalsCard().vitalsCardWithoutScore(context, color: color),
                        ));
                  }),
              // Vitals Card 🚩
              Obx(() {
                return _vitalLoaded.isTrue
                    ? Visibility(
                        visible: vital != null &&
                            PercentageCalculations().calculatePercentageFilled() == 100,
                        child: Padding(
                          padding: EdgeInsets.only(top: 2.h, right: 1.w, left: 2.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 1.w, bottom: 2),
                                child: Container(
                                  color: AppColors.backgroundScreenColor,
                                  width: 70.w,
                                  child: ValueListenableBuilder(
                                      valueListenable:
                                          UpdatingColorsBasedOnAffiliations.selectedAffiliation,
                                      builder: (BuildContext ctx, i, Widget child) {
                                        return Text(AppTexts.myVitals,
                                            style: Color(UpdatingColorsBasedOnAffiliations
                                                        .affiColorCode.value) ==
                                                    null
                                                ? AppTextStyles.contentHeading
                                                : TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 11.sp,
                                                    color: Color(UpdatingColorsBasedOnAffiliations
                                                        .affiColorCode.value),
                                                    fontWeight: FontWeight.w800,
                                                  ));
                                      }),
                                ),
                              ),
                              ValueListenableBuilder(
                                  valueListenable: CheckAllDataLoaded.data,
                                  builder: (_, v, __) {
                                    return Visibility(
                                      visible: v,
                                      replacement: Shimmer.fromColors(
                                          direction: ShimmerDirection.ltr,
                                          period: const Duration(seconds: 1),
                                          baseColor: const Color.fromARGB(255, 240, 240, 240),
                                          highlightColor: Colors.blueGrey.withOpacity(0.4),
                                          child: Container(
                                              height: 15.h,
                                              width: 100.w,
                                              padding:
                                                  const EdgeInsets.only(left: 8, right: 8, top: 8),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8)),
                                              child: const Text('Data Loading'))),
                                      child: SizedBox(
                                        height: 14.h,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: ProgramLists.vitalDetails.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              return VitalCardsIndiduval(
                                                show: false,
                                                vitalType: ProgramLists.vitalDetails[index],
                                                icon: AssetImage(
                                                    'newAssets/Icons/vitalsDetails/${ProgramLists.vitalDetails[index]}.png'),
                                              );
                                            }),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox();
              }),
              VariantBannerWidget.bannerWidget(
                _bannerController,
                _listofChallengeController,
              ),
              //Health Journal Card 🚩
              Visibility(
                visible: Tabss.featureSettings.healthJornal,
                child: GetBuilder<TodayLogController>(
                    id: "Today Food",
                    builder: (TodayLogController controller) => ValueListenableBuilder(
                        valueListenable: UpdatingColorsBasedOnAffiliations.selectedAffiliation,
                        builder: (BuildContext ctx, i, Widget child) {
                          return controller.logDetails.food != null ||
                                  controller.logDetails.activity != null
                              ? controller.logDetails.food.isEmpty
                                  ? Padding(
                                      padding: EdgeInsets.only(left: 1.w, top: 1.5.h, right: 1.w),
                                      child: HealthJournalCard().staticHealthJournal(
                                          selectedAfficolor: Color(UpdatingColorsBasedOnAffiliations
                                              .affiColorCode.value),
                                          fromHome: "home"),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(top: 1.h, left: 1.w),
                                      child: HealthJournalCard().caloriesCard(context,
                                          selectedAfficolor: Color(UpdatingColorsBasedOnAffiliations
                                              .affiColorCode.value),
                                          fromHome: "home"),
                                    )
                              : Padding(
                                  padding: EdgeInsets.only(top: 1.h, left: 1.w),
                                  child:
                                      HealthJournalCard().caloriesCard(context, fromHome: "home"),
                                );
                        })),
              ),

              //TeleConsultation Card 🚩
              GetBuilder<UpcomingDetailsController>(
                  id: "user_upcoming_detils",
                  builder: (_) {
                    return ValueListenableBuilder(
                        valueListenable: UpdatingColorsBasedOnAffiliations.affiColorCode,
                        builder: (BuildContext context, index, Widget child) {
                          Color col = UpdatingColorsBasedOnAffiliations.affiColorCode.value == 0
                              ? AppColors.primaryAccentColor
                              : Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value);
                          List<Color> listColor =
                              UpdatingColorsBasedOnAffiliations.affiColorCode.value == 0
                                  ? [
                                      AppColors.primaryAccentColor.withOpacity(0.5),
                                      Colors.blue.shade100.withOpacity(0.5),
                                    ]
                                  : [
                                      Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value)
                                          .withOpacity(0.4),
                                      Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value)
                                          .withOpacity(0.12)
                                    ];
                          if (_.upComingDetails.appointmentList != null) {
                            if (_.upComingDetails.appointmentList.isEmpty) {
                              return SizedBox(
                                  width: 100.w,
                                  child: ValueListenableBuilder(
                                      valueListenable:
                                          UpdatingColorsBasedOnAffiliations.affiColorCode,
                                      builder: (BuildContext context, index, Widget child) {
                                        return Visibility(
                                          visible: Tabss.featureSettings.teleconsultation,
                                          child: TeleConsultationWidgets()
                                              .teleConsultationDashboardWidget(
                                                  staticCard: true,
                                                  affiColor: col,
                                                  linerColor: listColor,
                                                  context: context),
                                        );
                                      }));
                            } else {
                              return Container();
                              // CrossBarConnect().consultantStatus(
                              //     _.upComingDetails.appointmentList.first.ihlConsultantId);
                              // return SizedBox(
                              //     width: 100.w,
                              //     child: TeleConsultationWidgets().teleConsultationDashboardWidget(
                              //         context: context,
                              //         appointmentList: _.upComingDetails.appointmentList[0],
                              //         staticCard: false,
                              //         affiColor: col,
                              //         linerColor: listColor));
                            }
                          } else {
                            return Container();
                          }
                        });
                  }),
              SizedBox(
                height: .1.h,
              ),

              DashBoardHealthChallengeWidget().upcomingChallengeWidget(context),
              /*   ValueListenableBuilder(
                  valueListenable: CheckUpcomingDataIsLoaded.showShimmer,
                  builder: (_, show, __) {
                    // CheckUpcomingDataIsLoaded.showShimmer.value = true;
                    // upcomingDetailsController.updateUpcomingDetails();
                    if (CheckUpcomingDataIsLoaded.showShimmer.value) {
                      return Shimmer.fromColors(
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
                              child: const Text('Hello')));
                    } else {
                      return ValueListenableBuilder(
                          valueListenable: UpdatingColorsBasedOnAffiliations.selectedAffiliation,
                          builder: (BuildContext ctx, index, Widget child) {
                            //    upcomingDetailsController.onInit();
                            return Column(
                              children: [
                                Visibility(
                                  visible: Tabss.featureSettings.challenges,
                                  child: GetBuilder<UpcomingDetailsController>(
                                      id: "user_upcoming_detils",
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
                                                padding: EdgeInsets.only(
                                                    top: 1.h, left: 1.w, bottom: 1.5.h),
                                                child: Text(
                                                  AppTexts.newChallenge,
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 12.3.sp,
                                                    color: UpdatingColorsBasedOnAffiliations
                                                                .affiColorCode.value ==
                                                            0
                                                        ? AppColors.primaryAccentColor
                                                        : Color(
                                                            UpdatingColorsBasedOnAffiliations
                                                                .affiColorCode.value,
                                                          ),
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => PercentageCalculations()
                                                            .calculatePercentageFilled() !=
                                                        100
                                                    ? Get.to(ProfileCompletionScreen())
                                                    : Get.to(HealthChallengesComponents(
                                                        // list: ["global", "Global"],
                                                        list: [
                                                            UpdatingColorsBasedOnAffiliations
                                                                .selectedAffiliation.value
                                                          ])),
                                                child: ChallengeCard().noChallenegs(context),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                                GetBuilder<UpcomingDetailsController>(builder: (_) {
                                  if (_.upComingDetails.enrolChallengeList != null) {
                                    return Visibility(
                                      //visible: _.upComingDetails.enrolChallengeList!.isEmpty,
                                      visible: false,
                                      child: Card(
                                        child: Column(children: [
                                          GestureDetector(
                                            child: ChallengeCard().newChallenge(context),
                                            onTap: () => PercentageCalculations()
                                                        .calculatePercentageFilled() !=
                                                    100
                                                ? Get.to(ProfileCompletionScreen())
                                                : Get.to(HealthChallengesComponents(
                                                    // list: ["global", "Global"],
                                                    list: [
                                                        UpdatingColorsBasedOnAffiliations
                                                            .selectedAffiliation.value
                                                      ])),
                                          )
                                        ]),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),
                                GetBuilder<UpcomingDetailsController>(
                                    id: "user_enroll_challenge",
                                    builder: (_) {
                                      if (_.upComingDetails.enrolChallengeList != null) {
                                        if (_.upComingDetails.enrolChallengeList.isNotEmpty) {
                                          return _.loading
                                              ? Shimmer.fromColors(
                                                  direction: ShimmerDirection.ltr,
                                                  period: const Duration(seconds: 2),
                                                  baseColor:
                                                      const Color.fromARGB(255, 240, 240, 240),
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
                                                  padding: EdgeInsets.only(
                                                      right: 1.w, left: 1.5.w, bottom: 1.h),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.fromLTRB(
                                                            14, 14, 14, 10),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              "Ongoing Challenge",
                                                              style: TextStyle(
                                                                fontFamily: 'Poppins',
                                                                fontSize: 12.3.sp,
                                                                color:
                                                                    UpdatingColorsBasedOnAffiliations
                                                                                .affiColorCode
                                                                                .value ==
                                                                            0
                                                                        ? AppColors
                                                                            .primaryAccentColor
                                                                        : Color(
                                                                            UpdatingColorsBasedOnAffiliations
                                                                                .affiColorCode
                                                                                .value,
                                                                          ),
                                                                fontWeight: FontWeight.w800,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            TeleConsultationWidgets().viewAll(
                                                                onTap: () => PercentageCalculations()
                                                                            .calculatePercentageFilled() !=
                                                                        100
                                                                    ? Get.to(
                                                                        ProfileCompletionScreen())
                                                                    : Get.to(
                                                                        EnrolledChallengesListScreen(
                                                                            uid: SpUtil.getString(
                                                                                LSKeys.ihlUserId),
                                                                            global: false,
                                                                            affiname:
                                                                                selectedAffiliationfromuniquenameDashboard)),
                                                                color: affiColor)
                                                          ],
                                                        ),
                                                      ),
                                                      Card(
                                                        child: ChallengeCard().enrolledChallenge(
                                                            context,
                                                            color: affiColor),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                        }
                                      }
                                      return Container();
                                    }),
                              ],
                            );
                          });
                    }
                  }),
             */
              GetBuilder<UpcomingDetailsController>(
                  // init: UpcomingDetailsController(),
                  id: "user_upcoming_detils",
                  builder: (_) {
                    return ValueListenableBuilder(
                        valueListenable: UpdatingColorsBasedOnAffiliations.selectedAffiliation,
                        builder: (BuildContext ctx, index, Widget child) {
                          if (_.upComingDetails.subcriptionList != null) {
                            if (_.upComingDetails.subcriptionList.isEmpty) {
                              return Visibility(
                                visible: Tabss.featureSettings.onlineClasses,
                                child: SubscriptionWidgets().subscriptionCard(
                                    context: context,
                                    staticCard: true,
                                    afficolor: Color(
                                        UpdatingColorsBasedOnAffiliations.affiColorCode.value),
                                    affi: fitnessClassSpecialties),
                              );
                            } else {
                              return Container();
                              // return SubscriptionWidgets().subscriptionCard(
                              //     context: context,
                              //     afficolor:
                              //         Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value),
                              //     staticCard: false,
                              //     subcriptionList: _.upComingDetails.subcriptionList.first,
                              //     affi: fitnessClassSpecialties);
                            }
                          } else {
                            return Container();
                          }
                        });
                  }),

              //Health Program Card 🚩
              SizedBox(
                height: 2.h,
              ),
              // Padding(
              //   padding: EdgeInsets.only(
              //       top: 2.h, right: 1.w, left: 1.w),
              //   child: Container(
              //     height: 100.h > 700 ? 12.h : 10.h,
              //     child: ListView.builder(
              //         scrollDirection: Axis.horizontal,
              //         itemCount: UpdatingColorsBasedOnAffiliations
              //             .selectedAffiliation.value ==
              //             "ihl_care"
              //             ? 8
              //             : 7,
              //         itemBuilder:
              //             (BuildContext context, int index) {
              //           return GestureDetector(
              //             onTap: options[index]['onTap'],
              //             child: Card(
              //               color: AppColors.plainColor,
              //               elevation: 3,
              //               child: Row(
              //                   mainAxisAlignment:
              //                   MainAxisAlignment.start,
              //                   crossAxisAlignment:
              //                   CrossAxisAlignment.start,
              //                   children: [
              //                     Center(
              //                       child: Padding(
              //                           padding:
              //                           EdgeInsets.all(5.0),
              //                           child: Container(
              //                             height:
              //                             MediaQuery.of(context)
              //                                 .size
              //                                 .height *
              //                                 0.6,
              //                             width:
              //                             MediaQuery.of(context)
              //                                 .size
              //                                 .width *
              //                                 0.65,
              //                             child: Row(
              //                               children: [
              //                                 Padding(
              //                                     padding:
              //                                     const EdgeInsets
              //                                         .all(6.0),
              //                                     child: options[index]
              //                                     [
              //                                     'image']
              //                                         .toString()
              //                                         .contains(
              //                                         'svg')
              //                                         ? SvgPicture
              //                                         .asset(
              //                                       options[index]
              //                                       [
              //                                       'image'],
              //                                     )
              //                                         : options[index]['icon'].toString().contains(
              //                                         'Customicons') ||
              //                                         options[index]['icon']
              //                                             .toString()
              //                                             .contains('AppColors')
              //                                         ? Icon(
              //                                       options[index]
              //                                       [
              //                                       'icon'],
              //                                       size:
              //                                       160.0,
              //                                       color:
              //                                       options[index]['colors'],
              //                                     )
              //                                         : Icon(
              //                                       options[index]
              //                                       [
              //                                       'icon'],
              //                                       size:
              //                                       30.0,
              //                                       color:
              //                                       options[index]['colors'],
              //                                     )),
              //                                 SizedBox(
              //                                   width: MediaQuery.of(
              //                                       context)
              //                                       .size
              //                                       .width *
              //                                       0.03,
              //                                 ),
              //                                 Expanded(
              //                                     child: Text(
              //                                       '${options[index]['text']}',
              //                                       maxLines: 1,
              //                                       style: TextStyle(
              //                                           fontSize: 12),
              //                                     ))
              //                               ],
              //                             ),
              //                           )),
              //                     )
              //                   ]),
              //             ),
              //           );
              //           //   VitalCardsIndiduval(
              //           //   vitalType: ProgramLists.vitalDetails[index],
              //           //   icon: AssetImage(
              //           //       'newAssets/Icons/vitalsDetails/${ProgramLists.vitalDetails[index]}.png'),
              //           // );
              //         }),
              //   ),
              // ),

              ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: UpdatingColorsBasedOnAffiliations.affiMap,
                  builder: (BuildContext context, Map<String, dynamic> val, Widget child) {
                    return Visibility(
                      visible: Tabss.featureSettings.healthTips,
                      child: HealthTipCard(
                        color: Color(UpdatingColorsBasedOnAffiliations.affiColorCode.value),
                        affiList: UpdatingColorsBasedOnAffiliations.selectedAffiliation.value,
                      ),
                    );
                  }),
              SizedBox(
                height: 2.h,
              ),
              Visibility(
                  visible: Tabss.featureSettings.heartHealth,
                  child: GestureDetector(
                    onTap: () {
                      if (PercentageCalculations().calculatePercentageFilled() != 100) {
                        Get.to(ProfileCompletionScreen());
                      } else {
                        tabBarController.updateSelectedIconValue(value: AppTexts.healthProgramms);
                        Get.put(VitalsContoller);
                        Get.to(CardioDashboardNew(
                          tabView: false,
                        ));
                      }
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
                            child: ValueListenableBuilder(
                                valueListenable:
                                    UpdatingColorsBasedOnAffiliations.selectedAffiliation,
                                builder: (BuildContext context, index, Widget child) {
                                  return Text(
                                    vital != null
                                        ? 'Suggested Health Program'
                                        : "New Health Program",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.3.sp,
                                      color: Color(
                                          UpdatingColorsBasedOnAffiliations.affiColorCode.value),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  );
                                }),
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
                                    ))
                              ],
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
                          //   height: 25.h,
                          // ),
                        ],
                      ),
                    ),
                  ))
            ])));
  }

  Widget ViewFourPillar(BuildContext context) {
    final TabBarController tabController = Get.find<TabBarController>();
    return CommonScreenForNavigation(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text("Our Services", style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              Get.put(UpcomingDetailsController()).onInit();
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        content: WillPopScope(
          onWillPop: () {
            print('Hello');
            Get.put(UpcomingDetailsController()).onInit();
            return Future.value(true);
          },
          child: Padding(
            padding: EdgeInsets.only(right: 1.w, left: 1.w, top: 1.h),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 2 / 1.4
                  // crossAxisSpacing: 4.0,
                  // mainAxisSpacing: 4.0
                  ),
              itemBuilder: (BuildContext context, int index) {
                if (selectedAffiliationfromuniquenameDashboard == "dev_testing" &&
                    index == options.length - 1) {
                  return Container();
                }
                // if (selectedAffiliationfromuniquenameDashboard == "dev_testing" &&
                //     index == options.length - 2) {
                //   return Container();
                // }
                // if (selectedAffiliationfromuniquenameDashboard == "ihl_care" &&
                //     index == options.length - 1) {
                //   return Container();
                // }
                return GestureDetector(
                  // onTap: options[index]['onTap'],
                  onTap: options[index]['text'] == "Health Challenges"
                      ? () {
                          Get.to(HealthChallengesComponents(
                            list: const ["global", "Global"],
                          ));
                        }
                      : options[index]['text'] == "Subscription"
                          ? () {
                              tabController.updateSelectedIconValue(value: AppTexts.onlineServices);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext ctx) => MultiBlocProvider(
                                            providers: [
                                              BlocProvider(
                                                  create: (BuildContext context) => TrainerBloc()),
                                            ],
                                            child: ViweAllClass(
                                                subcriptionList: const [], isHome: "Yes"),
                                          )));
                            }
                          : () {
                              tabController.updateSelectedIconValue(value: AppTexts.onlineServices);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                    create: (BuildContext context) =>
                                                        ClassandconsultantblocBloc()),
                                              ],
                                              child: ClassAndConsultantListPage(
                                                category: options[index]['text'],
                                              ))));
                            },
                  child: Card(
                    color: AppColors.plainColor,
                    elevation: 3,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 2.h),
                          Center(
                            child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(
                                    height: 8.h,
                                    width: 60.w,
                                    child: options[index]['image'].toString().contains('svg')
                                        ? SvgPicture.asset(
                                            'assets/svgs/mobile-icon.svg',
                                            color: Colors.red,
                                            fit: BoxFit.contain,
                                            height: 20,
                                          )
                                        : options[index]['image'].toString().contains('png')
                                            ? Image(image: AssetImage(options[index]['image']))
                                            : options[index]['icon']
                                                        .toString()
                                                        .contains('Customicons') ||
                                                    options[index]['icon']
                                                        .toString()
                                                        .contains('AppColors')
                                                ? Icon(
                                                    options[index]['icon'],
                                                    size: 160.0,
                                                    color: options[index]['colors'],
                                                  )
                                                : Icon(
                                                    options[index]['icon'],
                                                    size: 30.0,
                                                    color: options[index]['colors'],
                                                  )
                                    // Row(
                                    //   children: [
                                    //     Padding(
                                    //         padding:
                                    //         const EdgeInsets
                                    //             .all(6.0),
                                    //         child: options[index]
                                    //         [
                                    //         'image']
                                    //             .toString()
                                    //             .contains(
                                    //             'svg')
                                    //             ? SvgPicture
                                    //             .asset(
                                    //           options[index]
                                    //           [
                                    //           'image'],
                                    //         )
                                    //             : options[index]['icon'].toString().contains(
                                    //             'Customicons') ||
                                    //             options[index]['icon']
                                    //                 .toString()
                                    //                 .contains('AppColors')
                                    //             ? Icon(
                                    //           options[index]
                                    //           [
                                    //           'icon'],
                                    //           size:
                                    //           160.0,
                                    //           color:
                                    //           options[index]['colors'],
                                    //         )
                                    //             : Icon(
                                    //           options[index]
                                    //           [
                                    //           'icon'],
                                    //           size:
                                    //           30.0,
                                    //           color:
                                    //           options[index]['colors'],
                                    //         )),
                                    //     SizedBox(
                                    //       width: MediaQuery.of(
                                    //           context)
                                    //           .size
                                    //           .width *
                                    //           0.03,
                                    //     ),
                                    //     Expanded(
                                    //         child: Text(
                                    //           '${options[index]['text']}',
                                    //           maxLines: 1,
                                    //           style: TextStyle(
                                    //               fontSize: 12),
                                    //         ))
                                    //   ],
                                    // ),
                                    )),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03,
                          ),
                          Expanded(
                              child: Text(
                            '${options[index]['text']}',
                            maxLines: 1,
                            style: const TextStyle(fontSize: 12),
                          ))
                        ]),
                  ),
                );
              },
            ),
          ),
        ));
  }

  _showAlertDialog(
      BuildContext context, bool affCheck, String selectedAffi, String value, AfNo selectAffi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return an AlertDialog
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Spacer(),
              InkWell(
                  onTap: () {
                    affiEntered.value = 0;
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.close)),
            ],
          ),
          content: Text(
            'To access $selectedAffi corporate Login,you will be logout momentarily.Please log in using using your $selectedAffi corporate Login credentials',
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Colors.black,
              fontSize: 11.sp,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            // Close button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  fixedSize: Size.fromWidth(MediaQuery.of(context).size.width / 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                onPressed: () async {
                  HealthTipsApi.ihlUniqueName = value;
                  AffiliationWidgets.affiBoardChanges(
                      affi: selectAffi, userAffiliateDatas: userAffiliateDatas);
                  UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] =
                      value;
                  UpdatingColorsBasedOnAffiliations.affiMap.value = <String, dynamic>{
                    "affiliation_unique_name": value
                  };
                  affiEntered.value = 1;
                  String uniqueName =
                      UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"];

                  if (!affCheck) {
                    print('logout');
                    firstAffi = affCheck;
                    clear(0, userAffiliateDatas, currentAffi, uniqueName);
                  } else {
                    firstAffi = affCheck;
                    clear(1, userAffiliateDatas, currentAffi, uniqueName);
                    print('organisation');
                  }
                },
                child: const Text('Okay'),
              ),
            ),
            SizedBox(
              height: 1.h,
            )
          ],
        );
      },
    );
  }
}

Future clear(int index, List<AfNo> userAffiliateDatas, AfNo currentAffi, String uniqueName) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  //Removing the last selected affiliation data while signout🥚
  UpdatingColorsBasedOnAffiliations.ssoAffiliation = null;
  prefs.remove("sso_flow_affiliation");
  log("SSO account tap details removed");
  try {
    await localSotrage.write(LSKeys.ihlUserId, '');
    localSotrage.save();
    print(localSotrage.read(LSKeys.ihlUserId));
    Get.find<UpcomingDetailsController>().onClose();
    await localSotrage.erase();
    SpUtil.clear();

    try {
      await prefs.clear().then((bool value) {
        log('SharedPrefe Keys ${prefs.getKeys()}');

        log('Erase $value');
        localSotrage.write(LSKeys.logged, false);
        localSotrage.save();
      });
    } catch (e) {
      print(e);
    }

    Directory cacheDir;
    // = await getTemporaryDirectory();
    try {
      if (Platform.isAndroid) {
        cacheDir = await getTemporaryDirectory();
        if (cacheDir.existsSync()) {
          cacheDir.deleteSync(recursive: true);
        }
      } else {
        cacheDir = await getTemporaryDirectory();
        cacheDir.delete(recursive: true);
      }
    } catch (e) {
      print(e);
    }
    Directory appDir;
    // = await getApplicationSupportDirectory();
    try {
      if (Platform.isAndroid) {
        appDir = await getApplicationSupportDirectory();
        if (appDir.existsSync()) {
          appDir.deleteSync(recursive: true);
        }
      } else {
        appDir = await getApplicationSupportDirectory();
        appDir.delete(recursive: true);
      }
    } catch (e) {
      print(e);
    }
    Directory docDir;
    if (Platform.isAndroid) {
      docDir = await getApplicationDocumentsDirectory();
      try {
        if (docDir.existsSync()) {
          docDir.deleteSync(recursive: true);
        }
      } catch (e) {
        print(e);
      }
    }

    List<Directory> externalDir;
    if (Platform.isAndroid) {
      externalDir = await getExternalStorageDirectories();
      try {
        if (externalDir.isNotEmpty) {
          externalDir.clear();
        }
      } catch (e) {
        print(e);
      }
    }
    // final downDir = await getDownloadsDirectory();

    // if (downDir.existsSync()) {
    //   downDir.deleteSync(recursive: true);
    // }

    List<Directory> exeCac;

    try {
      if (Platform.isAndroid) {
        exeCac = await getExternalCacheDirectories();
        if (exeCac.isNotEmpty) {
          exeCac.clear();
        }
        print(exeCac.isEmpty);

        print(exeCac.toString());
        print(exeCac.toString());
      }
    } catch (e) {
      print(e);
    }
    Directory extSto;

    try {
      if (Platform.isAndroid) {
        extSto = await getExternalStorageDirectory();
        if (extSto.existsSync()) {
          extSto.deleteSync(recursive: true);
        }

        print(extSto.toString());
        extSto.delete();
      }
    } catch (e) {
      print(e);
    }
    // final libd = await getLibraryDirectory();

    // try {
    //   if (libd.existsSync()) {
    //     libd.deleteSync(recursive: true);
    //   }
    // } catch (e) {
    //   print(e);
    // }

    print('${prefs.isBlank}--------->');
    // print(localSotrage.getValues().toString() + '------>local storage');
    // print(cacheDir.isBlank.toString() + '------>cache storage');
    // print(appDir.isBlank.toString() + '------>appdir storage');
    // print(docDir.isBlank.toString() + '------>doc storage');
    //   print(externalDir.isBlank.toString() + '------>external storage');
    //    print(exeCac.isBlank.toString() + '------>external cache storage');
    //  print(extSto.isBlank.toString() + '------>ext storage storage');
    // print(libd.isBlank.toString() + '------>lib storage');
    // print(downDir.isBlank.toString() + '------>down storage');
  } catch (e) {
    print(e);
  }
  Tabss.firstTime = true;
  // currentAffi = userAffiliateDatas.where((AfNo element) {
  //   return element.affilateUniqueName == uniqueName;
  // }).first;
  Get.offAll(LoginEmailScreen(
    index: index,
  ));
}

class ViewFourPillar extends StatelessWidget {
  ViewFourPillar({Key key}) : super(key: key);
  final TabBarController _tabController = Get.find<TabBarController>();
  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text("Our Services", style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              Get.put(UpcomingDetailsController()).onInit();
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        content: WillPopScope(
          onWillPop: () {
            Get.put(UpcomingDetailsController()).onInit();
            return Future.value(true);
          },
          child: Padding(
            padding: EdgeInsets.only(right: 1.w, left: 1.w),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 2 / 1.4
                  // crossAxisSpacing: 4.0,
                  // mainAxisSpacing: 4.0
                  ),
              itemBuilder: (BuildContext context, int index) {
                if (selectedAffiliationfromuniquenameDashboard == "dev_testing" &&
                    index == options.length - 1) {
                  return Container();
                }
                return GestureDetector(
                  onTap: options[index]['text'] == "Health Challenges"
                      ? () {
                          // Get.to(NewChallengeCategory());
                          Get.to(HealthChallengesComponents(
                            list: const ["global", "Global"],
                          ));
                        }
                      : options[index]['text'] == "Subscription"
                          ? () {
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
                                                subcriptionList: const [], isHome: "Yes"),
                                          )));
                            }
                          : () {
                              _tabController.updateSelectedIconValue(
                                  value: AppTexts.onlineServices);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                    create: (BuildContext context) =>
                                                        ClassandconsultantblocBloc()),
                                              ],
                                              child: ClassAndConsultantListPage(
                                                category: options[index]['text'],
                                              ))));
                            },
                  // onTap: options[index]['onTap'],
                  child: Card(
                    color: AppColors.plainColor,
                    elevation: 3,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 2.h),
                          Center(
                            child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SizedBox(
                                    height: 8.h,
                                    width: 60.w,
                                    child: options[index]['image'].toString().contains('png')
                                        ? Image(image: AssetImage(options[index]['image']))
                                        : options[index]['icon']
                                                    .toString()
                                                    .contains('Customicons') ||
                                                options[index]['icon']
                                                    .toString()
                                                    .contains('AppColors')
                                            ? Icon(
                                                options[index]['icon'],
                                                size: 160.0,
                                                color: options[index]['colors'],
                                              )
                                            : Icon(
                                                options[index]['icon'],
                                                size: 30.0,
                                                color: options[index]['colors'],
                                              )
                                    // Row(
                                    //   children: [
                                    //     Padding(
                                    //         padding:
                                    //         const EdgeInsets
                                    //             .all(6.0),
                                    //         child: options[index]
                                    //         [
                                    //         'image']
                                    //             .toString()
                                    //             .contains(
                                    //             'svg')
                                    //             ? SvgPicture
                                    //             .asset(
                                    //           options[index]
                                    //           [
                                    //           'image'],
                                    //         )
                                    //             : options[index]['icon'].toString().contains(
                                    //             'Customicons') ||
                                    //             options[index]['icon']
                                    //                 .toString()
                                    //                 .contains('AppColors')
                                    //             ? Icon(
                                    //           options[index]
                                    //           [
                                    //           'icon'],
                                    //           size:
                                    //           160.0,
                                    //           color:
                                    //           options[index]['colors'],
                                    //         )
                                    //             : Icon(
                                    //           options[index]
                                    //           [
                                    //           'icon'],
                                    //           size:
                                    //           30.0,
                                    //           color:
                                    //           options[index]['colors'],
                                    //         )),
                                    //     SizedBox(
                                    //       width: MediaQuery.of(
                                    //           context)
                                    //           .size
                                    //           .width *
                                    //           0.03,
                                    //     ),
                                    //     Expanded(
                                    //         child: Text(
                                    //           '${options[index]['text']}',
                                    //           maxLines: 1,
                                    //           style: TextStyle(
                                    //               fontSize: 12),
                                    //         ))
                                    //   ],
                                    // ),
                                    )),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03,
                          ),
                          Expanded(
                              child: Text(
                            '${options[index]['text']}',
                            maxLines: 1,
                            style: const TextStyle(fontSize: 12),
                          ))
                        ]),
                  ),
                );
              },
            ),
          ),
        ));
  }
}
