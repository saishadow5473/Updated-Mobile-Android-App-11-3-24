import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/new_design/data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Getx/controller/listOfChallengeContoller.dart';
import '../../../constants/api.dart';
import '../../../constants/spKeys.dart';
import '../../../helper/checkForUpdate.dart';
import '../../../utils/CrossbarUtil.dart';
import '../../data/model/affiliation_details_model.dart';
import '../../data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../data/providers/network/apis/selectedProgramApi.dart';
import '../controllers/teleconsultation_onlineServices/common_token_genrator.dart';
import '../controllers/vitalDetailsController/myVitalsController.dart';
import '../pages/customizeProgram/CustomizeBLoC.dart';
import '../pages/customizeProgram/customizeProgramEvnet.dart';
import '../pages/customizeProgram/customizeProgramState.dart';
import '../pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../pages/home/landingPage.dart';
import '../pages/profile/profile_screen.dart';
import '../pages/profile/updatePhoto.dart';
import 'package:shimmer/shimmer.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../utils/SpUtil.dart';
import '../../app/utils/appColors.dart';
import '../../app/utils/appText.dart';
import '../../app/utils/localStorageKeys.dart';
import '../../app/utils/textStyle.dart';
import '../../data/providers/network/apis/dashboardApi/retriveUpcommingDetails.dart';
import '../../data/providers/network/apis/healthTipsApi/healthTipsApi.dart';
import '../controllers/dashboardControllers/dashBoardContollers.dart';
import '../pages/home/home_view.dart';
import 'dashboardWidgets/affiliation_widgets.dart';
import 'dashboardWidgets/healthtip_widget.dart';

class CustomeAppBar extends StatefulWidget {
  const CustomeAppBar({Key key, this.screen, this.personalenabled = false}) : super(key: key);

  final List<String> screen;
  final bool personalenabled;

  @override
  State<CustomeAppBar> createState() => _CustomeAppBarState();
}

class _CustomeAppBarState extends State<CustomeAppBar> with SingleTickerProviderStateMixin {
  bool personal = true;
  var response;

  // List<bool> isSelected;
  // bool aff = localSotrage.read(LSKeys.affiliation);
  final TabBarController _tabController = Get.put(TabBarController());

  // TabController tabController;
  @override
  void initState() {
    checkVersion();
    asyncFunction();
    Tabss.tabController.addListener(() {
      Tabss.selectedIndex.value = Tabss.tabController.index;
      print(Tabss.selectedIndex.value);
      if (Tabss.selectedIndex.value == 0) {
        start = 0;
        end = 2;
        HealthTipsApi.ihlUniqueName = "global_services";
        ChangeHealthTips.healthtipslist.value.clear();
        ChangeHealthTips.getTips();
      }
      Tabss.selectedIndex.notifyListeners();
    });
    super.initState();
  }

