import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../app/utils/appColors.dart';
import '../../../../data/functions/healthJounralFunctions.dart';
import '../../../Widgets/healthjournalWidgets/myInsightsWidgets.dart';
import '../../../Widgets/healthjournalWidgets/normalHealthJournalWidgets.dart';

class MyInsightsHealthJournal extends StatefulWidget {
  const MyInsightsHealthJournal({Key key}) : super(key: key);

  @override
  State<MyInsightsHealthJournal> createState() => _MyInsightsHealthJournalState();
}

class _MyInsightsHealthJournalState extends State<MyInsightsHealthJournal>
    with SingleTickerProviderStateMixin {
  TabController tabBarController;

  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier<int>(0);

  void initState() {
    MyInsightsWidgets.selectedIndex.value = 0;
    tabBarController = TabController(
      vsync: this,
      length: 5,
      initialIndex: 0,
    );
    tabBarController.addListener(() {
      MyInsightsWidgets.selectedIndex.value = tabBarController.index;
      _tabIndexNotifier.value = MyInsightsWidgets.selectedIndex.value;
    });
    super.initState();
  }

  // @override
  // void dispose() {
  //   tabBarController.dispose();
  //   log("Health journal => My Insights Tab controller disposed");
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
        appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () async {
                Get.back();
              },
              color: Colors.white,
            ),
            centerTitle: true,
            title: Text("My Insights"),
            backgroundColor: AppColors.primaryColor),
        content: SizedBox(
            height: 100.h,
            width: 100.w,
            child: DefaultTabController(
                length: 5,
                child: Column(children: [
                  Container(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(height: 0.8.h),
                    ValueListenableBuilder(
                        valueListenable: _tabIndexNotifier,
                        builder: (BuildContext context, int tabIndex, Widget child) {
                          return Container(
                              height: 16.w,
                              width: 100.w,
                              child: TabBar(
                                  controller: tabBarController,
                                  indicatorColor: Colors.transparent,
                                  indicatorWeight: 4,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 1.w),
                                  isScrollable: true,
                                  indicatorPadding: EdgeInsets.zero,
                                  tabs: [
                                    tabwidget(titile: "All Meals"),
                                    tabwidget(titile: "Breakfast"),
                                    tabwidget(titile: "Lunch"),
                                    tabwidget(titile: "Snacks"),
                                    tabwidget(titile: "Dinner"),
                                  ]));
                        })
                  ])),
                  Expanded(
                      child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: tabBarController,
                          children: [
                        AllMealsTab(),
                        IndividualMyInsightsScreen(category: "Breakfast"),
                        IndividualMyInsightsScreen(category: "Lunch"),
                        IndividualMyInsightsScreen(category: "Snacks"),
                        IndividualMyInsightsScreen(category: "Dinner")
                      ]))
                ]))));
  }

  Widget tabwidget({String titile}) {
    List keys = ["All Meals", "Breakfast", "Lunch", "Snacks", "Dinner"];
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(25),
          topLeft: Radius.circular(25),
          topRight: Radius.circular(0)),
      elevation: keys[MyInsightsWidgets.selectedIndex.value] == titile ? 0 : 3,
      child: ClipPath(
          clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(0)))),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: 10.w,
            width: 30.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Color(0XFFDCDBDB),
                border: keys[MyInsightsWidgets.selectedIndex.value] != titile
                    ? null
                    : Border(bottom: BorderSide(color: AppColors.primaryColor, width: 1.w))),
            child: Text(titile),
          )),
    );
  }
}

class AllMealsTab extends StatefulWidget {
  const AllMealsTab({Key key}) : super(key: key);

  @override
  State<AllMealsTab> createState() => _AllMealsTabState();
}

class _AllMealsTabState extends State<AllMealsTab> {
  @override
  void initState() {
    asyncFunctions();
    super.initState();
  }

  asyncFunctions() async {
    MyInsightsWidgets.myInsigtschanged.value = "Day";
    MyInsightsWidgets.myInsigtsdatas = [];
    MyInsightsWidgets.myInsigtsdatas = await HealthJournalFunctions.allDataGraphValue(
        selectedCate: ["Breakfast", "Lunch", "Snacks", "Dinner"], dateFreq: constantDate.dayFre);
    Timer(Duration.zero, () {
      MyInsightsWidgets.myInsigtschanged.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          ValueListenableBuilder(
              key: Key("HJMI_PCS09063"),
              valueListenable: MyInsightsWidgets.myInsigtschanged,
              builder: (ctx, index, child) {
                return MyInsightsWidgets.graphMyInsights(
                    datatoDisplay: MyInsightsWidgets.myInsigtsdatas);
              })
        ],
      ),
    );
  }
}

class IndividualMyInsightsScreen extends StatefulWidget {
  IndividualMyInsightsScreen({Key key, @required this.category}) : super(key: key);
  String category;
  @override
  State<IndividualMyInsightsScreen> createState() => _IndividualMyInsightsScreenState();
}

class _IndividualMyInsightsScreenState extends State<IndividualMyInsightsScreen> {
  @override
  void initState() {
    asyncFunctions();
    super.initState();
  }

  asyncFunctions() async {
    NormalHealthJournalWidgets.currentIndexValue.value = "Day";
    NormalHealthJournalWidgets.currentFreq = constantDate.dayFre;
    NormalHealthJournalWidgets.selectedCategory.value = widget.category;
    NormalHealthJournalWidgets.datas =
        await HealthJournalFunctions.singleGraphValue(dateFreq: constantDate.dayFre);
    // Timer(Duration.zero, () {
    NormalHealthJournalWidgets.currentIndexValue.notifyListeners();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          ValueListenableBuilder(
              key: Key("HJBF_VN21063"),
              valueListenable: NormalHealthJournalWidgets.currentIndexValue,
              builder: (ctx, index, child) {
                return NormalHealthJournalWidgets.graphHealthJournalIndividual(
                    datatoDisplay: NormalHealthJournalWidgets.datas);
              })
        ],
      ),
    );
  }
}
