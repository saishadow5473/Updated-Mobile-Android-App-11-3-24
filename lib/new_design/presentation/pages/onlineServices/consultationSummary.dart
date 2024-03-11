import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/CrossbarUtil.dart';
import '../../../../views/teleconsultation/files/pdf_viewer.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';
import '../../../../constants/spKeys.dart';
import '../../../../models/PrescriptionModel.dart';
import '../../../../models/invoice.dart';
import '../../../../repositories/api_consult.dart';
import '../../../../views/teleconsultation/videocall/genix_prescription.dart';
import '../../../../views/teleconsultation/view_bill.dart';
import '../../../app/utils/appColors.dart';
import 'dart:developer';

import '../../../data/model/TeleconsultationModels/consultation_summary_model.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_apiCalls.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../../pdf/consultation_instruction_pdf.dart';
import '../home/landingPage.dart';

class ConsultationSummaryScreen extends StatefulWidget {
  const ConsultationSummaryScreen({Key key, @required this.fromCall, @required this.appointmentId})
      : super(key: key);
  final bool fromCall;
  final String appointmentId;

  @override
  State<ConsultationSummaryScreen> createState() => _ConsultationSummaryScreenState();
}

class _ConsultationSummaryScreenState extends State<ConsultationSummaryScreen> {
  ConsultationSummaryModel appointmentSummaryDetails;
  List<dynamic> getFilesSummaryList;
  String userid = '';
  List<String> kioskValues = <String>[];
  String firstName, lastName, email, mobileNumber, age, gender, finalGender, weight;
  String address;
  String pincode;
  String area;
  String state;
  String city;
  var bmi;
  int finalAge;
  var ihlUserId;
  var invoiceNumber;
  Invoice invoice;

  List<PrescriptionModel> prescriptionsList = [];

  asyncFunction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString("ihlUserId");
    appointmentSummaryDetails = await TeleConsultationFunctionsAndVariables.getAppointmentDetails(
        appointmentId: widget.appointmentId);

