import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/utils/appColors.dart';
import 'teleconsultation_underonlineServiceTab.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../Modules/online_class/functionalities/upcoming_courses.dart';
import '../../../../Modules/online_class/online_class.dart';
import '../../../app/utils/constLists.dart';
import '../../Widgets/appBar.dart';
import '../dashboard/common_screen_for_navigation.dart';

class OnlineServicesTabs extends StatefulWidget {
  const OnlineServicesTabs({Key key}) : super(key: key);

  @override
  State<OnlineServicesTabs> createState() => _OnlineServicesTabsState();
}

class _OnlineServicesTabsState extends State<OnlineServicesTabs>
    with SingleTickerProviderStateMixin {
  TabController tabBarController;
  int selectedIndex = 0;
  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    );
    tabBarController.addListener(() {
      selectedIndex = tabBarController.index;
      _tabIndexNotifier.value = selectedIndex;
    });

    super.initState();
  }

  @override
  void dispose() {
    tabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   

    return WillPopScope(
      onWillPop: () => null,
      child: CommonScreenForNavigation(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarOpacity: 0,
          toolbarHeight: 6.h,
          flexibleSpace: const CustomeAppBar(screen: ProgramLists.commonList),
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.unSelectedColor,
        ),
        content: SizedBox(
          // color: HexColor('#AEAEAE'),
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
                          "Online Services",
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
                                controller: tabBarController,
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
                                            color: selectedIndex == 0
                                                ? const Color(0XFF61C6E7)
                                                : Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                              "newAssets/Icons/tab_icon_teleconsulation.png"),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Teleconsultation",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12.4.sp,
                                              color: selectedIndex == 0
                                                  ? const Color(0XFF61C6E7)
                                                  : Colors.black,
                                              fontWeight:
                                                  selectedIndex == 0 ? FontWeight.bold : null,
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
                                              color: selectedIndex == 1
                                                  ? const Color(0XFF61C6E7)
                                                  : Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 3,
                                                  spreadRadius: 3,
                                                  color: Colors.grey.shade200,
                                                  offset: const Offset(1, 1),
                                                )
                                              ]),
                                          child: Image.asset("newAssets/Icons/Online Class.png"),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Online Session",
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 12.4.sp,
                                              color: selectedIndex == 1
                                                  ? const Color(0XFF61C6E7)
                                                  : Colors.black,
                                              fontWeight:
                                                  selectedIndex == 1 ? FontWeight.bold : null,
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
                    controller: tabBarController,
                    children: [
                      const TeleconsultationOnlineService(),
                      if (!Tabss.featureSettings.onlineClasses)
                        const Center(child: Text("No Online Session Available"))
                      else
                        OnlineClassDashboard(),
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
