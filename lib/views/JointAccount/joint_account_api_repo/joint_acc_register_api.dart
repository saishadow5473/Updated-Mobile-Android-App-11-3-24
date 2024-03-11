import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/models/models.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/views/JointAccount/create_new_account/create_signup_pic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JointAccountRegisterUser {
  static String iHLUrl = Apirepository().iHLUrl;
  static String ihlToken = Apirepository().ihlToken;
  static String apiToken = Apirepository().apiToken;
  String apikey;
  String careTakerUserID;

  String guestID;
  String guestUserToken;

  var checkEmailGiven = SpUtil.putBool(SPKeys.jEmailGiven, true);
  var checkMobileGiven = SpUtil.putBool(SPKeys.jMobileGiven, true);
  var checkPasswordGiven = SpUtil.putBool(SPKeys.jPass, true);

  // static Future<bool> jEmailGiven = SpUtil.putBool(SPKeys.jEmailGiven, true);
  // static Future<bool> jMobileGiven = SpUtil.putBool(SPKeys.jMobileGiven, true);
  // static Future<bool> jPwdGiven = SpUtil.putBool(SPKeys.jPass, true);
  // static Future<bool> jVitalRead = SpUtil.putBool(SPKeys.jVitalRead, true);
  // static Future<bool> jvitalWrite = SpUtil.putBool(SPKeys.jVitalWrite, true);
  // static Future<bool> jTeleconsultRead =
  //     SpUtil.putBool(SPKeys.jTeleconsultRead, true);
  // static Future<bool> jTeleconsultWrite =
  //     SpUtil.putBool(SPKeys.jTeleconsultWrite, true);

  bool vitalRead =
      jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty ? true : false;
  bool vitalWrite =
      jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty ? true : false;
  bool teleconsultRead =
      jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty ? true : false;
  bool teleconsultWrite =
      jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty ? true : false;

  String isRequested = 'requested';

  bool isJointAccount = true;

  Future<String> getCareTakerID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    Map res = jsonDecode(userData);
    String careTakerUserID = res['User']['id'];
    return careTakerUserID;
  }

  // ignore: missing_return
  Future<String> jointAccountRegisterUser(
      {String jFirstName,
      String jLastName,
      String jEmail,
      String jPassword,
      String jMobileNumber,
      String jGender,
      String jDob,
      String jHeight,
      String jWeight,
      String careTakerUserID
      // 'OMaSpiRqWk6AqZALrUl8Rw'
      }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    Map res = jsonDecode(userData);
    careTakerUserID = res['User']['id'];

    var jsontext = '{"user":{"email":"' +
        jEmail +
        '", "mobileNumber":"' +
        jMobileNumber +
        '", "userInputWeightInKG":"' +
        jWeight +
        '", "firstName":"' +
        jFirstName +
        '", "lastName":"' +
        jLastName +
        '", "aadhaarNumber":"", "dateOfBirth":"' +
        jDob +
        '", "gender":"' +
        jGender +
        '", "heightMeters":"' +
        jHeight +
        '", "fingerprint":"","terms":{"termsFileName":"termsofuse_v9_01122016"},"privacyAgreed":{"privacyFileName":"privacypolicy_v7_08112014"}},"password":"' +
        jPassword +
        '","encryptionVersion":null, "care_taker_details_list":{"caretaker_user1":{"is_joint_account":"' +
        isJointAccount.toString() +
        '","caretaker_ihl_id":"' +
        careTakerUserID +
        '","vital_read": "' +
        vitalRead.toString() +
        '","vital_write": "' +
        vitalWrite.toString() +
        '","teleconsult_read": "' +
        teleconsultRead.toString() +
        '","teleconsult_write": "' +
        teleconsultWrite.toString() +
        '"}}}';
    http.Client _client = http.Client(); //3gb

    // ignore: non_constant_identifier_names
    final auth_response = await _client.get(
      // joint account Authentication URL
      Uri.parse(iHLUrl + '/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (auth_response.statusCode == 200) {
      JointAccountSignup reponseToken =
          JointAccountSignup.fromJson(json.decode(auth_response.body));
      print(auth_response.body);
      print(reponseToken);
      // final prefs = await SharedPreferences.getInstance();
      // prefs.setString('id', guestID);
      // prefs.setString('data', auth_response.body);

      // prefs.remove('data');

      apiToken = reponseToken.apiToken;
      final response = await _client.put(
        Uri.parse(iHLUrl + '/data/create_user'),
        body: jsontext,
        headers: {'ApiToken': apiToken},
      );
      print(apiToken);
      if (response.statusCode == 200) {
        JointAccountGuestUSerSignup guestUserResponse =
            JointAccountGuestUSerSignup.fromJson(json.decode(response.body));
        guestID = guestUserResponse.id;
        guestUserToken = guestUserResponse.token;

        print(guestUserResponse);
        print(guestUserToken);
        if (response != null) {
          final jointAccountloginResponse = await _client.post(
            Uri.parse(iHLUrl + '/login/get_user_login'),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': guestUserToken,
              // 'ApiToken':
              //     "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
            },
            body: jsonEncode(<String, String>{
              'id': guestID,
            }),
          );
          if (jointAccountloginResponse.statusCode == 200) {
            if (jointAccountloginResponse.body == 'null') {
              return 'User Registration Failed';
            } else {
              var decodedResponse = jsonDecode(jointAccountloginResponse.body);
              JointAccountGuestUserLogin reponseToken =
                  JointAccountGuestUserLogin.fromJson(
                      json.decode(jointAccountloginResponse.body));
              apikey = reponseToken.token;
              // ignore: unused_local_variable
              String guestUserToken = decodedResponse['Token'];
              print(guestUserToken);

              // ignore: unused_local_variable
              String guestID = decodedResponse['User']['id'];

              String guestUserName = decodedResponse['User']['firstName'];
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('id', guestID);
              prefs.setString('firstName', guestUserName);
              prefs.setString('Token', guestUserToken);
              prefs.setString('data', jointAccountloginResponse.body);
              prefs.remove('qAns');
              print(guestID);
              print(decodedResponse);

              // Edit User API starts

              var jsonEditUsertext =
                  '{"joint_user_detail_list":{"joint_user1":{"ihl_user_id":"' +
                      guestID +
                      '","ihl_user_name":"' +
                      guestUserName +
                      '","status": "' +
                      isRequested +
                      '","vital_read": "' +
                      vitalRead.toString() +
                      '","vital_write": "' +
                      vitalWrite.toString() +
                      '","teleconsult_read": "' +
                      teleconsultRead.toString() +
                      '","teleconsult_write": "' +
                      teleconsultWrite.toString() +
                      '"}}}';

              final editUserResponse = await _client.post(
                Uri.parse(iHLUrl +
                    '/data/user/' +
                    careTakerUserID), // Qylz47QlqESCqHLG4tkYhw
                headers: {
                  'Content-Type': 'application/json',
                  // 'ApiToken': apikey,
                  'ApiToken': apiToken,
                  'Token': guestUserToken
                  // 'ApiToken':
                  //     "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
                },
                body: jsonEditUsertext,
              );
              print(jsonEditUsertext);
              print(apiToken);

              if (editUserResponse.statusCode == 200) {
                if (editUserResponse.body != null) {
                  JointAccountEditGuestUSerSignup editGuestUSerSignup =
                      JointAccountEditGuestUSerSignup.fromJson(
                          json.decode(editUserResponse.body));
                  String guestUserID = editGuestUSerSignup.ihl_user_id;
                  print(guestUserID);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  // var userData = prefs.get('data');

                  var careTakerUserEmail = prefs.get('password');

                  var careTakerUserPassword = prefs.get('email');

                  final jointAccountloginfinalResponse = await _client.post(
                    Uri.parse(iHLUrl + '/login/qlogin2'),
                    headers: {
                      'Content-Type': 'application/json',
                      'ApiToken': apiToken,
                      // 'ApiToken':
                      //     "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
                    },
                    body: jsonEncode(<String, String>{
                      'password': careTakerUserEmail,
                      'email': careTakerUserPassword
                    }),
                  );
                  if (jointAccountloginfinalResponse.statusCode == 200) {
                    print(jointAccountloginfinalResponse.body);
                  }
                  print(jointAccountloginfinalResponse.body);
                } else {
                  return throw Exception('failed');
                }
              }

              // Edit User API ends

            }
          }
        }
      } else {
        throw Exception('failed');
      }
    }
  }
}

