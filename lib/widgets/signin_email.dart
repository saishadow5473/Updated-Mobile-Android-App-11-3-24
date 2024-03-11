import 'dart:convert';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../Getx/TabController.dart';
import '../constants/api.dart';
import '../constants/app_texts.dart';
import '../constants/routes.dart';
import '../constants/spKeys.dart';
import '../models/models.dart';
import '../new_design/app/utils/localStorageKeys.dart';
import '../new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../new_design/presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import '../repositories/api_register.dart';
import '../repositories/api_repository.dart';
import '../utils/SpUtil.dart';
import '../utils/app_colors.dart';
import '../utils/screenutil.dart';
import '../utils/sizeConfig.dart';
import '../views/signup/signup_alternate_email.dart';
import '../views/signup/signup_email.dart';
import '../views/signup/sso_signup_start_screen_new.dart';
import 'sigin_pwd.dart';
import 'ssoLoginChange.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../new_design/presentation/pages/home/landingPage.dart';
import '../views/splash_screen.dart';
import 'offline_widget.dart';

final String iHLUrl = API.iHLUrl;
final String ihlToken = API.ihlToken;
final Apirepository apirepository = Apirepository();

class LoginEmailScreen extends StatefulWidget {
  final bool deepLink, existLog;
  final int index;

  const LoginEmailScreen({Key key, this.deepLink, this.index, this.existLog}) : super(key: key);

  @override
  _LoginEmailScreenState createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final String _authToken =
      "GHG5118RtDtd7C9AXHa9d/i0WDated53MlFmHgDK4n+8s86uo2s4HMvJkWCbKM5485lCRsBc6uTSlUuuzbWMGsJV3q+PEmAfvoVmjF8bKUgBAA==";
  MyTabController _tabGetxController;
  final http.Client _client = http.Client(); //3gb
  final TextEditingController _typeAheadController = TextEditingController();
  String apiToken;
  bool userExistR = true;
  bool hasError = false;
  bool isChecking = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool emailchar = false;
  bool mobilechar = false;
  final TextEditingController emailController = TextEditingController();
  bool vitalDataExists = false;
  bool userLoginSuccess = false, _userAccVerify = false;
  bool isLoadingSso = false, _userAffliation = false, _ssoLogin = false;
  bool isPwdCorrect;
  bool suggestionsAreCreated;
  bool suggestionSelected = false;
  bool searchLoad = true;
  List<Map<String, dynamic>> matche = [];
  String affiUniqName;
  String signInType = "";
  String companyName = "";
  bool isEntered = true;
  GoogleSignInAccount _currentUser;
  String userExistResponse = '';

  //########## This Part is for SSO
  static final Config config = Config(
    tenant: 'common',
    clientId: 'e61ccb73-be25-4f31-a708-0156bd0dda6d',
    scope: 'User.Read',
    redirectUri: 'https://dashboard.indiahealthlink.com/ssoload/',
    // redirectUri: 'https://indiahealthlink.com/',
  );
  final AadOAuth oauth = AadOAuth(config);

  Future<bool> userExist() async {
    final http.Response response = await _client.get(
      Uri.parse('$iHLUrl/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(response.body));
      apiToken = reponseToken.apiToken;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', reponseToken.apiToken);
      final http.Response userExits = await _client.get(
        Uri.parse('$iHLUrl/login/emailormobileused?email=${emailController.text}&mobile=&aadhaar='),
        headers: {'ApiToken': reponseToken.apiToken},
      );
      if (userExits.statusCode == 200) {
        userExistResponse = userExits.body.replaceAll(RegExp(r'[^\w\s]+'), '');
        if (userExistResponse == "You never registered with this Email ID") {
          if (mounted) {
            setState(() {
              userExistR = false;
              isChecking = false;
            });
          }
          return userExistR;
        } else {
          if (mounted) {
            setState(() {
              userExistR = true;
            });
          }

          String userExistResponse = "User already exist";
          return userExistR;
        }
      } else {
        throw Exception('Authorization Failed');
      }
    }
    return userExistR;
  }

  void _initAsync() async {
    _tabGetxController = Get.put(MyTabController(index: widget.index ?? 0));

    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
    emailController.addListener(() {
      if (mounted) {
        setState(() {
          emailchar = emailController.text.contains(
              RegExp(
                  "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$"),
              0);
          mobilechar = emailController.text.contains(RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)'));
        });
      }
    });
  }

  Widget emailTextField() {
    return StreamBuilder<String>(
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Padding(
          padding: EdgeInsets.fromLTRB(7.sp, 1.sp, 10.sp, 0.0),
          child: TextFormField(
            enabled: !isLoadingSso,
            keyboardType: TextInputType.visiblePassword,
            controller: emailController,
            autocorrect: true,
            validator: (String value) {
              if (value.isEmpty) {
                userExistR = true;
                return 'Please Enter Your Credentials';
              } else if (!(emailchar) && (!(mobilechar)) && value.isNotEmpty) {
                return "Invalid Credentials";
              } else if (!value.contains('@') && value.length != 10) {
                return "Invalid Credentials";
              }
              return null;
            },
            decoration: const InputDecoration(
              // prefixIcon: const Padding(
              //   padding: EdgeInsetsDirectional.only(end: 8.0),
              //   child: Icon(Icons.person),
              // ),
              labelText: "email ID or mobile number",
              fillColor: Colors.white,
              labelStyle: TextStyle(
                color: Colors.grey, // Set the color you desire
              ),
              // border: OutlineInputBorder(
              //     borderRadius: BorderRadius.circular(15.0),
              //     borderSide: const BorderSide(color: Colors.blueGrey)),
            ),
            maxLines: 1,
            style: const TextStyle(
              fontSize: 16.0,
            ),
            textInputAction: TextInputAction.done,
          ),
        );
      },
    );
  }

