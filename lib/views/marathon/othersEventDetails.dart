import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/repositories/marathon_event_api.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/home_screen.dart';
import 'package:ihl/views/marathon/marathon_details.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../new_design/presentation/pages/home/home_view.dart';

class OthersDetail extends StatefulWidget {
  OthersDetail({this.eventDetailList, this.userEnrolledMap});
  final eventDetailList;
  final userEnrolledMap;
  @override
  _OthersDetailState createState() => _OthersDetailState();
}

class _OthersDetailState extends State<OthersDetail> {
  // await trackProgressApi(event_id: event_id,ihl_user_id:event_iHL_User_Id,steps: todaySteps.value.toString(),distance_covered: kms().toString(),event_status: status,start_time: eStartTime,progress_time: eProgressTime);

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  var event_id;
  // var totalDistance;
  // var variantsList = [];
  var event_iHL_User_Id;
  var steps;
  var event_start_date;

  getDetails() async {
    var prefs = await SharedPreferences.getInstance();
    var data1 = prefs.get('data');
    Map res = jsonDecode(data1);
    event_iHL_User_Id = res['User']['id'];
    event_id = widget.eventDetailList[0]['event_id'];
    totalDistance =
        double.parse(widget.userEnrolledMap['event_varient'].toString().replaceAll('Km', ''));
    var variantsList1 = widget.eventDetailList[0]['event_varients'];
    variantsList1.forEach((element) {
      variantsList.add(double.parse(element.toString().replaceAll('Km', '')));
    });
    print(variantsList);
    event_start_date = widget.eventDetailList[0]['event_start_time'].toString();
    // steps =
  }

  static double kmPerStep = 0.000762;
  static kms(km) {
    var steps;
    // steps = steps.toString();
    // double toSend = _stepCountValue * kmPerStep * 100;
    if (km != null && km != 'null' && km != '') {
      double k = double.parse(km);
      // double toSend = steps * kmPerStep * 100;
      steps = (k) / (100 * kmPerStep);
      // int clean = steps;
      steps = steps * 100;
      return (steps.toInt());
    }
  }

  @override
  final distanceController = TextEditingController();
  final timeController = TextEditingController();

