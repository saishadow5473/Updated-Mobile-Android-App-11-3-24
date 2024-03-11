import 'dart:developer';

import 'package:ihl/health_challenge/models/GetChallengeCategory.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/challenge_enrolled_usermodel.dart';
import 'package:ihl/health_challenge/models/challengemodel.dart';
import 'package:ihl/health_challenge/models/create_group_challenge_model.dart';
import 'package:ihl/health_challenge/models/edit_group_challenge_model.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/health_challenge/models/exit_group_challenge_model.dart';
import 'package:ihl/health_challenge/models/exit_individual_challenge_model.dart';
import 'package:ihl/health_challenge/models/group_details_model.dart';
import 'package:ihl/health_challenge/models/group_model.dart';
import 'package:ihl/health_challenge/models/join_group_model.dart';
import 'package:ihl/health_challenge/models/join_individual.dart';
import 'package:ihl/health_challenge/models/list_of_users_in_group.dart';
import 'package:ihl/health_challenge/models/listchallenge.dart';
import 'package:ihl/health_challenge/models/sorted_enrolled_challenge_model.dart';
import 'package:ihl/health_challenge/models/update_challenge_target_model.dart';
import 'package:ihl/health_challenge/networks/network_calls.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/challenge_video_gen_model.dart';
import '../models/get_enrolment_challenge_model.dart';
import '../models/get_selfie_image_model.dart';
import '../models/selfie_image_upload_model.dart';
import '../models/sendInviteUserForChallengeModel.dart';
import '../persistent/models/persistent_screenshot_model.dart';

class ChallengeApi {
  Future<List<Challenge>> listOfChallenges({ListChallenge challenge}) async {
    // Get a list of all the challenges from the NetworkCalls class
    var response = await NetworkCalls().getAllChallenges(listChallenge: challenge);
    // Create a list from the response
    List list = response;
    // Map each item in the list to a Challenge object and return the list as a list of Challenges
    return list.map((item) => Challenge.fromJson(item)).toList();
  }
  Future<GetEnrolmentChallengeList> getSortedEnrolledList({String userid}) async {
    // Get a list of all the challenges from the NetworkCalls class
    var response = await NetworkCalls().sortedEnrolledList(userUid: userid);
    // Create a list from the response
    // List list = response;
    // Map each item in the list to a Challenge object and return the list as a list of Challenges
    return GetEnrolmentChallengeList.fromJson(response);
  }
  Future<GetChallengeCategory> getChallengeCategory() async {
    // Get a list of all the getChallengeCategory from the NetworkCalls class
    var response = await NetworkCalls().getChallengeCategory();
    // Create a list from the response
    List<dynamic> list = response['status'];
    // Map each item in the list to a getChallengeCategory object and return the list as a list of Challenges
    // list.map((e) => GetChallengeCategory.fromJson(e)).toList();
    return GetChallengeCategory.fromJson(response);
  }

