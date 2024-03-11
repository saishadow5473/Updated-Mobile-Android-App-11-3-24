import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/landingPage.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../askIHL/askIHL.dart';
import '../healthTips/healthTips.dart';
import '../hpodLocations/hpodLocations.dart';
import '../newsLetter/newsLetter.dart';
import 'challenge.dart';
import '../../../../health_challenge/controllers/challenge_api.dart';
import '../../../../health_challenge/models/challenge_detail.dart';
import '../../../../health_challenge/models/enrolled_challenge.dart';
import '../../../app/utils/textStyle.dart';
import '../dashboard/common_screen_for_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../../Getx/controller/BannerChallengeController.dart';
import '../../../../Getx/controller/listOfChallengeContoller.dart';
import '../../../../health_challenge/models/group_details_model.dart';
import '../../../app/utils/appColors.dart';
import '../../../app/utils/constLists.dart';
import '../../../data/model/SocialdashboardModels/affiliationFlagModel.dart';
import '../../Widgets/appBar.dart';
import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../controllers/dashboardControllers/upComingDetailsController.dart';

class Social extends StatefulWidget {
  const Social({Key key}) : super(key: key);

  @override
  State<Social> createState() => _SocialState();
}

class _SocialState extends State<Social> {
  List<AffiliationFlagModel> affiliationFlagModel = [];
  final ListChallengeController _listofChallengeController = Get.put(ListChallengeController());

  // bool challengeProgress = false;

  @override
  void initState() {
    super.initState();
    // challengeListOnly();

    // Future.delayed(const Duration(seconds: 1), () {
    //   setState(() {
    //     challengeProgress = true;
    //   });
    // });
    _upcomingDetailsController = Get.put(UpcomingDetailsController());
  }

  // final PageController scrollPage =
  //     PageController(initialPage: 0, keepPage: true, viewportFraction: .95);

  // List<ChallengeDetailWithBadges> completedChallengesWithBadges = [];
  UpcomingDetailsController _upcomingDetailsController;
  // bool completedExistence = false;
  // String uniqueNme;
  int selectedIndex;
  final TabBarController tabController = Get.find();

  // void challengeListOnly() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   uniqueNme =
  //       UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] ?? "global";
  //   String userid = prefs.getString("ihlUserId");
  //   List<EnrolledChallenge> userEnrolledChallenge =
  //       await ChallengeApi().listofUserEnrolledChallenges(userId: userid);
  //   for (EnrolledChallenge e in userEnrolledChallenge) {
  //     if (e.userProgress == 'completed') {
  //       completedExistence = true;
  //       ChallengeDetail challengeDetail =
  //           await ChallengeApi().challengeDetail(challengeId: e.challengeId);
  //       GroupDetailModel groupDetailModel;
  //       if (e.challengeMode != "individual") {
  //         groupDetailModel = await ChallengeApi().challengeGroupDetail(groupID: e.groupId);
  //       }
  //       // completedChallengesWithBadges.add((ChallengeDetailWithBadges(
  //       //     challengeName: challengeDetail.challengeName,
  //       //     image: challengeDetail.challengeImgUrlThumbnail,
  //       //     challengeDesc: challengeDetail.challengeDescription,
  //       //     challengeDetail: challengeDetail,
  //       //     challengeId: e.challengeId,
  //       //     enrollmentId: e.enrollmentId,
  //       //     challengeMode: e.challengeMode,
  //       //     groupDetailModel: groupDetailModel)));
  //     }
  //   }
  //   // completedChallengesWithBadges.retainWhere((ChallengeDetailWithBadges element) =>
  //   //     element.challengeDetail.affiliations.contains(uniqueNme));
  //   setState(() {});
  // }

  List<Widget> pages = [
    const ChallengeScreenSocial(),
    HealthTips(),
    const NewsLetter(),
    const AskIHL(),
    HpodLocations()
  ];

