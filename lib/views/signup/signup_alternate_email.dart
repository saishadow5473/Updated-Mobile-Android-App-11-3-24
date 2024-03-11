import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ihl/models/models.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/views/signup/signup_email.dart';
import 'package:ihl/views/signup/signup_email_verify.dart';
import 'package:ihl/views/signup/signup_mob_sso.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:ihl/widgets/signin_email.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../constants/spKeys.dart';

final iHLUrl = API.iHLUrl;
final ihlToken = API.ihlToken;

class SignupAlternateEmailSso extends StatefulWidget {
  final bool loginSso;
  final String userId;

  const SignupAlternateEmailSso({Key key, @required this.loginSso, this.userId}) : super(key: key);

  @override
  _SignupAlternateEmailSsoState createState() => _SignupAlternateEmailSsoState();
}

class _SignupAlternateEmailSsoState extends State<SignupAlternateEmailSso> {
  String apiToken;
  bool userExistR = false;
  http.Client _client = http.Client(); //3gb
  bool _primaryEmail = false;
  String _ihlUserID;

  Future<bool> userExist() async {
    var ssotok = SpUtil.getString('sso_token');
    final response = await _client.get(
      Uri.parse(iHLUrl + '/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(response.body));
      apiToken = reponseToken.apiToken;
      var _alterEmailUrl =
          Uri.parse(iHLUrl + '/sso/personal_email_check?email=${_emailController.text}');
      final userExits = await _client.get(
        _alterEmailUrl,
        // Uri.parse(iHLUrl +
        //     '/login/emailormobileused?email=' +
        //     _emailController.text +
        //     '&mobile=&aadhaar='
        // ),
        headers: {'ApiToken': reponseToken.apiToken},
      );
      if (userExits.statusCode == 200) {
        print(userExits.body);

        var userExistStatus = json.decode(userExits.body);

        var userExistResponse = userExistStatus['status'];
        _ihlUserID = userExistStatus['id'];
        print('$userExistResponse');
        if (widget.loginSso) {
          if (userExistResponse == 'email never used') {
            userExistR = false;
          } else {
            userExistR = true;
            Get.snackbar('Failed', 'Already Have a Account');
            setState(() => isChecking = false);
          }
        } else {
          if (userExistResponse == 'email never used') {
            print('Email never Used : $userExistResponse');
            isChecking = false;
            userExistR = false;
            return userExistR;
          } else if (userExistResponse == 'already used as primary email') {
            print(userExistResponse);
            print('Email already Used : $userExistResponse');
            if (this.mounted) {
              setState(() {
                isChecking = false;
                _primaryEmail = true;
                userExistR = false;
              });
              return userExistR;
            }
          } else if (userExistResponse == 'already used as alternate email') {
            print(userExistResponse);
            print('Email already Used : $userExistResponse');

            if (this.mounted) {
              setState(() {
                userExistR = true;
                isChecking = false;
              });
            }
          } else {
            if (this.mounted) {
              setState(() {
                userExistR = true;
                isChecking = false;
              });
            }
            // ignore: unused_local_variable
            var userExistResponse = "User already exist";
            print(userExistResponse);

            return userExistR;
          }
        }
      } else {
        throw Exception('Authorization Failed');
      }
    }
    return userExistR;
  }

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool isChecking = false;
  FocusNode emailFocusNode;
  bool emailchar = false;
  final _emailController = TextEditingController();

  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    _initAsync();
    _emailController.addListener(() {
      if (this.mounted) {
        setState(() {
          emailchar = _emailController.text.contains(
              RegExp(
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'),
              0);
        });
      }
    });
  }

  Widget emailTextField() {
    return StreamBuilder<String>(
      builder: (context, snapshot) {
        return TextFormField(
          keyboardType: TextInputType.visiblePassword,
          controller: _emailController,
          autocorrect: true,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please Enter Your Credentials';
            } else if (!(emailchar) && value.isNotEmpty) {
              return "Invalid Email";
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.email),
            ),
            labelText: "Alternate E-mail address..",
            hintText: 'johndoe@example.com',
            fillColor: Colors.white24,
            border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(15.0),
                borderSide: new BorderSide(color: Colors.blueGrey)),
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

  void _onPressed() async {
    await userExist();
    if (widget.loginSso) {
      Future.delayed(new Duration(seconds: 3), () {
        if (userExistR == false) {
          if (this.mounted) {
            setState(() {
              // SpUtil.putString('email', _emailController.text);
              isChecking = false;
              Get.to(SignUpAlternateEmailVerify(
                alterEmail: _emailController.text,
                ihlUserID: widget.userId,
                isSso: false,
              ));
            });
          }
        }
      });
    } else {
      if (_primaryEmail) {
        Get.to(
          SignUpAlternateEmailVerify(
            alterEmail: _emailController.text,
            ihlUserID: _ihlUserID,
            isSso: true,
          ),
        );
      } else {
        widget.loginSso
            ? Get.defaultDialog(
                title: 'Failed',
                middleText: 'This Email Don\'t have Account',
              )
            : Future.delayed(new Duration(seconds: 3), () {
                if (userExistR == false) {
                  if (this.mounted) {
                    setState(() {
                      SpUtil.putString('email', _emailController.text);
                      isChecking = false;
                      Get.to(SignupMobSso());
                    });
                  }
                }
              });
      }
    }
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
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => widget.loginSso
                    ? Get.offAll(LoginEmailScreen()) //TODO: Back function check
                    : Navigator.of(context).pushNamed(Routes.Semail),
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
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (this.mounted) {
                        setState(() {
                          isChecking = true;
                        });
                      }
                      if (_formKey.currentState.validate()) {
                        _onPressed();
                      } else {
                        if (this.mounted) {
                          setState(() {
                            isChecking = false;
                            _autoValidate = true;
                          });
                        }
                      }
                    },
                    child: Text(AppTexts.next,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    style: TextButton.styleFrom(
                      textStyle: TextStyle(
                        color: Color(0xFF19a9e5),
                      ),
                      shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xffF4F6FA),
            body: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 5.0),
                    // Text(
                    //   AppTexts.step2,
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //       color: AppColors.primaryAccentColor,
                    //       fontFamily: 'Poppins',
                    //       fontSize: ScUtil().setSp(12),
                    //       letterSpacing: 1.5,
                    //       fontWeight: FontWeight.bold,
                    //       height: 1.1),
                    // ),
                    SizedBox(
                      height: 4 * SizeConfig.heightMultiplier,
                    ),
                    InkWell(
                      onTap: () {
                        print(SpUtil.getString(SPKeys.email));
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15.0, 50.0, 0.0, 0.0),
                        child: Text('Let\'s Start',
                            style: TextStyle(
                                fontSize: ScUtil().setSp(26),
                                fontFamily: 'Poppins',
                                color: Color.fromRGBO(109, 110, 113, 1),
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(
                      height: 3 * SizeConfig.heightMultiplier,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                      child: Text(
                        AppTexts.sub3,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(109, 110, 113, 1),
                            fontFamily: 'Poppins',
                            fontSize: ScUtil().setSp(15),
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w600,
                            height: 1),
                      ),
                    ),
                    SizedBox(height: 2 * SizeConfig.heightMultiplier),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                      child: Text(
                        AppTexts.sub31,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(109, 110, 113, 1),
                            fontFamily: 'Poppins',
                            fontSize: ScUtil().setSp(14),
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.normal,
                            height: 1),
                      ),
                    ),
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
                                ? Text(
                                    'Please try with a Different Email ID',
                                    style: TextStyle(
                                      color: Color(0xff6d6e71),
                                      fontSize: ScUtil().setSp(13),
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
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
                        child: Container(
                          height: 60,
                          child: GestureDetector(
                            onTap: () async {
                              FocusScopeNode currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              if (this.mounted) {
                                setState(() {
                                  isChecking = true;
                                });
                              }
                              if (_formKey.currentState.validate()) {
                                _onPressed();
                              } else {
                                if (this.mounted) {
                                  setState(() {
                                    isChecking = false;
                                    _autoValidate = true;
                                  });
                                }
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF19a9e5),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Center(
                                    child: isChecking == true
                                        ? new CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          )
                                        : Text(
                                            'Continue',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color.fromRGBO(255, 255, 255, 1),
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
                      height: 25 * SizeConfig.heightMultiplier,
                    ),
                    Center(
                        child: Text(
                      '* Note : We will use it to keep your account secure',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(10),
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.normal,
                        height: 1.75,
                        color: Color(0xff6D6E71),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
