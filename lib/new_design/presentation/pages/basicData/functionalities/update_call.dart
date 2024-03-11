import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../screens/MobileNumber.dart';
import 'percentage_calculations.dart';
import '../../../../../repositories/getuserData.dart';
import '../../../../../views/JointAccount/create_new_account/create_email.dart';
import '../models/basic_data.dart';
import 'draft_data.dart';
import '../../../../app/utils/localStorageKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../constants/api.dart';
import '../../../../../utils/SpUtil.dart';
import '../../../../data/providers/network/networks.dart';
import 'package:http/http.dart' as http;

class ProfileUpdate {
  DraftData saveData = DraftData();
  BasicDataModel basicData;
  final http.Client _client = http.Client(); //3gb

  Future<String> userProfileEditAPI({
    String mobileNumber,
    String gender,
    String dob,
    String height,
    String weight,
  }) async {
    // mobileNumber=saveData.phoneNumber;
    // gender=saveData.gender;
    // dob=saveData
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
        '{"mobileNumber": "$mobileNumber","dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
    try {
      dynamic userProfileEditAPIResponse = await dio.post(
        '${API.iHLUrl}/data/user/$iHLUserId',
        data: jsontext,
        options: Options(
          headers: {'Content-Type': 'application/json', 'ApiToken': apikey, 'Token': iHLUserToken},
        ),
      );
      if (userProfileEditAPIResponse.statusCode == 200) {
        var decode;
        String extractedResponseMessage =
            userProfileEditAPIResponse.data.replaceAll(RegExp(r'[^\w\s]+'), '');
        if (extractedResponseMessage == "updated") {
          Object password = prefs.get('password');

          Object email = prefs.get('email');

          Object authToken = prefs.get('auth_token');

          Object isSso = prefs.get('is_sso');

          String apiToken = SpUtil.getString(LSKeys.apiToken);
          String ihlUserToken = SpUtil.getString(LSKeys.iHLUserToken);

          http.Response response1 = await _client.post(
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
              bool resp = await updateData.uptoUserInfoDate();
            } catch (e) {
              print(e);
            }
          }
          return (extractedResponseMessage);
        } else {
          throw Exception('Failed in updating user profile');
        }
      } else {
        throw Exception('Authorization Failed${userProfileEditAPIResponse.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed');
    }
  }

  Future<String> userProfileEditAPISSO({
    String mobileNumber,
    String gender,
    String dob,
    String height,
    String weight,
  }) async {
    // mobileNumber=saveData.phoneNumber;
    // gender=saveData.gender;
    // dob=saveData
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Object userData = prefs.get('data');
    var decodedResponse = jsonDecode(userData);
    if (decodedResponse['response'] == 'user already has an primary account in this email') {
      var userId0 = decodedResponse['id'];
      // loginRes = false;
      http.Response resp = await _client.post(
        Uri.parse('${API.iHLUrl}/login/get_user_login'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken':
              "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA=="
        },
        body: jsonEncode({"id": userId0}),
      );
      decodedResponse = jsonDecode(resp.body);
      print(resp.body);
    }
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
        '{"mobileNumber": "$mobileNumber","dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
    try {
      dynamic userProfileEditAPIResponse = await dio.post(
        '${API.iHLUrl}/data/user/$iHLUserId',
        data: mobileSkipped
            ? jsonEncode(
                <String, dynamic>{
                  "id": iHLUserId,
                  'dateOfBirth': dob,
                  'heightMeters': height,
                  'gender': gender,
                  'userInputWeightInKG': weight
                },
              )
            : jsonEncode(
                <String, dynamic>{
                  "id": iHLUserId,
                  'mobileNumber': mobileNumber,
                  'dateOfBirth': dob,
                  'heightMeters': height,
                  'gender': gender,
                  'userInputWeightInKG': weight
                },
              ),
        options: Options(
          headers: {'Content-Type': 'application/json', 'ApiToken': apikey, 'Token': iHLUserToken},
        ),
      );
      if (userProfileEditAPIResponse.statusCode == 200) {
        String extractedResponseMessage =
            userProfileEditAPIResponse.data.replaceAll(RegExp(r'[^\w\s]+'), '');
        if (extractedResponseMessage == "updated") {
          http.Response userDetailResponse = await _client.post(
              Uri.parse(
                '${API.iHLUrl}/login/get_user_login',
              ),
              body: jsonEncode(
                <String, dynamic>{
                  "id": iHLUserId,
                },
              ),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken':
                    '69/G9PN0M1Y/ZxC9LMG4c+2qFCg+6Qfye8ci7XV53egWzXaBapR3LAVWzBX5+js5Q/Oy4CDOR/x24C/6gT5N/G98x8xd4GtBmbWNRE1YF1cBAA==',
              });
          if (userDetailResponse.statusCode == 200) {
            // prefs.setString(SPKeys.userData, userDetailResponse.body);
            var res = json.decode(userDetailResponse.body);
            try {
              await MyvitalsApi().vitalDatas(res);
            } catch (e) {
              print(e);
            }
            try {
              basicData = BasicDataModel(
                name: '${res['User']['firstName']} ${res['User']['lastName']}',
                dob: res['User'].containsKey('dateOfBirth')
                    ? res['User']['dateOfBirth'].toString()
                    : null,
                gender: res['User'].containsKey('gender') ? res['User']['gender'].toString() : null,
                height: res['User'].containsKey("heightMeters")
                    ? res['User']["heightMeters"].toString()
                    : null,
                mobile: res['User'].containsKey("mobileNumber")
                    ? res['User']['mobileNumber'].toString()
                    : null,
                weight: res['User'].containsKey("userInputWeightInKG")
                    ? res['User']['userInputWeightInKG'].toString()
                    : null,
              );
              final GetStorage box = GetStorage();

              box.write('BasicData', basicData);
              BasicDataModel b = box.read('BasicData');
              print(b);
              PercentageCalculations().checkHowManyFilled();
              PercentageCalculations().calculatePercentageFilled();
              GetData updateData = GetData();
              bool resp = await updateData.uptoUserInfoDate();
            } catch (e) {
              print(e);
            }
          }
          return (extractedResponseMessage);
        } else {
          throw Exception('Failed in updating user profile');
        }
      } else {
        throw Exception('Authorization Failed${userProfileEditAPIResponse.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed');
    }
  }
}
