import 'dart:async';
import 'dart:convert';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/CrossbarUtil.dart' as s;
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/screens.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:ihl/widgets/teleconsulation/payment/paymentUI.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../new_design/presentation/pages/onlineServices/MyAppointment.dart';

class CallWaitingScreen extends StatefulWidget {
  final List appointmentDetails;

  CallWaitingScreen({Key key, this.appointmentDetails}) : super(key: key);

  @override
  _CallWaitingScreenState createState() => _CallWaitingScreenState();
}

class _CallWaitingScreenState extends State<CallWaitingScreen> {
  http.Client _client = http.Client(); //3gb
  bool loading = true;
  bool success = false;
  var callStatus;
  Session session1;
  Client client;
  bool showMissedCallMessage = false;
  bool callDeclinedByDoctor = false;

  void connect() async {
    client = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
  }

  void appointmentSubscribe() async {
    if (session1 != null) {
      session1.close();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ihl_user_id = prefs.getString('ihlUserId');
    connect();
    session1 = await client.connect().first;
    try {
      final subscription = await session1.subscribe('ihl_send_data_to_user_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) {
        Map<String, dynamic> data = event.arguments[0];

        var status = data['data']['cmd'];
        List receiverId = [];
        if (data.containsKey("receiver_id")) {
          receiverId = data["receiver_id"];
        }
        if (data.containsKey("receiver_ids")) {
          receiverId = data["receiver_ids"];
        }
        // if (receiverId.contains(prefs.get("IHL_User_ID"))) {
        if (receiverId.contains(ihl_user_id)) {
          if (status == 'CallAcceptedByDoctor') {
            session1.close();
            callStatusUpdate(widget.appointmentDetails[0].toString(), 'on_going');
            setState(() {
              loading = false;
              success = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.offNamedUntil(Routes.ConsultVideo, (route) => false, arguments: [
                  widget.appointmentDetails[0].toString().replaceAll("ihl_consultant_", ""),
                  widget.appointmentDetails[1],
                  widget.appointmentDetails[2],
                  "LiveCall",
                ]);
              });
            });
          } else if (status == 'CallDeclinedByDoctor') {
            if (mounted)
              setState(() {
                loading = false;
                success = false;
                callDeclinedByDoctor = true;
              });
            /*Get.dialog(
              AlertDialog(
                title: Column(
                  children: [
                    Text(
                      'Consultant has declined your Call.\n\nYour Refund will be initiated.',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        color: AppColors.primaryColor,
                        child: Text(
                          'View Details',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Get.to(MyAppointments(
                            isHighlight: true,
                          ));
                        },
                      ),
                    ),
                    SizedBox(height: 6),
                  ],
                ),
              ),
              barrierDismissible: false);*/
          }
        }
      });
      await subscription.onRevoke
          .then((reason) => print('The server has killed my subscription due to: ' + reason));
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  Future<bool> _onBackPressed() {
    return (loading == true)
        ? showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Column(
                      children: [
                        Text(
                          'Info !\n',
                          style: TextStyle(color: AppColors.primaryColor),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Please wait while the Consultant Joins...',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: AppColors.primaryColor,
                            ),
                            child: Text(
                              'Okay',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }) ??
            false
        : true;
  }

  //Method to get appointment details to check on going call only for book appoitments
  void appointmentDetails(String callStatus) {
    if (callStatus == 'on_going') {
      setState(() {
        loading = false;
        success = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamedUntil(Routes.ConsultVideo, (route) => false, arguments: [
            widget.appointmentDetails[0],
            widget.appointmentDetails[1],
            widget.appointmentDetails[2],
            "appointmentCall",
          ]);
        });
      });
    } else {
      callStatusUpdate(widget.appointmentDetails[0].toString(), 'on_going');
      setState(() {
        loading = false;
        success = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamedUntil(Routes.ConsultVideo, (route) => false, arguments: [
            widget.appointmentDetails[0],
            widget.appointmentDetails[1],
            widget.appointmentDetails[2],
            "appointmentCall",
          ]);
        });
      });
    }
  }

  startTimerFor45Seconds() async {
    showMissedCallMessage = false;
    var _duration = new Duration(seconds: 45 ?? 0);
    return new Timer(_duration, missedCallMessage);
  }

  void missedCallMessage() {
    if (success == false && callDeclinedByDoctor == false) {
      setState(() {
        showMissedCallMessage = true;
        var _duration = new Duration(seconds: 5 ?? 0);
        return new Timer(_duration, navigationMessage);
      });
    }
  }

  void navigationMessage() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => MyAppointment(
                  backNav: false,
                )),
        (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    callDeclinedByDoctor = false;
    super.initState();
    if (widget.appointmentDetails[3] == "appointmentCall") {
      callStatus = widget.appointmentDetails[4];
      appointmentDetails(callStatus);
    } else if (widget.appointmentDetails[3] == "SubscriptionCall") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offNamedUntil(Routes.ConsultVideo, (route) => false, arguments: [
          widget.appointmentDetails[0],
          widget.appointmentDetails[1],
          widget.appointmentDetails[2],
          'SubscriptionCall',
          widget.appointmentDetails[4]
        ]);
      });
    } else if (widget.appointmentDetails[3] == "LiveCall") {
      List<String> receiverIds = [];
      receiverIds.add(widget.appointmentDetails[1]);
      startTimerFor45Seconds();
      appointmentSubscribe();
      s.publishCallDetails(
        'NewLiveAppointment',
        receiverIds,
        widget.appointmentDetails[2],
        widget.appointmentDetails[0].toString().replaceAll("ihl_consultant_", ""),
        widget.appointmentDetails[4],
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: PaymentUI(
        color: (loading == false && success == true)
            ? AppColors.bookApp
            : ((loading == false && success == false) || showMissedCallMessage == true)
                ? Colors.red
                : AppColors.myApp,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            (loading == false && success == true)
                ? 'Call Connected !'
                : (loading == false && success == true)
                    ? 'Call Declined!'
                    : (loading == false && success == false && callDeclinedByDoctor == true)
                        ? 'Call Declined!'
                        : (showMissedCallMessage == true)
                            ? 'Connecting Consultant Failed'
                            : 'Waiting for consultant to join ...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: (loading == false) || (widget.appointmentDetails[3] != "LiveCall")
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed(Routes.MyAppointments),
                  color: Colors.white,
                  tooltip: 'Back',
                )
              : Container(),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              (loading == false && success == true)
                  ? Lottie.network(API.callAcceptedLottieFileUrl, height: 300, width: 300)
                  : (showMissedCallMessage == true || callDeclinedByDoctor == true)
                      ? Lottie.network(API.declinedLottieFileUrl, height: 300, width: 300)
                      : (loading == true && success == false)
                          ? Lottie.network(
                              'https://assets5.lottiefiles.com/packages/lf20_e5fibvuv.json',
                              height: 400,
                              width: 400)
                          : '',
              Container(
                child: (loading == false && success == false && callDeclinedByDoctor == true)
                    ? Text('Sorry. The consultant declined the call. \nWere initiating the refund.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                        ))
                    : (widget.appointmentDetails[3] != "LiveCall")
                        ? Text(
                            'The consultant will join 5 minutes prior to the scheduled appointment.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          )
                        : widget.appointmentDetails[3] == "LiveCall"
                            ? (showMissedCallMessage == true || callDeclinedByDoctor == true)
                                ? Text(
                                    "Consultant is currently busy. Please rejoin the call via 'My Appointments'",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    'Please wait while the Consultant Joins...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  )
                            : null,
              ),
              SizedBox(height: 30),
              (loading == false && success == false)
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.myApp,
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewallTeleDashboard(
                                      backNav: true,
                                    )),
                            (Route<dynamic> route) => false);
                      },
                      child: Text(
                        "Take Me to Dashboard",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  callStatusUpdate(String appointmentID, String appStatus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiToken = prefs.get('auth_token');
    final response = await _client.get(
      Uri.parse(API.iHLUrl +
          '/consult/update_call_status?appointment_id=' +
          appointmentID +
          '&call_status=' +
          appStatus),
      headers: {'ApiToken': apiToken},
    );
    if (response.statusCode == 200) {
      var parsedString = response.body.replaceAll('&quot', '"');
      var parsedString1 = parsedString.replaceAll(";", "");
      var parsedString2 = parsedString1.replaceAll('"{', '{');
      var parsedString3 = parsedString2.replaceAll('}"', '}');
      var callStatusUpdate = json.decode(parsedString3);
      String apiResponse = callStatusUpdate['status'].toString();
      if (apiResponse == 'Update Sucessfull') {
        print('call status is made as "ONGOING" from My Appointment join call button');
      } else {
        print(
            'update_call_status <>><><>FAILED<><>><><> call status is made as "ONGOING" from My Appointment join call button');
      }
    }
  }
}
