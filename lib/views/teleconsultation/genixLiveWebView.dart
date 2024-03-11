// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, missing_return, unnecessary_statements, non_constant_identifier_names
import 'dart:convert';
import 'dart:io';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class GenixLiveWebView extends StatefulWidget {
  final String iHLUserId;
  final String specality;
  final String vendor_consultant_id;
  final String genixAppointId;
  final String url;
  final ChromeSafariBrowser browser = IHLChromeSafariBrowser();

  GenixLiveWebView(
      {Key key,
      this.iHLUserId,
      this.genixAppointId,
      this.specality,
      this.vendor_consultant_id,
      this.url})
      : super(key: key);
  @override
  _GenixLiveWebViewState createState() => _GenixLiveWebViewState();
}

class _GenixLiveWebViewState extends State<GenixLiveWebView> {
  http.Client _client = http.Client(); //3gb
  bool _isLoading = false;
  String genixURL;
  String vendorAppointmentId;
  bool _isPip = false;
  Client genixWebViewClient;
  Session genixWebViewSession;
  InAppWebViewController _webViewController;
  ur() async {
    final genixResponse = await _client.get(
      Uri.parse(API.iHLUrl +
          "/consult/get_existing_appointment_url_for_genix?ihl_appointment_id=${widget.genixAppointId}"),
      // Uri.parse(API.iHLUrl+"/consult/direct_call_to_genix?ihl_user_id=${widget.iHLUserId.toString()}&specality=${widget.specality}&vendor_consultant_id=${widget.vendor_consultant_id}&ihl_appointment_id=${widget.genixAppointId}"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      // headers: {
      //   'ApiToken': "tNfJTkJafsrzhJB3KQteyk2caz5Ye2OukglXvXr+ez8pB33+C2D+w+zHEHJ7UgboKrrf50P/jE8+On1IOVlObEsDyK/Gtf6iItpBPAwOcc0BAA==",
      //   'Token': "9Jk4Kqbm4qVOwRbftbg2s9Qu7tXxxiPvKcdLl/kPwbckzpWyrZc6OLaJ6KbiGBDDCSCHayHvYnDmxHqk9sND9uhRNhjflKmXsxnDes/YHSdBhka4Msh5zoheHPRCiPtyvtRHVz6yxBOpUBexiFIRCZJDswg7j198BH9+6ITZoNZhwe3RV9+43FlbbMlPkaFDAQA="
      //   },
      // headers: {
      //   'ApiToken':
      //       "tNfJTkJafsrzhJB3KQteyk2caz5Ye2OukglXvXr+ez8pB33+C2D+w+zHEHJ7UgboKrrf50P/jE8+On1IOVlObEsDyK/Gtf6iItpBPAwOcc0BAA=="
      // },
    );
    if (genixResponse.statusCode == 200) {
      var parsedString = genixResponse.body.replaceAll('&quot;', '"');
      var parsedString2 = parsedString.replaceAll('"[', '[');
      var parsedString3 = parsedString2.replaceAll(']"', ']');
      // var parsedString4 = parsedString3.replaceAll('}"', '}');
      var finalResponse = json.decode(parsedString3);
      String liveCallLink = '';
      for (int i = 0; i < finalResponse.length; i++) {
        if (finalResponse[i]['Type'] == 'Participant') {
          liveCallLink = finalResponse[i]['URL'];
        }
      }
      // String liveCallLink = finalResponse[0]['URL'];
      print(liveCallLink);
      if (mounted) {
        setState(() {
          genixURL = liveCallLink;
          _isLoading = true;
          if (Platform.isIOS) {
            iosWebview();
          }
        });
      }
      // ${iHLUserId.toString()}&specality=${widget.details['specality'].toString()}&vendor_consultant_id=${widget.details['doctor']['vendor_consultant_id'].toString()}&ihl_appointment_id=$genixAppointId",
      // Get.off(GenixLiveWebView(
      //   genixAppointId: genixAppointId,
      //   url: liveCallLink,
      //   iHLUserId: iHLUserId.toString(),
      //   specality: widget.details['specality'].toString(),
      //   vendor_consultant_id:
      //       widget.details['doctor']['vendor_consultant_id'].toString(),
      // )
      // );
    } else {
      print('api response failure status code is ${genixResponse.statusCode}');
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Call"),
        centerTitle: true,
      ),
      body: _isLoading == false
          ? Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text("Loading video call")
                  ],
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
                        Text("Ongoing Consultation",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)
                      ],
                    ),
                  ),
                )
              : Container(
                  child: Column(children: <Widget>[
                  Expanded(
                    child: Container(
                      child: InAppWebView(
                          initialUrlRequest: URLRequest(
                              url: Uri.parse(genixURL != null
                                  ? genixURL
                                  : 'www.google.com')),
                          // "https://meet.indiahealthlink.com/teleconsultation",
                          // "https://ks.genixits.com/Call/PatientVideo?id=fb2372c2-b6e3-484e-b2b1-9ce7f2f7ddef",
                          initialOptions: InAppWebViewGroupOptions(
                            crossPlatform: InAppWebViewOptions(
                              mediaPlaybackRequiresUserGesture: false,
                            ),
                          ),
                          onWebViewCreated:
                              (InAppWebViewController controller) {
                            _webViewController = controller;
                          },
                          androidOnPermissionRequest:
                              (InAppWebViewController controller, String origin,
                                  List<String> resources) async {
                            return PermissionRequestResponse(
                                resources: resources,
                                action: PermissionRequestResponseAction.GRANT);
                          }),
                    ),
                  ),
                ])),
      // Container(
      // child: Column(children: <Widget>[
      //   Expanded(
      //     child: Container(
      //       child: InAppWebView(
      //           initialUrl: widget.url,
      //           initialOptions: InAppWebViewGroupOptions(
      //             crossPlatform: InAppWebViewOptions(
      //               mediaPlaybackRequiresUserGesture: false,
      //               debuggingEnabled: true,
      //             ),
      //           ),
      //           onWebViewCreated: (InAppWebViewController controller) {
      //             _webViewController = controller;
      //           },
      //           androidOnPermissionRequest:
      //               (InAppWebViewController controller, String origin,
      //               List<String> resources) async {
      //             return PermissionRequestResponse(
      //                 resources: resources,
      //                 action: PermissionRequestResponseAction.GRANT,
      //                 );
      //           }),
      //     ),
      //   ),
      // ])
      // ),
    );
  }

  @override
  void initState() {
    ur();
    // TODO: implement initState
    super.initState();
    // generateURl(widget.iHLUserId,widget.genixAppointId,widget.specality,widget.vendor_consultant_id);
    appointmentSubscribe();
  }

  void connect() async {
    genixWebViewClient = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
  }

  void appointmentSubscribe() async {
    if (genixWebViewSession != null) {
      genixWebViewSession.close();
    }
    connect();
    genixWebViewSession = await genixWebViewClient.connect().first;
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHLUserId = res['User']['id'];

    try {
      final subscription = await genixWebViewSession.subscribe(
          'ihl_send_data_to_user_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) {
        Map<String, dynamic> data = event.arguments[0];
        var command = data['data']['cmd'];
        var receiverIds = [];
        receiverIds = data['receiver_id'] ?? data['receiver_ids'];
        print(receiverIds);
        if (receiverIds.contains(iHLUserId)) {
          if (command == 'AfterCallPrescriptionStatus') {
          } else if (command == 'CallEndedByDoctor') {
            Future.delayed(const Duration(seconds: 10), () {
              // JitsiMeet.closeMeeting();
              //JitsiMeet.removeAllListeners();
            });

            // //JitsiMeet.removeAllListeners();
            // if (widget.callModel != 'SubscriptionCall') {
            //   // calllog('user', widget.userId, 'end',
            //   //     widget.appointmentId.toString(), '');
            //   if (iscallError == true &&
            //       callErrorAppointmentId == widget.appointmentId.toString()) {
            //     callErrorDialog(widget.callModel);
            //   } else {
            //     callStatusUpdate(widget.appointmentId.toString(), 'completed');
            //     //currentAppointmentStatusUpdate(widget.appointmentId.toString(), 'completed');
            //     // calllog('user', widget.userId, 'end',
            //     //     widget.appointmentId.toString(), '');
            //     startTimer90Seconds(widget.callModel);
            //   }
            // }
          } else if (command == 'AfterCallPrescription') {
            // if (this.mounted) {
            //   setState(() {
            //     var teleMedicineStatus = data['data']['perscription_obj'];
            //     appointId = teleMedicineStatus["appointment_id"];
            //     consultationNotes = {
            //       'diagnosis': teleMedicineStatus["diagnosis"],
            //       'consultation_advice_notes':
            //       teleMedicineStatus["consultation_advice_notes"],
            //     };
            //     setAppointId(appointId);
            //     consultationstagesession.close();
            //   });
            // }
          }
        }
      });
      await subscription.onRevoke.then((reason) =>
          print('The server has killed my subscription due to: ' + reason));
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }
  //
  // Future<String> appointmentDetails(String appointmentID) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var authToken = prefs.get('auth_token');
  //   var userData = prefs.get('data');
  //   var decodedResponse = jsonDecode(userData);
  //   String iHLUserToken = decodedResponse['Token'];
  //   final response = await http.get(
  //       'https://testing.indiahealthlink.com:750/consult/get_appointment_details?appointment_id=' +
  //           appointmentID,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'ApiToken': authToken,
  //         'Token': iHLUserToken
  //       });
  //   if (response.statusCode == 200) {
  //     if (response.body != '""') {
  //       var parsedString = response.body.replaceAll('&quot', '"');
  //       var parsedString2 = parsedString.replaceAll("\\\\\\", "");
  //       var parsedString3 = parsedString2.replaceAll("\\", "");
  //       var parsedString4 = parsedString3.replaceAll(";", "");
  //       var parsedString5 = parsedString4.replaceAll('""', '"');
  //       var parsedString6 = parsedString5.replaceAll('"[', '[');
  //       var parsedString7 = parsedString6.replaceAll(']"', ']');
  //       var pasrseString8 = parsedString7.replaceAll(':,', ':"",');
  //       var pasrseString9 = pasrseString8.replaceAll('"{', '{');
  //       var pasrseString10 = pasrseString9.replaceAll('}"', '}');
  //       var pasrseString11 = pasrseString10.replaceAll('}"', '}');
  //       var pasrseString12 = pasrseString11.replaceAll(':",', ':"",');
  //       var parseString13 = pasrseString12.replaceAll(':"}', ':""}');
  //       var finalOutput = parseString13.replaceAll('/"', '/');
  //       Map details = json.decode(finalOutput);
  //       if (details['message']['vendor_appointment_id'] != null) {
  //         print(details['message']['vendor_appointment_id']);
  //         return details['message']['vendor_appointment_id'];
  //       }
  //     } else {
  //       return "N/A";
  //     }
  //   }
  // }

//

}
