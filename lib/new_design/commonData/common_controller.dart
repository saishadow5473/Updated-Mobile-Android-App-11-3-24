import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/spKeys.dart';
import '../../utils/CrossbarUtil.dart';
import '../../utils/SpUtil.dart';
import '../data/model/loginModel/userDataModel.dart';
import '../data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import 'common_api_calls.dart';
import 'data_class.dart';

//Controller that holds all the common Data
class CommonController {
  UserData userData;

  Map<String, dynamic> userMapData = {};
  bool loader;
  String userName;
  String userUID;
  String userEmail;
  static String token;
  String apiToken;
  double userHeight;
  double userWeight;
  ProfileDataModel profileDataModel;
  bool ssoLogin;
  static Map<String, String> headerSso = <String, String>{
    'Content-Type': 'application/json',
    'Token': 'bearer ',
    'ApiToken':
        "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA=="
  };
  static String authToken =
      "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA==";
}

//to Update current User data with all elements such as Affiliation, Last checkin, etc,.
class UserAllData extends CommonController {
  Future<void> userDataUpdateValue() async {
    loader = true;
    userData = await CommonDataConvertor.getAndUpdateUserData();
    SharedPreferencesData().vitalBasedDataupdating();
    //updating common datas;
    updateNormalDatas();
    debugPrint("UserAllData called and updated Succesfully !");
    loader = false;
  }

  updateNormalDatas({UserData userDATA}) {
    userDATA ??= userData;
    userName = userDATA.user.firstName + userDATA.user.lastName;
    CommonController.token = userDATA.token;
    userHeight = userDATA.lastCheckin.heightMeters ?? userDATA.user.heightMeters;
    userWeight = userDATA.lastCheckin.weightKg ?? double.parse(userDATA.user.userInputWeightInKg);
    userUID = userDATA.user.id;
    userEmail = userDATA.user.email;
    updateProfileBasedDatas(userDATA: userDATA);
  }

  updateProfileBasedDatas({UserData userDATA}) {
    userDATA ??= userData;
    User user = userDATA.user;
    profileDataModel = ProfileDataModel(
        firstName: user.firstName,
        lastName: user.lastName,
        uid: user.id,
        email: user.email,
        weight: userDATA.lastCheckin.weightKg ?? user.userInputWeightInKg,
        height: userDATA.lastCheckin.heightMeters ?? user.heightMeters,
        mobileNumber: user.mobileNumber,
        dob: user.dateOfBirth != null
            ? DateFormat("MM/dd/yyyy").parse(user.dateOfBirth)
            : null, //"MM/dd/year"
        gender: user.gender,
        address: user.address,
        area: user.area,
        city: user.city,
        state: user.state,
        pincode: user.pincode,
        displayPicture: user.photo);
    profileDataModel;
  }
}

//to Update the current Users vital data alone
class VitalData extends CommonController {
  void vitalDataUpdateValue() {
    loader = true;
    debugPrint("vitalData Calling");
    loader = false;
  }
}

//to update the current Users profile data alone
class ProfileData extends CommonController {
  void profileDataUpdateValue() {
    loader = true;
    debugPrint("profileData Calling");
    loader = false;
  }
}

class ApiTokenAndNormalToken extends CommonController {
  void profileDataUpdateValue() {
    loader = true;
    debugPrint("profileToken Calling");
    loader = false;
  }
}

class SharedPreferencesData extends CommonController {
  void sharedPrefsDataUpdating() {
    debugPrint("SharedPreference Data Update Calling");
  }

  basicDetailUpdating() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("ihlUserId", userUID);
    preferences.setString('email', userEmail);
  }

  vitalBasedDataupdating() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await MyvitalsApi().vitalDatas(data);
    Map<dynamic, dynamic> checkinData = await CommonApiCalls.getCheckinData(iHLUserId: userUID);
    preferences.setString(SPKeys.vitalsData, jsonEncode(checkinData));
    if (checkinData[0] == null && checkinData[0]['weightKG'] == null) {
      checkinData[0]['weightKG'] = userData.user.userInputWeightInKg;
    }
    if (checkinData[0] == null && checkinData[0]['heightMeters'] == null) {
      checkinData[0]['heightMeters'] = userData.user.heightMeters;
    }
    // double finalHeight = checkinData[i]['heightMeters'] ?? 0;
    // double finalWeight = checkinData[i]['weightKG'] ?? 0;
  }
}

class CommonDataConvertor {
  static Future<UserData> getAndUpdateUserData() async {
    Map<String, dynamic> data = await CommonApiCalls.userDataUpdateAPI();
    CommonController().userMapData = data;
    UserData modelData = UserData.fromJson(data);
    return modelData;
  }
}

