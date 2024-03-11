import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/cardio_dashboard/controllers/controller_for_cardio.dart';
import 'package:ihl/cardio_dashboard/models/last_updated_medicaldata_model.dart';
import 'package:ihl/cardio_dashboard/models/store_medical_data.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/views/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../constants/app_texts.dart';
import '../../constants/spKeys.dart';
import '../../constants/vitalUI.dart';
import '../../models/ecg_calculator.dart';
import '../../new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../utils/app_colors.dart';
import '../../views/teleconsultation/consultantsFilter.dart';
import '../models/retrive_medical_data_model.dart';
import '../models/user_data_model_cardio.dart';

class CardioGetXController extends GetxController {
  @override
  void onInit() {
    updateUserdata();
    visceralFat();
    getData();

    super.onInit();
  }

  bool updatebp = false;
  double score = 0.0;
  User userDataCardio = User();
  dynamic datum;
  dynamic bmi = [];
  dynamic bp = [];
  dynamic vsFat = [];
  dynamic CholestrolUpdated = [];
  RetriveMedicalData retrivedMedicalData = RetriveMedicalData();
  bool updatingVitalValue = false;
  StoreMedicalData medicalDataValuesToStore;
  LastUpdatedMedicaldata lastUpdatedMedicaldata = LastUpdatedMedicaldata();
  updateUserdata() async {
    userDataCardio = await CardioController().userDataGetterCardio();
    print(userDataCardio.id);
    lastUpdatedMedicaldata = await CardioController().medicalData(userId: userDataCardio.id);
    await retrieveMedicalData();
    await updateScoreValue();
    updatingVitalValue = false;
    update(["status", 'vitalscard']);
  }

  updateScoreValue() async {
    score = lastUpdatedMedicaldata.score ?? 0.0;
    update(['score', 'vitalscard']);
  }

// 👨‍⚕️ consultant list for cardiologist and diet consultation
  cardiolosit({String consultType}) async {
    Map res = await CardioController().consultantDataList(userId: userDataCardio.id);
    List consultationType = res["consult_type"];
    for (int i = 0; i < consultationType.length; i++) {
      if (consultationType[i]["consultation_type_name"] == "Medical Consultation") {
        consultationType[i]["consultation_type_name"] = "Doctor Consultation";
      }
    }
    Map currenttype = {};
    for (var e in consultationType) {
      if (e["consultation_type_name"] == consultType) {
        currenttype = e;
      }
    }
    List doctors = [];
    Map finalList = {};
    for (var e in currenttype["specality"]) {
      if (consultType == "Doctor Consultation") {
        if (e["specality_name"] == "Cardiology") {
          finalList = e;
          doctors = await ConsFilter.filterNonAffiliatedConsultants(e, false);
        }
      }
      if (consultType == "Health Consultation") {
        if (e["specality_name"] == "Diet Consultation") {
          finalList = e;
          doctors = await ConsFilter.filterNonAffiliatedConsultants(e, false);
        }
      }
    }
    finalList["filter_consultant_list"] = doctors;
    Get.to(SelectConsutantScreen(
      liveCall: true,
      arg: finalList,
    ));
  }

