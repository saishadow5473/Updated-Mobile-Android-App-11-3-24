// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, missing_return, unnecessary_statements, non_constant_identifier_names
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../new_design/presentation/pages/basicData/models/basic_data.dart';
import '../constants/api.dart';
import '../constants/spKeys.dart';
import '../models/models.dart';
import '../new_design/app/utils/localStorageKeys.dart';
import '../new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../new_design/presentation/pages/basicData/functionalities/percentage_calculations.dart';
import '../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../new_design/presentation/pages/profile/updatePhoto.dart';
import '../utils/SpUtil.dart';
import 'getuserData.dart';

class Apirepository {
  final http.Client _client = http.Client(); //3gb
  final String iHLUrl = API.iHLUrl;
  final String ihlToken = API.ihlToken;
  BasicDataModel basicData;

  Future<void> deleteToken() async {
    /// delete from keystore/keychain
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  Future<bool> hasToken() async {
    /// read from keystore/keychain
    await Future.delayed(const Duration(seconds: 1));
    return false;
  }

  Future logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await localSotrage.erase();
    return prefs.clear();
  }

  String apikey;

  Future<String> authenticate({String username, String password}) async {
    final http.Response response = await _client.get(
      Uri.parse('$iHLUrl/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Login student = Login.fromJson(json.decode(response.body));
      apikey = student.apiToken;
      final http.Response response1 = await _client.post(
        Uri.parse('$iHLUrl/login/qlogin2'),
        headers: {
          'Content-Type': 'application/json',
          'Token': 'bearer ',
          'ApiToken': student.apiToken
        },
        body: jsonEncode(<String, String>{
          'email': username,
          'password': password,
        }),
      );
      if (response1.statusCode == 200) {
        if (response1.body == 'null') {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('data', '');
        } else {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('data', response1.body);
          var decodedResponse = jsonDecode(response1.body);
          String iHLUserToken = decodedResponse['Token'];
          String iHLUserId = decodedResponse['User']['id'];

          final http.Response vitalData = await _client.get(
            Uri.parse('$iHLUrl/data/user/$iHLUserId/checkin'),
            headers: {
              'Content-Type': 'application/json',
              'Token': iHLUserToken,
              'ApiToken': student.apiToken
            },
          );
          if (vitalData.statusCode == 200) {
            final SharedPreferences sharedUserVitalData = await SharedPreferences.getInstance();
            sharedUserVitalData.setString('userVitalData', vitalData.body);
          } else {
            throw Exception('No Vital Data for this user');
          }
          return (response1.body);
        }
      } else {
        throw Exception('Authorization Failed');
      }
    } else {
      throw Exception('Failed to get API Key');
    }
  }

  String apiToken;

  Future<String> userExist({String email}) async {
    final http.Response response = await _client.get(
      Uri.parse('$iHLUrl/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(response.body));
      apiToken = reponseToken.apiToken;
      final http.Response userExits = await _client.get(
        Uri.parse('$iHLUrl/login/emailormobileused?email=$email&mobile=&aadhaar='),
        headers: {'ApiToken': reponseToken.apiToken},
      );
      if (userExits.statusCode == 200) {
        String userExistResponse = userExits.body.replaceAll(RegExp(r'[^\w\s]+'), '');
        if (userExistResponse == "You never registered with this Email ID") {
          return userExistResponse;
        } else {
          String userExistResponse = "User already exist";
          return userExistResponse;
        }
      } else {
        throw Exception('Authorization Failed');
      }
    }
  }

  Future<String> registerUser(
      {String firstName,
      String lastName,
      String email,
      String password,
      String mobileNumber,
      String gender,
      String dob,
      String height,
      String weight,
      String profilepic}) async {
    String jsontext =
        '{"user":{"email":"$email", "mobileNumber":$mobileNumber, "userInputWeightInKG":"$weight", "firstName":"$firstName", "lastName":"$lastName", "aadhaarNumber":"", "dateOfBirth":"$dob", "gender":"$gender", "heightMeters":"$height", "fingerprint":"","terms":{"termsFileName":"termsofuse_v9_01122016"},"privacyAgreed":{"privacyFileName":"privacypolicy_v7_08112014"}},"password":"$password","encryptionVersion":null}';

    final http.Response auth_response = await _client.get(
      Uri.parse('$iHLUrl/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (auth_response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(auth_response.body));
      apiToken = reponseToken.apiToken;

      final http.Response response = await _client.put(
        Uri.parse('$iHLUrl/data/user'),
        body: jsontext,
        headers: {'ApiToken': apiToken},
      );
      if (response != null) {
        final http.Response loginResponse = await _client.post(
          Uri.parse('$iHLUrl/login/qlogin2'),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken':
                "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'password': password,
          }),
        );
        if (loginResponse.statusCode == 200) {
          if (loginResponse.body == 'null') {
          } else {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('data', loginResponse.body);
            var decodedResponse = jsonDecode(loginResponse.body);
            Login reponseToken = Login.fromJson(json.decode(loginResponse.body));
            apikey = reponseToken.apiToken;
            String iHLUserToken = decodedResponse['Token'];
            String iHLUserId = decodedResponse['User']['id'];
            final http.Response userProfileImage = await _client.post(
              Uri.parse('$iHLUrl/data/user/$iHLUserId/photo'),
              headers: {
                'Content-Type': 'application/json',
                'Token': iHLUserToken,
                'ApiToken': apikey,
                'Accept': 'application/json'
              },
              body: jsonEncode(<String, String>{'photo_data': profilepic}),
            );
            if (userProfileImage.statusCode == 200) {
            } else {
              throw Exception('Photo upload Failed');
            }
            return (loginResponse.body);
          }
        }
      } else {
        throw Exception('failed');
      }
    } else {
      print('Fetching Auth Token failed');
    }
  }

  Future<String> userProfileEditAPI(
      {String firstName,
      String lastName,
      String email,
      String mobileNumber,
      String gender,
      String dob,
      String height,
      String weight,
      String userAffliation,
      String address,
      String area,
      String city,
      String state,
      String pincode,
      bool isTeleMedPolicyAgreed}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Object userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    String iHLUserToken = decodedResponse['Token'];
    String iHLUserId = decodedResponse['User']['id'];
    // String apikey = API.headerr['ApiToken'];
    String apikey = SpUtil.getString(LSKeys.apiToken);
    if (apikey.toString() == "") {
      Object tkn = apikey = prefs.get('auth_token');
      if (tkn.toString().length > 4) {
        apikey = tkn;
      } else {
        apikey =
            '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
        API.headerr['ApiToken'] =
            '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
      }
    }
    // String apikey = prefs.get('auth_token');
    String jsontext =
        '{"email": "$email","mobileNumber": "$mobileNumber","dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","firstName": "$firstName","encryptionVersion":null,"lastName": "$lastName","userInputWeightInKG": "$weight","affiliate": "$userAffliation","address": "$address","area": "$area","city": "$city","state": "$state","pincode": "$pincode","isTeleMedPolicyAgreed": "$isTeleMedPolicyAgreed"}';
    try {
      final http.Response userProfileEditAPIResponse = await _client.post(
        Uri.parse('$iHLUrl/data/user/$iHLUserId'),
        headers: {'Content-Type': 'application/json', 'ApiToken': apikey, 'Token': iHLUserToken},
        body: jsontext,
      );
      if (userProfileEditAPIResponse.statusCode == 200) {
        String extractedResponseMessage =
            userProfileEditAPIResponse.body.replaceAll(RegExp(r'[^\w\s]+'), '');
        if (extractedResponseMessage == "updated") {
          Object password = prefs.get(SPKeys.password);

          Object email = prefs.get(SPKeys.email);

          http.Response response1;
          bool isSSO = SpUtil.getBool('isSSoUser');
          if (isSSO ?? false) {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            Object userData = prefs.get('data');
            var decodedResponse = jsonDecode(userData);
            var userId = decodedResponse['User']['id'];
            http.Response resp;
            resp = await _client.post(
              Uri.parse('${API.iHLUrl}/login/get_user_login'),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken':
                    "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA=="
              },
              body: jsonEncode({"id": userId}),
            );
            response1 = resp;
          } else {
            response1 = await _client.post(
              Uri.parse('$iHLUrl/login/qlogin2'),
              body: jsonEncode(<String, String>{
                'email': email,
                'password': password,
              }),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken':
                    "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
              },
            );
          }

          if (response1.statusCode == 200) {
            Map<String, dynamic> decode = jsonDecode(response1.body);

            log(decode.toString());

            try {
              await MyvitalsApi().vitalDatas(decode);
            } catch (e) {
              print(e);
            }

            try {
              basicData = BasicDataModel(
                name: '${decode['User']['firstName']} ${decode['User']['lastName']}',
                dob: decode['User'].containsKey('dateOfBirth')
                    ? decode['User']['dateOfBirth'].toString()
                    : null,
                gender: decode['User'].containsKey('gender')
                    ? decode['User']['gender'].toString()
                    : null,
                height: decode['User'].containsKey("heightMeters")
                    ? decode['User']["heightMeters"].toString()
                    : null,
                mobile: decode['User'].containsKey("mobileNumber")
                    ? decode['User']['mobileNumber'].toString()
                    : null,
                weight: decode['User'].containsKey("userInputWeightInKG")
                    ? decode['User']['userInputWeightInKG'].toString()
                    : null,
              );

              final GetStorage box = GetStorage();

              box.write('BasicData', basicData);

              BasicDataModel b = box.read('BasicData');

              print(b);

              PercentageCalculations().checkHowManyFilled();

              PercentageCalculations().calculatePercentageFilled();

              GetData updateData = GetData();

              //   bool resp = await updateData.uptoUserInfoDate();
            } catch (e) {
              print(e);
            }
            return (extractedResponseMessage);
          } else {
            throw Exception('Failed in updating user profile');
          }
        } else {
          throw Exception('Authorization Failed${userProfileEditAPIResponse.statusCode}');
        }
      }
    } catch (e) {
      print(e);
      throw Exception('Failed');
    }
  }

  Future<String> userProfileEditAPIWithoutEmailMobile(
      {String firstName,
      String lastName,
      String email,
      String mobileNumber,
      String gender,
      String dob,
      String height,
      String weight,
      String userAffliation,
      String address,
      String area,
      String city,
      String state,
      String pincode,
      bool isTeleMedPolicyAgreed}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Object userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    String iHLUserToken = decodedResponse['Token'];
    String iHLUserId = decodedResponse['User']['id'];
    String apikey = prefs.get('auth_token');
    String jsontext =
        '{"email": "$email","mobileNumber": "$mobileNumber","dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","firstName": "$firstName","encryptionVersion":null,"lastName": "$lastName","userInputWeightInKG": "$weight","affiliate": "$userAffliation","address": "$address","area": "$area","city": "$city","state": "$state","pincode": "$pincode","isTeleMedPolicyAgreed": "$isTeleMedPolicyAgreed"}';
    try {
      final http.Response userProfileWithoutEmailMobileEditAPIResponse = await _client.post(
        Uri.parse('$iHLUrl/data/user/$iHLUserId'),
        headers: {'Content-Type': 'application/json', 'ApiToken': apikey, 'Token': iHLUserToken},
        body: jsontext,
      );
      if (userProfileWithoutEmailMobileEditAPIResponse.statusCode == 200) {
        String extractedResponseMessage =
            userProfileWithoutEmailMobileEditAPIResponse.body.replaceAll(RegExp(r'[^\w\s]+'), '');
        if (extractedResponseMessage == "updated") {
          return (extractedResponseMessage);
        } else {
          throw Exception('Failed in updating user profile');
        }
      } else {
        throw Exception(
            'Authorization Failed${userProfileWithoutEmailMobileEditAPIResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed');
    }
  }

  Future<String> userProfileResetPasswordAPI(
      {String email, String password, String newPassword}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Object userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    String apikey = prefs.get('auth_token');
    String iHLUserToken = decodedResponse['Token'];
    String jsontext = '{"password":"$newPassword","email":"$email","oldPassword":"$password"}';

    try {
      final http.Response userProfilePasswordResetAPIResponse = await _client.post(
        Uri.parse('$iHLUrl/login/changepassword'),
        headers: {'Content-Type': 'application/json', 'ApiToken': apikey, 'Token': iHLUserToken},
        body: jsontext,
      );
      if (userProfilePasswordResetAPIResponse.statusCode == 200) {
        String extractedResponseMessage =
            userProfilePasswordResetAPIResponse.body.replaceAll(RegExp(r'[^\w\s]+'), '');
        prefs.setString('password', newPassword);
        return (extractedResponseMessage);
      } else {
        throw Exception('Authorization Failed${userProfilePasswordResetAPIResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed');
    }
  }

  Future<String> userProfileDeleteAPI({String email, String password}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Object userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    String iHLUserToken = decodedResponse['Token'];
    String iHLUserId = decodedResponse['User']['id'];
    String authToken = prefs.get('auth_token');
    final http.Response userProfileDeleteAPIResponse = await _client.delete(
      Uri.parse(
          iHLUrl + '/login/user/' + iHLUserId + "/emailormobile/" + email + "/pass/" + password),
      headers: {
        // 'Content-Type': 'application/json',
        'ApiToken': authToken,
        'Token': iHLUserToken
      },
    );
    if (userProfileDeleteAPIResponse.statusCode == 200) {
      String extractedResponseMessage =
          userProfileDeleteAPIResponse.body.replaceAll(RegExp(r'[^\w\s]+'), '');
      return (extractedResponseMessage);
    } else {
      throw Exception('Authorization Failed${userProfileDeleteAPIResponse.statusCode}');
    }
  }

  // Forgot Password API
  Future<String> forgotPassword({String email}) async {
    final http.Response forgotPasswordAPI = await _client.get(
      Uri.parse('$iHLUrl/login/passreset?email=$email'),
      headers: {
        'ApiToken': apikey,
      },
    );
    if (forgotPasswordAPI.statusCode == 200) {
      String forgotPasswordAPIResponse = forgotPasswordAPI.body.replaceAll(RegExp(r'[^\w\s]+'), '');
      if (forgotPasswordAPIResponse == "success") {
      } else {
        throw Exception('Generating new passoword failed');
      }
    }
  }

  // Profile Image Upload API . Provide base64 format of the image as input
  //not using anymore this function
  //as we written this function below by using dio
  Future _profileImageUpload(String base64ProfileImage) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Object authToken = prefs.get('auth_token');
    Object userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    String iHLUserToken = decodedResponse['Token'];
    String iHLUserId = decodedResponse['User']['id'];
    DateTime d1, d2;
    d1 = DateTime.now();
    final http.Response userProfileImage = await _client.post(
      Uri.parse('$iHLUrl/data/user/$iHLUserId/photo'),
      headers: {
        'Content-Type': 'application/json',
        'Token': iHLUserToken,
        'ApiToken': authToken,
        'Accept': 'application/json'
      },
      body: jsonEncode(<String, String>{'photo_data': base64ProfileImage}),
    );
    if (userProfileImage.statusCode == 200) {
      d2 = DateTime.now();
    } else {
      throw Exception('Photo upload Failed');
    }
  }

  // dio package used for - // Profile Image Upload API...
  profileImageUpload(String base64ProfileImage) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      Object authToken = prefs.get('auth_token');
      Object userData = prefs.get('data');
      var decodedResponse = jsonDecode(userData);
      String iHLUserToken = decodedResponse['Token'];
      String iHLUserId = decodedResponse['User']['id'];
      DateTime d1, d2;
      d1 = DateTime.now();
      BaseOptions options = BaseOptions(
        baseUrl: iHLUrl,
        connectTimeout: 20000,
        receiveTimeout: 20000,
      );
      Dio dio = Dio(options);
      try {
        Response userProfileImage = await dio.request(
          '/data/user/$iHLUserId/photo',
          data: jsonEncode(<String, String>{'photo_data': base64ProfileImage}),
          options: Options(
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Token': iHLUserToken,
              'ApiToken': authToken,
              'Accept': 'application/json'
            },
          ),
        );
        if (userProfileImage.statusCode == 200) {
          // PhotoChangeNotifier.photo.notifyListeners();
          return 'true';
          // return 'Connection Timeout Please try again later';
        } else {
          // throw Exception('Photo upload Failed');
          return 'Photo upload Failed';
        }
      } on DioError catch (e) {
        print(e);
        if (e.type == DioErrorType.connectTimeout) {
          // throw Exception('Photo upload Failed\nConnection Timeout');
          return 'Slow Internet Please Try again later';
        }
        if (e.type == DioErrorType.receiveTimeout) {
          debugPrint("receiveTimeout");
          // throw Exception('Photo upload Failed\nConnection Timeout');
          return 'Connection Timeout Please try Again later';
        }
        if (e.message != null) {
          debugPrint(e.message);
          // throw Exception('Photo upload Failed\nTry again later');
          return 'Photo upload Failed Try again later';
        }
      }
    } catch (e) {
      print('Faild =>update profile API' + e);
      // throw Exception('Photo upload Failed');
      return 'Photo upload Failed';
    }
  }

  // Health Survey Submit Answer API

  Future submitAnswerHealthSurveyAPI(String answer) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Object userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    String iHLUserToken = decodedResponse['Token'];
    String iHLUserId = decodedResponse['User']['id'];
    final http.Response submitAnswerAPI = await _client.post(
      Uri.parse('$iHLUrl/login/submit_answers?id=$iHLUserId'),
      headers: {
        'Content-Type': 'application/json',
        'Token': 'bearer $iHLUserToken',
        'ApiToken': apikey
      },
      body: jsonEncode(<String, String>{'QB3': 'never'}),
    );
    if (submitAnswerAPI.statusCode == 200) {
      if (submitAnswerAPI.body == null) {
        throw Exception('Request body is not properly encoded');
      } else {}
    }
  }

  Future<List> yetToArrive({String consultId, venderName, status}) async {
    List availableSlot = ['NA', 'no'];
    Response res = await Dio().get(
        '${API.iHLUrl}/consult/busy_availability_check_new?ihl_consultant_id=$consultId&vendor_id=$venderName&status=$status');
    if (res.statusCode == 200 && !res.data.toString().contains('responce')) {
      availableSlot[0] = res.data['previous_slot'];
      availableSlot[1] = res.data['next_slot'];
      return availableSlot;
    } else {
      return availableSlot;
    }
  }

  Future<List<dynamic>> subScriptionDetails(
      {@required String userId, int pageKey = 20, String approvalStatus}) async {
    int startIndex = pageKey;
    int endIndex = pageKey + 5;
    Response res = await Dio().post(
      "${API.iHLUrl}/consult/view_all_subcription_pagination",
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      ),
      data: {
        'user_ihl_id': userId,
        "start_index": startIndex,
        "end_index": endIndex,
        "approval_status": approvalStatus
      },
    );
    if (res.statusCode == 200) {
      List list = res.data['appts_subscriptions'];
      return list;
    }
  }
}
