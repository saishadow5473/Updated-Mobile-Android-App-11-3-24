// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, missing_return, unnecessary_statements, non_constant_identifier_names
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/CrossbarUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/consultation_summary.dart' as c;
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
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

class GenixWebView extends StatefulWidget {
  final String appointmentId;
  final ChromeSafariBrowser browser = IHLChromeSafariBrowser();

  GenixWebView({Key key, this.appointmentId}) : super(key: key);
  @override
  _GenixWebViewState createState() => _GenixWebViewState();
}

class _GenixWebViewState extends State<GenixWebView> {
  http.Client _client = http.Client(); //3gb
  bool _isLoading = false;
  String genixURL;
  String vendorAppointmentId;
  Client genixWebViewClient;
  Session genixWebViewSession;
  InAppWebViewController _webViewController;
  var consultantNameFromAPI;
  var specialityFromAPI;
  var appointmentStartTimeFromAPI;
  var appointmentEndTimeFromAPI;
  var appointmentStatusFromAPI;
  var callStatusFromAPI;
  var consultationFeesFromAPI;
  var modeOfPaymentFromAPI;
  var appointmentModelFromAPI;
  var reasonOfVisitFromAPI;
  var allergyFromAPI;
  var userFirstNameFromAPI;
  var userLastNameFromAPI;
  var userEmailFromAPI;
  var userContactFromAPI;
  var ihlConsultantIDFromAPI;
  var vendorConsultatationIDFromAPI;
  var vendorNameFromAPI;
  var provider;
  var consultationDetails;
  Timer timergenixSession;
  bool istimergenixSession = false;

  var genixAppoinmentID;
  var isGenixCallAlive;

  void iosOpenWebview() async {
    await widget.browser.open(
      url: Uri.parse(genixURL),
      options: ChromeSafariBrowserClassOptions(
        ios: IOSSafariOptions(
            barCollapsingEnabled: true,
            presentationStyle: IOSUIModalPresentationStyle.FULL_SCREEN),
      ),
    );
  }

