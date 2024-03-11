import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/CrossbarUtil.dart' as s;
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/dateFormat.dart';
import 'package:ihl/views/teleconsultation/genix_livecall_signal.dart';
import 'package:ihl/views/teleconsultation/myAppointments.dart';
import 'package:ihl/views/teleconsultation/view_bill.dart';
import 'package:ihl/widgets/teleconsulation/payment/paymentUI.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/invoice.dart';
import '../../../new_design/presentation/Widgets/appBar.dart';
import '../../../new_design/presentation/pages/onlineServices/MyAppointment.dart';
import '../../../repositories/api_consult.dart';
import '../../../widgets/teleconsulation/appointmentTile.dart';
import '../../view_past_bill/view_only_bill.dart';
import '../view_all_appoinments_free.dart';
// import '../genixLiveWebView.dart';

class SuccessPage extends StatefulWidget {
  final Map details;

  SuccessPage({
    this.details,
  });

  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  http.Client _client = http.Client(); //3gb
  bool loading = true;
  bool success = false;
  var date = '';
  String appointId;
  String genixAppointId;
  String vendorAppointId;
  String genixURL;
  String docId;
  String iHLUserId;
  String ihlUserName;
  var mobileNumber;
  String status;
  String fometedStartDate;
  String fometEdendDate;
  bool showMissed = false;
  Map vitals;
  var appStrtDate;
  var appendDate;
  var bookedDate;
  List<String> sharedDocument;
  String userFirstName, userLastName;
  int fees;
  String userEmail;
  Map res;

