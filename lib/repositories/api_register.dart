import 'dart:async';
import 'dart:convert';

import 'package:dio/src/response.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../new_design/presentation/pages/profile/updatePhoto.dart';
import '../new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../new_design/presentation/pages/basicData/functionalities/percentage_calculations.dart';
import '../constants/api.dart';
import '../constants/spKeys.dart';
import '../models/models.dart';
import '../new_design/data/providers/network/networks.dart';
import '../new_design/presentation/pages/basicData/models/basic_data.dart';
import 'api_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../new_design/app/utils/localStorageKeys.dart';
import '../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import '../utils/SpUtil.dart';
import 'getuserData.dart';

String gType;

class RegisterUser {
  final http.Client _client = http.Client(); //3gb
  static String iHLUrl = Apirepository().iHLUrl;
  static String ihlToken = Apirepository().ihlToken;
  static String apiToken = Apirepository().apiToken;
  String apikey;
  static final GetData _updateData = GetData();
  // ignore: missing_return
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
      bool isSso,
      String ssoToken}) async {
    String jsontext =
        '{"user":{"email":"$email", "mobileNumber":"$mobileNumber", "userInputWeightInKG":"$weight", "firstName":"$firstName", "lastName":"$lastName", "aadhaarNumber":"", "dateOfBirth":"$dob", "gender":"$gender", "heightMeters":"$height", "fingerprint":"","terms":{"termsFileName":"termsofuse_v9_01122016"},"privacyAgreed":{"privacyFileName":"privacypolicy_v7_08112014"}},"password":"$password","encryptionVersion":null}';

    String jsontextSso;
    String jsontextSsoOkta;
    if (ssoToken != null) {
      jsontextSsoOkta = '{"sso_token":"' +
          ssoToken +
          '","sso_type":"' +
          gType +
          '","user":{"firstName":"' +
          firstName +
          '", "lastName":"' +
          lastName +
          '", "aadhaarNumber":"", "is_organization_account":true, "fingerprint":"","terms":{"termsFileName":"termsofuse_v9_01122016"},"privacyAgreed":{"privacyFileName":"privacypolicy_v7_08112014"}},"password":"' +
          "" +
          '","encryptionVersion":null}';
      jsontextSso = '{"sso_token":"' +
          ssoToken +
          '","sso_type":"' +
          gType +
          '","user":{ "aadhaarNumber":"", "is_organization_account":true, "fingerprint":"","terms":{"termsFileName":"termsofuse_v9_01122016"},"privacyAgreed":{"privacyFileName":"privacypolicy_v7_08112014"}},"password":"' +
          "" +
          '","encryptionVersion":null}';
    }

    // ignore: non_constant_identifier_names

    String urlEndpoint = isSso
        ?
        // '/sso/create_sso_user_account'
        '/sso/create_sso_user_account_v1'
        : '/data/user';
    final http.Response authResponse = await _client.get(
      Uri.parse('$iHLUrl/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (authResponse.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(authResponse.body));
      apiToken = reponseToken.apiToken;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', apiToken);
      final http.Response response = isSso
          ? await _client.post(
              Uri.parse(iHLUrl + urlEndpoint),
              body: jsontextSso,
              headers: {'ApiToken': apiToken},
            )
          : await _client.put(
              Uri.parse(iHLUrl + urlEndpoint),
              body: jsontext,
              headers: {'ApiToken': apiToken},
            );
      if (response != null) {
        String body = jsonEncode(<String, String>{
          'email': email,
          'password': password,
        });
        String bodySso = jsonEncode(<String, String>{'sso_token': ssoToken, "sso_type": gType});
        String loginUrl = isSso ? '/sso/login_sso_user_account' : '/login/qlogin2';
        final http.Response loginResponse = await _client.post(
          Uri.parse(iHLUrl + loginUrl),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken':
                "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
          },
          body: isSso ? bodySso : body,
        );
        if (loginResponse.statusCode == 200) {
          if (loginResponse.body == 'null') {
            return 'User Registration Failed';
          } else {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('password', password);
            prefs.setString('data', loginResponse.body);
            prefs.remove('qAns');
            if (isSso) {
              prefs.setString('sso_token', ssoToken);
              prefs.setString(SPKeys.is_sso, "true");
              //Addidng presistant affiliation to SSo users
              var tokenParse = jsonDecode(loginResponse.body);
              var token = tokenParse['Token'];
              var userIhlId = tokenParse['User']['id'];
              var email = tokenParse['User']['email'];
              var mobileNumber = tokenParse['User']['mobileNumber'];

              ///for making the affiliation dynamic:
              //TODO 1-> substring the email and send in the api and according to the response add the affiliation

              //Addidng presistant affiliation to SSo users
              String body = jsonEncode(<String, String>{'email': email});
              String affiliationUniqueName = "";
              String companyName = "";
              http.Client httpClient = http.Client(); //3gb
              final http.Response affiliationDetails = await httpClient.post(
                Uri.parse("$iHLUrl/sso/affiliation_details"),
                body: body,
              );
              if (affiliationDetails.statusCode == 200) {
                var tokenParse = jsonDecode(affiliationDetails.body);
                affiliationUniqueName = tokenParse['response']['affiliation_unique_name'];
                companyName = tokenParse['response']['company_name'];
              }

              final http.Response updateProfile = await _client.post(
                  Uri.parse('$iHLUrl/data/user/' + userIhlId),
                  headers: {
                    'Content-Type': 'application/json',
                    'ApiToken': apiToken,
                    'Token': token
                  },
                  body: jsonEncode(<String, dynamic>{
                    "id": userIhlId,
                    "user_affiliate": {
                      "af_no1": {
                        "affilate_unique_name": affiliationUniqueName,
                        "affilate_name": companyName,
                        "affilate_email": email,
                        "affilate_mobile": mobileNumber,
                        "affliate_identifier_id": "",
                        "is_sso": true,
                      }
                    }
                  }));
              final http.Response loginResponsereport = await _client.post(
                Uri.parse(iHLUrl + loginUrl),
                headers: {
                  'Content-Type': 'application/json',
                  'ApiToken':
                      "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
                },
                body: isSso ? bodySso : body,
              );
              if (loginResponsereport.statusCode == 200) {
                prefs.setString('data', loginResponsereport.body);
              }
            }
            var decodedResponse = jsonDecode(loginResponse.body);
            Login reponseToken = Login.fromJson(json.decode(loginResponse.body));
            apikey = reponseToken.apiToken;
            prefs.setString('auth_token', reponseToken.apiToken.toString());
            if (reponseToken.apiToken.toString() == 'null') {
              prefs.setString('auth_token', apiToken.toString());
              if (apiToken.toString() == 'null') {
                String aptkn =
                    '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
                prefs.setString('auth_token', aptkn.toString());
              }
            }

            // ignore: unused_local_variable
            String iHLUserToken = decodedResponse['Token'];
            // ignore: unused_local_variable
            String iHLUserId = decodedResponse['User']['id'];
            API.headerr = {};
            API.headerr['Token'] = iHLUserToken;
            API.headerr['ApiToken'] =
                '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${API.headerr}");
            localSotrage.write(LSKeys.logged, true);

            final http.Response getPlatformData = await _client.post(
              Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              },
              body: jsonEncode(<String, bool>{'cache': true}),
            );

            if (getPlatformData.statusCode == 200) {
              final SharedPreferences platformData = await SharedPreferences.getInstance();
              platformData.setString(SPKeys.platformData, getPlatformData.body);
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

            return (loginResponse.body);
          }
        }
      } else {
        throw Exception('failed');
      }
    }
  }
}