  asyncFunction() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var data1 = prefs.get('data');
    // Map res = jsonDecode(data1);
    // var userSsoID = res['User']['id'];
    // ihlId = prefs.getString("ihlUserId");
    //
    // Tabss.featureSettings.personalEnabled = userSsoID == ihlId;
    await Tabss.ssoFlow();
  }

  @override
  void dispose() {
    Tabss.tabController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final _tabController = Get.put(TabBarController());
    final TabBarController tabController = Get.find();
    Uint8List photoDecoded;
    if (SpUtil.getString(LSKeys.imageMemory) != null) {
      photoDecoded = base64Decode(SpUtil.getString(LSKeys.imageMemory));
    } else {
      photoDecoded = base64Decode(AvatarImage.defaultUrl);
    }
    //String userName = localSotrage.read(LSKeys.userName);
    String userName = SpUtil.getString(LSKeys.userName);
    // return
    // if ((!SpUtil.getBool(LSKeys.affiliation)) ?? false) {
    bool s = true;
    if (s) {
      //&& !Tabss.personalEnabled
      return Padding(
        padding: EdgeInsets.only(top: 1.5.h),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                //Get.toNamed(Routes.Profile);
                tabController.updateSelectedIconValue(value: "Profile");
                Get.to(const Profile());
                //Unslash the clear() function for log out for temp purpose only ⚪⚪
                //clear();
              },
              // child: Padding(
              //   padding: EdgeInsets.only(left: 5.w, top: 2.h),
              //   child: b64Image != " "
              //       ? Image.memory(imagB64, height: 8.h, width: 8.w)
              //       : Icon(Icons.person),
              // ),
              child: Padding(
                padding: EdgeInsets.only(left: 5.w, top: 3.8.h),
                child: ValueListenableBuilder(
                    valueListenable: PhotoChangeNotifier.photo,
                    builder: (BuildContext context, String val, Widget child) {
                      return Container(
                        height: 8.h,
                        width: 8.w,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: MemoryImage((PhotoChangeNotifier.photo.value == null)
                                    ? photoDecoded
                                    : base64Decode(PhotoChangeNotifier.photo.value))),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryColor)),
                      );
                    }),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(top: 3.8.h, left: 3.w),
              child: Text("${AppTexts.hiText}, ${userName.capitalize}",
                  textAlign: TextAlign.right, style: AppTextStyles.primaryColorText),
            ),
            const Spacer(
              flex: 2,
            ),
          ],
        ),
      );
    }
    return DefaultTabController(
      length: 2,
      child: ValueListenableBuilder<int>(
          valueListenable: Tabss.selectedIndex,
          builder: (BuildContext context, int value, Widget child) {
            return Padding(
              padding: EdgeInsets.only(top: 1.5.h),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        tabController.updateSelectedIconValue(value: "Profile");
                        Get.to(const Profile());
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w, top: 3.8.h),
                        child: ValueListenableBuilder<String>(
                            valueListenable: PhotoChangeNotifier.photo,
                            builder: (BuildContext context, String val, Widget child) {
                              return Container(
                                height: 8.h,
                                width: 8.w,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: MemoryImage((PhotoChangeNotifier.photo.value == null)
                                            ? photoDecoded
                                            : base64Decode(PhotoChangeNotifier.photo.value))),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primaryColor)),
                              );
                            }),
                      )),
                  const Spacer(),
                  ValueListenableBuilder<bool>(
                      valueListenable: CheckAllDataLoaded.data,
                      builder: (__, bool val, _) {
                        return val == false
                            ? Padding(
                                padding: EdgeInsets.only(top: 3.8.h, left: 3.w),
                                child: Shimmer.fromColors(
                                  direction: ShimmerDirection.ltr,
                                  period: const Duration(milliseconds: 600),
                                  baseColor: const Color.fromARGB(255, 240, 240, 240),
                                  highlightColor: Colors.grey.withOpacity(0.5),
                                  child: Container(
                                    width: 54.w,
                                    decoration: BoxDecoration(
                                        color: const Color(0XFFD2D0D0).withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(100)),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 27.w,
                                      height: 20.sp,
                                      decoration:
                                          BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 3.8.h, left: 3.w),
                                  child: SpUtil.getBool(LSKeys.affiliation) ?? false
                                      ? Container(
                                          width: 54.w,
                                          decoration: BoxDecoration(
                                              color: const Color(0XFFD2D0D0).withOpacity(0.4),
                                              borderRadius: BorderRadius.circular(20)),
                                          child: TabBar(
                                            indicator: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50), // Creates border
                                                color: AppColors.primaryColor),
                                            indicatorPadding:
                                                const EdgeInsets.symmetric(horizontal: 0),
                                            indicatorWeight: 0.1,
                                            controller: Tabss.tabController,
                                            tabs: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  eMarketaff = true;
                                                  selectedAffiliationfromuniquenameDashboard = '';
                                                  selectedAffiliationcompanyNamefromDashboard = '';
                                                  if (Get.currentRoute == "/LandingPage") {
                                                    Tabss.featureSettings = FeatureSettings(
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
                                                    Tabss.tabController.animateTo(0);
                                                    Tabss.isAffi = true;
                                                  } else {
                                                    Get.to(LandingPage());
                                                  }
                                                  ListChallengeController listChallengeController =
                                                      Get.put(ListChallengeController());
                                                  RetriveDetials().upcomingDetails(
                                                      affilist: listChallengeController
                                                          .affiliateCmpnyList,
                                                      fromChallenge: false);
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: 27.w,
                                                  height: 20.sp,
                                                  decoration: const BoxDecoration(
                                                      // color: _tabController.tabSelected.value == 0
                                                      //     ? AppColors.primaryAccentColor
                                                      //     : AppColors.unSelectedColor,
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(20),
                                                          topRight: Radius.circular(20),
                                                          bottomLeft: Radius.circular(20),
                                                          bottomRight: Radius.circular(20))),
                                                  child: Text(
                                                    AppTexts.personal,
                                                    style: Tabss.tabController.index == 0
                                                        ? AppTextStyles.selectedText
                                                        : AppTextStyles.unSelectedText,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  if (Get.currentRoute == "/LandingPage") {
                                                    Tabss.tabController.animateTo(1);
                                                    Tabss.isAffi = false;
                                                  } else {
                                                    Get.to(LandingPage());
                                                  }
                                                  // _tabController.updateTab(value: 1);
                                                  // Get.to(AffiliationDashboard());
                                                  // UpcomingDetailsController().updatingColors("ihl_care");
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: 27.w,
                                                  height: 20.sp,
                                                  decoration: const BoxDecoration(
                                                      // color: _tabController.tabSelected.value == 1
                                                      //     ? AppColors.primaryAccentColor
                                                      //     : AppColors.unSelectedColor,
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(20),
                                                          topRight: Radius.circular(20),
                                                          bottomLeft: Radius.circular(20),
                                                          bottomRight: Radius.circular(20))),
                                                  child: Text(
                                                    AppTexts.affiliattion,
                                                    style: Tabss.tabController.index == 1
                                                        ? AppTextStyles.selectedText
                                                        : AppTextStyles.unSelectedText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Text("${AppTexts.hiText}, ${userName.capitalize}",
                                          textAlign: TextAlign.right,
                                          style: AppTextStyles.primaryColorText),
                                ),
                              );
                      }),
                  const Spacer(
                    flex: 2,
                  ),
                  // IconButton(onPressed: () => checkVersion(), icon: const Icon(Icons.check))
                ],
              ),
            );
          }),
    );
  }

