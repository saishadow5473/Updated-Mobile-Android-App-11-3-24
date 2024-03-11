import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:file_picker/file_picker.dart';

// import 'package:charts_flutter/flutter.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/repositories/api_consult.dart';

// import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/utils/CrossbarUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/teleconsultation/files/file_resuable_snackbar.dart';

// import 'package:get/get.dart';
// import 'package:ihl/constants/api.dart';
// import 'package:ihl/constants/app_texts.dart';
// import 'package:flutter/material.dart';
// import 'package:ihl/utils/app_colors.dart';
// import 'package:ihl/views/teleconsultation/files/file_resuable_snackbar.dart';
import 'package:ihl/views/teleconsultation/files/pdf_viewer.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

// import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:strings/strings.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'consultation_summary.dart';
import 'teleconsultation/videocall/videocall.dart';

//global variable
bool istimerConsultationStagesSession = false;

class ConsultStagesPage extends StatefulWidget {
  final String appointmentId;
  final String callModel;
  final userId;
  final List callDetails;

  const ConsultStagesPage(
      {Key key, this.appointmentId, this.callModel, this.userId, this.callDetails})
      : super(key: key);

  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<ConsultStagesPage> {
  http.Client _client = http.Client(); //3gb
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
  var prescriptionStatus;
  Map consultationDetails;

  //bool loading = true;
  String docId;
  String iHLUserId;
  var appointId;
  Client consultationstagesclient;
  var callCompleted = false;
  var noPrescription = false;
  var prescriptionCompleted = false;
  var consultationNotes;
  Session consultationstagesession;
  Timer timerConsultationStagesSession;

  bool getUserDetailsUpdate = false;
  bool isRejoin = false;
  ValueNotifier<bool> medicalFileShared = ValueNotifier(false);

  ///med files var
  var ihl_consultant_id;
  bool showMedicalFilesCard = false;
  List<String> selectedDocIdList = [];
  List medFiles = [];
  List filesNameList = [];
  bool enableMedicalFilesTile = false;
  List<String> sharedReportAppIdList = [];

  getDetails() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    iHLUserId = prefs1.getString("ihlUserId");

    ihl_consultant_id = prefs1.getString('consultantId');
    print('==========================>>>>>><<<<<<<<<<<>><><><><><><<<<> ' + ihl_consultant_id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedReportAppIdList = prefs.getStringList('sharedReportAppIdList') ?? [];

    ///call the get medical files api
    medFiles = await MedicalFilesApi.getFiles();
    for (int i = 0; i < medFiles.length; i++) {
      var name;
      if (medFiles[i]['document_name'].toString().contains('.')) {
        var parse1 = medFiles[i]['document_name'].toString().replaceAll('.jpg', '');
        var parse2 = parse1.replaceAll('.jpeg', '');
        var parse3 = parse2.replaceAll('.png', '');
        var parse4 = parse3.replaceAll('.pdf', '');
        name = parse4;
      }
      filesNameList.add(name);
    }

    if (this.mounted) {
      setState(() {
        medFiles;
      });
    }
  }

  void connect() async {
    consultationstagesclient = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
  }

  void consultationstageCrossbar({bool fileCrossbar}) async {
    if (fileCrossbar == null) {
      fileCrossbar = false;
    }
    if (consultationstagesession != null) {
      consultationstagesession.close();
    }
    connect();
    consultationstagesession = await consultationstagesclient.connect().first;

    ///med files crossbar
    if (fileCrossbar) {
      shareMedFileCrossbar();
    }
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHLUserId = res['User']['id'];

    try {
      final subscription = await consultationstagesession.subscribe('ihl_send_data_to_user_channel',
          options: SubscribeOptions(get_retained: true));
      subscription.eventStream.listen((event) async {
        Map<String, dynamic> data = event.arguments[0];
        var command = data['data']['cmd'];
        var receiverIds = [];
        receiverIds = data['receiver_id'] ?? data['receiver_ids'];
        print(receiverIds);
        if (receiverIds.contains(iHLUserId)) {
          if (command == 'AfterCallPrescriptionStatus' &&
              data['data'].containsKey("perscription_status")) {
            JitsiMeet.closeMeeting();
            prescriptionStatus = data['data']['perscription_status'];
            appointId = widget.appointmentId.toString().replaceAll('ihl_consultant_', '');
            if (prescriptionStatus == false) {
              if (this.mounted) {
                setState(() {
                  getUserDetailsUpdate = true;
                });
              }
              setAppointId(appointId);
              consultationstagesession.close();

              // Updating getUserDetails API
              SharedPreferences prefs1 = await SharedPreferences.getInstance();
              var data1 = prefs1.get('data');
              Map res = jsonDecode(data1);
              iHLUserId = res['User']['id'];
            } else if (prescriptionStatus == true) {
              if (this.mounted) {
                setState(() {
                  callCompleted = true;
                  noPrescription = false;
                });
              }
            }
          } else if (command == 'CallEndedByDoctor') {
            JitsiMeet.closeMeeting();
            counterValueConsultaionStages.value = 90;
            counterUIConsultaionStages();
            isRejoin = true;
            if (widget.callModel != 'SubscriptionCall') {
              // calllog('user', widget.userId, 'end',
              //     widget.appointmentId.toString(), '');
              if (iscallError == true &&
                  callErrorAppointmentId == widget.appointmentId.toString()) {
                callErrorDialog(widget.callModel);
              } else {
                var saveappId = widget.appointmentId.toString().replaceAll('ihl_consultant_', '');
                await callStatusUpdate(saveappId, 'completed');
                // callStatusUpdate(widget.appointmentId.toString(), 'completed');
                //currentAppointmentStatusUpdate(widget.appointmentId.toString(), 'completed');
                // calllog('user', widget.userId, 'end',
                //     widget.appointmentId.toString(), '');

                startTimer90Seconds(widget.callModel);
              }
            }
            if (mounted) setState(() {});
          } else if (command == 'AfterCallPrescription') {
            JitsiMeet.closeMeeting();
            isRejoin = true;
            if (this.mounted) {
              setState(() {
                var teleMedicineStatus = data['data']['perscription_obj'];
                appointId = teleMedicineStatus["appointment_id"];
                consultationNotes = {
                  'diagnosis': teleMedicineStatus["diagnosis"],
                  'consultation_advice_notes': teleMedicineStatus["consultation_advice_notes"],
                };
                ConsultApi().updateServiceProvided(iHLUserId, appointId);
                setAppointId(appointId);
                consultationstagesession.close();
              });
            }

            // Updating getUserDetails API
            SharedPreferences prefs1 = await SharedPreferences.getInstance();
            var data1 = prefs1.get('data');
            Map res = jsonDecode(data1);
            iHLUserId = res['User']['id'];
            if (this.mounted) {
              setState(() {
                getUserDetailsUpdate = true;
              });
            }
          }
        }
      });
      await subscription.onRevoke
          .then((reason) => print('The server has killed my subscription due to: ' + reason));
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  ///share med file crossbar///call it after shared document api succesfully 200
  void shareMedFileCrossbar() async {
    connect();
    // consultationstagesession = await client.connect().first;
    // SharedPreferences prefs = await SharedPreferences.getInstance();

    // var data = prefs.get('data');
    // Map res = jsonDecode(data);
    // iHLUserId = res['User']['id'];
    var q = {
      'data': {
        'ihl_user_id': "$iHLUserId",
        "document_id": selectedDocIdList, //selectDocumentIdList
        "appointment_id": widget.appointmentId
            .toString()
            .replaceAll('ihl_consultant_', ''), //"0b59bf916752496f98c53f94b0e50212",//appointmentId
        "ihl_consultant_id": ihl_consultant_id, //"38726ba5bfcd42f08189e5e84a4105ca"//consultant_id
      }
    };

    try {
      await consultationstagesession.publish('medical_report_share',
          arguments: [q], options: PublishOptions(retain: false));
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

//timer to run checkAndMaintainSeesion Function for every 3seconds
  Future<void> consultationStagesSessionMaintainer() async {
    timerConsultationStagesSession = new Timer.periodic(
      Duration(seconds: 3),
      (timer3secConsultationStagesSession) {
        if (consultationstagesession != null) {
          consultationstagesession.onConnectionLost.then((value) => consultationstageCrossbar());
        } else {
          consultationstageCrossbar();
        }
        if (istimerConsultationStagesSession == false) {
          timer3secConsultationStagesSession.cancel();
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
        Uri.parse(API.iHLUrl + '/consult/get_appointment_details?appointment_id=' + appointmentID),
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
        var reasonForVisit = [];
        var notesLastEndIndex = 0;
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
          details['message']['reason_for_visit'] = reasonForVisit[i]['reason_for_visit'];
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
        getItem(consultationDetails);
        if (this.mounted) {
          setState(() {
            consultantNameFromAPI =
                consultationDetails["message"]["consultant_name"].toString() ?? "N/A";
            specialityFromAPI = consultationDetails["message"]["specality"].toString() ?? "N/A";
            appointmentStartTimeFromAPI =
                consultationDetails["message"]["appointment_start_time"].toString() ?? "N/A";
            appointmentEndTimeFromAPI =
                consultationDetails["message"]["appointment_end_time"].toString() ?? "N/A";
            appointmentStatusFromAPI =
                consultationDetails["message"]["appointment_status"].toString() ?? "N/A";
            callStatusFromAPI = consultationDetails["message"]["call_status"].toString() ?? "N/A";
            consultationFeesFromAPI =
                consultationDetails["message"]["consultation_fees"].toString() ?? "N/A";
            modeOfPaymentFromAPI =
                consultationDetails["message"]["mode_of_payment"].toString() ?? "N/A";
            appointmentModelFromAPI =
                consultationDetails["message"]["appointment_model"].toString() ?? "N/A";
            reasonOfVisitFromAPI =
                consultationDetails["message"]["reason_for_visit"].toString() ?? "N/A";
            allergyFromAPI = consultationDetails["message"]["alergy"].toString() ?? "N/A";
            userFirstNameFromAPI =
                consultationDetails["user_details"]["user_first_name"].toString() ?? "N/A";
            userLastNameFromAPI =
                consultationDetails["user_details"]["user_last_name"].toString() ?? "N/A";
            userEmailFromAPI =
                consultationDetails["user_details"]["user_email"].toString() ?? "N/A";
            userContactFromAPI =
                consultationDetails["user_details"]["user_mobile_number"].toString() ?? "N/A";
            ihlConsultantIDFromAPI =
                consultationDetails["message"]["ihl_consultant_id"].toString() ?? "N/A";
            vendorConsultatationIDFromAPI =
                consultationDetails["message"]["vendor_consultant_id"].toString() ?? "N/A";
            vendorNameFromAPI = consultationDetails["message"]["vendor_name"].toString() ?? "N/A";
            provider = consultationDetails["consultant_details"]["provider"].toString() ?? "N/A";
          });
        }
        setDataForConsultationSummaryAndBill();
      } else {
        consultationDetails = {};
      }
    }
    return consultationDetails;
  }

  setDataForConsultationSummaryAndBill() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("consultantNameFromStages", consultantNameFromAPI);
    prefs.setString("specialityFromStages", specialityFromAPI);
    prefs.setString("appointmentStartTimeFromStages", appointmentStartTimeFromAPI);
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
    prefs.setString("vendorConsultatationIDFromStages", vendorConsultatationIDFromAPI);
    prefs.setString("vendorNameFromStages", vendorNameFromAPI);
    prefs.setString("provider_FromStages", provider);
    if (prescriptionStatus == false) {
      if (this.mounted) {
        setState(() {
          callCompleted = true;
          noPrescription = true;
        });
      }
    } else {
      prescriptionCompleted = true;
      consultationstagesession?.close();
    }
    prescriptionStatus = false;
  }

  ConsultSummaryPage getItem(Map map) {
    return ConsultSummaryPage(
        consultantName: map["message"]["consultant_name"].toString() ?? "N/A",
        speciality: map["message"]["specality"].toString() ?? "N/A",
        appointmentStartTime: map["message"]["appointment_start_time"].toString() ?? "N/A",
        appointmentEndTime: map["message"]["appointment_end_time"].toString() ?? "N/A",
        appointmentStatus: map["message"]["appointment_status"].toString() ?? "N/A",
        callStatus: map["message"]["call_status"].toString() ?? "N/A",
        consultationFees: map["message"]["consultation_fees"].toString() ?? "N/A",
        modeOfPayment: map["message"]["mode_of_payment"].toString() ?? "N/A",
        appointmentModel: map["message"]["appointment_model"].toString() ?? "N/A",
        reasonOfVisit: map["message"]["reason_for_visit"].toString() ?? "N/A",
        provider: map["consultant_details"]["provider"].toString() ?? "N/A");
  }

  bool callConnected = false;

  @override
  void initState() {
    super.initState();
    consultationstageCrossbar();
    counterValueConsultaionStages.value = 90;
    consultationStagesSessionMaintainer();
    istimerConsultationStagesSession = true;
    getDetails();
  }

  @override
  void dispose() {
    consultationstagesession?.close();
    super.dispose();
  }

  setAppointId(String appointId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('appointmentIdFromConsultationStages', appointId);
    appointmentDetails(appointId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: CallConnectionState.callStatus,
            builder: ((_, value, __) {
              return !value
                  ? Container(
                      child: Center(child: Text('Connecting...please wait..')),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: Column(
                        children: <Widget>[
                          CustomPaint(
                            painter: BackgroundPainter(
                              primary: AppColors.primaryColor.withOpacity(0.7),
                              secondary: AppColors.primaryColor.withOpacity(0.0),
                            ),
                            child: Container(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 15),
                            child: Row(
                              children: [
                                SizedBox(width: 20.w),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Consultation Stages',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 20.0,
                          ),
                          //screen body
                          (noPrescription == false)
                              ? Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30),
                                        ),
                                      ),
                                      child:
                                          // ? Center(child: CircularProgressIndicator())
                                          Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 30.0),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(right: 7, top: 5),
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          elevation: 0.5,
                                                          backgroundColor: Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(10)),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(
                                                              top: 15,
                                                              bottom: 15,
                                                              right: 17,
                                                              left: 17),
                                                          child: Text(
                                                            'Rejoin',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.w600),
                                                          ),
                                                        ),
                                                        onPressed: (currentPage != "jitsiMeet" &&
                                                                isRejoin == false)
                                                            ? () {
                                                                print(currentPage +
                                                                    isRejoin.toString());
                                                                consultationstagesession?.close();
                                                                isTimer90seconds = false;
                                                                timerConsultationStagesSession
                                                                    .cancel();
                                                                istimerConsultationStagesSession =
                                                                    false;
                                                                Get.offNamedUntil(
                                                                    Routes.ConsultVideo,
                                                                    (route) => false,
                                                                    arguments: [
                                                                      widget.callDetails[0],
                                                                      widget.callDetails[1],
                                                                      widget.callDetails[2],
                                                                      widget.callDetails[3],
                                                                    ]);
                                                              }
                                                            : (isRejoin == false &&
                                                                    currentPage == "")
                                                                ? () {
                                                                    print(currentPage +
                                                                        isRejoin.toString());
                                                                    consultationstagesession
                                                                        ?.close();
                                                                    isTimer90seconds = false;
                                                                    timerConsultationStagesSession
                                                                        .cancel();
                                                                    istimerConsultationStagesSession =
                                                                        false;
                                                                    Get.offNamedUntil(
                                                                        Routes.ConsultVideo,
                                                                        (route) => false,
                                                                        arguments: [
                                                                          widget.callDetails[0],
                                                                          widget.callDetails[1],
                                                                          widget.callDetails[2],
                                                                          widget.callDetails[3],
                                                                        ]);
                                                                  }

                                                                // :  isRejoin == false &&  isCallTerminated == true?

                                                                : isRejoin == false
                                                                    ? () {
                                                                        print(currentPage +
                                                                            isRejoin.toString());
                                                                        if (isCallTerminated ==
                                                                            true) {
                                                                          print(currentPage +
                                                                              isRejoin.toString());
                                                                          consultationstagesession
                                                                              ?.close();
                                                                          isTimer90seconds = false;
                                                                          timerConsultationStagesSession
                                                                              .cancel();
                                                                          istimerConsultationStagesSession =
                                                                              false;
                                                                          Get.offNamedUntil(
                                                                              Routes.ConsultVideo,
                                                                              (route) => false,
                                                                              arguments: [
                                                                                widget
                                                                                    .callDetails[0],
                                                                                widget
                                                                                    .callDetails[1],
                                                                                widget
                                                                                    .callDetails[2],
                                                                                widget
                                                                                    .callDetails[3],
                                                                              ]);
                                                                        } else {
                                                                          Flushbar(
                                                                            title: "Info",
                                                                            message:
                                                                                "Already in call",
                                                                            duration: Duration(
                                                                                seconds: 3),
                                                                          )..show(context);
                                                                        }
                                                                      }
                                                                    : () {
                                                                        print(currentPage +
                                                                            isRejoin.toString());
                                                                        Flushbar(
                                                                          title: "Info",
                                                                          message: "Call completed",
                                                                          duration:
                                                                              Duration(seconds: 3),
                                                                        )..show(context);
                                                                      }),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              TimelineTile(
                                                alignment: TimelineAlign.center,
                                                isFirst: true,
                                                indicatorStyle: IndicatorStyle(
                                                  width: 30,
                                                  color: Colors.green,
                                                  padding: const EdgeInsets.all(8),
                                                  iconStyle: IconStyle(
                                                    color: Colors.white,
                                                    iconData: Icons.check,
                                                  ),
                                                ),
                                                beforeLineStyle: LineStyle(
                                                  color: (callCompleted == true)
                                                      ? Colors.green
                                                      : Colors.black12,
                                                  thickness: 3,
                                                ),
                                                startChild: Card(
                                                  margin: EdgeInsets.symmetric(vertical: 16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.0)),
                                                  clipBehavior: Clip.antiAlias,
                                                  color: Colors.green[100],
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Text(
                                                          'Consultation Initiated',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              color: Colors.black87,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        const SizedBox(
                                                          height: 8.0,
                                                        ),

                                                        ///commented on 310 Dec
                                                        TextButton(
                                                          child: !showMedicalFilesCard
                                                              ? Text('Share Medical\n    Report')
                                                              : Text(
                                                                  'Cancel Sharing',
                                                                  style:
                                                                      TextStyle(color: Colors.red),
                                                                ),
                                                          onPressed: () {
                                                            if (this.mounted) {
                                                              setState(
                                                                () {
                                                                  showMedicalFilesCard =
                                                                      !showMedicalFilesCard;
                                                                },
                                                              );
                                                            }
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                  visible: showMedicalFilesCard,
                                                  child: filesCard()),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Visibility(
                                                visible: showMedicalFilesCard,
                                                child: Center(
                                                  child: SizedBox(
                                                      width: Get.width - 40,
                                                      child: ValueListenableBuilder(
                                                          valueListenable: medicalFileShared,
                                                          builder: (_, value, __) => value
                                                              ? Center(
                                                                  child:
                                                                      CircularProgressIndicator())
                                                              : ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20.0),
                                                                    ),
                                                                    backgroundColor:
                                                                        AppColors.primaryColor,
                                                                    textStyle: TextStyle(
                                                                        color: Colors.white),
                                                                  ),
                                                                  child: Text('Send Report',
                                                                      style: TextStyle(
                                                                        fontSize: 16,
                                                                      )),
                                                                  onPressed: () {
                                                                    if (selectedDocIdList.length >
                                                                        0) {
                                                                      sendReports();
                                                                    } else {
                                                                      Get.snackbar(
                                                                          'No Report Selected',
                                                                          'Please Select at least 1 Report To Send',
                                                                          icon: Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .all(8.0),
                                                                            child: Icon(
                                                                                Icons.warning,
                                                                                color:
                                                                                    Colors.white),
                                                                          ),
                                                                          margin: EdgeInsets.all(20)
                                                                              .copyWith(bottom: 40),
                                                                          backgroundColor:
                                                                              Colors.red.shade400,
                                                                          colorText: Colors.white,
                                                                          duration:
                                                                              Duration(seconds: 2),
                                                                          snackPosition:
                                                                              SnackPosition.BOTTOM);
                                                                    }
                                                                  },
                                                                ))),
                                                ),
                                              ),
                                              // TimelineTile(
                                              //   alignment: TimelineAlign.center,
                                              //   indicatorStyle: (callCompleted ==
                                              //               true ||
                                              //           callCompleted ==
                                              //               false) //there will be no change for now based on condition
                                              //       ? IndicatorStyle(
                                              //           width: 30,
                                              //           color: Colors.green,
                                              //           padding:
                                              //               const EdgeInsets.all(8),
                                              //           iconStyle: IconStyle(
                                              //             color: Colors.white,
                                              //             iconData: Icons.check,
                                              //           ),
                                              //         )
                                              //       : IndicatorStyle(
                                              //           width: 30,
                                              //           color: Colors.grey[200],
                                              //           padding:
                                              //               const EdgeInsets.all(8),
                                              //         ),
                                              //   beforeLineStyle: LineStyle(
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green
                                              //         : Colors.black12,
                                              //     thickness: 3,
                                              //   ),
                                              //   afterLineStyle: LineStyle(
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green
                                              //         : Colors.black12,
                                              //     thickness: 3,
                                              //   ),
                                              //   endChild: Card(
                                              //     margin: EdgeInsets.symmetric(
                                              //         vertical: 16.0),
                                              //     shape: RoundedRectangleBorder(
                                              //         borderRadius:
                                              //             BorderRadius.circular(8.0)),
                                              //     clipBehavior: Clip.antiAlias,
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green[100]
                                              //         : Colors.green[
                                              //             100], // there will be no change for now
                                              //     child: Padding(
                                              //       padding: const EdgeInsets.all(16.0),
                                              //       child: Column(
                                              //         mainAxisSize: MainAxisSize.min,
                                              //         children: <Widget>[
                                              //           Text(
                                              //             'Call Started',
                                              //             textAlign: TextAlign.center,
                                              //             style: TextStyle(
                                              //                 color: (callCompleted ==
                                              //                         true)
                                              //                     ? Colors.black87
                                              //                     : Colors
                                              //                         .black87, //there will be no change for now based on condition
                                              //                 fontSize: 16,
                                              //                 fontWeight:
                                              //                     FontWeight.bold),
                                              //           ),
                                              //           const SizedBox(
                                              //             height: 8.0,
                                              //           ),
                                              //         ],
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              // TimelineTile(
                                              //   alignment: TimelineAlign.center,
                                              //   indicatorStyle: (callCompleted ==
                                              //               true ||
                                              //           callCompleted ==
                                              //               false) //there will be no change for now based on condition
                                              //       ? IndicatorStyle(
                                              //           width: 30,
                                              //           color: Colors.green,
                                              //           padding:
                                              //               const EdgeInsets.all(8),
                                              //           iconStyle: IconStyle(
                                              //             color: Colors.white,
                                              //             iconData: Icons.check,
                                              //           ),
                                              //         )
                                              //       : IndicatorStyle(
                                              //           width: 30,
                                              //           color: Colors.grey[200],
                                              //           padding:
                                              //               const EdgeInsets.all(8),
                                              //         ),
                                              //   beforeLineStyle: LineStyle(
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green
                                              //         : Colors.black12,
                                              //     thickness: 3,
                                              //   ),
                                              //   afterLineStyle: LineStyle(
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green
                                              //         : Colors.black12,
                                              //     thickness: 3,
                                              //   ),
                                              //   startChild: Card(
                                              //     margin: EdgeInsets.symmetric(
                                              //         vertical: 16.0),
                                              //     shape: RoundedRectangleBorder(
                                              //         borderRadius:
                                              //             BorderRadius.circular(8.0)),
                                              //     clipBehavior: Clip.antiAlias,
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green[100]
                                              //         : Colors.green[
                                              //             100], //there will be no change for now based on condition
                                              //     child: Padding(
                                              //       padding: const EdgeInsets.all(16.0),
                                              //       child: Column(
                                              //         mainAxisSize: MainAxisSize.min,
                                              //         children: <Widget>[
                                              //           Text(
                                              //             'Call Completed',
                                              //             textAlign: TextAlign.center,
                                              //             style: TextStyle(
                                              //                 color: (callCompleted ==
                                              //                         true)
                                              //                     ? Colors.black87
                                              //                     : Colors
                                              //                         .black87, //there will be no change for now based on condition
                                              //                 fontSize: 16,
                                              //                 fontWeight:
                                              //                     FontWeight.bold),
                                              //           ),
                                              //           const SizedBox(
                                              //             height: 8.0,
                                              //           ),
                                              //         ],
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              TimelineTile(
                                                alignment: TimelineAlign.center,
                                                indicatorStyle: (callCompleted == true)
                                                    ? IndicatorStyle(
                                                        width: 30,
                                                        color: Colors.green,
                                                        padding: const EdgeInsets.all(8),
                                                        iconStyle: IconStyle(
                                                          color: Colors.white,
                                                          iconData: Icons.check,
                                                        ),
                                                      )
                                                    : IndicatorStyle(
                                                        width: 30,
                                                        color: Colors.grey[200],
                                                        padding: const EdgeInsets.all(8),
                                                      ),
                                                beforeLineStyle: LineStyle(
                                                  color: (callCompleted == true)
                                                      ? Colors.green
                                                      : Colors.black12,
                                                  thickness: 3,
                                                ),
                                                endChild: Card(
                                                  margin: EdgeInsets.symmetric(vertical: 16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.0)),
                                                  clipBehavior: Clip.antiAlias,
                                                  color: (callCompleted == true &&
                                                          prescriptionCompleted == false)
                                                      ? Colors.amber[100]
                                                      : (callCompleted == true &&
                                                              prescriptionCompleted == true)
                                                          ? Colors.green[100]
                                                          : Colors.grey[200],
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Text(
                                                          'Preparing Instructions',
                                                          style: TextStyle(
                                                              color: (callCompleted == true)
                                                                  ? Colors.black87
                                                                  : Colors.black26,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                          height: 8.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TimelineTile(
                                                alignment: TimelineAlign.center,
                                                isLast: true,
                                                indicatorStyle: (callCompleted == true &&
                                                        prescriptionCompleted == true)
                                                    ? IndicatorStyle(
                                                        width: 30,
                                                        color: Colors.green,
                                                        padding: const EdgeInsets.all(8),
                                                        iconStyle: IconStyle(
                                                          color: Colors.white,
                                                          iconData: Icons.check,
                                                        ),
                                                      )
                                                    : IndicatorStyle(
                                                        width: 30,
                                                        color: Colors.grey[200],
                                                        padding: const EdgeInsets.all(8),
                                                      ),
                                                beforeLineStyle: LineStyle(
                                                  color: (callCompleted == true &&
                                                          prescriptionCompleted == true)
                                                      ? Colors.green
                                                      : Colors.black12,
                                                  thickness: 3,
                                                ),
                                                startChild: Card(
                                                  margin: EdgeInsets.symmetric(vertical: 16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.0)),
                                                  clipBehavior: Clip.antiAlias,
                                                  color: (callCompleted == true &&
                                                          prescriptionCompleted == true)
                                                      ? Colors.green[100]
                                                      : Colors.grey[200],
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Text(
                                                          'Consultation Completed',
                                                          style: TextStyle(
                                                              color: (callCompleted == true &&
                                                                      prescriptionCompleted == true)
                                                                  ? Colors.black87
                                                                  : Colors.black26,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                          height: 8.0,
                                                        ),
                                                        const SizedBox(
                                                          height: 8.0,
                                                        ),
                                                        getUserDetailsUpdate
                                                            ? InkWell(
                                                                child: Text(
                                                                  (callCompleted == true &&
                                                                          prescriptionCompleted ==
                                                                              true)
                                                                      ? 'Tap here to continue'
                                                                      : '',
                                                                  style: TextStyle(
                                                                    color: Colors.blueAccent,
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                onTap: () {
                                                                  consultationstagesession?.close();
                                                                  isTimer90seconds = false;
                                                                  timerConsultationStagesSession
                                                                      .cancel();
                                                                  istimerConsultationStagesSession =
                                                                      false;
                                                                  appointmentAndCallStatusUpdate();
                                                                  Navigator.of(context).pushNamed(
                                                                    Routes.ConsultSummary,
                                                                    arguments: consultationNotes,
                                                                  );
                                                                },
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 50),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              TimelineTile(
                                                alignment: TimelineAlign.center,
                                                isFirst: true,
                                                indicatorStyle: IndicatorStyle(
                                                  width: 30,
                                                  color: Colors.green,
                                                  padding: const EdgeInsets.all(8),
                                                  iconStyle: IconStyle(
                                                    color: Colors.white,
                                                    iconData: Icons.check,
                                                  ),
                                                ),
                                                beforeLineStyle: LineStyle(
                                                  color: (callCompleted == true)
                                                      ? Colors.green
                                                      : Colors.black12,
                                                  thickness: 3,
                                                ),
                                                startChild: Card(
                                                  margin: EdgeInsets.symmetric(vertical: 16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.0)),
                                                  clipBehavior: Clip.antiAlias,
                                                  color: Colors.green[100],
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Text(
                                                          'Consultation Initiated',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              color: Colors.black87,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        const SizedBox(
                                                          height: 8.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // TimelineTile(
                                              //   alignment: TimelineAlign.center,
                                              //   indicatorStyle: (callCompleted == true)
                                              //       ? IndicatorStyle(
                                              //           width: 30,
                                              //           color: Colors.green,
                                              //           padding:
                                              //               const EdgeInsets.all(8),
                                              //           iconStyle: IconStyle(
                                              //             color: Colors.white,
                                              //             iconData: Icons.check,
                                              //           ),
                                              //         )
                                              //       : IndicatorStyle(
                                              //           width: 30,
                                              //           color: Colors.grey[200],
                                              //           padding:
                                              //               const EdgeInsets.all(8),
                                              //         ),
                                              //   beforeLineStyle: LineStyle(
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green
                                              //         : Colors.black12,
                                              //     thickness: 3,
                                              //   ),
                                              //   afterLineStyle: LineStyle(
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green
                                              //         : Colors.black12,
                                              //     thickness: 3,
                                              //   ),
                                              //   endChild: Card(
                                              //     margin: EdgeInsets.symmetric(
                                              //         vertical: 16.0),
                                              //     shape: RoundedRectangleBorder(
                                              //         borderRadius:
                                              //             BorderRadius.circular(8.0)),
                                              //     clipBehavior: Clip.antiAlias,
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green[100]
                                              //         : Colors.grey[200],
                                              //     child: Padding(
                                              //       padding: const EdgeInsets.all(16.0),
                                              //       child: Column(
                                              //         mainAxisSize: MainAxisSize.min,
                                              //         children: <Widget>[
                                              //           Text(
                                              //             'Call Started',
                                              //             textAlign: TextAlign.center,
                                              //             style: TextStyle(
                                              //                 color: (callCompleted ==
                                              //                         true)
                                              //                     ? Colors.black87
                                              //                     : Colors.black26,
                                              //                 fontSize: 16,
                                              //                 fontWeight:
                                              //                     FontWeight.bold),
                                              //           ),
                                              //           const SizedBox(
                                              //             height: 8.0,
                                              //           ),
                                              //         ],
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              // TimelineTile(
                                              //   alignment: TimelineAlign.center,
                                              //   indicatorStyle: (callCompleted == true)
                                              //       ? IndicatorStyle(
                                              //           width: 30,
                                              //           color: Colors.green,
                                              //           padding:
                                              //               const EdgeInsets.all(8),
                                              //           iconStyle: IconStyle(
                                              //             color: Colors.white,
                                              //             iconData: Icons.check,
                                              //           ),
                                              //         )
                                              //       : IndicatorStyle(
                                              //           width: 30,
                                              //           color: Colors.grey[200],
                                              //           padding:
                                              //               const EdgeInsets.all(8),
                                              //         ),
                                              //   beforeLineStyle: LineStyle(
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green
                                              //         : Colors.black12,
                                              //     thickness: 3,
                                              //   ),
                                              //   afterLineStyle: LineStyle(
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green
                                              //         : Colors.black12,
                                              //     thickness: 3,
                                              //   ),
                                              //   startChild: Card(
                                              //     margin: EdgeInsets.symmetric(
                                              //         vertical: 16.0),
                                              //     shape: RoundedRectangleBorder(
                                              //         borderRadius:
                                              //             BorderRadius.circular(8.0)),
                                              //     clipBehavior: Clip.antiAlias,
                                              //     color: (callCompleted == true)
                                              //         ? Colors.green[100]
                                              //         : Colors.grey[200],
                                              //     child: Padding(
                                              //       padding: const EdgeInsets.all(16.0),
                                              //       child: Column(
                                              //         mainAxisSize: MainAxisSize.min,
                                              //         children: <Widget>[
                                              //           Text(
                                              //             'Call Completed',
                                              //             textAlign: TextAlign.center,
                                              //             style: TextStyle(
                                              //                 color: (callCompleted ==
                                              //                         true)
                                              //                     ? Colors.black87
                                              //                     : Colors.black26,
                                              //                 fontSize: 16,
                                              //                 fontWeight:
                                              //                     FontWeight.bold),
                                              //           ),
                                              //           const SizedBox(
                                              //             height: 8.0,
                                              //           ),
                                              //         ],
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              TimelineTile(
                                                alignment: TimelineAlign.center,
                                                isLast: true,
                                                indicatorStyle: (callCompleted == true)
                                                    ? IndicatorStyle(
                                                        width: 30,
                                                        color: Colors.green,
                                                        padding: const EdgeInsets.all(8),
                                                        iconStyle: IconStyle(
                                                          color: Colors.white,
                                                          iconData: Icons.check,
                                                        ),
                                                      )
                                                    : IndicatorStyle(
                                                        width: 30,
                                                        color: Colors.grey[200],
                                                        padding: const EdgeInsets.all(8),
                                                      ),
                                                beforeLineStyle: LineStyle(
                                                  color: (callCompleted == true)
                                                      ? Colors.green
                                                      : Colors.black12,
                                                  thickness: 3,
                                                ),
                                                endChild: Card(
                                                  margin: EdgeInsets.symmetric(vertical: 16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.0)),
                                                  clipBehavior: Clip.antiAlias,
                                                  color: (callCompleted == true)
                                                      ? Colors.green[100]
                                                      : Colors.grey[200],
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Text(
                                                          'Consultation Completed',
                                                          style: TextStyle(
                                                              color: (callCompleted == true)
                                                                  ? Colors.black87
                                                                  : Colors.black26,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                          height: 8.0,
                                                        ),
                                                        const SizedBox(
                                                          height: 8.0,
                                                        ),
                                                        getUserDetailsUpdate
                                                            ? InkWell(
                                                                child: Text(
                                                                  (callCompleted == true)
                                                                      ? 'Tap here to continue'
                                                                      : '',
                                                                  style: TextStyle(
                                                                    color: Colors.blueAccent,
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                onTap: () {
                                                                  consultationstagesession?.close();
                                                                  isTimer90seconds = false;
                                                                  timerConsultationStagesSession
                                                                      .cancel();
                                                                  istimerConsultationStagesSession =
                                                                      false;
                                                                  appointmentAndCallStatusUpdate();
                                                                  Navigator.of(context).pushNamed(
                                                                    Routes.ConsultSummary,
                                                                    arguments: consultationNotes,
                                                                  );
                                                                  // Navigator.push(context,
                                                                  //     MaterialPageRoute (builder: (context) => ConsultSummaryPage(
                                                                  //       consultantName: consultantNameFromAPI,
                                                                  //       speciality: specialityFromAPI,
                                                                  //       appointmentStartTime: appointmentStartTimeFromAPI,
                                                                  //       appointmentEndTime: appointmentEndTimeFromAPI,
                                                                  //       appointmentStatus: appointmentStatusFromAPI,
                                                                  //       callStatus: callStatusFromAPI,
                                                                  //       consultationFees: consultationFeesFromAPI,
                                                                  //       modeOfPayment: modeOfPaymentFromAPI,
                                                                  //       appointmentModel: appointmentModelFromAPI,
                                                                  //       reasonOfVisit: reasonOfVisitFromAPI,
                                                                  //       consultationNotes: '',
                                                                  //     )));
                                                                },
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ValueListenableBuilder(
                            //TODO 2nd: listen playerPointsToAdd
                            valueListenable: counterValueConsultaionStages,
                            builder: (context, value, widget) {
                              //TODO here you can setState or whatever you need
                              return (counterValueConsultaionStages.value != 90)
                                  ? prescriptionCompleted != true
                                      ? Text(
                                          "will redirect automatically in ${counterValueConsultaionStages.value.toString()} sec",
                                          style: TextStyle(color: Colors.grey, fontSize: 18),
                                        )
                                      : SizedBox()
                                  : SizedBox();
                            },
                          ),

                          ///med filessss builder
                        ],
                      ),
                    );
            }),
          ),
        ));
  }

  appointmentAndCallStatusUpdate() {
    print('uuuuuuupppppppdating the callllll & apppoiinntment status');
    callStatusUpdate(
        widget.appointmentId.toString().replaceAll('ihl_consultant_', ''), 'completed');
    print('uuuuuuupppppppdating the callllll & apppoiinntment status');
  }

  Widget buyMedicineDialog() {
    return SingleChildScrollView(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          height: 10.0,
        ),
        Text(
          "Purchase Medicine",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 22.0,
          ),
        ),
        SizedBox(
          height: 25.0,
        ),
        Center(
          child: Text(
            "Get your medicine delivered at your door step",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Center(
          child: Container(
            width: 80,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.rectangle),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/1mg-logo-large.png',
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Center(
          child: Text(
            "You will get a call from 1Mg.com to process your prescription",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: AppColors.primaryColor,
            ),
            child: Text('Yes Share My Prescription to 1 MG',
                style: TextStyle(
                  fontSize: 16,
                )),
            onPressed: () {}),
        SizedBox(
          height: 15.0,
        ),
      ]),
    );
  }

  ///med files function
  Widget filesCard() {
    // print('=============================$IHL_User_ID');
    // iHLUserId = IHL_User_ID;
    print('=============================$iHLUserId');
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Color(0xfff4f6fa),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Select your files to share",
              style: TextStyle(
                color: AppColors.primaryAccentColor,
                fontSize: 22.0,
              ),
            ),
          ),
          Container(
            height: medFiles.length > 3
                ? 470
                : medFiles.length == 3
                    ? 290
                    : medFiles.length == 2
                        ? 190
                        : medFiles.length == 1
                            ? 100
                            : 10,
            child: ListView.builder(
              itemCount: medFiles.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: medFiles[index]['document_link'].substring(
                                      medFiles[index]['document_link'].lastIndexOf(".") + 1) ==
                                  'jpg' ||
                              medFiles[index]['document_link'].substring(
                                      medFiles[index]['document_link'].lastIndexOf(".") + 1) ==
                                  'png'
                          ? Icon(Icons.image)
                          : Icon(Icons.insert_drive_file),
                      // Icon(Icons.insert_drive_file),
                      title: Text("${medFiles[index]['document_name']}"),
                      subtitle: Text(
                          "${camelize(medFiles[index]['document_type'].replaceAll('_', ' '))}"),
                      // subtitle: Text("1.9 MB"),
                      trailing: checkboxTile(medFiles[index]['document_id']),
                      onTap: () async {
                        print(medFiles[index]['document_link']);
                        // if(filesData[index]['document_link'].contains('pdf')){
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfView(
                              medFiles[index]['document_link'],
                              medFiles[index],
                              iHLUserId,
                              showExtraButton: false,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Divider(
                      thickness: 2.0,
                      height: 10.0,
                      indent: 5.0,
                    ),
                  ],
                );
              },
            ),
          ),
          Center(
              child: SizedBox(
                  width: 180.0,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.upload_file),
                    label: Text('New File',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      backgroundColor: AppColors.primaryColor,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      showFileTypePicker(context);
                    },
                  ))),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  ///ch
  Widget checkboxTile(String docId) {
    print(selectedDocIdList.toString());
    return Checkbox(
      value: selectedDocIdList.contains(docId.toString())
          ? true
          : false, //if this is in the list than add it or remove it
      onChanged: (value) {
        ///first check in the list and than
        ///if that item is available in the list already than => remove it from the list ,
        ///if item is not there in the list than add it
        if (selectedDocIdList.contains(docId.toString())) {
          if (this.mounted) {
            setState(() {
              selectedDocIdList.remove(docId.toString());
            });
          }
        } else {
          if (this.mounted) {
            setState(() {
              selectedDocIdList.add(docId.toString());
            });
          }
        }
        print('$selectedDocIdList');
      },
    );
  }

  sendReports() async {
    print(ihl_consultant_id);
    medicalFileShared.value = true;
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/share_medical_doc_after_appointment"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode({
        'ihl_user_id': "$iHLUserId",
        "document_id": selectedDocIdList,
        "appointment_id": widget.appointmentId.toString().replaceAll('ihl_consultant_', ''),
        //"0b59bf916752496f98c53f94b0e50212",//appointmentId
        "ihl_consultant_id": ihl_consultant_id,
        //'38726ba5bfcd42f08189e5e84a4105ca',//vendorConsultatationIDFromAPI,//widget.ihlConsultantId//"38726ba5bfcd42f08189e5e84a4105ca"//consultant_id
      }),
    );
    print('${response.statusCode}');
    if (response.statusCode == 200) {
      var output = json.decode(response.body);
      //getFiles();//for  updating the listview again
      print(response.body);
      if (output['status'] == 'document uploaded successfully') {
        //snackbar
        // Get.snackbar('Deleted!', '${camelize(filename)} deleted successfully.',
        sharedReportAppIdList.add(widget.appointmentId);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setStringList('sharedReportAppIdList', sharedReportAppIdList);

        // subscribeAppointmentApproved();
        ///may be this instead of this
        // shareMedFileCrossbar();
        consultationstageCrossbar(fileCrossbar: true);
// setState(() {
//   selectedDocIdList.clear();
// });
        medicalFileShared.value = false;
        Get.snackbar('Report ', 'Sent Successfully',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);

        // Timer(Duration(seconds: 2),
        //         ()=>Get.off(ViewallTeleDashboard()));

        ///15 oct

        // Timer(duration:Duration(seconds: 1), (){
        //   Get.off(ViewallTeleDashboard());
        // });
        // getFiles();
      } else {
        medicalFileShared.value = false;
        Get.snackbar('Report Not Sent', 'Encountered some error while sending. Please try again',
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.cancel_rounded, color: Colors.white),
            ),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      print(response.body);
    }
  }

  /// upload medical files/reports
  var _chosenType = 'others';
  FilePickerResult result;
  bool fileSelected = false;
  PlatformFile file;
  TextEditingController fileNameController = TextEditingController();
  String fileNametext;

  showFileTypePicker(BuildContext context) {
    bool submitted = false;
    // ignore: missing_return
    String fileNameValidator(String ip) {
      if (ip == null) {
        return null;
      }
      if (ip.length < 1) {
        return 'File Name is required';
      }
      if (ip.length < 4) {
        return 'File Name should be at least 4 character long';
      }
      if (filesNameList.contains(ip)) {
        return 'File Name should be Unique';
      }
    }

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter mystate) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    fileSelected == false
                        ? Padding(
                            padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                            child: AutoSizeText(
                              // 'Select File Type',
                              'Upload File',
                              style: TextStyle(
                                  color: AppColors.appTextColor, //AppColors.primaryColor
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                            child: AutoSizeText(
                              '${fileNametext + "." + "${isImageSelectedFromCamera ? 'jpg' : file.extension.toLowerCase()}"}',
                              style: TextStyle(
                                  color: AppColors.appTextColor, //AppColors.primaryColor
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                    Visibility(
                      visible: fileSelected == false,
                      child: Divider(
                        indent: 10,
                        endIndent: 10,
                        thickness: 2,
                      ),
                    ),
                    Visibility(
                      visible: fileSelected == false,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
                        child: TextFormField(
                          controller: fileNameController,
                          // validator: (v){
                          //   fileNameValidator(fileNametext);
                          // },
                          onChanged: (value) {
                            if (this.mounted) {
                              setState(() {
                                fileNametext = value;
                              });
                            }
                          },
                          // maxLength: 150,
                          autocorrect: true,
                          // scrollController: Scrollable,
                          autofocus: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                            labelText: "Enter file name",
                            errorText: fileNameValidator(fileNametext),
                            fillColor: Colors.white24,
                            border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                                borderSide: new BorderSide(color: Colors.blueGrey)),
                          ),
                          maxLines: 1,
                          style: TextStyle(fontSize: 16.0),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ),
                    fileSelected == false
                        ? Padding(
                            padding: const EdgeInsets.all(10.0).copyWith(left: 24, right: 24),
                            child: Container(
                              child: DropdownButton<String>(
                                focusColor: Colors.white,
                                value: _chosenType,
                                isExpanded: true,
                                underline: Container(
                                  height: 2.0,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        // color: widget.mealtype!=null?HexColor(widget.mealtype.startColor):AppColors.primaryColor,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                                style: TextStyle(color: Colors.white),
                                iconEnabledColor: Colors.black,
                                items: <String>[
                                  'lab_report',
                                  'x_ray',
                                  'ct_scan',
                                  'mri_scan',
                                  'others'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      camelize(value.replaceAll('_', ' ')),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                hint: Text(
                                  "Select File Type",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                onChanged: (String value) {
                                  mystate(() {
                                    _chosenType = value;
                                  });
                                  // //open file picker
                                  // if (fileNameValidator(fileNametext) == null) {
                                  //   Navigator.of(context).pop();
                                  //   sheetForSelectingReport(context);
                                  // } else {
                                  //   fileNameValidator(fileNametext);
                                  // }
                                },
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              MaterialButton(
                                child: Text(
                                  'Change',
                                  style: TextStyle(
                                      color: AppColors.primaryColor, //AppColors.primaryColor
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  //open file explorer again
                                  sheetForSelectingReport(context);
                                },
                              ),
                              MaterialButton(
                                child: Text(
                                  'Confirm',
                                  style: TextStyle(
                                      color: AppColors.primaryColor, //AppColors.primaryColor
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  //pop
                                  Navigator.pop(context);
                                  // Navigator.pop(context);
                                  if (this.mounted) {
                                    setState(() {
                                      fileSelected = false;
                                    });
                                  }

                                  ///send this payload diffrently if file selected from camera
                                  if (isImageSelectedFromCamera) {
                                    var n = croppedFile.path
                                        .substring(croppedFile.path.lastIndexOf('/') + 1);
                                    uploadDocuments(n, 'jpg', croppedFile.path);
                                  } else {
                                    uploadDocuments(result.files.first.name,
                                        result.files.first.extension, result.files.first.path);
                                  }

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (ctx) => AlertDialog(
                                      title: Text("Uploading..."),
                                      content: Text("Please Wait. The File is Uploading..."),
                                      actions: <Widget>[
                                        CircularProgressIndicator(),
                                        // FlatButton(
                                        //   onPressed: () {
                                        //     Navigator.of(ctx).pop();
                                        //   },
                                        //   child: Text("okay"),
                                        // ),
                                      ],
                                    ),
                                  );

                                  fileNameController.clear();
                                },
                              ),
                            ],
                          ),
                    Visibility(
                      visible: fileSelected == false,
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            backgroundColor: AppColors.primaryAccentColor,
                            textStyle: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            //open file picker
                            if (fileNameValidator(fileNametext) == null &&
                                fileNametext.length != 0) {
                              Navigator.of(context).pop();
                              sheetForSelectingReport(context);
                              // _openFileExplorer('upload');

                              // showDialog(
                              //   context: context,
                              //   builder: (ctx) => AlertDialog(
                              //     title: Text("Alert Dialog Box"),
                              //     content: Text("You have raised a Alert Dialog Box"),
                              //     actions: <Widget>[
                              //       FlatButton(
                              //         onPressed: () {
                              //           Navigator.of(ctx).pop();
                              //         },
                              //         child: Text("okay"),
                              //       ),
                              //     ],
                              //   ),
                              // );
                            } else {
                              fileNameValidator(fileNametext);
                              FocusManager.instance.primaryFocus.unfocus();
                            }
                          },
                          child: Text(
                            ' Upload ',
                            style:
                                TextStyle(color: Colors.white, letterSpacing: 1.2, fontSize: 16.sp),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  sheetForSelectingReport(BuildContext context) {
    // ignore: missing_return
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter mystate) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // fileSelected == false
                  //     ? Padding(
                  //   padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                  //   child: AutoSizeText(
                  //     // 'Select File Type',
                  //     'Upload File',
                  //     style: TextStyle(
                  //         color: AppColors.appTextColor, //AppColors.primaryColor
                  //         fontSize: 22,
                  //         fontWeight: FontWeight.bold),
                  //     textAlign: TextAlign.left,
                  //   ),
                  // )
                  //     : Padding(
                  //   padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                  //   child: AutoSizeText(
                  //     '${fileNametext+'.'+file.extension.toLowerCase()}',
                  //     style: TextStyle(
                  //         color: AppColors.appTextColor, //AppColors.primaryColor
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.bold),
                  //     textAlign: TextAlign.left,
                  //   ),
                  // ),
                  //
                  // Visibility(
                  //   visible: fileSelected == false,
                  //   child: Divider(
                  //     indent: 10,
                  //     endIndent: 10,
                  //     thickness: 2,
                  //   ),
                  // ),
                  ListTile(
                    title: Text('Select Report From Storage'),
                    leading: Icon(Icons.image),
                    onTap: () {
                      _openFileExplorer('upload');
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Capture Report From Camera',
                      style: TextStyle(color: Colors.grey),
                    ),
                    leading: Icon(
                      Icons.camera_alt_outlined,
                    ),
                    // onTap: () async {
                    //   await _imgFromCamera();
                    //   Navigator.of(context).pop();
                    //   showFileTypePicker(context);
                    //   if (this.mounted) {
                    //     setState(
                    //       () {
                    //         fileSelected = true;
                    //       },
                    //     );
                    //   }
                    // },
                  ),
                  SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ///capture report from camera
  bool isImageSelectedFromCamera = false;

  File croppedFile;
  File _image;
  final picker = ImagePicker();

  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    _image = new File(pickedFile.path);
    await ImageCropper().cropImage(
        sourcePath: _image.path,
        aspectRatio: CropAspectRatio(ratioX: 12, ratioY: 16),
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 60,
        uiSettings: [
          AndroidUiSettings(
            lockAspectRatio: false,
            activeControlsWidgetColor: AppColors.primaryAccentColor,
            toolbarTitle: 'Crop the Image',
            toolbarColor: Color(0xFF19a9e5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(title: 'Crop the Image', aspectRatioLockEnabled: true)
        ]).then((value) => croppedFile = File(value.path));

    if (this.mounted) {
      setState(() {
        List<int> imageBytes = croppedFile.readAsBytesSync();
        var im = croppedFile.path;
        isImageSelectedFromCamera = true;

        ///instead of image selected write here the older variable file selected = true, okay and than remove this file
        fileSelected = true;
      });
    }
  }

  ///file explorer
  Future<void> _openFileExplorer(type) async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf'],
    );
    // FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      file = result.files.first;
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      if (this.mounted) {
        setState(() {
          fileSelected = true;
          isImageSelectedFromCamera = false;
        });
      }
      // if(type=='upload'){
      Navigator.pop(context);
      showFileTypePicker(context);
      // }

      // else{
      //   editDocuments(edit_doc_id,edit_doc_type);
      //
      // }
    } else {
      // User canceled the picker
    }
  }

  ///upload api
  Future uploadDocuments(String filename, String extension, String path) async {
    print('uploadDocuments apicalll');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          // 'https://testserver.indiahealthlink.com/consult/upload_medical_document'),
          API.iHLUrl + '/consult/upload_medical_document'),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'data',
        path,
        filename: filename,
      ),
    );
    request.fields.addAll(await {
      "ihl_user_id": "$iHLUserId",
      "document_name": "${fileNametext + '.' + extension.toLowerCase()}",
      "document_format_type": extension.toLowerCase() == 'pdf'
          ? "${extension.toLowerCase()}"
          : 'image', //"${extension.toLowerCase()}",
      "document_type": "$_chosenType",
    });
    var res = await request.send();
    print('success api ++');
    var uploadResponse = await res.stream.bytesToString();
    print(uploadResponse);
    final finalOutput = json.decode(uploadResponse);
    print(finalOutput['status']);
    if (finalOutput['status'] == 'document uploaded successfully') {
      Navigator.of(context).pop();
      //snackbar
      Get.snackbar('Uploaded!',
          '${camelize(fileNametext + '.' + extension.toLowerCase())} uploaded successfully.',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.check_circle, color: Colors.white)),
          margin: EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: AppColors.primaryAccentColor,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM);
      medFiles = await MedicalFilesApi.getFiles();
      for (int i = 0; i < medFiles.length; i++) {
        var name;
        if (medFiles[i]['document_name'].toString().contains('.')) {
          var parse1 = medFiles[i]['document_name'].toString().replaceAll('.jpg', '');
          var parse2 = parse1.replaceAll('.jpeg', '');
          var parse3 = parse2.replaceAll('.png', '');
          var parse4 = parse3.replaceAll('.pdf', '');
          name = parse4;
        }
        filesNameList.add(name);
      }

      ///added\\improvised for the confirm visit
      if (this.mounted) {
        setState(() {
          medFiles;
        });
      }
      // getFiles();
    } else {
      Get.snackbar('File not uploaded', 'Encountered some error while uploading. Please try again',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.cancel_rounded, color: Colors.white)),
          margin: EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

//Counter UI for indicating 90 seconds
Timer _timerUI90ConsultaionStages;
// int counterValueConsultaionStages = 90;
final counterValueConsultaionStages = ValueNotifier<int>(180);

void counterUIConsultaionStages() {
  if (_timerUI90ConsultaionStages != null) {
    _timerUI90ConsultaionStages.cancel();
    _timerUI90ConsultaionStages = null;
  } else {
    _timerUI90ConsultaionStages = new Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (counterValueConsultaionStages.value < 1) {
        timer.cancel();
      } else {
        counterValueConsultaionStages.value = counterValueConsultaionStages.value - 1;
      }
    });
  }
}

class CallConnectionState {
  static ValueNotifier<bool> callStatus = ValueNotifier<bool>(false);
}
