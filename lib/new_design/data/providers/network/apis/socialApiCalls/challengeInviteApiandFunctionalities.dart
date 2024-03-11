// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:ihl/health_challenge/models/challenge_detail.dart';
// import 'package:ihl/new_design/data/model/loginModel/userDataModel.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../../../../../health_challenge/controllers/challenge_api.dart';
// import '../../../../../../health_challenge/models/enrolled_challenge.dart';
// import '../../../../../../health_challenge/models/sendInviteUserForChallengeModel.dart';
// import '../../../../model/SocialdashboardModels/affiliationFlagModel.dart';

// class ChallengeInviteAndFunctions {
//   // Invite Variables 🥥
//   static RegExp emailRegExp =
//       RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
//   // static ValueNotifier<int> invitedEmailCount = ValueNotifier<int>(0);
//   static TextEditingController sendInviteEmailController = TextEditingController();

//   //Affiliation Related Variables
//   static List<AfNo> affiliations = [];

//   //Functions that holds the invite option and invite count enable and disable 🥥
//   // inviteThroughEmailApiCall({String challengeID, referredbyname, refferredtoemail, index,totalInvite}) async {
//   //   if (ChallengeInviteAndFunctions.invitedEmailCountlist[ <= 5) {
//   //     SharedPreferences prefs1 = await SharedPreferences.getInstance();
//   //     String userEmail = prefs1.getString("email");
//   //     var response = await ChallengeApi().inviteUserForChallenge(
//   //         sendInviteUserForChallenge: SendInviteUserForChallenge(
//   //             challangeId: challengeID,
//   //             referredbyname: referredbyname,
//   //             referredbyemail: userEmail,
//   //             refferredtoemail: refferredtoemail));
//   //     if (response == "invite success") {
//   //       ChallengeInviteAndFunctions.invitedEmailCountlist[index].value =
//   //           ChallengeInviteAndFunctions.invitedEmailCountlist[index].value - 1;
//   //       sendInviteEmailController.clear();
//   //       checkReferInviteCount(challengeID);
//   //       Get.back();
//   //       toastMessageAlert("Invited Successfully!!");
//   //     } else if (response == "already invited") {
//   //       toastMessageAlert("Email already invited");
//   //     } else if (response == "failed") {
//   //       toastMessageAlert("Invite send failed");
//   //     }
//   //   } else {
//   //     toastMessageAlert("Already invited 5 members!!");
//   //   }
//   // }

//   static toastMessageAlert(String message) {
//     Fluttertoast.showToast(
//         msg: message,
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.SNACKBAR,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.grey,
//         textColor: Colors.white,
//         fontSize: 16.0);
//   }

//   Future<ValueNotifier<int>> checkReferInviteCount(String challengeID) async {
//     SharedPreferences prefs1 = await SharedPreferences.getInstance();
//     String userEmail = prefs1.getString("email");
//     var response = await ChallengeApi()
//         .challengeReferInviteCount(challangeId: challengeID, refer_by_email: userEmail);
//     if (response != null) {
//       try {
//         int i = 0;
//         i = 5 - int.parse(response);
//         // i = invitedEmailCount.value;
//         log("invite count for this challenge => ${i}");
//         return ValueNotifier(i);
//         // invitedEmailCount.notifyListeners();
//       } catch (e) {
//         log("invite Count had some issue");
//       }
//     }
//   }

//   //Functions that holds enrolled challenges list,🥥
//   //checking flag and validation for the challenge 🥥
//   // static listofUserEnrolledChallengesgetter() async {
//   //   SharedPreferences prefs1 = await SharedPreferences.getInstance();
//   //   String userid = prefs1.getString("ihlUserId");
//   //   List<EnrolledChallenge> enrolChallengeList =
//   //       await ChallengeApi().listofUserEnrolledChallenges(userId: userid);
//   //   enrolChallengeList.removeWhere((e) =>
//   //       e.userProgress.toString().toLowerCase() == "completed" ||
//   //       e.groupProgress.toString().toLowerCase() == "completed");
//   //   enrolChallengeList.removeWhere((e) => e.challenge_end_time.isBefore(DateTime.now()));
//   //   List<ChallengeDetail> listOfChallengeDetail = [];
//   //   for (EnrolledChallenge e in enrolChallengeList) {
//   //     listOfChallengeDetail.add(await ChallengeApi().challengeDetail(challengeId: e.challengeId));
//   //   }
//   //   listOfChallengeDetail.removeWhere((e) => e.is_challenge_banner_visible == false);
//   //   List<AffiliationFlagModel> affiliationFlagModel = [];
//   //   if (ChallengeInviteAndFunctions.affiliations.length != 0) {
//   //     for (int i = 0; i < ChallengeInviteAndFunctions.affiliations.length; i++) {
//   //       affiliationFlagModel.add(AffiliationFlagModel(
//   //           data: [],
//   //           affiliationName: ChallengeInviteAndFunctions.affiliations[i].affilateUniqueName));
//   //     }
//   //   }
//   //   if (affiliationFlagModel.length != 0) {
//   //     for (AffiliationFlagModel ee in affiliationFlagModel) {
//   //       listOfChallengeDetail.map((e) {
//   //         if (e.affiliations.contains(ee.affiliationName)) {
//   //           int i = affiliationFlagModel.indexWhere((element) {
//   //             return e.affiliations.contains(element.affiliationName);
//   //           });
//   //           affiliationFlagModel[i].data.add(e);
//   //         }
//   //       }).toList();
//   //     }
//   //     affiliationFlagModel.removeWhere((element) => element.data.isEmpty);
//   //     for (AffiliationFlagModel ee in affiliationFlagModel) {
//   //       invitedEmailCountlist.add(
//   //           await ChallengeInviteAndFunctions().checkReferInviteCount(ee.data.first.challengeId));
//   //     }
//   //     // for(ValueNotifier<int> notifyer in invitedEmailCountlist){

//   //     // }
//   //   }
//   //   return affiliationFlagModel;
//   // }
// }
