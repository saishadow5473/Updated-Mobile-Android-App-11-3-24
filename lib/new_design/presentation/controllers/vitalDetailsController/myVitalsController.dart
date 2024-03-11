import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../../constants/app_texts.dart';
import '../../../../constants/api.dart';
import '../../../../constants/spKeys.dart';
import '../../../../constants/vitalUI.dart';
import '../../../../models/ecg_calculator.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../../data/model/loginModel/userDataModel.dart';
import '../../../data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../pages/profile/updatePhoto.dart';
import '../../pages/spalshScreen/splashScreen.dart';
import '../../../../utils/SpUtil.dart';
import '../../../../views/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../../../utils/imageutils.dart';
import '../../../../views/vital_screen.dart';
import '../../../data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';

class MyVitalsController extends GetxController {
  @override
  void onInit() {
    //getUserDetails();
    //  getVitalsCheckinData();
    print('My Vital Controller Init');
    // TODO: implement onInit
    super.onInit();
  }

  UserData userData = UserData();
  LastCheckin vitalData;
  getUserDetails() async {
    try {
      userData = await MyvitalsApi().vitalDatas({});
      vitalData = userData.lastCheckin;
    } catch (e) {
      print(e);
    }

    // return userData;
    update();
  }

  Future getVitalsCheckinData(userId) async {
    bool loading = true;
    List vitalsToShow = [];
    bool isJointAccount = true;

    String name = 'you';
    Map allScores = {};
    var data;
    bool isVerified = true;

    /// handle null and empty strings⚡
    ///
    String stringify(dynamic prop) {
      if (prop == null || prop == '' || prop == ' ' || prop == 'NA') {
        return AppTexts.notAvailable;
      }
      try {
        if (prop is double) {
          double doub = prop;
          prop = doub.round();
        }
      } catch (e) {
        debugPrint('$e');
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
      if (bmi >= 23) {
        return "High";
      }

      if (bmi >= 22.99 && bmi <= 18.5) {
        return AppTexts.normalBMI;
      }
      if (bmi < 18.5) {
        return "Low";
      }
    }

    DateTime getDateTimeStamp(String d) {
      print(d);
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

    /// looooooooooooooong code processes JSON response 🌠
    Future getData() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Object raw = prefs.get(SPKeys.userData);
      if (raw == '' || raw == null) {
        raw = '{}';
      }
      data = jsonDecode(raw);

      Map user = data['User'];
      // var userId = data['User']['id'];
      user ??= {};
      Image photo = maleAvatar;
      if (data['User']['hasPhoto'] == true) {
        photo = imageFromBase64String(data['User']['photo']);
        SpUtil.putString(LSKeys.imageMemory, data['User']['photo']);
        PhotoChangeNotifier.photo.value = data['User']['photo'];
        PhotoChangeNotifier.photo.notifyListeners();
      } else {
        if (data['User']['gender'] == 'm') {
          PhotoChangeNotifier.photo.value = AvatarImage.maleAva;
        } else if (data['User']['gender'] == 'f') {
          PhotoChangeNotifier.photo.value = AvatarImage.femaleAva;
        } else {
          PhotoChangeNotifier.photo.value = AvatarImage.defaultAva;
        }
      }
      try {
        await SplashScreenApiCalls()
            .checkinData(ihlUID: userId, ihlUserToken: API.headerr['Token']);
      } catch (e) {
        print("Token is Empty");
      }
      var userVitalst = prefs.getString(SPKeys.vitalsData).runtimeType == String
          ? jsonDecode(prefs.getString(SPKeys.vitalsData))
          : prefs.getString(SPKeys.vitalsData);

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
          // if (this.mounted) {
          //   if (isJointAccount) {
          //     isVerified = true;
          //     loading = true;
          //   }
          //   // setState(() {});
          // } else {
          //   isVerified = false;
          //   loading = false;
          //   return;
          // }
        }
        userVitalst = '[{}]';
      }
      List userVitals = userVitalst.runtimeType == String ? jsonDecode(userVitalst) : userVitalst;
      //get inputted height weight if values are not available
      try {
        if (userVitals[0]['weightKG'] == null) {
          userVitals[0]['weightKG'] = user['userInputWeightInKG'];
        }
        if (userVitals[0]['heightMeters'] == null) {
          userVitals[0]['heightMeters'] = user['heightMeters'];
        }
        //Calculate bmi
        print("${userVitals[0]['bmi']}here it is ....");
        if (userVitals[0]['bmi'] == null) {
          userVitals[0]['bmi'] = calcBmi(
              height: userVitals[0]['heightMeters'].toString(),
              weight: userVitals[0]['weightKG'].toString());
          gHeight = userVitals[0]['heightMeters'].toString();
          gWeight = userVitals[0]['weightKG'].toString();
          gBmi = userVitals[0]['bmi'];
          userVitals[0]['bmiClass'] = bmiClassCalc(userVitals[0]['bmi']);
        }
      } catch (e) {
        int bmi = calcBmi(
            height: user['heightMeters'].toString(),
            weight: user['userInputWeightInKG'].toString());
        gBmi = bmi;
        localSotrage.write("createdDate", user['accountCreated']);
        try {
          userVitals[0]['weightKG'] = user['userInputWeightInKG'];
          userVitals[0]['heightMeters'] = user['heightMeters'];
          userVitals[0]['bmi'] = calcBmi(
              height: userVitals[0]['heightMeters'].toString(),
              weight: userVitals[0]['weightKG'].toString());
          gHeight = userVitals[0]['heightMeters'].toString();
          gWeight = userVitals[0]['weightKG'].toString();

          userVitals[0]['bmiClass'] = bmiClassCalc(userVitals[0]['bmi']);
        } catch (e) {
          debugPrint(e);
        }
      }
      List latestWeight = [];

      if (userVitals != null) {
        for (int i = 0; i < userVitals.length; i++) {
          if (userVitals[i]["weightKG"] != null) {
            latestWeight.add(userVitals[i]["weightKG"]);
          }
        }
      }

      allScores = {};
      //prepare data
      double finalWeight = 0;
      double finalHeight = 0;
      String bcml = "20.00";
      String pulseLowLimit = "60.00";
      String pulseHighLimit = "99.00";
      String spo2Limit = "95.00";
      String tempLowLimit = "97.00";
      String tempHighLimt = "99.50";
      String bcmh = "25.00";
      String lowMineral = "2.00";
      String highMineral = "3.00";

      var heightinCMS = userVitals[0]['heightMeters'] * 100 ?? 15 * 100;
      String weight = latestWeight.last.runtimeType == String
          ? latestWeight.last
          : (latestWeight.last).toStringAsFixed(2);
      // String weight =
      //     userVitals[0]['weightKG'].toString() == "" ? '0' : userVitals[0]['weightKG'].toString();

      String gender = user['gender'].toString();
      var lowSmmReference,
          lowFatReference,
          acceptableFatReference,
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
          highPbfReference,
          accepatablePbfReference;

      if (gender != 'm') {
        lowPbfReference = "18.00";
        accepatablePbfReference = "28.00";
        highPbfReference = "32.00";
        List<List<int>> femaleHeightWeight = [
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
        int j = 0;
        while (femaleHeightWeight[j][0] <= heightinCMS) {
          j++;
          if (j == 13) {
            break;
          }
        }
        int wtl, wth;
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
        acceptableFatReference = (0.28 * double.tryParse(weight));
        highFatReference = (0.32 * double.tryParse(weight));
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
        accepatablePbfReference = "20.00";
        highPbfReference = "27.00";
        List<List<int>> maleHeightWeight = [
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
        int k = 0;
        while (maleHeightWeight[k][0] <= heightinCMS) {
          k++;
          if (k == 14) {
            break;
          }
        }
        int wtl, wth;
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
        highFatReference = (0.27 * double.parse(weight ?? '0'));
        acceptableFatReference = (0.20 * double.parse(weight ?? '0'));
        lowBmcReference = "1.700";
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
      String proteinStatus;
      String ecwStatus;
      String icwStatus;
      String bmiStatus;
      String mineralStatus;
      String smmStatus;
      String bfmStatus;
      String bcmStatus;
      String pulseStatus;
      String tempStatus;
      String spo2Status;
      String waistHipStatus;
      String pbfStatus;
      String waistHeightStatus;
      String vfStatus;
      String bmrStatus;
      String bomcStatus;
      String bpStatus;
      calculateFullBodyBMIStatus(dynamic bmi) {
        bmi = double.parse(bmi);
        if (bmi == null) {
          return AppTexts.notAvailable;
        }
        if (bmi >= 23) {
          return "High";
        }

        if (bmi <= 22.99 && bmi >= 18.5) {
          return AppTexts.normalBMI;
        }
        if (bmi < 18.5) {
          return "Low";
        }
      }

      calculateFullBodyProteinStatus(FullBodyProtein) {
        gproteinl = double.parse(proteinl.toStringAsFixed(2));
        gproteinh = double.parse(proteinh.toStringAsFixed(2));
        if (double.parse(FullBodyProtein) < proteinl) {
          return 'Low';
        } else if (double.parse(FullBodyProtein) >= proteinl &&
            double.parse(FullBodyProtein) <= proteinh) {
          return 'Normal';
        } else if (double.parse(FullBodyProtein) > proteinh) {
          return "High";
        } else {
          return "N/A";
        }
      }

      calculateFullBodyECWStatus(FullBodyECW) {
        gecll = double.parse(ecll.toStringAsFixed(2));

        geclh = double.parse(eclh.toStringAsFixed(2));
        if (double.parse(FullBodyECW) < ecll) {
          return 'Low';
        } else if (double.parse(FullBodyECW) >= ecll && double.parse(FullBodyECW) <= eclh) {
          return 'Normal';
        } else if (double.parse(FullBodyECW) > eclh) {
          return 'High';
        }
      }

      calculateFullBodyICWStatus(FullBodyICW) {
        gicll = double.parse(icll.toStringAsFixed(2));
        giclh = double.parse(iclh.toStringAsFixed(2));
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
        glowSmmReference = double.parse(lowSmmReference.toStringAsFixed(2));

        if (double.parse(FullBodySMM) < lowSmmReference) {
          return 'Low';
        } else if (double.parse(FullBodySMM) >= lowSmmReference) {
          return 'Normal';
        }
      }

      calculateFullBodyBMCStatus(FullBodyBMC) {
        glowBmcReference = double.parse(lowBmcReference);
        if (double.parse(FullBodyBMC) < double.parse(lowBmcReference)) {
          return 'Low';
        } else if (double.parse(FullBodyBMC) >= double.parse(lowBmcReference)) {
          return 'Normal';
        }
      }

      calculateFullBodyPBFStatus(FullBodyPBF) {
        glowPbfReference = double.parse(lowPbfReference);
        gacceptablePbfReference = double.parse(accepatablePbfReference);
        ghighPbfReference = double.parse(highPbfReference);
        if (double.parse(FullBodyPBF) < glowPbfReference) {
          return 'Low';
        } else if (double.parse(FullBodyPBF) >= glowPbfReference &&
            double.parse(FullBodyPBF) <= gacceptablePbfReference) {
          return 'Normal';
        } else if (double.parse(FullBodyPBF) > gacceptablePbfReference &&
            double.parse(FullBodyPBF) <= ghighPbfReference) {
          return 'Acceptable';
        } else if (double.parse(FullBodyPBF) > ghighPbfReference) {
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

      calculatePulseStatus(FullBodyPulse) {
        if (double.parse(FullBodyPulse) < double.parse(pulseLowLimit)) {
          return 'Low';
        } else if (double.parse(FullBodyPulse) >= double.parse(pulseHighLimit)) {
          return 'High';
        } else {
          return 'Normal';
        }
      }

      calculateFullBodySpo2Status(FullBodySpo2) {
        if (double.parse(FullBodySpo2) < double.parse(spo2Limit)) {
          return "Low";
        } else {
          return "Normal";
        }
      }

      calculateFullBodyFATStatus(FullBodyFAT) {
        glowFatReference = double.parse(lowFatReference.toStringAsFixed(2));
        ghighFatReference = double.parse(highFatReference.toStringAsFixed(2));
        gacceptableFatReference = double.parse(acceptableFatReference.toStringAsFixed(2));
        if (double.parse(FullBodyFAT) < lowFatReference) {
          return 'Low';
        } else if (double.parse(FullBodyFAT) >= lowFatReference &&
            double.parse(FullBodyFAT) <= acceptableFatReference) {
          return 'Normal';
        } else if (double.parse(FullBodyFAT) > highFatReference) {
          return 'High';
        } else if (double.parse(FullBodyFAT) > acceptableFatReference &&
            double.parse(FullBodyFAT) <= highFatReference) {
          return 'Acceptable';
        }
      }

      calculateFullBodyVFStatus(FullBodyVF) {
        if (FullBodyVF != "NaN") {
          // if (int.tryParse(FullBodyVF) <= 100) {
          //   return 'Normal';
          // } else if (int.tryParse(FullBodyVF) > 100) {
          //   return 'High';
          // }

          if (int.tryParse(FullBodyVF) >= 100 && int.tryParse(FullBodyVF) <= 120) {
            return 'Acceptable';
          }
          if (int.tryParse(FullBodyVF) > 120) {
            return 'High';
          } else {
            return 'Normal';
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

      calculateFullBodyTemperaturStatus(FullBodyTemp) {
        if (double.parse(FullBodyTemp) < double.parse(tempLowLimit)) {
          return "Low";
        } else if (double.parse(FullBodyTemp) > double.parse(tempHighLimt)) {
          return "High";
        } else {
          return "Normal";
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

      calculateFullBodyBPStatus(FullBodySystolic) {
        // if (double.parse(FullBodySystolic) >140) {
        //   return "High";
        // } else if (double.parse(FullBodySystolic) <= 90) {
        //   return "Low";
        // } else if ((double.parse(FullBodySystolic) > 90 && double.parse(FullBodySystolic) <= 120)) {
        //   return "Normal";
        // } else {
        //   return "Elevated";
        // }
        if (double.parse(FullBodySystolic) < 130) {
          return "Normal";
        } else if (double.parse(FullBodySystolic) > 130 && double.parse(FullBodySystolic) < 140) {
          return "Acceptable";
        } else {
          return "Clinical Screening Recommended";
        }
      }

      calculateFullBodyWHTRStatus(FullBodyWHTR) {
        gwaisttoheightratiolow = double.parse(waisttoheightratiolow);
        gwaisttoheightratiohigh = double.parse(waisttoheightratiohigh);
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

      //<======================Vitals Iteration starts here================================>
      //The below for loop will goes last index to get the lastest data of vitals;
      //if in the iteration any values comes null the loop skipped and it will holds the value where it was not null in the iteration
      for (int i = 0; i < userVitals.length; i++) {
        if (userVitals[i]['protien'] != null && userVitals[i]['protien'] != "NaN") {
          userVitals[i]['protien'] = userVitals[i]['protien'].toStringAsFixed(2);
          proteinStatus = calculateFullBodyProteinStatus(userVitals[i]['protien']);
        }
        if (userVitals[i]['bmi'] != null && userVitals[i]['bmi'] != "NaN") {
          try {
            userVitals[i]['bmi'] = userVitals[i]['bmi'].toStringAsFixed(2);
            bmiStatus = calculateFullBodyBMIStatus(userVitals[i]['bmi']);
          } catch (e) {
            print(e);
          }
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
        if (userVitals[i]['pulseBpm'] != null && userVitals[i]['pulseBpm'] != 'Nan') {
          userVitals[i]['pulseBpm'] = userVitals[i]['pulseBpm'].toStringAsFixed(0);
          pulseStatus = calculatePulseStatus(userVitals[i]['pulseBpm']);
        }
        if (userVitals[i]['waist_hip_ratio'] != null && userVitals[i]['waist_hip_ratio'] != "NaN") {
          userVitals[i]['waist_hip_ratio'] = userVitals[i]['waist_hip_ratio'].toStringAsFixed(2);
          waistHipStatus = calculateFullBodyWHPRStatus(userVitals[i]['waist_hip_ratio']);
        }
        if (userVitals[i]['spo2'] != null && userVitals[i]['spo2'] != "NaN") {
          userVitals[i]['spo2'] = userVitals[i]['spo2'].toStringAsFixed(0);
          spo2Status = calculateFullBodySpo2Status(userVitals[i]['spo2']);
        }
        if (userVitals[i]['percent_body_fat'] != null &&
            userVitals[i]['percent_body_fat'] != "NaN") {
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
        if (userVitals[i]['temperature'] != null && userVitals[i]['temperature'] != "NaN") {
          var fhrenhiet = userVitals[i]['temperature'] * (9 / 5) + 32;
          userVitals[i]['temperature'] = ((fhrenhiet * 100).truncateToDouble() / 100).toString();
          tempStatus = calculateFullBodyTemperaturStatus(userVitals[i]['temperature']);
        }
        if (userVitals[i]['bone_mineral_content'] != null &&
            userVitals[i]['bone_mineral_content'] != "NaN") {
          userVitals[i]['bone_mineral_content'] =
              userVitals[i]['bone_mineral_content'].toStringAsFixed(2);
          bomcStatus = calculateFullBodyBMCStatus(userVitals[i]['bone_mineral_content']);
        }

        userVitals[i]['bmi'] ??= calcBmi(
            height: userVitals[i]['heightMeters'].toString(),
            weight: userVitals[i]['weight'].toString());
        finalHeight = doubleFly(userVitals[i]['heightMeters']) ?? finalHeight;
        finalWeight = doubleFly(userVitals[i]['weightKG']) ?? finalWeight;
        if (userVitals[i]['systolic'] != null && userVitals[i]['diastolic'] != null) {
          userVitals[i]['bp'] =
              '${stringify(userVitals[i]['systolic'])}/${stringify(userVitals[i]['diastolic'])}';
          bpStatus = calculateFullBodyBPStatus(stringify(userVitals[i]['systolic']));
        }
        userVitals[i]['weightKGClass'] = userVitals[i]['bmiClass'];
        userVitals[i]['ECGBpmClass'] = userVitals[i]['leadTwoStatus'];
        userVitals[i]['fatRatioClass'] = userVitals[i]['fatClass'];
        userVitals[i]['pulseBpmClass'] = userVitals[i]['pulseClass'];
        print(userVitals[i]['bmi']);
        print(bmiStatus);
      }
      //<======================Vitals Iteration Ends here================================>
      //if anyhow current checkin vitals comes null enable below code to rectify the problem
      //the last index of the checkin comes null. It goes back and get vital values where it was not null in iteration.
      //Its only written for BMI

      // if (bmiStatus == null) {
      //   for (int j = userVitals.length - 1; j > 0; j--) {
      //     if (userVitals[j]['bmi'] != null && bmiStatus == null) {
      //       String v = userVitals[j]['bmi'].toString();
      //       bmiStatus = calculateFullBodyBMIStatus(v);
      //       break;
      //     }
      //   }
      // }
      // print(bmiStatus);
      prefs.setDouble(SPKeys.weight, finalWeight);
      prefs.setDouble(SPKeys.height, finalHeight);
      gHeight = finalHeight;
      gWeight = finalWeight;
      //Check which vital

      vitalsOnHome = [
        'bmi',
        'weightKG',
        // 'heightMeters',
        'temperature',
        'pulseBpm',
        'fatRatio',
        'ECGBpm',
        'bp',
        'spo2',
        'protien',
        'extra_cellular_water',
        'intra_cellular_water',
        'mineral',
        'skeletal_muscle_mass',
        'body_fat_mass',
        'body_cell_mass',
        'waist_hip_ratio',
        'percent_body_fat',
        'waist_height_ratio',
        'visceral_fat',
        'basal_metabolic_rate',
        'bone_mineral_content',
        'Cholesterol'
      ];
      await Future.forEach(vitalsOnHome, (f) {
        allScores[f] = [];
        allScores[f + 'Class'] = [];
        for (int i = 0; i < userVitals.length; i++) {
          if (userVitals[i][f] != '' && userVitals[i][f] != null && userVitals[i][f] != 'N/A') {
            bool ecgBpmVitalCheck = false;
            if (f == "ECGBpm") {
              ecgBpmVitalCheck = userVitals[i][f].toString() == "0";
            }
            if (!ecgBpmVitalCheck) {
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

              // if (f == 'temperature') {
              //   if (userVitals[i]['Roomtemperature'] != null) {
              //     userVitals[i]['Roomtemperature'] = doubleFly(userVitals[i]['Roomtemperature']);
              //     mapToAdd['moreData']['Room Temperature'] =
              //         '${stringify((userVitals[i]['Roomtemperature'] * 9 / 5) + 32)} ${vitalsUI['temperature']['unit']}';
              //   }
              //   mapToAdd['value'] =
              //       (((userVitals[i][f] * 900 / 5).toInt()) / 100 + 32).toStringAsFixed(2);
              // }
              if (f == 'bmi') {
                mapToAdd['bmi'] = userVitals[i]['bmi'].toString();
                mapToAdd['status'] = bmiStatus.toString();
              }
              if (f == 'weightKG') {
                mapToAdd['weightKG'] = userVitals[i]['weightKG'].toString();
                mapToAdd['status'] = bmiStatus.toString();
              }
              if (f == 'bp') {
                mapToAdd['moreData']['Systolic'] = userVitals[i]['systolic'].toString();
                mapToAdd['moreData']['Diastolic'] = userVitals[i]['diastolic'].toString();
                mapToAdd['status'] = bpStatus.toString();
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
              if (f == 'pulse') {
                mapToAdd['pulse'] = userVitals[i]['pulse'].toString();
                mapToAdd['status'] = pulseStatus.toString();
              }
              if (f == 'spo2') {
                mapToAdd['spo2'] = userVitals[i]['spo2'].toString();
                mapToAdd['status'] = spo2Status.toString();
              }
              if (f == 'waist_hip_ratio') {
                mapToAdd['waist_hip_ratio'] = userVitals[i]['waist_hip_ratio'].toString();
                mapToAdd['status'] = waistHipStatus.toString();
              }
              if (f == "temperature") {
                mapToAdd['temperature'] = userVitals[i]['temperature'].toString();
                mapToAdd['status'] = tempStatus.toString();
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
              if (f == 'pulseBpm') {
                mapToAdd['pulseBpm'] = userVitals[i]['pulseBpm'].toString();
                mapToAdd['status'] = pulseStatus.toString();
              }

              if (f == 'ECGBpm') {
                if (userVitals[i]["ECGBpm"].toString() != "0") {
                  mapToAdd['graphECG'] = ECGCalc(
                    isLeadThree: userVitals[i]['LeadMode'] == 3,
                    data1: userVitals[i]['ECGData'],
                    data2: userVitals[i]['ECGData2'],
                    data3: userVitals[i]['ECGData3'],
                  );

                  mapToAdd['moreData']['Lead One Status'] =
                      stringify(userVitals[i]['leadOneStatus']);
                  mapToAdd['moreData']['Lead Two Status'] =
                      stringify(userVitals[i]['leadTwoStatus']);
                  mapToAdd['moreData']['Lead Three Status'] =
                      stringify(userVitals[i]['leadThreeStatus']);
                }
              }
              allScores[f].add(mapToAdd);
              if (!vitalsToShow.contains(f)) {
                vitalsToShow.add(f);
              }
            }
          }
        }
      });
      vitalsToShow.toSet();
      vitalsToShow = vitalsOnHome;
      if (allScores == null || allScores == []) {
        allScores = {"bmi": [], "weightKG": []};
      }
      localSotrage.write(LSKeys.allScors, allScores);
      // print(allScores);
      // print(allScores.runtimeType);
      // var all = jsonEncode(allScores.toString());
      // print(all);
      // SpUtil.putString(LSKeys.allScors, all);

      ///for removing the card from the dashboard that have N/A value
      if (kDebugMode) {
        print('length -> ${vitalsToShow.length}  ${vitalsOnHome.length}');
      }
      // for(int i = 0 ;i<vitalsOnHome.length;i++){
      //   if(allScores[vitalsToShow[i]].isEmpty){
      //     vitalsToShow.removeAt(i);
      //   }
      // }
      vitalsToShow.removeWhere((element) => allScores[element].isEmpty);
      print('after length -> ${vitalsToShow.length}  ${vitalsOnHome.length}');

      loading = false;
      // if (this.mounted) {
      //   this.setState(() {});
      // }
    }

    bool s;
    String score = '';
    await getData();
    update(["vitals Update"]);
    // Future<void> getVitalScoreData() async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   var data = prefs.get(SPKeys.userData);
    //   data = data == null || data == '' ? '{"User":{}}' : data;
    //   Map res = jsonDecode(data);
    //   res['User']['user_score'] ??= {};
    //   res['User']['user_score']['T'] ??= 'N/A';
    //   score = res['User']['user_score']['T'].toString();
    //   s = prefs.getBool('allAns');
    // }
  }

  double doubleFly(k) {
    try {
      if (k is num) {
        return k * 1.0;
      }
      if (k is String) {
        return double.tryParse(k);
      }
      return null;
    } catch (e) {
      print(e);
    }
  }
// Future retriveData()async{
//   final vitalDatas =
//       await SplashScreenApiCalls().checkinData(ihlUID: localSotrage.read(LSKeys.ihlUserId), ihlUserToken: localSotrage.read(key));
//   prefs1.setString(SPKeys.vitalsData, vitalDatas);
//   await MyvitalsApi().vitalDatas(decodedResponse);
// }
}
