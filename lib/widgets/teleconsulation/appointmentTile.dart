import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/new_design/presentation/pages/onlineServices/MyAppointment.dart';
import 'package:ihl/utils/CrossbarUtil.dart' as s;
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/teleconsultation/genixWebView.dart';
import 'package:ihl/views/teleconsultation/myAppointments.dart';
import 'package:ihl/widgets/teleconsulation/share_from_my_appointment.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../models/data_helper.dart';
import '../../models/invoice.dart';
import '../../repositories/api_consult.dart';
import '../../repositories/api_repository.dart';
import '../../views/view_past_bill/view_only_bill.dart';

// ignore: must_be_immutable
class AppointmentTile extends StatefulWidget {
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

  var isCancelledByDoc;
  List<String> sharedReportAppIdList;

  AppointmentTile({
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
  });

  @override
  _AppointmentTileState createState() => _AppointmentTileState();

  toList() {}
}

class _AppointmentTileState extends State<AppointmentTile> {
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
        style: TextStyle(color: AppColors.primaryAccentColor, fontSize: 16.0),
      );
    }
    if (widget.isCompleted == true) {
      return Text(
        "Appointment Completed",
        style: TextStyle(color: Colors.green, fontSize: 16.0),
      );
    }
    if (widget.isApproved == true) {
      return Text(
        AppTexts.myAppointmentReqAccepted,
        style: TextStyle(color: Colors.green, fontSize: 16.0),
      );
    }
    if (widget.isRejected == true) {
      return Text(
        "Appointment Rejected by Consultant",
        style: TextStyle(color: Colors.red, fontSize: 16.0),
      );
    }
    if (widget.isCancelled == true || cancelled == true) {
      return Text(
        "Appointment Cancelled ",
        style: TextStyle(color: Colors.red, fontSize: 16.0),
      );
    }
    if (widget.isCancelledByDoc == true || cancelled == true) {
      return Text(
        "Appointment Cancelled ",
        style: TextStyle(color: Colors.red, fontSize: 16.0),
      );
    }
    return Text(
      AppTexts.myAppointmentReqPen,
      style: TextStyle(color: AppColors.primaryAccentColor, fontSize: 16.0),
    );
  }

  void httpStatus() async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/getConsultantLiveStatus'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
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
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      // headers: {'ApiToken': apiToken},
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
    var transcationId = '';

    var apiToken = prefs.get('auth_token');
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/cancel_appointment'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      // headers: {'ApiToken': apiToken},
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
            Uri.parse(API.iHLUrl + "/consult/user_transaction_from_ihl_id?ihl_id=" + iHLUserId),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
          );
          if (transresponce.statusCode == 200) {
            if (transresponce.body != "[]" || transresponce.body != null) {
              var transcationList = json.decode(transresponce.body);
              for (int i = 0; i <= transcationList.length - 1; i++) {
                if (transcationList[i]["ihl_appointment_id"] == appointId) {
                  transcationId = transcationList[i]["transaction_id"];
                }
              }
              final responsetrans = await _client.get(
                Uri.parse(API.iHLUrl +
                    '/consult/update_refund_status?transaction_id=' +
                    transcationId +
                    '&refund_status=Initated'),
                headers: {
                  'Content-Type': 'application/json',
                  'ApiToken': '${API.headerr['ApiToken']}',
                  'Token': '${API.headerr['Token']}',
                },
              );
              if (responsetrans.statusCode == 200 || refundAmount.toString() == '0') {
                // if (responsetrans.body == '"Refund Status Update Success"') {
                if (responsetrans.body == '"Refund Status Update Success"' ||
                    refundAmount.toString() == '0') {
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
                          btnOkOnPress: () => Get.offAll(MyAppointment(
                                backNav: false,
                              )),
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
            desc: 'Appointment Cancellation Unsuccessful. Please Try Again.',
            btnOkOnPress: () => Get.offAll(MyAppointment(
                  backNav: false,
                )),
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
  Stream timer;

  void initState() {
    super.initState();
    httpStatus();
    subscribeAppointmentApproved();
    getconsultantStatus();
    // getSharedAppIdList();
  }

  // getSharedAppIdList() async{
  //   SharedPreferences prefs =await SharedPreferences.getInstance();
  //   sharedReportAppIdList =  prefs.getStringList('sharedReportAppIdList') ?? [];
  // }
  @override
  void dispose() {
    super.dispose();
    if (session != null) {
      session.close();
    }
    if (session != null) {
      session.close();
    }
    timer = null;
    // session.close();
    // session1.close();
    // timer.listen((event) {
    //   print('we are now disposing the timer before disposing last listen -> ${event.toString()}');
    //   print(timer.toString());
    // }).cancel();

    print('timer is done check its value -> ${timer.toString()}');
  }

//changed enable to true to test genix
  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    DateTime current = DateTime.now();
    var currentDateTime = new DateTime.now();
    var appointmentStartingTime;
    timer = Stream.periodic(Duration(seconds: 5), (i) {
      current = current.add(Duration(seconds: 5));
      return current;
    });

    String appointmentStartTime1 = widget.date;
    String appointmentStartstringTime = appointmentStartTime1.substring(11, 19);
    String appointmentStartTime = appointmentStartTime1.substring(0, 10);
    DateTime startTimeformattime = DateFormat.jm().parse(appointmentStartstringTime);
    String starttime = DateFormat("HH:mm:ss").format(startTimeformattime);
    String appointmentStartdateToFormat = appointmentStartTime + " " + starttime;
    appointmentStartingTime = DateTime.parse(appointmentStartdateToFormat);
    DateTime fiveMinutesBeforeStartAppointment =
        appointmentStartingTime.subtract(Duration(minutes: 0));
    DateTime thirtyMinutesAfterStartAppointment =
        appointmentStartingTime.add(Duration(minutes: 30));

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
      String starttime = DateFormat("HH:mm:ss").format(startTimeformattime);
      String appointmentStartdateToFormat = appointmentStartTime + " " + starttime;
      appointmentStartingTime = DateTime.parse(appointmentStartdateToFormat);
      DateTime fiveMinutesBeforeStartAppointment =
          appointmentStartingTime.subtract(new Duration(minutes: 0));
      DateTime thirtyMinutesAfterStartAppointment =
          appointmentStartingTime.add(new Duration(minutes: 30));

      if (currentDateTime.isAfter(fiveMinutesBeforeStartAppointment) &&
          currentDateTime.isBefore(thirtyMinutesAfterStartAppointment) &&
          widget.callStatus != "completed") {
        if (doctorStatus != 'Offline' || doctorStatus == 'offline') {
          if (mounted) {
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
    });
    return Column(
      children: [
        Card(
          color: AppColors.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    /*Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                         FontAwesomeIcons.video,
                        color: AppColors.startConsult,
                      ),
                    ),*/
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ///commented on 310 Dec
                                Visibility(
                                    visible: widget.sharedReportAppIdList
                                            .contains(widget.appointmentId) ==
                                        false,
                                    child: Spacer(
                                      flex: 2,
                                    )),
                                Text(
                                  widget.name.toString(),
                                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                ),

                                ///commented on 310 Dec
                                Visibility(
                                    visible: widget.sharedReportAppIdList
                                            .contains(widget.appointmentId) ==
                                        false,
                                    child: Spacer(
                                      flex: 1,

                                      ///commented on 310 Dec
                                    )),
                                Visibility(
                                  visible:
                                      widget.sharedReportAppIdList.contains(widget.appointmentId) ==
                                          false,
                                  child: PopupMenuButton<String>(onSelected: (k) async {
                                    if (k == 'Share Medical Report') {
                                      Get.to(ShareDocumentFromMyAppointment(
                                        ihlConsultantId: widget.ihlConsultantId,
                                        appointmentId: widget.appointmentId,
                                      ));
                                    } else {
                                      bool permissionGrandted = false;
                                      if (Platform.isAndroid) {
                                        final deviceInfo = await DeviceInfoPlugin().androidInfo;
                                        Map<Permission, PermissionStatus> _status;
                                        if (deviceInfo.version.sdkInt <= 32) {
                                          _status = await [Permission.storage].request();
                                        } else {
                                          _status = await [Permission.photos, Permission.videos]
                                              .request();
                                        }
                                        _status.forEach((permission, status) {
                                          if (status == PermissionStatus.granted) {
                                            permissionGrandted = true;
                                          }
                                        });
                                      } else {
                                        permissionGrandted = true;
                                      }
                                      if (permissionGrandted) {
                                        SharedPreferences prefs =
                                            await SharedPreferences.getInstance();
                                        Get.snackbar(
                                          '',
                                          'Invoice will be saved in your mobile!',
                                          backgroundColor: AppColors.primaryAccentColor,
                                          colorText: Colors.white,
                                          duration: Duration(seconds: 5),
                                          isDismissible: false,
                                        );
                                        await appointmentDetailsGlobal(
                                            context: context, appointmentID: widget.appointmentId);
                                        Invoice invoice = await ConsultApi()
                                            .getInvoiceNumber(iHLUserId, widget.appointmentId);

                                        new Future.delayed(new Duration(seconds: 2), () {
                                          billView(context, invoiceNumber, true,
                                              invoiceModel: invoice);
                                        });
                                      } else {
                                        Get.snackbar('Storage Access Denied',
                                            'Allow Storage permission to continue',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            duration: Duration(seconds: 5),
                                            isDismissible: false,
                                            mainButton: TextButton(
                                                onPressed: () async {
                                                  await openAppSettings();
                                                },
                                                child: Text('Allow')));
                                      }
                                    }
                                  }, itemBuilder: (context) {
                                    if (double.parse(widget.consultationFees) > 1) {
                                      return [
                                        PopupMenuItem(
                                          value: 'Share Medical Report',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.share,
                                                color: AppColors.primaryColor,
                                              ),
                                              SizedBox(
                                                width: 7,
                                              ),
                                              Text('Share Medical Report'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'Download Invoice',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.download,
                                                color: AppColors.primaryColor,
                                              ),
                                              SizedBox(
                                                width: 7,
                                              ),
                                              Text('Download Invoice'),
                                            ],
                                          ),
                                        ),
                                      ];
                                    } else {
                                      return [
                                        PopupMenuItem(
                                          value: 'Share Medical Report',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.share,
                                                color: AppColors.primaryColor,
                                              ),
                                              SizedBox(
                                                width: 7,
                                              ),
                                              Text('Share Medical Report'),
                                            ],
                                          ),
                                        ),
                                      ];
                                    }
                                  }),
                                ),
                              ],
                            ),
                            Text(
                              widget.date.toString(),
                              style: TextStyle(fontSize: 16.0),
                            ),
                            status(),
                            SizedBox(
                              height: 10.0,
                            ),
                            widget.isApproved
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: ScUtil().setWidth(130),
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                            primary: enableJoinCall ? Colors.green : Colors.grey,
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

                                                      ///save ihl_con_id for sharing the file while call
                                                      prefs.setString(
                                                        'consultantId_for_share',
                                                        widget.ihlConsultantId.toString(),
                                                      );

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
                                          label: Text("Join Call"),
                                          icon: Icon(Icons.phone),
                                        ),
                                      ),
                                      SizedBox(
                                        width: ScUtil().setWidth(120),
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                            primary: AppColors.primaryColor,
                                          ),
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
                                          label: Text("Cancel"),
                                          icon: Icon(Icons.cancel),
                                        ),
                                      ),
                                    ],
                                  )
                                : widget.isPending
                                    ? ButtonTheme(
                                        minWidth: 240.0,
                                        height: 40.0,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                            primary: AppColors.primaryColor,
                                          ),
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
                                                                              TextInputAction.done,
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
                                                                            child: isChecking ==
                                                                                    true
                                                                                ? SizedBox(
                                                                                    height: 20.0,
                                                                                    width: 20.0,
                                                                                    child:
                                                                                        new CircularProgressIndicator(
                                                                                      valueColor: AlwaysStoppedAnimation<
                                                                                              Color>(
                                                                                          Colors
                                                                                              .white),
                                                                                    ),
                                                                                  )
                                                                                : Text(
                                                                                    'Submit',
                                                                                    style: TextStyle(
                                                                                        color: Colors
                                                                                            .white),
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
                                                                                              widget
                                                                                                  .appointmentId,
                                                                                              reasonController
                                                                                                  .text);
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
                                          label: Text("Cancel Appointment"),
                                          icon: Icon(Icons.cancel),
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<Map> appointmentDetailsGlobal({String appointmentID, BuildContext context}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var authToken = prefs.get('auth_token');
  var userData = prefs.get('data');
  var decodedResponse = jsonDecode(userData);
  String iHLUserToken = decodedResponse['Token'];
  Map consultationDetails = {};
  try {
    String iHLUrl = Apirepository().iHLUrl;
    String ihlToken = Apirepository().ihlToken;
    final auth_response = await http
        .get(Uri.parse(iHLUrl + '/login/kioskLogin?id=2936'), headers: {'ApiToken': ihlToken});
    Signup reponseToken = Signup.fromJson(json.decode(auth_response.body));
    String apiToken = reponseToken.apiToken;
    final response = await http.get(
        Uri.parse(API.iHLUrl + '/consult/get_appointment_details?appointment_id=$appointmentID'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': authToken != null ? authToken : apiToken,
          'Token': iHLUserToken
        });
    if (response.statusCode == 200) {
      if (response.body != '""') {
        String value = '';
        var reasonForVisit = [];
        List reas = reasonCut(response.body);
        value = reas[0];
        reasonForVisit = reas[1];
        var parsedString = value.replaceAll('&quot', '"');
        var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        var parsedString3 = parsedString2.replaceAll("\\\\n", "\\n");
        var _p = parsedString3.replaceAll('\\\\', '');
        var parsedString4 = _p.replaceAll(";", "");
        var parsedString5 = parsedString4.replaceAll('""', '"');
        var parsedString6 = parsedString5.replaceAll('"[', '[');
        var parsedString7 = parsedString6.replaceAll(']"', ']');
        var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
        var pasrseString9 = pasrseString8.replaceAll('"{', '{');
        var pasrseString10 = pasrseString9.replaceAll('}"', '}');
        var pasrseString11 = pasrseString10.replaceAll('}"', '}');
        var pasrseString12 = pasrseString11.replaceAll(':",', ':"",');
        var parseString13 = pasrseString12.replaceAll(':"}', ':""}');
        var finalOutput = parseString13.replaceAll('/"', '/');
        Map details = json.decode(finalOutput);
        for (int i = 0; i < reasonForVisit.length; i++) {
          details['message']['reason_for_visit'] = reasonForVisit[i]['reason_for_visit'];
          details['message']['alergy'] = reasonForVisit[i]['alergy'];
          details['message']['notes'] = reasonForVisit[i]['notes'];
          if (reasonForVisit[i]['direction_of_use'] != null &&
              reasonForVisit[i]['direction_of_use'].length > 0) {
            for (int j = 0; j < reasonForVisit[i]['direction_of_use'].length; j++) {
              details['message']['prescription'][j]['direction_of_use'] =
                  reasonForVisit[i]['direction_of_use'][j];
            }
          }
          if (reasonForVisit[i]['drug_name'] != null && reasonForVisit[i]['drug_name'].length > 0) {
            for (int j = 0; j < reasonForVisit[i]['drug_name'].length; j++) {
              details['message']['prescription'][j]['drug_name'] =
                  reasonForVisit[i]['drug_name'][j];
            }
          }
        }
        // if (this.mounted) {
        // setState(() {
        consultationDetails = details;
        print(consultationDetails["message"]["alergy_genix"]);
        consultationDetails['message']['notes'] =
            consultationDetails['message']['notes'] ?? ["N/A"];
        consultationDetails["message"]["ihl_consultant_id"] =
            consultationDetails["message"]["ihl_consultant_id"] ?? 'N/A';
        // });
        String appointmentStartTime1 =
            consultationDetails["message"]["appointment_start_time"].toString() ?? "N/A";
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var data = prefs.get(SPKeys.userData);
        data = data == null || data == '' ? '{"User":{}}' : data;
        Map res = jsonDecode(data);
        String firstName = res['User']['firstName'];
        String ihlUserId = res['User']['id'];
        String lastName = res['User']['lastName'];
        firstName ??= "";
        lastName ??= "";
        String email = res['User']['email'];
        String mobileNumber = res['User']['mobileNumber'];
        String age = res['User']['dateOfBirth'];
        address = res['User']['address'].toString();
        address = address == 'null' ? '' : address;
        area = res['User']['area'].toString();
        area = area == 'null' ? '' : area;
        city = res['User']['city'].toString();
        city = city == 'null' ? '' : city;
        state = res['User']['state'].toString();
        state = state == 'null' ? '' : state;
        pincode = res['User']['pincode'].toString();
        pincode = pincode == 'null' ? '' : pincode;
        String gender = res['User']['gender'];
        int finalAge;
        String finalGender = "";
        if (gender == "m" || gender == "M" || gender == "male" || gender == "Male") {
          finalGender = "Male";
        } else {
          finalGender = "Female";
        }
        age = age.replaceAll(" ", "");
        if (age.contains("-")) {
          DateTime tempDate = new DateFormat("dd-MM-yyyy").parse(age);
          DateTime currentDate = DateTime.now();
          finalAge = currentDate.year - tempDate.year;
        } else if (age.contains("/")) {
          DateTime tempDate = new DateFormat("MM/dd/yyyy").parse(age.trim());
          DateTime currentDate = DateTime.now();
          finalAge = currentDate.year - tempDate.year;
        }
        prefs.setString("appointIdFromHistory", appointmentID);
        prefs.setString("modeOfPaymentFromHistory",
            consultationDetails["message"]["mode_of_payment"].toString() ?? "N/A");
        prefs.setString("consultantNameFromHistory",
            consultationDetails["consultant_details"]["consultant_name"].toString() ?? "N/A");
        prefs.setString("consultantEmailFromHistory",
            consultationDetails["consultant_details"]["consultant_email"].toString() ?? "N/A");
        prefs.setString("consultantMobileFromHistory",
            consultationDetails["consultant_details"]["consultant_mobile"].toString() ?? "N/A");
        prefs.setString("consultationFeesFromHistory",
            consultationDetails["message"]["consultation_fees"].toString() ?? "N/A");
        prefs.setString("consultantEducationFromHistory",
            consultationDetails["consultant_details"]["education"].toString() ?? "N/A");
        prefs.setString("consultantDescriptionFromHistory",
            consultationDetails["consultant_details"]["description"].toString() ?? "N/A");

        prefs.setString("appointmentStartTimeFromHistory",
            consultationDetails["message"]["appointment_start_time"].toString() ?? "N/A");
        prefs.setString("reasonForVisitFromHistory",
            consultationDetails["message"]["reason_for_visit"].toString() ?? "N/A");
        prefs.setString("diagnosisFromHistory",
            consultationDetails["message"]["diagnosis"].toString() ?? "N/A");
        prefs.setString("instructionFromHistory",
            consultationDetails["message"]["consultation_internal_notes"] ?? "N/A");
        prefs.setString("adviceFromHistory",
            consultationDetails["message"]["consultation_advice_notes"].toString() ?? "N/A");
        prefs.setString("userFirstNameFromHistory", firstName);
        prefs.setString("userLastNameFromHistory", lastName);
        prefs.setString("userEmailFromHistory", email);
        prefs.setString("userContactFromHistory", mobileNumber);
        prefs.setString("ageFromHistory", finalAge.toString());
        prefs.setString("genderFromHistory", finalGender);

        prefs.setString("useraddressFromHistory", address);
        prefs.setString("userareaFromHistory", area);
        prefs.setString("usercityFromHistory", city);
        prefs.setString("userstateFromHistory", state);
        prefs.setString("userpincodeFromHistory", pincode);
        // }
      } else {
        consultationDetails = {};
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: new Text("Please try again later..."),
        backgroundColor: AppColors.primaryColor,
      ));
    }
  } catch (e) {
    print(e);
    appointmentDetailsGlobal(appointmentID: appointmentID, context: context);
  }
  return consultationDetails;
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
        style: TextStyle(color: Colors.green),
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

