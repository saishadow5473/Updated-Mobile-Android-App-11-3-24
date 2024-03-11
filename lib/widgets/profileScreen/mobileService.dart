import 'package:ihl/widgets/profileScreen/verifyPhone.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/models/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

/// all services related to mobile phone and email verification 🔐
class MobileService {
  static String iHLUrl1 = API.iHLUrl;
  static String ihlToken1 = API.ihlToken;

  /// Future<bool> returns true if user verifies through otp🔑🔑
  static Future<bool> otpVerify(
      {String mobileNumber, BuildContext context}) async {
    bool response =
        true; //obscure text giving error in VerifyMob class , thats why this line is added and below lines are commented
    // bool response = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => VerifyMob(
    //       mobileNumber: mobileNumber,
    //       next: (c) {
    //         Navigator.of(c).pop(true);
    //       },
    //     ),
    //   ),
    // );
    return response;
  }

  /// Future<bool> returns true if user mobile or email already exists in database🔑🔑
  static Future<bool> userExist(String moe) async {
    http.Client _client = http.Client(); //3gb
    bool userExistR = false;
    final response = await _client.get(
      Uri.parse(iHLUrl1 + '/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken1},
    );
    if (response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(response.body));
      final userExits = await _client.get(
        Uri.parse(iHLUrl1 +
            '/login/emailormobileused?email=&mobile=' +
            moe +
            '&aadhaar='),
        headers: {'ApiToken': reponseToken.apiToken},
      );
      if (userExits.statusCode == 200) {
        var userExistResponse =
            userExits.body.replaceAll(new RegExp(r'[^\w\s]+'), '');
        if (userExistResponse ==
            "You never registered with this Mobile number") {
          userExistR = false;
          return userExistR;
        } else {
          userExistR = true;
          return userExistR;
        }
      } else {
        throw Exception('Authorization Failed');
      }
    }
    return userExistR;
  }
}
