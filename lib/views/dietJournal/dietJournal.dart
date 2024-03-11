import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/offline_widget.dart';

///experiment with graph screen --sumit
import 'package:provider/provider.dart';

import '../../new_design/presentation/pages/home/home_view.dart';
import 'add_new_dish.dart';
import 'diet_journal_dash.dart';

class DietJournal extends StatefulWidget {
  final String Screen;
  DietJournal({Key key, this.Screen}) : super(key: key);
  @override
  _DietJournalState createState() => _DietJournalState();
}

class _DietJournalState extends State<DietJournal> with TickerProviderStateMixin {
  int currentIndex = 0;
  PageController _pageController;
  @override
  void initState() {
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
            Get.off(LandingPage());
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
                    child: DietJournalDash(),
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
