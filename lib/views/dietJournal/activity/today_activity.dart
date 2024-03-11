import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../constants/routes.dart';
import '../../../new_design/presentation/pages/manageHealthscreens/healthJournalScreens/activityLog/activityLog1.dart';
import '../../../painters/backgroundPanter.dart';
import '../../../utils/ScUtil.dart';
import '../../../utils/app_colors.dart';
import 'edit_activity_log.dart';
import 'previous_activity.dart';
import '../models/get_todays_food_log_model.dart';
import '../title_widget.dart';
import 'package:intl/intl.dart';
import 'package:strings/strings.dart';

import '../dietJournalNew.dart';
import 'activity_list_view.dart';

RxBool gNavigate = true.obs;

class TodayActivityScreen extends StatefulWidget {
  final List<Activity> todaysActivityData;
  final List<Activity> otherActivityData;

  const TodayActivityScreen({Key key, this.todaysActivityData, this.otherActivityData})
      : super(key: key);

  @override
  _TodayActivityScreenState createState() => _TodayActivityScreenState();
}

class _TodayActivityScreenState extends State<TodayActivityScreen> {
  ScrollController _controller = ScrollController();
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels > 0) {
          if (_isVisible) {
            setState(() {
              _isVisible = false;
            });
          }
        }
      } else {
        if (!_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      }
    });
  }

  num calculateTotalcalories() {
    int activitykCal = 0;
    for (var element in widget.todaysActivityData) {
      if (element.totalCaloriesBurned != '0' && element.totalCaloriesBurned != null) {
        activitykCal = activitykCal + (double.parse(element.totalCaloriesBurned)).toInt();
      }
    }
    return activitykCal;
  }

  String mins = '0';
  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Get.offAll(DietJournalNew(),
            predicate: (Route route) => Get.currentRoute == Routes.Home, popGesture: true);
      },
      child: Scaffold(
          body: SafeArea(
            child: Container(
              color: AppColors.bgColorTab,
              child: CustomPaint(
                painter: BackgroundPainter(
                    primary: HexColor('#6F72CA').withOpacity(0.8), secondary: HexColor('#6F72CA')),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: [
                          Positioned(
                            top: 0,
                            right: 30,
                            child: SizedBox(
                              width: ScUtil().setWidth(80),
                              height: ScUtil().setHeight(60),
                              child: Image.asset("assets/images/diet/runner.png"),
                            ),
                          ),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios),
                                      color: Colors.white,
                                      onPressed: () => Get.offAll(DietJournalNew(),
                                          predicate: (Route route) =>
                                              Get.currentRoute == Routes.Home),
                                    ),
                                    SizedBox(
                                      width: ScUtil().setWidth(40),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: ScUtil().setHeight(20),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: ScUtil().setWidth(40)),
                          child: Text(
                            'Activities',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScUtil().setSp(32.0),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(ScUtil().setSp(6)),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(ScUtil().setSp(10)),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: ScUtil().setHeight(12)),
                                    child: const FoodTitleView(
                                      titleTxt: 'Summary of Today',
                                      subTxt: '',
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: ScUtil().setSp(12)),
                                    child: Card(
                                      elevation: 2,
                                      shadowColor: FitnessAppTheme.nearlyWhite,
                                      borderOnForeground: true,
                                      shape: const RoundedRectangleBorder(
                                          // borderRadius: BorderRadius.all(
                                          //   Radius.circular(10),
                                          // ),
                                          side: BorderSide(
                                        width: 1,
                                        color: FitnessAppTheme.nearlyWhite,
                                      )),
                                      color: FitnessAppTheme.white,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding:  EdgeInsets.all(12.sp),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Burned",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: ScUtil().setSp(16),
                                                  ),
                                                ),
                                                Text(
                                                  '${calculateTotalcalories()} Cal',
                                                  style: TextStyle(
                                                    color: HexColor('#6F72CA'),
                                                    fontSize: ScUtil().setSp(20),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:  EdgeInsets.all(12.sp),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Logged",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: ScUtil().setSp(16),
                                                  ),
                                                ),
                                                Text(
                                                  "${widget.todaysActivityData.length} ${widget.todaysActivityData.length > 1 ? "Activities" : "Activity"}",
                                                  style: TextStyle(
                                                    color: HexColor('#6F72CA'),
                                                    fontSize: ScUtil().setSp(20),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: ScUtil().setHeight(8), bottom: ScUtil().setHeight(8)),
                                    child: FoodTitleView(
                                      titleTxt: 'Activity Recorded Today',
                                      subTxt: 'View Previous',
                                      onTap: () => Get.off(PreviousActivityScreen(
                                          otherActivityData: widget.otherActivityData)),
                                    ),
                                  ),
                                  widget.todaysActivityData.isNotEmpty
                                      ? SizedBox(
                                          height: ScUtil.screenHeight > 600
                                              ? ScUtil().setHeight(250)
                                              : ScUtil().setHeight(200),
                                          child: Scrollbar(
                                            child: ListView.builder(
                                                // physics:
                                                //     NeverScrollableScrollPhysics(),
                                                // reverse: true,
                                                padding: const EdgeInsets.all(0),
                                                itemCount: widget.todaysActivityData.length,
                                                itemBuilder: (BuildContext context, int ind) {
                                                  int index =
                                                      widget.todaysActivityData.length - 1 - ind;
                                                  mins = widget
                                                      .todaysActivityData[index]
                                                      .activityDetails[0]
                                                      .activityDetails[0]
                                                      .activityDuration
                                                      .toString();
                                                  // mins = widget.todaysActivityList[index].activityDetails[0].activityDetails[0].activityDuration.toString();
                                                  if (widget
                                                          .todaysActivityData[index]
                                                          .activityDetails[0]
                                                          .activityDetails[0]
                                                          .activityId ==
                                                      'activity_103') {
                                                    mins =
                                                        '${((double.parse(mins)) / 60).toStringAsFixed(1)} Mins';
                                                  } else {
                                                    mins = '$mins Mins';
                                                  }
                                                  DateTime tempDate =
                                                      DateFormat("dd-MM-yyyy HH:mm:ss").parse(
                                                          widget.todaysActivityData[index].logTime);
                                                  String formatedDate =
                                                      DateFormat('hh:mm a').format(tempDate);
                                                  return Visibility(
                                                    // visible: widget.todaysActivityData[index].activityDetails[0]
                                                    //     .activityDetails[0].activityId!='activity_103',

                                                    child: ListTile(
                                                      title: Text(
                                                        camelize(widget
                                                                .todaysActivityData[index]
                                                                .activityDetails[0]
                                                                .activityDetails[0]
                                                                .activityName ??
                                                            'Activity'),
                                                        style: TextStyle(
                                                            fontSize: ScUtil().setSp(12),
                                                            fontWeight: FontWeight.w600,
                                                            letterSpacing: 0.5),
                                                      ),
                                                      subtitle: Text(
                                                        // '${widget.todaysActivityData[index].totalCaloriesBurned ?? '-'} Kcal  |  ${widget.todaysActivityData[index].activityDetails[0].activityDetails[0].activityDuration} Mins',
                                                        '${widget.todaysActivityData[index].totalCaloriesBurned ?? '-'} Kcal  |  $mins',
                                                        style: TextStyle(
                                                            fontSize: ScUtil().setSp(10),
                                                            fontWeight: FontWeight.w600,
                                                            letterSpacing: 0.5),
                                                      ),
                                                      leading: ClipRRect(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        child: Container(
                                                            height: ScUtil().setHeight(40),
                                                            width: ScUtil().setWidth(40),
                                                            decoration: const BoxDecoration(
                                                                borderRadius: BorderRadius.all(
                                                                    Radius.circular(20))),
                                                            child: Image.network(
                                                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFfwLJ_c9qyqUd7-Fa2V5mXqyc20VTWftelVPml48TJupo-TZKbBowiah2awK1s_0kPSQ&usqp=CAU')),
                                                      ),
                                                      trailing: Text(
                                                        'Today ${formatedDate.toString()}',
                                                        // 'Light Impact', //L -Light, M- Medium, V-High
                                                        style: TextStyle(
                                                            fontSize: ScUtil().setSp(11),
                                                            fontWeight: FontWeight.w600,
                                                            letterSpacing: 0.5),
                                                      ),
                                                      onTap: () {
                                                        if (widget
                                                                .todaysActivityData[index]
                                                                .activityDetails[0]
                                                                .activityDetails[0]
                                                                .activityId ==
                                                            'activity_103') {
                                                          Get.snackbar('Not Editable!',
                                                              '${camelize('This')} is an Auto Logged Activity.',
                                                              icon: const Padding(
                                                                  padding: EdgeInsets.all(8.0),
                                                                  child: Icon(
                                                                      Icons.warning_amber_sharp,
                                                                      color: Colors.white)),
                                                              margin: const EdgeInsets.all(20)
                                                                  .copyWith(bottom: 40),
                                                              backgroundColor: HexColor('#6F72CA'),
                                                              colorText: Colors.white,
                                                              duration: const Duration(seconds: 3),
                                                              snackPosition: SnackPosition.BOTTOM);
                                                        } else {
                                                          Get.to(
                                                            EditActivityLogScreen(
                                                              activityId: widget
                                                                  .todaysActivityData[index]
                                                                  .activityDetails[0]
                                                                  .activityDetails[0]
                                                                  .activityId,
                                                              duration: widget
                                                                  .todaysActivityData[index]
                                                                  .activityDetails[0]
                                                                  .activityDetails[0]
                                                                  .activityDuration,
                                                              logTime: widget
                                                                  .todaysActivityData[index]
                                                                  .logTime,
                                                              today: true,
                                                              logId: widget
                                                                  .todaysActivityData[index].logId
                                                                  .replaceRange(0, 1, ""),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  );
                                                }),
                                          ),
                                        )
                                      : Container(
                                          height: ScUtil.screenHeight > 600
                                              ? ScUtil().setHeight(205)
                                              : ScUtil().setHeight(205),
                                          width: double.infinity,
                                          margin: const EdgeInsets.all(10.0),
                                          child: Card(
                                            elevation: 2,
                                            shadowColor: FitnessAppTheme.nearlyWhite,
                                            borderOnForeground: true,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(4),
                                                ),
                                                side: BorderSide(
                                                  width: 2,
                                                  color: FitnessAppTheme.nearlyWhite,
                                                )),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Image.network(
                                                  'https://i.postimg.cc/prP1hLtK/pngaaa-com-4773437.png',
                                                  height: ScUtil().setHeight(60),
                                                  width: ScUtil().setWidth(100),
                                                ),
                                                SizedBox(
                                                  height: ScUtil().setHeight(10),
                                                ),
                                                Text(
                                                  'No activity recorded yet for today!',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontFamily: FitnessAppTheme.fontName,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: ScUtil().setSp(15),
                                                    letterSpacing: 0.5,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Visibility(
            visible: _isVisible,
            child: FloatingActionButton.extended(
                onPressed: () {
                  Get.to(ActivityLandingScreen(todayLogList: widget.todaysActivityData));
                },
                // backgroundColor: HexColor('#1E1466'),
                backgroundColor: HexColor('#6F72CA'), //HexColor('#6F72CA').withOpacity(0.9),
                label: Text(
                    widget.todaysActivityData.isNotEmpty ? 'Add Activity' : 'Start Logging !',
                    style:
                        const TextStyle(fontWeight: FontWeight.w600, color: FitnessAppTheme.white)),
                icon: const Icon(Icons.run_circle, color: FitnessAppTheme.white)),
          )),
    );
  }
}
