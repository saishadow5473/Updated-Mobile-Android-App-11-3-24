import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/abha/networks/network_calls_abha.dart';
import 'package:ihl/abha/views/abha_id_download.dart';
import 'package:ihl/abha/views/abha_otp.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:sizer/sizer.dart';

import '../clipPath/Custom_clip_art.dart';

class AbhaAccountLogin extends StatefulWidget {
  AbhaAccountLogin({Key key, @required this.abhaTextField}) : super(key: key);
  String abhaTextField;
  @override
  State<AbhaAccountLogin> createState() => _AbhaAccountLoginState();
}

class _AbhaAccountLoginState extends State<AbhaAccountLogin> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController mobileNumber = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController aadharNumber = new TextEditingController();
  TextEditingController abhaAddress = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: Text("ABHA Health ID", style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: height / 3,
                child: Stack(
                  children: [
                    ClipPath(
                      clipper: CustomClipPath(),
                      child: Container(
                        height: height / 5,
                        decoration: BoxDecoration(
                          color: Color(0XFFdef3fc),
                        ),
                      ),
                    ),
                    Container(
                      height: height / 3.2,
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          customImages(
                              title: "Get Records\nDigility",
                              imagePath: "assets/images/Group 1718.png",
                              color: Color(0xffb9c770)),
                          Transform.translate(
                              offset: Offset(0, 35),
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: customImages(
                                      title: "Store\nRecords",
                                      imagePath: "assets/images/Group 1729.png",
                                      color: Color(0xff6aa6ab)))),
                          customImages(
                              title: "Share\nRecords",
                              imagePath: "assets/images/Group 1728.png",
                              color: Color(0xff7ab290)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 28),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Link with your ABHA Account',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'Poppins',
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Visibility(
                        visible: widget.abhaTextField.toLowerCase() == "aadhar",
                        child: TextFormField(
                          controller: aadharNumber,
                          validator: (str) {
                            if (str.length == 0) {
                              return "Enter your Aadhar number";
                            } else if (str.length < 12 || str.length > 12) {
                              return "Enter 12 Digit number";
                            }
                            return null;
                          },
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Enter your 12 digit Aadhar number'),
                        ),
                      ),
                      Visibility(
                        visible: widget.abhaTextField.toLowerCase() == "phonenumber",
                        child: TextFormField(
                          controller: mobileNumber,
                          validator: (str) {
                            if (str.length == 0) {
                              return "field not empty";
                            } else if (str.length < 10 || str.length > 10) {
                              return "invalid";
                            }
                            return null;
                          },
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "Enter your ABHA related Mobile Number",
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.abhaTextField.toLowerCase() == "email",
                        child: TextFormField(
                          controller: email,
                          validator: (str) {
                            if (str.length == 0) {
                              return "field not empty";
                            } else if (str.length > 60) {
                              return "invalid";
                            }
                            return null;
                          },
                          // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "Enter your Email address",
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.abhaTextField.toLowerCase() == "password",
                        child: Column(
                          children: [
                            TextFormField(
                              controller: abhaAddress,
                              validator: (str) {
                                if (str.length == 0) {
                                  return "Enter your Aabha Address";
                                } else if (str.length > 16) {
                                  return 'invalid';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: "Enter your ABHA Address",
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: password,
                              validator: (str) {
                                if (str.length == 0) {
                                  return "Enter your Aabha Password";
                                } else if (str.length > 12) {
                                  return "Password  must have 8 characters";
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: "Enter your ABHA Password",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  setState(() {
                    isLoading = true;
                  });
                  if (_formKey.currentState.validate()) {
                    if (widget.abhaTextField.toLowerCase() == "phonenumber") {
                      var box = new GetStorage();
                      box.write("userMobileNumber", mobileNumber.text);
                      if (registrationAfterLoggedIn == false) {
                        var response =
                            await NetworkCallsAbha().checkAbhaUserOrnot(mobileNumber.text);
                        final box = GetStorage();
                        box.write("mobileNo", mobileNumber.text);
                        if (response == 'success') {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => AbhaOtpScreen(
                                        screen: "LoggedInMobile",
                                      ))));
                        }
                        print(response == null);
                        if (response == null) {
                          setState(() {
                            isLoading = false;
                          });
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              content: const Text("You don't have abha account"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Container(
                                    color: Colors.blue,
                                    padding: const EdgeInsets.all(12),
                                    child: const Text(
                                      "cancel",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.close(1);
                                    Get.to(AbhaAccountLogin(abhaTextField: 'aadhar'));
                                  },
                                  child: Container(
                                    color: Colors.blue,
                                    padding: const EdgeInsets.all(12),
                                    child: const Text(
                                      "Create",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                      if (registrationAfterLoggedIn == true) {
                        String userExistenceCheck =
                            await NetworkCallsAbha().checkAbhaUserOrnot(mobileNumber.text);
                        if (userExistenceCheck == 'success') {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => AbhaOtpScreen(
                                        screen: "aadharUserCheckAf" + "+" + mobileNumber.text,
                                      ))));
                        } else {
                          var reponse1 =
                              await NetworkCallsAbha().generateMobileOtp(mobileNumber.text);
                          var response =
                              await NetworkCallsAbha().checkAndGenerateMobileOtp(mobileNumber.text);
                          if (response == 'success') {
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => AbhaOtpScreen(
                                          screen: "mobileAf",
                                        ))));
                          }
                        }
                      }
                    }
                    if (widget.abhaTextField.toLowerCase() == "aadhar") {
                      await NetworkCallsAbha().getAccessToken();
                      String response =
                          await NetworkCallsAbha().generateAadharOtp(aadharNumber.text);
                      print(response);
                      if (response == "success") {
                        SpUtil.putString('aadharNo', aadharNumber.text);
                        registrationAfterLoggedIn = true;
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => AbhaOtpScreen(
                                      screen: "LoggedInaadhar",
                                    ))));
                      }
                    }
                    if (widget.abhaTextField.toLowerCase() == "password") {
                      await NetworkCallsAbha().getAccessToken();
                      var response1 = await NetworkCallsAbha()
                          .loginWithPasswordAfterLoggedin(abhaAddress.text, password.text);
                      if (response1 == 'success') {
                        dynamic response2 = await NetworkCallsAbha().viewAbhadetails();
                        print(response2.isEmpty);
                        if (response2.isEmpty) {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AbhaAccountLogin(abhaTextField: "phonenumber")));
                        } else {
                          print(response2);
                          var healthid = response2[0]['abha_address'];
                          var abhaNumber = response2[0]['abha_number'];
                          String abhaCard = await NetworkCallsAbha().viewAbhaCard(healthid);
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AbhaIdDownloadScreen(
                                        abhaAddress: healthid,
                                        abhaCard: abhaCard,
                                        abhaNumber: abhaNumber,
                                      )));
                        }
                      }
                    }
                    if (widget.abhaTextField.toLowerCase() == "email") {
                      await NetworkCallsAbha().getAccessToken();
                      var response = await NetworkCallsAbha().emailAbhaLogin(email.text);
                      if (response == 'success') {
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => AbhaOtpScreen(
                                      screen: "LoggedInMobile",
                                    ))));
                      }
                      print(response == null);
                      if (response == null) {
                        setState(() {
                          isLoading = false;
                        });
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            content: const Text("You don't have abha account"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Container(
                                  color: Colors.blue,
                                  padding: const EdgeInsets.all(12),
                                  child: const Text(
                                    "cancel",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.close(1);
                                  Get.to(AbhaAccountLogin(abhaTextField: 'aadhar'));
                                },
                                child: Container(
                                  color: Colors.blue,
                                  padding: const EdgeInsets.all(12),
                                  child: const Text(
                                    "Create",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppColors.primaryColor, borderRadius: BorderRadius.circular(8.sp)),
                  child: !isLoading
                      ? Text(
                          'SUBMIT',
                          style: TextStyle(
                              fontSize: 16.5.sp,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30, top: 6, bottom: 6),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
              Visibility(
                visible: !(widget.abhaTextField.toLowerCase() == "password"),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
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
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text:
                                'By entering your Aadhar number you will be linked with Ayushman Bharat Health Account [ABHA].',
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
              ),
              // Visibility(
              //   visible: !(widget.abhaTextField.toLowerCase() == "password" &&
              //       widget.abhaTextField.toLowerCase() == "email" &&
              //       widget.abhaTextField.toLowerCase() == "phonenumber"),
              //   child: Padding(
              //     padding: EdgeInsets.only(right: 28),
              //     child: Align(
              //       alignment: Alignment.centerRight,
              //       child: InkWell(
              //         onTap: () {
              //           showDialog(
              //             context: context,
              //             builder: (ctx) => AlertDialog(
              //               backgroundColor: Colors.white,
              //               // content:
              //               actions: <Widget>[
              //                 SizedBox(
              //                   height: 15.sp,
              //                 ),
              //                 // SizedBox(height: 6.sp,),

              //                 Align(
              //                   alignment: Alignment.center,
              //                   child: Text(
              //                     "Select any option to Login",
              //                     style: TextStyle(
              //                         fontSize: 20,
              //                         fontWeight: FontWeight.bold,
              //                         color: Colors.black54),
              //                   ),
              //                 ),
              //                 SizedBox(
              //                   height: 15.sp,
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.only(left: 20, right: 20),
              //                   child: MaterialButton(
              //                     shape: RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(15.0)),
              //                     color: Colors.blue,
              //                     elevation: 10,
              //                     onPressed: () {
              //                       Get.to(AbhaAccountLogin(abhaTextField: "password"));
              //                     },
              //                     child: Row(
              //                       mainAxisAlignment: MainAxisAlignment.center,
              //                       children: [
              //                         Text(
              //                           "Sign In with Abha Address",
              //                           style: TextStyle(
              //                               color: Colors.white,
              //                               letterSpacing: 0.3,
              //                               fontWeight: FontWeight.w300),
              //                         )
              //                       ],
              //                     ),
              //                   ),
              //                 ),

              //                 SizedBox(
              //                   height: 9.sp,
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.only(left: 20, right: 20),
              //                   child: MaterialButton(
              //                     shape: RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(15.0)),
              //                     color: Colors.blue,
              //                     elevation: 10,
              //                     onPressed: () {
              //                       Get.to(AbhaAccountLogin(abhaTextField: "email"));
              //                     },
              //                     child: Row(
              //                       mainAxisAlignment: MainAxisAlignment.center,
              //                       children: [
              //                         Text("Sign In with Email Address",
              //                             style: TextStyle(
              //                                 color: Colors.white,
              //                                 letterSpacing: 0.3,
              //                                 fontWeight: FontWeight.w300))
              //                       ],
              //                     ),
              //                   ),
              //                 ),

              //                 SizedBox(
              //                   height: 12.sp,
              //                 ),
              //                 Text('')
              //               ],
              //             ),
              //           );
              //         },
              //         child: Text(
              //           'Login using other options',
              //           style: TextStyle(
              //             fontSize: 14.sp,
              //             fontFamily: 'Poppins',
              //             color: Colors.blue,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ));
  }

  Widget customImages({String title, imagePath, Color color}) {
    return SizedBox(
      width: 100.sp,
      height: 120.sp,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 50.sp,
            width: 50.sp,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(250)),
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Image.asset(
                imagePath,
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
                fontFamily: 'Poppins'),
          )
        ],
      ),
    );
  }
}