  void bookConsultation() async {
    // var appStartDate = widget.details['start_date'];
    // var appEndDate = widget.details['end_date'];
    // String approvalStatus = widget.details['doctor']['vendor_id'] == "GENIX" ||
    //         widget.details['livecall'] == true
    //     ? "Approved"
    //     : "requested";
    // fometedStartDate = changeDateFormat(appStrtDate.toString());
    // fometEdendDate = changeDateFormat(appendDate.toString());
    // date = appStrtDate + ' - ' + appendDate;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(SpUtil.getString(SPKeys.affiliateUniqueName));
    String affiliationUniqueName = prefs.getString(SPKeys.affiliateUniqueName);
    print(affiliationUniqueName);
    if (affiliationUniqueName == null ||
        affiliationUniqueName.toString() == 'null' ||
        affiliationUniqueName == '' ||
        Tabss.isAffi) {
      affiliationUniqueName = 'global_services';
    }
    bool sendLastCheckin = prefs.get('sendLastCheckin');
    var data = prefs.get('data');
    prefs.setString('consultantName', widget.details['doctor']['name'].toString());
    prefs.setString('consultantId', widget.details['doctor']['ihl_consultant_id'].toString());
    prefs.setString('vendorName', widget.details['doctor']['vendor_id'].toString());
    var vendorConsultantId = widget.details['doctor']['vendor_consultant_id'];
    prefs.setString('vendorConId', vendorConsultantId);
    res = jsonDecode(data);
    vitals = res["LastCheckin"];
    if (vitals != null) {
      vitals.removeWhere((key, value) =>
          // key != "dateTimeFormatted" &&
          key != "dateTime" &&
          //pulsebpm
          key != "diastolic" &&
          key != "systolic" &&
          key != "pulseBpm" &&
          key != "bpClass" &&
          //BMC
          key != "fatRatio" &&
          key != "fatClass" &&
          key != "percent_body_fat" &&
          key != "percent_body_sdf_fat" &&

          //ECG
          key != "leadTwoStatus" &&
          key != "ecgBpm" &&
          //BMI
          key != "weightKG" &&
          key != "heightMeters" &&
          key != "bmi" &&
          key != "bmiClass" &&
          //spo2
          key != "spo2" &&
          key != "spo2Class" &&
          //temprature
          key != "temperature" &&
          key != "temperatureClass" &&
          //BMC parameters
          key != "bone_mineral_content" &&
          key != "protien" &&
          key != "extra_cellular_water" &&
          key != "intra_cellular_water" &&
          key != "mineral" &&
          key != "skeletal_muscle_mass" &&
          key != "body_fat_mass" &&
          key != "body_cell_mass" &&
          key != "waist_hip_ratio" &&
          key != "percent_body_fat" &&
          key != "waist_height_ratio" &&
          key != "visceral_fat" &&
          key != "basal_metabolic_rate" &&
          key != "bone_mineral_content_status" &&
          key != "protien_status" &&
          key != "extra_cellular_water_status" &&
          key != "intra_cellular_water_status" &&
          key != "mineral_status" &&
          key != "skeletal_muscle_mass_status" &&
          key != "body_fat_mass_status" &&
          key != "body_cell_mass_status" &&
          key != "waist_hip_ratio_status" &&
          key != "percent_body_fat_status" &&
          key != "waist_height_ratio_status" &&
          key != "visceral_fat_status" &&
          key != "basal_metabolic_rate_status");
      vitals.forEach((key, value) {
        if (key == "weightKG") {
          vitals["weightKG"] = double.parse((value).toStringAsFixed(2));
        }
        if (key == "heightMeters") {
          vitals["heightMeters"] = double.parse((value).toStringAsFixed(2));
        }
      });
      vitals.removeWhere((key, value) => value == "");
    }
    String apiToken = prefs.get('auth_token');
    iHLUserId = res['User']['id'];
    // String userFirstName, userLastName;
    userFirstName = res['User']['firstName'];
    userLastName = res['User']['lastName'];
    userFirstName ??= "";
    userLastName ??= "";
    ihlUserName = userFirstName + " " + userLastName;
    mobileNumber = res['User']['mobileNumber'];
    userEmail = res['User']['email'];
    docId = widget.details['doctor']['ihl_consultant_id'].toString();
    sharedDocument = widget.details['document_id'];
    print('==========>>>>>>>>>>>>>>>>$sharedDocument');
    try {
      fees = int.tryParse(widget.details['doctor']['affilation_excusive_data']['affilation_array']
          [0]['affilation_price']);
    } catch (e) {
      fees = int.tryParse(widget.details['doctor']['consultation_fees']);
    }
    if (fees == null || affiliationUniqueName == 'global_services') {
      fees = int.tryParse(widget.details['fees']);
    }
    bookedDate = bookingDate();
    print(widget.details['livecall']);
    var xyz = jsonEncode(<String, dynamic>{
      "user_ihl_id": iHLUserId,
      "consultant_name": widget.details['doctor']['name'].toString(),
      "vendor_consultant_id": widget.details['doctor']['vendor_consultant_id'].toString(),
      "ihl_consultant_id": widget.details['doctor']['ihl_consultant_id'].toString(),
      "vendor_id": widget.details['doctor']['vendor_id'].toString(),
      "specality": widget.details['specality'].toString(),
      "consultation_fees": fees,
      "mode_of_payment": "online",
      "alergy": widget.details['alergy'].toString() ?? "",
      "kiosk_checkin_history": vitals,
      // sendLastCheckin == true
      //     ? (vitals != null)
      //     ? vitals
      //     : null
      //     : null,

      // : []
      //   : [],

      "appointment_start_time": widget.details["start_date"].toString().replaceAll("-", "/"),
      // (widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
      //         widget.details['livecall'] == true)
      //     ? "05/17/2021 04:25 PM"
      //     : fometedStartDate,
      "appointment_end_time": widget.details["end_date"].toString().replaceAll("-", "/"),
      // (widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
      //         widget.details['livecall'] == true)
      //     ? "05/17/2021 04:40 PM"
      //     : fometEdendDate,

      //     "appointment_start_time": fometedStartDate,
      // "appointment_end_time": fometEdendDate,

      "appointment_duration": "30 Min", //"30 Min",
      "appointment_status": widget.details['livecall'] == true ? "Approved" : "Requested",
      // 'Requested',//approvalStatus,
      "appointment_model": "appointment",
      "vendor_name": widget.details['doctor']['vendor_id'].toString(),
      "reason_for_visit": widget.details['reason'].toString() ?? "",
      "notes": "",
      "document_id": sharedDocument,
      "direct_call": widget.details['livecall'],
      "affiliation_unique_name": Tabss.isAffi ? 'global_services' : affiliationUniqueName,
    });

    log(xyz.toString());

    log('book appointment time start ${DateTime.now().toString()}');
    final response = await _client.post(
      Uri.parse('${API.iHLUrl}/consult/BookAppointment'),
      // headers: {
      //   'Content-Type': 'application/json',
      //   'ApiToken': '${API.headerr['ApiToken']}',
      //   'Token': '${API.headerr['Token']}',
      // },

      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token':
            '9Jk4Kqbm4qVOwRbftbg2s9Qu7tXxxiPvKcdLl/kPwbckzpWyrZc6OLaJ6KbiGBDDCSCHayHvYnDmxHqk9sND9uhRNhjflKmXsxnDes/YHSdBhka4Msh5zoheHPRCiPtyvtRHVz6yxBOpUBexiFIRCZJDswg7j198BH9+6ITZoNZhwe3RV9+43FlbbMlPkaFDAQA= ',
      },
      body: jsonEncode(<String, dynamic>{
        "user_ihl_id": iHLUserId,
        "consultant_name": widget.details['doctor']['name'].toString(),
        "vendor_consultant_id": widget.details['doctor']['vendor_consultant_id'].toString(),
        "ihl_consultant_id": widget.details['doctor']['ihl_consultant_id'].toString(),
        "vendor_id": widget.details['doctor']['vendor_id'].toString(),
        "specality": widget.details['specality'].toString(),
        "consultation_fees": widget.details['fees'],
        "mode_of_payment": "online",
        "alergy": widget.details['alergy'].toString() ?? "",
        "kiosk_checkin_history": vitals,
        // sendLastCheckin == true
        //     ? (vitals != null)
        //     ? vitals
        //     : null
        //     : null,

        // : []
        //   : [],

        "appointment_start_time": widget.details["start_date"].toString().replaceAll("-", "/"),
        // (widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
        //         widget.details['livecall'] == true)
        //     ? "05/17/2021 04:25 PM"
        //     : fometedStartDate,
        "appointment_end_time": widget.details["end_date"].toString().replaceAll("-", "/"),
        // (widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
        //         widget.details['livecall'] == true)
        //     ? "05/17/2021 04:40 PM"
        //     : fometEdendDate,

        //     "appointment_start_time": fometedStartDate,
        // "appointment_end_time": fometEdendDate,

        "appointment_duration": "30 Min", //"30 Min",
        "appointment_status": widget.details['livecall'] == true ? "Approved" : "Requested",
        // 'Requested',//approvalStatus,
        "appointment_model": "appointment",
        "vendor_name": widget.details['doctor']['vendor_id'].toString(),
        "reason_for_visit": widget.details['reason'].toString() ?? "",
        "notes": "",
        "document_id": sharedDocument,
        "direct_call": widget.details['livecall'],
        "affiliation_unique_name": Tabss.isAffi ? 'global_services' : affiliationUniqueName,
      }),
    );

