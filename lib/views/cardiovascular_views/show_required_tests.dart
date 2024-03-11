import 'dart:async';
import 'dart:convert';
import 'dart:io';

// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/cardiovascular_views/cardio_file_.dart';
import 'package:ihl/views/cardiovascular_views/cardio_navbar.dart';
import 'package:ihl/views/cardiovascular_views/cardiovascular_survey.dart';
import 'package:ihl/views/cardiovascular_views/show_required_vitals.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowRequiredTest extends StatefulWidget {
  ShowRequiredTest({Key key}) : super(key: key);

  @override
  _ShowRequiredTestState createState() => _ShowRequiredTestState();
}

class _ShowRequiredTestState extends State<ShowRequiredTest> {
  @override
  void initState() {
    getKioskData();
    super.initState();
  }

  var age;
  var gender;
  var height;
  var weight;
  var bmi;
  var bmi_status;
  var systolic_blood_pressure;
  var systolic_blood_pressure_status;
  var percentage_body_fat;
  var percentage_body_fat_status;
  var body_fat_mass;
  var body_fat_mass_status;
  var visceral_fat;
  var visceral_fat_status;
  var waist_to_hip_ratio;
  var waist_to_hip_ratio_status;
  var __notAvailableKeys = [];
  var loading = true;
  var vitalsExpired = '';
  var vitalsExpiredTxt =
      'Last checkup should be under 7 days. \nVisit your Nearby H-pod for Vital Checkup. \n '; //H - Pod Nearby your location : \n
  var vitalsMissingTxt =
      'Some Vital are Not available for Cardiovascular Checkup. \nVisit your Nearby H-Pod for Vital Checkup. \n '; //H - Pod Nearby your location : \n
  Map vitals;
  String _age, _gender, _email, _fName, _lName;
  getKioskData() async {
    // await _determinePosition();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    var res = jsonDecode(data);
    _fName = res['User']['firstName'];
    _fName ??= '';
    _lName = res['User']['lastName'];
    _lName ??= '';
    _email = res['User']['email'];
    _email ??= '';
    // _age = dob;
    String datePattern = "MM/dd/yyyy";
    var dob = res['User']['dateOfBirth'].toString();
    DateTime today = DateTime.now();
    DateTime birthDate = DateFormat(datePattern).parse(dob);
    _age = (today.year - birthDate.year).toString();
    _gender = res['User']['gender'];
    _gender.toLowerCase() == 'm' ? _gender = 'Male' : _gender = 'Female';

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
          key != "percent_body_fat_status" &&

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
          //waist_to_hip_ratio
          key != "waist_hip_ratio" &&
          key != "waist_hip_ratio_status" &&
          //visceral_fat
          key != "visceral_fat" &&
          key != "visceral_fat_status" &&
          //body_fat_mass
          key != "body_fat_mass" &&
          key != "body_fat_mass_status");
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
    print(vitals);
    if (vitals.toString() != "null" && vitals.toString() != "[]" && vitals.toString() != "") {
      age = res['User']['dateOfBirth'];
      gender = res['User']['gender'];
      height = vitals['heightMeters'] ?? '';
      weight = vitals['weightKG'];
      if (weight == null) weight = res['User']['userInputWeightInKG'];

      bmi = vitals['bmi'];
      bmi_status = vitals['bmiClass'];
      systolic_blood_pressure =
          vitals['systolic'].toString() + '/' + vitals['diastolic'].toString();
      systolic_blood_pressure_status = vitals['bpClass'];
      // percentage_body_fat = vitals['percent_body_fat'];
      // percentage_body_fat_status = vitals['percent_body_fat_status'];
      // body_fat_mass = vitals['body_fat_mass'];
      // body_fat_mass_status = vitals['body_fat_mass_status'];
      // visceral_fat = vitals['visceral_fat'];
      // visceral_fat_status = vitals['visceral_fat_status'];
      // waist_to_hip_ratio = vitals['waist_hip_ratio'];
      // waist_to_hip_ratio_status = vitals['waist_hip_ratio_status'];
      checkAvailabilityOfVitals();
    } else {
      vitalsExpired = 'Expired';
      loading = false;
      setState(() {});
      // await createMarker();
    }
  }

  List notAvailableKeys = [];
  checkAvailabilityOfVitals() async {
    ///1.)  if vital are older than a week , Than show map
    var lastCheckinDateString =
        int.parse(vitals['dateTime'].toString().replaceAll('/Date(', '').replaceAll(')/', ''));
    DateTime lastCheckinDate = DateTime.fromMillisecondsSinceEpoch(lastCheckinDateString);
    if (lastCheckinDate.isBefore(DateTime.now().subtract(Duration(days: 7)))) {
      vitalsExpired = 'Expired';
      loading = false;
      setState(() {});
      // await createMarker();
    }

    /// 2.) vitals are latest -> than check all the vital are available or not
    else {
      List keys = ['bmi', 'systolic', 'diastolic'];
      for (int i = 0; i < keys.length; i++) {
        if (vitals.containsKey(keys[i].toString())) {
          //nothing
        } else {
          notAvailableKeys.add(keys[i].toString());
        }
      }
      loading = false;
      if (notAvailableKeys.length > 0) vitalsExpired = 'Missing';
      setState(() {});
    }
  }

  List keys = [
    'Height',
    'Weight',
    'Bmi',
    "Cholesterol",
    "Blood Pressure Systolic",
    "Blood Pressure Diastolic",
  ];

  @override
  Widget build(BuildContext context) {
    List icons = [
      Icons.height,
      FontAwesomeIcons.weight,
      FontAwesomeIcons.tape,
      FontAwesomeIcons.heartbeat,
      // Icons.volunteer_activism,
      Icons.bloodtype_sharp,
      Icons.bloodtype_sharp,
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor.withOpacity(0.7),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
        title: Center(
          child: Text(
            'Required  Vitals',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.download_rounded),
            onPressed: () async {
              navigateOnCall(context);
            },
            color: Colors.white,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryAccentColor.withOpacity(0.8),
        // backgroundColor: HexColor('#6F72CA'),
        label: Text('Continue with test',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        icon: Icon(
          Icons.animation_sharp,
          color: Colors.white,
        ),
        onPressed: () {
          currentIndexOfCardio = ValueNotifier<int>(0);
          if (vitalsExpired == 'Missing' || vitalsExpired == 'Expired')
            Navigator.of(context).pushReplacementNamed(Routes.CardiovascularSurvey);
          // alertBox(
          //     vitalsExpired == 'Missing'
          //         ? vitalsMissingTxt
          //         : vitalsExpiredTxt,
          //     FitnessAppTheme.grey,
          //     true);
          else
            Navigator.of(context).pushReplacementNamed(Routes.CardiovascularSurvey);
        },
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Padding(
          //    padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
          // child: patientInf(age: '23',datetime: DateTime.now().toString().substring(0,10),gender: 'Male',userEmailFromHistory: 'email@gmail.com',userFirstNameFromHistory: 'Sumit',userLastNameFromHistory: 'Mandloi'),
          //  ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              SizedBox(
                width: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 15,
                child: Text(
                  'Required Vitals For Test :-',
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.appTextColor,
                    letterSpacing: 0.2,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: 20,
          ),

          col(),

          Visibility(
            visible: false,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: keys.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      child: Row(
                        children: [
                          Icon(
                            icons[index],
                            color: AppColors.primaryColor.withOpacity(1),
                            size: 30,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '${keys[index]}',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.normal,
                              color: AppColors.appTextColor,
                              letterSpacing: 0.2,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ));
                }),
          ),
        ],
      ),
    );
  }

  alertBox(alertText, txtColor, allow) {
    onTap() {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => CardioNavBar(
                    index: 1,
                  )),
          (Route<dynamic> route) => false);
    }

    _buildChild(BuildContext context, StateSetter mystate) => CustomAlertWidget(
          alertText: alertText,
          allow: false,
          context: context,
          isAgree: false,
          mystate: mystate,
          txtColor: txtColor,
          continueOnTap: onTap,
          changeOnTap: onTap,
        );
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter mystate) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: _buildChild(context, mystate),
                );
              },
            ),
          );
        });
  }

  Widget col() {
    return Column(
      children: [
        // FileListButton(
        //   notAvailableKeyLength: 0,
        //   vitalName: 'age',
        //   vitalValue: '',
        //   vitalStatus: '',
        // ),
        // FileListButton(
        //   notAvailableKeyLength: 0,
        //   vitalName: 'gender',
        //   vitalValue: '',
        //   vitalStatus: '',
        // ),
        //height
        /// ['heightMeters', 'weightKG', 'bmi', 'systolic', 'diastolic'];
        FileListButton(
          notAvailableKeyLength: height.toString() == 'null' || height.toString() == '' ? 1 : 0,
          vitalName: 'height',
          vitalValue: height.toString(),
          vitalStatus: '',
          unit: height.toString() != 'null' ? ' M' : '',
        ),
        //wt
        FileListButton(
          notAvailableKeyLength: weight.toString() == 'null' || weight.toString() == '' ? 1 : 0,
          vitalName: 'weight',
          vitalValue: weight.toString(),
          vitalStatus: '',
          unit: weight.toString() != 'null' ? ' Kg' : '',
        ),
        FileListButton(
            notAvailableKeyLength: notAvailableKeys.contains('bmi') ? 1 : 0,
            vitalName: 'BMI',
            vitalValue: bmi.toString(),
            vitalStatus: bmi_status != null ? bmi_status : '',
            unit: ''),

        /// var percentage_body_fat;
        /// var percentage_body_fat_status;
        // FileListButton(
        //   notAvailableKeyLength: __notAvailableKeys.length,
        //   vitalName: 'Percentage body fat',
        //   vitalValue: '', //percentage_body_fat.toString(),
        //   vitalStatus: percentage_body_fat_status.toString(),
        // ),
        /// var body_fat_mass;
        /// var body_fat_mass_status;

        // FileListButton(
        //   notAvailableKeyLength: __notAvailableKeys.length,
        //   vitalName: 'body fat mass',
        //   vitalValue: body_fat_mass.toString(),
        //   vitalStatus: body_fat_mass_status.toString(),
        // ),
        // var visceral_fat;
        // var visceral_fat_status;
        // FileListButton(
        //   notAvailableKeyLength: __notAvailableKeys.length,
        //   vitalName: 'visceral fat',
        //   vitalValue: visceral_fat.toString(),
        //   vitalStatus: visceral_fat_status.toString(),
        // ),
        // var systolic_blood_pressure;
        FileListButton(
          notAvailableKeyLength:
              notAvailableKeys.contains('systolic') && notAvailableKeys.contains('diastolic')
                  ? 1
                  : 0,
          vitalName: 'Blood Pressure',
          vitalValue: systolic_blood_pressure.toString().contains('null')
              ? ''
              : systolic_blood_pressure.toString(),
          vitalStatus: systolic_blood_pressure_status.toString(),
          unit: systolic_blood_pressure.toString().contains('null') ? ' mmHg' : '',
        ),
        // var waist_to_hip_ratio;
        FileListButton(
          notAvailableKeyLength: 0,
          vitalName: 'Cholesterol',
          vitalValue: '',
          vitalStatus: '',
        ),
      ],
    );
  }

  TextStyle txtstyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.appTextColor,
    letterSpacing: 0.4,
    fontFamily: 'Poppins',
  );
  patientInf(
      {userFirstNameFromHistory,
      userLastNameFromHistory,
      age,
      gender,
      userEmailFromHistory,
      datetime}) {
    return Column(children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.start, //spaceBetween
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Name :- ',
                      style: txtstyle,
                    ),
                    TextSpan(
                      text: userFirstNameFromHistory + " " + userLastNameFromHistory,
                      style: txtstyle.copyWith(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: age != '' && age != "N/A" ? 'Age :- ' : '',
                      style: txtstyle,
                    ),
                    TextSpan(
                      text: age != '' && age != "N/A" ? ' $age years' : '',
                      style: txtstyle.copyWith(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: gender != '' && gender != "N/A" ? 'Gender :- ' : '',
                      style: txtstyle,
                    ),
                    TextSpan(
                      text: gender != '' && gender != "N/A" ? ' $gender' : '',
                      style: txtstyle.copyWith(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: userEmailFromHistory != '' && userEmailFromHistory != "N/A"
                          ? 'Email :- '
                          : '',
                      style: txtstyle,
                    ),
                    TextSpan(
                      text: userEmailFromHistory != '' && userEmailFromHistory != "N/A"
                          ? '$userEmailFromHistory'
                          : '',
                      style: txtstyle.copyWith(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Date :- ',
                      style: txtstyle,
                    ),
                    TextSpan(
                      text: '$datetime',
                      style: txtstyle.copyWith(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ]),
          ]),
    ]);
  }

  navigateOnCall(context) async {
    // AwesomeNotifications().cancelAll();
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

    final status = await permission.request();

    if (status.isGranted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString(
      //     "userpincodeFromHistory",
      //     pincode);
      // Get.snackbar(
      //   '',
      //   'Invoice will be saved in your mobile!',
      //   backgroundColor: AppColors.primaryAccentColor,
      //   colorText: Colors.white,
      //   duration: Duration(seconds: 5),
      //   isDismissible: false,
      // );
      Future.delayed(new Duration(seconds: 2), () {
        requiredVitals(context, '', true,
            gender: _gender, age: _age, email: _email, fName: _fName, lName: _lName);

        ///loading off
      });
    } else if (status.isDenied) {
      await permission.request();
      await Permission.accessMediaLocation.request();
      Get.snackbar(
        'Storage Access Denied',
        'Allow Storage permission to continue',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        isDismissible: false,
      );
      Future.delayed(Duration(seconds: 2), () {
        requiredVitals(context, '', true,
            gender: _gender, age: _age, email: _email, fName: _fName, lName: _lName);
      });
    } else if (status.isDenied) {
      await permission.request();
      await Permission.accessMediaLocation.request();
      Get.snackbar('Storage Access Denied', 'Allow Storage permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    } else {
      Get.snackbar('Storage Access Denied', 'Allow Storage permission to continue',
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
}

///  this
class CustomAlertWidget extends StatefulWidget {
  CustomAlertWidget(
      {this.allow,
      this.isAgree,
      this.alertText,
      this.txtColor,
      this.context,
      this.mystate,
      this.continueOnTap,
      this.changeOnTap});

  final allow;
  bool isAgree;
  final alertText;
  final txtColor;
  final context;
  final mystate;
  Function continueOnTap;
  Function changeOnTap;

  @override
  _CustomAlertWidgetState createState() => _CustomAlertWidgetState();
}

class _CustomAlertWidgetState extends State<CustomAlertWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    return Container(
      height: widget.alertText.length > 30 ? 390 : 350,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Column(
        children: <Widget>[
          Container(
            child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    SizedBox(
                      // width: 100,
                      height: 140,
                      // child: Image.asset(''),
                      child: Image.network(
                        'https://indiahealthlink.com/wp-content/uploads/2022/05/img4.png',
                        fit: BoxFit.cover,
                      ),
                      // 'https://i.postimg.cc/gj4Dfy7g/Objective-PNG-Free-Download.png'),
                    ),
                  ],
                )),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, //AppColors.primaryColor,
                shape: BoxShape.rectangle,
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          ),
          // SizedBox(
          //   height: 24,
          // ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: Text(
              widget
                  .alertText, //+'\n'+(int.parse((goalCaloriesIntake))*bmrRateForAlert).toString(),
              style: TextStyle(
                color: widget.txtColor,
                fontFamily: 'Poppins',
                fontSize: ScUtil().setSp(17),
                letterSpacing: 0.2,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.5,
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 13.0, bottom: 13.0, right: 15, left: 15),
                  child: Text(
                    'Continue',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                onPressed: () async {
                  widget.continueOnTap();
                },
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
