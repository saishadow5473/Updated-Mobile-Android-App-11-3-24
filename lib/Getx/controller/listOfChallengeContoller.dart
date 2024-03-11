import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/spKeys.dart';
import '../../health_challenge/models/GetChallengeCategory.dart';
import '../../health_challenge/models/challenge_detail.dart';
import '../../health_challenge/models/challengemodel.dart';
import '../../health_challenge/models/enrolled_challenge.dart';
import '../../health_challenge/models/join_individual.dart';
import '../../health_challenge/models/listchallenge.dart';
import '../../health_challenge/models/sendInviteUserForChallengeModel.dart';

class ListChallengeController extends GetxController {
  DateTime now = DateTime.now();
  List<Challenge> allChallenegeList = [];
  List<Challenge> persistantChList = [];
  List<ChallengeDetail> challengeList = [];
  List<Challenge> runtypeChallengeList = [];
  List<Challenge> runtypeIHLChallengeList = [];
  List<EnrolledChallenge> enrolledChallenegeList = [];
  dynamic completeList = [];
  dynamic mergedList = [];
  List<EnrolledChallenge> completedChallenge = [];
  List<ChallengeDetail> allChallenegDetails = [];
  List<ChallengeDetail> allenrolledChallengeDetails = [];
  List<EnrolledChallenge> currentUserEnrolledChallenges = [];
  ChallengeDetail challengeDetails;
  EnrolledChallenge currentSelectedChallenge;
  dynamic newChallenges = [];
  String email, personalEmail;
  ChallengeApi challengeApi = ChallengeApi();
  int invitedEmailCount = 5;
  List affiliateCmpnyList = ["Global"];
  var userData;
  String userid;
  Timer gtimer;
  bool loading = true, challengeLoading = true;
  bool persistentInvite = false, ihlInvite = false;
  List<ChallengeDetail> completedChallengeDetails = [];
  GetChallengeCategory getChallengeCategoryList;

  Future inviteThroughEmailApiCall(String challengeID, referredbyname, refferredtoemail) async {
    if (invitedEmailCount <= 5) {
      var response = await ChallengeApi().inviteUserForChallenge(
          sendInviteUserForChallenge: SendInviteUserForChallenge(
              challangeId: challengeID,
              referredbyname: referredbyname,
              referredbyemail: email,
              refferredtoemail: refferredtoemail));
      return response;
    }
  }

  checkReferInviteCount(String challengeID) async {
    var response = await ChallengeApi()
        .challengeReferInviteCount(challangeId: challengeID, refer_by_email: email);
    if (response != null) {
      try {
        invitedEmailCount = 5 - int.parse(response);
        update(['inviteupdate']);
      } catch (e) {}
    }
  }

  @override
  void dispose() {
    print('ListController Dispost');
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Future<void> onInit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userData = prefs.get(SPKeys.userData);
    userid = prefs.getString("ihlUserId");
    var res = json.decode(userData);
    email = prefs.getString('email') ?? '';
    personalEmail = res['User']['personal_email'] ?? '';
    getAfilitaionName();
    allChallengeList();
    getChallengeCategoryFunc();
    // persistantBannerVisibleForUserInvitedThroughEmail();
    // gtimer = Timer.periodic(Duration(seconds: 10), (timer) async {
    //print('Timer');
    // getAfilitaionName();
    // await listOfChalleneg();
    // await enrolledChallenge();
    //  await filterChallenegList();
    // });
    super.onInit();
  }
  getChallengeCategoryFunc() async {
    getChallengeCategoryList =
    await ChallengeApi().getChallengeCategory();
    print('STATUS=======${getChallengeCategoryList.status}');
  }
  getAfilitaionName() async {
    userData = userData == null || userData == '' ? '{"User":{}}' : userData;
    Map res = jsonDecode(userData);
    Map affiliationList = res["User"]["user_affiliate"];
    if (affiliationList != null) {
      affiliateCmpnyList.clear();
      for (int i = 1; i <= affiliationList.length; i++) {
        affiliateCmpnyList.add(affiliationList['af_no$i']['affilate_unique_name']);
      }
    } else {
      affiliateCmpnyList.add("Global");
    }
    affiliateCmpnyList.forEach((element) => log(element.toString()));
    await listOfChalleneg();
  }