    log(xyz.toString());
    log('book appointment time end ${DateTime.now().toString()}');
    if (response.statusCode == 200 && !response.body.contains('consultant_busy_failure')) {
      var parsedString = response.body.replaceAll('&quot', '"');
      var parsedString2 = parsedString.replaceAll(";", "");
      var parsedString3 = parsedString2.replaceAll('"{', '{');
      var parsedString4 = parsedString3.replaceAll('}"', '}');
      var finalResponse = json.decode(parsedString4);
      if (widget.details['doctor']['vendor_id'].toString() != "GENIX") {
        appointId = finalResponse['appointment_id'];
      } else {
        appointId = finalResponse['appointment_id'];
        genixAppointId = finalResponse['appointment_id'];
        vendorAppointId = finalResponse['vendor_appointment_id'];
      }
      log('get user detail time start ${DateTime.now().toString()}');

      final getUserDetails = await _client.post(
        Uri.parse(API.iHLUrl + "/consult/get_user_details"),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, dynamic>{
          'ihl_id': iHLUserId,
        }),
      );
      log('get user time end ${DateTime.now().toString()}');

      if (getUserDetails.statusCode == 200) {
        print("Updated");
        final userDetailsResponse = await SharedPreferences.getInstance();
        userDetailsResponse.setString(
          'consultantId_for_share',
          widget.details['doctor']['ihl_consultant_id'].toString(),
        );
        userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);

