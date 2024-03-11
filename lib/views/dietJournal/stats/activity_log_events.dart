import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:googleapis/admin/reports_v1.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/dietJournal/activity/edit_activity_log.dart';
import 'package:ihl/views/dietJournal/activity/today_activity.dart';

import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:get/get.dart';
import 'package:ihl/views/dietJournal/models/get_activity_log_model.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ActivityLogEvnets extends StatefulWidget {
  List<GetActivityLog> activityData;
  dynamic actvityDetailLen;
  ActivityLogEvnets(this.activityData, this.actvityDetailLen, {Key key})
      : super(key: key);

  @override
  State<ActivityLogEvnets> createState() => _ActivityLogEvnetsState();
}

class _ActivityLogEvnetsState extends State<ActivityLogEvnets> {
  ListApis listApis = ListApis();
  bool isLoading = true;
  dynamic todaysActivityData = [];
  dynamic otherActivityData = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    listApis.getUserTodaysFoodLogHistoryApi().then((value) {
      print('Value ${value}');
      if (value != null) {
        todaysActivityData = value['activity'];
        otherActivityData = value['previous_activity'];

        // todaysActivityData.forEach((element) {
        //   if(element.activityDetails[0]
        //       .activityDetails[0].activityId=='activity_103'){
        //     // todaysActivityData.removeAt(todaysActivityData.indexOf(element));
        //     stepCounterActivityLength++;
        //   }
        // });
        if (this.mounted) {
          setState(() {
            todaysActivityData = todaysActivityData;
            // todaysActivityData = value['activity'];
            // otherActivityData = value['previous_activity'];
          });
        }
      }
    });
  }

  activityLogDate(indexNum) {
    log(widget.activityData[indexNum].activityLogTime);
    DateTime tempDate = DateFormat("dd-MM-yyyy HH:mm:ss")
        .parse(widget.activityData[indexNum].activityLogTime);
    print(tempDate);
    var formatedDate = DateFormat('dd-MM-yyyy hh:mm a').format(tempDate);
    String time =
        widget.activityData[indexNum].activityLogTime.substring(11, 16);
    String date =
        widget.activityData[indexNum].activityLogTime.substring(0, 10);
    TimeOfDay timeOnly = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    var formattedTime = localizations.formatTimeOfDay(timeOnly);
    return "$date $formatedDate";
  }

  @override
  Widget build(BuildContext context) {
    return widget.activityData.length != 0 && widget.actvityDetailLen != 0
        ? ListView.builder(
            itemCount: widget.activityData.length,
            itemBuilder: (BuildContext context, int index) {
              return widget.activityData[index].activityDetails.length != 0
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xff6e72cb),
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                widget.activityData[index].activityDetails[0]
                                    .activityDetails[0].activityName,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    //fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5),
                              ),
                              subtitle: Text(activityLogDate(index),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      //fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5)),
                              onTap: () {
                                Get.to(EditActivityLogScreen(
                                  activityId: widget
                                      .activityData[index]
                                      .activityDetails[0]
                                      .activityDetails[0]
                                      .activityId,
                                  duration: widget
                                      .activityData[index]
                                      .activityDetails[0]
                                      .activityDetails[0]
                                      .activityDuration,
                                  logTime: widget
                                      .activityData[index].activityLogTime,
                                  logId: widget.activityData[index].activityLogId,
                                  today: false,
                                ));
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      height: 1,
                    );
            })
        : Container(
            height: 350,
            width: double.infinity,
            margin: const EdgeInsets.all(10.0),
            child: Card(
                color: CardColors.bgColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://i.postimg.cc/prP1hLtK/pngaaa-com-4773437.png',
                      height: 5.h,
                      width: 20.w,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No activity recorded for today',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp,
                        letterSpacing: 0.5,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: ScUtil().setHeight(20)),
                    FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TodayActivityScreen(
                                    todaysActivityData: todaysActivityData,
                                    otherActivityData: otherActivityData,
                                  )),
                        );
                      },
                      label: Text(
                        "Log Activities",
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 18.sp,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                )),
          );
  }
}