  @override
  Widget build(BuildContext context) {
    bool aff = false;
    // final _tabController = Get.put(TabBarController());
    return WillPopScope(
        onWillPop: () async {
          await Get.to(LandingPage());
          return false;
        },
        child: CommonScreenForNavigation(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarOpacity: 0,
            toolbarHeight: 7.5.h,
            flexibleSpace: const CustomeAppBar(screen: ProgramLists.commonList),
            backgroundColor: Colors.white,
            elevation: aff ? 0 : 2,
            shadowColor: AppColors.unSelectedColor,
          ),
          content: SizedBox(
            height: 100.h,
            child: ListView(
              children: [
                PhysicalModel(
                  color: AppColors.plainColor,
                  elevation: 2,
                  child: Container(
                    height: 30.w,
                    color: AppColors.plainColor,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: EdgeInsets.only(top: 1.h, left: 4.w),
                        child: Text('Social', style: AppTextStyles.selectedHeadline),
                      ),
                      Flexible(
                          child: ListView.builder(
                              padding: EdgeInsets.only(
                                top: 1.h,
                              ),
                              scrollDirection: Axis.horizontal,
                              // itemCount: Platform.isIOS ? screen.length - 1 : screen.length,
                              itemCount: ProgramLists.commonList.length,
                              itemBuilder: (BuildContext context, int index) {
                                String tempScreen = ProgramLists.commonList[index];
                                return Container(
                                  decoration:
                                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                                  width: 20.w,
                                  child: Column(
                                    children: <Widget>[
                                      InkWell(
                                        child: Obx(
                                          () => tabController.programsTab.value == index
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: const Color(0xff61C6E7),
                                                          // color: Colors.tealAccent,
                                                          width: 2),
                                                      borderRadius: BorderRadius.circular(20.w)),
                                                  height: 10.w,
                                                  width: 10.w,
                                                  padding: const EdgeInsets.all(8),
                                                  child: Image.asset(
                                                    'newAssets/Icons/$tempScreen.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                      boxShadow: const <BoxShadow>[
                                                        BoxShadow(
                                                            color: Colors.black12,
                                                            blurRadius: 15.0,
                                                            offset: Offset(0.0, 0.75))
                                                      ],
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(20.w)),
                                                  height: 10.w,
                                                  width: 10.w,
                                                  padding: const EdgeInsets.all(8),
                                                  child: Image.asset(
                                                      'newAssets/Icons/$tempScreen.png'),
                                                ),
                                        ),
                                        onTap: () {
                                          switch (ProgramLists.commonList[index].toString()) {
                                            case 'News Letter':
                                              selectedIndex = index;
                                              tabController.updateSelectedIconValue(
                                                  value: "Social");
                                              tabController.updateProgramsTab(val: selectedIndex);
                                              // Get.toNamed(Routes.newsLetter);

                                              break;
                                            case 'Health Tips':
                                              selectedIndex = index;
                                              tabController.updateProgramsTab(val: selectedIndex);
                                              //Get.toNamed(Routes.healthTips);
                                              tabController.updateSelectedIconValue(
                                                  value: "Social");

                                              break;
                                            case 'hPod Locations':
                                              selectedIndex = index;
                                              tabController.updateProgramsTab(val: selectedIndex);
                                              tabController.updateSelectedIconValue(
                                                  value: "Social");
                                              // Get.toNamed(Routes.hpodLocations);

                                              break;
                                            case 'Ask IHL':
                                              selectedIndex = index;
                                              tabController.updateProgramsTab(val: selectedIndex);
                                              tabController.updateSelectedIconValue(
                                                  value: "Social");
                                              // Get.toNamed(Routes.askIHL);

                                              break;

                                            case 'Challenges':
                                              selectedIndex = index;
                                              tabController.updateProgramsTab(val: selectedIndex);
                                              tabController.updateSelectedIconValue(
                                                  value: "Social");
                                              // Get.to(HealthChallengesComponents(
                                              //   list: ["global", "Global"],
                                              // ));
                                              // Get.to(const Social());
                                              break;
                                            default:
                                          }
                                          // if ('News Letter' == screen[index].toString()) {
                                          //   Get.toNamed(Routes.newsLetter);
                                          // }
                                        },
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 1.h, bottom: 0.5.h),
                                        child: Obx(
                                          () => Text(ProgramLists.commonList[index],
                                              maxLines: 1,
                                              softWrap: false,
                                              style: tabController.programsTab.value != index
                                                  ? AppTextStyles.iconFonts
                                                  : AppTextStyles.IconTitles),
                                        ),
                                      ),
                                      Obx(() => tabController.programsTab.value == index
                                          ? Padding(
                                              padding: tabController.programsTab.value == 0
                                                  ? EdgeInsets.only(left: 2.w)
                                                  : EdgeInsets.only(left: .1.w),
                                              child: Container(
                                                width: 18.w,
                                                height: .4.h,
                                                decoration: BoxDecoration(
                                                    color: const Color(0xff61C6E7),
                                                    borderRadius: BorderRadius.circular(2)),
                                              ),
                                            )
                                          : Container())
                                    ],
                                  ),
                                );
                              }))
                    ]),
                  ),
                ),
                Obx(() {
                  if (pages.length > tabController.programsTab.value) {
                    return SizedBox(height: 70.h, child: pages[tabController.programsTab.value]);
                  }
                  return Container();
                })
              ],
            ),
          ),
        ));
  }
}
