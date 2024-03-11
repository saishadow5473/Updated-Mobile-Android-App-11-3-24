import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../constants/routes.dart';
import '../../../../constants/spKeys.dart';
import '../../../data/providers/network/api_provider.dart';
import '../../../firebase_utils/firebase_utils.dart' as fire_node;
import '../../../../utils/SpUtil.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/dateFormat.dart';
import '../../../../views/teleconsultation/view_bill.dart';
import '../../../../widgets/teleconsulation/payment/paymentUI.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../models/invoice.dart';
import '../../../../repositories/api_consult.dart';
import '../../../../views/teleconsultation/view_all_appoinments_free.dart';
import '../../../../views/view_past_bill/view_only_bill.dart';
import '../../../../widgets/teleconsulation/appointmentTile.dart';
import '../../../data/model/TeleconsultationModels/doctorModel.dart';
import '../../../firebase_utils/firestore_instructions.dart';
import '../../../jitsi/genix_signal.dart';
import '../../Widgets/appBar.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../teleconsultation/wait_for_consultant_screen.dart';
import 'myAppointmentsTabs.dart';

class SuccessPageNew extends StatefulWidget {
  DoctorModel doctorDetails;
  Map purposeDetails;
  Map datadecode;
  final Map details;

  SuccessPageNew({this.details, this.doctorDetails, this.purposeDetails, this.datadecode});

  @override
  _SuccessPageNewState createState() => _SuccessPageNewState();
}

class _SuccessPageNewState extends State<SuccessPageNew> {
  http.Client _client = http.Client(); //3gb
  bool loading = true;
  bool success = false;
  String date = '';
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
    print(widget.purposeDetails['document_id']);
    print(widget.datadecode);
    print(widget.details);
    print(widget.doctorDetails);
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
    Object data = prefs.get('data');
    prefs.setString('consultantName', widget.doctorDetails.name.toString());
    prefs.setString('consultantId', widget.doctorDetails.ihlConsultantId.toString());
    prefs.setString('vendorName', widget.doctorDetails.vendorId.toString());
    String vendorConsultantId = widget.doctorDetails.vendorConsultantId;
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
    docId = widget.doctorDetails.ihlConsultantId.toString();
    sharedDocument = widget.purposeDetails['document_id'];
    print('==========>>>>>>>>>>>>>>>>$sharedDocument');
    try {
      if (widget.doctorDetails.affilationExcusiveData != null) {
        fees = int.tryParse(
            widget.doctorDetails.affilationExcusiveData.affilationArray[0].affilationPrice);
      } else {
        fees = int.tryParse(widget.details["fees"]);
      }
    } catch (e) {
      fees = int.tryParse(widget.doctorDetails.consultationFees);
    }
    if (fees == null || affiliationUniqueName == 'global_services') {
      // fees = int.tryParse(widget.doctorDetails.consultationFees);
      fees = int.tryParse(widget.details["fees"]);
      //purposeDetails
    }
    bookedDate = bookingDate();
    String xyz = jsonEncode(<String, dynamic>{
      "user_ihl_id": iHLUserId,
      "consultant_name": widget.doctorDetails.name.toString(),
      "vendor_consultant_id": widget.doctorDetails.vendorConsultantId.toString(),
      "ihl_consultant_id": widget.doctorDetails.ihlConsultantId.toString(),
      "vendor_id": widget.doctorDetails.vendorId.toString(),
      "specality": widget.doctorDetails.consultantSpeciality.first ?? "N/A",
      "consultation_fees": fees,
      "mode_of_payment": "online",
      "alergy": widget.purposeDetails['alergy'].toString() ?? "",
      "kiosk_checkin_history": vitals,
      // sendLastCheckin == true
      //     ? (vitals != null)
      //     ? vitals
      //     : null
      //     : null,

      // : []
      //   : [],

      "appointment_start_time":
          widget.purposeDetails["appointment_start_time"].toString().replaceAll("-", "/"),
      // (widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
      //         widget.details['livecall'] == true)
      //     ? "05/17/2021 04:25 PM"
      //     : fometedStartDate,
      "appointment_end_time":
          widget.purposeDetails["appointment_end_time"].toString().replaceAll("-", "/"),
      // (widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
      //         widget.details['livecall'] == true)
      //     ? "05/17/2021 04:40 PM"
      //     : fometEdendDate,

      //     "appointment_start_time": fometedStartDate,
      // "appointment_end_time": fometEdendDate,

      "appointment_duration": "30 Min", //"30 Min",
      "appointment_status": widget.doctorDetails.livecall == true ? "Approved" : "Requested",
      // 'Requested',//approvalStatus,
      "appointment_model": "appointment",
      "vendor_name": widget.doctorDetails.vendorId.toString(),
      "reason_for_visit": widget.purposeDetails['reason_for_visit'].toString() ?? "",
      "notes": "",
      "document_id": sharedDocument,
      "direct_call": widget.doctorDetails.livecall,
      // widget.doctorDetails.vendorId.toString() == "GENIX" &&
      //         widget.doctorDetails.livecall == true
      //     ? true
      //     : false,
      "affiliation_unique_name": affiliationUniqueName,
    });

