import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/rsa_encryption.dart';
import 'package:ihl/views/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool abhaRegistraion = true;
bool registrationAfterLoggedIn = false;
bool creationflowAfterLoggedIn = false;
bool abhaSkipped = false;
bool termsAndConditions = false;

class NetworkCallsAbha {
  final Dio dio = Dio();
  final box = GetStorage();
  Future getAccessToken() async {
    try {
      var response = await dio.post(
        "https://dev.abdm.gov.in/gateway/v0.5/sessions",
        data: json.encode({
          "clientId": "SBX_001197",
          "clientSecret": "1bc7860a-c42e-4cb2-85e0-f8606c22b1c5",
          "grantType": "client_credentials"
        }),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      box.write("AbhaAccessToken", response.data['accessToken']);
      box.write("AbhaRefreshToken", response.data['refreshToken']);

      return response.data;
    } catch (e) {}
  }

  Future<String> generateAadharOtp(aadharNumber) async {
    var token = box.read('AbhaAccessToken');
    try {
      var response = await dio.post(
        "https://healthidsbx.abdm.gov.in/api/v1/registration/aadhaar/generateOtp",
        data: json.encode({"aadhaar": aadharNumber.toString()}),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      print(response);
      box.write("AbhatxnId", response.data['txnId']);
      print(response.data['txnId']);
      print(response.statusCode == 200);
      if (response.statusCode == 200) {
        return 'success';
      }
    } catch (error) {
      print(error);
    }
  }

  Future<String> verifyAadharOtp(String otp) async {
    var token = box.read('AbhaAccessToken');
    var txnId = box.read('AbhatxnId');
    try {
      var response = await dio.post(
        "https://healthidsbx.abdm.gov.in/api/v1/registration/aadhaar/verifyOTP",
        data: json.encode({"otp": otp, "txnId": txnId}),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      box.write("AbhatxnId", response.data['txnId']);
      if (response.statusCode == 200) {
        return 'success';
      }
      return null;
    } on DioError catch (e) {
      if (e.type == DioErrorType.response) {
        print(e.response.data['details'][0]['message']);
        return e.response.data['details'][0]['message'];
      }
      ;
    }
  }

  Future resendOtp() async {
    var token = box.read('AbhaAccessToken');
    var txnId = box.read('AbhatxnId');
    try {
      var response = await dio.post(
        "https://healthidsbx.abdm.gov.in/api/v1/registration/aadhaar/resendAadhaarOtp",
        data: json.encode({"txnId": txnId}),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      box.write("AbhatxnId", response.data['txnId']);
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print(e);
    }
  }

  Future generateMobileOtp(mobile) async {
    var token = box.read('AbhaAccessToken');
    var txnId = box.read('AbhatxnId');
    try {
      var response = await dio.post(
        "https://healthidsbx.abdm.gov.in/api/v1/registration/aadhaar/generateMobileOTP",
        data: json.encode({"mobile": "+91" + mobile, "txnId": txnId}),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      box.write("AbhatxnId", response.data['txnId']);
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  Future checkAndGenerateMobileOtp(mobile) async {
    var token = box.read('AbhaAccessToken');
    var txnId = box.read('AbhatxnId');
    print(txnId);
    try {
      var response = await dio.post(
        "https://healthidsbx.abdm.gov.in/api/v2/registration/aadhaar/checkAndGenerateMobileOTP",
        data: json.encode({"mobile": mobile.toString(), "txnId": txnId}),
        options: Options(
          headers: {'authorization': "Bearer $token", 'Content-Type': 'application/json'},
        ),
      );
      box.write("AbhatxnId", response.data['txnId']);
      print(response.data);
      if (response.statusCode == 200) {
        return 'success';
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> verifyMobileOtp(otp) async {
    var token = box.read('AbhaAccessToken');
    var txnId = box.read('AbhatxnId');
    try {
      var response = await dio.post(
        "https://healthidsbx.abdm.gov.in/api/v1/registration/aadhaar/verifyMobileOTP",
        data: json.encode({"otp": otp, "txnId": txnId}),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      box.write("AbhatxnId", response.data['txnId']);
      if (response.statusCode == 200) {
        return 'success';
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.response) {
        print(e.response.data['details'][0]['message']);
        return e.response.data['details'][0]['message'];
      }
      ;
    }
  }

  Future<String> checkAbhaUserOrnot(String mobile) async {
    var token = box.read('AbhaAccessToken');
    var encryptedNo = RSAEncryption().encrypt(mobile);
    try {
      var response = await dio.post(
        // "https://dev.abdm.gov.in/cm/v1/apps/login/mobileEmail/auth-init",
        "https://phrsbx.abdm.gov.in/api/v1/phr/login/mobileEmail/init",
        data: json.encode({
          // "value": encryptedNo,
          // "purpose": "CM_ACCESS",
          // "authMode": "MOBILE_OTP",
          // "requester": {"type": "PHR", "id": "ihl_yog34_2023"}
          "input": encryptedNo
        }),
        options: Options(
          headers: {'authorization': "Bearer $token", 'X-HIP-ID': "ihl_yog34_2023"},
        ),
      );
      print(response.data);
      if (response.statusCode == 200) {
        box.write("AbhatxnId1", response.data['transactionId']);
        return 'success';
      }
    } catch (e) {
      print(e);
    }
  }

  Future confirmAuth(String txnid, String abha_address) async {
    var token = box.read('AbhaAccessToken');
    try {
      var response = await dio.post(
        //  "https://dev.abdm.gov.in/cm/v1/apps/login/mobileEmail/auth-confirm",
        "https://phrsbx.abdm.gov.in/api/v1/phr/login/mobileEmail/getUserToken",
        data: json.encode({
          "transactionId": txnid,
          "phrAddress": abha_address
          //"patientId": abha_address,
          //  "requesterId": "ihl_yog34_2023"
        }),
        options: Options(
          headers: {'authorization': "Bearer $token", 'X-HIP-ID': "ihl_yog34_2023"},
        ),
      );
      print(response.data);
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> loginOtpVerfication(String otp) async {
    var token = box.read('AbhaAccessToken');
    var txnId = box.read('AbhatxnId1');
    var authCode = RSAEncryption().encrypt(otp);
    print(otp);
    try {
      var response = await dio.post(
        //   "https://dev.abdm.gov.in/cm/v1/apps/login/mobileEmail/pre-Verify",
        "https://phrsbx.abdm.gov.in/api/v1/phr/login/mobileEmail/preVerification",
        data: json.encode({
          "transactionId": txnId,
          //  "authCode": authCode,
          //  "requesterId": "ihl_yog34_2023"
          "otp": authCode
        }),
        options: Options(
          headers: {'authorization': "Bearer $token", 'X-HIP-ID': "ihl_yog34_2023"},
        ),
      );
      print(response.data);
      if (response.statusCode == 200) {
        print(response.data['mappedPhrAddress'].isEmpty);
        if (response.data['mappedPhrAddress'].isEmpty) {
          return 'newUser';
        }
        if (response.data['mappedPhrAddress'].isNotEmpty) {
          box.write("AbhaMappedAccounts", response.data);
          return 'ExistingUser';
        }
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.response) {
        print(e.response.data['details'][0]['message']);
        if (e.response.data['details'][0]['message']
            .toString()
            .contains('Please enter the correct OTP')) {
          return e.response.data['details'][0]['message'];
        }
        return 'Something went wrong';
      }
      ;
    }
  }

  String generateRandomString(int length) {
    final random = Random();
    const availableChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890.';
    final randomString =
        List.generate(length, (index) => availableChars[random.nextInt(availableChars.length)])
            .join();

    return randomString;
  }

  Future<String> loginWithAbhaNumber(String abhaNumber, String password) async {
    var token = box.read('AbhaAccessToken');
    //init
    try {
      var response = await dio.post(
        "https://healthidsbx.abdm.gov.in/api/v1/auth/authPassword",
        data: json.encode({"healthId": abhaNumber, "password": password}),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      if (response.statusCode == 200) {
        var accessToken = response.data['token'];
        return accessToken;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> loginWithPassword(String patientId) async {
    var pwd = SpUtil.getString('pwd');
    var encryptedPwd = RSAEncryption().encrypt(pwd);
    var token = box.read('AbhaAccessToken');
    //init
    try {
      var response = await dio.post(
        "https://dev.abdm.gov.in/cm/v1/apps/phrAddress/auth-init",
        data: json.encode({
          "patientId": patientId,
          "purpose": "CM_ACCESS",
          "authMode": "PASSWORD",
          "requester": {"type": "PHR", "id": "ihl_yog34_2023"}
        }),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      if (response.statusCode == 200) {
        //authentication
        var transactionId = response.data['transactionId'];
        var response1 = await dio.post(
          "https://dev.abdm.gov.in/cm/v1/apps/phrAddress/auth-confirm",
          data: json.encode({
            "transactionId": transactionId,
            "authCode": encryptedPwd,
            "requesterId": "ihl_yog34_2023"
          }),
          options: Options(
            headers: {'authorization': "Bearer $token"},
          ),
        );
        var accessToken = response1.data['token'];
        return accessToken;
      }
    } catch (e) {
      print(e);
    }
  }

  Future createHealthIdWithPreVerified() async {
    bool isSSo = true;
    if (gs.read(GSKeys.isSSO) == null) {
      isSSo = false;
    }
    var token = box.read('AbhaAccessToken');
    var txnId = box.read('AbhatxnId');
    var mobileNumber = box.read('mobileNumber');
    var fname = SpUtil.getString('fname');
    var email = SpUtil.getString('email');
    var lname = SpUtil.getString('lname');
    var phoneno = SpUtil.getString('mob');
    var mobile = box.read("userMobileNumber");
    var pwd = isSSo ? "" : SpUtil.getString('pwd');
    var aadhar = SpUtil.getString('aadharNo');
    var pic = SpUtil.getString('ProfileImage');
    var healthid = (fname + mobile.toString()).substring(0, 15);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ihlUserId = prefs.get("ihlUserId");
    try {
      var response = await dio.post(
        "https://healthidsbx.abdm.gov.in/api/v1/registration/aadhaar/createHealthIdWithPreVerified",
        data: json.encode({
          "email": email,
          "firstName": fname,
          "healthId": healthid,
          "lastName": lname,
          "middleName": "",
          "password": pwd,
          "profilePhoto": pic,
          "txnId": txnId
        }),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      print(response.data);
      bool newUser = response.data['new'];
      var responseHealthId = response.data['healthId'];
      box.write("healthId", response.data['healthId']);
      box.write("abhaNumber", response.data['healthIdNumber']);
      var abhaNumber = response.data['healthIdNumber'];
      if (response.statusCode == 200) {
        var encryptedNo = RSAEncryption().encrypt(mobile);
        try {
          var response = await dio.post(
            "https://phrsbx.abdm.gov.in/api/v1/phr/login/mobileEmail/init",
            data: json.encode({'input': encryptedNo}),
            options: Options(
              headers: {'authorization': "Bearer $token", 'X-HIP-ID': "ihl_yog34_2023"},
            ),
          );
          print(response.data);
          if (response.statusCode == 200) {
            box.write("AbhatxnId1", response.data['transactionId']);
            return 'success';
          }
        } catch (e) {
          print(e);
        }
      }

      return response;
    } on DioError catch (e) {
      abhaSkipped = true;
      print(e);
      if (e.type == DioErrorType.response) {
        print(e.response.data['details'][0]['message']);
        return e.response.data['details'][0]['message'];
      }
      ;
    }
  }

  Future confirmAuthAndStoreData(otp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ihlUserId = prefs.get("ihlUserId");
    var email = SpUtil.getString('email');
    var aadhar = SpUtil.getString('aadharNo');
    var token = box.read('AbhaAccessToken');
    var txnId = box.read('AbhatxnId1');
    var healthId = box.read('healthId');
    var abhaNumber = box.read('abhaNumber');
    var authCode = RSAEncryption().encrypt(otp);
    print(otp);
    try {
      var response = await dio.post(
        "https://phrsbx.abdm.gov.in/api/v1/phr/login/mobileEmail/preVerification",
        data: json.encode({
          "transactionId": txnId, "otp": authCode,
          //"requesterId": "ihl_yog34_2023"
        }),
        options: Options(
          headers: {'authorization': "Bearer $token", 'X-HIP-ID': "ihl_yog34_2023"},
        ),
      );
      print(response.data);
      if (response.statusCode == 200) {
        print(response.data['mappedPhrAddress'].isEmpty);
        if (response.data['mappedPhrAddress'].isEmpty) {
          return 'newUser';
        }
        if (response.data['mappedPhrAddress'].isNotEmpty) {
          //  box.write("AbhaMappedAccounts", response.data);
          // return 'ExistingUser';
          var txnid = response.data['transactionId'];
          try {
            var response = await dio.post(
              "https://phrsbx.abdm.gov.in/api/v1/phr/login/mobileEmail/getUserToken",
              data: json.encode({
                "transactionId": txnid, "phrAddress": healthId,
                // "requesterId": "ihl_yog34_2023"
              }),
              options: Options(
                headers: {'authorization': "Bearer $token", 'X-HIP-ID': "ihl_yog34_2023"},
              ),
            );
            print(response.data);
            if (response.statusCode == 200) {
              box.write("token1", response.data['token']);
              //return response.data;
            }
          } catch (e) {
            print(e);
          }
        }
      }
    } catch (e) {
      print(e);
    }
    var token1 = box.read('token1');
    var abhacard;
    if (token1 != null) {
      abhacard = await getAbhaCard(token1);
    }
    if (true) {
      //newUser
      var response = await dio.post(
        "https://devserver.indiahealthlink.com/ihlabha/store_ihl_user_abha_detail",
        data: json.encode({
          "ihl_user_id": ihlUserId,
          "user_email": email, // optional
          "user_mobile": "", // optional
          "user_adhar": aadhar,
          "abha_number": abhaNumber,
          "abha_address": healthId,
          "abha_card": abhacard,
          "abha_qr_code": "",
          "self": true,
        }),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      if (response.statusCode == 200) {
        return 'success';
      }
    }
  }

  Future getProfile(token1) async {
    var token = box.read('AbhaAccessToken');
    try {
      var response = await dio.get("https://phrsbx.abdm.gov.in/api/v1/phr/profile",
          options: Options(
            headers: {'authorization': "Bearer $token", 'X-Token': "Bearer $token1"},
          ));
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  Future getAbhaCard(token1) async {
    var token = box.read('AbhaAccessToken');
    try {
      var response =
          await Dio().get<List<int>>("https://phrsbx.abdm.gov.in/api/v1/phr/profile/png/getCard",
              options: Options(
                responseType: ResponseType.bytes,
                headers: {'authorization': "Bearer $token", 'X-Token': "Bearer $token1"},
              ));
      if (response.statusCode == 200) {
        print(response.data.runtimeType);
        String base64String = base64Encode(response.data);
        print(base64String);
        return base64String;
      }
    } catch (e) {
      print(e);
    }
  }

  Future getAbhaCardx(token1) async {
    var token = box.read('AbhaAccessToken');
    try {
      var response =
          await Dio().get<List<int>>("https://phrsbx.abdm.gov.in/api/v1/phr/profile/png/getCard",
              options: Options(
                responseType: ResponseType.bytes,
                headers: {'authorization': "Bearer $token", 'X-Token': "Bearer $token1"},
              ));
      if (response.statusCode == 200) {
        print(response.data.runtimeType);
        String base64String = base64Encode(response.data);
        print(base64String);
        return base64String;
      }
    } catch (e) {
      print(e);
    }
  }

  Future getAbhaCardX(token1) async {
    var token = box.read('AbhaAccessToken');
    try {
      var response =
          await Dio().get<List<int>>("https://healthidsbx.abdm.gov.in/api/v1/account/getCard",
              options: Options(
                responseType: ResponseType.bytes,
                headers: {'authorization': "Bearer $token", 'X-Token': "Bearer $token1"},
              ));
      if (response.statusCode == 200) {
        print(response.data.runtimeType);
        String base64String = base64Encode(response.data);
        print(base64String);
        return base64String;
      }
    } catch (e) {
      print(e);
    }
  }

  Future storeAbhaDetails() async {
    //via login
    var token1 = box.read("LoginToken");
    var token = box.read('AbhaAccessToken');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ihlUserId = prefs.get("ihlUserId");
    var profileResponse = await getProfile(token1);
    var abhaNumber = profileResponse['healthIdNumber'];
    var HealthId = box.read('selectedAbhaId');
    var abhacard = await getAbhaCardx(token1);
    var _email = SpUtil.getString('email');
    try {
      var response = await dio.post(
        "https://devserver.indiahealthlink.com/ihlabha/store_ihl_user_abha_detail",
        data: json.encode({
          "ihl_user_id": ihlUserId,
          "user_email": _email, // optional
          "user_mobile": "", // optional
          "user_adhar": "", //optional
          "abha_number": abhaNumber,
          "abha_address": HealthId,
          "abha_card": abhacard,
          "abha_qr_code": "",
          "self": true,
        }),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      print(response.data);
      print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }

  Future viewAbhaCard(String abhaAdress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ihlUserId = prefs.get("ihlUserId");
    try {
      var response = await dio.get(
        "https://devserver.indiahealthlink.com/ihlabha/view_ihl_user_abha_card",
        queryParameters: {'ihl_user_id': ihlUserId, 'abha_address': abhaAdress},
      );
      if (response.statusCode == 200) {
        print(response.data);
        return response.data;
      }
    } catch (e) {
      print(e);
    }
  }

  Future viewAbhadetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ihlUserId = prefs.get("ihlUserId");

    try {
      var response = await Dio().get(
        "https://devserver.indiahealthlink.com/ihlabha/view_ihl_user_abha_detail",
        queryParameters: {
          'ihl_user_id': ihlUserId,
        },
      );
      if (response.statusCode == 200) {
        print(response.data);
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> loginWithPasswordAfterLoggedin(String patientId, String pwd) async {
    var encryptedPwd = RSAEncryption().encrypt(pwd);
    var token = box.read('AbhaAccessToken');
    try {
      var response = await dio.post(
        "https://dev.abdm.gov.in/cm/v1/apps/phrAddress/auth-init",
        data: json.encode({
          "patientId": patientId,
          "purpose": "CM_ACCESS",
          "authMode": "PASSWORD",
          "requester": {"type": "PHR", "id": "ihl_yog34_2023"}
        }),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      if (response.statusCode == 200) {
        //authentication
        var transactionId = response.data['transactionId'];
        var response1 = await dio.post(
          "https://dev.abdm.gov.in/cm/v1/apps/phrAddress/auth-confirm",
          data: json.encode({
            "transactionId": transactionId,
            "authCode": encryptedPwd,
            "requesterId": "ihl_yog34_2023"
          }),
          options: Options(
            headers: {'authorization': "Bearer $token"},
          ),
        );
        var accessToken = response1.data['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        var ihlUserId = prefs.get("ihlUserId");
        var profileResponse = await getProfile(accessToken);
        var abhaNumber = profileResponse['healthIdNumber'];
        var HealthId = profileResponse['phrAddress'];
        var abhacard = await getAbhaCard(accessToken);
        var _email = SpUtil.getString('email');
        try {
          var response = await dio.post(
            "https://devserver.indiahealthlink.com/ihlabha/store_ihl_user_abha_detail",
            data: json.encode({
              "ihl_user_id": ihlUserId,
              "user_email": _email, // optional
              "user_mobile": "", // optional
              "user_adhar": "", //optional
              "abha_number": abhaNumber,
              "abha_address": HealthId,
              "abha_card": abhacard,
              "abha_qr_code": "",
              "self": true,
            }),
            options: Options(
              headers: {'authorization': "Bearer $token"},
            ),
          );
          //need to set exception
          print(response.data);
          print(response.statusCode);
        } catch (e) {
          print(e);
        }

        return 'success';
      }
    } catch (e) {
      print(e);
    }
  }

  Future createHealthIdWithPreVerifiedAf() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = box.read('AbhaAccessToken');
    var txnId = box.read('AbhatxnId');
    var data = prefs.get(SPKeys.userData);
    Map res = jsonDecode(data);
    var fname = res['User']['firstName'];
    var email = SpUtil.getString('email');
    var lname = res['User']['lastName'];
    // var phoneno = res['User']['mobileNumber'];
    var phoneno = box.read('mobileNo');
    var pic = res['User']['photo'];
    var pwd = box.read('abhapwd');
    var aadhar = SpUtil.getString('aadharNo');
    var healthid = fname + phoneno.toString();
    var ihlUserId = prefs.get("ihlUserId");
    if (pic == null) {
      ByteData bytes = await rootBundle.load('assets/images/defAva.png');
      var buffer = bytes.buffer;
      var m = base64.encode(Uint8List.view(buffer));
      pic = m;
    }
    try {
      var response = await dio.post(
        "https://healthidsbx.abdm.gov.in/api/v1/registration/aadhaar/createHealthIdWithPreVerified",
        data: json.encode({
          "email": email,
          "firstName": fname,
          "healthId": healthid,
          "lastName": lname,
          "middleName": "",
          "password": pwd,
          "profilePhoto": pic,
          "txnId": txnId
        }),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      print(response.data);
      bool newUser = response.data['new'];
      var responseHealthId = response.data['healthId'];
      var abhaNumber = response.data['healthIdNumber'];
      box.write("healthId", response.data['healthId']);
      box.write("abhaNumber", response.data['healthIdNumber']);
      // if (response.statusCode == 200) {
      //   var token1 = await loginWithPassword(responseHealthId);
      //   var abhacard;
      //   if (token1 != null) {
      //     abhacard = await getAbhaCard(token1);
      //   }
      //   if (true) {
      //     //newUser
      //     var response = await dio.post(
      //       "https://devserver.indiahealthlink.com/ihlabha/store_ihl_user_abha_detail",
      //       data: json.encode({
      //         "ihl_user_id": ihlUserId,
      //         "user_email": email, // optional
      //         "user_mobile": "", // optional
      //         "user_adhar": aadhar,
      //         "abha_number": abhaNumber,
      //         "abha_address": responseHealthId,
      //         "abha_card": abhacard,
      //         "abha_qr_code": "",
      //         "self": true,
      //       }),
      //       options: Options(
      //         headers: {'authorization': "Bearer $token"},
      //       ),
      //     );
      //   }
      // }
      if (response.statusCode == 200) {
        var encryptedNo = RSAEncryption().encrypt(phoneno);
        try {
          var response = await dio.post(
            "https://phrsbx.abdm.gov.in/api/v1/phr/login/mobileEmail/init",
            data: json.encode({'input': encryptedNo}),
            options: Options(
              headers: {'authorization': "Bearer $token", 'X-HIP-ID': "ihl_yog34_2023"},
            ),
          );
          print(response.data);
          if (response.statusCode == 200) {
            box.write("AbhatxnId1", response.data['transactionId']);
            return 'success';
          }
        } catch (e) {
          print(e);
        }
      }
      return response;
    } on DioError catch (e) {
      if (e.type == DioErrorType.response) {
        print(e.response.data['details'][0]['message']);
        return e.response.data['details'][0]['message'];
      }
      ;
    }
  }

  Future<String> emailAbhaLogin(String email) async {
    var token = box.read('AbhaAccessToken');
    var encryptedNo = RSAEncryption().encrypt(email);
    try {
      var response = await dio.post(
        "https://dev.abdm.gov.in/cm/v1/apps/login/mobileEmail/auth-init",
        data: json.encode({
          "value": encryptedNo,
          "purpose": "CM_ACCESS",
          "authMode": "EMAIL_OTP",
          "requester": {"type": "PHR", "id": "ihl_yog34_2023"}
        }),
        options: Options(
          headers: {'authorization': "Bearer $token"},
        ),
      );
      print(response.data);
      if (response.statusCode == 200) {
        box.write("AbhatxnId1", response.data['transactionId']);
        return 'success';
      }
    } catch (e) {
      print(e);
    }
  }
}