        if (widget.details['livecall'] == true &&
            widget.details['doctor']['vendor_id'].toString() != "GENIX") {
          startTime();
        }
      } else {
        // Updating irrespective of getUserDetails API Response

        if (this.mounted) {
          setState(() {
            loading = false;
            success = true;
            if (widget.details['livecall'] == true &&
                widget.details['doctor']['vendor_id'].toString() != "GENIX") {
              startTime();
            }
          });
        }
        print(getUserDetails.body);
      }
      var affiliationMRP;
      try {
        affiliationMRP = widget.details['doctor']['affilation_excusive_data']['affilation_array'][0]
            ['affilation_mrp'];
      } catch (e) {
        affiliationMRP = widget.details['doctor']['consultation_fees'];
      }
      log('update payment time start ${DateTime.now().toString()}');
      String principalAmt =
          (double.parse(widget.details['fees'].toString()) / 1.18).toStringAsFixed(2);
      principalAmt = principalAmt == "0.00" ? "" : principalAmt;
      String gstAmt = "";
      if (principalAmt != "") {
        gstAmt = ((double.parse(principalAmt) * 18) / 100).toStringAsFixed(2);
      }

      print("principalAmt = $principalAmt");
      print("gstAmt = $gstAmt");

      final paymentUpdateStatusResponse = await _client.post(
        Uri.parse(API.iHLUrl + "/consult/update_payment_transaction"),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, String>{
          'MRPCost': affiliationMRP,
          'ConsultantID': widget.details['doctor']['ihl_consultant_id'].toString(),
          'ConsultantName': widget.details['doctor']['name'].toString(),
          "ihl_id": iHLUserId,
          "PurposeDetails": jsonEncode(widget.details['purposeDetails']),
          "TotalAmount": widget.details['affiliationPrice'] != "none"
              ? widget.details['affiliationPrice']
              : widget.details['doctor']['consultation_fees'],
          "payment_status": "completed",
          "transaction_start_date_time": DateTime.now().toString(),
          "transactionId": widget.details['transaction_id'],
          "payment_for": "teleconsultation",
          "MobileNumber": mobileNumber,
          "payment_mode": "online",
          "Service_Provided": 'false',
          "appointment_id": finalResponse['appointment_id'],
          "AppointmentID": finalResponse['appointment_id'],
          "razorpay_payment_id": widget.details["razorpay_payment_id"],
          "razorpay_order_id": widget.details["razorpay_order_id"],
          "razorpay_signature": widget.details["razorpay_signature"],
          "principal_amount": principalAmt,
          "gst_amount": gstAmt,
        }),
      );
      log('update payment time end ${DateTime.now().toString()}');

      if (paymentUpdateStatusResponse.statusCode == 200) {
        print('payment update responce ${paymentUpdateStatusResponse.body}');

        ///invoice to the user ###call that function from here
        await sendInvoiceToUser();
        log('Email Sended $userEmail');
        if (mounted)
          setState(() {
            loading = false;
            success = true;
          });

        //for genix live call
        if (widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
            widget.details['livecall'] == true) {
          // final genixResponse = await http.get(
          //   API.iHLUrl+"/consult/direct_call_to_genix?ihl_user_id=${iHLUserId.toString()}&specality=${widget.details['specality'].toString()}&vendor_consultant_id=${widget.details['doctor']['vendor_consultant_id'].toString()}&ihl_appointment_id=$genixAppointId",
          //   headers: {
          //     'ApiToken':
          //         "tNfJTkJafsrzhJB3KQteyk2caz5Ye2OukglXvXr+ez8pB33+C2D+w+zHEHJ7UgboKrrf50P/jE8+On1IOVlObEsDyK/Gtf6iItpBPAwOcc0BAA=="
          //   },
          // );

          // if (genixResponse.statusCode == 200) {
          //   print(
          //       'STATUS Code IS 200   ================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
          //   print('${iHLUserId.toString()}');
          //   print(genixResponse.body);
          //   var parsedString = genixResponse.body.replaceAll('&quot', '"');
          //   var parsedString2 = parsedString.replaceAll(";", "");
          //   var parsedString3 = parsedString2.replaceAll('"{', '{');
          //   var parsedString4 = parsedString3.replaceAll('}"', '}');
          //   var finalResponse = json.decode(parsedString4);
          //   String liveCallLink = finalResponse['URL'];
          //   print(liveCallLink);
          //   // ${iHLUserId.toString()}&specality=${widget.details['specality'].toString()}&vendor_consultant_id=${widget.details['doctor']['vendor_consultant_id'].toString()}&ihl_appointment_id=$genixAppointId",
          //   Get.off(
          // GenixLiveWebView(
          //     genixAppointId: genixAppointId,
          //     url: liveCallLink,
          //     iHLUserId: iHLUserId.toString(),
          //     specality: widget.details['specality'].toString(),
          //     vendor_consultant_id:
          //         widget.details['doctor']['vendor_consultant_id'].toString(),
          //   )
          //   );
          // } else {
          //   print(
          //       'api response failure status code is ${genixResponse.statusCode}');
          // }
          String appointment_ID = finalResponse['appointment_id'];
          Get.to(FreeSuccessPage(
              date: date,
              appointment_ID: appointment_ID,
              liveCall: true,
              materialPageRoute: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.to(() => GenixLiveSignal(
                        genixAppointId: genixAppointId,
                        iHLUserId: iHLUserId.toString(),
                        specality: widget.details['specality'].toString(),
                        vendor_consultant_id:
                            widget.details['doctor']['vendor_consultant_id'].toString(),
                        vendorConsultantId:
                            widget.details['doctor']['vendor_consultant_id'].toString(),
                        vendorAppointmentId: vendorAppointId,
                        vendorUserName: widget.details['doctor']['user_name'],
                      ));
                });
              }));
        }

        /// for appointment

        if (widget.details['livecall'] == false) {
          List<String> receiverIds = [];
          receiverIds.add(widget.details['doctor']['ihl_consultant_id'].toString());
          s.appointmentPublish('GenerateNotification', 'BookAppointment', receiverIds, iHLUserId,
              finalResponse['appointment_id'].toString());
        }
      } else {
        print('appoitnment api responce ${paymentUpdateStatusResponse.body}');
        AwesomeDialog(
                context: context,
                animType: AnimType.TOPSLIDE,
                headerAnimationLoop: true,
                dialogType: DialogType.ERROR,
                dismissOnTouchOutside: false,
                title: 'Failed!',
                desc: 'Payment Failed!',
                btnOkOnPress: () {
                  Navigator.of(context).pop(true);
                },
                btnOkColor: Colors.red,
                btnOkText: 'Done',
                onDismissCallback: (_) {})
            .show();
      }
    } else {
      print(response.body);
      log('get user time start ${DateTime.now().toString()}');

      log('get userdetail time end ${DateTime.now().toString()}');

      if (this.mounted) {
        setState(() {
          loading = false;
          success = true;
          if (widget.details['livecall'] == true &&
              widget.details['doctor']['vendor_id'].toString() != "GENIX") {
            startTime();
          }
        });
      }
    }

    // if (widget.details['doctor']['vendor_id'].toString() == "GENIX") {
    //   generateGenixUrl();
    // }
  }

  // Future generateGenixUrl() async {
  //   final genixURLResponse = await http.post(
  //     API.iHLUrl+"/consult/generate_genix_call_url",
  //     body: jsonEncode(<String, String>{
  //       'ihl_appointment_id': genixAppointId,
  //     }),
  //   );
  //   if (genixURLResponse.statusCode == 200) {
  //     var parsedString = genixURLResponse.body.replaceAll('&quot', '"');
  //     var parsedString2 = parsedString.replaceAll(";", "");
  //     var parsedString3 = parsedString2.replaceAll('"{', '{');
  //     var parsedString4 = parsedString3.replaceAll('}"', '}');
  //     var finalResponse = json.decode(parsedString4);
  //     genixURL = finalResponse['url'];
  //   }
  // }

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
                      'Please wait. DO NOT LEAVE this page while your appointment is being confirmed',
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
                          Get.off(MyAppointment(
                            backNav: false,
                          ));
                          //Navigator.of(context).pop(false);
                        },
                      ),
                    ),
                  ],
                ),
              );
            })
        : Get.off(MyAppointment(
            backNav: false,
          ));
  }

  startTime() async {
    var _duration = new Duration(seconds: 6 ?? 0);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Get.to(FreeSuccessPage(
        date: date,
        appointment_ID: appointId,
        liveCall: true,
        // materialPageRoute:
        materialPageRoute: () {
          Get.offNamedUntil(Routes.CallWaitingScreen, (route) => false, arguments: [
            //'ihl_consultant_' + appointId,
            appointId,
            docId,
            iHLUserId,
            "LiveCall",
            ihlUserName,
          ]);
        }));
  }

  bookingDate() {
    final now = (widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
            widget.details['livecall'] == true)
        ? DateTime.now().add(Duration(minutes: 1))
        : DateTime.now();
    String formattedDate = DateFormat.yMMMMd('en_US').format(now);
    String d_d = now.day.toString();
    String m_m = now.month.toString();
    m_m = MonthFormats.month_number_to_String[m_m];
    if (d_d.length == 1) {
      d_d = '0' + d_d;
    }
    formattedDate = d_d + 'th' + ' ' + m_m;
    String formattedTime = (widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
            widget.details['livecall'] == true)
        ? DateFormat("hh:mm a").format(DateTime.now().add(Duration(minutes: 3)))
        : DateFormat("hh:mm a").format(DateTime.now());

    String appStartDate = formattedDate + ' ' + formattedTime;
    var appEndTime = DateFormat('hh:mm a').parse(formattedTime);
    var appEndTimeString =
        DateFormat('hh:mm a').format(appEndTime.add(Duration(minutes: 30))).toString();

    String appointmentStartDateToSend = "";
    String appointmentEndDateToSend = "";
    DateTime currentDate = new DateTime.now();

    if (appStartDate.contains("rd") ||
        appStartDate.contains("th") ||
        appStartDate.contains("nd") ||
        appStartDate.contains("st")) {
      String dd = appStartDate.substring(0, 2);
      String month = appStartDate.substring(5, 8);
      String mm = "";

      switch (month) {
        case "Jan":
          mm = "01";
          break;
        case "Feb":
          mm = "02";
          break;
        case "Mar":
          mm = "03";
          break;
        case "Apr":
          mm = "04";
          break;
        case "May":
          mm = "05";
          break;
        case "Jun":
          mm = "06";
          break;
        case "Jul":
          mm = "07";
          break;
        case "Aug":
          mm = "08";
          break;
        case "Sep":
          mm = "09";
          break;
        case "Oct":
          mm = "10";
          break;
        case "Nov":
          mm = "11";
          break;
        case "Dec":
          mm = "12";
          break;
      }
      appointmentStartDateToSend =
          currentDate.year.toString() + "-" + mm + "-" + dd + ' ' + formattedTime;

      String endDd = appStartDate.substring(0, 2);
      String endMonth = appStartDate.substring(5, 8);
      String endMm = "";

      switch (endMonth) {
        case "Jan":
          endMm = "01";
          break;
        case "Feb":
          endMm = "02";
          break;
        case "Mar":
          endMm = "03";
          break;
        case "Apr":
          endMm = "04";
          break;
        case "May":
          endMm = "05";
          break;
        case "Jun":
          endMm = "06";
          break;
        case "Jul":
          endMm = "07";
          break;
        case "Aug":
          endMm = "08";
          break;
        case "Sep":
          endMm = "09";
          break;
        case "Oct":
          endMm = "10";
          break;
        case "Nov":
          endMm = "11";
          break;
        case "Dec":
          endMm = "12";
          break;
      }

      appointmentEndDateToSend =
          currentDate.year.toString() + "-" + endMm + "-" + endDd + ' ' + appEndTimeString;
    } else if (appStartDate.contains('today') || appStartDate.contains('Today')) {
      String currentDateDay;
      String currentDateMonth;

      if (currentDate.day.toString().length < 2) {
        currentDateDay = "0" + currentDate.day.toString();
      } else {
        currentDateDay = currentDate.day.toString();
      }

      if (currentDate.month.toString().length < 2) {
        currentDateMonth = "0" + currentDate.month.toString();
      } else {
        currentDateMonth = currentDate.month.toString();
      }

      appointmentStartDateToSend = currentDate.year.toString() +
          '-' +
          currentDateMonth +
          '-' +
          currentDateDay +
          ' ' +
          formattedTime;

      appointmentEndDateToSend = currentDate.year.toString() +
          "-" +
          currentDateMonth +
          "-" +
          currentDateDay +
          ' ' +
          appEndTimeString;
    } else if (appStartDate.contains('tomorrow') || appStartDate.contains('Tomorrow')) {
      var tomorrow = currentDate.add(new Duration(days: 1));
      String tomorrowDateDay;
      String tomorrowDateMonth;

      if (tomorrow.day.toString().length < 2) {
        tomorrowDateDay = "0" + tomorrow.day.toString();
      } else {
        tomorrowDateDay = tomorrow.day.toString();
      }

      if (tomorrow.month.toString().length < 2) {
        tomorrowDateMonth = "0" + tomorrow.month.toString();
      } else {
        tomorrowDateMonth = tomorrow.month.toString();
      }

      appointmentStartDateToSend = tomorrow.year.toString() +
          '-' +
          tomorrowDateMonth +
          '-' +
          tomorrowDateDay +
          ' ' +
          formattedTime;
      appointmentEndDateToSend = tomorrow.year.toString() +
          "-" +
          tomorrowDateMonth +
          "-" +
          tomorrowDateDay +
          ' ' +
          appEndTimeString;
    } else if (appStartDate.contains('January') ||
        appStartDate.contains('February') ||
        appStartDate.contains('March') ||
        appStartDate.contains('April') ||
        appStartDate.contains('May') ||
        appStartDate.contains('June') ||
        appStartDate.contains('July') ||
        appStartDate.contains('August') ||
        appStartDate.contains('September') ||
        appStartDate.contains('October') ||
        appStartDate.contains('November') ||
        appStartDate.contains('December')) {
      String currentDateDay;
      String currentDateMonth;

      if (currentDate.day.toString().length < 2) {
        currentDateDay = "0" + currentDate.day.toString();
      } else {
        currentDateDay = currentDate.day.toString();
      }

      if (currentDate.month.toString().length < 2) {
        currentDateMonth = "0" + currentDate.month.toString();
      } else {
        currentDateMonth = currentDate.month.toString();
      }

      appointmentStartDateToSend = currentDate.year.toString() +
          '-' +
          currentDateMonth +
          '-' +
          currentDateDay +
          ' ' +
          formattedTime;
      appointmentEndDateToSend = currentDate.year.toString() +
          "-" +
          currentDateMonth +
          "-" +
          currentDateDay +
          ' ' +
          appEndTimeString;
    }

    if ((widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
        widget.details['livecall'] == true)) {
      appStrtDate = appointmentStartDateToSend.toString();
      appendDate = appointmentEndDateToSend.toString();

      fometedStartDate = changeDateFormat(appStrtDate.toString());
      fometEdendDate = changeDateFormat(appendDate.toString());
      date = appStrtDate + ' - ' + appendDate;
      return [fometedStartDate, fometEdendDate];
    } else {
      // var appStartDate = widget.details['start_date'];
      // var appEndDate = widget.details['end_date'];
      appStrtDate = widget.details['start_date'];
      appendDate = widget.details['end_date'];

      fometedStartDate = changeDateFormat(appStrtDate.toString());
      fometEdendDate = changeDateFormat(appendDate.toString());
      date = appStrtDate + ' - ' + appendDate;
      return [fometedStartDate, fometEdendDate];
    }
  }

  sendInvoiceToUser() async {
    // AwesomeNotifications()
    //     .cancelAll();
    // var invoiceNumber = await widget.details['doctor']['vendor_id'].toString() != "GENIX" ?ConsultApi().getInvoiceNumber(iHLUserId, appointId):ConsultApi().getInvoiceNumber(iHLUserId, genixAppointId);
    var invoiceNumber;
    var invoiceBase64;
    bool permissionGrandted = false;
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      Map<Permission, PermissionStatus> _status;
      if (deviceInfo.version.sdkInt <= 32) {
        _status = await [Permission.storage].request();
      } else {
        _status = await [Permission.photos, Permission.videos].request();
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("useraddressFromHistory", res['User']['address']);
      prefs.setString("userareaFromHistory", res['User']['area']);
      prefs.setString("usercityFromHistory", res['User']['city']);
      prefs.setString("userstateFromHistory", res['User']['state']);
      prefs.setString("userpincodeFromHistory", res['User']['pincode']);

      invoiceNumber = prefs.getString('invoice');
      if (invoiceNumber == null || invoiceNumber == 'null' || invoiceNumber == '') {
        invoiceNumber = widget.details['invoiceNumber'].toString();
      }

      prefs.setString("consultantNameFromStages", widget.details['doctor']['name'].toString());
      // prefs.setString("appointmentStartTimeFromStages",bookedDate[0]);
      prefs.setString("appointmentStartTimeFromStages", widget.details['start_date']);
      // prefs.setString("appointmentEndTimeFromStages",bookedDate[1]);
      prefs.setString("appointmentEndTimeFromStages", widget.details['end_date']);
      prefs.setString("consultationFeesFromStages", fees.toString());
      prefs.setString("modeOfPaymentFromStages", 'online');
      prefs.setString("userFirstNameFromStages", userFirstName);
      prefs.setString("userLastNameFromStages", userLastName);
      prefs.setString("userEmailFromStages", userEmail);
      prefs.setString("userContactFromStages", mobileNumber);
      // consultationFeesFromHistory =
      //     double.parse(prefs.getString("consultationFeesFromStages"));
      Invoice invoice = await ConsultApi().getInvoiceNumber(iHLUserId, appointId);
      invoiceBase64 = await reportView(context, invoiceNumber, false, invoiceModel: invoice);

      // });
    } else {
      Get.snackbar('Storage Access Denied', 'Allow Storage permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              // style: TextButton
              //     .styleFrom(
              //   primary:
              //       Colors.white,
              // ),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    }
    String invoiceFeesText = widget.details['MRPCost'].toString() != ""
        ? widget.details['MRPCost'].toString()
        : widget.details["fees"].toString();

    var jsontext =
        '{"first_name":"$userFirstName","last_name":"$userLastName","email":"$userEmail","mobile":"$mobileNumber","invoice_id":"$invoiceNumber","date":"${widget.details["start_date"].toString().replaceAll("-", "/")}","amount":"$invoiceFeesText","invoice_base64":"$invoiceBase64"}';
    // '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$prescription_base64","security_hash":"$calculatedHash"}';
    print('api yet to be called');
    log('send invoice time start ${DateTime.now().toString()}');
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/login/sendInvoiceToUser"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsontext,
    );
    print('api called===================================>>>');
    print(invoiceBase64);
    print(jsontext);
    log('send invoice time end ${DateTime.now().toString()}');
    if (response.statusCode == 200) {
      print(response.body);
      // Get.close(1);
      print(response.body);
    } else {
      // Get.close(1);
      print(response.body);
    }
  }

  @override
  void initState() {
    bookConsultation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: PaymentUI(
        color: (loading == false && success == true)
            ? AppColors.bookApp
            : (loading == false && success == false)
                ? Colors.red
                : AppColors.myApp,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            (loading == false && success == true && showMissed == false)
                ? widget.details['livecall']
                    ? 'Live call Connecting !'
                    : 'Appointment Successful !'
                : (loading == false &&
                        success == false &&
                        showMissed == false &&
                        (widget.details['livecall'] == false))
                    ? 'Appointment Failed !'
                    : (loading == false &&
                            success == false &&
                            showMissed == false &&
                            (widget.details['livecall']))
                        ? 'Live Call Connecting Failed !'
                        : (widget.details['livecall'])
                            ? 'Live call ...'
                            : 'Booking Appointment ...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: (loading == false)
              ? IconButton(
                  key: Key('paymentSuccessBackButton'),
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Get.off(MyAppointment(
                    backNav: false,
                  )),
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
                  ? Lottie.network('https://assets2.lottiefiles.com/packages/lf20_pn7kzizl.json',
                      height: 300, width: 300)
                  : (loading == false && success == false)
                      ? Lottie.network(API.declinedLottieFileUrl, height: 300, width: 300)
                      : Lottie.network(
                          'https://assets5.lottiefiles.com/packages/lf20_e5fibvuv.json',
                          height: 400,
                          width: 400),
              Container(
                child: (loading == false && success == true)
                    ? (widget.details['livecall'])
                        ? Text(
                            'You will be redirected to Call Screen automatically within 5 seconds...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          )
                        : Text(
                            'Your appointment for ' + "\n" + date + ' \n Booked successfully!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          )
                    : (loading == false && success == false)
                        ? Text('Your appointment for ' + date + ' failed!\n Try Again!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                            ))
                        : (widget.details['livecall'] && showMissed == false)
                            ? Text(
                                'Please Wait...\nConnecting to the consultant',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                ),
                              )
                            : (showMissed == true)
                                ? Text(
                                    'Consultant is Busy... Please try later\n',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue,
                                    ),
                                  )
                                : Text(
                                    'Please wait. DO NOT LEAVE this page while your appointment is being confirmed',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue,
                                    ),
                                  ),
              ),
              SizedBox(height: 30),
              (loading == false && success == true && widget.details['livecall'] == false)
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          key: Key('paymentSuccessViewMyAppointment'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            primary: (loading == false && success == true)
                                ? Colors.green
                                : (loading == false && success == false)
                                    ? Colors.red
                                    : AppColors.myApp,
                          ),
                          onPressed: ((loading == false &&
                                      success == true &&
                                      widget.details['livecall'] == false) ||
                                  (loading == false && success == false))
                              ? () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyAppointment(
                                                backNav: false,
                                              )),
                                      (Route<dynamic> route) => false);
                                }
                              : null,
                          child: Text(
                            (loading == false &&
                                    success == true &&
                                    widget.details['livecall'] == false)
                                ? "View My Appointments"
                                : (loading == false && success == false)
                                    ? "Try Again"
                                    : "Proceed",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          // key: Key('paymentSuccessViewMyAppointment'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            primary: Colors.green,
                          ),
                          onPressed: ((loading == false &&
                                      success == true &&
                                      widget.details['livecall'] == false) ||
                                  (loading == false && success == false))
                              ? () async {
                                  bool permissionGrandted = false;
                                  if (Platform.isAndroid) {
                                    final deviceInfo = await DeviceInfoPlugin().androidInfo;
                                    Map<Permission, PermissionStatus> _status;
                                    if (deviceInfo.version.sdkInt <= 32) {
                                      _status = await [Permission.storage].request();
                                    } else {
                                      _status =
                                          await [Permission.photos, Permission.videos].request();
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
                                    Get.snackbar(
                                      '',
                                      'Invoice will be saved in your mobile!',
                                      backgroundColor: AppColors.primaryAccentColor,
                                      colorText: Colors.white,
                                      duration: Duration(seconds: 5),
                                      isDismissible: false,
                                    );
                                    await appointmentDetailsGlobal(
                                        context: context, appointmentID: appointId);
                                    Invoice invoice =
                                        await ConsultApi().getInvoiceNumber(iHLUserId, appointId);

                                    new Future.delayed(new Duration(seconds: 2), () {
                                      billView(context, invoice.ihlInvoiceNumbers, true,
                                          invoiceModel: invoice, navigation: "dont");
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
                              : null,
                          child: Text(
                            (loading == false &&
                                    success == true &&
                                    widget.details['livecall'] == false)
                                ? "Download Invoice"
                                : (loading == false && success == false)
                                    ? "Try Again"
                                    : "Proceed",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  : Container(),
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
    List<String> test1 = List<String>(19);
    test1[0] = test2[5];
    test1[1] = test2[6];
    test1[2] = '/';
    test1[3] = test2[8];
    test1[4] = test2[9];
    test1[5] = '/';
    test1[6] = test2[0];
    test1[7] = test2[1];
    test1[8] = test2[2];
    test1[9] = test2[3];
    test1[10] = test2[10];
    test1[11] = test2[11];
    test1[12] = test2[12];
    test1[13] = test2[13];
    test1[14] = test2[14];
    test1[15] = test2[15];
    test1[16] = test2[16];
    test1[17] = test2[17];
    test1[18] = test2[18];
    finaldate = test1.join('');
    return finaldate;
  }
}
//"e01844fc6b754ca58c7d924d030e6d16"