// void clear() async {
//   final prefs = await SharedPreferences.getInstance();
//   var x = await SpUtil.remove('qAns');
//   var y = await SpUtil.clear();
//   _deleteCacheDir();
//   _deleteAppDir();
//   // if (x == true && y == true) {
//   await localSotrage.erase();
//   await prefs.clear().then((value) {
//     Get.offAll(WelcomePage());
//     // Navigator.of(context).pushNamedAndRemoveUntil(
//     //     newRoute.Welcome, (Route<dynamic> route) => false,
//     //     arguments: false);
//   });
//   // }
// }

// Future<void> _deleteCacheDir() async {
//   final cacheDir = await getTemporaryDirectory();

//   if (cacheDir.existsSync()) {
//     cacheDir.deleteSync(recursive: true);
//   }
// }

// Future<void> _deleteAppDir() async {
//   final appDir = await getApplicationSupportDirectory();

//   if (appDir.existsSync()) {
//     appDir.deleteSync(recursive: true);
//   }
// }
  void checkVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object alreadyNotChecked = prefs.get(SPKeys.needToCheckAppVersion);
    if (alreadyNotChecked == 'yes') {
      final AppVersionChecker snapChatChecker =
          AppVersionChecker(appId: "com.indiahealthlink.ihlhealth");
      AppCheckerResult snapValue;
      await Future.wait(<Future<AppCheckerResult>>[
        snapChatChecker.checkUpdate().then((AppCheckerResult value) => snapValue = value),
      ]);
      //print(snapValue.toString());
      if (snapValue.canUpdate) {
        // double _hSmallDevice = MediaQuery.of(context).size.height;
        // double _wSmallDevice = MediaQuery.of(context).size.width;
        Future.delayed(Duration.zero, () {
          showGeneralDialog(
              barrierColor: Colors.black.withOpacity(0.5),
              transitionBuilder:
                  (BuildContext ctx, Animation<double> a1, Animation<double> a2, Widget widget) {
                final double curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
                return Transform(
                  transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
                  child: Opacity(
                    opacity: a1.value,
                    child: Center(
                      child: Platform.isIOS
                          ? Dialog(
                              backgroundColor: Colors.transparent, //must have
                              elevation: 0,
                              child: SizedBox(
                                height: 35.h,
                                width: 100.w,
                                child: Stack(
                                  children: <Widget>[
                                    Positioned(
                                        top: 4.h,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                            color: Colors.white,
                                          ),
                                          height: 29.h,
                                          width: 75.w,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              Text("Update App?",
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      color: Colors.black87,
                                                      letterSpacing: 0.7,
                                                      fontWeight: FontWeight.w800)),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Text(
                                                "A new version ${snapValue.newVersion} of hCare is available!\n Currently installed version ${snapValue.currentVersion} ",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.grey,
                                                    letterSpacing: 0.7,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              Text("Would you like to update it now?",
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.grey,
                                                      letterSpacing: 0.7,
                                                      fontWeight: FontWeight.w600)),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text(
                                                          "Not now",
                                                          style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color: AppColors.primaryAccentColor
                                                                  .withOpacity(0.5),
                                                              letterSpacing: 0.7,
                                                              fontWeight: FontWeight.w600),
                                                        )),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        Uri url = Uri.parse(snapValue.appURL);
                                                        await launchUrl(
                                                          url,
                                                          mode: LaunchMode.externalApplication,
                                                        );
                                                      },
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty.all<Color>(
                                                                  AppColors.primaryAccentColor)),
                                                      child: Text(
                                                        "Update Now",
                                                        style: TextStyle(
                                                            fontSize: 14.sp,
                                                            color: Colors.white,
                                                            letterSpacing: 0.7,
                                                            fontWeight: FontWeight.w600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        radius: 25.sp,
                                        child: ClipRect(
                                          child: Image.asset("assets/images/app-store.png"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          : Dialog(
                              backgroundColor: Colors.transparent, //must have
                              elevation: 0,
                              child: SizedBox(
                                height: 35.h,
                                width: 100.w,
                                child: Stack(
                                  children: <Widget>[
                                    Positioned(
                                        top: 4.h,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(20)),
                                            color: Colors.white,
                                          ),
                                          height: 27.h,
                                          width: 75.w,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 4.h),
                                              Text("Update App?",
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      color: Colors.black87,
                                                      letterSpacing: 0.7,
                                                      fontWeight: FontWeight.w800)),
                                              SizedBox(height: 2.h),
                                              Text(
                                                "A new version ${snapValue.newVersion} of hCare is available!\n Currently installed version ${snapValue.currentVersion} ",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.grey,
                                                    letterSpacing: 0.7,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              Text("Would you like to update it now?",
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.grey,
                                                      letterSpacing: 0.7,
                                                      fontWeight: FontWeight.w600)),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: <Widget>[
                                                    TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: Text(
                                                          "Not now",
                                                          style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color: AppColors.primaryAccentColor
                                                                  .withOpacity(0.5),
                                                              letterSpacing: 0.7,
                                                              fontWeight: FontWeight.w600),
                                                        )),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        Uri url = Uri.parse(snapValue.appURL);
                                                        await launchUrl(
                                                          url,
                                                          mode: LaunchMode.externalApplication,
                                                        );
                                                      },
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty.all<Color>(
                                                                  AppColors.primaryAccentColor)),
                                                      child: Text(
                                                        "Update Now",
                                                        style: TextStyle(
                                                            fontSize: 14.sp,
                                                            color: Colors.white,
                                                            letterSpacing: 0.7,
                                                            fontWeight: FontWeight.w600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        radius: 25.sp,
                                        child: ClipRect(
                                          child: Image.asset(
                                            "assets/images/googlePlayStore.png",
                                            //height: 20.h,
                                            // width: 60.w,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                    ),
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 200),
              barrierDismissible: true,
              barrierLabel: '',
              context: context,
              pageBuilder: (BuildContext context, Animation<double> animation1,
                  Animation<double> animation2) {
                return Container();
              });
        });
      }
      prefs.setString(SPKeys.needToCheckAppVersion, "no");
    }
  }
}

class Tabss {
  static bool personalEnabled = false;
  static bool isAffi = false;
  static FeatureSettings featureSettings = FeatureSettings(
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
  static TabController tabController;
  static bool firstTime = true;
  static ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  static ssoFlow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await CommonTokens.getApiToken();
    var data1 = prefs.get('data');
    Map res = jsonDecode(data1);
    var userSsoID = res['User']['id'];
    String ihlId = prefs.getString("personalDashboardUID") ?? "";
    Tabss.personalEnabled = userSsoID == ihlId;

    String ss = prefs.getString("sso_flow_affiliation");
    if (ss != null) {
      Map<String, dynamic> exsitingAffi = jsonDecode(ss);
      UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
        "affiliation_unique_name": exsitingAffi["affiliation_unique_name"]
      };
    }
    UpdatingColorsBasedOnAffiliations.sso =
        UpdatingColorsBasedOnAffiliations.ssoAffiliation != null &&
            UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] != null;
    if (UpdatingColorsBasedOnAffiliations.ssoAffiliation != null) {
      prefs.setString(
          "sso_flow_affiliation", jsonEncode(UpdatingColorsBasedOnAffiliations.ssoAffiliation));
    }
    UpdatingColorsBasedOnAffiliations.affiMap.addListener(() async {
      UpdatingColorsBasedOnAffiliations.affiMap.value =
          UpdatingColorsBasedOnAffiliations.ssoAffiliation;
      if (UpdatingColorsBasedOnAffiliations.ssoAffiliation != null &&
          UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] != null) {
        debugPrint("affiliation changed");
        UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] =
            UpdatingColorsBasedOnAffiliations.affiMap.value["affiliation_unique_name"];
        prefs.setString(
            "sso_flow_affiliation", jsonEncode(UpdatingColorsBasedOnAffiliations.affiMap.value));
      }
    });
  }
}