    log(xyz.toString());

    log('book appointment time start ${DateTime.now().toString()}');
    final http.Response response = await _client.post(
        Uri.parse('${API.iHLUrl}/consult/BookAppointment'),
        // headers: {
        //   'Content-Type': 'application/json',
        //   'ApiToken': '${API.headerr['ApiToken']}',
        //   'Token': '${API.headerr['Token']}',
        // },

        headers: {
          'Content-Type': 'application/json',
          'ApiToken': API.headerr['ApiToken'],
          'Token': API.headerr["Token"],
        },
        body: xyz
        // body: jsonEncode(<String, dynamic>{
        //   "user_ihl_id": iHLUserId,
        //   "consultant_name": widget.doctorDetails.name.toString(),
        //   "vendor_consultant_id": widget.doctorDetails.vendorConsultantId.toString(),
        //   "ihl_consultant_id": widget.doctorDetails.ihlConsultantId.toString(),
        //   "vendor_id": widget.doctorDetails.vendorId.toString(),
        //   "specality": widget.doctorDetails.consultantSpeciality.toString(),
        //   "consultation_fees": widget.doctorDetails.consultationFees,
        //   "mode_of_payment": "online",
        //   "alergy": widget.purposeDetails['alergy'].toString() ?? "",
        //   "kiosk_checkin_history": vitals,
        //   // sendLastCheckin == true
        //   //     ? (vitals != null)
        //   //     ? vitals
        //   //     : null
        //   //     : null,

        //   // : []
        //   //   : [],

        //   "appointment_start_time":
        //       widget.purposeDetails["appointment_start_time"].toString().replaceAll("-", "/"),
        //   // (widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
        //   //         widget.details['livecall'] == true)
        //   //     ? "05/17/2021 04:25 PM"
        //   //     : fometedStartDate,
        //   "appointment_end_time":
        //       widget.purposeDetails["appointment_end_time"].toString().replaceAll("-", "/"),
        //   // (widget.details['doctor']['vendor_id'].toString() == "GENIX" &&
        //   //         widget.details['livecall'] == true)
        //   //     ? "05/17/2021 04:40 PM"
        //   //     : fometEdendDate,

        //   //     "appointment_start_time": fometedStartDate,
        //   // "appointment_end_time": fometEdendDate,

        //   "appointment_duration": "30 Min", //"30 Min",
        //   "appointment_status": widget.doctorDetails.livecall == true ? "Approved" : "Requested",
        //   // 'Requested',//approvalStatus,
        //   "appointment_model": "appointment",
        //   "vendor_name": widget.doctorDetails.vendorId.toString(),
        //   "reason_for_visit": widget.details['reason'].toString() ?? "",
        //   "notes": "",
        //   "document_id": sharedDocument,
        //   "direct_call": widget.doctorDetails.livecall,
        //   // widget.doctorDetails.vendorId.toString() == "GENIX" &&
        //   //         widget.doctorDetails.livecall == true
        //   //     ? true
        //   //     : false,
        //   "affiliation_unique_name": affiliationUniqueName,
        // }),
        );

