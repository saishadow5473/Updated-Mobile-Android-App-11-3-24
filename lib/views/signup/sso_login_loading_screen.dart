import 'dart:convert';
import 'dart:developer';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/api.dart';
import '../../new_design/app/utils/localStorageKeys.dart';
import '../../new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../new_design/data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';
import '../../new_design/presentation/pages/basicData/functionalities/percentage_calculations.dart';
import '../../new_design/presentation/pages/basicData/models/basic_data.dart';
import '../../new_design/presentation/pages/profile/updatePhoto.dart';
import '../../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/spKeys.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../utils/SpUtil.dart';

class SsoLoginLoadingScreen extends StatefulWidget {
  String signInType, ssoToken;
  bool login;
  var resp;
  SsoLoginLoadingScreen({Key key, this.signInType, this.login, this.ssoToken, this.resp})
      : super(key: key);

  @override
  State<SsoLoginLoadingScreen> createState() => _SsoLoginLoadingScreenState();
}

class _SsoLoginLoadingScreenState extends State<SsoLoginLoadingScreen> {
  var _userId;
  bool _userAccVerify = false, _userAffliation = false;
  final String _authToken =
      "GHG5118RtDtd7C9AXHa9d/i0WDated53MlFmHgDK4n+8s86uo2s4HMvJkWCbKM5485lCRsBc6uTSlUuuzbWMGsJV3q+PEmAfvoVmjF8bKUgBAA==";
  @override
  void initState() {
    asyncFunction();
    super.initState();
  }

