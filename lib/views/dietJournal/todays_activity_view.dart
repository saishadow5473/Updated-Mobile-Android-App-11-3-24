import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:ihl/views/dietJournal/models/get_todays_food_log_model.dart';
import 'package:loading_skeleton/loading_skeleton.dart';
import 'package:ihl/views/dietJournal/activity/today_activity.dart';
import 'package:ihl/views/dietJournal/activity_tile_view.dart';
import 'package:strings/strings.dart';

class TodaysActivityView extends StatefulWidget {
  TodaysActivityView({this.todaysActivityList, this.otherActivityList});
  final List<Activity> todaysActivityList;
  final List<Activity> otherActivityList;

  @override
  _TodaysActivityViewState createState() => _TodaysActivityViewState();
}

class _TodaysActivityViewState extends State<TodaysActivityView> {
  bool loaded = true;

  void getData() async {
    final preferences = await StreamingSharedPreferences.instance;
    int actvitykCal = 0;
    for (int i = 0; i < widget.todaysActivityList.length; i++) {
      if (widget.todaysActivityList[i].totalCaloriesBurned != '0' &&
          widget.todaysActivityList[i].totalCaloriesBurned != null) {
        actvitykCal = actvitykCal + int.parse(widget.todaysActivityList[i].totalCaloriesBurned);
      }
    }
    preferences.setInt('burnedCalorie', actvitykCal);
    setState(() {
      loaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // getData();
  }

  String mins = '0';
  String cals = '0';
  @override
  Widget build(BuildContext context) {
    return Container(
      child: loaded
          ? Scrollbar(
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  reverse: true,
                  // scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(4),
                  shrinkWrap: true,
                  itemCount: widget.todaysActivityList.length,
                  itemBuilder: (BuildContext context, int index) {
                    try {
                      mins = widget.todaysActivityList[index].activityDetails[0].activityDetails[0]
                          .activityDuration
                          .toString();
                      cals = widget.todaysActivityList[index].totalCaloriesBurned.toString();
                      if (widget.todaysActivityList[index].activityDetails[0].activityDetails[0]
                              .activityId ==
                          'activity_103') {
                        mins = ((double.parse(mins)) / 60).toStringAsFixed(1) + ' Mins';
                        if ((double.parse(cals)) > 1) {
                          cals = (double.parse(cals)).toStringAsFixed(0) + ' Cal';
                        } else {
                          cals = '< 1' + ' Cal';
                        }
                      } else {
                        mins = '$mins' + ' Mins';
                        cals = '$cals' + ' Cal';
                      }
                    } catch (e) {
                      mins = '- Mins';
                      cals = '- Cal';
                    }
                    DateTime tempDate = DateFormat("dd-MM-yyyy HH:mm:ss")
                        .parse(widget.todaysActivityList[index].logTime);
                    var formatedDate = DateFormat('hh:mm a').format(tempDate);
                    return Visibility(
                      // visible: widget.todaysActivityList[index].activityDetails[0]
                      //     .activityDetails[0].activityId!='activity_103',
                      child: ListTile(
                        title: Text(
                          camelize(widget.todaysActivityList[index].activityDetails[0]
                                  .activityDetails[0].activityName ??
                              'Unknown Activity'),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                        subtitle: Text(
                          // '${widget.todaysActivityList[index].totalCaloriesBurned ?? '-'} Kcal  |  $mins',
                          "$cals  |  $mins",
                          // 'Light Impact', //L -Light, M- Medium, V-High
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20))),
                              child: Image.network(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFfwLJ_c9qyqUd7-Fa2V5mXqyc20VTWftelVPml48TJupo-TZKbBowiah2awK1s_0kPSQ&usqp=CAU')),
                        ),
                        trailing: Text(
                          'Today ${formatedDate}',
                          // 'Light Impact', //L -Light, M- Medium, V-High
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TodayActivityScreen(
                                      todaysActivityData: widget.todaysActivityList,
                                      otherActivityData: widget.otherActivityList,
                                    )),
                          );
                        },
                      ),
                    );
                  }),
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
