import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/controllers/healthJournalControllers/getTodayLogController.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/dietJournal.dart';
import 'package:ihl/views/dietJournal/dietJournalNew.dart';
import 'package:ihl/views/dietJournal/title_widget.dart';
import 'package:ihl/views/goal_settings/apis/goal_apis.dart';
import 'package:ihl/views/goal_settings/goal_setting_screen.dart';
import 'package:ihl/views/goal_settings/view_expired_goal_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../../new_design/presentation/pages/healthProgram/healthProgramTabs.dart';
import '../../new_design/presentation/pages/healthProgram/myGoalScreen.dart';
import '../../new_design/presentation/pages/manageHealthscreens/manageHealthScreentabs.dart';

class ViewGoalSettingScreen extends StatefulWidget {
  final goalChangeNavigation;

  const ViewGoalSettingScreen({this.goalChangeNavigation});

  @override
  _ViewGoalSettingScreenState createState() => _ViewGoalSettingScreenState();
}

class _ViewGoalSettingScreenState extends State<ViewGoalSettingScreen> {
  StreamingSharedPreferences preferences;
  List<dynamic> goalLists = [];
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    getData();
    StreamingSharedPreferences.instance.then((value) {
      setState(() {
        preferences = value;
      });
    });
  }

  String goalType(String currentWeight, String targetWeight) {
    if (double.tryParse(currentWeight) > double.tryParse(targetWeight)) {
      return 'Lose Weight';
    } else if (double.tryParse(currentWeight) < double.tryParse(targetWeight)) {
      return 'Gain Weight';
    } else {
      return 'Maintain Weight';
    }
  }

  Future<Map> sendDataToAPI(String goalID) async {
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    return {"ihl_user_id": iHLUserId, "goal_id": goalID, "goal_status": "inactive"};
  }

  void getData() {
    GoalApis.listGoal().then((value) {
      if (value != null) {
        List<dynamic> activeGoalLists = [];
        for (int i = 0; i < value.length; i++) {
          if (value[i]['goal_status'] == 'active') {
            activeGoalLists.add(value[i]);
          }
        }
        setState(() {
          goalLists = activeGoalLists;
          loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () => widget.goalChangeNavigation.toString() == 'true'
          ? Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ManageHealthScreenTabs()),
              (Route<dynamic> route) => false)
          : Get.to(ManageHealthScreenTabs()),
      child: DietJournalUI(
        topColor: Colors.green,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => widget.goalChangeNavigation.toString() == 'true'
                  ? Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => ManageHealthScreenTabs()),
                      (Route<dynamic> route) => false)
                  :
                  //  Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => HomeScreen(introDone: true)),
                  //     (Route<dynamic> route) => false)
                  Get.to(ManageHealthScreenTabs())),
          title: Text(
            "Weight Management",
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 50.0,
              ),
              TitleView(
                titleTxt: 'Your Active Goal:',
                subTxt: 'View expired',
                color: Colors.green,
                onTap: () {
                  Get.to(ViewExpiredGoalSettingScreen());
                },
              ),
              SizedBox(
                height: 30.0,
              ),
              if (loaded)
                goalLists.isNotEmpty
                    ? Container(
                        height: 500,
                        child: ListView.builder(
                            padding: EdgeInsets.all(0),
                            itemCount: goalLists.length,
                            itemBuilder: (BuildContext context, int i) => Container(
                                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    color: Colors.green,
                                    elevation: 10,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        SizedBox(height: 16),
                                        ListTile(
                                          leading: goalType(goalLists[i]['weight'],
                                                      goalLists[i]['target_weight']) ==
                                                  'Lose Weight'
                                              ? Icon(Icons.trending_down_rounded,
                                                  size: 70, color: Colors.white)
                                              : goalType(goalLists[i]['weight'],
                                                          goalLists[i]['target_weight']) ==
                                                      'Gain Weight'
                                                  ? Icon(Icons.trending_up_rounded,
                                                      color: Colors.white, size: 70)
                                                  : Icon(Icons.trending_neutral_rounded,
                                                      color: Colors.white, size: 70),
                                          title: Text(
                                            goalType(goalLists[i]['weight'],
                                                goalLists[i]['target_weight']),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${goalLists[i]['weight']} Kgs  ➡️  ${goalLists[i]['target_weight']} Kgs\nDaily Intake - ${goalLists[i]['target_calorie'] ?? 'NA'} Cal\n${goalLists[i]['goal_date'] != '' || goalLists[i]['goal_date'] != null ? 'By ${goalLists[i]['goal_date'] ?? '-'}' : ''}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        ButtonBar(
                                          children: <Widget>[
                                            TextButton(
                                              child: const Text('Delete Goal',
                                                  style: TextStyle(color: Colors.white)),
                                              onPressed: () async {
                                                AwesomeDialog(
                                                    context: context,
                                                    animType: AnimType.TOPSLIDE,
                                                    headerAnimationLoop: true,
                                                    dialogType: DialogType.WARNING,
                                                    dismissOnTouchOutside: true,
                                                    title: 'Confirm ?',
                                                    desc: 'this action will delete your Goal',
                                                    btnOkOnPress: () async {
                                                      SharedPreferences prefs =
                                                          await SharedPreferences.getInstance();
                                                      Get.snackbar('Goal deleted!',
                                                          'Your current goal has been deleted.',
                                                          icon: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Icon(
                                                                  Icons.check_circle_outline,
                                                                  color: Colors.white)),
                                                          margin: EdgeInsets.all(20)
                                                              .copyWith(bottom: 40),
                                                          backgroundColor: Colors.blue,
                                                          colorText: Colors.white,
                                                          duration: Duration(seconds: 5),
                                                          snackPosition: SnackPosition.BOTTOM);
                                                      var goalData = await sendDataToAPI(
                                                          goalLists[i]['goal_id']);
                                                      GoalApis.editGoal(goalData).then((value) {
                                                        if (value != null) {
                                                          preferences.setBool(
                                                              'maintain_weight', true);
                                                          prefs.remove('daily_target');

                                                          setState(() {
                                                            goalLists.removeAt(i);
                                                          });
                                                          try {
                                                            Get.find<TodayLogController>().onInit();
                                                          } catch (e) {
                                                            Get.put(TodayLogController());
                                                          }
                                                        } else {
                                                          Get.snackbar('Goal not deleted!',
                                                              'Encountered some error. Please try again',
                                                              icon: Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(8.0),
                                                                  child: Icon(Icons.cancel_outlined,
                                                                      color: Colors.white)),
                                                              margin: EdgeInsets.all(20)
                                                                  .copyWith(bottom: 40),
                                                              backgroundColor: Colors.redAccent,
                                                              colorText: Colors.white,
                                                              duration: Duration(seconds: 5),
                                                              snackPosition: SnackPosition.BOTTOM);
                                                        }
                                                      });
                                                      print('delete goal');
                                                    },
                                                    btnCancelOnPress: () {
                                                      // Get.back();
                                                    },
                                                    buttonsTextStyle: TextStyle().copyWith(
                                                        color: FitnessAppTheme.white,
                                                        fontWeight: FontWeight.normal),
                                                    btnCancelText: 'Go Back',
                                                    btnOkText: 'Confirm',
                                                    btnCancelColor: Colors.green,
                                                    btnOkColor: Colors.red,
                                                    // btnOkIcon: Icons.check_circle,
                                                    // btnCancelIcon: Icons.check_circle,
                                                    onDismissCallback: (_) {
                                                      debugPrint('Dialog Dissmiss from callback');
                                                    }).show();
                                              },
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                  foregroundColor: Colors.blue,
                                                  backgroundColor: Colors.white),
                                              child: const Text('Edit Goal',
                                                  style: TextStyle(color: Colors.blue)),
                                              onPressed: () {
                                                print('hi');
                                                Get.to(GoalSettingScreen(
                                                  goalId: goalLists[i]['goal_id'],
                                                  goalType: goalLists[i]['goal_type'],
                                                ));
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                      )
                    : Container(
                        height: 350,
                        width: double.infinity,
                        margin: const EdgeInsets.all(40.0),
                        child: Card(
                          elevation: 2,
                          shadowColor: FitnessAppTheme.grey,
                          borderOnForeground: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              side: BorderSide(
                                width: 2,
                                color: FitnessAppTheme.nearlyWhite,
                              )),
                          color: FitnessAppTheme.white,
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
                                'No Goal has been set.\nTry Setting Healthy Goal!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 10),
                              TextButton(
                                child: Text(
                                  'Set your Goal !',
                                  style:
                                      TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                                onPressed: () => Get.to(MyGoalScreen(
                                  fromManageHealth: true,
                                )),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.all(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
              else
                CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
