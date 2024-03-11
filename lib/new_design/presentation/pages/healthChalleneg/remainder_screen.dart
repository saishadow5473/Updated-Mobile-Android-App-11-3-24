import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:get/get.dart';
import '../../../../constants/api.dart';
import '../../../../health_challenge/models/challenge_detail.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_text_styles.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../../health_challenge/models/enrolled_challenge.dart';

import '../../../app/utils/appText.dart';
import '../dashboard/common_screen_for_navigation.dart';


class SetRemainderScreen extends StatelessWidget {
  ChallengeDetail challengeDetail;
  final List<String> sessionList;
  List<EnrolledChallenge> enList;

  SetRemainderScreen({Key key,this.sessionList,this.enList,this.challengeDetail}) : super(key: key);

  // SetRemainderScreen({Key key, this.sessionList, this.challengeDetail,this.enList}) : super(key: key);
  // final ClockController _calController = Get.put(ClendarController());
  @override
  Widget build(BuildContext context) {

    TimeOfDay selectedTime = TimeOfDay.now();

    return CommonScreenForNavigation(
        resizeToAvoidBottomInset: true,
        contentColor: "true",
        appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                Get.back();
              }, //replaces the screen to Main dashboard
              color: Colors.white,
            ),
            title: Text(
              AppTexts.setAlarmText,
              style: AppTextStyles.appBarText,
            ),
            backgroundColor: AppColors.primaryColor),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 100.w,
            height: 100.h,
            child: Column(
              children: [
                 Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Day ${challengeDetail.challengeDurationDays}"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Visibility(
                    visible: sessionList.isNotEmpty,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                      child: SizedBox(
                        height: 6.h,
                        // width: 90.w,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: sessionList.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              return GestureDetector(
                                onTap: () {
                                  // _selectTime(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 6.w),
                                  child: Text(sessionList[index],
                                      style: AppTextStyles.fontSize14b4RegularStyle),
                                ),
                              );
                            }),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TimePickerDialog(

                    initialTime: selectedTime,
                  ),
                  // child: ClockCustomizer((ClockModel model) => AnalogClock(model)),
                ),
                Row(
                  children: [
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                      child: TextButton(child: Text("Cancel"), onPressed: null),
                    ),
                    TextButton(
                      child: Text("Set"),
                      onPressed: () async{
                        print(selectedTime);
                        // FlutterAlarmClock.createAlarm(1, 15, title: "");
                        // List<Map<String, dynamic>> myList = [{'time':'03:00 PM','title':'Set reminder title'}];
                        //
                        // var _s ="{\"feature_setting\":{\"health_jornal\":true,\"challenges\":true,\"news_letter\":true,\"ask_ihl\":true,\"hpod_locations\":false,\"teleconsultation\":false,\"online_classes\":false,\"my_vitals\":true,\"step_counter\":false,\"heart_health\":true,\"set_your_goals\":false,\"diabetics_health\":false,\"personal_data\":true,\"health_tips\":true}}";
                        // var _p = jsonDecode(_s.replaceAll("&#39;", "\""));
                        // print(_p.toString().contains('reminder'));
                        // if(_p.toString().contains('reminder')){
                        //   print('yes');
                        //   Map<String, dynamic> myMap = {'time':'03:00 PM','title':'Set reminder title'};
                        //   myList.add(myMap);
                        //   print(myList);
                        // }
                        // else{
                        //   print('no');
                        //   _p['reminder'] = myList;
                        // }
                        // print(_p);
                        // var response = await Dio()
                        //     .post('${API.iHLUrl}/healthchallenge/edit_reminder_detail', data: {
                        //   "enrollment_id": enList[0].enrollmentId,
                        //   "challenge_id": challengeDetail.challengeId,
                        //   "reminder_detail": jsonEncode(myList)
                        // });
                        // print(response.data);
                      },
                    ),
                    SizedBox(width: 8.w)
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
class TimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  TimePickerDialog({ this.initialTime});

  @override
  _TimePickerDialogState createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {
   TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 200,
            child: TimePicker(
              selectedTime: selectedTime,
              onTimeChanged: (TimeOfDay newTime) {
                setState(() {
                  selectedTime = newTime;
                });
              },
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(selectedTime); // Return the selected time
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

class TimePicker extends StatelessWidget {
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  TimePicker({ this.selectedTime,  this.onTimeChanged});

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Theme.of(context).brightness,
      ),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: DateTime(2020, 1, 1, selectedTime.hour, selectedTime.minute),
        onDateTimeChanged: (DateTime dateTime) {
          onTimeChanged(TimeOfDay(hour: dateTime.hour, minute: dateTime.minute));
        },
      ),
    );
  }
}
