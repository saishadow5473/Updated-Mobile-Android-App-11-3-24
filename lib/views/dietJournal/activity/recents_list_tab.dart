import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:strings/strings.dart';
import 'package:ihl/views/dietJournal/activity/activity_detail.dart';
import 'package:ihl/views/dietJournal/models/user_bookmarked_activity_model.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:ihl/utils/SpUtil.dart';

import '../models/get_todays_food_log_model.dart';

class RecentsActivityTab extends StatefulWidget {
  final List<Activity> todayLogList;
  RecentsActivityTab({Key key, @required this.todayLogList}) : super(key: key);

  @override
  _RecentsActivityTabState createState() => _RecentsActivityTabState();
}

class _RecentsActivityTabState extends State<RecentsActivityTab> {
  List<BookMarkedActivity> recentList = [];
  bool loaded = false;
  bool empty = false;

  @override
  void initState() {
    super.initState();
    getRecentList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getRecentList() async {
    await SpUtil.getInstance();
    recentList = SpUtil.getRecentActivityObjectList('recent_activity') ?? [];
    if (recentList.isNotEmpty) {
      setState(() {
        loaded = true;
      });
    } else {
      setState(() {
        loaded = true;
        empty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loaded) {
      return !empty
          ? ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount: recentList.length,
              itemBuilder: (BuildContext context, int index) => ListTile(
                title: Text(
                  camelize(recentList[index].activityName ?? 'Name Unknown'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                subtitle: Text(
                  recentList[index].activityType == 'L'
                      ? 'Light Impact'
                      : recentList[index].activityType == 'M'
                          ? 'Medium Impact'
                          : recentList[index].activityType == 'V'
                              ? 'High Impact'
                              : 'Normal',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                      height: 50,
                      width: 50,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFfwLJ_c9qyqUd7-Fa2V5mXqyc20VTWftelVPml48TJupo-TZKbBowiah2awK1s_0kPSQ&usqp=CAU')),
                ),
                onTap: () {
                  Get.to(ActivityDetailScreen(
                    activityObj: recentList[index],
                    todayLogList: widget.todayLogList,
                  ));
                },
              ),
            )
          : Container(
              child: Center(
                child: Text(
                  'No Recents\nContinue browsing activities to see more here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: 4,
        itemBuilder: (BuildContext context, int index) => ListTile(
          title: LoadingSkeleton(
            width: 100,
            height: 20,
            colors: [Colors.grey, Colors.grey[300], Colors.grey],
            margin: EdgeInsets.only(right: 120),
          ),
          subtitle: LoadingSkeleton(
            width: 200,
            height: 10,
            colors: [Colors.grey, Colors.grey[300], Colors.grey],
            margin: EdgeInsets.only(right: 80),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LoadingSkeleton(
              width: 50,
              height: 50,
              colors: [Colors.grey, Colors.grey[300], Colors.grey],
            ),
          ),
          onTap: () {},
        ),
      );
    }
  }
}
