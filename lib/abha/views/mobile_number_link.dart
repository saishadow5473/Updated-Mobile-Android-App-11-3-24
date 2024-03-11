import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/abha/networks/network_calls_abha.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/views/screens.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class MobileNumberLink extends StatefulWidget {
  MobileNumberLink({Key key}) : super(key: key);

  @override
  State<MobileNumberLink> createState() => _MobileNumberLinkState();
}

class _MobileNumberLinkState extends State<MobileNumberLink> {
  TextEditingController otpInput = new TextEditingController();
  var phoneno;
  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userData);
    Map res = jsonDecode(data);
    phoneno = res['User']['mobileNumber'];
  }

  bool isLoading = false;
  String otp = '';
  verifyOtp(String otp) async {
    setState(() {
      isLoading = true;
    });
    print(otp);
    var res = await NetworkCallsAbha().confirmAuthAndStoreData(otp);
    print(res);
    if (res == 'success') {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.SurveyProceed, (Route<dynamic> route) => false);
    }
    setState(() {
      isLoading = false;
    });
  }

  final formKey = GlobalKey<FormState>();
  var box = new GetStorage();

  @override
  void initState() {
    var mobile = box.read("userMobileNumber");
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 48.sp,
                  fit: BoxFit.fill,
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/images/Group 25.png',
                  height: 48.sp,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 18.sp,
              ),
              Padding(
                padding: EdgeInsets.all(15.sp),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'OTP VERIFICATION',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'Poppins',
                      color: Color(0xFF19a9e5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15.sp),
                child: Center(
                  child: Text(
                    'In order to link your Abha account with IHL account, Enter the OTP received on your mobile number ${mobile}',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Color.fromARGB(255, 87, 87, 87),
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15.sp),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'One Time Password',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'Poppins',
                      color: Color.fromARGB(255, 83, 83, 83),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Form(
                key: formKey,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 28.sp),
                    child: PinCodeTextField(
                      controller: otpInput,
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      obscureText: true,
                      obscuringCharacter: '*',
                      blinkWhenObscuring: true,
                      pinTheme: PinTheme(
                          shape: PinCodeFieldShape.circle,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 60,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Color.fromARGB(255, 228, 227, 227),
                          activeColor: Colors.black,
                          inactiveColor: Color.fromARGB(255, 99, 99, 99)),
                      cursorColor: Colors.black,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      //  errorAnimationController: errorController,
                      //  controller: textEditingController,
                      keyboardType: TextInputType.number,
                      boxShadows: const [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.black12,
                          blurRadius: 10,
                        )
                      ],
                      onCompleted: (v) {
                        debugPrint("Completed");
                      },

                      validator: (v) {
                        if (v.length != 6) {
                          return "Invalid Otp";
                        } else {
                          return null;
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          otp = value;
                        });
                      },
                      beforeTextPaste: (text) {
                        debugPrint("Allowing to paste $text");
                        return true;
                      },
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.sp, right: 20.sp, top: 20.sp, bottom: 24.sp),
                child: GestureDetector(
                  onTap: () {},
                  child: RichText(
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.end,
                    textDirection: TextDirection.rtl,
                    softWrap: true,
                    textScaleFactor: 1,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Did not receive otp ?',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 63, 63, 63),
                            )),
                        TextSpan(
                            text: ' Resend',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'Poppins',
                                color: Color(0xFF19a9e5),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  formKey.currentState.validate();
                  verifyOtp(otp);
                },
                child: Container(
                  height: 7.h,
                  width: 65.w,
                  decoration: BoxDecoration(
                      color: Color(0xFF19a9e5), borderRadius: BorderRadius.circular(15.sp)),
                  child: Center(
                      child: !isLoading
                          ? Text(
                              'Verify & Proceed',
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : CircularProgressIndicator(
                              color: Colors.white,
                            )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
