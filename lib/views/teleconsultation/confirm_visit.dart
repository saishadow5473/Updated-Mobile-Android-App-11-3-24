import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/utils/CheckPermi.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/screens.dart';
import 'package:ihl/views/teleconsultation/appointment_status_check.dart';
import 'package:ihl/views/teleconsultation/genix_livecall_signal.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../models/freeconsultant_model.dart';
import '../../new_design/presentation/Widgets/appBar.dart';
import '../../new_design/presentation/controllers/dashboardControllers/upComingDetailsController.dart';
import '../../new_design/presentation/pages/onlineServices/MyAppointment.dart';
import '../../utils/SpUtil.dart';
import '../cardiovascular_views/cardio_dashboard.dart';
import 'files/file_resuable_snackbar.dart';
import 'files/pdf_viewer.dart';

class ConfirmVisit extends StatefulWidget {
  final Map visitDetails;

  ConfirmVisit({this.visitDetails});

  @override
  _ConfirmVisitState createState() => _ConfirmVisitState();
}

class _ConfirmVisitState extends State<ConfirmVisit> {
  http.Client _client = http.Client(); //3gb
  bool _isPageJustEntered = true;
  bool _isPageLoaded = false;
  bool loading = false;

  // ignore: non_constant_identifier_names
  String IHL_User_ID;
  String selectedSpecality;
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;
  TextEditingController _controller = new TextEditingController();
  String email = '';
  String mobile = '';
  String height = '';
  String allergy = '';
  String reason, affiliationUniquename = 'global_services';
  String userInputWeightInKG;
  var localBMR;
  double heightMeters;
  List<dynamic> vitalList = [];
  Map vitals = {};
  bool c1 = false;
  bool c2 = false;
  bool c3 = false;
  bool c4 = false;
  bool c5 = false;
  bool c6 = false;
  bool c7 = false;
  bool c8 = false;

  bool f1 = false;
  bool f2 = false;
  bool f3 = false;
  List<String> selectedDocIdList = [];
  List medFiles = [];
  List filesNameList = [];
  bool enableMedicalFilesTile = false;
  bool showMedicalFilesCard = false;

  bool threeweekData = false;
  bool threemonthData = false;
  bool sixmonthData = false;

  bool vitalsShare = false;

  bool mobilechar = false;

  TextEditingController dateController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController allergyController = TextEditingController();
  var bookedDate;

