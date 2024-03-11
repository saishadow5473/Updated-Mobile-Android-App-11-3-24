import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/repositories/book_appointment_pagination_api.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/dateFormat.dart';
import 'package:ihl/views/teleconsultation/doctor_reviews.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:ihl/widgets/teleconsulation/SelectSlot.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:strings/strings.dart';

class BookAppointmentForAffiliation extends StatefulWidget {
  final Map doctor;
  final String companyName;

  BookAppointmentForAffiliation({this.doctor, this.companyName});

  @override
  _BookAppointmentForAffiliationState createState() => _BookAppointmentForAffiliationState();
}

class _BookAppointmentForAffiliationState extends State<BookAppointmentForAffiliation> {
  http.Client _client = http.Client(); //3gb
  String ihlConsultantID;
  String vendorID;
  List next30;
  String consultantAvailabilityURL;
  bool loading = true;

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

  String affiliationMrp;
  String affiliationPrice;

  String status;
  Client client;
  Session session1;

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
    if (session1 != null) {
      session1.close();
    }
    connect();
    var doctorId = widget.doctor['ihl_consultant_id'];
    session1 = await client.connect().first;
    try {
      final subscription = await session1.subscribe('ihl_update_doctor_status_channel',
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
    if (status == 'Busy' || status == 'busy') {
      color = Colors.red;
    }
    if (status == 'Offline' || status == 'offline') {
      color = Colors.grey;
    }
    return color;
  }

  getMrpAndPriceForAffiliation() {
    var consultant = widget.doctor;
    var affiliationArrayMap = consultant['affilation_excusive_data']['affilation_array'];
    var index;
    for (int i = 0; i <= affiliationArrayMap.length - 1; i++) {
      print(widget.companyName);
      if (affiliationArrayMap[i]['affilation_unique_name'] == widget.companyName ||
          affiliationArrayMap[i]['affilation_name'] == widget.companyName) {
        index = i;
      }
    }
    var affiliationMap = affiliationArrayMap.asMap();
    affiliationMrp = affiliationMap[index]['affilation_mrp'];
    affiliationPrice = affiliationMap[index]['affilation_price'];
  }

  Future getDataBookAppointments() async {
    print('Start databook Time ${DateTime.now()}');

    var subscriptionsDetails;

    // final response = await _client.get(
    //   Uri.parse(API.iHLUrl +
    //       '/consult/view_all_book_appointment?ihl_consultant_id=' +
    //       widget.doctor['ihl_consultant_id']),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'ApiToken': '${API.headerr['ApiToken']}',
    //     'Token': '${API.headerr['Token']}',
    //   },
    // );
    final paginationData =
        await RemoteApi.getCharacterList(0, widget.doctor['ihl_consultant_id'], end_index: 50);
    if (paginationData != null) {
      print('Getting Response Time ${DateTime.now()}');
      var reasonForVisit = paginationData[2];
      List<dynamic> appointments = paginationData[0];
      for (int i = 0; i < reasonForVisit.length; i++) {
        appointments[i]['Book_Apointment']['reason_for_visit'] =
            reasonForVisit[i]['reason_for_visit'];
        appointments[i]['Book_Apointment']['alergy'] = reasonForVisit[i]['alergy'];
        appointments[i]['Book_Apointment']['notes'] = reasonForVisit[i]['notes'];
      }
      subscriptionsDetails = appointments;

      // List<dynamic> subscriptions = json.decode(finalOutput);
      // // subscriptions[0]['Book_Appointment'].length
      // for (int i = 0; i < reasonForVisit.length; i++) {
      //   subscriptions[i]['Book_Apointment']['reason_for_visit'] =
      //       reasonForVisit[i]['reason_for_visit'];
      //   subscriptions[i]['Book_Apointment']['alergy'] =
      //       reasonForVisit[i]['alergy'];
      //   subscriptions[i]['Book_Apointment']['notes'] =
      //       reasonForVisit[i]['notes'];
      // }
      // subscriptionsDetails = subscriptions;
      ///
      // List<DateTime> formattedTime = [];
      // List<String> stringFormattedDateTime = [];
      // for (int i = 0; i < subscriptionsDetails.length; i++) {
      //   String date = subscriptionsDetails[i]['Book_Apointment']
      //       ["appointment_start_time"];
      //   String stringTime = date.substring(11, 19);
      //   date = date.substring(0, 10);
      //   DateTime formattime = DateFormat.jm().parse(stringTime);
      //   String time = DateFormat("HH:mm:ss").format(formattime);
      //   String dateToFormat = date + " " + time;
      //   var newTime = DateTime.parse(dateToFormat);
      //   formattedTime.add(newTime);
      // }
      // formattedTime.sort((a, b) => b.compareTo(a));
      //
      // List appointmentDetails = [];
      // List temp = [];
      // sort(List subscriptionsDetails) {
      //   if (subscriptionsDetails == null || subscriptionsDetails.length == 0)
      //     return;
      //   for (int i = 0; i < subscriptionsDetails.length; i++) {
      //     String stringFormattedTime =
      //         DateFormat("yyyy-MM-dd hh:mm aaa").format(formattedTime[i]);
      //     stringFormattedDateTime.add(stringFormattedTime);
      //     temp.add(subscriptionsDetails[i]['Book_Apointment']
      //         ["appointment_start_time"]);
      //   }
      //   for (int i = 0; i < stringFormattedDateTime.length; i++) {
      //     if (temp.contains(stringFormattedDateTime[i])) {
      //       int ii = temp.indexOf(stringFormattedDateTime[i]);
      //       appointmentDetails.add(subscriptionsDetails[ii]);
      //     }
      //   }
      // }
      //
      // sort(subscriptionsDetails);
      // subscriptionsDetails = appointmentDetails;
      DateTime current = DateTime.now();
      var appDetails = [];

      for (int i = 0; i < subscriptionsDetails.length; i++) {
        //  if (subscriptionsDetails[i] != null) {
        String date = subscriptionsDetails[i]['Book_Apointment']["appointment_start_time"];
        String callStatus = subscriptionsDetails[i]['Book_Apointment']['call_status'];
        String stringTime;
        try {
          stringTime = date.substring(11, 19);
        } catch (e) {
          stringTime = date.substring(11, 18);
        }
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
      print('After Filtering Time ${DateTime.now()}');

      return appDetails;
    } else {
      print(paginationData + '< pagination data is nulll');
    }
  }

  Future getAvailableSlot() async {
    print('Start Time ${DateTime.now()}');
    var existingAppointments = await getDataBookAppointments();
    print('End Time ${DateTime.now()}');

    ihlConsultantID = widget.doctor['ihl_consultant_id'];
    vendorID = widget.doctor['vendor_id'];
    consultantAvailabilityURL = API.iHLUrl +
        // "/consult/consultant_timings_live_availablity?ihl_consultant_id=" +
        // ihlConsultantID +
        // "&vendor_id=" +
        // vendorID;
        "/consult/consultant_timings_live_availablity_mobile?ihl_consultant_id=$ihlConsultantID&vendor_id=$vendorID";
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

      // List<dynamic> filtered = [];
      // for (int i = 0; i <= testm[0]['today'].length - 1; i++) {
      //   TimeOfDay tt = timeConvert(testm[0]['today'][i]);
      //   TimeOfDay t = TimeOfDay.now();
      //   final now = new DateTime.now();
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
      // }
      // var filteredToday = {'today': filtered};
      // next30.removeAt(0);
      // next30.insert(0, filteredToday);

      if (this.mounted) {
        setState(() {
          _isFetching = true;
        });
      }
    } else {
      print(response.body);
    }
  }

  bool _isLoading = false;
  @override
  void initState() {
    getAvailableSlot();

    update();
    getMrpAndPriceForAffiliation();
    if (widget.doctor['livecall'] == true) {
      _isProfileVisible = true;
    } else {
      _isCalendarVisible = true;
    }
    showProfile();
    Timer(Duration(seconds: 2), () {
      setState(() {
        _isLoading = true;
      });
    });
    super.initState();
  }

  void showProfile() {
    if (_isProfileVisible) {
      return;
    }
    if (this.mounted) {
      setState(() {
        _isCalendarVisible = false;
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
    return ScrollessBasicPageUI(
      appBar: Column(
        children: [
          SizedBox(
            width: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    widget.doctor['livecall'] == false
                        ? AppTexts.teleConDashboardBook
                        : 'Consultation',
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
    );
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: SingleChildScrollView(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text("Please wait while we are fetching"),
            // Text("While we are fetching"),
            // Text("the available slots!"),
            SizedBox(
              height: 5.0,
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
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
    final now = new DateTime.now();
    String formattedDate = DateFormat.yMMMMd('en_US').format(now);
    String d_d = now.day.toString();
    String m_m = now.month.toString();
    m_m = MonthFormats.month_number_to_String[m_m];
    if (d_d.length == 1) {
      d_d = '0' + d_d;
    }
    String y_y = now.year.toString();

    String formattedTime = DateFormat("hh:mm a").format(DateTime.now());
    formattedDate = d_d + 'th' + ' ' + m_m;
    return {
      'date': formattedDate,
      'time': formattedTime,
      'doctor': widget.doctor,
      'affiliationPrice': widget.companyName != null ? affiliationPrice : 'none',
    };
  }

  Widget doctorInfo() {
    print(widget.doctor['livecall'].toString() +
        "&&&&&" +
        widget.doctor['live_call_allowed'].toString());
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.all(0),
            color: Color(0xfff4f6fa),
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
              Text(
                widget.doctor['name'].toString(),
                style: TextStyle(
                  letterSpacing: 2.0,
                  color: AppColors.primaryColor,
                  fontFamily: 'Poppins',
                  fontSize: nameTextSize(),
                ),
              ),
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
                visible: affiliationPrice.toString() != "0",
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'M.R.P.: ',
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Color(0xff6D6E71),
                        ),
                      ),
                      Text(
                        '\u{20B9} ' + affiliationMrp.toString(),
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 22.0,
                          color: Color(0xff6D6E71),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: affiliationPrice.toString() != "0",
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Fees: ' + '\u{20B9} ' + affiliationPrice.toString(),
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Color(0xff6D6E71),
                        ),
                      ),
                    ],
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
                  rating: widget.doctor['ratings'] ?? 0,
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
                height: 10.0,
              ),
              widget.doctor['livecall'] == true && widget.doctor['live_call_allowed'] == true
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // widget.doctor['livecall'] == true?
                        _isLoading
                            ? ClipOval(
                                child: Material(
                                  color: (widget.doctor['availabilityStatus'] == 'Online' ||
                                          widget.doctor['availabilityStatus'] == 'online')
                                      ? callButtonColor
                                      : Colors.grey, // button color
                                  child: InkWell(
                                    splashColor: Colors.lightGreen, // inkwell color
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: (widget.doctor['availabilityStatus'] == 'Online' ||
                                            widget.doctor['availabilityStatus'] == 'online')
                                        ? () {
                                            if (widget.doctor['livecall']) {
                                              Navigator.of(context).pushNamed(
                                                Routes.ConfirmVisit,
                                                arguments: dataToSend(),
                                              );
                                            } else {
                                              if (this.mounted) {
                                                setState(() {
                                                  widget.doctor['livecall'] = true;
                                                  Navigator.of(context).pushNamed(
                                                    Routes.ConfirmVisit,
                                                    arguments: dataToSend(),
                                                  );
                                                });
                                              }
                                            }
                                          }
                                        : () {},
                                  ),
                                ),
                              )
                            : Container(
                                child: Center(
                                  child: Text(
                                    "Please wait\n while we check the availability",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.blue),
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
                height: 30,
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
                          camelize(widget.doctor['availabilityStatus'].toString()),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Color(0xfff4f6fa),
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
                  Container(
                    width: 100.w,
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 16),
                    child: Text(
                      widget.doctor['description']
                          .toString()
                          .trimLeft()
                          .replaceAll("&#39;", "")
                          .replaceAll('&amp;', '&')
                          .replaceAll('&quot;', '"'),
                      style: TextStyle(height: 2),
                      textAlign: TextAlign.justify,
                    ),
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
              companyName: widget.companyName,
              affiliationPrice: affiliationPrice,
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
