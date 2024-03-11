import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/models/models.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JointAccountRegisterUser {
  static String iHLUrl = Apirepository().iHLUrl;
  static String ihlToken = Apirepository().ihlToken;
  static String apiToken = Apirepository().apiToken;
  String apikey;

  Future<bool> jEmailGiven = SpUtil.putBool(SPKeys.jEmailGiven, true);
  Future<bool> jMobileGiven = SpUtil.putBool(SPKeys.jMobileGiven, true);
  Future<bool> jPwdGiven = SpUtil.putBool(SPKeys.jPass, true);

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
      String jWeight}) async {
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
        '","encryptionVersion":null}';
    http.Client _client = http.Client(); //3gb

    // ignore: non_constant_identifier_names
    final auth_response = await _client.get(
      // joint account Authentication URL
      Uri.parse(
          'https://azureapi.indiahealthlink.com/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (auth_response.statusCode == 200) {
      JointAccountSignup reponseToken =
          JointAccountSignup.fromJson(json.decode(auth_response.body));
      print(auth_response.body);
      print(reponseToken);
      apiToken = reponseToken.apiToken;
      final response = await _client.put(
        Uri.parse(iHLUrl + '/data/user'),
        body: jsontext,
        headers: {'ApiToken': apiToken},
      );
      print(apiToken);
      if (response.statusCode == 200) {
        if (response != null) {
          final jointAccountloginResponse = await _client.post(
            Uri.parse(iHLUrl + '/login/qlogin2'),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': apiToken,
              // 'ApiToken':
              //     "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
            },
            body: jsonEncode(<String, String>{
              'email': jEmail,
              'password': jPassword,
            }),
          );
          if (jointAccountloginResponse.statusCode == 200) {
            if (jointAccountloginResponse.body == 'null') {
              return 'User Registration Failed';
            } else {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('password', jPassword);
              prefs.setString('data', jointAccountloginResponse.body);
              prefs.remove('qAns');
              var decodedResponse = jsonDecode(jointAccountloginResponse.body);
              JointAccountLogin reponseToken = JointAccountLogin.fromJson(
                  json.decode(jointAccountloginResponse.body));
              apikey = reponseToken.apiToken;
              // ignore: unused_local_variable
              String iHLUserToken = decodedResponse['Token'];
              print(iHLUserToken);
              // ignore: unused_local_variable
              String iHLUserId = decodedResponse['User']['id'];
              print(iHLUserId);

              final getPlatformData = await _client.post(
                Uri.parse(API.iHLUrl + "/consult/GetPlatfromData"),
                body: jsonEncode(<String, bool>{'cache': true}),
              );

              if (getPlatformData.statusCode == 200) {
                final platformData = await SharedPreferences.getInstance();
                platformData.setString(
                    SPKeys.jPlatformData, getPlatformData.body);
              } else {
                print('PlatformData---------------->');
                print(getPlatformData.body);
              }

              // var userAffiliate = SpUtil.getString('affiliate');
              // if(userAffiliate != "none" || userAffiliate != null) {
              //   var affiliateToSend = jsonDecode(userAffiliate);
              //
              //   final updatedAffiliation = await http.post(
              //     iHLUrl + '/data/user/' + iHLUserId + '',
              //     headers: {
              //       'Content-Type': 'application/json',
              //       'Token': iHLUserToken,
              //       'ApiToken': apiToken,
              //       'Accept': 'application/json'
              //     },
              //     body: jsonEncode(<String, dynamic>{
              //       'user_affiliate': affiliateToSend
              //     }),
              //   );
              //   if (updatedAffiliation.statusCode == 200) {
              //     print("Updated Affiliation!");
              //   }
              //   else {
              //     print(updatedAffiliation.body);
              //   }
              // }

              return (jointAccountloginResponse.body);
            }
          }
        }
      } else {
        throw Exception('failed');
      }
    }
  }
}

class JointAccountRegisterUserWithPic {
  static String iHLUrl = Apirepository().iHLUrl;
  static String ihlToken = Apirepository().ihlToken;
  static String apiToken = Apirepository().apiToken;
  String apikey;
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
      String jProfilepic}) async {
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
        '","encryptionVersion":null}';
    http.Client _client = http.Client(); //3gb

    // ignore: non_constant_identifier_names
    final auth_response = await _client.get(
      // joint account Authentication URL
      Uri.parse(
          'https://azureapi.indiahealthlink.com/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (auth_response.statusCode == 200) {
      JointAccountSignup reponseToken =
          JointAccountSignup.fromJson(json.decode(auth_response.body));
      apiToken = reponseToken.apiToken;
      final response = await _client.put(
        Uri.parse(iHLUrl + '/data/user'),
        body: jsontext,
        headers: {'ApiToken': apiToken},
      );
      if (response.statusCode == 200) {
        if (response != null) {
          final jointAccountloginResponse = await _client.post(
            Uri.parse(iHLUrl + '/login/qlogin2'),
            headers: {
              'Content-Type': 'application/json',
              // 'ApiToken':
              //     "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
              'ApiToken': apiToken
            },
            body: jsonEncode(<String, String>{
              'email': jEmail,
              'password': jPassword,
            }),
          );
          if (jointAccountloginResponse.statusCode == 200) {
            if (jointAccountloginResponse.body == 'null') {
              print('Invalid Credentials -Login');
              return 'User Registration Failed';
            } else {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('password', jPassword);
              prefs.setString('data', jointAccountloginResponse.body);
              prefs.remove('qAns');
              var decodedResponse = jsonDecode(jointAccountloginResponse.body);
              JointAccountLogin reponseToken = JointAccountLogin.fromJson(
                  json.decode(jointAccountloginResponse.body));
              apikey = reponseToken.apiToken;
              String iHLUserToken = decodedResponse['Token'];
              String iHLUserId = decodedResponse['User']['id'];

              final getPlatformData = await _client.post(
                Uri.parse(API.iHLUrl + "/consult/GetPlatfromData"),
                body: jsonEncode(<String, bool>{'cache': true}),
              );
              if (getPlatformData.statusCode == 200) {
                final platformData = await SharedPreferences.getInstance();
                platformData.setString(
                    SPKeys.jPlatformData, getPlatformData.body);
              } else {
                print(getPlatformData.body);
              }

              final userProfileImage = await _client.post(
                Uri.parse(iHLUrl + '/data/user/' + iHLUserId + '/photo'),
                headers: {
                  'Content-Type': 'application/json',
                  'Token': iHLUserToken,
                  'ApiToken': apiToken,
                  'Accept': 'application/json'
                },
                body: jsonEncode(<String, String>{'photo_data': jProfilepic}),
              );
              if (userProfileImage.statusCode == 200) {
                // var userAffiliate = SpUtil.getString('affiliate');
                // print(userAffiliate);
                // if(userAffiliate != "none" || userAffiliate != null) {
                //   var affiliateToSend = jsonDecode(userAffiliate);
                //   final updatedAffiliation = await http.post(
                //     iHLUrl + '/data/user/' + iHLUserId + '',
                //     headers: {
                //       'Content-Type': 'application/json',
                //       'Token': iHLUserToken,
                //       'ApiToken': apiToken,
                //       'Accept': 'application/json'
                //     },
                //     body: jsonEncode(<String, dynamic>{
                //       'user_affiliate': affiliateToSend
                //     }),
                //   );
                //   if (updatedAffiliation.statusCode == 200) {
                //     print("Updated Affiliation!");
                //   }
                //   else {
                //     print(updatedAffiliation.body);
                //   }
                // }

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
    } else {
      print('Fetching Auth Token failed');
    }
  }
}