  String _userId;

  Widget _singleSignOnButtonColumn(int index) {
    return Column(
      children: [
        SizedBox(
          height: 6 * SizeConfig.heightMultiplier,
        ),
        widget.existLog == false
            ? SsoStartScreenNew(
                login: widget.existLog,
              )
            : const SsoStartScreenNew(
                login: true,
              )
        // InkWell(
        //   onTap: () async {
        //     logoutSso();
        //     // login();
        //     Get.to(const SsoStartScreen(login: true));
        //   },
        //   child: Container(
        //     width: ScUtil.screenWidth / 1.6,
        //     height: ScUtil.screenHeight * 0.07,
        //     decoration: BoxDecoration(
        //       color: !isLoadingSso ? const Color(0xFF19a9e5) : Colors.grey,
        //       borderRadius: BorderRadius.circular(9.0),
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: <Widget>[
        //         Center(
        //           child: isChecking == true
        //               ? const CircularProgressIndicator(
        //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        //                 )
        //               : Text(
        //                   'PROCEED',
        //                   textAlign: TextAlign.center,
        //                   style: TextStyle(
        //                       color: const Color.fromRGBO(255, 255, 255, 1),
        //                       fontFamily: 'Poppins',
        //                       fontSize: ScUtil().setSp(16),
        //                       letterSpacing: 0.2,
        //                       fontWeight: FontWeight.normal,
        //                       height: 1),
        //                 ),
        //         )
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _emailFieldLogin() {
    return Column(
      children: [
        SizedBox(
          height: 3 * SizeConfig.heightMultiplier,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(6.sp, 1.sp, 10.sp, 0.0),
          child: Text(
            'Enter the email ID or mobile number that you have registered with',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: ScUtil().setSp(15),
              letterSpacing: 0.2,
              fontWeight: FontWeight.normal,
              height: 1.75,
              color: const Color(0xff6D6E71),
            ),
          ),
        ),
        SizedBox(
          height: 4.h,
        ),
        Container(
          child: Column(
            children: [
              emailTextField(),
              SizedBox(
                height: 2 * SizeConfig.heightMultiplier,
              ),
              userExistR == false && userExistResponse == "You never registered with this Email ID"
                  ? Column(children: [
                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Uh-ho! Looks like you haven\'t registered!',
                                style: TextStyle(
                                  color: const Color(0xff6d6e71),
                                  fontSize: ScUtil().setSp(12),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' ',
                                style: TextStyle(
                                  color: const Color(0xff66688f),
                                  fontSize: ScUtil().setSp(12),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              TextSpan(
                                text: 'Register Here!',
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Get.to(SignupEmail(
                                        apiRepository: apirepository,
                                        email: emailController.text,
                                      )),
                              ),
                            ],
                          ))
                    ])
                  : SizedBox(height: 1 * SizeConfig.heightMultiplier)
            ],
          ),
        ),
        SizedBox(
          height: 4 * SizeConfig.heightMultiplier,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 50.0, right: 50.0),
          child: Center(
            child: SizedBox(
              height: 6.8.h,
              child: GestureDetector(
                onTap: isChecking == true
                    ? () {}
                    : !isLoadingSso
                        ? () async {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            if (mounted) {
                              setState(() {
                                isChecking = true;
                              });
                            }
                            if (_formKey.currentState.validate()) {
                              userExist();
                              Future.delayed(const Duration(seconds: 6), () async {
                                if (userExistR == true) {
                                  try {
                                    UpdatingColorsBasedOnAffiliations.affiColorCode.value == 0;
                                    UpdatingColorsBasedOnAffiliations.ssoAffiliation.clear();
                                    UpdatingColorsBasedOnAffiliations.affiMap.value.clear();
                                    UpdatingColorsBasedOnAffiliations.companyName.clear();
                                    selectedAffiliationfromuniquenameDashboard = '';
                                  } catch (e) {
                                    print('data is not there');
                                  }
                                  if (mounted) {
                                    setState(() {
                                      SpUtil.putString('email', emailController.text);
                                      localSotrage.write(LSKeys.email, emailController.text);
                                      isChecking = false;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) => LoginPasswordPage(
                                                    deepLink: widget.deepLink,
                                                  )));
                                    });
                                  }
                                }
                              });
                            } else {
                              if (mounted) {
                                setState(() {
                                  isChecking = false;
                                  _autoValidate = true;
                                });
                              }
                            }
                          }
                        : () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: !isLoadingSso ? const Color(0xFF19a9e5) : Colors.grey,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: isChecking == true
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 14.h,
        ),
        Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'New user?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: ScUtil().setSp(17),
                letterSpacing: 0.2,
                fontWeight: FontWeight.normal,
                height: 1.75,
                color: const Color(0xff6D6E71),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.Semail);
              },
              child: Text(
                ' Create account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(17),
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.bold,
                  height: 1.75,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    ScUtil.init(context, width: 360, height: 670, allowFontScaling: true);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: WillPopScope(
        onWillPop: () async => false,
        child: ConnectivityWidgetWrapper(
          disableInteraction: true,
          offlineWidget: OfflineWidget(),
          child: SafeArea(
            child: Scaffold(
              // appBar: AppBar(
              //   backgroundColor: Colors.transparent,
              //   elevation: 0.0,
              //   title: Padding(
              //     padding: const EdgeInsets.only(left: 20),
              //     child: ClipRRect(
              //       borderRadius: BorderRadius.circular(10),
              //       child: SizedBox(
              //         height: 5,
              //         child: const LinearProgressIndicator(
              //           value: 0.5, // percent filled
              //           backgroundColor: Color(0xffDBEEFC),
              //         ),
              //       ),
              //     ),
              //   ),
              //   leading: IconButton(
              //     icon: const Icon(Icons.arrow_back_ios),
              //     onPressed: () =>
              //         Navigator.of(context).pushNamed(Routes.Welcome, arguments: widget.deepLink),
              //     color: Colors.black,
              //   ),
              //   actions: <Widget>[
              //     Visibility(
              //       visible: false,
              //       replacement: SizedBox(
              //         width: 10.w,
              //       ),
              //       child: TextButton(
              //         onPressed: !isLoadingSso
              //             ? () async {
              //                 FocusScopeNode currentFocus = FocusScope.of(context);
              //                 if (!currentFocus.hasPrimaryFocus) {
              //                   currentFocus.unfocus();
              //                 }
              //                 if (mounted) {
              //                   setState(() {
              //                     isChecking = true;
              //                   });
              //                 }
              //                 if (_formKey.currentState.validate()) {
              //                   userExist();
              //                   Future.delayed(const Duration(seconds: 6), () async {
              //                     if (userExistR == true) {
              //                       if (mounted) {
              //                         setState(() {
              //                           SpUtil.putString('email', emailController.text);
              //                           localSotrage.write(LSKeys.email, emailController.text);
              //                           isChecking = false;
              //                           Navigator.push(
              //                               context,
              //                               MaterialPageRoute(
              //                                   builder: (BuildContext context) => LoginPasswordPage(
              //                                         deepLink: widget.deepLink,
              //                                       )));
              //                         });
              //                       }
              //                     }
              //                   });
              //                 } else {
              //                   if (mounted) {
              //                     setState(() {
              //                       isChecking = false;
              //                       _autoValidate = true;
              //                     });
              //                   }
              //                 }
              //               }
              //             : () {},
              //         style: TextButton.styleFrom(
              //             shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
              //             textStyle: const TextStyle(color: Color(0xFF19a9e5))),
              //         child: Text(AppTexts.next,
              //             style: TextStyle(
              //               fontFamily: 'Poppins',
              //               fontWeight: FontWeight.bold,
              //               fontSize: ScUtil().setSp(16),
              //             )),
              //       ),
              //     ),
              //   ],
              // ),
              backgroundColor: Colors.white,
              body: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 6.h,
                      ),
                      // SizedBox(
                      //   child: Center(
                      //     child: Image.asset(
                      //       'assets/images/logo.png',
                      //       height: ScUtil().setHeight(100),
                      //       width: ScUtil().setWidth(118),
                      //       fit: BoxFit.fill,
                      //     ),
                      //   ),
                      // ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 0.0, 0.0),
                        child: Text(AppTexts.hello,
                            style: TextStyle(
                                fontSize: ScUtil().setSp(26),
                                fontFamily: 'Poppins',
                                letterSpacing: 1.3,
                                color: const Color.fromRGBO(109, 110, 113, 1),
                                fontWeight: FontWeight.bold)),
                      ),

                      Container(
                        padding: EdgeInsets.fromLTRB(23.sp, 15.sp, 23.sp, 0.0),
                        child: Text(
                          'Select corporate login, in order to login with your organization email ID',
                          style: TextStyle(
                              fontSize: ScUtil().setSp(15),
                              fontFamily: 'Poppins',
                              color: const Color.fromRGBO(109, 110, 113, 1),
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 4 * SizeConfig.heightMultiplier,
                      ),
                      SizedBox(
                        width: ScUtil.screenWidth * 0.9,
                        height: ScUtil.screenHeight / 1.4,
                        child: Column(
                          children: [
                            TabBar(
                              tabs: _tabGetxController.loginTabs,
                              controller: _tabGetxController.controller,
                              isScrollable: false,
                              physics: const NeverScrollableScrollPhysics(),
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: ScUtil().setSp(14.5),
                                fontWeight: FontWeight.w700,
                                height: 1.22,
                              ),
                              labelColor: const Color(0xff6D6E71),
                              unselectedLabelStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: ScUtil().setSp(14.5),
                                fontWeight: FontWeight.normal,
                                height: 1.22,
                                color: const Color(0xff6D6E71),
                              ),
                              unselectedLabelColor: const Color(0xff585D5E),
                              automaticIndicatorColorAdjustment: false,
                              indicatorColor: AppColors.primaryColor,
                              overlayColor: MaterialStateProperty.all(AppColors.primaryColor),
                              onTap: (int v) {
                                FocusScope.of(context).unfocus();
                                if (v == 1) {
                                  gs.write(GSKeys.isSSO, true);
                                } else {
                                  gs.write(GSKeys.isSSO, false);
                                }
                              },
                            ),
                            Expanded(
                              child: TabBarView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  controller: _tabGetxController.controller,
                                  children: [
                                    _emailFieldLogin(),
                                    _singleSignOnButtonColumn(widget.index),
                                  ]),
                            )
                          ],
                        ),
                      )
                      // Center(
                      //     child: Text(
                      //   'Login with your Email',
                      //   style: TextStyle(
                      //       fontFamily: 'Poppins',
                      //       fontSize: ScUtil().setSp(26),
                      //       letterSpacing: 0,
                      //       fontWeight: FontWeight.bold,
                      //       height: 1.33,
                      //       color: Color(0xff6D6E71)),
                      // )),
                      // SizedBox(
                      //   height: 10.0,
                      // ),
                      // Center(
                      //     child: Text(
                      //   'or Mobile number',
                      //   style: TextStyle(
                      //       fontFamily: 'Poppins',
                      //       fontSize: ScUtil().setSp(26),
                      //       letterSpacing: 0,
                      //       fontWeight: FontWeight.bold,
                      //       height: 1.33,
                      //       color: Color(0xff6D6E71)),
                      // )),
                      // SizedBox(
                      //   height: 3 * SizeConfig.heightMultiplier,
                      // ),
                      // Center(
                      //     child: Text(
                      //   'Email or Mobile you have registered',
                      //   style: TextStyle(
                      //     fontFamily: 'Poppins',
                      //     fontSize: ScUtil().setSp(15),
                      //     letterSpacing: 0.2,
                      //     fontWeight: FontWeight.normal,
                      //     height: 1.75,
                      //     color: Color(0xff6D6E71),
                      //   ),
                      // )),
                      // SizedBox(
                      //   height: 40.0,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      //   child: Container(
                      //     child: Column(
                      //       children: [
                      //         emailTextField(),
                      //         SizedBox(
                      //           height: 2 * SizeConfig.heightMultiplier,
                      //         ),
                      //         userExistR == false
                      //             ? Column(children: [
                      //                 RichText(
                      //                     textAlign: TextAlign.center,
                      //                     text: TextSpan(
                      //                       children: [
                      //                         TextSpan(
                      //                           text:
                      //                               'Uh-ho! Looks like you haven\'t registered!',
                      //                           style: TextStyle(
                      //                             color: Color(0xff6d6e71),
                      //                             fontSize: ScUtil().setSp(12),
                      //                             fontFamily: 'Poppins',
                      //                             fontWeight: FontWeight.bold,
                      //                           ),
                      //                         ),
                      //                         TextSpan(
                      //                           text: ' ',
                      //                           style: TextStyle(
                      //                             color: Color(0xff66688f),
                      //                             fontSize: ScUtil().setSp(12),
                      //                             fontFamily: 'Poppins',
                      //                           ),
                      //                         ),
                      //                         TextSpan(
                      //                           text: 'Register Here!',
                      //                           style: TextStyle(
                      //                             color: AppColors.primaryColor,
                      //                             fontSize: 16,
                      //                             fontFamily: 'Poppins',
                      //                             fontWeight: FontWeight.w600,
                      //                           ),
                      //                           recognizer: TapGestureRecognizer()
                      //                             ..onTap = () => Navigator.of(
                      //                                     context)
                      //                                 .pushNamed(Routes.Onboard),
                      //                         ),
                      //                       ],
                      //                     ))
                      //               ])
                      //             : SizedBox(
                      //                 height: 1 * SizeConfig.heightMultiplier)
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 4 * SizeConfig.heightMultiplier,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                      //   child: Center(
                      //     child: Container(
                      //       height: 60.0,
                      //       child: GestureDetector(
                      //         onTap: !isLoadingSso
                      //             ? () {
                      //                 FocusScopeNode currentFocus =
                      //                     FocusScope.of(context);
                      //                 if (!currentFocus.hasPrimaryFocus) {
                      //                   currentFocus.unfocus();
                      //                 }
                      //                 if (this.mounted) {
                      //                   setState(() {
                      //                     isChecking = true;
                      //                   });
                      //                 }
                      //                 if (_formKey.currentState.validate()) {
                      //                   userExist();
                      //                   new Future.delayed(new Duration(seconds: 6),
                      //                       () {
                      //                     if (userExistR == true) {
                      //                       if (this.mounted) {
                      //                         setState(() {
                      //                           SpUtil.putString(
                      //                               'email', emailController.text);
                      //                           isChecking = false;
                      //                           Navigator.push(
                      //                               context,
                      //                               MaterialPageRoute(
                      //                                   builder: (context) =>
                      //                                       LoginPasswordPage(
                      //                                         deepLink:
                      //                                             widget.deepLink,
                      //                                       )));
                      //                         });
                      //                       }
                      //                     }
                      //                   });
                      //                 } else {
                      //                   if (this.mounted) {
                      //                     setState(() {
                      //                       isChecking = false;
                      //                       _autoValidate = true;
                      //                     });
                      //                   }
                      //                 }
                      //               }
                      //             : () {},
                      //         child: Container(
                      //           decoration: BoxDecoration(
                      //             color: !isLoadingSso
                      //                 ? Color(0xFF19a9e5)
                      //                 : Colors.grey,
                      //             borderRadius: BorderRadius.circular(20.0),
                      //           ),
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: <Widget>[
                      //               Center(
                      //                 child: isChecking == true
                      //                     ? new CircularProgressIndicator(
                      //                         valueColor:
                      //                             AlwaysStoppedAnimation<Color>(
                      //                                 Colors.white),
                      //                       )
                      //                     : Text(
                      //                         'Continue',
                      //                         textAlign: TextAlign.center,
                      //                         style: TextStyle(
                      //                             color: Color.fromRGBO(
                      //                                 255, 255, 255, 1),
                      //                             fontFamily: 'Poppins',
                      //                             fontSize: ScUtil().setSp(16),
                      //                             letterSpacing: 0.2,
                      //                             fontWeight: FontWeight.normal,
                      //                             height: 1),
                      //                       ),
                      //               )
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 4 * SizeConfig.heightMultiplier,
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     Expanded(
                      //       child: Divider(
                      //         thickness: 3,
                      //         indent: 15,
                      //         endIndent: 10,
                      //         height: 5,
                      //       ),
                      //     ),
                      //     Text('or',
                      //         style: TextStyle(
                      //             fontSize: ScUtil().setSp(26),
                      //             fontFamily: 'Poppins',
                      //             color: Color.fromRGBO(109, 110, 113, 1),
                      //             fontWeight: FontWeight.bold)),
                      //     Expanded(
                      //       child: Divider(
                      //         thickness: 3,
                      //         indent: 10,
                      //         endIndent: 15,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: 4 * SizeConfig.heightMultiplier,
                      // ),
                      // isLoadingSso
                      //     ? CircularProgressIndicator()
                      //     : GestureDetector(
                      //         child: Column(
                      //           children: [
                      //             Padding(
                      //               padding: EdgeInsets.only(
                      //                   left: ScUtil().setWidth(80.0),
                      //                   right: ScUtil().setWidth(5)),
                      //               child: Row(
                      //                 children: [
                      //                   Icon(
                      //                     FontAwesome.id_card,
                      //                     color: Color(0xFF19a9e5),
                      //                     size: 30,
                      //                   ),
                      //                   Padding(
                      //                     padding: EdgeInsets.only(
                      //                         left: ScUtil().setWidth(5.0),
                      //                         right: ScUtil().setWidth(50.0)),
                      //                     child: Text(
                      //                       'Log in with your \n organisation account',
                      //                       textAlign: TextAlign.center,
                      //                       style: TextStyle(
                      //                           color: Color.fromRGBO(
                      //                               109, 110, 113, 1),
                      //                           fontFamily: 'Poppins',
                      //                           fontSize: ScUtil().setSp(15),
                      //                           letterSpacing: 0.2,
                      //                           fontWeight: FontWeight.normal,
                      //                           height: 1),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //             Icon(
                      //               Icons.double_arrow_rounded,
                      //               color: Color(0xFF19a9e5),
                      //             ),
                      //           ],
                      //         ),
                      //         onTap: () async {
                      //           await logoutSso();
                      //           login();
                      //           //showMessageNotVerified();
                      //         },
                      //       )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void logoutSso() async {
    await oauth.logout();
  }

  void login() async {
    try {
      await oauth.login();
      String accessToken = await oauth.getAccessToken();
      SpUtil.putString('sso_token', accessToken);

      setState(() {
        isLoadingSso = true;
      });
      bool responce = await authenticate(accessToken);
      if (_ssoLogin) {
        Get.to(
          SignupAlternateEmailSso(
            loginSso: true,
            userId: _userId,
          ),
        );
        // Alert(
        //   context: context,
        //   title: 'Info',
        //   desc: 'Don\'t have Personal Email Update',
        //   style: AlertStyle(
        //       animationType: AnimationType.shrink,
        //       animationDuration: Duration(milliseconds: 500),
        //       descStyle: TextStyle(fontSize: 15),
        //       isCloseButton: false),
        //   buttons: [
        //     DialogButton(
        //       onPressed: () {
        //         setState(() => isLoadingSso = false);
        //         Navigator.pop(context, false);
        //       }, // passing false
        //       child: Text('No'),
        //     ),
        //     DialogButton(
        //       child: Text('Yes'),
        //       onPressed: () => Get.to(
        //         SignupAlternateEmailSso(
        //           loginSso: true,
        //           userId: _userId,
        //         ),
        //       ),
        //     ) // passing false
        //   ],
        // ).show();
      } else if (responce) {
        setState(() {
          isLoadingSso = false;
        });
        await oauth.logout();
        //showMessageVerified();
      } else {
        setState(() {
          isLoadingSso = false;
        });
        await oauth.logout();
        showMessageNotVerified();
      }
    } catch (e) {
      setState(() {
        isLoadingSso = false;
      });
      await oauth.logout();
      showMessageNotVerified();
    }
  }

  Future<bool> authenticate(String ssoToken) async {
    final http.Response response = await _client.get(
      Uri.parse('$iHLUrl/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(response.body));
      apiToken = reponseToken.apiToken;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', reponseToken.apiToken);

      Object email = prefs.get('email');
      Object authToken = prefs.get('auth_token');
      final http.Response response1 = await _client.post(
        Uri.parse('$iHLUrl/sso/login_sso_user_account'),
        headers: {'Content-Type': 'application/json', 'ApiToken': apiToken},
        body: jsonEncode(<String, String>{'sso_token': ssoToken, "sso_type": gType}),
      );
      print(response1.body);

      if (response1.statusCode == 200) {
        var res = jsonDecode(response1.body);
        if (res['response'] == 'user already has an primary account in this email') {
          _userId = res['id'];
          setState(() => _ssoLogin = true);
        } else if (response1.body == 'null') {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('data', '');
          if (mounted) {
            setState(() {
              isPwdCorrect = false;
              isLoadingSso = false;
            });
          }

          return isPwdCorrect;
        } else {
          if (mounted) {
            setState(() {
              isPwdCorrect = true;
              isLoadingSso = true;
            });
          }
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('data', response1.body);
          prefs.setString(SPKeys.is_sso, "true");
          //prefs.setString('email', email);
          var decodedResponse = jsonDecode(response1.body);
          print(decodedResponse);
          String iHLUserToken = decodedResponse['Token'];
          String iHLUserId = decodedResponse['User']['id'];
          String userEmail = decodedResponse['User']['email'];
          prefs.setString('email', userEmail);
          localSotrage.write(LSKeys.email, userEmail);
          bool introDone = decodedResponse['User']['introDone'] ?? false;
          API.headerr = {};
          API.headerr['Token'] = iHLUserToken;
          API.headerr['ApiToken'] = apiToken;
          print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${API.headerr}");
          localSotrage.write(LSKeys.logged, true);
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
          final http.Response getUserDetails = await _client.post(
            Uri.parse("${API.iHLUrl}/consult/get_user_details"),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
            body: jsonEncode(<String, String>{
              'ihl_id': iHLUserId,
            }),
          );
          if (getUserDetails.statusCode == 200) {
            final SharedPreferences userDetailsResponse = await SharedPreferences.getInstance();
            userDetailsResponse.setString(SPKeys.userDetailsResponse, getUserDetails.body);
          }
          final http.Response vitalData = await _client.get(
            Uri.parse('$iHLUrl/data/user/$iHLUserId/checkin'),
            headers: {
              'Content-Type': 'application/json',
              'Token': iHLUserToken,
              'ApiToken': authToken
            },
          );
          Map<String, dynamic> userAffiliationDetail;

          Object userData = prefs.get(SPKeys.userData);
          Map userDecodeData = jsonDecode(userData);
          final http.Response affiliationDetails = await _client.post(
            Uri.parse("$iHLUrl/sso/affiliation_details"),
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
            print(finalResponse);
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
                      final http.Response updateProfile =
                          await _client.post(Uri.parse('$iHLUrl/data/user/$iHLUserId'),
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
                              await _client.post(Uri.parse('$iHLUrl/data/user/$iHLUserId'),
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
                          await _client.post(Uri.parse('$iHLUrl/data/user/$iHLUserId'),
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

                print('Already');
              } else {
                final http.Response updateProfile =
                    await _client.post(Uri.parse('$iHLUrl/data/user/$iHLUserId'),
                        headers: {
                          'Content-Type': 'application/json',
                          'ApiToken': API.headerr['ApiToken'],
                          'Token': API.headerr['Token']
                        },
                        body: jsonEncode(<String, dynamic>{
                          "id": iHLUserId,
                          "user_affiliate": {
                            "af_no1": {
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
            vitalDataExists = true;
            final SharedPreferences sharedUserVitalData = await SharedPreferences.getInstance();
            sharedUserVitalData.setString('userVitalData', vitalData.body);
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
            await MyvitalsApi().vitalDatas({});
            setState(() {
              isLoadingSso = false;
              if (widget.deepLink == true) {
                Get.offNamedUntil(
                    Routes.MyAppointments, (Route route) => Get.currentRoute == Routes.Home);
              } else {
                // Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => HomeScreen(
                //               introDone: introDone,
                //             )),
                //     (Route<dynamic> route) => false);
                Get.to(LandingPage());
              }
            });
          }
          return isPwdCorrect;
        }
      }
    } else {
      throw Exception('Authorization Failed');
    }
  }

  void showMessageVerified() {
    //var succ=CupertinoAlertDialog()
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
            child: Column(
          children: [
            Lottie.network('https://assets10.lottiefiles.com/packages/lf20_drbxtbz4.json'),
            SizedBox(
              height: 1 * SizeConfig.heightMultiplier,
            ),
            Text(
              "Verified",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: const Color.fromRGBO(109, 110, 113, 1),
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(25),
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
          ],
        )),
        actions: <Widget>[
          Center(
            child: TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(
                      //color: Color.fromRGBO(109, 110, 113, 1),
                      fontFamily: 'Poppins',
                      fontSize: ScUtil().setSp(20),
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.normal,
                      height: 1),
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          )
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageNotVerified() {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.network('https://assets7.lottiefiles.com/packages/lf20_owg6bznj.json'),
              Text(
                "Unable to Verify. \n Please try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: const Color.fromRGBO(109, 110, 113, 1),
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                Navigator.pop(context);
                showMessageNotVerifiedExtended();
              },
              child: Text(
                'Ok',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageNotVerifiedExtended() {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.network(
                'https://assets5.lottiefiles.com/packages/lf20_ju8hin0q.json',
              ),
              Text(
                "Do you still work in this organisation?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: const Color.fromRGBO(109, 110, 113, 1),
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: Text(
                'Yes',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
              onPressed: () {
                Navigator.pop(context);
                showMessageNotVerifiedExtendedFlow(true);
              }),
          TextButton(
              child: Text(
                'No',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
              onPressed: () {
                Navigator.pop(context);
                showMessageNotVerifiedExtendedFlow(false);
              })
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageNotVerifiedExtendedFlow(bool isOrganisation) {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                isOrganisation
                    ? "Please contact your organisation admin."
                    : "You can login with your alternate email.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: const Color.fromRGBO(109, 110, 113, 1),
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            isDestructiveAction: false,
            onPressed: isOrganisation
                ? () {
                    Navigator.pop(context);
                  }
                : () {
                    Get.to(SsoLoginConvertPage(
                      deepLink: widget.deepLink,
                    ));
                  },
            child: Text(
              'Okay',
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(20),
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
          ),
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

// Future<List> getSuggestions(String query) async {
//   List<Map<String, dynamic>> matches = [];
//
//   matches = [];
//   setState(() {});
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   String iHLUserId = prefs.getString('ihlUserId');
//   List aff = [];
//   http.Client client = http.Client(); //3gb
//   final http.Response response = await client.get(
//       Uri.parse(
//           '${API.iHLUrl}/consult/list_of_aff_starts_with?search_string=$query&ihl_user_id=$iHLUserId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'ApiToken': '${API.headerr['ApiToken']}',
//         'Token': '${API.headerr['Token']}',
//       });
//   if (response.statusCode == 200) {
//     String text = parseFragment(response.body).text;
//     text = parseFragment(text).text; //needed to be done twise to avoid html tags
//     // var parse = response.body.replaceAll('&#160;', ' ');
//     // var parse1 = parse.replaceAll('(6&quot;)', '');
//     // var parse2 = parse1.replaceAll('&amp;', '');
//
//     aff = jsonDecode(text);
//
//     List value = aff;
//   }
//   print(aff);
//   if (mounted) setState(() {});
//   for (int i = 0; i < aff.length; i++) {
//     if (aff[i]['sign_in_option'] == "microsoft" || aff[i]['sign_in_option'] == "google") {
//       matches.add(aff[i]);
//     }
//   }
//   if (matches.isNotEmpty) {
//     suggestionsAreCreated = true;
//   } else {
//     suggestionsAreCreated = false;
//   }
//   suggestionSelected = false;
//   if (_typeAheadController.text != "") matche = matches.toSet().toList();
//   searchLoad = false;
//   if (mounted) setState(() {});
//
//   return matches;
// }

// Widget _buildBody() {
//   final GoogleSignInAccount user = _currentUser;
//   if (signInType == "") {
//     return const SizedBox(); //Text("Not Found");
//   } else if (signInType == "google") {
//     if (user != null) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           Visibility(
//             visible: isFetching,
//             child: const ListTile(
//               title: LinearProgressIndicator(
//                 semanticsLabel: 'Loading...',
//               ),
//             ),
//           ),
//
//           // ListTile(
//           //   leading: ClipRRect(
//           //       borderRadius: BorderRadius.circular(50.0),
//           //       child: Image.network(user.photoUrl)),
//           //   title: Text(user.displayName ?? ''),
//           //   subtitle: Text(user.email),
//           // ),
//           // const Text('Signed in successfully.'),
//           SizedBox(
//             height: ScUtil().setHeight(15),
//           ),
//           ElevatedButton.icon(
//             onPressed: isFetching ? null : signInWithGoogle,
//             icon: const Icon(Icons.change_circle_outlined),
//             label: Text('Try again',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: const Color.fromRGBO(255, 255, 255, 1),
//                     fontFamily: 'Poppins',
//                     fontSize: ScUtil().setSp(16),
//                     letterSpacing: 0.2,
//                     fontWeight: FontWeight.normal,
//                     height: 1)),
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF19a9e5),
//                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                 textStyle: TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
//           ),
//
//           // ElevatedButton(
//           //   child: const Text('REFRESH'),
//           //   onPressed: () => _handleGetContact(user),
//           // ),
//         ],
//       );
//     } else {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           SizedBox(
//             height: ScUtil().setHeight(10),
//           ),
//           Text('You are not currently signed in.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   color: Colors.black54,
//                   fontFamily: 'Poppins',
//                   fontSize: ScUtil().setSp(16),
//                   letterSpacing: 0.2,
//                   fontWeight: FontWeight.normal,
//                   height: 1)),
//           SizedBox(
//             height: ScUtil().setHeight(20),
//           ),
//           ElevatedButton.icon(
//             onPressed: signInWithGoogle,
//             //onPressed: _handleGoogleSignIn,
//             icon: Image.asset(
//               'assets/images/google.png',
//               height: ScUtil().setHeight(20),
//               width: ScUtil().setWidth(25),
//               fit: BoxFit.cover,
//             ),
//             label: Text('Sign in using google',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: const Color.fromRGBO(255, 255, 255, 1),
//                     fontFamily: 'Poppins',
//                     fontSize: ScUtil().setSp(16),
//                     letterSpacing: 0.2,
//                     fontWeight: FontWeight.normal,
//                     height: 1)),
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF19a9e5),
//                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                 textStyle: TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
//           )
//         ],
//       );
//     }
//   } else if (signInType == "microsoft") {
//     if (microSoftUserDetails == null || microSoftUserDetails == "") {
//       return isFetching
//           ? const CircularProgressIndicator()
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: <Widget>[
//                 SizedBox(
//                   height: ScUtil().setHeight(10),
//                 ),
//                 Text('You are not currently signed in.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.black54,
//                         fontFamily: 'Poppins',
//                         fontSize: ScUtil().setSp(16),
//                         letterSpacing: 0.2,
//                         fontWeight: FontWeight.normal,
//                         height: 1)),
//                 SizedBox(
//                   height: ScUtil().setHeight(20),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _handleMicrosoftSignIn,
//                   icon: Image.asset(
//                     'assets/images/microsoft.png',
//                     height: ScUtil().setHeight(20),
//                     width: ScUtil().setWidth(20),
//                     fit: BoxFit.cover,
//                   ),
//                   label: Text('Sign in using microsoft',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           color: const Color.fromRGBO(255, 255, 255, 1),
//                           fontFamily: 'Poppins',
//                           fontSize: ScUtil().setSp(16),
//                           letterSpacing: 0.2,
//                           fontWeight: FontWeight.normal,
//                           height: 1)),
//                   style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10), // <-- Radius
//                       ),
//                       backgroundColor: const Color(0xFF19a9e5),
//                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                       textStyle:
//                           TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
//                 )
//               ],
//             );
//     } else {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           ListTile(
//             leading: microSoftUserProfilePic != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(50.0),
//                     child: Image.memory(microSoftUserProfilePic))
//                 : const Icon(
//                     Icons.account_circle_sharp,
//                     size: 50,
//                   ),
//             title: Text(microSoftUserDetails['givenName'] ?? ''),
//             subtitle: Text(microSoftUserDetails['userPrincipalName'] ?? ''),
//           ),
//           //const Text('Signed in successfully.'),
//           SizedBox(
//             height: ScUtil().setHeight(15),
//           ),
//           ElevatedButton.icon(
//             onPressed: _handleMicrosoftSignOut,
//             icon: const Icon(Icons.change_circle_outlined),
//             label: Text('Try again',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: const Color.fromRGBO(255, 255, 255, 1),
//                     fontFamily: 'Poppins',
//                     fontSize: ScUtil().setSp(16),
//                     letterSpacing: 0.2,
//                     fontWeight: FontWeight.normal,
//                     height: 1)),
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF19a9e5),
//                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                 textStyle: TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
//           ),
//           // ElevatedButton(
//           //   child: const Text('REFRESH'),
//           //   onPressed: () => _handleGetContact(user),
//           // ),
//         ],
//       );
//     }
//   } else {
//     return const SizedBox();
//   }
// }

// Future signInWithGoogle({BuildContext context}) async {
//   hasOppend = true;
//   final GoogleSignIn googleSignIn = GoogleSignIn();
//   setState(() => isFetching = true);
//   try {
//     if (!kIsWeb) {
//       await googleSignIn.signOut();
//     }
//     await FirebaseAuth.instance.signOut();
//   } catch (e) {
//     showMessageNotVerified();
//   }
//
//   FirebaseAuth auth = FirebaseAuth.instance;
//   User user;
//   if (kIsWeb) {
//     GoogleAuthProvider authProvider = GoogleAuthProvider();
//
//     try {
//       final UserCredential userCredential = await auth.signInWithPopup(authProvider);
//
//       user = userCredential.user;
//     } catch (e) {
//       print(e);
//       setState(() {
//         isFetching = false;
//       });
//
//       showMessageNotVerified();
//     }
//   } else {
//     final GoogleSignIn googleSignIn = GoogleSignIn();
//
//     final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
//
//     if (googleSignInAccount != null) {
//       _currentUser = googleSignInAccount;
//       final GoogleSignInAuthentication googleSignInAuthentication =
//           await googleSignInAccount.authentication;
//
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleSignInAuthentication.accessToken,
//         idToken: googleSignInAuthentication.idToken,
//       );
//
//       try {
//         final UserCredential userCredential = await auth.signInWithCredential(credential);
//
//         user = userCredential.user;
//       } on FirebaseAuthException catch (e) {
//         if (e.code == 'account-exists-with-different-credential') {
//           showMessageNotVerified();
//         } else if (e.code == 'invalid-credential') {
//           showMessageNotVerified();
//         }
//       } catch (e) {
//         print(e);
//         setState(() {
//           isFetching = false;
//         });
//
//         showMessageNotVerified();
//       }
//     }
//   }
//   setState(() {
//     _currentUser = _currentUser;
//   });
//   login_init(_currentUser);
//   //return user;
// }
//
// Future<void> _handleMicrosoftSignIn() async {
//   hasOppend = true;
//   setState(() {
//     isFetching = true;
//   });
//   try {
//     await oauth.logout();
//     await oauth.login();
//     var token = await oauth.getAccessToken();
//     login(token);
//   } catch (e) {
//     setState(() {
//       isFetching = false;
//     });
//     showMessageNotVerified();
//   }
// }
//
// Future<void> _handleMicrosoftSignOut() async {
//   await oauth.logout();
//   setState(() {
//     microSoftUserDetails = null;
//   });
// }
//
// Future<void> _handleGoogleSignIn() async {
//   try {
//     await _googleSignIn.signIn();
//   } catch (e) {
//     print(e);
//     setState(() {
//       isFetching = false;
//     });
//
//     showMessageNotVerified();
//   }
// }
}