  listOfChalleneg() async {
    int pagination_start = 0;
    int pagination_end = 50;
    allChallenegeList = await challengeApi.listOfChallenges(
        challenge: ListChallenge(
            challenge_mode: " ",
            email: email,
            pagination_end: pagination_end,
            pagination_start: pagination_start,
            affiliation_list: affiliateCmpnyList));
    allChallenegeList.removeWhere((ele) => ele.challengeStatus != "active");
    allChallengeList();
    persistantChList = await challengeApi.listOfChallenges(
        challenge: ListChallenge(
            challenge_mode: " ",
            email: email,
            pagination_end: pagination_end,
            pagination_start: pagination_start,
            affiliation_list: persistentInvite ? [''] : ["persistent", "Persistent"]));
    if (runtypeChallengeList.length < 1)
      for (int i = 0; i < persistantChList.length; i++) {
        if (persistantChList[i].runtimeType != null &&
            persistantChList[i].challengeMode == 'individual' &&
            persistantChList[i].challengeUnit == 'km' &&
            persistantChList[i].challengeEndTime.isAfter(DateTime.now())) {
          runtypeChallengeList.add(persistantChList[i]);
        }
      }
    runtypeChallengeList.removeWhere((element) {
      if (!element.affiliations.contains('persistent') &&
          !element.affiliations.contains('Persistent')) {
        return true;
      }
      return false;
    });
    runtypeChallengeList
        .sort((a, b) => int.parse(a.targetToAchieve).compareTo(int.parse(b.targetToAchieve)));
    print(runtypeChallengeList.length);
    /* allChallenegeList.forEach((element) async {
      if (element.challengeRunType != null) {
        ChallengeDetail _challengeDetail =
            await challengeApi.challengeDetail(challengeId: element.challengeId);
        runtypeChallengeList.add(_challengeDetail);
      }
      print('Runtype ${runtypeChallengeList.length}');
    });*/
    //(allChallenegeList);
    //update(['loadingUpdate']);
    List<Challenge> ihlList = await challengeApi.listOfChallenges(
        challenge: ListChallenge(
            challenge_mode: " ",
            email: email,
            pagination_end: pagination_end,
            pagination_start: pagination_start,
            affiliation_list: ihlInvite ? [''] : ["ihl_care"]));
    ihlList.removeWhere((element) => element.challengeStatus != "active");
    if (runtypeIHLChallengeList.length < 1)
      for (int i = 0; i < ihlList.length; i++) {
        if (ihlList[i].runtimeType != null &&
            ihlList[i].challengeMode == 'individual' &&
            ihlList[i].challengeUnit == 'km' &&
            ihlList[i].affiliations.contains('ihl_care') &&
            ihlList[i].challengeEndTime.isAfter(DateTime.now())) {
          runtypeIHLChallengeList.add(ihlList[i]);
        }
      }
    runtypeIHLChallengeList
        .sort((a, b) => int.parse(a.targetToAchieve).compareTo(int.parse(b.targetToAchieve)));
    await enrolledChallenge();
  }

  enrolledChallenge() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    String userid = prefs1.getString("ihlUserId");
    //currentUserEnrolledChallenges.clear();
    currentUserEnrolledChallenges = await challengeApi.listofUserEnrolledChallenges(userId: userid);
    completedChallenge.clear();
    for (int i = 0; i < currentUserEnrolledChallenges.length; i++) {
      if (currentUserEnrolledChallenges[i].userProgress == "completed" ||
          currentUserEnrolledChallenges[i].groupProgress == "completed") {
        completedChallenge.add(currentUserEnrolledChallenges[i]);
      }
    }
    currentUserEnrolledChallenges.removeWhere(
        (element) => element.userProgress == "completed" || element.groupProgress == "completed");

