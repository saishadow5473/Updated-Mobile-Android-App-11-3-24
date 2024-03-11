import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../home/landingPage.dart';
import '../../../app/utils/appColors.dart';
import '../dashboard/common_screen_for_navigation.dart';
import 'stepcounter/stepcounterdashboard.dart';
import '../../../../utils/SpUtil.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../app/utils/constLists.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../Widgets/appBar.dart';
import '../myVitals/myVitalsDashBoard.dart';
import 'healthjournalTab.dart';

TabController gTabBarController;
int indexFromStepCounter = 0;

class ManageHealthScreenTabs extends StatefulWidget {
  int naviBack;
  ManageHealthScreenTabs({Key key, this.naviBack}) : super(key: key);

  @override
  State<ManageHealthScreenTabs> createState() => _ManageHealthScreenTabsState();
}

class _ManageHealthScreenTabsState extends State<ManageHealthScreenTabs>
    with SingleTickerProviderStateMixin {
  ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  ValueNotifier<int> _tabIndexNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    _tabIndexNotifier.value = widget.naviBack ?? indexFromStepCounter;
    print(_tabIndexNotifier.value);
    gTabBarController = TabController(
      vsync: this,
      //Unslash for Step counter 🥥
      length: 3,
      // length: 2,
      initialIndex: widget.naviBack ?? indexFromStepCounter,
    );
    gTabBarController.addListener(() {
      selectedIndex.value = gTabBarController.index;
      _tabIndexNotifier.value = selectedIndex.value;
      // if (gTabBarController.index == 2) {
      //   Get.to(StepsScreen());
      // }
      indexFromStepCounter = 0;
    });

    super.initState();
  }

  @override
  void dispose() {
    gTabBarController.dispose();
    log("Health Journal Tab controller disposed");
    super.dispose();
  }

  final TabBarController tabController = Get.put(TabBarController());

  @override
  Widget build(BuildContext context) {
    bool aff = SpUtil.getBool(LSKeys.affiliation) ?? false;

    return WillPopScope(
      onWillPop: () async {
        tabController.programsTab.value = 0;
        Get.offAll(LandingPage());
        return false;
      },
      child: CommonScreenForNavigation(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarOpacity: 0,
          toolbarHeight: 7.5.h,
          flexibleSpace: const CustomeAppBar(screen: ProgramLists.vitalsList),
          backgroundColor: Colors.white,
          elevation: aff ?? false ? 2 : 0,
          shadowColor: AppColors.unSelectedColor,
        ),
        content: Container(
          color: Colors.white,
          height: 100.h,
          width: 100.w,
          child: DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      spreadRadius: 3,
                      color: Colors.grey.shade400,
                      offset: const Offset(1, 1),
                    )
                  ]),
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 2),
                        child: Text(
                          "Manage health",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ValueListenableBuilder(
                          valueListenable: _tabIndexNotifier,
                          builder: (BuildContext context, int tabIndex, Widget child) {
                            return SizedBox(
                              height: 16.w,
                              width: 100.w,
                              child: TabBar(
                                controller: gTabBarController,
                                indicatorColor: const Color(0XFF61C6E7),
                                indicatorWeight: 4,
                                labelPadding: EdgeInsets.symmetric(horizontal: 3.w),
                                isScrollable: true,
                                indicatorPadding: EdgeInsets.zero,
                                tabs: [
                                  Tab(
                                    height: 9.h,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 10.w,
                                          width: 10.w,
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 3,
                                                spreadRadius: 3,
                                                color: Colors.grey.shade200,
                                                offset: const Offset(1, 1),
                                              )
                                            ],
                                            border: Border.all(
                                                color: tabIndex == 0
                                                    ? const Color(0XFF61C6E7)
                                                    : Colors.white,

                                                // color: Colors.tealAccent,
                                                width: 2),
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset("newAssets/Icons/Vitals.png"),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Vitals",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12.4.sp,
                                              color: tabIndex == 0
                                                  ? const Color(0XFF61C6E7)
                                                  : Colors.black,
                                              fontWeight: tabIndex == 0 ? FontWeight.bold : null,
                                              letterSpacing: 0.4),
                                        )
                                      ],
                                    ),
                                  ),
                                  Tab(
                                    height: 9.h,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 10.w,
                                          width: 10.w,
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: tabIndex == 1
                                                      ? const Color(0XFF61C6E7)
                                                      : Colors.white,

                                                  // color: Colors.tealAccent,
                                                  width: 2),
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 3,
                                                  spreadRadius: 3,
                                                  color: Colors.grey.shade200,
                                                  offset: const Offset(1, 1),
                                                )
                                              ]),
                                          child: Image.asset("newAssets/Icons/Calorie Tracker.png"),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Calorie Tracker",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12.4.sp,
                                              color: tabIndex == 1
                                                  ? const Color(0XFF61C6E7)
                                                  : Colors.black,
                                              fontWeight: tabIndex == 1 ? FontWeight.bold : null,
                                              letterSpacing: 0.4),
                                        )
                                      ],
                                    ),
                                  ),
                                  //Unslash for Step counter 🥥
                                  Tab(
                                    height: 9.h,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 10.w,
                                          width: 10.w,
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: tabIndex == 2
                                                      ? const Color(0XFF61C6E7)
                                                      : Colors.white,

                                                  // color: Colors.tealAccent,
                                                  width: 2),
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 3,
                                                  spreadRadius: 3,
                                                  color: Colors.grey.shade200,
                                                  offset: const Offset(1, 1),
                                                )
                                              ]),
                                          child: Image.asset("newAssets/Icons/Step Tracker.png"),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Step Tracker",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12.4.sp,
                                              color: tabIndex == 2
                                                  ? const Color(0XFF61C6E7)
                                                  : Colors.black,
                                              fontWeight: tabIndex == 2 ? FontWeight.bold : null,
                                              letterSpacing: 0.4),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: gTabBarController,
                    children: [
                      const MyvitalsDetails(),
                      const HealthJournalTab(),
                      //Unslash for Step counter 🥥
                      StepCounterMainDashboard(),

                      // Container()
                      // StepsScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