reasonCut(value) {
  var lastStartIndex = 0;
  var lastEndIndex = 0;
  var reasonLastEndIndex = 0;
  var alergyLastEndIndex = 0;
  var notesLastEndIndex = 0;
  var directionOfUseLastEndIndex = 0;
  var dirOfUseLastEndIndex = 0;
  var drugNameLastEndIndex = 0;
  var reasonForVisit = [];
  for (int i = 0; i < value.length; i++) {
    if (value.contains("reason_for_visit")) {
      var start = ";appointment_id";
      var end = "vendor_appointment_id";
      var startIndex = value.indexOf(start, lastStartIndex);
      var endIndex = value.indexOf(end, lastEndIndex);
      lastStartIndex = value.indexOf(start, startIndex) + start.length;
      lastEndIndex = value.indexOf(end, endIndex) + end.length;

      String a = value.substring(startIndex + start.length, endIndex);
      var parseda1 = a.replaceAll('&quot', '');
      var parseda2 = parseda1.replaceAll(';:;', '');
      var parseda3 = parseda2.replaceAll(';,;', '');
//reason
      var reasonStart = "reason_for_visit";
      var reasonEnd = ";notes";
      var reasonStartIndex = value.indexOf(reasonStart);
      var reasonEndIndex = value.indexOf(reasonEnd, reasonLastEndIndex);
      reasonLastEndIndex = value.indexOf(reasonEnd, reasonLastEndIndex) + reasonEnd.length;
      String b = value.substring(reasonStartIndex + reasonStart.length, reasonEndIndex);
      var parsedb1 = b.replaceAll('&quot', '');
      var parsedb2 = parsedb1.replaceAll(';:;', '');
      var parsedb3 = parsedb2.replaceAll(';,', '');
      var temp1 = value.substring(0, reasonStartIndex);
      var temp2 = value.substring(reasonEndIndex, value.length);
      value = temp1 + temp2;
//alergy
      var alergyStart = "alergy";
      var alergyEnd = "appointment_start_time";
      var alergyStartIndex = value.indexOf(alergyStart);
      var alergyEndIndex = value.indexOf(alergyEnd, alergyLastEndIndex);
      alergyLastEndIndex = alergyEndIndex + alergyEnd.length;
      String c = value.substring(alergyStartIndex + alergyStart.length, alergyEndIndex);
      var parsedc1 = c.replaceAll('&quot;', '');
      var parsedc2 = parsedc1.replaceAll(':', '');
      var parsedc3 = parsedc2.replaceAll(',', '');
      temp1 = value.substring(0, alergyStartIndex);
      temp2 = value.substring(alergyEndIndex, value.length);
      value = temp1 + temp2;

//notes
      var notesStart = ";notes";
      var notesEnd = ";kiosk_checkin_history";
      var notesStartIndex = value.indexOf(notesStart);
      var notesEndIndex = value.indexOf(notesEnd, notesLastEndIndex);
      notesLastEndIndex = notesEndIndex + notesEnd.length;
      String d = value.substring(notesStartIndex + notesStart.length, notesEndIndex);
      var parsedd1 = d.replaceAll('&quot;', ' ');
      var parsedd2 = parsedd1.replaceAll(':', ' ');
      var parsedd3 = parsedd2.replaceAll(',', '');
      var parsedd4 = parsedd3.replaceAll('&quot', '');
      var parsedd5 = parsedd4.replaceAll('[{', '');
      var parsedd6 = parsedd5.replaceAll('\\\\n', '\n');
      var parsedd7 = parsedd6.replaceAll('\\', '');
      var parsedd8 = parsedd7.replaceAll('}]', '');
      var parsedd9 = parsedd8.replaceAll('}', '');
      var parsedd10 = parsedd9.replaceAll('{', '');
      var parsedd11 = parsedd10.replaceAll('&#39;', '');
      var parsedd12 = parsedd11.replaceAll('[', '');
      var parsedd13 = parsedd12.replaceAll(']', '');
      parsedd12 = parsedd13;
      temp1 = value.substring(0, notesStartIndex);
      temp2 = value.substring(notesEndIndex, value.length);
      value = temp1 + temp2;
      List descriptionList = [];
      for (int i = 0; i < parsedd12.length; i++) {
        if (parsedd12.contains("Description")) {
          var descriptionLastEndIndex = 0;
          var descriptionStart = "Description";
          var descriptionEnd = "Description";
          var descriptionStartIndex = parsedd12.indexOf(descriptionStart);
          descriptionLastEndIndex = descriptionStartIndex + descriptionStart.length;
          var descriptionEndIndex = parsedd12.indexOf(descriptionEnd, descriptionLastEndIndex);
          // descriptionLastEndIndex = descriptionEndIndex + descriptionEnd.length;
          String des = parsedd12.substring(descriptionStartIndex + descriptionStart.length,
              descriptionEndIndex != -1 ? descriptionEndIndex : parsedd12.length);
          temp1 = parsedd12.substring(0, descriptionStartIndex);
          temp2 = parsedd12.substring(
              descriptionEndIndex != -1 ? descriptionEndIndex : parsedd12.length, parsedd12.length);
          parsedd12 = temp1 + temp2;

          if (des.trim() == 'Notes from notes section' ||
              des.trim() == 'testing notes from the notes section' ||
              des.trim() == 'notes area test') {
            null;
          } else {
            descriptionList.add(des.trim());
          }
        } else {
          i = parsedd12.length;
        }
      }

//direction of use

      var directionOfUseStart = ";prescription";
      var directionOfUseEnd = ";lab_tests";
      var directionOfUseStartIndex = value.indexOf(directionOfUseStart);
      var directionOfUseEndIndex = value.indexOf(directionOfUseEnd, directionOfUseLastEndIndex);
      directionOfUseLastEndIndex = directionOfUseEndIndex + directionOfUseEnd.length;
      String prescrpton = value.substring(
          directionOfUseStartIndex + directionOfUseStart.length, directionOfUseEndIndex);
      var dirOfUseList = [];
      var drugNameList = [];
      for (int j = 0; j < prescrpton.length; j++) {
        if (prescrpton.contains("direction_of_use")) {
          var dirOfUseStart = ";direction_of_use";
          var dirOfUseEnd = ";SIG";
          var dirOfUseStartIndex = prescrpton.indexOf(dirOfUseStart);
          var dirOfUseEndIndex = prescrpton.indexOf(dirOfUseEnd, dirOfUseLastEndIndex);
          dirOfUseLastEndIndex = dirOfUseEndIndex + dirOfUseEnd.length;
          String e =
              prescrpton.substring(dirOfUseStartIndex + dirOfUseStart.length, dirOfUseEndIndex);
          var parsede1 = e.replaceAll('&quot;', ' ');
          var parsede2 = parsede1.replaceAll(':', ' ');
          var parsede3 = parsede2.replaceAll(',', '');
          var parsede4 = parsede3.replaceAll('&quot', '');
          var parsede5 = parsede4.replaceAll('[{', '');
          var parsede6 = parsede5.replaceAll('\\\\n', '\n');
          var parsede7 = parsede6.replaceAll('\\', '');
          var parsede8 = parsede7.replaceAll('}]', '');
          var parsede9 = parsede8.replaceAll('}', '');
          var parsede10 = parsede9.replaceAll('{', '');
          var parsede11 = parsede10.replaceAll('&#39;', '');
          var parsede12 = parsede11.replaceAll('[', '');
          var parsede13 = parsede12.replaceAll(']', '');
          parsede12 = parsede13;
          temp1 = prescrpton.substring(0, dirOfUseStartIndex);
          temp2 = prescrpton.substring(dirOfUseEndIndex, prescrpton.length);
          prescrpton = temp1 + temp2;

          dirOfUseList.add(parsede12.trim());
//drug name extraction
          var drugNameStart = ";drug_name";
          var drugNameEnd = ";quantity";
          var drugNameStartIndex = prescrpton.indexOf(drugNameStart);
          var drugNameEndIndex = prescrpton.indexOf(drugNameEnd, drugNameLastEndIndex);
          drugNameLastEndIndex = drugNameEndIndex + drugNameEnd.length;
          String f =
              prescrpton.substring(drugNameStartIndex + drugNameStart.length, drugNameEndIndex);

          var parsedf1 = f.replaceAll('&quot;', ' ');
          var parsedf2 = parsedf1.replaceAll(':', ' ');
          var parsedf3 = parsedf2.replaceAll(',', '');
          var parsedf4 = parsedf3.replaceAll('&quot', '');
          var parsedf5 = parsedf4.replaceAll('[{', '');
          var parsedf6 = parsedf5.replaceAll('\\\\n', '\n');
          var parsedf7 = parsedf6.replaceAll('\\', '');
          var parsedf8 = parsedf7.replaceAll('}]', '');
          var parsedf9 = parsedf8.replaceAll('}', '');
          var parsedf10 = parsedf9.replaceAll('{', '');
          var parsedf11 = parsedf10.replaceAll('&#39;', '');
          var parsedf12 = parsedf11.replaceAll('[', '');
          var parsedf13 = parsedf12.replaceAll(']', '');
          parsedf12 = parsedf13;
          temp1 = prescrpton.substring(0, drugNameStartIndex);
          temp2 = prescrpton.substring(drugNameEndIndex, prescrpton.length);
          prescrpton = temp1 + temp2;

          drugNameList.add(parsedf12.trim());
        } else {
          j = prescrpton.length;
        }
      }

      Map<String, dynamic> app = {};
      app['appointment_id'] = parseda3;
      app['reason_for_visit'] = parsedb3;
      app["alergy"] = parsedc3;
      app["notes"] = descriptionList;
      app['direction_of_use'] = dirOfUseList;
      app['drug_name'] = drugNameList;
      reasonForVisit.add(app);
    } else {
      i = value.length;
    }
  }

  return [value, reasonForVisit];
}
