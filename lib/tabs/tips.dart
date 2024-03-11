// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:ihl/views/home_screen.dart';

class Tab1 extends StatefulWidget {
  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  var final_recommedation = "";
  var final_energyneed = "";
  var final_exercislight = "";
  var final_exercismoderate = "";
  var final_exercisintense = "";
  var recomedation = "";
  var restrictions = "";
  bool loading = true;
  bool couldnotfetch = false;
  final Widget couldntfetchMessage = Container(
    child: Center(
        child: Column(
      children: [
        Icon(
          Icons.error_outline,
          color: AppColors.appTextColor,
          size: 100,
        ),
        Text('Sorry, failed to fetch health tips', style: TextStyle(color: AppColors.appTextColor)),
      ],
    )),
  );
  Future<String> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response1;
    var raw = prefs.get('data');
    if (raw == null || raw == '') {
      couldnotfetch = true;
      loading = false;
      if (this.mounted) {
        setState(() {});
      }
      return '';
    }
    raw = raw == null || raw == '' ? '{"LastCheckin":{}}' : raw;
    var data = jsonDecode(raw);
    if (data['LastCheckin'] == null) {
      data['LastCheckin'] = {};
    }
    Map user = data['User'];
    var LastCheckin = data['LastCheckin'];

    var BMIStatus = data['LastCheckin']['bmiClass'];
    var BMCStatus = data['LastCheckin']['fatClass'];
    var BPStatus = data['LastCheckin']['bpClass'];
    var SPO2Status = data['LastCheckin']['spo2Class'];
    var TEMPStatus = data['LastCheckin']['temperatureClass'];
    var PULSEStatus = data['LastCheckin']['pulseClass'];
    var GENDER = data['User']['gender'];

    var thisGender = GENDER;
    var dietID = "GD1";

    var dietTipsResponse = await rootBundle.loadString('assets/dietTips.json');
    var dietFitnessRecommendationsResponse =
        await rootBundle.loadString('assets/dietFitnessRecommendations.json');

    var dietTIpJson = json.decode(dietTipsResponse);
    var thisBMIStatus;
    var thisBMCStatus;
    var thisBPStatus;
    var thisSPO2Status;
    var thisTEMPStatus;
    var thisPULSEStatus;

    if (BMIStatus == '' || BMIStatus == null) {
      thisBMIStatus = '';
    } else {
      thisBMIStatus = BMIStatus;
    }
    if (BMCStatus == '' || BMCStatus == null) {
      thisBMCStatus = '';
    } else {
      thisBMCStatus = BMCStatus;
    }
    if (BPStatus == '' || BPStatus == null) {
      thisBPStatus = '';
    } else {
      thisBPStatus = BPStatus;
    }
    if (SPO2Status == '' || SPO2Status == null) {
      thisSPO2Status = '';
    } else {
      thisSPO2Status = SPO2Status;
    }
    if (TEMPStatus == '' || TEMPStatus == null) {
      thisTEMPStatus = '';
    } else {
      thisTEMPStatus = TEMPStatus;
    }
    if (PULSEStatus == '' || PULSEStatus == null) {
      thisPULSEStatus = '';
    } else {
      thisPULSEStatus = PULSEStatus;
    }

    var filteredList = dietTIpJson.where(((val) =>
        (val["bp"] == thisBPStatus) &&
        (val["spo2"] == thisSPO2Status) &&
        (val["pulse"] == thisPULSEStatus) &&
        (val["bmi"] == thisBMIStatus) &&
        (val["bmc"] == thisBMCStatus) &&
        (val["temp"] == thisTEMPStatus)));
    if (filteredList.length > 0) {
      if (thisGender == 'm' || thisGender == 'male') {
        if (filteredList.last['male'] != "") {
          dietID = filteredList.last['male'];
        } else {
          dietID = "GD1";
        }
      } else if (thisGender == 'f' || thisGender == 'female') {
        if (filteredList.last['female'] != "") {
          // Filtering dietplan id based on gender(Female) from the filtered vital data
          dietID = filteredList.last['female'];
        } else {
          dietID = "GD1";
        }
      }
    } else {
      dietID = "GD1";
    }

    var parsedDietPlan = jsonDecode(dietFitnessRecommendationsResponse);

