import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/api.dart';
import '../../constants/spKeys.dart';
import '../../new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../utils/SpUtil.dart';
import '../../utils/sizeConfig.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../new_design/app/utils/localStorageKeys.dart';
import '../../new_design/presentation/pages/spalshScreen/splashScreen.dart';

final String iHLUrl = API.iHLUrl;
final String ihlToken = API.ihlToken;

class SurveyWaiting extends StatefulWidget {
  const SurveyWaiting({Key key}) : super(key: key);

  @override
  _SurveyWaitingState createState() => _SurveyWaitingState();
}

class _SurveyWaitingState extends State<SurveyWaiting> {
  final http.Client _client = http.Client(); //3gb
  startTime() async {
    Duration duration = const Duration(seconds: 13 ?? 0);
    return Timer(duration, navigationPage);
  }

  void _initAsync() async {
    await SpUtil.getInstance();
    String email = SpUtil.getString('email');
    String pwd = SpUtil.getString('password');
    authenticate(email, pwd);
  }

  void navigationPage() {
    /// this conditon is called from home screen already , no need here
    ////this two line
    // final firebaseMessaging = FCM();
    // firebaseMessaging.setNotifications();
    // Navigator.of(context)
    //     .pushNamedAndRemoveUntil(Routes.Home, (Route<dynamic> route) => false);
    Get.offAll(LandingPage());
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
    startTime();
  }

  // ignore: missing_return
  Future<bool> authenticate(String email, String password) async {
    getTheIhlIdForSso() async {
      final http.Response ress1 = await _client.post(
        Uri.parse('$iHLUrl/sso/get_sso_user_ihl_id'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        // headers: {
        //   'Content-Type': 'application/json',
        //   'Token': 'bearer ',
        //   'ApiToken': authToken
        // },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );
      if (ress1.statusCode == 200) {
        if (ress1.body.toString() != 'null') {
          var decodedRess1 = json.decode(ress1.body);
          if (decodedRess1['status'] == 'success') {
            var ihluseridForSsoUser = decodedRess1['response']['ihl_user_id'];
            return ihluseridForSsoUser.toString();
          }
        }
      }
      return '';
    }

    String authToken = SpUtil.getString('auth_token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object isSso = prefs.get(SPKeys.is_sso);
    String ihlUserId = '';
    if (isSso.toString() == 'true') {
      ihlUserId = await getTheIhlIdForSso();
      prefs.setString('ihlUserId', ihlUserId);
    }
    String loginUrl = isSso == "true" ? '/login/get_user_login' : '/login/qlogin2';
    String body = jsonEncode(<String, String>{
      'email': email,
      'password': password,
    });
    String bodySso = jsonEncode(<String, String>{
      "id": ihlUserId,
    });
    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Token': 'bearer ',
      'ApiToken': authToken
    };
    Map<String, String> headerSso = {
      'Content-Type': 'application/json',
      'Token': 'bearer ',
      'ApiToken': authToken
    };
    final http.Response response1 = await _client.post(
      Uri.parse(iHLUrl + loginUrl),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken':
            "32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==",
      },
      body: isSso == "true" ? bodySso : body,
    );
    if (response1.statusCode == 200) {
      if (response1.body == 'null') {
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('data', response1.body);
        prefs.setString('password', password);
        prefs.setString('email', email);
        localSotrage.write(LSKeys.email, email);

        var decodedResponse = jsonDecode(response1.body);
        await MyvitalsApi().vitalDatas(decodedResponse);
        // ignore: unused_local_variable
        String iHLUserToken = decodedResponse['Token'];
        // ignore: unused_local_variable
        String iHLUserId = decodedResponse['User']['id'];
        API.headerr = {};
        API.headerr['Token'] = iHLUserToken;
        API.headerr['ApiToken'] = authToken;
        prefs.setString("ihlUserId", iHLUserId);
      }
    } else {
      throw Exception('Authorization Failed');
    }
    final String getTermsURL = '${API.iHLUrl}/data/getterms';
    final http.Response response = await _client.get(Uri.parse(getTermsURL));
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("IHLTermsandPolicies", response.body);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
}
