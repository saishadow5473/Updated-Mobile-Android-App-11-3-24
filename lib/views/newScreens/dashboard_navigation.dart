import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../widgets/BasicPageUI.dart';
import '../../widgets/offline_widget.dart';
import '../../widgets/teleconsulation/dashboardCards.dart';

/// Main Teleconsultation dashboard 🚚
class DashBoardNavigation extends StatelessWidget {
  DashBoardNavigation({this.backNav, @required this.title, @required this.navigationList});
  final bool backNav;
  final String title;
  final List navigationList;

  /// list of options in dashboard 🚃🚃🚃

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        onWillPop: () {
          Get.off(LandingPage());
        },
        //replaces the screen to Main dashboard
        child: BasicPageUI(
          appBar: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () async {
                  Get.off(LandingPage());
                }, //replaces the screen to Main dashboard
                color: Colors.white,
              ),
              Text(
                '$title',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0.sp,
                    // fontFamily: 'Poppins'
                    fontFamily: 'Poppins'
                    // fontFamily: 'Poppins-Black'
                    ),
              ),
              SizedBox(
                width: 1.w,
              ),
              SizedBox(
                height: 10.h,
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height /
                        1.2, // bottom white space fot the teledashboard
                    child: ListView.builder(
                      physics: const ScrollPhysics(),
                      primary: false,
                      shrinkWrap: true,
                      itemCount: navigationList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return card(
                          context,
                          navigationList[index]['text'],
                          navigationList[index]['icon'],
                          navigationList[index]['iconSize'],
                          navigationList[index]['color'],
                          navigationList[index]['onTap'],
                        );
                      },
                    ),
                  ),
                  //ConsultationHistory(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