  @override
  void initState() {
    super.initState();
    liveCCall = widget.visitDetails['doctor']['livecall'];
    getDetails();
    _controller.addListener(() => _extension = _controller.text);
    if (this.mounted) {
      setState(() {
        mobilechar = mobileController.text.contains(RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)'));
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _isPageLoaded = true);
  }

  bool liveCCall = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  // ignore: missing_return
  String emailValidator(String mail) {
    mail.contains(
        RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'),
        0);
  }

  void getDetails() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    IHL_User_ID = prefs1.getString("ihlUserId");
    selectedSpecality = prefs1.getString("selectedSpecality");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.get('email');
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    var mobileNumber = res['User']['mobileNumber'];
    var dob = res['User']['dateOfBirth'].toString();

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

    if (mounted) {
      setState(() {
        var date = DateFormat('mm/DD/yyyy').parse(dob);
        print(date);
        dateController.text = DateFormat('dd/MM/yyyy').format(date) ?? '';
        emailController.text = email ?? '';
        mobileController.text = mobileNumber.toString().replaceAll(new RegExp(r"\s+"), "") ?? '';

        ///medical files api set state
        medFiles;
        enableMedicalFilesTile = medFiles.length > 0 ? true : false;
      });
    }
    vitals = res["LastCheckin"] ?? {};

    if (vitals != null || vitals.isNotEmpty || vitals != {}) {
      vitals.removeWhere((key, value) =>
          key != "dateTimeFormatted" &&
          //pulsebpm
          key != "diastolic" &&
          key != "systolic" &&
          key != "pulseBpm" &&
          key != "bpClass" &&
          //BMC
          key != "fatRatio" &&
          key != "fatClass" &&
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
    } else {
      userInputWeightInKG = SpUtil.getString(LSKeys.weight);
      heightMeters = SpUtil.getDouble(LSKeys.height);
      localBMR = SpUtil.getDouble("localBMI");
      vitals["bmi"] = localBMR.toStringAsFixed(2);
      vitals["weightKG"] = double.parse((userInputWeightInKG)).toStringAsFixed(2);
      vitals["heightMeters"] = heightMeters.toStringAsFixed(2);
    }
    /* if (DateTime.tryParse(vitalData[0]['vitals']['dateTime'].toString())
        .isBefore(DateTime.now().subtract(Duration(days: 21)))) {
      setState(() {
        threeweekData = true;
      });
    } else if (DateTime.tryParse(vitalData[0]['vitals']['dateTime'].toString())
        .isBefore(DateTime.now().subtract(Duration(days: 90)))) {
      setState(() {
        threemonthData = true;
      });
    } else if (DateTime.tryParse(vitalData[0]['vitals']['dateTime'].toString())
        .isBefore(DateTime.now().subtract(Duration(days: 180)))) {
      setState(() {
        sixmonthData = true;
      });
    } else {}*/
    setState(() {});
  }

  bool validate() {
    if (_isPageLoaded) _isPageJustEntered = false;
    if (emailValidator(emailController.text) == null &&
        phoneValidator(mobileController.text) == null &&
        reason.toString() != 'null' &&
        reasonValidator(reason) == null) {
      return true;
    }
    return false;
  }

  // ignore: missing_return
  String reasonValidator(String ip) {
    if (ip.toString() == 'null' && _isPageJustEntered == true) {
      return null;
    } else if (ip.toString() == 'null') {
      return 'Reason for Appointment';
    }
    if (ip.length < 1) {
      return 'Reason for Appointment';
    }
    if (ip.length < 4) {
      return 'Reason should be at least 4 character long';
    }
    if (ip.toString() == 'no value') {
      return 'Reason for Appointment';
    }
  }

  // ignore: missing_return
  String fileValidator(String ip) {
    if (showMedicalFilesCard) {
      if (selectedDocIdList.length < 0) {
        return 'Select At least One file Or Uncheck the CheckBox';
      }
    }
    // if (ip.length < 4) {
    //   return 'Reason should be at least 4 character long';
    // }
  }

  // ignore: missing_return
  String phoneValidator(String numb) {
    int tryp = int.tryParse(numb);
    if (tryp.toString().length < 10) {
      return 'The mobile number must be 10 digits.';
    }
  }

  // ignore: missing_return
  ///_openfileexplorer  commented during the feature of medical files because it is not used in this files
  ///and having same name as another folder were giving error
  // void _openFileExplorer() async {
  //   if (_pickingType != FileType.custom || _hasValidMime) {
  //     if (this.mounted) {
  //       setState(() => _loadingPath = true);
  //     }
  //     try {
  //       if (_multiPick) {
  //         _path = null;
  //         _paths = (await FilePicker.platform.pickFiles(
  //             type: _pickingType,
  //             allowedExtensions: [_extension],
  //             allowMultiple: true)) as Map<String, String>;
  //       } else {
  //         _paths = null;
  //         _path = (await FilePicker.platform.pickFiles(
  //             type: _pickingType,
  //             allowedExtensions: [_extension],
  //             allowMultiple: false)) as String;
  //       }
  //     } on PlatformException catch (e) {
  //       print("Unsupported operation" + e.toString());
  //     }
  //     if (!mounted) return;
  //     if (this.mounted) {
  //       setState(() {
  //         _loadingPath = false;
  //         _fileName = _path != null
  //             ? _path.split('/').last
  //             : _paths != null
  //                 ? _paths.keys.toString()
  //                 : '...';
  //       });
  //     }
  //   }
  // }

  String dateTimeToString(DateTime dateTime) {
    DateFormat ipF = DateFormat("dd/MM/yyyy");
    return ipF.format(dateTime);
  }

  String formattedStartDate;
  String formattedEndDate;
  var iHLUserId;
  var appointmentId;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (loading) {
          return null;
        } else {
          Navigator.pop(context, true);
        }
      },
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: BasicPageUI(
            appBar: Column(
              children: [
                SizedBox(
                  width: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: loading ? () {} : () => Navigator.of(context).pop(),
                      color: Colors.white,
                      tooltip: 'Back',
                    ),
                    Text(
                      AppTexts.confirmVisitTitle,
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                    SizedBox(
                      width: 40,
                    )
                  ],
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  visitDetails(),
                  SizedBox(
                    height: 20.0,
                  ),
                  contactCard(),
                  SizedBox(
                    height: 20.0,
                  ),
                  reasonCard(),
                  SizedBox(
                    height: 20.0,
                  ),
                  // widget.visitDetails['doctor']['vendor_id'] == "Genix" ||
                  //         widget.visitDetails['doctor']['vendor_id'] == "GENIX"
                  //     ? SizedBox(
                  //         height: 0.0,
                  //       )
                  //     : vitalsCard(),
                  vitalsCard(),
                  SizedBox(
                    height: 20.0,
                  ),
                  Visibility(visible: showMedicalFilesCard, child: filesCard()),
                  SizedBox(
                    height: 20.0,
                  ),
                  // TextButton(
                  //     onPressed: () {
                  //       if (c8) {
                  //         vitals['bmi'] = vitals['bmi'].toStringAsFixed(2);
                  //       }
                  //       log(vitals.toString());
                  //     },
                  //     child: Text('text'))
                  confirmButton()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map dataToSend() {
    String appStartDate = widget.visitDetails['date'] + ' ' + widget.visitDetails['time'];
    var appEndTime = DateFormat('hh:mm a').parse(widget.visitDetails['time']);
    var appEndTimeString =
        DateFormat('hh:mm a').format(appEndTime.add(Duration(minutes: 30))).toString();
    String appointmentStartDateToSend = "";
    String appointmentEndDateToSend = "";
    DateTime currentDate = DateTime.now();

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
          currentDate.year.toString() + "-" + mm + "-" + dd + ' ' + widget.visitDetails['time'];

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
          widget.visitDetails['time'];

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
          widget.visitDetails['time'];
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
          widget.visitDetails['time'];
      appointmentEndDateToSend = currentDate.year.toString() +
          "-" +
          currentDateMonth +
          "-" +
          currentDateDay +
          ' ' +
          appEndTimeString;
    }

    // if(selectedDocIdList.length>0){
    widget.visitDetails['doctor']['livecall'] = liveCCall;
    return {
      'start_date': appointmentStartDateToSend,
      'end_date': appointmentEndDateToSend,
      'doctor': widget.visitDetails['doctor'],
      'reason': reasonController.text ?? "",
      'alergy': allergyController.text ?? "",
      'data': c1 == true ? vitalList : [],
      'livecall': liveCCall,
      'fees': widget.visitDetails['affiliationPrice'] != "none"
          ? widget.visitDetails['affiliationPrice']
          : widget.visitDetails['doctor']['consultation_fees'],
      'specality': selectedSpecality.toString().trim(),
      'email': emailController.text,
      'mobile_number': mobileController.text,
      'document_id': selectedDocIdList,
    };
  }

  void freeConsultationProceed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    vitals = res["LastCheckin"] ?? {};

    if (vitals != null || vitals.isNotEmpty) {
      vitals.removeWhere((key, value) =>
          key != "dateTimeFormatted" &&
          //pulsebpm
          key != "diastolic" &&
          key != "systolic" &&
          key != "pulseBpm" &&
          key != "bpClass" &&
          //BMC
          key != "fatRatio" &&
          key != "fatClass" &&
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
    // 05th August
    // august 1 2022
    String appStartDate = widget.visitDetails['date'] + ' ' + widget.visitDetails['time'];
    var appEndTime = DateFormat('hh:mm a').parse(widget.visitDetails['time']);
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
          currentDate.year.toString() + "-" + mm + "-" + dd + ' ' + widget.visitDetails['time'];

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
          widget.visitDetails['time'];

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
          widget.visitDetails['time'];
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
          widget.visitDetails['time'];
      appointmentEndDateToSend = currentDate.year.toString() +
          "-" +
          currentDateMonth +
          "-" +
          currentDateDay +
          ' ' +
          appEndTimeString;
    }

    formattedStartDate = changeDateFormat(appointmentStartDateToSend.toString());
    formattedEndDate = changeDateFormat(appointmentEndDateToSend.toString());

    print(formattedStartDate);
    print(formattedEndDate);

    iHLUserId = res['User']['id'];
    String _firstname = res['User']['firstName'];
    String _lastname = res['User']['lastName'];
    String apiToken = prefs.get('auth_token');
    prefs.setString('consultantName', widget.visitDetails['doctor']['name'].toString());
    prefs.setString('consultantId', widget.visitDetails['doctor']['ihl_consultant_id'].toString());
    prefs.setString('vendorName', widget.visitDetails['doctor']['vendor_id'].toString());
    prefs.setString('vendorConId', widget.visitDetails['doctor']['ihl_consultant_id'].toString());
    if (c8) {
      vitals['dateTime'] = vitals['dateTimeFormatted'];
      if (vitals['temperature'] != null &&
          widget.visitDetails['doctor']['vendor_id'].toString() == 'GENIX')
        vitals['temperature'] = (vitals['temperature'] * 9 / 5) + 32;
    }
    log(vitals.toString());
    Map purposeDetails = {
      "name": "$_firstname $_lastname",
      "user_ihl_id": iHLUserId.toString(),
      "consultant_name": widget.visitDetails['doctor']['name'].toString(),
      "vendor_consultant_id": widget.visitDetails['doctor']['vendor_consultant_id'].toString(),
      "ihl_consultant_id": widget.visitDetails['doctor']['ihl_consultant_id'].toString(),
      "vendor_id": widget.visitDetails['doctor']['vendor_id'].toString(),
      "specality": selectedSpecality.toString().trim(),
      "consultation_fees": '0',
      "mode_of_payment": "online",
      "alergy": allergyController.text.toString() ?? "",
      "kiosk_checkin_history": (vitals != null && vitals.isNotEmpty) && c8
          ? vitals
          : (vitals != null && vitals.isNotEmpty)
              ? {
                  "weightKG": vitals["weightKG"],
                  "bmi": vitals["bmi"],
                  'heightMeters': vitals["heightMeters"]
                }
              : {},
      "appointment_start_time": formattedStartDate.toString(), //yyyy-mm-dd 03:00 PM
      "appointment_end_time": formattedEndDate.toString(),
      "appointment_duration": "30 Min",
      "appointment_status": "Requested",
      "direct_call": liveCCall,
      "vendor_name": widget.visitDetails['doctor']['vendor_id'].toString(),
      "appointment_model": "appointment",
      "reason_for_visit": reasonController.text.toString(),
      "notes": "",
      "document_id": selectedDocIdList,
    };
    bookedDate = bookingDate();
    print(vitals);
    FreeConsultation _freeConsultation = FreeConsultation(
      purposeDetails: jsonEncode(purposeDetails),
      kioskCheckinHistory: (vitals != null && vitals.isNotEmpty) && c8
          ? vitals
          : (vitals != null && vitals.isNotEmpty)
              ? {
                  "weightKG": vitals["weightKG"],
                  "bmi": vitals["bmi"],
                  'heightMeters': vitals["heightMeters"]
                }
              : {},
      userIhlId: iHLUserId.toString(),
      consultantName: widget.visitDetails['doctor']['name'].toString(),
      vendorConsultantId: widget.visitDetails['doctor']['vendor_consultant_id'].toString(),
      ihlConsultantId: widget.visitDetails['doctor']['ihl_consultant_id'].toString(),
      vendorId: widget.visitDetails['doctor']['vendor_id'].toString(),
      specality: selectedSpecality.toString().trim(),
      modeOfPayment: 'free',
      alergy: allergyController.text.toString() ?? "",
      appointmentStartTime: formattedStartDate.toString(),
      appointmentEndTime: formattedEndDate.toString(),
      appointmentDuration: "30 Min",
      appointmentStatus: liveCCall == true ? "Approved" : "Requested",
      vendorName: widget.visitDetails['doctor']['vendor_id'].toString(),
      appointmentModel: 'appointment',
      reasonForVisit: reasonController.text.toString(),
      documentId: selectedDocIdList,
      directCall: liveCCall,
      accountName: widget.visitDetails['doctor']['vendor_id'].toString() == "GENIX"
          ? widget.visitDetails['doctor']['account_name'].toString()
          : '',
      affiliationUniqueName: Tabss.isAffi ? 'global_services' : affiliationUniquename,
      date: widget.visitDetails['date'],
      userMobileNumber: mobileController.text,
      userEmail: emailController.text,
      usageType: "Free",
      mobileNumber: mobileController.text,
      paymentFor: "teleconsultation",
      paymentStatus: "completed",
      purpose: 'teleconsult',
      time: widget.visitDetails['time'],
      serviceProvided: 'false',
      serviceProvidedDate: bookedDate[0],
      sourceDevice: 'mobile_app',
    );
    log(json.encode(_freeConsultation.toJson().toString()));
    log('Start Time');
    log(json.encode(_freeConsultation.toJson()));
    log(DateTime.now().toString());
    var _token = API.headerr['Token'];
    var _freeRes = await http.post(
      // Uri.parse('https://6915-103-182-121-26.ngrok-free.app' + '/consult/free_consultation'),
      Uri.parse('${API.iHLUrl}/consult/free_consultation'),
      body: json.encode(_freeConsultation.toJson()),
      headers: {
        'ApiToken':
            '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==',
        'Token': '$_token',
      },
    );
    log('Start Time');

    log(DateTime.now().toString());

    // widget.visitDetails['doctor']['vendor_id'].toString() == "GENIX" && widget.visitDetails['livecall'] == true ? true:false,
    if (_freeRes.statusCode == 200) {
      log(json.encode(_freeConsultation.toJson()));
      print(_freeRes.body);
      var _data = json.decode(_freeRes.body);

      var appointmentStatus = _data['BookApointment_status'];
      var paymentStatus = _data['PaymentTransaction_status'];

      var appointmentStatus1 = appointmentStatus.replaceAll('&quot;', '"');
      var appointmentStatus2 = json.decode(appointmentStatus1);
      if (appointmentStatus2['status'] == 'success') {
        var appointId = appointmentStatus2[
            'appointment_id']; //'ihl_consultant_' + finalResponse['appointment_id'];
        var vendorAppointId = appointmentStatus2['vendor_appointment_id'];
        appointmentId = appointmentStatus2['appointment_id'];
        if (paymentStatus['status'] == 'inserted') {
          var invoiceNumber = paymentStatus['invoice_number'];
          var transactionId = paymentStatus['transaction_id'];

          var data = prefs.get('data');
          Map res = jsonDecode(data);
          String userFirstName, userLastName, ihlUserName;
          userFirstName = res['User']['firstName'];
          userLastName = res['User']['lastName'];
          userFirstName ??= "";
          userLastName ??= "";
          ihlUserName = "$userFirstName $userLastName";
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: true,
              dialogType: DialogType.SUCCES,
              dismissOnTouchOutside: false,
              title: 'Success!',
              desc: liveCCall
                  ? "Appointment confirmed! Join in and kindly wait for the doctor to connect."
                  : 'Appointment Booked Successfully',
              btnOkOnPress: () {
                if (liveCCall == true) {
                  if (widget.visitDetails['doctor']['vendor_id'].toString() == 'GENIX') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenixLiveSignal(
                          // genixAppointId: appointId.toString().replaceAll('ihl_consultant_', ''),
                          genixAppointId: appointmentId,
                          iHLUserId: iHLUserId.toString(),
                          specality: selectedSpecality.toString().trim(),
                          vendor_consultant_id:
                              widget.visitDetails['doctor']['vendor_consultant_id'].toString(),
                          vendorConsultantId:
                              widget.visitDetails['doctor']['vendor_consultant_id'].toString(),
                          vendorAppointmentId: vendorAppointId,
                          vendorUserName: widget.visitDetails['doctor']['user_name'],
                        ),
                      ), //user_name
                    );
                  } else {
                    Get.offNamedUntil(Routes.CallWaitingScreen, (route) => false, arguments: [
                      appointId.toString(),
                      widget.visitDetails['doctor']['ihl_consultant_id'].toString(),
                      iHLUserId.toString(),
                      "LiveCall",
                      ihlUserName
                    ]);
                  }
                } else {
                  Get.find<UpcomingDetailsController>().updateUpcomingDetails(fromChallenge: false);
                  Get.to(MyAppointment(backNav: false));
                }
              },
              btnOkText: liveCCall == true ? 'Join Call' : 'View My Appointments',
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        } else {
          if (this.mounted) {
            setState(() {
              loading = false;
            });
          }
          AwesomeDialog(
                  context: context,
                  animType: AnimType.TOPSLIDE,
                  headerAnimationLoop: true,
                  dialogType: DialogType.INFO,
                  dismissOnTouchOutside: false,
                  title: 'Failed!',
                  desc: 'Appointment not Booked. Please try again later.',
                  btnOkOnPress: () {
                    Navigator.of(context).pop();
                  },
                  btnOkColor: AppColors.primaryAccentColor,
                  btnOkText: 'Try Later',
                  btnOkIcon: Icons.refresh,
                  onDismissCallback: (_) {})
              .show();
        }
      } else if (liveCCall == true) {
        if (this.mounted) {
          setState(() {
            loading = false;
          });
        }
        Get.defaultDialog(title: 'Busy', middleText: 'Consultant have appointment');
      }
    } else {
      if (this.mounted) {
        setState(() {
          loading = false;
        });
      }
      AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: true,
              dialogType: DialogType.INFO,
              dismissOnTouchOutside: false,
              title: 'Failed!',
              desc: 'Appointment not Booked. Please try again later.',
              btnOkOnPress: () {
                Navigator.of(context).pop();
              },
              btnOkColor: AppColors.primaryAccentColor,
              btnOkText: 'Try Later',
              btnOkIcon: Icons.refresh,
              onDismissCallback: (_) {})
          .show();
    }
  }

  Widget visitDetails() {
    return Card(
      elevation: 2,
      shadowColor: FitnessAppTheme.grey,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: FitnessAppTheme.nearlyWhite, width: 2)),
      color: FitnessAppTheme.white,
      // color: Color(0xfff4f6fa),
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(15.0),
      // ),
      // color: Color(0xfff4f6fa),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          const Center(
            child: Text(
              "Visit Details",
              style: TextStyle(
                color: AppColors.primaryAccentColor,
                fontSize: 22.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundImage: widget.visitDetails['doctor']['profile_picture'] == null
                        ? null
                        : Image.memory(
                                base64Decode(widget.visitDetails['doctor']['profile_picture']))
                            .image,
                    backgroundColor: AppColors.primaryAccentColor,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.visitDetails['doctor']['name'].toString(),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      RichText(
                        softWrap: true,
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text:
                                    widget.visitDetails['date'].toString().toCapitalized() + '\n'),
                            TextSpan(text: widget.visitDetails['time'].toString()),
                          ],
                          style: TextStyle(
                            fontFamily: "Poppins",
                            color: AppColors.appTextColor,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget confirmButton() {
    return AnimatedContainer(
      curve: Curves.easeInOutCubic,
      width: loading ? 80 : 250,
      height: loading ? 45 : 40,
      duration: Duration(milliseconds: 400),
      child: IgnorePointer(
        ignoring: loading,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            fixedSize: Size.fromWidth(MediaQuery.of(context).size.width / 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
          child: loading
              ? Padding(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  "Confirm",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
          onPressed: validate()
              ? () async {
                  // widget.visitDetails['doctor']['consultation_fees'] = '10';
                  if (this.mounted) {
                    setState(() {
                      loading = true;
                    });
                  }
                  DateTime _now = DateTime.now();
                  DateTime _lastAppointmentTime = _now.subtract(Duration(minutes: 15));

                  bool _callAllowed = false;
                  if (liveCCall) {
                    var appointmentStatus = await AppointmentStatusChecker()
                        .getConsultantLatestAppointments(
                            consultId:
                                widget.visitDetails['doctor']['ihl_consultant_id'].toString());
                    if (appointmentStatus.length > 0) {
                      if (_now.day ==
                          DateFormat('yyyy-MM-dd hh:mm a')
                              .parse(appointmentStatus[0].bookApointment.appointmentStartTime)
                              .day) {
                        _lastAppointmentTime = DateFormat('yyyy-MM-dd hh:mm a')
                            .parse(appointmentStatus[0].bookApointment.appointmentStartTime);
                        if (_now.difference(_lastAppointmentTime) < Duration(minutes: 30) &&
                            appointmentStatus[0].bookApointment.callStatus == 'on_going') {
                          _callAllowed = true;
                        } else {
                          _callAllowed = false;
                        }
                      }
                    }
                  } else {
                    _callAllowed = false;
                  }
                  if (_callAllowed) {
                    if (this.mounted) {
                      setState(() {
                        loading = false;
                      });
                    }
                    Get.defaultDialog(title: 'Busy', middleText: 'Consultant have appointment');
                  } else {
                    try {
                      affiliationUniquename = widget.visitDetails['doctor']
                              ['affilation_excusive_data']['affilation_array'][0]
                          ['affilation_unique_name'];
                    } catch (e) {
                      affiliationUniquename = 'global_services';
                    }
                    var fees = widget.visitDetails['affiliationPrice'] != "none"
                        ? widget.visitDetails['affiliationPrice']
                        : widget.visitDetails['doctor']['consultation_fees'];
                    widget.visitDetails['doctor']['livecall'] = liveCCall;
                    setState(() {});
                    if (fees == 'Free' ||
                        fees == 'free' ||
                        fees == 'FREE' ||
                        fees == 'N/A' ||
                        fees == '0' ||
                        fees == '00' ||
                        fees == '000' ||
                        fees == '0000' ||
                        fees == '000000') {
                      if (this.mounted) {
                        setState(() {
                          loading = true;
                        });
                      }
                      freeConsultationProceed();
                    } else {
                      if (this.mounted) {
                        setState(() {
                          loading = true;
                        });
                      }
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      var data = prefs.get('data');
                      Map res = jsonDecode(data);
                      iHLUserId = res['User']['id'];
                      String apiToken = prefs.get('auth_token');
                      prefs.setString(
                          'consultantName', widget.visitDetails['doctor']['name'].toString());
                      prefs.setString('consultantId',
                          widget.visitDetails['doctor']['ihl_consultant_id'].toString());
                      prefs.setString(
                          'vendorName', widget.visitDetails['doctor']['vendor_id'].toString());
                      prefs.setString('vendorConId',
                          widget.visitDetails['doctor']['ihl_consultant_id'].toString());
                      var isExclusive = widget.visitDetails['doctor']['exclusive_only'];
                      var affiliationUniqueName;
                      try {
                        affiliationUniqueName = widget.visitDetails['doctor']
                                ['affilation_excusive_data']['affilation_array'][0]
                            ['affilation_unique_name'];
                      } catch (e) {
                        affiliationUniqueName = "global_services";
                      }

                      var affiliationMRP;
                      try {
                        affiliationMRP = widget.visitDetails['doctor']['affilation_excusive_data']
                            ['affilation_array'][0]['affilation_mrp'];
                      } catch (e) {
                        affiliationMRP = null;
                      }
                      var affiliationPrice;
                      try {
                        affiliationPrice = widget.visitDetails['doctor']['affilation_excusive_data']
                            ['affilation_array'][0]['affilation_price'];
                      } catch (e) {
                        affiliationPrice = null;
                      }
                      var discountPrice;
                      try {
                        discountPrice =
                            double.parse(affiliationMRP) - double.parse(affiliationPrice);
                      } catch (e) {
                        discountPrice = null;
                      }
                      bookedDate = bookingDate();
                      if (c8) {
                        vitals['dateTime'] = vitals['dateTimeFormatted'];
                        if (vitals['temperature'] != null &&
                            widget.visitDetails['doctor']['vendor_id'].toString() == 'GENIX')
                          vitals['temperature'] = (vitals['temperature'] * 9 / 5) + 32;
                      }
                      Map purposeDetails = {
                        "user_ihl_id": iHLUserId.toString(),
                        "consultant_name": widget.visitDetails['doctor']['name'].toString(),
                        "vendor_consultant_id":
                            widget.visitDetails['doctor']['vendor_consultant_id'].toString(),
                        "ihl_consultant_id":
                            widget.visitDetails['doctor']['ihl_consultant_id'].toString(),
                        "vendor_id": widget.visitDetails['doctor']['vendor_id'].toString(),
                        "specality": selectedSpecality.toString().trim(),
                        "consultation_fees": fees.toString(),
                        "mode_of_payment": "online",
                        "alergy": allergyController.text.toString() ?? "",
                        "kiosk_checkin_history": (vitals != null || vitals.isNotEmpty) && c8
                            ? vitals
                            : (vitals != null || vitals.isNotEmpty)
                                ? {
                                    "weightKG": vitals["weightKG"],
                                    "bmi": vitals["bmi"],
                                    "heightMeters": vitals["heightMeters"]
                                  }
                                : {},
                        "appointment_start_time":
                            formattedStartDate.toString(), //yyyy-mm-dd 03:00 PM
                        "appointment_end_time": formattedEndDate.toString(),
                        "appointment_duration": "30 Min",
                        "appointment_status": "Requested",
                        "direct_call": liveCCall,
                        "vendor_name": widget.visitDetails['doctor']['vendor_name'].toString(),
                        "appointment_model": "appointment",
                        "reason_for_visit": reasonController.text.toString(),
                        "notes": ""
                      };
                      log(purposeDetails.toString());
                      // final paymentInitiateResponse = await _client.post(
                      //   Uri.parse(API.iHLUrl + "/data/paymenttransaction"),
                      //   headers: {
                      //     'Content-Type': 'application/json',
                      //     // 'ApiToken': '${API.headerr['ApiToken']}',
                      //     'ApiToken':
                      //         '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==',
                      //     'Token': '${API.headerr['Token']}',
                      //   },
                      //   // headers: {
                      //   //   'ApiToken':
                      //   //       '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==',
                      //   // },
                      //   body: jsonEncode(<String, String>{
                      //     'MRPCost': affiliationMRP.toString(),
                      //     'Discounts': discountPrice.toString(),
                      //     'ConsultantID':
                      //         widget.visitDetails['doctor']['ihl_consultant_id'].toString(),
                      //     'ConsultantName': widget.visitDetails['doctor']['name'].toString(),
                      //     'PurposeDetails': jsonEncode(purposeDetails),
                      //     'purpose': 'teleconsult',
                      //     'AppointmentID': '',
                      //     'AffilationUniqueName': affiliationUniqueName,
                      //     'Service_Provided': 'false',
                      //     'SourceDevice': 'mobile_app',
                      //     'user_ihl_id': iHLUserId,
                      //     'user_email': emailController.text,
                      //     'user_mobile_number': mobileController.text,
                      //     'TotalAmount': widget.visitDetails['affiliationPrice'] != "none"
                      //         ? widget.visitDetails['affiliationPrice']
                      //         : widget.visitDetails['doctor']['consultation_fees'],
                      //     "MobileNumber": mobileController.text,
                      //     "payment_status": "initiated",
                      //     "vendor_name": widget.visitDetails['doctor']['vendor_id'].toString(),
                      //     //account_name
                      //     "account_name":
                      //         widget.visitDetails['doctor']['vendor_id'].toString() == "GENIX"
                      //             ? widget.visitDetails['doctor']['account_name'].toString()
                      //             : '',
                      //     "service_provided_date":
                      //         bookedDate[0] //appointment or subscription start date
                      //     // "service_provided_date":"2020-11-30 05:51 PM"//appointment or subscription start date
                      //   }),
                      // );
                      // if (paymentInitiateResponse.statusCode == 300) {
                      // if (paymentInitiateResponse.statusCode == 200) {
                      // print(paymentInitiateResponse.body);
                      /*{"status": "inserted","invoice_number": "IHL-21-22/0000000003"}*/
                      // var parsedString = paymentInitiateResponse.body;
                      // var finalResponse = json.decode(parsedString);
                      // var invoiceNumber = finalResponse['invoice_number'];
                      // var transactionId = finalResponse['transaction_id'];

                      var sendData = dataToSend();
                      sendData['purposeDetails'] = purposeDetails;
                      sendData['affiliationPrice'] = widget.visitDetails['affiliationPrice'];
                      // sendData['invoiceNumber'] = invoiceNumber;
                      // sendData['transaction_id'] = transactionId;
                      if (mounted) {
                        setState(() {
                          loading = false;
                        });
                      }
                      log("liveCall ======== ${sendData.toString()}");
                      Navigator.of(context).pushNamed(Routes.Telepayment, arguments: sendData);
                      // } else {
                      //   print(paymentInitiateResponse.body);
                      //   if (mounted) {
                      //     setState(() {
                      //       loading = false;
                      //     });
                      //   }
                      //   print('atleast this print is working......    failed...');
                      //   AwesomeDialog(
                      //           context: context,
                      //           animType: AnimType.TOPSLIDE,
                      //           headerAnimationLoop: true,
                      //           dialogType: DialogType.ERROR,
                      //           dismissOnTouchOutside: false,
                      //           title: 'Failed!',
                      //           desc: 'Payment initiation failed! Please try again',
                      //           btnOkOnPress: () {
                      //             Navigator.of(context).pop(true);
                      //           },
                      //           btnOkColor: Colors.red,
                      //           btnOkText: 'Done',
                      //           onDismissCallback: (_) {})
                      //       .show();
                      //   print(paymentInitiateResponse.body);
                      // }
                    }
                  }
                }
              : null,
        ),
      ),
    );
  }

  Widget contactCard() {
    return Card(
      elevation: 2,
      shadowColor: FitnessAppTheme.grey,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: FitnessAppTheme.nearlyWhite, width: 2)),
      // color: Color(0xfff4f6fa),
      color: FitnessAppTheme.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Contact details",
              style: TextStyle(
                color: AppColors.primaryAccentColor,
                fontSize: 22.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: TextFormField(
              controller: emailController,
              onChanged: (value) {
                if (this.mounted) {
                  setState(() {
                    email = value;
                  });
                }
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Icon(Icons.email),
                ),
                labelText: "Email address",
                fillColor: Colors.white24,
                border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(color: Colors.blueGrey)),
              ),
              keyboardType: TextInputType.emailAddress,
              maxLines: 1,
              style: TextStyle(fontSize: 16.0),
              textInputAction: TextInputAction.done,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: TextFormField(
              controller: mobileController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your mobile number';
                } else if ((!(mobilechar)) && value.isNotEmpty) {
                  return "Invalid mobile number";
                }
                return null;
              },
              autocorrect: true,
              maxLength: 10,
              onChanged: (value) {
                if (this.mounted) {
                  setState(() {
                    mobile = value;
                  });
                }
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Icon(Icons.phone),
                ),
                errorText: phoneValidator(mobileController.text),
                labelText: "Mobile Number",
                fillColor: Colors.white24,
                border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(color: Colors.blueGrey)),
              ),
              keyboardType: TextInputType.number,
              maxLines: 1,
              style: TextStyle(fontSize: 16.0),
              textInputAction: TextInputAction.done,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: TextFormField(
              onTap: () async {
                DateTime date = DateTime(1900);
                FocusScope.of(context).requestFocus(new FocusNode());

                date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100));
                if (date != null) {
                  dateController.text = dateTimeToString(date);
                }
              },
              readOnly: true,
              controller: dateController,
              autocorrect: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Icon(FontAwesomeIcons.calendar),
                ),
                labelText: "Date of birth(DD/MM/YYYY)",
                fillColor: Colors.white24,
                border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                    borderSide: new BorderSide(color: Colors.blueGrey)),
              ),
              keyboardType: TextInputType.number,
              maxLines: 1,
              style: TextStyle(fontSize: 16.0),
              textInputAction: TextInputAction.done,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: TextFormField(
              controller: allergyController,
              autocorrect: true,
              onChanged: (value) {
                allergy = value;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                labelText: "Food or medicine allergies, if any",
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
        ],
      ),
    );
  }

  Widget reasonCard() {
    return Card(
      elevation: 2,
      shadowColor: FitnessAppTheme.grey,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: FitnessAppTheme.nearlyWhite, width: 2)),
      // color: Color(0xfff4f6fa),
      color: FitnessAppTheme.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                text: 'Reason for Visit ',
                style: TextStyle(
                  color: AppColors.primaryAccentColor,
                  fontFamily: "Poppins",
                  fontSize: ScUtil().setSp(22.0),
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '*',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: ScUtil().setSp(22.0),
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
            child: TextFormField(
              controller: reasonController,
              onChanged: (value) {
                if (this.mounted) {
                  setState(() {
                    reason = value;
                  });
                }
              },
              maxLength: 150,
              autocorrect: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                labelText: "Example: Fever, Cold, etc.",
                errorText: reasonValidator(reason),
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
        ],
      ),
    );
  }

  Widget filesCard() {
    print('=============================$IHL_User_ID');
    iHLUserId = IHL_User_ID;
    print('=============================$iHLUserId');
    return Card(
      elevation: 2,
      shadowColor: FitnessAppTheme.grey,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: FitnessAppTheme.nearlyWhite, width: 2)),
      // color: Color(0xfff4f6fa),
      color: FitnessAppTheme.white,
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
          SizedBox(
            height: medFiles.length > 3
                ? 400
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
                  width: 150.0,
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

  ///upload card commented during the feature of medical files because it is not used in this files
  // Widget uploadCard() {
  //   return Card(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(15.0),
  //     ),
  //     color: Color(0xfff4f6fa),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Center(
  //             child: Text(
  //               "Upload files to share(if any)",
  //               style: TextStyle(
  //                 color: AppColors.primaryAccentColor,
  //                 fontSize: 22.0,
  //               ),
  //             ),
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: IconButton(
  //             icon: Icon(
  //               Icons.cloud_upload,
  //               size: 50.0,
  //             ),
  //             onPressed: () {
  //               _openFileExplorer();
  //             },
  //           ),
  //         ),
  //         Builder(
  //           builder: (BuildContext context) => _loadingPath
  //               ? Padding(
  //                   padding: const EdgeInsets.only(bottom: 10.0),
  //                   child: const CircularProgressIndicator())
  //               : _path != null || _paths != null
  //                   ? new Container(
  //                       padding: const EdgeInsets.only(bottom: 30.0),
  //                       height: MediaQuery.of(context).size.height * 0.50,
  //                       child: new Scrollbar(
  //                           child: new ListView.separated(
  //                         itemCount: _paths != null && _paths.isNotEmpty
  //                             ? _paths.length
  //                             : 1,
  //                         itemBuilder: (BuildContext context, int index) {
  //                           final bool isMultiPath =
  //                               _paths != null && _paths.isNotEmpty;
  //                           final String name = 'File $index: ' +
  //                               (isMultiPath
  //                                   ? _paths.keys.toList()[index]
  //                                   : _fileName ?? '...');
  //                           final path = isMultiPath
  //                               ? _paths.values.toList()[index].toString()
  //                               : _path;
  //
  //                           return new ListTile(
  //                             title: new Text(
  //                               name,
  //                             ),
  //                             subtitle: new Text(path),
  //                           );
  //                         },
  //                         separatorBuilder: (BuildContext context, int index) =>
  //                             new Divider(),
  //                       )),
  //                     )
  //                   : new Container(),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Center(
  //             child: Text(
  //               "Click to add",
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget vitalsCard() {
    return Card(
      elevation: 2,
      shadowColor: FitnessAppTheme.grey,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: FitnessAppTheme.nearlyWhite, width: 2)),
      // color: Color(0xfff4f6fa),
      color: FitnessAppTheme.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Health vitals to share",
              style: TextStyle(
                color: AppColors.primaryAccentColor,
                fontSize: 22.0,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              threeweekData == true ? checkbox("Past 3 week Kiosk data", c1) : Container(),
              threemonthData == true ? checkbox("Past 3 months Kiosk data", c6) : Container(),
              sixmonthData == true ? checkbox("Past 6 months Kiosk data", c7) : Container(),

              (vitals == null || vitals.isEmpty)
                  ? Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 12,
                            ),
                            Icon(
                              Icons.check_box_outline_blank_outlined,
                              color: Colors.grey[500],
                            ),
                            Text('   Last Check-in Kiosk data',
                                style: TextStyle(color: Colors.grey[600]))
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                      ],
                    )
                  : checkbox("Last Check-in Kiosk data", c8),
              Row(children: [
                SizedBox(
                  width: 12,
                ),
                Icon(
                  Icons.check_box_outline_blank_outlined,
                  color: Colors.grey[500],
                ),
                Text('   Health Assessment Survey', style: TextStyle(color: Colors.grey[600]))
              ]),
              SizedBox(
                height: 12,
              ),
              Row(children: [
                SizedBox(
                  width: 12,
                ),
                Icon(
                  Icons.check_box_outline_blank_outlined,
                  color: Colors.grey[500],
                ),
                Text('   Google fit data', style: TextStyle(color: Colors.grey[600]))
              ]),
              SizedBox(
                height: 12,
              ),
              Row(children: [
                SizedBox(
                  width: 12,
                ),
                Icon(
                  Icons.check_box_outline_blank_outlined,
                  color: Colors.grey[500],
                ),
                Text('   Exercise/Walking history', style: TextStyle(color: Colors.grey[600]))
              ]),
              Visibility(
                visible: !enableMedicalFilesTile,
                child: SizedBox(
                  height: 12,
                ),
              ),
              // checkbox("Health Assessment Survey", c2),
              // checkbox("Google fit data", c3),
              // checkbox("Exercise/Walking history", c4),
              ///enabled medical files tile
              Visibility(
                // visible: enableMedicalFilesTile,
                child: Row(
                  children: <Widget>[
                    Checkbox(
                        value: showMedicalFilesCard,
                        onChanged: (value) {
                          if (this.mounted) {
                            setState(
                              () {
                                showMedicalFilesCard = value;
                              },
                            );
                          }
                        }),
                    Text(
                      'Select Files to Share',
                    ),
                  ],
                ),
              ),

              ///disabled medical files tile
              // Visibility(
              //   visible: !enableMedicalFilesTile,
              //   child: Row(
              //     children: [
              //       SizedBox(
              //         width: 12,
              //       ),
              //       Icon(
              //         Icons.check_box_outline_blank_outlined,
              //         color: Colors.grey[500],
              //       ),
              //       Text('   Select Files to Share',
              //           style: TextStyle(color: Colors.grey[600]))
              //     ],
              //   ),
              // ),

              SizedBox(
                height: 12,
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  Widget medicalFileCard() {
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
              "Select Medical Files",
              style: TextStyle(
                color: AppColors.primaryAccentColor,
                fontSize: 22.0,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  Widget checkbox(String title, bool boolValue) {
    return Row(
      children: <Widget>[
        Checkbox(
          value: boolValue,
          onChanged: (vitals == null || vitals.isEmpty)
              ? (value) {}
              : (bool value) async {
                  if (this.mounted) {
                    setState(() {
                      print(value);
                      switch (title) {
                        case "Past 3 week Kiosk data":
                          c1 = value;
                          break;
                        case "Health Assessment Survey":
                          c2 = value;
                          break;
                        case "Google fit data":
                          c3 = value;
                          break;
                        case "Exercise/Walking history":
                          c4 = value;
                          break;
                        case "Past 3 months Kiosk data":
                          c6 = value;
                          break;
                        case "Past 6 months Kiosk data":
                          c7 = value;
                          break;
                        case "Last Check-in Kiosk data":
                          c8 = value;
                          break;
                      }
                    });
                  }
                },
        ),
        Text(title),
      ],
    );
  }

  Widget checkboxTile(String docId) {
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

        // if (this.mounted) {
        //   setState(() {
        //     switch (doc) {
        //       case 1:
        //         f1 = value;
        //         break;
        //       case 2:
        //         f2 = value;
        //         break;
        //       case 3:
        //         f3 = value;
        //         break;
        //     }
        //   });
        // }
      },
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
                                  Navigator.of(context).pop();
                                  sheetForSelectingReport(context);
                                  // (context);
                                },
                              ),
                              MaterialButton(
                                child: const Text(
                                  'Confirm',
                                  style: TextStyle(
                                      color: AppColors.primaryColor, //AppColors.primaryColor
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  //pop
                                  Navigator.pop(context);
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
                            textStyle: TextStyle(
                                fontSize: ScUtil().setSp(14), fontWeight: FontWeight.bold),
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
                              FocusManager.instance.primaryFocus?.unfocus();
                            }
                          },
                          child: Text(
                            ' Upload ',
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 1.5,
                                fontSize: ScUtil().setSp(16)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScUtil().setHeight(60)),
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
                  Platform.isIOS
                      ? ListTile(
                          title: Text('Select Report From Storage'),
                          leading: Icon(Icons.image),
                          onTap: () {
                            sheetForSelectingPdfOrImageIos(context);
                          },
                        )
                      : ListTile(
                          title: Text('Select Report From Storage'),
                          leading: Icon(Icons.image),
                          onTap: () async {
                            var status = await CheckPermissions.filePermissions(context);
                            if (status) {
                              _openFileExplorer('upload');
                            }
                          },
                        ),
                  ListTile(
                    title: Text('Capture Report From Camera'),
                    leading: Icon(Icons.camera_alt_outlined),
                    onTap: () async {
                      var status = await CheckPermissions.cameraPermissions(context);
                      if (status) {
                        await _imgFromCamera();
                        Navigator.of(context).pop();
                        showFileTypePicker(context);
                        if (this.mounted) {
                          setState(
                            () {
                              fileSelected = true;
                            },
                          );
                        }
                      }
                    },
                  ),
                  SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  sheetForSelectingPdfOrImageIos(BuildContext context) {
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
                    title: Text('Pdf'),
                    leading: Icon(Icons.picture_as_pdf_rounded),
                    onTap: () {
                      _openFileExplorer('upload');
                    },
                  ),
                  ListTile(
                    title: Text('Image'),
                    leading: Icon(Icons.image),
                    onTap: () {
                      onGallery(context);
                    },
                  ),

                  // new ListTile(
                  //     leading: new Icon(Icons.photo_library),
                  //     title: new Text('Photo Library'),
                  //     onTap: () {
                  //       // _imgFromGallery();
                  //       // Navigator.of(context).pop();
                  //     }),
                  // new ListTile(
                  //   leading: new Icon(Icons.photo_camera),
                  //   title: new Text('Camera'),
                  //   onTap: () async{
                  //    await _imgFromCamera();
                  //
                  //     Navigator.of(context).pop();
                  //
                  //     showFileTypePicker(context);
                  //     setState(() {
                  //       fileSelected = true;
                  //     });
                  //
                  //   },
                  // ),

                  SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void onGallery(BuildContext cont) async {
    var permission = Permission.photos;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print(androidInfo.version.release);
      print(int.parse(androidInfo.version.release) <= 12);
      if (int.parse(androidInfo.version.release) <= 12) {
        permission = Permission.storage;
      }
    }
    if (await permission.request().isGranted) {
      getIMG(source: ImageSource.gallery, context: cont);
      //Navigator.of(context).pop();
    } else if (await permission.request().isDenied) {
      await permission.request();
      Get.snackbar('Gallery Access Denied', 'Allow Photos/Storage permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    } else {
      Get.snackbar('Gallery Access Denied', 'Allow Photos/Storage permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    }
  }

  Future<File> _pickImage({ImageSource source, BuildContext context}) async {
    final picked = await ImagePicker().getImage(
      source: source,
      maxHeight: 720,
      maxWidth: 720,
      imageQuality: 80,
    );

    if (picked != null) {
      File selected = await FlutterExifRotation.rotateImage(path: picked.path);
      if (selected != null) {
        return selected;
      }
    }
  }

  Future<File> getIMG({ImageSource source, BuildContext context}) async {
    File fromPickImage = await _pickImage(context: context, source: source);
    if (fromPickImage != null) {
      File cropped = await crop(fromPickImage);
      print(cropped.path);
      //upload(cropped, context);
      if (cropped != null) {
        croppedFile = CroppedFile(cropped.path);
        if (this.mounted) {
          setState(() {
            fileSelected = true;
            isImageSelectedFromCamera = true;
          });
        }
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
        showFileTypePicker(context);
      }
    } else {
      loading = false;
    }
  }

  Future<File> crop(File selectedfile) async {
    try {
      File toSend;
      await ImageCropper().cropImage(sourcePath: selectedfile.path, uiSettings: [
        AndroidUiSettings(
          lockAspectRatio: false,
          activeControlsWidgetColor: AppColors.primaryAccentColor,
          backgroundColor: AppColors.appBackgroundColor,
          toolbarColor: AppColors.primaryAccentColor,
          toolbarWidgetColor: Colors.white,
          toolbarTitle: 'Crop Image',
        ),
        IOSUiSettings(
          title: 'Crop image',
        )
      ]).then((value) => toSend = File(value.path));
      if (toSend == null) {
        return selectedfile;
      } else
        return toSend;
    } catch (e) {
      return selectedfile;
    }
  }

  ///capture report from camera

  ///capture report from camera
  bool isImageSelectedFromCamera = false;

  CroppedFile croppedFile;
  File _image;
  final picker = ImagePicker();

  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    _image = new File(pickedFile.path);
    croppedFile = await ImageCropper().cropImage(
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
        ]);

    if (this.mounted) {
      setState(() {
        List<int> imageBytes = File(croppedFile.path).readAsBytesSync();
        var im = croppedFile.path;
        isImageSelectedFromCamera = true;

        ///instead of image selected write here the older variable file selected = true, okay and than remove this file
        fileSelected = true;
      });
    }
  }

  ///file explorer
  Future<void> _openFileExplorer(type, {edit_doc_type}) async {
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
    request.headers.addAll(
      {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'data',
        path,
        filename: filename,
      ),
    );
    print('$_chosenType======$iHLUserId');
    request.fields.addAll(await {
      "ihl_user_id": "$iHLUserId",
      "document_name": "${fileNametext.replaceAll('.', '') + '.' + extension.toLowerCase()}",
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

  bookingDate() {
    var dataa = dataToSend();
    print(dataa);
    return [dataa['start_date'], dataa['end_date']];
  }
// bookingDate(visitDetails) {
//   var new_appStrtdate;
//   var new_appenddate;
//   String new_fometedStartdate;
//   String new_fometEdenddate;
//   var date = '';
//   final now = (visitDetails['doctor']['vendor_id'].toString() == "GENIX" &&
//       visitDetails['doctor']['livecall'] == true)
//       ? DateTime.now().add(Duration(minutes: 1))
//       : DateTime.now();
//   String formatteddate = DateFormat.yMMMMd('en_US').format(now);
//   String formattedTime = (visitDetails['doctor']['vendor_id'].toString() ==
//       "GENIX" &&
//       visitDetails['doctor']['livecall'] == true)
//       ? DateFormat("hh:mm a").format(DateTime.now().add(Duration(minutes: 3)))
//       : DateFormat("hh:mm a").format(DateTime.now());
//   String appStartdate = formatteddate + ' ' + formattedTime;
//   var appEndTime = DateFormat('hh:mm a').parse(formattedTime);
//   var appEndTimeString = DateFormat('hh:mm a')
//       .format(appEndTime.add(Duration(minutes: 30)))
//       .toString();
//
//   String appointmentStartdateToSend = "";
//   String appointmentEnddateToSend = "";
//   DateTime currentdate = new DateTime.now();
//
//   if (appStartdate.contains("rd") ||
//       appStartdate.contains("th") ||
//       appStartdate.contains("nd") ||
//       appStartdate.contains("st")) {
//     String dd = appStartdate.substring(0, 2);
//     String month = appStartdate.substring(5, 8);
//     String mm = "";
//
//     switch (month) {
//       case "Jan":
//         mm = "01";
//         break;
//       case "Feb":
//         mm = "02";
//         break;
//       case "Mar":
//         mm = "03";
//         break;
//       case "Apr":
//         mm = "04";
//         break;
//       case "May":
//         mm = "05";
//         break;
//       case "Jun":
//         mm = "06";
//         break;
//       case "Jul":
//         mm = "07";
//         break;
//       case "Aug":
//         mm = "08";
//         break;
//       case "Sep":
//         mm = "09";
//         break;
//       case "Oct":
//         mm = "10";
//         break;
//       case "Nov":
//         mm = "11";
//         break;
//       case "Dec":
//         mm = "12";
//         break;
//     }
//     appointmentStartdateToSend = currentdate.year.toString() +
//         "-" +
//         mm +
//         "-" +
//         dd +
//         ' ' +
//         formattedTime;
//
//     String endDd = appStartdate.substring(0, 2);
//     String endMonth = appStartdate.substring(5, 8);
//     String endMm = "";
//
//     switch (endMonth) {
//       case "Jan":
//         endMm = "01";
//         break;
//       case "Feb":
//         endMm = "02";
//         break;
//       case "Mar":
//         endMm = "03";
//         break;
//       case "Apr":
//         endMm = "04";
//         break;
//       case "May":
//         endMm = "05";
//         break;
//       case "Jun":
//         endMm = "06";
//         break;
//       case "Jul":
//         endMm = "07";
//         break;
//       case "Aug":
//         endMm = "08";
//         break;
//       case "Sep":
//         endMm = "09";
//         break;
//       case "Oct":
//         endMm = "10";
//         break;
//       case "Nov":
//         endMm = "11";
//         break;
//       case "Dec":
//         endMm = "12";
//         break;
//     }
//
//     appointmentEnddateToSend = currentdate.year.toString() +
//         "-" +
//         endMm +
//         "-" +
//         endDd +
//         ' ' +
//         appEndTimeString;
//   } else if (appStartdate.contains('today') ||
//       appStartdate.contains('Today')) {
//     String currentdateDay;
//     String currentdateMonth;
//
//     if (currentdate.day.toString().length < 2) {
//       currentdateDay = "0" + currentdate.day.toString();
//     } else {
//       currentdateDay = currentdate.day.toString();
//     }
//
//     if (currentdate.month.toString().length < 2) {
//       currentdateMonth = "0" + currentdate.month.toString();
//     } else {
//       currentdateMonth = currentdate.month.toString();
//     }
//
//     appointmentStartdateToSend = currentdate.year.toString() +
//         '-' +
//         currentdateMonth +
//         '-' +
//         currentdateDay +
//         ' ' +
//         formattedTime;
//
//     appointmentEnddateToSend = currentdate.year.toString() +
//         "-" +
//         currentdateMonth +
//         "-" +
//         currentdateDay +
//         ' ' +
//         appEndTimeString;
//   } else if (appStartdate.contains('tomorrow') ||
//       appStartdate.contains('Tomorrow')) {
//     var tomorrow = currentdate.add(new Duration(days: 1));
//     String tomorrowdateDay;
//     String tomorrowdateMonth;
//
//     if (tomorrow.day.toString().length < 2) {
//       tomorrowdateDay = "0" + tomorrow.day.toString();
//     } else {
//       tomorrowdateDay = tomorrow.day.toString();
//     }
//
//     if (tomorrow.month.toString().length < 2) {
//       tomorrowdateMonth = "0" + tomorrow.month.toString();
//     } else {
//       tomorrowdateMonth = tomorrow.month.toString();
//     }
//
//     appointmentStartdateToSend = tomorrow.year.toString() +
//         '-' +
//         tomorrowdateMonth +
//         '-' +
//         tomorrowdateDay +
//         ' ' +
//         formattedTime;
//     appointmentEnddateToSend = tomorrow.year.toString() +
//         "-" +
//         tomorrowdateMonth +
//         "-" +
//         tomorrowdateDay +
//         ' ' +
//         appEndTimeString;
//   } else if (appStartdate.contains('January') ||
//       appStartdate.contains('February') ||
//       appStartdate.contains('March') ||
//       appStartdate.contains('April') ||
//       appStartdate.contains('May') ||
//       appStartdate.contains('June') ||
//       appStartdate.contains('July') ||
//       appStartdate.contains('August') ||
//       appStartdate.contains('September') ||
//       appStartdate.contains('October') ||
//       appStartdate.contains('November') ||
//       appStartdate.contains('December')) {
//     String currentdateDay;
//     String currentdateMonth;
//
//     if (currentdate.day.toString().length < 2) {
//       currentdateDay = "0" + currentdate.day.toString();
//     } else {
//       currentdateDay = currentdate.day.toString();
//     }
//
//     if (currentdate.month.toString().length < 2) {
//       currentdateMonth = "0" + currentdate.month.toString();
//     } else {
//       currentdateMonth = currentdate.month.toString();
//     }
//
//     appointmentStartdateToSend = currentdate.year.toString() +
//         '-' +
//         currentdateMonth +
//         '-' +
//         currentdateDay +
//         ' ' +
//         formattedTime;
//     appointmentEnddateToSend = currentdate.year.toString() +
//         "-" +
//         currentdateMonth +
//         "-" +
//         currentdateDay +
//         ' ' +
//         appEndTimeString;
//   }
//
//   if ((visitDetails['doctor']['vendor_id'].toString() == "GENIX" &&
//       visitDetails['doctor']['livecall']== true)) {
//     new_appStrtdate = appointmentStartdateToSend.toString();
//     new_appenddate = appointmentEnddateToSend.toString();
//
//     new_fometedStartdate = changeDateFormat(new_appStrtdate.toString());
//     new_fometEdenddate = changeDateFormat(new_appenddate.toString());
//     date = new_appStrtdate + ' - ' + new_appenddate;
//     return [new_fometedStartdate, new_fometEdenddate];
//   } else {
//     // var appStartdate = visitDetails['start_date'];
//     // var new_appenddate = visitDetails['end_date'];
//     ///shi h
//     var dataa = dataToSend();
//     print(dataa);
//     new_appStrtdate = visitDetails['start_date'];
//     new_appenddate = visitDetails['end_date'];
//
//     new_fometedStartdate = changeDateFormat(new_appStrtdate.toString());
//     new_fometEdenddate = changeDateFormat(new_appenddate.toString());
//     date = new_appStrtdate + ' - ' + new_appenddate;
//     return [new_fometedStartdate, new_fometEdenddate];
//   }
// }
}
