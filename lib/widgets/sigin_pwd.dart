import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/src/response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../new_design/presentation/pages/basicData/functionalities/percentage_calculations.dart';
import '../new_design/presentation/pages/basicData/functionalities/data_loading.dart';
import '../Getx/controller/listOfChallengeContoller.dart';
import '../constants/api.dart';
import '../constants/routes.dart';
import '../constants/spKeys.dart';
import '../new_design/app/utils/localStorageKeys.dart';
import '../new_design/data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';
import '../new_design/data/providers/network/networks.dart';
import '../new_design/presentation/bindings/initialControllerBindings.dart';
import '../new_design/presentation/controllers/getTokenContoller/getTokenController.dart';
import '../new_design/presentation/pages/basicData/models/basic_data.dart';
import '../new_design/presentation/pages/home/home_view.dart';
import '../new_design/presentation/pages/home/landingPage.dart';
import '../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import '../repositories/repositories.dart';
import '../utils/SpUtil.dart';
import '../utils/app_colors.dart';
import '../utils/screenutil.dart';
import '../utils/sizeConfig.dart';
import '../views/dietDashboard/edit_profile_screen.dart';
import 'signin_email.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../views/forgotpwd/forgot_password_screen.dart';
import 'offline_widget.dart';

final String iHLUrl = API.iHLUrl;
final String ihlToken = API.ihlToken;

class LoginPasswordPage extends StatefulWidget {
  final bool deepLink;

  const LoginPasswordPage({Key key, this.deepLink}) : super(key: key);

  @override
  _LoginPasswordPageState createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<LoginPasswordPage> {
  final http.Client _client = http.Client(); //3gb

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _autoValidate = false;
  final TextEditingController _passController = TextEditingController();
  bool eightChars = false;
  bool specialChar = false;
  bool upperCaseChar = false;
  bool number = false;
  bool _passwordVisible = false;
  bool vitalDataExists = false;
  bool userLoginSuccess = false;
  bool isLoading = false;
  bool isPwdCorrect;

  Future getTerms() async {
    final String getTermsURL = '${API.iHLUrl}/data/getterms';
    final http.Response response = await _client.get(
      Uri.parse(getTermsURL),
    );
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("IHLTermsandPolicies", response.body);
    } else {}
  }

  var email, password;

  @override
  void initState() {
    super.initState();
    getTerms();
    _passController.addListener(() {
      if (mounted) {
        setState(() {
          eightChars = _passController.text.length >= 8;
          number = _passController.text.contains(RegExp(r'\d'), 0);
          upperCaseChar = _passController.text.contains(RegExp(r'[A-Z]'), 0);
          specialChar = _passController.text.isNotEmpty &&
              !_passController.text.contains(RegExp(r'^[\w&.-]+$'), 0);
        });
      }
    });
  }

