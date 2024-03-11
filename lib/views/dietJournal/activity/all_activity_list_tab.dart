import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/views/dietJournal/activity/activity_detail.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/models/user_bookmarked_activity_model.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:strings/strings.dart';

import '../models/get_todays_food_log_model.dart';

class AllActivityTab extends StatefulWidget {
  final List<Activity> todayLogList;
  AllActivityTab({Key key, @required this.todayLogList}) : super(key: key);

  @override
  _AllActivityTabState createState() => _AllActivityTabState();
}

class _AllActivityTabState extends State<AllActivityTab> {
  List<BookMarkedActivity> allActivitylist = [];
  bool loaded = false;
  bool empty = false;

  @override
  void initState() {
    super.initState();
    getAllActivityList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getAllActivityList() async {
    var details = await ListApis.getActivityList();

    for (int i = 0; i < details.length; i++) {
      bool exists = allActivitylist.any((fav) => fav.activityId == details[i].activityId);
      if (!exists) {
        allActivitylist.add(details[i]);
        print(allActivitylist);
      }
    }
    if (allActivitylist.isNotEmpty) {
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
          ? Scrollbar(
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: allActivitylist.length,
                itemBuilder: (BuildContext context, int index) => Visibility(
                  visible: allActivitylist[index].activityId != 'activity_103' &&
                      allActivitylist[index].activityId != 'activity_61',
                  child: ListTile(
                    title: Text(
                      camelize(allActivitylist[index].activityName ?? 'Name Unknown'),
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                    subtitle: Text(
                      allActivitylist[index].activityType == 'L'
                          ? 'Light Impact'
                          : allActivitylist[index].activityType == 'M'
                              ? 'Medium Impact'
                              : allActivitylist[index].activityType == 'V'
                                  ? 'High Impact'
                                  : 'Normal',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
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
                        activityObj: allActivitylist[index],
                        todayLogList: widget.todayLogList,
                      ));
                    },
                  ),
                ),
              ),
            )
          : Container(
              child: Center(
                child: Text(
                  'Activity List not Loaded.\nSorry for the inconvinence.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: 8,
        itemBuilder: (BuildContext context, int index) => ListTile(
          title: LoadingSkeleton(
            width: 100,
            height: 20,
            colors: [Colors.grey, Colors.grey[300], Colors.grey],
            animationEnd: AnimationEnd.EXTREMELY_ON_TOP,
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
