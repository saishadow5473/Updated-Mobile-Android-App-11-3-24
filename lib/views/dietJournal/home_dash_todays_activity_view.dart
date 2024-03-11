import 'package:flutter/material.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:ihl/views/dietJournal/models/get_todays_food_log_model.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:ihl/views/dietJournal/activity/today_activity.dart';
import 'package:ihl/views/dietJournal/activity_tile_view.dart';
import 'package:strings/strings.dart';

class HomeDashBoardTodaysActivityView extends StatefulWidget {
  HomeDashBoardTodaysActivityView({this.todaysActivityList, this.otherActivityList});
  final List<Activity> todaysActivityList;
  final List<Activity> otherActivityList;

  @override
  _HomeDashBoardTodaysActivityViewState createState() => _HomeDashBoardTodaysActivityViewState();
}

class _HomeDashBoardTodaysActivityViewState extends State<HomeDashBoardTodaysActivityView> {
  bool loaded = true;

  void getData() async {
    final preferences = await StreamingSharedPreferences.instance;
    int actvitykCal = 0;
    for (int i = 0; i < widget.todaysActivityList.length; i++) {
      if (widget.todaysActivityList[i].totalCaloriesBurned != '0' &&
          widget.todaysActivityList[i].totalCaloriesBurned != null) {
        print('Calories :${widget.todaysActivityList[i].totalCaloriesBurned}');
        actvitykCal = actvitykCal + int.parse(widget.todaysActivityList[i].totalCaloriesBurned);
      }
    }
    preferences.setInt('burnedCalorie', actvitykCal);
    if (this.mounted) {
      setState(() {
        loaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // getData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ScUtil.screenHeight > 800 ? Colors.transparent : Colors.white,
        borderRadius:
            ScUtil.screenHeight > 800 ? BorderRadius.circular(0) : BorderRadius.circular(25),
      ),
      child: loaded
          ? Scrollbar(
              child: Column(
                children: [
                  SizedBox(height: ScUtil().setHeight(28)),
                  Container(
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      // scrollDirection: Axis.horizontal,
                      // padding: EdgeInsets.symmetric(horizontal: 0, vertical: 18),
                      // padding: EdgeInsets.only(top: ScUtil().setSp(30)),
                      shrinkWrap: true,
                      itemCount: widget.todaysActivityList.length.clamp(1, 2),
                      itemBuilder: (BuildContext context, int index) => ListTile(
                        title: Text(
                          camelize(widget.todaysActivityList[index].activityDetails[0]
                                  .activityDetails[0].activityName ??
                              'Unknown Activity'),
                          style: TextStyle(
                              fontSize: ScUtil().setSp(11.5),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5),
                        ),
                        subtitle: Text(
                          '${widget.todaysActivityList[index].totalCaloriesBurned ?? '-'} Cal  |  ${widget.todaysActivityList[index].activityDetails[0].activityDetails[0].activityDuration} Mins',
                          // 'Light Impact', //L -Light, M- Medium, V-High
                          style: TextStyle(
                              fontSize: ScUtil().setSp(9),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5),
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            height: 50,
                            width: 45,
                            decoration:
                                BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: Image.asset('assets/icons/act3.png'),
                          ),
                        ),
                        trailing: Text(
                          'Today ${widget.todaysActivityList[index].logTime.substring(11, 16)}',
                          // 'Light Impact', //L -Light, M- Medium, V-High
                          style: TextStyle(
                              fontSize: ScUtil().setSp(12),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TodayActivityScreen(
                                todaysActivityData: widget.todaysActivityList,
                                otherActivityData: widget.otherActivityList,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          : RunningView(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TodayActivityScreen(
                            todaysActivityData: widget.todaysActivityList,
                          )),
                );
              },
            ),
    );
  }
}
