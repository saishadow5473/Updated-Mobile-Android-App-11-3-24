import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/goal_settings/apis/goal_apis.dart';
import 'package:ihl/views/goal_settings/goal_setting_screen.dart';
import 'package:ihl/views/dietJournal/title_widget.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/commonUi.dart';

class ViewExpiredGoalSettingScreen extends StatefulWidget {
  @override
  _ViewExpiredGoalSettingScreenState createState() => _ViewExpiredGoalSettingScreenState();
}

class _ViewExpiredGoalSettingScreenState extends State<ViewExpiredGoalSettingScreen> {
  List<dynamic> goalLists = [];
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    getData();
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

  void getData() {
    GoalApis.listGoal().then((value) {
      if (value != null) {
        List<dynamic> inactiveGoalLists = [];
        for(int i=0;i<value.length;i++){
          if(value[i]['goal_status']!='active'){
            inactiveGoalLists.add(value[i]);
          }
        }
        setState(() {
          goalLists = inactiveGoalLists;
          loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DietJournalUI(
      topColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          color: Colors.white,
            icon: Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
        title: Text(
          "Your Expired Goal",
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500,color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
          children: [

            if (loaded)
              goalLists.isNotEmpty
                  ? Container(
                    height: MediaQuery.of(context).size.height*1,
                    child: ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount: goalLists.length,
              itemBuilder: (BuildContext context, int i) =>Container(
                        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: Colors.grey,
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
                                  '${goalLists[i]['weight']} Kgs  ➡️  ${goalLists[i]['target_weight']} Kgs\nDaily Intake - ${goalLists[i]['target_calorie']??'NA'} Cal\n${goalLists[i]['goal_date']!=''?'By ${goalLists[i]['goal_date']??'-'}':''}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(height:20),
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
                              'No Goals has been expired.\nTry Achevieing your Set Goal, if you did not!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                letterSpacing: 0.5,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
            else
               Padding(
                 padding: const EdgeInsets.all(10.0),
                 child: CircularProgressIndicator(),
               ),
          ],
        ),
    );
  }
}