/*
 var ihlUserId = prefs.get("ihlUserId");******
    var email = SpUtil.getString('email');


    //myVitalsAPI********
    if (response != null) {
        SpUtil.putString(LSKeys.apiToken, apiToken);
        SpUtil.putString(LSKeys.iHLUserToken, response['Token']);
        SpUtil.putString(LSKeys.ihlUserId, response['User']['id']);

        SpUtil.putString(LSKeys.userDetail, jsonEncode(response['User']));
        SpUtil.putString(LSKeys.userName, response['User']["firstName"]);
        SpUtil.putString(LSKeys.userLastNAme, response['User']["lastName"]);
        prefs.setString('name', response['User']["firstName"] + ' ' + response['User']["lastName"]);
        SpUtil.putInt(LSKeys.ihlScore,
        SpUtil.putBool(
            LSKeys.affiliation, response['User']['user_affiliate'] == null ? false : true);
        SpUtil.putString(
            LSKeys.weight,
            response['User']["userInputWeightInKG"] ==null||response['User']["userInputWeightInKG"] == ""
                ? "50"
                : response['User']["userInputWeightInKG"]);

        SpUtil.putDouble(LSKeys.height, response['User']["heightMeters"]);
        try{
          var localBMI = double.parse(response['User']["userInputWeightInKG"]) /
              (response["User"]["heightMeters"]*
                 response["User"]["heightMeters"]);
          SpUtil.putDouble("localBMI", localBMI);
        }
        catch(e){
          SpUtil.putDouble("localBMI", 0.0);
        }
        SpUtil.putString(LSKeys.gender, response['User']['gender']);
        String birthYear = response["User"]["dateOfBirth"];
        String dob = birthYear.substring(birthYear.length - 4, birthYear.length);
        print(dob);
        var currentYear = DateTime.now().year;
        var age = currentYear - int.parse(dob);
        SpUtil.putInt(LSKeys.userAge, age);
        double height = response["User"]["heightMeters"] * 100;

        num maleBmr;
        if (response['User']["userInputWeightInKG"] != null &&
            response['User']["userInputWeightInKG"] != "") {
          maleBmr = (10 * double.parse(response['User']["userInputWeightInKG"]) +
              6.25 * height -
              (5 * age) +
              5);
        } else if (response['LastCheckin']["weightKG"] != null) {
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
        } else if (response['LastCheckin']["weightKG"] != null) {
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
        localSotrage.write(
            LSKeys.ogCaloriesNeed,
            response['User']['gender'] == 'm' ||
                    response['User']['gender'] == "M" ||
                    response['User']['gender'] == "male" ||
                    response['User']['gender'] == "Male"
                ? maleBmr.toStringAsFixed(0)
                : femaleBmr.toStringAsFixed(0));
        var b64Image = response['User']["photo"] ?? AvatarImage.profilBase;

        if (b64Image != null) {
          SpUtil.putString(LSKeys.imageMemory, b64Image);
          PhotoChangeNotifier.photo.value = b64Image;
          PhotoChangeNotifier.photo.notifyListeners();
        }
  SpUtil.putBool(
            LSKeys.affiliation, response['User']["user_affiliate"] == null ? false : true);
        print(response["LastCheckin"] != null);
        if (response["LastCheckin"] != null) {
       
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
          try {
            BMI = int.parse(response['User']["userInputWeightInKG"]) /
                (response['User']["heightMeters"] * response['User']["heightMeters"]);
          } catch (e) {
            BMI = double.parse(response['User']["userInputWeightInKG"]) /
                (response['User']["heightMeters"] * response['User']["heightMeters"]);
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
            "BMI_status": BMI < 18.5
                ? "underweight"
                : BMI < 24.9
                    ? "Normal"
                    : BMI < 29.9
                        ? "overweight"
                        : "Obese",
            "BP_status": null,
            "Mineral_status": null,
            "Weight_status": BMI < 18.5
                ? "underweight"
                : BMI < 24.9
                    ? "Normal"
                    : BMI < 29.9
                        ? "overweight"
                        : "Obese",
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


      //fooddetailscreen
    iHLUserId = prefs.getString('ihlUserId');****



    //custom_food_details
    var userData = prefs.get('data');
     var height = prefs.get('userLatestHeight').toString();
    var currentWeight = await prefs.get('userLatestWeight').toString();

    //myvitalsController
    Object raw = prefs.get(SPKeys.userData);
    var userVitalst = prefs.getString(SPKeys.vitalsData).runtimeType == String
          ? jsonDecode(prefs.getString(SPKeys.vitalsData))
          : prefs.getString(SPKeys.vitalsData);
    prefs.setDouble(SPKeys.weight, finalWeight);
      prefs.setDouble(SPKeys.height, finalHeight);


      //getx_controller_cardio
      var visceralFatStatus = prefs.get("vf_status");


      //other_vitals
    s = prefs.getBool('allAns');


//splash_screen
prefs.setString(SPKeys.userData, response1.body);
          prefs1.setString("ihlUserId", iHLUserId);
prefs.setString(SPKeys.email, email); ****

challenge_details_screen
                        var k = jsonDecode(prefs.getString(SPKeys.jUserData));
//paymentsuccessnew

    bool sendLastCheckin = prefs.get('sendLastCheckin');
    String apiToken = prefs.get('auth_token');
SPKeys.userData

 */