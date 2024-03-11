import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../new_design/app/utils/constLists.dart';
import '../../new_design/presentation/Widgets/appBar.dart';
import '../../new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import '../../new_design/presentation/controllers/healthJournalControllers/getTodayLogController.dart';
import '../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../../new_design/presentation/pages/healthProgram/healthProgramTabs.dart';
import '../../new_design/presentation/pages/manageHealthscreens/manageHealthScreentabs.dart';
import 'activity/today_activity.dart';
import 'models/get_todays_food_log_model.dart';
import 'title_widget.dart';
import 'todays_activity_view.dart';
import '../goal_settings/edit_goal_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../utils/screenutil.dart';
import '../../utils/app_colors.dart';
import '../goal_settings/apis/goal_apis.dart';
import 'activity_tile_view.dart';
import 'apis/list_apis.dart';
import 'diet_view.dart';
import 'meal_list_view.dart';
import 'dart:math' as math;

class DietJournalDashNew extends StatefulWidget {
  final String Screen;

  const DietJournalDashNew({Key key, this.Screen}) : super(key: key);

  @override
  State<DietJournalDashNew> createState() => _DietJournalDashNewState();
}

class _DietJournalDashNewState extends State<DietJournalDashNew> {
  List<dynamic> goalLists = [];
  StreamingSharedPreferences preferences;
  List<Activity> todaysActivityData = [];
  List<Activity> otherActivityData = [];
  ListApis listApis = ListApis();
  bool showBanner = false;
  int stepCounterActivityLength = 0;

  void getGoalData() {
    GoalApis.listGoal().then((List value) {
      if (value != null) {
        List<dynamic> activeGoalLists = [];
        for (int i = 0; i < value.length; i++) {
          if (value[i]['goal_status'] == 'active') {
            activeGoalLists.add(value[i]);
          }
        }
        if (mounted) {
          setState(() {
            goalLists = activeGoalLists;
          });
        }
      }
    });
  }

