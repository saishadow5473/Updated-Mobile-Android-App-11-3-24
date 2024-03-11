import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../../constants/api.dart';
import '../../../../../repositories/api_register.dart';
import '../../../../../repositories/getuserData.dart';
import '../../../../../utils/SpUtil.dart';
import '../../../../../views/teleconsultation/new_speciality_type_screen.dart';
import '../../../../app/utils/localStorageKeys.dart';
import '../../../../data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../functionalities/percentage_calculations.dart';
import '../functionalities/update_call.dart';
import '../models/basic_data.dart';
import '../screens/AlternateEmail.dart';
import '../../home/landingPage.dart';
import '../../../../../constants/spKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/utils/appColors.dart';
import '../functionalities/draft_data.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

import '../functionalities/mobile_otp.dart';
import 'package:http/http.dart' as http;

import 'MobileNumber.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final bool primaryEmail, fromAlternateEmail, frompersonal;

  const OtpVerificationScreen(
      {Key key, this.mobileNumber, this.primaryEmail, this.fromAlternateEmail, this.frompersonal})
      : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool isLoading = false;
  GetStorage box = GetStorage();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var mobile;
  String otp = '';
  String responseOtp = '';
  DraftData saveData = DraftData();
  String isSSo;

  @override
  void initState() {
    genOtp();
    checkIsSSO();
    super.initState();
  }

  genOtp() async {
    String mobile = '';
    if (widget.mobileNumber != '') {
      mobile = widget.mobileNumber;
    } else {
      mobile = saveData.phoneNumber;
    }
    responseOtp = await OtpHandle().generateOtp(mobile);
    setState(() {});
  }

  checkIsSSO() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isSSo = prefs.get(
      SPKeys.is_sso,
    );
    if (isSSo == null) {
      isSSo = 'false';
    } else {
      isSSo = 'true';
    }
    print(isSSo.toString());
    print(isSSo.toString());
  }

  bool inProgress = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController otpInput = TextEditingController();
    DraftData saveData = DraftData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryAccentColor,
        title: const Text('Enter the OTP'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 28.sp,
          ),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 18.sp,
              ),
              Center(
                child: Image.asset(
                  'assets/images/Group 25.png',
                  height: 20.h,
                  width: 45.w,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 18.sp,
              ),
              Padding(
                padding: EdgeInsets.all(15.sp),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'OTP VERIFICATION',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF19a9e5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.sp, bottom: 8.sp, left: 12.sp, right: 12.sp),
                child: Text(
                  'Enter the OTP received on mobile number',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                      color: const Color.fromARGB(255, 87, 87, 87),
                      fontWeight: FontWeight.w300),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.sp),
                child: Text(
                  widget.mobileNumber.toString().replaceRange(2, 8, "******"),
                  style: TextStyle(
                      letterSpacing: 4.0,
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                      color: const Color.fromARGB(255, 87, 87, 87),
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.sp),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'One Time Password',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      color: const Color.fromARGB(255, 83, 83, 83),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Form(
                key: formKey,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 24.sp),
                    child: PinCodeTextField(
                      controller: otpInput,
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      obscureText: true,
                      obscuringCharacter: '*',

                      // obscuringWidget: const FlutterLogo(
                      //   size: 24,
                      // ),
                      blinkWhenObscuring: true,
                      //animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          // borderRadius: BorderRadius.circular(5),
                          fieldHeight: 48,
                          fieldWidth: 48,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: const Color.fromARGB(255, 228, 227, 227),
                          activeColor: Colors.black,
                          inactiveColor: const Color.fromARGB(255, 99, 99, 99)),
                      cursorColor: Colors.black,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      //  errorAnimationController: errorController,
                      //  controller: textEditingController,
                      keyboardType: TextInputType.number,
                      // boxShadows: const [
                      //   BoxShadow(
                      //     offset: Offset(0, 1),
                      //     color: Colors.black12,
                      //     blurRadius: 10,
                      //   )
                      // ],
                      onCompleted: (String v) {
                        debugPrint("Completed");
                      },
                      validator: (String v) {
                        if (v.length != 6) {
                          return "Invalid Otp";
                        } else {
                          return null;
                        }
                      },
                      onChanged: (String value) {
                        setState(() {
                          otp = value;
                        });
                      },
                      beforeTextPaste: (String text) {
                        debugPrint("Allowing to paste $text");
                        return true;
                      },
                    )),
              ),
              SizedBox(
                height: 6.h,
              ),
              GestureDetector(
                onTap: () async {
                  inProgress = true;
                  setState(() {});
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  if (otp == prefs.getString('OtpProfile')) {
                    if (prefs.getBool('isSSoUser') ?? false) {
                      Get.to(AlternateEmailScreen(isSSo: prefs.getBool('isSSoUser')));
                    }
                    if (widget.frompersonal ?? false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryAccentColor,
                          content: Text('Profile Successfully Updated'),
                        ),
                      );
                      Get.to(NewSpecialtiyTypeScreen());
                    } else {
                      String res = await ProfileUpdate().userProfileEditAPI(
                          dob: prefs.getString('DobM'),
                          gender: prefs.getString('GenderM'),
                          height: prefs.getString('HeightM'),
                          mobileNumber: widget.mobileNumber,
                          weight: prefs.getString('WeightM'));
                      print(res);
                      inProgress = false;
                      setState(() {});
                      UpdatingColorsBasedOnAffiliations.sso ? null : Get.off(LandingPage());
                    }
                  } else {
                    Get.showSnackbar(
                      const GetSnackBar(
                        title: "Error occurred!!",
                        message: 'Wrong OTP',
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                  inProgress = false;
                  setState(() {});
                },
                child: Container(
                  height: 7.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                      color: const Color(0xFF19a9e5), borderRadius: BorderRadius.circular(6.sp)),
                  child: inProgress
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Center(
                          child: Text(
                          'VERIFY & PROCEED',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  final http.Client _client = http.Client();

  Future _checkUserAndUpdate() async {
    bool userAccVerify = false;
    bool userAffliation = false;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String dob = prefs.getString('DobM');
    String gender = prefs.getString('GenderM');
    String height = prefs.getString('HeightM');
    String mobileNumber = prefs.getString('MobileM');
    String weight = prefs.getString('WeightM');
    String ihlUserID = prefs.getString('UserIDSso');
    bool isSSo = prefs.getBool('isSSoUser');
    String userId;
    print(ihlUserID);
    var resEmail;
    http.Response userDetailResponse = await _client.post(
        Uri.parse(
          '${API.iHLUrl}/login/get_user_login',
        ),
        body: jsonEncode(
          <String, dynamic>{
            "id": ihlUserID,
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
      if (ihlUserID == finalResponse['User']['id'] || isSSo) {
        if (isSSo) {
          userId = ihlUserID;
        } else {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          print(finalResponse['User']['email']);
          // prefs.setString('email', finalResponse['User']['email']);
          // resEmail = finalResponse['User']['email'];
          // localSotrage.write(LSKeys.email, finalResponse['User']['email']);
        }

        API.headerr['ApiToken'] =
            '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
        API.headerr['Token'] = finalResponse['Token'];
        userAccVerify = true;
      } else {
        userAccVerify = false;
      }
    } else {
      userAccVerify = false;
    }
    if (userAccVerify) {
      userId = ihlUserID;
      // _loadingText = 'Updating Email..!';
      // setState(() => _2ndBox = true);
      dynamic updateProfile1;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      String jsontextM =
          '{"mobileNumber": "$mobileNumber","personal_email":"${widget.mobileNumber}","id": "$userId","mobileNumber": "$mobileNumber", "dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
      String jsontext =
          '{"id": "$userId","personal_email":"${widget.mobileNumber}","mobileNumber": "$mobileNumber","dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
      if (widget.primaryEmail) {
        jsontextM =
            '{"mobileNumber": "$mobileNumber","email":"${widget.mobileNumber}","personal_email":true,"id": "$userId","mobileNumber": "$mobileNumber", "dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
        jsontext =
            '{"id": "$userId","email":"${widget.mobileNumber}","personal_email":true,"mobileNumber": "$mobileNumber","dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
      }
      try {
        final Dio dio = Dio();
        updateProfile1 = await dio.post(
          '${API.iHLUrl}/data/user/$userId',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': API.headerr['ApiToken'],
              'Token': API.headerr['Token']
            },
          ),
          data: isSSo
              ? mobileSkipped
                  ? jsontext
                  //  jsonEncode(
                  //     <String, dynamic>{
                  //       "id": userId,
                  //       'personal_email': email.text,
                  //       'email': SpUtil.getString('email'),
                  //       'dateOfBirth': dob,
                  //       'heightMeters': height,
                  //       'gender': gender,
                  //       'userInputWeightInKG': weight
                  //     },
                  //   )
                  : jsontextM
              // jsonEncode(
              //     <String, dynamic>{
              //       "id": userId,
              //       'personal_email': email.text,
              //       'email': SpUtil.getString('email'),
              //       'mobileNumber': mobileNumber,
              //       'dateOfBirth': dob,
              //       'heightMeters': height,
              //       'gender': gender,
              //       'userInputWeightInKG': weight
              //     },
              //   )
              : {
                  "id": userId,
                  'personal_email': widget.mobileNumber,
                },
        );
        print(updateProfile1.data);
      } catch (e) {
        print(e);
      }
      if (updateProfile1.statusCode == 200) {
        // setState(() {
        //   _loadingText = 'Updating....!';
        //   _loadingValue = 0.4;
        // });
        print('SSo token ${SpUtil.getString('sso_token')}');

        http.Response loginResponsereport = await _client.post(
          Uri.parse('${API.iHLUrl}/sso/login_sso_user_account_v1'),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken':
                "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
          },
          body: gType == 'okta'
              ? jsonEncode(<String, String>{
                  'sso_token': SpUtil.getString('sso_token'),
                  "sso_type": gType,
                  'email': prefs.getString('OktaEmail')
                })
              : jsonEncode(
                  <String, String>{'sso_token': SpUtil.getString('sso_token'), "sso_type": gType}),
        );
        print('loginResponsereport  ${loginResponsereport.body}');
        if (loginResponsereport.statusCode == 200) {
          http.Response resp;
          var res1 = jsonDecode(loginResponsereport.body);

          bool loginRes = true;
          if (res1['response'] == 'user already has an primary account in this email') {
            var userId0 = res1['id'];
            loginRes = false;
            resp = await _client.post(
              Uri.parse('${API.iHLUrl}/login/get_user_login'),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken':
                    "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA=="
              },
              body: jsonEncode({"id": userId0}),
            );
            loginResponsereport = resp;
            print(resp.body);
          }
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(SPKeys.userData, loginResponsereport.body);
          var res = json.decode(loginResponsereport.body);
          API.headerr['Token'] = res['Token'];
          prefs.setString('ihlUserId', res['User']['id']);
          prefs.setString(SPKeys.is_sso, 'true');
          BasicDataModel basicData;
          prefs.setString('data', loginResponsereport.body);
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
        } else {
          print('Error');
        }
        final http.Response getPlatformData = await _client.post(
          Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken':
                "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
            'Token': '${API.headerr['Token']}',
          },
          body: jsonEncode(<String, bool>{'cache': true}),
        );
        // _loadingText = 'Check Affiliation';
        // setState(() => _3rdBox = true);
        if (getPlatformData.statusCode == 200) {
          final SharedPreferences platformData = await SharedPreferences.getInstance();
          platformData.setString(SPKeys.platformData, getPlatformData.body);
        } else {
          print(getPlatformData.body);
        }
      } else {
        print('Updated False');
      }
      Map<String, dynamic> userAffiliationDetail;
      final SharedPreferences prefs1 = await SharedPreferences.getInstance();
      Object userData = prefs.get(SPKeys.userData);
      Map userDecodeData = jsonDecode(userData);
      var emailfromres = userDecodeData['User']['email'];
      try {
        final http.Response affiliationDetails = await _client.post(
          Uri.parse("${API.iHLUrl}/sso/affiliation_details"),
          body: jsonEncode(<String, String>{'email': prefs1.get(SPKeys.email) ?? emailfromres}),
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
      http.Response userAffiliationDetailCheck = await _client.post(
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
      print(userAffiliationDetailCheck.body);
      if (userAffiliationDetailCheck.statusCode == 200) {
        // setState(() {
        //   _4thBox = true;
        //   _loadingText = 'Adding Affiliations..!';
        //   _loadingValue = 0.8;
        // });
        var finalResponse = json.decode(userAffiliationDetailCheck.body);
        print(finalResponse);
        if (userId == finalResponse['User']['id']) {
          API.headerr['ApiToken'] =
              '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
          API.headerr['Token'] = finalResponse['Token'];
          userAccVerify = true;
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
                  final http.Response updateProfile =
                      await _client.post(Uri.parse('${API.iHLUrl}/data/user/$userId'),
                          headers: {
                            'Content-Type': 'application/json',
                            'ApiToken': API.headerr['ApiToken'],
                            'Token': API.headerr['Token']
                          },
                          body: jsonEncode(<String, dynamic>{
                            "id": userId,
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
                    await _login(userId);
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
                              "ihl_user_id": userId,
                            }));
                    if (ssoCount.statusCode == 200) {
                      print('Count Added');
                    }
                    userAffliation = true;

                    break;
                  } else {
                    userAffliation = true;
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
                          await _client.post(Uri.parse('${API.iHLUrl}/data/user/$userId'),
                              headers: {
                                'Content-Type': 'application/json',
                                'ApiToken': API.headerr['ApiToken'],
                                'Token': API.headerr['Token']
                              },
                              body: jsonEncode(<String, dynamic>{
                                "id": userId,
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
                        await _login(userId);
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
                              "ihl_user_id": userId,
                            }));
                        if (ssoCount.statusCode == 200) {
                          print('Count Added');
                        }
                        userAffliation = true;

                        break;
                      } else {
                        userAffliation = true;
                      }
                    }
                    print('Same');
                    break;
                  }
                }
              } else {
                if (affiliationAdded == false) {
                  final http.Response updateProfile =
                      await _client.post(Uri.parse('${API.iHLUrl}/data/user/$userId'),
                          headers: {
                            'Content-Type': 'application/json',
                            'ApiToken': API.headerr['ApiToken'],
                            'Token': API.headerr['Token']
                          },
                          body: jsonEncode(<String, dynamic>{
                            "id": userId,
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
                    await _login(userId);
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
                              "ihl_user_id": userId,
                            }));
                    if (ssoCount.statusCode == 200) {
                      print('Count Added');
                    }
                    affiliationAdded = true;

                    print(updateProfile.body);
                    userAffliation = true;
                  } else {
                    userAffliation = true;
                  }
                }
                break;
              }
            }
            Get.off(LandingPage());
            print('Already');
          } else {
            final http.Response updateProfile =
                await _client.post(Uri.parse('${API.iHLUrl}/data/user/$userId'),
                    headers: {
                      'Content-Type': 'application/json',
                      'ApiToken': API.headerr['ApiToken'],
                      'Token': API.headerr['Token']
                    },
                    body: jsonEncode(<String, dynamic>{
                      "id": userId,
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
              await _login(userId);
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
                        "ihl_user_id": userId,
                      }));
              if (ssoCount.statusCode == 200) {
                print('Count Added');
              }
              affiliationAdded = true;

              print(updateProfile.body);
              userAffliation = true;
              Get.off(LandingPage());
            } else {
              userAffliation = true;
            }
          }
        } else {
          userAccVerify = false;
        }
      } else {
        userAccVerify = false;
      }
    }
  }

  Future _login(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    http.Response userDetailResponse = await _client.post(
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
}

class OtpVerificationScreenSso extends StatefulWidget {
  final String mobileNumber;
  final bool primaryEmail, fromAlternateEmail, frompersonal;

  const OtpVerificationScreenSso(
      {Key key, this.mobileNumber, this.primaryEmail, this.fromAlternateEmail, this.frompersonal})
      : super(key: key);

  @override
  State<OtpVerificationScreenSso> createState() => _OtpVerificationScreenSsoState();
}

class _OtpVerificationScreenSsoState extends State<OtpVerificationScreenSso> {
  bool isLoading = false;
  GetStorage box = GetStorage();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var mobile;
  String otp = '';
  String responseOtp = '';
  DraftData saveData = DraftData();
  String isSSo;

  @override
  void initState() {
    genOtp();
    checkIsSSO();
    super.initState();
  }

  genOtp() async {
    String mobile = '';
    if (widget.mobileNumber != '') {
      mobile = widget.mobileNumber;
    } else {
      mobile = saveData.phoneNumber;
    }
    responseOtp = await OtpHandle().generateOtp(mobile);
    setState(() {});
  }

  checkIsSSO() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isSSo = prefs.get(
      SPKeys.is_sso,
    );
    if (isSSo == null) {
      isSSo = 'false';
    } else {
      isSSo = 'true';
    }
    print(isSSo.toString());
    print(isSSo.toString());
  }

  bool inProgress = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController otpInput = TextEditingController();
    DraftData saveData = DraftData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryAccentColor,
        title: const Text('Enter the OTP'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 28.sp,
          ),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 18.sp,
              ),
              Center(
                child: Image.asset(
                  'assets/images/Group 25.png',
                  height: 20.h,
                  width: 45.w,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 18.sp,
              ),
              Padding(
                padding: EdgeInsets.all(15.sp),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'OTP VERIFICATION',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF19a9e5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.sp, bottom: 8.sp, left: 12.sp, right: 12.sp),
                child: Text(
                  'Enter the OTP received on Email',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                      color: const Color.fromARGB(255, 87, 87, 87),
                      fontWeight: FontWeight.w300),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.sp),
                child: Text(
                  widget.mobileNumber.toString(),
                  style: TextStyle(
                      letterSpacing: 4.0,
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                      color: const Color.fromARGB(255, 87, 87, 87),
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.sp),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'One Time Password',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      color: const Color.fromARGB(255, 83, 83, 83),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Form(
                key: formKey,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 24.sp),
                    child: PinCodeTextField(
                      controller: otpInput,
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      obscureText: true,
                      obscuringCharacter: '*',

                      // obscuringWidget: const FlutterLogo(
                      //   size: 24,
                      // ),
                      blinkWhenObscuring: true,
                      //animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          // borderRadius: BorderRadius.circular(5),
                          fieldHeight: 48,
                          fieldWidth: 48,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: const Color.fromARGB(255, 228, 227, 227),
                          activeColor: Colors.black,
                          inactiveColor: const Color.fromARGB(255, 99, 99, 99)),
                      cursorColor: Colors.black,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      //  errorAnimationController: errorController,
                      //  controller: textEditingController,
                      keyboardType: TextInputType.number,
                      // boxShadows: const [
                      //   BoxShadow(
                      //     offset: Offset(0, 1),
                      //     color: Colors.black12,
                      //     blurRadius: 10,
                      //   )
                      // ],
                      onCompleted: (String v) {
                        debugPrint("Completed");
                      },
                      validator: (String v) {
                        if (v.length != 6) {
                          return "Invalid Otp";
                        } else {
                          return null;
                        }
                      },
                      onChanged: (String value) {
                        setState(() {
                          otp = value;
                        });
                      },
                      beforeTextPaste: (String text) {
                        debugPrint("Allowing to paste $text");
                        return true;
                      },
                    )),
              ),
              SizedBox(
                height: 6.h,
              ),
              GestureDetector(
                onTap: () async {
                  inProgress = true;
                  setState(() {});
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  if (otp == prefs.getString('OtpProfile')) {
                    await _checkUserAndUpdate();
                    // if (prefs.getBool('isSSoUser') ?? false) {
                    //   Get.to(AlternateEmailScreen(isSSo: prefs.getBool('isSSoUser')));
                    // }
                    // if (widget.frompersonal) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //       backgroundColor: AppColors.primaryAccentColor,
                    //       content: Text('Profile Successfully Updated'),
                    //     ),
                    //   );
                    //   Get.to(NewSpecialtiyTypeScreen());
                    // } else {
                    //     String res = await ProfileUpdate().userProfileEditAPI(
                    //         dob: prefs.getString('DobM'),
                    //         gender: prefs.getString('GenderM'),
                    //         height: prefs.getString('HeightM'),
                    //         mobileNumber: widget.mobileNumber,
                    //         weight: prefs.getString('WeightM'));
                    //     print(res);
                    //     inProgress = false;
                    //     setState(() {});
                    //     Get.off(LandingPage());
                    //
                    // }
                  } else {
                    Get.showSnackbar(
                      const GetSnackBar(
                        title: "Error occurred!!",
                        message: 'Wrong OTP',
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                  inProgress = false;
                  setState(() {});
                },
                child: Container(
                  height: 7.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                      color: const Color(0xFF19a9e5), borderRadius: BorderRadius.circular(6.sp)),
                  child: inProgress
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Center(
                          child: Text(
                          'VERIFY & PROCEED',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  final http.Client _client = http.Client();

  Future _checkUserAndUpdate() async {
    bool userAccVerify = false;
    bool userAffliation = false;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String dob = prefs.getString('DobM');
    String gender = prefs.getString('GenderM');
    String height = prefs.getString('HeightM');
    String mobileNumber = prefs.getString('MobileM');
    String weight = prefs.getString('WeightM');
    String ihlUserID = prefs.getString('UserIDSso');
    bool isSSo = prefs.getBool('isSSoUser');
    String userId;
    print(ihlUserID);
    var resEmail;
    http.Response userDetailResponse = await _client.post(
        Uri.parse(
          '${API.iHLUrl}/login/get_user_login',
        ),
        body: jsonEncode(
          <String, dynamic>{
            "id": ihlUserID,
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
      if (ihlUserID == finalResponse['User']['id'] || isSSo) {
        if (isSSo) {
          userId = ihlUserID;
        } else {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          print(finalResponse['User']['email']);
          // prefs.setString('email', finalResponse['User']['email']);
          // resEmail = finalResponse['User']['email'];
          // localSotrage.write(LSKeys.email, finalResponse['User']['email']);
        }

        API.headerr['ApiToken'] =
            '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
        API.headerr['Token'] = finalResponse['Token'];
        userAccVerify = true;
      } else {
        userAccVerify = false;
      }
    } else {
      userAccVerify = false;
    }
    if (userAccVerify) {
      userId = ihlUserID;
      // _loadingText = 'Updating Email..!';
      // setState(() => _2ndBox = true);
      dynamic updateProfile1;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      String jsontextM =
          '{"mobileNumber": "$mobileNumber","personal_email":"${widget.mobileNumber}","id": "$userId","mobileNumber": "$mobileNumber", "dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
      String jsontext =
          '{"id": "$userId","personal_email":"${widget.mobileNumber}","mobileNumber": "$mobileNumber","dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
      if (widget.primaryEmail) {
        jsontextM =
            '{"mobileNumber": "$mobileNumber","email":"${widget.mobileNumber}","personal_email":true,"id": "$userId","mobileNumber": "$mobileNumber", "dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
        jsontext =
            '{"id": "$userId","email":"${widget.mobileNumber}","personal_email":true,"mobileNumber": "$mobileNumber","dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
      }
      try {
        final Dio dio = Dio();
        updateProfile1 = await dio.post(
          '${API.iHLUrl}/data/user/$userId',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': API.headerr['ApiToken'],
              'Token': API.headerr['Token']
            },
          ),
          data: isSSo
              ? mobileSkipped
                  ? jsontext
                  //  jsonEncode(
                  //     <String, dynamic>{
                  //       "id": userId,
                  //       'personal_email': email.text,
                  //       'email': SpUtil.getString('email'),
                  //       'dateOfBirth': dob,
                  //       'heightMeters': height,
                  //       'gender': gender,
                  //       'userInputWeightInKG': weight
                  //     },
                  //   )
                  : jsontextM
              // jsonEncode(
              //     <String, dynamic>{
              //       "id": userId,
              //       'personal_email': email.text,
              //       'email': SpUtil.getString('email'),
              //       'mobileNumber': mobileNumber,
              //       'dateOfBirth': dob,
              //       'heightMeters': height,
              //       'gender': gender,
              //       'userInputWeightInKG': weight
              //     },
              //   )
              : {
                  "id": userId,
                  'personal_email': widget.mobileNumber,
                },
        );
        print(updateProfile1.data);
      } catch (e) {
        print(e);
      }
      if (updateProfile1.statusCode == 200) {
        // setState(() {
        //   _loadingText = 'Updating....!';
        //   _loadingValue = 0.4;
        // });
        print('SSo token ${SpUtil.getString('sso_token')}');

        http.Response loginResponsereport = await _client.post(
          Uri.parse('${API.iHLUrl}/sso/login_sso_user_account_v1'),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken':
                "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
          },
          body: gType == 'okta'
              ? jsonEncode(<String, String>{
                  'sso_token': SpUtil.getString('sso_token'),
                  "sso_type": gType,
                  'email': prefs.getString('OktaEmail')
                })
              : jsonEncode(
                  <String, String>{'sso_token': SpUtil.getString('sso_token'), "sso_type": gType}),
        );
        print('loginResponsereport  ${loginResponsereport.body}');
        if (loginResponsereport.statusCode == 200) {
          http.Response resp;
          var res1 = jsonDecode(loginResponsereport.body);

          bool loginRes = true;
          if (res1['response'] == 'user already has an primary account in this email') {
            var userId0 = res1['id'];
            loginRes = false;
            resp = await _client.post(
              Uri.parse('${API.iHLUrl}/login/get_user_login'),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken':
                    "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA=="
              },
              body: jsonEncode({"id": userId0}),
            );
            loginResponsereport = resp;
            print(resp.body);
          }
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString(SPKeys.userData, loginResponsereport.body);
          var res = json.decode(loginResponsereport.body);
          API.headerr['Token'] = res['Token'];
          prefs.setString('ihlUserId', res['User']['id']);
          prefs.setString(SPKeys.is_sso, 'true');
          BasicDataModel basicData;
          prefs.setString('data', loginResponsereport.body);
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
        } else {
          print('Error');
        }
        final http.Response getPlatformData = await _client.post(
          Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken':
                "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
            'Token': '${API.headerr['Token']}',
          },
          body: jsonEncode(<String, bool>{'cache': true}),
        );
        // _loadingText = 'Check Affiliation';
        // setState(() => _3rdBox = true);
        if (getPlatformData.statusCode == 200) {
          final SharedPreferences platformData = await SharedPreferences.getInstance();
          platformData.setString(SPKeys.platformData, getPlatformData.body);
        } else {
          print(getPlatformData.body);
        }
      } else {
        print('Updated False');
      }
      Map<String, dynamic> userAffiliationDetail;
      final SharedPreferences prefs1 = await SharedPreferences.getInstance();
      Object userData = prefs.get(SPKeys.userData);
      Map userDecodeData = jsonDecode(userData);
      var emailfromres = userDecodeData['User']['email'];
      try {
        final http.Response affiliationDetails = await _client.post(
          Uri.parse("${API.iHLUrl}/sso/affiliation_details"),
          body: jsonEncode(<String, String>{'email': prefs1.get(SPKeys.email) ?? emailfromres}),
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
      http.Response userAffiliationDetailCheck = await _client.post(
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
      print(userAffiliationDetailCheck.body);
      if (userAffiliationDetailCheck.statusCode == 200) {
        // setState(() {
        //   _4thBox = true;
        //   _loadingText = 'Adding Affiliations..!';
        //   _loadingValue = 0.8;
        // });
        var finalResponse = json.decode(userAffiliationDetailCheck.body);
        print(finalResponse);
        if (userId == finalResponse['User']['id']) {
          API.headerr['ApiToken'] =
              '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
          API.headerr['Token'] = finalResponse['Token'];
          userAccVerify = true;
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
                  final http.Response updateProfile =
                      await _client.post(Uri.parse('${API.iHLUrl}/data/user/$userId'),
                          headers: {
                            'Content-Type': 'application/json',
                            'ApiToken': API.headerr['ApiToken'],
                            'Token': API.headerr['Token']
                          },
                          body: jsonEncode(<String, dynamic>{
                            "id": userId,
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
                    await _login(userId);
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
                              "ihl_user_id": userId,
                            }));
                    if (ssoCount.statusCode == 200) {
                      print('Count Added');
                    }
                    userAffliation = true;

                    break;
                  } else {
                    userAffliation = true;
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
                          await _client.post(Uri.parse('${API.iHLUrl}/data/user/$userId'),
                              headers: {
                                'Content-Type': 'application/json',
                                'ApiToken': API.headerr['ApiToken'],
                                'Token': API.headerr['Token']
                              },
                              body: jsonEncode(<String, dynamic>{
                                "id": userId,
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
                        await _login(userId);
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
                              "ihl_user_id": userId,
                            }));
                        if (ssoCount.statusCode == 200) {
                          print('Count Added');
                        }
                        userAffliation = true;

                        break;
                      } else {
                        userAffliation = true;
                      }
                    }
                    print('Same');
                    break;
                  }
                }
              } else {
                if (affiliationAdded == false) {
                  final http.Response updateProfile =
                      await _client.post(Uri.parse('${API.iHLUrl}/data/user/$userId'),
                          headers: {
                            'Content-Type': 'application/json',
                            'ApiToken': API.headerr['ApiToken'],
                            'Token': API.headerr['Token']
                          },
                          body: jsonEncode(<String, dynamic>{
                            "id": userId,
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
                    await _login(userId);
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
                              "ihl_user_id": userId,
                            }));
                    if (ssoCount.statusCode == 200) {
                      print('Count Added');
                    }
                    affiliationAdded = true;

                    print(updateProfile.body);
                    userAffliation = true;
                  } else {
                    userAffliation = true;
                  }
                }
                break;
              }
            }
            Get.off(LandingPage());
            print('Already');
          } else {
            final http.Response updateProfile =
                await _client.post(Uri.parse('${API.iHLUrl}/data/user/$userId'),
                    headers: {
                      'Content-Type': 'application/json',
                      'ApiToken': API.headerr['ApiToken'],
                      'Token': API.headerr['Token']
                    },
                    body: jsonEncode(<String, dynamic>{
                      "id": userId,
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
              await _login(userId);
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
                        "ihl_user_id": userId,
                      }));
              if (ssoCount.statusCode == 200) {
                print('Count Added');
              }
              affiliationAdded = true;

              print(updateProfile.body);
              userAffliation = true;
              Get.off(LandingPage());
            } else {
              userAffliation = true;
            }
          }
        } else {
          userAccVerify = false;
        }
      } else {
        userAccVerify = false;
      }
    }
  }

  Future _login(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    http.Response userDetailResponse = await _client.post(
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
}
