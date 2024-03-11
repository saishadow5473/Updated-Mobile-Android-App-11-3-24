import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../utils/SpUtil.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../new_design/app/utils/appColors.dart';
import '../../repositories/api_register.dart';

class SsoWaitingScreen extends StatefulWidget {
  String ssoToken;
  SsoWaitingScreen({Key key, this.ssoToken}) : super(key: key);

  @override
  State<SsoWaitingScreen> createState() => _SsoWaitingScreenState();
}

class _SsoWaitingScreenState extends State<SsoWaitingScreen> {
  @override
  void initState() {
    asyncFunction(widget.ssoToken);
    super.initState();
  }

  asyncFunction(String ssoToken) async {
    String fnameController = SpUtil.getString('fname');
    String lnameController = SpUtil.getString('lname');
    String userRegister = await RegisterUserWithPic().registerUser(
        firstName: fnameController,
        lastName: lnameController,
        email: '',
        password: '',
        isSso: true,
        ssoToken: ssoToken);
    if (userRegister == 'User Registration Failed') {
      Navigator.pop(context);
      AwesomeDialog(
          context: context,
          animType: AnimType.TOPSLIDE,
          headerAnimationLoop: false,
          dialogType: DialogType.ERROR,
          dismissOnTouchOutside: true,
          title: 'Failed!',
          desc: 'Registration failed\nTry Again',
          onDismissCallback: (_) {
            debugPrint('Dialog Dissmiss from callback');
          }).show();

      setState(() {});
    } else {
      Get.off(LandingPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.only(top: 30.sp, bottom: 15.sp, left: 20.sp),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello.',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: .5),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      'Welcome Onboard',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w300,
                        fontSize: 17,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
                SizedBox(
                  height: 80.sp,
                  child: Center(
                    child: Image.asset(
                      "assets/gif/onboardingGIF.gif",
                      height: 60.sp,
                      width: 60.sp,
                    ),
                  ),
                ),
                SizedBox(
                  height: 11.sp,
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
