import 'dart:async';
import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

final iHLUrl1 = API.iHLUrl;
final ihlToken1 = API.ihlToken;

class CreateVerifyMobile extends StatefulWidget {
  final String mobileNumber;
  final Function next;
  CreateVerifyMobile({Key key, @required this.mobileNumber, this.next}) : super(key: key);

  @override
  _CreateVerifyMobileState createState() => _CreateVerifyMobileState();
}

class _CreateVerifyMobileState extends State<CreateVerifyMobile> with TickerProviderStateMixin {
  TextEditingController codeController = TextEditingController();
  StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();

  String currentText = "";
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool hasError = false;
  bool otpSent = false;
  String otp;
  Timer _timer;
  int counter = 30;
  var respstatus;
  var jEmail;
  void _startTimer() {
    counter = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (counter > 0) {
        if (this.mounted) {
          setState(() {
            counter--;
          });
        }
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    codeController.dispose();
  }

  @override
  void initState() {
    super.initState();
    sendOtp(context);
  }

  Future<String> genOTP(number, jEmail) async {
    http.Client _client = http.Client(); //3gb
    final response = await _client.get(Uri.parse(API.iHLUrl +
        "/login/send_registration_otp_verify?email=" +
        jEmail +
        "&mobile=" +
        number +
        "&from=mobile"));
    if (response.statusCode == 200) {
      if (response.body != null || response.body != "[]") {
        var output = json.decode(response.body);
        respstatus = output["status"];
        otp = output["OTP"];
        print(otp);
      }
    }

    return otp.toString();
  }

  Future<String> test() {
    return Future.delayed(
        Duration(
          seconds: 1,
        ),
        () => 'sent');
  }

  String message({String otp}) {
    return 'Dear IHL User, Your One Time Password for verification is: ' + otp;
  }

  Future<dynamic> sendMessageApi({String otp}) async {
    http.Client _client = http.Client(); //3gb
    final resp = await _client.get(
        Uri.parse(otpServiceEndpoint(message: message(otp: otp), mobile: widget.mobileNumber)));
    return resp.body;
  }

  Future<void> sendOtp(BuildContext context) async {
    if (this.mounted) {
      setState(() {
        otpSent = false;
      });
    }
    jEmail = SpUtil.getString('jEmail');
    var genotp = await genOTP(widget.mobileNumber, jEmail);
    // var resp = await sendMessageApi(otp: genotp);
    if (respstatus == 'sent_sucess') {
      if (this.mounted) {
        setState(() {
          otpSent = true;
          otp = genotp;
          _startTimer();
          currentText = '';
          codeController.clear();
        });
      }
    } else {
      Navigator.of(context).pop(false);
    }
  }

  Widget codeTextField() {
    return PinCodeTextField(
      appContext: context,
      backgroundColor: Color(0xffF4F6FA),
      length: 6,
      obscureText: false,
      animationType: AnimationType.fade,
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.circle,
        activeColor: Color(0xffDBEEFC),
        inactiveColor: AppColors.primaryColor,
        activeFillColor: AppColors.primaryColor,
        fieldHeight: 50,
        fieldWidth: 40,
      ),
      validator: (v) {
        if (v.length != 6) {
          return "Invalid OTP";
        } else {
          if (v != otp) {
            return "Incorrect OTP";
          } else {
            return null;
          }
        }
      },
      animationDuration: Duration(milliseconds: 300),
      errorAnimationController: errorController,
      controller: codeController,
      errorTextSpace: 20,
      onCompleted: (v) {},
      autoDisposeControllers: false,
      onChanged: (value) {
        if (this.mounted) {
          setState(() {
            currentText = value;
          });
        }
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
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 5,
                    child: LinearProgressIndicator(
                      value: 0.5, // percent filled
                      backgroundColor: Color(0xffDBEEFC),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pushNamed(Routes.Cmobilenumber),
                color: Colors.black,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    _formKey.currentState.validate();
                    if (currentText.length != 4 || currentText != otp) {
                      errorController
                          .add(ErrorAnimationType.shake); // Triggering error shake animation
                      if (this.mounted) {
                        setState(() {
                          hasError = true;
                        });
                      }
                    } else {
                      if (this.mounted) {
                        setState(() {
                          hasError = false;
                        });
                      }
                    }
                    if (_formKey.currentState.validate()) {
                      Navigator.of(context).pushNamed(Routes.Cdob);
                    } else {
                      if (this.mounted) {
                        setState(() {
                          _autoValidate = true;
                        });
                      }
                    }
                  },
                  child: Text(AppTexts.next,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: ScUtil().setSp(16),
                      )),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      color: Color(0xFF19a9e5),
                    ),
                    shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
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
                    Text(
                      AppTexts.step4,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF19a9e5),
                          fontFamily: 'Poppins',
                          fontSize: ScUtil().setSp(12),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          height: 1.16),
                    ),
                    SizedBox(
                      height: 6 * SizeConfig.heightMultiplier,
                    ),
                    Text(
                      'Verify your number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(109, 110, 113, 1),
                          fontFamily: 'Poppins',
                          fontSize: ScUtil().setSp(26),
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                          height: 1.33),
                    ),
                    SizedBox(
                      height: 1 * SizeConfig.heightMultiplier,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                      child: Text(
                        AppTexts.familysubtxt,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(109, 110, 113, 1),
                            fontFamily: 'Poppins',
                            fontSize: ScUtil().setSp(13),
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.normal,
                            height: 1),
                      ),
                    ),
                    SizedBox(
                      height: 3 * SizeConfig.heightMultiplier,
                    ),
                    otpSent
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                                child: Text(
                                  'We have sent OTP to you on ${widget.mobileNumber} and $jEmail',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromRGBO(109, 110, 113, 1),
                                      fontFamily: 'Poppins',
                                      fontSize: ScUtil().setSp(15),
                                      letterSpacing: 0.2,
                                      fontWeight: FontWeight.normal,
                                      height: 1),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                                  child: Text(
                                    'Please wait while we\'re sending OTP on ${widget.mobileNumber} and $jEmail',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color.fromRGBO(109, 110, 113, 1),
                                        fontFamily: 'Poppins',
                                        fontSize: ScUtil().setSp(15),
                                        letterSpacing: 0.2,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 70),
                                  child: LinearProgressIndicator(),
                                )
                              ],
                            ),
                          ),
                    AbsorbPointer(
                      absorbing: !otpSent,
                      child: Opacity(
                        opacity: otpSent ? 1 : 0,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 6 * SizeConfig.heightMultiplier,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 50),
                              child: codeTextField(),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextButton(
                              onPressed: counter > 0
                                  ? null
                                  : () {
                                      sendOtp(context);
                                    },
                              child: Text(
                                  counter > 0
                                      ? 'Please wait ${counter.toString()} seconds to request new code'
                                      : 'Send me a new code',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScUtil().setSp(14),
                                  )),
                              style: TextButton.styleFrom(
                                textStyle: TextStyle(
                                  color: Color(0xFF19a9e5),
                                ),
                                shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                              ),
                            ),
                            SizedBox(
                              height: 6 * SizeConfig.heightMultiplier,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                              child: Center(
                                child: _customButton(),
                              ),
                            ),
                          ],
                        ),
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

  Widget _customButton() {
    return Container(
      height: 60,
      child: GestureDetector(
        onTap: () {
          _formKey.currentState.validate();
          if (currentText.length != 4 || currentText != otp) {
            errorController.add(ErrorAnimationType.shake); // Triggering error shake animation
            if (this.mounted) {
              setState(() {
                hasError = true;
              });
            }
          } else {
            if (this.mounted) {
              setState(() {
                hasError = false;
              });
            }
          }
          if (_formKey.currentState.validate()) {
            if (widget.next == null) {
              Navigator.of(context).pushNamed(Routes.Cpassword);
            } else {
              widget.next(context);
            }
          } else {
            if (this.mounted) {
              setState(() {
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
                child: Text(
                  AppTexts.continuee,
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
    );
  }
}
