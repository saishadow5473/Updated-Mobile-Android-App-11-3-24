import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/health_challenge/models/create_group_challenge_model.dart';
import 'package:ihl/health_challenge/models/edit_group_challenge_model.dart';
import 'package:ihl/health_challenge/models/exit_group_challenge_model.dart';
import 'package:ihl/health_challenge/models/exit_individual_challenge_model.dart';
import 'package:ihl/health_challenge/models/join_group_model.dart';
import 'package:ihl/health_challenge/models/join_individual.dart';
import 'package:ihl/health_challenge/models/update_challenge_target_model.dart';
import 'package:ihl/health_challenge/persistent/models/persistent_screenshot_model.dart';
import 'package:ihl/views/dietJournal/models/get_frequent_food_consumed.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Getx/controller/google_fit_controller.dart';
import '../../new_design/commonData/common_controller.dart';
import '../models/GetChallengeCategory.dart';
import '/health_challenge/models/listchallenge.dart';
import '../models/challenge_video_gen_model.dart';
import '../models/selfie_image_upload_model.dart';
import '../models/sendInviteUserForChallengeModel.dart';

class NetworkCalls {
  final Dio dio = Dio();

  Future getAllChallenges({ListChallenge listChallenge}) async {
    try {
      var response = await dio.post(
        '${API.iHLUrl}/healthchallenge/list_health_challenge',
        data: listChallenge.toJson(),
      );
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }
  Future getChallengeCategory({GetChallengeCategory getChallengeCategory}) async {
    try {
      var response = await dio.get(
        '${API.iHLUrl}/healthchallenge/get_challenge_category',
      );
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }


  Future getChallengeDetail({String challengeId}) async {
    try {
      var response = await dio
          .get('${API.iHLUrl}/healthchallenge/get_challenge_detail?challengeId=$challengeId');

      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future geteditReminderChallengeDetail({String enrollmentId, String challengeId}) async {
    try {
      var response = await dio.get('${API.iHLUrl}/healthchallenge/edit_reminder_detail');

      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future get_applicable_badge_challenges({ListBadges listbadges}) async {
    dio.options.receiveTimeout = 15000;

    try {
      var response = await dio.post(
        '${API.iHLUrl}/healthchallenge/get_applicable_badge_challenges',
        data: listbadges.toJson(),
      );
      return response.data;
    } on DioError catch (error) {
      print(error);
      throw checkAndThrowError(error.type);
    }
  }

  Future joinGroup({JoinGroup joinGroup}) async {
    dio.options.receiveTimeout = 15000;

    try {
      var response = await dio.post('${API.iHLUrl}/healthchallenge/join_group_challenge',
          data: joinGroup.toJson());

      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future joinIndividual({JoinIndividual joinIndividual}) async {
    dio.options.receiveTimeout = 15000;
    try {
      var response = await dio.post(
        '${API.iHLUrl}/healthchallenge/join_individual_challenge',
        data: joinIndividual.toJson(),
      );
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getListOfGroups({String challengeId}) async {
    dio.options.receiveTimeout = 15000;
    try {
      var response = await dio
          .get('${API.iHLUrl}/healthchallenge/list_group_for_challenge?challenge_id=$challengeId');
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getListOfEnrolledUser({String challengeId}) async {
    dio.options.receiveTimeout = 15000;
    try {
      var response = await dio.get(
        '${API.iHLUrl}/healthchallenge/list_all_user_enrolled_challenge?challenge_id=$challengeId',
      );
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getListOfGroupUsers({String groupId}) async {
    try {
      var response =
          await dio.get('${API.iHLUrl}/healthchallenge/list_users_in_group?group_id=$groupId');

      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getListOfUserEnrolledChallenges({String userId}) async {
    dio.options.receiveTimeout = 35000;
    try {
      var response = await dio
          .get('${API.iHLUrl}/healthchallenge/user_enrolled_challenge_list?user_id=$userId');
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getCreateGroupChallenge({CreateGroupChallenge createGroupChallenge}) async {
    dio.options.receiveTimeout = 15000;
    try {
      var response = await dio.post('${API.iHLUrl}/healthchallenge/create_group_challenge',
          data: createGroupChallenge.toJson());
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getDeleteOrReactiveGroupChallenge({String groupID, groupStatus}) async {
    dio.options.receiveTimeout = 15000;
    try {
      String url =
          '${API.iHLUrl}/healthchallenge/delete_reactive_group_challenge?group_id=$groupID&status=$groupStatus';
      var response = await dio.get(url);
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getEditGroupchallenge({EditGroupChallenge editGroupChallenge}) async {
    dio.options.receiveTimeout = 15000;
    try {
      var response = await dio.post('${API.iHLUrl}/healthchallenge/edit_group_challenge',
          data: editGroupChallenge.toJson());
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future exitGroup({ExitGroupChallenge exitGroupChallenge}) async {
    dio.options.receiveTimeout = 15000;
    try {
      var response = await dio.post('${API.iHLUrl}/healthchallenge/exit_group_challenge',
          data: exitGroupChallenge.toJson());
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future exitIndividual({ExitIndividualChallenge exitIndividualChallenge}) async {
    dio.options.receiveTimeout = 15000;
    try {
      var response = await dio.post('${API.iHLUrl}/healthchallenge/exit_individual_challenge',
          data: exitIndividualChallenge.toJson());
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getEnrollDetail({String enrollChallengeId}) async {
    dio.options.receiveTimeout = 30000;
    try {
      var response = await dio.get(
        '${API.iHLUrl}/healthchallenge/get_enrolment_detail?enrollment_id=$enrollChallengeId',
      );
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getUpdateChallengeTarget({UpdateChallengeTarget updateChallengeTarget}) async {
    print(updateChallengeTarget.toJson());
    try {
      var response = await dio.post('${API.iHLUrl}/healthchallenge/update_challenge_target',
          data: updateChallengeTarget.toJson());
      try {
        if (getx.Get.currentRoute == "/OnGoingChallenge") {
          var _c = getx.Get.put(HealthRepository());
          _c.update([_c.widgetUpdate]);
        }
      } catch (e) {
        print(e);
      }
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getChallengeGroupDetail({String groupID}) async {
    dio.options.receiveTimeout = 15000;
    try {
      var response =
          await dio.get('${API.iHLUrl}/healthchallenge/challenge_group_detail?group_id=$groupID');
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getUserPhotoDataRetrive({String userUid}) async {
    // dio.options.receiveTimeout = 8000;
    try {
      var response = await dio.get(
        '${API.iHLUrl}/login/UserPhotoDataRetrive?id=$userUid',
        options: Options(
          headers: {'ApiToken': '${API.headerr['ApiToken']}', 'Token': '${API.headerr['Token']}'},
        ),
      );
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getChallengeUserNameCheck({String challengeID, name}) async {
    // dio.options.receiveTimeout = 8000;
    try {
      var response = await dio.get(
          "${API.iHLUrl}/healthchallenge/challenge_user_name_check?name=$name&challenge_id=$challengeID");
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future getChallengeReferInviteCount({String challengeID, refer_by_email}) async {
    // dio.options.receiveTimeout = 8000;
    try {
      var response = await dio.get(
          "${API.iHLUrl}/healthchallenge/challenge_refer_invite_count_check?challengeId=$challengeID&refer_by_email=$refer_by_email");
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future canCheckBanner({String email}) async {
    // dio.options.receiveTimeout = 8000;
    try {
      var response = await dio.get("${API.iHLUrl}/healthchallenge/can_banner_visible?email=$email");
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future sendInviteUserForChallenge({SendInviteUserForChallenge sendInviteUserForChallenge}) async {
    // dio.options.receiveTimeout = 8000;
    try {
      var response = await dio.post("${API.iHLUrl}/healthchallenge/challenge_refer_through_email",
          data: sendInviteUserForChallenge.toJson());
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future selfiUpload({SelfieImgUpload selfieImgUpload}) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${API.iHLUrl}/healthchallenge/healthchallengeimageupload'));
      request.fields.addAll({
        'enroll_id': selfieImgUpload.enrollId,
        'user_id': selfieImgUpload.userid,
        'challengeid': selfieImgUpload.challengeid
      });
      request.files.add(await http.MultipartFile.fromPath('', selfieImgUpload.selfieImage.path));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        return true;
      } else {
        print(response.reasonPhrase);
        return false;
      }
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future ssUploadScreeenShotPersistent(
      {PersistentUploadScreenShot persistentUploadScreenShot}) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${API.iHLUrl}/healthchallenge/challengedocupload'));
      request.fields.addAll({
        'enroll_id': persistentUploadScreenShot.enrollId,
        'user_id': persistentUploadScreenShot.userId,
        'challengeid': persistentUploadScreenShot.challengeid
      });
      request.files.add(
          await http.MultipartFile.fromPath('testimg', persistentUploadScreenShot.testimg.path));
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final decodedData = json.decode(await response.stream.bytesToString());
        print(decodedData);
        return true;
      } else {
        return false;
      }
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future selfieImageVideoGen({ChallengeVideoGenModel challengeVideoGenModel}) async {
    try {
      String containsAffi='IHL';
      var existingAffi;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ss= prefs.getString('sso_flow_affiliation');
      if(ss!=null){
        existingAffi = jsonDecode(ss);
      }
      FormData formData = FormData.fromMap({
        'img1': challengeVideoGenModel.img1,
        'img2': challengeVideoGenModel.img2,
        'img3': challengeVideoGenModel.img3,
        'img4': challengeVideoGenModel.img4,
        'img5': challengeVideoGenModel.img5,
        'img6': challengeVideoGenModel.img6,
        'img7': challengeVideoGenModel.img7,
        'img8': challengeVideoGenModel.img8,
        'img9': challengeVideoGenModel.img9,
        'img10': challengeVideoGenModel.img10,
        'img11': challengeVideoGenModel.img11,
        'first_name': challengeVideoGenModel.firstName,
        'last_name': challengeVideoGenModel.lastName,
        'run_name': challengeVideoGenModel.runName,
        'bib': challengeVideoGenModel.bib,
        'enrollment_id': challengeVideoGenModel.enrollmentId,
        'speed': challengeVideoGenModel.speed,
        'distance': challengeVideoGenModel.distance,
        'duration': challengeVideoGenModel.duration,
        'submit': challengeVideoGenModel.submit,
        'challenge_name':challengeVideoGenModel.challenge_name,
        'template_affiliation':challengeVideoGenModel.template_affiliation??"IHL"
      });
     if(existingAffi["affiliation_unique_name"].toString().contains('ihl')||existingAffi["affiliation_unique_name"].toString().contains('dev_testing'))
       {
         containsAffi ="IHL";
       }
     else
       {
         containsAffi ="Default";
       }
      var response = await dio.post(
          containsAffi=="IHL"?'http://xampp.indiahealthlink.com:9000/challenge_video_generator/IHL/process.php':
          'http://xampp.indiahealthlink.com:9000/challenge_video_generator/Default/process.php',
          data: formData,
          onSendProgress: (int send, int total) {});
      if (response.statusCode == 200) {
        print(await response.data);
        return response.data;
      } else {
        return await response.data;
      }
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future selfieImageData({String enroll_id}) async {
    // dio.options.receiveTimeout = 8000;
    try {
      var response = await dio.get(
          "${API.iHLUrl}/healthchallenge/healthchallengeimageuploaded_retrieval?enroll_id=$enroll_id");
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future sortedEnrolledList({String userUid}) async {
    // dio.options.receiveTimeout = 8000;
    try {
      var response = await dio
          .get("${API.iHLUrl}/healthchallenge/get_enrolment_challenge_list?user_id=$userUid");
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  Future userLoggedDetails({String enrolId, startDate, endDate}) async {
    // dio.options.receiveTimeout = 8000;
    try {
      var response = await dio.post("${API.iHLUrl}/healthchallenge/retrive_dynamic_challenge_logs",
          data: {"enrollment_id": "$enrolId", "start_date": "$startDate", "end_date": "$endDate"});
      return response.data;
    } on DioError catch (error) {
      throw checkAndThrowError(error.type);
    }
  }

  static checkAndThrowError(DioErrorType errorType) {
    switch (errorType) {
      case DioErrorType.sendTimeout:
        log('Send TimeOut');
        throw Exception('sendTimeout');
        break;
      case DioErrorType.receiveTimeout:
        log('Receive TimeOut');
        throw Exception('receiveTimeout');
        break;
      case DioErrorType.response:
        log('Error Response');
        throw Exception('response');
        break;
      case DioErrorType.cancel:
        log('Connection Cancel');
        throw Exception('cancel');
        break;
      case DioErrorType.other:
        log('Other Error');
        throw Exception('other');
        break;
      case DioErrorType.connectTimeout:
        log('Connect Timeout');
        throw Exception('connectTimeout');
        break;
    }
  }
}