    log(xyz.toString());
    log('book appointment time end ${DateTime.now().toString()}');
    if (response.statusCode == 200 && !response.body.contains('consultant_busy_failure')) {
      String parsedString = response.body.replaceAll('&quot', '"');
      String parsedString2 = parsedString.replaceAll(";", "");
      String parsedString3 = parsedString2.replaceAll('"{', '{');
      String parsedString4 = parsedString3.replaceAll('}"', '}');
      var finalResponse = json.decode(parsedString4);
      if (widget.doctorDetails.vendorId.toString() != "GENIX") {
        appointId = finalResponse['appointment_id'];
      } else {
        appointId = finalResponse['appointment_id'];
        genixAppointId = finalResponse['appointment_id'];
        vendorAppointId = finalResponse['vendor_appointment_id'];
      }
      if (!widget.doctorDetails.livecall) {
        FireStoreServices.appointmentStatusUpdate(
            attributes: AppointmentStatusModel(
                docID: widget.doctorDetails.ihlConsultantId.toString(),
                userID: iHLUserId,
                status: "Requested",
                appointmentID: appointId));
      }
      log('get user detail time start ${DateTime.now().toString()}');

      final http.Response getUserDetails = await _client.post(
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
        final SharedPreferences userDetailsResponse = await SharedPreferences.getInstance();
        userDetailsResponse.setString(
          'consultantId_for_share',
          widget.doctorDetails.ihlConsultantId.toString(),
        );
        userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);

        if (widget.doctorDetails.livecall == true &&
            widget.doctorDetails.vendorId.toString() != "GENIX") {
          startTime();
        }
      } else {
        log("There is an issuse from the get_user_details ");
        // Updating irrespective of getUserDetails API Response

        if (this.mounted) {
          setState(() {
            loading = false;
            success = true;
            if (widget.doctorDetails.livecall == true &&
                widget.doctorDetails.vendorId.toString() != "GENIX") {
              startTime();
            }
          });
        }
        print(getUserDetails.body);
      }
      String affiliationMRP;
      try {
        if (widget.doctorDetails.affilationExcusiveData != null) {
          affiliationMRP =
              widget.doctorDetails.affilationExcusiveData.affilationArray[0].affilationMrp;
        } else {
          affiliationMRP = widget.details['fees'].toString();
        }
      } catch (e) {
        affiliationMRP = widget.doctorDetails.consultationFees;
      }
      log('update payment time start ${DateTime.now().toString()}');
      // Get the principal amount by dividing the total fees by 1.18
      String principalAmt =
          (double.parse(widget.details['fees'].toString()) / 1.18).toStringAsFixed(2);
      // If the principal amount is 0, set it to empty string
      principalAmt = principalAmt == "0.00" ? "" : principalAmt;
      // Get the GST amount by multiplying the principal amount by 18 and dividing by 100
      String gstAmt = "";
      if (principalAmt != "") {
        gstAmt = ((double.parse(principalAmt) * 18) / 100).toStringAsFixed(2);
      }

      print("principalAmt = $principalAmt");
      print("gstAmt = $gstAmt");

