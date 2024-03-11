import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/teleconsultation/genixWebView.dart';
import 'package:ihl/views/teleconsultation/myAppointments.dart';
import 'package:ihl/widgets/teleconsulation/share_from_my_appointment.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:ihl/utils/CrossbarUtil.dart' as s;

import '../../new_design/presentation/pages/onlineServices/MyAppointment.dart';

// ignore: must_be_immutable
class DashBoardAppointmentTile extends StatefulWidget {
  final items;
  final int index;

  final String ihlConsultantId;
  final String name;
  final String date;
  final String endDateTime;
  final String consultationFees;
  bool isPending;
  bool isApproved;
  bool isRejected;
  final bool isCancelled;
  final bool isCompleted;
  final String appointmentId;
  final String callStatus;
  final String vendorId;
  String profilePic;

  var isCancelledByDoc;
  List<String> sharedReportAppIdList;

  DashBoardAppointmentTile({
    this.items,
    this.index,
    this.ihlConsultantId,
    this.name,
    this.date,
    this.endDateTime,
    this.consultationFees,
    this.isPending,
    this.isApproved,
    this.isRejected,
    this.isCancelled,
    this.isCancelledByDoc,
    this.isCompleted,
    this.appointmentId,
    this.callStatus,
    this.vendorId,
    this.sharedReportAppIdList,
    this.profilePic,
  });

  @override
  _DashBoardAppointmentTileState createState() => _DashBoardAppointmentTileState();

  toList() {}
}

class _DashBoardAppointmentTileState extends State<DashBoardAppointmentTile> {
  http.Client _client = http.Client(); //3gb
  String genixURL;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool isChecking = false;
  bool makeValidateVisible = false;
  final reasonController = TextEditingController();
  bool cancelled = false;
  bool enableJoinCall = false;
  String doctorStatus = 'Offline';
  String currentAppointmentStatus;
  var doctorId;
  var errorMessage = 'You can join the call at least 5 mins before appointment start time';

  Session session1, session;
  Client client;

  String iHLUserId;

  var consultantIDAndImage = [];
  var base64Image;
  var consultantImage;
  var image;

