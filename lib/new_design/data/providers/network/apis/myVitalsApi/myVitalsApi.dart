import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/new_design/data/model/loginModel/userDataModel.dart';
import 'package:ihl/new_design/data/model/loginModel/vitalsData.dart';
import 'package:ihl/new_design/presentation/pages/profile/updatePhoto.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../utils/SpUtil.dart';
import '../../../../../app/utils/localStorageKeys.dart';
import '../../../../../presentation/controllers/vitalDetailsController/myVitalsController.dart';
import '../../api_provider.dart';
import '../../networks.dart';

class MyvitalsApi {
  Future vitalDatas(Map response) async {
    // var apiToken = localSotrage.read(LSKeys.apiToken);
    var apiToken = SpUtil.getString(LSKeys.apiToken);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // var csrfToken = await GenerateToken().GetCSRFToken();
    try {
      // final response = await dio.post(API.iHLUrl + '/login/qlogin2',
      //     options: Options(
      //       headers: {
      //         'Content-Type': 'application/json',
      //         'ApiToken': apiToken,
      //         //'X-XSRF-TOKEN': csrfToken
      //       },
      //     ),
      //     data: jsonEncode(<String, String>{
      //       'email': "dinesh.kumar@indiahealthlink.com",

      //       //'password': _password,
      //       'password': "Test@123"
      //     }));
      // response = await SplashScreenApiCalls().loginApi();
      CheckAllDataLoaded.data.value = false;
      if (response != null) {
        //localSotrage.write(LSKeys.apiToken, apiToken);
        SpUtil.putString(LSKeys.apiToken, apiToken);
        //localSotrage.write(LSKeys.iHLUserToken, response['Token']);
        SpUtil.putString(LSKeys.iHLUserToken, response['Token']);
        //localSotrage.write(LSKeys.ihlUserId, response['User']['id']);
        SpUtil.putString(LSKeys.ihlUserId, response['User']['id']);
        //localSotrage.write(LSKeys.userDetail, response['User']);

        SpUtil.putString(LSKeys.userDetail, jsonEncode(response['User']));
        //localSotrage.write(LSKeys.userName, response['User']["firstName"]);
        SpUtil.putString(LSKeys.userName, response['User']["firstName"]);
        SpUtil.putString(LSKeys.userLastNAme, response['User']["lastName"]);
        prefs.setString('name', response['User']["firstName"] + ' ' + response['User']["lastName"]);
        //localSotrage.write(LSKeys.ihlScore,
        //    response['User']["user_score"] == null ? 0 : response['User']["user_score"]["T"] ?? 0);
        SpUtil.putInt(LSKeys.ihlScore,
            response['User']["user_score"] == null ? 0 : response['User']["user_score"]["T"] ?? 0);
        //localSotrage.write(
        //    LSKeys.affiliation, response['User']['user_affiliate'] == null ? false : true);
        SpUtil.putBool(
            LSKeys.affiliation, response['User']['user_affiliate'] == null ? false : true);
        //localSotrage.write(LSKeys.weight, response['User']["userInputWeightInKG"]);
        SpUtil.putString(
            LSKeys.weight,
            response['User']["userInputWeightInKG"] == null ||
                    response['User']["userInputWeightInKG"] == ""
                ? "50"
                : response['User']["userInputWeightInKG"]);

        //localSotrage.write(LSKeys.height, response['User']["heightMeters"]);
        SpUtil.putDouble(LSKeys.height, response['User']["heightMeters"] ?? 1.1);
        //localSotrage.write(LSKeys.gender, response['User']['gender']);
        try {
          var localBMI = double.parse(response['User']["userInputWeightInKG"]) /
              (response["User"]["heightMeters"] * response["User"]["heightMeters"]);
          SpUtil.putDouble("localBMI", localBMI);
        } catch (e) {
          SpUtil.putDouble("localBMI", 0.0);
        }
        SpUtil.putString(LSKeys.gender, response['User']['gender'] ?? "1");
        String birthYear = response["User"]["dateOfBirth"] ?? '01-01-2000';
        String dob = birthYear.substring(birthYear.length - 4, birthYear.length);
        print(dob);
        var currentYear = DateTime.now().year;
        var age = currentYear - int.parse(dob);
        // localSotrage.write(LSKeys.userAge, age);
        SpUtil.putInt(LSKeys.userAge, age);
        double height = (response["User"]["heightMeters"] ?? 1.1) * 100;

        num maleBmr;

        if (response['User']["userInputWeightInKG"] != null &&
            response['User']["userInputWeightInKG"] != "") {
          maleBmr = (10 * double.parse(response['User']["userInputWeightInKG"]) +
              6.25 * height -
              (5 * age) +
              5);
        } else if (response['LastCheckin'] != null && response['LastCheckin']["weightKG"] != null) {
          maleBmr = (10 * double.parse(response['LastCheckin']["weightKG"].toString()) +
              6.25 * height -
              (5 * age) +
              5);
        } else {
          maleBmr = 1700;
        }
        num femaleBmr;
        if (response['User']["userInputWeightInKG"] != null &&
            response['User']["userInputWeightInKG"] != "") {
          femaleBmr = (10 * double.parse(response['User']["userInputWeightInKG"]) +
              6.25 * height -
              (5 * age) -
              161);
        } else if (response['LastCheckin'] != null && response['LastCheckin']["weightKG"] != null) {
          femaleBmr = (10 * double.parse(response['LastCheckin']["weightKG"].toString()) +
              6.25 * height -
              (5 * age) -
              161);
        } else {
          femaleBmr = 1550;
        }
        final navi = GetStorage();
        if (navi.read("setGoalNavigation") != null) {
          if (navi.read("setGoalNavigation")) {
          } else {
            localSotrage.write(
                LSKeys.caloriesNeed,
                response['User']['gender'] == 'm' ||
                        response['User']['gender'] == "M" ||
                        response['User']['gender'] == "male" ||
                        response['User']['gender'] == "Male"
                    ? maleBmr.toStringAsFixed(0)
                    : femaleBmr.toStringAsFixed(0));
          }
        } else {
          localSotrage.write(
              LSKeys.caloriesNeed,
              response['User']['gender'] == 'm' ||
                      response['User']['gender'] == "M" ||
                      response['User']['gender'] == "male" ||
                      response['User']['gender'] == "Male"
                  ? maleBmr.toStringAsFixed(0)
                  : femaleBmr.toStringAsFixed(0));
        }
        // SpUtil.putString(
        //     LSKeys.caloriesNeed,
        //     response['User']['gender'] == 'm' ||
        //             response['User']['gender'] == "M" ||
        //             response['User']['gender'] == "male" ||
        //             response['User']['gender'] == "Male"
        //         ? maleBmr.toStringAsFixed(0)
        //         : femaleBmr.toStringAsFixed(0));
        localSotrage.write(
            LSKeys.ogCaloriesNeed,
            response['User']['gender'] == 'm' ||
                    response['User']['gender'] == "M" ||
                    response['User']['gender'] == "male" ||
                    response['User']['gender'] == "Male"
                ? maleBmr.toStringAsFixed(0)
                : femaleBmr.toStringAsFixed(0));
        // SpUtil.putString(
        //     LSKeys.ogCaloriesNeed,
        //     response['User']['gender'] == 'm' ||
        //             response['User']['gender'] == "M" ||
        //             response['User']['gender'] == "male" ||
        //             response['User']['gender'] == "Male"
        //         ? maleBmr.toStringAsFixed(0)
        //         : femaleBmr.toStringAsFixed(0));
        var b64Image = response['User']["photo"] ?? AvatarImage.profilBase;

        if (b64Image != null) {
          // Uint8List imagB64 = await base64Decode(b64Image);
          // localSotrage.write(LSKeys.imageMemory, b64Image);
          SpUtil.putString(LSKeys.imageMemory, b64Image);
          PhotoChangeNotifier.photo.value = b64Image;
          PhotoChangeNotifier.photo.notifyListeners();
        }

        // localSotrage.write(
        //     LSKeys.affiliation, response['User']["user_affiliate"] == null ? false : true);
        SpUtil.putBool(
            LSKeys.affiliation, response['User']["user_affiliate"] == null ? false : true);
        print(response["LastCheckin"] != null);
        if (response["LastCheckin"] != null) {
          // localSotrage.write(LSKeys.lastCheckin, response["LastCheckin"] ?? " ");
          SpUtil.putString(LSKeys.lastCheckin, jsonEncode(response["LastCheckin"]) ?? " ");
          print("token from sharedPref${SpUtil.getString(LSKeys.iHLUserToken)}");

          try {
            await MyVitalsController().getVitalsCheckinData(SpUtil.getString(LSKeys.ihlUserId));
          } catch (e) {
            print(e);
          }

          try {
            await VitalData().updateData();
          } catch (e) {
            print(e);
          }
        } else {
          var BMI;
          if (response['User']["userInputWeightInKG"] != null &&
              response['User']["heightMeters"] != null) {
            try {
              BMI = int.parse(response['User']["userInputWeightInKG"]) /
                  (response['User']["heightMeters"] * response['User']["heightMeters"]);
            } catch (e) {
              BMI = double.parse(response['User']["userInputWeightInKG"]) /
                  (response['User']["heightMeters"] * response['User']["heightMeters"]);
            }
          } else {
            BMI = 0;
          }
          var vitalListData = {
            "BMI": BMI.toStringAsFixed(2),
            "Weight": response['User']["userInputWeightInKG"] ?? 0,
            "TEMP": 0,
            "Mineral": 0,
            "SMM": 0,
            "Pulse": 0,
            "ECG": 0,
            "BP": 0,
            "BMC": 0,
            "Protein": 0,
            "ECW": 0,
            "ICW": 0,
            "BFM": 0,
            "BCM": 0,
            "Waist Hip": 0,
            "PBF": 0,
            "VF": 0,
            "BMR": 0,
            "SPO2": 0,
            "WtHR": 0
          };
          var vitalListStatus = {
            "BMI_status": BMI <= 18.5
                ? "Low"
                : BMI <= 22.9
                    ? "Normal"
                    : BMI <= 24.9
                        ? "High"
                        : "High",
            "BP_status": null,
            "Mineral_status": null,
            "Weight_status": BMI <= 18.5
                ? "Low"
                : BMI <= 22.9
                    ? "Normal"
                    : BMI <= 24.9
                        ? "High"
                        : "High",
            "BCM_status": null,
            "TEMP_status": null,
            "Pulse_status": null,
            "ECG_status": null,
            "Protein_status": null,
            "SPO2_status": null,
            "ECW_status": null,
            "ICW_status": null,
            "BFM_status": null,
            "WaistHip_status": null,
            "PBF_status": null,
            "WtHR_status": null,
            "VF_status": null,
            "BMR_status": null,
            "BMC_status": null,
            "SMM_status": null,
          };
          localSotrage.write(LSKeys.vitalsData, vitalListData);
          localSotrage.write((LSKeys.vitalStatus), vitalListStatus);
        }
        CheckAllDataLoaded.data.value = true;
        return UserData.fromJson(response);
      }
    } on DioError catch (error) {
      throw NetworkCallsCardio.checkAndThrowError(error.type);
    }
  }
}

class CheckAllDataLoaded {
  static ValueNotifier<bool> data = ValueNotifier<bool>(false);
}