// with jointaccount details

class JointAccountRegisterUserWithPic {
  static String iHLUrl = Apirepository().iHLUrl;
  static String ihlToken = Apirepository().ihlToken;
  static String apiToken = Apirepository().apiToken;
  String apikey;
  String careTakerUserID;
  String guestID;
  String guestUserToken;
  String isRequested = 'requested';
  bool vitalRead =
      jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty ? true : false;
  bool vitalWrite =
      jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty ? true : false;
  bool teleconsultRead =
      jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty ? true : false;
  bool teleconsultWrite =
      jEmail.isEmpty && jPwd.isEmpty && jMobile.isEmpty ? true : false;

  bool isJointAccount = true;
  // ignore: missing_return
  Future<String> jointAccountRegisterUser({
    String jFirstName,
    String jLastName,
    String jEmail,
    String jPassword,
    String jMobileNumber,
    String jGender,
    String jDob,
    String jHeight,
    String jWeight,
    String jProfilepic,
    String careTakerUserID,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = prefs.get('data');
    Map res = jsonDecode(userData);
    String careTakerUserID = res['User']['id'];
    prefs.remove('email');

    var jsontext = '{"user":{"email":"' +
        jEmail +
        '", "mobileNumber":"' +
        jMobileNumber +
        '", "userInputWeightInKG":"' +
        jWeight +
        '", "firstName":"' +
        jFirstName +
        '", "lastName":"' +
        jLastName +
        '", "aadhaarNumber":"", "dateOfBirth":"' +
        jDob +
        '", "gender":"' +
        jGender +
        '", "heightMeters":"' +
        jHeight +
        '", "fingerprint":"","terms":{"termsFileName":"termsofuse_v9_01122016"},"privacyAgreed":{"privacyFileName":"privacypolicy_v7_08112014"}},"password":"' +
        jPassword +
        '","encryptionVersion":null,"care_taker_details_list":{"caretaker_user1":{"is_joint_account":"' +
        isJointAccount.toString() +
        '","caretaker_ihl_id":"' +
        careTakerUserID +
        '","vital_read": "' +
        vitalRead.toString() +
        '","vital_write": "' +
        vitalWrite.toString() +
        '","teleconsult_read": "' +
        teleconsultRead.toString() +
        '","teleconsult_write": "' +
        teleconsultWrite.toString() +
        '"}}}';
    http.Client _client = http.Client(); //3gb

    // ignore: non_constant_identifier_names
    final auth_response = await _client.get(
      // joint account Authentication URL
      Uri.parse(iHLUrl + '/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (auth_response.statusCode == 200) {
      JointAccountSignup reponseToken =
          JointAccountSignup.fromJson(json.decode(auth_response.body));
      apiToken = reponseToken.apiToken;

      final response = await _client.put(
        Uri.parse(iHLUrl + '/data/create_user'),
        body: jsontext,
        headers: {'ApiToken': apiToken},
      );
      if (response.statusCode == 200) {
        JointAccountGuestUSerSignup guestUserResponse =
            JointAccountGuestUSerSignup.fromJson(json.decode(response.body));
        guestID = guestUserResponse.id;
        guestUserToken = guestUserResponse.token;

        print(guestUserResponse);
        print(guestUserToken);
        if (response != null) {
          final jointAccountloginResponse = await _client.post(
            Uri.parse(iHLUrl + '/login/get_user_login'),
            headers: {
              'Content-Type': 'application/json',
              // 'ApiToken':
              //     "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
              'ApiToken': guestUserToken
            },
            body: jsonEncode(<String, String>{
              'id': guestID,
            }),
          );
          if (jointAccountloginResponse.statusCode == 200) {
            if (jointAccountloginResponse.body == 'null') {
              print('Invalid Credentials -Login');
              return 'User Registration Failed';
            } else {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('id', guestID);
              prefs.setString('data', jointAccountloginResponse.body);
              prefs.remove('qAns');
              // SpUtil.remove('id');
              // SpUtil.remove('password');
              var decodedResponse = jsonDecode(jointAccountloginResponse.body);
              JointAccountGuestUserLogin reponseToken =
                  JointAccountGuestUserLogin.fromJson(
                      json.decode(jointAccountloginResponse.body));
              apikey = reponseToken.token;
              // String iHLUserToken = decodedResponse['Token'];
              String guestUserLoginID = decodedResponse['User']['id'];
              String guestUserName = decodedResponse['User']['firstName'];
              prefs.setString('firstName', guestUserName);
              prefs.setString('id', guestID);
              final userProfileImage = await _client.post(
                Uri.parse(iHLUrl + '/data/user/' + guestUserLoginID + '/photo'),
                headers: {
                  'Content-Type': 'application/json',
                  // 'Token': iHLUserToken,
                  'ApiToken': guestUserToken,
                  'Accept': 'application/json'
                },
                body: jsonEncode(<String, String>{'photo_data': jProfilepic}),
              );
              print(jProfilepic);
              if (userProfileImage.statusCode == 200) {
                // Edit User API starts

                var jsonEditUsertext =
                    '{"joint_user_detail_list":{"joint_user1":{"ihl_user_id":"' +
                        guestID +
                        '","ihl_user_name":"' +
                        guestUserName +
                        '","status": "' +
                        isRequested +
                        '","vital_read": "' +
                        vitalRead.toString() +
                        '","vital_write": "' +
                        vitalWrite.toString() +
                        '","teleconsult_read": "' +
                        teleconsultRead.toString() +
                        '","teleconsult_write": "' +
                        teleconsultWrite.toString() +
                        '"}}}';

                final editUserResponse = await _client.post(
                  Uri.parse(iHLUrl +
                      '/data/user/' +
                      careTakerUserID), // Qylz47QlqESCqHLG4tkYhw
                  headers: {
                    'Content-Type': 'application/json',
                    // 'ApiToken': apikey,
                    'ApiToken': apiToken,
                    'Token': guestUserToken
                    // 'ApiToken':
                    //     "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
                  },
                  body: jsonEditUsertext,
                );
                print(jsonEditUsertext);
                print(apiToken);

                if (editUserResponse.statusCode == 200) {
                  if (editUserResponse.body != null) {
                    final jointAccountloginfinalResponse = await _client.post(
                      Uri.parse(iHLUrl + '/login/get_user_login'),
                      headers: {
                        'Content-Type': 'application/json',
                        'ApiToken': apiToken,
                        // 'ApiToken':
                        //     "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
                      },
                      body: jsonEncode(<String, String>{
                        'id': guestID,
                      }),
                    );
                    print(jointAccountloginfinalResponse.body);
                  } else {
                    return throw Exception('failed');
                  }
                }

                // Edit User API ends

                return 'User Registration Success';
              } else {
                throw Exception('Photo upload Failed');
              }
            }
          }
        }
      } else {
        throw Exception('failed');
      }
    }
  }
}