  Future getConsultantImageURL() async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/profile_image_fetch"),
      body: jsonEncode(<String, dynamic>{
        'consultantIdList': [widget.ihlConsultantId],
      }),
    );
    if (response.statusCode == 200) {
      var imageOutput = json.decode(response.body);
      consultantIDAndImage = imageOutput["ihlbase64list"];
      for (var i = 0; i < consultantIDAndImage.length; i++) {
        if (widget.ihlConsultantId == consultantIDAndImage[i]['consultant_ihl_id']) {
          base64Image = consultantIDAndImage[i]['base_64'].toString();
          base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
          base64Image = base64Image.replaceAll('}', '');
          base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
          if (this.mounted) {
            setState(() {
              consultantImage = base64Image;
            });
          }
          if (consultantImage == null || consultantImage == "") {
            widget.profilePic = AvatarImage.defaultUrl;
            image = Image.memory(base64Decode(widget.profilePic));
          } else {
            widget.profilePic = consultantImage;
            image = Image.memory(base64Decode(widget.profilePic));
          }
        }
      }
    } else {
      print(response.body);
    }
  }

  void connect() async {
    client = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
  }

  void subscribeAppointmentApproved() async {
    if (session1 != null) {
      session1.close();
    }
    connect();
    session1 = await client.connect().first;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var data = prefs.get('data');
    Map res = jsonDecode(data);
    iHLUserId = res['User']['id'];

    try {
      final subscription = await session1.subscribe('ihl_send_data_to_user_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) async {
        Map<String, dynamic> data = event.arguments[0];
        var receivedAppointmentId = data['data']['appointment_id'];
        var status = data['data']['status'];
        if (widget.appointmentId == receivedAppointmentId) {
          if (status == 'Approved') {
            if (this.mounted) {
              setState(() {
                widget.isApproved = true;
                widget.isPending = false;
              });
            }
            // Updating getUserDetails API
          }

          if (status == 'Rejected') {
            if (this.mounted) {
              setState(() {
                widget.isApproved = false;
                widget.isRejected = true;
                widget.isPending = false;
              });
            }
            // Updating getUserDetails API
          }
          if (status == 'CancelAppointment') {
            if (this.mounted) {
              setState(() {
                widget.isApproved = false;
                widget.isRejected = false;
                widget.isPending = false;
                widget.isCancelledByDoc = true;
                cancelled = true;
              });
            }
            // Updating getUserDetails API
          }
        }
      });
      await subscription.onRevoke
          .then((reason) => print('The server has killed my subscription due to: ' + reason));
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  Text status() {
    if (widget.isPending == true) {
      return Text(
        AppTexts.myAppointmentReqPen,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.0,
        ),
      );
    }
    if (widget.isCompleted == true) {
      return Text(
        "Appointment Completed",
        style: TextStyle(color: Colors.green, fontSize: ScUtil().setSp(11)),
      );
    }
    if (widget.isApproved == true) {
      return Text(
        'Status: Request Approved',
        style: TextStyle(color: Colors.white, fontSize: ScUtil().setSp(11)),
      );
    }
    if (widget.isRejected == true) {
      return Text(
        "Appointment Rejected by Consultant",
        style: TextStyle(color: Colors.red, fontSize: ScUtil().setSp(11)),
      );
    }
    if (widget.isCancelled == true || cancelled == true) {
      return Text(
        "Appointment Cancelled ",
        style: TextStyle(color: Colors.red, fontSize: ScUtil().setSp(11)),
      );
    }
    if (widget.isCancelledByDoc == true || cancelled == true) {
      return Text(
        "Appointment Cancelled ",
        style: TextStyle(color: Colors.red, fontSize: ScUtil().setSp(11)),
      );
    }
    return Text(
      AppTexts.myAppointmentReqPen,
      style: TextStyle(color: AppColors.primaryAccentColor, fontSize: ScUtil().setSp(11)),
    );
  }

  void httpStatus() async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/getConsultantLiveStatus'),
      body: jsonEncode(<String, dynamic>{
        "consultant_id": [widget.ihlConsultantId.toString()]
      }),
    );
    if (response.statusCode == 200) {
      if (response.body != '"[]"') {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString1 = parsedString.replaceAll(";", "");
        var parsedString2 = parsedString1.replaceAll('"[', '[');
        var parsedString3 = parsedString2.replaceAll(']"', ']');
        var finalOutput = json.decode(parsedString3);
        var doctorId = widget.ihlConsultantId;
        if (doctorId == finalOutput[0]['consultant_id']) {
          doctorStatus = camelize(finalOutput[0]['status'].toString());
          if (this.mounted) {
            setState(() {
              if (doctorStatus == null ||
                  doctorStatus == "" ||
                  doctorStatus == "null" ||
                  doctorStatus == "Null") {
                doctorStatus = "Offline";
              } else {
                doctorStatus = camelize(finalOutput[0]['status'].toString());
              }
            });
          }
        }
      } else {}
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  currentAppointmentStatusUpdate(String appointmentID, String appStatus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiToken = prefs.get('auth_token');
    final response = await _client.get(
      Uri.parse(API.iHLUrl +
          '/consult/update_appointment_status?appointment_id=' +
          appointmentID +
          '&appointment_status=' +
          appStatus),
      headers: {'ApiToken': apiToken},
    );
    var parsedString = response.body.replaceAll('&quot', '"');
    var parsedString1 = parsedString.replaceAll(";", "");
    var parsedString2 = parsedString1.replaceAll('"{', '{');
    var parsedString3 = parsedString2.replaceAll('}"', '}');
    var currentAppointmentStatusUpdate = json.decode(parsedString3);
    if (currentAppointmentStatusUpdate == 'Database Updated') {
      if (this.mounted) {
        setState(() {
          currentAppointmentStatus = appStatus;
        });
      }
    } else {}
  }

  void cancelAppointment(var canceledBy, var appointId, var reason) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var data = prefs.get('data');
    Map res = jsonDecode(data);
    iHLUserId = res['User']['id'];
    var transcationId;

    var apiToken = prefs.get('auth_token');
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/cancel_appointment'),
      headers: {'ApiToken': apiToken},
      body: jsonEncode(<String, dynamic>{
        "canceled_by": canceledBy.toString(),
        "ihl_appointment_id": appointId.toString(),
        "reason": reason.toString(),
      }),
    );
    if (response.statusCode == 200) {
      if (response.body != '"[]"') {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString1 = parsedString.replaceAll(";", "");
        var parsedString2 = parsedString1.replaceAll('"[', '[');
        var parsedString3 = parsedString2.replaceAll(']"', ']');
        var finalOutput = json.decode(parsedString3);
        var status = finalOutput["status"];
        var refundAmount = finalOutput["refund_amount"];
        if (status == "cancel_success") {
          final transresponce = await _client.get(
              Uri.parse(API.iHLUrl + "/consult/user_transaction_from_ihl_id?ihl_id=" + iHLUserId));
          if (transresponce.statusCode == 200) {
            if (transresponce.body != "[]" || transresponce.body != null) {
              var transcationList = json.decode(transresponce.body);
              for (int i = 0; i <= transcationList.length - 1; i++) {
                if (transcationList[i]["ihl_appointment_id"] == appointId) {
                  transcationId = transcationList[i]["transaction_id"];
                }
              }
              final responsetrans = await _client.get(Uri.parse(API.iHLUrl +
                  '/consult/update_refund_status?transaction_id=' +
                  transcationId +
                  '&refund_status=Initated'));
              if (responsetrans.statusCode == 200) {
                if (responsetrans.body == '"Refund Status Update Success"') {
                  if (this.mounted) {
                    setState(() {
                      isChecking = false;
                    });
                  }
                  currentAppointmentStatusUpdate(widget.appointmentId, "Canceled");
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  var data = prefs.get('data');
                  Map res = jsonDecode(data);

                  List<String> receiverIds = [];
                  receiverIds.add(widget.ihlConsultantId.toString());
                  s.appointmentPublish('GenerateNotification', 'CancelAppointment', receiverIds,
                      iHLUserId, widget.appointmentId);
                  AwesomeDialog(
                          context: context,
                          animType: AnimType.TOPSLIDE,
                          headerAnimationLoop: true,
                          dialogType: DialogType.SUCCES,
                          dismissOnTouchOutside: false,
                          title: 'Success!',
                          desc:
                              'Appointment Successfully Cancelled! Your Refund has been Initiated.',
                          btnOkOnPress: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyAppointment(
                                          backNav: false,
                                        )),
                                (Route<dynamic> route) => false);
                          },
                          btnOkColor: Colors.green,
                          btnOkText: 'Proceed',
                          btnOkIcon: Icons.check,
                          onDismissCallback: (_) {})
                      .show();
                }
              } else {
                errorDialog();
              }
            } else {
              errorDialog();
            }
          } else {
            errorDialog();
          }

          // Updating getUserDetails API
        } else {
          errorDialog();
        }
      } else {
        errorDialog();
      }
    } else {
      errorDialog();
    }
  }

  errorDialog() {
    AwesomeDialog(
            context: context,
            animType: AnimType.TOPSLIDE,
            headerAnimationLoop: true,
            dialogType: DialogType.ERROR,
            dismissOnTouchOutside: false,
            title: 'Failed!',
            desc: 'Cancelling Appointment Failed!\nPlease try again ...',
            btnOkOnPress: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyAppointment(
                            backNav: false,
                          )),
                  (Route<dynamic> route) => false);
            },
            btnOkColor: Colors.red,
            btnOkText: 'Proceed',
            btnOkIcon: Icons.refresh,
            onDismissCallback: (_) {})
        .show();
  }

  void getconsultantStatus() async {
    if (session != null) {
      session.close();
    }
    connect();
    session = await client.connect().first;
    try {
      final subscription = await session.subscribe('ihl_update_doctor_status_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) {
        Map data = event.arguments[0];
        var status = data['data']['status'];
        if (data['sender_id'] == widget.ihlConsultantId) {
          if (this.mounted) {
            setState(() {
              doctorStatus = status;
            });
          }
        }
      });
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  @override
  void initState() {
    super.initState();
    httpStatus();
    subscribeAppointmentApproved();
    getconsultantStatus();
    getConsultantImageURL();
  }

  // getSharedAppIdList() async{
  //   SharedPreferences prefs =await SharedPreferences.getInstance();
  //   sharedReportAppIdList =  prefs.getStringList('sharedReportAppIdList') ?? [];
  // }
  @override
  void dispose() {
    super.dispose();
    session.close();
    session1.close();
  }

//changed enable to true to test genix
  @override
  Widget build(BuildContext context) {
    DateTime current = DateTime.now();
    var currentDateTime = new DateTime.now().add(Duration(seconds: 90));
    // var currentDateTimeFormatted =
    //     DateFormat('MM/dd/yyyy hh:mm a').format(currentDateTime);
    var appointmentStartingTime;
    var difference;
    Stream timer = Stream.periodic(Duration(seconds: 5), (i) {
      current = current.add(Duration(seconds: 5));
      // current = current.add(Duration(seconds: 90));

      return current;
    });

    String appointmentStartTime1 = widget.date;
    String appointmentStartstringTime = appointmentStartTime1.substring(11, 19);
    String appointmentStartTime = appointmentStartTime1.substring(0, 10);
    DateTime startTimeformattime = DateFormat.jm().parse(appointmentStartstringTime);
    String starttime = DateFormat("hh:mm a").format(startTimeformattime);
    String appointmentStartdateToFormat = appointmentStartTime;
    appointmentStartingTime = DateTime.parse(appointmentStartdateToFormat);
    DateTime fiveMinutesBeforeStartAppointment =
        appointmentStartingTime.subtract(new Duration(minutes: 5));
    DateTime thirtyMinutesAfterStartAppointment =
        appointmentStartingTime.add(new Duration(minutes: 30));
    // date2. difference(birthday). inDays

    int daysBetween(DateTime from, DateTime to) {
      from = DateTime(from.year, from.month, from.day);
      to = DateTime(to.year, to.month, to.day);
      return (to.difference(from).inHours / 24).round();
    }

    // print(appointmentStartingTime);
    // print(DateTime.now());
    // var noOfDays = DateTime.now().difference(appointmentStartingTime).inDays;
    difference = daysBetween(current, appointmentStartingTime);

    // print(difference);
    if (currentDateTime.isAfter(fiveMinutesBeforeStartAppointment) &&
        currentDateTime.isBefore(thirtyMinutesAfterStartAppointment) &&
        widget.callStatus != "completed") {
      if (doctorStatus != 'Offline' || doctorStatus == 'offline') {
        if (this.mounted) {
          setState(() {
            enableJoinCall = true;
          });
        }
      } else {
        errorMessage = "Consultant is offline";
      }
    } else {
      errorMessage = 'You can join the call at least 5 mins before appointment start time';
      if (this.mounted) {
        setState(() {
          enableJoinCall = false;
        });
      }
    }

    timer.listen((data) {
      var currentDateTime = new DateTime.now();

      String appointmentStartTime1 = widget.date;
      String appointmentStartstringTime = appointmentStartTime1.substring(11, 19);
      String appointmentStartTime = appointmentStartTime1.substring(0, 10);
      DateTime startTimeformattime = DateFormat.jm().parse(appointmentStartstringTime);
      // print(startTimeformattime);
      String starttime = DateFormat("HH:mm:ss").format(startTimeformattime);
      String appointmentStartdateToFormat = appointmentStartTime + " " + starttime;
      appointmentStartingTime = DateTime.parse(appointmentStartdateToFormat);

      // print(appointmentStartingTime);

      DateTime fiveMinutesBeforeStartAppointment =
          appointmentStartingTime.subtract(new Duration(minutes: 5));
      DateTime thirtyMinutesAfterStartAppointment =
          appointmentStartingTime.add(new Duration(minutes: 30));

      // var difference =
      //     appointmentStartingTime.difference(currentDateTime).inDays;
      // print('---------------->');
      // print (difference);

      if (currentDateTime.isAfter(fiveMinutesBeforeStartAppointment) &&
          currentDateTime.isBefore(thirtyMinutesAfterStartAppointment) &&
          widget.callStatus != "completed") {
        if (doctorStatus != 'Offline' || doctorStatus == 'offline') {
          if (this.mounted) {
            // if (!mounted) return;

            setState(() {
              enableJoinCall = true;
            });
          }
        } else {
          errorMessage = "Consultant is offline";
        }
      } else {
        errorMessage = 'You can join the call at least 5 mins before appointment start time';
        if (this.mounted) {
          try {
            setState(() {
              enableJoinCall = false;
            });
          } catch (e) {
            print(e.toString());
            Get.snackbar('restart the app', 'Some error occurred');
          }
        }
      }
    });
    return Column(
      children: [
        Container(
          // height: MediaQuery.of(context).size.height / 4.1,
          // width: MediaQuery.of(context).size.width / 1.24,
          width: ScUtil().setWidth(285),
          // height: ScUtil().setHeight(200),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            color: Color.fromRGBO(35, 107, 254, 0.8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.indigo[900],
                    //Colors.lightBlue,
                    Colors.blue,
                  ],
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /*Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                           FontAwesomeIcons.video,
                          color: AppColors.startConsult,
                        ),
                      ),*/
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 5.0,
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.only(left: 15.0),
                              title: Padding(
                                padding: const EdgeInsets.only(bottom: 2.0),
                                child: Text(
                                  widget.name.toString(),
                                  style: TextStyle(
                                      // fontSize: 16.0,
                                      fontSize: ScUtil().setSp(13),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                              subtitle: status(),
                              leading: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                    color: Colors.white),
                                height: 45,
                                width: 42,
                                // width: ScUtil().setWidth(40),
                                // height: ScUtil().setHeight(35),
                                child: CircleAvatar(
                                  radius: 50.0,
                                  backgroundImage: image == null ? null : image.image,
                                  backgroundColor: AppColors.primaryAccentColor,
                                ),

                                // Image.asset('assets/images/newfdc.png'),
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.only(bottom: 18.0),
                                child: PopupMenuButton<String>(
                                  // color: Colors.white,
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                  onSelected: (k) async {
                                    // Navigator.of(context).pushNamed(
                                    //     Routes.ConsultationType,
                                    //     arguments: false);
                                    Get.to(MyAppointment(
                                      backNav: false,
                                    ));
                                    // Get.to(
                                    //   ShareDocumentFromMyAppointment(
                                    //     ihlConsultantId: widget.ihlConsultantId,
                                    //     appointmentId: widget.appointmentId,
                                    //   ),
                                    // );
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        value: 'View Other Appointments',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.book_outlined,
                                              color: AppColors.primaryColor,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text('View Other Appointments'),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                                // height: MediaQuery.of(context).size.height / 80,
                                height: ScUtil().setHeight(12)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17.0),
                              child: Row(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Icon(
                                      Icons.date_range,
                                      color: Colors.white,
                                      size: ScUtil().setSp(18),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScUtil().setWidth(5),
                                  ),
                                  difference == 0
                                      ? Text(
                                          'today',
                                          style: TextStyle(
                                              fontSize: ScUtil().setSp(12),
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        )
                                      : Row(
                                          children: [
                                            Text(
                                              'In',
                                              style: TextStyle(
                                                  fontSize: ScUtil().setSp(12),
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(width: ScUtil().setWidth(3)),
                                            Text(
                                              difference.toString(),
                                              // widget.date.toString().substring(0, 10),
                                              style: TextStyle(
                                                  fontSize: ScUtil().setSp(12),
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(width: ScUtil().setWidth(3)),
                                            difference == 1
                                                ? Text(
                                                    'day',
                                                    style: TextStyle(
                                                        fontSize: ScUtil().setSp(12),
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600),
                                                  )
                                                : Text(
                                                    'days',
                                                    style: TextStyle(
                                                        fontSize: ScUtil().setSp(12),
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600),
                                                  )
                                          ],
                                        ),
                                  SizedBox(
                                      // width: 22.0,
                                      width: ScUtil().setWidth(40)),
                                  Container(
                                    child: Icon(
                                      Icons.timer,
                                      color: Colors.white,
                                      size: ScUtil().setSp(16),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScUtil().setWidth(5),
                                  ),
                                  Text(
                                    starttime,
                                    style: TextStyle(
                                        fontSize: ScUtil().setSp(12),
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                // height: 15.0,
                                // height: MediaQuery.of(context).size.height / 32
                                height: ScUtil().setHeight(15)),
                            widget.isApproved
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: ScUtil().setWidth(110),
                                        height: ScUtil().setHeight(28),
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15)),
                                            primary: enableJoinCall ? Colors.green : Colors.white,
                                          ),
                                          onPressed: enableJoinCall
                                              ? widget.vendorId == "GENIX"
                                                  ? () async {
                                                      print(genixURL);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => GenixWebView(
                                                                  appointmentId:
                                                                      widget.appointmentId)));
                                                    }
                                                  : () async {
                                                      SharedPreferences prefs =
                                                          await SharedPreferences.getInstance();
                                                      var data = prefs.get('data');
                                                      Map res = jsonDecode(data);
                                                      var iHLUserId = res['User']['id'];

                                                      Get.offNamedUntil(Routes.CallWaitingScreen,
                                                          (route) => false,
                                                          arguments: [
                                                            widget.appointmentId.toString(),
                                                            widget.ihlConsultantId.toString(),
                                                            iHLUserId.toString(),
                                                            "appointmentCall",
                                                            widget.callStatus,
                                                          ]);
                                                    }
                                              : () async {
                                                  showDialog<bool>(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text('Info'),
                                                        content: Text(errorMessage),
                                                        actions: <Widget>[
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              primary: Color(0xff4393cf),
                                                            ),
                                                            child: Text(
                                                              'Okay',
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                          label: Text(
                                            "Join Call",
                                            style: TextStyle(
                                                color: enableJoinCall
                                                    ? Colors.white
                                                    : Colors.blueAccent,
                                                fontWeight: FontWeight.w600,
                                                fontSize: ScUtil().setSp(12)),
                                          ),
                                          icon: Icon(
                                            Icons.phone,
                                            color:
                                                enableJoinCall ? Colors.white : Colors.blueAccent,
                                            size: ScUtil().setSp(18),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: ScUtil().setWidth(100),
                                        height: ScUtil().setHeight(28),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15)),
                                              primary: Colors.white),
                                          onPressed:
                                              currentDateTime.isAfter(appointmentStartingTime)
                                                  ? () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          String reasonRadioBtnVal = "";
                                                          final _formKey = GlobalKey<FormState>();
                                                          return WillPopScope(
                                                            onWillPop: () async => false,
                                                            child: AlertDialog(
                                                                title: Text(
                                                                  'Please provide the reason for Cancellation!',
                                                                  style: TextStyle(
                                                                      color: Color(0xff4393cf)),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                content: StatefulBuilder(
                                                                  builder: (BuildContext context,
                                                                      StateSetter setState) {
                                                                    return SingleChildScrollView(
                                                                      child: Form(
                                                                        key: _formKey,
                                                                        child: Column(
                                                                          children: [
                                                                            Column(
                                                                              children: <Widget>[
                                                                                Row(
                                                                                  children: [
                                                                                    new Radio<
                                                                                        String>(
                                                                                      value:
                                                                                          "Consultant didn\'t joined the call",
                                                                                      groupValue:
                                                                                          reasonRadioBtnVal,
                                                                                      onChanged:
                                                                                          (String
                                                                                              value) {
                                                                                        if (this
                                                                                            .mounted) {
                                                                                          setState(
                                                                                              () {
                                                                                            reasonRadioBtnVal =
                                                                                                value;
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                    Expanded(
                                                                                      child:
                                                                                          new Text(
                                                                                        'Consultant didn\'t joined the call',
                                                                                        style: new TextStyle(
                                                                                            fontSize:
                                                                                                16.0),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    new Radio<
                                                                                        String>(
                                                                                      value:
                                                                                          "You were facing technical issue",
                                                                                      groupValue:
                                                                                          reasonRadioBtnVal,
                                                                                      onChanged:
                                                                                          (String
                                                                                              value) {
                                                                                        if (this
                                                                                            .mounted) {
                                                                                          setState(
                                                                                              () {
                                                                                            reasonRadioBtnVal =
                                                                                                value;
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                    Expanded(
                                                                                      child:
                                                                                          new Text(
                                                                                        'You were facing technical issue',
                                                                                        style:
                                                                                            new TextStyle(
                                                                                          fontSize:
                                                                                              16.0,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    new Radio<
                                                                                        String>(
                                                                                      value:
                                                                                          'You didn\'t joined the call',
                                                                                      groupValue:
                                                                                          reasonRadioBtnVal,
                                                                                      onChanged:
                                                                                          (String
                                                                                              value) {
                                                                                        if (this
                                                                                            .mounted) {
                                                                                          setState(
                                                                                              () {
                                                                                            reasonRadioBtnVal =
                                                                                                value;
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                    Expanded(
                                                                                      child:
                                                                                          new Text(
                                                                                        'You didn\'t joined the call',
                                                                                        style: new TextStyle(
                                                                                            fontSize:
                                                                                                16.0),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    new Radio<
                                                                                        String>(
                                                                                      value:
                                                                                          'Consultant was facing technical issue',
                                                                                      groupValue:
                                                                                          reasonRadioBtnVal,
                                                                                      onChanged:
                                                                                          (String
                                                                                              value) {
                                                                                        if (this
                                                                                            .mounted) {
                                                                                          setState(
                                                                                              () {
                                                                                            reasonRadioBtnVal =
                                                                                                value;
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                    Expanded(
                                                                                      child:
                                                                                          new Text(
                                                                                        'Consultant was facing technical issue',
                                                                                        style: new TextStyle(
                                                                                            fontSize:
                                                                                                16.0),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                TextFormField(
                                                                                  controller:
                                                                                      reasonController,
                                                                                  validator:
                                                                                      (value) {
                                                                                    if (value
                                                                                        .isEmpty) {
                                                                                      return 'Please provide the reason!';
                                                                                    }
                                                                                    return null;
                                                                                  },
                                                                                  decoration:
                                                                                      InputDecoration(
                                                                                    contentPadding:
                                                                                        EdgeInsets.symmetric(
                                                                                            vertical:
                                                                                                15,
                                                                                            horizontal:
                                                                                                18),
                                                                                    labelText:
                                                                                        "Other reason",
                                                                                    fillColor: Colors
                                                                                        .white24,
                                                                                    border: new OutlineInputBorder(
                                                                                        borderRadius:
                                                                                            new BorderRadius.circular(
                                                                                                15.0),
                                                                                        borderSide:
                                                                                            new BorderSide(
                                                                                                color:
                                                                                                    Colors.blueGrey)),
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  textInputAction:
                                                                                      TextInputAction
                                                                                          .done,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Visibility(
                                                                              visible:
                                                                                  makeValidateVisible
                                                                                      ? true
                                                                                      : false,
                                                                              child: Text(
                                                                                "Please select the reason!",
                                                                                style: TextStyle(
                                                                                    color:
                                                                                        Colors.red),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 10.0,
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment
                                                                                      .spaceEvenly,
                                                                              children: [
                                                                                ElevatedButton(
                                                                                  style:
                                                                                      ElevatedButton
                                                                                          .styleFrom(
                                                                                    primary: AppColors
                                                                                        .primaryColor,
                                                                                    shape: RoundedRectangleBorder(
                                                                                        borderRadius:
                                                                                            BorderRadius.circular(
                                                                                                10.0),
                                                                                        side: BorderSide(
                                                                                            color: AppColors
                                                                                                .primaryColor)),
                                                                                  ),
                                                                                  child: Text(
                                                                                    'Go Back',
                                                                                    style: TextStyle(
                                                                                        color: Colors
                                                                                            .white),
                                                                                  ),
                                                                                  onPressed:
                                                                                      isChecking ==
                                                                                              true
                                                                                          ? null
                                                                                          : () {
                                                                                              Navigator.pop(
                                                                                                  context);
                                                                                            },
                                                                                ),
                                                                                ElevatedButton(
                                                                                    style: ElevatedButton
                                                                                        .styleFrom(
                                                                                      shape: RoundedRectangleBorder(
                                                                                          borderRadius:
                                                                                              BorderRadius.circular(
                                                                                                  10.0),
                                                                                          side: BorderSide(
                                                                                              color:
                                                                                                  AppColors.primaryColor)),
                                                                                      primary: AppColors
                                                                                          .primaryColor,
                                                                                    ),
                                                                                    child:
                                                                                        isChecking ==
                                                                                                true
                                                                                            ? SizedBox(
                                                                                                height:
                                                                                                    20.0,
                                                                                                width:
                                                                                                    20.0,
                                                                                                child:
                                                                                                    new CircularProgressIndicator(
                                                                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                                                                ),
                                                                                              )
                                                                                            : Text(
                                                                                                'Submit',
                                                                                                style:
                                                                                                    TextStyle(color: Colors.white),
                                                                                              ),
                                                                                    onPressed:
                                                                                        isChecking ==
                                                                                                true
                                                                                            ? null
                                                                                            : () {
                                                                                                if (reasonRadioBtnVal.isNotEmpty) {
                                                                                                  if (this.mounted) {
                                                                                                    setState(() {
                                                                                                      isChecking = true;
                                                                                                      makeValidateVisible = false;
                                                                                                    });
                                                                                                  }
                                                                                                  cancelAppointment("user", widget.appointmentId, reasonRadioBtnVal);
                                                                                                } else if (reasonController.text.isNotEmpty) {
                                                                                                  if (this.mounted) {
                                                                                                    setState(() {
                                                                                                      isChecking = true;
                                                                                                      makeValidateVisible = false;
                                                                                                    });
                                                                                                  }
                                                                                                  cancelAppointment("user", widget.appointmentId, reasonController.text);
                                                                                                } else {
                                                                                                  if (this.mounted) {
                                                                                                    setState(() {
                                                                                                      makeValidateVisible = true;
                                                                                                    });
                                                                                                  }
                                                                                                }
                                                                                              }),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                )),
                                                          );
                                                        },
                                                      );
                                                      if (this.mounted) {
                                                        setState(() {});
                                                      }
                                                    }
                                                  : () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return WillPopScope(
                                                              onWillPop: () async => false,
                                                              child: AlertDialog(
                                                                  title: Text(
                                                                    'Please provide the reason for cancellation!',
                                                                    style: TextStyle(
                                                                        color:
                                                                            AppColors.primaryColor),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                  content: StatefulBuilder(
                                                                    builder: (BuildContext context,
                                                                        StateSetter setState) {
                                                                      return SingleChildScrollView(
                                                                        child: Form(
                                                                          key: _formKey,
                                                                          // ignore: deprecated_member_use
                                                                          autovalidateMode:
                                                                              AutovalidateMode
                                                                                  .onUserInteraction,
                                                                          child: Column(
                                                                            children: [
                                                                              Column(
                                                                                children: <Widget>[
                                                                                  TextFormField(
                                                                                    controller:
                                                                                        reasonController,
                                                                                    validator:
                                                                                        (value) {
                                                                                      if (value
                                                                                          .isEmpty) {
                                                                                        return 'Please provide the reason!';
                                                                                      }
                                                                                      return null;
                                                                                    },
                                                                                    decoration:
                                                                                        InputDecoration(
                                                                                      contentPadding:
                                                                                          EdgeInsets.symmetric(
                                                                                              vertical:
                                                                                                  15,
                                                                                              horizontal:
                                                                                                  18),
                                                                                      labelText:
                                                                                          "Specify your reason",
                                                                                      fillColor: Colors
                                                                                          .white24,
                                                                                      border: new OutlineInputBorder(
                                                                                          borderRadius:
                                                                                              new BorderRadius.circular(
                                                                                                  15.0),
                                                                                          borderSide:
                                                                                              new BorderSide(
                                                                                                  color: Colors.blueGrey)),
                                                                                    ),
                                                                                    maxLines: 1,
                                                                                    textInputAction:
                                                                                        TextInputAction
                                                                                            .done,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 10.0,
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment:
                                                                                    MainAxisAlignment
                                                                                        .spaceEvenly,
                                                                                children: [
                                                                                  ElevatedButton(
                                                                                    style: ElevatedButton
                                                                                        .styleFrom(
                                                                                      primary: AppColors
                                                                                          .primaryColor,
                                                                                      shape: RoundedRectangleBorder(
                                                                                          borderRadius:
                                                                                              BorderRadius.circular(
                                                                                                  10.0),
                                                                                          side: BorderSide(
                                                                                              color:
                                                                                                  AppColors.primaryColor)),
                                                                                    ),
                                                                                    child: Text(
                                                                                      'Go Back',
                                                                                      style: TextStyle(
                                                                                          color: Colors
                                                                                              .white),
                                                                                    ),
                                                                                    onPressed:
                                                                                        isChecking ==
                                                                                                true
                                                                                            ? null
                                                                                            : () {
                                                                                                Navigator.pop(context);
                                                                                              },
                                                                                  ),
                                                                                  ElevatedButton(
                                                                                      style: ElevatedButton
                                                                                          .styleFrom(
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius:
                                                                                                BorderRadius.circular(
                                                                                                    10.0),
                                                                                            side: BorderSide(
                                                                                                color:
                                                                                                    AppColors.primaryColor)),
                                                                                        primary:
                                                                                            AppColors
                                                                                                .primaryColor,
                                                                                      ),
                                                                                      child: isChecking ==
                                                                                              true
                                                                                          ? SizedBox(
                                                                                              height:
                                                                                                  20.0,
                                                                                              width:
                                                                                                  20.0,
                                                                                              child:
                                                                                                  new CircularProgressIndicator(
                                                                                                valueColor:
                                                                                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                                                                              ),
                                                                                            )
                                                                                          : Text(
                                                                                              'Submit',
                                                                                              style:
                                                                                                  TextStyle(color: Colors.white),
                                                                                            ),
                                                                                      onPressed:
                                                                                          isChecking ==
                                                                                                  true
                                                                                              ? null
                                                                                              : () {
                                                                                                  if (_formKey.currentState.validate()) {
                                                                                                    if (this.mounted) {
                                                                                                      setState(() {
                                                                                                        isChecking = true;
                                                                                                      });
                                                                                                    }
                                                                                                    cancelAppointment("user", widget.appointmentId, reasonController.text);
                                                                                                  } else {
                                                                                                    if (this.mounted) {
                                                                                                      setState(() {
                                                                                                        _autoValidate = true;
                                                                                                      });
                                                                                                    }
                                                                                                  }
                                                                                                }),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  )),
                                                            );
                                                          });
                                                    },
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: ScUtil().setSp(12),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // icon: Icon(Icons.cancel),
                                        ),
                                      ),
                                    ],
                                  )
                                : widget.isPending
                                    ? Container(
                                        // height: 40,
                                        // height:
                                        //     MediaQuery.of(context).size.height /
                                        //         18,
                                        width: ScUtil().setWidth(150),
                                        height: ScUtil().setHeight(28),
                                        child: ButtonTheme(
                                          minWidth: 240.0,
                                          // height: 40.0,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                primary: Colors.white),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return WillPopScope(
                                                      onWillPop: () async => false,
                                                      child: AlertDialog(
                                                          title: Text(
                                                            'Please provide the reason for cancellation!',
                                                            style:
                                                                TextStyle(color: Color(0xff4393cf)),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                          content: StatefulBuilder(
                                                            builder: (BuildContext context,
                                                                StateSetter setState) {
                                                              return SingleChildScrollView(
                                                                child: Form(
                                                                  key: _formKey,
                                                                  // ignore: deprecated_member_use
                                                                  autovalidateMode: AutovalidateMode
                                                                      .onUserInteraction,
                                                                  child: Column(
                                                                    children: [
                                                                      Column(
                                                                        children: <Widget>[
                                                                          TextFormField(
                                                                            controller:
                                                                                reasonController,
                                                                            validator: (value) {
                                                                              if (value.isEmpty) {
                                                                                return 'Please provide the reason!';
                                                                              }
                                                                              return null;
                                                                            },
                                                                            decoration:
                                                                                InputDecoration(
                                                                              contentPadding:
                                                                                  EdgeInsets
                                                                                      .symmetric(
                                                                                          vertical:
                                                                                              15,
                                                                                          horizontal:
                                                                                              18),
                                                                              labelText:
                                                                                  "Specify your reason",
                                                                              fillColor:
                                                                                  Colors.white24,
                                                                              border: new OutlineInputBorder(
                                                                                  borderRadius:
                                                                                      new BorderRadius
                                                                                              .circular(
                                                                                          15.0),
                                                                                  borderSide:
                                                                                      new BorderSide(
                                                                                          color: Colors
                                                                                              .blueGrey)),
                                                                            ),
                                                                            maxLines: 1,
                                                                            textInputAction:
                                                                                TextInputAction
                                                                                    .done,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height: 10.0,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .spaceEvenly,
                                                                        children: [
                                                                          ElevatedButton(
                                                                            style: ElevatedButton
                                                                                .styleFrom(
                                                                              primary: AppColors
                                                                                  .primaryColor,
                                                                              shape: RoundedRectangleBorder(
                                                                                  borderRadius:
                                                                                      BorderRadius
                                                                                          .circular(
                                                                                              10.0),
                                                                                  side: BorderSide(
                                                                                      color: AppColors
                                                                                          .primaryColor)),
                                                                            ),
                                                                            child: Text(
                                                                              'Go Back',
                                                                              style: TextStyle(
                                                                                  color:
                                                                                      Colors.white),
                                                                            ),
                                                                            onPressed:
                                                                                isChecking == true
                                                                                    ? null
                                                                                    : () {
                                                                                        Navigator.pop(
                                                                                            context);
                                                                                      },
                                                                          ),
                                                                          ElevatedButton(
                                                                              style: ElevatedButton
                                                                                  .styleFrom(
                                                                                shape: RoundedRectangleBorder(
                                                                                    borderRadius:
                                                                                        BorderRadius
                                                                                            .circular(
                                                                                                10.0),
                                                                                    side: BorderSide(
                                                                                        color: AppColors
                                                                                            .primaryColor)),
                                                                                primary: AppColors
                                                                                    .primaryColor,
                                                                              ),
                                                                              child:
                                                                                  isChecking == true
                                                                                      ? SizedBox(
                                                                                          height:
                                                                                              20.0,
                                                                                          width:
                                                                                              20.0,
                                                                                          child:
                                                                                              new CircularProgressIndicator(
                                                                                            valueColor:
                                                                                                AlwaysStoppedAnimation<Color>(Colors.white),
                                                                                          ),
                                                                                        )
                                                                                      : Text(
                                                                                          'Submit',
                                                                                          style: TextStyle(
                                                                                              color:
                                                                                                  Colors.white),
                                                                                        ),
                                                                              onPressed:
                                                                                  isChecking == true
                                                                                      ? null
                                                                                      : () {
                                                                                          if (_formKey
                                                                                              .currentState
                                                                                              .validate()) {
                                                                                            if (this
                                                                                                .mounted) {
                                                                                              setState(
                                                                                                  () {
                                                                                                isChecking =
                                                                                                    true;
                                                                                              });
                                                                                            }
                                                                                            cancelAppointment(
                                                                                                "user",
                                                                                                widget.appointmentId,
                                                                                                reasonController.text);
                                                                                          } else {
                                                                                            if (this
                                                                                                .mounted) {
                                                                                              setState(
                                                                                                  () {
                                                                                                _autoValidate =
                                                                                                    true;
                                                                                              });
                                                                                            }
                                                                                          }
                                                                                        }),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )),
                                                    );
                                                  });
                                            },
                                            child: Text(
                                              "Cancel Appointment",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: ScUtil().setSp(12),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            // icon: Icon(Icons.cancel,
                                            //     color: Colors.blue),
                                          ),
                                        ),
                                      )
                                    : Container(),
                            Visibility(
                              visible: false,
                              //  visible: widget.sharedReportAppIdList.contains(widget.appointmentId)==false,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      Get.to(ShareDocumentFromMyAppointment(
                                        ihlConsultantId: widget.ihlConsultantId,
                                        appointmentId: widget.appointmentId,
                                      ));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                      primary: AppColors.primaryColor,
                                    ),
                                    label: Text("Share Your Medical Documents"),
                                    icon: Icon(Icons.insert_drive_file),
                                  ),
                                ],
                              ),
                            ),
                            /*SizedBox(height: 5.0),
                            Visibility(
                              visible: (currentDateTime
                                          .isAfter(
                                              fiveMinutesBeforeStartAppointment) &&
                                      currentDateTime.isBefore(
                                          thirtyMinutesAfterStartAppointment)
                                  ? true
                                  : false,
                              child: Text("Consultant is Offline",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red)),
                            ),
                            Visibility(
                              visible: (currentDateTime
                                          .isAfter(
                                              fiveMinutesBeforeStartAppointment) &&
                                      currentDateTime.isBefore(
                                          thirtyMinutesAfterStartAppointment) &&
                                      (doctorStatus == "Busy" &&
                                          (widget.callStatus != "on_going" || widget.callStatus != "requested")))
                                  ? true
                                  : false,
                              child: Text("Consultant is Offline",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red)),
                            ),*/
                            SizedBox(height: ScUtil().setHeight(15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppointmentList extends StatefulWidget {
  final String name;
  final String date;
  final bool isPending;
  final bool isApproved;

  AppointmentList({this.name, this.date, this.isPending, this.isApproved});

  @override
  _AppointmentListState createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  Text status() {
    if (widget.isPending == true) {
      return Text(
        AppTexts.myAppointmentReqPen,
        style: TextStyle(color: AppColors.primaryAccentColor),
      );
    }
    if (widget.isApproved == true) {
      return Text(
        AppTexts.myAppointmentReqAccepted,
        // style: TextStyle(color: Colors.green),
        style: TextStyle(color: Colors.white),
      );
    }
    if (widget.isApproved == false) {
      return Text(
        AppTexts.myAppointmentReqRejected,
        style: TextStyle(color: Colors.red),
      );
    }
    return Text(
      AppTexts.myAppointmentReqPen,
      style: TextStyle(color: AppColors.primaryAccentColor),
    );
  }

  Widget _buildApprovedInfoCard(context) {
    return Visibility(
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 5),
              child: Card(
                color: AppColors.cardColor,
                elevation: 6,
                child: ExpansionTile(
                  backgroundColor: AppColors.cardColor,
                  /*leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                        FontAwesomeIcons.video,
                      color: AppColors.startConsult,
                    ),
                  ),*/
                  title: Text(
                    widget.name.toString(),
                  ),
                  subtitle: Text(widget.date, style: TextStyle(fontSize: 12)),
                  trailing: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                      ),
                      onPressed: () async {
                        // ignore: unused_local_variable
                        var dismiss = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Info'),
                              content: Text(
                                  'Please join the call at least 5 mins before appointment time'),
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: AppColors.primaryColor,
                                  ),
                                  child: Text(
                                    'Okay',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.phone,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Join",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardColor,
      elevation: 6,
      child: ExpansionTile(
        backgroundColor: AppColors.cardColor,
        /*leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
             FontAwesomeIcons.video,
            color: AppColors.startConsult,
          ),
        ),*/
        title: Text(
          widget.name.toString(),
        ),
        subtitle: Text(widget.date, style: TextStyle(fontSize: 12)),
        trailing: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
            ),
            onPressed: () async {
              // ignore: unused_local_variable
              var dismiss = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Info'),
                    content: Text('Please join the call at least 5 mins before appointment time'),
                    actions: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.primaryColor,
                        ),
                        child: Text(
                          'Okay',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.phone,
              color: Colors.white,
            ),
            label: Text(
              "Join",
              style: TextStyle(color: Colors.white),
            )),
        children: [_buildApprovedInfoCard(context)],
      ),
    );
  }
}