  void iosCloseWebview() async {
    await widget.browser.close();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => alertDialogBox(),
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text("Video Call"),
            centerTitle: true,
            actions: [
              TextButton(
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => alertDialogBox(),
              ),
            ],
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
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      child: Column(children: <Widget>[
                      Expanded(
                        child: Container(
                          child: InAppWebView(
                              initialUrlRequest:
                                  URLRequest(url: Uri.parse(genixURL)),
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
                                  (InAppWebViewController controller,
                                      String origin,
                                      List<String> resources) async {
                                return PermissionRequestResponse(
                                    resources: resources,
                                    action:
                                        PermissionRequestResponseAction.GRANT);
                              }),
                        ),
                      ),
                    ]))),
    );
  }

  alertDialogBox() {
    _buildChild(BuildContext context) => Container(
          height: 350,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Column(
            children: <Widget>[
              Container(
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Icon(
                          FontAwesomeIcons.questionCircle,
                          size: 80,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    )),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12))),
              ),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: Text(
                  'Are you sure want to \n End the call ?',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 10,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      primary: AppColors.primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 13.0, bottom: 13.0, right: 15, left: 15),
                      child: Text(
                        'Yes',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('genixAppoinmentID', "");
                      prefs.setBool('isGenixCallAlive', false);
                      genixAppoinmentID = "";
                      isGenixCallAlive = false;
                      istimergenixSession = false;
                      Get.offAll(ViewallTeleDashboard());
                    },
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      primary: AppColors.primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 13.0, bottom: 13.0, right: 15, left: 15),
                      child: Text(
                        'No',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: _buildChild(context),
            ),
          );
        });
  }

  @override
  Future<void> initState() {
    // TODO: implement initState

    super.initState();
    generateURl(widget.appointmentId);
    genixCrossbar();
    genixSessionMaintainer();
    istimergenixSession = true;
    currentPage = "GenixCall";
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

  void genixCrossbar() async {
    if (genixWebViewSession != null) {
      genixWebViewSession.close();
    }
    connect();
    genixWebViewSession = await genixWebViewClient.connect().first;
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHLUserId = res['User']['id'];
//Genix prescription notification
    final prefs = await SharedPreferences.getInstance();
    genixAppoinmentID = widget.appointmentId;
    isGenixCallAlive = prefs.getBool('isGenixCallAlive');
    try {
      final subscription = await genixWebViewSession.subscribe(
          'ihl_send_data_to_user_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) {
        Map<String, dynamic> data = event.arguments[0];
        var command = data['cmd'];
        var receiverIds = data['data']['receiver_ids'];
        print(receiverIds);
        if (receiverIds == iHLUserId) {
          if (command == "AfterCallPrescriptionStatus") {
            if ((genixAppoinmentID != "" || genixAppoinmentID != null) &&
                isGenixCallAlive == true) {
              istimergenixSession = false;
              appointmentDetails(genixAppoinmentID);
              Future.delayed(const Duration(seconds: 10), () {
                if (Platform.isIOS) {
                  iosCloseWebview();
                }
                // Get.offAll(c.ConsultSummaryPage());
              });
            }
          }
        }
      });
      await subscription.onRevoke.then((reason) =>
          print('The server has killed my subscription due to: ' + reason));
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  //timer to run checkAndMaintainSeesion Function for every 3seconds
  Future<void> genixSessionMaintainer() async {
    timergenixSession = new Timer.periodic(
      Duration(seconds: 3),
      (timer3secgenixSession) {
        if (genixWebViewSession != null) {
          genixWebViewSession.onConnectionLost.then((value) => genixCrossbar());
        } else {
          genixCrossbar();
        }
        if (istimergenixSession == false) {
          timer3secgenixSession.cancel();
        }
      },
    );
  }

  Future<Map> appointmentDetails(String appointmentID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var authToken = prefs.get('auth_token');
    var userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    String iHLUserToken = decodedResponse['Token'];
    final response = await _client.get(
        Uri.parse(API.iHLUrl +
            '/consult/get_appointment_details?appointment_id=' +
            appointmentID),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': authToken,
          'Token': iHLUserToken
        });
    if (response.statusCode == 200) {
      if (response.body != '""') {
        String value = response.body;
        var lastStartIndex = 0;
        var lastEndIndex = 0;
        var reasonLastEndIndex = 0;
        var alergyLastEndIndex = 0;
        var notesLastEndIndex = 0;
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
            var reasonStartIndex = value.indexOf(
              reasonStart,
            );
            var reasonEndIndex = value.indexOf(reasonEnd, reasonLastEndIndex);
            reasonLastEndIndex =
                value.indexOf(reasonEnd, reasonLastEndIndex) + reasonEnd.length;
            String b = value.substring(
                reasonStartIndex + reasonStart.length, reasonEndIndex);
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
            String c = value.substring(
                alergyStartIndex + alergyStart.length, alergyEndIndex);
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
            String d = value.substring(
                notesStartIndex + notesStart.length, notesEndIndex);
            var parsedd1 = d.replaceAll('&quot;', '');
            var parsedd2 = parsedd1.replaceAll(':', '');
            var parsedd3 = parsedd2.replaceAll(',', '');
            var parsedd4 = parsedd3.replaceAll('&quot', '');
            var parsedd5 = parsedd4.replaceAll('[{', '');
            var parsedd6 = parsedd5.replaceAll('\\', '');
            var parsedd7 = parsedd6.replaceAll('}]', '');
            var parsedd8 = parsedd7.replaceAll('}', '');
            var parsedd9 = parsedd8.replaceAll('{', '');
            var parsedd10 = parsedd9.replaceAll('&#39;', '');
            var parsedd11 = parsedd10.replaceAll('[', '');
            var parsedd12 = parsedd11.replaceAll(']', '');
            temp1 = value.substring(0, notesStartIndex);
            temp2 = value.substring(notesEndIndex, value.length);
            value = temp1 + temp2;

            Map<String, String> app = {};
            app['appointment_id'] = parseda3;
            app['reason_for_visit'] = parsedb3;
            app["alergy"] = parsedc3;
            app['notes'] = parsedd12;
            reasonForVisit.add(app);
          } else {
            i = value.length;
          }
        }

        var parsedString = value.replaceAll('&quot', '"');
        var parsedString2 = parsedString.replaceAll("\\\\\\", "");
        var parsedString3 = parsedString2.replaceAll("\\", "");
        var parsedString4 = parsedString3.replaceAll(";", "");
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
          details['message']['reason_for_visit'] =
              reasonForVisit[i]['reason_for_visit'];
          details['message']['alergy'] = reasonForVisit[i]['alergy'];
          details['message']['notes'] = reasonForVisit[i]['notes'];
          //  print(details['message']['reason_for_visit']);
          //  print(details['message']['alergy']);
        }
        if (this.mounted) {
          setState(() {
            consultationDetails = details;
          });
        }

        if (this.mounted) {
          setState(() {
            consultantNameFromAPI =
                consultationDetails["message"]["consultant_name"].toString() ??
                    "N/A";
            specialityFromAPI =
                consultationDetails["message"]["specality"].toString() ?? "N/A";
            appointmentStartTimeFromAPI = consultationDetails["message"]
                        ["appointment_start_time"]
                    .toString() ??
                "N/A";
            appointmentEndTimeFromAPI = consultationDetails["message"]
                        ["appointment_end_time"]
                    .toString() ??
                "N/A";
            appointmentStatusFromAPI = consultationDetails["message"]
                        ["appointment_status"]
                    .toString() ??
                "N/A";
            callStatusFromAPI =
                consultationDetails["message"]["call_status"].toString() ??
                    "N/A";
            consultationFeesFromAPI = consultationDetails["message"]
                        ["consultation_fees"]
                    .toString() ??
                "N/A";
            modeOfPaymentFromAPI =
                consultationDetails["message"]["mode_of_payment"].toString() ??
                    "N/A";
            appointmentModelFromAPI = consultationDetails["message"]
                        ["appointment_model"]
                    .toString() ??
                "N/A";
            reasonOfVisitFromAPI =
                consultationDetails["message"]["reason_for_visit"].toString() ??
                    "N/A";
            allergyFromAPI =
                consultationDetails["message"]["alergy"].toString() ?? "N/A";
            userFirstNameFromAPI = consultationDetails["user_details"]
                        ["user_first_name"]
                    .toString() ??
                "N/A";
            userLastNameFromAPI = consultationDetails["user_details"]
                        ["user_last_name"]
                    .toString() ??
                "N/A";
            userEmailFromAPI =
                consultationDetails["user_details"]["user_email"].toString() ??
                    "N/A";
            userContactFromAPI = consultationDetails["user_details"]
                        ["user_mobile_number"]
                    .toString() ??
                "N/A";
            ihlConsultantIDFromAPI = consultationDetails["message"]
                        ["ihl_consultant_id"]
                    .toString() ??
                "N/A";
            vendorConsultatationIDFromAPI = consultationDetails["message"]
                        ["vendor_consultant_id"]
                    .toString() ??
                "N/A";
            vendorNameFromAPI =
                consultationDetails["message"]["vendor_name"].toString() ??
                    "N/A";
            provider = consultationDetails["consultant_details"]["provider"]
                    .toString() ??
                "N/A";
          });
        }
        setDataForConsultationSummaryAndBill();
        // calllog('user', consultationDetails["message"]["user_ihl_id"], 'join',
        //     appointmentID.toString(), '');
      } else {
        consultationDetails = {};
      }
    }
    return consultationDetails;
  }

  setDataForConsultationSummaryAndBill() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'appointmentIdFromConsultationStages', widget.appointmentId);
    prefs.setString("consultantNameFromStages", consultantNameFromAPI);
    prefs.setString("specialityFromStages", specialityFromAPI);
    prefs.setString(
        "appointmentStartTimeFromStages", appointmentStartTimeFromAPI);
    prefs.setString("appointmentEndTimeFromStages", appointmentEndTimeFromAPI);
    prefs.setString("appointmentStatusFromStages", appointmentStatusFromAPI);
    prefs.setString("callStatusFromStages", callStatusFromAPI);
    prefs.setString("consultationFeesFromStages", consultationFeesFromAPI);
    prefs.setString("modeOfPaymentFromStages", modeOfPaymentFromAPI);
    prefs.setString("appointmentModelFromStages", appointmentModelFromAPI);
    prefs.setString("reasonOfVisitFromStages", reasonOfVisitFromAPI);
    prefs.setString("allergyFromStages", allergyFromAPI);

    prefs.setString("userFirstNameFromStages", userFirstNameFromAPI);
    prefs.setString("userLastNameFromStages", userLastNameFromAPI);
    prefs.setString("userEmailFromStages", userEmailFromAPI);
    prefs.setString("userContactFromStages", userContactFromAPI);

    prefs.setString("ihlConsultantIDFromStages", ihlConsultantIDFromAPI);
    prefs.setString(
        "vendorConsultatationIDFromStages", vendorConsultatationIDFromAPI);
    prefs.setString("vendorNameFromStages", vendorNameFromAPI);
    prefs.setString("provider_FromStages", provider);
    //navigation
    Get.offAll(c.ConsultSummaryPage());
  }

  generateURl(var appoinmentId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('genixAppoinmentID', widget.appointmentId);
    prefs.setBool('isGenixCallAlive', true);

    final genixURLResponse = await _client.get(
      Uri.parse(API.iHLUrl +
          '/consult/get_existing_appointment_url_for_genix?ihl_appointment_id=' +
          appoinmentId),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    if (genixURLResponse.statusCode == 200) {
      var parsedString = genixURLResponse.body.replaceAll('&quot;', '"');
      var parsedString2 = parsedString.replaceAll('"[', "[");
      var parsedString3 = parsedString2.replaceAll(']"', ']');
      var parsedString4 = parsedString3.replaceAll('}"', '}');
      List finalResponse = json.decode(parsedString3);
      setState(() {
        for (int i = 0; i < finalResponse.length; i++) {
          if (finalResponse[i]['Type'] == "Participant") {
            genixURL = finalResponse[i]['URL'];
            print(
                '###################################################################################');
            print(genixURL);
            if (Platform.isIOS) {
              iosOpenWebview();
            }
          }
        }
        callStatusUpdate(appoinmentId, 'on_going');
        if (genixURL != null) {
          _isLoading = true;
        }
      });
    }
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
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      // headers: {'ApiToken': apiToken},
    );
    if (response.statusCode == 200) {
      var parsedString = response.body.replaceAll('&quot', '"');
      var parsedString1 = parsedString.replaceAll(";", "");
      var parsedString2 = parsedString1.replaceAll('"{', '{');
      var parsedString3 = parsedString2.replaceAll('}"', '}');
      var callStatusUpdate = json.decode(parsedString3);
      String apiResponse = callStatusUpdate['status'].toString();
      if (apiResponse == 'Update Sucessfull') {
      } else {}
    }
  }
}

