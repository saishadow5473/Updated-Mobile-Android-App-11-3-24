// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/onlineServices/couponPage.dart';
import '../../../../models/freeconsultant_model.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:strings/strings.dart';
import '../../../../constants/app_texts.dart';
import '../../../../models/appointment_pagination_model.dart';
import '../../../../utils/CheckPermi.dart';
import '../../../../utils/screenutil.dart';
import '../../../../views/teleconsultation/appointment_status_check.dart';
import '../../../../utils/app_colors.dart';
import '../../../../views/teleconsultation/files/pdf_viewer.dart';
import '../../../data/model/TeleconsultationModels/allMedicalFiles.dart';
import '../../../data/model/TeleconsultationModels/doctorModel.dart';
import '../../Widgets/appBar.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../dashboard/common_screen_for_navigation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'consultationStages.dart';

class ConfirmVisitPage extends StatefulWidget {
  ConfirmVisitPage(
      {Key key,
      this.doctorDetails,
      this.datadecode,
      this.slotSelectedTime,
      this.liveCall,
      this.fees})
      : super(key: key);
  DoctorModel doctorDetails;
  Map datadecode;
  Map slotSelectedTime;
  bool liveCall;
  String fees;

  @override
  State<ConfirmVisitPage> createState() => _ConfirmVisitPageState();
}

class _ConfirmVisitPageState extends State<ConfirmVisitPage> {
  String IHL_User_ID;
  var paymentStatus;
  String selectedSpeciality;
  TextEditingController dateController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController allergyController = TextEditingController();
  var bookedDate;
  String affiliationUniquename = 'global_services';
  bool liveCCall = false;
  List<dynamic> vitalList = [];
  FreeConsultation _freeConsultation;

  // String email = '';

  // String mobile = '';
  // String allergy = '';
  String email = '';
  ValueNotifier<String> reason = ValueNotifier('');
  ValueNotifier<String> mobile = ValueNotifier('1234567890');
  ValueNotifier<String> allergy = ValueNotifier('');
  ValueNotifier<String> fileNametext = ValueNotifier('');
  TextEditingController fileNameController = TextEditingController();
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  ValueNotifier<bool> fileSelected = ValueNotifier<bool>(false);
  ValueNotifier<bool> isImageSelectedFromCamera = ValueNotifier<bool>(false);

  // ValueNotifier< List<String>> selectedDocIdList = ValueNotifier<bool>(false);
  List<String> selectedDocIdList = [];

  // String reason = '';
  bool mobilechar = false;
  bool _isPageJustEntered = true;
  List filesNameList = [];
  PlatformFile file;
  String formattedStartDate;
  String formattedEndDate;

  /// upload medical files/reports
  String _chosenType = 'others';
  FilePickerResult result;
  bool c1 = false;

  // bool showMedicalFilesCard = false;
  Map vitals = {};
  bool _isPageLoaded = false;
  String userInputWeightInKG;
  var localBMR;
  double heightMeters;
  bool threeweekData = false;
  bool threemonthData = false;
  bool sixmonthData = false;
  bool enableMedicalFilesTile = false;
  CroppedFile croppedFile;
  File _image;
  final ImagePicker picker = ImagePicker();
  var appointmentId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // bool isImageSelectedFromCamera = false;
  String iHLUserId = '';

