import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import 'package:ihl/new_design/presentation/controllers/healthJournalControllers/getTodayLogController.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/views/dietJournal/dietJournalDashNew.dart';
import '../../new_design/app/utils/appText.dart';
import '../../new_design/presentation/pages/home/home_view.dart';
import '../../new_design/presentation/pages/manageHealthscreens/manageHealthScreentabs.dart';
import 'add_new_dish.dart';
import 'package:provider/provider.dart';

import '../../utils/screenutil.dart';
import '../../widgets/offline_widget.dart';
import 'diet_journal_dash.dart';

class DietJournalNew extends StatefulWidget {
  final String Screen;

  DietJournalNew({Key key, this.Screen}) : super(key: key);

  @override
  State<DietJournalNew> createState() => _DietJournalNewState();
}

class _DietJournalNewState extends State<DietJournalNew> {
  PageController _pageController;
  int currentIndex = 0;
  final _tabController = Get.put(TabBarController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.updateSelectedIconValue(value: AppTexts.manageHealth);
    });

    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return ChangeNotifierProvider<listData>(
      create: (context) => listData(),
      child: WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          // Get.put(TodayLogController());
          // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()),
          //     (Route<dynamic> route) => false);

          if (widget.Screen == 'home' || widget.Screen == 'manageHealth') {
            Get.back();
          } else {
            Get.off(ManageHealthScreenTabs());
            try {
              Get.find<TodayLogController>().onInit();
            } catch (e) {
              print("Today Log Controller deleted");
            }
          }
        },
        child: ConnectivityWidgetWrapper(
          disableInteraction: true,
          offlineWidget: OfflineWidget(),
          child: Container(
            color: AppColors.primaryAccentColor,
            child: Scaffold(
                body: Container(
              color: AppColors.bgColorTab,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  if (this.mounted) {
                    setState(() => currentIndex = index);
                  }
                },
                children: [
                  Tab(
                      child: widget.Screen == "home"
                          ? DietJournalDashNew(
                        Screen: "home",
                      )
                          : DietJournalDashNew(
                        Screen: "managehealth",
                      )
                    // : DietJournalDashNew(),
                  ),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
