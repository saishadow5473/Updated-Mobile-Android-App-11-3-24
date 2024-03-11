import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/cardiovascular_views/cardio_dashboard.dart';
import 'package:ihl/views/cardiovascular_views/cardio_stats.dart';
import 'package:ihl/views/cardiovascular_views/hpod_locations.dart';
import 'package:ihl/views/re_designed_home_screen.dart';

import '../../new_design/presentation/pages/home/home_view.dart';

class CardioNavBar extends StatefulWidget {
  const CardioNavBar({Key key, this.index, this.affiliatedCompanyNamesList}) : super(key: key);
  final index;
  final List<String> affiliatedCompanyNamesList;

  @override
  State<CardioNavBar> createState() => _CardioNavBarState();
}

class _CardioNavBarState extends State<CardioNavBar> {
  @override
  int currentIndex;
  List<String> affLst = [];

  @override
  void initState() {
    // widget.affiliatedCompanyNamesList.removeWhere((element) {
    //   if (!element.toString().contains('empty')) {
    //     affLst.add(element);
    //     return element.toString().contains('empty');
    //   } else
    //     return element.toString().contains('empty');
    // });
    // TODO: implement initState
    widget.index != null ? currentIndex = widget.index : currentIndex = 0;
    super.initState();
  }

  PageController _pageController = PageController(keepPage: true);
  void changePage(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
    setState(() => currentIndex = index);
  }

  List<Widget> body = [
    CardioDashboard(),
    HpodLocations(
      isGeneric: false,
    ),
    CardioGraphView(
      isGeneric: false,
    )
  ];
  Future<bool> willPopFunction() async {
    // Navigator.pushAndRemoveUntil(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => HomeScreen(
    //         introDone: true,
    //       ),
    //     ),
    // (Route<dynamic> route) => false);
    Get.off(LandingPage());
  }

  var currentPageValue = 0.0;
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      onWillPop: willPopFunction,
      child: Scaffold(
        body: PageView(
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: body,
        ),
        // body: body[currentIndex],
        bottomNavigationBar: BubbleBottomBar(
          hasNotch: true,
          // fabLocation: BubbleBottomBarFabLocation.end,
          opacity: .2,
          currentIndex: currentIndex,
          onTap: changePage,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ), //border radius doesn't work when the notch is enabled.
          elevation: 8,
          // tilesPadding: EdgeInsets.symmetric(
          //   vertical: 8.0,
          // ),
          items: <BubbleBottomBarItem>[
            BubbleBottomBarItem(
              // showBadge: true,
              // badge: Text("5"),
              // badgeColor: Colors.deepPurpleAccent,
              backgroundColor: Colors.red,
              icon: Icon(
                Icons.dashboard,
                color: FitnessAppTheme.grey,
              ),
              activeIcon: Icon(
                Icons.dashboard,
                color: Colors.red,
              ),
              title: Text("Score"),
            ),
            BubbleBottomBarItem(
              // showBadge: true,
              // badge: Text("5"),
              // badgeColor: Colors.deepPurpleAccent,
              backgroundColor: AppColors.primaryAccentColor.withOpacity(0.5),
              icon: Icon(Icons.place_outlined, color: FitnessAppTheme.grey
                  // Colors.black,
                  ),
              activeIcon: Icon(
                Icons.place_rounded,
                color: AppColors.primaryAccentColor,
              ),
              title: Text(
                "H-Pod Stations",
                style: TextStyle(color: AppColors.primaryAccentColor),
              ),
            ),
            BubbleBottomBarItem(
              backgroundColor: Colors.deepPurple,
              icon: Icon(Icons.poll_outlined, color: FitnessAppTheme.grey),
              activeIcon: Icon(
                Icons.poll_rounded,
                color: Colors.deepPurple,
              ),
              title: Text(
                "Stats",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