  asyncFunction() async {
    await login(widget.ssoToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.only(top: 30.sp, bottom: 15.sp, left: 20.sp),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello.',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: .5),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      'Welcome Onboard',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w300,
                        fontSize: 17,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
                SizedBox(
                  height: 80.sp,
                  child: Center(
                    child: Image.asset(
                      "assets/gif/onboardingGIF.gif",
                      height: 60.sp,
                      width: 60.sp,
                    ),
                  ),
                ),
                SizedBox(
                  height: 11.sp,
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  String signInType = '';

  bool isFetching = false;
  final http.Client _client = http.Client();
  Future login(String ssoToken) async {
    isFetching = true;
    signInType = widget.signInType;
    var response1 = widget.resp;
    setState(() {});

    log('SSO Token$ssoToken');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = ssoToken;
    if (widget.login) {
      SpUtil.putString('sso_token', ssoToken);

      var res = jsonDecode(response1.body);

      http.Response resp;
      bool loginRes = true;
      if (res['response'] == 'user already has an primary account in this email') {
        _userId = res['id'];
        loginRes = false;
        resp = await _client.post(
          Uri.parse('${API.iHLUrl}/login/get_user_login'),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken':
                "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA=="
          },
          body: jsonEncode({"id": _userId}),
        );

        print(resp.body);
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (loginRes) {
        prefs.setString('data', response1.body);
      } else {
        prefs.setString('data', resp.body.toString());
      }

      prefs.setString(SPKeys.is_sso, "true");

      //prefs.setString('email', email);
      var decodedResponse = loginRes ? jsonDecode(response1.body) : jsonDecode(resp.body);
      prefs.setString('UserIDSso', decodedResponse['User']['id'].toString());
      prefs.setBool('isSSoUser', true);
      String iHLUserToken = decodedResponse['Token'];
      String iHLUserId = decodedResponse['User']['id'];
      localSotrage.write(LSKeys.ihlUserId, iHLUserId);
      String userEmail = decodedResponse['User']['email'];
      prefs.setString('email', userEmail);
      prefs.setString('emailM', userEmail);
      localSotrage.write(LSKeys.email, userEmail);
      bool introDone = decodedResponse['User']['introDone'] ?? false;
      var b64Image = decodedResponse['User']["photo"] ?? AvatarImage.defaultAva;

      if (b64Image != null) {
        // Uint8List imagB64 = await base64Decode(b64Image);
        // localSotrage.write(LSKeys.imageMemory, b64Image);
        SpUtil.putString(LSKeys.imageMemory, b64Image);
        PhotoChangeNotifier.photo.value = b64Image;
        PhotoChangeNotifier.photo.notifyListeners();
      }

      BasicDataModel basicData;
      try {
        basicData = BasicDataModel(
          name: '${decodedResponse['User']['firstName']} ${decodedResponse['User']['lastName']}',
          dob: decodedResponse['User'].containsKey('dateOfBirth')
              ? decodedResponse['User']['dateOfBirth'].toString()
              : null,
          gender: decodedResponse['User'].containsKey('gender')
              ? decodedResponse['User']['gender'].toString()
              : null,
          height: decodedResponse['User'].containsKey("heightMeters")
              ? decodedResponse['User']["heightMeters"].toString()
              : null,
          mobile: decodedResponse['User'].containsKey("mobileNumber")
              ? decodedResponse['User']['mobileNumber'].toString()
              : null,
          weight: decodedResponse['User'].containsKey("userInputWeightInKG")
              ? decodedResponse['User']['userInputWeightInKG'].toString()
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
      API.headerr = {};

      prefs.setString('auth_token',
          "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA==");
      API.headerr['Token'] = iHLUserToken;
      API.headerr['ApiToken'] =
          "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA==";
      print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${API.headerr}");
      localSotrage.write(LSKeys.logged, true);
      try {
        if (loginRes) {
          await MyvitalsApi().vitalDatas(json.decode(response1.body));
        } else {
          await MyvitalsApi().vitalDatas(json.decode(resp.body));
        }
      } catch (e) {
        print(e);
      }

      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      prefs1.setString("ihlUserId", iHLUserId);
      final http.Response getPlatformData = await _client.post(
        Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: jsonEncode(<String, dynamic>{"ihl_id": iHLUserId, 'cache': "true"}),
      );
      if (getPlatformData.statusCode == 200) {
        final SharedPreferences platformData = await SharedPreferences.getInstance();
        platformData.setString(SPKeys.platformData, getPlatformData.body);
      }
      final http.Response vitalData = await _client.get(
        Uri.parse('${API.iHLUrl}/data/user/$iHLUserId/checkin'),
        headers: {
          'Content-Type': 'application/json',
          'Token': iHLUserToken,
          'ApiToken': _authToken
        },
      );
      Map<String, dynamic> userAffiliationDetail;

      // Object userData = prefs.get(SPKeys.userData);
      dynamic dat = loginRes ? response1.body : resp.body;
      print(dat);
      Map userDecodeData;
      try {
        userDecodeData = jsonDecode(dat);
      } catch (e) {
        print(e);
        print(prefs.get(SPKeys.email));
        print(prefs.get(SPKeys.email));
      }

      final http.Response affiliationDetails = await _client.post(
        Uri.parse("${API.iHLUrl}/sso/affiliation_details"),
        body: jsonEncode(<String, String>{'email': prefs.get(SPKeys.email)}),
      );
      if (affiliationDetails.statusCode == 200) {
        var tokenParse = jsonDecode(affiliationDetails.body);
        userAffiliationDetail = {
          "company_name": tokenParse['response']['company_name'],
          "affiliation_unique_name": tokenParse['response']['affiliation_unique_name']
        };
      }

      http.Response userAffiliationDetailCheck = await _client.post(
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
      if (userAffiliationDetailCheck.statusCode == 200) {
        var finalResponse = json.decode(userAffiliationDetailCheck.body);
        final vitalDatas =
            await SplashScreenApiCalls().checkinData(ihlUID: iHLUserId, ihlUserToken: iHLUserToken);
        prefs1.setString(SPKeys.vitalsData, vitalDatas);
        try {
          await MyvitalsApi().vitalDatas(finalResponse);
        } catch (e) {
          print(e);
        }

        if (iHLUserId == finalResponse['User']['id']) {
          API.headerr['ApiToken'] =
              '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
          API.headerr['Token'] = finalResponse['Token'];
          _userAccVerify = true;
          Map userMap = finalResponse['User'];
          bool affiliationAdded = false;
          if (userMap.containsKey('user_affiliate')) {
            Map userMapAffiliate = finalResponse['User']['user_affiliate'];

            for (int count = 1; count <= 9; count++) {
              if (userMapAffiliate.containsKey('af_no$count')) {
                var affiliateData = userMapAffiliate['af_no$count'];

                if (affiliateData['affilate_unique_name'] == null ||
                    affiliateData['affilate_unique_name'] == '' &&
                        affiliateData['affilate_name'] == null ||
                    affiliateData['affilate_name'] == '') {
                  http.Response updateProfile;
                  try {
                    updateProfile =
                        await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                            headers: {
                              'Content-Type': 'application/json',
                              'ApiToken': API.headerr['ApiToken'],
                              'Token': API.headerr['Token']
                            },
                            body: jsonEncode(<String, dynamic>{
                              "id": iHLUserId,
                              "user_affiliate": {
                                "af_no$count": {
                                  "affilate_unique_name":
                                      userAffiliationDetail['affiliation_unique_name'],
                                  "affilate_name": userAffiliationDetail['company_name'],
                                  "affilate_email": prefs.get(SPKeys.email),
                                  "affilate_mobile": userDecodeData['User']['mobileNumber'],
                                  "affliate_identifier_id": "",
                                  "is_sso": true,
                                }
                              }
                            }));
                  } catch (e) {
                    print(e);
                  }

                  print(updateProfile.body);

                  if (updateProfile.statusCode == 200) {
                    final http.Response ssoCount =
                        await _client.post(Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                            headers: {
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode(<String, dynamic>{
                              "email": prefs.get(SPKeys.email),
                              "affiliation_unique_name":
                                  userAffiliationDetail['affiliation_unique_name'],
                              "mobileNumber": userDecodeData['User']['mobileNumber'],
                              "company_name": userAffiliationDetail['company_name'],
                              "firstName": userDecodeData['User']['firstName'],
                              "lastName": userDecodeData['User']['lastName'],
                              "ihl_user_id": iHLUserId,
                            }));
                    if (ssoCount.statusCode == 200) {
                      print('Count Added');
                    }
                    _userAffliation = true;

                    break;
                  } else {
                    _userAffliation = true;
                  }
                } else {
                  if (affiliateData['affilate_unique_name'] ==
                          userAffiliationDetail['affiliation_unique_name'] &&
                      affiliateData['affilate_name'] == userAffiliationDetail['company_name']) {
                    if (affiliateData['affilate_email'] == prefs.get(SPKeys.email) &&
                        affiliateData['is_sso'] == true) {
                      break;
                    } else {
                      final http.Response updateProfile =
                          await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                              headers: {
                                'Content-Type': 'application/json',
                                'ApiToken': API.headerr['ApiToken'],
                                'Token': API.headerr['Token']
                              },
                              body: jsonEncode(<String, dynamic>{
                                "id": iHLUserId,
                                "user_affiliate": {
                                  "af_no$count": {
                                    "affilate_unique_name":
                                        userAffiliationDetail['affiliation_unique_name'],
                                    "affilate_name": userAffiliationDetail['company_name'],
                                    "affilate_email": prefs.get(SPKeys.email),
                                    "affilate_mobile": userDecodeData['User']['mobileNumber'],
                                    "affliate_identifier_id": "",
                                    "is_sso": true,
                                  }
                                }
                              }));
                      print(updateProfile.body);

                      if (updateProfile.statusCode == 200) {
                        final http.Response ssoCount = await _client.post(
                            Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                            headers: {
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode(<String, dynamic>{
                              "email": prefs.get(SPKeys.email),
                              "affiliation_unique_name":
                                  userAffiliationDetail['affiliation_unique_name'],
                              "mobileNumber": userDecodeData['User']['mobileNumber'],
                              "company_name": userAffiliationDetail['company_name'],
                              "firstName": userDecodeData['User']['firstName'],
                              "lastName": userDecodeData['User']['lastName'],
                              "ihl_user_id": iHLUserId,
                            }));
                        if (ssoCount.statusCode == 200) {
                          print('Count Added');
                        }
                        _userAffliation = true;

                        break;
                      } else {
                        _userAffliation = true;
                      }
                    }
                    print('Same');
                    break;
                  }
                }
              } else {
                if (affiliationAdded == false) {
                  final http.Response updateProfile =
                      await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                          headers: {
                            'Content-Type': 'application/json',
                            'ApiToken': API.headerr['ApiToken'],
                            'Token': API.headerr['Token']
                          },
                          body: jsonEncode(<String, dynamic>{
                            "id": iHLUserId,
                            "user_affiliate": {
                              "af_no$count": {
                                "affilate_unique_name":
                                    userAffiliationDetail['affiliation_unique_name'],
                                "affilate_name": userAffiliationDetail['company_name'],
                                "affilate_email": prefs.get(SPKeys.email),
                                "affilate_mobile": userDecodeData['User']['mobileNumber'],
                                "affliate_identifier_id": "",
                                "is_sso": true,
                              }
                            }
                          }));
                  print(updateProfile.body);

                  if (updateProfile.statusCode == 200) {
                    final http.Response ssoCount =
                        await _client.post(Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                            headers: {
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode(<String, dynamic>{
                              "email": prefs.get(SPKeys.email),
                              "affiliation_unique_name":
                                  userAffiliationDetail['affiliation_unique_name'],
                              "mobileNumber": userDecodeData['User']['mobileNumber'],
                              "company_name": userAffiliationDetail['company_name'],
                              "firstName": userDecodeData['User']['firstName'],
                              "lastName": userDecodeData['User']['lastName'],
                              "ihl_user_id": iHLUserId,
                            }));
                    if (ssoCount.statusCode == 200) {
                      print('Count Added');
                    }
                    affiliationAdded = true;

                    print(updateProfile.body);
                    _userAffliation = true;
                  } else {
                    _userAffliation = true;
                  }
                }
                break;
              }
            }
            print(userMap);
            SpUtil.putString(LSKeys.userDetail, userAffiliationDetailCheck.body);
            print('Already');
          } else {
            final http.Response updateProfile =
                await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                    headers: {
                      'Content-Type': 'application/json',
                      'ApiToken': API.headerr['ApiToken'],
                      'Token': API.headerr['Token']
                    },
                    body: jsonEncode(<String, dynamic>{
                      "id": iHLUserId,
                      "user_affiliate": {
                        "af_no1": {
                          "affilate_unique_name": userAffiliationDetail['affiliation_unique_name'],
                          "affilate_name": userAffiliationDetail['company_name'],
                          "affilate_email": prefs.get(SPKeys.email),
                          "affilate_mobile": userDecodeData['User']['mobileNumber'],
                          "affliate_identifier_id": "",
                          "is_sso": true,
                        }
                      }
                    }));
            print(updateProfile.body);

            if (updateProfile.statusCode == 200) {
              final http.Response ssoCount =
                  await _client.post(Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                      headers: {
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode(<String, dynamic>{
                        "email": prefs.get(SPKeys.email),
                        "affiliation_unique_name": userAffiliationDetail['affiliation_unique_name'],
                        "mobileNumber": userDecodeData['User']['mobileNumber'],
                        "company_name": userAffiliationDetail['company_name'],
                        "firstName": userDecodeData['User']['firstName'],
                        "lastName": userDecodeData['User']['lastName'],
                        "ihl_user_id": iHLUserId,
                      }));
              if (ssoCount.statusCode == 200) {
                print('Count Added');
              }
              affiliationAdded = true;

              print(updateProfile.body);
              _userAffliation = true;
            } else {
              _userAffliation = true;
            }
          }
        } else {
          _userAccVerify = false;
        }
      } else {
        _userAccVerify = false;
      }

      if (vitalData.statusCode == 200) {
        final SharedPreferences sharedUserVitalData = await SharedPreferences.getInstance();
        sharedUserVitalData.setString(SPKeys.vitalsData, vitalData.body);

        prefs.setString('disclaimer', 'no');
        prefs.setString('refund', 'no');
        prefs.setString('terms', 'no');
        prefs.setString('grievance', 'no');
        prefs.setString('privacy', 'no');
      }
      if (mounted) {
        setState(() {
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => HomeScreen(
          //               introDone: introDone,
          //             )),
          //     (Route<dynamic> route) => false);

          Get.offAll(LandingPage());
        });
      }
    }
  }
}
