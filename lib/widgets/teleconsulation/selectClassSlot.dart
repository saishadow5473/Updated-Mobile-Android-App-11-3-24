import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/models/freesubscription_model.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/teleconsultation/mySubscriptions.dart';
import 'package:ihl/widgets/teleconsulation/reviews.dart';
import 'package:ihl/widgets/teleconsulation/subscriptionPayment/subscription_invoice_navigation_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../new_design/presentation/pages/basicData/functionalities/percentage_calculations.dart';
import '../../tabs/profiletab.dart';
import '../../views/teleconsultation/MySubscription.dart';
import '../../views/teleconsultation/viewallneeds.dart';

/// select slot for class ??
class SelectClassSlot extends StatefulWidget {
  final List slots;
  final Map course;
  final String companyName;
  final affiliationPrice;

  SelectClassSlot({@required this.slots, this.course, this.companyName, this.affiliationPrice});

  @override
  _SelectClassSlotState createState() => _SelectClassSlotState();
}

class _SelectClassSlotState extends State<SelectClassSlot> {
  http.Client _client = http.Client(); //3gb
  String email;
  String mobileNumber;

  String courseDuration;
  String courseFeesFor;
  String courseDurationStart;
  String courseDurationEnd;
  var subscriptionId;

  DateTime st;
  DateTime nd;
  DateTime ed;
  DateTime now = DateTime.now();

  //class status based on date
  bool classAlive = true;
  bool classOngoing = false;
  bool classExpired = false;
  bool upcoming = false;
  bool buttonLoading = false;

  bool makeEndDateVisible = false;
  String approval_status = 'Requested';

  var newFormat = DateFormat("dd-MM-yyyy");
  String _date = "Not set";
  String _endDate;
  bool autoApprove = false;
  String selectedDateFromPicker;
  DateTime tempDate;
  DateTime endDate;
  DateTime startDuration;
  String endDuration;
  DateTime startDate;
  final startInput = TextEditingController();
  final endInput = TextEditingController();

  TimeOfDay timeConvert(String normTime) {
    int hour;
    int minute;
    DateTime convertedTime = DateFormat.jm().parse(normTime);
    hour = convertedTime.hour;
    minute = convertedTime.minute;
    return TimeOfDay(hour: hour, minute: minute);
  }

  List<DateTime> picked = [];

  String selectedDate;
  String selectedTime = '';
  final double buttonSize = 120.0;

