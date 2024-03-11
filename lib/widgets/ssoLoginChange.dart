import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/models/data_helper.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/views/screens.dart';
import 'package:ihl/widgets/sigin_pwd.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'offline_widget.dart';

final iHLUrl = API.iHLUrl;
final ihlToken = API.ihlToken;

class SsoLoginConvertPage extends StatefulWidget {
  final bool deepLink;

  const SsoLoginConvertPage({Key key, this.deepLink}) : super(key: key);

  @override
  State<SsoLoginConvertPage> createState() => _SsoLoginConvertPageState();
}

class _SsoLoginConvertPageState extends State<SsoLoginConvertPage> {
  http.Client _client = http.Client(); //3gb
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String apiToken;
  bool userExistR = true;
  bool hasError = false;
  bool isChecking = false;
  String otpReceived = "";
  bool _otpReceivedapi = false;
  bool _isOtpVerified = false;
  double progressBar = 0.25;
  String steps = 'STEP 1/3';
  String ihlUserid = "";
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  Widget emailTextField() {
    return StreamBuilder<String>(
      builder: (context, snapshot) {
        return TextFormField(
          //enabled: userExistR,
          keyboardType: TextInputType.visiblePassword,
          controller: emailController,
          autocorrect: true,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(
                FontAwesome.id_card,
                //color: Color(0xFF19a9e5),
              ),
            ),
            labelText: "Alternate Email",
            fillColor: Colors.white24,
            border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(15.0),
                borderSide: new BorderSide(color: Colors.blueGrey)),
          ),
          maxLines: 1,
          style: TextStyle(fontSize: 16.0),
          textInputAction: TextInputAction.done,
        );
      },
    );
  }

  Widget otpTextField() {
    return StreamBuilder<String>(
      builder: (context, snapshot) {
        return TextFormField(
          //enabled: userExistR,
          keyboardType: TextInputType.number,
          controller: otpController,
          autocorrect: false,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your otp';
            } else if (value != otpReceived) {
              return 'Invalid password';
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(
                FontAwesome.key,
                //color: Color(0xFF19a9e5),
              ),
            ),
            labelText: "Enter your otp",
            fillColor: Colors.white24,
            border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(15.0),
                borderSide: new BorderSide(color: Colors.blueGrey)),
          ),
          maxLines: 1,
          style: TextStyle(fontSize: 16.0),
          textInputAction: TextInputAction.done,
        );
      },
    );
  }

  Widget passwordTextField() {
    return StreamBuilder<String>(
      builder: (context, snapshot) {
        return TextFormField(
          //enabled: userExistR,
          keyboardType: TextInputType.visiblePassword,
          controller: passwordController,
          autocorrect: true,
          autovalidateMode:AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your new password';
            } else if (value.length < 8) {
              return 'Password must be at min length of 8';
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(
                FontAwesome.lock,
                //color: Color(0xFF19a9e5),
              ),
            ),
            labelText: "Enter your new password",
            // errorText: errorTextFunForPassController(),
            fillColor: Colors.white24,
            border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(15.0),
                borderSide: new BorderSide(color: Colors.blueGrey)),
          ),
          maxLines: 1,
          style: TextStyle(fontSize: 16.0),
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
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 5,
                  child: LinearProgressIndicator(
                    value: progressBar, // percent filled
                    backgroundColor: Color(0xffDBEEFC),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: !_otpReceivedapi
                  ? () => Navigator.of(context)
                      .pushNamed(Routes.Welcome, arguments: widget.deepLink)
                  : () {
                      setState(() {
                        userExistR = true;
                        hasError = false;
                        isChecking = false;
                        otpReceived = "";
                        _otpReceivedapi = false;
                        _isOtpVerified = false;
                        progressBar = 0.25;
                        steps = 'STEP 1/3';
                        ihlUserid = "";
                        emailController.clear();
                        otpController.clear();
                        passwordController.clear();
                      });
                    },
              color: Colors.black,
            ),
            // actions: <Widget>[
            //   TextButton(
            //     onPressed: () {
            //       FocusScopeNode currentFocus = FocusScope.of(context);
            //       if (!currentFocus.hasPrimaryFocus) {
            //         currentFocus.unfocus();
            //       }
            //       if (this.mounted) {
            //         setState(() {
            //           isChecking = true;
            //         });
            //       }
            //       if (_formKey.currentState.validate()) {
            //         userExist();
            //         new Future.delayed(new Duration(seconds: 6), () {
            //           if (userExistR == true) {
            //             if (this.mounted) {
            //               setState(() {
            //                 //SpUtil.putString('email', emailController.text);
            //                 isChecking = false;
            //                 Navigator.push(
            //                     context,
            //                     MaterialPageRoute(
            //                         builder: (context) => LoginPasswordPage(
            //                               deepLink: widget.deepLink,
            //                             )));
            //               });
            //             }
            //           }
            //         });
            //       } else {
            //         if (this.mounted) {
            //           setState(() {
            //             isChecking = false;
            //             _autoValidate = true;
            //           });
            //         }
            //       }
            //     },
            //     child: Text(AppTexts.next,
            //         style: TextStyle(
            //           fontFamily: 'Poppins',
            //           fontWeight: FontWeight.bold,
            //           fontSize: ScUtil().setSp(16),
            //         )),
            //     style: TextButton.styleFrom(
            //         shape: CircleBorder(
            //             side: BorderSide(color: Colors.transparent)),
            //         textStyle: TextStyle(color: Color(0xFF19a9e5))),
            //   ),
            // ],
          ),
          backgroundColor: Color(0xffF4F6FA),
          body: Form(
            key: _formKey,
            autovalidateMode:AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
                child: !_otpReceivedapi
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 3 * SizeConfig.heightMultiplier,
                          ),
                          Center(
                              child: Text(
                            steps,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: ScUtil().setSp(12),
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                          SizedBox(
                            height: 8 * SizeConfig.heightMultiplier,
                          ),
                          Center(
                              child: Text(
                            'Login with your',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: ScUtil().setSp(26),
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                                height: 1.33,
                                color: Color(0xff6D6E71)),
                          )),
                          SizedBox(
                            height: 10.0,
                          ),
                          Center(
                              child: Text(
                            'Alternate Email',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: ScUtil().setSp(26),
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                                height: 1.33,
                                color: Color(0xff6D6E71)),
                          )),
                          SizedBox(
                            height: 3 * SizeConfig.heightMultiplier,
                          ),
                          // Center(
                          //     child: Text(
                          //   'Email you have given at\n the time registration',
                          //   style: TextStyle(
                          //     fontFamily: 'Poppins',
                          //     fontSize: ScUtil().setSp(15),
                          //     letterSpacing: 0.2,
                          //     fontWeight: FontWeight.normal,
                          //     height: 1.75,
                          //     color: Color(0xff6D6E71),
                          //   ),
                          // )),
                          SizedBox(
                            height: 40.0,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Container(
                              child: Column(
                                children: [
                                  emailTextField(),
                                  SizedBox(
                                    height: 2 * SizeConfig.heightMultiplier,
                                  ),
                                  userExistR == false
                                      ? Column(children: [
                                          RichText(
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        'Uh-ho! Looks like you haven\'t registered!',
                                                    style: TextStyle(
                                                      color: Color(0xff6d6e71),
                                                      fontSize:
                                                          ScUtil().setSp(12),
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' ',
                                                    style: TextStyle(
                                                      color: Color(0xff66688f),
                                                      fontSize:
                                                          ScUtil().setSp(12),
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: 'Register Here!',
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .primaryColor,
                                                      fontSize: 16,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(Routes
                                                                      .Onboard),
                                                  ),
                                                ],
                                              ))
                                        ])
                                      : SizedBox(
                                          height:
                                              1 * SizeConfig.heightMultiplier)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 4 * SizeConfig.heightMultiplier,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 50.0, right: 50.0),
                            child: Center(
                              child: Container(
                                height: 60.0,
                                child: GestureDetector(
                                  onTap: () {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                    if (this.mounted) {
                                      setState(() {
                                        isChecking = true;
                                      });
                                    }
                                    if (_formKey.currentState.validate()) {
                                      userExist();
                                      new Future.delayed(
                                          new Duration(seconds: 6), () {
                                        if (userExistR == true) {
                                          if (this.mounted) {
                                            setState(() {
                                              SpUtil.putString('email',
                                                  emailController.text);
                                              isChecking = false;
                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             LoginPasswordPage(
                                              //               deepLink:
                                              //                   widget.deepLink,
                                              //             )));
                                            });
                                          }
                                        }
                                      });
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Center(
                                          child: isChecking == true
                                              ? new CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                )
                                              : Text(
                                                  'Continue',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          255, 255, 255, 1),
                                                      fontFamily: 'Poppins',
                                                      fontSize:
                                                          ScUtil().setSp(16),
                                                      letterSpacing: 0.2,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                            '* Note : By doing this your organisation email \nwill be removed from your account permanently',
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
                      )
                    : _isOtpVerified
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 3 * SizeConfig.heightMultiplier,
                              ),
                              Center(
                                  child: Text(
                                steps,
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: ScUtil().setSp(12),
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                              SizedBox(
                                height: 8 * SizeConfig.heightMultiplier,
                              ),
                              Center(
                                  child: Text(
                                'Set New Password ',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: ScUtil().setSp(26),
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.bold,
                                    height: 1.33,
                                    color: Color(0xff6D6E71)),
                              )),
                              SizedBox(
                                height: 3 * SizeConfig.heightMultiplier,
                              ),
                              Center(
                                  child: Text(
                                'Enter new password',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: ScUtil().setSp(15),
                                  letterSpacing: 0.2,
                                  fontWeight: FontWeight.normal,
                                  height: 1.75,
                                  color: Color(0xff6D6E71),
                                ),
                              )),
                              SizedBox(
                                height: 40.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0, right: 30.0),
                                child: Container(
                                  child: Column(
                                    children: [
                                      passwordTextField(),
                                      SizedBox(
                                        height: 2 * SizeConfig.heightMultiplier,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 4 * SizeConfig.heightMultiplier,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50.0, right: 50.0),
                                child: Center(
                                  child: Container(
                                    height: 60.0,
                                    child: GestureDetector(
                                      onTap: () {
                                        // if (passwordController.text.length >= 8) {
                                        if (_formKey.currentState.validate()) {
                                          FocusScopeNode currentFocus =
                                              FocusScope.of(context);
                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                          if (this.mounted) {
                                            setState(() {
                                              isChecking = true;
                                            });
                                          }
                                          if (_formKey.currentState
                                              .validate()) {
                                            passwordSet();
                                            new Future.delayed(
                                                new Duration(seconds: 6), () {
                                              if (userExistR == true) {
                                                if (this.mounted) {
                                                  setState(() {
                                                    // SpUtil.putString(
                                                    //     'email', emailController.text);
                                                    isChecking = false;
                                                    // Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(
                                                    //         builder: (context) =>
                                                    //             LoginPasswordPage(
                                                    //               deepLink:
                                                    //                   widget.deepLink,
                                                    //             )));
                                                  });
                                                }
                                              }
                                            });
                                          } else {
                                            if (this.mounted) {
                                              setState(() {
                                                isChecking = false;
                                                _autoValidate = true;
                                              });
                                            }
                                          }
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
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Center(
                                              child: isChecking == true
                                                  ? new CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    )
                                                  : Text(
                                                      'Set Password',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              255, 255, 255, 1),
                                                          fontFamily: 'Poppins',
                                                          fontSize: ScUtil()
                                                              .setSp(16),
                                                          letterSpacing: 0.2,
                                                          fontWeight:
                                                              FontWeight.normal,
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
                                '* Note : By doing this your organisation email \nwill be removed from your account permanently',
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
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 3 * SizeConfig.heightMultiplier,
                              ),
                              Center(
                                  child: Text(
                                steps,
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: ScUtil().setSp(12),
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                              SizedBox(
                                height: 8 * SizeConfig.heightMultiplier,
                              ),
                              Center(
                                  child: Text(
                                'OTP verification',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: ScUtil().setSp(26),
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.bold,
                                    height: 1.33,
                                    color: Color(0xff6D6E71)),
                              )),
                              SizedBox(
                                height: 10.0,
                              ),
                              Center(
                                  child: Text(
                                'Enter otp',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: ScUtil().setSp(26),
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.bold,
                                    height: 1.33,
                                    color: Color(0xff6D6E71)),
                              )),
                              SizedBox(
                                height: 3 * SizeConfig.heightMultiplier,
                              ),
                              Center(
                                  child: Text(
                                'Sent to your email address',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: ScUtil().setSp(15),
                                  letterSpacing: 0.2,
                                  fontWeight: FontWeight.normal,
                                  height: 1.75,
                                  color: Color(0xff6D6E71),
                                ),
                              )),
                              SizedBox(
                                height: 40.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0, right: 30.0),
                                child: Container(
                                  child: Column(
                                    children: [
                                      otpTextField(),
                                      SizedBox(
                                        height: 2 * SizeConfig.heightMultiplier,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 4 * SizeConfig.heightMultiplier,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50.0, right: 50.0),
                                child: Center(
                                  child: Container(
                                    height: 60.0,
                                    child: GestureDetector(
                                      onTap: () {
                                        FocusScopeNode currentFocus =
                                            FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        if (this.mounted) {
                                          setState(() {
                                            isChecking = true;
                                          });
                                        }
                                        if (_formKey.currentState.validate()) {
                                          passwordCheck();
                                          new Future.delayed(
                                              new Duration(seconds: 6), () {
                                            if (userExistR == true) {
                                              if (this.mounted) {
                                                setState(() {
                                                  isChecking = false;
                                                  // Navigator.push(
                                                  //     context,
                                                  //     MaterialPageRoute(
                                                  //         builder: (context) =>
                                                  //             LoginPasswordPage(
                                                  //               deepLink:
                                                  //                   widget.deepLink,
                                                  //             )));
                                                });
                                              }
                                            }
                                          });
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
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Center(
                                              child: isChecking == true
                                                  ? new CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    )
                                                  : Text(
                                                      'Verify',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              255, 255, 255, 1),
                                                          fontFamily: 'Poppins',
                                                          fontSize: ScUtil()
                                                              .setSp(16),
                                                          letterSpacing: 0.2,
                                                          fontWeight:
                                                              FontWeight.normal,
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
                                '* Note : By doing this your organisation email \nwill be removed from your account permanently',
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
                          )),
          ),
        ),
      ),
    );
  }

  Future<bool> userExist() async {
    final response = await _client.get(
      Uri.parse(iHLUrl + '/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(response.body));
      apiToken = reponseToken.apiToken;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', reponseToken.apiToken);
      final userExits = await _client.post(
          Uri.parse(iHLUrl + '/sso/get_sso_user_ihl_id'),
          headers: {'ApiToken': reponseToken.apiToken},
          body: jsonEncode(<String, String>{"email": emailController.text}));
      if (userExits.statusCode == 200) {
        var userExistResponse = jsonDecode(userExits.body);
        var finalresponce = userExistResponse['response'];
        try {
          otpReceived = finalresponce['OTP'];
          ihlUserid = finalresponce['ihl_user_id'];
          if (mounted) {
            setState(() {
              userExistR = false;
              isChecking = false;
              _otpReceivedapi = true;
              progressBar = 0.75;
              steps = "2/3";
            });
          }
        } catch (e) {
          setState(() {
            userExistR = true;
            isChecking = false;
            emailIdNotFound();
          });
        }
      } else {
        throw Exception('Authorization Failed');
      }
    }
    return userExistR;
  }

  void emailIdNotFound() {
    //var succ=CupertinoAlertDialog()
    var alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
            child: Column(
          children: [
            Lottie.network(
                'https://assets7.lottiefiles.com/packages/lf20_owg6bznj.json'),
            SizedBox(
              height: 1 * SizeConfig.heightMultiplier,
            ),
            Text(
              "Email Id Not Found",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(109, 110, 113, 1),
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
        context: context,
        builder: (BuildContext context) => alert,
        barrierDismissible: false);
  }

  Future<bool> passwordSet() async {
    final response = await _client.get(
      Uri.parse(iHLUrl + '/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(response.body));
      apiToken = reponseToken.apiToken;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', reponseToken.apiToken);

      final response1 =
          await _client.post(Uri.parse(iHLUrl + '/login/get_user_login'),
              headers: {
                'Content-Type': 'application/json',
                'Token': 'bearer ',
                'ApiToken': reponseToken.apiToken
              },
              body: jsonEncode(<String, String>{
                "id": ihlUserid,
              }));
      if (response1.statusCode == 200) {
        var resjd = jsonDecode(response1.body);
        if (response1.body == 'null' ||
            response1.body == null ||
            resjd == "Object reference not set to an instance of an object." ||
            response1.body ==
                "Object reference not set to an instance of an object.") {
        } else {
          var tokenParse = jsonDecode(response1.body);
          var token = tokenParse['Token'];

          final setPassword = await _client.post(
              Uri.parse(iHLUrl + '/sso/sso_user_set_password'),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken': reponseToken.apiToken,
                'Token': token
              },
              body: jsonEncode(<String, String>{
                "password": passwordController.text,
                "email": emailController.text
              }));
          if (setPassword.statusCode == 200) {
            var responceParse1 = jsonDecode(setPassword.body);
            try {
              var resoncestatus = responceParse1['response'];
              if (resoncestatus == "success") {
                final updateProfile = await _client.post(
                    Uri.parse(iHLUrl + '/data/user/' + ihlUserid),
                    headers: {
                      'Content-Type': 'application/json',
                      'ApiToken': reponseToken.apiToken,
                      'Token': token
                    },
                    body: jsonEncode(<String, dynamic>{
                      "id": ihlUserid,
                      "personal_email": "",
                      "email": emailController.text,
                      "user_affiliate": {
                        "af_no1": {
                          "affilate_unique_name": "",
                          "affilate_name": "",
                          "affilate_email": "",
                          "affilate_mobile": "",
                          "affliate_identifier_id": ""
                        }
                      }
                    }));
                try {
                  var temp = updateProfile.body;
                  if (updateProfile.statusCode == 200 &&
                      updateProfile.body == '"updated"') {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString(SPKeys.userData, response1.body);
                    prefs.setString(SPKeys.password, passwordController.text);
                    prefs.setString(SPKeys.email, emailController.text);

                    Get.offAll(SplashScreen());
                  } else {
                    ErrorMessage();
                  }
                } catch (e) {
                  ErrorMessage();
                }
              } else {
                ErrorMessage();
              }
            } catch (e) {
              ErrorMessage();
            }
          } else {
            ErrorMessage();
          }
        }
      } else {
        ErrorMessage();
      }
    }
    return userExistR;
  }

  passwordCheck() {
    if (otpReceived == otpController.text) {
      var alert = CupertinoAlertDialog(
          content: SingleChildScrollView(
              child: Column(
            children: [
              Lottie.network(
                  'https://assets10.lottiefiles.com/packages/lf20_drbxtbz4.json'),
              SizedBox(
                height: 1 * SizeConfig.heightMultiplier,
              ),
              Text(
                "Verified",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color.fromRGBO(109, 110, 113, 1),
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
                    setState(() {
                      _isOtpVerified = true;
                      isChecking = false;
                      steps = '3/3';
                      progressBar = 1.0;
                    });
                  }),
            )
          ]);

      showDialog(
          context: context,
          builder: (BuildContext context) => alert,
          barrierDismissible: false);
    }
  }

  void ErrorMessage() {
    //var succ=CupertinoAlertDialog()
    var alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
            child: Column(
          children: [
            Lottie.network(
                'https://assets7.lottiefiles.com/packages/lf20_owg6bznj.json'),
            Text(
              "Something went wrong\nplease try again",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(109, 110, 113, 1),
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(22),
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
                      fontSize: ScUtil().setSp(25),
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.normal,
                      height: 1),
                ),
                onPressed: () {
                  setState(() {
                    userExistR = true;
                    hasError = false;
                    isChecking = false;
                    otpReceived = "";
                    _otpReceivedapi = false;
                    _isOtpVerified = false;
                    progressBar = 0.25;
                    steps = 'STEP 1/3';
                    ihlUserid = "";
                    emailController.clear();
                    otpController.clear();
                    passwordController.clear();
                  });
                  Navigator.pop(context);
                }),
          )
        ]);

    showDialog(
        context: context,
        builder: (BuildContext context) => alert,
        barrierDismissible: false);
  }
}
