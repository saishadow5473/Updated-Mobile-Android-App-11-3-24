import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/abha/networks/network_calls_abha.dart';
import 'package:ihl/abha/views/abha_account.dart';
import 'package:ihl/abha/views/abha_id_download.dart';
import 'package:ihl/abha/views/abha_mapped_accounts.dart';
import 'package:ihl/abha/views/abha_mobile.dart';
import 'package:ihl/abha/views/abha_password.dart';
import 'package:ihl/abha/views/signin_abha.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/new_design/presentation/pages/profile/profile_screen.dart';
import 'package:ihl/tabs/profiletab.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

class AbhaOtpScreen extends StatefulWidget {
  final screen;
  const AbhaOtpScreen({Key key, this.screen}) : super(key: key);

  @override
  State<AbhaOtpScreen> createState() => _AbhaOtpScreenState();
}

class _AbhaOtpScreenState extends State<AbhaOtpScreen> {
  bool isLoading = false;
  var box = new GetStorage();
  final formKey = GlobalKey<FormState>();
  var mobile;
  String otp = '';
  @override
  void initState() {
    mobile = box.read("userMobileNumber");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController otpInput = new TextEditingController();
    verifyOtp() async {
      print(widget.screen);
      setState(() {
        isLoading = true;
      });
      print(otpInput);
      print(otp);
      if (widget.screen == "finalRegistration") {
        var res = await NetworkCallsAbha().confirmAuthAndStoreData(otp);

        if (res == 'success') {
          dynamic response1 = await NetworkCallsAbha().viewAbhadetails();
          print(response1.isEmpty);
          if (response1.isEmpty) {
            setState(() {
              isLoading = false;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AbhaAccountLogin(abhaTextField: "phonenumber")));
          } else {
            print(response1);
            var healthid = response1[0]['abha_address'];
            var abhaNumber = response1[0]['abha_number'];
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

      if (widget.screen == "aadhar") {
        String response = await NetworkCallsAbha().verifyAadharOtp(otp);
        if (response == 'success') {
          setState(() {
            isLoading = false;
          });
          Navigator.push(context, MaterialPageRoute(builder: ((context) => AbhaMobileLogin())));
        }
        if (response != 'success') {
          Get.showSnackbar(
            GetSnackBar(
              title: "Error Occured!!",
              message: response.toString(),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      if (widget.screen == "LoggedInaadhar") {
        String response = await NetworkCallsAbha().verifyAadharOtp(otp);
        if (response == 'success') {
          abhaRegistraion = true;
          setState(() {
            isLoading = false;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => AbhaAccountLogin(abhaTextField: 'phonenumber'))));
        }
        if (response != 'success') {
          Get.showSnackbar(
            GetSnackBar(
              title: "Error Occured!!",
              message: response.toString(),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      if (widget.screen == "mobile") {
        String response = await NetworkCallsAbha().verifyMobileOtp(otp);
        //var a = gs.read(GSKeys.isSSO);
        // if (a == null) {
        //   gs.write(GSKeys.isSSO, false);
        //   print(gs.read(GSKeys.isSSO));
        // }
        // if (response == 'success') {
        //   if (gs.read(GSKeys.isSSO)) {
        //     Get.to(() => SignupDobSso());
        //   } else {

        // }
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pushNamed(Routes.Sdob);

        if (response.contains('Please enter the correct OTP')) {
          Get.showSnackbar(
            GetSnackBar(
              title: "Error Occured!!",
              message: response.toString(),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      if (widget.screen == 'LoggedInMobile') {
        String response = await NetworkCallsAbha().loginOtpVerfication(otp);
        if (response == 'ExistingUser') {
          setState(() {
            isLoading = false;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => AbhaMappedAccounts(
                        screen: 'AfterLoggedIn',
                      ))));
        }
        if (response == 'newUser') {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              content: const Text("You don't have abha account"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Get.to(ProfileTab(
                      editing: false,
                      showdel: false,
                    ));
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
        if (response.contains('Please enter the correct OTP')) {
          Get.showSnackbar(
            GetSnackBar(
              title: "Error Occured!!",
              message: response.toString(),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      if (widget.screen == "mobileUserCheck") {
        String response = await NetworkCallsAbha().loginOtpVerfication(otp);
        if (response == 'ExistingUser') {
          setState(() {
            isLoading = false;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => AbhaMappedAccounts(
                        screen: 'beforeLogIn',
                      ))));
        }
        if (response == 'newUser') {
          setState(() {
            isLoading = false;
          });
          Navigator.push(context, MaterialPageRoute(builder: ((context) => AbhaLoginScreen())));
        }
        if (response.contains('Please enter the correct OTP')) {
          Get.showSnackbar(
            GetSnackBar(
              title: "Error Occured!!",
              message: response.toString(),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      List s = widget.screen.split('+');
      if (s[0] == "aadharUserCheck") {
        String response = await NetworkCallsAbha().loginOtpVerfication(otp);
        if (response.toString() == 'ExistingUser') {
          setState(() {
            isLoading = false;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => AbhaMappedAccounts(
                        screen: 'beforeLogIn',
                      ))));
        }
        if (response.toString() == 'newUser') {
          var box = new GetStorage();
          var mobile = box.read("userMobileNumber");
          // var reponse1 = await NetworkCallsAbha().generateMobileOtp(s[1].toString());
          // var response = await NetworkCallsAbha().checkAndGenerateMobileOtp(s[1].toString());
          var reponse1 = await NetworkCallsAbha().generateMobileOtp(mobile);
          var response = await NetworkCallsAbha().checkAndGenerateMobileOtp(mobile);
          if (response == 'success') {
            setState(() {
              isLoading = false;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => AbhaOtpScreen(
                          screen: "mobile",
                        ))));
          }
        }
        if (response.contains('Please enter the correct OTP')) {
          Get.showSnackbar(
            GetSnackBar(
              title: "Error Occured!!",
              message: response.toString(),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      if (s[0] == "aadharUserCheckAf") {
        String response = await NetworkCallsAbha().loginOtpVerfication(otp);
        if (response.toString() == 'ExistingUser') {
          setState(() {
            isLoading = false;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => AbhaMappedAccounts(
                        screen: 'AfterLoggedIn',
                      ))));
        }
        if (response.toString() == 'newUser') {
          var box = new GetStorage();
          var mobile = box.read("userMobileNumber");
          var reponse1 = await NetworkCallsAbha().generateMobileOtp(mobile);
          var response = await NetworkCallsAbha().checkAndGenerateMobileOtp(mobile);
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
      if (widget.screen == "mobileAf") {
        String response = await NetworkCallsAbha().verifyMobileOtp(otp);
        if (response == 'success') {
          setState(() {
            isLoading = false;
          });
          Navigator.push(context, MaterialPageRoute(builder: ((context) => AbhaPasswordScreen())));
        }
        if (response != 'success') {
          Get.showSnackbar(
            GetSnackBar(
              title: "Error Occured!!",
              message: response.toString(),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      setState(() {
        isLoading = false;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 13.h,
                  fit: BoxFit.fill,
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/images/Group 25.png',
                  height: 12.h,
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
                      fontSize: 16.sp,
                      fontFamily: 'Poppins',
                      color: Color(0xFF19a9e5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.sp),
                child: Text(
                  widget.screen == 'finalRegistration'
                      ? 'In order to link your Abha account with IHL account, Enter the OTP received on your mobile number'
                      : widget.screen.toString().contains('aadhar')
                          ? 'Enter the OTP received on mobile number, which is linked with your Aadhar'
                          : 'Enter the OTP received on mobile number, ${mobile}',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                      color: Color.fromARGB(255, 87, 87, 87),
                      fontWeight: FontWeight.w300),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.sp),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'One Time Password',
                    style: TextStyle(
                      fontSize: 14.sp,
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

                      // obscuringWidget: const FlutterLogo(
                      //   size: 24,
                      // ),
                      blinkWhenObscuring: true,
                      //animationType: AnimationType.fade,
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
              Visibility(
                visible: widget.screen == 'aadhar',
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 20.sp,
                      right: 20.sp,
                      top: 2.sp,
                      bottom: widget.screen == 'aadhar' ? 20.sp : 23.sp),
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.screen == "aadhar") {
                        await NetworkCallsAbha().resendOtp();
                      }
                    },
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
                                fontSize: 13.sp,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 63, 63, 63),
                              )),
                          TextSpan(
                              text: ' Resend',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF19a9e5),
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  abhaSkipped = true;
                  print(widget.screen);
                  if (widget.screen == 'LoggedInaadhar' ||
                      widget.screen == 'aadharUserCheckAf+9600700114' ||
                      widget.screen == 'moobileAf' ||
                      widget.screen == 'LoggedInMobile') {
                    Get.to(Profile());
                  } else {
                    Navigator.of(context).pushNamed(Routes.Sdob);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 17.sp, right: 10.sp, bottom: widget.screen == 'aadhar' ? 15.sp : 23.sp),
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
              GestureDetector(
                onTap: () {
                  formKey.currentState.validate();
                  verifyOtp();
                },
                child: Container(
                  height: 7.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                      color: Color(0xFF19a9e5), borderRadius: BorderRadius.circular(12.sp)),
                  child: Center(
                      child: !isLoading
                          ? Text(
                              'Verify & Proceed',
                              style: TextStyle(
                                fontSize: 14.sp,
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