  Future<bool> authenticate(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object email = prefs.get('email');
    email ??= localSotrage.read(LSKeys.email);
    Object authToken = prefs.get('auth_token');
    log(DateTime.now().toLocal().toString());

    final http.Response response1 = await _client
        .post(
      Uri.parse('$iHLUrl/login/qlogin2'),
      headers: {'Content-Type': 'application/json', 'Token': 'bearer ', 'ApiToken': authToken},
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    )
        .timeout(const Duration(seconds: 30), onTimeout: () {
      Get.showSnackbar(
        const GetSnackBar(
          title: "No Internet!!",
          message: 'Try again later',
          icon: Icon(Icons.highlight_off_outlined),
          backgroundColor: AppColors.primaryColor,
          duration: Duration(seconds: 3),
        ),
      );
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return http.Response('Timeout', 400);
    });
    log(DateTime.now().toLocal().toString());

    if (response1.statusCode == 200) {
      if (response1.body == 'null') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('data', '');
        if (mounted) {
          setState(() {
            userLoginSuccess = false;
            isPwdCorrect = false;
            isLoading = false;
          });
        }

        return isPwdCorrect;
      } else {
        /// this conditon is called from home screen already , no need here
        ////this two line
        // final firebaseMessaging = FCM();
        // firebaseMessaging.setNotifications();
        if (mounted) {
          setState(() {
            isPwdCorrect = true;
            userLoginSuccess = true;
          });
        }
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        try {
          UpdatingColorsBasedOnAffiliations.affiColorCode.value == 0;
          UpdatingColorsBasedOnAffiliations.ssoAffiliation.clear();
          UpdatingColorsBasedOnAffiliations.affiMap.value.clear();
          UpdatingColorsBasedOnAffiliations.companyName.clear();
          print('Affiliations cleared and will be added if user has affiliations');
        } catch (e) {
          print('Affiliations not cleared');
        }

        prefs.setString('data', response1.body);
        prefs.setString('password', password);
        prefs.setString('email', email);
        localSotrage.write(LSKeys.email, email);
        SpUtil.putString(LSKeys.email, email);
        var decodedResponse = jsonDecode(response1.body);
        try {
          userInputWeight = decodedResponse['User']['userInputWeightInKG'] ??
              decodedResponse['LastCheckin']['weightKG'].toStringAsFixed(2);

          prefs.setString('userInputWeight', userInputWeight);
        } catch (e) {
          userInputWeight = null;
        }
        print(decodedResponse);
        String iHLUserToken = decodedResponse['Token'];
        String iHLUserId = decodedResponse['User']['id'];

        bool introDone = decodedResponse['User']['introDone'];
        API.headerr = {};
        API.headerr['Token'] = iHLUserToken;
        API.headerr['ApiToken'] = '$authToken';
        localSotrage.write(LSKeys.logged, true);
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${API.headerr}");
        localSotrage.write(LSKeys.logged, true);
        password = prefs.get(SPKeys.password);
        SharedPreferences prefs1 = await SharedPreferences.getInstance();
        prefs1.setString("ihlUserId", iHLUserId);
        BasicDataModel basicData;
        try {
          for (int i = 1; i <= decodedResponse['User']['user_affiliate'].length; i++) {
            if (decodedResponse['User']['user_affiliate']['af_no$i']['is_sso'] == false) {
              if (decodedResponse["User"]["user_affiliate"] != null &&
                  decodedResponse["User"]["user_affiliate"]["af_no$i"] != null) {
                String uniqueNameAf1 =
                    decodedResponse["User"]["user_affiliate"]["af_no$i"]["affilate_unique_name"];
                UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] =
                    uniqueNameAf1;
              }
              break;
            }
            // break;
            // List a = [];
            // a.add(decodedResponse['User']['user_affiliate']['af_no$i']);
            // print('=======${decodedResponse['User']['user_affiliate']['af_no$i']}');
          }
          // if (decodedResponse["User"]["user_affiliate"] != null &&
          //     decodedResponse["User"]["user_affiliate"]["af_no1"] != null) {
          //   String uniqueNameAf1 =
          //       decodedResponse["User"]["user_affiliate"]["af_no1"]["affilate_unique_name"];
          //   UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] =
          //       uniqueNameAf1;
          // }
        } catch (e) {
          print(e);
        }
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
            weight: userInputWeight ?? null,
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

        try {
          dynamic res = await dio.post(
            "${API.iHLUrl}/ihlanalytics/store_and_update_login_user_record",
            data: json.encode({
              "ihl_user_id": iHLUserId, //mandatory
              "login_type": "password", // sso, password  //mandatory
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

        localSotrage.write(LSKeys.ihlUserId, iHLUserId);

        try {
          final vitalDatas = await SplashScreenApiCalls()
              .checkinData(ihlUID: iHLUserId, ihlUserToken: iHLUserToken);
          prefs1.setString(SPKeys.vitalsData, jsonEncode(vitalDatas));
          print(vitalDatas);
          await MyvitalsApi().vitalDatas(decodedResponse);
        } catch (e) {
          print(e);
        }

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
        } else {}
        // Get.offAll(HomeScreen(introDone: introDone));
        Get.put(() => ListChallengeController());
        Get.offAll(LandingPage(), binding: InitialBindings());
        final getUserDetails = await SplashScreenApiCalls().getDetailsApi(ihlUID: iHLUserId);
        if (getUserDetails != null) {
          final SharedPreferences userDetailsResponse = await SharedPreferences.getInstance();
          userDetailsResponse.setString(SPKeys.userDetailsResponse, jsonEncode(getUserDetails));
        }

        final vitalData =
            await SplashScreenApiCalls().checkinData(ihlUID: iHLUserId, ihlUserToken: iHLUserToken);

        // _client.get(
        //   Uri.parse(iHLUrl + '/data/user/' + iHLUserId + '/checkin'),
        //   headers: {
        //     'Content-Type': 'application/json',
        //     'Token': iHLUserToken,
        //     'ApiToken': authToken
        //   },
        // );
        if (vitalData != null) {
          vitalDataExists = true;
          final SharedPreferences sharedUserVitalData = await SharedPreferences.getInstance();
          sharedUserVitalData.setString('userVitalData', vitalData);
          vitalDataExists = true;
          prefs.setString('disclaimer', 'no');
          prefs.setString('refund', 'no');
          prefs.setString('terms', 'no');
          prefs.setString('grievance', 'no');
          prefs.setString('privacy', 'no');
        } else {
          vitalDataExists = false;
          throw Exception('No Vital Data for this user');
        }
        if (mounted) {
          setState(() {
            isLoading = false;
            if (widget.deepLink == true) {
              Get.offNamedUntil(
                  Routes.MyAppointments, (Route route) => Get.currentRoute == Routes.Home);
            } else {
              if (userInputWeight.toString() == 'null') {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const EditProfileScreen(
                              kisokAccountWithoutWeight: true,
                            )),
                    (Route<dynamic> route) => false);
              } else {}
            }
          });
        }
        return isPwdCorrect;
      }
    } else {
      throw Exception('Authorization Failed');
    }
  }

  var userInputWeight;

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
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: Scaffold(
          backgroundColor: const Color(0xffF4F6FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,

            // title: Padding(
            //   padding: const EdgeInsets.only(left: 20),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(10),
            //     child: Container(
            //       height: 5,
            //       child: LinearProgressIndicator(
            //         value: 1.0, // percent filled
            //         backgroundColor: Color(0xffDBEEFC),
            //       ),
            //     ),
            //   ),
            // ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginEmailScreen(
                            deepLink: widget.deepLink,
                          ))),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        if (mounted) {
                          setState(() {
                            isLoading = true;
                          });
                        }
                        if (_formKey.currentState.validate()) {
                          await authenticate(_passController.text);
                          // new Future.delayed(new Duration(seconds: 6), () {
                          if (userLoginSuccess == true) {
                            localSotrage = GetStorage();
                            Get.put(GetTokenController());
                            print('----------------------------------------------------');
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                          // });
                        } else {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                              _autoValidate = true;
                            });
                          }
                        }
                      },
                style: TextButton.styleFrom(
                    textStyle: TextStyle(color: isLoading ? Colors.grey : const Color(0xFF19a9e5)),
                    shape: const CircleBorder(side: BorderSide(color: Colors.transparent))),
                child: Text("",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScUtil().setSp(16),
                    )),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 5.0,
                  ),
                  // Center(
                  //     child: Text(
                  //   'STEP 2/2',
                  //   style: TextStyle(
                  //       color: AppColors.primaryColor,
                  //       fontSize: ScUtil().setSp(12),
                  //       fontWeight: FontWeight.bold),
                  // )),
                  SizedBox(
                    height: 8 * SizeConfig.heightMultiplier,
                  ),
                  Center(
                      child: Text(
                    'Type your password',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScUtil().setSp(24),
                        color: const Color(0xff6D6E71)),
                  )),
                  const SizedBox(
                    height: 40.0,
                  ),
                  StreamBuilder<String>(
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return Padding(
                          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                          child: Container(
                            child: TextFormField(
                              obscureText: !_passwordVisible,
                              onChanged: (String val) {
                                isPwdCorrect = true;
                                final String trimVal = val.trim();
                                if (val != trimVal) if (mounted) {
                                  setState(() {
                                    _passController.text = trimVal;
                                    password = _passController.text;
                                    _passController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: trimVal.length));
                                  });
                                }
                              },
                              keyboardType: TextInputType.visiblePassword,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Password can\'t be empty!';
                                }

                                return null;
                              },
                              controller: _passController,
                              decoration: InputDecoration(
                                  prefixIcon: const Padding(
                                    padding: EdgeInsetsDirectional.only(end: 8.0),
                                    child: Icon(Icons.lock),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 17.0, horizontal: 15.0),
                                  labelText: "Password",
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: const Color(0xff252529),
                                    ),
                                    onPressed: () {
                                      if (mounted) {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      }
                                    },
                                  ),
                                  fillColor: Colors.white24,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: const BorderSide(color: Colors.blueGrey))),
                            ),
                          ));
                    },
                  ),
                  isPwdCorrect == false
                      ? Text(
                          'Incorrect Password',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: ScUtil().setSp(14),
                          ),
                        )
                      : SizedBox(height: 1 * SizeConfig.heightMultiplier),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ForgotPasswordPage(apiRepository: Apirepository())));
                          },
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(
                                color: AppColors.primaryColor,
                              ),
                              shape:
                                  const CircleBorder(side: BorderSide(color: Colors.transparent))),
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                                fontSize: ScUtil().setSp(18), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 60.0,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                      child: Center(
                        child: SizedBox(
                          height: 60.0,
                          child: GestureDetector(
                            onTap: isLoading
                                ? () {}
                                : () async {
                                    FocusScopeNode currentFocus = FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                    if (mounted) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                    }
                                    if (_formKey.currentState.validate()) {
                                      // Timer timer;
                                      // timer = Timer(const Duration(seconds: 30), () {
                                      //   if (mounted) {
                                      //     setState(() {
                                      //       isLoading = false;
                                      //       _autoValidate = true;
                                      //     });
                                      //   }
                                      //   Get.snackbar(
                                      //     "Time Out",
                                      //     "Oops! Timeout detected. Check your internet connection, then retry your login",
                                      //     colorText: Colors.white,
                                      //     backgroundColor: Colors.lightBlue,
                                      //     icon: const Icon(Icons
                                      //         .signal_cellular_connected_no_internet_4_bar_rounded),
                                      //   );
                                      //   timer.cancel();
                                      // });
                                      await authenticate(_passController.text);
                                      // new Future.delayed(new Duration(seconds: 6), () {
                                      if (userLoginSuccess == true) {
                                        // timer.cancel();
                                        localSotrage = GetStorage();
                                        Get.put(GetTokenController());
                                        print(
                                            '----------------------------------------------------');
                                        if (mounted) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      }
                                      // });
                                    } else {
                                      if (mounted) {
                                        setState(() {
                                          isLoading = false;
                                          _autoValidate = true;
                                        });
                                      }
                                    }
                                  },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isLoading ? Colors.grey : const Color(0xFF19a9e5),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: AnimatedContainer(
                                curve: Curves.easeInOutCubic,
                                width: isLoading ? 80 : 250,
                                height: isLoading ? 45 : 40,
                                duration: const Duration(milliseconds: 400),
                                alignment: Alignment.center,
                                child: isLoading
                                    ? const Padding(
                                        padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Continue',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: const Color.fromRGBO(255, 255, 255, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: ScUtil().setSp(16),
                                            letterSpacing: 0.2,
                                            fontWeight: FontWeight.normal,
                                            height: 1),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