  @override
  void initState() {
    liveCCall = widget.liveCall;
    TeleConsultationFunctionsAndVariables.showVitals.value = false;
    TeleConsultationFunctionsAndVariables.showMedicalFilesCard.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _isPageLoaded = true);
    getDetails();
    asyncFunction();
    mobilechar = mobileController.text.contains(RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)'));
    // TODO: implement initState
    super.initState();
  }

  asyncFunction() async {
    await TeleConsultationFunctionsAndVariables.allMedicalFilesList();
    // await TeleConsultationFunctionsAndVariables.getUploadMedicalDocumentList();
  }

  getDetails() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    IHL_User_ID = prefs1.getString("ihlUserId");
    // selectedSpeciality = prefs1.getString("selectedSpecality");
    selectedSpeciality ??= widget.doctorDetails.consultantSpeciality.first ?? "N/A";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object email = prefs.get('email');
    emailController.text = email ?? '';
    // var data = prefs.get('data');
    // Map res = jsonDecode(data);
    var mobileNumber = widget.datadecode['User']['mobileNumber'];

    String dob = widget.datadecode['User']['dateOfBirth'].toString();
    DateTime date = DateFormat('mm/DD/yyyy').parse(dob);
    dateController.text = DateFormat('dd/MM/yyyy').format(date) ?? '';
    emailController.text = email ?? '';
    mobileController.text = mobileNumber.toString().replaceAll(RegExp(r"\s+"), "") ?? '1234567890';
    vitals = widget.datadecode["LastCheckin"] ?? {};

    ///call the get medical files api
    for (int i = 0; i < TeleConsultationFunctionsAndVariables.medFilesList.value.length; i++) {
      String name;
      if (TeleConsultationFunctionsAndVariables.medFilesList.value[i].documentName
          .toString()
          .contains('.')) {
        String parse1 = TeleConsultationFunctionsAndVariables.medFilesList.value[i].documentName
            .toString()
            .replaceAll('.jpg', '');
        String parse2 = parse1.replaceAll('.jpeg', '');
        String parse3 = parse2.replaceAll('.png', '');
        String parse4 = parse3.replaceAll('.pdf', '');
        name = parse4;
      }
      filesNameList.add(name);
    }
    if (widget.datadecode["LastCheckin"] != null &&
        widget.datadecode["LastCheckin"].isNotEmpty &&
        widget.datadecode["LastCheckin"] != {}) {
      widget.datadecode["LastCheckin"].removeWhere((key, value) =>
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
      widget.datadecode["LastCheckin"].forEach((key, value) {
        if (key == "weightKG") {
          widget.datadecode["LastCheckin"]["weightKG"] = double.parse((value).toStringAsFixed(2));
        }
        if (key == "heightMeters") {
          widget.datadecode["LastCheckin"]["heightMeters"] =
              double.parse((value).toStringAsFixed(2));
        }
      });
      widget.datadecode["LastCheckin"].removeWhere((key, value) => value == "");
    } else {
      userInputWeightInKG = SpUtil.getString(LSKeys.weight);
      heightMeters = SpUtil.getDouble(LSKeys.height);
      localBMR = SpUtil.getDouble("localBMI");
      widget.datadecode["LastCheckin"] = {};
      widget.datadecode["LastCheckin"]["bmi"] = localBMR.toStringAsFixed(2);
      widget.datadecode["LastCheckin"]["weightKG"] =
          double.parse((userInputWeightInKG)).toStringAsFixed(2);
      widget.datadecode["LastCheckin"]["heightMeters"] = heightMeters.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (loading.value) {
          return null;
        } else {
          Navigator.pop(context, true);
        }
        return true;
      },
      child: CommonScreenForNavigation(
        contentColor: '',
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: loading.value ? () {} : () => Navigator.of(context).pop(),
            color: Colors.white,
            tooltip: 'Back',
          ),
          centerTitle: true,
          title: const Text(
            AppTexts.confirmVisitTitle,
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
        content: InkWell(
          onTap: () => primaryFocus.unfocus(),
          child: Column(children: <Widget>[
            Expanded(
              child: ListView(
                children: [
                  SizedBox(
                    height: 1.h,
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.px),
                    child: consultantDetails(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 13.sp, top: 12.sp, bottom: 12.sp),
                    child: Text(
                      'Contact Details',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17.5.sp),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: userDetails(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 13.sp, top: 12.sp, bottom: 12.sp),
                    child: Text(
                      'Reason for Visit',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17.5.sp),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      // height: 14.h,
                      width: 96.w,
                      child: Card(
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 6.0, right: 6.0, top: 20, bottom: 6.0),
                                child: SizedBox(
                                    // height: 10.h,
                                    child: ValueListenableBuilder<String>(
                                        valueListenable: reason,
                                        builder: (BuildContext context, val, Widget child) {
                                          return TextFormField(
                                            controller: reasonController,
                                            onChanged: (String value) {
                                              reason.value = value;
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(
                                                  vertical: 15, horizontal: 18),
                                              labelText: "Example: Fever, Cold, etc.",
                                              errorText: reasonValidator(reason.value),
                                              fillColor: Colors.white24,
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(6.0),
                                                  borderSide: BorderSide(color: Colors.blueGrey)),
                                            ),
                                            keyboardType: TextInputType.emailAddress,
                                            maxLines: 1,
                                            style: const TextStyle(fontSize: 16.0),
                                            textInputAction: TextInputAction.done,
                                          );
                                        })),
                              ),
                            ],
                          )),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 13.sp, top: 12.sp, bottom: 12.sp),
                        child: Text(
                          'Health vitals to share',
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 17.5.sp),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          elevation: 4,
                          child: Column(children: [
                            (widget.datadecode["LastCheckin"] == null ||
                                    widget.datadecode["LastCheckin"].isEmpty)
                                ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(
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
                                      const SizedBox(
                                        height: 12,
                                      ),
                                    ],
                                  )
                                : ValueListenableBuilder<bool>(
                                    valueListenable:
                                        TeleConsultationFunctionsAndVariables.showVitals,
                                    builder: (BuildContext context, val, Widget child) {
                                      return checkbox("Last Check-in Kiosk data", val);
                                    }),
                            Row(children: [
                              const SizedBox(
                                width: 12,
                              ),
                              Icon(
                                Icons.check_box_outline_blank_outlined,
                                color: Colors.grey[500],
                              ),
                              Text('   Health Assessment Survey',
                                  style: TextStyle(color: Colors.grey[600]))
                            ]),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(children: [
                              const SizedBox(
                                width: 12,
                              ),
                              Icon(
                                Icons.check_box_outline_blank_outlined,
                                color: Colors.grey[500],
                              ),
                              Text('   Google fit data', style: TextStyle(color: Colors.grey[600]))
                            ]),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(children: [
                              const SizedBox(
                                width: 12,
                              ),
                              Icon(
                                Icons.check_box_outline_blank_outlined,
                                color: Colors.grey[500],
                              ),
                              Text('   Exercise/Walking history',
                                  style: TextStyle(color: Colors.grey[600]))
                            ]),
                            // Visibility(
                            //   visible: !enableMedicalFilesTile,
                            //   child: SizedBox(
                            //     height: 12,
                            //   ),
                            // ),

                            // checkbox("Health Assessment Survey", c2),
                            // checkbox("Google fit data", c3),
                            // checkbox("Exercise/Walking history", c4),
                            ///enabled medical files tile
                            Visibility(
                              // visible: enableMedicalFilesTile,
                              child: Row(
                                children: <Widget>[
                                  ValueListenableBuilder<bool>(
                                      valueListenable: TeleConsultationFunctionsAndVariables
                                          .showMedicalFilesCard,
                                      builder: (BuildContext context, val, Widget child) {
                                        return Checkbox(
                                            value: val,
                                            onChanged: (bool value) {
                                              TeleConsultationFunctionsAndVariables
                                                  .showMedicalFilesCard.value = value;
                                            });
                                      }),
                                  const Text(
                                    'Select Files to Share',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),
                          ]),
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable:
                              TeleConsultationFunctionsAndVariables.showMedicalFilesCard,
                          builder: (BuildContext context, val, Widget child) {
                            return Visibility(visible: val, child: filesCard());
                          }),
                      const SizedBox(
                        height: 20.0,
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: loading,
                          builder: (BuildContext context, val1, Widget child) {
                            return Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  fixedSize: Size.fromWidth(MediaQuery.of(context).size.width / 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                ),
                                onPressed: validate()
                                    ? () async {
                                        loading.value = true;
                                        String appointmentStartDateToSend = "";
                                        String appointmentEndDateToSend = "";
                                        DateTime _now = DateTime.now();
                                        DateTime _lastAppointmentTime =
                                            _now.subtract(const Duration(minutes: 15));

                                        bool _callAllowed = false;
                                        if (liveCCall) {
                                          List<CharacterSummary> appointmentStatus =
                                              await AppointmentStatusChecker()
                                                  .getConsultantLatestAppointments(
                                                      consultId: widget
                                                          .doctorDetails.ihlConsultantId
                                                          .toString());
                                          if (appointmentStatus.length > 0) {
                                            if (_now.day ==
                                                DateFormat('yyyy-MM-dd hh:mm a')
                                                    .parse(appointmentStatus[0]
                                                        .bookApointment
                                                        .appointmentStartTime)
                                                    .day) {
                                              _lastAppointmentTime =
                                                  DateFormat('yyyy-MM-dd hh:mm a').parse(
                                                      appointmentStatus[0]
                                                          .bookApointment
                                                          .appointmentStartTime);
                                              if (_now.difference(_lastAppointmentTime) <
                                                      const Duration(minutes: 30) &&
                                                  appointmentStatus[0].bookApointment.callStatus ==
                                                      'on_going') {
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
                                          loading.value = false;

                                          Get.defaultDialog(
                                              title: 'Busy',
                                              middleText: 'Consultant have appointment');
                                        } else {
                                          try {
                                            affiliationUniquename = widget
                                                .doctorDetails
                                                .affilationExcusiveData
                                                .affilationArray[0]
                                                .affilationUniqueName;
                                          } catch (e) {
                                            affiliationUniquename = 'global_services';
                                          }
                                          // String fees =
                                          //     widget.doctorDetails.consultationFees != "none"
                                          //         ? widget.doctorDetails.affilationExcusiveData
                                          //             .affilationArray[0].affilationPrice
                                          //         : widget.doctorDetails.consultationFees;
                                          widget.doctorDetails.livecall = liveCCall;
                                          if (widget.fees == 'Free' ||
                                              widget.fees == 'free' ||
                                              widget.fees == 'FREE' ||
                                              widget.fees == 'N/A' ||
                                              widget.fees == '0' ||
                                              widget.fees == '00' ||
                                              widget.fees == '000' ||
                                              widget.fees == '0000' ||
                                              widget.fees == '000000') {
                                            loading.value = true;

                                            freeConsultationProceed();
                                          } else {
                                            loading.value = true;
                                            SharedPreferences prefs =
                                                await SharedPreferences.getInstance();
                                            Object data = prefs.get('data');
                                            Map res = jsonDecode(data);
                                            iHLUserId = res['User']['id'];
                                            String currentDateDay;
                                            String currentDateMonth;
                                            String appStartDate =
                                                widget.slotSelectedTime['selectedTile'] +
                                                    ' ' +
                                                    widget.slotSelectedTime['time'];
                                            DateTime appEndTime = DateFormat('hh:mm a')
                                                .parse(widget.slotSelectedTime['time']);
                                            String appEndTimeString = DateFormat('hh:mm a')
                                                .format(appEndTime.add(const Duration(minutes: 30)))
                                                .toString();
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
                                                  currentDate.year.toString() +
                                                      "-" +
                                                      mm +
                                                      "-" +
                                                      dd +
                                                      ' ' +
                                                      widget.slotSelectedTime['time'];

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
                                                  currentDate.year.toString() +
                                                      "-" +
                                                      endMm +
                                                      "-" +
                                                      endDd +
                                                      ' ' +
                                                      appEndTimeString;
                                            } else if (appStartDate.contains('today') ||
                                                appStartDate.contains('Today')) {
                                              String currentDateDay;
                                              String currentDateMonth;

                                              if (currentDate.day.toString().length < 2) {
                                                currentDateDay = "0${currentDate.day}";
                                              } else {
                                                currentDateDay = currentDate.day.toString();
                                              }

                                              if (currentDate.month.toString().length < 2) {
                                                currentDateMonth = "0${currentDate.month}";
                                              } else {
                                                currentDateMonth = currentDate.month.toString();
                                              }

                                              appointmentStartDateToSend =
                                                  '${currentDate.year}-$currentDateMonth-$currentDateDay ' +
                                                      widget.slotSelectedTime['time'];

                                              appointmentEndDateToSend =
                                                  currentDate.year.toString() +
                                                      "-" +
                                                      currentDateMonth +
                                                      "-" +
                                                      currentDateDay +
                                                      ' ' +
                                                      appEndTimeString;
                                            } else if (appStartDate.contains('tomorrow') ||
                                                appStartDate.contains('Tomorrow')) {
                                              DateTime tomorrow =
                                                  currentDate.add(Duration(days: 1));
                                              String tomorrowDateDay;
                                              String tomorrowDateMonth;

                                              if (tomorrow.day.toString().length < 2) {
                                                tomorrowDateDay = "0${tomorrow.day}";
                                              } else {
                                                tomorrowDateDay = tomorrow.day.toString();
                                              }

                                              if (tomorrow.month.toString().length < 2) {
                                                tomorrowDateMonth = "0${tomorrow.month}";
                                              } else {
                                                tomorrowDateMonth = tomorrow.month.toString();
                                              }

                                              appointmentStartDateToSend =
                                                  '${tomorrow.year}-$tomorrowDateMonth-$tomorrowDateDay ' +
                                                      widget.slotSelectedTime['time'];
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
                                                currentDateDay = "0${currentDate.day}";
                                              } else {
                                                currentDateDay = currentDate.day.toString();
                                              }

                                              if (currentDate.month.toString().length < 2) {
                                                currentDateMonth = "0${currentDate.month}";
                                              } else {
                                                currentDateMonth = currentDate.month.toString();
                                              }

                                              appointmentStartDateToSend =
                                                  '${currentDate.year}-$currentDateMonth-$currentDateDay ' +
                                                      widget.slotSelectedTime['time'];
                                              appointmentEndDateToSend =
                                                  currentDate.year.toString() +
                                                      "-" +
                                                      currentDateMonth +
                                                      "-" +
                                                      currentDateDay +
                                                      ' ' +
                                                      appEndTimeString;
                                            }
                                            formattedStartDate = changeDateFormat(
                                                appointmentStartDateToSend.toString());
                                            formattedEndDate = changeDateFormat(
                                                appointmentEndDateToSend.toString());
                                          }

                                          // prefs.setString('consultantName',
                                          //     widget.doctorDetails.name.toString());
                                          // prefs.setString('consultantId',
                                          //     widget.doctorDetails.ihlConsultantId.toString());
                                          // prefs.setString('vendorName',
                                          //     widget.doctorDetails.vendorId.toString());
                                          // prefs.setString('vendorConId',
                                          //     widget.doctorDetails.ihlConsultantId.toString());
                                          // try {} catch (e) {}
                                          //
                                          // try {} catch (e) {}
                                          // try {} catch (e) {}
                                          // try {} catch (e) {}
                                          // bookedDate = bookingDate();
                                          // if (TeleConsultationFunctionsAndVariables
                                          //     .showVitals.value) {
                                          //   vitals['dateTime'] = vitals['dateTimeFormatted'];
                                          //   if (vitals['temperature'] != null &&
                                          //       widget.doctorDetails.vendorId.toString() ==
                                          //           'GENIX') {
                                          //     vitals['temperature'] =
                                          //         (vitals['temperature'] * 9 / 5) + 32;
                                          //   }
                                          // }
                                          Map purposeDetails = {
                                            "user_ihl_id": iHLUserId.toString(),
                                            "consultant_name": widget.doctorDetails.name.toString(),
                                            "vendor_consultant_id":
                                                widget.doctorDetails.vendorConsultantId.toString(),
                                            "ihl_consultant_id":
                                                widget.doctorDetails.ihlConsultantId.toString(),
                                            "vendor_id": widget.doctorDetails.vendorId.toString(),
                                            "specality": selectedSpeciality.toString(),
                                            "consultation_fees": widget.fees.toString(),
                                            "mode_of_payment": "online",
                                            "alergy": allergyController.text.toString() ?? "",
                                            "kiosk_checkin_history":
                                                (vitals != null || vitals.isNotEmpty) &&
                                                        TeleConsultationFunctionsAndVariables
                                                            .showVitals.value
                                                    ? vitals
                                                    : (vitals != null || vitals.isNotEmpty)
                                                        ? {
                                                            "weightKG": vitals["weightKG"],
                                                            "bmi": vitals["bmi"],
                                                            "heightMeters": vitals["heightMeters"]
                                                          }
                                                        : {},
                                            "appointment_start_time": formattedStartDate.toString(),
                                            //yyyy-mm-dd 03:00 PM
                                            "appointment_end_time": formattedEndDate.toString(),
                                            "appointment_duration": "30 Min",
                                            "appointment_status": "Requested",
                                            "direct_call": liveCCall,
                                            "vendor_name": widget.doctorDetails.vendorId.toString(),
                                            // "vendor_name": widget.doctorDetails.vendorId['doctor']['vendor_name'].toString(),
                                            "appointment_model": "appointment",
                                            "reason_for_visit": reasonController.text.toString(),
                                            "notes": "",
                                            "document_id": selectedDocIdList,
                                          };
                                          loading.value = false;
                                          Get.to(CouponPage(
                                              datadecode: widget.datadecode,
                                              doctorDetails: widget.doctorDetails,
                                              purposeDetails: purposeDetails,
                                              startDate: formattedStartDate,
                                              endDate: formattedEndDate,
                                              freeconsult: _freeConsultation));
                                        }
                                      }
                                    : null,
                                child: val1
                                    ? const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.only(
                                            left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                                        child: Text(
                                          "Confirm",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                              ),
                            );
                          }),
                      SizedBox(
                        height: 2.5.h,
                      )
                    ],
                  ),
                  // Visibility(visible: showMedicalFilesCard, child: filesCard()),
                ],
              ),
            ),
            SizedBox(
              height: 8.h,
            ),
          ]),
        ),
      ),
    );
  }

  Widget consultantDetails() {
    return SizedBox(
      // height: 26.h,
      width: 92.w,
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 8.0, bottom: 9.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                FutureBuilder<Uint8List>(
                  future: TeleConsultationFunctionsAndVariables.vendorImage(
                      vendorName: widget.doctorDetails.vendorId),
                  builder: (BuildContext context, AsyncSnapshot<Uint8List> i) {
                    if (i.connectionState == ConnectionState.done) {
                      return Container(
                        width: 12.w,
                        height: 3.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: Image.memory(
                              i.data,
                            ).image,
                          ),
                        ),
                      );
                    } else if (i.connectionState == ConnectionState.waiting) {
                      return Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.grey.withOpacity(0.3),
                        direction: ShimmerDirection.ltr,
                        child: Container(
                          width: 13.w,
                          height: 3.w,
                          decoration: const BoxDecoration(color: Colors.white),
                        ),
                      );
                    } else {
                      return SizedBox(
                        width: 13.w,
                        height: 3.w,
                      );
                    }
                  },
                ),
              ]),
            ),
            Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 2.w,
                ),
                SizedBox(
                  width: 38.w,
                  height: 18.h,
                  child: FutureBuilder<String>(
                    future: TabBarController()
                        .getConsultantImageUrl(doctor: widget.doctorDetails.toJson() ?? {}),
                    builder: (BuildContext context, AsyncSnapshot<String> i) {
                      if (i.connectionState == ConnectionState.done) {
                        widget.doctorDetails.docImage = i.data.toString();
                        return Container(
                          width: 28.w,
                          height: 18.h,
                          decoration: BoxDecoration(
                            color: const Color(0xff7c94b6),
                            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                            image: DecorationImage(
                                image: Image.memory(
                                  base64Decode(
                                    i.data.toString(),
                                  ),
                                ).image,
                                fit: BoxFit.cover),
                          ),
                        );
                      } else if (i.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.withOpacity(0.3),
                          direction: ShimmerDirection.ltr,
                          child: Container(
                            width: 28.w,
                            height: 18.h,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              color: Colors.white,
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(width: 18.w, height: 18.w);
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 1.w,
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 51.w,
                    // height: 18.h,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0, right: 8.0),
                            child: FittedBox(
                              child: Text(
                                widget.doctorDetails.name.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5.sp),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0, bottom: 4.0, right: 8.0),
                            child: widget.doctorDetails.qualification == null
                                ? const SizedBox()
                                : Text(
                                    widget.doctorDetails.qualification.toString(),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0, bottom: 4.0, right: 8.0),
                            child: Text(
                              widget.doctorDetails.consultantSpeciality.toString().substring(1,
                                  widget.doctorDetails.consultantSpeciality.toString().length - 1),
                              style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0, bottom: 4.0, right: 8.0),
                            child: Text(
                              capitalize(widget.slotSelectedTime['selectedTile'].toString()),
                              style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0, bottom: 4.0, right: 8.0),
                            child: Text(
                              widget.slotSelectedTime['time'],
                              style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 1.h,
            )
          ],
        ),
      ),
    );
  }

  String dateTimeToString(DateTime dateTime) {
    DateFormat ipF = DateFormat("dd/MM/yyyy");
    return ipF.format(dateTime);
  }

  Widget userDetails() {
    return Form(
      key: _formKey,
      child: SizedBox(
        // height: 4.h,
        width: 96.w,
        child: Card(
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 20, bottom: 6.0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.always,
                      controller: emailController,
                      onChanged: (String value) {
                        email = value;
                      },
                      validator: (String value) {
                        if (value.isNotEmpty) {
                          return null;
                        } else {
                          bool isMail = value.contains(
                              RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"),
                              0);
                          if ((!isMail)) {
                            return 'Enter valid Email';
                          }
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Icon(
                            Icons.email,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        labelText: "Email address",
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(color: Colors.grey)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 16.0),
                      textInputAction: TextInputAction.done,
                    )),
                Padding(
                    padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 20, bottom: 6.0),
                    child: ValueListenableBuilder<String>(
                        valueListenable: mobile,
                        builder: (BuildContext context, String val, Widget child) {
                          return TextFormField(
                            autovalidateMode: AutovalidateMode.always,
                            controller: mobileController,
                            validator: (String value) {
                              int tryp = int.tryParse(value);
                              if (tryp.toString().length < 10) {
                                return 'Mobile number should be at least 10 digit long';
                              }
                              if (value.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              return null;
                            },
                            autocorrect: true,
                            maxLength: 10,
                            onChanged: (String value) {
                              mobile.value = value;
                            },
                            decoration: InputDecoration(
                              errorText: mobileValidator(mobile.value),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(15),
                                child: Icon(
                                  Icons.phone,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              labelText: "Mobile Number",
                              fillColor: Colors.white24,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                  borderSide: BorderSide(color: Colors.blueGrey)),
                            ),
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 16.0),
                            textInputAction: TextInputAction.done,
                          );
                        })),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 20, bottom: 6.0),
                  child: TextFormField(
                    onTap: () async {
                      DateTime date = DateTime(1900);
                      FocusScope.of(context).requestFocus(FocusNode());

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
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Icon(
                          FontAwesomeIcons.calendar,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      labelText: "Date of birth(DD/MM/YYYY)",
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: const BorderSide(color: Colors.blueGrey)),
                    ),
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 16.0),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 20, bottom: 6.0),
                    child: ValueListenableBuilder<String>(
                        valueListenable: allergy,
                        builder: (BuildContext context, val, Widget child) {
                          return TextFormField(
                            controller: allergyController,
                            autocorrect: true,
                            onChanged: (String value) {
                              allergy.value = value;
                            },
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                              labelText: "Food or medicine allergies, if any",
                              fillColor: Colors.white24,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                  borderSide: BorderSide(color: Colors.blueGrey)),
                            ),
                            maxLines: 1,
                            style: const TextStyle(fontSize: 16.0),
                            textInputAction: TextInputAction.done,
                          );
                        })),
                SizedBox(height: 10.px)
              ],
            )),
      ),
    );
  }

  Widget filesCard() {
    // iHLUserId = IHL_User_ID;
    // print('=============================$iHLUserId');
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 13.sp, top: 12.sp, bottom: 12.sp),
            child: Text(
              'Select your files to share',
              style: TextStyle(
                  color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 17.5.sp),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ValueListenableBuilder<List<AllMedicalFiles>>(
              valueListenable: TeleConsultationFunctionsAndVariables.medFilesList,
              builder: (BuildContext context, List<AllMedicalFiles> val, Widget child) {
                return Card(
                  elevation: 4,
                  shadowColor: FitnessAppTheme.grey,
                  borderOnForeground: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                      side: const BorderSide(color: FitnessAppTheme.nearlyWhite, width: 1)),
                  // color: Color(0xfff4f6fa),
                  color: FitnessAppTheme.white,
                  child: Column(
                    children: [
                      Container(
                          height: val.length > 3
                              ? 35.h
                              : val.length == 3
                                  ? 290
                                  : val.length == 2
                                      ? 190
                                      : val.length == 1
                                          ? 100
                                          : 10,
                          child: Scrollbar(
                            child: ListView(
                              children: val
                                  .map((AllMedicalFiles e) => GestureDetector(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext context) => PdfView(
                                                e.documentLink,
                                                e.toJson(),
                                                IHL_User_ID,
                                                showExtraButton: false,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(15.sp),
                                          child: Card(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 4.w,
                                                  ),
                                                  e.documentLink.substring(
                                                                  e.documentLink.lastIndexOf(".") +
                                                                      1) ==
                                                              'jpg' ||
                                                          e.documentLink.substring(
                                                                  e.documentLink.lastIndexOf(".") +
                                                                      1) ==
                                                              'png'
                                                      ? const Icon(
                                                          Icons.image,
                                                          color: Colors.grey,
                                                        )
                                                      : const Icon(
                                                          Icons.insert_drive_file,
                                                          color: Colors.grey,
                                                        ),
                                                  SizedBox(
                                                    width: 6.w,
                                                  ),
                                                  Container(
                                                    width: 50.w,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(e.documentName),
                                                        Text(
                                                            "${camelize(e.documentType.replaceAll('_', ' '))}"),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 4.w,
                                                  ),
                                                  checkboxTile(e.documentId)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          )),
                      SizedBox(
                        height: 1.h,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showFileTypePicker(context);
                        },
                        child: SizedBox(
                          width: 20.w,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add),
                              const Text('New File'),
                            ],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }

  String reasonValidator(String ip) {
    if (ip.toString() == 'null' && _isPageJustEntered == true) {
      return null;
    } else if (ip.toString() == 'null') {
      return 'Reason for Appointment';
    }
    if (ip.isEmpty) {
      return 'Reason for Appointment';
    }
    if (ip.length < 4) {
      return 'Reason should be at least 4 character long';
    }
    if (ip.toString() == 'no value') {
      return 'Reason for Appointment';
    }
  }

  Widget checkbox(String title, bool boolValue) {
    return Row(
      children: <Widget>[
        Checkbox(
          value: boolValue,
          onChanged:
              (widget.datadecode["LastCheckin"] == null || widget.datadecode["LastCheckin"].isEmpty)
                  ? (bool value) {}
                  : (bool value) async {
                      switch (title) {
                        case "Past 3 week Kiosk data":
                          c1 = value;
                          break;
                        case "Last Check-in Kiosk data":
                          TeleConsultationFunctionsAndVariables.showVitals.value = value;
                          break;
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
      onChanged: (dynamic value) {
        ///first check in the list and than
        ///if that item is available in the list already than => remove it from the list ,
        ///if item is not there in the list than add it
        if (selectedDocIdList.contains(docId.toString())) {
          selectedDocIdList.remove(docId.toString());
        } else {
          selectedDocIdList.add(docId.toString());
        }
        TeleConsultationFunctionsAndVariables.medFilesList.notifyListeners();
      },
    );
  }

  showFileTypePicker(BuildContext context) {
    // ignore: missing_return
    String fileNameValidator(String ip) {
      if (ip == null) {
        return null;
      }
      if (ip.isEmpty) {
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
      shape: const RoundedRectangleBorder(
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
                    fileSelected.value == false
                        ? Padding(
                            padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                            child: const AutoSizeText(
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
                              "${fileNametext.value}.${isImageSelectedFromCamera.value ? 'jpg' : file.extension.toLowerCase()}",
                              style: const TextStyle(
                                  color: AppColors.appTextColor, //AppColors.primaryColor
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                    Visibility(
                      visible: fileSelected.value == false,
                      child: const Divider(
                        indent: 10,
                        endIndent: 10,
                        thickness: 2,
                      ),
                    ),
                    Visibility(
                      visible: fileSelected.value == false,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
                          child: ValueListenableBuilder<String>(
                              valueListenable: fileNametext,
                              builder: (BuildContext context, val, Widget child) {
                                return TextFormField(
                                  controller: fileNameController,
                                  // validator: (v){
                                  //   fileNameValidator(fileNametext);
                                  // },
                                  onChanged: (String value) {
                                    fileNametext.value = value;
                                  },
                                  // maxLength: 150,
                                  autocorrect: true,
                                  // scrollController: Scrollable,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                                    labelText: "Enter file name",
                                    errorText: fileNameValidator(fileNametext.value),
                                    fillColor: Colors.white24,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                        borderSide: BorderSide(color: Colors.blueGrey)),
                                  ),
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 16.0),
                                  textInputAction: TextInputAction.done,
                                );
                              })),
                    ),
                    fileSelected.value == false
                        ? Padding(
                            padding: const EdgeInsets.all(10.0).copyWith(left: 24, right: 24),
                            child: Container(
                              child: DropdownButton<String>(
                                focusColor: Colors.white,
                                value: _chosenType,
                                isExpanded: true,
                                underline: Container(
                                  height: 2.0,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        // color: widget.mealtype!=null?HexColor(widget.mealtype.startColor):AppColors.primaryColor,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
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
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                hint: const Text(
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
                                child: const Text(
                                  'Change',
                                  style: TextStyle(
                                      color: AppColors.primaryColor, //AppColors.primaryColor
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  //open file explorer again
                                  Navigator.pop(context);
                                  sheetForSelectingReport(context);
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
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    fileSelected.value = false;

                                    ///send this payload diffrently if file selected from camera
                                    if (isImageSelectedFromCamera.value) {
                                      String n = croppedFile.path
                                          .substring(croppedFile.path.lastIndexOf('/') + 1);
                                      await TeleConsultationFunctionsAndVariables
                                          .getUploadMedicalDocumentList(
                                              filename: n,
                                              extension: 'jpg',
                                              path: croppedFile.path,
                                              chooseType: _chosenType,
                                              fileNametext: fileNametext.value,
                                              context: context);
                                      for (int i = 0;
                                          i <
                                              TeleConsultationFunctionsAndVariables
                                                  .medFilesList.value.length;
                                          i++) {
                                        String name;
                                        if (TeleConsultationFunctionsAndVariables
                                            .medFilesList.value[i].documentName
                                            .toString()
                                            .contains('.')) {
                                          String parse1 = TeleConsultationFunctionsAndVariables
                                              .medFilesList.value[i].documentName
                                              .toString()
                                              .replaceAll('.jpg', '');
                                          String parse2 = parse1.replaceAll('.jpeg', '');
                                          String parse3 = parse2.replaceAll('.png', '');
                                          String parse4 = parse3.replaceAll('.pdf', '');
                                          name = parse4;
                                        }
                                        filesNameList.add(name);
                                      }
                                      await TeleConsultationFunctionsAndVariables
                                          .allMedicalFilesList();

                                      Get.snackbar('Uploaded!',
                                          '${camelize('${fileNametext.value.replaceAll('.', '')}.jpg')} uploaded successfully.',
                                          icon: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(Icons.check_circle, color: Colors.white)),
                                          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                          backgroundColor: AppColors.primaryAccentColor,
                                          colorText: Colors.white,
                                          duration: const Duration(seconds: 5),
                                          snackPosition: SnackPosition.BOTTOM);
                                    } else {
                                      await TeleConsultationFunctionsAndVariables
                                          .getUploadMedicalDocumentList(
                                              filename: result.files.first.name,
                                              extension: result.files.first.extension,
                                              path: result.files.first.path,
                                              chooseType: _chosenType,
                                              fileNametext: fileNametext.value,
                                              context: context);

                                      for (int i = 0;
                                          i <
                                              TeleConsultationFunctionsAndVariables
                                                  .medFilesList.value.length;
                                          i++) {
                                        String name;
                                        if (TeleConsultationFunctionsAndVariables
                                            .medFilesList.value[i].documentName
                                            .toString()
                                            .contains('.')) {
                                          String parse1 = TeleConsultationFunctionsAndVariables
                                              .medFilesList.value[i].documentName
                                              .toString()
                                              .replaceAll('.jpg', '');
                                          String parse2 = parse1.replaceAll('.jpeg', '');
                                          String parse3 = parse2.replaceAll('.png', '');
                                          String parse4 = parse3.replaceAll('.pdf', '');
                                          name = parse4;
                                        }
                                        filesNameList.add(name);
                                      }
                                      await TeleConsultationFunctionsAndVariables
                                          .allMedicalFilesList();
                                      Get.snackbar('Uploaded!',
                                          '${camelize('${fileNametext.value}.${result.files.first.extension.toLowerCase()}')} uploaded successfully.',
                                          icon: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(Icons.check_circle, color: Colors.white)),
                                          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                          backgroundColor: AppColors.primaryAccentColor,
                                          colorText: Colors.white,
                                          duration: const Duration(seconds: 5),
                                          snackPosition: SnackPosition.BOTTOM);
                                    }
                                    fileNameController.clear();
                                  }),
                            ],
                          ),
                    Visibility(
                      visible: fileSelected.value == false,
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
                            if (fileNameValidator(fileNametext.value) == null &&
                                fileNametext.value.length != 0) {
                              Navigator.of(context).pop();
                              sheetForSelectingReport(context);
                            } else {
                              fileNameValidator(fileNametext.value);
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
      shape: const RoundedRectangleBorder(
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
                  Platform.isIOS
                      ? ListTile(
                          title: const Text('Select Report From Storage'),
                          leading: const Icon(Icons.image),
                          onTap: () {
                            sheetForSelectingPdfOrImageIos(context);
                          },
                        )
                      : ListTile(
                          title: const Text('Select Report From Storage'),
                          leading: const Icon(Icons.image),
                          onTap: () async {
                            var status = await CheckPermissions.filePermissions(context);
                            if (status) {
                              _openFileExplorer('upload');
                            }
                          },
                        ),
                  ListTile(
                    title: const Text('Capture Report From Camera'),
                    leading: const Icon(Icons.camera_alt_outlined),
                    onTap: () async {
                      var status = await CheckPermissions.cameraPermissions(context);
                      if (status) {
                        await _imgFromCamera();
                        Navigator.of(context).pop();
                        showFileTypePicker(context);

                        fileSelected.value = true;
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _imgFromCamera() async {
    final PickedFile pickedFile = await picker.getImage(source: ImageSource.camera);
    _image = File(pickedFile.path);
    croppedFile = await ImageCropper().cropImage(
        sourcePath: _image.path,
        aspectRatio: const CropAspectRatio(ratioX: 12, ratioY: 16),
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 60,
        uiSettings: [
          AndroidUiSettings(
            lockAspectRatio: false,
            activeControlsWidgetColor: AppColors.primaryAccentColor,
            toolbarTitle: 'Crop the Image',
            toolbarColor: const Color(0xFF19a9e5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(title: 'Crop the Image', aspectRatioLockEnabled: true)
        ]);

    isImageSelectedFromCamera.value = true;

    ///instead of image selected write here the older variable file selected = true, okay and than remove this file
    fileSelected.value = true;
  }

  sheetForSelectingPdfOrImageIos(BuildContext context) {
    // ignore: missing_return
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
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
                  ListTile(
                    title: const Text('Pdf'),
                    leading: const Icon(Icons.picture_as_pdf_rounded),
                    onTap: () {
                      _openFileExplorer('upload');
                    },
                  ),
                  ListTile(
                    title: const Text('Image'),
                    leading: const Icon(Icons.image),
                    onTap: () async {
                      onGallery(context);
                      // await _imgFromCamera();
                      // Navigator.of(context).pop();
                      // showFileTypePicker(context);
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
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

      fileSelected.value = true;
      isImageSelectedFromCamera.value = false;

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
  // Future uploadDocuments(String filename, String extension, String path) async {
  //   print('uploadDocuments apicalll');
  //   doctorList = await TeleConsultationFunctionsAndVariables.gettingDocList(
  //       specName: selectedSpecName.value);
  //
  //
  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse(
  //       // 'https://testserver.indiahealthlink.com/consult/upload_medical_document'),
  //         API.iHLUrl + '/consult/upload_medical_document'),
  //   );
  //   request.headers.addAll(
  //     {
  //       'Content-Type': 'application/json',
  //       'ApiToken': '${API.headerr['ApiToken']}',
  //       'Token': '${API.headerr['Token']}',
  //     },
  //   );
  //   request.files.add(
  //     await http.MultipartFile.fromPath(
  //       'data',
  //       path,
  //       filename: filename,
  //     ),
  //   );
  //   request.fields.addAll(await {
  //     "ihl_user_id": "$iHLUserId",
  //     "document_name": "${fileNametext + '.' + extension.toLowerCase()}",
  //     "document_format_type": extension.toLowerCase() == 'pdf'
  //         ? "${extension.toLowerCase()}"
  //         : 'image', //"${extension.toLowerCase()}",
  //     "document_type": "$_chosenType",
  //   });
  //   var res = await request.send();
  //   print('success api ++');
  //   var uploadResponse = await res.stream.bytesToString();
  //   print(uploadResponse);
  //   final finalOutput = json.decode(uploadResponse);
  //   print(finalOutput['status']);
  //   if (finalOutput['status'] == 'document uploaded successfully') {
  //     Navigator.of(context).pop();
  //     //snackbar
  //     Get.snackbar('Uploaded!',
  //         '${camelize(fileNametext + '.' + extension.toLowerCase())} uploaded successfully.',
  //         icon: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Icon(Icons.check_circle, color: Colors.white)),
  //         margin: EdgeInsets.all(20).copyWith(bottom: 40),
  //         backgroundColor: AppColors.primaryAccentColor,
  //         colorText: Colors.white,
  //         duration: Duration(seconds: 5),
  //         snackPosition: SnackPosition.BOTTOM);
  //     medFiles = await MedicalFilesApi.getFiles();
  //     for (int i = 0; i < medFiles.length; i++) {
  //       var name;
  //       if (medFiles[i]['document_name'].toString().contains('.')) {
  //         var parse1 = medFiles[i]['document_name'].toString().replaceAll('.jpg', '');
  //         var parse2 = parse1.replaceAll('.jpeg', '');
  //         var parse3 = parse2.replaceAll('.png', '');
  //         var parse4 = parse3.replaceAll('.pdf', '');
  //         name = parse4;
  //       }
  //       filesNameList.add(name);
  //     }
  //
  //     ///added\\improvised for the confirm visit
  //     if (this.mounted) {
  //       setState(() {
  //         medFiles;
  //       });
  //     }
  //     // getFiles();
  //   }
  //   else {
  //     Get.snackbar('File not uploaded', 'Encountered some error while uploading. Please try again',
  //         icon: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Icon(Icons.cancel_rounded, color: Colors.white)),
  //         margin: EdgeInsets.all(20).copyWith(bottom: 40),
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         duration: Duration(seconds: 5),
  //         snackPosition: SnackPosition.BOTTOM);
  //   }
  // }

  String phoneValidator(String numb) {
    int tryp = int.tryParse(numb);
    if (tryp.toString().length < 10 && tryp.toString().length != 4) {
      return 'Mobile number should be at least 10 digit long';
    }
  }

  void freeConsultationProceed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get('data');
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
    String appStartDate =
        widget.slotSelectedTime['selectedTile'] + ' ' + widget.slotSelectedTime['time'];
    DateTime appEndTime = DateFormat('hh:mm a').parse(widget.slotSelectedTime['time']);
    String appEndTimeString =
        DateFormat('hh:mm a').format(appEndTime.add(const Duration(minutes: 30))).toString();

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
          currentDate.year.toString() + "-" + mm + "-" + dd + ' ' + widget.slotSelectedTime['time'];

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
        currentDateDay = "0${currentDate.day}";
      } else {
        currentDateDay = currentDate.day.toString();
      }

      if (currentDate.month.toString().length < 2) {
        currentDateMonth = "0${currentDate.month}";
      } else {
        currentDateMonth = currentDate.month.toString();
      }

      appointmentStartDateToSend = '${currentDate.year}-$currentDateMonth-$currentDateDay ' +
          widget.slotSelectedTime['time'];

      appointmentEndDateToSend = currentDate.year.toString() +
          "-" +
          currentDateMonth +
          "-" +
          currentDateDay +
          ' ' +
          appEndTimeString;
    } else if (appStartDate.contains('tomorrow') || appStartDate.contains('Tomorrow')) {
      DateTime tomorrow = currentDate.add(Duration(days: 1));
      String tomorrowDateDay;
      String tomorrowDateMonth;

      if (tomorrow.day.toString().length < 2) {
        tomorrowDateDay = "0${tomorrow.day}";
      } else {
        tomorrowDateDay = tomorrow.day.toString();
      }

      if (tomorrow.month.toString().length < 2) {
        tomorrowDateMonth = "0${tomorrow.month}";
      } else {
        tomorrowDateMonth = tomorrow.month.toString();
      }

      appointmentStartDateToSend =
          '${tomorrow.year}-$tomorrowDateMonth-$tomorrowDateDay ' + widget.slotSelectedTime['time'];
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
        currentDateDay = "0${currentDate.day}";
      } else {
        currentDateDay = currentDate.day.toString();
      }

      if (currentDate.month.toString().length < 2) {
        currentDateMonth = "0${currentDate.month}";
      } else {
        currentDateMonth = currentDate.month.toString();
      }

      appointmentStartDateToSend = '${currentDate.year}-$currentDateMonth-$currentDateDay ' +
          widget.slotSelectedTime['time'];
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

    iHLUserId = res['User']['id'];
    String _firstname = res['User']['firstName'];
    String _lastname = res['User']['lastName'];
    prefs.setString('consultantName', widget.doctorDetails.name.toString());
    prefs.setString('consultantId', widget.doctorDetails.ihlConsultantId.toString());
    prefs.setString('vendorName', widget.doctorDetails.vendorId.toString());
    prefs.setString('vendorConId', widget.doctorDetails.ihlConsultantId.toString());
    if (TeleConsultationFunctionsAndVariables.showVitals.value) {
      vitals['dateTime'] = vitals['dateTimeFormatted'];
      if (vitals['temperature'] != null && widget.doctorDetails.vendorId.toString() == 'GENIX')
        vitals['temperature'] = (vitals['temperature'] * 9 / 5) + 32;
    }
    log(vitals.toString());
    Map purposeDetails = {
      "name": "$_firstname $_lastname",
      "user_ihl_id": iHLUserId.toString(),
      "consultant_name": widget.doctorDetails.name.toString(),
      "vendor_consultant_id": widget.doctorDetails.vendorConsultantId.toString(),
      "ihl_consultant_id": widget.doctorDetails.ihlConsultantId.toString(),
      "vendor_id": widget.doctorDetails.vendorId.toString(),
      "specality": selectedSpeciality.toString().trim(),
      "consultation_fees": '0',
      "mode_of_payment": "online",
      "alergy": allergyController.text.toString() ?? "",
      "kiosk_checkin_history": (vitals != null && vitals.isNotEmpty) &&
              TeleConsultationFunctionsAndVariables.showVitals.value
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
      "vendor_name": widget.doctorDetails.vendorId.toString(),
      "appointment_model": "appointment",
      "reason_for_visit": reasonController.text.toString(),
      "notes": "",
      "document_id": selectedDocIdList,
    };
    bookedDate = bookingDate();
    _freeConsultation = FreeConsultation(
      consultationFees: widget.fees,
      purposeDetails: jsonEncode(purposeDetails),
      kioskCheckinHistory: (vitals != null && vitals.isNotEmpty) &&
              TeleConsultationFunctionsAndVariables.showVitals.value
          ? vitals
          : (vitals != null && vitals.isNotEmpty)
              ? {
                  "weightKG": vitals["weightKG"],
                  "bmi": vitals["bmi"],
                  'heightMeters': vitals["heightMeters"]
                }
              : {},
      userIhlId: iHLUserId.toString(),
      consultantName: widget.doctorDetails.name.toString(),
      vendorConsultantId: widget.doctorDetails.vendorConsultantId.toString(),
      ihlConsultantId: widget.doctorDetails.ihlConsultantId.toString(),
      vendorId: widget.doctorDetails.vendorId.toString(),
      specality: selectedSpeciality.toString().trim(),
      modeOfPayment: 'free',
      alergy: allergyController.text.toString() ?? "",
      appointmentStartTime: formattedStartDate.toString(),
      appointmentEndTime: formattedEndDate.toString(),
      appointmentDuration: "30 Min",
      appointmentStatus: liveCCall == true ? "Approved" : "Requested",
      vendorName: widget.doctorDetails.vendorId.toString(),
      appointmentModel: 'appointment',
      reasonForVisit: reasonController.text.toString(),
      documentId: selectedDocIdList,
      directCall: liveCCall,
      accountName: widget.doctorDetails.vendorId.toString() == "GENIX"
          ? widget.doctorDetails.accountName.toString()
          : '',
      affiliationUniqueName: Tabss.isAffi ? 'global_services' : affiliationUniquename,
      date: widget.slotSelectedTime['selectedTile'],
      userMobileNumber: mobileController.text,
      userEmail: emailController.text,
      usageType: "Free",
      mobileNumber: mobileController.text,
      paymentFor: "teleconsultation",
      paymentStatus: "completed",
      purpose: 'teleconsult',
      time: widget.slotSelectedTime['time'],
      serviceProvided: 'false',
      serviceProvidedDate: bookedDate[0],
      sourceDevice: 'mobile_app',
    );

    log(json.encode(_freeConsultation.toJson().toString()));
    log('Start Time');
    log(json.encode(_freeConsultation.toJson()));
    log(DateTime.now().toString());
    Get.to(TeleConsultationStagesScreen(
      // doctorDetails: widget.doctorDetails,
      startDate: appointmentStartDateToSend,
      endDate: appointmentEndDateToSend,
      JoinCall: widget.liveCall,
      freeConsultation: _freeConsultation,
      loading: loading.value,
      doctorDetails: widget.doctorDetails,
    ));
  }

  Map dataToSend() {
    String appStartDate =
        widget.slotSelectedTime['selectedTile'] + ' ' + widget.slotSelectedTime['time'];
    DateTime appEndTime = DateFormat('hh:mm a').parse(widget.slotSelectedTime['time']);
    String appEndTimeString =
        DateFormat('hh:mm a').format(appEndTime.add(const Duration(minutes: 30))).toString();
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
          currentDate.year.toString() + "-" + mm + "-" + dd + ' ' + widget.slotSelectedTime['time'];

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
        currentDateDay = "0${currentDate.day}";
      } else {
        currentDateDay = currentDate.day.toString();
      }

      if (currentDate.month.toString().length < 2) {
        currentDateMonth = "0${currentDate.month}";
      } else {
        currentDateMonth = currentDate.month.toString();
      }

      appointmentStartDateToSend = '${currentDate.year}-$currentDateMonth-$currentDateDay ' +
          widget.slotSelectedTime['time'];

      appointmentEndDateToSend = currentDate.year.toString() +
          "-" +
          currentDateMonth +
          "-" +
          currentDateDay +
          ' ' +
          appEndTimeString;
    } else if (appStartDate.contains('tomorrow') || appStartDate.contains('Tomorrow')) {
      DateTime tomorrow = currentDate.add(Duration(days: 1));
      String tomorrowDateDay;
      String tomorrowDateMonth;

      if (tomorrow.day.toString().length < 2) {
        tomorrowDateDay = "0${tomorrow.day}";
      } else {
        tomorrowDateDay = tomorrow.day.toString();
      }

      if (tomorrow.month.toString().length < 2) {
        tomorrowDateMonth = "0${tomorrow.month}";
      } else {
        tomorrowDateMonth = tomorrow.month.toString();
      }

      appointmentStartDateToSend =
          '${tomorrow.year}-$tomorrowDateMonth-$tomorrowDateDay ' + widget.slotSelectedTime['time'];
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
        currentDateDay = "0${currentDate.day}";
      } else {
        currentDateDay = currentDate.day.toString();
      }

      if (currentDate.month.toString().length < 2) {
        currentDateMonth = "0${currentDate.month}";
      } else {
        currentDateMonth = currentDate.month.toString();
      }

      appointmentStartDateToSend = '${currentDate.year}-$currentDateMonth-$currentDateDay ' +
          widget.slotSelectedTime['time'];
      appointmentEndDateToSend = currentDate.year.toString() +
          "-" +
          currentDateMonth +
          "-" +
          currentDateDay +
          ' ' +
          appEndTimeString;
    }

    // if(selectedDocIdList.length>0){
    widget.doctorDetails.livecall = liveCCall;
    return {
      'start_date': appointmentStartDateToSend,
      'end_date': appointmentEndDateToSend,
      'doctor': widget.doctorDetails,
      'reason': reasonController.text ?? "",
      'alergy': allergyController.text ?? "",
      'data': c1 == true ? vitalList : [],
      'livecall': liveCCall,
      'fees': widget.fees,
      'specality': selectedSpeciality.toString().trim(),
      'email': emailController.text,
      'mobile_number': mobileController.text,
      'document_id': selectedDocIdList,
    };
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

  bookingDate() {
    Map dataa = dataToSend();
    return [dataa['start_date'], dataa['end_date']];
  }

  bool validate() {
    if (_isPageLoaded) _isPageJustEntered = false;
    if (emailValidator(emailController.text) == null &&
        phoneValidator(mobileController.text) == null &&
        reason.toString() != 'null' &&
        reasonValidator(reason.value) == null) {
      return true;
    }
    return false;
  }

  // ignore: missing_return
  String emailValidator(String mail) {
    // mail = 'test';
    bool isMail = mail.contains(
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"), 0);
    if ((mail.isEmpty)) {
      return 'Enter valid Email';
    }
  }

  String mobileValidator(String numb) {
    int tryp = int.tryParse(numb);
    if (tryp == null || numb.isEmpty) {
      return 'Please enter a valid mobile number.';
    }
    if (tryp < 999999999) {
      return 'The mobile number must be 10 digits.';
    }
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
            fileSelected.value = true;
            isImageSelectedFromCamera.value = true;
          });
        }
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
        showFileTypePicker(context);
      }
    } else {
      loading.value = false;
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
}