    updateEnrolledChallenge();
    update();
    await filterChallenegList();
  }

  updateEnrolledChallenge() async {
    if (currentSelectedChallenge != null) {
      currentSelectedChallenge =
          await ChallengeApi().getEnrollDetail(currentSelectedChallenge.enrollmentId);
      update(['currentchallengeupdate']);
    }
  }

  filterChallenegList() async {
    for (int i = 0; i < currentUserEnrolledChallenges.length; i++) {
      if (allChallenegeList.length != 0) {
        for (int j = 0; j < allChallenegeList.length; j++) {
          if (currentUserEnrolledChallenges[i].challengeId == allChallenegeList[j].challengeId) {
            allChallenegeList.remove(allChallenegeList[j]);
            // update();
          }
        }
      }
    }
    if (completedChallenge != null) {
      for (int i = 0; i < completedChallenge.length; i++) {
        for (int j = 0; j < allChallenegeList.length; j++) {
          if (completedChallenge[i].challengeId == allChallenegeList[j].challengeId) {
            allChallenegeList.remove(allChallenegeList[j]);
          }
        }
      }
    }
    allChallenegeList.removeWhere((element) =>
        element.challengeEndTime.isBefore(now) &&
        (DateFormat('MM-dd-yyyy').format(element.challengeEndTime).toString() != "01-01-2000"));
    currentUserEnrolledChallenges.removeWhere((element) => element.userStatus == "deactive");
    mergedList.clear();
    mergedList.add(currentUserEnrolledChallenges);
    mergedList.add(allChallenegeList);

    completedChallenge.removeWhere((element) =>
        element.challenge_end_time.isBefore(now) &&
        (DateFormat('MM-dd-yyyy').format(element.challenge_end_time).toString() != "01-01-2000"));
    completedChallengeDetails.clear();
    for (int i = 0; i < completedChallenge.length; i++) {
      challengeDetails =
          await challengeApi.challengeDetail(challengeId: completedChallenge[i].challengeId);
      completedChallengeDetails.add(challengeDetails);
    }
    update();
    await challengeDetailsList();
  }

  persistantBannerVisibleForUserInvitedThroughEmail() async {
    var resp = await challengeApi.canCheckBanner(email: email);
    if (resp['persistant'].toString() == 'true' && resp['ihl_care'].toString() == 'true') {
      persistentInvite = true;
      ihlInvite = true;
    } else if (resp['ihl_care'].toString() == 'true') {
      ihlInvite = true;
    } else if (resp['persistant'].toString() == 'true') {
      persistentInvite = true;
    }
    update();
  }

  Future<ChallengeDetail> challengeDetailsList() async {
    List<EnrolledChallenge> challengeDetailEnrolled = mergedList[0];
    List<Challenge> challengeDetailAll = mergedList[1];
    challengeList.clear();
    for (int i = 0; i < challengeDetailEnrolled.length; i++) {
      challengeDetails =
          await challengeApi.challengeDetail(challengeId: challengeDetailEnrolled[i].challengeId);
      challengeList.add(challengeDetails);
    }
    for (int i = 0; i < challengeDetailAll.length; i++) {
      challengeDetails =
          await challengeApi.challengeDetail(challengeId: challengeDetailAll[i].challengeId);
      challengeList.add(challengeDetails);
    }

    challengeLoading = false;
    loading = false;
    update();
  }

  Future<ChallengeDetail> allChallengeList() async {
    List<Challenge> challenegList = [];
    allChallenegDetails.clear();
    allenrolledChallengeDetails.clear();
    int pagination_start = 0;
    int pagination_end = 50;
    enrolledChallenegeList.clear();
    enrolledChallenegeList = await challengeApi.listofUserEnrolledChallenges(userId: userid);
    challenegList = await challengeApi.listOfChallenges(
        challenge: ListChallenge(
            challenge_mode: " ",
            email: email,
            pagination_end: pagination_end,
            pagination_start: pagination_start,
            affiliation_list: affiliateCmpnyList));
    for (int i = 0; i < challenegList.length; i++) {
      challengeDetails =
          await challengeApi.challengeDetail(challengeId: challenegList[i].challengeId);
      allChallenegDetails.add(challengeDetails);
    }
    for (int i = 0; i < enrolledChallenegeList.length; i++) {
      challengeDetails =
          await challengeApi.challengeDetail(challengeId: enrolledChallenegeList[i].challengeId);
      allenrolledChallengeDetails.add(challengeDetails);
    }
    update();
  }
}
