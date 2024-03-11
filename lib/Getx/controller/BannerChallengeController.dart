import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../health_challenge/models/enrolled_challenge.dart';
import 'listOfChallengeContoller.dart';
import '../../health_challenge/controllers/challenge_api.dart';
import '../../new_design/data/model/Banner/BannerInputModel.dart';
import '../../new_design/data/providers/network/apis/BannerApi/bannerChallengeApi.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/spKeys.dart';
import '../../health_challenge/models/sendInviteUserForChallengeModel.dart';
import '../../new_design/data/model/Banner/BannerChallengeModel.dart';
import '../../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';

class BannerChallengeController extends GetxController {
  RegExp emailRegExp =
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  // static ValueNotifier<int> invitedEmailCount = ValueNotifier<int>(0);
  TextEditingController sendInviteEmailController = TextEditingController();
  final String BANNERCHALLENGEUPDATE = 'BannerChallenge';
  var userData;
  Datum challenge;
  RxInt invited = RxInt(0);
  bool loading = false;
  String affi;
  bool inviteVisible = false;
  List<Map<String, dynamic>> bannerChallenges = [];
  int _totalChallenges = 0;
  List<EnrolledChallenge> _enrollList = [];
  List<String> _enrollIds = [];
  List<EnrolledChallenge> get enrollList => _enrollList;
  String userId, userEmail, challengeVisibleType;

  void getChallenges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _data = prefs.get(SPKeys.userData);
    userData = json.decode(_data);
    userId = userData['User']['id'];
    userEmail = userData['User']['email'];
    String ss = prefs.getString("sso_flow_affiliation");
    if (ss != null) {
      Map<String, dynamic> exsitingAffi = jsonDecode(ss);
      UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
        "affiliation_unique_name": exsitingAffi["affiliation_unique_name"]
      };
    }
    affi = UpdatingColorsBasedOnAffiliations.ssoAffiliation == null
        ? "global_services"
        : UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"];
    await getBannerChallenges();
  }

  bool isAssidAlreadyExist(String assid, List<Map<String, dynamic>> bannerChallenges) {
    for (var challenge in bannerChallenges) {
      if (challenge["assid"] == assid) {
        return true; // assid already exists
      }
    }
    return false; // assid does not exist
  }

  Future getBannerChallenges() async {
    loading = true;
    bannerChallenges = [];
    update([BANNERCHALLENGEUPDATE]);
    BannerInputModel bannerInputModel = BannerInputModel(
        userId: userId, userEmail: userEmail, affiliation: [affi], pageStart: 0, pageEnd: 10);
    var _apiChallenge = await BannerChallengeApi().gettingBannerChallenges(bannerInputModel);
    _enrollList = await ChallengeApi().listofUserEnrolledChallenges(userId: userId);
    _enrollIds = [];
    if (_enrollList.isNotEmpty) {
      _enrollIds = _enrollList.map((e) => e.challengeId).toList();
    }
    Map<String, List<Datum>> groupedData = {};

    for (Datum item in _apiChallenge.data) {
      String assid = item.assosideId;

      if (groupedData.containsKey(assid)) {
        groupedData[assid].add(item);
      } else {
        groupedData[assid] = [item];
      }
    }

    for (var item in groupedData.entries) {
      var _inviteVisible = false;
      var dataList = item.value;
      var assid = item.key;
      var _enrolList = dataList.any((element) => _enrollIds.contains(element.challengeId));
      try {
        dataList.forEach((_l) async {
          var _challenge = await ChallengeApi().challengeDetail(challengeId: _l.challengeId);
          if ((DateFormat('MM-dd-yyyy').format(_challenge.challengeEndTime).toString() !=
              "01-01-2000")) {
            if (_challenge.challengeEndTime.isBefore(DateTime.now())) {
              dataList.removeWhere((element) => element.challengeId == _challenge.challengeId);
            }
          }
        });
      } catch (e) {
        print(e);
      }
      try {
        if (dataList[0].affiliations.contains(affi) && _enrolList) {
          await inviteCount(dataList[0].challengeId);
          _inviteVisible = true;
        }
      } catch (e) {
        print(e);
      }
      if (Get.currentRoute == "/LandingPage" || Get.currentRoute == "/Home") {
        challengeVisibleType = 'main';
      } else {
        challengeVisibleType = 'social';
      }
      if (challengeVisibleType == 'main' &&
          dataList.any((element) => element.bannerVisibleInMainDashboard == true)) {
        bannerChallenges.add({'assid': assid, 'data': dataList, 'invite': _inviteVisible});
      } else if (challengeVisibleType == 'social' &&
          dataList.any((element) => element.bannerVisibleInSocialDashboard == true)) {
        if (!isAssidAlreadyExist(assid, bannerChallenges)) {
          // Add the new challenge with the unique assid
          bannerChallenges.add({'assid': assid, 'data': dataList, 'invite': _inviteVisible});
        } else {
          print("Assid already exists!");
        }
      }
    }

    bannerChallenges = bannerChallenges.toSet().toList();
    if (bannerChallenges.isNotEmpty) {
      List<Datum> _li = bannerChallenges[0]['data'];

      await inviteCount(_li[0].challengeId);
      inviteVisible = bannerChallenges[0]['invite'];
    }
    loading = false;
    update([BANNERCHALLENGEUPDATE]);
    return bannerChallenges;
  }

  inviteCount(String challengeID) async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    String userEmail = prefs1.getString("email");
    var response = await ChallengeApi()
        .challengeReferInviteCount(challangeId: challengeID, refer_by_email: userEmail);
    if (response != null) {
      try {
        invited.value = 5 - int.parse(response);
      } catch (e) {
        log("invite Count had some issue");
      }
    }
  }

  inviteThroughEmailApiCall({
    String challengeID,
    referredbyname,
    refferredtoemail,
  }) async {
    log('invite $invited');
    if (invited.value <= 5) {
      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      String userEmail = prefs1.getString("email");
      var response = await ChallengeApi().inviteUserForChallenge(
          sendInviteUserForChallenge: SendInviteUserForChallenge(
              challangeId: challengeID,
              referredbyname: referredbyname,
              referredbyemail: userEmail,
              refferredtoemail: refferredtoemail));
      if (response == "invite success") {
        invited.value = invited.value - 1;
        sendInviteEmailController.clear();
        checkReferInviteCount(challengeID);
        Get.back();
        toastMessageAlert("Invited Successfully!!");
      } else if (response == "already invited") {
        toastMessageAlert("Email already invited");
      } else if (response == "failed") {
        toastMessageAlert("Invite send failed");
      }
    } else {
      toastMessageAlert("Already invited 5 members!!");
    }
  }

  static toastMessageAlert(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<ValueNotifier<int>> checkReferInviteCount(String challengeID) async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    String userEmail = prefs1.getString("email");
    var response = await ChallengeApi()
        .challengeReferInviteCount(challangeId: challengeID, refer_by_email: userEmail);
    if (response != null) {
      try {
        int i = 0;
        i = 5 - int.parse(response);
        // i = invitedEmailCount.value;
        log("invite count for this challenge => ${i}");
        return ValueNotifier(i);
        // invitedEmailCount.notifyListeners();
      } catch (e) {
        log("invite Count had some issue");
      }
    }
  }
}