  ///visceral fat
  var viseralFFat;
  String visceralFats = 'no';
  visceralFat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //viseralFFat = prefs.getString('ViseralValue') ?? 0;
    try {
      viseralFFat = localSotrage.read(LSKeys.vitalsData)["VF"];
    } catch (e) {
      debugPrint(e.toString());
    }
    if (prefs.get("vf_status") != null) {
      var visceralFatStatus = prefs.get("vf_status");
      if (visceralFatStatus == "high" || visceralFatStatus == "High") {
        visceralFats = 'yes';
      } else {
        visceralFats = 'no';
      }
    }
    update(['vitalscard']);
  }

  //Navigate to graphs
  BuildContext context;
  var data;
  var gproteinl,
      gproteinh,
      gecll,
      geclh,
      gicll,
      giclh,
      glowSmmReference,
      glowBmcReference,
      glowPbfReference,
      ghighPbfReference,
      glowFatReference,
      ghighFatReference,
      gwaisttoheightratiolow,
      gHeight,
      gWeight,
      gBmi,
      gwaisttoheightratiohigh;
  Map allScores = {};

  List vitalsToShow = [];
  updateGetDataDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var updatedData = await CardioController().retriveUserData();
    var userCheckinData = await CardioController().getCheckinData(iHLUserId: userDataCardio.id);
    prefs.setString(SPKeys.userData, jsonEncode(updatedData));
    prefs.setString(SPKeys.vitalsData, jsonEncode(userCheckinData));
    updateUserdata();
    await datumCollect();
    await MyvitalsApi().vitalDatas(updatedData);
    Get.back();
    updatingVitalValue = false;
    update(["vitalscard", "status"]);
    await getData();
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var raw = prefs.get(SPKeys.userData);
    if (raw == '' || raw == null) {
      raw = '{}';
    }

    data = jsonDecode(raw);

    Map user = data['User'];
    if (user == null) {
      user = {};
    }
    var userVitalst = prefs.getString(SPKeys.vitalsData);
    if (userVitalst == null || userVitalst == '' || userVitalst == '[]') {
      if (user['userInputWeightInKG'] == null ||
          user['userInputWeightInKG'] == '' ||
          user['heightMeters'] == null ||
          user['heightMeters'] == '' ||
          ((user['email'] == null || user['email'] == '') &&
              (user['mobileNumber'] == null || user['mobileNumber'] == ''))) {
        // isVerified = false;
        // loading = false;
        // if (this.mounted) {
        //   setState(() {});
        //   return;
        // }
      }
      userVitalst = '[{}]';
    }
    List userVitals = jsonDecode(userVitalst);

    //get inputted height weight if values are not available

    if (userVitals[0]['weightKG'] == null) {
      userVitals[0]['weightKG'] = user['userInputWeightInKG'];
    }
    if (userVitals[0]['heightMeters'] == null) {
      userVitals[0]['heightMeters'] = user['heightMeters'];
    }
    //Calculate bmi
    if (userVitals[0]['bmi'] == null) {
      userVitals[0]['bmi'] = calcBmi(
          height: userVitals[0]['heightMeters'].toString(),
          weight: userVitals[0]['weightKG'].toString());
      userVitals[0]['bmiClass'] = bmiClassCalc(userVitals[0]['bmi']);
    }
    allScores = {};
    //prepare data
    double finalWeight = 0;
    double finalHeight = 0;
    var bcml = "20.00";
    var bcmh = "25.00";
    var lowMineral = "2.00";
    var highMineral = "3.00";
    var heightinCMS = userVitals[0]['heightMeters'] * 100;
    var weight =
    userVitals[0]['weightKG'].toString() == "" ? '0' : userVitals[0]['weightKG'].toString();
    var gender = user['gender'].toString();
    var lowSmmReference,
        lowFatReference,
        highSmmReference,
        highFatReference,
        lowBmcReference,
        highBmcReference,
        icll,
        iclh,
        ecll,
        eclh,
        proteinl,
        proteinh,
        waisttoheightratiolow,
        waisttoheightratiohigh,
        lowPbfReference,
        highPbfReference;

    if (gender != 'm') {
      lowPbfReference = "18.00";
      highPbfReference = "28.00";
      var femaleHeightWeight = [
        [147, 45, 59],
        [150, 45, 60],
        [152, 46, 62],
        [155, 47, 63],
        [157, 49, 65],
        [160, 50, 67],
        [162, 51, 69],
        [165, 53, 70],
        [167, 54, 72],
        [170, 55, 74],
        [172, 57, 75],
        [175, 58, 77],
        [177, 60, 78],
        [180, 61, 80]
      ];
      var j = 0;
      while (femaleHeightWeight[j][0] <= heightinCMS) {
        j++;
        if (j == 13) {
          break;
        }
      }
      var wtl, wth;
      if (j == 0) {
        wtl = femaleHeightWeight[j][1];
        wth = femaleHeightWeight[j][2];
      } else {
        wtl = femaleHeightWeight[j - 1][1];
        wth = femaleHeightWeight[j - 1][2];
      }
      lowSmmReference = (0.36 * wtl);
      highSmmReference = (0.36 * wth);
      lowFatReference = (0.18 * double.tryParse(weight));
      highFatReference = (0.28 * double.tryParse(weight));
      lowBmcReference = "1.70";
      highBmcReference = "3.00";
      icll = (0.3 * wtl);
      iclh = (0.3 * wth);
      ecll = (0.2 * wtl);
      eclh = (0.2 * wth);
      proteinl = (0.116 * double.tryParse(weight));
      proteinh = (0.141 * double.tryParse(weight));
      waisttoheightratiolow = "0.35";
      waisttoheightratiohigh = "0.53";
    } else {
      lowPbfReference = "10.00";
      highPbfReference = "20.00";
      var maleHeightWeight = [
        [155, 55, 66],
        [157, 56, 67],
        [160, 57, 68],
        [162, 58, 70],
        [165, 59, 72],
        [167, 60, 74],
        [170, 61, 75],
        [172, 62, 77],
        [175, 63, 79],
        [177, 64, 81],
        [180, 65, 83],
        [182, 66, 85],
        [185, 68, 87],
        [187, 69, 89],
        [190, 71, 91]
      ];
      var k = 0;
      while (maleHeightWeight[k][0] <= heightinCMS) {
        k++;
        if (k == 14) {
          break;
        }
      }
      var wtl, wth;
      if (k == 0) {
        wtl = maleHeightWeight[k][1];
        wth = maleHeightWeight[k][2];
      } else {
        wtl = maleHeightWeight[k - 1][1];
        wth = maleHeightWeight[k - 1][2];
      }
      lowSmmReference = (0.42 * wtl);
      highSmmReference = (0.42 * wth);
      lowFatReference = (0.10 * double.parse(weight ?? '0'));
      highFatReference = (0.20 * double.parse(weight ?? '0'));
      lowBmcReference = "2.00";
      highBmcReference = "3.70";
      icll = (0.3 * wtl);
      iclh = (0.3 * wth);
      ecll = (0.2 * wtl);
      eclh = (0.2 * wth);
      proteinl = (0.109 * double.parse(weight));
      proteinh = (0.135 * double.parse(weight));
      waisttoheightratiolow = "0.35";
      waisttoheightratiohigh = "0.57";
    }

    var proteinStatus;
    var ecwStatus;
    var icwStatus;
    var bmiStatus;
    var mineralStatus;
    var smmStatus;
    var bfmStatus;
    var bpStatus;
    var bcmStatus;
    var waistHipStatus;
    var pbfStatus;
    var waistHeightStatus;
    var vfStatus;
    var bmrStatus;
    var bomcStatus;
    var cholesterolStatus;

    calculateFullBodyProteinStatus(FullBodyProtein) {
      if (double.parse(FullBodyProtein) < proteinl) {
        return 'Low';
      } else if (double.parse(FullBodyProtein) >= proteinl) {
        return 'Normal';
      }
    }

    calculateFullBodyECWStatus(FullBodyECW) {
      if (double.parse(FullBodyECW) < ecll) {
        return 'Low';
      } else if (double.parse(FullBodyECW) >= ecll && double.parse(FullBodyECW) <= eclh) {
        return 'Normal';
      } else if (double.parse(FullBodyECW) > eclh) {
        return 'High';
      }
    }

    calculateFullBodyICWStatus(FullBodyICW) {
      if (double.parse(FullBodyICW) < icll) {
        return 'Low';
      } else if (double.parse(FullBodyICW) >= icll && double.parse(FullBodyICW) <= iclh) {
        return 'Normal';
      } else if (double.parse(FullBodyICW) > iclh) {
        return 'High';
      }
    }

    calculateFullBodyMineralStatus(FullBodyMineral) {
      if (double.parse(FullBodyMineral) < double.parse(lowMineral)) {
        return 'Low';
      } else if (double.parse(FullBodyMineral) >= double.parse(lowMineral)) {
        return 'Normal';
      }
    }

    calculateFullBodySMMStatus(FullBodySMM) {
      if (double.parse(FullBodySMM) < lowSmmReference) {
        return 'Low';
      } else if (double.parse(FullBodySMM) >= lowSmmReference) {
        return 'Normal';
      }
    }

    calculateFullBodyBMCStatus(FullBodyBMC) {
      if (double.parse(FullBodyBMC) < double.parse(lowBmcReference)) {
        return 'Low';
      } else if (double.parse(FullBodyBMC) >= double.parse(lowBmcReference)) {
        return 'Normal';
      }
    }

    calculateFullBodyPBFStatus(FullBodyPBF) {
      if (double.parse(FullBodyPBF) < double.parse(lowPbfReference)) {
        return 'Low';
      } else if (double.parse(FullBodyPBF) >= double.parse(lowPbfReference) &&
          double.parse(FullBodyPBF) <= double.parse(highPbfReference)) {
        return 'Normal';
      } else if (double.parse(FullBodyPBF) > double.parse(highPbfReference)) {
        return 'High';
      }
    }

    calculateFullBodyBCMStatus(FullBodyBCM) {
      if (double.parse(FullBodyBCM) < double.parse(bcml)) {
        return 'Low';
      } else if (double.parse(FullBodyBCM) >= double.parse(bcml)) {
        return 'Normal';
      }
    }

    calculateFullBodyFATStatus(FullBodyFAT) {
      if (double.parse(FullBodyFAT) < lowFatReference) {
        return 'Low';
      } else if (double.parse(FullBodyFAT) >= lowFatReference &&
          double.parse(FullBodyFAT) <= highFatReference) {
        return 'Normal';
      } else if (double.parse(FullBodyFAT) > highFatReference) {
        return 'High';
      }
    }

    calculateFullBodyVFStatus(FullBodyVF) {
      if (FullBodyVF != "NaN") {
        if (int.tryParse(FullBodyVF) <= 100) {
          return 'Normal';
        } else if (int.tryParse(FullBodyVF) > 100) {
          return 'High';
        }
      }
    }

    calculateFullBodyBMRStatus(FullBodyBMR) {
      if (int.parse(FullBodyBMR) < 1200) {
        return 'Low';
      } else if (int.parse(FullBodyBMR) >= 1200) {
        return 'Normal';
      }
    }

    calculateFullBodyWHPRStatus(FullBodyWHPR) {
      if (double.parse(FullBodyWHPR) < 0.80) {
        return 'Low';
      } else if (double.parse(FullBodyWHPR) >= 0.80 && double.parse(FullBodyWHPR) <= 0.90) {
        return 'Normal';
      }
      if (double.parse(FullBodyWHPR) > 0.90) {
        return 'High';
      }
    }

    calculateFullBodyWHTRStatus(FullBodyWHTR) {
      if (double.parse(FullBodyWHTR) < double.parse(waisttoheightratiolow)) {
        return 'Low';
      } else if (double.parse(FullBodyWHTR) >= double.parse(waisttoheightratiolow) &&
          double.parse(FullBodyWHTR) <= double.parse(waisttoheightratiohigh)) {
        return 'Normal';
      }
      if (double.parse(FullBodyWHTR) > double.parse(waisttoheightratiohigh)) {
        return 'High';
      }
    }
    calculateFullBodyBPStatus(FullBodySystolic) {
      if (double.parse(FullBodySystolic) >= 140) {
        return "High";
      } else {
        return "Normal";
      }
    }
    calculateFullBodyBMIStatus(dynamic bmi) {
      bmi=double.parse(bmi);
      if (bmi == null) {
        return AppTexts.notAvailable;
      }
      if (bmi > 30) {
        return AppTexts.obeseBMI;
      }
      if (bmi > 25) {
        return AppTexts.ovwBMI;
      }
      if (bmi < 18) {
        return AppTexts.undwBMI;
      }
      return AppTexts.normalBMI;
    }
    calculateCholesterolStatus(FullBodyCholesterol) {
      if (FullBodyCholesterol < 160.0) {
        return 'Low';
      } else if (FullBodyCholesterol >= 161.0 && FullBodyCholesterol <= 239.0) {
        return 'Normal';
      }
      if (FullBodyCholesterol > 239.0) {
        return 'High';
      }
    }

    for (var i = 0; i < userVitals.length; i++) {
      if (userVitals[i]['protien'] != null && userVitals[i]['protien'] != "NaN") {
        userVitals[i]['protien'] = userVitals[i]['protien'].toStringAsFixed(2);
        proteinStatus = calculateFullBodyProteinStatus(userVitals[i]['protien']);
      }

      if (userVitals[i]['intra_cellular_water'] != null &&
          userVitals[i]['intra_cellular_water'] != "NaN") {
        userVitals[i]['intra_cellular_water'] =
            userVitals[i]['intra_cellular_water'].toStringAsFixed(2);
        icwStatus = calculateFullBodyICWStatus(userVitals[i]['intra_cellular_water']);
      }

      if (userVitals[i]['extra_cellular_water'] != null &&
          userVitals[i]['extra_cellular_water'] != "NaN") {
        userVitals[i]['extra_cellular_water'] =
            userVitals[i]['extra_cellular_water'].toStringAsFixed(2);
        ecwStatus = calculateFullBodyECWStatus(userVitals[i]['extra_cellular_water']);
      }

      if (userVitals[i]['mineral'] != null && userVitals[i]['mineral'] != "NaN") {
        userVitals[i]['mineral'] = userVitals[i]['mineral'].toStringAsFixed(2);
        mineralStatus = calculateFullBodyMineralStatus(userVitals[i]['mineral']);
      }

      if (userVitals[i]['skeletal_muscle_mass'] != null &&
          userVitals[i]['skeletal_muscle_mass'] != "NaN") {
        userVitals[i]['skeletal_muscle_mass'] =
            userVitals[i]['skeletal_muscle_mass'].toStringAsFixed(2);
        smmStatus = calculateFullBodySMMStatus(userVitals[i]['skeletal_muscle_mass']);
      }

      if (userVitals[i]['body_fat_mass'] != null && userVitals[i]['body_fat_mass'] != "NaN") {
        userVitals[i]['body_fat_mass'] = userVitals[i]['body_fat_mass'].toStringAsFixed(2);
        bfmStatus = calculateFullBodyFATStatus(userVitals[i]['body_fat_mass']);
      }

      if (userVitals[i]['body_cell_mass'] != null && userVitals[i]['body_cell_mass'] != "NaN") {
        userVitals[i]['body_cell_mass'] = userVitals[i]['body_cell_mass'].toStringAsFixed(2);
        bcmStatus = calculateFullBodyBCMStatus(userVitals[i]['body_cell_mass']);
      }

      if (userVitals[i]['waist_hip_ratio'] != null && userVitals[i]['waist_hip_ratio'] != "NaN") {
        userVitals[i]['waist_hip_ratio'] = userVitals[i]['waist_hip_ratio'].toStringAsFixed(2);
        waistHipStatus = calculateFullBodyWHPRStatus(userVitals[i]['waist_hip_ratio']);
      }

      if (userVitals[i]['percent_body_fat'] != null && userVitals[i]['percent_body_fat'] != "NaN") {
        userVitals[i]['percent_body_fat'] = userVitals[i]['percent_body_fat'].toStringAsFixed(2);
        pbfStatus = calculateFullBodyPBFStatus(userVitals[i]['percent_body_fat']);
      }

      if (userVitals[i]['waist_height_ratio'] != null &&
          userVitals[i]['waist_height_ratio'] != "NaN") {
        userVitals[i]['waist_height_ratio'] =
            userVitals[i]['waist_height_ratio'].toStringAsFixed(2);
        waistHeightStatus = calculateFullBodyWHTRStatus(userVitals[i]['waist_height_ratio']);
      }

      if (userVitals[i]['visceral_fat'] != null && userVitals[i]['visceral_fat'] != "NaN") {
        userVitals[i]['visceral_fat'] = stringify(userVitals[i]['visceral_fat']);
        vfStatus = calculateFullBodyVFStatus(userVitals[i]['visceral_fat']);
      }

      if (userVitals[i]['basal_metabolic_rate'] != null &&
          userVitals[i]['basal_metabolic_rate'] != "NaN") {
        userVitals[i]['basal_metabolic_rate'] = stringify(userVitals[i]['basal_metabolic_rate']);
        bmrStatus = calculateFullBodyBMRStatus(userVitals[i]['basal_metabolic_rate']);
      }

      if (userVitals[i]['bone_mineral_content'] != null &&
          userVitals[i]['bone_mineral_content'] != "NaN") {
        userVitals[i]['bone_mineral_content'] =
            userVitals[i]['bone_mineral_content'].toStringAsFixed(2);
        bomcStatus = calculateFullBodyBMCStatus(userVitals[i]['bone_mineral_content']);
      }
      if (userVitals[i]['Cholesterol'] != null && userVitals[i]['Cholesterol'] != "NaN") {
        cholesterolStatus = calculateCholesterolStatus(userVitals[i]['Cholesterol']);
      }
      if (userVitals[i]['systolic'] != null && userVitals[i]['diastolic'] != null) {
        userVitals[i]['bp'] =
        '${stringify(userVitals[i]['systolic'])}/${stringify(userVitals[i]['diastolic'])}';
        bpStatus = calculateFullBodyBPStatus(stringify(userVitals[i]['systolic']));
      }
      if(userVitals[i]['bmi'] != null && userVitals[i]['bmi'] != "NaN"){
        userVitals[i]['bmi'] =
            userVitals[i]['bmi'].toStringAsFixed(2);
        bmiStatus = calculateFullBodyBMIStatus(userVitals[i]['bmi']);
      }
      userVitals[i]['bmi'] ??= calcBmi(
          height: userVitals[i]['heightMeters'].toString(),
          weight: userVitals[i]['weight'].toString());
      finalHeight = doubleFly(userVitals[i]['heightMeters']) ?? finalHeight;
      finalWeight = doubleFly(userVitals[i]['weightKG']) ?? finalWeight;
      if (userVitals[i]['systolic'] != null && userVitals[i]['diastolic'] != null) {
        userVitals[i]['bp'] =
            '${stringify(userVitals[i]['systolic'])}/${stringify(userVitals[i]['diastolic'])}';
      }
      userVitals[i]['weightKGClass'] = userVitals[i]['bmiClass'];
      userVitals[i]['ECGBpmClass'] = userVitals[i]['leadTwoStatus'];
      userVitals[i]['fatRatioClass'] = userVitals[i]['fatClass'];
      userVitals[i]['pulseBpmClass'] = userVitals[i]['pulseClass'];
    }
    prefs.setDouble(SPKeys.weight, finalWeight);
    prefs.setDouble(SPKeys.height, finalHeight);

    //Check which vital
    vitalsOnHome.forEach((f) {
      allScores[f] = [];
      allScores[f + 'Class'] = [];
      for (var i = 0; i < userVitals.length; i++) {
        if (userVitals[i][f] != '' && userVitals[i][f] != null && userVitals[i][f] != 'N/A') {
          /// round off to nearest 2 decimal 🌊
          if (userVitals[i][f] is double) {
            if (decimalVitals.contains(f)) {
              userVitals[i][f] = (userVitals[i][f] * 100.0).toInt() / 100;
            } else {
              userVitals[i][f] = (userVitals[i][f]).toInt();
            }
          }
          Map mapToAdd = {
            'value': userVitals[i][f],
            'status': userVitals[i][f + 'Class'] == null
                ? 'Unknown'
                : camelize(userVitals[i][f + 'Class']),
            'date': userVitals[i]['dateTimeFormatted'] != null
                ? DateTime.tryParse(userVitals[i]['dateTimeFormatted'].toString())
                : getDateTimeStamp(user['accountCreated']),
            'moreData': {
              'Address': stringify(userVitals[i]['orgAddress']),
              'City': stringify(userVitals[i]['IHLMachineLocation']),
            }
          };
          // processing specific to a vital
          if (f == 'temperature') {
            if (userVitals[i]['Roomtemperature'] != null) {
              userVitals[i]['Roomtemperature'] = doubleFly(userVitals[i]['Roomtemperature']);
              mapToAdd['moreData']['Room Temperature'] =
              '${stringify((userVitals[i]['Roomtemperature'] * 9 / 5) + 32)} ${vitalsUI['temperature']['unit']}';
            }
            mapToAdd['value'] =
                (((userVitals[i][f] * 900 / 5).toInt()) / 100 + 32).toStringAsFixed(2);
          }
          if (f == 'bp') {
            mapToAdd['moreData']['Systolic'] = userVitals[i]['systolic'].toString();
            mapToAdd['moreData']['Diastolic'] = userVitals[i]['diastolic'].toString();
            mapToAdd['status'] = bpStatus.toString();
          }
          if(f=='bmi'){
            mapToAdd['bmi'] = userVitals[i]['bmi'].toString();
            mapToAdd['status'] = bmiStatus.toString();
          }
          if (f == 'Cholesterol') {
            mapToAdd['Cholesterol'] = userVitals[i]['Cholesterol'].toString();
            mapToAdd['status'] = cholesterolStatus.toString();
          }
          if (f == 'protien') {
            mapToAdd['protien'] = userVitals[i]['protien'].toString();
            mapToAdd['status'] = proteinStatus.toString();
          }

          if (f == 'intra_cellular_water') {
            mapToAdd['intra_cellular_water'] = userVitals[i]['intra_cellular_water'].toString();
            mapToAdd['status'] = icwStatus.toString();
          }

          if (f == 'extra_cellular_water') {
            mapToAdd['extra_cellular_water'] = userVitals[i]['extra_cellular_water'].toString();
            mapToAdd['status'] = ecwStatus.toString();
          }

          if (f == 'mineral') {
            mapToAdd['mineral'] = userVitals[i]['mineral'].toString();
            mapToAdd['status'] = mineralStatus.toString();
          }

          if (f == 'skeletal_muscle_mass') {
            mapToAdd['skeletal_muscle_mass'] = userVitals[i]['skeletal_muscle_mass'].toString();
            mapToAdd['status'] = smmStatus.toString();
          }

          if (f == 'body_fat_mass') {
            mapToAdd['body_fat_mass'] = userVitals[i]['body_fat_mass'].toString();
            mapToAdd['status'] = bfmStatus.toString();
          }

          if (f == 'body_cell_mass') {
            mapToAdd['body_cell_mass'] = userVitals[i]['body_cell_mass'].toString();
            mapToAdd['status'] = bcmStatus.toString();
          }

          if (f == 'waist_hip_ratio') {
            mapToAdd['waist_hip_ratio'] = userVitals[i]['waist_hip_ratio'].toString();
            mapToAdd['status'] = waistHipStatus.toString();
          }

          if (f == 'percent_body_fat') {
            mapToAdd['percent_body_fat'] = userVitals[i]['percent_body_fat'].toString();
            mapToAdd['status'] = pbfStatus.toString();
          }

          if (f == 'waist_height_ratio') {
            mapToAdd['waist_height_ratio'] = userVitals[i]['waist_height_ratio'].toString();
            mapToAdd['status'] = waistHeightStatus.toString();
          }

          if (f == 'visceral_fat') {
            mapToAdd['visceral_fat'] = userVitals[i]['visceral_fat'].toString();
            mapToAdd['status'] = vfStatus.toString();
          }

          if (f == 'basal_metabolic_rate') {
            mapToAdd['basal_metabolic_rate'] = userVitals[i]['basal_metabolic_rate'].toString();
            mapToAdd['status'] = bmrStatus.toString();
          }

          if (f == 'bone_mineral_content') {
            mapToAdd['bone_mineral_content'] = userVitals[i]['bone_mineral_content'].toString();
            mapToAdd['status'] = bomcStatus.toString();
          }

          if (f == 'ECGBpm') {
            mapToAdd['graphECG'] = ECGCalc(
              isLeadThree: userVitals[i]['LeadMode'] == 3,
              data1: userVitals[i]['ECGData'],
              data2: userVitals[i]['ECGData2'],
              data3: userVitals[i]['ECGData3'],
            );

            mapToAdd['moreData']['Lead One Status'] = stringify(userVitals[i]['leadOneStatus']);
            mapToAdd['moreData']['Lead Two Status'] = stringify(userVitals[i]['leadTwoStatus']);
            mapToAdd['moreData']['Lead Three Status'] = stringify(userVitals[i]['leadThreeStatus']);
          }
          allScores[f].add(mapToAdd);
          if (!vitalsToShow.contains(f)) {
            vitalsToShow.add(f);
          }
        }
      }
    });
    vitalsToShow.toSet();
    vitalsToShow = vitalsOnHome;
    print(allScores);

    // loading = false;
    // if (this.mounted) {
    //   this.setState(() {});
    // }
    await datumCollect();
    update(["vitalscard"]);
  }

  String stringify(dynamic prop) {
    if (prop == null || prop == '' || prop == ' ' || prop == 'NA' || prop == 'NaN') {
      return AppTexts.notAvailable;
    }
    try {
      if (prop is double) {
        double doub = prop;
        prop = doub.round();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    String stringVal = prop.toString();
    stringVal = stringVal.trim().isEmpty ? AppTexts.notAvailable : stringVal;
    return stringVal;
  }

  /// calculate bmi🎇🎇
  int calcBmi({height, weight}) {
    double parsedH;
    double parsedW;
    if (height == null || weight == null) {
      return null;
    }

    parsedH = double.tryParse(height);
    gHeight = parsedH;
    parsedW = double.tryParse(weight);
    if (parsedH != null && parsedW != null) {
      int bmi = parsedW ~/ (parsedH * parsedH);
      return bmi;
    }
    return null;
  }

  /// returns BMI Class for a BMI 🌈
  String bmiClassCalc(int bmi) {
    if (bmi == null) {
      return AppTexts.notAvailable;
    }
    if (bmi > 30) {
      return AppTexts.obeseBMI;
    }
    if (bmi > 25) {
      return AppTexts.ovwBMI;
    }
    if (bmi < 18) {
      return AppTexts.undwBMI;
    }
    return AppTexts.normalBMI;
  }

  DateTime getDateTimeStamp(String d) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(int.tryParse(d
          .substring(0, d.indexOf('+'))
          .replaceAll('Date', '')
          .replaceAll('/', '')
          .replaceAll('(', '')
          .replaceAll(')', '')));
    } catch (e) {
      return DateTime.now();
    }
  }

  double doubleFly(k) {
    if (k is num) {
      return k * 1.0;
    }
    if (k is String) {
      return double.tryParse(k);
    }
    return null;
  }

  datumCollect() async {
    print(vitalsToShow.runtimeType);
    datum = allScores[vitalsToShow[0]];
    bmi = allScores[vitalsToShow[0]];

    bp = allScores["bp"];
    vsFat = allScores["visceral_fat"];
    CholestrolUpdated = allScores["Cholesterol"];
    print(datum);
  }

  Future retrieveMedicalData() async {
    retrivedMedicalData = await CardioController().retrieve_medical_data(userId: userDataCardio.id);
    log(retrivedMedicalData.toJson().toString());

    update(["vitalscard"]);
  }

  Future storeMEdicalData({Map datatoChange}) async {
    updatingVitalValue = true;
    update(["vitalscard", "status"]);
    String dateTime = await genericDateTime(DateTime.now());
    medicalDataValuesToStore = StoreMedicalData(
      cholesterol: retrivedMedicalData.cholesterol,
      diastolicBloodPressure: retrivedMedicalData.diastolicBloodPressure,
      systolicBloodPressure: retrivedMedicalData.systolicBloodPressure,
      hdl: retrivedMedicalData.hdl,
      ldl: retrivedMedicalData.ldl,
      gender: retrivedMedicalData.gender,
      foodPreference: retrivedMedicalData.foodPreference,
      weight: retrivedMedicalData.weight,
      hasFamilyHistoryDiabetes: retrivedMedicalData.hasFamilyHistoryDiabetes,
      hasHypertensionTreatment: retrivedMedicalData.hasFamilyHistoryHypertension,
      onAspirinTheraphy: retrivedMedicalData.onAspirinTheraphy,
      isSmoker: retrivedMedicalData.isSmoker,
      region: retrivedMedicalData.region,
      onStatin: retrivedMedicalData.onStatin,
      ihlUserId: userDataCardio.id,
      storeLogTime: dateTime,
    );
    if (datatoChange["dataName"] == "BMI") {
      medicalDataValuesToStore.weight = datatoChange["weight"];
    } else if (datatoChange["dataName"] == "BP") {
      medicalDataValuesToStore.systolicBloodPressure = datatoChange["systolic"];
      medicalDataValuesToStore.diastolicBloodPressure = datatoChange["diastolic"];
    } else if (datatoChange["dataName"] == "Cholesterol") {
      medicalDataValuesToStore.ldl = datatoChange["ldl"];
      medicalDataValuesToStore.hdl = datatoChange["hdl"];
      medicalDataValuesToStore.cholesterol = datatoChange["cholesterol"];
    }
    log(medicalDataValuesToStore.toJson().toString());
    // Get.showSnackbar(
    //   GetSnackBar(
    //     title: "Status",
    //     message: 'Updating',
    //     icon: const Icon(Icons.update),
    //     backgroundColor: AppColors.primaryColor,
    //     duration: const Duration(seconds: 3),
    //   ),
    // );
    var res =
    await CardioController().storing_medical_data(storeMedicalData: medicalDataValuesToStore);
    await retrieveMedicalData();
    await updateGetDataDetails();
    snakBarShow(data: res);
    updatebp = true;
  }

  genericDateTime(DateTime dateTime) {
    String str = dateTime.toString();
    var str1 = str.substring(0, str.indexOf(' '));
    var str2 = str.substring(str1.length + 1, str1.length + 6);
    // return DateTime.parse('$str1 00:00:00');
    var ss = str1 + " " + str2;
    // return DateTime.parse('$str1 $str2'+':00');
    return '$str1 $str2' + ':00';
  }

  snakBarShow({Map data}) async {
    if (data["status"] == "success") {
      Get.showSnackbar(
        GetSnackBar(
          title: "Status",
          message: 'Successfully Updated',
          icon: const Icon(Icons.done),
          backgroundColor: AppColors.primaryColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (data['response'] == 'exception') {
      Get.showSnackbar(
        GetSnackBar(
          title: "Status",
          message: 'Failed to Calculate try Again',
          icon: const Icon(Icons.highlight_off_outlined),
          backgroundColor: AppColors.failure,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      Get.showSnackbar(
        GetSnackBar(
          title: "Status",
          message: 'Failed to Store try Again',
          icon: const Icon(Icons.highlight_off_outlined),
          backgroundColor: AppColors.failure,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
