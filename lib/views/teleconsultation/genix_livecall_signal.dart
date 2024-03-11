// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, missing_return, unnecessary_statements, non_constant_identifier_names
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/teleconsultation/genixLiveWebView.dart';
import 'package:ihl/views/teleconsultation/genixWebView.dart';
import 'package:ihl/views/teleconsultation/selectConsultant.dart';
import 'package:ihl/views/teleconsultation/teleconsultationDashboard.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:ihl/widgets/teleconsulation/payment/paymentUI.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as WS_status;
import '../../constants/spKeys.dart';
import '../../new_design/presentation/pages/onlineServices/MyAppointment.dart';
import 'myAppointments.dart';

class IHLChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("Custom Tab opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("Tab load completed");
  }

  @override
  void onClosed() {
    print("Custom Tab closed");
  }
}

class GenixLiveSignal extends StatefulWidget {
  final String iHLUserId;
  final String specality;
  final String vendor_consultant_id;
  final String genixAppointId;
  final String url;
  final vendorConsultantId;
  final vendorAppointmentId;
  final vendorUserName;

  final ChromeSafariBrowser browser = IHLChromeSafariBrowser();

  GenixLiveSignal(
      {Key key,
      this.iHLUserId,
      this.genixAppointId,
      this.specality,
      this.vendor_consultant_id,
      this.url,
      this.vendorConsultantId,
      this.vendorAppointmentId,
      this.vendorUserName})
      : super(key: key);

  @override
  _GenixLiveSignalState createState() => _GenixLiveSignalState();
}

class _GenixLiveSignalState extends State<GenixLiveSignal> {
  http.Client _client = http.Client(); //3gb
  // bool _isLoading = false;

  bool _isLoading = false;
  bool _is_url_received = false;
  String genixURL =
      '${API.updatedIHLurl}/signalr/index.html?vendor_consultant_id=f845dfd5-2225-4ad9-a8b4-1fb2265849de&vendor_appointment_id=2d5ae469-32a3-4984-86e4-3da3fe8a138b&vendor_user_name=hassan';
  String vendorAppointmentId;
  bool _isPip = false;
  Client genixWebViewClient;
  Session genixWebViewSession;
  InAppWebViewController _webViewController;
  Client client;
  Session session;
  bool joinedCall = true;
  bool declineCall = false;
  bool acceptCall = false;
  bool callWaiting = true;
  bool doctorNotAvailable = false;
  var _timer;

  void iosCloseWebview() async {
    await widget.browser.close();
  }

  // Session bookAppointmentSession;
  void connect() {
    client = Client(
      realm: 'crossbardemo',
      transport: WebSocketTransport(
        API.crossbarUrl,
        Serializer(),
        WebSocketSerialization.SERIALIZATION_JSON,
      ),
    );
  }

  void subWebSocket() async {
    final channel = IOWebSocketChannel.connect(
      API.crossbarUrl,
    );
    channel.stream.listen((message) {
      channel.sink.add('received!');
      channel.sink.close(WS_status.goingAway);
    });
  }

