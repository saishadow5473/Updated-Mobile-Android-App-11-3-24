import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import '../controllers/challenge_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/spKeys.dart';
import 'enrolled_challenge.dart';
import 'group_details_model.dart';
import 'listchallenge.dart';

class BadgesChallengeController extends GetxController {
  List affiliateCmpnyList = [];
  List<Badge> BadgesList = [];
  String email = '';
  String userid = '';
  var userData;
  int pagination_start = 0;
  int pagination_end = 50;
  var challenge;
  List<EnrolledChallenge> enrolledChallenge = [];
  bool follow = true;
  ChallengeApi challengeApi = ChallengeApi();

  @override
  void onInit() async {
    userEnrolledChal();
    follow = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString("ihlUserId");
    email = prefs.getString('email') ?? '';
    userData = prefs.get(SPKeys.userData);
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
    for (var element in affiliateCmpnyList) {
      log(element.toString());
    }
    await badgesList();
    update();
    // TODO: implement onInit
    super.onInit();
  }

  bool userEnrolled = false;
  List<EnrolledChallenge> currentUserEnrolledChallenges = [];

  userEnrolledChal() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    String userid = prefs1.getString("ihlUserId");
    await Future.delayed(const Duration(milliseconds: 500));
    currentUserEnrolledChallenges = await challengeApi.listofUserEnrolledChallenges(userId: userid);
    print('Enrolled challenges done');
    if (currentUserEnrolledChallenges.isNotEmpty) {
      userEnrolled = true;
    } else {
      userEnrolled = false;
    }
  }

  badgesList() async {
    ListBadges listbadges = ListBadges(
      affiliation_list: affiliateCmpnyList,
      user_id: userid,
      email: email,
      pagination_start: pagination_start,
      pagination_end: pagination_end,
    );

    BadgesList = await ChallengeApi().getApplicableBadgeChallenges(badges: listbadges);

    print('BadgesList done');
    // progressing test 🤍
    // BadgesList.add(Badge(
    //     challengeId: "hea_chal_5dfee881ecff42bfbe78a75c791deb87",
    //     challengeBadgeImgUrl: "progressing",
    //     challengeName: "TESTINGS MMM",
    //     enrollementStatus: "progressing"));
    if (BadgesList != null) {
      try {
        if (BadgesList.isNotEmpty) {
          for (Badge i in BadgesList) {
            i.challengeDetail = await ChallengeApi().challengeDetail(challengeId: i.challengeId);
          }
          SharedPreferences prefs1 = await SharedPreferences.getInstance();
          String userid = prefs1.getString("ihlUserId");
          enrolledChallenge = await ChallengeApi().listofUserEnrolledChallenges(userId: userid);
          print(enrolledChallenge);
          for (Badge i in BadgesList) {
            if (i.enrollementStatus == "notEnrolled") {
              print("Not enrolled in any challenges");
            } else {
              i.enrolledChallenge = enrolledChallenge.where((EnrolledChallenge element) {
                return element.challengeId == i.challengeId;
              }).first;
            }
          }
          for (Badge i in BadgesList) {
            if (i.enrolledChallenge != null &&
                i.enrolledChallenge.groupId != null &&
                i.enrolledChallenge.groupId != "") {
              GroupDetailModel gr =
                  await ChallengeApi().challengeGroupDetail(groupID: i.enrolledChallenge.groupId);
              i.enrolledChallenge.groupname = gr.groupName;
            }
          }
          follow = true;
          update();
        } else {
          BadgesList = [];
        }
      } catch (e) {
        print(e);
      }
    }
    update();
  }
}