  // healthchallenge/get_applicable_badge_challenges
  Future getApplicableBadgeChallenges({ListBadges badges}) async {
    var response = await NetworkCalls().get_applicable_badge_challenges(listbadges: badges);
    List list = response['status'];
    try {
      return list.map((e) => Badge.fromJson(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<ChallengeDetail> challengeDetail({String challengeId}) async {
    var response = await NetworkCalls().getChallengeDetail(challengeId: challengeId);
    return ChallengeDetail.fromJson(response['challenge_data']);
  }

  Future<List<GroupModel>> listOfGroups({String challengeId}) async {
    var response = await NetworkCalls().getListOfGroups(challengeId: challengeId);
    List list = response;
    return list.map((group) => GroupModel.fromJson(group)).toList();
  }

  Future<bool> userJoinGroup({JoinGroup joinGroup}) async {
    var response = await NetworkCalls().joinGroup(joinGroup: joinGroup);
    if (response['status'] == 'success') {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> userJoinIndividual({JoinIndividual joinIndividual}) async {
    print(joinIndividual.toJson());
    var response = await NetworkCalls().joinIndividual(joinIndividual: joinIndividual);
    if (response['status'] == 'success') {
      return true;
    } else {
      return false;
    }
  }

  Future<List<GroupUser>> listofGroupUsers({String groupId}) async {
    var response = await NetworkCalls().getListOfGroupUsers(groupId: groupId);
    List list = response;
    return list.map((group) => GroupUser.fromJson(group)).toList();
  }

  Future<List<EnrolledUser>> listofEnrolledUsers({String challengeId}) async {
    var response = await NetworkCalls().getListOfEnrolledUser(challengeId: challengeId);
    List list = response;
    return list.map((group) => EnrolledUser.fromJson(group)).toList();
  }

  Future<List<EnrolledChallenge>> listofUserEnrolledChallenges({String userId}) async {
    var response = await NetworkCalls().getListOfUserEnrolledChallenges(userId: userId);
    List list = response;
    return list.map((group) => EnrolledChallenge.fromJson(group)).toList();
  }

  Future<String> createGroupChallenge({CreateGroupChallenge createGroupChallenge}) async {
    var response =
        await NetworkCalls().getCreateGroupChallenge(createGroupChallenge: createGroupChallenge);
    if (response['status'] == 'success') {
      return 'success';
    } else {
      return response['status'];
    }
  }

  Future<bool> deleteOrReactiveChallenge({String groupID, groupStatus}) async {
    var response = await NetworkCalls()
        .getDeleteOrReactiveGroupChallenge(groupID: groupID, groupStatus: groupStatus);
    if (response['status'] == 'success') {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> editGroupChallenge({EditGroupChallenge editGroupChallenge}) async {
    var response =
        await NetworkCalls().getEditGroupchallenge(editGroupChallenge: editGroupChallenge);
    if (response['status'] == 'success') {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> userExitGroup({ExitGroupChallenge exitGroupChallenge}) async {
    var response = await NetworkCalls().exitGroup(exitGroupChallenge: exitGroupChallenge);
    if (response['status'] == 'success') {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> userExitIndividual({ExitIndividualChallenge exitIndividualChallenge}) async {
    var response =
        await NetworkCalls().exitIndividual(exitIndividualChallenge: exitIndividualChallenge);
    if (response['status'] == 'success') {
      return true;
    } else {
      return false;
    }
  }

  Future<EnrolledChallenge> getEnrollDetail(String enrollId) async {
    var response = await NetworkCalls().getEnrollDetail(enrollChallengeId: enrollId);
    return EnrolledChallenge.fromJson(response[0]);
  }

  Future<bool> updateChallengeTarget({UpdateChallengeTarget updateChallengeTarget}) async {
    log('updateChallengeTarget ${updateChallengeTarget.enrollmentId} ${updateChallengeTarget.progressStatus} ${updateChallengeTarget.achieved}');
    var _enroll = await ChallengeApi().getEnrollDetail(updateChallengeTarget.enrollmentId);
    if (_enroll.userProgress != 'completed') {
      var response = await NetworkCalls()
          .getUpdateChallengeTarget(updateChallengeTarget: updateChallengeTarget);
      if (response['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } else {
      print('Already Completed from Network Calls');
      return true;
    }
  }

  //getChallengeGroupDetail
  Future<GroupDetailModel> challengeGroupDetail({String groupID}) async {
    var response = await NetworkCalls().getChallengeGroupDetail(groupID: groupID);
    return GroupDetailModel.fromJson(response);
  }

  Future<String> userPhotoDataRetrive({String userUid}) async {
    var response = await NetworkCalls().getUserPhotoDataRetrive(userUid: userUid);
    return response.toString();
  }

  Future challengeUserNameCheck({String challangeId, name}) async {
    var response =
        await NetworkCalls().getChallengeUserNameCheck(name: name, challengeID: challangeId);
    return response;
  }

  Future canCheckBanner({String email}) async {
    var response = await NetworkCalls().canCheckBanner(email: email);
    return response;
  }

  Future challengeReferInviteCount({String challangeId, refer_by_email}) async {
    var response = await NetworkCalls()
        .getChallengeReferInviteCount(challengeID: challangeId, refer_by_email: refer_by_email);
    return response;
  }

  Future inviteUserForChallenge({SendInviteUserForChallenge sendInviteUserForChallenge}) async {
    var response = await NetworkCalls()
        .sendInviteUserForChallenge(sendInviteUserForChallenge: sendInviteUserForChallenge);
    return response;
  }

  Future<bool> putUploadSelfie({SelfieImgUpload selfieImgUpload}) async {
    bool response = await NetworkCalls().selfiUpload(selfieImgUpload: selfieImgUpload);
    return response;
  }

  Future<bool> putScreenShotUploadPersistent(
      {PersistentUploadScreenShot persistentUploadScreenShot}) async {
    bool response = await NetworkCalls()
        .ssUploadScreeenShotPersistent(persistentUploadScreenShot: persistentUploadScreenShot);
    return response;
  }

  Future<List<SelifeImageData>> getSelfieImageData({String enroll_id}) async {
    List response = await NetworkCalls().selfieImageData(enroll_id: enroll_id);
    return response.map((e) => SelifeImageData.fromJson(e)).toList();
  }

  Future genVideoWithSelfieImage({ChallengeVideoGenModel challengeVideoGenModel}) async {
    var response =
        await NetworkCalls().selfieImageVideoGen(challengeVideoGenModel: challengeVideoGenModel);
    return response;
  }

  Future getSortedErList({String userUid}) async {
    var response = await NetworkCalls().sortedEnrolledList(userUid: userUid);
    return SortedErChallenge.fromJson(response);
  }

  Future getLogUserDetails({
    String enrolId,
    DateTime startDate,
  }) async {
    var _dateFormat = DateFormat('MM/dd/yyyy HH:mm:ss');
    var response = await NetworkCalls().userLoggedDetails(
        enrolId: enrolId,
        startDate: _dateFormat.format(startDate),
        endDate: _dateFormat.format(DateTime.now()));
    if (response.toString().contains("error_message")) {
      return [];
    } else {
      return response;
    }
  }
}