  void subscribeLiveCallCrossbar() async {
    if (session != null) {
      session.close();
    }
    connect();
    session = await client.connect().first;
    try {
      final subscription = await session.subscribe('ihl_send_data_to_doctor_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) {
        Map data = event.arguments[0];
        var docStatus = data['data']['cmd'];
        //receiver ==ihl_user_id
        //

        if (docStatus == 'CallDeclinedByDoctor') {
          cancelAppointment('doctor', widget.genixAppointId, 'Rejected');
          if (Platform.isIOS) {
            iosCloseWebview();
          }
          if (mounted)
            setState(() {
              declineCall = true;
              callWaiting = false;
            });
          //decline
          _timer.cancel();
        } else if (docStatus == 'CallAcceptedByDoctor') {
          if (Platform.isIOS) {
            iosCloseWebview();
          }
          if (mounted)
            setState(() {
              acceptCall = true;
              callWaiting = false;
            });
          //
          if (joinedCall) {
            joinedCall = false;
            _timer?.cancel();
            Navigator.push(
              context,
              MaterialPageRoute(
                  // builder: (context) => GenixLiveWebView(
                  builder: (context) => GenixWebView(
                        appointmentId: widget.genixAppointId,
                      )), //user_name
            );
          }
        }
        // else if (sixtySecComplete) {
        //   ///navigate to the doctor list
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         // builder: (context) => GenixLiveWebView(
        //         builder: (context) => ViewallTeleDashboard(
        //               backNav: false,
        //             )), //user_name
        //   );
        // }
        print(data);

        ///if call accept  call the genixlivewebview , call reject > call the dashboard , if no response after certain time call my appointment
      });
    } catch (Exception) {
      print(Exception.message.message);
      if (Platform.isIOS) {
        iosCloseWebview();
      }
    }
  }

  void iosWebview() async {
    await widget.browser.open(
        url: Uri.parse(genixURL),
        options: ChromeSafariBrowserClassOptions(
            ios: IOSSafariOptions(
                barCollapsingEnabled: true,
                presentationStyle: IOSUIModalPresentationStyle.FULL_SCREEN)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (declineCall) {
            Get.to(() => ViewallTeleDashboard(
                  backNav: false,
                ));
          } else {
            _onBackPressed();
          }
        },
        child: PaymentUI(
          color: declineCall ? Colors.red : AppColors.bookApp, //AppColors.myApp,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "Live Call",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: _isLoading == false
              ? Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [CircularProgressIndicator(), Text("Loading video call")],
                    ),
                  ),
                )
              : (Platform.isIOS)
                  ? Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text("Please wait while the Consultant Joins...",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            // RawMaterialButton(
                            //     child: Text('click it...'),
                            //     onPressed: iosWebview)
                          ],
                        ),
                      ),
                    )
                  : Container(
                      child: Center(
                      child: Column(children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        lottie(),
                        text(),
                        Container(
                          height: 10,
                          width: 10,
                          // color: Colors.redAccent,
                          child: InAppWebView(
                              initialUrlRequest: URLRequest(
                                  url: Uri.parse(genixURL != null ? genixURL : 'www.google.com')),
                              // "https://meet.indiahealthlink.com/teleconsultation",
                              // "https://ks.genixits.com/Call/PatientVideo?id=fb2372c2-b6e3-484e-b2b1-9ce7f2f7ddef",
                              initialOptions: InAppWebViewGroupOptions(
                                crossPlatform: InAppWebViewOptions(
                                  mediaPlaybackRequiresUserGesture: false,
                                ),
                              ),
                              onWebViewCreated: (InAppWebViewController controller) {
                                _webViewController = controller;
                              },
                              androidOnPermissionRequest: (InAppWebViewController controller,
                                  String origin, List<String> resources) async {
                                return PermissionRequestResponse(
                                    resources: resources,
                                    action: PermissionRequestResponseAction.GRANT);
                              }),
                        ),
                      ]),
                    )),
        ));
  }

  Future<bool> _onBackPressed() {
    return showDialog(
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
        });
  }

  bool sixtySecComplete = false;
  int _start = 60;

  // int _start = 10;
  var arg;

  @override
  void initState() {
    if (mounted)
      setState(() {
        genixURL =
            '${API.updatedIHLurl}/signalr/index.html?vendor_consultant_id=${widget.vendor_consultant_id}&vendor_appointment_id=${widget.vendorAppointmentId}&vendor_user_name=${widget.vendorUserName}';

        if (Platform.isIOS) {
          _is_url_received = true;
          _isLoading = true;
        } else {
          _isLoading = true;
        }
      });
    print(genixURL);
    if (Platform.isIOS) {
      String iHLUserId_ = widget.iHLUserId;
      final String specality_ = widget.specality;
      final String vendor_consultant_id_ = widget.vendor_consultant_id;
      final String genixAppointId_ = widget.genixAppointId;
      final String url_ = widget.url;
      final vendorConsultantId = widget.vendorConsultantId;
      final vendorAppointmentId_ = widget.vendorAppointmentId;
      final vendorUserName_ = widget.vendorUserName;
      var x = jsonEncode({
        'iHLUserId_': widget.iHLUserId,
        'specality_': widget.specality,
        'vendor_consultant_id_': widget.vendor_consultant_id,
        'genixAppointId_': widget.genixAppointId,
        'url_': widget.url,
        'vendorConsultantId': widget.vendorConsultantId,
        'vendorAppointmentId_': widget.vendorAppointmentId,
        'vendorUserName_': widget.vendorUserName
      });
      print(x);
      if (_is_url_received) iosWebview();
      // Future.delayed(Duration(seconds: 5));
      // if(mounted)setState(() {
      //   _isLoading = true;
      // });
    }
    subWebSocket();
    subscribeLiveCallCrossbar();
    timeOut();
    arg = SpUtil.getObject('selectConsultantTypeData');
    print(arg.toString());
    // ur();
    // TODO: implement initState
    super.initState();
    // generateURl(widget.iHLUserId,widget.genixAppointId,widget.specality,widget.vendor_consultant_id);
    // appointmentSubscribe();
  }

  void dispose() {
    if (session != null) {
      session.close();
    }
    super.dispose();
  }

  callStatusUpdate() async {
    var txt = {
      "appointment_id": "${widget.genixAppointId}",
      "call_status": "Missed",
    };

    try {
      final callStatusResponse = await _client.get(
        Uri.parse(API.iHLUrl +
            '/consult/update_call_status?appointment_id=${widget.genixAppointId}&call_status=Missed'),
        headers: {
          'ApiToken':
              "hZH2vKcf1BPjROFM/DY0XAt89wo/09DXqsAzoCQC5QHYpXttcd5DNPOkFuhrPWcyT57DFFR9MnAdRAXoVw1j5yupkl+ps7+Z1UoM6uOrTxUBAA=="
        },
      );
      if (callStatusResponse.statusCode == 200) {
        var parsedString = callStatusResponse.body.replaceAll('&quot;', '"');
        var parsedString2 = parsedString.replaceAll('"[', "[");
        var parsedString3 = parsedString2.replaceAll(']"', ']');
        var parsedString4 = parsedString3.replaceAll('}"', '}');
        // List finalResponse = json.decode(parsedString3);
        return 'finalResponse';
      } else {
        return 'failed';
      }
    } catch (e) {
      print(e.toString());
      return 'failed';
    }
  }

  timeOut() {
    ///after 60 second we make the timeout variable(sixtySecComplete) true
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          if (mounted)
            setState(() {
              timer.cancel();

              ///show call failed lottie
              doctorNotAvailable = true;
              declineCall = false;
              acceptCall = false;
              callWaiting = false;

              ///api call , success
              //  try{

              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(
              // builder: (context) => GenixLiveWebView(
              //   builder: (context) => SelectConsutantScreen(
              //     arg: arg,
              //     liveCall: true,
              //   )),
              //         (Route<dynamic> route) => false);    //user_name

              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => AddFood(mealType: "Breakfast")),
              //         (Route<dynamic> route) => false);
            });
          callStatusUpdate().then((value) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyAppointment()),
                (Route<dynamic> route) => false);
            // print(value);
            // Get.offAll(SelectConsutantScreen(
            //   arg: arg,
            //   liveCall: true,
            //   backNavi: true,
            // ));
            // }
            // catch(e){
            //   print(e.toString());
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       // builder: (context) => GenixLiveWebView(
            //         builder: (context) => SelectConsutantScreen(
            //           arg: arg,
            //           liveCall: true,
            //         )), //user_name
            //   );
            // }
            ///navigate to doctor list
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       // builder: (context) => GenixLiveWebView(
            //       builder: (context) => ViewallTeleDashboard(
            //             backNav: false,
            //           )), //user_name
            // );
          });
        } else {
          if (_start == 30) {
            if (Platform.isIOS) {
              iosCloseWebview();
            }
          }
          // setState(() {
          _start--;
          print(_start.toString());
          // });
        }
      },
    );
  }

  text() {
    if (declineCall) {
      return Text(
        'Sorry, Consultant declined your call.\nInitiating your refund. Please wait...!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Colors.red,
        ),
      );
    } else if (callWaiting) {
      return Text(
        'Please wait while the Consultant Joins...',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      );
    } else if (acceptCall) {
      return Text(
        'Please wait while the Consultant Joins...',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      );
    } else if (doctorNotAvailable) {
      return Text(
        'Doctor is Busy\nPlease try again',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      );
    } else {
      return Text(
        'Something went wrong...',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      );
    }
  }

  void cancelAppointment(var canceledBy, var appointId, var reason) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Options options = Options(
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    var iHLUserId = res['User']['id'];
    var transcationId = '';
    var apiToken = prefs.get('auth_token');
    final response = await Dio().post(
      API.iHLUrl + '/consult/cancel_appointment',
      options: options,
      // headers: {'ApiToken': apiToken},
      data: {
        "canceled_by": canceledBy.toString(),
        "ihl_appointment_id": appointId.toString(),
        "reason": reason.toString(),
      },
    );
    if (response.statusCode == 200) {
      var status = response.data["status"];
      var refundAmount = response.data["refund_amount"];
      if (status == "cancel_success" && refundAmount != '0') {
        final transresponce = await Dio().get(
          API.iHLUrl + "/consult/user_transaction_from_ihl_id?ihl_id=" + iHLUserId,
          options: options,
        );
        if (transresponce.statusCode == 200) {
          if (transresponce.data != "[]" || transresponce.data != null) {
            var transcationList = transresponce.data;
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
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => Get.to(() => ViewallTeleDashboard(
                          backNav: false,
                        )));
                // currentAppointmentStatusUpdate(widget.appointmentId, "Canceled");

                // List<String> receiverIds = [];
                // receiverIds.add(widget.ihlConsultantId.toString());
                // s.appointmentPublish('GenerateNotification', 'CancelAppointment', receiverIds,
                //     iHLUserId, widget.appointmentId);
                // AwesomeDialog(
                //         context: context,
                //         animType: AnimType.TOPSLIDE,
                //         headerAnimationLoop: true,
                //         dialogType: DialogType.SUCCES,
                //         dismissOnTouchOutside: false,
                //         title: 'Success!',
                //         desc: 'Appointment Successfully Cancelled! Your Refund has been Initiated.',
                //         btnOkOnPress: () {
                //           Navigator.pushAndRemoveUntil(
                //               context,
                //               MaterialPageRoute(builder: (context) => MyAppointments()),
                //               (Route<dynamic> route) => false);
                //         },
                //         btnOkColor: Colors.green,
                //         btnOkText: 'Proceed',
                //         btnOkIcon: Icons.check,
                //         onDismissCallback: (_) {})
                //     .show();
              }
            } else {
              // errorDialog();
            }
          } else {
            // errorDialog();
          }
        } else {
          // errorDialog();
        }

        // Updating getUserDetails API
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              // builder: (context) => GenixLiveWebView(
              builder: (context) => ViewallTeleDashboard(
                    backNav: false,
                  )), //user_name
        );
        // errorDialog();
      }
    } else {
      // errorDialog();
    }
  }

  lottie() {
    if (declineCall) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Lottie.network(
            // 'https://assets5.lottiefiles.com/packages/lf20_e5fibvuv.json',
            API.declinedLottieFileUrl,
            height: 280,
            width: 280),
      );
    } else if (acceptCall) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Lottie.network(API.callAcceptedLottieFileUrl, height: 280, width: 280),
      );
    } else if (callWaiting) {
      return Lottie.network('https://assets5.lottiefiles.com/packages/lf20_e5fibvuv.json',
          height: 400, width: 400);
    } else if (doctorNotAvailable) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Lottie.network(
            // 'https://assets5.lottiefiles.com/packages/lf20_e5fibvuv.json',
            API.declinedLottieFileUrl,
            height: 300,
            width: 300),
      );
    } else {
      return Lottie.network(
          // 'https://assets5.lottiefiles.com/packages/lf20_e5fibvuv.json',
          API.declinedLottieFileUrl,
          height: 200,
          width: 200);
    }
  }
}
