import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/abha/networks/network_calls_abha.dart';
import 'package:ihl/abha/views/abha_otp.dart';
import 'package:ihl/abha/views/terms_conditions.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:sizer/sizer.dart';

import '../../constants/app_texts.dart';

class AbhaLoginScreen extends StatefulWidget {
  AbhaLoginScreen({Key key}) : super(key: key);

  @override
  State<AbhaLoginScreen> createState() => _AbhaLoginScreenState();
}

class _AbhaLoginScreenState extends State<AbhaLoginScreen> {
  @override
  bool value = false;
  var _formKey = GlobalKey<FormState>();
  TextEditingController aadharNumber = new TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    NetworkCallsAbha().getAccessToken();
    // NetworkCallsAbha().generateAadharOtp();
    super.initState();
  }

  void _submit() {
    if (value == false) {
      Get.showSnackbar(
        GetSnackBar(
          title: "Warning!!",
          message: 'you must agree to the terms and conditions',
          icon: const Icon(Icons.highlight_off_outlined),
          backgroundColor: AppColors.primaryColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      final isValid = _formKey.currentState.validate();
      if (!isValid) {
        return;
      }
      _formKey.currentState.save();
      getOtp();
    }
  }

  getOtp() async {
    setState(() {
      isLoading = true;
    });
    String response = await NetworkCallsAbha().generateAadharOtp(aadharNumber.text);
    print(response);
    setState(() {
      isLoading = false;
    });
    if (response == "success") {
      SpUtil.putString('aadharNo', aadharNumber.text);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => AbhaOtpScreen(
                    screen: "aadhar",
                  ))));
    }
    setState(() {
      isLoading = false;
    });
    //else try again after some time msg
  }

  Widget build(BuildContext context) {
    return Scaffold(
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
          onPressed: () {
            Get.back();
          },
          color: Colors.black,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _submit();
            },
            child: Text(AppTexts.next,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                )),
            style: TextButton.styleFrom(
                shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                textStyle: TextStyle(color: Color(0xFF19a9e5))),
          ),
        ],
      ),
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 5.0,
                ),
                Center(
                    child: Text(
                  'STEP 3/9',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                Container(
                  padding: EdgeInsets.fromLTRB(42.0.sp, 32.sp, 36.sp, 22.sp),
                  child: Text('Provide us your Aadhar Number',
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Poppins',
                          color: Color.fromRGBO(74, 75, 77, 1),
                          fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(20.sp),
                  child: TextFormField(
                    controller: aadharNumber,
                    keyboardType: TextInputType.number,
                    autocorrect: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 18.sp, horizontal: 28.sp),
                      labelText: "Aadhar number (optional)",
                      fillColor: Colors.white24,
                      border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                          borderSide: new BorderSide(color: Colors.blueGrey)),
                    ),
                    maxLines: 1,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter a correct aadhar number!';
                      }
                      if (value.length != 12) {
                        return 'Enter a valid aadhar number!';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 16.0),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: RichText(
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.end,
                    textDirection: TextDirection.rtl,
                    softWrap: true,
                    textScaleFactor: 1,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Note : ',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontFamily: 'Poppins',
                                color: Colors.blue,
                                fontWeight: FontWeight.w200)),
                        TextSpan(
                            text:
                                'By entering your Aadhar number you will be linked with Ayushman Bharat Health Account [ABHA] Your ABHA ID will be generated automatically .',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w200,
                              color: Color.fromARGB(255, 63, 63, 63),
                            )),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(14.sp),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: this.value,
                        onChanged: (bool value) {
                          setState(() {
                            this.value = value;
                          });
                        },
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(TermsAndConditions());
                        },
                        child: Text(
                          'I agree to the Terms & Conditions',
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontFamily: 'Poppins',
                              color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    abhaSkipped = true;
                    Navigator.of(context).pushNamed(Routes.Sdob);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 13.sp, left: 17.sp, right: 17.sp, bottom: 17.sp),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        'Skip & Proceed',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 21.sp,
                ),
                GestureDetector(
                  onTap: () {
                    _submit();
                  },
                  child: Container(
                      height: 38.sp,
                      width: 124.sp,
                      decoration: BoxDecoration(
                          color: Color(0xFF19a9e5), borderRadius: BorderRadius.circular(12.sp)),
                      child: Center(
                        child: !isLoading
                            ? Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                      )),
                )
              ],
            ),
          )),
    );
  }
}