  Widget timeButton(String time) {
    bool isActive = false;
    var now = DateTime.now();
    var courseDuration = widget.course['course_duration'];
    var courseDurationStart = courseDuration.substring(0, 10);
    var courseEnd = courseDuration.substring(13, 23);
    // print(courseEnd);
    String courseStartTime = time.substring(0, time.indexOf("-") - 1); //07:00 PM
    courseDurationStart = courseDurationStart + " " + courseStartTime;
    var fullStartDate = DateFormat('dd-MM-yyyy hh:mm aaa').parse(courseDurationStart);
    var endDate = nd; //DateFormat('dd-MM-yyyy').parse(courseEnd);
    print(endDate);
    // var today = DateFormat('dd-MM-yyyy').parse(now.toString());
    // print(today);
    if (now.isAfter(endDate)) {
      isActive = false;
    } else {
      if (autoApprove) {
        isActive = true;
      } else if (fullStartDate.isAfter(now)) {
        isActive = true;
      } else if (fullStartDate.isBefore(now)) {
        isActive = false;
      } else {
        isActive = false;
      }
    }
    // if (now.isBefore(endDate) && autoApprove) {
    //   isActive = true;
    // } else if (now.isAfter(fullStartDate) && !autoApprove) {
    //   isActive = false;
    // } else {
    //   isActive = true;
    // }
    if (time == selectedTime) {
      return ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
        ),
        child: Text(time.toString(), style: const TextStyle(fontSize: 14)),
      );
    }
    return ElevatedButton(
      onPressed: isActive
          ? () {
              if (this.mounted) {
                setState(() {
                  selectedTime = time.toString();
                  SpUtil.putString("selectedTime", selectedTime);
                });
              }
            }
          : () {},
      style: ElevatedButton.styleFrom(
        primary: isActive ? AppColors.primaryAccentColor : Colors.grey,
      ),
      child: Text(time.toString(), style: const TextStyle(fontSize: 14)),
    );
  }

  IconData getIcon(String string) {
    if (string == 'morning') {
      return FontAwesomeIcons.cloudSun;
    }
    if (string == 'afternoon') {
      return FontAwesomeIcons.sun;
    }
    if (string == 'evening') {
      return FontAwesomeIcons.moon;
    }
    if (string == 'night') {
      return FontAwesomeIcons.cloudMoon;
    }
    return FontAwesomeIcons.briefcaseMedical;
  }

  Widget getEachTime(List list, String string) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              getIcon(string),
              size: 25.0,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                camelize(string),
                style: const TextStyle(
                  fontSize: 22.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5.0,
        ),
        Wrap(
          runAlignment: WrapAlignment.spaceEvenly,
          spacing: 8,
          children: list.map((e) => timeButton(e)).toList(),
        ),
        // Divider(
        //   thickness: 2.0,
        //   height: 30.0,
        //   indent: 5.0,
        // ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }

  int nextAvailable(List list) {
    if (list == null) {
      return 0;
    }
    for (int i = 0; i < list.length; i++) {
      if (list[i] is Map && list[i] != null && list[i].isNotEmpty) {
        return i;
      }
    }
    return 0;
  }

  Map getTimeMapList(List times) {
    Map toSend = {};
    times.forEach((element) {
      toSend[timings(element)] ??= [];
      toSend[timings(element)].add(element);
    });
    return toSend;
  }

  Widget makeList(Map map) {
    return Container(
      child: Column(
        children: map.keys.map((e) => getEachTime(map[e], e.toString())).toList(),
      ),
    );
  }

  String timings(String time) {
    DateTime convertedTime1 = DateFormat.jm().parse(time.replaceAll('  ', ''));
    int convertedTime2 = convertedTime1.hour;
    if (convertedTime2 < 12) {
      return 'morning';
    } else if (convertedTime2 < 17) {
      return 'afternoon';
    } else if (convertedTime2 < 21) {
      return 'evening';
    }
    return 'night';
  }

  var checkAddress = false;

  void personalDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userData);
    Map res = jsonDecode(data);
    if (res['User']['address'] != null || res['User']['address'] != "null") {
      checkAddress = false;
      setState(() {});
    } else {
      checkAddress = true;
    }
    email = res['User']['email'] ?? 'User@gmail.com';
    mobileNumber = res['User']['mobileNumber'] ?? '9999999999';
  }

  Map dataToSendFreeCourse() {
    return {
      'email': email,
      'mobile': mobileNumber,
      "course_img_url": widget.course['course_img_url'].toString(),
      "title": widget.course['title'].toString(),
      "course_id": widget.course['course_id'].toString(),
      "course_time": widget.course['course_time'],
      "course_on": widget.course['course_on'],
      "reason_for_visit": "",
      "category": "",
      "course_type": widget.course['fees_for'].toString(),
      "appointment_date_time": "",
      "provider": widget.course['provider'].toString(),
      "fees_for": widget.course['fees_for'].toString(),
      "consultant_name": widget.course['consultant_name'].toString(),
      "consultant_gender": widget.course['consultant_gender'].toString(),
      "course_fees": widget.course['course_fees'].toString(),
      "consultant_id": widget.course['consultant_id'].toString(),
      "subscriber_count": widget.course['subscriber_count'].toString(),
      "available_slot_count": widget.course['available_slot_count'].toString(),
      "course_duration": selectedDateFromPicker.toString(),
      "available_slot": widget.course['available_slot'],
      "approval_status": "upcoming",
    };
  }

  Map dataToSend() {
    return {
      "title": widget.course['title'].toString(),
      "course_id": widget.course['course_id'].toString(),
      "course_on": widget.course['course_on'],
      "course_type": widget.course['course_type'].toString(),
      "provider": widget.course['provider'].toString(),
      "fees_for": widget.course['fees_for'].toString(),
      "consultant_name": widget.course['consultant_name'].toString(),
      "consultant_gender": widget.course['consultant_gender'].toString(),
      "course_fees": widget.companyName != "none"
          ? widget.affiliationPrice.toString()
          : widget.course['course_fees'].toString(),
      "consultant_id": widget.course['consultant_id'].toString(),
      "subscriber_count": widget.course['subscriber_count'],
      "available_slot_count": widget.course['available_slot_count'].toString(),
      "course_duration": selectedDateFromPicker.toString(),
      "available_slot": widget.course['available_slot'],
      "approval_status": approval_status,
    };
  }

  affiliationValueFix() {}

  @override
  void initState() {
    // print('Course :' + widget.course.toString());
    SpUtil.getInstance();
    affiliationValueFix();
    personalDetails();
    super.initState();
    int ini = nextAvailable(widget.slots);

    if (widget.slots != null && widget.slots.isNotEmpty) {
      selectedDate = widget.slots[ini];
    }
    approval_status = widget.course['auto_approve'].toString() == 'true' ? "Accepted" : 'Requested';
    print('auto_approve == $approval_status');
    int lastIndexValue = widget.course["course_time"].length - 1;
    var courseTime = widget.course['course_time'][lastIndexValue];

    var midvalue = courseTime.indexOf('-');
    String courseStartTime = courseTime.substring(0, midvalue - 1);
    String courseEndTime = courseTime.substring(midvalue + 2, courseTime.length);
    autoApprove = widget.course['auto_approve'] ?? "false";
    courseDuration = widget.course['course_duration'];
    courseDurationStart = courseDuration.substring(0, 10);
    courseDurationEnd = courseDuration.substring(13, 23);
    startInput.text = courseDurationStart;
    endInput.text = courseDurationEnd;
    selectedDateFromPicker = "$courseDurationStart-$courseDurationEnd";
    courseDurationStart = "$courseDurationStart $courseStartTime";
    courseDurationEnd = "$courseDurationEnd $courseEndTime";
    var fullStartDate = DateFormat('dd-MM-yyyy hh:mm aaa').parse(courseDurationStart);
    //before(5 june 2021) we selecting the date from date picker , now we show date directly from the api (start and end date)
    SpUtil.putString("selectedDateFromPicker", selectedDateFromPicker);

    courseFeesFor = widget.course['fees_for'];
    st = DateFormat("dd-MM-yyyy hh:mm a").parse(courseDurationStart);
    nd = DateFormat("dd-MM-yyyy hh:mm a").parse(courseDurationEnd);
    //need to change
    // if (autoApprove) {
    //   if (nd.day == now.day && nd.isAfter(now)) {
    //     classAlive = false;
    //   }
    //   classAlive = true;
    // }
    // if (st.day == now.day && nd.day == now.day) {
    //   classOngoing = true;
    // } else if (nd.isBefore(now) && autoApprove) {
    //   classOngoing = false;
    //   classAlive = true;
    // } else if (nd.isAfter(now)) {
    //   classExpired = true;
    // } else if (nd.isBefore(now)) {
    //   classOngoing = false;
    //   classAlive = true;
    // }
    ///after 29 jun 22 when we showing status saprately
    if (st.day == now.day && nd.day == now.day) {
      if (fullStartDate.isAfter(now)) {
        classAlive = true;
        upcoming = true;
      } else if (nd.isAfter(now)) {
        classOngoing = true;
      } else if (nd.isBefore(now)) {
        classOngoing = false;
        classExpired = true;

        ///expired
      }
    } else if (nd.isBefore(now)) {
      classExpired = true;

      ///expired
    } else if (st.isAfter(now)) {
      classAlive = false;
      upcoming = true;
    } else if (st.day == now.day) {
      ///if upcoming or ongoing
      if (fullStartDate.isAfter(now)) {
        upcoming = true;
      } else if (fullStartDate.isBefore(now)) {
        classOngoing = true;
      } else {
        classOngoing = false;
        classAlive = true;
      }
    } else if (st.isBefore(now)) {
      classOngoing = true;
    } else {
      classAlive = true;
    }

    ///before 29 jun 22 but after old
    // if (st.day == now.day && nd.day == now.day) {
    //   if (fullStartDate.isAfter(now)) {
    //     classAlive = true;
    //   } else if (nd.isAfter(now)) {
    //     classOngoing = true;
    //   } else if (nd.isBefore(now)) {
    //     classOngoing = false;
    //   }
    // } else if (nd.isBefore(now)) {
    //   classExpired = true;
    // } else if (st.day == now.day) {
    //   classOngoing = false;
    //   classAlive = true;
    // } else if (st.isBefore(now)) {
    //   classOngoing = true;
    // } else {
    //   classAlive = true;
    // }
    ///old
    // if (st.day == now.day && nd.day == now.day) {
    //   print('equal');
    //   if (fullStartDate.isAfter(now)) {
    //     classAlive = true;

    //   }

    //   classOngoing = false;
    // } else if (nd.isBefore(now) && autoApprove) {
    //   print('nd.isBefore(now) && autoApprove');

    //   classOngoing = false;
    // } else if (nd.isBefore(now)) {
    //   print('nd.isBefore(now)');

    //   classExpired = true;
    // } else if (st.day == now.day) {
    //   print('st.day == now.day');

    //   classOngoing = false;
    //   classAlive = true;
    // } else if (st.isBefore(now) && autoApprove) {
    //   print('st.isBefore(now) && autoApprove');
    //   classOngoing = false;
    //   classAlive = true;
    //   classExpired = false;
    //   print(classAlive);
    // } else if (st.isBefore(now)) {
    //   print('st.isBefore(now)');

    //   classOngoing = true;
    // } else {
    //   classAlive = true;
    // }
    // String dy, mn;

    // if (now.day.toString().length == 1) {
    //   dy = "0" + now.day.toString();
    // } else {
    //   dy = now.day.toString();
    // }

    // if (now.month.toString().length == 1) {
    //   mn = "0" + now.month.toString();
    // } else {
    //   mn = now.month.toString();
    // }

    // String stDay, stMonth;

    // if (st.day.toString().length == 1) {
    //   stDay = "0" + st.day.toString();
    // } else {
    //   stDay = st.day.toString();
    // }

    // if (st.month.toString().length == 1) {
    //   stMonth = "0" + st.month.toString();
    // } else {
    //   stMonth = st.month.toString();
    // }

    // if (st.isAfter(now)) {
    //   startInput.text = stDay + "-" + stMonth + "-" + st.year.toString();
    // } else {
    //   startInput.text = dy + "-" + mn + "-" + now.year.toString();
    // }

    // show that sorry dailog
  }

  void callAoi(SharedPreferences prefs) async {
    if (widget.companyName == "none") {
      print('Price ${widget.course['course_fees']}');
      int _fees = widget.course['course_fees'] != 'Free' &&
              widget.course['course_fees'] != 'free' &&
              widget.course['course_fees'] != 'FREE' &&
              widget.course['course_fees'] != 'N/A' &&
              widget.course['course_fees'] != '0' &&
              widget.course['course_fees'] != '00' &&
              widget.course['course_fees'] != '000' &&
              widget.course['course_fees'] != '0.0'
          ? int.parse(widget.course['course_fees'].toString())
          : 0;
      if (widget.course['course_fees'] == 'Free' ||
          widget.course['course_fees'] == 'free' ||
          widget.course['course_fees'] == 'FREE' ||
          widget.course['course_fees'] == '0' ||
          widget.course['course_fees'] == '00' ||
          widget.course['course_fees'] == 0 ||
          _fees == 0 ||
          _fees < 1) {
        String apiToken = prefs.get('auth_token');
        var email = prefs.get('email');
        var data = prefs.get('data');
        Map res = jsonDecode(data);
        var firstName = res['User']['firstName'];
        var lastName = res['User']['lastName'];
        var mobile = res['User']['mobileNumber'];
        var ihlUserID = res['User']['id'];
        var courseDate = SpUtil.getString("selectedDateFromPicker");
        var courseTime = SpUtil.getString("selectedTime");

        String filteredDate = changeDateFormat(courseDate.toString());
        //Change date format from 09-12-2020 - 08-06-2021 to 09/12/2020 - 08/06/2021
        Map<String, dynamic> subscribeData = {
          "user_ihl_id": ihlUserID,
          "course_id": widget.course['course_id'].toString(),
          "name": "$firstName $lastName",
          "email": email.toString(),
          "mobile_number": mobile.toString(),
          "course_type": widget.course['course_type'].toString(),
          "course_time": courseTime.toString(),
          "provider": widget.course['provider'].toString(),
          "fees_for": widget.course['fees_for'].toString(),
          "consultant_name": widget.course['consultant_name'].toString(),
          "course_duration": filteredDate,
          "course_fees": widget.course['course_fees'].toString(),
          "consultation_id": widget.course['consultant_id'].toString(),
          "approval_status": approval_status,
        };
        log(subscribeData.toString());

        var classStartTime = DateFormat('yyyy-MM-dd hh:mm aaa')
            .format(DateFormat('dd-MM-yyyy hh:mm aaa').parse(courseDurationStart))
            .toString();
        var _courseDerationDateTime =
            DateFormat('dd-MM-yyyy').parse(widget.course['course_duration']);
        var _courseDurationFormated = DateFormat('MM/dd/yyyy').format(_courseDerationDateTime);
        FreeSubscription _freeSubScription = FreeSubscription(
            consultantName: widget.course["consultant_name"],
            affiliationUniqueName:
                widget.companyName != "none" ? widget.companyName : "global_services",
            approvalStatus: approval_status,
            availableSlotCount: widget.course['available_slot_count'].toString(),
            availableSlot: widget.course['available_slot'],
            className: widget.course['title'].toString(),
            consultationId: widget.course['consultant_id'].toString(),
            courseDuration: filteredDate ?? "30 Min",
            courseId: widget.course['course_id'].toString(),
            courseImgUrl: '',
            email: email,
            userMobileNumber: mobileNumber,
            mobileNumber: mobileNumber,
            purposeDetails: jsonEncode(subscribeData),
            courseOn: widget.course['course_on'],
            courseTime: courseTime.toString(),
            courseType: widget.course['fees_for'].toString(),
            feesFor: widget.course['fees_for'].toString(),
            title: widget.course['title'].toString(),
            provider: widget.course['provider'].toString(),
            transactionMode: '',
            reasonForVisit: '',
            serviceProvidedDate: classStartTime,
            userEmail: email,
            subscriberCount: widget.course['subscriber_count'].toString(),
            userIhlId: ihlUserID,
            name: "$firstName $lastName",
            time: courseTime.toString(),
            date: _courseDurationFormated);
        log(DateTime.now().toString());
        try {
          var _freeSubRes = await Dio().post('${API.iHLUrl}/consult/free_subscription',
              data: _freeSubScription.toJson(),
              options: Options(headers: {
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              }));
          log(DateTime.now().toString());
          if (_freeSubRes.statusCode == 200) {
            final getUserDetails = await _client.post(
              Uri.parse("${API.iHLUrl}/consult/get_user_details"),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              },
              body: jsonEncode(<String, dynamic>{
                'ihl_id': ihlUserID,
              }),
            );
            if (getUserDetails.statusCode == 200) {
              setState(() {
                buttonLoading = false;
              });
              final userDetailsResponse = await SharedPreferences.getInstance();
              userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
              localSotrage.write("subNav", true);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MySubscription(
                            afterCall: false,
                          )),
                  (Route<dynamic> route) => false);
            }
          } else {
            AwesomeDialog(
                    context: context,
                    animType: AnimType.TOPSLIDE,
                    headerAnimationLoop: true,
                    dialogType: DialogType.ERROR,
                    dismissOnTouchOutside: false,
                    title: 'Error!',
                    desc: 'Booking Class failed!',
                    btnOkOnPress: () {
                      Navigator.of(context).pop(true);
                    },
                    btnOkColor: Colors.red,
                    btnOkText: 'Try again !',
                    onDismissCallback: (_) {})
                .show();
          }
        } catch (e) {
          print(e);
          AwesomeDialog(
                  context: context,
                  animType: AnimType.TOPSLIDE,
                  headerAnimationLoop: true,
                  dialogType: DialogType.ERROR,
                  dismissOnTouchOutside: false,
                  title: 'Error!',
                  desc: 'Booking Class failed!',
                  btnOkOnPress: () {
                    Navigator.of(context).pop(true);
                  },
                  btnOkColor: Colors.red,
                  btnOkText: 'Try again !',
                  onDismissCallback: (_) {})
              .show();
        }
        /*
          //Code to send notification through crossbar Starts --->

          List<String> receiverIds = [];
          receiverIds
          //.add(widget.details['doctor']['ihl_consultant_id'].toString());
              .add(widget.course['consultant_id'].toString());
          var abcd = [];
          abcd.add('GenerateNotification');
          abcd.add('SubscriptionClass');
          abcd.add('$receiverIds');
          abcd.add('$ihlUserID');
          abcd.add('$subscriptionId');
          print(abcd.toString());
          s.appointmentPublish(
              'GenerateNotification',
              'SubscriptionClass',
              receiverIds,
              ihlUserID,
              subscriptionId.toString());*/
        //Code to send notification through crossbar Ends --->
      } else {
        var classStartTime = DateFormat('yyyy-MM-dd hh:mm aaa')
            .format(DateFormat('dd-MM-yyyy hh:mm aaa').parse(courseDurationStart))
            .toString();

        var sendData = dataToSend();
        sendData['consultant_id'] = widget.course['consultant_id'].toString();
        sendData['consultant_name'] = widget.course['consultant_name'].toString();
        sendData['title'] = widget.course['title'].toString();
        sendData['AffilationUniqueName'] =
            widget.companyName != 'none' ? widget.companyName : 'global_services';
        sendData['appointment_duration'] = widget.course['course_duration'] ?? "30 Min";
        sendData['affiliationPrice'] = widget.companyName != "none"
            ? widget.affiliationPrice.toString()
            : widget.course['course_fees'].toString();
        sendData['classStartTime'] = classStartTime;
        setState(() {
          buttonLoading = false;
        });
        Navigator.of(context).pushNamed(Routes.SubscriptionPaymentPage, arguments: sendData);
        // } else {
        //   print(paymentInitiateResponse.body);
        //   AwesomeDialog(
        //           context: context,
        //           animType: AnimType.TOPSLIDE,
        //           headerAnimationLoop: true,
        //           dialogType: DialogType.ERROR,
        //           dismissOnTouchOutside: false,
        //           title: 'Error!',
        //           desc: 'Payment initiation failed!',
        //           btnOkOnPress: () {
        //             Navigator.of(context).pop(true);
        //           },
        //           btnOkColor: Colors.red,
        //           btnOkText: 'Done',
        //           onDismissCallback: (_) {})
        //       .show();
        // }
      }
    } else if (widget.companyName != "none") {
      int _aff_fees = widget.affiliationPrice != 'Free' &&
              widget.affiliationPrice != 'free' &&
              widget.affiliationPrice != 'FREE' &&
              widget.affiliationPrice != 'N/A' &&
              widget.affiliationPrice != '0' &&
              widget.affiliationPrice != '00' &&
              widget.affiliationPrice != '000' &&
              widget.affiliationPrice != '0.0'
          ? int.parse(widget.affiliationPrice.toString())
          : 0;
      if (widget.affiliationPrice == 'Free' ||
          widget.affiliationPrice == 'free' ||
          widget.affiliationPrice == 'FREE' ||
          widget.affiliationPrice == '0' ||
          widget.affiliationPrice == '00' ||
          widget.affiliationPrice == 0 ||
          _aff_fees < 1) {
        String apiToken = prefs.get('auth_token');
        var email = prefs.get('email');
        var data = prefs.get('data');
        Map res = jsonDecode(data);
        var firstName = res['User']['firstName'];
        var lastName = res['User']['lastName'];
        var mobile = res['User']['mobileNumber'];
        var ihlUserID = res['User']['id'];
        var courseDate = SpUtil.getString("selectedDateFromPicker");
        var courseTime = SpUtil.getString("selectedTime");

        String filteredDate = changeDateFormat(courseDate.toString());
        //Change date format from 09-12-2020 - 08-06-2021 to 09/12/2020 - 08/06/2021
        Map<String, dynamic> subscribeData = {
          "user_ihl_id": ihlUserID,
          "course_id": widget.course['course_id'].toString(),
          "name": "$firstName $lastName",
          "email": email.toString(),
          "mobile_number": mobile.toString(),
          "course_type": widget.course['course_type'].toString(),
          "course_time": courseTime.toString(),
          "provider": widget.course['provider'].toString(),
          "fees_for": widget.course['fees_for'].toString(),
          "consultant_name": widget.course['consultant_name'].toString(),
          "course_duration": filteredDate,
          "course_fees": widget.course['course_fees'].toString(),
          "consultation_id": widget.course['consultant_id'].toString(),
          "approval_status": approval_status,
        };
        log(subscribeData.toString());
        var classStartTime = DateFormat('yyyy-MM-dd hh:mm aaa')
            .format(DateFormat('dd-MM-yyyy hh:mm aaa').parse(courseDurationStart))
            .toString();
        var _courseDerationDateTime =
            DateFormat('dd-MM-yyyy').parse(widget.course['course_duration']);
        var _courseDurationFormated = DateFormat('MM/dd/yyyy').format(_courseDerationDateTime);
        FreeSubscription _freeSubScription = FreeSubscription(
            consultantName: widget.course["consultant_name"],
            affiliationUniqueName:
                widget.companyName != "none" ? widget.companyName : "global_services",
            approvalStatus: approval_status,
            availableSlotCount: widget.course['available_slot_count'].toString(),
            availableSlot: widget.course['available_slot'],
            className: widget.course['title'].toString(),
            consultationId: widget.course['consultant_id'].toString(),
            courseDuration: filteredDate ?? "30 Min",
            courseId: widget.course['course_id'].toString(),
            courseImgUrl: '',
            email: email,
            userMobileNumber: mobileNumber,
            mobileNumber: mobileNumber,
            purposeDetails: jsonEncode(subscribeData),
            courseOn: widget.course['course_on'],
            courseTime: courseTime.toString(),
            courseType: widget.course['fees_for'].toString(),
            feesFor: widget.course['fees_for'].toString(),
            title: widget.course['title'].toString(),
            provider: widget.course['provider'].toString(),
            transactionMode: '',
            reasonForVisit: '',
            serviceProvidedDate: classStartTime,
            userEmail: email,
            subscriberCount: widget.course['subscriber_count'].toString(),
            userIhlId: ihlUserID,
            name: "$firstName $lastName",
            time: courseTime.toString(),
            date: _courseDurationFormated);
        log(_freeSubScription.toJson().toString());
        try {
          print(_freeSubScription.toJson());
          var _freeSubRes = await Dio().post('${API.iHLUrl}/consult/free_subscription',
              data: _freeSubScription.toJson(),
              options: Options(headers: {
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              }));
          if (_freeSubRes.statusCode == 200) {
            final getUserDetails = await _client.post(
              Uri.parse("${API.iHLUrl}/consult/get_user_details"),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              },
              body: jsonEncode(<String, dynamic>{
                'ihl_id': ihlUserID,
              }),
            );
            if (getUserDetails.statusCode == 200) {
              setState(() {
                buttonLoading = false;
              });
              final userDetailsResponse = await SharedPreferences.getInstance();
              userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
              localSotrage.write("subNav", true);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MySubscription(
                            afterCall: false,
                          )),
                  (Route<dynamic> route) => false);
            }
          } else {
            AwesomeDialog(
                    context: context,
                    animType: AnimType.TOPSLIDE,
                    headerAnimationLoop: true,
                    dialogType: DialogType.ERROR,
                    dismissOnTouchOutside: false,
                    title: 'Error!',
                    desc: 'Booking Class failed!',
                    btnOkOnPress: () {
                      Navigator.of(context).pop(true);
                    },
                    btnOkColor: Colors.red,
                    btnOkText: 'Try again !',
                    onDismissCallback: (_) {})
                .show();
          }
        } catch (e) {
          print(e);
          AwesomeDialog(
                  context: context,
                  animType: AnimType.TOPSLIDE,
                  headerAnimationLoop: true,
                  dialogType: DialogType.ERROR,
                  dismissOnTouchOutside: false,
                  title: 'Error!',
                  desc: 'Booking Class failed!',
                  btnOkOnPress: () {
                    Navigator.of(context).pop(true);
                  },
                  btnOkColor: Colors.red,
                  btnOkText: 'Try again !',
                  onDismissCallback: (_) {})
              .show();
        }
      } else {
        var classStartTime = DateFormat('yyyy-MM-dd hh:mm aaa')
            .format(DateFormat('dd-MM-yyyy hh:mm aaa').parse(courseDurationStart))
            .toString();

        var sendData = dataToSend();
        sendData['consultant_id'] = widget.course['consultant_id'].toString();
        sendData['consultant_name'] = widget.course['consultant_name'].toString();
        sendData['title'] = widget.course['title'].toString();
        sendData['AffilationUniqueName'] =
            widget.companyName != 'none' ? widget.companyName : 'global_services';
        sendData['appointment_duration'] = widget.course['course_duration'] ?? "30 Min";
        sendData['affiliationPrice'] = widget.companyName != "none"
            ? widget.affiliationPrice.toString()
            : widget.course['course_fees'].toString();
        sendData['classStartTime'] = classStartTime;
        setState(() {
          buttonLoading = false;
        });
        Navigator.of(context).pushNamed(Routes.SubscriptionPaymentPage, arguments: sendData);
        // } else {
        //   print(paymentInitiateResponse.body);
        //   AwesomeDialog(
        //           context: context,
        //           animType: AnimType.TOPSLIDE,
        //           headerAnimationLoop: true,
        //           dialogType: DialogType.ERROR,
        //           dismissOnTouchOutside: false,
        //           title: 'Error!',
        //           desc: 'Payment initiation failed!',
        //           btnOkOnPress: () {
        //             Navigator.of(context).pop(true);
        //           },
        //           btnOkColor: Colors.red,
        //           btnOkText: 'Done',
        //           onDismissCallback: (_) {})
        //       .show();
        // }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    if (widget.slots == null || widget.slots.isEmpty) {
      return Card(
        elevation: 2,
        shadowColor: FitnessAppTheme.grey,
        borderOnForeground: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(color: FitnessAppTheme.nearlyWhite, width: 2)),
        // color: Color(0xfff4f6fa),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
              child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 40,
              ),
              const Text('No slots available'),
            ],
          )),
        ),
      );
    }

    return Container(
      child: Card(
        elevation: 2,
        shadowColor: FitnessAppTheme.grey,
        borderOnForeground: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(color: FitnessAppTheme.nearlyWhite, width: 2)),
        // color: Color(0xfff4f6fa),
        color: FitnessAppTheme.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Visibility(
                visible: true, //makeEndDateVisible ? true : false,
                child: ButtonTheme(
                  minWidth: 290.0,
                  height: 50.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      primary: FitnessAppTheme.white,
                    ),
                    child: Column(
                      children: [
                        upcoming
                            ? const Cstatus(
                                txt1: "Course Status :",
                                txt2: " Upcoming",
                              )
                            : classOngoing
                                ? const Cstatus(
                                    txt1: "Course Status :",
                                    txt2: " Ongoing",
                                  )
                                : classExpired
                                    ? const Cstatus(
                                        txt1: "Course Status :",
                                        txt2: " Expired",
                                      )
                                    : classAlive
                                        ? const Cstatus(
                                            txt1: "Course Status :",
                                            txt2: " Active",
                                          )
                                        : const Cstatus(
                                            txt1: "Course Status :",
                                            txt2: " Upcoming",
                                          ),
                      ],
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              const Divider(
                thickness: 2.0,
                height: 10.0,
                indent: 5.0,
              ),
              const SizedBox(
                height: 10,
              ),
              Cdescription(
                title: "Course Description : ",
                txt: widget.course["course_description"]
                        .toString()
                        .replaceAll("&#39;", "")
                        .replaceAll('&amp;n', '&')
                        .replaceAll('&quot;n', " ")
                        .replaceAll("&#160;n", " ") ??
                    '',
                // // txt: 'Kindly check the phone and let me know how sdaf',
                // txt:
                //     "simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum",
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                thickness: 2.0,
                height: 10.0,
                indent: 5.0,
              ),
              const SizedBox(
                height: 7.0,
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Start Date : ',
                        style: TextStyle(
                          color: const Color(0xff6d6e71),
                          fontSize: ScUtil().setSp(18),
                          fontFamily: 'Poppins',
                        )),
                    TextSpan(
                        text: startInput.text,
                        style: TextStyle(
                          color: const Color(0xff6D6E71),
                          fontSize: ScUtil().setSp(18),
                          fontFamily: 'Poppins',
                        )),
                  ])),
              //start date
              // TextFormField(
              //   controller: startInput,
              //   readOnly: true,
              //   autocorrect: true,
              //   onTap: false == true
              //       ? () {
              //           DatePicker.showDatePicker(context,
              //               theme: DatePickerTheme(
              //                 itemStyle: TextStyle(
              //                   color: Colors.black,
              //                   fontSize: 18,
              //                 ),
              //                 cancelStyle: TextStyle(
              //                   color: Colors.red,
              //                   fontSize: 16,
              //                 ),
              //                 doneStyle: TextStyle(
              //                   fontSize: 16,
              //                 ),
              //                 containerHeight: 210,
              //               ),
              //               showTitleActions: true,
              //               minTime: st.isAfter(now) ? st : DateTime.now(),
              //               maxTime: nd, onConfirm: (date) {
              //             String number = courseFeesFor;
              //
              //             int i = number.indexOf(' ');
              //             String word = number.substring(0, i);
              //             int numberToInt = int.tryParse(word);
              //
              //             if (courseFeesFor.contains("days") ||
              //                 courseFeesFor.contains("Days")) {
              //               ed = now.add(new Duration(days: numberToInt));
              //             } else if (courseFeesFor.contains("months") ||
              //                 courseFeesFor.contains("Months") ||
              //                 courseFeesFor.contains("Month") ||
              //                 courseFeesFor.contains("month")) {
              //               ed = new DateTime(date.year,
              //                   date.month + numberToInt, date.day - 1);
              //             } else if (courseFeesFor.contains("years") ||
              //                 courseFeesFor.contains("Years") ||
              //                 courseFeesFor.contains("Year") ||
              //                 courseFeesFor.contains("year")) {
              //               ed = new DateTime(
              //                   date.year + numberToInt, date.month, date.day);
              //             } else if (courseFeesFor.contains("weeks") ||
              //                 courseFeesFor.contains("Weeks") ||
              //                 courseFeesFor.contains("week") ||
              //                 courseFeesFor.contains("Week")) {
              //               ed = new DateTime(date.year, date.month,
              //                   date.day + (numberToInt * 7));
              //             }
              //             if (this.mounted) {
              //               setState(() {
              //                 nd = ed;
              //                 makeEndDateVisible = true;
              //                 String dd, mm;
              //                 if (ed.day.toString().length == 1) {
              //                   dd = "0" + ed.day.toString();
              //                 } else {
              //                   dd = ed.day.toString();
              //                 }
              //                 if (ed.month.toString().length == 1) {
              //                   mm = "0" + ed.month.toString();
              //                 } else {
              //                   mm = ed.month.toString();
              //                 }
              //                 endInput.text =
              //                     dd + "-" + mm + "-" + ed.year.toString();
              //               });
              //             }
              //             String updatedDt = newFormat.format(date);
              //             _date = updatedDt;
              //             startInput.text = _date;
              //             if (this.mounted) {
              //               setState(() {
              //                 tempDate =
              //                     new DateFormat("dd-MM-yyyy").parse(_date);
              //               });
              //             }
              //           }, currentTime: DateTime.now(), locale: LocaleType.en);
              //         }
              //       : () {},
              //   decoration: InputDecoration(
              //     contentPadding:
              //         EdgeInsets.symmetric(vertical: 15, horizontal: 18),
              //     labelText: "Start Date",
              //     fillColor: Colors.white24,
              //   ),
              //   keyboardType: TextInputType.datetime,
              //   maxLines: 1,
              //   style: TextStyle(fontSize: 16.0),
              //   textInputAction: TextInputAction.done,
              // ),
              const SizedBox(
                height: 30.0,
              ),
              //end date
              RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'End Date  : ',
                        style: TextStyle(
                          color: const Color(0xff6d6e71),
                          fontSize: ScUtil().setSp(18),
                          fontFamily: 'Poppins',
                        )),
                    TextSpan(
                        text: endInput.text,
                        style: TextStyle(
                          color: const Color(0xff6D6E71),
                          fontSize: ScUtil().setSp(18),
                          fontFamily: 'Poppins',
                        )),
                  ])),
              // Visibility(
              //   visible: true, //makeEndDateVisible ? true : false,
              //   child: TextFormField(
              //     controller: endInput,
              //     readOnly: true,
              //     autocorrect: true,
              //     onTap: false == true
              //         ? () {
              //             DatePicker.showDatePicker(context,
              //                 theme: DatePickerTheme(
              //                   itemStyle: TextStyle(
              //                     color: Colors.black,
              //                     fontSize: 18,
              //                   ),
              //                   cancelStyle: TextStyle(
              //                     color: Colors.red,
              //                     fontSize: 16,
              //                   ),
              //                   doneStyle: TextStyle(
              //                     fontSize: 16,
              //                   ),
              //                   containerHeight: 210,
              //                 ),
              //                 showTitleActions: true,
              //                 minTime: tempDate,
              //                 maxTime: nd, onConfirm: (date) {
              //               String updatedDt = newFormat.format(date);
              //               _endDate = updatedDt;
              //               endInput.text = _endDate;
              //               selectedDateFromPicker = _date + "-" + _endDate;
              //               SpUtil.putString("selectedDateFromPicker",
              //                   selectedDateFromPicker);
              //               if (this.mounted) {
              //                 setState(() {});
              //               }
              //             },
              //                 currentTime: DateTime.now(),
              //                 locale: LocaleType.en);
              //           }
              //         : () {},
              //     decoration: InputDecoration(
              //       contentPadding:
              //           EdgeInsets.symmetric(vertical: 15, horizontal: 18),
              //       labelText: "End Date",
              //       fillColor: Colors.white24,
              //       border: new OutlineInputBorder(
              //           borderRadius: new BorderRadius.circular(15.0),
              //           borderSide: new BorderSide(color: Colors.blueGrey)),
              //     ),
              //     keyboardType: TextInputType.datetime,
              //     maxLines: 1,
              //     style: TextStyle(fontSize: 16.0),
              //     textInputAction: TextInputAction.done,
              //   ),
              // ),
              //please select date
              const Visibility(
                  visible: false, //makeEndDateVisible ? false : true,
                  child: Text("Please select Start date", style: TextStyle(fontSize: 18.0))),
              const SizedBox(
                height: 10.0,
              ),
              const Divider(
                thickness: 2.0,
                height: 30.0,
                indent: 5.0,
              ),

              Visibility(
                visible: false,
                child: Row(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.widgets_outlined,
                          size: 25.0,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            "Status : ",
                            style: TextStyle(
                              fontSize: 22.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: true, //makeEndDateVisible ? true : false,
                      child: ButtonTheme(
                        minWidth: 290.0,
                        // height: 50.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            primary: AppColors.primaryAccentColor,
                          ),
                          child: classAlive
                              ? const Text("Alive",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ))
                              : classOngoing
                                  ? const Text("Ongoing",
                                      style: TextStyle(
                                        fontSize: 18,
                                      ))
                                  : const Text("Expired",
                                      style: TextStyle(
                                        fontSize: 18,
                                      )),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Visibility(
                //Change it to true when the above visibility is true
                visible: false,
                child: Divider(
                  thickness: 2.0,
                  height: 30.0,
                  indent: 5.0,
                ),
              ),

              makeList(
                getTimeMapList(
                  widget.course['course_time'],
                ),
              ),
              // SizedBox(
              //   height: 20.0,
              // ),
              Visibility(
                visible: true, //makeEndDateVisible ? true : false,
                child: AnimatedContainer(
                  curve: Curves.easeInOutCubic,
                  width: buttonLoading ? 80 : 250,
                  height: buttonLoading ? 45 : 40,
                  duration: const Duration(milliseconds: 400),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      primary: classAlive || upcoming || autoApprove
                          // ? AppColors.primaryAccentColor
                          // : autoApprove
                          ? AppColors.primaryAccentColor
                          : Colors.grey,
                    ),
                    // : classAlive
                    //     ? Text("Confirm Subscription",
                    //         style: TextStyle(
                    //           fontSize: 18,
                    //         ))
                    //     : classOngoing
                    //         ? Text("Ongoing",
                    //             style: TextStyle(
                    //               fontSize: 18,
                    //             ))
                    //         : Text("Expired",
                    //             style: TextStyle(
                    //               fontSize: 18,
                    //             )),
                    onPressed: selectedTime.isEmpty
                        ? null
                        : (checkAddress == true)
                            ? () {
                                Get.to(ProfileTab(
                                    editing: true,
                                    bacNav: () {
                                      Get.to(ViewallTeleDashboard(
                                        includeHelthEmarket: true,
                                      ));
                                    }));
                              }
                            : buttonLoading
                                ? null
                                : () async {
                                    selectedDateFromPicker =
                                        "${startInput.text} - ${endInput.text}";
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    SpUtil.putString(
                                        "selectedDateFromPicker", selectedDateFromPicker);
                                    log(SpUtil.getString("selectedDateFromPicker"));

                                    if (classAlive || upcoming) {
                                      setState(() {
                                        buttonLoading = true;
                                      });

                                      callAoi(prefs);
                                    } else if (classOngoing) {
                                      if (!autoApprove) {
                                        Get.snackbar(
                                          '',
                                          'Sorry can\'t subscribe to ongoing class',
                                          backgroundColor: AppColors.primaryAccentColor,
                                          colorText: Colors.white,
                                          duration: const Duration(seconds: 3),
                                          isDismissible: true,
                                        );
                                      } else {
                                        setState(() => buttonLoading = true);
                                        callAoi(prefs);
                                      }
                                      //sorry slots are filled
                                    } else {
                                      Get.snackbar(
                                        '',
                                        'Sorry can\'t subscribe to expired class',
                                        backgroundColor: AppColors.primaryAccentColor,
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 3),
                                        isDismissible: true,
                                      );
                                    }
                                  },
                    child: buttonLoading
                        ? const Padding(
                            padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                            ),
                          )
                        : const Text(
                            "Confirm Subscription",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ),
              const Divider(
                thickness: 2.0,
                height: 30.0,
                indent: 5.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        // SizedBox(width: 20),
                        Icon(
                          Icons.star,
                          size: 30.0,
                          color: AppColors.primaryAccentColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Reviews & Ratings",
                          style: TextStyle(
                            color: AppColors.primaryAccentColor,
                            fontSize: 22.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    widget.course['text_reviews_data'] != null
                        ? widget.course['text_reviews_data'].length == 0
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("No Reviews yet"),
                              )
                            : Container(
                                height:
                                    widget.course['text_reviews_data'].length > 4 ? 255.0 : null,
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Reviews(
                                    reviews: widget.course['text_reviews_data'] ?? [],
                                  ),
                                ),
                              )
                        : const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("No Reviews yet"),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  changeDateFormat(var date) {
    String date1 = date;
    String finaldate;
    List<String> test2 = date1.split('');

    List<String> test1 = []..length = 23;
    test1[0] = test2[3];
    test1[1] = test2[4];
    test1[2] = '/';
    test1[3] = test2[0];
    test1[4] = test2[1];
    test1[5] = '/';
    test1[6] = test2[6];
    test1[7] = test2[7];
    test1[8] = test2[8];
    test1[9] = test2[9];
    test1[10] = test2[10];
    test1[11] = test2[11];
    test1[12] = test2[12];
    test1[13] = test2[16];
    test1[14] = test2[17];
    test1[15] = '/';
    test1[16] = test2[13];
    test1[17] = test2[14];
    test1[18] = '/';
    test1[19] = test2[19];
    test1[20] = test2[20];
    test1[21] = test2[21];
    test1[22] = test2[22];
    finaldate = test1.join('');
    return (finaldate);
  }
}

class Cstatus extends StatelessWidget {
  final txt1;
  final txt2;

  const Cstatus({
    Key key,
    this.txt1,
    this.txt2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
          text: "$txt1",
          style: TextStyle(
            color: const Color(0xff6d6e71),
            fontSize: ScUtil().setSp(18),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w300,
          ),
        ),
        TextSpan(
          text: '$txt2',
          style: TextStyle(
            color: AppColors.primaryAccentColor,
            fontSize: ScUtil().setSp(18),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    ));
  }
}

class Cdescription extends StatelessWidget {
  final title;
  final txt;

  const Cdescription({
    Key key,
    this.title,
    this.txt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> tempsplitedwords = [];
    List<String> splitedwords = [];
    if (30 < txt.length ?? 0) {
      tempsplitedwords = txt.split(" ");
      print('$tempsplitedwords');

      if (9 < tempsplitedwords.length ?? 0) {
        for (int i = 0; i < 9; i++) {
          splitedwords.add(tempsplitedwords[i]);
        }
      } else {
        for (int i = 0; i < tempsplitedwords.length ?? 0; i++) {
          splitedwords.add(tempsplitedwords[i]);
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title.toString().trim(),
              style: TextStyle(
                color: const Color(0xff6d6e71),
                fontSize: ScUtil().setSp(18.5),
                letterSpacing: 0.7,
                fontWeight: FontWeight.lerp(FontWeight.w500, FontWeight.w600, 0.49),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          tempsplitedwords.length > 9
              ? RichText(
                  text: TextSpan(children: [
                  TextSpan(
                    text: splitedwords.join(" "),
                    style: TextStyle(
                      color: AppColors.dividerColor,
                      fontSize: ScUtil().setSp(14),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: Text(title.toString()),
                                  content: SingleChildScrollView(child: Text(txt.toString())),
                                );
                              });
                        },
                        child: Text(
                          " ...more",
                          style: TextStyle(
                            color: AppColors.primaryAccentColor,
                            fontSize: ScUtil().setSp(14),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ))
                ]))
              : Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Text(
                    txt.toString() ?? "N/A",
                    style: TextStyle(
                      color: AppColors.dividerColor,
                      fontSize: ScUtil().setSp(14),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

Future getDataSubID({String subID}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String ihlId = prefs.getString("ihlUserId");
  final getUserDetails = await http.post(
    Uri.parse("${API.iHLUrl}/consult/get_user_details"),
    headers: {
      'Content-Type': 'application/json',
      'ApiToken': '${API.headerr['ApiToken']}',
      'Token': '${API.headerr['Token']}',
    },
    body: jsonEncode(<String, dynamic>{
      'ihl_id': ihlId,
    }),
  );
  if (getUserDetails.statusCode == 200) {
    final userDetailsResponse = await SharedPreferences.getInstance();
    userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
  } else {
    print(getUserDetails.body);
  }
  var data = prefs.get(SPKeys.userDetailsResponse);

  Map teleConsulResponse = json.decode(data);
  // loading = false;
  if (teleConsulResponse['my_subscriptions'] == null ||
      teleConsulResponse['my_subscriptions'] is! List ||
      teleConsulResponse['my_subscriptions'].isEmpty) {
    return;
  }
  // if (this.mounted) {
  // setState(() {
  var subscriptions = teleConsulResponse['my_subscriptions'];
  var currentSubscription = subscriptions.where((i) => i['subscription_id'] == subID).toList();
  //   });
  // }
  return currentSubscription;
}
