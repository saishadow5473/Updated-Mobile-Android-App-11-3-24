import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/repositories/book_appointment_pagination_api.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/dateFormat.dart';
import 'package:ihl/views/teleconsultation/doctor_reviews.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:ihl/widgets/teleconsulation/SelectSlot.dart';
import 'package:intl/intl.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:strings/strings.dart';

import '../offline_widget.dart';

// ignore: must_be_immutable
class BookAppointment extends StatefulWidget {
  final Map doctor;
  final specality;
  BookAppointment({@required this.doctor, this.specality});
  @override
  _BookAppointmentState createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  http.Client _client = http.Client(); //3gb
  List appDetails = [];
  bool doctorHasAppointment = false;
  bool hasappointment = false;
  bool hasnorequest = false;
  bool loading = true;

  String ihlConsultantID;
  String vendorID;
  List next30;
  String consultantAvailabilityURL;

  bool profilePressed = true;
  bool calendarPressed = true;
  bool _isProfileVisible = true;
  bool _isCalendarVisible = true;
  bool _isFetching = false;
  Color callButtonColor = Colors.green;
  Color calenderButtonColor = Colors.green;
  Color infoButtonColor = AppColors.primaryAccentColor;
  ScrollController _controller = ScrollController();
  final profile = new GlobalKey();

  String status;
  Client client;
  Session bookAppointmentSession;