      final http.Response paymentUpdateStatusResponse = await _client.post(
        Uri.parse(API.iHLUrl + "/consult/update_payment_transaction"),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, String>{
          'MRPCost': affiliationMRP,
          'ConsultantID': widget.doctorDetails.ihlConsultantId.toString(),
          'ConsultantName': widget.doctorDetails.name.toString(),
          "ihl_id": iHLUserId,
          "PurposeDetails": jsonEncode(widget.purposeDetails),
          "TotalAmount": widget.doctorDetails.affilationExcusiveData != null
              ? widget.doctorDetails.affilationExcusiveData.affilationArray[0].affilationPrice
              : widget.details['fees'].toString(),
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
      log('${paymentUpdateStatusResponse.body}');
      log("There is an issuse from the update_payment_transaction ");
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
        if (widget.doctorDetails.vendorId.toString() == "GENIX" &&
            widget.doctorDetails.livecall == true) {
          String appointmentId = finalResponse['appointment_id'];
          Get.to(FreeSuccessPage(
              date: date,
              appointment_ID: appointmentId,
              liveCall: true,
              materialPageRoute: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.to(() => GenixSignal(
                      genixCallDetails: GenixCallDetails(
                          genixAppointId: genixAppointId,
                          ihlUserId: iHLUserId,
                          specality: widget.doctorDetails.consultantSpeciality.first,
                          vendorAppointmentId: vendorAppointId,
                          vendorConsultantId: widget.doctorDetails.vendorConsultantId,
                          vendorUserName: widget.doctorDetails.userName)));
                });
              }));
        }

        /// for appointment

        if (widget.doctorDetails.livecall == false) {
          List<String> receiverIds = [];
          receiverIds.add(widget.doctorDetails.ihlConsultantId.toString());
          fire_node.appointmentPublish('GenerateNotification', 'BookAppointment', receiverIds,
              iHLUserId, finalResponse['appointment_id'].toString());
        }
      } else {
        log("There is an issuse from the update_payment_transaction ");
        print('appoitnment api responce ${paymentUpdateStatusResponse.body}');
        AwesomeDialog(
                context: context,
                animType: AnimType.topSlide,
                headerAnimationLoop: true,
                dialogType: DialogType.error,
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
          if (widget.doctorDetails.livecall == true &&
              widget.doctorDetails.vendorId.toString() != "GENIX") {
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
                    const Text(
                      'Info !\n',
                      style: TextStyle(color: AppColors.primaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Please wait. DO NOT LEAVE this page while your appointment is being confirmed',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text(
                          'Okay',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          // Get.off(MyAppointment(
                          //   backNav: false,
                          // ));
                          Get.off(MyAppointmentsTabs(fromCall: true));
                          //Navigator.of(context).pop(false);
                        },
                      ),
                    ),
                  ],
                ),
              );
            })
        : Get.off(MyAppointmentsTabs(fromCall: true));
    // Get.off(MyAppointment(
    //         backNav: false,
    //       )
  }

  startTime() async {
    Duration _duration = new Duration(seconds: 6 ?? 0);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Get.to(FreeSuccessPage(
        date: date,
        appointment_ID: appointId,
        liveCall: true,
        // materialPageRoute:
        materialPageRoute: () {
          TeleConsultationFunctionsAndVariables().permissionCheckerForCall(
              nav: () => Get.offAll(WaitForConsultant(
                    videoCallDetails: VideoCallDetail(
                        appointId: appointId,
                        docId: docId,
                        userID: iHLUserId,
                        callType: "LiveCall",
                        ihlUserName: ihlUserName),
                  )));
          // Get.offNamedUntil(Routes.CallWaitingScreen, (Route route) => false, arguments: [
          //   //'ihl_consultant_' + appointId,
          //   appointId,
          //   docId,
          //   iHLUserId,
          //   "LiveCall",
          //   ihlUserName,
          // ]);
        }));
  }

  bookingDate() {
    final DateTime now = (widget.doctorDetails.vendorId.toString() == "GENIX" &&
            widget.doctorDetails.livecall == true)
        ? DateTime.now().add(const Duration(minutes: 1))
        : DateTime.now();
    String formattedDate = DateFormat.yMMMMd('en_US').format(now);
    String d_d = now.day.toString();
    String m_m = now.month.toString();
    m_m = MonthFormats.month_number_to_String[m_m];
    if (d_d.length == 1) {
      d_d = '0' + d_d;
    }
    formattedDate = d_d + 'th' + ' ' + m_m;
    String formattedTime = (widget.doctorDetails.vendorId.toString() == "GENIX" &&
            widget.doctorDetails.livecall == true)
        ? DateFormat("hh:mm a").format(DateTime.now().add(const Duration(minutes: 3)))
        : DateFormat("hh:mm a").format(DateTime.now());

    String appStartDate = formattedDate + ' ' + formattedTime;
    DateTime appEndTime = DateFormat('hh:mm a').parse(formattedTime);
    String appEndTimeString =
        DateFormat('hh:mm a').format(appEndTime.add(const Duration(minutes: 30))).toString();

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
      DateTime tomorrow = currentDate.add(new Duration(days: 1));
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

    if ((widget.doctorDetails.vendorId.toString() == "GENIX" &&
        widget.doctorDetails.livecall == true)) {
      appStrtDate = appointmentStartDateToSend.toString();
      appendDate = appointmentEndDateToSend.toString();

      fometedStartDate = changeDateFormat(appStrtDate.toString());
      fometEdendDate = changeDateFormat(appendDate.toString());
      date = appStrtDate + ' - ' + appendDate;
      return [fometedStartDate, fometEdendDate];
    } else {
      // var appStartDate = widget.details['start_date'];
      // var appEndDate = widget.details['end_date'];
      appStrtDate = widget.purposeDetails['appointment_start_time'];
      appendDate = widget.purposeDetails['appointment_end_time'];

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
    String invoiceNumber;
    var invoiceBase64;
    bool permissionGrandted = false;
    if (Platform.isAndroid) {
      final AndroidDeviceInfo deviceInfo = await DeviceInfoPlugin().androidInfo;
      Map<Permission, PermissionStatus> _status;
      if (deviceInfo.version.sdkInt <= 32) {
        _status = await [Permission.storage].request();
      } else {
        _status = await [Permission.photos, Permission.videos].request();
      }
      _status.forEach((Permission permission, PermissionStatus status) {
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

      prefs.setString("consultantNameFromStages", widget.doctorDetails.name.toString());
      // prefs.setString("appointmentStartTimeFromStages",bookedDate[0]);
      prefs.setString(
          "appointmentStartTimeFromStages", widget.purposeDetails['appointment_start_time']);
      // prefs.setString("appointmentEndTimeFromStages",bookedDate[1]);
      prefs.setString(
          "appointmentEndTimeFromStages", widget.purposeDetails['appointment_end_time']);
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
          duration: const Duration(seconds: 5),
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
              child: const Text('Allow')));
    }
    String invoiceFeesText = widget.details['MRPCost'].toString() != ""
        ? widget.details['MRPCost'].toString()
        : widget.details["fees"].toString();

    String jsontext =
        '{"first_name":"$userFirstName","last_name":"$userLastName","email":"$userEmail","mobile":"$mobileNumber","invoice_id":"$invoiceNumber","date":"${widget.purposeDetails["appointment_start_time"].toString().replaceAll("-", "/")}","amount":"$invoiceFeesText","invoice_base64":"$invoiceBase64"}';
    // '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$prescription_base64","security_hash":"$calculatedHash"}';
    print('api yet to be called');
    log('send invoice time start ${DateTime.now().toString()}');
    final http.Response response = await _client.post(
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
      log("There is an issuse from the Send invoice ");
      // Get.close(1);
      print(response.body);
    }
  }

  @override
  void initState() {
    // widget.doctorDetails.livecall ??= widget.details['livecall'];
    bookConsultation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            (loading == false && success == true && showMissed == false)
                ? widget.doctorDetails.livecall
                    ? 'Live call Connecting !'
                    : 'Appointment Successful !'
                : (loading == false &&
                        success == false &&
                        showMissed == false &&
                        (widget.doctorDetails.livecall == false))
                    ? 'Appointment Failed !'
                    : (loading == false &&
                            success == false &&
                            showMissed == false &&
                            (widget.doctorDetails.livecall))
                        ? 'Live Call Connecting Failed !'
                        : (widget.doctorDetails.livecall)
                            ? 'Live call ...'
                            : 'Booking Appointment ...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: (loading == false)
              ? IconButton(
                  key: const Key('paymentSuccessBackButton'),
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Get.to(MyAppointmentsTabs(fromCall: true))
                  //     Get.off(MyAppointment(
                  //   backNav: false,
                  // )
                  ,
                  color: Colors.white,
                  tooltip: 'Back',
                )
              : Container(),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              (loading == false && success == true)
                  ? Container(
                      height: 70.w,
                      width: 70.w,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("newAssets/Icons/success_payment.png"),
                              fit: BoxFit.contain)),
                    )
                  : (loading == false && success == false)
                      ? Lottie.network(API.declinedLottieFileUrl, height: 300, width: 300)
                      : Lottie.network(
                          'https://assets5.lottiefiles.com/packages/lf20_e5fibvuv.json',
                          height: 400,
                          width: 400),
              Container(
                child: (loading == false && success == true)
                    ? (widget.doctorDetails.livecall)
                        ? const Text(
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
                          )
                    : (loading == false && success == false)
                        ? Text(
                            'Your appointment for ' + date + ' failed!\n Try Again!',
                            textAlign: TextAlign.center,
                          )
                        : (widget.doctorDetails.livecall && showMissed == false)
                            ? const Text(
                                'Please Wait...\nConnecting to the consultant',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                ),
                              )
                            : (showMissed == true)
                                ? const Text(
                                    'Please wait. DO NOT LEAVE this page while your appointment is being confirmed',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue,
                                    ),
                                  )
                                : const Text(
                                    'Please Wait...\nDO NOT GO BACK while\nBooking Appointment',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blue,
                                    ),
                                  ),
              ),
              const SizedBox(height: 30),
              (loading == false && success == true && widget.doctorDetails.livecall == false)
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: 70.w,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.primaryColor, width: 2),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 3,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 0))
                              ]),
                          child: GestureDetector(
                            onTap: ((loading == false &&
                                        success == true &&
                                        widget.doctorDetails.livecall == false) ||
                                    (loading == false && success == false))
                                ? () {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                MyAppointmentsTabs(fromCall: true)
                                            // MyAppointment(
                                            //   backNav: false,
                                            // )
                                            ),
                                        (Route<dynamic> route) => false);
                                  }
                                : null,
                            child: Text(
                              (loading == false &&
                                      success == true &&
                                      widget.doctorDetails.livecall == false)
                                  ? "VIEW ALL APPOINTMENTS"
                                  : (loading == false && success == false)
                                      ? "Try Again"
                                      : "Proceed",
                              style: TextStyle(
                                  letterSpacing: 0.3,
                                  color: Colors.black.withOpacity(0.5),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          // ElevatedButton(
                          //   // key: Key('paymentSuccessViewMyAppointment'),
                          //   style: ElevatedButton.styleFrom(
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(10.0),
                          //     ),
                          //     backgroundColor: Colors.green,
                          //   ),
                          //   onPressed: ((loading == false &&
                          //               success == true &&
                          //               widget.doctorDetails.livecall == false) ||
                          //           (loading == false && success == false))
                          //       ? () async {
                          //           bool permissionGranted = false;
                          //           if (Platform.isAndroid) {
                          //             final AndroidDeviceInfo deviceInfo =
                          //                 await DeviceInfoPlugin().androidInfo;
                          //             Map<Permission, PermissionStatus> _status;
                          //             if (deviceInfo.version.sdkInt <= 32) {
                          //               _status = await [Permission.storage].request();
                          //             } else {
                          //               _status =
                          //                   await [Permission.photos, Permission.videos].request();
                          //             }
                          //             _status
                          //                 .forEach((Permission permission, PermissionStatus status) {
                          //               if (status == PermissionStatus.granted) {
                          //                 permissionGranted = true;
                          //               }
                          //             });
                          //           } else {
                          //             permissionGranted = true;
                          //           }
                          //           if (permissionGranted) {
                          //             Get.snackbar(
                          //               '',
                          //               'Invoice will be saved in your mobile!',
                          //               backgroundColor: AppColors.primaryAccentColor,
                          //               colorText: Colors.white,
                          //               duration: Duration(seconds: 5),
                          //               isDismissible: false,
                          //             );
                          //             await appointmentDetailsGlobal(
                          //                 context: context, appointmentID: appointId);
                          //             Invoice invoice =
                          //                 await ConsultApi().getInvoiceNumber(iHLUserId, appointId);
                          //
                          //             Future.delayed(Duration(seconds: 2), () {
                          //               billView(context, invoice.ihlInvoiceNumbers, true,
                          //                   invoiceModel: invoice, navigation: "dont");
                          //             });
                          //           } else {
                          //             Get.snackbar('Storage Access Denied',
                          //                 'Allow Storage permission to continue',
                          //                 backgroundColor: Colors.red,
                          //                 colorText: Colors.white,
                          //                 duration: Duration(seconds: 5),
                          //                 isDismissible: false,
                          //                 mainButton: TextButton(
                          //                     onPressed: () async {
                          //                       await openAppSettings();
                          //                     },
                          //                     child: Text('Allow')));
                          //           }
                          //         }
                          //       : null,
                          //   child: Text(
                          //     (loading == false &&
                          //             success == true &&
                          //             widget.doctorDetails.livecall == false)
                          //         ? "Download Invoice"
                          //         : (loading == false && success == false)
                          //             ? "Try Again"
                          //             : "Proceed",
                          //     style: TextStyle(color: Colors.white),
                          //   ),
                          // ),
                        )
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
