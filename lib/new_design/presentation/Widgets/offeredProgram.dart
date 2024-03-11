import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Getx/controller/BannerChallengeController.dart';
import '../../app/utils/appText.dart';
import '../pages/askIHL/askIHL.dart';
import '../pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../pages/healthTips/healthTips.dart';
import '../pages/hpodLocations/hpodLocations.dart';
import '../pages/manageHealthscreens/manageHealthScreentabs.dart';
import '../pages/newsLetter/newsLetter.dart';
import '../pages/social/social.dart';
import 'package:sizer/sizer.dart';

import '../../../views/teleconsultation/viewallneeds.dart';
import '../../app/utils/appColors.dart';
import '../../app/utils/textStyle.dart';
import '../controllers/dashboardControllers/dashBoardContollers.dart';

class OfferedPrograms extends StatelessWidget {
  final screen;
  final screenTitle;
  const OfferedPrograms({Key key, this.screen, @required this.screenTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int selectedIndex;
    final TabBarController tabController = Get.find();
    return PhysicalModel(
      color: AppColors.plainColor,
      elevation: 2,
      child: Container(
        height: 30.w,
        color: AppColors.plainColor,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.only(top: 1.h, left: 4.w),
            child: Text(screenTitle, style: AppTextStyles.selectedHeadline),
          ),
          Flexible(
              child: ListView.builder(
                  padding: EdgeInsets.only(
                    top: 1.h,
                  ),
                  scrollDirection: Axis.horizontal,
                  // itemCount: Platform.isIOS ? screen.length - 1 : screen.length,
                  itemCount: screen.length,
                  itemBuilder: (BuildContext context, int index) {
                    String tempScreen = screen[index];
                    return Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                      width: 20.w,
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            child: Obx(
                              () => tabController.programsTab.value == index
                                  ? Container(
                                      decoration: BoxDecoration(
                                          // color: const Color(0xff61C6E7),
                                          border: Border.all(
                                              color: const Color(0xff61C6E7),
                                              // color: Colors.tealAccent,
                                              width: 2),
                                          borderRadius: BorderRadius.circular(20.w)),
                                      height: 10.w,
                                      width: 10.w,
                                      padding: const EdgeInsets.all(8),
                                      child: tempScreen != "Teleconsultations"
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
                                      child: tempScreen != "Teleconsultations"
                                          ? Image.asset('newAssets/Icons/$tempScreen.png')
                                          : Image.asset(
                                              'newAssets/tele.png',
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                            ),
                            onTap: () {
                              switch (screen[index].toString()) {
                                case 'News Letter':
                                  selectedIndex = index;
                                  tabController.updateSelectedIconValue(value: "Social");
                                  tabController.updateProgramsTab(val: selectedIndex);
                                  // Get.toNamed(Routes.newsLetter);
                                  Get.to(const NewsLetter());
                                  break;
                                case 'Health Tips':
                                  selectedIndex = index;
                                  tabController.updateProgramsTab(val: selectedIndex);
                                  //Get.toNamed(Routes.healthTips);
                                  tabController.updateSelectedIconValue(value: "Social");
                                  Get.to(HealthTips());
                                  break;
                                case 'hPod Locations':
                                  selectedIndex = index;
                                  tabController.updateProgramsTab(val: selectedIndex);
                                  tabController.updateSelectedIconValue(value: "Social");
                                  // Get.toNamed(Routes.hpodLocations);
                                  Get.to(HpodLocations());
                                  break;
                                case 'Ask IHL':
                                  selectedIndex = index;
                                  tabController.updateProgramsTab(val: selectedIndex);
                                  tabController.updateSelectedIconValue(value: "Social");
                                  // Get.toNamed(Routes.askIHL);
                                  Get.to(const AskIHL());
                                  break;
                                case 'Vitals':
                                  selectedIndex = index;
                                  tabController.updateProgramsTab(val: selectedIndex);
                                  tabController.updateSelectedIconValue(
                                      value: AppTexts.manageHealth);
                                  //Get.toNamed(Routes.myVitals);
                                  Get.to( ManageHealthScreenTabs());
                                  // Get.to(VitalTab(
                                  //   isShowAsMainScreen: false,
                                  // ));
                                  break;
                                case 'Teleconsultations':
                                  selectedIndex = index;
                                  tabController.updateProgramsTab(val: selectedIndex);
                                  selectedAffiliationfromuniquenameDashboard == ''
                                      ? Get.to(ViewallTeleDashboard(
                                          backNav: null,
                                        ))
                                      : Get.to( ViewFourPillar());
                                  break;
                                case 'Challenges':
                                  selectedIndex = index;
                                  tabController.updateProgramsTab(val: selectedIndex);
                                  tabController.updateSelectedIconValue(value: "Social");
                                  // Get.to(HealthChallengesComponents(
                                  //   list: ["global", "Global"],
                                  // ));
                                  Get.put(BannerChallengeController()).challengeVisibleType =
                                      'social';
                                  Get.to(const Social());
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
                              () => Text(screen[index],
                                  maxLines: 1,
                                  softWrap: false,
                                  style: tabController.programsTab.value != index
                                      ? AppTextStyles.iconFonts
                                      : AppTextStyles.IconTitles),
                            ),
                          ),
                          Obx(() => tabController.programsTab.value == index
                              ? Container(
                                  width: 18.w,
                                  height: .4.h,
                                  decoration: BoxDecoration(
                                      color: const Color(0xff61C6E7),
                                      borderRadius: BorderRadius.circular(2)),
                                )
                              : Container())
                        ],
                      ),
                    );
                  }))
        ]),
      ),
    );
  }
}
