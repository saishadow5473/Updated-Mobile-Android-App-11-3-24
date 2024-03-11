import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/views/dietJournal/activity/edit_activity_log.dart';
import 'package:ihl/views/dietJournal/dietJournal.dart';
import 'package:ihl/views/dietJournal/models/get_todays_food_log_model.dart';
import 'package:intl/intl.dart';
import 'package:strings/strings.dart';

class PreviousActivityScreen extends StatefulWidget {
  List<Activity> otherActivityData;

  PreviousActivityScreen({Key key, this.otherActivityData}) : super(key: key);

  @override
  _PreviousActivityScreenState createState() => _PreviousActivityScreenState();
}

class _PreviousActivityScreenState extends State<PreviousActivityScreen> {
  var _controller = ScrollController();
  bool _isVisible = true;
  List<Activity> otherActivityListTemp = [];
  @override
  void initState() {
    if (widget.otherActivityData != null) {
      if (widget.otherActivityData.length > 1) {
        for (int i = widget.otherActivityData.length - 1; i >= 0; i--) {
          otherActivityListTemp.add(widget.otherActivityData[i]);
        }
        widget.otherActivityData = otherActivityListTemp;
      }
    }
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

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Get.back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: AppColors.bgColorTab,
            child: CustomPaint(
              painter: BackgroundPainter(
                  primary: HexColor('#6F72CA').withOpacity(0.8), secondary: HexColor('#6F72CA')),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 30,
                        child: SizedBox(
                          width: 80,
                          height: 80,
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
                                  icon: Icon(Icons.arrow_back_ios),
                                  color: Colors.white,
                                  onPressed: () => Get.back(),
                                ),
                                SizedBox(
                                  width: ScUtil().setWidth(40),
                                ),
                              ],
                            ),
                            Container(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.only(left: 40),
                      child: Text(
                        'Previous Activities',
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
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                          controller: _controller,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                widget.otherActivityData.length != 0
                                    ? Container(
                                        height: 600,
                                        child: Scrollbar(
                                          child: ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            // reverse: true,
                                            physics: BouncingScrollPhysics(),
                                            padding: EdgeInsets.all(0),
                                            itemCount: widget.otherActivityData.length,
                                            itemBuilder: (BuildContext context, int index) =>
                                                ListTile(
                                              title: Text(
                                                camelize(widget
                                                        .otherActivityData[index]
                                                        .activityDetails[0]
                                                        .activityDetails[0]
                                                        .activityName ??
                                                    'Activity'),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.5),
                                              ),
                                              subtitle: Text(
                                                '${widget.otherActivityData[index].totalCaloriesBurned ?? '-'} Cal  |  ${widget.otherActivityData[index].activityDetails[0].activityDetails[0].activityDuration} Mins',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.5),
                                              ),
                                              leading: ClipRRect(
                                                borderRadius: BorderRadius.circular(8.0),
                                                child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(Radius.circular(20))),
                                                    child: Image.network(
                                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFfwLJ_c9qyqUd7-Fa2V5mXqyc20VTWftelVPml48TJupo-TZKbBowiah2awK1s_0kPSQ&usqp=CAU')),
                                              ),
                                              trailing: Text(
                                                '${DateFormat('dd-MM-yyyy hh:mm a').format(DateFormat("dd-MM-yyyy HH:mm:ss").parse(widget.otherActivityData[index].logTime))}',
                                                // 'Light Impact', //L -Light, M- Medium, V-High
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.5),
                                              ),
                                              onTap: () {
                                                Get.to(EditActivityLogScreen(
                                                  activityId: widget
                                                      .otherActivityData[index]
                                                      .activityDetails[0]
                                                      .activityDetails[0]
                                                      .activityId,
                                                  duration: widget
                                                      .otherActivityData[index]
                                                      .activityDetails[0]
                                                      .activityDetails[0]
                                                      .activityDuration,
                                                  logTime: widget.otherActivityData[index].logTime,
                                                  today: false,
                                                  logId: widget.otherActivityData[index].logId,
                                                ));
                                              },
                                            ),
                                          ),
                                        ),
                                      )
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
                                                  height: 60,
                                                  width: 100,
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'No activity recorded for today',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontFamily: FitnessAppTheme.fontName,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    letterSpacing: 0.5,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                              ],
                            ),
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
    );
  }
}
