import 'dart:convert';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../Getx/TabController.dart';
import '../../constants/api.dart';
import '../../constants/app_texts.dart';
import '../../constants/routes.dart';
import '../../models/models.dart';
import '../../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../new_design/presentation/pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../../repositories/api_register.dart';
import '../../repositories/api_repository.dart';
import '../../utils/ScUtil.dart';
import '../../utils/SpUtil.dart';
import '../../utils/app_colors.dart';
import '../../utils/sizeConfig.dart';
import 'signup_alternate_email.dart';
import 'sso_signup_start_screen.dart';
import 'sso_signup_start_screen_new.dart';
import '../../widgets/offline_widget.dart';
import '../../widgets/signin_email.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../constants/spKeys.dart';
import '../splash_screen.dart';

final String iHLUrl = API.iHLUrl;
final String ihlToken = API.ihlToken;

class SignupEmail extends StatefulWidget {
  static const String id = '/signup_email';
  final Apirepository apiRepository;
  String email;

  SignupEmail({Key key, @required this.apiRepository, this.email})
      : assert(apiRepository != null),
        super(key: key);

  @override
  _SignupEmailState createState() => _SignupEmailState();
}

class _SignupEmailState extends State<SignupEmail> {
  final http.Client _client = http.Client(); //3gb
  String apiToken;
  bool userExistR = false;
  var _userId;
  bool isLoadingSso = false;