//old format webview
//  body: Container(
//       child: Stack(
//         children: [
//           Positioned(
//             top: 10,
//             bottom: 560,
//             right: 280,
//             left: 5,
//             child: ElevatedButton(
//               shape: new CircleBorder(),
//               child: Icon(Icons.photo_size_select_large),
//               onPressed: () {
//                 setState(() {
//                   _isPip = false;
//                 });
//               },
//               color: Colors.grey[350],
//             ),
//           ),
//           Container(
//             child: Center(
//               child: Text('Consultation Stages'),
//             ),
//           ),
//           _isPip
//               ? Stack(
//                   children: [
//                     Positioned(
//                       top: 380,
//                       bottom: 5,
//                       right: 10,
//                       left: 120,
//                       child: WebView(
//                         initialUrl: "https://stg.hummy.io/-/RETJB",
//                         initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy
//                             .require_user_action_for_all_media_types,
//                         javascriptMode: JavascriptMode.unrestricted,
//                       ),
//                     ),
//                   ],
//                 )
//               : Stack(
//                   children: [
//                     WebView(
//                       initialUrl:
//                           "https://ks.genixits.com/Call/PatientVideo?id=18e6ca3a-d41c-4bd1-ae5a-e120f1a4c208&quot", //"https://stg.hummy.io/-/RETJB",

//                       javascriptMode: JavascriptMode.unrestricted,
//                     ),
//                     //uncomment this below part if need to show second screen skimuntaneoulsy
//                     // Positioned(
//                     //   top: 10,
//                     //   bottom: 560,
//                     //   right: 280,
//                     //   left: 5,
//                     //   child: ElevatedButton(
//                     //     shape: new CircleBorder(),
//                     //     child: Icon(Icons.photo_size_select_large),
//                     //     onPressed: () {
//                     //       setState(() {
//                     //         _isPip = true;
//                     //       });
//                     //     },
//                     //     color: Colors.grey[350],
//                     //   ),
//                     // ),
//                     Positioned(
//                       top: MediaQuery.of(context).size.height / 1.3,
//                       bottom: MediaQuery.of(context).size.height / 6,
//                       right: MediaQuery.of(context).size.width / 6,
//                       left: MediaQuery.of(context).size.width / 6,
//                       child: ElevatedButton(
//                         shape: new CircleBorder(),
//                         child: Icon(Icons.call_end),
//                         onPressed: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => ConsultStagesPage())),
//                         color: Colors.red,
//                       ),
//                     ),
//                   ],
//                 ),
//         ],
//       ),
//     ));
//   }
