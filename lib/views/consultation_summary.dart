// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';

//import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/repositories/api_consult.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/home_screen.dart';
import 'package:ihl/views/teleconsultation/consultation_history_summary.dart';
import 'package:ihl/views/teleconsultation/files/file_resuable_snackbar.dart';
import 'package:ihl/views/teleconsultation/files/pdf_viewer.dart';
import 'package:ihl/views/teleconsultation/videocall/genix_lab_order_pdf.dart' as lab;
import 'package:ihl/views/teleconsultation/videocall/genix_lab_order_pdf.dart';
import 'package:ihl/views/teleconsultation/videocall/genix_prescription.dart';
import 'package:ihl/views/teleconsultation/view_bill.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:ihl/widgets/policyDialog.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:strings/strings.dart';

import '../models/invoice.dart';

class ConsultSummaryPage extends StatefulWidget {
  final Map consultationNotes;
  final consultantName;
  final speciality;
  final appointmentStartTime;
  final appointmentEndTime;
  final appointmentStatus;
  final callStatus;
  final consultationFees;
  final modeOfPayment;
  final appointmentModel;
  final reasonOfVisit;

  final allergy;
  var provider;

  ConsultSummaryPage(
      {Key key,
      this.consultationNotes,
      this.consultantName,
      this.speciality,
      this.appointmentStartTime,
      this.appointmentEndTime,
      this.appointmentStatus,
      this.callStatus,
      this.consultationFees,
      this.modeOfPayment,
      this.appointmentModel,
      this.reasonOfVisit,
      this.allergy,
      this.provider})
      : super(key: key);

  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<ConsultSummaryPage> {
  String _imageBase64 =
      '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';

  http.Client _client = http.Client(); //3gb
  bool hasDetails = false;
  bool loading = true;
  String docId;
  String appointId;
  String iHLUserId;
  var consultantName;
  var consultantId;
  var vendorName;
  String affiliation_unique_name;
  var vendorConId;
  Map consultationDetails;
  double _rating = 0.0;
  var _prescriptionNotes;
  bool submitting = false;
  final reviewTextController = TextEditingController();
  var prescription, allergy, _allergies;
  Invoice invoice;
  var labTestList;
  var consultantMobile;
  var consultantEmail;
  var notes;
  var labNotes;
  var appointmentStatus;
  var callStatus;
  var ihlConsultantId;
  var isAgree = false;
  var rmpid;
  var consultantAddress;
  var accountId;
  var logoUrl;
  var consultantSignature;
  var base64Signature;
  var genixRadiology;
  var genixDiagnosis;
  var kisokCheckinHistory;
  var footerDetail;

  var consultantEducation;
  var consultantDescription;
  var adviceNotes;
  var appointStartTime;
  var speciality;

  var consultantNameFromStages;
  var specialityFromStages;
  var appointmentStartTimeFromStages;
  var appointmentEndTimeFromStages;
  var appointmentStatusFromStages;
  var callStatusFromStages;
  var consultationFeesFromStages;
  var modeOfPaymentFromStages;
  var appointmentModelFromStages;
  var reasonOfVisitFromStages;
  var allergyFromStages;
  var ihlConsultantIDFromStages;
  var vendorConsultatationIDFromStages;
  var vendorNameFromStages;
  var dummy = [
    {
      "drug_name": "Dolo 650",
      "quantity": "2",
      "SIG": "1-1-2-2",
      "days": "3",
      "direction_of_use": "AfterFood"
    },
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userData);
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

    gender = res['User']['gender'];
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
      var raw = prefs.get(SPKeys.userData);
      if (raw == '' || raw == null) {
        raw = '{}';
      }
      Map data = jsonDecode(raw);

      Map user = data['User'];
      if (user == null) {
        user = {};
      }

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

  sha256_hash(data) {
    List<int> bytes = utf8.encode(data);
    String hash = sha256.convert(bytes).toString();
    print(hash);
    return hash;
  }

  sendPrescriptionTo1MG() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Get.snackbar(
      'Sending Prescription',
      'Please wait',
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      backgroundColor: AppColors.primaryAccentColor,
      colorText: Colors.white,
      duration: Duration(seconds: 10),
    );
    prefs.setString("useraddressFromHistory", address);
    prefs.setString("userareaFromHistory", area);
    prefs.setString("usercityFromHistory", city);
    prefs.setString("userstateFromHistory", state);
    prefs.setString("userpincodeFromHistory", pincode);
    // ignore: non_constant_identifier_names
    var prescription_base64 = await genixPrescription(
        context: context,
        showPdfNotification: false,
        prescription: prescription,
        prescriptionNotes: _prescriptionNotes,
        mobilenummber: mobileNumber,
        footer: footerDetail,
        allergy: allergy,
        specality: speciality,
        appointmentId: appointId,
        bmi: bmi,
        weight: weight,
        allergies: _allergies,
        rmpid: rmpid,
        notes: notes,
        consultantSignature: consultantSignature,
        genixDaignosis: genixDiagnosis,
        genixRadiology: genixRadiology,
        kisokCheckinHistory: kisokCheckinHistory,
        genixLabTest: labTestList,
        genixLabNotes: labNotes,
        consultantAddress: consultantAddress,
        logoUrl: Image.memory(base64Decode(_imageBase64)));
    String salt = "f1nd1ngn3m0";
    // String data_to_find_hash = 'thamarais16@gmail.com' + '9894599498' + salt;
    String dataToFindHash = '$email' + '$mobileNumber' + salt;
    String calculatedHash = sha256_hash(dataToFindHash);

    // var jsontext ='{"first_name":"Thamarai","last_name":"Selvan","email":"thamarais16@gmail.com","mobile":"9894599498","prescription_number":"IHL-21-22/0000000001","prescription_base64":"eyJkcnVnX25hbWUiOiJQYXJhY2V0YW1vbCAyNTBtZy81bWwgU3lydXAiLCJkb3NhZ2UiOjEyLCJ1bml0cyI6Ik1MIiwic3RyZW5ndGgiOiIyNTBtZy81bWwiLCJmcmVxdWVuY3kiOiJPbmNlIGluIHRoZSB3ZWVrIiwid2hlblRvVGFrZSI6Ik4vQSIsIm5vdGVzIjoiIiwic3RhcnREYXRlIjoxNjA1NDY1MDAwLCJlbmREYXRlIjoxNjA1NTUxMzk5fQ==","security_hash":"5f51981aaf6539d3adfac598c9edde9bdd02bcbfcc47ed813a65dc7e12058948"}';
    var jsontext =
        '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$prescription_base64","security_hash":"$calculatedHash","affiliation_unique_name":"$affiliation_unique_name",' // the
        '"order_type":"medication"}';
    // '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$prescription_base64","security_hash":"$calculatedHash"}';
    print(prescription_base64);
    print('api yet to be called');
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/login/sendPrescription"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsontext,
    );
    print('api called===================================>>>');
    print(prescription_base64);
    print(jsontext);
    if (response.statusCode == 200) {
      print(response.body);
      Get.close(1);
      print(response.body);
      Get.snackbar(
        'Prescription Sent!',
        'You will get Confirmation call before your medicine is dispatched',
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        mainButton: TextButton(
            child: Text(
              'Close',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Get.close(1)),
        duration: Duration(seconds: 10),
      );
    } else {
      Get.close(1);
      print(response.body);
      Get.snackbar(
        'Prescription not sent!',
        'Some error occured while sending. Try again!',
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        mainButton: TextButton(
            child: Text(
              'Close',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Get.close(1)),
        duration: Duration(seconds: 10),
      );
    }
  }

  sendLabTestTo1MG() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Get.snackbar(
      'Sending LabTests',
      'Please wait',
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      backgroundColor: AppColors.primaryAccentColor,
      colorText: Colors.white,
      duration: Duration(seconds: 10),
    );
    prefs.setString("useraddressFromHistory", address);
    prefs.setString("userareaFromHistory", area);
    prefs.setString("usercityFromHistory", city);
    prefs.setString("userstateFromHistory", state);
    prefs.setString("userpincodeFromHistory", pincode);
    // ignore: non_constant_identifier_names
    var labTest_base64 = await lab.genixLabOrder(
        context, false, labTestList, bmi, weight, rmpid, labNotes, consultantSignature);
    String salt = "f1nd1ngn3m0";
    // String data_to_find_hash = 'thamarais16@gmail.com' + '9894599498' + salt;
    String dataToFindHash = '$email' + '$mobileNumber' + salt;
    String calculatedHash = sha256_hash(dataToFindHash);

    // var jsontext ='{"first_name":"Thamarai","last_name":"Selvan","email":"thamarais16@gmail.com","mobile":"9894599498","prescription_number":"IHL-21-22/0000000001","prescription_base64":"eyJkcnVnX25hbWUiOiJQYXJhY2V0YW1vbCAyNTBtZy81bWwgU3lydXAiLCJkb3NhZ2UiOjEyLCJ1bml0cyI6Ik1MIiwic3RyZW5ndGgiOiIyNTBtZy81bWwiLCJmcmVxdWVuY3kiOiJPbmNlIGluIHRoZSB3ZWVrIiwid2hlblRvVGFrZSI6Ik4vQSIsIm5vdGVzIjoiIiwic3RhcnREYXRlIjoxNjA1NDY1MDAwLCJlbmREYXRlIjoxNjA1NTUxMzk5fQ==","security_hash":"5f51981aaf6539d3adfac598c9edde9bdd02bcbfcc47ed813a65dc7e12058948"}';
    var jsontext =
        '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$labTest_base64","security_hash":"$calculatedHash","affiliation_unique_name":"$affiliation_unique_name",' // the
        '"order_type":"lab"}';
    // '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$labTest_base64","security_hash":"$calculatedHash"}';
    print(labTest_base64);
    print('api yet to be called');
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/login/sendPrescription"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsontext,
    );
    print('api called===================================>>>');
    print(labTest_base64);
    print(jsontext);
    if (response.statusCode == 200) {
      print(response.body);
      Get.close(1);
      print(response.body);
      Get.snackbar(
        'LabTests Sent!',
        'You will get Confirmation call',
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        mainButton: TextButton(
            child: Text(
              'Close',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Get.close(1)),
        duration: Duration(seconds: 10),
      );
    } else {
      Get.close(1);
      print(response.body);
      Get.snackbar(
        'LabTests not sent!',
        'Some error occured while sending. Try again!',
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        mainButton: TextButton(
            child: Text(
              'Close',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Get.close(1)),
        duration: Duration(seconds: 10),
      );
    }
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(value),
      backgroundColor: Colors.blue,
    ));
  }

  Future insertTelemedReview(String textReview, double ratingValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    var apiToken = prefs.get('auth_token');
    Map res = jsonDecode(data);
    iHLUserId = res['User']['id'];
    print('"provider": "${widget.provider}"');
    var provi_der = widget.provider ?? prefs.getString("provider_FromStages");
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/insert_telemed_reviews_new'),
      // Uri.parse(API.iHLUrl + '/consult/insert_telemed_reviews'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      // headers: {'ApiToken': apiToken},
      //   request.body = json.encode({
      //     "user_ihl_id": "6JnHkzHO8UaHCRfpykp7Cg",
      //     "consultant_name": "doctorihl",
      //     "ihl_consultants_id": "747b2be230a94d408157a95c66a38666",
      //     "vendor_consultatation_id": "747b2be230a94d408157a95c66a38666",
      //     "ratings": "5",
      //     "review_text": "This doctor is good doctor",
      //     "vendor_name": "GENIX",
      //     "provider": "genix",
      //     "appointment_id": "sbfsbfsb"
      //   });
      body: jsonEncode(<String, dynamic>{
        "user_ihl_id": iHLUserId.toString(),
        "consultant_name": consultantNameFromStages.toString(),
        "ihl_consultants_id": ihlConsultantIDFromStages.toString(),
        "vendor_consultatation_id": vendorConsultatationIDFromStages.toString(),
        "ratings": ratingValue.toInt(),
        "review_text": textReview.toString().replaceAll('"', 'š'),
        "vendor_name": vendorNameFromStages.toString(),
        "provider": provi_der ?? "${widget.provider}",
        "appointment_id": "$appointId"
      }),
    );
    if (response.statusCode == 200) {
      print(response.body);
      if (this.mounted) {
        setState(() {
          submitting = false;
        });
      }
      Fluttertoast.showToast(
          msg: "Your review is appreciated. Thank you!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pop(context);
    } else {
      print('See the failure response in next line');
      Fluttertoast.showToast(
          msg: "Reviewing failed!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pop(context);
    }
  }

  getDataFromConsultationStages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    consultantNameFromStages = prefs.getString("consultantNameFromStages");
    specialityFromStages = prefs.getString("specialityFromStages");
    appointmentStartTimeFromStages = prefs.getString("appointmentStartTimeFromStages");
    appointmentEndTimeFromStages = prefs.getString("appointmentEndTimeFromStages");
    appointmentStatusFromStages = prefs.getString("appointmentStatusFromStages");
    callStatusFromStages = prefs.getString("callStatusFromStages");
    consultationFeesFromStages = prefs.getString("consultationFeesFromStages");
    modeOfPaymentFromStages = prefs.getString("modeOfPaymentFromStages");
    appointmentModelFromStages = prefs.getString("appointmentModelFromStages");
    reasonOfVisitFromStages = prefs.getString("reasonOfVisitFromStages");
    allergyFromStages = prefs.getString("allergyFromStages");

    ihlConsultantIDFromStages = prefs.getString("ihlConsultantIDFromStages");
    vendorConsultatationIDFromStages = prefs.getString("vendorConsultatationIDFromStages");
    vendorNameFromStages = prefs.getString("vendorNameFromStages");
    widget.provider = widget.provider ?? prefs.getString("provider_FromStages");
  }

  Future<Map> appointmentDetails(String appointmentID) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var authToken = prefs.get('auth_token');
      var userData = prefs.get('data');
      var decodedResponse = jsonDecode(userData);
      String iHLUserToken = decodedResponse['Token'];
      final response = await _client.get(
          Uri.parse(API.iHLUrl +
              '/consult/get_appointment_details?appointment_id=' + //'e36dfa358eef49889d6ac8bcd97bfce5',
              // 'fbd28d000b1d44eba4205bff05f857a9',
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
                  var descriptionEndIndex =
                      parsedd12.indexOf(descriptionEnd, descriptionLastEndIndex);
                  // descriptionLastEndIndex = descriptionEndIndex + descriptionEnd.length;
                  String des = parsedd12.substring(descriptionStartIndex + descriptionStart.length,
                      descriptionEndIndex != -1 ? descriptionEndIndex : parsedd12.length);
                  temp1 = parsedd12.substring(0, descriptionStartIndex);
                  temp2 = parsedd12.substring(
                      descriptionEndIndex != -1 ? descriptionEndIndex : parsedd12.length,
                      parsedd12.length);
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
              var directionOfUseEndIndex =
                  value.indexOf(directionOfUseEnd, directionOfUseLastEndIndex);
              directionOfUseLastEndIndex = directionOfUseEndIndex + directionOfUseEnd.length;
              String prescrpton = value.substring(
                  directionOfUseStartIndex + directionOfUseStart.length, directionOfUseEndIndex);
              var dirOfUseList = [];
              var drugNameList = [];
              for (int i = 0; i < prescrpton.length; i++) {
                if (prescrpton.contains("direction_of_use")) {
                  var dirOfUseStart = ";direction_of_use";
                  var dirOfUseEnd = ";SIG";
                  var dirOfUseStartIndex = prescrpton.indexOf(dirOfUseStart);
                  var dirOfUseEndIndex = prescrpton.indexOf(dirOfUseEnd, dirOfUseLastEndIndex);
                  dirOfUseLastEndIndex = dirOfUseEndIndex + dirOfUseEnd.length;
                  String e = prescrpton.substring(
                      dirOfUseStartIndex + dirOfUseStart.length, dirOfUseEndIndex);

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
                  String f = prescrpton.substring(
                      drugNameStartIndex + drugNameStart.length, drugNameEndIndex);

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
                  i = prescrpton.length;
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
            if (reasonForVisit[i]['direction_of_use'] != null &&
                reasonForVisit[i]['direction_of_use'].length > 0) {
              for (int j = 0; j < reasonForVisit[i]['direction_of_use'].length; j++) {
                details['message']['prescription'][j]['direction_of_use'] =
                    reasonForVisit[i]['direction_of_use'][j];
              }
            }
            if (reasonForVisit[i]['drug_name'] != null &&
                reasonForVisit[i]['drug_name'].length > 0) {
              for (int j = 0; j < reasonForVisit[i]['drug_name'].length; j++) {
                details['message']['prescription'][j]['drug_name'] =
                    reasonForVisit[i]['drug_name'][j];
              }
            }
          }
          if (this.mounted) {
            consultationDetails = details;
            hasDetails = true;
            loading = false;
            _allergies = consultationDetails["message"]["alergy_genix"] ?? 0;

            _prescriptionNotes = consultationDetails["message"]["prescription"] != null &&
                    consultationDetails["message"]["prescription"].length > 0
                ? consultationDetails["message"]["prescription"][0]["med_note"] ?? 'N/A'
                : 'N/A';
            consultantEmail =
                consultationDetails["consultant_details"]["consultant_email"].toString() ?? "N/A";
            consultantMobile =
                consultationDetails["consultant_details"]["consultant_mobile"].toString() ?? "N/A";
            consultantEducation =
                consultationDetails["consultant_details"]["education"].toString() ?? "N/A";
            consultantDescription =
                consultationDetails["consultant_details"]["description"].toString() ?? "N/A";
            adviceNotes = consultationDetails["message"]["consultation_advice_notes"] != null
                ? consultationDetails["message"]["consultation_advice_notes"].toString() ?? "N/A"
                : "N/A";
            affiliation_unique_name =
                consultationDetails['message']['affiliation_unique_name'] ?? "global_services";
            prescription = consultationDetails["message"]["prescription"] ?? "N/A";
            genixRadiology = consultationDetails["message"]["radiology"] ?? "N/A"; //radiology
            allergy = consultationDetails["message"]["alergy"].toString() ?? "N/A";
            genixDiagnosis = consultationDetails["message"]["patient_diagnosis"] ?? "N/A";

            ///kisok
            kisokCheckinHistory =
                consultationDetails["message"]["kiosk_checkin_history"].toString() != "null" &&
                        consultationDetails["message"]["kiosk_checkin_history"].length > 0
                    ? kisokDataManipulation(consultationDetails["message"]["kiosk_checkin_history"])
                    : 'N/A';
            // kisokCheckinHistory = consultationDetails["message"]["kiosk_checkin_history"] ?? "N/A";

            appointStartTime =
                consultationDetails["message"]["appointment_start_time"].toString() ?? "N/A";

            speciality = consultationDetails["message"]["specality"].toString() ?? "N/A";
            labTestList = consultationDetails["message"]["lab_tests"] ?? [];
            if (labTestList.length > 0) {
              for (int i = 0; i < labTestList.length; i++) {
                print(labTestList[i]['lab_note']);
                if (labTestList[i]['lab_note'] != null && labTestList[i]['lab_note'] != '') {
                  labNotes = labTestList[i]['lab_note'].toString();
                }
              }
            }
            notes = consultationDetails["message"]["notes"] ?? ["N/A"];
            // consultantFee= consultationDetails['message']['consultation_fees'].toString()?? 'N/A';
            callStatus = consultationDetails["message"]["call_status"] != null
                ? consultationDetails["message"]["call_status"].toString()
                : "N/A" ?? "N/A";
            appointmentStatus =
                camelize(consultationDetails["message"]["appointment_status"].toString()) ?? "N/A";
            ihlConsultantId = consultationDetails["message"]["ihl_consultant_id"] ?? 'N/A';
            // consultationDetails['consultant_details']['vendor_name'] ==
            //         'GENIX'
            //     ? getSignature()
            //     : null;
            ///it is in getPlatformData() fun
            consultationDetails['consultant_details']['vendor_name'] == 'GENIX'
                ? getPlatformData()
                : '';
            if (mounted) setState(() {});
          }
          getItem(consultationDetails);
        } else {
          consultationDetails = {};
        }
      }
      return consultationDetails;
    } catch (e) {
      print('get appointment failed.........');
    }
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
        allergy: map["message"]["alergy"].toString() ?? "N/A",
        reasonOfVisit: map["message"]["reason_for_visit"].toString() ?? "N/A",
        provider: map["consultant_details"]["provider"].toString() ?? "N/A");
  }

  ///for download option in files that now removed
  // int progress = 0;
  //
  //
  // ReceivePort _receivePort = ReceivePort();
  //
  // static downloadingCallback(id, status, progress) {
  //   ///Looking up for a send port
  //   SendPort sendPort = IsolateNameServer.lookupPortByName("downloading");
  //
  //   ///ssending the data
  //   sendPort.send([id, status, progress]);
  // }
  @override
  void initState() {
    getDataFromConsultationStages();
    getUserDetails();
    getAppointId();

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => new AlertDialog(content: showReviewDialog()),
      );
    });

    ///written for download option of med files
    // ///register a send port for the other isolates
    // IsolateNameServer.registerPortWithName(_receivePort.sendPort, "downloading");
    // ///Listening for the data is comming other isolataes
    // _receivePort.listen((message) {
    //   if(this.mounted){setState(() {
    //     progress = message[2];
    //   });}
    //   print(progress);
    // });
    // FlutterDownloader.registerCallback(downloadingCallback);
  }

  var dummmyMedFiles = ["c955961253774b74adf0574d0b04aa4d", "f3263f06acb74362b6949553cee0589d"];
  var medFiles = [];

  Future getLogoUrl(accId) async {
    final logoUrlResponse = await http.get(
      Uri.parse(API.iHLUrl + "/consult/get_logo_url?accountId=$accId"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    try {
      if (accId == '499935c5-01a7-4b39-b7e2-bf08b5e787eb') {
        footerDetail = {
          'Description': 'Please note the Emergency Helpline Numbers of Dr Mehta\'s Hospital',
          'line1': 'Chennai: Chetpet Unit: 044-40054005',
          'line2': 'Global Campus @ Velappanchavadi : 044-40474047'
        };
      } else {
        footerDetail = null;
      }
      if (logoUrlResponse.statusCode == 200) {
        var res = jsonDecode(logoUrlResponse.body);
        // logoUrl = res.toString();
        res == 'https://indiahealthlink.com/affiliate_logo/ihl-plus.png'
            ? 'https://dashboard.indiahealthlink.com/affiliate_logo/ihl-plus.png'
            : res;
        return res;
      } else {
        return '';
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future getLogoForPrescriptionPDF(accId) async {
    final logoUrlResponse = await _client.get(
      // Uri.parse(API.iHLUrl + "/consult/get_logo_url?accountId=$accId"),
      Uri.parse(API.iHLUrl + "/consult/genixAccountLogoFetch?accountid=$accId"),
    );
    try {
      if (accId == '499935c5-01a7-4b39-b7e2-bf08b5e787eb') {
        footerDetail = {
          'Description': 'Please note the Emergency Helpline Numbers of Dr Mehta\'s Hospital',
          'line1': 'Chennai: Chetpet Unit: 044-40054005',
          'line2': 'Global Campus @ Velappanchavadi : 044-40474047'
        };
      } else {
        footerDetail = null;
      }
      if (logoUrlResponse.statusCode == 200) {
        var res = jsonDecode(logoUrlResponse.body);
        // logoUrl = res.toString();
        var r = res['logo_list'][0];
        String _base64Image = r.replaceAll('data:image/jpeg;base64,', '');
        _base64Image = _base64Image.replaceAll('}', '');
        _base64Image = _base64Image.replaceAll('data:image/jpegbase64,', '');
        return _base64Image;
      } else {
        return '';
      }
    } catch (e) {
      print(e.toString());
      return '';
    }
  }

  // Future getLogoUrl(accId) async {
  //   final logoUrlResponse = await http.get(
  //     Uri.parse(API.iHLUrl + "/consult/get_logo_url?accountId=$accId"),
  //   );
  //   try{
  //     if (logoUrlResponse.statusCode == 200) {
  //       Map res = jsonDecode(logoUrlResponse.body);
  //       // logoUrl = res.toString();
  //       return res;
  //     }
  //     else{
  //       return '';
  //     }
  //   }
  //   catch(e){
  //     print(e.toString());
  //   }
  // }

  Future getPlatformData() async {
    final getPlatformData = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/GetPlatfromData"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, bool>{'cache': false}),
    );

    if (getPlatformData.statusCode == 200) {
      Map res = jsonDecode(getPlatformData.body);
      if (res['consult_type'] == null ||
          !(res['consult_type'] is List) ||
          res['consult_type'].isEmpty) {
        return;
      }
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      String type;
      if (vendorName == 'GENIX') {
        type = "Medical Consultation";
      } else {
        type = "Health Consultation";
      }
      var consultType =
          res['consult_type'].where((i) => i["consultation_type_name"] == type).toList();
      var spclty =
          consultType[0]["specality"].where((i) => i["specality_name"] == speciality).toList();
      var consultant = spclty[0]['consultant_list']
          .where((i) => i['ihl_consultant_id'] == ihlConsultantId)
          .toList();
      rmpid = consultant[0]['RMP_ID'];
      accountId = consultant[0]['account_id'];
      consultantAddress = consultant[0]['consultant_address'];
      logoUrl = await getLogoUrl(accountId);
      _imageBase64 = await getLogoForPrescriptionPDF(accountId);
      print('rmpId == $rmpid');

      ///get the signature of genix doc
      consultationDetails['consultant_details']['vendor_name'] == 'GENIX'
          ? await getSignature()
          : null;

      ///send lab and prescription to user
      if (consultationDetails["message"]["prescription"] != null) {
        sendPrescriptionToUser();
      }
    } else {
      print(getPlatformData.body);
    }
    //   final platformData = await SharedPreferences.getInstance();
    //  var getPlatformBody = await platformData.getString(SPKeys.platformData,);
  }

  Future getSignature() async {
    final signatureResponse = await _client.get(
      Uri.parse(API.iHLUrl + '/consult/getGenixDoctorSign?ihl_consultant_id=' + ihlConsultantId),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      // '355b25949ed8405dba88c07e9705082a'
    );

    if (signatureResponse.statusCode == 200) {
      base64Signature = signatureResponse.body;

      base64Signature = base64Signature.replaceAll('&quot;', '');
      base64Signature = base64Signature.replaceAll('{ContentType:image/png,Content:', '');
      base64Signature = base64Signature.replaceAll('{ContentType:image/jpeg,Content:', '');
      base64Signature = base64Signature.replaceAll('}', '');
      base64Signature = base64Signature.replaceAll('"', '');
      if (base64Signature.contains('error')) {
      } else {
        consultantSignature = Image.memory(base64Decode(base64Signature));
      }
      //getPlatformData();
    } else {
      print('signatureAPI else part => ${signatureResponse.body}');
    }
  }

  getAppointId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    consultantName = prefs.get('consultantName');
    consultantId = prefs.get('consultantId');
    vendorName = prefs.get('vendorName');
    vendorConId = prefs.get('vendorConId');
    appointId = prefs.getString('appointmentIdFromConsultationStages');
    appointId = appointId.replaceAll("ihl_consultant_", "");
    appointId = appointId.replaceAll("IHLTeleConsult", "");
    invoice = await ConsultApi().getInvoiceNumber(ihlUserId, appointId);
    print(invoiceNumber);
    // SharedPreferences pref = await SharedPreferences.getInstance();
    invoiceNumber = prefs.getString('invoice');
    print(invoiceNumber.toString());
    appointmentDetails(appointId);
    //we call the files view api with documentid and
    medFiles = await MedicalFilesApi.getFilesSummary(consultantId, appID: appointId);
    setState(() {
      medFiles;
    });
  }

  kisokDataManipulation(kisokData) {
    var LastCheckinList = [];
    var type;
    var value;
    var status;
    var unit;
    //weight
    if (kisokData['weightKG'] != null) {
      type = 'Weight';
      value = kisokData['weightKG'].toStringAsFixed(2); //.toStringAsFixed(2);
      status = 'N/A'; //ASK
      unit = 'Kg';
      LastCheckinList.add(
          {'type': '$type', 'value': '$value', 'status': '$status', 'unit': '$unit'});
    }
    //bmi
    if (kisokData['bmi'] != null) {
      type = 'BMI';
      value = kisokData['bmi']
          .toStringAsFixed(2); //(double.parse(kisokData['bmi'])).toStringAsFixed(2);
      status = kisokData['bmiClass'];
      unit = 'N/A'; //CHECK
      LastCheckinList.add(
          {'type': '$type', 'value': '$value', 'status': '$status', 'unit': '$unit'});
    }
    //blood pressure
    if (kisokData['diastolic'] != null && kisokData['systolic'] != null) {
      type = 'Blood Pressure';
      value = kisokData['systolic'].toString() + '/' + kisokData['diastolic'].toString();
      status = kisokData['bpClass'] ?? 'N/A';
      unit = 'mmHg'; //CHECK
      LastCheckinList.add(
          {'type': '$type', 'value': '$value', 'status': '$status', 'unit': '$unit'});
    }
    //bmc
    if (kisokData['percent_body_fat'] != null) {
      type = 'Body Mass Composition';
      value = kisokData['percent_body_fat'];
      status = kisokData['fatClass'] ?? 'N/A';
      unit = '%'; //CHECK
      LastCheckinList.add(
          {'type': '$type', 'value': '$value', 'status': '$status', 'unit': '$unit'});
    }
    //ECG
    if (kisokData['ecgBpm'] != null) {
      type = 'ECG';
      value = kisokData['ecgBpm'];
      status = kisokData['leadTwoStatus'] ?? 'N/A';
      unit = 'N/A'; //CHECK
      LastCheckinList.add(
          {'type': '$type', 'value': '$value', 'status': '$status', 'unit': '$unit'});
    }
    //SPO2
    if (kisokData['spo2'] != null) {
      type = 'SPO2';
      value = kisokData['spo2'];
      status = kisokData['spo2Class'] ?? 'N/A';
      unit = '%'; //CHECK
      LastCheckinList.add(
          {'type': '$type', 'value': '$value', 'status': '$status', 'unit': '$unit'});
    }
    //temprature
    if (kisokData['temperature'] != null) {
      type = 'Temperature';
      value = kisokData['temperature'];
      status = kisokData['temperatureClass'] ?? 'N/A';
      unit = ' F'; //CHECK
      LastCheckinList.add(
          {'type': '$type', 'value': '$value', 'status': '$status', 'unit': '$unit'});
    }
    //Test Time
    if (kisokData['dateTime'] != null) {
      type = 'Test Time';
      value = kisokData['dateTime'].toString().substring(0, 10);
      status = 'N/A';
      unit = 'N/A'; //CHECK
      LastCheckinList.add(
          {'type': '$type', 'value': '$value', 'status': '$status', 'unit': '$unit'});
    }

    ///calling the user
    return LastCheckinList;
  }

  sendPrescriptionToUser() async {
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
      await Permission.mediaLibrary.status;
      permissionGrandted = true;
    }
    if (permissionGrandted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("consultantNameFromHistorySummary", consultantName);
      prefs.setString("consultantEmailFromHistorySummary", consultantEmail);
      prefs.setString("consultantMobileFromHistorySummary", consultantMobile);
      prefs.setString("consultantEducationFromHistorySummary", consultantEducation);
      prefs.setString("consultantDescriptionFromHistorySummary", consultantDescription);

      prefs.setString("appointmentStartTimeFromHistorySummary", appointStartTime
          // appointmentStartTimeFromStages
          );
      prefs.setString("reasonForVisitFromHistorySummary", reasonOfVisitFromStages);
      prefs.setString("diagnosisFromHistorySummary", diagnosislab ?? '');
      prefs.setString("adviceFromHistorySummary", adviceNotes);
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

      // Get.snackbar(
      //   '',
      //   'Instructions will be saved in your mobile!',
      //   backgroundColor: AppColors.primaryAccentColor,
      //   colorText: Colors.white,
      //   duration: Duration(seconds: 5),
      //   isDismissible: false,
      // );
      new Future.delayed(new Duration(seconds: 2), () {
        // lab.genixLabOrder(
        //     context,
        //     true,
        //     labTestList,
        //     bmi,
        //     weight,
        //     rmpid,
        //     labNotes,
        //     consultantSignature);
      });
    } else {
      Get.snackbar(
        'Storage Access Denied',
        'Allow Storage permission to continue',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        isDismissible: false,
        mainButton: TextButton(
          onPressed: () async {
            await openAppSettings();
          },
          child: Text('Allow'),
        ),
      );
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("useraddressFromHistory", address);
    prefs.setString("userareaFromHistory", area);
    prefs.setString("usercityFromHistory", city);
    prefs.setString("userstateFromHistory", state);
    prefs.setString("userpincodeFromHistory", pincode);
    // ignore: non_constant_identifier_names
    var prescription_base64 = await genixPrescription(
        appointmentId: appointId,
        allergies: _allergies,
        prescriptionNotes: _prescriptionNotes,
        footer: footerDetail,
        mobilenummber: mobileNumber,
        specality: speciality,
        context: context,
        showPdfNotification: false,
        prescription: prescription,
        bmi: bmi,
        weight: weight,
        rmpid: rmpid,
        notes: notes,
        consultantSignature: consultantSignature,
        genixDaignosis: genixDiagnosis,
        genixRadiology: genixRadiology,
        kisokCheckinHistory: kisokCheckinHistory,
        genixLabTest: labTestList,
        allergy: allergyFromStages,
        genixLabNotes: labNotes,
        consultantAddress: consultantAddress,
        logoUrl: Image.memory(base64Decode(_imageBase64)));
    String salt = "f1nd1ngn3m0";
    // String data_to_find_hash = 'thamarais16@gmail.com' + '9894599498' + salt;
    String dataToFindHash = '$email' + '$mobileNumber' + salt;
    String calculatedHash = sha256_hash(dataToFindHash);

    // var jsontext ='{"first_name":"Thamarai","last_name":"Selvan","email":"thamarais16@gmail.com","mobile":"9894599498","prescription_number":"IHL-21-22/0000000001","prescription_base64":"eyJkcnVnX25hbWUiOiJQYXJhY2V0YW1vbCAyNTBtZy81bWwgU3lydXAiLCJkb3NhZ2UiOjEyLCJ1bml0cyI6Ik1MIiwic3RyZW5ndGgiOiIyNTBtZy81bWwiLCJmcmVxdWVuY3kiOiJPbmNlIGluIHRoZSB3ZWVrIiwid2hlblRvVGFrZSI6Ik4vQSIsIm5vdGVzIjoiIiwic3RhcnREYXRlIjoxNjA1NDY1MDAwLCJlbmREYXRlIjoxNjA1NTUxMzk5fQ==","security_hash":"5f51981aaf6539d3adfac598c9edde9bdd02bcbfcc47ed813a65dc7e12058948"}';
    var jsontext =
        '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$prescription_base64","security_hash":"$calculatedHash","affiliation_unique_name":"$affiliation_unique_name",' // the
        '"order_type":"user"}';
    // '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$prescription_base64","security_hash":"$calculatedHash"}';
    print(prescription_base64);
    print('api yet to be called');
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/login/sendPrescription"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsontext,
    );
    print('api called===================================>>>');
    print(prescription_base64);
    print(jsontext);
    if (response.statusCode == 200) {
      print(response.body);
      // Get.close(1);
      // sendInvoiceToUser();

      ///prescription sent to user
    } else {
      // Get.close(1);
      print(response.body);
      // sendInvoiceToUser();

      ///prescription not sent
    }

    /// SHARE LAB TEST TO USER

    // ignore: non_constant_identifier_names
    // var labTest_base64 = await lab.genixLabOrder(context, false, labTestList,
    //     bmi, weight, rmpid, labNotes, consultantSignature);
    // String salt = "f1nd1ngn3m0";
    // String data_to_find_hash = 'thamarais16@gmail.com' + '9894599498' + salt;
    // String dataToFindHash = '$email' + '$mobileNumber' + salt;
    // String calculatedHash = sha256_hash(dataToFindHash);

    // var jsontext ='{"first_name":"Thamarai","last_name":"Selvan","email":"thamarais16@gmail.com","mobile":"9894599498","prescription_number":"IHL-21-22/0000000001","prescription_base64":"eyJkcnVnX25hbWUiOiJQYXJhY2V0YW1vbCAyNTBtZy81bWwgU3lydXAiLCJkb3NhZ2UiOjEyLCJ1bml0cyI6Ik1MIiwic3RyZW5ndGgiOiIyNTBtZy81bWwiLCJmcmVxdWVuY3kiOiJPbmNlIGluIHRoZSB3ZWVrIiwid2hlblRvVGFrZSI6Ik4vQSIsIm5vdGVzIjoiIiwic3RhcnREYXRlIjoxNjA1NDY1MDAwLCJlbmREYXRlIjoxNjA1NTUxMzk5fQ==","security_hash":"5f51981aaf6539d3adfac598c9edde9bdd02bcbfcc47ed813a65dc7e12058948"}';
    // var jsontextLab =
    //     '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$labTest_base64","security_hash":"$calculatedHash","affiliation_unique_name":"$affiliation_unique_name",' // the
    //     '"order_type":"user"}';
    // '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$labTest_base64","security_hash":"$calculatedHash"}';
    // print(labTest_base64);
    // print('api yet to be called');
    // final lab_response = await http.post(
    //   Uri.parse(API.iHLUrl + "/login/sendPrescription"),
    //   body: jsontextLab,
    // );
    // print('api called===================================>>>');
    // print(labTest_base64);
    // print(jsontextLab);
    // if (lab_response.statusCode == 200) {
    //   print(lab_response.body);
    //   Get.close(1);
    //  ///lab test share to user
    // } else {
    //   ///lab test not share to user
    //   Get.close(1);
    // }
  }

  // sendInvoiceToUser() async {
  //   // AwesomeNotifications()
  //   //     .cancelAll();
  //   var invoiceBase64;
  //   final status =
  //   await Permission
  //       .storage
  //       .request();
  //   if (status
  //       .isGranted) {
  //     SharedPreferences
  //     prefs =
  //     await SharedPreferences
  //         .getInstance();
  //     prefs.setString(
  //         "useraddressFromHistory",
  //         address);
  //     prefs.setString(
  //         "userareaFromHistory",
  //         area);
  //     prefs.setString(
  //         "usercityFromHistory",
  //         city);
  //     prefs.setString(
  //         "userstateFromHistory",
  //         state);
  //     prefs.setString(
  //         "userpincodeFromHistory",
  //         pincode);
  //     // Get.snackbar(
  //     //   '',
  //     //   'Invoice will be saved in your mobile!',
  //     //   backgroundColor:
  //     //   AppColors
  //     //       .primaryAccentColor,
  //     //   colorText:
  //     //   Colors.white,
  //     //   duration:
  //     //   Duration(
  //     //       seconds:
  //     //       5),
  //     //   isDismissible:
  //     //   false,
  //     // );
  //     // new Future.delayed(
  //     //     new Duration(
  //     //         seconds: 2),
  //     //         () async {
  //
  //     invoiceBase64 =   await reportView(
  //               context,
  //               invoiceNumber,
  //               false);
  //
  //         // });
  //   } else if (status
  //       .isDenied) {
  //     await Permission
  //         .storage
  //         .request();
  //     Get.snackbar(
  //         'Storage Access Denied',
  //         'Allow Storage permission to continue',
  //         backgroundColor:
  //         Colors.red,
  //         colorText:
  //         Colors
  //             .white,
  //         duration:
  //         Duration(
  //             seconds:
  //             5),
  //         isDismissible:
  //         false,
  //         mainButton: TextButton(
  //           //TextButton(
  //           // style: TextButton
  //           //     .styleFrom(
  //           //   primary:
  //           //       Colors.white,
  //           // ),
  //             onPressed: () async {
  //               await openAppSettings();
  //             },
  //             child: Text('Allow')));
  //   } else {
  //     Get.snackbar(
  //         'Storage Access Denied',
  //         'Allow Storage permission to continue',
  //         backgroundColor:
  //         Colors.red,
  //         colorText:
  //         Colors
  //             .white,
  //         duration:
  //         Duration(
  //             seconds:
  //             5),
  //         isDismissible:
  //         false,
  //         mainButton: TextButton(
  //           // style: TextButton
  //           //     .styleFrom(
  //           //   primary:
  //           //       Colors.white,
  //           // ),
  //             onPressed: () async {
  //               await openAppSettings();
  //             },
  //             child: Text('Allow')));
  //   }
  //
  //
  //   var jsontext =
  //       '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","invoice_id":"$invoiceNumber","date":"$appointmentStartTimeFromStages","amount":"$consultationFeesFromStages","invoice_base64":"$invoiceBase64"}';
  //   // '{"first_name":"$firstName","last_name":"$lastName","email":"$email","mobile":"$mobileNumber","prescription_number":"IHL-21-22/0000000001","prescription_base64":"$prescription_base64","security_hash":"$calculatedHash"}';
  //   print(invoiceBase64);
  //   print('api yet to be called');
  //   final response = await http.post(
  //     Uri.parse(API.iHLUrl + "/login/sendInvoiceToUser"),
  //     body: jsontext,
  //   );
  //   print('api called===================================>>>');
  //   print(invoiceBase64);
  //   print(jsontext);
  //   if (response.statusCode == 200) {
  //     print(response.body);
  //     // Get.close(1);
  //     print(response.body);}
  //   else {
  //     // Get.close(1);
  //     print(response.body);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => ViewallTeleDashboard(
                    backNav: true,
                  )),
          (Route<dynamic> route) => false),
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          color: Colors.grey[200],
          child: Column(
            children: <Widget>[
              CustomPaint(
                painter: BackgroundPainter(
                  primary: AppColors.primaryColor.withOpacity(0.7),
                  secondary: AppColors.primaryColor,
                ),
                child: Container(),
              ),
              SizedBox(
                height: 20.0,
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: BackButton(
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewallTeleDashboard(
                                    backNav: true,
                                  )),
                          (Route<dynamic> route) => false);
                    },
                  )),
              SizedBox(
                height: 20.0,
              ),
              Text(
                'Consultation Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScUtil().setSp(25),
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: loading == true
                        ? Center(child: CircularProgressIndicator())
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListView(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                //Consultation Details
                                Card(
                                  margin: EdgeInsets.all(10),
                                  color: AppColors.cardColor,
                                  shadowColor: FitnessAppTheme.grey.withOpacity(0.2),
                                  elevation: 2,
                                  borderOnForeground: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                      side: BorderSide(
                                        width: 1,
                                        color: FitnessAppTheme.nearlyWhite,
                                      )),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Consultation Details' + ':',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                'Consultant name :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              Text(
                                                consultantNameFromStages ?? "N/A",
                                                style: TextStyle(
                                                    color: CardColors.textColor, height: 2),
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                'Speciality :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              Text(
                                                specialityFromStages ?? "N/A",
                                                style: TextStyle(
                                                    color: CardColors.textColor, height: 2),
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                'Appointment start time :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              Text(
                                                appointmentStartTimeFromStages ?? "N/A",
                                                style: TextStyle(
                                                    color: CardColors.textColor, height: 2),
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                'Appointment end time :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              Text(
                                                appointmentEndTimeFromStages ?? "N/A",
                                                style: TextStyle(
                                                    color: CardColors.textColor, height: 2),
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                'Appointment status :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              Text(
                                                appointmentStatusFromStages ?? "N/A",
                                                style: TextStyle(
                                                    color: CardColors.textColor, height: 2),
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                'Appointment call status :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              Text(
                                                callStatusFromStages ?? "N/A",
                                                style: TextStyle(
                                                    color: CardColors.textColor, height: 2),
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                'Charges :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              consultationFeesFromStages != '0'
                                                  ? invoice.discount != ''
                                                      ? Text(
                                                          '${double.parse(consultationFeesFromStages) - double.parse(invoice.discount)}')
                                                      : Text(
                                                          consultationFeesFromStages ?? '',
                                                          style: TextStyle(
                                                              color: CardColors.textColor,
                                                              height: 2),
                                                        )
                                                  : Text(
                                                      consultationFeesFromStages ?? '',
                                                      style: TextStyle(
                                                          color: CardColors.textColor, height: 2),
                                                    ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                'Payment mode :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              Text(
                                                modeOfPaymentFromStages ?? "N/A",
                                                style: TextStyle(
                                                    color: CardColors.textColor, height: 2),
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                'Appointment model :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              Text(
                                                appointmentModelFromStages ?? "N/A",
                                                style: TextStyle(
                                                    color: CardColors.textColor, height: 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                // reason and instruction
                                Card(
                                  margin: EdgeInsets.all(10),
                                  color: AppColors.cardColor,
                                  shadowColor: FitnessAppTheme.grey.withOpacity(0.2),
                                  elevation: 2,
                                  borderOnForeground: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                      side: BorderSide(
                                        width: 1,
                                        color: FitnessAppTheme.nearlyWhite,
                                      )),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                'Other Instructions :',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                'Reason :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              Text(
                                                reasonOfVisitFromStages ?? "N/A",
                                                textAlign: TextAlign.justify,
                                                style: TextStyle(
                                                    color: CardColors.textColor, height: 2),
                                              ),
                                              SizedBox(height: 10.0),
                                              Text(
                                                'Allergy :',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: CardColors.titleColor,
                                                ),
                                              ),
                                              Text(
                                                (allergyFromStages == null) ||
                                                        (allergyFromStages == "")
                                                    ? "N/A"
                                                    : allergyFromStages,
                                                style: TextStyle(
                                                    color: CardColors.textColor, height: 2),
                                              ),
                                              vendorName == 'GENIX'
                                                  ? SizedBox.shrink()
                                                  : SizedBox(height: 10.0),
                                              vendorName == 'GENIX'
                                                  ? SizedBox.shrink()
                                                  : Text(
                                                      'Diagnosis :',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: CardColors.titleColor,
                                                      ),
                                                    ),
                                              vendorName == 'GENIX'
                                                  ? SizedBox.shrink()
                                                  : Text(
                                                      widget.consultationNotes != null
                                                          ? widget.consultationNotes['diagnosis']
                                                              .toString()
                                                          : "N/A",
                                                      textAlign: TextAlign.justify,
                                                      style: TextStyle(
                                                          color: CardColors.textColor, height: 2),
                                                    ),
                                              vendorName == 'GENIX'
                                                  ? SizedBox.shrink()
                                                  : SizedBox(height: 10.0),
                                              vendorName == 'GENIX'
                                                  ? SizedBox.shrink()
                                                  : Text(
                                                      'Consultant advice notes :',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: CardColors.titleColor,
                                                      ),
                                                    ),
                                              vendorName == 'GENIX'
                                                  ? SizedBox.shrink()
                                                  : Text(
                                                      widget.consultationNotes != null
                                                          ? widget.consultationNotes[
                                                              'consultation_advice_notes']
                                                          : "N/A",
                                                      style: TextStyle(
                                                          color: CardColors.textColor, height: 2),
                                                    ),
                                              //invoice
                                              Visibility(
                                                visible: consultationFeesFromStages != "0"
                                                    ? true
                                                    : false,
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 180.0,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(20.0),
                                                          ),
                                                          primary: AppColors.primaryColor,
                                                          textStyle: TextStyle(color: Colors.white),
                                                        ),
                                                        child: Text('Get Invoice',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                            )),
                                                        onPressed: () async {
                                                          // AwesomeNotifications()
                                                          //     .cancelAll();
                                                          bool permissionGrandted = false;
                                                          if (Platform.isAndroid) {
                                                            final deviceInfo =
                                                                await DeviceInfoPlugin()
                                                                    .androidInfo;
                                                            Map<Permission, PermissionStatus>
                                                                _status;
                                                            if (deviceInfo.version.sdkInt <= 32) {
                                                              _status = await [Permission.storage]
                                                                  .request();
                                                            } else {
                                                              _status = await [
                                                                Permission.photos,
                                                                Permission.videos
                                                              ].request();
                                                            }
                                                            _status.forEach((permission, status) {
                                                              if (status ==
                                                                  PermissionStatus.granted) {
                                                                permissionGrandted = true;
                                                              }
                                                            });
                                                          } else {
                                                            permissionGrandted = true;
                                                          }
                                                          if (permissionGrandted) {
                                                            SharedPreferences prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            prefs.setString(
                                                                "useraddressFromHistory", address);
                                                            prefs.setString(
                                                                "userareaFromHistory", area);
                                                            prefs.setString(
                                                                "usercityFromHistory", city);
                                                            prefs.setString(
                                                                "userstateFromHistory", state);
                                                            prefs.setString(
                                                                "userpincodeFromHistory", pincode);
                                                            Get.snackbar(
                                                              '',
                                                              'Invoice will be saved in your mobile!',
                                                              backgroundColor:
                                                                  AppColors.primaryAccentColor,
                                                              colorText: Colors.white,
                                                              duration: Duration(seconds: 5),
                                                              isDismissible: false,
                                                            );
                                                            new Future.delayed(
                                                                new Duration(seconds: 2), () async {
                                                              reportView(
                                                                  context, invoiceNumber, true,
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
                                                        }),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                //vital data
                                Visibility(
                                  visible: kisokCheckinHistory != null &&
                                      kisokCheckinHistory.length > 0 &&
                                      kisokCheckinHistory != "N/A",
                                  child: Card(
                                    margin: EdgeInsets.all(10),
                                    color: AppColors.cardColor,
                                    shadowColor: FitnessAppTheme.grey.withOpacity(0.2),
                                    elevation: 2,
                                    borderOnForeground: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4),
                                        ),
                                        side: BorderSide(
                                          width: 1,
                                          color: FitnessAppTheme.nearlyWhite,
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Text(
                                                'Vital Data :',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              // SizedBox(
                                              //     width:
                                              //     MediaQuery.of(context)
                                              //         .size
                                              //         .width /
                                              //         3.8),
                                            ],
                                          ),
                                          Visibility(
                                            visible: kisokCheckinHistory.length > 0 &&
                                                kisokCheckinHistory != "N/A",
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: kisokCheckinHistory.length > 0 &&
                                                        kisokCheckinHistory != "N/A"
                                                    ? kisokCheckinHistory
                                                        .map<Widget>(
                                                          (e) => Padding(
                                                            padding: const EdgeInsets.only(
                                                                left: 8.0, bottom: 8),
                                                            child: VitalDataTile(
                                                              value: e['type'] == 'Temperature'
                                                                  ? consultationDetails[
                                                                                  'consultant_details']
                                                                              ['vendor_name'] ==
                                                                          'GENIX'
                                                                      ? double.parse(e['value'])
                                                                          .toStringAsFixed(2)
                                                                      : ((double.parse(e['value']
                                                                                      .toString()) *
                                                                                  (9 / 5)) +
                                                                              32)
                                                                          .toStringAsFixed(2)
                                                                  : e['value'].toString(),
                                                              type: e['type'].toString(),
                                                              status: e['status'].toString(),
                                                              unit: e['unit'].toString(),

                                                              // e.value.toString(),
                                                              k: '',
                                                              index: 1,

                                                              // (kisokCheckinHistory
                                                              //     .indexOf(v) +
                                                              //     1)
                                                              //     .toString(),
                                                            ),
                                                          ),
                                                        )
                                                        .toList()
                                                    : dummy
                                                        .map((e) => Padding(
                                                              padding: const EdgeInsets.all(8),
                                                              child: PrescriptionTile(
                                                                  index: (dummy.indexOf(e) + 1)
                                                                      .toString(),
                                                                  value: e),
                                                            ))
                                                        .toList()),
                                          ),
                                          //
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 10.0,
                                ),

                                ///patient daignosis
                                Visibility(
                                  visible: genixDiagnosis != null &&
                                      genixDiagnosis.length > 0 &&
                                      genixDiagnosis != "N/A",
                                  child: Card(
                                    margin: EdgeInsets.all(10),
                                    color: AppColors.cardColor,
                                    shadowColor: FitnessAppTheme.grey.withOpacity(0.2),
                                    elevation: 2,
                                    borderOnForeground: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4),
                                        ),
                                        side: BorderSide(
                                          width: 1,
                                          color: FitnessAppTheme.nearlyWhite,
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Text(
                                                'Diagnosis :',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context).size.width / 3.8),
                                              // IconButton(
                                              //     icon: Icon(
                                              //         Icons.download_sharp,
                                              //         color: AppColors
                                              //             .primaryAccentColor),
                                              //     tooltip:
                                              //     "Download Prescription",
                                              //     onPressed: () async {
                                              //       AwesomeNotifications()
                                              //           .cancelAll();
                                              //       final status =
                                              //       await Permission
                                              //           .storage
                                              //           .request();
                                              //       if (status.isGranted) {
                                              //         SharedPreferences
                                              //         prefs =
                                              //         await SharedPreferences
                                              //             .getInstance();
                                              //         prefs.setString(
                                              //             "consultantNameFromHistorySummary",
                                              //             consultantName);
                                              //         prefs.setString(
                                              //             "consultantEmailFromHistorySummary",
                                              //             consultantEmail);
                                              //         prefs.setString(
                                              //             "consultantMobileFromHistorySummary",
                                              //             consultantMobile);
                                              //         prefs.setString(
                                              //             "consultantEducationFromHistorySummary",
                                              //             consultantEducation);
                                              //         prefs.setString(
                                              //             "consultantDescriptionFromHistorySummary",
                                              //             consultantDescription);
                                              //
                                              //         prefs.setString(
                                              //             "appointmentStartTimeFromHistorySummary",
                                              //             appStartingTime);
                                              //         prefs.setString(
                                              //             "reasonForVisitFromHistorySummary",
                                              //             reasonOfVisit);
                                              //         prefs.setString(
                                              //             "diagnosisFromHistorySummary",
                                              //             diagnosis);
                                              //         prefs.setString(
                                              //             "adviceFromHistorySummary",
                                              //             adviceNotes);
                                              //         prefs.setString(
                                              //             "userFirstNameFromHistorySummary",
                                              //             firstName);
                                              //         prefs.setString(
                                              //             "userLastNameFromHistorySummary",
                                              //             lastName);
                                              //         prefs.setString(
                                              //             "userEmailFromHistorySummary",
                                              //             email);
                                              //         prefs.setString(
                                              //             "userContactFromHistorySummary",
                                              //             mobileNumber);
                                              //         prefs.setString(
                                              //             "ageFromHistorySummary",
                                              //             finalAge
                                              //                 .toString());
                                              //         prefs.setString(
                                              //             "genderFromHistorySummary",
                                              //             finalGender);
                                              //
                                              //         prefs.setString(
                                              //             "useraddressFromHistory",
                                              //             address);
                                              //         prefs.setString(
                                              //             "userareaFromHistory",
                                              //             area);
                                              //         prefs.setString(
                                              //             "usercityFromHistory",
                                              //             city);
                                              //         prefs.setString(
                                              //             "userstateFromHistory",
                                              //             state);
                                              //         prefs.setString(
                                              //             "userpincodeFromHistory",
                                              //             pincode);
                                              //
                                              //         Get.snackbar(
                                              //           '',
                                              //           'Instructions will be saved in your mobile!',
                                              //           backgroundColor: AppColors
                                              //               .primaryAccentColor,
                                              //           colorText:
                                              //           Colors.white,
                                              //           duration: Duration(
                                              //               seconds: 5),
                                              //           isDismissible: false,
                                              //         );
                                              //         new Future.delayed(
                                              //             new Duration(
                                              //                 seconds: 2),
                                              //                 () {
                                              //               genixPrescription(
                                              //                   context,
                                              //                   true,
                                              //                   prescription,
                                              //                   bmi,
                                              //                   weight,
                                              //                   rmpId,
                                              //                   notes,
                                              //                   consultantSignature);
                                              //             });
                                              //       } else if (status
                                              //           .isDenied) {
                                              //         await Permission.storage
                                              //             .request();
                                              //         Get.snackbar(
                                              //             'Storage Access Denied',
                                              //             'Allow Storage permission to continue',
                                              //             backgroundColor:
                                              //             Colors.red,
                                              //             colorText:
                                              //             Colors.white,
                                              //             duration: Duration(
                                              //                 seconds: 5),
                                              //             isDismissible:
                                              //             false,
                                              //             mainButton:
                                              //             TextButton(
                                              //                 onPressed:
                                              //                     () async {
                                              //                   await openAppSettings();
                                              //                 },
                                              //                 child: Text(
                                              //                     'Allow')));
                                              //       } else {
                                              //         Get.snackbar(
                                              //             'Storage Access Denied',
                                              //             'Allow Storage permission to continue',
                                              //             backgroundColor:
                                              //             Colors.red,
                                              //             colorText:
                                              //             Colors.white,
                                              //             duration: Duration(
                                              //                 seconds: 5),
                                              //             isDismissible:
                                              //             false,
                                              //             mainButton:
                                              //             TextButton(
                                              //                 onPressed:
                                              //                     () async {
                                              //                   await openAppSettings();
                                              //                 },
                                              //                 child: Text(
                                              //                     'Allow')));
                                              //       }
                                              //     })
                                            ],
                                          ),
                                          Visibility(
                                            visible: genixDiagnosis.length > 0 &&
                                                genixDiagnosis != "N/A",
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: genixDiagnosis.length > 0 &&
                                                        genixDiagnosis != "N/A"
                                                    ? genixDiagnosis
                                                        // dummy
                                                        .map<Widget>(
                                                          (e) => Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: DaignosisTile(
                                                              value: e,
                                                              index: (genixDiagnosis.indexOf(e) + 1)
                                                                  .toString(),
                                                            ),
                                                          ),
                                                        )
                                                        .toList()
                                                    : dummy
                                                        .map((e) => Padding(
                                                              padding: const EdgeInsets.all(8),
                                                              child: PrescriptionTile(
                                                                  index: (dummy.indexOf(e) + 1)
                                                                      .toString(),
                                                                  value: e),
                                                            ))
                                                        .toList()),
                                          ),
                                          //
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                //lab test order
                                Visibility(
                                  visible: labTestList != null &&
                                      labTestList.length > 0 &&
                                      labTestList != "N/A",

                                  // (vendorName != "" &&
                                  //               vendorName != "") ||
                                  //           (vendorName != null &&
                                  //               vendorName != null) ||
                                  //           (vendorName != "null" &&
                                  //               vendorName != "null") ||
                                  //           (vendorName != "IHL" &&
                                  //               vendorName == "GENIX") ||
                                  //           prescription != null &&
                                  //               prescription != "N/A"||
                                  //       prescription.length > 0 ,
                                  // ? false
                                  // : true,
                                  child: Card(
                                    margin: EdgeInsets.all(10),
                                    color: AppColors.cardColor,
                                    shadowColor: FitnessAppTheme.grey.withOpacity(0.2),
                                    elevation: 2,
                                    borderOnForeground: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4),
                                        ),
                                        side: BorderSide(
                                          width: 1,
                                          color: FitnessAppTheme.nearlyWhite,
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Text(
                                                'Lab Tests :',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context).size.width / 2.78),
                                              Visibility(
                                                visible: false,
                                                child: IconButton(
                                                  icon: Icon(Icons.download,
                                                      color: AppColors.primaryAccentColor),
                                                  tooltip: "Download Lab Order",
                                                  onPressed: () async {
                                                    // AwesomeNotifications()
                                                    //     .cancelAll();
                                                    bool permissionGrandted = false;
                                                    if (Platform.isAndroid) {
                                                      final deviceInfo =
                                                          await DeviceInfoPlugin().androidInfo;
                                                      Map<Permission, PermissionStatus> _status;
                                                      if (deviceInfo.version.sdkInt <= 32) {
                                                        _status =
                                                            await [Permission.storage].request();
                                                      } else {
                                                        _status = await [
                                                          Permission.photos,
                                                          Permission.videos
                                                        ].request();
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
                                                      prefs.setString(
                                                          "consultantNameFromHistorySummary",
                                                          consultantName);
                                                      prefs.setString(
                                                          "consultantEmailFromHistorySummary",
                                                          consultantEmail);
                                                      prefs.setString(
                                                          "consultantMobileFromHistorySummary",
                                                          consultantMobile);
                                                      prefs.setString(
                                                          "consultantEducationFromHistorySummary",
                                                          consultantEducation);
                                                      prefs.setString(
                                                          "consultantDescriptionFromHistorySummary",
                                                          consultantDescription);

                                                      prefs.setString(
                                                          "appointmentStartTimeFromHistorySummary",
                                                          appointStartTime
                                                          // appointmentStartTimeFromStages
                                                          );
                                                      prefs.setString(
                                                          "reasonForVisitFromHistorySummary",
                                                          reasonOfVisitFromStages);
                                                      prefs.setString("diagnosisFromHistorySummary",
                                                          diagnosislab ?? '');
                                                      prefs.setString(
                                                          "adviceFromHistorySummary", adviceNotes);
                                                      prefs.setString(
                                                          "userFirstNameFromHistorySummary",
                                                          firstName);
                                                      prefs.setString(
                                                          "userLastNameFromHistorySummary",
                                                          lastName);
                                                      prefs.setString(
                                                          "userEmailFromHistorySummary", email);
                                                      prefs.setString(
                                                          "userContactFromHistorySummary",
                                                          mobileNumber);
                                                      prefs.setString("ageFromHistorySummary",
                                                          finalAge.toString());
                                                      prefs.setString(
                                                          "genderFromHistorySummary", finalGender);
                                                      prefs.setString(
                                                          "useraddressFromHistory", address);
                                                      prefs.setString("userareaFromHistory", area);
                                                      prefs.setString("usercityFromHistory", city);
                                                      prefs.setString(
                                                          "userstateFromHistory", state);
                                                      prefs.setString(
                                                          "userpincodeFromHistory", pincode);

                                                      Get.snackbar(
                                                        '',
                                                        'Instructions will be saved in your mobile!',
                                                        backgroundColor:
                                                            AppColors.primaryAccentColor,
                                                        colorText: Colors.white,
                                                        duration: Duration(seconds: 5),
                                                        isDismissible: false,
                                                      );
                                                      new Future.delayed(new Duration(seconds: 2),
                                                          () {
                                                        lab.genixLabOrder(
                                                            context,
                                                            true,
                                                            labTestList,
                                                            bmi,
                                                            weight,
                                                            rmpid,
                                                            labNotes,
                                                            consultantSignature);
                                                      });
                                                    } else {
                                                      Get.snackbar(
                                                        'Storage Access Denied',
                                                        'Allow Storage permission to continue',
                                                        backgroundColor: Colors.red,
                                                        colorText: Colors.white,
                                                        duration: Duration(seconds: 5),
                                                        isDismissible: false,
                                                        mainButton: TextButton(
                                                          onPressed: () async {
                                                            await openAppSettings();
                                                          },
                                                          child: Text('Allow'),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  // onPressed: () async {
                                                  //   AwesomeNotifications()
                                                  //       .cancelAll();
                                                  //   final status =
                                                  //       await Permission
                                                  //           .storage
                                                  //           .request();
                                                  //   if (status.isGranted) {
                                                  //     SharedPreferences
                                                  //         prefs =
                                                  //         await SharedPreferences
                                                  //             .getInstance();
                                                  //     prefs.setString(
                                                  //         "consultantNameFromHistorySummary",
                                                  //         consultantName);
                                                  //     prefs.setString(
                                                  //         "consultantEmailFromHistorySummary",
                                                  //         consultantEmail);
                                                  //     prefs.setString(
                                                  //         "consultantMobileFromHistorySummary",
                                                  //         consultantMobile);
                                                  //     prefs.setString(
                                                  //         "consultantEducationFromHistorySummary",
                                                  //         consultantEducation);
                                                  //     prefs.setString(
                                                  //         "consultantDescriptionFromHistorySummary",
                                                  //         consultantDescription);

                                                  //     prefs.setString(
                                                  //         "appointmentStartTimeFromHistorySummary",
                                                  //         appStartingTime);
                                                  //     prefs.setString(
                                                  //         "reasonForVisitFromHistorySummary",
                                                  //         reasonOfVisit);
                                                  //     prefs.setString(
                                                  //         "diagnosisFromHistorySummary",
                                                  //         diagnosis);
                                                  //     prefs.setString(
                                                  //         "adviceFromHistorySummary",
                                                  //         adviceNotes);
                                                  //     prefs.setString(
                                                  //         "userFirstNameFromHistorySummary",
                                                  //         firstName);
                                                  //     prefs.setString(
                                                  //         "userLastNameFromHistorySummary",
                                                  //         lastName);
                                                  //     prefs.setString(
                                                  //         "userEmailFromHistorySummary",
                                                  //         email);
                                                  //     prefs.setString(
                                                  //         "userContactFromHistorySummary",
                                                  //         mobileNumber);
                                                  //     prefs.setString(
                                                  //         "ageFromHistorySummary",
                                                  //         finalAge
                                                  //             .toString());
                                                  //     prefs.setString(
                                                  //         "genderFromHistorySummary",
                                                  //         finalGender);

                                                  //     prefs.setString(
                                                  //         "useraddressFromHistory",
                                                  //         address);
                                                  //     prefs.setString(
                                                  //         "userareaFromHistory",
                                                  //         area);
                                                  //     prefs.setString(
                                                  //         "usercityFromHistory",
                                                  //         city);
                                                  //     prefs.setString(
                                                  //         "userstateFromHistory",
                                                  //         state);
                                                  //     prefs.setString(
                                                  //         "userpincodeFromHistory",
                                                  //         pincode);

                                                  //     Get.snackbar(
                                                  //       '',
                                                  //       'Instructions will be saved in your mobile!',
                                                  //       backgroundColor: AppColors
                                                  //           .primaryAccentColor,
                                                  //       colorText:
                                                  //           Colors.white,
                                                  //       duration: Duration(
                                                  //           seconds: 5),
                                                  //       isDismissible: false,
                                                  //     );
                                                  //     new Future.delayed(
                                                  //         new Duration(
                                                  //             seconds: 2),
                                                  //         () {
                                                  //       genixPrescription(
                                                  //           context,
                                                  //           true,
                                                  //           prescription,
                                                  //           bmi,
                                                  //           weight,
                                                  //           rmpId,
                                                  //           notes,
                                                  //           consultantSignature);
                                                  //     });
                                                  //   } else if (status
                                                  //       .isDenied) {
                                                  //     await Permission.storage
                                                  //         .request();
                                                  //     Get.snackbar(
                                                  //         'Storage Access Denied',
                                                  //         'Allow Storage permission to continue',
                                                  //         backgroundColor:
                                                  //             Colors.red,
                                                  //         colorText:
                                                  //             Colors.white,
                                                  //         duration: Duration(
                                                  //             seconds: 5),
                                                  //         isDismissible:
                                                  //             false,
                                                  //         mainButton:
                                                  //             TextButton(
                                                  //                 onPressed:
                                                  //                     () async {
                                                  //                   await openAppSettings();
                                                  //                 },
                                                  //                 child: Text(
                                                  //                     'Allow')));
                                                  //   } else {
                                                  //     Get.snackbar(
                                                  //         'Storage Access Denied',
                                                  //         'Allow Storage permission to continue',
                                                  //         backgroundColor:
                                                  //             Colors.red,
                                                  //         colorText:
                                                  //             Colors.white,
                                                  //         duration: Duration(
                                                  //             seconds: 5),
                                                  //         isDismissible:
                                                  //             false,
                                                  //         mainButton:
                                                  //             TextButton(
                                                  //                 onPressed:
                                                  //                     () async {
                                                  //                   await openAppSettings();
                                                  //                 },
                                                  //                 child: Text(
                                                  //                     'Allow')));
                                                  //   }
                                                  // },
                                                  // onPressed: () {
                                                  //   showModalBottomSheet(
                                                  //       context: context,
                                                  //       backgroundColor:
                                                  //           Colors.white,
                                                  //       shape:
                                                  //           RoundedRectangleBorder(
                                                  //         borderRadius:
                                                  //             BorderRadius.only(
                                                  //                 topLeft: Radius
                                                  //                     .circular(
                                                  //                         15.0),
                                                  //                 topRight: Radius
                                                  //                     .circular(
                                                  //                         15.0)),
                                                  //       ),
                                                  //       builder: (BuildContext
                                                  //           context) {
                                                  //         return StatefulBuilder(
                                                  //             builder: (BuildContext
                                                  //                     context,
                                                  //                 StateSetter
                                                  //                     mystate) {
                                                  //           return Column(
                                                  //             crossAxisAlignment:
                                                  //                 CrossAxisAlignment
                                                  //                     .start,
                                                  //             mainAxisSize:
                                                  //                 MainAxisSize
                                                  //                     .min,
                                                  //             children: [
                                                  //               Padding(
                                                  //                 padding: const EdgeInsets
                                                  //                             .all(
                                                  //                         8.0)
                                                  //                     .copyWith(
                                                  //                         left:
                                                  //                             16),
                                                  //                 child: Text(
                                                  //                   'Share Lab Order ?',
                                                  //                   style: TextStyle(
                                                  //                       color: AppColors.appTextColor, //AppColors.primaryColor
                                                  //                       fontSize: 24,
                                                  //                       fontWeight: FontWeight.bold),
                                                  //                   textAlign:
                                                  //                       TextAlign
                                                  //                           .left,
                                                  //                 ),
                                                  //               ),
                                                  //               Divider(
                                                  //                 indent: 10,
                                                  //                 endIndent: 10,
                                                  //                 thickness: 2,
                                                  //               ),
                                                  //               Expanded(
                                                  //                 child: Align(
                                                  //                   alignment:
                                                  //                       Alignment
                                                  //                           .center,
                                                  //                   child:
                                                  //                       Padding(
                                                  //                     padding:
                                                  //                         const EdgeInsets.all(
                                                  //                             8.0),
                                                  //                     child: Image
                                                  //                         .network(
                                                  //                       'https://i.postimg.cc/mrDDfxQT/Group-43.png',
                                                  //                     ),
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //               Padding(
                                                  //                 padding:
                                                  //                     const EdgeInsets
                                                  //                             .all(
                                                  //                         10.0),
                                                  //                 child: RichText(
                                                  //                   textAlign:
                                                  //                       TextAlign
                                                  //                           .left,
                                                  //                   text:
                                                  //                       TextSpan(
                                                  //                     text:
                                                  //                         "By providing your consent to India Health Link (IHL) Pvt. Ltd to share your prescription and personal contact details to 1mg Technology Pvt Ltd in your own interest for your lab test order fulfillment as per the ",
                                                  //                     style: TextStyle(
                                                  //                         color: AppColors.appTextColor, //AppColors.primaryColor
                                                  //                         fontSize: 14),
                                                  //                     children: [
                                                  //                       TextSpan(
                                                  //                         text:
                                                  //                             "Terms & Conditions",
                                                  //                         style: TextStyle(
                                                  //                             fontWeight:
                                                  //                                 FontWeight.bold,
                                                  //                             color: Colors.blue,
                                                  //                             decoration: TextDecoration.underline),
                                                  //                         recognizer:
                                                  //                             TapGestureRecognizer()
                                                  //                               ..onTap = () {
                                                  //                                 Get.dialog(PolicyDialog(
                                                  //                                   title: "Tele Consultation T & C",
                                                  //                                   mdFileName: 'TeleTOC.md',
                                                  //                                 ));
                                                  //                               },
                                                  //                       ),
                                                  //                       TextSpan(
                                                  //                           text:
                                                  //                               " and "),
                                                  //                       TextSpan(
                                                  //                         text:
                                                  //                             "Privacy Policy",
                                                  //                         style: TextStyle(
                                                  //                             fontWeight:
                                                  //                                 FontWeight.bold,
                                                  //                             color: Colors.blue,
                                                  //                             decoration: TextDecoration.underline),
                                                  //                         recognizer:
                                                  //                             TapGestureRecognizer()
                                                  //                               ..onTap = () {
                                                  //                                 Get.dialog(PolicyDialog(
                                                  //                                   title: "Privacy Policy",
                                                  //                                   mdFileName: 'PrivacyPolicy.md',
                                                  //                                 ));
                                                  //                               },
                                                  //                       ),
                                                  //                       TextSpan(
                                                  //                         text:
                                                  //                             ", you will be able to avail the 'Order Lab Test' services.",
                                                  //                         style: TextStyle(
                                                  //                             color: AppColors.appTextColor, //AppColors.primaryColor
                                                  //                             fontSize: 14),
                                                  //                       ),
                                                  //                     ],
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //               CheckboxListTile(
                                                  //                 controlAffinity:
                                                  //                     ListTileControlAffinity
                                                  //                         .leading,
                                                  //                 value: isAgree,
                                                  //                 onChanged:
                                                  //                     (val) {
                                                  //                   mystate(() {
                                                  //                     isAgree =
                                                  //                         val;
                                                  //                     print(
                                                  //                         isAgree);
                                                  //                   });
                                                  //                 },
                                                  //
                                                  //                 title: Text(
                                                  //                   'I agree to the Terms and Condition for the service',
                                                  //                   style: TextStyle(
                                                  //                       color: AppColors
                                                  //                           .appTextColor,
                                                  //                       fontSize:
                                                  //                           12),
                                                  //                 ),
                                                  //                 // isThreeLine: false,
                                                  //                 contentPadding:
                                                  //                     EdgeInsets.only(
                                                  //                         left:
                                                  //                             16),
                                                  //               ),
                                                  //               Padding(
                                                  //                 padding:
                                                  //                     const EdgeInsets
                                                  //                             .all(
                                                  //                         8.0),
                                                  //                 child: Row(
                                                  //                   mainAxisAlignment:
                                                  //                       MainAxisAlignment
                                                  //                           .spaceEvenly,
                                                  //                   children: [
                                                  //                     RaisedButton(
                                                  //                       color: isAgree
                                                  //                           ? Color(
                                                  //                               0xff4393cf)
                                                  //                           : Colors
                                                  //                               .grey,
                                                  //                       shape: RoundedRectangleBorder(
                                                  //                           borderRadius: BorderRadius.circular(10.0),
                                                  //                           side: BorderSide(
                                                  //                             color: isAgree
                                                  //                                 ? AppColors.primaryColor
                                                  //                                 : Colors.grey,
                                                  //                           )),
                                                  //                       child:
                                                  //                           Text(
                                                  //                         'Share',
                                                  //                         style: TextStyle(
                                                  //                             color:
                                                  //                                 Colors.white),
                                                  //                       ),
                                                  //                       onPressed: isAgree
                                                  //                           ? () {
                                                  //                               sendPrescriptionTo1MG();
                                                  //                               Get.close(1);
                                                  //                             }
                                                  //                           : null,
                                                  //                     ),
                                                  //                     // SizedBox(width: 10.0),
                                                  //                     RaisedButton(
                                                  //                       shape: RoundedRectangleBorder(
                                                  //                           borderRadius: BorderRadius.circular(
                                                  //                               10.0),
                                                  //                           side:
                                                  //                               BorderSide(color: AppColors.primaryColor)),
                                                  //                       color: Color(
                                                  //                           0xff4393cf),
                                                  //                       child:
                                                  //                           Text(
                                                  //                         'Cancel',
                                                  //                         style: TextStyle(
                                                  //                             color:
                                                  //                                 Colors.white),
                                                  //                       ),
                                                  //                       onPressed:
                                                  //                           () {
                                                  //                         Navigator.of(context)
                                                  //                             .pop();
                                                  //                       },
                                                  //                     ),
                                                  //                   ],
                                                  //                 ),
                                                  //               ),
                                                  //               SizedBox(
                                                  //                   height: 20),
                                                  //             ],
                                                  //           );
                                                  //         });
                                                  //       });
                                                  // },
                                                ),
                                              )
                                            ],
                                          ),
                                          Text(
                                            'Prescribed Tests',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: CardColors.titleColor,
                                            ),
                                          ),
                                          Visibility(
                                            visible: labTestList.length > 0 && labTestList != "N/A",
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: labTestList
                                                    .map<Widget>((e) => Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 8, vertical: 5),
                                                          child: LabOrderTile(
                                                              showNotesOfLabTests: false,
                                                              index: (labTestList.indexOf(e) + 1)
                                                                  .toString(),
                                                              value: e),
                                                        ))
                                                    .toList()),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Text(
                                              'Remarks:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: CardColors.titleColor,
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: labTestList != null &&
                                                labTestList.length > 0 &&
                                                labTestList != "N/A",
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: labTestList != null
                                                  ? labTestList
                                                      .map<Widget>((e) => Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 8, vertical: 4),
                                                            child: LabOrderTile(
                                                                showNotesOfLabTests: true,
                                                                index: (labTestList.indexOf(e) + 1)
                                                                    .toString(),
                                                                value: e),
                                                          ))
                                                      .toList()
                                                  : [],
                                            ),
                                          ),
                                          Visibility(
                                            ///in issue list 6.0.5
                                            ///request came to disabe the order la\b test
                                            visible: false,
                                            // visible: logoUrl != null &&
                                            //     logoUrl != '',
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  // width: ScUtil().setWidth(270),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20.0),
                                                      ),
                                                      primary: AppColors.primaryColor,
                                                    ),
                                                    child: Text('Order Lab Tests',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        )),
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                          context: context,
                                                          backgroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(15.0),
                                                                topRight: Radius.circular(15.0)),
                                                          ),
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(builder:
                                                                (BuildContext context,
                                                                    StateSetter mystate) {
                                                              return Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(8.0)
                                                                            .copyWith(left: 16),
                                                                    child: Text(
                                                                      'Share Lab Tests ?',
                                                                      style: TextStyle(
                                                                          color: AppColors
                                                                              .appTextColor,
                                                                          //AppColors.primaryColor
                                                                          fontSize: 24,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      textAlign: TextAlign.left,
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                    indent: 10,
                                                                    endIndent: 10,
                                                                    thickness: 2,
                                                                  ),
                                                                  Expanded(
                                                                    child: Align(
                                                                      alignment: Alignment.center,
                                                                      child: Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                                8.0),
                                                                        child: logoUrl != null &&
                                                                                logoUrl != ''
                                                                            ? Row(
                                                                                mainAxisAlignment:
                                                                                    MainAxisAlignment
                                                                                        .center,
                                                                                children: [
                                                                                  Card(
                                                                                    elevation: 0,
                                                                                    child: Padding(
                                                                                      padding:
                                                                                          EdgeInsets
                                                                                              .all(
                                                                                                  10),
                                                                                      child: Image
                                                                                          .asset(
                                                                                        'assets/images/ihl-plus.png',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  // Image.asset(''),
                                                                                  Card(
                                                                                      elevation: 0,
                                                                                      child: Icon(
                                                                                        Icons
                                                                                            .send_sharp,
                                                                                        color: AppColors
                                                                                            .appItemTitleTextColor,
                                                                                        size: 35,
                                                                                      )),
                                                                                  Card(
                                                                                      elevation: 0,
                                                                                      child: Image
                                                                                          .network(
                                                                                              '$logoUrl')),
                                                                                ],
                                                                              )
                                                                            : Container(
                                                                                height: 0,
                                                                                width: 0,
                                                                              ),

                                                                        // Image.network(
                                                                        //   'https://i.postimg.cc/mrDDfxQT/Group-43.png',
                                                                        // ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(10.0),
                                                                    child: RichText(
                                                                      textAlign: TextAlign.left,
                                                                      text: TextSpan(
                                                                        text:
                                                                            "By providing your consent to India Health Link (IHL) Pvt. Ltd to share your lab Tests and personal contact details to 1mg Technology Pvt Ltd in your own interest for your lab Tests order fulfillment as per the ",
                                                                        style: TextStyle(
                                                                            color: AppColors
                                                                                .appTextColor,
                                                                            //AppColors.primaryColor
                                                                            fontSize: 14),
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                "Terms & Conditions",
                                                                            style: TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                                color: Colors.blue,
                                                                                decoration:
                                                                                    TextDecoration
                                                                                        .underline),
                                                                            recognizer:
                                                                                TapGestureRecognizer()
                                                                                  ..onTap = () {
                                                                                    Get.dialog(
                                                                                        PolicyDialog(
                                                                                      title:
                                                                                          "Tele Consultation T & C",
                                                                                      mdFileName:
                                                                                          'TeleTOC.md',
                                                                                    ));
                                                                                  },
                                                                          ),
                                                                          TextSpan(text: " and "),
                                                                          TextSpan(
                                                                            text: "Privacy Policy",
                                                                            style: TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                                color: Colors.blue,
                                                                                decoration:
                                                                                    TextDecoration
                                                                                        .underline),
                                                                            recognizer:
                                                                                TapGestureRecognizer()
                                                                                  ..onTap = () {
                                                                                    Get.dialog(
                                                                                        PolicyDialog(
                                                                                      title:
                                                                                          "Privacy Policy",
                                                                                      mdFileName:
                                                                                          'PrivacyPolicy.md',
                                                                                    ));
                                                                                  },
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                ", you will be able to avail the 'Lab Test Order' services.",
                                                                            style: TextStyle(
                                                                                color: AppColors
                                                                                    .appTextColor,
                                                                                //AppColors.primaryColor
                                                                                fontSize: 14),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  CheckboxListTile(
                                                                    controlAffinity:
                                                                        ListTileControlAffinity
                                                                            .leading,
                                                                    value: isAgree,
                                                                    onChanged: (val) {
                                                                      mystate(() {
                                                                        isAgree = val;
                                                                        print(isAgree);
                                                                      });
                                                                    },

                                                                    title: Text(
                                                                      'I agree to the Terms and Condition for the service',
                                                                      style: TextStyle(
                                                                          color: AppColors
                                                                              .appTextColor,
                                                                          fontSize: 12),
                                                                    ),
                                                                    // isThreeLine: false,
                                                                    contentPadding:
                                                                        EdgeInsets.only(left: 16),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(8.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        ElevatedButton(
                                                                          style: ElevatedButton
                                                                              .styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(
                                                                                          10.0),
                                                                              side: BorderSide(
                                                                                color: isAgree
                                                                                    ? AppColors
                                                                                        .primaryColor
                                                                                    : Colors.grey,
                                                                              ),
                                                                            ),
                                                                            primary: isAgree
                                                                                ? AppColors
                                                                                    .primaryColor
                                                                                : Colors.grey,
                                                                          ),
                                                                          child: Text(
                                                                            'Share',
                                                                            style: TextStyle(
                                                                                color:
                                                                                    Colors.white),
                                                                          ),
                                                                          onPressed: isAgree
                                                                              ? () {
                                                                                  sendLabTestTo1MG();
                                                                                  Get.close(1);
                                                                                }
                                                                              : null,
                                                                        ),
                                                                        // SizedBox(width: 10.0),
                                                                        ElevatedButton(
                                                                          style: ElevatedButton
                                                                              .styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(
                                                                                          10.0),
                                                                            ),
                                                                            primary: AppColors
                                                                                .primaryColor,
                                                                          ),
                                                                          child: Text(
                                                                            'Cancel',
                                                                            style: TextStyle(
                                                                                color:
                                                                                    Colors.white),
                                                                          ),
                                                                          onPressed: () {
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 20),
                                                                ],
                                                              );
                                                            });
                                                          });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                ///radiology test

                                Visibility(
                                  visible: genixRadiology != null &&
                                      genixRadiology.length > 0 &&
                                      genixRadiology != "N/A",
                                  child: Card(
                                    margin: EdgeInsets.all(10),
                                    color: AppColors.cardColor,
                                    shadowColor: FitnessAppTheme.grey.withOpacity(0.2),
                                    elevation: 2,
                                    borderOnForeground: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4),
                                        ),
                                        side: BorderSide(
                                          width: 1,
                                          color: FitnessAppTheme.nearlyWhite,
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Text(
                                                'Radiology :',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context).size.width / 3.8),
                                              // IconButton(
                                              //     icon: Icon(
                                              //         Icons.download_sharp,
                                              //         color: AppColors
                                              //             .primaryAccentColor),
                                              //     tooltip:
                                              //     "Download Prescription",
                                              //     onPressed: () async {
                                              //       AwesomeNotifications()
                                              //           .cancelAll();
                                              //       final status =
                                              //       await Permission
                                              //           .storage
                                              //           .request();
                                              //       if (status.isGranted) {
                                              //         SharedPreferences
                                              //         prefs =
                                              //         await SharedPreferences
                                              //             .getInstance();
                                              //         prefs.setString(
                                              //             "consultantNameFromHistorySummary",
                                              //             consultantName);
                                              //         prefs.setString(
                                              //             "consultantEmailFromHistorySummary",
                                              //             consultantEmail);
                                              //         prefs.setString(
                                              //             "consultantMobileFromHistorySummary",
                                              //             consultantMobile);
                                              //         prefs.setString(
                                              //             "consultantEducationFromHistorySummary",
                                              //             consultantEducation);
                                              //         prefs.setString(
                                              //             "consultantDescriptionFromHistorySummary",
                                              //             consultantDescription);
                                              //
                                              //         prefs.setString(
                                              //             "appointmentStartTimeFromHistorySummary",
                                              //             appStartingTime);
                                              //         prefs.setString(
                                              //             "reasonForVisitFromHistorySummary",
                                              //             reasonOfVisit);
                                              //         prefs.setString(
                                              //             "diagnosisFromHistorySummary",
                                              //             diagnosis);
                                              //         prefs.setString(
                                              //             "adviceFromHistorySummary",
                                              //             adviceNotes);
                                              //         prefs.setString(
                                              //             "userFirstNameFromHistorySummary",
                                              //             firstName);
                                              //         prefs.setString(
                                              //             "userLastNameFromHistorySummary",
                                              //             lastName);
                                              //         prefs.setString(
                                              //             "userEmailFromHistorySummary",
                                              //             email);
                                              //         prefs.setString(
                                              //             "userContactFromHistorySummary",
                                              //             mobileNumber);
                                              //         prefs.setString(
                                              //             "ageFromHistorySummary",
                                              //             finalAge
                                              //                 .toString());
                                              //         prefs.setString(
                                              //             "genderFromHistorySummary",
                                              //             finalGender);
                                              //
                                              //         prefs.setString(
                                              //             "useraddressFromHistory",
                                              //             address);
                                              //         prefs.setString(
                                              //             "userareaFromHistory",
                                              //             area);
                                              //         prefs.setString(
                                              //             "usercityFromHistory",
                                              //             city);
                                              //         prefs.setString(
                                              //             "userstateFromHistory",
                                              //             state);
                                              //         prefs.setString(
                                              //             "userpincodeFromHistory",
                                              //             pincode);
                                              //
                                              //         Get.snackbar(
                                              //           '',
                                              //           'Instructions will be saved in your mobile!',
                                              //           backgroundColor: AppColors
                                              //               .primaryAccentColor,
                                              //           colorText:
                                              //           Colors.white,
                                              //           duration: Duration(
                                              //               seconds: 5),
                                              //           isDismissible: false,
                                              //         );
                                              //         new Future.delayed(
                                              //             new Duration(
                                              //                 seconds: 2),
                                              //                 () {
                                              //               genixPrescription(
                                              //                   context,
                                              //                   true,
                                              //                   prescription,
                                              //                   bmi,
                                              //                   weight,
                                              //                   rmpId,
                                              //                   notes,
                                              //                   consultantSignature);
                                              //             });
                                              //       } else if (status
                                              //           .isDenied) {
                                              //         await Permission.storage
                                              //             .request();
                                              //         Get.snackbar(
                                              //             'Storage Access Denied',
                                              //             'Allow Storage permission to continue',
                                              //             backgroundColor:
                                              //             Colors.red,
                                              //             colorText:
                                              //             Colors.white,
                                              //             duration: Duration(
                                              //                 seconds: 5),
                                              //             isDismissible:
                                              //             false,
                                              //             mainButton:
                                              //             TextButton(
                                              //                 onPressed:
                                              //                     () async {
                                              //                   await openAppSettings();
                                              //                 },
                                              //                 child: Text(
                                              //                     'Allow')));
                                              //       } else {
                                              //         Get.snackbar(
                                              //             'Storage Access Denied',
                                              //             'Allow Storage permission to continue',
                                              //             backgroundColor:
                                              //             Colors.red,
                                              //             colorText:
                                              //             Colors.white,
                                              //             duration: Duration(
                                              //                 seconds: 5),
                                              //             isDismissible:
                                              //             false,
                                              //             mainButton:
                                              //             TextButton(
                                              //                 onPressed:
                                              //                     () async {
                                              //                   await openAppSettings();
                                              //                 },
                                              //                 child: Text(
                                              //                     'Allow')));
                                              //       }
                                              //     })
                                            ],
                                          ),
                                          Visibility(
                                            visible: genixRadiology.length > 0 &&
                                                genixRadiology != "N/A",
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: genixRadiology.length > 0 &&
                                                        genixRadiology != "N/A"
                                                    ? genixRadiology
                                                        // dummy
                                                        .map<Widget>(
                                                          (e) => Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: RadiologyTile(
                                                              value: e,
                                                              index: (genixRadiology.indexOf(e) + 1)
                                                                  .toString(),
                                                            ),
                                                          ),
                                                        )
                                                        .toList()
                                                    : dummy
                                                        .map((e) => Padding(
                                                              padding: const EdgeInsets.all(8),
                                                              child: PrescriptionTile(
                                                                  index: (dummy.indexOf(e) + 1)
                                                                      .toString(),
                                                                  value: e),
                                                            ))
                                                        .toList()),
                                          ),
                                          //
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                //prescription / Medicine

                                Visibility(
                                  visible: true,
                                  child: Card(
                                    margin: EdgeInsets.all(10),
                                    color: AppColors.cardColor,
                                    shadowColor: FitnessAppTheme.grey.withOpacity(0.2),
                                    elevation: 2,
                                    borderOnForeground: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4),
                                        ),
                                        side: BorderSide(
                                          width: 1,
                                          color: FitnessAppTheme.nearlyWhite,
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Text(
                                                'Prescription :',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              // SizedBox(
                                              //     width: MediaQuery.of(context)
                                              //             .size
                                              //             .width /
                                              //         3.8),
                                              Visibility(
                                                visible: labTestList != null &&
                                                    labTestList.length > 0 &&
                                                    labTestList != "N/A",
                                                child: IconButton(
                                                  icon: Icon(Icons.download_sharp,
                                                      color: AppColors.primaryAccentColor),
                                                  tooltip: "Download Prescription",
                                                  onPressed: () async {
                                                    // AwesomeNotifications()
                                                    //     .cancelAll();
                                                    bool permissionGrandted = false;
                                                    if (Platform.isAndroid) {
                                                      final deviceInfo =
                                                          await DeviceInfoPlugin().androidInfo;
                                                      Map<Permission, PermissionStatus> _status;
                                                      if (deviceInfo.version.sdkInt <= 32) {
                                                        _status =
                                                            await [Permission.storage].request();
                                                      } else {
                                                        _status = await [
                                                          Permission.photos,
                                                          Permission.videos
                                                        ].request();
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
                                                      prefs.setString(
                                                          "consultantNameFromHistorySummary",
                                                          consultantName);
                                                      prefs.setString(
                                                          "consultantEmailFromHistorySummary",
                                                          consultantEmail);
                                                      prefs.setString(
                                                          "consultantMobileFromHistorySummary",
                                                          consultantMobile);
                                                      prefs.setString(
                                                          "consultantEducationFromHistorySummary",
                                                          consultantEducation);
                                                      prefs.setString(
                                                          "consultantDescriptionFromHistorySummary",
                                                          consultantDescription);

                                                      prefs.setString(
                                                          "appointmentStartTimeFromHistorySummary",
                                                          appointStartTime
                                                          // appointmentStartTimeFromStages
                                                          );
                                                      prefs.setString(
                                                          "reasonForVisitFromHistorySummary",
                                                          reasonOfVisitFromStages);
                                                      prefs.setString("diagnosisFromHistorySummary",
                                                          diagnosislab ?? '');
                                                      prefs.setString(
                                                          "adviceFromHistorySummary", adviceNotes);
                                                      prefs.setString(
                                                          "userFirstNameFromHistorySummary",
                                                          firstName);
                                                      prefs.setString(
                                                          "userLastNameFromHistorySummary",
                                                          lastName);
                                                      prefs.setString(
                                                          "userEmailFromHistorySummary", email);
                                                      prefs.setString(
                                                          "userContactFromHistorySummary",
                                                          mobileNumber);
                                                      prefs.setString("ageFromHistorySummary",
                                                          finalAge.toString());
                                                      prefs.setString(
                                                          "genderFromHistorySummary", finalGender);
                                                      prefs.setString(
                                                          "useraddressFromHistory", address);
                                                      prefs.setString("userareaFromHistory", area);
                                                      prefs.setString("usercityFromHistory", city);
                                                      prefs.setString(
                                                          "userstateFromHistory", state);
                                                      prefs.setString(
                                                          "userpincodeFromHistory", pincode);

                                                      Get.snackbar(
                                                        '',
                                                        'Instructions will be saved in your mobile!',
                                                        backgroundColor:
                                                            AppColors.primaryAccentColor,
                                                        colorText: Colors.white,
                                                        duration: Duration(seconds: 5),
                                                        isDismissible: false,
                                                      );
                                                      Future.delayed(const Duration(seconds: 2),
                                                          () {
                                                        genixLabOrder(
                                                            context,
                                                            true,
                                                            labTestList,
                                                            bmi,
                                                            weight,
                                                            rmpid,
                                                            labNotes,
                                                            consultantSignature);
                                                        // genixPrescription(
                                                        //     context: context,
                                                        //     showPdfNotification: true,
                                                        //     allergies: _allergies,
                                                        //     footer: footerDetail,
                                                        //     mobilenummber: mobileNumber,
                                                        //     prescription: prescription,
                                                        //     bmi: bmi,
                                                        //     weight: weight,
                                                        //     rmpid: rmpid,
                                                        //     notes: notes,
                                                        //     consultantSignature:
                                                        //         consultantSignature,
                                                        //     genixDaignosis: genixDiagnosis,
                                                        //     genixRadiology: genixRadiology,
                                                        //     kisokCheckinHistory:
                                                        //         kisokCheckinHistory,
                                                        //     genixLabTest: labTestList,
                                                        //     genixLabNotes: labNotes,
                                                        //     consultantAddress: consultantAddress,
                                                        //     prescriptionNotes: _prescriptionNotes,
                                                        //     appointmentId: appointId,
                                                        //     allergy: allergy,
                                                        //     specality: speciality,
                                                        //     logoUrl: Image.memory(
                                                        //         base64Decode(_imageBase64)));
                                                      });
                                                    } else {
                                                      Get.snackbar(
                                                        'Storage Access Denied',
                                                        'Allow Storage permission to continue',
                                                        backgroundColor: Colors.red,
                                                        colorText: Colors.white,
                                                        duration: Duration(seconds: 5),
                                                        isDismissible: false,
                                                        mainButton: TextButton(
                                                          onPressed: () async {
                                                            await openAppSettings();
                                                          },
                                                          child: Text('Allow'),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                          Visibility(
                                            visible:
                                                prescription.length > 0 && prescription != "N/A",
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: prescription.length > 0 &&
                                                        prescription != "N/A"
                                                    ? prescription
                                                        // dummy
                                                        .map<Widget>(
                                                          (e) => Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: PrescriptionTile(
                                                              value: e,
                                                              index: (prescription.indexOf(e) + 1)
                                                                  .toString(),
                                                            ),
                                                          ),
                                                        )
                                                        .toList()
                                                    : dummy
                                                        .map((e) => Padding(
                                                              padding: const EdgeInsets.all(8),
                                                              child: PrescriptionTile(
                                                                  index: (dummy.indexOf(e) + 1)
                                                                      .toString(),
                                                                  value: e),
                                                            ))
                                                        .toList()),
                                          ),
                                          //order medicine button
                                          Visibility(
                                            visible: false,
                                            // logoUrl != null &&
                                            //     logoUrl != '',
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  // width: ScUtil().setWidth(270),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20.0),
                                                      ),
                                                      primary: AppColors.primaryColor,
                                                    ),
                                                    child: Text('Order Medicine',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        )),
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                          context: context,
                                                          backgroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(15.0),
                                                                topRight: Radius.circular(15.0)),
                                                          ),
                                                          builder: (BuildContext context) {
                                                            return StatefulBuilder(builder:
                                                                (BuildContext context,
                                                                    StateSetter mystate) {
                                                              return Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(8.0)
                                                                            .copyWith(left: 16),
                                                                    child: Text(
                                                                      'Share prescription ?',
                                                                      style: TextStyle(
                                                                          color: AppColors
                                                                              .appTextColor,
                                                                          //AppColors.primaryColor
                                                                          fontSize: 24,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      textAlign: TextAlign.left,
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                    indent: 10,
                                                                    endIndent: 10,
                                                                    thickness: 2,
                                                                  ),
                                                                  Expanded(
                                                                    child: Align(
                                                                      alignment: Alignment.center,
                                                                      child: Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                                8.0),
                                                                        child: logoUrl != null &&
                                                                                logoUrl != ''
                                                                            ? Row(
                                                                                mainAxisAlignment:
                                                                                    MainAxisAlignment
                                                                                        .center,
                                                                                children: [
                                                                                  Card(
                                                                                    elevation: 0,
                                                                                    child: Padding(
                                                                                      padding:
                                                                                          EdgeInsets
                                                                                              .all(
                                                                                                  10),
                                                                                      child: Image
                                                                                          .asset(
                                                                                        'assets/images/ihl-plus.png',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  // Image.asset(''),
                                                                                  Card(
                                                                                      elevation: 0,
                                                                                      child: Icon(
                                                                                        Icons
                                                                                            .send_sharp,
                                                                                        color: AppColors
                                                                                            .appItemTitleTextColor,
                                                                                        size: 35,
                                                                                      )),
                                                                                  Card(
                                                                                      elevation: 0,
                                                                                      child: Image
                                                                                          .network(
                                                                                              '$logoUrl')),
                                                                                ],
                                                                              )
                                                                            : Container(
                                                                                height: 0,
                                                                                width: 0,
                                                                              ),

                                                                        // Image.network(
                                                                        //   'https://i.postimg.cc/mrDDfxQT/Group-43.png',
                                                                        // ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(10.0),
                                                                    child: RichText(
                                                                      textAlign: TextAlign.left,
                                                                      text: TextSpan(
                                                                        text:
                                                                            "By providing your consent to India Health Link (IHL) Pvt. Ltd to share your prescription and personal contact details to 1mg Technology Pvt Ltd in your own interest for your medicine order fulfillment as per the ",
                                                                        style: TextStyle(
                                                                            color: AppColors
                                                                                .appTextColor,
                                                                            //AppColors.primaryColor
                                                                            fontSize: 14),
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                "Terms & Conditions",
                                                                            style: TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                                color: Colors.blue,
                                                                                decoration:
                                                                                    TextDecoration
                                                                                        .underline),
                                                                            recognizer:
                                                                                TapGestureRecognizer()
                                                                                  ..onTap = () {
                                                                                    Get.dialog(
                                                                                        PolicyDialog(
                                                                                      title:
                                                                                          "Tele Consultation T & C",
                                                                                      mdFileName:
                                                                                          'TeleTOC.md',
                                                                                    ));
                                                                                  },
                                                                          ),
                                                                          TextSpan(text: " and "),
                                                                          TextSpan(
                                                                            text: "Privacy Policy",
                                                                            style: TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                                color: Colors.blue,
                                                                                decoration:
                                                                                    TextDecoration
                                                                                        .underline),
                                                                            recognizer:
                                                                                TapGestureRecognizer()
                                                                                  ..onTap = () {
                                                                                    Get.dialog(
                                                                                        PolicyDialog(
                                                                                      title:
                                                                                          "Privacy Policy",
                                                                                      mdFileName:
                                                                                          'PrivacyPolicy.md',
                                                                                    ));
                                                                                  },
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                ", you will be able to avail the 'Order Medicine' services.",
                                                                            style: TextStyle(
                                                                                color: AppColors
                                                                                    .appTextColor,
                                                                                //AppColors.primaryColor
                                                                                fontSize: 14),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  CheckboxListTile(
                                                                    controlAffinity:
                                                                        ListTileControlAffinity
                                                                            .leading,
                                                                    value: isAgree,
                                                                    onChanged: (val) {
                                                                      mystate(() {
                                                                        isAgree = val;
                                                                        print(isAgree);
                                                                      });
                                                                    },

                                                                    title: Text(
                                                                      'I agree to the Terms and Condition for the service',
                                                                      style: TextStyle(
                                                                          color: AppColors
                                                                              .appTextColor,
                                                                          fontSize: 12),
                                                                    ),
                                                                    // isThreeLine: false,
                                                                    contentPadding:
                                                                        EdgeInsets.only(left: 16),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(8.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        ElevatedButton(
                                                                          style: ElevatedButton
                                                                              .styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(
                                                                                          10.0),
                                                                              side: BorderSide(
                                                                                color: isAgree
                                                                                    ? AppColors
                                                                                        .primaryColor
                                                                                    : Colors.grey,
                                                                              ),
                                                                            ),
                                                                            primary: isAgree
                                                                                ? AppColors
                                                                                    .primaryColor
                                                                                : Colors.grey,
                                                                          ),
                                                                          child: Text(
                                                                            'Share',
                                                                            style: TextStyle(
                                                                                color:
                                                                                    Colors.white),
                                                                          ),
                                                                          onPressed: isAgree
                                                                              ? () {
                                                                                  sendPrescriptionTo1MG();
                                                                                  Get.close(1);
                                                                                }
                                                                              : null,
                                                                        ),
                                                                        // SizedBox(width: 10.0),
                                                                        ElevatedButton(
                                                                          style: ElevatedButton
                                                                              .styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(
                                                                                          10.0),
                                                                            ),
                                                                            primary: AppColors
                                                                                .primaryColor,
                                                                          ),
                                                                          child: Text(
                                                                            'Cancel',
                                                                            style: TextStyle(
                                                                                color:
                                                                                    Colors.white),
                                                                          ),
                                                                          onPressed: () {
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 20),
                                                                ],
                                                              );
                                                            });
                                                          });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                //notes in medicine
                                Visibility(
                                  visible: notes != null && notes.length > 0,
                                  child: Card(
                                    margin: EdgeInsets.all(10),
                                    color: AppColors.cardColor,
                                    shadowColor: FitnessAppTheme.grey.withOpacity(0.2),
                                    elevation: 2,
                                    borderOnForeground: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4),
                                        ),
                                        side: BorderSide(
                                          width: 1,
                                          color: FitnessAppTheme.nearlyWhite,
                                        )),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Notes',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: notes
                                                // dummy
                                                .map<Widget>(
                                                  (e) => Container(
                                                      padding: EdgeInsets.all(10),
                                                      child: Text(
                                                        notes != null && notes.length > 0
                                                            ? e.toString()
                                                            : '',
                                                        textAlign: TextAlign.left,
                                                      )),
                                                )
                                                .toList()),
                                      ],
                                    ),
                                  ),
                                ),

                                ///commented on 310 Dec
                                ///Files
                                Visibility(
                                  visible: medFiles != null ? medFiles.length > 0 : false,
                                  child: filesCard(),
                                ),

                                //report
                                Visibility(
                                  visible: (vendorName == 'GENIX') &&
                                          ((prescription != null &&
                                                  prescription.length > 0 &&
                                                  prescription != "N/A") ||
                                              (genixRadiology != null &&
                                                  genixRadiology.length > 0 &&
                                                  genixRadiology != "N/A") ||
                                              (labTestList != null &&
                                                  labTestList.length > 0 &&
                                                  labTestList != "N/A"))
                                      ? true
                                      : false,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      primary: AppColors.primaryColor,
                                    ),
                                    child: Text('Report',
                                        style: TextStyle(
                                          fontSize: 16,
                                        )),
                                    onPressed: () async {
                                      // AwesomeNotifications()
                                      //     .cancelAll();
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
                                        prefs.setString(
                                            "consultantNameFromHistorySummary", consultantName);
                                        prefs.setString(
                                            "consultantEmailFromHistorySummary", consultantEmail);
                                        prefs.setString(
                                            "consultantMobileFromHistorySummary", consultantMobile);
                                        prefs.setString("consultantEducationFromHistorySummary",
                                            consultantEducation);
                                        prefs.setString("consultantDescriptionFromHistorySummary",
                                            consultantDescription);

                                        prefs.setString("appointmentStartTimeFromHistorySummary",
                                            appointStartTime
                                            // appointmentStartTimeFromStages
                                            );
                                        prefs.setString("reasonForVisitFromHistorySummary",
                                            reasonOfVisitFromStages);
                                        prefs.setString(
                                            "diagnosisFromHistorySummary", diagnosislab ?? '');
                                        prefs.setString("adviceFromHistorySummary", adviceNotes);
                                        prefs.setString(
                                            "userFirstNameFromHistorySummary", firstName);
                                        prefs.setString("userLastNameFromHistorySummary", lastName);
                                        prefs.setString("userEmailFromHistorySummary", email);
                                        prefs.setString(
                                            "userContactFromHistorySummary", mobileNumber);
                                        prefs.setString(
                                            "ageFromHistorySummary", finalAge.toString());
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
                                          duration: Duration(seconds: 5),
                                          isDismissible: false,
                                        );
                                        new Future.delayed(new Duration(seconds: 2), () {
                                          genixPrescription(
                                              context: context,
                                              showPdfNotification: true,
                                              mobilenummber: mobileNumber,
                                              footer: footerDetail,
                                              allergies: _allergies,
                                              prescription: prescription,
                                              bmi: bmi,
                                              weight: weight,
                                              rmpid: rmpid,
                                              notes: notes,
                                              consultantSignature: consultantSignature,
                                              genixDaignosis: genixDiagnosis,
                                              genixRadiology: genixRadiology,
                                              kisokCheckinHistory: kisokCheckinHistory,
                                              genixLabTest: labTestList,
                                              genixLabNotes: labNotes,
                                              consultantAddress: consultantAddress,
                                              prescriptionNotes: _prescriptionNotes,
                                              appointmentId: appointId,
                                              allergy: allergy,
                                              specality: speciality,
                                              logoUrl: Image.memory(base64Decode(_imageBase64)));
                                        });
                                      } else {
                                        Get.snackbar(
                                          'Storage Access Denied',
                                          'Allow Storage permission to continue',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                          duration: Duration(seconds: 5),
                                          isDismissible: false,
                                          mainButton: TextButton(
                                            onPressed: () async {
                                              await openAppSettings();
                                            },
                                            child: Text('Allow'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),

                                //order medicine
                                Visibility(
                                  ///in issue list 6.0.5
                                  ///request came to disabe the order medicine
                                  visible: false,
                                  // visible: prescription != null &&
                                  //     prescription.length > 0 &&
                                  //     prescription != "N/A",
                                  // appointmentStatus == "Completed" ? true : false,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      primary: AppColors.primaryColor,
                                      textStyle: TextStyle(color: Colors.white),
                                    ),
                                    child: Text('Order Medicine',
                                        style: TextStyle(
                                          fontSize: 16,
                                        )),
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15.0),
                                                topRight: Radius.circular(15.0)),
                                          ),
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context, StateSetter mystate) {
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0)
                                                        .copyWith(left: 16),
                                                    child: Text(
                                                      'Share prescription ?',
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .appTextColor, //AppColors.primaryColor
                                                          fontSize: 24,
                                                          fontWeight: FontWeight.bold),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                  Divider(
                                                    indent: 10,
                                                    endIndent: 10,
                                                    thickness: 2,
                                                  ),
                                                  Expanded(
                                                    child: Align(
                                                      alignment: Alignment.center,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.network(
                                                          'https://i.postimg.cc/mrDDfxQT/Group-43.png',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: RichText(
                                                      textAlign: TextAlign.left,
                                                      text: TextSpan(
                                                        text:
                                                            "By providing your consent to India Health Link (IHL) Pvt. Ltd to share your prescription and personal contact details to 1mg Technology Pvt Ltd in your own interest for your medicine order fulfillment as per the ",
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .appTextColor, //AppColors.primaryColor
                                                            fontSize: 14),
                                                        children: [
                                                          TextSpan(
                                                            text: "Terms & Conditions",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.blue,
                                                                decoration:
                                                                    TextDecoration.underline),
                                                            recognizer: TapGestureRecognizer()
                                                              ..onTap = () {
                                                                Get.dialog(PolicyDialog(
                                                                  title: "Tele Consultation T & C",
                                                                  mdFileName: 'TeleTOC.md',
                                                                ));
                                                              },
                                                          ),
                                                          TextSpan(text: " and "),
                                                          TextSpan(
                                                            text: "Privacy Policy",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.blue,
                                                                decoration:
                                                                    TextDecoration.underline),
                                                            recognizer: TapGestureRecognizer()
                                                              ..onTap = () {
                                                                Get.dialog(PolicyDialog(
                                                                  title: "Privacy Policy",
                                                                  mdFileName: 'PrivacyPolicy.md',
                                                                ));
                                                              },
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                ", you will be able to avail the 'Order Medicine' services.",
                                                            style: TextStyle(
                                                                color: AppColors.appTextColor,
                                                                //AppColors.primaryColor
                                                                fontSize: 14),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  CheckboxListTile(
                                                    controlAffinity:
                                                        ListTileControlAffinity.leading,
                                                    value: isAgree,
                                                    onChanged: (val) {
                                                      mystate(() {
                                                        isAgree = val;
                                                        print(isAgree);
                                                      });
                                                    },

                                                    title: Text(
                                                      'I agree to the Terms and Condition for the service',
                                                      style: TextStyle(
                                                          color: AppColors.appTextColor,
                                                          fontSize: 12),
                                                    ),
                                                    // isThreeLine: false,
                                                    contentPadding: EdgeInsets.only(left: 16),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            primary: isAgree
                                                                ? Color(0xff4393cf)
                                                                : Colors.grey,
                                                            textStyle:
                                                                TextStyle(color: Colors.white),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(10.0),
                                                                side: BorderSide(
                                                                  color: isAgree
                                                                      ? Color(0xff4393cf)
                                                                      : Colors.grey,
                                                                )),
                                                          ),
                                                          child: Text(
                                                            'Share',
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                          onPressed: isAgree
                                                              ? () {
                                                                  sendPrescriptionTo1MG();
                                                                  Get.close(1);
                                                                }
                                                              : null,
                                                        ),
                                                        // SizedBox(width: 10.0),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            primary: Color(0xff4393cf),
                                                            textStyle:
                                                                TextStyle(color: Colors.white),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(10.0),
                                                                side: BorderSide(
                                                                  color: Color(0xff4393cf),
                                                                )),
                                                          ),
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 20.0),
                                                ],
                                              );
                                            });
                                          });
                                    },
                                  ),
                                ),

                                // DashBorad
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      primary: AppColors.primaryColor,
                                      textStyle: TextStyle(color: Colors.white),
                                    ),
                                    child: Text('Go to Dashboard',
                                        style: TextStyle(
                                          fontSize: 16,
                                        )),
                                    onPressed: () {
                                      Get.to(LandingPage());
                                      // Navigator.pushAndRemoveUntil(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => HomeScreen(
                                      //               introDone: true,
                                      //             )),
                                      //     (Route<dynamic> route) => false);
                                    }),
                              ],
                            ),
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget showReviewDialog() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          height: 20.0,
        ),
        Text(
          "Rate Your Experience",
          style: TextStyle(
            color: Color(0xff6D6E71),
            fontSize: 22.0,
          ),
        ),
        SizedBox(
          height: 25.0,
        ),
        Text(
          "Your Ratings",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 22.0,
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        SmoothStarRating(
          allowHalfRating: false,
          starCount: 5,
          rating: _rating,
          size: 40.0,
          isReadOnly: false,
          color: Colors.amberAccent,
          borderColor: Colors.grey,
          spacing: 0.0,
          onRated: (value) {
            if (this.mounted) {
              setState(() {
                _rating = value;
              });
            }
          },
        ),
        SizedBox(
          height: 10.0,
        ),
        TextFormField(
          autocorrect: true,
          controller: reviewTextController,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            labelText: "Your feedback for " + consultantName.toString(),
            fillColor: Colors.white24,
            border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(15.0),
                borderSide: new BorderSide(color: AppColors.primaryAccentColor)),
          ),
          style: TextStyle(fontSize: 16.0),
          textInputAction: TextInputAction.done,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                primary: AppColors.primaryColor,
                textStyle: TextStyle(color: Colors.white),
              ),
              child: Text(
                'Skip',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: submitting == true
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                primary: AppColors.primaryColor,
                textStyle: TextStyle(color: Colors.white),
              ),
              child: submitting == true
                  ? SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: new CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
              onPressed: submitting == true
                  ? null
                  : () {
                      if (this.mounted) {
                        setState(() {
                          submitting = true;
                        });
                      }
                      insertTelemedReview(reviewTextController.text, _rating);
                      Fluttertoast.showToast(
                          msg: "Submitting review!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    },
            ),
          ],
        ),
      ]));
    });
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
                borderRadius: BorderRadius.circular(10.0),
              ),
              primary: AppColors.primaryColor,
              textStyle: TextStyle(color: Colors.white),
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

  Widget filesCard() {
    return Card(
      margin: EdgeInsets.all(10),
      color: AppColors.cardColor,
      shadowColor: FitnessAppTheme.grey.withOpacity(0.2),
      elevation: 2,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
          side: BorderSide(
            width: 1,
            color: FitnessAppTheme.nearlyWhite,
          )),
      //
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(15.0),
      // ),
      // color: Color(0xfff4f6fa),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Share Medical Report" + ':',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          Container(
            height: medFiles != null
                ? (medFiles.length > 3
                    ? 400
                    : medFiles.length == 3
                        ? 290
                        : medFiles.length == 2
                            ? 180
                            : 87)
                : 1,
            child: ListView.builder(
              itemCount: medFiles != null ? medFiles.length : 0,
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
                      title: Text("${medFiles[index]['document_name']}" ?? 'N/A'),
                      subtitle: Text(
                          "${camelize(medFiles[index]['document_type'].replaceAll('_', ' '))}" ??
                              'N/A'),
                      // subtitle: Text("1.9 MB"),
                      // trailing: IconButton(icon:Icon(Icons.download),onPressed:(){
                      //   //call the download api
                      //   MedicalFilesApi.download(medFiles[index]['document_name'],medFiles[index]['document_link']);
                      // },),
                      onTap: () async {
                        print(medFiles[index]['document_link']);
                        // if(filesData[index]['document_link'].contains('pdf')){
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfView(
                              medFiles[index]['document_link'],
                              medFiles[index],
                              ihlUserId,
                              showExtraButton: false,
                            ),
                          ),
                        );
                      },
                      // checkboxTile(medFiles[index]['document_id']),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Divider(
                      thickness: 1.4,
                      height: 10.0,
                      indent: 5.0,
                      endIndent: 5.0,
                    ),
                  ],
                );
              },
            ),
          ),
          // Column(
          //   children: <Widget>[
          //     ListTile(
          //       leading: Icon(Icons.insert_drive_file),
          //       title: Text("My Scan Report.pdf"),
          //       subtitle: Text("1.9 MB"),
          //       trailing: checkboxTile('1'),
          //     ),
          //     SizedBox(
          //       height: 5.0,
          //     ),
          //     Divider(
          //       thickness: 2.0,
          //       height: 10.0,
          //       indent: 5.0,
          //     ),
          //     ListTile(
          //       leading: Icon(Icons.insert_drive_file),
          //       title: Text("My Blood Report.pdf"),
          //       subtitle: Text("1.6 MB"),
          //       trailing: checkboxTile('2'),
          //     ),
          //     SizedBox(
          //       height: 5.0,
          //     ),
          //     Divider(
          //       thickness: 2.0,
          //       height: 10.0,
          //       indent: 5.0,
          //     ),
          //     ListTile(
          //       leading: Icon(Icons.insert_drive_file),
          //       title: Text("My X-ray Report.pdf"),
          //       subtitle: Text("1.9 MB"),
          //       trailing: checkboxTile('3'),
          //     )
          //   ],
          // ),
        ],
      ),
    );
  }
}