  Future<bool> userExist() async {
    final http.Response response = await _client.get(
      Uri.parse('$iHLUrl/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(response.body));
      apiToken = reponseToken.apiToken;

      final http.Response userExits = await _client.get(
        Uri.parse(
            '$iHLUrl/login/emailormobileused?email=${_emailController.text}&mobile=&aadhaar='),
        headers: {'ApiToken': reponseToken.apiToken},
      );
      if (userExits.statusCode == 200) {
        String userExistResponse = userExits.body.replaceAll(RegExp(r'[^\w\s]+'), '');
        if (userExistResponse == "You never registered with this Email ID") {
          userExistR = false;
          return userExistR;
        } else {
          if (mounted) {
            setState(() {
              userExistR = true;
              isChecking = false;
            });
          }
          // ignore: unused_local_variable
          String userExistResponse = "User already exist";
          return userExistR;
        }
      } else {
        throw Exception('Authorization Failed');
      }
    }
    return userExistR;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool isChecking = false;
  bool isCheckingSso = false;
  FocusNode emailFocusNode;
  bool emailchar = false;
  final TextEditingController _emailController = TextEditingController();
  final MyTabController _tabGetxController = Get.put(MyTabController());

  //########## This Part is for SSO
  static final Config config = Config(
    tenant: 'common',
    clientId: 'e61ccb73-be25-4f31-a708-0156bd0dda6d',
    scope: 'User.Read',
    redirectUri: 'https://dashboard.indiahealthlink.com/ssoload/',
    // redirectUri: 'https://indiahealthlink.com/',
  );
  final AadOAuth oauth = AadOAuth(config);

  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer ';

  // ###############//
  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    print(widget.email);
    super.initState();
    emailFocusNode = FocusNode();
    _initAsync();
    _emailController.text = widget.email;
    _emailController.addListener(() {
      if (mounted) {
        setState(() {
          emailchar = _emailController.text.contains(
              RegExp(
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'),
              0);
        });
      }
    });
  }

  Widget _singleTab() {
    return Column(
      children: [
        SizedBox(
          height: 6 * SizeConfig.heightMultiplier,
        ),
        Text(
          'Use your Organization Email Id here.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: ScUtil().setSp(15),
            letterSpacing: 0.2,
            fontWeight: FontWeight.normal,
            height: 2,
            color: const Color(0xff6D6E71),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 10 * SizeConfig.heightMultiplier,
        ),
        InkWell(
          onTap: () async {
            logoutSso();
            // login();
            Get.off(const SsoStartScreenNew(
              login: false,
            ));
          },
          child: Container(
            width: ScUtil.screenWidth / 1.3,
            height: ScUtil.screenHeight * 0.07,
            decoration: BoxDecoration(
              color: !isLoadingSso ? const Color(0xFF19a9e5) : Colors.grey,
              borderRadius: BorderRadius.circular(12.0),
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
                          'Single Sign On',
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
      ],
    );
  }

  Widget _emailSignUp() {
    return Column(
      children: [
        SizedBox(
          height: 4 * SizeConfig.heightMultiplier,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Container(
            child: Column(
              children: [
                emailTextField(),
                SizedBox(
                  height: 2 * SizeConfig.heightMultiplier,
                ),
                userExistR == true
                    ? Column(children: [
                        RichText(
                            text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Looks like you already registered!',
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
                                fontSize: ScUtil().setSp(14),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: 'Login Here!',
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    Navigator.of(context).pushNamed(Routes.Login, arguments: false),
                            ),
                          ],
                        ))
                      ])
                    : SizedBox(height: 1 * SizeConfig.heightMultiplier)
              ],
            ),
          ),
        ),
        SizedBox(
          height: 4 * SizeConfig.heightMultiplier,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 50.0, right: 50.0),
          child: Center(
            child: SizedBox(
              height: 60,
              child: GestureDetector(
                onTap: isChecking == true
                    ? () {}
                    : !isCheckingSso
                        ? () {
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
                              try {
                                UpdatingColorsBasedOnAffiliations.affiColorCode.value == 0;
                                UpdatingColorsBasedOnAffiliations.ssoAffiliation.clear();
                                UpdatingColorsBasedOnAffiliations.affiMap.value.clear();
                                UpdatingColorsBasedOnAffiliations.companyName.clear();
                                selectedAffiliationfromuniquenameDashboard = '';
                              } catch (e) {
                                print('data is not there');
                              }
                              userExist();
                              Future.delayed(const Duration(seconds: 6), () {
                                if (userExistR == false) {
                                  if (mounted) {
                                    setState(() {
                                      SpUtil.putString('email', _emailController.text);
                                      isChecking = false;
                                      Navigator.of(context).pushNamed(Routes.Sname);
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
                    color: !isCheckingSso ? const Color(0xFF19a9e5) : Colors.grey,
                    borderRadius: BorderRadius.circular(20.0),
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
          height: 4 * SizeConfig.heightMultiplier,
        ),
      ],
    );
  }

  Widget emailTextField() {
    return StreamBuilder<String>(
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return TextFormField(
          // initialValue: widget.email,
          enabled: !isCheckingSso,
          keyboardType: TextInputType.visiblePassword,
          controller: _emailController,
          autocorrect: true,
          validator: (String value) {
            RegExp regex = RegExp(r'^[1-9]\d*$');
            RegExp regexnumber = RegExp(r'^[789]\d{9}$');
            RegExp regexemail = RegExp(r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$');
            if (value.isEmpty) {
              return 'Please Enter Your Credentials';
            }
            String phoneNumberPattern = r'^\[0-9]\d{9}$';
            RegExp regExp = RegExp(phoneNumberPattern);
            // verify email
            if (!regex.hasMatch(value)) {
              if (!regexemail.hasMatch(value)) {
                return "Enter a valid email address or mobile number!";
              }
            }
            // verify mobile number
            if (!regexemail.hasMatch(value)) {
              if (!regexnumber.hasMatch(value)) {
                return 'Enter a valid email address or mobile number!';
              }
            }
            //If value empty
            else if (value.isEmpty) {
              return "Invalid Credentials";
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.email),
            ),
            labelText: "E-mail address..",
            hintText: 'johndoe@example.com',
            fillColor: Colors.white24,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(color: Colors.blueGrey)),
          ),
          maxLines: 1,
          style: TextStyle(
            fontSize: ScUtil().setSp(16),
          ),
          focusNode: emailFocusNode,
          textInputAction: TextInputAction.done,
        );
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
              //         value: 0.125, // percent filled
              //         backgroundColor: Color(0xffDBEEFC),
              //       ),
              //     ),
              //   ),
              // ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Get.to(const LoginEmailScreen()),
                color: Colors.black,
              ),
              actions: <Widget>[
                Visibility(
                  visible: false,
                  replacement: SizedBox(
                    width: 10.w,
                  ),
                  child: TextButton(
                    onPressed: () {
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
                        Future.delayed(const Duration(seconds: 6), () {
                          if (userExistR == false) {
                            if (mounted) {
                              setState(() {
                                SpUtil.putString('email', _emailController.text);
                                isChecking = false;
                                Navigator.of(context).pushNamed(Routes.Semail);
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
                    },
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        color: Color(0xFF19a9e5),
                      ),
                      shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                    child: const Text(
                      AppTexts.next,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xffF4F6FA),
            body: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 5.0),
                    // Text(
                    //   AppTexts.step1,
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //       color: AppColors.primaryAccentColor,
                    //       fontFamily: 'Poppins',
                    //       fontSize: ScUtil().setSp(12),
                    //       letterSpacing: 1.5,
                    //       fontWeight: FontWeight.bold,
                    //       height: 1.1),
                    // ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15.0, 50.0, 0.0, 0.0),
                      child: Text(AppTexts.hello,
                          style: TextStyle(
                              fontSize: ScUtil().setSp(26),
                              fontFamily: 'Poppins',
                              letterSpacing: 1.2,
                              color: const Color.fromRGBO(109, 110, 113, 1),
                              fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 3 * SizeConfig.heightMultiplier,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                      child: Text(
                        AppTexts.sub1,
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
                    SizedBox(
                      height: 6 * SizeConfig.heightMultiplier,
                    ),
                    SizedBox(
                      width: ScUtil.screenWidth * 0.9,
                      height: ScUtil.screenHeight / 2,
                      child: Column(
                        children: [
                          // TabBar(
                          //   tabs: _tabGetxController.signUpTabs,
                          //   controller: _tabGetxController.signupController,
                          //   labelStyle: TextStyle(
                          //     fontFamily: 'Poppins',
                          //     fontSize: ScUtil().setSp(17),
                          //     letterSpacing: 0,
                          //     fontWeight: FontWeight.w700,
                          //     height: 1.33,
                          //   ),
                          //   labelColor: Color(0xff6D6E71),
                          //   unselectedLabelStyle: TextStyle(
                          //     fontFamily: 'Poppins',
                          //     fontSize: ScUtil().setSp(17),
                          //     letterSpacing: 0,
                          //     fontWeight: FontWeight.normal,
                          //     height: 1.33,
                          //     color: Color(0xff6D6E71),
                          //   ),
                          //   unselectedLabelColor: Color(0xff585D5E),
                          //   automaticIndicatorColorAdjustment: false,
                          //   indicatorColor: AppColors.primaryColor,
                          //   onTap: (v) {
                          //     FocusScope.of(context).unfocus();
                          //     if (v == 0) {
                          //       gs.write(GSKeys.isSSO, false);
                          //
                          //       // gs.write(GSKeys.isSSO, true);
                          //     } else {
                          //       gs.write(GSKeys.isSSO, false);
                          //     }
                          //   },
                          //   overlayColor: MaterialStateProperty.all(AppColors.primaryColor),
                          // ),
                          _emailSignUp()
                        ],
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

  void logoutSso() async {
    await oauth.logout();
  }

  void login() async {
    try {
      await oauth.login();
      String accessToken = await oauth.getAccessToken();

      final http.Response response = await _client.post(
        Uri.parse('$iHLUrl/sso/sso_user_details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"sso_token": accessToken, "sso_type": gType}),
      );

      if (response.statusCode == 200) {
        var finalresponce = jsonDecode(response.body);
        print('Final Response  $finalresponce');
        var outResponce = finalresponce['response']['ihl_account_status'];
        //emailExist
        //emailNotExist
        if (outResponce == "emailNotExist") {
          SpUtil.putString('sso_token', accessToken);
          SpUtil.putString('email', finalresponce['response']['email']);

          showMessageVerified();
        } else if (outResponce == "emailExist") {
          showMessageUserExist();
          setState(() {
            userExistR = true;
          });
        } else {
          showMessageNotVerified();
        }
      }
    } catch (e) {
      showMessageNotVerified();
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
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                setState(() {
                  isCheckingSso = false;
                });
                SpUtil.getString('sso_token');
                print('Calling to ${SpUtil.getString('sso_token')}');
                Get.to(const SignupAlternateEmailSso(
                  loginSso: false,
                ));
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
                logoutSso();
                setState(() {
                  isCheckingSso = false;
                });
                Navigator.pop(context);
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

  void showMessageUserExist() {
    //var succ=CupertinoAlertDialog()
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
            child: Column(
          children: [
            Text(
              "Email ID already Registered",
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
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                logoutSso();
                setState(() {
                  isCheckingSso = false;
                });
                Navigator.pop(context);
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
}