    // Retrive Diet information associated with DietPlan ID
    var filteredPlan = parsedDietPlan.where((val) => val["diet_plan"] == dietID);
    if (filteredPlan.last['restrictions'] == "") {
      restrictions = "N/A";
    } else {
      restrictions = filteredPlan.last['restrictions'];
    }
    if (filteredPlan.last['Recomedation'] == "") {
      recomedation = "N/A";
    } else {
      recomedation = filteredPlan.last['Recomedation'];
    }

    final_recommedation = filteredPlan.last['recommedation'];
    final_energyneed = filteredPlan.last['energy_needed'];
    final_exercislight = filteredPlan.last['exercise_light'];
    final_exercismoderate = filteredPlan.last['exercise_moderate'];
    final_exercisintense = filteredPlan.last['exercise_intense'];
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    int dailyTarget = prefs.getInt('daily_target');
    if (dailyTarget != 0 || dailyTarget != null) {
      final_energyneed = dailyTarget.toString() + ' Cals';
    }

    response1 = final_recommedation +
        final_energyneed +
        final_exercislight +
        final_exercismoderate +
        final_exercisintense +
        restrictions +
        recomedation;
    loading = false;
    return response1;
  }

  @override
  void initState() {
    super.initState();
    this.getData().then((value) {
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      width = 500;
    }
    return WillPopScope(
        onWillPop: () {
          //   Navigator.pushAndRemoveUntil(
          // context,
          // MaterialPageRoute(
          //     builder: (context) => HomeScreen(
          //       introDone: true,
          //     )),
          //     (Route<dynamic> route) => false);
          Get.off(LandingPage());
        },
        child: BasicPageUI(
          appBar: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              // HomeScreen(introDone: true)),
                              LandingPage()),
                      (Route<dynamic> route) => false),
                  color: Colors.white,
                  tooltip: 'Back',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Recommendation',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: ScUtil().setSp(28),
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  'Customized diet tips from our Professional Nutrionist\nPooja Malhotra (Nutritionist, Masters in Food and Nutrition)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          body: loading
              ? Center(child: CircularProgressIndicator())
              : couldnotfetch
                  ? couldntfetchMessage
                  : Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              shadowColor: FitnessAppTheme.grey.withOpacity(0.5),
                              elevation: 2,
                              borderOnForeground: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                  side: BorderSide(
                                    width: 2,
                                    color: FitnessAppTheme.nearlyWhite,
                                  )),
                              margin: EdgeInsets.all(10),
                              color: AppColors.cardColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        'Diet Recommedation',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: FitnessAppTheme.grey,
                                          fontSize: ScUtil().setSp(18),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        final_recommedation,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: ScUtil().setSp(14),
                                            color: FitnessAppTheme.grey,
                                            height: 2),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: Text(
                                        'Energy Needed',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: FitnessAppTheme.grey,
                                          fontSize: ScUtil().setSp(18),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        final_energyneed,
                                        style: TextStyle(
                                          fontSize: ScUtil().setSp(14),
                                          color: CardColors.textColor,
                                          height: 2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: Text(
                                        'Light Exercises ',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: FitnessAppTheme.grey,
                                          fontSize: ScUtil().setSp(18),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        final_exercislight,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: ScUtil().setSp(14),
                                          color: CardColors.textColor,
                                          height: 2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: Text(
                                        'Intense Exercises ',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: FitnessAppTheme.grey,
                                          fontSize: ScUtil().setSp(18),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        final_exercisintense,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: ScUtil().setSp(14),
                                          color: CardColors.textColor,
                                          height: 2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: Text(
                                        'Special Recommedations',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: FitnessAppTheme.grey,
                                          fontSize: ScUtil().setSp(18),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        recomedation,
                                        style: TextStyle(
                                          fontSize: ScUtil().setSp(14),
                                          color: CardColors.textColor,
                                          height: 2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: Text(
                                        'Restrictions',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          color: FitnessAppTheme.grey,
                                          fontSize: ScUtil().setSp(18),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        restrictions,
                                        style: TextStyle(
                                          fontSize: ScUtil().setSp(14),
                                          color: CardColors.textColor,
                                          height: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ));
  }
}
