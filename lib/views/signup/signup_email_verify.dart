import 'dart:async';
import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/painters/backgroundPanter.dart';
import 'package:ihl/repositories/api_register.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/views/screens.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../new_design/app/utils/localStorageKeys.dart';
import '../../new_design/presentation/pages/spalshScreen/splashScreen.dart';

final iHLUrl1 = API.iHLUrl;
final ihlToken1 = API.ihlToken;

class SignUpAlternateEmailVerify extends StatefulWidget {
  final String alterEmail, ihlUserID;
  final bool isSso;

  const SignUpAlternateEmailVerify(
      {Key key, @required this.alterEmail, @required this.ihlUserID, @required this.isSso})
      : super(key: key);

  @override
  _SignUpAlternateEmailVerifyState createState() => _SignUpAlternateEmailVerifyState();
}

class _SignUpAlternateEmailVerifyState extends State<SignUpAlternateEmailVerify>
    with TickerProviderStateMixin {
  final http.Client _client = http.Client(); //3gb
  TextEditingController codeController = TextEditingController();
  StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();
  String _loadingText = 'Checking Profile';

  final int _selectedImage = 0;

  bool _2ndBox = false, _3rdBox = false, _4thBox = false;

  String currentText = "";
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool hasError = false, _userAccVerify = false, _userAffliation = false, _uploading = false;
  bool otpSent = false;
  String otp, _userId;
  double _loadingValue = 0.2;
  Timer _timer;
  int counter = 30;
  var respstatus;
  var email;
  void _startTimer() {
    counter = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter > 0) {
        if (mounted) {
          setState(() {
            counter--;
          });
        }
      } else {
        _timer.cancel();
      }
    });
  }

  Future _login(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    var userDetailResponse = await _client.post(
        Uri.parse(
          '${API.iHLUrl}/login/get_user_login',
        ),
        body: jsonEncode(
          <String, dynamic>{
            "id": userId,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken':
              '69/G9PN0M1Y/ZxC9LMG4c+2qFCg+6Qfye8ci7XV53egWzXaBapR3LAVWzBX5+js5Q/Oy4CDOR/x24C/6gT5N/G98x8xd4GtBmbWNRE1YF1cBAA==',
        });
    if (userDetailResponse.statusCode == 200) {
      prefs.setString(SPKeys.userData, userDetailResponse.body);
      var res = json.decode(userDetailResponse.body);
      // TODO SSO Signup flow affiliation grey screen error
      SpUtil.putString(
          LSKeys.userDetail, jsonEncode(res['User'])); // add this line to fix that issue
      API.headerr['Token'] = res['Token'];
      prefs.setString('ihlUserId', res['User']['id']);
      prefs.setString(SPKeys.is_sso, 'true');
    } else {
      print('Error');
    }
  }

  Future _checkUserAndUpdate() async {
    setState(() => _uploading = true);

    print(API.headerr['Token']);
    _formKey.currentState.validate();

    if (currentText.length != 4 || currentText != otp) {
      errorController.add(ErrorAnimationType.shake); // Triggering error shake animation
      if (mounted) {
        setState(() {
          hasError = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          hasError = false;
        });
      }
    }
    if (_formKey.currentState.validate()) {
      print(codeController.text);
      if (otp == codeController.text) {
        print(widget.ihlUserID);

        var userDetailResponse = await _client.post(
            Uri.parse(
              '${API.iHLUrl}/login/get_user_login',
            ),
            body: jsonEncode(
              <String, dynamic>{
                "id": widget.ihlUserID,
              },
            ),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken':
                  '69/G9PN0M1Y/ZxC9LMG4c+2qFCg+6Qfye8ci7XV53egWzXaBapR3LAVWzBX5+js5Q/Oy4CDOR/x24C/6gT5N/G98x8xd4GtBmbWNRE1YF1cBAA==',
            });
        print(userDetailResponse.body);
        if (userDetailResponse.statusCode == 200) {
          var finalResponse = json.decode(userDetailResponse.body);
          print(finalResponse);
          if (widget.ihlUserID == finalResponse['User']['id'] || widget.isSso) {
            if (widget.isSso) {
              _userId = widget.ihlUserID;
            } else {
              final prefs = await SharedPreferences.getInstance();

              prefs.setString('email', finalResponse['User']['email']);
              localSotrage.write(LSKeys.email, finalResponse['User']['email']);
            }

            API.headerr['ApiToken'] =
                '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
            API.headerr['Token'] = finalResponse['Token'];
            _userAccVerify = true;
          } else {
            _userAccVerify = false;
          }
        } else {
          _userAccVerify = false;
        }
        if (_userAccVerify) {
          _userId = widget.ihlUserID;
          _loadingText = 'Updating Email..!';
          setState(() => _2ndBox = true);
          final updateProfile = await _client.post(
            Uri.parse('${API.iHLUrl}/data/user/$_userId'),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': API.headerr['ApiToken'],
              'Token': API.headerr['Token']
            },
            body: widget.isSso
                ? jsonEncode(
                    <String, dynamic>{
                      "id": _userId,
                      'personal_email': widget.alterEmail,
                      'email': SpUtil.getString('email'),
                    },
                  )
                : jsonEncode(
                    <String, dynamic>{
                      "id": _userId,
                      'personal_email': widget.alterEmail,
                    },
                  ),
          );
          print(updateProfile.body);
          if (updateProfile.statusCode == 200) {
            setState(() {
              _loadingText = 'Updating....!';
              _loadingValue = 0.4;
            });
            print('SSo token ${SpUtil.getString('sso_token')}');

            final loginResponsereport = await _client.post(
              Uri.parse('${API.iHLUrl}/sso/login_sso_user_account'),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken':
                    "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
              },
              body: jsonEncode(
                  <String, String>{'sso_token': SpUtil.getString('sso_token'), "sso_type": gType}),
            );
            print('loginResponsereport  ${loginResponsereport.body}');
            if (loginResponsereport.statusCode == 200) {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString(SPKeys.userData, loginResponsereport.body);
              var res = json.decode(loginResponsereport.body);
              API.headerr['Token'] = res['Token'];
              prefs.setString('ihlUserId', res['User']['id']);
              prefs.setString(SPKeys.is_sso, 'true');

              prefs.setString('data', loginResponsereport.body);
            } else {
              print('Error');
            }
            final getPlatformData = await _client.post(
              Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken':
                    "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
                'Token': '${API.headerr['Token']}',
              },
              body: jsonEncode(<String, bool>{'cache': true}),
            );
            _loadingText = 'Check Affiliation';
            setState(() => _3rdBox = true);
            if (getPlatformData.statusCode == 200) {
              final platformData = await SharedPreferences.getInstance();
              platformData.setString(SPKeys.platformData, getPlatformData.body);
            } else {
              print(getPlatformData.body);
            }
          } else {
            print('Updated False');
          }
          Map<String, dynamic> userAffiliationDetail;
          final prefs = await SharedPreferences.getInstance();
          var userData = prefs.get(SPKeys.userData);
          Map userDecodeData = jsonDecode(userData);
          try {
            final affiliationDetails = await _client.post(
              Uri.parse("$iHLUrl/sso/affiliation_details"),
              body: jsonEncode(<String, String>{'email': prefs.get(SPKeys.email)}),
            );

            if (affiliationDetails.statusCode == 200) {
              var tokenParse = jsonDecode(affiliationDetails.body);
              userAffiliationDetail = {
                "company_name": tokenParse['response']['company_name'],
                "affiliation_unique_name": tokenParse['response']['affiliation_unique_name']
              };
              SpUtil.putBool(LSKeys.affiliation, true);
            }
          } catch (e) {
            print(e);
          }
          var userAffiliationDetailCheck = await _client.post(
              Uri.parse(
                '${API.iHLUrl}/login/get_user_login',
              ),
              body: jsonEncode(
                <String, dynamic>{
                  "id": _userId,
                },
              ),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken':
                    '69/G9PN0M1Y/ZxC9LMG4c+2qFCg+6Qfye8ci7XV53egWzXaBapR3LAVWzBX5+js5Q/Oy4CDOR/x24C/6gT5N/G98x8xd4GtBmbWNRE1YF1cBAA==',
              });
          print(userAffiliationDetailCheck.body);
          if (userAffiliationDetailCheck.statusCode == 200) {
            setState(() {
              _4thBox = true;
              _loadingText = 'Adding Affiliations..!';
              _loadingValue = 0.8;
            });
            var finalResponse = json.decode(userAffiliationDetailCheck.body);
            print(finalResponse);
            if (_userId == finalResponse['User']['id']) {
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
                      final updateProfile =
                          await _client.post(Uri.parse('$iHLUrl/data/user/$_userId'),
                              headers: {
                                'Content-Type': 'application/json',
                                'ApiToken': API.headerr['ApiToken'],
                                'Token': API.headerr['Token']
                              },
                              body: jsonEncode(<String, dynamic>{
                                "id": _userId,
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
                        await _login(_userId);
                        final ssoCount =
                            await _client.post(Uri.parse('$iHLUrl/sso/affiliation_bulk_update'),
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
                                  "ihl_user_id": _userId,
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
                          final updateProfile =
                              await _client.post(Uri.parse('$iHLUrl/data/user/$_userId'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'ApiToken': API.headerr['ApiToken'],
                                    'Token': API.headerr['Token']
                                  },
                                  body: jsonEncode(<String, dynamic>{
                                    "id": _userId,
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
                            await _login(_userId);
                            final ssoCount =
                                await _client.post(Uri.parse('$iHLUrl/sso/affiliation_bulk_update'),
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
                                      "ihl_user_id": _userId,
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
                      final updateProfile =
                          await _client.post(Uri.parse('$iHLUrl/data/user/$_userId'),
                              headers: {
                                'Content-Type': 'application/json',
                                'ApiToken': API.headerr['ApiToken'],
                                'Token': API.headerr['Token']
                              },
                              body: jsonEncode(<String, dynamic>{
                                "id": _userId,
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
                        await _login(_userId);
                        final ssoCount =
                            await _client.post(Uri.parse('$iHLUrl/sso/affiliation_bulk_update'),
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
                                  "ihl_user_id": _userId,
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

                print('Already');
              } else {
                final updateProfile = await _client.post(Uri.parse('$iHLUrl/data/user/$_userId'),
                    headers: {
                      'Content-Type': 'application/json',
                      'ApiToken': API.headerr['ApiToken'],
                      'Token': API.headerr['Token']
                    },
                    body: jsonEncode(<String, dynamic>{
                      "id": _userId,
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
                  await _login(_userId);
                  final ssoCount =
                      await _client.post(Uri.parse('$iHLUrl/sso/affiliation_bulk_update'),
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
                            "ihl_user_id": _userId,
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
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _autoValidate = true;
        });
      }
    }
    print('${API.headerr['ApiToken']}');
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    codeController.dispose();
  }

  @override
  void initState() {
    sendOtp(context);
    super.initState();
  }

  Future<String> genOTP(email) async {
    final userExits = widget.isSso
        ? await _client.post(Uri.parse('${API.iHLUrl}/sso/get_sso_user_ihl_id'),
            body: jsonEncode(<String, String>{"email": email}))
        : await _client.get(Uri.parse(API.iHLUrl +
            "/login/send_registration_otp_verify?email=" +
            email +
            "&mobile=" +
            '' +
            "&from=mobile"));
    print(userExits.body);
    if (userExits.statusCode == 200) {
      var userExistResponse = jsonDecode(userExits.body);
      var finalresponce = userExistResponse['response'];
      try {
        if (widget.isSso) {
          if (userExits.body != null || userExits.body != "[]") {}
          respstatus = userExistResponse['response'];
          otp = finalresponce['OTP'];
          print('Otp :$otp');
          _userId = finalresponce['ihl_user_id'];
        } else {
          var output = json.decode(userExits.body);
          respstatus = output["status"];
          otp = output["OTP"];
          print(otp);
        }
      } catch (e) {}
    } else {
      throw Exception('Authorization Failed');
    }

    return otp.toString();
  }

  Future<String> test() {
    return Future.delayed(
        const Duration(
          seconds: 1,
        ),
        () => 'sent');
  }

  String message({String otp}) {
    return 'Dear IHL User, Your One Time Password for verification is: $otp';
  }

  Future<dynamic> sendMessageApi({String otp}) async {
    final resp = await _client
        .get(Uri.parse(otpServiceEndpoint(message: message(otp: otp), mobile: widget.alterEmail)));
    return resp.body;
  }

  Future<void> sendOtp(BuildContext context) async {
    if (mounted) {
      setState(() {
        otpSent = false;
      });
    }
    email = SpUtil.getString('email');
    var genotp = await genOTP(
      widget.alterEmail,
    );
    // var resp = await sendMessageApi(otp: genotp);
    if (respstatus.length > 0) {
      if (mounted) {
        setState(() {
          otpSent = true;
          otp = genotp;
          _startTimer();
          currentText = '';
          codeController.clear();
        });
      }
    } else {
      Navigator.of(context).pop(false);
    }
  }

  Widget codeTextField() {
    return PinCodeTextField(
      appContext: context,
      backgroundColor: const Color(0xffF4F6FA),
      length: 6,
      obscureText: false,
      animationType: AnimationType.fade,
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.circle,
        activeColor: const Color(0xffDBEEFC),
        inactiveColor: AppColors.primaryColor,
        activeFillColor: AppColors.primaryColor,
        fieldHeight: 50,
        fieldWidth: 40,
      ),
      validator: (v) {
        if (v.length != 6) {
          return "Invalid OTP";
        } else {
          if (v != otp) {
            return "Incorrect OTP";
          } else {
            return null;
          }
        }
      },
      animationDuration: const Duration(milliseconds: 300),
      errorAnimationController: errorController,
      controller: codeController,
      errorTextSpace: 20,
      onCompleted: (v) {},
      autoDisposeControllers: false,
      onChanged: (value) {
        if (mounted) {
          setState(() {
            currentText = value;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SafeArea(
        top: true,
        child: ConnectivityWidgetWrapper(
          disableInteraction: true,
          offlineWidget: OfflineWidget(),
          child: Scaffold(
            appBar: _uploading
                ? null
                : AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    title: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const SizedBox(
                          height: 5,
                          child: LinearProgressIndicator(
                            value: 0.5, // percent filled
                            backgroundColor: Color(0xffDBEEFC),
                          ),
                        ),
                      ),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Get.back(),
                      color: Colors.black,
                    ),
                    actions: <Widget>[
                      Visibility(
                        visible: false,
                        replacement: SizedBox(
                          width: 10.w,
                        ),
                        child: TextButton(
                          onPressed: () async {
                            print(_userId);
                            await _checkUserAndUpdate();
                            Get.off(LandingPage());
                            // old dashboard
                            /* Get.off(HomeScreen(
                              introDone: true,
                              isJointAccount: false,
                            ));*/
                          },
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(
                              color: Color(0xFF19a9e5),
                            ),
                            shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
                          ),
                          child: Text(AppTexts.next,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: ScUtil().setSp(16),
                              )),
                        ),
                      ),
                    ],
                  ),
            backgroundColor: const Color(0xffF4F6FA),
            body: _uploading
                ? Container(
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        CustomPaint(
                          painter: BackgroundPainter(
                            primary: AppColors.primaryColor.withOpacity(0.7),
                            secondary: AppColors.primaryColor.withOpacity(0.0),
                          ),
                          child: Container(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        height: 4.h,
                                        child: Text(
                                          'Please wait.. $_loadingText',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 17.sp, color: AppColors.primaryColor),
                                        ),
                                      ),
                                      TimelineTile(
                                        alignment: TimelineAlign.center,
                                        isFirst: true,
                                        indicatorStyle: IndicatorStyle(
                                          width: 30,
                                          color: Colors.green,
                                          padding: const EdgeInsets.all(8),
                                          iconStyle: IconStyle(
                                            color: Colors.white,
                                            iconData: Icons.check,
                                          ),
                                        ),
                                        beforeLineStyle: const LineStyle(
                                          color: Colors.green,
                                          thickness: 3,
                                        ),
                                        startChild: Card(
                                          margin: const EdgeInsets.symmetric(vertical: 26.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0)),
                                          clipBehavior: Clip.antiAlias,
                                          color: Colors.green[300],
                                          child: const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text(
                                              'Checking Profile',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TimelineTile(
                                        alignment: TimelineAlign.center,
                                        indicatorStyle: IndicatorStyle(
                                          width: 30,
                                          color: _2ndBox ? Colors.green : Colors.grey,
                                          padding: const EdgeInsets.all(8),
                                          iconStyle: IconStyle(
                                            color: Colors.white,
                                            iconData: Icons.check,
                                          ),
                                        ),
                                        beforeLineStyle: LineStyle(
                                          color: _2ndBox ? Colors.green : Colors.grey,
                                          thickness: 3,
                                        ),
                                        endChild: Card(
                                          margin: const EdgeInsets.symmetric(vertical: 26.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0)),
                                          clipBehavior: Clip.antiAlias,
                                          color: _2ndBox ? Colors.green[300] : Colors.amber[100],
                                          child: const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text(
                                              'Updating Email..!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TimelineTile(
                                        alignment: TimelineAlign.center,
                                        indicatorStyle: IndicatorStyle(
                                          width: 30,
                                          color: _3rdBox ? Colors.green : Colors.grey,
                                          padding: const EdgeInsets.all(8),
                                          iconStyle: IconStyle(
                                            color: Colors.white,
                                            iconData: Icons.check,
                                          ),
                                        ),
                                        beforeLineStyle: LineStyle(
                                          color: _3rdBox ? Colors.green : Colors.grey,
                                          thickness: 3,
                                        ),
                                        startChild: Card(
                                          margin: const EdgeInsets.symmetric(vertical: 26.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0)),
                                          clipBehavior: Clip.antiAlias,
                                          color: _3rdBox ? Colors.green[300] : Colors.amber[100],
                                          child: const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text(
                                              'Check Affiliation',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TimelineTile(
                                        alignment: TimelineAlign.center,
                                        isFirst: false,
                                        isLast: true,
                                        indicatorStyle: IndicatorStyle(
                                          width: 30,
                                          color: _4thBox ? Colors.green : Colors.grey,
                                          padding: const EdgeInsets.all(8),
                                          iconStyle: IconStyle(
                                            color: Colors.white,
                                            iconData: Icons.check,
                                          ),
                                        ),
                                        beforeLineStyle: LineStyle(
                                          color: _4thBox ? Colors.green : Colors.grey,
                                          thickness: 3,
                                        ),
                                        endChild: Card(
                                          margin: const EdgeInsets.symmetric(vertical: 26.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0)),
                                          clipBehavior: Clip.antiAlias,
                                          color: _4thBox ? Colors.green[300] : Colors.amber[100],
                                          child: const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text(
                                              'Adding Affiliations..!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 5.0),
                          Text(
                            AppTexts.step4,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: const Color(0xFF19a9e5),
                                fontFamily: 'Poppins',
                                fontSize: ScUtil().setSp(12),
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                height: 1.16),
                          ),
                          SizedBox(
                            height: 6 * SizeConfig.heightMultiplier,
                          ),
                          Text(
                            'Verify your Email',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: const Color.fromRGBO(109, 110, 113, 1),
                                fontFamily: 'Poppins',
                                fontSize: ScUtil().setSp(26),
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                                height: 1.33),
                          ),
                          SizedBox(
                            height: 3 * SizeConfig.heightMultiplier,
                          ),
                          otpSent
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                                      child: Text(
                                        'We have sent OTP to you on ${widget.alterEmail}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: const Color.fromRGBO(109, 110, 113, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: ScUtil().setSp(15),
                                            letterSpacing: 0.2,
                                            fontWeight: FontWeight.normal,
                                            height: 1),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                                        child: Text(
                                          'Please wait while we\'re sending OTP on ${widget.alterEmail}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: const Color.fromRGBO(109, 110, 113, 1),
                                              fontFamily: 'Poppins',
                                              fontSize: ScUtil().setSp(15),
                                              letterSpacing: 0.2,
                                              fontWeight: FontWeight.normal,
                                              height: 1),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 70),
                                        child: LinearProgressIndicator(),
                                      )
                                    ],
                                  ),
                                ),
                          AbsorbPointer(
                            absorbing: !otpSent,
                            child: Opacity(
                              opacity: otpSent ? 1 : 0,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 6 * SizeConfig.heightMultiplier,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 50),
                                    child: codeTextField(),
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  TextButton(
                                    onPressed: counter > 0
                                        ? null
                                        : () {
                                            sendOtp(context);
                                          },
                                    style: TextButton.styleFrom(
                                      textStyle: const TextStyle(
                                        color: Color(0xFF19a9e5),
                                      ),
                                      shape: const CircleBorder(
                                          side: BorderSide(color: Colors.transparent)),
                                    ),
                                    child: Text(
                                        counter > 0
                                            ? 'Please wait ${counter.toString()} seconds to request new code'
                                            : 'Send me a new code',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: ScUtil().setSp(14),
                                        )),
                                  ),
                                  SizedBox(
                                    height: 6 * SizeConfig.heightMultiplier,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                                    child: Center(
                                      child: _customButton(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _customButton() {
    return SizedBox(
      height: 60,
      child: GestureDetector(
        onTap: () async {
          print(_userId);
          await _checkUserAndUpdate();
          Get.off(LandingPage());
          // old Dashboard
          /* Get.off(HomeScreen(
            introDone: true,
            isJointAccount: false,
          ));*/
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF19a9e5),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  AppTexts.continuee,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      fontFamily: 'Poppins',
                      fontSize: ScUtil().setSp(16),
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.normal,
                      height: 1),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
