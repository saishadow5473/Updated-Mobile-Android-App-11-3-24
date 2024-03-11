import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/activity/today_activity.dart';
import 'package:ihl/views/dietJournal/activity_tile_view.dart';
import 'package:ihl/views/dietJournal/apis/list_apis.dart';
import 'package:ihl/views/dietJournal/diet_view.dart';
import 'package:ihl/views/dietJournal/meal_list_view.dart';
import 'package:ihl/views/dietJournal/models/get_todays_food_log_model.dart';
import 'package:ihl/views/dietJournal/stats/caloriesStats.dart';
import 'package:ihl/views/dietJournal/title_widget.dart';
import 'package:ihl/views/dietJournal/todays_activity_view.dart';
import 'package:ihl/views/goal_settings/edit_goal_screen.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../../new_design/presentation/pages/home/home_view.dart';
import '../../utils/screenutil.dart';
import '../goal_settings/apis/goal_apis.dart';

class DietJournalDash extends StatefulWidget {
  final String Screen;
  DietJournalDash({Key key, this.Screen}) : super(key: key);
  @override
  _DietJournalDashState createState() => _DietJournalDashState();
}

class _DietJournalDashState extends State<DietJournalDash> {
  StreamingSharedPreferences preferences;
  List<Activity> todaysActivityData = [];
  List<Activity> otherActivityData = [];
  List<dynamic> goalLists = [];
  ListApis listApis = ListApis();
  bool showBanner = false;
  var stepCounterActivityLength = 0;
  void getGoalData() {
    GoalApis.listGoal().then((value) {
      if (value != null) {
        List<dynamic> activeGoalLists = [];
        for (int i = 0; i < value.length; i++) {
          if (value[i]['goal_status'] == 'active') {
            activeGoalLists.add(value[i]);
          }
        }
        if (mounted)
          setState(() {
            goalLists = activeGoalLists;
          });
      }
    });
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

  @override
  void initState() {
    getMaintainWeight();
    getGoalData();
    getData();
    super.initState();
  }

  void getMaintainWeight() async {
    StreamingSharedPreferences.instance.then((value) {
      if (this.mounted) {
        setState(() {
          preferences = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return WillPopScope(
      onWillPop: () async{
        if (widget.Screen == 'home' || widget.Screen == 'manageHealth') {
          Get.back();
        } else {
          Get.off(LandingPage());
        }
        return null;
      },
      child: DietJournalUI(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                if (widget.Screen == 'home' || widget.Screen == 'manageHealth') {
                  Get.back();
                } else {
                  Get.off(LandingPage());
                }

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
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              showBanner
                  ? MaterialBanner(
                      padding: EdgeInsets.all(20),
                      content: Text(
                          'Your Calorie requirement is based on your BMR calculated from your information available with us.',
                          style: TextStyle(color: Colors.white)),
                      leading: Icon(Icons.info_outline, color: Colors.white),
                      backgroundColor: AppColors.primaryAccentColor.withOpacity(0.8),
                      actions: <Widget>[
                        TextButton(
                          child: Text('DISMISS', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            if (this.mounted) {
                              setState(() {
                                showBanner = false;
                              });
                            }
                          },
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 30.0,
              ),
              TitleView(
                titleTxt: 'Today\'s Overview',
                subTxt: 'More',
                onTap: () {
                  //Get.to(DietJournalDashboard());
                  // Get.to(CalorieGraph());
                  Get.to(CaloriesStats());
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: MediterranesnDietView(
                  isNavigation: false,
                ),
              ),
              // preferences != null
              //     ? PreferenceBuilder<bool>(
              //         preference: preferences.getBool('maintain_weight',
              //             defaultValue: false),
              //         builder: (BuildContext context, bool maintainWeight) {
              //           return maintainWeight
              //               ? SetGoal(
              //             onTap: () {
              //               Navigator.pushAndRemoveUntil(
              //                   context,
              //                   MaterialPageRoute(
              //                     builder: (context) =>
              //                         ViewGoalSettingScreen(
              //                           goalChangeNavigation: true,
              //                         ),
              //                   ),
              //                       (Route<dynamic> route) => false);
              //             },
              //           )
              //               : SizedBox.shrink();
              //         })
              //     : SizedBox.shrink(),
              SetGoal(
                activeGoal: goalLists,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewGoalSettingScreen(
                          goalChangeNavigation: true,
                        ),
                      ),
                      (Route<dynamic> route) => false);
                },
              ),
              FoodTitleView(
                titleTxt: 'Today\'s Meals',
                subTxt: '',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: MealsListView(),
              ),
              TitleView(
                titleTxt: 'Today\'s Activity',
                subTxt: 'Details',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TodayActivityScreen(
                              todaysActivityData: todaysActivityData,
                              otherActivityData: otherActivityData,
                            )),
                  );
                },
              ),
              todaysActivityData.length == 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: RunningView(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TodayActivityScreen(
                                todaysActivityData: todaysActivityData,
                                otherActivityData: otherActivityData,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : TodaysActivityView(
                      todaysActivityList: todaysActivityData, otherActivityList: otherActivityData),
            ],
          ),
        ),
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon, this.onTap});
  final String title;
  final IconData icon;
  final Function onTap;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Breakfast', icon: FontAwesomeIcons.carrot),
  const Choice(title: 'Lunch', icon: Icons.set_meal),
  const Choice(title: 'Dinner', icon: Icons.rice_bowl),
  const Choice(title: 'Snacks', icon: FontAwesomeIcons.pizzaSlice),
];

class SelectCard extends StatelessWidget {
  const SelectCard({Key key, this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.labelLarge;
    return Card(
      color: CardColors.bgColor,
      elevation: 4,
      child: InkWell(
        onTap: () {
          print("tapped");
        },
        child: Center(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            Expanded(
              child: Icon(choice.icon, size: 30.0, color: textStyle.color),
            ),
            Text(choice.title, style: textStyle),
          ]),
        ),
      ),
    );
  }
}
