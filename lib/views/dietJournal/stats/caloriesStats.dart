import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ihl/views/dietJournal/stats/caloriesHiestory.dart';

import '../apis/list_apis.dart';

class CaloriesStats extends StatefulWidget {
  const CaloriesStats({Key key}) : super(key: key);

  @override
  State<CaloriesStats> createState() => _CaloriesStatsState();
}

class _CaloriesStatsState extends State<CaloriesStats> {
  // int _selectedIndex = 0;
  // List<Widget> tabItems = [
  //   TableEventsExample(),
  //   CalorieGraph(),
  // ];

  // @override
  // void initState() {
  //   getData();
  //   super.initState();
  // }
  List<MealsListData> mealsListData = [];
  void initState() {
    //getMaintainWeight();
    getData();
    super.initState();
  }

  ListApis listApis = ListApis();
  getData() {
    listApis.getUserTodaysFoodLogHistoryApi().then((value) {
      if (mounted) {
        setState(() {
          mealsListData = value['food'];
          //loaded = true;
        });
      }
    });
    print(mealsListData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TableEventsExample(mealsListData),
      // bottomNavigationBar: FlashyTabBar(
      //   animationCurve: Curves.easeInOutCirc,
      //   backgroundColor: FitnessAppTheme.nearlyWhite,
      //   iconSize: 20,
      //   selectedIndex: _selectedIndex,
      //   onItemSelected: (index) => setState(() {
      //     _selectedIndex = index;
      //   }),
      //   items: [
      //     FlashyTabBarItem(
      //         icon: Icon(
      //           Icons.history,
      //           color: FitnessAppTheme.nearlyBlue,
      //         ),
      //         title: Text(
      //           "History",
      //           style: FitnessAppTheme.iconText,
      //         )),
      //     FlashyTabBarItem(
      //         icon: Icon(
      //           Icons.auto_graph,
      //           color: FitnessAppTheme.nearlyBlue,
      //         ),
      //         title: Text(
      //           "Stats",
      //           style: FitnessAppTheme.iconText,
      //         )),
      //   ],
      // ),
    );
  }
}
