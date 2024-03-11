import 'dart:convert';
import 'dart:developer' as log;
import 'dart:io' as io;
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/main.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api.dart';

class CustomActivityTile extends StatefulWidget {
  CustomActivityTile(
      {Key key,
      this.name,
      this.imagePath,
      this.reminderText,
      this.durationType,
      this.activityList,
      this.activityLoaded})
      : super(key: key);
  final String name, imagePath, reminderText, durationType;
  final List activityList;
  bool activityLoaded;

  @override
  State<CustomActivityTile> createState() => _CustomActivityTileState();
}

class _CustomActivityTileState extends State<CustomActivityTile> {
  var activityIndex = 0;
  // a2c.Event buildEvent(
  //     {a2c.Recurrence recurrence, String title, String description, int mintuesValue,DateTime s,DateTime e}){
  //           addIosTimedata(title, s, e);
  //  return a2c.Event(
  //     title: title + description,
  //     description: "Activity reminder by IHL",
  //     location: 'IHL Care',
  //     startDate: s,
  //     endDate: e,
  //     allDay: false,
  //     iosParams: a2c.IOSParams(
  //       reminder: Duration(minutes: 0),
  //     ),
  //     androidParams: a2c.AndroidParams(
  //       emailInvites: ["test@example.com"],
  //     ),
  //     recurrence: recurrence,
  //   );
  // }
  addIosTimedata(title, startDate, endDate) async {
    var dateOfDay = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        widget.name + dateOfDay.toString().substring(0, 10), [title, startDate, endDate]);
    getData();
  }

  inputTimeSelect(
    String alarmtitile,
    String d,
    String title,
  ) async {
    int _startTime, _endTime;
    if (d.contains('-')) {
      List _times = d.split('-');
      _startTime = int.parse(_times[0]);
      _endTime = 60;
    } else {
      _startTime = int.parse(d);
      _endTime = 120;
    }
    log.log('$_startTime $_endTime');
    final TimeOfDay picked = await showTimePicker(
      helpText: "PICK START TIME",
      confirmText: 'NEXT',
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
              data:
                  Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Colors.blue)),
              child: child),
        );
      },
    );
    if (picked != null) {
      final TimeOfDay picked1 = await showTimePicker(
        helpText: "PICK END TIME",
        initialEntryMode: TimePickerEntryMode.dial,
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: Theme(
                data: Theme.of(context)
                    .copyWith(colorScheme: ColorScheme.light(primary: Colors.green)),
                child: child),
          );
        },
      );
      var dateOfDay = DateTime.now();

      DateTime _picked1DateTime =
          DateTime(dateOfDay.year, dateOfDay.month, dateOfDay.day, picked.hour, picked.minute);
      DateTime _picked2DateTime =
          DateTime(dateOfDay.year, dateOfDay.month, dateOfDay.day, picked1.hour, picked1.minute);
      String fomattedDay = dateOfDay.toString().substring(0, 10);
      // String pickedHours=picked.hour.hours.inHours.toString().length
      String pickedHours = picked.hour.hours.inHours.toString().length == 1
          ? '0${picked.hour.hours.inHours}'
          : picked.hour.hours.inHours.toString();
      String pickedMinute = picked.minute.minutes.inMinutes.toString().length == 1
          ? '0${picked.minute.minutes.inMinutes}'
          : picked.minute.minutes.inMinutes.toString();
      String picked1Hours = picked1.hour.hours.inHours.toString().length == 1
          ? '0${picked1.hour.hours.inHours}'
          : picked1.hour.hours.inHours.toString();
      String picked1Minute = picked.minute.minutes.inMinutes.toString().length == 1
          ? '0${picked.minute.minutes.inMinutes}'
          : picked.minute.minutes.inMinutes.toString();
      print(picked.minute.minutes.inMinutes);
      DateTime dt1 = DateTime.parse("$fomattedDay $pickedHours:$pickedMinute:00");
      DateTime dt22 = DateTime.parse("$fomattedDay $picked1Hours:$picked1Minute:00");
      DateTime dt2 = dt1.add(Duration(minutes: int.parse(d.substring(0, 2))));
      log.log(dt2.difference(dt1).toString());
      int timeDifference;
      timeDifference = dt22.difference(dt1).inMinutes.toInt();
      if (_picked2DateTime.difference(_picked1DateTime).inMinutes <= _endTime &&
          _picked2DateTime.difference(_picked1DateTime).inMinutes >= _startTime) {
        Get.snackbar('Success', 'Activity Saved Successfully',
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM);
        FlutterAlarmClock.createAlarm(picked.hour.hours.inHours, picked.minute.minutes.inMinutes,
            title: alarmtitile.toString());
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setStringList(widget.name + dateOfDay.toString().substring(0, 10),
            [alarmtitile, picked.format(context).toString(), picked1.format(context).toString()]);
        getData();
      } else {
        Get.snackbar('Failed', 'Invalid Duration',
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 1),
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  List<String> _reminderList = [];

  getData() async {
    var dateOfDay = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminderList = prefs.getStringList(widget.name + dateOfDay.toString().substring(0, 10));
    });
  }

  http.Client _client = http.Client();
  submitSelectedActivity(String selectedId, String category, String timeOfTheDay,
      String activityName, String activityId, String duration) async {
    String iHLUserId;
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    iHLUserId = prefs1.getString("ihlUserId");
    var _activityResponse = await _client.post(
        Uri.parse(
            "${API.iHLUrl}/empcardiohealth/create_or_edit_user_selected_recommended_activity"),
        body: jsonEncode(<String, String>{
          "id": selectedId, //mandatory only of edit
          "duration_in_mintues": duration,
          "time_of_the_day": timeOfTheDay,
          "activity_name": activityName,
          "activity_id": activityId,
          "category": category,
          "ihl_user_id": iHLUserId
        }));
    if (_activityResponse.statusCode == 200) {
      setState(() {
        getSelectedActivity();
        var dateOfDay = DateTime.now();
        prefs1.remove(widget.name + dateOfDay.toString().substring(0, 10));
        getData();
      });
    }
  }

  List<dynamic> _selectedActivityList;
  Map<String, dynamic> _selectedActivity = {};

  Future getSelectedActivity() async {
    String iHLUserId;
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    iHLUserId = prefs1.getString("ihlUserId");
    var res = await http.get(
      Uri.parse(
          '${API.iHLUrl}/empcardiohealth/view_user_selected_recommended_activity?ihl_user_id=$iHLUserId'),
    );
    if (res.statusCode == 200) {
      _selectedActivityList = json.decode(res.body);
      _selectedActivityList.forEach((element) {
        print(widget.name);
        if (element['category'].toString() == widget.name.toString()) {
          setState(() {
            _selectedActivity = element;
            widget.activityList.forEach((e) {
              if (e.containsValue(element['activity_name'])) {
                activityIndex = widget.activityList.indexOf(e);
                print("activity id: " + element['activity_name']);
              }
            });
          });
        }
      });
    }
  }

  String getDuration(String duration) {
    if (duration.length == 1) {
      return duration * 60;
    }
    List durationList = duration.split('-');
    String startDuration = '';
    String endDuration = '';
    if (durationList[0].length == 1) {
      startDuration = durationList[0] * 60;
    }
    if (durationList[0].length == 2) {
      startDuration = durationList[0];
    }

    return startDuration;
  }

  String getDurationType(String duration) {
    if (duration.length == 2) {
      return '$duration Min';
    }
    if (duration.length == 1) {
      return '$duration Hour';
    }
    List durationList = duration.split('-');
    String startDuration = '';
    String endDuration = '';
    if (durationList[0].length == 1) {
      startDuration = durationList[0] + ' Hour';
    }
    if (durationList[1].length == 1) {
      endDuration = durationList[1] + ' Hour';
    }
    if (durationList[0].length == 2) {
      startDuration = durationList[0] + ' Min';
    }
    if (durationList[1].length == 2) {
      endDuration = durationList[1] + ' Min';
    }
    return '$startDuration-$endDuration';
  }

  @override
  void initState() {
    getSelectedActivity();
    getData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    getSelectedActivity();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return widget.activityLoaded
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: width > 400 ? 43.w : 42.w,
                height: width > 400 ? 43.w : 42.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(offset: Offset(1, 1), color: Colors.grey.shade400, blurRadius: 16)
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        height: 28.sp,
                        width: 30.sp,
                        child: Image.asset(widget.imagePath),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 20.sp,
                        ),
                        Center(
                          child: Text(
                            _selectedActivity['activity_name'] == null
                                ? widget.name.capitalizeFirst
                                : "${widget.name[0].toUpperCase()}${widget.name.substring(1).toLowerCase()}",
                            style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                            maxLines: 2,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            // if (io.Platform.isIOS) {
                            //   var status = await Permission.calendar.status;
                            //   if (status.isDenied) {
                            //     Permission.calendar.request();
                            //     openAppSettings();
                            //   }
                            //   else if (status.isPermanentlyDenied) {
                            //     showDialog(
                            //         context: context,
                            //         builder: (BuildContext context) => CupertinoAlertDialog(
                            //           title: new Text("Calendar Access Denied"),
                            //           content:
                            //           new Text("Allow Calendar permission to continue"),
                            //           actions: <Widget>[
                            //             CupertinoDialogAction(
                            //               isDefaultAction: true,
                            //               child: Text("Yes"),
                            //               onPressed: () async {
                            //                 await openAppSettings();
                            //                 Get.back();
                            //               },
                            //             ),
                            //             CupertinoDialogAction(
                            //               child: Text("No"),
                            //               onPressed: () => Get.back(),
                            //             )
                            //           ],
                            //         ));
                            //   } else {
                            //     int _startTime, _endTime;
                            //     if (_selectedActivity['duration_in_mintues'].contains('-')) {
                            //       List _times =
                            //       _selectedActivity['duration_in_mintues'].split('-');
                            //       _startTime = int.parse(_times[0]);
                            //       _endTime = 60;
                            //     } else {
                            //       _startTime =
                            //           int.parse(_selectedActivity['duration_in_mintues']);
                            //       _endTime = 120;
                            //     }
                            //     log.log('$_startTime $_endTime');
                            //     final TimeOfDay picked = await showTimePicker(
                            //       helpText: "PICK START TIME",
                            //       confirmText: 'NEXT',
                            //       initialEntryMode: TimePickerEntryMode.dial,
                            //       context: context,
                            //       initialTime: TimeOfDay.now(),
                            //       builder: (BuildContext context, Widget child) {
                            //         return MediaQuery(
                            //           data: MediaQuery.of(context)
                            //               .copyWith(alwaysUse24HourFormat: false),
                            //           child: Theme(
                            //               data: Theme.of(context).copyWith(
                            //                   colorScheme:
                            //                   ColorScheme.light(primary: Colors.blue)),
                            //               child: child),
                            //         );
                            //       },
                            //     );
                            //     if (picked != null) {
                            //       final TimeOfDay picked1 = await showTimePicker(
                            //         helpText: "PICK END TIME",
                            //         initialEntryMode: TimePickerEntryMode.dial,
                            //         context: context,
                            //         initialTime: TimeOfDay.now(),
                            //         builder: (BuildContext context, Widget child) {
                            //           return MediaQuery(
                            //             data: MediaQuery.of(context)
                            //                 .copyWith(alwaysUse24HourFormat: false),
                            //             child: Theme(
                            //                 data: Theme.of(context).copyWith(
                            //                     colorScheme:
                            //                     ColorScheme.light(primary: Colors.green)),
                            //                 child: child),
                            //           );
                            //         },
                            //       );
                            //       print(picked.format(context));
                            //       print(picked1.format(context));
                            //       var dateOfDay = DateTime.now();
                            //       DateTime _picked1DateTime = DateTime(dateOfDay.year,
                            //           dateOfDay.month, dateOfDay.day, picked.hour, picked.minute);
                            //       DateTime _picked2DateTime = DateTime(
                            //           dateOfDay.year,
                            //           dateOfDay.month,
                            //           dateOfDay.day,
                            //           picked1.hour,
                            //           picked1.minute);
                            //       String fomattedDay = dateOfDay.toString().substring(0, 10);
                            //       String pickedHours =
                            //       picked.hour.hours.inHours.toString().length == 1
                            //           ? '0' + picked.hour.hours.inHours.toString()
                            //           : picked.hour.hours.inHours.toString();
                            //       String pickedMinute =
                            //       picked.minute.minutes.inMinutes.toString().length == 1
                            //           ? '0' + picked.minute.minutes.inMinutes.toString()
                            //           : picked.minute.minutes.inMinutes.toString();
                            //       String picked1Hours =
                            //       picked1.hour.hours.inHours.toString().length == 1
                            //           ? '0' + picked1.hour.hours.inHours.toString()
                            //           : picked1.hour.hours.inHours.toString();
                            //       String picked1Minute =
                            //       picked.minute.minutes.inMinutes.toString().length == 1
                            //           ? '0' + picked.minute.minutes.inMinutes.toString()
                            //           : picked.minute.minutes.inMinutes.toString();
                            //       print(picked.minute.minutes.inMinutes);
                            //       DateTime dt1 = DateTime.parse("${fomattedDay}" +
                            //           " " +
                            //           pickedHours +
                            //           ":" +
                            //           pickedMinute +
                            //           ":00");
                            //       DateTime dt22 = DateTime.parse("${fomattedDay}" +
                            //           " " +
                            //           picked1Hours +
                            //           ":" +
                            //           picked1Minute +
                            //           ":00");
                            //       DateTime dt2 = dt1.add(Duration(
                            //           minutes: int.parse(_selectedActivity['duration_in_mintues']
                            //               .toString()
                            //               .substring(0, 2))));
                            //       print(dt2.difference(dt1));
                            //       int timeDifference;
                            //       timeDifference = dt22.difference(dt1).inMinutes.toInt();
                            //
                            //       final d = DateTime(
                            //           dt1.year, dt1.month, dt1.day, dt1.hour, dt1.minute);
                            //       final d1 = DateTime(
                            //           dt22.year, dt22.month, dt22.day, dt22.hour, dt22.minute);
                            //       final format = DateFormat.jm();
                            //       var start = format.format(d);
                            //       var end = format.format(d1);
                            //       print(d.toString() + "start and end date" + d1.toString());
                            //       if (_picked2DateTime.difference(_picked1DateTime).inMinutes <
                            //           _endTime &&
                            //           _picked2DateTime.difference(_picked1DateTime).inMinutes >
                            //               _startTime) {
                            //         addIosTimedata(
                            //             _selectedActivity['category'] == null
                            //                 ? widget.name
                            //                 : _selectedActivity['activity_name'].toString(),
                            //             start.toString(),
                            //             picked1.format(context).toString());
                            //         var iosPlatfrom = IOSNotificationDetails();
                            //         NotificationDetails platformNotificataion =
                            //         NotificationDetails(iOS: iosPlatfrom);
                            //         Random random = new Random();
                            //         await flutterLocalNotificationsPlugin.schedule(
                            //             random.nextInt(100),
                            //             _selectedActivity['category'] == null
                            //                 ? widget.name
                            //                 : _selectedActivity['activity_name'].toString(),
                            //             ' (Duration : ' + timeDifference.toString() + ' in Min)',
                            //             d,
                            //             platformNotificataion);
                            //       } else {
                            //         Get.snackbar('Failed', 'Invalid Duration',
                            //             margin: EdgeInsets.all(20).copyWith(bottom: 40),
                            //             backgroundColor: Colors.red,
                            //             colorText: Colors.white,
                            //             duration: Duration(seconds: 1),
                            //             snackPosition: SnackPosition.BOTTOM);
                            //       }
                            //
                            //       //  a2c.Add2Calendar.addEvent2Cal(buildEvent(
                            //       //       recurrence: a2c.Recurrence(
                            //       //         frequency: a2c.Frequency.daily,
                            //       //         endDate: DateTime.now().add(Duration(days: 30)),
                            //       //       ),
                            //       //       title:_selectedActivity['category']==null?widget.name:  _selectedActivity['activity_name'].toString(),
                            //       //       description: ' (Duration : ' +
                            //       //           widget.activityList[activityIndex]['duration_in_mintues'] +
                            //       //           ' Min)',
                            //       //       mintuesValue: 30,s:dt1,e: dt22));
                            //     }
                            //   }
                            // }
                            // else {
                            //   setState(() {
                            //     _selectedActivity['category'] == null
                            //         ? inputTimeSelect(
                            //       widget.activityList[activityIndex]['activity_name'] +
                            //           ' (Duration : ' +
                            //           widget.activityList[activityIndex]
                            //           ['duration_in_mintues'] +
                            //           ' in Min)',
                            //       widget.activityList[activityIndex]['duration_in_mintues'],
                            //       widget.name,
                            //     )
                            //         : inputTimeSelect(
                            //         _selectedActivity['activity_name'].toString() +
                            //             ' (Duration : ' +
                            //             _selectedActivity['duration_in_mintues'].toString() +
                            //             ' in Min)',
                            //         _selectedActivity['duration_in_mintues'],
                            //         _selectedActivity['activity_name'].toString());
                            //   });
                            // }
                            await showDialog<String>(
                              builder: (context) => StatefulBuilder(
                                builder: (context, setInnerState) => AlertDialog(
                                  contentPadding: const EdgeInsets.all(16.0),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          "${widget.name[0].toUpperCase()}${widget.name.substring(1).toLowerCase()}",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.sp),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Container(
                                        // height: 9.h,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(2),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  offset: Offset(1, 2),
                                                  color: Colors.grey.shade300,
                                                  blurRadius: 16)
                                            ]),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                                          child: Column(
                                              children: widget.activityList.map((e) {
                                            var underscore =
                                                e['activity_name'].toString().split('_');
                                            var space = e['activity_name'].toString().split(' ');
                                            // "${e['activity_name'][0].toString().toUpperCase()}${e['activity_name'].substring(1).toLowerCase().replaceAll(new RegExp('[\\W_]+'),' ')}",
                                            return Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    e['activity_name'].toString().contains('_')
                                                        ? Text(
                                                            "${underscore[0][0].toString().toUpperCase()}${underscore[0].toString().substring(1).toLowerCase()} ${underscore[1][0].toString().toUpperCase()}${underscore[1].toString().substring(1).toLowerCase()}",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey.shade700,
                                                            ),
                                                          )
                                                        : e['activity_name']
                                                                .toString()
                                                                .contains(' ')
                                                            ? Text(
                                                                "${space[0][0].toString().toUpperCase()}${space[0].toString().substring(1).toLowerCase()} ${space[1][0].toString().toUpperCase()}${space[1].toString().substring(1).toLowerCase()}",
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.grey.shade700,
                                                                ),
                                                              )
                                                            : Text(
                                                                "${underscore[0][0].toString().toUpperCase()}${underscore[0].toString().substring(1).toLowerCase()}",
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.grey.shade700,
                                                                ),
                                                              ),
                                                    Text(
                                                      getDurationType(
                                                          e['duration_in_mintues'].toString()),
                                                      style: TextStyle(
                                                          color: Colors.grey, fontSize: 15.sp),
                                                    )
                                                  ],
                                                ),
                                                Spacer(),
                                                Radio(
                                                  value: widget.activityList.indexOf(e),
                                                  groupValue: activityIndex,
                                                  //activeColor:activityIndex==activityList.indexOf(e)? Colors.blue:Colors.grey,
                                                  onChanged: (val) {
                                                    setInnerState(() => activityIndex = val);
                                                  },
                                                ),
                                              ],
                                            );
                                          }).toList()),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding:
                                                EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                                            primary: Colors.blue,
                                            onPrimary: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(32.0),
                                            ),
                                          ),
                                          child: Text(
                                            'Submit',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            String selectedId;
                                            selectedId = _selectedActivity['id'] ?? "";
                                            submitSelectedActivity(
                                                selectedId,
                                                widget.activityList[activityIndex]['category'],
                                                widget.activityList[activityIndex]
                                                    ['time_of_the_day'],
                                                widget.activityList[activityIndex]['activity_name'],
                                                widget.activityList[activityIndex]['id'].toString(),
                                                widget.activityList[activityIndex]
                                                    ['duration_in_mintues']);
                                            Navigator.pop(context);
                                            if (io.Platform.isIOS) {
                                              var status = await Permission.calendar.status;
                                              if (status.isDenied) {
                                                Permission.calendar.request();
                                                openAppSettings();
                                              } else if (status.isPermanentlyDenied) {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) =>
                                                        CupertinoAlertDialog(
                                                          title: new Text("Calendar Access Denied"),
                                                          content: new Text(
                                                              "Allow Calendar permission to continue"),
                                                          actions: <Widget>[
                                                            CupertinoDialogAction(
                                                              isDefaultAction: true,
                                                              child: Text("Yes"),
                                                              onPressed: () async {
                                                                await openAppSettings();
                                                                Get.back();
                                                              },
                                                            ),
                                                            CupertinoDialogAction(
                                                              child: Text("No"),
                                                              onPressed: () => Get.back(),
                                                            )
                                                          ],
                                                        ));
                                              } else {
                                                int _startTime, _endTime;
                                                if (_selectedActivity['duration_in_mintues']
                                                    .contains('-')) {
                                                  List _times =
                                                      _selectedActivity['duration_in_mintues']
                                                          .split('-');
                                                  _startTime = int.parse(_times[0]);
                                                  _endTime = 60;
                                                } else {
                                                  _startTime = int.parse(
                                                      _selectedActivity['duration_in_mintues']);
                                                  _endTime = 120;
                                                }
                                                log.log('$_startTime $_endTime');
                                                final TimeOfDay picked = await showTimePicker(
                                                  helpText: "PICK START TIME",
                                                  confirmText: 'NEXT',
                                                  initialEntryMode: TimePickerEntryMode.dial,
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                  builder: (BuildContext context, Widget child) {
                                                    return MediaQuery(
                                                      data: MediaQuery.of(context)
                                                          .copyWith(alwaysUse24HourFormat: false),
                                                      child: Theme(
                                                          data: Theme.of(context).copyWith(
                                                              colorScheme: ColorScheme.light(
                                                                  primary: Colors.blue)),
                                                          child: child),
                                                    );
                                                  },
                                                );
                                                if (picked != null) {
                                                  final TimeOfDay picked1 = await showTimePicker(
                                                    helpText: "PICK END TIME",
                                                    initialEntryMode: TimePickerEntryMode.dial,
                                                    context: context,
                                                    initialTime: TimeOfDay.now(),
                                                    builder: (BuildContext context, Widget child) {
                                                      return MediaQuery(
                                                        data: MediaQuery.of(context)
                                                            .copyWith(alwaysUse24HourFormat: false),
                                                        child: Theme(
                                                            data: Theme.of(context).copyWith(
                                                                colorScheme: ColorScheme.light(
                                                                    primary: Colors.green)),
                                                            child: child),
                                                      );
                                                    },
                                                  );
                                                  print(picked1.format(context));
                                                  var dateOfDay = DateTime.now();
                                                  DateTime _picked1DateTime = DateTime(
                                                      dateOfDay.year,
                                                      dateOfDay.month,
                                                      dateOfDay.day,
                                                      picked.hour,
                                                      picked.minute);
                                                  DateTime _picked2DateTime = DateTime(
                                                      dateOfDay.year,
                                                      dateOfDay.month,
                                                      dateOfDay.day,
                                                      picked1.hour,
                                                      picked1.minute);
                                                  String fomattedDay =
                                                      dateOfDay.toString().substring(0, 10);
                                                  String pickedHours =
                                                      picked.hour.hours.inHours.toString().length ==
                                                              1
                                                          ? '0${picked.hour.hours.inHours}'
                                                          : picked.hour.hours.inHours.toString();
                                                  String pickedMinute = picked
                                                              .minute.minutes.inMinutes
                                                              .toString()
                                                              .length ==
                                                          1
                                                      ? '0${picked.minute.minutes.inMinutes}'
                                                      : picked.minute.minutes.inMinutes.toString();
                                                  String picked1Hours = picked1.hour.hours.inHours
                                                              .toString()
                                                              .length ==
                                                          1
                                                      ? '0${picked1.hour.hours.inHours}'
                                                      : picked1.hour.hours.inHours.toString();
                                                  String picked1Minute = picked
                                                              .minute.minutes.inMinutes
                                                              .toString()
                                                              .length ==
                                                          1
                                                      ? '0${picked.minute.minutes.inMinutes}'
                                                      : picked.minute.minutes.inMinutes.toString();
                                                  print(picked.minute.minutes.inMinutes);
                                                  DateTime dt1 = DateTime.parse(
                                                      "$fomattedDay $pickedHours:$pickedMinute:00");
                                                  DateTime dt22 = DateTime.parse(
                                                      "$fomattedDay $picked1Hours:$picked1Minute:00");
                                                  DateTime dt2 = dt1.add(Duration(
                                                      minutes: int.parse(
                                                          _selectedActivity['duration_in_mintues']
                                                              .toString()
                                                              .substring(0, 2))));
                                                  print(dt2.difference(dt1));
                                                  int timeDifference;
                                                  timeDifference =
                                                      dt22.difference(dt1).inMinutes.toInt();

                                                  final d = DateTime(dt1.year, dt1.month, dt1.day,
                                                      dt1.hour, dt1.minute);
                                                  final d1 = DateTime(dt22.year, dt22.month,
                                                      dt22.day, dt22.hour, dt22.minute);
                                                  final format = DateFormat.jm();
                                                  var start = format.format(d);
                                                  var end = format.format(d1);
                                                  print("${d}start and end date$d1");
                                                  if (_picked2DateTime
                                                              .difference(_picked1DateTime)
                                                              .inMinutes <
                                                          _endTime &&
                                                      _picked2DateTime
                                                              .difference(_picked1DateTime)
                                                              .inMinutes >
                                                          _startTime) {
                                                    addIosTimedata(
                                                        _selectedActivity['category'] == null
                                                            ? widget.name
                                                            : _selectedActivity['activity_name']
                                                                .toString(),
                                                        start.toString(),
                                                        picked1.format(context).toString());
                                                    var iosPlatfrom = IOSNotificationDetails();
                                                    NotificationDetails platformNotificataion =
                                                        NotificationDetails(iOS: iosPlatfrom);
                                                    Random random = new Random();
                                                    await flutterLocalNotificationsPlugin.schedule(
                                                        random.nextInt(100),
                                                        _selectedActivity['category'] == null
                                                            ? widget.name
                                                            : _selectedActivity['activity_name']
                                                                .toString(),
                                                        ' (Duration : $timeDifference in Min)',
                                                        d,
                                                        platformNotificataion);
                                                  } else {
                                                    Get.snackbar('Failed', 'Invalid Duration',
                                                        margin:
                                                            EdgeInsets.all(20).copyWith(bottom: 40),
                                                        backgroundColor: Colors.red,
                                                        colorText: Colors.white,
                                                        duration: Duration(seconds: 1),
                                                        snackPosition: SnackPosition.BOTTOM);
                                                  }

                                                  //  a2c.Add2Calendar.addEvent2Cal(buildEvent(
                                                  //       recurrence: a2c.Recurrence(
                                                  //         frequency: a2c.Frequency.daily,
                                                  //         endDate: DateTime.now().add(Duration(days: 30)),
                                                  //       ),
                                                  //       title:_selectedActivity['category']==null?widget.name:  _selectedActivity['activity_name'].toString(),
                                                  //       description: ' (Duration : ' +
                                                  //           widget.activityList[activityIndex]['duration_in_mintues'] +
                                                  //           ' Min)',
                                                  //       mintuesValue: 30,s:dt1,e: dt22));
                                                }
                                              }
                                            } else {
                                              setState(() {
                                                _selectedActivity['category'] == null
                                                    ? inputTimeSelect(
                                                        widget.activityList[activityIndex]
                                                                ['activity_name'] +
                                                            ' (Duration : ' +
                                                            widget.activityList[activityIndex]
                                                                ['duration_in_mintues'] +
                                                            ' in Min)',
                                                        widget.activityList[activityIndex]
                                                            ['duration_in_mintues'],
                                                        widget.name,
                                                      )
                                                    : inputTimeSelect(
                                                        '${_selectedActivity['activity_name']} (Duration : ${_selectedActivity['duration_in_mintues']} in Min)',
                                                        _selectedActivity['duration_in_mintues'],
                                                        _selectedActivity['activity_name']
                                                            .toString());
                                              });
                                            } // Get.back();
                                          }),
                                      SizedBox(
                                        height: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              context: context,
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 11.sp),
                            child: Container(
                              height: 19.sp,
                              width: 19.sp,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset(0, 1), color: Colors.grey, blurRadius: 16)
                                ],
                                borderRadius: BorderRadius.circular(250),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 18.sp,
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _selectedActivity['activity_name'] == null
                          ? getDurationType(
                              widget.activityList[activityIndex]['duration_in_mintues'].toString())
                          : getDurationType(_selectedActivity['duration_in_mintues']),
                      style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    _reminderList == null
                        ? GestureDetector(
                            onTap: () async {
                              if (_selectedActivity['id'] == null) {
                                Get.snackbar('Warning', 'Select a Activity!!!',
                                    margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                    backgroundColor: AppColors.primaryColor,
                                    colorText: Colors.white,
                                    duration: Duration(seconds: 1),
                                    snackPosition: SnackPosition.BOTTOM);
                                await showDialog<String>(
                                  builder: (context) => StatefulBuilder(
                                    builder: (context, setInnerState) => AlertDialog(
                                      contentPadding: const EdgeInsets.all(16.0),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Align(
                                            alignment: Alignment.topCenter,
                                            child: Text(
                                              "${widget.name[0].toUpperCase()}${widget.name.substring(1).toLowerCase()}",
                                              style: TextStyle(
                                                  color: Colors.blue, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          Container(
                                            // height: 9.h,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(2),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                      offset: Offset(1, 2),
                                                      color: Colors.grey.shade300,
                                                      blurRadius: 16)
                                                ]),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                                              child: Column(
                                                  children: widget.activityList.map((e) {
                                                var underscore =
                                                    e['activity_name'].toString().split('_');

                                                // "${e['activity_name'][0].toString().toUpperCase()}${e['activity_name'].substring(1).toLowerCase().replaceAll(new RegExp('[\\W_]+'),' ')}",
                                                return Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        e['activity_name'].toString().contains('_')
                                                            ? Text(
                                                                "${underscore[0][0].toString().toUpperCase()}${underscore[0].toString().substring(1).toLowerCase()} ${underscore[1][0].toString().toUpperCase()}${underscore[1].toString().substring(1).toLowerCase()}",
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.grey.shade700,
                                                                ),
                                                              )
                                                            : Text(
                                                                "${underscore[0][0].toString().toUpperCase()}${underscore[0].toString().substring(1).toLowerCase()}",
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.grey.shade700,
                                                                ),
                                                              ),
                                                        Text(
                                                          getDurationType(
                                                              e['duration_in_mintues'].toString()),
                                                          style: TextStyle(
                                                              color: Colors.grey, fontSize: 15.sp),
                                                        )
                                                      ],
                                                    ),
                                                    Spacer(),
                                                    Radio(
                                                      value: widget.activityList.indexOf(e),
                                                      groupValue: activityIndex,
                                                      //activeColor:activityIndex==activityList.indexOf(e)? Colors.blue:Colors.grey,
                                                      onChanged: (val) {
                                                        setInnerState(() => activityIndex = val);
                                                      },
                                                    ),
                                                  ],
                                                );
                                              }).toList()),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 25,
                                          ),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 2, horizontal: 20),
                                                primary: Colors.blue,
                                                onPrimary: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(32.0),
                                                ),
                                              ),
                                              child: Text(
                                                'Submit',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              onPressed: () async {
                                                String selectedId;
                                                selectedId = _selectedActivity['id'] == null
                                                    ? ""
                                                    : _selectedActivity['id'];
                                                submitSelectedActivity(
                                                    selectedId,
                                                    widget.activityList[activityIndex]['category'],
                                                    widget.activityList[activityIndex]
                                                        ['time_of_the_day'],
                                                    widget.activityList[activityIndex]
                                                        ['activity_name'],
                                                    widget.activityList[activityIndex]['id']
                                                        .toString(),
                                                    widget.activityList[activityIndex]
                                                        ['duration_in_mintues']);
                                                Navigator.pop(context);
                                                if (io.Platform.isIOS) {
                                                  var status = await Permission.calendar.status;
                                                  if (status.isDenied) {
                                                    Permission.calendar.request();
                                                    openAppSettings();
                                                  } else if (status.isPermanentlyDenied) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) =>
                                                            CupertinoAlertDialog(
                                                              title: new Text(
                                                                  "Calendar Access Denied"),
                                                              content: new Text(
                                                                  "Allow Calendar permission to continue"),
                                                              actions: <Widget>[
                                                                CupertinoDialogAction(
                                                                  isDefaultAction: true,
                                                                  child: Text("Yes"),
                                                                  onPressed: () async {
                                                                    await openAppSettings();
                                                                    Get.back();
                                                                  },
                                                                ),
                                                                CupertinoDialogAction(
                                                                  child: Text("No"),
                                                                  onPressed: () => Get.back(),
                                                                )
                                                              ],
                                                            ));
                                                  } else {
                                                    int _startTime, _endTime;
                                                    if (_selectedActivity['duration_in_mintues']
                                                        .contains('-')) {
                                                      List _times =
                                                          _selectedActivity['duration_in_mintues']
                                                              .split('-');
                                                      _startTime = int.parse(_times[0]);
                                                      _endTime = 60;
                                                    } else {
                                                      _startTime = int.parse(
                                                          _selectedActivity['duration_in_mintues']);
                                                      _endTime = 120;
                                                    }
                                                    log.log('$_startTime $_endTime');
                                                    final TimeOfDay picked = await showTimePicker(
                                                      helpText: "PICK START TIME",
                                                      confirmText: 'NEXT',
                                                      initialEntryMode: TimePickerEntryMode.dial,
                                                      context: context,
                                                      initialTime: TimeOfDay.now(),
                                                      builder:
                                                          (BuildContext context, Widget child) {
                                                        return MediaQuery(
                                                          data: MediaQuery.of(context).copyWith(
                                                              alwaysUse24HourFormat: false),
                                                          child: Theme(
                                                              data: Theme.of(context).copyWith(
                                                                  colorScheme: ColorScheme.light(
                                                                      primary: Colors.blue)),
                                                              child: child),
                                                        );
                                                      },
                                                    );
                                                    if (picked != null) {
                                                      final TimeOfDay picked1 =
                                                          await showTimePicker(
                                                        helpText: "PICK END TIME",
                                                        initialEntryMode: TimePickerEntryMode.dial,
                                                        context: context,
                                                        initialTime: TimeOfDay.now(),
                                                        builder:
                                                            (BuildContext context, Widget child) {
                                                          return MediaQuery(
                                                            data: MediaQuery.of(context).copyWith(
                                                                alwaysUse24HourFormat: false),
                                                            child: Theme(
                                                                data: Theme.of(context).copyWith(
                                                                    colorScheme: ColorScheme.light(
                                                                        primary: Colors.green)),
                                                                child: child),
                                                          );
                                                        },
                                                      );

                                                      print(picked1.format(context));
                                                      var dateOfDay = DateTime.now();
                                                      DateTime _picked1DateTime = DateTime(
                                                          dateOfDay.year,
                                                          dateOfDay.month,
                                                          dateOfDay.day,
                                                          picked.hour,
                                                          picked.minute);
                                                      DateTime _picked2DateTime = DateTime(
                                                          dateOfDay.year,
                                                          dateOfDay.month,
                                                          dateOfDay.day,
                                                          picked1.hour,
                                                          picked1.minute);
                                                      String fomattedDay =
                                                          dateOfDay.toString().substring(0, 10);
                                                      String pickedHours = picked.hour.hours.inHours
                                                                  .toString()
                                                                  .length ==
                                                              1
                                                          ? '0${picked.hour.hours.inHours}'
                                                          : picked.hour.hours.inHours.toString();
                                                      String pickedMinute = picked
                                                                  .minute.minutes.inMinutes
                                                                  .toString()
                                                                  .length ==
                                                              1
                                                          ? '0${picked.minute.minutes.inMinutes}'
                                                          : picked.minute.minutes.inMinutes
                                                              .toString();
                                                      String picked1Hours = picked1
                                                                  .hour.hours.inHours
                                                                  .toString()
                                                                  .length ==
                                                              1
                                                          ? '0${picked1.hour.hours.inHours}'
                                                          : picked1.hour.hours.inHours.toString();
                                                      String picked1Minute = picked
                                                                  .minute.minutes.inMinutes
                                                                  .toString()
                                                                  .length ==
                                                              1
                                                          ? '0${picked.minute.minutes.inMinutes}'
                                                          : picked.minute.minutes.inMinutes
                                                              .toString();
                                                      print(picked.minute.minutes.inMinutes);
                                                      DateTime dt1 = DateTime.parse(
                                                          "$fomattedDay $pickedHours:$pickedMinute:00");
                                                      DateTime dt22 = DateTime.parse(
                                                          "$fomattedDay $picked1Hours:$picked1Minute:00");
                                                      DateTime dt2 = dt1.add(Duration(
                                                          minutes: int.parse(_selectedActivity[
                                                                  'duration_in_mintues']
                                                              .toString()
                                                              .substring(0, 2))));
                                                      print(dt2.difference(dt1));
                                                      int timeDifference;
                                                      timeDifference =
                                                          dt22.difference(dt1).inMinutes.toInt();

                                                      final d = DateTime(dt1.year, dt1.month,
                                                          dt1.day, dt1.hour, dt1.minute);
                                                      final d1 = DateTime(dt22.year, dt22.month,
                                                          dt22.day, dt22.hour, dt22.minute);
                                                      final format = DateFormat.jm();
                                                      var start = format.format(d);
                                                      var end = format.format(d1);
                                                      print("${d}start and end date$d1");
                                                      if (_picked2DateTime
                                                                  .difference(_picked1DateTime)
                                                                  .inMinutes <
                                                              _endTime &&
                                                          _picked2DateTime
                                                                  .difference(_picked1DateTime)
                                                                  .inMinutes >
                                                              _startTime) {
                                                        addIosTimedata(
                                                            _selectedActivity['category'] == null
                                                                ? widget.name
                                                                : _selectedActivity['activity_name']
                                                                    .toString(),
                                                            start.toString(),
                                                            picked1.format(context).toString());
                                                        var iosPlatfrom = IOSNotificationDetails();
                                                        NotificationDetails platformNotificataion =
                                                            NotificationDetails(iOS: iosPlatfrom);
                                                        Random random = new Random();
                                                        await flutterLocalNotificationsPlugin.schedule(
                                                            random.nextInt(100),
                                                            _selectedActivity['category'] == null
                                                                ? widget.name
                                                                : _selectedActivity['activity_name']
                                                                    .toString(),
                                                            ' (Duration : $timeDifference in Min)',
                                                            d,
                                                            platformNotificataion);
                                                      } else {
                                                        Get.snackbar('Failed', 'Invalid Duration',
                                                            margin: EdgeInsets.all(20)
                                                                .copyWith(bottom: 40),
                                                            backgroundColor: Colors.red,
                                                            colorText: Colors.white,
                                                            duration: Duration(seconds: 1),
                                                            snackPosition: SnackPosition.BOTTOM);
                                                      }

                                                      //  a2c.Add2Calendar.addEvent2Cal(buildEvent(
                                                      //       recurrence: a2c.Recurrence(
                                                      //         frequency: a2c.Frequency.daily,
                                                      //         endDate: DateTime.now().add(Duration(days: 30)),
                                                      //       ),
                                                      //       title:_selectedActivity['category']==null?widget.name:  _selectedActivity['activity_name'].toString(),
                                                      //       description: ' (Duration : ' +
                                                      //           widget.activityList[activityIndex]['duration_in_mintues'] +
                                                      //           ' Min)',
                                                      //       mintuesValue: 30,s:dt1,e: dt22));
                                                    }
                                                  }
                                                } else {
                                                  setState(() {
                                                    _selectedActivity['category'] == null
                                                        ? inputTimeSelect(
                                                            widget.activityList[activityIndex]
                                                                    ['activity_name'] +
                                                                ' (Duration : ' +
                                                                widget.activityList[activityIndex]
                                                                    ['duration_in_mintues'] +
                                                                ' in Min)',
                                                            widget.activityList[activityIndex]
                                                                ['duration_in_mintues'],
                                                            widget.name,
                                                          )
                                                        : inputTimeSelect(
                                                            '${_selectedActivity['activity_name']} (Duration : ${_selectedActivity['duration_in_mintues']} in Min)',
                                                            _selectedActivity[
                                                                'duration_in_mintues'],
                                                            _selectedActivity['activity_name']
                                                                .toString());
                                                  });
                                                }

                                                // Get.back();
                                              }),
                                          SizedBox(
                                            height: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  context: context,
                                );
                              } else {
                                if (io.Platform.isIOS) {
                                  var status = await Permission.calendar.status;
                                  if (status.isDenied) {
                                    Permission.calendar.request();
                                    openAppSettings();
                                  } else if (status.isPermanentlyDenied) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) => CupertinoAlertDialog(
                                              title: new Text("Calendar Access Denied"),
                                              content:
                                                  new Text("Allow Calendar permission to continue"),
                                              actions: <Widget>[
                                                CupertinoDialogAction(
                                                  isDefaultAction: true,
                                                  child: Text("Yes"),
                                                  onPressed: () async {
                                                    await openAppSettings();
                                                    Get.back();
                                                  },
                                                ),
                                                CupertinoDialogAction(
                                                  child: Text("No"),
                                                  onPressed: () => Get.back(),
                                                )
                                              ],
                                            ));
                                  } else {
                                    int _startTime, _endTime;
                                    if (_selectedActivity['duration_in_mintues'].contains('-')) {
                                      List _times =
                                          _selectedActivity['duration_in_mintues'].split('-');
                                      _startTime = int.parse(_times[0]);
                                      _endTime = 60;
                                    } else {
                                      _startTime =
                                          int.parse(_selectedActivity['duration_in_mintues']);
                                      _endTime = 120;
                                    }
                                    log.log('$_startTime $_endTime');
                                    final TimeOfDay picked = await showTimePicker(
                                      helpText: "PICK START TIME",
                                      confirmText: 'NEXT',
                                      initialEntryMode: TimePickerEntryMode.dial,
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      builder: (BuildContext context, Widget child) {
                                        return MediaQuery(
                                          data: MediaQuery.of(context)
                                              .copyWith(alwaysUse24HourFormat: false),
                                          child: Theme(
                                              data: Theme.of(context).copyWith(
                                                  colorScheme:
                                                      ColorScheme.light(primary: Colors.blue)),
                                              child: child),
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      final TimeOfDay picked1 = await showTimePicker(
                                        helpText: "PICK END TIME",
                                        initialEntryMode: TimePickerEntryMode.dial,
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        builder: (BuildContext context, Widget child) {
                                          return MediaQuery(
                                            data: MediaQuery.of(context)
                                                .copyWith(alwaysUse24HourFormat: false),
                                            child: Theme(
                                                data: Theme.of(context).copyWith(
                                                    colorScheme:
                                                        ColorScheme.light(primary: Colors.green)),
                                                child: child),
                                          );
                                        },
                                      );
                                      print(picked1.format(context));
                                      var dateOfDay = DateTime.now();
                                      DateTime _picked1DateTime = DateTime(
                                          dateOfDay.year,
                                          dateOfDay.month,
                                          dateOfDay.day,
                                          picked.hour,
                                          picked.minute);
                                      DateTime _picked2DateTime = DateTime(
                                          dateOfDay.year,
                                          dateOfDay.month,
                                          dateOfDay.day,
                                          picked1.hour,
                                          picked1.minute);
                                      String fomattedDay = dateOfDay.toString().substring(0, 10);
                                      String pickedHours =
                                          picked.hour.hours.inHours.toString().length == 1
                                              ? '0${picked.hour.hours.inHours}'
                                              : picked.hour.hours.inHours.toString();
                                      String pickedMinute =
                                          picked.minute.minutes.inMinutes.toString().length == 1
                                              ? '0${picked.minute.minutes.inMinutes}'
                                              : picked.minute.minutes.inMinutes.toString();
                                      String picked1Hours =
                                          picked1.hour.hours.inHours.toString().length == 1
                                              ? '0${picked1.hour.hours.inHours}'
                                              : picked1.hour.hours.inHours.toString();
                                      String picked1Minute =
                                          picked.minute.minutes.inMinutes.toString().length == 1
                                              ? '0${picked.minute.minutes.inMinutes}'
                                              : picked.minute.minutes.inMinutes.toString();
                                      print(picked.minute.minutes.inMinutes);
                                      DateTime dt1 = DateTime.parse(
                                          "$fomattedDay $pickedHours:$pickedMinute:00");
                                      DateTime dt22 = DateTime.parse(
                                          "$fomattedDay $picked1Hours:$picked1Minute:00");
                                      DateTime dt2 = dt1.add(Duration(
                                          minutes: int.parse(
                                              _selectedActivity['duration_in_mintues']
                                                  .toString()
                                                  .substring(0, 2))));
                                      print(dt2.difference(dt1));
                                      int timeDifference;
                                      timeDifference = dt22.difference(dt1).inMinutes.toInt();

                                      final d = DateTime(
                                          dt1.year, dt1.month, dt1.day, dt1.hour, dt1.minute);
                                      final d1 = DateTime(
                                          dt22.year, dt22.month, dt22.day, dt22.hour, dt22.minute);
                                      final format = DateFormat.jm();
                                      var start = format.format(d);
                                      var end = format.format(d1);
                                      print("${d}start and end date$d1");
                                      if (_picked2DateTime.difference(_picked1DateTime).inMinutes <=
                                              _endTime &&
                                          _picked2DateTime.difference(_picked1DateTime).inMinutes >
                                              _startTime) {
                                        addIosTimedata(
                                            _selectedActivity['category'] == null
                                                ? widget.name
                                                : _selectedActivity['activity_name'].toString(),
                                            start.toString(),
                                            picked1.format(context).toString());
                                        var iosPlatfrom = IOSNotificationDetails();
                                        Get.snackbar('Success', 'Activity Saved Successfully',
                                            margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                            backgroundColor: AppColors.primaryAccentColor,
                                            colorText: Colors.white,
                                            duration: Duration(seconds: 3),
                                            snackPosition: SnackPosition.BOTTOM);
                                        NotificationDetails platformNotificataion =
                                            NotificationDetails(iOS: iosPlatfrom);
                                        Random random = new Random();
                                        await flutterLocalNotificationsPlugin.schedule(
                                            random.nextInt(100),
                                            _selectedActivity['category'] == null
                                                ? widget.name
                                                : _selectedActivity['activity_name'].toString(),
                                            ' (Duration : $timeDifference in Min)',
                                            d,
                                            platformNotificataion);
                                      } else {
                                        Get.snackbar('Failed', 'Invalid Duration',
                                            margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            duration: Duration(seconds: 1),
                                            snackPosition: SnackPosition.BOTTOM);
                                      }

                                      //  a2c.Add2Calendar.addEvent2Cal(buildEvent(
                                      //       recurrence: a2c.Recurrence(
                                      //         frequency: a2c.Frequency.daily,
                                      //         endDate: DateTime.now().add(Duration(days: 30)),
                                      //       ),
                                      //       title:_selectedActivity['category']==null?widget.name:  _selectedActivity['activity_name'].toString(),
                                      //       description: ' (Duration : ' +
                                      //           widget.activityList[activityIndex]['duration_in_mintues'] +
                                      //           ' Min)',
                                      //       mintuesValue: 30,s:dt1,e: dt22));
                                    }
                                  }
                                } else {
                                  setState(() {
                                    _selectedActivity['category'] == null
                                        ? inputTimeSelect(
                                            widget.activityList[activityIndex]['activity_name'] +
                                                ' (Duration : ' +
                                                widget.activityList[activityIndex]
                                                    ['duration_in_mintues'] +
                                                ' in Min)',
                                            widget.activityList[activityIndex]
                                                ['duration_in_mintues'],
                                            widget.name,
                                          )
                                        : inputTimeSelect(
                                            '${_selectedActivity['activity_name']} (Duration : ${_selectedActivity['duration_in_mintues']} in Min)',
                                            _selectedActivity['duration_in_mintues'],
                                            _selectedActivity['activity_name'].toString());
                                  });
                                }
                              }
                            },
                            child: Container(
                              height: 27.sp,
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Text(
                                widget.reminderText,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        : Container(
                            height: 27.sp,
                            width: double.maxFinite,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              '${_reminderList[1]} - ${_reminderList[2]}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          )
        : Container(height: 100, child: Center(child: CircularProgressIndicator()));
  }
}