  void getData() async {
    listApis.getUserTodaysFoodLogHistoryApi().then((value) {
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
        if (mounted) {
          setState(() {
            todaysActivityData = todaysActivityData;
            // todaysActivityData = value['activity'];
            // otherActivityData = value['previous_activity'];
          });
        }
      }
    });
  }

  @override
  void initState() {
    getMaintainWeight();
    getGoalData();
    getData();
    super.initState();
  }

  void getMaintainWeight() async {
    StreamingSharedPreferences.instance.then((StreamingSharedPreferences value) {
      if (mounted) {
        setState(() {
          preferences = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.Screen);
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
        onWillPop: () async {
          if (widget.Screen == 'home') {
            Get.off(LandingPage());
          } else {
            // Get.back();
            Get.off(ManageHealthScreenTabs());
            try {
              Get.find<TodayLogController>().onInit();
            } catch (e) {}
          }
          return Get.off(ManageHealthScreenTabs());
        },
        child: CommonScreenForNavigation(
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 19.sp,
                ),
                onPressed: () async {
                  TabBarController _ = Get.find<TabBarController>();

                  if (widget.Screen == 'home') {
                    _.updateSelectedIconValue(value: "Home");
                    Get.off(LandingPage());
                  }
                  if (widget.Screen == "managehealth") {
                    Get.off(ManageHealthScreenTabs(
                      naviBack: 1,
                    ));
                    try {
                      Get.find<TodayLogController>().onInit();
                    } catch (e) {}
                  } else {
                    Get.back();
                  }

                  // Get.back();

                  // Get.offAll(Home());
                  // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => Home(),
                  //     ),
                  //     (Route<dynamic> route) => false);
                }),
            title: Text(
              "Calorie Tracker",
              style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            centerTitle: true,
          ),
          content: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // showBanner
                  //     ? MaterialBanner(
                  //   padding: EdgeInsets.all(20),
                  //   content: Text(
                  //       'Your Calorie requirement is based on your BMR calculated from your information available with us.',
                  //       style: TextStyle(color: Colors.white)),
                  //   leading: Icon(Icons.info_outline, color: Colors.white),
                  //   backgroundColor: AppColors.primaryAccentColor.withOpacity(0.8),
                  //   actions: <Widget>[
                  //     TextButton(
                  //       child: Text('DISMISS', style: TextStyle(color: Colors.white)),
                  //       onPressed: () {
                  //         if (this.mounted) {
                  //           setState(() {
                  //             showBanner = false;
                  //           });
                  //         }
                  //       },
                  //     ),
                  //   ],
                  // )
                  //     : SizedBox.shrink(),
                  // SizedBox(
                  //   height: 30.0,
                  //   child: Align(alignment:Alignment.topLeft,child: Card(child: Text('Today', style: const TextStyle(fontWeight: FontWeight.bold),),)),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Container(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: const [
                            Text(
                              "Today's Overview",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16.5,
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            // Icon(Icons.arrow_drop_down,color:AppColors.primaryColor,size: 30,)
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: MediterranesnDietViewNew(
                        isNavigation: false,
                      )),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: SetGoalNew(
                      activeGoal: goalLists,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => const ViewGoalSettingScreen(
                                goalChangeNavigation: true,
                              ),
                            ),
                            (Route<dynamic> route) => false);
                      },
                    ),
                  ),
                  // SetGoal(
                  //   activeGoal: goalLists,
                  //   onTap: () {
                  //     Navigator.pushAndRemoveUntil(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => ViewGoalSettingScreen(
                  //             goalChangeNavigation: true,
                  //           ),
                  //         ),
                  //             (Route<dynamic> route) => false);
                  //   },
                  // ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    child: FoodTitleView(
                      titleTxt: 'Today\'s Meals',
                      subTxt: '',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    child: MealsListView(Screen: widget.Screen),
                  ),
                  TitleView(
                    titleTxt: 'Today\'s Activity',
                    subTxt: 'Overview',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => TodayActivityScreen(
                                  todaysActivityData: todaysActivityData,
                                  otherActivityData: otherActivityData,
                                )),
                      );
                    },
                  ),
                  todaysActivityData.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: RunningView(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => TodayActivityScreen(
                                    todaysActivityData: todaysActivityData,
                                    otherActivityData: otherActivityData,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : TodaysActivityView(
                          todaysActivityList: todaysActivityData,
                          otherActivityList: otherActivityData),
                  SizedBox(
                    height: 10.h,
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class SetGoalNew extends StatelessWidget {
  final Function onTap;
  final Function onClose;
  final bool curvedBorder;
  final List activeGoal;

  const SetGoalNew({Key key, this.onTap, this.onClose, this.curvedBorder, this.activeGoal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          final GetStorage navi = GetStorage();
          navi.write("setGoalNavigation", true);
          Get.to(CommonScreenForNavigation(
              appBar: AppBar(
                backgroundColor: AppColors.primaryColor,
                centerTitle: true,
                title: Text("Weight Management", style: TextStyle(color: Colors.white)),
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    setGoalTab(true),
                    SizedBox(height: 12.h),
                  ],
                ),
              )));
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(
          //       builder: (BuildContext context) => const ViewGoalSettingScreen(
          //         goalChangeNavigation: false,
          //       ),
          //     ),
          //     (Route<dynamic> route) => false);
        },
        child: Stack(
          children: [
            Card(
              elevation: 3,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.14,
                // width: MediaQuery.of(context).size.width*1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 2.h,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.055,
                          child: Text(
                            "Looking for personalised calorie requirements?",
                            textAlign: TextAlign.left,
                            maxLines: 2,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: ScUtil().setSp(13), //16
                              // letterSpacing: 0.0,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 0.6.h,
                        ),
                        Container(
                          child: Text(
                            activeGoal.isNotEmpty
                                ? "Tap here to view your goal"
                                : "Tap here to set your goal.",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: ScUtil().setSp(11),
                              // letterSpacing: 0.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Transform(transform: Matrix4.rotationY(math.pi),child: Transform.translate(offset: Offset(-150, -20),child:
                    // Transform(transform: Matrix4.rotationY(math.pi),origin:  Offset(80, -100),child:
                    // Container(width:40.w,color:Colors.deepOrangeAccent,child:
                    // Transform(transform: Matrix4.rotationY(math.pi),child: Transform.translate(
                    //     offset: Offset(-150, -20),child: Image(image:AssetImage('newAssets/arrow.png'),fit: BoxFit.cover,width: 150,height: MediaQuery.of(context).size.height*1,)))
                    // Transform(
                    // transform: Matrix4.skewY(0.3),
                    // origin: Offset(0, 0),
                    // child:
                    // AssetImage('newAssets/Icons/target.png')
                  ]),
                ),
              ),
            ),
            Positioned(
                top: -100,
                right: -220,
                bottom: -83,
                child: Transform(
                    transform: Matrix4.rotationY(math.pi),
                    child: Image.asset(
                      'newAssets/arrow.png',
                      width: 200,
                    )))
          ],
        ));
  }
}