    try {
      if (appointmentSummaryDetails.message.prescription != null &&
          appointmentSummaryDetails.message.prescription.length != 0) {
        int size = appointmentSummaryDetails.message.prescription.length;
        for (var e in appointmentSummaryDetails.message.prescription) {
          prescriptionsList.add(PrescriptionModel.fromJson(e));
        }
      }
    } catch (e) {
      print(e.toString());
    }
    getFilesSummaryList = await TeleConsultationApiCalls.getFilesSummary(
        consultantId: appointmentSummaryDetails.message.ihlConsultantId,
        appID: widget.appointmentId);
    prefs.setString(
        "appointmentStartTimeFromStages", appointmentSummaryDetails.message.appointmentStartTime);
    prefs.setString(
        "consultationFeesFromStages", appointmentSummaryDetails.message.consultationFees);
    prefs.setString("consultantNameFromStages", appointmentSummaryDetails.message.consultantName);
    appointmentSummaryDetails.kioskCheckinHistory
        .toJson()
        .values
        .map((dynamic e) => kioskValues.add(e.toString()))
        .toList();
    kioskValues
        .removeWhere((String element) => element.toString() == "null" || element.toString() == "");
    if (mounted) setState(() {});
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);
    firstName = res['User']['firstName'];
    ihlUserId = res['User']['id'];
    lastName = res['User']['lastName'];
    firstName ??= "";
    lastName ??= "";
    email = res['User']['email'];
    mobileNumber = res['User']['mobileNumber'];
    age = res['User']['dateOfBirth'];
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

    invoice = await TeleConsultationApiCalls.getInvoiceNumber(ihlUserId, appointId);
    invoiceNumber = prefs.getString('invoice');
    gender = res['User']['gender'];
    if (gender == "m" || gender == "M" || gender == "male" || gender == "Male") {
      finalGender = "Male";
    } else {
      finalGender = "Female";
    }
    age = age.replaceAll(" ", "");
    if (age.contains("-")) {
      DateTime tempDate = DateFormat("dd-MM-yyyy").parse(age);
      DateTime currentDate = DateTime.now();
      finalAge = currentDate.year - tempDate.year;
    } else if (age.contains("/")) {
      DateTime tempDate = DateFormat("MM/dd/yyyy").parse(age.trim());
      DateTime currentDate = DateTime.now();
      finalAge = currentDate.year - tempDate.year;
    }
    if (res.containsKey('LastCheckin')) {
      if (res['LastCheckin'].containsKey('bmi') || res['LastCheckin'].containsKey('bmi')) {
        weight = res['LastCheckin']['weightKG'].toStringAsFixed(2);
        bmi = res['LastCheckin']['bmi'].toStringAsFixed(2);
      }
    } else {
      weight = null;
      bmi = null;
    }
    if (weight != null && weight != '') {
      null;
    } else {
      Object raw = prefs.get(SPKeys.userData);
      if (raw == '' || raw == null) {
        raw = '{}';
      }
      Map data = jsonDecode(raw);

      Map user = data['User'];
      user ??= {};

      /// calculate bmi🎇🎇
      int calcBmi({height, weight}) {
        double parsedH;
        double parsedW;
        if (height != null && weight != null && height != '' && weight != '') {
          parsedH = double.tryParse(height.toString());
          parsedW = double.tryParse(weight.toString());
        }
        if (parsedH != null && parsedW != null) {
          int bmi = parsedW ~/ (parsedH * parsedH);

          return bmi;
        }
        return null;
      }
      //get inputted height weight if values are not available

      weight = user['userInputWeightInKG'];

      var height = user['heightMeters'];

      //Calculate bmi

      bmi = calcBmi(height: height, weight: weight);

      // bmi = bmiClassCalc(userVitals[0]['bmi']);
    }
  }

  @override
  void initState() {
    asyncFunction();
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TeleConsultationFunctionsAndVariables.getAppointmentDetails(
    //     appointmentId: widget.appointmentId);
    // TeleConsultationApiCalls.getFilesSummary(
    //         consultantId: appointmentSummaryDetails.message.ihlConsultantId,
    //         appID: widget.appointmentId)
    //     .then((v) {
    //   getFilesSummaryList = v;
    // });
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (widget.fromCall) {
          Get.offAll(LandingPage());
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          automaticallyImplyLeading: false,
          title: const Text("Consultation Summary"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              if (widget.fromCall) {
                Get.offAll(LandingPage());
              } else {
                Get.back();
              }
            },
            color: Colors.white,
          ),
        ),
        body: SingleChildScrollView(
          child: appointmentSummaryDetails == null
              ? SizedBox(
                  height: 75.h,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(left: 18.sp, right: 18.sp, top: 22.sp, bottom: 22.sp),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        headingDetails('Consultant Details'),
                        SizedBox(height: 1.h),
                        // summaryDescriptionDetails(
                        //     'Consultant Name', widget.completeAppointment.consultantName),
                        summaryDescriptionDetails('Consultant Name',
                            appointmentSummaryDetails.consultantDetails.consultantName),
                        SizedBox(height: 1.h),
                        summaryDescriptionDetails(
                            'Speciality', appointmentSummaryDetails.message.specality ?? "N/A"),
                        SizedBox(
                          height: 2.h,
                        ),
                        headingDetails('Consultation Details'),
                        SizedBox(height: 1.7.h),
                        summaryDescriptionDetails('Appointment ID', widget.appointmentId),
                        SizedBox(height: 1.5.h),
                        // summaryDescriptionDetails('Appointment Start time',
                        //     widget.completeAppointment.appointmentStartTime),
                        summaryDescriptionDetails('Appointment Start time',
                            appointmentSummaryDetails.message.appointmentStartTime),
                        SizedBox(height: 1.5.h),
                        // summaryDescriptionDetails(
                        //     'Appointment End time', widget.completeAppointment.appointmentEndTime),
                        summaryDescriptionDetails('Appointment End time',
                            appointmentSummaryDetails.message.appointmentEndTime),
                        SizedBox(height: 1.5.h),
                        // summaryDescriptionDetails(
                        //     'Appointment Status', widget.completeAppointment.callStatus),
                        summaryDescriptionDetails('Appointment Status',
                            appointmentSummaryDetails.message.callStatus ?? "N/A"),
                        SizedBox(height: 1.5.h),
                        // summaryDescriptionDetails(
                        //     'Charges', widget.completeAppointment.consultationFees),
                        summaryDescriptionDetails(
                            'Charges', appointmentSummaryDetails.message.consultationFees),
                        SizedBox(height: 1.5.h),
                        // summaryDescriptionDetails(
                        //     'Payment Mode', widget.completeAppointment.modeOfPayment),
                        summaryDescriptionDetails('Payment Mode',
                            appointmentSummaryDetails.message.modeOfPayment ?? "N/A"),
                        SizedBox(height: 1.5.h),
                        // summaryDescriptionDetails(
                        //     'Appointment Model', widget.completeAppointment.appointmentStatus),
                        summaryDescriptionDetails('Appointment Model',
                            appointmentSummaryDetails.message.appointmentStatus),
                        SizedBox(height: 1.5.h),
                        summaryDescriptionDetails(
                            'Allergy', appointmentSummaryDetails.message.alergy ?? 'N/A'),
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          height: 2.h,
                        ),
                        if (prescriptionsList.isNotEmpty) headingDetails('Prescription'),
                        if (prescriptionsList.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (prescriptionsList.first.medNote != "")
                                summaryDescriptionDetails(
                                    'Notes', prescriptionsList.first.medNote ?? "N/A"),
                              if (prescriptionsList.first.medNote != "") SizedBox(height: 1.5.h),
                              Column(
                                children: prescriptionsList.map((PrescriptionModel e) {
                                  if (e.drugName != "" && e.drugName != null) {
                                    int rollNumber = prescriptionsList
                                        .indexWhere((PrescriptionModel ee) => e == ee);
                                    rollNumber++;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        summaryDescriptionDetails(
                                            '$rollNumber. Drug Name', e.drugName,
                                            manualpadding: true),
                                        summaryDescriptionDetails('Days', e.days,
                                            manualpadding: true),
                                        if (e.sig != null && e.sig != "")
                                          summaryDescriptionDetails('Frequency', e.sig,
                                              manualpadding: true),
                                        if (e.directionOfUse != null && e.directionOfUse != "")
                                          summaryDescriptionDetails(
                                              'Direction Of Use', e.directionOfUse,
                                              manualpadding: true),
                                        SizedBox(height: 1.5.h),
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                }).toList(),
                              ),
                            ],
                          ),
                        SizedBox(height: 1.5.h),
                        if (appointmentSummaryDetails.message.patientDiagnosis.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              headingDetails('Diagnosis'),
                              SizedBox(height: 0.5.h),
                              ...appointmentSummaryDetails.message.patientDiagnosis
                                  .map((dynamic e) {
                                return Column(
                                  children: <Widget>[
                                    if (e["diagnosis_name"].toString() != "" &&
                                        e["diagnosis_name"].toString() != "null")
                                      summaryDescriptionDetails(
                                          "Diagnosis Name", e["diagnosis_name"] ?? "N/A"),
                                    if (e["diagnosis_note"].toString() != "" &&
                                        e["diagnosis_note"].toString() != "null")
                                      summaryDescriptionDetails(
                                          "Diagnosis Note", e["diagnosis_note"] ?? "N/A",
                                          manualpadding: true),
                                  ],
                                );
                              }).toList(),
                              SizedBox(height: 2.h),
                            ],
                          ),
                        if (appointmentSummaryDetails.message.labTests.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              headingDetails('Lab Tests'),
                              SizedBox(height: 0.5.h),
                              if (appointmentSummaryDetails.message.labTests.first.testName !=
                                      "N/A" &&
                                  appointmentSummaryDetails.message.labTests.first.testName != "")
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Prescribed Tests : ",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    ...appointmentSummaryDetails.message.labTests
                                        .map((LabTestModel e) {
                                      int serialNumber =
                                          appointmentSummaryDetails.message.labTests.indexOf(e) + 1;
                                      return Column(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100.w,
                                            child: Text(
                                              "$serialNumber. ${e.testName.toString()}",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16.px,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 1.h),
                                        ],
                                      );
                                    }).toList(),
                                    SizedBox(height: 0.5.h),
                                  ],
                                ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Remarks : ",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  ...appointmentSummaryDetails.message.labTests
                                      .map((LabTestModel e) {
                                    int serialNumber =
                                        appointmentSummaryDetails.message.labTests.indexOf(e) + 1;
                                    return Column(
                                      children: <Widget>[
                                        Text(
                                          "$serialNumber. ${e.labNote.toString()}",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16.px,
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                              SizedBox(height: 2.h),
                            ],
                          ),
                        if (appointmentSummaryDetails.message.radiology.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              headingDetails('Radiology '),
                              SizedBox(height: 0.5.h),
                              ...appointmentSummaryDetails.message.radiology
                                  .map((RadiologyModel e) {
                                int serialNumber =
                                    appointmentSummaryDetails.message.radiology.indexOf(e) + 1;
                                return Column(
                                  children: <Widget>[
                                    if (e.testName != "")
                                      summaryDescriptionDetails(
                                          "$serialNumber. Test Name", e.testName ?? "N/A",
                                          manualpadding: true),
                                    if (e.radiologyNote != "")
                                      summaryDescriptionDetails("Notes", e.radiologyNote ?? "N/A",
                                          manualpadding: true),
                                    if (e.prescribedBy != "")
                                      summaryDescriptionDetails(
                                          "Prescribed By", e.prescribedBy ?? "N/A",
                                          manualpadding: true),
                                    if (e.testPrescribedOn != "")
                                      summaryDescriptionDetails(
                                          "Prescribed On", e.testPrescribedOn ?? "N/A",
                                          manualpadding: true),
                                    SizedBox(height: 1.5.h),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        Container(
                          alignment: Alignment.center,
                          width: 100.w,
                          child: Visibility(
                            visible: (appointmentSummaryDetails.message.vendorName == 'GENIX') &&
                                    // ((prescription != null &&
                                    //         prescription.length > 0 &&
                                    //         prescription != "N/A")
                                    (prescriptionsList.isNotEmpty ||
                                        // (genixRadiology != null &&
                                        //     genixRadiology.length > 0 &&
                                        //     genixRadiology != "N/A")
                                        appointmentSummaryDetails.message.radiology.isNotEmpty ||
                                        appointmentSummaryDetails.message.labTests.isNotEmpty)
                                // (labTestList != null &&
                                //     labTestList.length > 0 &&
                                //     labTestList != "N/A"))
                                ? true
                                : false,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  backgroundColor: AppColors.primaryColor,
                                ),
                                child: const Text('Report',
                                    style: TextStyle(
                                      fontSize: 16,
                                    )),
                                onPressed: () async {
                                  bool permissionGrandted = false;
                                  if (Platform.isAndroid) {
                                    AndroidDeviceInfo deviceInfo =
                                        await DeviceInfoPlugin().androidInfo;
                                    Map<Permission, PermissionStatus> status;
                                    if (deviceInfo.version.sdkInt <= 32) {
                                      status = await [Permission.storage].request();
                                    } else {
                                      status =
                                          await [Permission.photos, Permission.videos].request();
                                    }
                                    status
                                        .forEach((Permission permission, PermissionStatus status) {
                                      if (status == PermissionStatus.granted) {
                                        permissionGrandted = true;
                                      }
                                    });
                                  } else {
                                    permissionGrandted = true;
                                  }
                                  if (permissionGrandted) {
                                    Message message = appointmentSummaryDetails.message;
                                    ConsultantDetails consultantDetails =
                                        appointmentSummaryDetails.consultantDetails;
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString("consultantNameFromHistorySummary",
                                        consultantDetails.consultantName);
                                    prefs.setString("consultantEmailFromHistorySummary",
                                        consultantDetails.consultantEmail);
                                    prefs.setString("consultantMobileFromHistorySummary",
                                        consultantDetails.consultantMobile);
                                    prefs.setString("consultantEducationFromHistorySummary",
                                        consultantDetails.education);
                                    prefs.setString("consultantDescriptionFromHistorySummary",
                                        consultantDetails.description);
                                    prefs.setString("appointmentStartTimeFromHistorySummary",
                                        message.appointmentStartTime);
                                    prefs.setString(
                                        "reasonForVisitFromHistorySummary", message.reasonForVisit);
                                    prefs.setString(
                                        "diagnosisFromHistorySummary", message.diagnosis);
                                    prefs.setString("instructionFromHistorySummary",
                                        message.consultationInternalNotes ?? "N/A");
                                    prefs.setString("adviceFromHistorySummary",
                                        message.consultationAdviceNotes ?? "N/A");
                                    prefs.setString("userFirstNameFromHistorySummary", firstName);
                                    prefs.setString("userLastNameFromHistorySummary", lastName);
                                    prefs.setString("userEmailFromHistorySummary", email);
                                    prefs.setString("userContactFromHistorySummary", mobileNumber);
                                    prefs.setString("ageFromHistorySummary", finalAge.toString());
                                    prefs.setString("genderFromHistorySummary", finalGender);

                                    prefs.setString("useraddressFromHistory", address);
                                    prefs.setString("userareaFromHistory", area);
                                    prefs.setString("usercityFromHistory", city);
                                    prefs.setString("userstateFromHistory", state);
                                    prefs.setString("userpincodeFromHistory", pincode);

                                    Get.snackbar(
                                      '',
                                      'Instructions will be saved in your mobile!',
                                      backgroundColor: AppColors.primaryAccentColor,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 5),
                                      isDismissible: false,
                                    );
                                    String getPlatformData = prefs.getString(SPKeys.platformData);
                                    Map res = jsonDecode(getPlatformData);
                                    if (res['consult_type'] == null ||
                                        res['consult_type'] is! List ||
                                        res['consult_type'].isEmpty) {
                                      return;
                                    }
                                    String type = "Health Consultation";
                                    var consultType = res['consult_type']
                                        .where((i) => i["consultation_type_name"] == type)
                                        .toList();
                                    List<dynamic> spclty = [];
                                    spclty = consultType.map((e) {
                                      return e["specality"];
                                    }).toList();
                                    // .where(
                                    //     (i) => i["specality_name"] == message.specality)
                                    // .toList();
                                    List temp = [];
                                    spclty.map((e) {
                                      temp += e["consultant_list"];
                                    });
                                    String rmpid;
                                    String accountId;
                                    String consultantAddress;
                                    if (temp.isNotEmpty) {
                                      List temp2 = [];
                                      temp2 = temp.where((element) {
                                        return element["ihl_consultant_id"] ==
                                            message.ihlConsultantId;
                                      }).toList();
                                      // spclty[0]['consultant_list']
                                      //     .where((i) =>
                                      //         i['ihl_consultant_id'] ==
                                      //         message.ihlConsultantId)
                                      //     .toList();
                                      rmpid = temp2[0]['RMP_ID'];
                                      accountId = temp2[0]['account_id'];
                                      consultantAddress = temp2[0]['consultant_address'];
                                    }
                                    String footerDetail;
                                    String imageBase64;
                                    await TeleConsultationApiCalls.getLogoForPrescriptionPDF(
                                            accId: consultantDetails.accountId)
                                        .then((List<dynamic> value) {
                                      footerDetail = value[0];
                                      imageBase64 = value[1];
                                    });
                                    dynamic consultantSignature =
                                        await TeleConsultationApiCalls.getSignature(
                                            message.ihlConsultantId);
                                    Future<void>.delayed(const Duration(seconds: 2), () {
                                      genixPrescription(
                                        context: context,
                                        allergies: message.alergy,
                                        mobilenummber: mobileNumber,
                                        showPdfNotification: true,
                                        footer: footerDetail,
                                        prescriptionNotes: message.prescription != null &&
                                                message.prescription.length > 0
                                            ? message.prescription[0]["med_note"] ?? 'N/A'
                                            : 'N/A',
                                        appointmentId: widget.appointmentId,
                                        allergy: message.alergy,
                                        prescription: message.prescription ?? "N/A",
                                        bmi: bmi,
                                        weight: weight,
                                        rmpid: rmpid,
                                        notes: message.notes,
                                        specality: message.specality,
                                        consultantSignature: consultantSignature,
                                        genixDaignosis: message.patientDiagnosis,
                                        genixRadiology:
                                            message.radiology.map((e) => e.toJson()).toList(),
                                        kisokCheckinHistory:
                                            message.kioskCheckinHistory.toJson().keys.isEmpty
                                                ? "N/A"
                                                : kisokDataManipulation(
                                                    message.kioskCheckinHistory.toJson()),
                                        genixLabTest:
                                            message.labTests.map((e) => e.toJson()).toList(),
                                        genixLabNotes:
                                            message.labTests.map((e) => e.toJson()).toList(),
                                        // .map((dynamic e) {
                                        //   if (e['lab_note'] != null && e['lab_note'] != '') {
                                        //     return e['lab_note'].toString();
                                        //   }
                                        //   return "";
                                        // }).toList(),
                                        consultantAddress: consultantAddress,
                                        logoUrl: Image.memory(base64Decode(imageBase64)),
                                      );
                                    });
                                  } else {
                                    Get.snackbar('Storage Access Denied',
                                        'Allow Storage permission to continue',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 5),
                                        isDismissible: false,
                                        mainButton: TextButton(
                                            onPressed: () async {
                                              await openAppSettings();
                                            },
                                            child: const Text('Allow')));
                                  }
                                }),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        if (appointmentSummaryDetails.message.notes.isNotEmpty)
                          headingDetails('Notes'),
                        if (appointmentSummaryDetails.message.notes.isNotEmpty)
                          Column(children: <Widget>[
                            SizedBox(height: 1.h),
                            ...appointmentSummaryDetails.message.notes
                                .map((dynamic e) => Text(
                                      e.toString().replaceAll('&amp;', ' & '),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.black,
                                        height: 1.3,
                                        fontSize: 15.5.sp,
                                      ),
                                      maxLines: 2,
                                    ))
                                .toList(),
                            SizedBox(height: 2.h),
                          ]),
                        headingDetails('Reason to Visit'),
                        SizedBox(height: 1.h),
                        SizedBox(
                          child: Text(
                            appointmentSummaryDetails.message.reasonForVisit,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.black,
                                height: 1.3,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        if (kioskValues.isNotEmpty)
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              headingDetails('Vital data'),
                              //invoice
                            ],
                          ),
                        SizedBox(height: 0.5.h),
                        ...appointmentSummaryDetails.kioskCheckinHistory
                            .toJson()
                            .keys
                            .map((String e) {
                          int index = appointmentSummaryDetails.kioskCheckinHistory
                              .toJson()
                              .keys
                              .toList()
                              .indexWhere((String element) => element == e);
                          final List<String> key =
                              appointmentSummaryDetails.kioskCheckinHistory.toJson().keys.toList();
                          final List<dynamic> value = appointmentSummaryDetails.kioskCheckinHistory
                              .toJson()
                              .values
                              .toList();
                          if (value[index].toString() != "null") {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(5.sp, 10.px, 5.sp, 0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 50.w,
                                    child: Text(
                                      capitalize(key[index].toString()),
                                      // formatType(
                                      //     key: capitalize(key[index].toString()), itsKey: true),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.black,
                                        height: 1.6,
                                        fontSize: key[index].length > 20 ? 15.5.sp : 16.sp,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ': ',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: key[index].length > 20 ? 15.5.sp : 16.sp,
                                    ),
                                  ),
                                  // Spacer(),
                                  SizedBox(
                                    width: 35.w,
                                    child: Text(
                                      formatType(
                                          keyValue: value[index].toString(),
                                          itsKey: false,
                                          key: key[index]),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                        height: 1.6,
                                        fontSize: 15.5.sp,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox();
                        }).toList(),
                        SizedBox(height: 1.h),
                        appointmentSummaryDetails.message.consultationAdviceNotes.toString() ==
                                    "null" &&
                                appointmentSummaryDetails.message.diagnosis.toString() == "null"
                            ? const SizedBox()
                            : SizedBox(height: 1.5.h),
                        appointmentSummaryDetails.message.consultationAdviceNotes.toString() ==
                                    "null" ||
                                appointmentSummaryDetails.message.diagnosis.toString() == "null" ||
                                appointmentSummaryDetails.message.diagnosis.toString() == "" ||
                                appointmentSummaryDetails.message.consultationAdviceNotes
                                        .toString() ==
                                    ""
                            ? const SizedBox()
                            : headingwithdownload('Consultant instructions'),
                        Visibility(
                            visible:
                                appointmentSummaryDetails.message.diagnosis.toString() != "null" &&
                                    appointmentSummaryDetails.message.diagnosis.toString() != "",
                            child: SizedBox(height: 1.5.h)),
                        appointmentSummaryDetails.message.diagnosis.toString() == "null" ||
                                appointmentSummaryDetails.message.diagnosis.toString() == ""
                            ? const SizedBox()
                            : headingString("Diagnosis  :"),
                        appointmentSummaryDetails.message.diagnosis.toString() == "null" ||
                                appointmentSummaryDetails.message.diagnosis.toString() == ""
                            ? const SizedBox()
                            : SizedBox(height: 1.5.h),
                        appointmentSummaryDetails.message.diagnosis.toString() == "null"
                            ? const SizedBox()
                            : content("${appointmentSummaryDetails.message.diagnosis ?? "N/A"}"),
                        appointmentSummaryDetails.message.diagnosis.toString() == "null" ||
                                appointmentSummaryDetails.message.diagnosis.toString() == ""
                            ? const SizedBox()
                            : SizedBox(height: 1.5.h),
                        appointmentSummaryDetails.message.consultationAdviceNotes.toString() ==
                                    "null" ||
                                appointmentSummaryDetails.message.consultationAdviceNotes
                                        .toString() ==
                                    ""
                            ? const SizedBox()
                            : headingString("Consultation advice notes"),
                        appointmentSummaryDetails.message.consultationAdviceNotes.toString() ==
                                "null"
                            ? const SizedBox()
                            : SizedBox(height: 1.5.h),
                        appointmentSummaryDetails.message.consultationAdviceNotes.toString() ==
                                "null"
                            ? const SizedBox()
                            : content(
                                "${appointmentSummaryDetails.message.consultationAdviceNotes ?? "N/A"}"),
                        appointmentSummaryDetails.message.consultationAdviceNotes.toString() ==
                                "null"
                            ? const SizedBox()
                            : SizedBox(height: 1.5.h),
                        getFilesSummaryList.isEmpty
                            ? const SizedBox()
                            : headingDetails('Shared Medical Report:'),
                        ...getFilesSummaryList.map((e) {
                          return Column(
                            children: <Widget>[
                              ListTile(
                                leading: e['document_link'].substring(
                                                e['document_link'].lastIndexOf(".") + 1) ==
                                            'jpg' ||
                                        e['document_link'].substring(
                                                e['document_link'].lastIndexOf(".") + 1) ==
                                            'png'
                                    ? const Icon(Icons.image)
                                    : const Icon(Icons.insert_drive_file),
                                // Icon(Icons.insert_drive_file),
                                title: Text("${e['document_name']}" ?? "N/A"),
                                subtitle: Padding(
                                  padding: EdgeInsets.all(8.sp),
                                  child: Text(
                                      camelize(e['document_type'].replaceAll('_', ' ')) ?? "N/A"),
                                ),
                                onTap: () async {
                                  await Get.to(
                                    PdfView(
                                      e['document_link'],
                                      e,
                                      userid,
                                      showExtraButton: false,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              const Divider(
                                thickness: 1.4,
                                height: 10.0,
                                indent: 5.0,
                                endIndent: 5.0,
                              ),
                            ],
                          );
                        }).toList(),
                        Visibility(
                          visible: appointmentSummaryDetails.message.consultationFees != "0"
                              ? appointmentSummaryDetails.message.consultationFees == "free"
                                  ? false
                                  : true
                              : false,
                          child: Center(
                            child: SizedBox(
                              child: TextButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: AppColors.primaryColor,
                                    textStyle: const TextStyle(color: Colors.white),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 2.w),
                                      Text(
                                        "Get Invoice",
                                        style: TextStyle(color: Colors.white, fontSize: 15.sp),
                                      ),
                                      SizedBox(width: 2.w),
                                      const Icon(Icons.download_rounded, color: Colors.white)
                                    ],
                                  ),
                                  onPressed: () async {
                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    String iHLUserId = prefs.getString('ihlUserId');
                                    bool permissionGrandted = false;
                                    if (Platform.isAndroid) {
                                      final AndroidDeviceInfo deviceInfo =
                                          await DeviceInfoPlugin().androidInfo;
                                      Map<Permission, PermissionStatus> status;
                                      if (deviceInfo.version.sdkInt <= 32) {
                                        status = await <Permission>[Permission.storage].request();
                                      } else {
                                        status = await <Permission>[
                                          Permission.photos,
                                          Permission.videos
                                        ].request();
                                      }
                                      status.forEach(
                                          (Permission permission, PermissionStatus status) {
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
                                      prefs.setString("useraddressFromHistory", address);
                                      prefs.setString("userareaFromHistory", area);
                                      prefs.setString("usercityFromHistory", city);
                                      prefs.setString("userstateFromHistory", state);
                                      prefs.setString("userpincodeFromHistory", pincode);
                                      prefs.setString("userFirstNameFromStages", firstName);
                                      prefs.setString("userLastNameFromStages", lastName);
                                      prefs.setString("userContactFromStages", mobileNumber);
                                      prefs.setString("userEmailFromStages", email);
                                      Get.snackbar(
                                        '',
                                        'Invoice will be saved in your mobile!',
                                        backgroundColor: AppColors.primaryAccentColor,
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 5),
                                        isDismissible: false,
                                      );
                                      Invoice invoice = await ConsultApi()
                                          .getInvoiceNumber(iHLUserId, widget.appointmentId);
                                      Future<void>.delayed(const Duration(seconds: 2), () async {
                                        reportView(context, invoiceNumber, true,
                                            invoiceModel: invoice);
                                      });
                                    } else {
                                      Get.snackbar('Storage Access Denied',
                                          'Allow Storage permission to continue',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                          duration: const Duration(seconds: 5),
                                          isDismissible: false,
                                          mainButton: TextButton(
                                              onPressed: () async {
                                                await openAppSettings();
                                              },
                                              child: const Text('Allow')));
                                    }
                                  }),
                            ),
                          ),
                        ),
                      ]),
                ),
        ),
      ),
    );
  }

//Below code is used to get the proper parameter type for kiosk values based on their key names ✅
  String formatType({String key, String keyValue, bool itsKey}) {
    if (itsKey) {
      switch (key) {
        case "WeightKG":
          return "Weight";
          break;
        default:
          return key;
      }
    } else {
      switch (key) {
        case "Weight":
          return "$keyValue kg";
          break;
        case "Height":
          String height;
          try {
            height = (double.parse(keyValue.toString()) * 100).toStringAsFixed(0);
          } catch (e) {
            height = "N/A";
          }
          return "$height cm";
          break;
        case "Bone Mineral Content":
          return "$keyValue kg";
          break;
        case "Protien":
          return "$keyValue kg";
          break;
        case "Extra Cellular Water":
          return "$keyValue ltr";
          break;
        case "Intra Cellular Water":
          return "$keyValue ltr";
          break;
        case "Mineral":
          return "$keyValue kg";
          break;
        case "Skeletal Muscle Mass":
          return "$keyValue kg";
          break;
        case "Body Fat Mass":
          return "$keyValue kg";
          break;
        case "Body Cell Mass":
          return "$keyValue kg";
          break;
        case "Percent Body Fat":
          return "$keyValue %";
          break;
        case "Visceral Fat":
          return "$keyValue cm.sq";
          break;
        case "Basal Metabolic Rate":
          return "$keyValue K-Cal";
          break;
        default:
          return keyValue;
      }
    }
  }

  Widget content(String content) {
    return Opacity(
      opacity: 0.6,
      child: Text(
        content,
        textAlign: TextAlign.left,
        style: TextStyle(
            color: Colors.black, height: 1.3, fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget headingString(String content) {
    return Text(
      content,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: AppColors.blackText,
        height: 1.3,
        fontSize: 17.sp,
      ),
    );
  }

  Widget headingDetails(String heading) {
    return Text(
      heading,
      textAlign: TextAlign.left,
      style: TextStyle(
          color: AppColors.primaryColor, height: 1.3, fontSize: 17.sp, fontWeight: FontWeight.bold),
    );
  }

  Widget summaryDescriptionDetails(String detailsLeft, String detailsRight, {bool manualpadding}) {
    return Padding(
      padding: manualpadding ?? false ? EdgeInsets.only(bottom: 10.sp) : EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 38.w,
            child: Text(
              detailsLeft,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                height: 1.2,
                fontSize: 16.sp,
              ),
            ),
          ),
          const Text(
            ': ',
            textAlign: TextAlign.left,
          ),
          Opacity(
            opacity: 0.6,
            child: SizedBox(
              width: 48.w,
              child: Text(
                detailsRight.toString(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  height: 1.3,
                  fontSize: 15.5.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  Widget summaryDescriptionDetailsForPrescription(String detailsLeft, String detailsRight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(
          width: 38.w,
          child: Text(
            detailsLeft,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              height: 1.2,
              fontSize: 16.sp,
            ),
          ),
        ),
        const Text(
          ': ',
          textAlign: TextAlign.left,
        ),
        Opacity(
          opacity: 0.6,
          child: SizedBox(
            width: 48.w,
            child: Text(
              detailsRight.toString(),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                height: 1.3,
                fontSize: 15.5.sp,
              ),
              maxLines: 2,
            ),
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget vitaldataDetails(String detailsRight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text(
          ':',
          textAlign: TextAlign.left,
        ),
        // Spacer(),
        SizedBox(
          width: 50.w,
          child: Opacity(
            opacity: 0.6,
            child: Text(
              detailsRight,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
                height: 1.3,
                fontSize: 15.5.sp,
              ),
              maxLines: 2,
            ),
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget headingwithdownload(String detailsLeft) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          detailsLeft,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: AppColors.primaryColor,
              height: 1.3,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        InkWell(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String data = prefs.getString("data");
            Map<String, dynamic> userData = jsonDecode(data)["User"];
            String fectedAge = userData["dateOfBirth"];
            DateTime dateTime = DateFormat("mm/dd/yyyy").parse(fectedAge);
            String finalAge = (DateTime.now().year - dateTime.year).toString();
            String gender = userData["gender"];
            appointmentSummaryDetails.userDetails.age = finalAge;
            appointmentSummaryDetails.userDetails.gender =
                gender.toLowerCase().contains("f") ? "Female" : "Male";
            bool permissionGrandted = false;
            // Checking permission to download the instructions based on the device ⚪
            if (Platform.isAndroid) {
              final AndroidDeviceInfo deviceInfo = await DeviceInfoPlugin().androidInfo;
              Map<Permission, PermissionStatus> status;
              if (deviceInfo.version.sdkInt <= 32) {
                status = await <Permission>[Permission.storage].request();
              } else {
                status = await <Permission>[Permission.photos, Permission.videos].request();
              }
              status.forEach((Permission permission, PermissionStatus status) {
                if (status == PermissionStatus.granted) {
                  debugPrint("Permission Allowed to Download file");
                  permissionGrandted = true;
                }
              });
            } else {
              permissionGrandted = true;
            }
            if (permissionGrandted) {
              //PDF started Rendering using the below functions ⚪
              Future<void>.delayed(const Duration(seconds: 2), () {
                instructionsView(context: context, summary: appointmentSummaryDetails);
              });
              //Snack bar that shows The instructions are saved in Your mobile ⚪
              Get.snackbar(
                'Info !',
                'Instructions will be saved in your mobile!',
                backgroundColor: AppColors.primaryAccentColor,
                margin: EdgeInsets.all(2.w),
                icon: Icon(
                  Icons.download_outlined,
                  size: 10.w,
                  color: Colors.white,
                ),
                boxShadows: <BoxShadow>[
                  BoxShadow(
                      blurRadius: 3,
                      spreadRadius: 3,
                      offset: const Offset(0, 0),
                      color: Colors.black.withOpacity(0.1))
                ],
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
                isDismissible: true,
              );
            } else {
              //Snack bar that shows permission was denied ⚪
              Get.snackbar('Storage Access Denied', 'Allow Storage permission to continue',
                  duration: const Duration(seconds: 3),
                  isDismissible: true,
                  backgroundColor: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: EdgeInsets.all(2.w),
                  colorText: Colors.red,
                  boxShadows: <BoxShadow>[
                    BoxShadow(
                        blurRadius: 3,
                        spreadRadius: 3,
                        offset: const Offset(0, 0),
                        color: Colors.black.withOpacity(0.1))
                  ],
                  mainButton: TextButton(
                      onPressed: () async {
                        await openAppSettings();
                      },
                      child: const Text('Allow')));
            }
          },
          child: Container(
            alignment: Alignment.center,
            height: 10.w,
            width: 10.w,
            child: Icon(Icons.download, color: AppColors.primaryColor, size: 25.px),
          ),
        ),
        SizedBox(height: 1.h),
      ],
    );
  }

  kisokDataManipulation(Map<String, dynamic> kisokData) {
    List<dynamic> lastCheckinList = <dynamic>[];
    String type;
    String value;
    String status;
    String unit;
    //weight
    if (kisokData['weightKG'] != null) {
      type = 'Weight';
      value = kisokData['weightKG'].toStringAsFixed(2);
      status = 'N/A';
      unit = 'Kg';
      lastCheckinList
          .add(<String, dynamic>{'type': type, 'value': value, 'status': status, 'unit': unit});
    }
    //bmi
    if (kisokData['bmi'] != null) {
      type = 'BMI';
      value = kisokData['bmi'].toStringAsFixed(2);
      status = kisokData['bmiClass'];
      unit = 'N/A';
      lastCheckinList
          .add(<String, dynamic>{'type': type, 'value': value, 'status': status, 'unit': unit});
    }
    //blood pressure
    if (kisokData['diastolic'] != null && kisokData['systolic'] != null) {
      type = 'Blood Pressure';
      value = '${kisokData['systolic']}/${kisokData['diastolic']}';
      status = kisokData['bpClass'] ?? 'N/A';
      unit = 'mmHg';
      lastCheckinList
          .add(<String, dynamic>{'type': type, 'value': value, 'status': status, 'unit': unit});
    }
    //bmc
    if (kisokData['percent_body_fat'] != null) {
      type = 'Body Mass Composition';
      value = kisokData['percent_body_fat'];
      status = kisokData['fatClass'] ?? 'N/A';
      unit = '%';
      lastCheckinList
          .add(<String, dynamic>{'type': type, 'value': value, 'status': status, 'unit': unit});
    }
    //ECG
    if (kisokData['ecgBpm'] != null) {
      type = 'ECG';
      value = kisokData['ecgBpm'];
      status = kisokData['leadTwoStatus'] ?? 'N/A';
      unit = 'N/A';
      lastCheckinList
          .add(<String, dynamic>{'type': type, 'value': value, 'status': status, 'unit': unit});
    }
    //SPO2
    if (kisokData['spo2'] != null) {
      type = 'SPO2';
      value = kisokData['spo2'];
      status = kisokData['spo2Class'] ?? 'N/A';
      unit = '%';
      lastCheckinList
          .add(<String, dynamic>{'type': type, 'value': value, 'status': status, 'unit': unit});
    }
    //temprature
    if (kisokData['temperature'] != null) {
      type = 'Temperature';
      value = kisokData['temperature'];
      status = kisokData['temperatureClass'] ?? 'N/A';
      unit = ' F';
      lastCheckinList
          .add(<String, dynamic>{'type': type, 'value': value, 'status': status, 'unit': unit});
    }
    //Test Time
    if (kisokData['dateTime'] != null) {
      type = 'Test Time';
      value = kisokData['dateTime'].toString().substring(0, 10);
      status = 'N/A';
      unit = 'N/A';
      lastCheckinList
          .add(<String, dynamic>{'type': type, 'value': value, 'status': status, 'unit': unit});
    }
    return lastCheckinList;
  }
}
