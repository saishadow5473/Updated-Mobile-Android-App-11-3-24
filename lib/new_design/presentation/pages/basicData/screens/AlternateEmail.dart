import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/screenutil.dart';
import '../../../../data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../home/landingPage.dart';
import '../../../../../repositories/getuserData.dart';
import '../../../../../constants/spKeys.dart';
import '../../../../data/providers/network/api_provider.dart';
import '../../../../../repositories/api_register.dart';
import '../../../../../utils/SpUtil.dart';
import '../../../../app/utils/localStorageKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/utils/appColors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../functionalities/percentage_calculations.dart';
import '../functionalities/update_call.dart';
import '../models/basic_data.dart';
import 'MobileNumber.dart';
import 'OtpVerificationScreen.dart';

class AlternateEmailScreen extends StatefulWidget {
  bool isSSo;

  AlternateEmailScreen({Key key, this.isSSo}) : super(key: key);

  @override
  State<AlternateEmailScreen> createState() => _AlternateEmailScreenState();
}

class _AlternateEmailScreenState extends State<AlternateEmailScreen> {
  TextEditingController email = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  bool inProgress = false;
  bool inProgressskip = false;

  @override
  Widget build(BuildContext context) {
    bool isMail = email.text.contains(
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"), 0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryAccentColor,
        title: const Text('Alternate email - ID'),
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
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(13.sp),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 9.h,
                  ),
                  Container(
                    height: 24.h,
                    width: 100.w,
                    decoration: const BoxDecoration(
                        image: DecorationImage(image: AssetImage('newAssets/images/email.png'))),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Alternate email ID',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 36.w,
                      ),
                      widget.isSSo
                          ? GestureDetector(
                              onTap: () async {
                                inProgressskip = true;
                                setState(() {});
                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String res = await ProfileUpdate().userProfileEditAPISSO(
                                    dob: prefs.getString('DobM'),
                                    gender: prefs.getString('GenderM'),
                                    height: prefs.getString('HeightM'),
                                    mobileNumber: prefs.getString('MobileM'),
                                    weight: prefs.getString('WeightM'));
                                print(res);
                                inProgressskip = false;
                                Get.off(LandingPage());
                              },
                              child: inProgressskip
                                  ? SizedBox(
                                      height: 3.h,
                                      width: 6.w,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryAccentColor,
                                        ),
                                      ))
                                  : Row(
                                      children: [
                                        Center(
                                            child: Text(
                                          ' SKIP ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp),
                                        )),
                                        const Icon(Icons.arrow_right_alt)
                                      ],
                                    ))
                          : Container(),
                    ],
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    controller: email,
                    decoration: InputDecoration(
                      errorText: emailValidator(email.text),
                      labelStyle: TextStyle(
                          color: isMail.toString().isEmpty && !isMail ? Colors.red : Colors.blue,
                          fontSize: ScUtil().setSp(14),
                          fontWeight: FontWeight.normal),
                      labelText: 'Enter alternate email',
                    ),
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                        onTap: () async {
                          bool isMail = email.text.contains(
                              RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"),
                              0);
                          if (_formKey.currentState.validate()) {
                            if (isMail && email.text.isNotEmpty) {
                              bool check = await userExist();
                              if (check) {
                                Get.showSnackbar(
                                  const GetSnackBar(
                                    title: "Error Occured",
                                    message: "Already Used",
                                    backgroundColor: Colors.blue,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                // String res = await ProfileUpdate().userProfileEditAPI(
                                //     dob: prefs.getString('DobM'),
                                //     gender: prefs.getString('GenderM'),
                                //     height: prefs.getString('HeightM'),
                                //     mobileNumber: prefs.getString('MobileM'),
                                //     weight: prefs.getString('WeightM'));
                                inProgress = true;
                                setState(() {});
                                Get.to(OtpVerificationScreenSso(
                                    mobileNumber: email.text,
                                    primaryEmail: _primaryEmail,
                                    fromAlternateEmail: true));
                                // await _checkUserAndUpdate();
                                inProgress = false;
                                setState(() {});
                              }
                            } else {
                              Get.showSnackbar(
                                const GetSnackBar(
                                  title: "Error Occured",
                                  message: "Invalid Email Id!!",
                                  backgroundColor: AppColors.primaryColor,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                          // Get.off(LandingPage());
                        },
                        child: inProgress
                            ? SizedBox(
                                width: 22.w,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryAccentColor,
                                      borderRadius: BorderRadius.circular(5)),
                                  height: 4.h,
                                  width: 50.w,
                                  child: Center(
                                    child: SizedBox(
                                        height: 2.h,
                                        width: 4.w,
                                        child: const Center(
                                            child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ))),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    color: AppColors.primaryAccentColor,
                                    borderRadius: BorderRadius.circular(5)),
                                height: 4.h,
                                width: 40.w,
                                child: const Center(
                                    child: Text(
                                  ' PROCEED ',
                                  style: TextStyle(color: Colors.white),
                                )))),
                  ),
                ],
              ),
            ),
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
          '{"mobileNumber": "$mobileNumber","personal_email":"${email.text}","id": "$userId","mobileNumber": "$mobileNumber", "dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
      String jsontext =
          '{"id": "$userId","personal_email":"${email.text}","mobileNumber": "$mobileNumber","dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
      if (_primaryEmail) {
        jsontextM =
            '{"mobileNumber": "$mobileNumber","email":"${email.text}","personal_email":"${prefs.getBool('email')}","id": "$userId","mobileNumber": "$mobileNumber", "dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
        jsontext =
            '{"id": "$userId","email":"${email.text}","personal_email":"${prefs.getBool('email')}","mobileNumber": "$mobileNumber","dateOfBirth": "$dob","heightMeters": "$height","gender": "$gender","encryptionVersion":null,"userInputWeightInKG": "$weight"}';
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
                  'personal_email': email.text,
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

  bool userExistR = false;
  bool _primaryEmail = false;

  Future<bool> userExist() async {
    String ssotok = SpUtil.getString('sso_token');

    // Signup reponseToken = Signup.fromJson(json.decode(response.body));
    String apiToken =
        //reponseToken.apiToken ??
        'hZH2vKcf1BPjROFM/DY0XAt89wo/09DXqsAzoCQC5QHYpXttcd5DNPOkFuhrPWcyT57DFFR9MnAdRAXoVw1j5yupkl+ps7+Z1UoM6uOrTxUBAA==';
    Uri alterEmailUrl = Uri.parse('${API.iHLUrl}/sso/personal_email_check?email=${email.text}');

    final http.Response userExits = await _client.get(
      alterEmailUrl,
      headers: {'ApiToken': apiToken},
    );
    if (userExits.statusCode == 200) {
      print(userExits.body);

      var userExistStatus = json.decode(userExits.body);

      var userExistResponse = userExistStatus['status'];
      var ihlUserID = userExistStatus['id'];
      print('$userExistResponse');

      if (userExistResponse == 'email never used') {
        print('Email never Used : $userExistResponse');

        userExistR = false;
        return userExistR;
      } else if (userExistResponse == 'already used as primary email') {
        print(userExistResponse);
        print('Email already Used : $userExistResponse');
        if (mounted) {
          setState(() {
            _primaryEmail = true;
            userExistR = false;
          });
          return userExistR;
        }
      } else if (userExistResponse == 'already used as alternate email') {
        print(userExistResponse);
        print('Email already Used : $userExistResponse');

        if (mounted) {
          setState(() {
            userExistR = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            userExistR = true;
          });
        }
        // ignore: unused_local_variable
        String userExistResponse = "User already exist";
        print(userExistResponse);

        return userExistR;
      }
    } else {
      throw Exception('Authorization Failed');
    }

    return userExistR;
  }

  String emailValidator(String mail) {
    bool isMail = mail.contains(
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"), 0);
    if ((isMail)) {
      return 'Enter valid Email';
    }
  }
}