  void connect() {
    client = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
  }

//check the crossbar for status update
  void update() async {
    if (bookAppointmentSession != null) {
      bookAppointmentSession.close();
    }
    connect();
    // httpStatus(widget.doctor['ihl_consultant_id']);
    var doctorId = widget.doctor['ihl_consultant_id'];
    bookAppointmentSession = await client.connect().first;
    try {
      final subscription = await bookAppointmentSession.subscribe(
          'ihl_update_doctor_status_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) {
        Map data = event.arguments[0];
        var docStatus = data['data']['status'];
        if (data['sender_id'] == doctorId) {
          if (this.mounted) {
            setState(() {
              status = docStatus;
              widget.doctor['availabilityStatus'] = docStatus;
            });
          }
        }
      });
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  Color avail() {
    status = widget.doctor['availabilityStatus'];
    Color color = AppColors.primaryAccentColor;
    if (status == 'Online' || status == 'online') {
      color = Colors.green;
    }
    if (doctorHasAppointment == true) {
      color = Colors.red;
    }
    if (status == 'Busy' || status == 'busy') {
      color = Colors.red;
    }
    if (status == 'Offline' || status == 'offline') {
      color = Colors.grey;
    }
    return color;
  }

  Future<String> httpStatus(var consultantId) async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/getConsultantLiveStatus'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, dynamic>{
        "consultant_id": [consultantId]
      }),
    );
    if (response.statusCode == 200) {
      if (response.body != '"[]"') {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString1 = parsedString.replaceAll(";", "");
        var parsedString2 = parsedString1.replaceAll('"[', '[');
        var parsedString3 = parsedString2.replaceAll(']"', ']');
        var finalOutput = json.decode(parsedString3);
        var doctorId = consultantId;

        if (doctorId == finalOutput[0]['consultant_id']) {
          if (this.mounted) {
            setState(() {
              status = camelize(finalOutput[0]['status'].toString());
            });
          }
        }
      } else {}
    } else {
      print('responce failure');
    }

    return status;
  }

  Future getDataBookAppointments() async {
    var subscriptionsDetails;

    // final response = await http.get(
    //   Uri.parse(API.iHLUrl +
    //       '/consult/view_all_book_appointment?ihl_consultant_id=' +
    //       widget.doctor['ihl_consultant_id']),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'ApiToken':'${API.headerr['ApiToken']}',
    //     'Token':'${API.headerr['Token']}',
    //   },
    // );
    final paginationData =
        await RemoteApi.getCharacterList(0, widget.doctor['ihl_consultant_id'], end_index: 100);

    if (paginationData != null) {
//       String value = response.body;
//       var lastStartIndex = 0;
//       var lastEndIndex = 0;
//       var reasonLastEndIndex = 0;
//       var alergyLastEndIndex = 0;
//       var notesLastEndIndex = 0;
//       var reasonForVisit = [];
//       for (int i = 0; i < value.length; i++) {
//         if (value.contains("reason_for_visit")) {
//           var start = "appointment_id";
//           var end = "booked_date_time";
//           var startIndex = value.indexOf(start, lastStartIndex);
//           var endIndex = value.indexOf(end, lastEndIndex);
//           lastStartIndex = value.indexOf(start, startIndex) + start.length;
//           lastEndIndex = value.indexOf(end, endIndex) + end.length;
//           String a = value.substring(startIndex + start.length, endIndex);
//           var parseda1 = a.replaceAll('\\&quot', '"');
//           var parseda2 = parseda1.replaceAll('\\";:\\";', '');
//           var parseda3 = parseda2.replaceAll('\\";,\\";', '');
//
//           var reasonStart = "reason_for_visit";
//           var reasonEnd = "notes";
//           var reasonStartIndex = value.indexOf(reasonStart);
//           var reasonEndIndex = value.indexOf(reasonEnd, reasonLastEndIndex);
//           reasonLastEndIndex =
//               value.indexOf(reasonEnd, reasonLastEndIndex) + reasonEnd.length;
//           String b = value.substring(
//               reasonStartIndex + reasonStart.length, reasonEndIndex);
//           var parsedb1 = b.replaceAll('\\&quot', '"');
//           var parsedb2 = parsedb1.replaceAll('\\";:\\";', '');
//           var parsedb3 = parsedb2.replaceAll('\\";,\\";', '');
//           var temp1 = value.substring(0, reasonStartIndex);
//           var temp2 = value.substring(reasonEndIndex, value.length);
//           value = temp1 + temp2;
// // rest.add(value.substring(startIndex+start.length , endIndex));
//
//           var alergyStart = "alergy";
//           var alergyEnd = "appointment_start_time";
//           var alergyStartIndex = value.indexOf(alergyStart);
//           var alergyEndIndex = value.indexOf(alergyEnd, alergyLastEndIndex);
//           alergyLastEndIndex = alergyEndIndex + alergyEnd.length;
//
//           String c = value.substring(
//               alergyStartIndex + alergyStart.length, alergyEndIndex);
//           var parsedc1 = c.replaceAll('\\&quot;', '');
//           var parsedc2 = parsedc1.replaceAll('\\:\\', '');
//           var parsedc3 = parsedc2.replaceAll('\\,\\', '');
//           temp1 = value.substring(0, alergyStartIndex);
//           temp2 = value.substring(alergyEndIndex, value.length);
//           value = temp1 + temp2;
//
//           var notesStart = ";notes";
//           var notesEnd = ";kiosk_checkin_history";
//           var notesStartIndex = value.indexOf(notesStart);
//           var notesEndIndex = value.indexOf(notesEnd, notesLastEndIndex);
//           notesLastEndIndex = notesEndIndex + notesEnd.length;
//           String d = value.substring(
//               notesStartIndex + notesStart.length, notesEndIndex);
//           var parsedd1 = d.replaceAll('&quot;', '');
//           var parsedd2 = parsedd1.replaceAll(':', '');
//           var parsedd3 = parsedd2.replaceAll(',', '');
//           var parsedd4 = parsedd3.replaceAll('&quot', '');
//           temp1 = value.substring(0, notesStartIndex);
//           temp2 = value.substring(notesEndIndex, value.length);
//           value = temp1 + temp2;
// //todo : parsing
//           Map<String, String> app = {};
//           app['appointment_id'] = parseda3;
//           app['reason_for_visit'] = parsedb3;
//           app["alergy"] = parsedc3;
//           app["notes"] = parsedd4;
//           reasonForVisit.add(app);
// // print(app);
// // print(value.length);
//
//         } else {
//           i = value.length;
//         }
//       }
//       // print(reasonForVisit);
//       var parsedString = value.replaceAll('\\&quot;', '"');
//       var parsedString2 = parsedString.replaceAll('"[', '[');
//       var parsedString3 = parsedString2.replaceAll(']"', ']');
//       var parsedString4 = parsedString3.replaceAll("&quot;", "");
//       var parsedString5 = parsedString4.replaceAll("\\\\\\\\", "");
//       var parsedString6 = parsedString5.replaceAll('\\"', '"');
//       var parsedString7 = parsedString6.replaceAll('}"', '}');
//       var parsedString8 = parsedString7.replaceAll('"{', '{');
//       var parsedString9 = parsedString8.replaceAll('"W/"', '"');
//       var parsedString10 = parsedString9.replaceAll(';""', ';"');
//       var parsedString11 = parsedString10.replaceAll('\\[]"', '"[]"');
//       var finalOutput = parsedString11.replaceAll('"[]"', '""');
//       List<dynamic> subscriptions = json.decode(finalOutput);
//       // subscriptions[0]['Book_Appointment'].length
      var reasonForVisit = paginationData[2];
      List<dynamic> subscriptions = paginationData[0];
      for (int i = 0; i < reasonForVisit.length; i++) {
        subscriptions[i]['Book_Apointment']['reason_for_visit'] =
            reasonForVisit[i]['reason_for_visit'];
        subscriptions[i]['Book_Apointment']['alergy'] = reasonForVisit[i]['alergy'];
        subscriptions[i]['Book_Apointment']['notes'] = reasonForVisit[i]['notes'];
      }
      subscriptionsDetails = subscriptions;
      List<DateTime> formattedTime = [];
      List<String> stringFormattedDateTime = [];
      for (int i = 0; i < subscriptionsDetails.length; i++) {
        String date = subscriptionsDetails[i]['Book_Apointment']["appointment_start_time"];
        String stringTime = date.substring(11, 19);
        date = date.substring(0, 10);
        DateTime formattime = DateFormat.jm().parse(stringTime);
        String time = DateFormat("HH:mm:ss").format(formattime);
        String dateToFormat = date + " " + time;
        var newTime = DateTime.parse(dateToFormat);
        formattedTime.add(newTime);
      }
      formattedTime.sort((a, b) => b.compareTo(a));

      List appointmentDetails = [];
      List temp = [];
      sort(List subscriptionsDetails) {
        if (subscriptionsDetails == null || subscriptionsDetails.length == 0) return;
        for (int i = 0; i < subscriptionsDetails.length; i++) {
          String stringFormattedTime = DateFormat("yyyy-MM-dd hh:mm aaa").format(formattedTime[i]);
          stringFormattedDateTime.add(stringFormattedTime);
          temp.add(subscriptionsDetails[i]['Book_Apointment']["appointment_start_time"]);
        }
        for (int i = 0; i < stringFormattedDateTime.length; i++) {
          if (temp.contains(stringFormattedDateTime[i])) {
            int ii = temp.indexOf(stringFormattedDateTime[i]);
            appointmentDetails.add(subscriptionsDetails[ii]);
          }
        }
      }

      sort(subscriptionsDetails);
      subscriptionsDetails = appointmentDetails;
      DateTime current = DateTime.now();
      var appDetails = [];

      for (int i = 0; i < subscriptionsDetails.length; i++) {
        //  if (subscriptionsDetails[i] != null) {
        String date = subscriptionsDetails[i]['Book_Apointment']["appointment_start_time"];
        String callStatus = subscriptionsDetails[i]['Book_Apointment']['call_status'];
        String stringTime = date.substring(11, 19);
        date = date.substring(0, 10);
        DateTime formattime = DateFormat.jm().parse(stringTime);
        String time = DateFormat("HH:mm:ss").format(formattime);
        String dateToFormat = date + " " + time;
        var appointmentStartingTime = DateTime.parse(dateToFormat);
        if (appointmentStartingTime.day == current.day) {
          var tempappDetails = [];
          tempappDetails.add(appointmentStartingTime);
          tempappDetails.add(callStatus);
          appDetails.add(tempappDetails);
        }
        // }
      }

      return appDetails;
    } else {
      print(paginationData + '< pagination data is nulll');
    }
  }

  existingAppointmentsFromGetDataBookAppointments(subscriptionsDetails) {
    List<DateTime> formattedTime = [];
    List<String> stringFormattedDateTime = [];
    for (int i = 0; i < subscriptionsDetails.length; i++) {
      String date = subscriptionsDetails[i]['Book_Apointment']["appointment_start_time"];
      String stringTime = date.substring(11, 19);
      date = date.substring(0, 10);
      DateTime formattime = DateFormat.jm().parse(stringTime);
      String time = DateFormat("HH:mm:ss").format(formattime);
      String dateToFormat = date + " " + time;
      var newTime = DateTime.parse(dateToFormat);
      formattedTime.add(newTime);
    }
    formattedTime.sort((a, b) => b.compareTo(a));

    List appointmentDetails = [];
    List temp = [];
    sort(List subscriptionsDetails) {
      if (subscriptionsDetails == null || subscriptionsDetails.length == 0) return;
      for (int i = 0; i < subscriptionsDetails.length; i++) {
        String stringFormattedTime = DateFormat("yyyy-MM-dd hh:mm aaa").format(formattedTime[i]);
        stringFormattedDateTime.add(stringFormattedTime);
        temp.add(subscriptionsDetails[i]['Book_Apointment']["appointment_start_time"]);
      }
      for (int i = 0; i < stringFormattedDateTime.length; i++) {
        if (temp.contains(stringFormattedDateTime[i])) {
          int ii = temp.indexOf(stringFormattedDateTime[i]);
          appointmentDetails.add(subscriptionsDetails[ii]);
        }
      }
    }

    sort(subscriptionsDetails);
    subscriptionsDetails = appointmentDetails;
    DateTime current = DateTime.now();
    var appDetails = [];

    for (int i = 0; i < subscriptionsDetails.length; i++) {
      //  if (subscriptionsDetails[i] != null) {
      String date = subscriptionsDetails[i]['Book_Apointment']["appointment_start_time"];
      String callStatus = subscriptionsDetails[i]['Book_Apointment']['call_status'];
      String stringTime = date.substring(11, 19);
      date = date.substring(0, 10);
      DateTime formattime = DateFormat.jm().parse(stringTime);
      String time = DateFormat("HH:mm:ss").format(formattime);
      String dateToFormat = date + " " + time;
      var appointmentStartingTime = DateTime.parse(dateToFormat);
      if (appointmentStartingTime.day == current.day) {
        var tempappDetails = [];
        tempappDetails.add(appointmentStartingTime);
        tempappDetails.add(callStatus);
        appDetails.add(tempappDetails);
      }
      // }
    }

    return appDetails;
  }

  Future getAppointments() async {
    print('Start Get Appointment ${DateTime.now()}');

    final paginationData =
        await RemoteApi.getCharacterList(0, widget.doctor['ihl_consultant_id'], end_index: 50);

    if (paginationData != null) {
      var reasonForVisit = paginationData[2];
      List<dynamic> appointments = paginationData[0];

      for (int i = 0; i < reasonForVisit.length; i++) {
        appointments[i]['Book_Apointment']['reason_for_visit'] =
            reasonForVisit[i]['reason_for_visit'];
        appointments[i]['Book_Apointment']['alergy'] = reasonForVisit[i]['alergy'];
        appointments[i]['Book_Apointment']['notes'] = reasonForVisit[i]['notes'];
      }
      appDetails = appointments;
      // getAppointmentDataManipulation(finalOutput,appDetails);
      // getAvailableSlot(appDetails);
      getAppointmentDataManipulation(paginationData[3], appDetails);
    } else {
      print(paginationData + '< pagination data is nulll');
    }
  }

  getAppointmentDataManipulation(finalOutput, appDetails) {
    appDetails = appDetails
        .where((i) =>
            (i['Book_Apointment']["appointment_status"] == "Approved" ||
                i['Book_Apointment']["appointment_status"] == "approved") &&
            (i['Book_Apointment']["call_status"] != "completed"))
        .toList();

    for (int i = 0; i < appDetails.length; i++) {
      String startTime = appDetails[i]['Book_Apointment']["appointment_start_time"];
      String stringTime = startTime.substring(11, 19);
      startTime = startTime.substring(0, 10);
      DateTime formattime = DateFormat.jm().parse(stringTime);
      String time = DateFormat("HH:mm:ss").format(formattime);
      String dateToFormat = startTime + " " + time;

      var currentDateTime = new DateTime.now();

      var appointmentStartingTime = DateTime.parse(dateToFormat);
      var fifteenMinutesBeforeStartAppointment =
          appointmentStartingTime.subtract(new Duration(minutes: 15));
      var thirtyMinutesAfterStartAppointment =
          appointmentStartingTime.add(new Duration(minutes: 30));

      if (currentDateTime.isAfter(fifteenMinutesBeforeStartAppointment) &&
          currentDateTime.isBefore(thirtyMinutesAfterStartAppointment) &&
          (appDetails[i]['Book_Apointment']["call_status"] != "completed" ||
              appDetails[i]['Book_Apointment']["call_status"] != "Completed") &&
          (appDetails[i]['Book_Apointment']["appointment_status"] != "Canceled")) {
        if (this.mounted) {
          setState(() {
            doctorHasAppointment = true;
            loading = false;
          });
        }
      } else if (currentDateTime.isAfter(fifteenMinutesBeforeStartAppointment) &&
          currentDateTime.isBefore(thirtyMinutesAfterStartAppointment) &&
          (appDetails[i]['Book_Apointment']["call_status"] == "completed" ||
              appDetails[i]['Book_Apointment']["call_status"] == "Completed")) {
        if (this.mounted) {
          setState(() {
            doctorHasAppointment = false;
            loading = false;
          });
        }
      } else {
        if (this.mounted) {
          setState(() {
            // doctorHasAppointment = false;
            loading = false;
          });
        }
      }
    }
    if (this.mounted) {
      setState(() {
        if (finalOutput == "[]" || appDetails.length == 0 || appDetails == null) {
          hasnorequest = true;
          loading = false;
        }
        hasappointment = true;
      });
    }
  }

  Future getAvailableSlot(
      //subscriptionsDetails_
      ) async {
    print('Start Time ${DateTime.now()}');

    // var existingAppointments = await getDataBookAppointments();
    // var existingAppointments =
    //     await existingAppointmentsFromGetDataBookAppointments(
    //         subscriptionsDetails_);
    ihlConsultantID = widget.doctor['ihl_consultant_id'];
    vendorID = widget.doctor['vendor_id'];
    consultantAvailabilityURL = API.iHLUrl +
        // "/consult/consultant_timings_live_availablity?ihl_consultant_id=" +
        // ihlConsultantID +
        // "&vendor_id=" +
        // vendorID;
        // old api
        // "/consult/consultant_timings_live_availablity?ihl_consultant_id=$ihlConsultantID&vender_id=$vendorID";
        // new api
        // "/consult/consultant_timings_live_availablity_mobile?ihl_consultant_id={ihl_consultant_id}&vendor_id={vendor_id}""
        "/consult/consultant_timings_live_availablity_mobile?ihl_consultant_id=$ihlConsultantID&vendor_id=$vendorID";
    print(consultantAvailabilityURL);
    final response = await _client.get(
      Uri.parse(consultantAvailabilityURL),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );

    if (response.statusCode == 200) {
      next30 = jsonDecode(response.body);

      // for (int i = 0; i <= testm[0]['today'].length - 1; i++) {
      //   TimeOfDay tt = timeConvert(testm[0]['today'][i]);
      //   TimeOfDay t = TimeOfDay.now();
      //   final now = DateTime.now();
      //   DateTime nowTime =
      //       DateTime(now.year, now.month, now.day, t.hour, t.minute);
      //   DateTime fromAPI =
      //       DateTime(now.year, now.month, now.day, tt.hour, tt.minute);

      //   if (fromAPI.isAfter(nowTime)) {
      //     if (existingAppointments.isNotEmpty) {
      //       var callStatus = existingAppointments[0][1];
      //       if (callStatus != "completed") {
      //         if ((fromAPI.isBefore(existingAppointments[0][0]
      //                 .add(new Duration(minutes: 30)))) &&
      //             (fromAPI.isAfter(existingAppointments[0][0]
      //                 .add(new Duration(minutes: 5))))) {
      //           print(testm[0]['today'][i]);
      //         } else {
      //           // filtered.add(testm[0]['today'][i]);
      //         }
      //       } else {
      //         // filtered.add(testm[0]['today'][i]);
      //       }
      //     } else {
      //       // filtered.add(testm[0]['today'][i]);
      //     }
      //   }

      //   // for(int j =0 ; j< existingAppointments.length ; j++)
      //   // for(int k=0;k<filtered.length;k++){
      //   //   if (existingAppointments[j]
      //   //       .add(new Duration(minutes: 30))
      //   //       .isBefore(filtered[k])) {
      //   //     filtered.removeAt(k);
      //   //   }
      //   // }
      // }
      // var filteredToday = {'today': filtered};
      // next30.removeAt(0);
      // next30.insert(0, filteredToday);
      print('End ${DateTime.now()}');
      if (this.mounted) {
        setState(() {
          _isFetching = true;
        });
      }
    } else {
      print(response.body);
    }
  }

  @override
  void initState() {
    print('Start Init State ${DateTime.now()}');
    getAvailableSlot();
    update();

    if (widget.doctor['livecall'] == true) {
      _isProfileVisible = true;
    } else {
      _isCalendarVisible = true;
    }

    getAppointments();

    showProfile();
    getConsultantImageURL();
    super.initState();
  }

  Future getConsultantImageURL() async {
    try {
      if (widget.doctor['profile_picture'] == null) {
        var map = widget.doctor['vendor_id'] == "GENIX"
            ? [widget.doctor['vendor_consultant_id'], widget.doctor['vendor_id']]
            : [widget.doctor['ihl_consultant_id'], widget.doctor['vendor_id']];
        var bodyGenix = jsonEncode(<String, dynamic>{
          'vendorIdList': [map[0]],
          "consultantIdList": [""],
        });
        var bodyIhl = jsonEncode(<String, dynamic>{
          'consultantIdList': [map[0]],
          "vendorIdList": [""],
        });
        final response = await _client.post(
          Uri.parse(API.iHLUrl + "/consult/profile_image_fetch"),
          body: map[1] == "GENIX" ? bodyGenix : bodyIhl,
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        );
        if (response.statusCode == 200) {
          var imageOutput = json.decode(response.body);
          var consultantImage, base64Image;
          var consultantIDAndImage =
              map[1] == 'GENIX' ? imageOutput["genixbase64list"] : imageOutput["ihlbase64list"];
          for (var i = 0; i < consultantIDAndImage.length; i++) {
            // if (widget.doctor['ihl_consultant_id'] ==
            if (map[0] == consultantIDAndImage[i]['consultant_ihl_id']) {
              base64Image = consultantIDAndImage[i]['base_64'].toString();
              base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
              base64Image = base64Image.replaceAll('}', '');
              base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
              if (this.mounted) {
                setState(() {
                  consultantImage = base64Image;
                  if (consultantImage == null || consultantImage == "") {
                    widget.doctor['profile_picture'] = AvatarImage.defaultUrl;
                  } else {
                    widget.doctor['profile_picture'] = consultantImage;
                  }
                });
              }
            }
          }
        } else {
          print(response.body);
        }
      }
    } catch (e) {
      print(e.toString());
      if (this.mounted) {
        widget.doctor['profile_picture'] = AvatarImage.defaultUrl;
      }
    }
  }

  void showProfile() {
    if (_isProfileVisible) {
      return;
    }
    if (this.mounted) {
      setState(() {
        _isCalendarVisible = true;
        _isProfileVisible = true;
        if (_isProfileVisible) {
          _controller.animateTo(_controller.offset + 100,
              duration: Duration(milliseconds: 800), curve: Curves.ease);
        }
      });
    }
  }

  String reviews(List list) {
    list ??= [];
    return '${list.length} reviews';
  }

  void showCalendar() {
    if (_isCalendarVisible) {
      return;
    }
    if (this.mounted) {
      setState(() {
        _isProfileVisible = false;
        _isCalendarVisible = true;
        if (_isCalendarVisible) {
          _controller.animateTo(_controller.offset + 100,
              duration: Duration(milliseconds: 800), curve: Curves.ease);
        }
      });
    }
  }

  nameTextSize() {
    var name = widget.doctor['name'].toString();
    if (name.length <= 18) {
      return 22.0;
    } else if (name.length <= 25) {
      return 19.0;
    }
    return 15.0;
  }

  expierienceText() {
    var expierience =
        widget.doctor['experience'].toString() == null || widget.doctor['experience'] == ""
            ? "N/A"
            : widget.doctor["experience"];
    return expierience;
  }

  specialitiesText() {
    List sp = widget.doctor['consultant_speciality'];
    var spString = "";
    for (int i = 0; i < sp.length; i++) {
      if (i != sp.length - 1) {
        spString = spString + sp[i] + ",";
      } else {
        spString = spString + sp[i];
      }
    }

    return spString;
  }

  List<Widget> specialities() {
    List sp = widget.doctor['consultant_speciality'];
    sp ??= [];
    return sp
        .map(
          (e) => FilterChip(
            label: Text(
              camelize(
                e.toString(),
              ),
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            padding: EdgeInsets.all(0),
            backgroundColor: AppColors.primaryAccentColor,
            onSelected: (bool value) {},
          ),
        )
        .toList();
  }

  List<Widget> languages() {
    List lang = widget.doctor['languages_Spoken'];
    lang ??= [];
    return lang
        .map(
          (e) => Visibility(
            visible: lang.contains("") ? false : true,
            child: FilterChip(
              label: Text(
                camelize(
                  e.toString(),
                ),
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
              padding: EdgeInsets.all(0),
              onSelected: (bool value) {},
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          Navigator.pop(context);
        },
        child: ScrollessBasicPageUI(
          appBar: Column(
            children: [
              SizedBox(
                width: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BackButton(
                  //   key: Key('bookAppointmentBackButton'),
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  //   color: Colors.white,
                  // ),
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.white,
                  ),
                  Flexible(
                    child: Center(
                      child: Text(
                        "Consultation",
                        // widget.doctor['livecall'] == false
                        //     ? AppTexts.teleConDashboardBook
                        //     : 'Live Call',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  )
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              controller: _controller,
              children: <Widget>[
                doctorInfo(),
                SizedBox(
                  height: 10.0,
                ),
                doctorAppointment(),
                doctorProfile(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showDoctorBusyDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text('Info'),
      content:
          Text('Consultant already has an appointment at this time. Please try after some time!'),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: AppColors.primaryColor,
          ),
          child: Text(
            'OK',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Map dataToSend() {
    final now = new DateTime.now().add(Duration(seconds: 60));
    print(now);
    String formattedDate = DateFormat.yMMMMd('en_US').format(now);
    // String formattedDate = DateFormat("MM/dd/yyyy hh:mm t").format(now);

    print(formattedDate);
    String formattedTime = DateFormat("hh:mm a").format(DateTime.now().add(Duration(seconds: 60)));
    print(formattedTime);
    String d_d = now.day.toString();
    String m_m = now.month.toString();
    m_m = MonthFormats.month_number_to_String[m_m];
    if (d_d.length == 1) {
      d_d = '0' + d_d;
    }
    String y_y = now.year.toString();
    formattedDate = d_d + 'th' + ' ' + m_m;
    return {
      'date': formattedDate,
      'time': formattedTime,
      'doctor': widget.doctor,
      'affiliationPrice': "none"
    };
  }

  Widget doctorInfo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Color(0xfff4f6fa)),
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: EdgeInsets.all(0),
            color: FitnessAppTheme.white, //Color(0xfff4f6fa),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: widget.doctor['profile_picture'] == null
                        ? null
                        : Image.memory(base64Decode(widget.doctor['profile_picture'])).image,
                    backgroundColor: AppColors.primaryAccentColor,
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              RichText(
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                softWrap: true,
                // maxLines: 1,
                textScaleFactor: 1,
                text: TextSpan(
                  text: widget.doctor['name'].toString() + " ",
                  style: TextStyle(
                    letterSpacing: 2.0,
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: nameTextSize(),
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: widget.doctor['qualification'] ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            fontSize: nameTextSize() - 5)),
                  ],
                ),
              ),
              // Text(
              //   widget.doctor['name'].toString(),
              //   style: TextStyle(
              //     letterSpacing: 2.0,
              //     color: AppColors.primaryColor,
              //     fontSize: nameTextSize(),
              //   ),
              // ),
              SizedBox(
                height: 5.0,
              ),
              RichText(
                text: TextSpan(
                    text: "Experience: ",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xff6D6E71),
                      fontSize: 16.0,
                    ),
                    children: [
                      TextSpan(
                        text: expierienceText(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xff6D6E71),
                          fontSize: 15.0,
                        ),
                      )
                    ]),
              ),
              SizedBox(
                height: 5.0,
              ),
              RichText(
                text: TextSpan(
                    text: "Speciality: ",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xff6D6E71),
                      fontSize: 16.0,
                    ),
                    children: [
                      TextSpan(
                        text: specialitiesText(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xff6D6E71),
                          fontSize: 15.0,
                        ),
                      )
                    ]),
              ),
              /*Wrap(
                direction: Axis.horizontal,
                children: specialities(),
                runSpacing: 0,
                spacing: 8,
              ),*/
              SizedBox(
                height: 5.0,
              ),
              SizedBox(
                height: 5.0,
              ),
              Wrap(
                direction: Axis.horizontal,
                children: languages(),
                runSpacing: 0,
                spacing: 8,
              ),
              Visibility(
                visible: widget.doctor['consultation_fees'].toString() != "0",
                child: Center(
                  child: Text(
                    '\u{20B9} ' +
                        widget.doctor['consultation_fees'].toString() +
                        ' Consultation fee',
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Color(0xff6D6E71),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              SmoothStarRating(
                  allowHalfRating: false,
                  onRated: (v) {},
                  starCount: 5,
                  rating: widget.doctor['ratings'].runtimeType != double
                      ? double.tryParse(widget.doctor['ratings'])
                      : widget.doctor['ratings'] ?? 0,
                  size: 30.0,
                  isReadOnly: true,
                  color: Colors.amberAccent,
                  borderColor: Colors.grey,
                  spacing: 0.0),
              SizedBox(
                height: 5.0,
              ),
              Center(
                child: Text(
                  reviews(widget.doctor['text_reviews_data']),
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Color(0xff6D6E71),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              widget.doctor['livecall'] == true && widget.doctor['live_call_allowed'] == true
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // widget.doctor['livecall'] == true?
                        //Loading symbol for Live Call 🏳‍🌈
                        loading
                            ? Text(
                                "Please wait\n while we check the availability",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.blue),
                              )
                            : ClipOval(
                                child: Material(
                                  color: loading
                                      ? Colors.white
                                      : ((widget.doctor['availabilityStatus'] == 'Online' ||
                                                  widget.doctor['availabilityStatus'] ==
                                                      'online') &&
                                              doctorHasAppointment != true)
                                          ? callButtonColor
                                          : Colors.grey, // button color
                                  child: InkWell(
                                    splashColor: Colors.lightGreen, // inkwell color
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: loading
                                          ? CircularProgressIndicator()
                                          : Icon(
                                              Icons.phone,
                                              color: Colors.white,
                                            ),
                                    ),
                                    onTap: doctorHasAppointment == true
                                        ? () {
                                            showDoctorBusyDialog(context);
                                          }
                                        : (widget.doctor['availabilityStatus'] == 'Online' ||
                                                widget.doctor['availabilityStatus'] == 'online')
                                            ? () {
                                                if (widget.doctor['livecall'] &&
                                                    doctorHasAppointment == false) {
                                                  Navigator.of(context).pushNamed(
                                                    Routes.ConfirmVisit,
                                                    arguments: dataToSend(),
                                                  );
                                                }
                                                // else {
                                                //   if (this.mounted) {
                                                //     setState(() {
                                                //       widget.doctor['livecall'] =
                                                //           true;
                                                //       Navigator.of(context).pushNamed(
                                                //         Routes.ConfirmVisit,
                                                //         arguments: dataToSend(),
                                                //       );
                                                //     });
                                                //   }
                                                // }
                                              }
                                            : () {},
                                    // ,
                                  ),
                                ),
                              ),
                        /*: ClipOval(
                          child: Material(
                            color: !_isCalendarVisible
                                ? calenderButtonColor
                                : Colors.green, // button color
                            child: InkWell(
                              splashColor: Colors.red, // inkwell color
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                showAlertDialog(context);
                                new Future.delayed(new Duration(seconds: 15),
                                    () {
                                  showCalendar();
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ),
                        ),*/
                      ],
                    )
                  : SizedBox(
                      height: 0,
                    ),
              SizedBox(
                height: 20,
              )
            ]),
          ),
          Positioned(
            top: -25,
            left: -55,
            child: Transform.rotate(
              angle: -pi / 4,
              child: Container(
                color: avail(),
                child: SizedBox(
                  width: 150,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 70,
                      ),
                      Center(
                        child: Text(
                          camelize(doctorHasAppointment == true
                              ? 'Busy'
                              : widget.doctor['availabilityStatus'].toString()),
                          style: TextStyle(color: Colors.white),
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
    );
  }

  // Future<bool> _booklater(BuildContext context) {
  //   return showDialog(
  //         context: context,
  //         child: AlertDialog(
  //           title: Column(
  //             children: [
  //               Text(
  //                 'This consultant now currently unavailable for live call !\n',
  //                 textAlign: TextAlign.center,
  //               ),
  //               Text(
  //                 'Would you like to book appointment at later time?',
  //                 style: TextStyle(color: AppColors.primaryColor),
  //                 textAlign: TextAlign.center,
  //               ),
  //               SizedBox(height: 8),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 40),
  //                 child: ElevatedButton(
  //                   color: AppColors.primaryColor,
  //                   child: Text(
  //                     'Book Appointment',
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                     showCalendar();
  //                   },
  //                 ),
  //               ),
  //               SizedBox(height: 6),
  //               InkWell(
  //                 onTap: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text(
  //                   'Try later',
  //                   style: new TextStyle(
  //                       fontSize: 14,
  //                       color: AppColors.primaryColor,
  //                       fontWeight: FontWeight.w600),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ) ??
  //       false;
  // }

  Widget doctorProfile() {
    return _isProfileVisible
        ? Visibility(
            visible: _isProfileVisible &&
                widget.doctor['description']
                        .toString()
                        .replaceAll('&lt;p&gt;', '')
                        .replaceAll('&lt;br&gt;', '')
                        .replaceAll('&lt;/p&gt;', '')
                        .replaceAll('&amp;nbsp;', '')
                        .replaceAll('&#39;', "'")
                        .replaceAll('&amp;amp#39', "'")
                        .trim() !=
                    "",
            child: Card(
              key: profile,
              elevation: 2,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Color(0xfff4f6fa)),
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: FitnessAppTheme.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 30.0,
                        color: AppColors.primaryAccentColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Profile",
                          style: TextStyle(
                            color: AppColors.primaryAccentColor,
                            fontSize: 22.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    widget.doctor['description']
                        .toString()
                        .replaceAll('&lt;p&gt;', '')
                        .replaceAll('&lt;br&gt;', '')
                        .replaceAll('&lt;/p&gt;', '')
                        .replaceAll('&amp;nbsp;', '')
                        .replaceAll('&#39;', "'")
                        .replaceAll('&amp;amp#39', "'"),
                    style: TextStyle(height: 2),
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 30.0,
                        color: AppColors.primaryAccentColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Reviews",
                          style: TextStyle(
                            color: AppColors.primaryAccentColor,
                            fontSize: 22.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  widget.doctor['text_reviews_data'].length == 0
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("No Reviews yet"),
                        )
                      : Container(
                          height: 205.0,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ConsultantReviews(
                              reviews: widget.doctor['text_reviews_data'] ?? [],
                            ),
                          ),
                        ),
                ]),
              ),
            ),
          )
        : SizedBox();
  }

  Widget doctorAppointment() {
    return _isCalendarVisible
        ? Visibility(
            visible: _isCalendarVisible,
            child: SelectAppSlot(
              next30: next30,
              consultant: widget.doctor,
              isFetching: _isFetching,
              companyName: "none",
              affiliationPrice: "empty",
            ),
          )
        : SizedBox();
  }

  TimeOfDay timeConvert(String normTime) {
    int hour;
    int minute;
    DateTime convertedTime = DateFormat.jm().parse(normTime);
    hour = convertedTime.hour;
    minute = convertedTime.minute;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