class RegisterUserWithPic {
  static String iHLUrl = Apirepository().iHLUrl;
  static String ihlToken = Apirepository().ihlToken;
  static String apiToken = Apirepository().apiToken;
  static final GetData _updateData = GetData();
  String apikey;
  // ignore: missing_return
  Future<String> registerUser(
      {String firstName,
      String lastName,
      String email,
      String password,
      // String mobileNumber,
      // String gender,
      // String dob,
      // String height,
      // String weight,
      // String profilepic,
      bool isSso,
      String ssoToken}) async {
    //need to add model for below payload
    String jsontext =
        '{"user":{"email":"$email", "firstName":"$firstName", "lastName":"$lastName", "aadhaarNumber":"",  "fingerprint":"","terms":{"termsFileName":"termsofuse_v9_01122016"},"privacyAgreed":{"privacyFileName":"privacypolicy_v7_08112014"}},"password":"$password","encryptionVersion":null}';
    String jsontextSso;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String emailokta = prefs.getString('OktaEmail');
    if (ssoToken != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString('SignInType') == 'okta') {
        jsontextSso = '{"sso_token":"' +
            ssoToken +
            '","sso_type":"' +
            gType +
            '","user":{"firstName":"' +
            firstName +
            '", "lastName":"' +
            lastName +
            '","email":"' +
            emailokta +
            '", "aadhaarNumber":"", "is_organization_account":true, "fingerprint":"","terms":{"termsFileName":"termsofuse_v9_01122016"},"privacyAgreed":{"privacyFileName":"privacypolicy_v7_08112014"}},"password":"' +
            "" +
            '","encryptionVersion":null}';
      } else {
        jsontextSso = '{"sso_token":"' +
            ssoToken +
            '","sso_type":"' +
            gType +
            '","user":{ "aadhaarNumber":"", "is_organization_account":true, "fingerprint":"","terms":{"termsFileName":"termsofuse_v9_01122016"},"privacyAgreed":{"privacyFileName":"privacypolicy_v7_08112014"}},"password":"' +
            "" +
            '","encryptionVersion":null}';
      }
    }
    // ignore: non_constant_identifier_names
    String urlEndpoint = isSso
        ?
        // '/sso/create_sso_user_account'
        '/sso/create_sso_user_account_v1'
        : '/data/user';
    http.Client client4 = http.Client(); //3gb
    final http.Response authResponse = await client4.get(
      Uri.parse('$iHLUrl/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (authResponse.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(authResponse.body));
      apiToken = reponseToken.apiToken;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', apiToken);
      final http.Response response = isSso
          ? await client4.post(
              Uri.parse(iHLUrl + urlEndpoint),
              body: jsontextSso,
              headers: {'ApiToken': apiToken},
            )
          : await client4.put(
              Uri.parse(iHLUrl + urlEndpoint),
              body: jsontext,
              headers: {'ApiToken': apiToken},
            );
      if (response != null) {
        String check = response.body;
        String body = jsonEncode(<String, String>{
          'email': email,
          'password': password,
        });
        String bodySso = jsonEncode(<String, String>{'sso_token': ssoToken, "sso_type": gType});
        if (prefs.getString('SignInType') == 'okta') {
          bodySso = jsonEncode(<String, String>{
            'sso_token': ssoToken,
            "sso_type": gType,
            'email': prefs.getString('OktaEmail')
          });
        }
        String loginUrl = isSso
            ?
            //  '/sso/login_sso_user_account'
            '/sso/login_sso_user_account_v1'
            : '/login/qlogin2';

        http.Client client5 = http.Client(); //3gb
        final http.Response loginResponse = await client5.post(
          Uri.parse(iHLUrl + loginUrl),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken':
                "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
          },
          body: isSso ? bodySso : body,
        );
        http.Response alternateRes;
        if (loginResponse.statusCode == 200) {
          if (loginResponse.body == 'null') {
            return 'User Registration Failed';
          } else {
            bool pri = true;
            alternateRes = loginResponse;
            var checkRes = jsonDecode(loginResponse.body);
            var tokenResponse = jsonDecode(loginResponse.body);
            if (checkRes['response'] == 'user already has an primary account in this email') {
              pri = false;
              var userId = checkRes['id'];
              http.Client client0 = http.Client();
              http.Response resp = await client0.post(
                Uri.parse('${API.iHLUrl}/login/get_user_login'),
                headers: {
                  'Content-Type': 'application/json',
                  'ApiToken':
                      "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA=="
                },
                body: jsonEncode({"id": userId}),
              );

              tokenResponse = jsonDecode(resp.body);
              alternateRes = resp;
            }
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('password', password);
            SpUtil.putString('password', password);
            try {
              prefs.setString('data', pri ? loginResponse.body : tokenResponse.toString());
            } catch (e) {
              print(e);
            }

            prefs.remove('qAns');

            //add basic data model
            try {
              await MyvitalsApi().vitalDatas(tokenResponse);
            } catch (e) {
              print(e);
            }

            BasicDataModel basicData;
            try {
              basicData = BasicDataModel(
                name: '${tokenResponse['User']['firstName']} ${tokenResponse['User']['lastName']}',
                dob: tokenResponse['User'].containsKey('dateOfBirth')
                    ? tokenResponse['User']['dateOfBirth'].toString()
                    : null,
                gender: tokenResponse['User'].containsKey('gender')
                    ? tokenResponse['User']['gender'].toString()
                    : null,
                height: tokenResponse['User'].containsKey("heightMeters")
                    ? tokenResponse['User']["heightMeters"].toString()
                    : null,
                mobile: tokenResponse['User'].containsKey("mobileNumber")
                    ? tokenResponse['User']['mobileNumber'].toString()
                    : null,
                weight: tokenResponse['User'].containsKey("userInputWeightInKG")
                    ? tokenResponse['User']['userInputWeightInKG'].toString()
                    : null,
              );
              final GetStorage box = GetStorage();

              box.write('BasicData', basicData);
              BasicDataModel b = box.read('BasicData');
              print(b);
              PercentageCalculations().checkHowManyFilled();
              PercentageCalculations().calculatePercentageFilled();
            } catch (e) {
              print(e);
            }
            if (isSso) {
              prefs.setString('sso_token', ssoToken);
              prefs.setString(SPKeys.is_sso, "true");

              var tokenParse;

              if (pri) {
                tokenParse = jsonDecode(loginResponse.body);
              } else {
                print(tokenResponse);
                try {
                  tokenParse = tokenResponse;
                } catch (e) {
                  print(e);
                }
                print(tokenParse);
              }

              var token = tokenParse['Token'];
              var userIhlId = tokenParse['User']['id'];
              prefs.setString('UserIDSso', tokenParse['User']['id'].toString());
              prefs.setBool('isSSoUser', true);
              var email = tokenParse['User']['email'];
              prefs.setString('emailM', email);
              prefs.setString('email', email);
              var mobileNumber = tokenParse['User']['mobileNumber'];

              //Addidng presistant affiliation to SSo users
              ///here why you didn't create a new client...
              ///i am gonna create a new client and then check it again

              //
              String body = jsonEncode(<String, String>{'email': email});
              String affiliationUniqueName = "";
              String companyName = "";
              http.Client httpClient = http.Client(); //3gb
              final http.Response affiliationDetails = await httpClient.post(
                Uri.parse("$iHLUrl/sso/affiliation_details"),
                body: body,
              );
              if (affiliationDetails.statusCode == 200) {
                var tokenParse = jsonDecode(affiliationDetails.body);
                affiliationUniqueName = tokenParse['response']['affiliation_unique_name'];
                if (gType == 'okta') {
                  companyName = UpdatingColorsBasedOnAffiliations.companyName['company_name'] ??
                      tokenParse['response']['company_name'];
                } else {
                  companyName = tokenParse['response']['company_name'];
                }
              }

              http.Client client5_1 = http.Client(); //3gb
              final http.Response updateProfile = await client5_1.post(
                  Uri.parse('$iHLUrl/data/user/' + userIhlId),
                  headers: {
                    'Content-Type': 'application/json',
                    'ApiToken': apiToken,
                    'Token': token
                  },
                  body: jsonEncode(<String, dynamic>{
                    "id": userIhlId,
                    "user_affiliate": {
                      "af_no1": {
                        "affilate_unique_name": affiliationUniqueName,
                        "affilate_name": companyName,
                        "affilate_email": email,
                        "affilate_mobile": mobileNumber,
                        "affliate_identifier_id": "",
                        "is_sso": true,
                      }
                    }
                  }));
              if (updateProfile.statusCode == 200) {
                http.Client client = http.Client(); //3gb

                final http.Response ssoCount =
                    await client.post(Uri.parse('$iHLUrl/sso/affiliation_bulk_update'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode(<String, dynamic>{
                          "email": prefs.get(SPKeys.email),
                          "affiliation_unique_name": affiliationUniqueName,
                          "mobileNumber": mobileNumber,
                          "company_name": companyName,
                          "firstName": tokenParse['User']['firstName'],
                          "lastName": tokenParse['User']['lastName'],
                          "ihl_user_id": tokenParse['User']['id'],
                        }));
                final http.Response loginResponsereport = await client4.post(
                  Uri.parse(iHLUrl + loginUrl),
                  headers: {
                    'Content-Type': 'application/json',
                    'ApiToken':
                        "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
                  },
                  body: isSso ? bodySso : body,
                );
                if (loginResponsereport.statusCode == 200) {
                  var checkRes1 = jsonDecode(loginResponsereport.body);
                  if (checkRes1['response'] ==
                      'user already has an primary account in this email') {
                    pri = false;
                    var userId = checkRes1['id'];
                    http.Client client0 = http.Client();
                    http.Response resp = await client0.post(
                      Uri.parse('${API.iHLUrl}/login/get_user_login'),
                      headers: {
                        'Content-Type': 'application/json',
                        'ApiToken':
                            "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA=="
                      },
                      body: jsonEncode({"id": userId}),
                    );

                    tokenResponse = jsonDecode(resp.body);
                    alternateRes = resp;
                  }
                  //prefs.setString('data', loginResponsereport.body);
                  prefs.setString(
                      SPKeys.userData, pri ? loginResponsereport.body : alternateRes.body);
                  prefs.setString(
                      LSKeys.userDetail, pri ? loginResponsereport.body : alternateRes.body);
                }
              }
            }

            var decodedResponse = pri ? jsonDecode(loginResponse.body) : tokenResponse;
            Login reponseToken =
                Login.fromJson(pri ? jsonDecode(loginResponse.body) : tokenResponse);
            apikey = reponseToken.apiToken;
            String iHLUserToken = decodedResponse['Token'];
            String iHLUserId = decodedResponse['User']['id'];
            //for user count
            try {
              Response res = await dio.post(
                "${API.iHLUrl}/ihlanalytics/store_and_update_login_user_record",
                data: json.encode({
                  "ihl_user_id": iHLUserId, //mandatory
                  "login_type": isSso ? "sso" : "password", // sso, password  //mandatory
                  "login_source": "mobile"
                }),
              );

              if (res.statusCode == 200) {
                print('USER COUNT ADDED =========> + 1');
              } else {
                print('USER COUNT NOT ADDED =========>');
              }
            } catch (e) {
              print(e);
            }

            prefs.setString("ihlUserId", iHLUserId);
            API.headerr = {};
            API.headerr['Token'] = iHLUserToken;
            API.headerr['ApiToken'] =
                '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${API.headerr}");
            http.Client client1 = http.Client(); //3gb
            localSotrage.write(LSKeys.logged, true);

            final http.Response getPlatformData = await client1.post(
              Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              },
              body: jsonEncode(<String, bool>{'cache': true}),
            );
            if (getPlatformData.statusCode == 200) {
              final SharedPreferences platformData = await SharedPreferences.getInstance();
              platformData.setString(SPKeys.platformData, getPlatformData.body);
            }
            http.Client client2 = http.Client(); //3gb
            final http.Response userProfileImage = await client2.post(
              Uri.parse('$iHLUrl/data/user/$iHLUserId/photo'),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              },
              // headers: {
              //   'Content-Type': 'application/json',
              //   'Token': iHLUserToken,
              //   'ApiToken': apiToken,
              //   'Accept': 'application/json'
              // },
              body: jsonEncode(<String, String>{'photo_data': AvatarImage.defaultAva}),
            );
            if (userProfileImage.statusCode == 200) {
              PhotoChangeNotifier.photo.value = AvatarImage.defaultAva;
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
      } else {
        throw Exception('failed');
      }
    }
  }
}
