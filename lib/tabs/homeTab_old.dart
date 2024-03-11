// // ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names
//
// import 'package:ihl/models/ecg_calculator.dart';
// import 'package:ihl/utils/fitkit_util.dart';
// import 'package:ihl/views/dietDashboard/profile_screen.dart';
// import 'package:ihl/views/dietJournal/dietJournal.dart';
// import 'package:ihl/views/goal_settings/edit_goal_screen.dart';
// import 'package:ihl/widgets/dashboard/scoreMeter.dart';
// import 'package:ihl/widgets/profileScreen/photo.dart';
// import 'package:lottie/lottie.dart';
// import 'package:strings/strings.dart';
// import 'dart:convert';
// import 'package:ihl/utils/app_colors.dart';
// import 'package:ihl/painters/backgroundPanter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/material.dart';
// import 'package:ihl/constants/vitalUI.dart';
// import 'package:ihl/constants/app_texts.dart';
// import 'package:ihl/widgets/dashboard/liteVitalsCard.dart';
// import 'package:ihl/constants/spKeys.dart';
//
// // ignore: must_be_immutable
// class HomeTab extends StatefulWidget {
//   Function closeDrawer;
//   Function openDrawer;
//   Function goToProfile;
//   var userScore = '0';
//   String username;
//   HomeTab({
//     this.closeDrawer,
//     this.username,
//     this.openDrawer,
//     this.userScore,
//     this.goToProfile,
//   });
//   @override
//   _HomeTabState createState() => _HomeTabState();
// }
//
// class _HomeTabState extends State<HomeTab> {
//   bool loading = true;
//   List vitalsToShow = [];
//   String name = 'Guest User';
//   Map allScores = {};
//   String score = 'N/A';
//   var data;
//   bool isVerified = true;
//
//   /// handle null and empty strings⚡
//   String stringify(dynamic prop) {
//     if (prop == null || prop == '' || prop == ' ' || prop == 'NA') {
//       return AppTexts.notAvailable;
//     }
//     if (prop is double) {
//       double doub = prop;
//       prop = doub.round();
//     }
//     String stringVal = prop.toString();
//     stringVal = stringVal.trim().isEmpty ? AppTexts.notAvailable : stringVal;
//     return stringVal;
//   }
//
//   /// calculate bmi🎇🎇
//   int calcBmi({height, weight}) {
//     double parsedH;
//     double parsedW;
//     if (height == null || weight == null) {
//       return null;
//     }
//
//     parsedH = double.tryParse(height);
//     parsedW = double.tryParse(weight);
//     if (parsedH != null && parsedW != null) {
//       int bmi = parsedW ~/ (parsedH * parsedH);
//
//       return bmi;
//     }
//     return null;
//   }
//
//   /// returns BMI Class for a BMI 🌈
//   String bmiClassCalc(int bmi) {
//     if (bmi == null) {
//       return AppTexts.notAvailable;
//     }
//     if (bmi > 30) {
//       return AppTexts.obeseBMI;
//     }
//     if (bmi > 25) {
//       return AppTexts.ovwBMI;
//     }
//     if (bmi < 18) {
//       return AppTexts.undwBMI;
//     }
//     return AppTexts.normalBMI;
//   }
//
//   DateTime getDateTimeStamp(String d) {
//     try {
//       return DateTime.fromMillisecondsSinceEpoch(int.tryParse(d
//           .substring(0, d.indexOf('+'))
//           .replaceAll('Date', '')
//           .replaceAll('/', '')
//           .replaceAll('(', '')
//           .replaceAll(')', '')));
//     } catch (e) {
//       return DateTime.now();
//     }
//   }
//
//   /// looooooooooooooong code processes JSON response 🌠
//   getData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var raw = prefs.get(SPKeys.userData);
//     final stepResults = await FitKitHelper.getHR(days: 60);
//     print(stepResults);
//     if (raw == '' || raw == null) {
//       raw = '{}';
//     }
//     data = jsonDecode(raw);
//
//     Map user = data['User'];
//     user ??= {};
//     user['user_score'] ??= {};
//     user['user_score']['T'] ??= 'N/A';
//     score = user['user_score']['T'].toString();
//     var userVitalst = prefs.getString(SPKeys.vitalsData);
//     if (userVitalst == null || userVitalst == '' || userVitalst == '[]') {
//       if (user['userInputWeightInKG'] == null ||
//           user['userInputWeightInKG'] == '' ||
//           user['heightMeters'] == null ||
//           user['heightMeters'] == '' ||
//           ((user['email'] == null || user['email'] == '') &&
//               (user['mobileNumber'] == null || user['mobileNumber'] == ''))) {
//         isVerified = false;
//         loading = false;
//         if (this.mounted) {
//           setState(() {});
//           return;
//         }
//       }
//       userVitalst = '[{}]';
//     }
//     List userVitals = jsonDecode(userVitalst);
//     //get inputted height weight if values are not available
//
//     if (userVitals[0]['weightKG'] == null) {
//       userVitals[0]['weightKG'] = user['userInputWeightInKG'];
//     }
//     if (userVitals[0]['heightMeters'] == null) {
//       userVitals[0]['heightMeters'] = user['heightMeters'];
//     }
//     //Calculate bmi
//     if (userVitals[0]['bmi'] == null) {
//       userVitals[0]['bmi'] = calcBmi(
//           height: userVitals[0]['heightMeters'].toString(),
//           weight: userVitals[0]['weightKG'].toString());
//       userVitals[0]['bmiClass'] = bmiClassCalc(userVitals[0]['bmi']);
//     }
//     allScores = {};
//     //prepare data
//     double finalWeight = 0;
//     double finalHeight = 0;
//     var bcml = "20.00";
//     var bcmh = "25.00";
//     var lowMineral = "2.00";
//     var highMineral = "3.00";
//     var heightinCMS = userVitals[0]['heightMeters'] * 100;
//     var weight = userVitals[0]['weightKG'].toString() == ""
//         ? '0'
//         : userVitals[0]['weightKG'].toString();
//     var gender = user['gender'].toString();
//     var lowSmmReference,
//         lowFatReference,
//         highSmmReference,
//         highFatReference,
//         lowBmcReference,
//         highBmcReference,
//         icll,
//         iclh,
//         ecll,
//         eclh,
//         proteinl,
//         proteinh,
//         waisttoheightratiolow,
//         waisttoheightratiohigh,
//         lowPbfReference,
//         highPbfReference;
//
//     if (gender != 'm') {
//       lowPbfReference = "18.00";
//       highPbfReference = "28.00";
//       var femaleHeightWeight = [
//         [147, 45, 59],
//         [150, 45, 60],
//         [152, 46, 62],
//         [155, 47, 63],
//         [157, 49, 65],
//         [160, 50, 67],
//         [162, 51, 69],
//         [165, 53, 70],
//         [167, 54, 72],
//         [170, 55, 74],
//         [172, 57, 75],
//         [175, 58, 77],
//         [177, 60, 78],
//         [180, 61, 80]
//       ];
//       var j = 0;
//       while (femaleHeightWeight[j][0] <= heightinCMS) {
//         j++;
//         if (j == 13) {
//           break;
//         }
//       }
//       var wtl, wth;
//       if (j == 0) {
//         wtl = femaleHeightWeight[j][1];
//         wth = femaleHeightWeight[j][2];
//       } else {
//         wtl = femaleHeightWeight[j - 1][1];
//         wth = femaleHeightWeight[j - 1][2];
//       }
//       lowSmmReference = (0.36 * wtl);
//       highSmmReference = (0.36 * wth);
//       lowFatReference = (0.18 * double.tryParse(weight));
//       highFatReference = (0.28 * double.tryParse(weight));
//       lowBmcReference = "1.70";
//       highBmcReference = "3.00";
//       icll = (0.3 * wtl);
//       iclh = (0.3 * wth);
//       ecll = (0.2 * wtl);
//       eclh = (0.2 * wth);
//       proteinl = (0.116 * double.tryParse(weight));
//       proteinh = (0.141 * double.tryParse(weight));
//       waisttoheightratiolow = "0.35";
//       waisttoheightratiohigh = "0.53";
//     } else {
//       lowPbfReference = "10.00";
//       highPbfReference = "20.00";
//       var maleHeightWeight = [
//         [155, 55, 66],
//         [157, 56, 67],
//         [160, 57, 68],
//         [162, 58, 70],
//         [165, 59, 72],
//         [167, 60, 74],
//         [170, 61, 75],
//         [172, 62, 77],
//         [175, 63, 79],
//         [177, 64, 81],
//         [180, 65, 83],
//         [182, 66, 85],
//         [185, 68, 87],
//         [187, 69, 89],
//         [190, 71, 91]
//       ];
//       var k = 0;
//       while (maleHeightWeight[k][0] <= heightinCMS) {
//         k++;
//         if (k == 14) {
//           break;
//         }
//       }
//       var wtl, wth;
//       if (k == 0) {
//         wtl = maleHeightWeight[k][1];
//         wth = maleHeightWeight[k][2];
//       } else {
//         wtl = maleHeightWeight[k - 1][1];
//         wth = maleHeightWeight[k - 1][2];
//       }
//       lowSmmReference = (0.42 * wtl);
//       highSmmReference = (0.42 * wth);
//       lowFatReference = (0.10 * double.parse(weight ?? '0'));
//       highFatReference = (0.20 * double.parse(weight ?? '0'));
//       lowBmcReference = "2.00";
//       highBmcReference = "3.70";
//       icll = (0.3 * wtl);
//       iclh = (0.3 * wth);
//       ecll = (0.2 * wtl);
//       eclh = (0.2 * wth);
//       proteinl = (0.109 * double.parse(weight));
//       proteinh = (0.135 * double.parse(weight));
//       waisttoheightratiolow = "0.35";
//       waisttoheightratiohigh = "0.57";
//     }
//
//     var proteinStatus;
//     var ecwStatus;
//     var icwStatus;
//     var mineralStatus;
//     var smmStatus;
//     var bfmStatus;
//     var bcmStatus;
//     var waistHipStatus;
//     var pbfStatus;
//     var waistHeightStatus;
//     var vfStatus;
//     var bmrStatus;
//     var bomcStatus;
//
//     calculateFullBodyProteinStatus(FullBodyProtein) {
//       if (double.parse(FullBodyProtein) < proteinl) {
//         return 'Low';
//       } else if (double.parse(FullBodyProtein) >= proteinl) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyECWStatus(FullBodyECW) {
//       if (double.parse(FullBodyECW) < ecll) {
//         return 'Low';
//       } else if (double.parse(FullBodyECW) >= ecll &&
//           double.parse(FullBodyECW) <= eclh) {
//         return 'Normal';
//       } else if (double.parse(FullBodyECW) > eclh) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyICWStatus(FullBodyICW) {
//       if (double.parse(FullBodyICW) < icll) {
//         return 'Low';
//       } else if (double.parse(FullBodyICW) >= icll &&
//           double.parse(FullBodyICW) <= iclh) {
//         return 'Normal';
//       } else if (double.parse(FullBodyICW) > iclh) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyMineralStatus(FullBodyMineral) {
//       if (double.parse(FullBodyMineral) < double.parse(lowMineral)) {
//         return 'Low';
//       } else if (double.parse(FullBodyMineral) >= double.parse(lowMineral)) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodySMMStatus(FullBodySMM) {
//       if (double.parse(FullBodySMM) < lowSmmReference) {
//         return 'Low';
//       } else if (double.parse(FullBodySMM) >= lowSmmReference) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyBMCStatus(FullBodyBMC) {
//       if (double.parse(FullBodyBMC) < double.parse(lowBmcReference)) {
//         return 'Low';
//       } else if (double.parse(FullBodyBMC) >= double.parse(lowBmcReference)) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyPBFStatus(FullBodyPBF) {
//       if (double.parse(FullBodyPBF) < double.parse(lowPbfReference)) {
//         return 'Low';
//       } else if (double.parse(FullBodyPBF) >= double.parse(lowPbfReference) &&
//           double.parse(FullBodyPBF) <= double.parse(highPbfReference)) {
//         return 'Normal';
//       } else if (double.parse(FullBodyPBF) > double.parse(highPbfReference)) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyBCMStatus(FullBodyBCM) {
//       if (double.parse(FullBodyBCM) < double.parse(bcml)) {
//         return 'Low';
//       } else if (double.parse(FullBodyBCM) >= double.parse(bcml)) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyFATStatus(FullBodyFAT) {
//       if (double.parse(FullBodyFAT) < lowFatReference) {
//         return 'Low';
//       } else if (double.parse(FullBodyFAT) >= lowFatReference &&
//           double.parse(FullBodyFAT) <= highFatReference) {
//         return 'Normal';
//       } else if (double.parse(FullBodyFAT) > highFatReference) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyVFStatus(FullBodyVF) {
//       if (FullBodyVF != "NaN") {
//         if (int.tryParse(FullBodyVF) <= 100) {
//           return 'Normal';
//         } else if (int.tryParse(FullBodyVF) > 100) {
//           return 'High';
//         }
//       }
//     }
//
//     calculateFullBodyBMRStatus(FullBodyBMR) {
//       if (int.parse(FullBodyBMR) < 1200) {
//         return 'Low';
//       } else if (int.parse(FullBodyBMR) >= 1200) {
//         return 'Normal';
//       }
//     }
//
//     calculateFullBodyWHPRStatus(FullBodyWHPR) {
//       if (double.parse(FullBodyWHPR) < 0.80) {
//         return 'Low';
//       } else if (double.parse(FullBodyWHPR) >= 0.80 &&
//           double.parse(FullBodyWHPR) <= 0.90) {
//         return 'Normal';
//       }
//       if (double.parse(FullBodyWHPR) > 0.90) {
//         return 'High';
//       }
//     }
//
//     calculateFullBodyWHTRStatus(FullBodyWHTR) {
//       if (double.parse(FullBodyWHTR) < double.parse(waisttoheightratiolow)) {
//         return 'Low';
//       } else if (double.parse(FullBodyWHTR) >=
//               double.parse(waisttoheightratiolow) &&
//           double.parse(FullBodyWHTR) <= double.parse(waisttoheightratiohigh)) {
//         return 'Normal';
//       }
//       if (double.parse(FullBodyWHTR) > double.parse(waisttoheightratiohigh)) {
//         return 'High';
//       }
//     }
//
//     for (var i = 0; i < userVitals.length; i++) {
//       if (userVitals[i]['protien'] != null &&
//           userVitals[i]['protien'] != "NaN") {
//         userVitals[i]['protien'] = userVitals[i]['protien'].toStringAsFixed(2);
//         proteinStatus =
//             calculateFullBodyProteinStatus(userVitals[i]['protien']);
//       }
//
//       if (userVitals[i]['intra_cellular_water'] != null &&
//           userVitals[i]['intra_cellular_water'] != "NaN") {
//         userVitals[i]['intra_cellular_water'] =
//             userVitals[i]['intra_cellular_water'].toStringAsFixed(2);
//         icwStatus =
//             calculateFullBodyICWStatus(userVitals[i]['intra_cellular_water']);
//       }
//
//       if (userVitals[i]['extra_cellular_water'] != null &&
//           userVitals[i]['extra_cellular_water'] != "NaN") {
//         userVitals[i]['extra_cellular_water'] =
//             userVitals[i]['extra_cellular_water'].toStringAsFixed(2);
//         ecwStatus =
//             calculateFullBodyECWStatus(userVitals[i]['extra_cellular_water']);
//       }
//
//       if (userVitals[i]['mineral'] != null &&
//           userVitals[i]['mineral'] != "NaN") {
//         userVitals[i]['mineral'] = userVitals[i]['mineral'].toStringAsFixed(2);
//         mineralStatus =
//             calculateFullBodyMineralStatus(userVitals[i]['mineral']);
//       }
//
//       if (userVitals[i]['skeletal_muscle_mass'] != null &&
//           userVitals[i]['skeletal_muscle_mass'] != "NaN") {
//         userVitals[i]['skeletal_muscle_mass'] =
//             userVitals[i]['skeletal_muscle_mass'].toStringAsFixed(2);
//         smmStatus =
//             calculateFullBodySMMStatus(userVitals[i]['skeletal_muscle_mass']);
//       }
//
//       if (userVitals[i]['body_fat_mass'] != null &&
//           userVitals[i]['body_fat_mass'] != "NaN") {
//         userVitals[i]['body_fat_mass'] =
//             userVitals[i]['body_fat_mass'].toStringAsFixed(2);
//         bfmStatus = calculateFullBodyFATStatus(userVitals[i]['body_fat_mass']);
//       }
//
//       if (userVitals[i]['body_cell_mass'] != null &&
//           userVitals[i]['body_cell_mass'] != "NaN") {
//         userVitals[i]['body_cell_mass'] =
//             userVitals[i]['body_cell_mass'].toStringAsFixed(2);
//         bcmStatus = calculateFullBodyBCMStatus(userVitals[i]['body_cell_mass']);
//       }
//
//       if (userVitals[i]['waist_hip_ratio'] != null &&
//           userVitals[i]['waist_hip_ratio'] != "NaN") {
//         userVitals[i]['waist_hip_ratio'] =
//             userVitals[i]['waist_hip_ratio'].toStringAsFixed(2);
//         waistHipStatus =
//             calculateFullBodyWHPRStatus(userVitals[i]['waist_hip_ratio']);
//       }
//
//       if (userVitals[i]['percent_body_fat'] != null &&
//           userVitals[i]['percent_body_fat'] != "NaN") {
//         userVitals[i]['percent_body_fat'] =
//             userVitals[i]['percent_body_fat'].toStringAsFixed(2);
//         pbfStatus =
//             calculateFullBodyPBFStatus(userVitals[i]['percent_body_fat']);
//       }
//
//       if (userVitals[i]['waist_height_ratio'] != null &&
//           userVitals[i]['waist_height_ratio'] != "NaN") {
//         userVitals[i]['waist_height_ratio'] =
//             userVitals[i]['waist_height_ratio'].toStringAsFixed(2);
//         waistHeightStatus =
//             calculateFullBodyWHTRStatus(userVitals[i]['waist_height_ratio']);
//       }
//
//       if (userVitals[i]['visceral_fat'] != null &&
//           userVitals[i]['visceral_fat'] != "NaN") {
//         userVitals[i]['visceral_fat'] =
//             stringify(userVitals[i]['visceral_fat']);
//         vfStatus = calculateFullBodyVFStatus(userVitals[i]['visceral_fat']);
//       }
//
//       if (userVitals[i]['basal_metabolic_rate'] != null &&
//           userVitals[i]['basal_metabolic_rate'] != "NaN") {
//         userVitals[i]['basal_metabolic_rate'] =
//             stringify(userVitals[i]['basal_metabolic_rate']);
//         bmrStatus =
//             calculateFullBodyBMRStatus(userVitals[i]['basal_metabolic_rate']);
//       }
//
//       if (userVitals[i]['bone_mineral_content'] != null &&
//           userVitals[i]['bone_mineral_content'] != "NaN") {
//         userVitals[i]['bone_mineral_content'] =
//             userVitals[i]['bone_mineral_content'].toStringAsFixed(2);
//         bomcStatus =
//             calculateFullBodyBMCStatus(userVitals[i]['bone_mineral_content']);
//       }
//
//       userVitals[i]['bmi'] ??= calcBmi(
//           height: userVitals[i]['heightMeters'].toString(),
//           weight: userVitals[i]['weight'].toString());
//       finalHeight = doubleFly(userVitals[i]['heightMeters']) ?? finalHeight;
//       finalWeight = doubleFly(userVitals[i]['weightKG']) ?? finalWeight;
//       if (userVitals[i]['systolic'] != null &&
//           userVitals[i]['diastolic'] != null) {
//         userVitals[i]['bp'] = stringify(userVitals[i]['systolic']) +
//             '/' +
//             stringify(userVitals[i]['diastolic']);
//       }
//       userVitals[i]['weightKGClass'] = userVitals[i]['bmiClass'];
//       userVitals[i]['ECGBpmClass'] = userVitals[i]['leadTwoStatus'];
//       userVitals[i]['fatRatioClass'] = userVitals[i]['fatClass'];
//       userVitals[i]['pulseBpmClass'] = userVitals[i]['pulseClass'];
//     }
//     prefs.setDouble(SPKeys.weight, finalWeight);
//     prefs.setDouble(SPKeys.height, finalHeight);
//
//     //Check which vital
//     vitalsOnHome.forEach((f) {
//       allScores[f] = [];
//       allScores[f + 'Class'] = [];
//       for (var i = 0; i < userVitals.length; i++) {
//         if (userVitals[i][f] != '' &&
//             userVitals[i][f] != null &&
//             userVitals[i][f] != 'N/A') {
//           /// round off to nearest 2 decimal 🌊
//           if (userVitals[i][f] is double) {
//             if (decimalVitals.contains(f)) {
//               userVitals[i][f] = (userVitals[i][f] * 100.0).toInt() / 100;
//             } else {
//               userVitals[i][f] = (userVitals[i][f]).toInt();
//             }
//           }
//           Map mapToAdd = {
//             'value': userVitals[i][f],
//             'status': userVitals[i][f + 'Class'] == null
//                 ? 'Unknown'
//                 : camelize(userVitals[i][f + 'Class']),
//             'date': userVitals[i]['dateTimeFormatted'] != null
//                 ? DateTime.tryParse(
//                     userVitals[i]['dateTimeFormatted'].toString())
//                 : getDateTimeStamp(user['accountCreated']),
//             'moreData': {
//               'Address': stringify(userVitals[i]['orgAddress']),
//               'City': stringify(userVitals[i]['IHLMachineLocation']),
//               'Source': 'IHL Kiosk'
//             }
//           };
//           // processing specific to a vital
//           if (f == 'temperature') {
//             if (userVitals[i]['Roomtemperature'] != null) {
//               userVitals[i]['Roomtemperature'] =
//                   doubleFly(userVitals[i]['Roomtemperature']);
//               mapToAdd['moreData']['Room Temperature'] =
//                   '${stringify((userVitals[i]['Roomtemperature'] * 9 / 5) + 32)} ${vitalsUI['temperature']['unit']}';
//             }
//             mapToAdd['value'] =
//                 (((userVitals[i][f] * 900 / 5).toInt()) / 100 + 32)
//                     .toStringAsFixed(2);
//           }
//           if (f == 'bp') {
//             mapToAdd['moreData']['Systolic'] =
//                 userVitals[i]['systolic'].toString();
//             mapToAdd['moreData']['Diastolic'] =
//                 userVitals[i]['diastolic'].toString();
//           }
//
//           if (f == 'protien') {
//             mapToAdd['protien'] = userVitals[i]['protien'].toString();
//             mapToAdd['status'] = proteinStatus.toString();
//           }
//
//           if (f == 'intra_cellular_water') {
//             mapToAdd['intra_cellular_water'] =
//                 userVitals[i]['intra_cellular_water'].toString();
//             mapToAdd['status'] = icwStatus.toString();
//           }
//
//           if (f == 'extra_cellular_water') {
//             mapToAdd['extra_cellular_water'] =
//                 userVitals[i]['extra_cellular_water'].toString();
//             mapToAdd['status'] = ecwStatus.toString();
//           }
//
//           if (f == 'mineral') {
//             mapToAdd['mineral'] = userVitals[i]['mineral'].toString();
//             mapToAdd['status'] = mineralStatus.toString();
//           }
//
//           if (f == 'skeletal_muscle_mass') {
//             mapToAdd['skeletal_muscle_mass'] =
//                 userVitals[i]['skeletal_muscle_mass'].toString();
//             mapToAdd['status'] = smmStatus.toString();
//           }
//
//           if (f == 'body_fat_mass') {
//             mapToAdd['body_fat_mass'] =
//                 userVitals[i]['body_fat_mass'].toString();
//             mapToAdd['status'] = bfmStatus.toString();
//           }
//
//           if (f == 'body_cell_mass') {
//             mapToAdd['body_cell_mass'] =
//                 userVitals[i]['body_cell_mass'].toString();
//             mapToAdd['status'] = bcmStatus.toString();
//           }
//
//           if (f == 'waist_hip_ratio') {
//             mapToAdd['waist_hip_ratio'] =
//                 userVitals[i]['waist_hip_ratio'].toString();
//             mapToAdd['status'] = waistHipStatus.toString();
//           }
//
//           if (f == 'percent_body_fat') {
//             mapToAdd['percent_body_fat'] =
//                 userVitals[i]['percent_body_fat'].toString();
//             mapToAdd['status'] = pbfStatus.toString();
//           }
//
//           if (f == 'waist_height_ratio') {
//             mapToAdd['waist_height_ratio'] =
//                 userVitals[i]['waist_height_ratio'].toString();
//             mapToAdd['status'] = waistHeightStatus.toString();
//           }
//
//           if (f == 'visceral_fat') {
//             mapToAdd['visceral_fat'] = userVitals[i]['visceral_fat'].toString();
//             mapToAdd['status'] = vfStatus.toString();
//           }
//
//           if (f == 'basal_metabolic_rate') {
//             mapToAdd['basal_metabolic_rate'] =
//                 userVitals[i]['basal_metabolic_rate'].toString();
//             mapToAdd['status'] = bmrStatus.toString();
//           }
//
//           if (f == 'bone_mineral_content') {
//             mapToAdd['bone_mineral_content'] =
//                 userVitals[i]['bone_mineral_content'].toString();
//             mapToAdd['status'] = bomcStatus.toString();
//           }
//
//           if (f == 'ECGBpm') {
//             mapToAdd['graphECG'] = ECGCalc(
//               isLeadThree: userVitals[i]['LeadMode'] == 3,
//               data1: userVitals[i]['ECGData'],
//               data2: userVitals[i]['ECGData2'],
//               data3: userVitals[i]['ECGData3'],
//             );
//
//             mapToAdd['moreData']['Lead One Status'] =
//                 stringify(userVitals[i]['leadOneStatus']);
//             mapToAdd['moreData']['Lead Two Status'] =
//                 stringify(userVitals[i]['leadTwoStatus']);
//             mapToAdd['moreData']['Lead Three Status'] =
//                 stringify(userVitals[i]['leadThreeStatus']);
//           }
//           allScores[f].add(mapToAdd);
//           if (!vitalsToShow.contains(f)) {
//             vitalsToShow.add(f);
//           }
//         }
//       }
//     });
//     vitalsToShow.toSet();
//     vitalsToShow = vitalsOnHome;
//
//     loading = false;
//     if (this.mounted) {
//       this.setState(() {});
//     }
//   }
//
//   double doubleFly(k) {
//     if (k is num) {
//       return k * 1.0;
//     }
//     if (k is String) {
//       return double.tryParse(k);
//     }
//     return null;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     this.getData();
//   }
//
//   Widget vitalInfo(String leftTitleTxt, String leftSubTxt, String rightTitleTxt,
//       String rightSubTxt) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: Container(
//         child: Row(
//           children: <Widget>[
//             Column(
//               children: [
//                 Text(
//                   leftTitleTxt,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontFamily: FitnessAppTheme.fontName,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 20,
//                     letterSpacing: 0.5,
//                     color: AppColors.textitemTitleColor.withOpacity(0.9),
//                   ),
//                 ),
//                 Text(
//                   leftSubTxt,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontFamily: FitnessAppTheme.fontName,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                     letterSpacing: 0.5,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//               ],
//             ),
//             SizedBox(width: 60),
//             Column(
//               children: [
//                 Text(
//                   rightTitleTxt,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontFamily: FitnessAppTheme.fontName,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 20,
//                     letterSpacing: 0.5,
//                     color: AppColors.textitemTitleColor.withOpacity(0.9),
//                   ),
//                 ),
//                 Text(
//                   rightSubTxt,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontFamily: FitnessAppTheme.fontName,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                     letterSpacing: 0.5,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     if (width < 600) {
//       width = 500;
//     }
//     if (loading) {
//       return SafeArea(
//         child: Container(
//           color: AppColors.bgColorTab,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 40,
//                     child: TextButton(
//                       child: Icon(
//                         Icons.menu,
//                         size: 30,
//                         color: Colors.white,
//                       ),
//                       onPressed: () {
//                         Scaffold.of(context).openDrawer();
//                       },
//                       style: TextButton.styleFrom(
//                         padding: EdgeInsets.all(0),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     if (!isVerified) {
//       return SafeArea(
//         child: Container(
//           color: AppColors.bgColorTab,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 40,
//                     child: TextButton(
//                       child: Icon(
//                         Icons.menu,
//                         size: 30,
//                         color: AppColors.primaryAccentColor,
//                       ),
//                       onPressed: () {
//                         Scaffold.of(context).openDrawer();
//                       },
//                       style: TextButton.styleFrom(
//                         padding: EdgeInsets.all(0),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Center(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       size: 100,
//                       color: AppColors.lightTextColor,
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     Text(AppTexts.updateProfile),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     TextButton(
//                       style: TextButton.styleFrom(
//                         backgroundColor: AppColors.primaryAccentColor,
//                         textStyle: TextStyle(color: Colors.white),
//                       ),
//                       child: Text(AppTexts.visitProfile),
//                       onPressed: () {
//                         widget.goToProfile();
//                       },
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     return SafeArea(
//       child: Column(
//         children: <Widget>[
//           CustomPaint(
//             painter: BackgroundPainter(
//               primary: AppColors.primaryColor.withOpacity(0.7),
//               secondary: AppColors.primaryColor.withOpacity(0.0),
//             ),
//             child: Container(),
//           ),
//           Expanded(
//             child: CustomScrollView(
//               slivers: <Widget>[
//                 SliverToBoxAdapter(
//                   child: Container(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             SizedBox(
//                               width: 40,
//                               child: TextButton(
//                                 child: Icon(
//                                   Icons.menu,
//                                   size: 30,
//                                   color: Colors.white,
//                                 ),
//                                 onPressed: () {
//                                   Scaffold.of(context).openDrawer();
//                                 },
//                                 style: TextButton.styleFrom(
//                                   padding: EdgeInsets.all(0),
//                                 ),
//                               ),
//                             ),
//                             /*Text(
//                               AppTexts.scoreTitle,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 25 * width / 500),
//                             ),
//                             SizedBox(
//                               width: 40,
//                             )*/
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SliverToBoxAdapter(
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                       child: Container(
//                         height: 450,
//                         child: Card(
//                           margin: const EdgeInsets.symmetric(
//                             vertical: 8.0,
//                             horizontal: 0,
//                           ),
//                           child: Column(
//                             children: <Widget>[
//                               ListTile(
//                                 title: Text(
//                                   "Glance at your Vitals",
//                                   style: TextStyle(
//                                     fontFamily: FitnessAppTheme.fontName,
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 24,
//                                     letterSpacing: 0.5,
//                                     color: AppColors.textitemTitleColor,
//                                   ),
//                                 ),
//                                 onTap: () {},
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 10),
//                     child: Text(
//                       vitalsToShow.length > 0
//                           ? AppTexts.yoVitals
//                           : AppTexts.noVitals,
//                       style: TextStyle(
//                         fontSize: 20 * width / 500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SliverGrid(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount:
//                         MediaQuery.of(context).size.width > 600 ? 3 : 2,
//                     childAspectRatio: 1.2,
//                   ),
//                   delegate: SliverChildBuilderDelegate(
//                     (BuildContext context, int index) {
//                       return VitalCard(
//                         uiData: vitalsUI[vitalsToShow[index]],
//                         vitalType: vitalsToShow[index],
//                         data: allScores[vitalsToShow[index]],
//                       );
//                     },
//                     childCount: vitalsToShow.length,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
