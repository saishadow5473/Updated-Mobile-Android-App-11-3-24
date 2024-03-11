import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Getx/controller/BannerChallengeController.dart';
import '../../../app/utils/imageAssets.dart';
import '../home/landingPage.dart';
import 'package:sizer/sizer.dart';

import '../../../app/utils/appColors.dart';
import '../../Widgets/bottomNavBar.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../controllers/healthJournalControllers/getTodayLogController.dart';
import 'affiliation_dashboard/affiliationDasboard.dart';

class CommonScreenForNavigation extends StatefulWidget {
  CommonScreenForNavigation(
      {Key key,
      this.appBar,
      @required this.content,
      this.contentColor,
      this.resizeToAvoidBottomInset = false})
      : super(key: key);
  AppBar appBar;
  Widget content;
  String contentColor;
  bool resizeToAvoidBottomInset;

  @override
  State<CommonScreenForNavigation> createState() => _CommonScreenForNavigationState();
}

class _CommonScreenForNavigationState extends State<CommonScreenForNavigation> {
  final TabBarController _tabController = Get.put(TabBarController());

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      appBar: widget.appBar,
      body: Container(
        color: widget.contentColor == null ? AppColors.backgroundScreenColor : Colors.white,
        child: Stack(
          children: [
            widget.content,
            Positioned(
              bottom: -0.9.h,
              child: bottom != 0 ? const SizedBox() : const BottomNavBar(),
            ),
            Positioned(
              bottom: Platform.isAndroid ? 0.5.h : 2.h,
              child: bottom != 0
                  ? const SizedBox()
                  : Container(
                      width: 100.w,
                      alignment: Alignment.center,
                      child: GetBuilder<TabBarController>(
                        id: "navigation_icons",
                        builder: (_) {
                          return Padding(
                            padding: EdgeInsets.all(5.5.w),
                            child: InkWell(
                              onTap: () {
                                _tabController.programsTab.value = 0;
                                if (_.selectedBottomIcon != "Home") {
                                  eMarketaff = true;
                                  _tabController.programsTab.value = 0;
                                  _tabController.updateSelectedIconValue(value: "Home");
                                  Get.put(BannerChallengeController()).challengeVisibleType =
                                      'home';
                                  Get.to(LandingPage());
                                  try {
                                    Get.find<TodayLogController>().onInit();
                                  } catch (e) {
                                    Get.put(TodayLogController());
                                  }
                                } else if (_.selectedBottomIcon == "Home") {
                                  Get.to(LandingPage());
                                } else {
                                  return null;
                                }
                              },
                              // child: TitleAvatar(image: "newAssets/Icons/Home.png"),
                              child: Container(
                                height: 7.8.h,
                                width: 17.w,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 2,
                                          color: Colors.grey.withOpacity(0.5),
                                          blurRadius: 3,
                                          offset: const Offset(1, 1))
                                    ]),
                                child: Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: Image(
                                    image: _.selectedBottomIcon == "Home"
                                        ? ImageAssets.selectedHome
                                        : ImageAssets.home,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