  static getProgresstimes(hour, min, sec) {
    if (hour.length < 2) {
      hour = '0' + hour;
    }
    if (min.length < 2) {
      min = '0' + min;
    }
    if (sec.length < 2) {
      sec = '0' + sec;
    }
    return '1800-01-01 $hour:$min:$sec';
  }

  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return BasicPageUI(
      appBar: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Get.off(LandingPage()),
              color: Colors.white,
              tooltip: 'Back',
            ),
            title: Text(
              'Store Event Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScUtil().setSp(25),
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: ScUtil().setHeight(25),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: ScUtil().setHeight(20),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      'Total Distance Covered In KM',
                      style: TextStyle(
                        fontSize: ScUtil().setSp(16),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // TextButton(
                  //   child: Text(
                  //     'Save',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  //   onPressed: () {
                  //     formHandling();
                  //   },
                  //   style: TextButton.styleFrom(
                  //     backgroundColor: AppColors.primaryAccentColor,
                  //     padding: EdgeInsets.all(0),
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(
              height: ScUtil().setHeight(7),
            ),
            TextFormField(
              controller: distanceController,
              keyboardType: TextInputType.number,
              maxLines: 1,
              autocorrect: true,
              onChanged: (value) {
                if (this.mounted) {
                  setState(() {
                    // firstName = value;
                  });
                }
              },
              style: TextStyle(
                fontSize: ScUtil().setSp(16),
              ),
              decoration: InputDecoration(
                suffixIcon: Text(
                  '  KM',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, height: 3, color: AppColors.primaryAccentColor),
                ),
                disabledBorder: InputBorder.none,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryAccentColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                labelStyle: TextStyle(
                    // color: firstName == ''
                    // ? Colors.red
                    //     : AppColors.appTextColor.withOpacity(0.6),
                    fontSize: ScUtil().setSp(20),
                    fontWeight: FontWeight.normal),
                labelText: 'Enter Distance',
                // errorText: nameValidator(firstName),
              ),
            ),
            SizedBox(
              height: ScUtil().setHeight(14),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      'Total Time Taken',
                      style: TextStyle(
                        fontSize: ScUtil().setSp(16),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: ScUtil().setHeight(7),
            ),
            TextFormField(
              // enabled: false,
              keyboardType: TextInputType.numberWithOptions(),
              // enableInteractiveSelection: ,
              controller: timeController,
              onTap: () {
                _selectTime(context);
              },
              onChanged: (v) {
                timeController.text =
                    selectedTime.hour.toString() + ':' + selectedTime.minute.toString();
              },
              style: TextStyle(
                fontSize: ScUtil().setSp(16),
              ),
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.history_toggle_off),
                disabledBorder: InputBorder.none,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryAccentColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                // errorText: nameValidator(lastName),
                labelStyle: TextStyle(
                    // color: lastName == ''
                    // ? Colors.red
                    //     : AppColors.appTextColor.withOpacity(0.6),
                    fontSize: ScUtil().setSp(20),
                    fontWeight: FontWeight.normal),
                labelText: 'Enter Time',
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 80.0),
              child: TextButton(
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (double.parse(distanceController.text) <= totalDistance) {
                    // AwesomeDialog(
                    //     context: context,
                    //     animType: AnimType.TOPSLIDE,
                    //     headerAnimationLoop: true,
                    //     dialogType: DialogType.INFO,
                    //     dismissOnTouchOutside: true,
                    //     title: 'Confirm!!!',
                    //     desc: 'You did not able to edit the information after clicking on Confirm Button!',
                    //
                    //     //                               String kmValue = '10 KM Mini Marathon at 7 AM';
                    //     // String orgValue = 'Persistent';
                    //     // String deptValue = 'Marketing';
                    //     // String eventSourceValue = 'Google';
                    //     // String placeValue = 'Adayar';
                    //     // String appValue = 'IHL Care';
                    //
                    //     btnOkOnPress: () {
                    //       _submit();
                    //     },
                    //     btnOkColor: AppColors.primaryAccentColor,
                    //     btnOkText: '   Confirm',
                    //     btnOkIcon: Icons.check_circle,
                    //     onDismissCallback: (_) {
                    //       debugPrint(
                    //           'Dialog Dissmiss from callback');
                    //     }).show();
                    AwesomeDialog(
                        context: context,
                        animType: AnimType.TOPSLIDE,
                        headerAnimationLoop: true,
                        dialogType: DialogType.INFO,
                        dismissOnTouchOutside: true,
                        title: 'Confirm!',
                        desc: 'you can\'t able to edit the information once submitted , ',
                        showCloseIcon: true,
                        btnOkOnPress: () async {
                          _submit();
                          // Get.back();
                        },
                        btnCancelOnPress: () {
                          Navigator.of(context).pop();
                          // Get.back();
                        },
                        useRootNavigator: true,
                        btnCancelText: 'Go Back',
                        btnOkText: 'Continue',
                        btnCancelColor: Colors.green,
                        btnOkColor: Colors.red,
                        // btnOkIcon: Icons.check_circle,
                        // btnCancelIcon: Icons.check_circle,
                        onDismissCallback: (_) {
                          debugPrint('Dialog Dissmiss from callback');
                        }).show();
                  } else {
                    Get.snackbar('Please Enter Correct Details',
                        'Your Selected variant is $totalDistance Km',
                        icon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.extension, color: Colors.white)),
                        margin: EdgeInsets.all(20).copyWith(bottom: 40),
                        backgroundColor: AppColors.primaryAccentColor,
                        colorText: Colors.white,
                        duration: Duration(seconds: 5),
                        snackPosition: SnackPosition.BOTTOM);
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryAccentColor,
                  padding: EdgeInsets.all(0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _submit() async {
    if (totalDistance.toInt() == int.parse(distanceController.text)) {
      await trackProgressApi(
          event_id: event_id,
          ihl_user_id: event_iHL_User_Id,
          steps: kms(distanceController.text).toString(),
          distance_covered: distanceController.text,
          event_status: 'complete',
          start_time: event_start_date,
          progress_time:
              getProgresstimes(selectedTime.hour.toString(), selectedTime.minute.toString(), '00'));
    } else {
      await trackProgressApi(
          event_id: event_id,
          ihl_user_id: event_iHL_User_Id,
          steps: kms(distanceController.text).toString(),
          distance_covered: distanceController.text,
          event_status: 'stop',
          start_time: event_start_date,
          progress_time:
              getProgresstimes(selectedTime.hour.toString(), selectedTime.minute.toString(), '00'));
    }
    Get.snackbar('Successfull!', 'Stored successfully.',
        icon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.check_circle_outline_outlined, color: Colors.white)),
        margin: EdgeInsets.all(20).copyWith(bottom: 40),
        backgroundColor: HexColor('#6F72CA'),
        colorText: Colors.white,
        duration: Duration(seconds: 6),
        snackPosition: SnackPosition.BOTTOM);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LandingPage()
            // HomeScreen(
            //   introDone: true,
            // ),
            ),
        (Route<dynamic> route) => false);
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
        timeController.text = '${selectedTime.hour}:${selectedTime.minute}';
      });
    }
  }

  TimeOfDay selectedTime = TimeOfDay.now();
}
